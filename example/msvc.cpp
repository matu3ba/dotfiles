// https://stackoverflow.com/questions/73161788/visual-studio-2022-how-to-access-the-built-in-developer-powershell-instead-of
// VsDevCmd.bat batch file or Launch-VsDevShell.ps1
// Get-ChildItem 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\'
// Get-ChildItem 'C:\Windows\SysWOW64\WindowsPowerShell\v1.0\'
// fd cl.exe "C:\Program Files\Microsoft Visual Studio\2022\Community\"
// & "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.40.33807\bin\Hostx64\x64\cl.exe" example\msvc.cpp
// PowerShell Tools for Visual Studio 2022
// https://marketplace.visualstudio.com/items?itemName=AdamRDriscoll.PowerShellToolsVS2022

// & "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\bin\MSBuild.exe"
// & "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe" .\Solution.sln
// & "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1"
// & "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
// & "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" Solution.sln /t:Build /p:Configuration=ReleaseRevision /p:Platform=x64 -nologo -v:d > build2.log
// & "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" Solution.sln /t:Project /p:Configuration=ReleaseRevision /p:Platform=x64 -nologo -v:d > build.log
// & "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" .\Solution.sln

// ====generate compile_commands.json
// TODO how to extract cl.exe args from msbuild
// parse build.log for cl.exe and retrieve flags
// adjust compile_commands.json with content
// {
//   "directory": "C:/Users/hafer/SolutionDir/",
//   "command": "\"C:/Program Files/LLVM/bin/clang++.exe\" -x c++ \"ABSOLUTE_PATH_TO_FILE\" -std=c++14 -Wall -fms-compatibility-version=19.10 -Wmicrosoft -Wno-invalid-token-paste -Wno-unknown-pragmas -Wno-unused-value -m32 -fsyntax-only \"-D_MT\" \"-D_DLL\"
//   \"-D_USING_V110_SDK71_\" \"-DSOMEMACRO\" \"-DWIN32\" \"-D_DEBUG\" ..
//   -isystem\"ABS_PATH_TO_PROJECT_DIR\"
//   -isystem\"C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/include\"
//   -isystem\"C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/atlmfc/include\"
//   -isystem\"C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/Auxiliary/VS/include\"
//   -isystem\"C:/Program Files (x86)/Windows Kits/10/Include/10.0.10240.0/ucrt\"
//   -isystem\"C:/Program Files (x86)/Microsoft SDKs/Windows/v7.1A/Include\" -I\"PxLibrary\" -I\"C:/Users/hafer/pix/SolutionDir/ProjectDir\"",
//   "file": "ABSOLUTE_PATH_TO_FILE"
// }
// via
// \"-D_USING_V110_SDK71_\" \"-DSOMEMACRO\" \"-DX64\" \"-D_DEBUG\" ..

// https://learn.microsoft.com/de-de/previous-versions/visualstudio/visual-studio-2015/msbuild/msbuild-special-characters?view=vs-2015&redirectedfrom=MSDN

//The following table lists MSBuild special characters:
// Character 	ASCII 	Reserved Usage
// % 	%25 	Referencing metadata
// $ 	%24 	Referencing properties
// @ 	%40 	Referencing item lists
// ' 	%27 	Conditions and other expressions
// ; 	%3B 	List separator
// ? 	%3F 	Wildcard character for file names in Include and Exclude attributes
// * 	%2A 	Wildcard character for use in file names in Include and Exclude attributes

//https://stackoverflow.com/questions/41227419/msbuild-exec-command-always-fails
// <Exec Command="git log -1 --oneline --pretty=&quot;%25%25h %25%25ad &lt;%25%25ae&gt;&quot; &gt; $(OutputPath)/git-info.txt" />
// This will execute this command:
// git log -1 --oneline --pretty="%h %ad <%ae>" > bin/debug/git-info.txt
// Here's what I understood of why each escape is needed:
//     %25 is the MSBuild Special Characters escape for a % sign
//     %25%25 then will create two percent signs which is the cmd escape for percent
//     &quot; is the xml attribute value escape for double quotes "
//     &gt; is the xml attribute value escape for the > character

// SHENNANIGAN
// $(VC_ExecutablePath_x64_x64) looks like correct path on VS2022
// $(VC_ExecutablePath_x64) can be wrongly expanded path on VS2022

// Bump these on incompatibilities.
// if using newer C version
// static_assert(__STDC_VERSION__ >= 201710L);
// requires /Zc:__cplusplus https://learn.microsoft.com/en-us/cpp/build/reference/zc-cplusplus?view=msvc-170
//static_assert(__cplusplus >= 202002L);

#if (__cplusplus == 202302L)
  #define IS_CPP23
  #define HAS_CPP23
  static_assert(sizeof(char) == 1, "invalid char8_t size");
  static_assert(sizeof(char8_t) == 1, "invalid char8_t size");
  static_assert(sizeof(char16_t) == 2, "invalid char16_t size");
  static_assert(sizeof(wchar_t) == 2, "invalid wchar_t size");
  static_assert(sizeof(char32_t) == 4, "invalid char32_t size");

  static_assert(std::is_signed_v<char>, "invalid char sign");
  static_assert(std::is_unsigned_v<char8_t>, "invalid char8_t sign");
  static_assert(std::is_unsigned_v<char16_t>, "invalid char16_t sign");
  static_assert(std::is_unsigned_v<wchar_t>, "invalid wchar_t sign");
  static_assert(std::is_unsigned_v<char32_t>, "invalid char32_t sign");
#endif

// file Stdafx.h
// TODO C++26 use WideCharToMultiByte(CP_UTF8 ..), MultiBytetoWideChar
// and remove following macro to ignore deprecation
#define _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING
// TODO C++23 use std::atomic<std::shared_ptr<>> for atomic shared_ptr
// and remove following macro to ignore deprecation
#define _SILENCE_CXX20_OLD_SHARED_PTR_ATOMIC_SUPPORT_DEPRECATION_WARNING

// #include "Stdafx.h"
#include <stdio.h>


int main() {
  fprintf(stdout, "hello world\n");
  return 0;
}
