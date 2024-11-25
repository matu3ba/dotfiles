// Tested with
// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default ./example/common.cpp
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default ./example/common.cpp

#include <fstream>    // std::ifstream
#include <sstream>    // std::stringstream
#include <string>     // std::string
#include <sys/stat.h> // stat + fstat

// C and C++, being both annoying want to hide the fact that
// we are operating on file descriptors and instead provides
// us with "a pointer to opaque".
// So the second option is unnecessary annoying.
// C++26 should fix this
long GetFileSize(std::string filename);
long GetFileSize(std::string filename) {
  struct stat stat_buf;
  int rc = stat(filename.c_str(), &stat_buf);
  return rc == 0 ? stat_buf.st_size : -1;
}

long FdGetFileSize(int fd);
long FdGetFileSize(int fd) {
  struct stat stat_buf;
  int rc = fstat(fd, &stat_buf);
  return rc == 0 ? stat_buf.st_size : -1;
}

void read(std::string &path);
void read(std::string &path) {
  std::ifstream t(path, std::ios::binary); // std::os::app, std::ios::ate
  std::stringstream buffer;
  buffer << t.rdbuf();
  std::string buffer_string = buffer.str();
}

void write(std::string &path, std::string &buffer);
void write(std::string &path, std::string &buffer) {
  std::ofstream ostrm(path, std::ios::binary); // os::trunc, ios::app
  ostrm.write(buffer.c_str(), static_cast<std::streamsize>(buffer.length()));
}

int32_t main() { return 0; }
