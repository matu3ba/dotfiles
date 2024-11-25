//! Why -Wstring-conversion is necessary.
//! mkdir -p build && clang++ implicit_string_conversion.cpp -o build/implicit_string_conversion && ./build/implicit_string_conversion
#include <cinttypes>
#include <cstdio>
#include <string>

class Example {
public:
  enum ExpectedType {
    TypeUndefined = -1,
    TypeBool = 0,
    TypeString = 1,
  };

  void SetVar(bool const &val) { // <<< typical usage
    val_bool = val;
    ty = TypeBool;
  }
  void SetVar(std::string const &val) {
    val_string = val;
    ty = TypeString;
  }

  bool val_bool = false;
  int val_int = -1;
  double val_double = -1.0;
  std::string val_string = "-1.0";
  ExpectedType ty = TypeUndefined;
};

static uint8_t some_call(bool const &val) { // <<< reduced problem
  (void)val;
  return 1;
}

int32_t main() {
  Example ex;
  ex.SetVar("somevalue");
  uint8_t st = 0;

  if (ex.ty != Example::ExpectedType::TypeString) {
    fprintf(stdout, "expected %" PRId32 "(TypeString), got %" PRId32 "(TypeBool)\n", Example::ExpectedType::TypeString,
            ex.ty);
    st += 1;
  }
  st += some_call("somevalue");
  fprintf(stdout, "called 'uint8_t some_call(const bool & val)' with 'st += some_call(\"somevalue\")'\n");
  fprintf(stdout, "errors: %" PRIu8 "\n", st);
  return st;
}
