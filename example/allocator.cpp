// minimal bloat-free allocator usage for C++
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/allocator.cpp -o ./build/allocator.exe && ./build/allocator.exe
// https://badlydrawnrod.github.io/posts/2021/12/30/monotonic_buffer_resource/
// https://gist.github.com/louis-langholtz/c6f6759366fa384b9f01d7f06545fc0c
// https://gist.github.com/louis-langholtz/f780eacc762e53fccd52a0db33e3db01
// https://learn.microsoft.com/en-us/cpp/standard-library/allocators?view=msvc-170
#include <print>
#include <vector>

// necessary
// * a converting copy constructor (see example)
// * operator==
// * operator!=
// * allocate
// * deallocate

template<class T> struct Mallocator {
  typedef T value_type;
  Mallocator() noexcept {} //default ctor not required by C++ Standard Library

  // A converting copy constructor:
  template<class U> Mallocator(Mallocator<U> const &) noexcept {}
  template<class U> bool operator==(Mallocator<U> const &) const noexcept { return true; }
  template<class U> bool operator!=(Mallocator<U> const &) const noexcept { return false; }
  T *allocate(size_t const n) const;
  void deallocate(T *const p, size_t) const noexcept;
};

template<class T> T *Mallocator<T>::allocate(size_t const n) const {
  if (n == 0) {
    return nullptr;
  }
  if (n > static_cast<size_t>(-1) / sizeof(T)) {
    throw std::bad_array_new_length();
  }
  void *const pv = malloc(n * sizeof(T));
  if (!pv) {
    throw std::bad_alloc();
  }
  return static_cast<T *>(pv);
}

template<class T> void Mallocator<T>::deallocate(T *const p, size_t) const noexcept { free(p); }

int main() {
  std::vector<int64_t, Mallocator<int64_t>> v1;
  v1.push_back(1);
  v1.push_back(2);
  v1.push_back(3);

#if (__cplusplus >= 202302L) // C++23
  std::print(stdout, "v1.size: {}\n", std::format("{}", v1.size()));
  std::print(stdout, "allocator works\n");
#endif
  return 0;
}
