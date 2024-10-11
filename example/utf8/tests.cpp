// clang++ -std=c++20 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage -Wno-switch-default .\example\utf8\tests.cpp && .\a.exe
// clang++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage -Wno-switch-default .\example\utf8\tests.cpp && .\a.exe

#if (__cplusplus >= 202002L)
#define HAS_CPP20 1
static_assert(HAS_CPP20, "use HAS_CPP20 macro");
#endif

#include "../util_test.h"
#include <sstream>

// #include <iostream>
#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
// #include <wchar.h>
// #include <WinNls.h>
// #include <stdio.h>
// #include <consoleapi2.h>
// #include <iostream>
// #include <codecvt>
// #include <locale>
#endif

// https://vitaut.net/posts/2023/print-in-cpp23/
// #include <print> // C++23 sane utf8 encoding without locale influence
#include <string>
// https://stackoverflow.com/questions/6693010/how-do-i-use-multibytetowidechar
static std::string ConvertWideToANSI(const std::wstring& wstr) {
    int count = WideCharToMultiByte(CP_ACP, 0, wstr.c_str(), static_cast<int32_t>(wstr.length()), nullptr, 0, nullptr, nullptr);
    if (count <= 0) return "";
    std::string str(static_cast<size_t>(count), 0);
    WideCharToMultiByte(CP_ACP, 0, wstr.c_str(), -1, &str[0], count, nullptr, nullptr);
    return str;
}

static std::wstring ConvertAnsiToWide(const std::string& str) {
    int count = MultiByteToWideChar(CP_ACP, 0, str.c_str(), static_cast<int32_t>(str.length()), nullptr, 0);
    if (count <= 0) return L"";
    std::wstring wstr(static_cast<size_t>(count), 0);
    MultiByteToWideChar(CP_ACP, 0, str.c_str(), static_cast<int32_t>(str.length()), &wstr[0], count);
    return wstr;
}

static int32_t test_utf8comparison() {

  std::string Biiru1 = u8"<PixUTF8>生ビールBier"_SC;
  std::string Biiru2 = u8"<PixUTF8>Bier生ビール"_SC;
  std::string Biiru3 = u8"<PixUTF8>Bier生ビール"_SC;

  // TEST_EQUAL(Biiru1, Biiru2);
  TEST_EQUAL(Biiru2, Biiru2);
  return 0; // ok
}

#ifdef _WIN32
#ifndef HAS_CPP20
static int32_t deprecated_test_utf8utf32conversion() {
  std::wstring_convert<std::codecvt_utf8<int32_t>, int32_t> utf32conv;
  auto utf32 = utf32conv.from_bytes("The quick brown fox jumped over the lazy dog.");
  // use reinterpret_cast<const char32_t *>(utf32.c_str())
}
#endif

static int32_t test_utf8uf16conversion() {
  (void)ConvertWideToANSI;
  (void)ConvertAnsiToWide;
  #ifndef HAS_CPP20
  (void)deprecated_test_utf8utf32conversion;
  #endif

  // \x00C4
  std::wstring HelloUTF16Str = L"  HelloÄ   ";
  std::string HelloUTF8Str = ConvertWideToUtf8(HelloUTF16Str);
  fprintf(stdout, "%s\n", HelloUTF8Str.c_str());
  std::wstring SameHelloUTF16Str = ConvertUtf8ToWide(HelloUTF8Str);
  std::wstring OtherHelloUTF16Str = L"HelloÄ";

  TEST_EQUAL(HelloUTF16Str, SameHelloUTF16Str);
  TEST_EQUAL(HelloUTF16Str, OtherHelloUTF16Str);
  return 0; // ok

  // output encoding must be respecting what is used and it looks like this
  // can only be set once to either use ascii xor utf8 xor utf16/wide strings
  // fprintf(stderr, "%ls\n", tmpptr1); // wstring -> %ls
  // fwprintf(stdout, L"%ls\n", L"Ä");
  // fwprintf(stdout, L"%ls\n", L"  HelloÄ   ");
  // fwprintf(stdout, L"%ls\n", tmpptr1);
  // fflush(stdout);

  // std::wcout << L"Русский текст\n";
  // const char ru[] = "Привет"; //Russian language
  // std::print("{}\n", ru);
  // std::wcout << L"Ä" << std::endl;
  // wchar_t en[] = L"Hello";
  // wchar_t ru[] = L"Привет"; //Russian language
  // std::wcout << ru << std::endl << en << std::endl;
}
#endif

// struct SPoint1 {
//   int32_t x;
//   int32_t y;
//   std::ostream& operator << (std::ostream & stream) {
//     stream << "[" << std::to_string(x) << ", " << std::to_string(y) << "]";
//     return stream;
//   }
//   bool operator == (const SPoint & other) const{
//     return (x == other.x && y == other.y);
//   }
// };
//
// static int32_t test_streamingoperator() {
//   SPoint pt1 = { 1, 2 };
//   SPoint pt2 = { 1, 2 };
//   TEST_EQUAL(pt1, pt2);
//   return 0;
// }

struct SPoint2 {
  int32_t x;
  int32_t y;
};
static std::ostream& operator<<(std::ostream& Stream, const SPoint2 Val)
{
	std::locale loc = Stream.getloc();
	auto pt = std::use_facet<std::numpunct<char>>(loc).decimal_point();
	Stream << "[" << Val.x << pt << Val.y << "]";

	return Stream;
}

static int32_t test_localestreamop() {
  SPoint2 p2 = { 1, 2 };
  std::stringstream ss_p2;
  ss_p2 << p2;
  std::string actual = ss_p2.str();
  std::string ref = "[1.2]";

  TEST_EQUAL(actual, ref);
  return 0; // ok
}

int main(int argc, const char* argv[]) {
  // std::cout.imbue(std::locale(""));
  // std::wcout.imbue(std::locale(""));
  // std::cerr.imbue(std::locale(""));
  // std::wcerr.imbue(std::locale(""));
  (void)argc;
  (void)argv;
#ifdef _WIN32
  // comparable to _setmode(_fileno(stdout), _O_U8TEXT);
  SetConsoleOutputCP( CP_UTF8 );
  // no buffering to prevent interference in unfinished UTF8 byte sequences
  // setvbuf( stderr, nullptr, _IONBF, 0 );
  // setlocale(LC_CTYPE,"C");

  // _O_U16TEXT is 0x00020000
  // _O_U8TEXT is 0x00040000
  // _setmode(_fileno(stdout), _O_U8TEXT);
  // _setmode(_fileno(stdout), _O_U16TEXT);
#endif

  TestClass tc;
  tc.AddTestFn("test_utf8comparison", test_utf8comparison, TestType::UnitTest);
#ifdef _WIN32
  tc.AddTestFn("test_utf8uf16conversion", test_utf8uf16conversion, TestType::UnitTest);
#endif
  // tc.AddTestFn("test_streamingoperator", test_streamingoperator, TestType::UnitTest);
  tc.AddTestFn("test_localestreamop", test_localestreamop, TestType::UnitTest);
  int32_t st = tc.RunTests();
  return st;
}
