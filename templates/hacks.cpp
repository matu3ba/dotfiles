// #include <cstddef>
// #include <cstdint>
#include <limits>
#include <string>
#include <type_traits>

// Not beautiful conditional compilation with templates
// clang-format off
template<class T>
struct example {
  template <typename Y=T, typename std::enable_if<
    !std::is_same<bool, Y>::value
    && !std::numeric_limits<Y>::is_integer
    && !std::is_floating_point<Y>::value
    && std::is_same<std::string, Y>::value, int>::type = 0>
  void SetValue(T& arValue) {
    mtValue = arValue;
  }
  T mtValue;
};
// clang-format on
// The same can be done in an incompatible way with C maros and
// generic selection since C11. see templates/common.h "C11's Generic selection"

int32_t main() {}
