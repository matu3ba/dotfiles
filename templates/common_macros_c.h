/* https://sourceforge.net/p/predef/wiki/Home/ */

/* https://sourceforge.net/p/predef/wiki/Standards/ */
/* C89     __STDC__  ANSI X3.159-1989 */
/* C90     __STDC__  ISO/IEC 9899:1990 */
/* C94     __STDC_VERSION__ = 199409L  ISO/IEC 9899-1:1994 */
/* C99     __STDC_VERSION__ = 199901L  ISO/IEC 9899:1999 */
/* C11     __STDC_VERSION__ = 201112L  ISO/IEC 9899:2011 */
/* C17/C18 __STDC_VERSION__ = 201710L  ISO/IEC 9899:2018 */
/* C23     __STDC_VERSION__ = 202311L  ISO/IEC needed */
/* C++98   __cplusplus = 199711L   ISO/IEC 14882:1998 */
/* C++11   __cplusplus = 201103L   ISO/IEC 14882:2011 */
/* C++14   __cplusplus = 201402L   ISO/IEC 14882:2014 */
/* C++17   __cplusplus = 201703L   ISO/IEC 14882:2017 */
/* C++/CLI __cplusplus_cli = 200406L   ECMA-372 */

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

/* https://sourceforge.net/p/predef/wiki/Compilers/ */

/* https://sourceforge.net/p/predef/wiki/Libraries/ */

/* https://sourceforge.net/p/predef/wiki/OperatingSystems/ */

/* https://sourceforge.net/p/predef/wiki/Architectures/ */
