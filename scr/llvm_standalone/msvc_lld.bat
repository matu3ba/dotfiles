REM clang-17.0.4.src/
REM depends on: llvm-17.0.4.src/ clang-17.0.4.src/
mkdir %USERPROFILE%\lld-17.0.4.src\build-release
cd %USERPROFILE%\lld-17.0.4.src\build-release
REM patched: -DLLVM_INCLUDE_TESTS=OFF
"c:\Program Files\CMake\bin\cmake.exe" .. -Thost=x64 -G "Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=%USERPROFILE%\llvm+clang+lld-14.0.6-x86_64-windows-msvc-release-mt -DCMAKE_PREFIX_PATH=%USERPROFILE%\llvm+clang+lld-17.0.4-x86_64-windows-msvc-release-mt -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_INCLUDE_TESTS=OFF
msbuild /m -p:Configuration=Release INSTALL.vcxproj

REM mkdir %USERPROFILE%\lld-17.0.4.src\build-debug
REM cd %USERPROFILE%\lld-17.0.4.src\build-debug
REM "c:\Program Files\CMake\bin\cmake.exe" .. -Thost=x64 -G "Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=C:\Users\andy\llvm+clang+lld-17.0.4-x86_64-windows-msvc-debug -DCMAKE_PREFIX_PATH=C:\Users\andy\llvm+clang+lld-17.0.4-x86_64-windows-msvc-debug -DCMAKE_BUILD_TYPE=Debug -DLLVM_USE_CRT_DEBUG=MTd
REM msbuild /m INSTALL.vcxproj
