#if (__cplusplus >= 202302L)
#define HAS_CPP23 1
static_assert(HAS_CPP23, "use HAS_CPP23 macro");
#endif
#define ALLOW_BAD_PRACTICE 1

#include <functional>
#include <iostream> // stderr
#include <string>
#include <chrono>
#include <vector>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
inline std::string ConvertWideToUtf8(const std::wstring& wstr) {
    int count = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int32_t>(wstr.length()), nullptr, 0, nullptr, nullptr);
    if (count <= 0) return "";
    std::string str(static_cast<size_t>(count), 0);
    WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), -1, &str[0], count, nullptr, nullptr);
    return str;
}

inline std::wstring ConvertUtf8ToWide(const std::string& str) {
    int count = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), static_cast<int32_t>(str.length()), nullptr, 0);
    if (count <= 0) return L"";
    std::wstring wstr(static_cast<size_t>(count), 0);
    MultiByteToWideChar(CP_UTF8, 0, str.c_str(), static_cast<int32_t>(str.length()), &wstr[0], count);
    return wstr;
}
#endif

template <typename Ty>
concept can_create_string_from = requires(Ty t1) {
    static_cast<std::string>(t1);
};

template <typename Ty>
concept can_create_wstring_from = requires(Ty t1) {
    static_cast<std::wstring>(t1);
};

#ifdef ALLOW_BAD_PRACTICE
// template <typename T>
// concept Stream = std::is_convertible_v<T, std::ostream &>;

// template <typename T>
// concept Streamable =
//   requires(std::ostream &os, T value) {
//     { os << value } -> Stream;
//   };
// template <typename Ty>
// concept is_streamable = requires(std::ostream & os, Ty value) {
//     { os << value };
//   };

// template <typename Ty>
// concept Streamable = requires(std::ostream & os, Ty value) {
//     { os << value };
// };
// template <typename Ty>
// concept is_streamable = requires(std::ostream & ostream, Ty t1) {
//   { ostream << t1 } -> std::convertible_to<std::ostream &>;
// };
// struct STestStreamable {
//   int32_t mem;
//   std::ostream& operator << (std::ostream & ostream) {
//     ostream << mem;
//     return ostream;
//   }
// };
// static_assert(is_streamable<STestStreamable>, "can not use stream");
// static_assert(Streamable<STestStreamable>, "can not use stream");
#endif

inline char const* operator ""_SC(const char8_t* str, std::size_t) {
  return reinterpret_cast< const char* >(str);
}

struct TestResult {
  enum class Status : uint8_t {
    NotRun = 0
    , Error
    , Passed
    , Failed
    , Skipped
  } status;
  std::string Info;
  std::chrono::nanoseconds Runtime;
  std::string Stacktrace;
  TestResult() :
    status(Status::NotRun)
    , Info("")
    , Runtime(0)
    , Stacktrace("")
  {}
};

enum class TestType : uint8_t {
  Placeholder = 0
  , UnitTest
  , CrashTest
  , TestGroup
};

struct TestClass {
  std::vector <std::string> test_fns_name;
  std::vector <std::function<int32_t()>> test_fns;
  std::vector <TestType> test_tys;
  std::vector <TestResult> test_fns_res;

  // std::vector <int32_t> thread_id;
  // std::vector < std::atomic<int32_t> > test_fns_thread_id;

  void AddTestFn(const char * TestFnName, std::function<int32_t()> test_fn, TestType test_ty) {
    test_fns_name.emplace_back(TestFnName);
    test_fns.emplace_back(test_fn);
    test_tys.emplace_back(test_ty);
    test_fns_res.emplace_back(TestResult());
  }

  void CheckAndAddTests(std::function<void()> check_fn) {
    check_fn();
  }

