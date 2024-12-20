cmake_minimum_required(VERSION 2.6)
project(test)

# TODO distinguish profile clang|gcc|msvc dev|release
# TODO test if -g is implicit or what ReleaseDebug and Debug imply

add_executable(dev_gcc.exe)
target_sources(dev_gcc.exe PRIVATE use_gcc.cpp)
# more lightweight is -D_GLIBCXX_ASSERTIONS -DDEBUG
target_compile_options(dev_gcc.exe PRIVATE -std=c++20 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -Wall -Wformat -Wformat=2 -Wconversion -Wimplicit-fallthrough -Werror -Wextra -Wpedantic -Wtrampolines -Wshadow -Wold-style-cast -Woverloaded-virtual -Wstrict-aliasing)

add_executable(rel_gcc.exe)
target_sources(rel_gcc.exe PRIVATE use_gcc.cpp)
target_compile_options(rel_gcc.exe PRIVATE -std=c++20 -Wall -Wformat -Wformat=2 -Wconversion -Wimplicit-fallthrough -Werror -Wextra -Wpedantic -Wtrampolines -Wshadow -Wold-style-cast -Woverloaded-virtual -Wstrict-aliasing)

add_executable(dev_clang.exe)
target_sources(dev_clang.exe PRIVATE use_gcc.cpp)
target_compile_options(dev_clang.exe PRIVATE -std=c++20 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default)

add_executable(rel_clang.exe)
target_sources(rel_clang.exe PRIVATE use_gcc.cpp)
target_compile_options(rel_clang.exe PRIVATE -std=c++20 for production code 	-fno-delete-null-pointer-checks -fno-strict-overflow -fno-strict-aliasing -ftrivial-auto-var-init=zero -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default)

# warning level
# cl /W4 /wd4146 /wd4245 /D_CRT_SECURE_NO_WARNINGS /Z7
# cl /Z7 /W4 /wd4146 /wd4245 /RTCcsu

# cmake -B build src/ -DCMAKE_BUILD_TYPE=Debug -GNinja && time cmake --build build
# watchexec -e hpp,cpp 'time cmake --build build && ./build/use_adjust.exe'
# cmake -B buildrel src/ -DCMAKE_BUILD_TYPE=ReleaseDebug -GNinja && time cmake --build buildrel
# watchexec -e hpp,cpp 'time cmake --build buildrel && ./buildrel/use_adjust.exe'
