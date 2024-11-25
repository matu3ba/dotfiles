//! Simple server to write data changes to connecting sockets.
//! Main reason is to get the netinet.h usage for static linking.

// #include <time.h> // C11
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h> // TCP_NODELAY
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
// #include <arpa/inet.h>
// #include <asm-generic/errno-base.h>
// #include <asm-generic/errno.h>
#include <stdbool.h>
#include <unistd.h> // usleep needs C11 and/or posix extensions

#define CONNMAX 5

// must be put into header, but for simplicity we make it static here
// Optionally, use `extern bool g_stop` in the header.
static bool g_stop = false;

// forward declare
void setnonblocking(int sock);
void startServer(uint16_t const port, int *listenfd);
void server_forever(uint16_t const port_poll);

void setnonblocking(int sock) {
  int opt;

  opt = fcntl(sock, F_GETFL);
  if (opt < 0) {
    perror("could not execute fcntl F_GETFL");
    exit(1);
  }
  opt |= O_NONBLOCK;
  if (fcntl(sock, F_SETFL, opt) < 0) {
    perror("could not execute fcntl F_SETFL");
    exit(1);
  }
}

void startServer(uint16_t const port, int *listenfd) {
  // static char addr_str[NI_MAXHOST];
  int addr_family;
  //int ip_protocol;
  struct sockaddr_in6 source_addr; // can contain Ipv4 and Ipv6
  memset(&source_addr, 0, sizeof(source_addr));
  //struct in_addr source_addr;
  struct sockaddr_in6 dest_addr;
  memset(&dest_addr, 0, sizeof(dest_addr));

  dest_addr.sin6_family = AF_INET6;
  dest_addr.sin6_port = htons(port);
  addr_family = AF_INET6;

  *listenfd = socket(addr_family, SOCK_STREAM, 0);
  if (*listenfd < 0) {
    perror("unable to create socket");
    exit(1);
  }
  // 1 - on, 0 - off
  int opt_REUSEADDR = 1;
  int opt_NODELAY = 1;
  int st = setsockopt(*listenfd, SOL_SOCKET, SO_REUSEADDR, &opt_REUSEADDR, sizeof(opt_REUSEADDR));
  if (st < 0) {
    perror("set socket option SO_REUSEADDR failed");
    close(*listenfd);
    exit(1);
  }
  st = setsockopt(*listenfd, IPPROTO_TCP, TCP_NODELAY, &opt_NODELAY, sizeof(opt_NODELAY));
  if (st < 0) {
    perror("set socket option TCP_NODELAY failed");
    close(*listenfd);
    exit(1);
  }
  st = bind(*listenfd, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
  if (st != 0) {
    perror("unable to bind socket");
    close(*listenfd);
    exit(1);
  }
  // listen for 10_000 incoming connections
  st = listen(*listenfd, 10000);
  if (st != 0) {
    perror("listen() error");
    shutdown(*listenfd, SHUT_RDWR);
    close(*listenfd);
    exit(1);
  }
}

struct data_t {
  uint8_t some;
  uint8_t data;
};

static int clients[CONNMAX];

void server_forever(uint16_t const port_poll) {
  struct sockaddr_in clientaddr;
  socklen_t addrlen;
  int slot = 0;
  int listenfd;
  startServer(port_poll, &listenfd);
  printf("Server started %shttp://127.0.0.1:%d%s\n", "\033[92m", port_poll, "\033[0m");
  // Ignore SIGCHLD to avoid zombie threads (this is the default on Posix, see :Man signal-safety)
  signal(SIGCHLD, SIG_IGN);
  setnonblocking(listenfd);

  struct data_t prev_data = {255, 255};

  // 1ms timeout to prevent flooding logs
  // Alternatively, one can use poll or notifications for the loop.
  while (!g_stop) {
    // free up disconnected file descriptors
    {
      char buf[10];
      int old_slot = slot;
      slot += 1;
      slot %= CONNMAX;
      while (slot != old_slot) {
        if (clients[slot] != -1) {
          ssize_t read_cnt = read(clients[slot], buf, 10);
          if (read_cnt == 0) {
            int st = shutdown(clients[slot], SHUT_RDWR);
            if (st == -1) {
              perror("shutdown error in tcp client");
              if (EBADF == st) {
                clients[slot] = -1;
              } else {
                close(clients[slot]);
                clients[slot] = -1;
              }
            } else {
              close(clients[slot]);
              clients[slot] = -1;
            }
          }
        }
        slot += 1;
        slot %= CONNMAX;
      }
    }

    // handle incoming tcp connections
    addrlen = sizeof(clientaddr);
    int client_tcp = accept(listenfd, (struct sockaddr *)&clientaddr, &addrlen);
    if (client_tcp < 0) {
      switch (errno) {
        case EWOULDBLOCK: // = EAGAIN
            ;
          break; // ok, we are non-blocking
        case EINTR:
          fprintf(stdout, "accept interrupted");
          break;
        case EOPNOTSUPP: // [[fallthrough]] ;
        case EINVAL:     // [[fallthrough]] ;
        case ENOTSOCK:
          perror("accept()");
          exit(1);
        default: {
          perror("accept():");
          break;
        }
      }
    } else {
      bool max_connections = false;
      int old_slot = slot;
      while (clients[slot] != -1) {
        slot += 1; // step
        slot %= CONNMAX;
        if (old_slot == slot) {
          fprintf(stderr, "max. connections, dropping last connection");
          int st = shutdown(client_tcp, SHUT_RDWR);
          if (st == -1) {
            perror("shutdown error in tcp client");
            if (EBADF == st) {
              clients[slot] = -1;
            } else {
              close(clients[slot]);
              clients[slot] = -1;
            }
          } else {
            close(clients[slot]);
            clients[slot] = -1;
          }
          max_connections = true;
        }
      }
      if (false == max_connections)
        clients[slot] = client_tcp;
    }

    // write data
    struct data_t cur_data = {
        1,
        2,
    };

    // write data, if updated data different.
    if (prev_data.some != cur_data.some || prev_data.data != cur_data.data) {
      char buf[20]; // x chars is length of formatter string
      int written = sprintf(buf, "some=%d,data=%d\n", cur_data.some, cur_data.data);
      if (written > 0) {
        int now_slot = slot;

        while (true) {
          if (clients[now_slot] != -1) {
            // printf("sending data in client_tcp %d..\n", clients[now_slot]);
            ssize_t bytes_send = send(clients[now_slot], buf, (size_t)written, MSG_NOSIGNAL);
            // printf("bytes_send: %d\n", bytes_send);
            if (bytes_send == -1) {
              switch (errno) {
                case EACCES:     // [[fallthrough]] ; // no access permissions
                case ENOTCONN:   // [[fallthrough]] ; // not connected
                case ECONNRESET: // [[fallthrough]] ; // connection reset
                case EPIPE: {
                  shutdown(clients[now_slot], SHUT_RDWR); // broken pipe
                  close(clients[now_slot]);
                  clients[now_slot] = -1;
                  break;
                }
                case EBADF:
                  clients[slot] = -1; // invalid fd => mark slot as free
                  break;
                case EINTR:
                  fprintf(stdout, "send interrupted"); // ignore
                  break;

                default:
                  break; // ignore
              }
              // client might have disconnected, which is handled before.
              // Log the error, which is not necessary fatal.
              perror("No data was send to client\n");
            }
          } else {
            // printf("now_slot %d in clients not active\n", now_slot);
          }
          now_slot += 1; // step
          now_slot %= CONNMAX;
          if (now_slot == slot)
            break;
        }
      } else {
        perror("FAIL: data loss, because insufficient buffer size");
      }
    }

    // assign data
    prev_data.some = cur_data.some;
    prev_data.data = cur_data.data;

    sleep(1);
  }

  printf("Stop server\n");
}

int32_t main(void) {}