  int32_t RunTests() {
    int32_t res = 0; // 0 ok, 1 err

    // run with 1 thread under assumption that test routines cleanup themself
    for (uint32_t test_i = 0; test_i < test_fns.size(); test_i+=1) {
      switch (test_tys[test_i]) {
        case TestType::UnitTest: {
          int32_t st = test_fns[test_i]();
          if (st != 0) res = 1;
          break;
        }
        case TestType::Placeholder : [[fallthrough]];
        case TestType::CrashTest : [[fallthrough]];
        case TestType::TestGroup :
          break;
      }
    }

    return res;
  }

  inline static void PrintEqFail(
  FILE * const cstream
  , const char * file
  , uint32_t line
  , const char * testname
  , const char * reference
  , const char * value
  ) {
    fprintf(cstream, "%s:%d %s failed,\nexpected '%s' got '%s'\n"
      , file
      , line
      , testname
      , reference
      , value
    );
  }

  struct ValRefStr {
    std::string val;
    std::string ref;
  };
  template <class Ty1, class Ty2>
  static constexpr ValRefStr ConvertToString(const Ty1& value, const Ty2& reference) {
    // 1 enum
    // 2 integral types (integers)
    // 3 float types
    // 4 can_create_string_from (char*, std::string, with and without refs et)
    // * create copy
    // 5 can_create_wstring_from (wchar_t*, std::wstring, with and without refs et)
    // * create tmp copy and convert it to std::string
    // 6 composite types with custom string formatter: toString
    if constexpr (std::is_enum_v<Ty1>) {
      static_assert(std::is_same_v<Ty1, Ty2>);
      using Ty1_underlyingTy = typename std::underlying_type_t<Ty1>;
      auto val_casted = static_cast<Ty1_underlyingTy>(value);
      auto ref_casted = static_cast<Ty1_underlyingTy>(reference);
      return { std::to_string(val_casted), std::to_string(ref_casted) };
    } else if constexpr (std::is_integral_v<Ty1>) {
      static_assert(std::is_integral_v<Ty2>);
      return { std::to_string(value), std::to_string(reference) };
    } else if constexpr (std::is_floating_point_v<Ty2>) {
      static_assert(std::is_floating_point_v<Ty2>);
      return { std::to_string(value), std::to_string(reference) };
    } else if constexpr (can_create_string_from<Ty1>) {
      static_assert(can_create_string_from<Ty2>);
      return { std::string(value), std::string(reference) };
    }
#ifdef _WIN32
    else if constexpr (can_create_wstring_from<Ty1>) {
      static_assert(can_create_wstring_from<Ty2>);
      // convert wstring -> string for utf8 encoded output
      return { ConvertWideToUtf8(std::wstring(value))
        , ConvertWideToUtf8(std::wstring(reference))
      };
    }
// #ifdef ALLOW_BAD_PRACTICE
// #ifdef HAS_CPP23
//     else if constexpr (can_use_stream<Ty1>) {
//       static_assert(can_use_stream<Ty2>);
//       std::stringstream stream_val;
//       stream_val << value;
//       std::stringstream stream_ref;
//       stream_ref << value;
//       return { stream_val.str(), stream_ref.str() };
//     }
// #endif // HAS_CPP23
// #endif // ALLOW_BAD_PRACTICE
#endif
    else {
      return { value.toString(), reference.toString() };
    }
  }

  /// uses implicit type coercion and/or equality operator
  template <class Ty1, class Ty2>
  static inline int32_t TestEqual(const char * testname, const Ty1& value, const Ty2& reference, const char* file, const uint32_t line) {
    if (!(value == reference))
    {
      ValRefStr valref = ConvertToString(value, reference);
      PrintEqFail(stderr, file, line, testname, valref.val.c_str(), valref.ref.c_str());
      return 1;
    }
    return 0;
  }
};

// LEAF(__FILE__)
#define TEST_EQUAL(A,B) { int32_t res = TestClass::TestEqual(#A" == "#B,(A),(B),__FILE_NAME__,(__LINE__)); if (res != 0) return res; } do {} while(false)
