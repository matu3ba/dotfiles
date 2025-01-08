// File extensions conventions
// module unit files:                .cppm (or .ccm, .cxxm, or .c++m)
// module implementation unit files: .cpp  (or .cc, .cxx, or .c++)
// BMI                               .pcm
// BMI for PMI unit                  module_name.pcm
// BMI for MP unit                   module_name-partition_name.pcm
// clang fails on wrong convention usage

// mkdir -p build
// clang++ -std=c++20 -x c++-module example/cpp23_modules/hello.cppm --precompile -o build/hello.pcm
// clang++ -std=c++20 example/cpp23_modules/hello.cpp -fprebuilt-module-path=. build/hello.pcm -o build/hello.exe
// ./build/hello.exe

// Hello.cppm
module;
import std;
// #include <iostream>
export module Hello;
export void hello() {
  std.print("Hello World!\n");
  // std::cout << "Hello World!\n";
}
