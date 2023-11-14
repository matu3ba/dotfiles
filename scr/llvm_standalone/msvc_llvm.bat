echo %USERPROFILE%
REM >> Every major release llvm appears to break standalone builds, so better use something else. <<
REM clang-17.0.4.src/
REM assume: Visual Studio Community with "Desktop development with C++"
REM * MSBuild, C++-Redistributable-Update, C++-CMake-Tools for Windows
REM * C++ core features, C++-ATL for newest v142 Buildtools, Windows 10 SDK
mkdir %USERPROFILE%\llvm-17.0.4.src\build-release
cd %USERPROFILE%\llvm-17.0.4.src\build-release
REM patched: download cmakeXYZ.tar.xz and mv cmakeXYZ cmake next to other standalone dirs
REM patched: -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF
"c:\Program Files\CMake\bin\cmake.exe" .. -Thost=x64 -G "Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=%USERPROFILE%\llvm+clang+lld-17.0.4-x86_64-windows-msvc-release-mt -DCMAKE_PREFIX_PATH=%USERPROFILE%\llvm+clang+lld-17.0.4-x86_64-windows-msvc-release-mt -DLLVM_ENABLE_ZLIB=OFF -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_USE_CRT_RELEASE=MT -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF
msbuild /m -p:Configuration=Release INSTALL.vcxproj

REM mkdir %USERPROFILE%\llvm-17.0.4.src\build-debug
REM cd %USERPROFILE%\llvm-17.0.4.src\build-debug
REM "c:\Program Files\CMake\bin\cmake.exe" .. -Thost=x64 -G "Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=C:\Users\andy\llvm+clang+lld-17.0.4-x86_64-windows-msvc-debug -DLLVM_ENABLE_ZLIB=OFF -DCMAKE_PREFIX_PATH=C:\Users\andy\llvm+clang+lld-17.0.4-x86_64-windows-msvc-debug -DCMAKE_BUILD_TYPE=Debug -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="AVR" -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_USE_CRT_DEBUG=MTd
REM msbuild /m INSTALL.vcxproj
