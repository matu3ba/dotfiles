/* https://sourceforge.net/p/predef/wiki/Home/ */

/* Known C++17 and C17 compatible compilers re reliable to*/
/* specify the macros.                                    */
/* C89     __STDC__                    ANSI X3.159-1989   */
/* C90     __STDC__                    ISO/IEC 9899:1990  */
/* C94     __STDC_VERSION__ = 199409L  ISO/IEC 9899-1:1994*/
/* C99     __STDC_VERSION__ = 199901L  ISO/IEC 9899:1999  */
/* C11     __STDC_VERSION__ = 201112L  ISO/IEC 9899:2011  */
/* C17/C18 __STDC_VERSION__ = 201710L  ISO/IEC 9899:2018  */
/* C23     __STDC_VERSION__ = 202311L  ISO/IEC needed     */
/* C26     __STDC_VERSION__ = UNFIN    ISO/IEC needed     */
/* C++98   __cplusplus = 199711L       ISO/IEC 14882:1998 */
/* C++11   __cplusplus = 201103L       ISO/IEC 14882:2011 */
/* C++14   __cplusplus = 201402L       ISO/IEC 14882:2014 */
/* C++17   __cplusplus = 201703L       ISO/IEC 14882:2017 */
/* C++20   __cplusplus = 202002L                          */
/* C++23   __cplusplus = 202302L                          */
/* C++26   __cplusplus = UNFIN                            */
/* C++/CLI __cplusplus_cli = 200406L   ECMA-372           */

#if defined(__STDC__)
# define IS_C89
# if defined(__STDC_VERSION__)
#  if (__STDC_VERSION__ == 199409L)
#   define IS_C94
#  endif
#  if (__STDC_VERSION__ == 199901L)
#   define IS_C99
#  endif
#  if (__STDC_VERSION__ == 201112L)
#   define IS_C11
#  endif
#  if (__STDC_VERSION__ == 201710L)
#   define IS_C17
#  endif
#  if (__STDC_VERSION__ == 202311L)
#   define IS_C23
#  endif
# endif
#endif

// msvc requires /Zc:__cplusplus https://learn.microsoft.com/en-us/cpp/build/reference/zc-cplusplus?view=msvc-170
#if defined(__cplusplus)
  #if (__cplusplus == 202002L)
    #define IS_CPP20
  #endif
  #if (__cplusplus == 202302L)
    #define IS_CPP23
  #endif
#endif

/* https://sourceforge.net/p/predef/wiki/Compilers/ */
#ifdef _MSC_VER
#define VISUAL_STUDIO 1
#define MIN_VS2015 (VISUAL_STUDIO && (_MSC_VER >= 1900)) // Visual Studio 2013
#define MIN_VS2013 (VISUAL_STUDIO && (_MSC_VER >= 1800)) // Visual Studio 2013
#define MIN_VS2012 (VISUAL_STUDIO && (_MSC_VER >= 1700)) // Visual Studio 2012
#define MIN_VS2010 (VISUAL_STUDIO && (_MSC_VER >= 1600)) // Visual Studio 2010
#else
#define VISUAL_STUDIO 0
#endif

// msvc compatibility hacks
#if MIN_VS2015
#define DEPRECATED(MSG) [[deprecated(MSG)]]
#define DEPRECATED_CONSTRUCTOR __declspec(deprecated)
#define DISABLE_DEPRECATED_WARNINGS __pragma(warning(disable:4996))  // disables deprecated warnings in msvc
#define FINAL sealed
#define NORETURN [[noreturn]]
#define NULLPTR nullptr
#define OVERRIDE override
#elif MIN_VS2010
#define DEPRECATED(MSG) __declspec(deprecated(MSG))
#define DEPRECATED_CONSTRUCTOR __declspec(deprecated)
#define DISABLE_DEPRECATED_WARNINGS __pragma(warning(disable:4996))
#define FINAL sealed
#define NORETURN __declspec(noreturn)
#define NULLPTR nullptr
#define OVERRIDE override
#define constexpr
#endif
