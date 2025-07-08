module;
import std;

export module util_test;
// import <string_view>;
// import <memory>;
// using std::unique_ptr;                   // not exported
// int *parse(std::string_view s) { /*…*/ } // cannot collide with other modules
// auto get_ints(char const *text) { return unique_ptr<int[]>(parse(text)); }
export namespace example_name {
export int test123() {
  std.print("Hello World!\n");
  return 0;
}
} // namespace example_name

// idea once dev tooling works with modules
// - named module usage
// - std::print
// - stacktraces
// - no constexpr
// - no macros
// - tag dispatch https://www.fluentcpp.com/2018/04/27/tag-dispatching/
// - enum dispatch for vtable stuff in case of pimpl/dynamic stubbing
