// http://scaryreasoner.wordpress.com/2009/02/28/checking-sizeof-at-compile-time/
#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))
usage: BUILD_BUG_ON( sizeof(someThing) != PAGE_SIZE );
