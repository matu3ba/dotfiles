//! Simple non-blocking server to write data changes to connecting sockets.
//! Main reason is to copy paste java boilerplate once I need it again.
//! Pendant is client.java.
package dotfiles.templates.nonblocking_tcp;
import java.io.*;
import java.net.*;
import java.nio.ByteBuffer;
import java.nio.channels.*;
import java.util.*;

public class Server {
  InetAddress host = null;
  Selector selector = null;
  ServerSocketChannel socket_channel = null;
  SelectionKey key = null;

  public void init(int port) throws Exception {
    host = InetAddress.getByName("localhost"); // can_throw
    selector = Selector.open(); // can_throw
    socket_channel = ServerSocketChannel.open(); // can_throw
    socket_channel.configureBlocking(false); // can_throw
    socket_channel.bind(new InetSocketAddress(host, port)); // can_throw
    socket_channel.register(selector, SelectionKey.OP_ACCEPT); // can_throw
  }

  public void deinit() {
    host = null;
    selector = null;
    socket_channel = null;
    key = null;
  }

  public void serve() {
    while (true) {
      int sel = selector.select(); // can_throw
      if (sel <= 0) continue;
      Set<SelectionKey> selectedKeys = selector.selectedKeys();
      Iterator<SelectionKey> iterator = selectedKeys.iterator();
      while (iterator.hasNext()) {
        key = (SelectionKey)iterator.next();
        iterator.remove();
        if (key.isAcceptable()) {
          SocketChannel sc = socket_channel.accept(); // can_throw
          sc.configureBlocking(false); // can_throw
          sc.register(selector, SelectionKey.OP_READ); // can_throw
          System.err.println("New Connection Accepted: " + sc.getLocalAddress()); // can_throw
        }
        if (key.isReadable()) {
          SocketChannel sc = (SocketChannel) key.channel();
          ByteBuffer bb = ByteBuffer.allocate(1024); // buffer for bytes, not objects
          int bcount = sc.read(bb); // can_throw
          if (bcount <= 0) {
            sc.close(); // can_throw
            System.err.println("Connection closed...");
            System.err.println(
              "Server will keep running. " +
              "Try running another client to " +
              "re-establish connection");
          } else {
            String result = new String(bb.array()).trim(); // ascii encoded
            System.err.println("Message received: " + result + " Message length= " + result.length());
            // echo msg
            ByteBuffer bb_echo = ByteBuffer.wrap(result.getBytes());
            sc.write(bb); // can_throw
          }
        }
      }
      // exit condition
    }
  }

  private static void printStackTrace() {
    System.err.print(Arrays.toString(Thread.currentThread().getStackTrace()).replace( ',', '\n' ));
  }
  private static int panic(int status) {
    printStackTrace();
    return status;
  }
  public static void main(String[] args) throws Exception {
    int st = -1;
    Server server = new Server();
    server.init(1234);
    server.serve();
    server.deinit();
  }
}


// void serve_forever(const uint16_t port_poll) {
// startServer
// loop:
//   free up disconnected connections
//   handle incomping tcp connection
//   write data
//   remember data
