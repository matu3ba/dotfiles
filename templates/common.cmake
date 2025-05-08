#====basics
# best overview I found so far https://cliutils.gitlab.io/modern-cmake/chapters/intro/dodonot.html
# https://cliutils.gitlab.io/modern-cmake/README.html

# https://dane-bulat.medium.com/cmake-how-to-inspect-and-configure-the-compiler-877e6cb0317f
# git clone https://github.com/danebulat/cmake-compiler-flags.git
# ccmake .
# cmake --system-information information.txt

#====cross_compilation
# https://github.com/Rodiii/cmake_crosscompiling_template
# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html
# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Cross%20Compiling%20With%20CMake.html

#====cpp_modules

# TODO summarize techniques from https://izzys.casa/

#====cpp_modules
# idea 1 project to use macros and https://learnmoderncpp.com/2020/02/10/writing-assert-in-cpp/
# Find how to pass some vars from cmake to header via @VAR_NAME@ syntax and via CMake's function configure_file
# https://github.com/TheLartians/PackageProject.cmake

# idea 2 TODO lib configuration
# https://vector-of-bool.github.io/2020/10/04/lib-configuration.html
# fixed paths, include path hackery or providing the path as macro

# cmake can output a trace file, meaning it can convert the the processed CMakeLists.txt into a list of json objects
# offer build.zig step integration.
# - [ ] 1. sane de
# - [ ] 1. per project json getting + dump json cli command
# - [ ] 2. sane default tracing
# - [ ] 3. store + retrieve the cmake cli invocation
# - [ ] 4. verbatim forward flag mode for stuff like graphiz info, see http://postbits.de/debugging-cmake.html
# ```
# cmake --help
# ..
#   --trace                      = Put cmake in trace mode.
#   --trace-expand               = Put cmake in trace mode with variable
#                                  expansion.
#   --trace-format=<human|json-v1>
#                                = Set the output format of the trace.
#   --trace-source=<file>        = Trace only this CMake file/module.  Multiple
#                                  options allowed.
#   --trace-redirect=<file>      = Redirect trace output to a file instead of
#                                  stderr.
#
# https://hsf-training.github.io/hsf-training-cmake-webpage/08-debugging/index.html
# cmake -S . -B build --trace-source=CMakeLists.txt
# [CMAKE_CXX_COMPILER_LAUNCHER](https://cmake.org/cmake/help/latest/envvar/CMAKE_LANG_COMPILER_LAUNCHER.html) can set up a compiler launcher, like ccache, to speed up your builds.
# [CMAKE_CXX_CLANG_TIDY](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_CLANG_TIDY.html) can run clang-tidy to help you clean up your code.
# [CMAKE_CXX_CPPCHECK](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_CPPCHECK.html) for cppcheck.
# [CMAKE_CXX_CPPLINT](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_CPPLINT.html) for cpplint.
# [CMAKE_CXX_INCLUDE_WHAT_YOU_USE](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_INCLUDE_WHAT_YOU_USE.html) for iwyu.

# message(STATUS "MY_VARIABLE=${MY_VARIABLE}")
#include(CMakePrintHelpers)
#cmake_print_variables(MY_VARIABLE)
#cmake_print_properties(
#    TARGETS my_target
#    PROPERTIES POSITION_INDEPENDENT_CODE
#)
