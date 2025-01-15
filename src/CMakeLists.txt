# SHENNANIGAN cmake error is bogus, gcc 15 needed
# CMake Error in CMakeLists.txt:
#   The "CXX_MODULE_STD" property on the target "test_example.exe" requires
#   that the "__CMAKE::CXX23" target exist, but it was not provided by the
#   toolchain.  Reason:
#
#     Only `libc++` is supported
# See also https://gitlab.kitware.com/cmake/cmake/-/issues/25965

# set CXXFLAGS -stdlib=libc++
# CXXFLAGS=-stdlib=libc++
# mkdir -p build_src
# cmake -G Ninja -S src/ -B build_src -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS=-stdlib=libc++
# ninja -C build_src
# ./build_src/test_example.exe

# This requires a recent nightly build.
# This will be part of CMake 3.30.0.
cmake_minimum_required(VERSION 3.29.0 FATAL_ERROR)

# Enables the Standard module support. This needs to be done
# before selecting the languages.
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "0e5b6991-d74f-4b3d-a41c-cf096e0b2508")
set(CMAKE_CXX_MODULE_STD ON)

project("test_example"
  LANGUAGES CXX
)

# Set language version used
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
# Currently CMake requires extensions enabled when using import std.
# https://gitlab.kitware.com/cmake/cmake/-/issues/25916
# https://gitlab.kitware.com/cmake/cmake/-/issues/25539
set(CMAKE_CXX_EXTENSIONS ON)

add_executable(test_example.exe)
target_sources(test_example.exe
  PRIVATE
    test_example.cpp
)
