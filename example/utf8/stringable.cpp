// clang++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage -Wno-switch-default .\example\utf8\stringable.cpp && .\a.exe
// TODO gcc
// TODO cl.exe

#include <cstdint>
#include <iostream>
#include <string>

// template <typename Ty>
// concept can_create_string_from = requires(Ty t1) {
//     static_cast<std::string>(t1);
// };
// template <typename Ty>
// concept can_create_wstring_from = requires(Ty t1) {
//     static_cast<std::wstring>(t1);
// };

template  <typename Ty>
using can_create_string_from = std::is_convertible<Ty,std::string>;

template  <typename Ty>
using can_create_wstring_from = std::is_convertible<Ty,std::wstring>;

struct SString {
    operator std::string();
};

template <typename Ty>
void print(Ty t1) {
  if constexpr (can_create_string_from<Ty>::value) {
    std::string s1(t1);
    fprintf(stdout, "stringable %s\n", s1.c_str());
  }
  // does not cover s3 and s4 for both std::string and std::wstring
  // if constexpr (std::is_convertible<Ty, std::string>) {
  //   std::string s1(t1);
  //   fprintf(stdout, "convertible %s\n", s1.c_str());
  // }

  if constexpr (can_create_wstring_from<Ty>::value) {
    std::wstring s1(t1);
    fprintf(stdout, "stringable %ls\n", s1.c_str());
  }

  // Neither does cover char8_t, char16_t and char32_t
}

static int32_t test_string_construction()
{
    std::cout << std::boolalpha;
    std::cout << can_create_string_from<std::string>::value << "\n";
    std::cout << can_create_string_from<std::string &>::value << "\n";
    std::cout << can_create_string_from<char *>::value << "\n";
    std::cout << can_create_string_from<char const *>::value << "\n";
    std::cout << can_create_string_from<SString>::value << "\n";
    // std::cout << can_create_string_from<bool> << "\n"; // no conversion
    // std::cout << can_create_string_from<int> << "\n"; // no conversion

    std::string s1 = "s1";
    print(s1);
    std::string s2 = "s2";
    const std::string& ref_s2 = s2;
    const std::string& const_ref_s2 = s2;
    print(ref_s2);
    print(const_ref_s2);
    char const * cstr_s3 = "s3";
    print(cstr_s3);
    const char * cstr_s4 = "s4";
    print(cstr_s4);
    char * mut_cstr_s4 = const_cast<char*>(cstr_s4);
    print(mut_cstr_s4);

    return 0;
}

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#include <cstdio>

struct SWString {
    operator std::wstring();
};

static int32_t test_wstring_construction()
{
    // _setmode(_fileno(stdout), _O_U16TEXT);
    std::cout << std::boolalpha;
    std::cout << can_create_wstring_from<std::wstring>::value << "\n";
    std::cout << can_create_wstring_from<std::wstring &>::value << "\n";
    std::cout << can_create_wstring_from<wchar_t *>::value << "\n";
    std::cout << can_create_wstring_from<wchar_t const *>::value << "\n";
    std::cout << can_create_wstring_from<const wchar_t *>::value << "\n";
    std::cout << can_create_wstring_from<SWString>::value << "\n";
    // std::cout << can_create_wstring_from<char16_t *> << "\n"; // no conversion
    // std::cout << can_create_wstring_from<char16_t const *> << "\n"; // no conversion
    // std::cout << can_create_wstring_from<const char16_t *> << "\n"; // no conversion
    // std::cout << can_create_wstring_from<bool> << "\n"; // no conversion
    // std::cout << can_create_wstring_from<int> << "\n"; // no conversion

    std::wstring s1 = L"s1";
    print(s1);
    std::wstring s2 = L"s2";
    std::wstring& ref_s2 = s2;
    const std::wstring& const_ref_s2 = s2;
    print(ref_s2);
    print(const_ref_s2);
    wchar_t const * cstr_s3 = L"s3";
    print(cstr_s3);
    const wchar_t * cstr_s4 = L"s4";
    print(cstr_s4);
    wchar_t * mut_cstr_s4 = const_cast<wchar_t*>(cstr_s4);
    print(mut_cstr_s4);

    return 0;
}
#endif

int main() {
  test_string_construction();
  test_wstring_construction();
  return 0;
}
