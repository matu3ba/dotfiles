// broken on g++ -std=c++20 -Werror -Wall -Wextra -Wpedantic -Wno-unused-value -Wno-unsafe-buffer-usage -Wno-switch-default ./example/clang_builtins/builtin_constant_p.cpp
// zig c++ -std=c++14 -Werror -Wall -Wextra -Wpedantic -Wno-unused-value ./example/clang_builtins/builtin_constant_p.cpp
// zig c++ -std=c++17 -Werror -Wall -Wextra -Wpedantic -Wno-unused-value ./example/clang_builtins/builtin_constant_p.cpp
// zig c++ -std=c++20 -Werror -Wall -Wextra -Wpedantic -Wno-unused-value -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default ./example/clang_builtins/builtin_constant_p.cpp
#include <string>
#include <string_view>
#include <utility>

using namespace std::literals;

#if !defined(__clang__) && (defined(__GNUC__) || defined(_MSC_VER))

/// this do not work for Clang, but work in VS2017.5
namespace detail {
constexpr void cx_test_helper(...) {}
} //namespace detail

#define is_constexpr(...) noexcept(detail::cx_test_helper((__VA_ARGS__, 0)))
//#define is_constexpr(...) noexcept(detail::cx_test_helper( __VA_ARGS__ ))

#elif defined(__clang__)

#define is_constexpr(...) __builtin_constant_p((__VA_ARGS__, 0))

#endif

// static auto constexpr func(...) {}

static void bar() {}
constexpr void foo() {}

static_assert(!is_constexpr(bar()));
static_assert(is_constexpr(foo()));

int main() {
  // empty check

  //? static_assert(is_constexpr());

  // literal values

  static_assert(is_constexpr("hello"));
  static_assert(is_constexpr("hello"sv));

  static_assert(!is_constexpr("hello"s));

  // constexpr values

  auto constexpr a = "hello";
  auto constexpr b = "hello"sv;

  static_assert(is_constexpr(a));
  static_assert(is_constexpr(b));

  // non-constexpr values

  auto c = "hello";
  auto d = "hello"s;
  auto e = "hello"sv;

  //? static_assert(!is_constexpr(c));
  //? static_assert(!is_constexpr(d));
  //? static_assert(!is_constexpr(e));

  // non-capture lambda as literal (NOTE: relies on p0315)

#if 0
    static_assert(is_constexpr([]{}));
    static_assert(is_constexpr([]{ return "hello"; }));
    static_assert(is_constexpr([]{ return "hello"sv; }));
    static_assert(is_constexpr([]{ return "hello"s; }));

    static_assert(is_constexpr([]{ return "hello"; }()));
    static_assert(is_constexpr([]{ return "hello"sv; }()));
    static_assert(is_constexpr([]{ return "hello"s; }()));
#endif

  // capture lambda as literal (NOTE: relies on p0315)

#if 0
    static_assert(is_constexpr([&]{}));
    static_assert(is_constexpr([&]{ return "hello"; }));
    static_assert(is_constexpr([&]{ return "hello"sv; }));
    static_assert(is_constexpr([&]{ return "hello"s; }));

    static_assert(is_constexpr([&]{ return "hello"; }()));
    static_assert(is_constexpr([&]{ return "hello"sv; }()));
    static_assert(is_constexpr([&]{ return "hello"s; }()));
#endif

  // constexpr non-capture lambda

  auto constexpr lam1 = [] {};
  auto constexpr lam2 = [] { return "hello"; };
  auto constexpr lam3 = [] { return "hello"sv; };
  auto constexpr lam4 = [] { return "hello"s; };

  static_assert(is_constexpr(lam1));
  static_assert(is_constexpr(lam2));
  static_assert(is_constexpr(lam3));
  static_assert(is_constexpr(lam4));

  static_assert(is_constexpr(lam2()));
  static_assert(is_constexpr(lam3()));
  static_assert(!is_constexpr(lam4()));

  // non-constexpr non-capture lambda

  auto lam5 = [] {};
  auto lam6 = [] { return "hello"; };
  auto lam7 = [] { return "hello"sv; };
  auto lam8 = [] { return "hello"s; };

  static_assert(is_constexpr(lam5));
  static_assert(is_constexpr(lam6));
  static_assert(is_constexpr(lam7));
  static_assert(is_constexpr(lam8));

  static_assert(is_constexpr(lam6()));
  static_assert(is_constexpr(lam7()));
  static_assert(!is_constexpr(lam8()));

  // constexpr capture lambda

  auto constexpr cap1 = [&] {};
  auto constexpr cap2 = [&] { return a; };
  //?  auto constexpr cap3 = [&]{ return b; };

  static_assert(is_constexpr(cap1));
  static_assert(is_constexpr(cap2));
  //? static_assert(is_constexpr(cap3));

  static_assert(is_constexpr(cap2()));
  //? static_assert(is_constexpr(cap3()));

  // non-constexpr capture lambda

  auto cap4 = [&] {};
  auto cap5 = [&] { return c; };
  auto cap6 = [&] { return d; };
  auto cap7 = [&] { return e; };

  static_assert(is_constexpr(cap4));
  //? static_assert(!is_constexpr(cap5));
  //? static_assert(!is_constexpr(cap6));
  //? static_assert(!is_constexpr(cap7));

  static_assert(!is_constexpr(cap5()));
  static_assert(!is_constexpr(cap6()));
  static_assert(!is_constexpr(cap7()));

  //
}
