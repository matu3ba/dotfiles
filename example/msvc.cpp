// Development dependencies
// * debug symbols for Operating Sysem (Win32 and lower to ntdll and blow) shipped with Windows SDK
// * debug symbols for C and C++ libs shipped via Visual Studio, for example
//   + C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Redist\MSVC\14.40.33807\debug_nonredist\x64\Microsoft.VC143.DebugCRT
//   + C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Redist\MSVC\14.40.33807\debug_nonredist\x64\Microsoft.VC143.DebugOpenMP
//   + C:\Program Files (x86)\Windows Kits\10\bin\x64\ucrt
//
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
//   "directory": "C:/Users/USER/SolutionDir/",
//   "command": "\"C:/Program Files/LLVM/bin/clang++.exe\" -x c++ \"ABSOLUTE_PATH_TO_FILE\" -std=c++14 -Wall -fms-compatibility-version=19.10 -Wmicrosoft -Wno-invalid-token-paste -Wno-unknown-pragmas -Wno-unused-value -m32 -fsyntax-only \"-D_MT\" \"-D_DLL\"
//   \"-D_USING_V110_SDK71_\" \"-DSOMEMACRO\" \"-DWIN32\" \"-D_DEBUG\" ..
//   -isystem\"ABS_PATH_TO_PROJECT_DIR\"
//   -isystem\"C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/include\"
//   -isystem\"C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/atlmfc/include\"
//   -isystem\"C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/Auxiliary/VS/include\"
//   -isystem\"C:/Program Files (x86)/Windows Kits/10/Include/10.0.10240.0/ucrt\"
//   -isystem\"C:/Program Files (x86)/Microsoft SDKs/Windows/v7.1A/Include\" -I\"LibDir\" -I\"C:/Users/USER/SolutionDir/ProjectDir\"",
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

// Fix preprocessor VAR_ARGS with flag /Zc:preprocessor

// Bump these on incompatibilities.
// if using newer C version
// static_assert(__STDC_VERSION__ >= 201710L);
// requires flag /Zc:__cplusplus https://learn.microsoft.com/en-us/cpp/build/reference/zc-cplusplus?view=msvc-170
//static_assert(__cplusplus >= 202002L);

// utf8 handling is bad in msvc
// * msvc defaults to used locale, if msvc finds no BOM in file
// * manual reencoding is needed, because msvc provides no tooling and neither
// offers introspection in what encoding it internally uses
// * good default requires flag /utf-8 and only errors out, if it can not find BOM

// Looking up unicode symbols to copy paste
// https://www.compart.com/en/unicode/U+00C4

// typical manual conversion
// * UTF8 LE BOM files with strings -> UTF8 files
// * UTF16 LE BOM files with strings -> UTF8 files
// * latin(ISO-8859-1)/WINDOWS-1252 files with strings -> UTF8 files

// SHENNANIGAN git diff shows no difference, when the BOM was locally removed, because
// it sees UTF-8 LE BOM as redundant to its internal utf8 storage.
// However, msvc thinks differently and may choose other encodings than UTF-8

// SHENNANIGAN execution with recompilation will save local file and reencode it,
// if the file is opened in tab, even though no change in VS2022 editor has
// happened.
// Probably the timepoint and file content of file in opened tab nis cached,
// so cache mismatches lead to automatic reencoding.
// Hence, external changes must be done with closed file and reopen it,
// if VS2022 would reencode the file and msvc incorrectly interpret it.

// SHENNANIGAN AdditionalOptions are mutual exclusive and can lead to incorrect
// precompiled headers.
//  <ClCompile>
//    <WarningLevel>Level3</WarningLevel>
//    <PrecompiledHeader>Use</PrecompiledHeader>
//    <Optimization>MaxSpeed</Optimization>
//    <FunctionLevelLinking>true</FunctionLevelLinking>
//    <IntrinsicFunctions>true</IntrinsicFunctions>
//    <PreprocessorDefinitions>_CRT_SECURE_NO_WARNINGS;WIN64;NDEBUG;_CONSOLE;RELEASE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
//    <AdditionalIncludeDirectories>$(SolutionDir)MyLibrary;</AdditionalIncludeDirectories>
//    <TreatWarningAsError>true</TreatWarningAsError>
//    <OpenMPSupport>true</OpenMPSupport>
//    <MultiProcessorCompilation>true</MultiProcessorCompilation>
//    <WholeProgramOptimization>true</WholeProgramOptimization>
//    <LanguageStandard>stdcpp20</LanguageStandard>
//    <AdditionalOptions>/utf-8 %(AdditionalOptions)</AdditionalOptions>
//  </ClCompile>
//  ..
// -    <ClCompile Include="SomeFile.cpp">
// -      <AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
// -      </AdditionalOptions>
// -      <AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
// -      </AdditionalOptions>
// -    </ClCompile>
// +    <ClCompile Include="SomeFile.cpp" />

// SHENNANIGAN Step success is based on exit code 0 or 1, other exit codes may be incorrectly evaluated.

// https://pspdfkit.com/blog/2021/string-literals-character-encodings-and-multiplatform-cpp/
// https://learn.microsoft.com/en-us/cpp/build/reference/utf-8-set-source-and-executable-character-sets-to-utf-8?view=msvc-170
// https://learn.microsoft.com/en-us/windows/win32/Intl/code-page-identifiers
// https://learn.microsoft.com/en-us/dotnet/api/microsoft.visualstudio.vcprojectengine.vcclcompilertool.additionaloptions?view=visualstudiosdk-2022
// https://en.wikipedia.org/wiki/Unicode_in_Microsoft_Windows#UTF-8
// https://stackoverflow.com/questions/41335199/how-to-config-visual-studio-to-use-utf-8-as-the-default-encoding-for-all-project
// TODO summary from https://stackoverflow.com/questions/1857668/c-visual-studio-character-encoding-issues
// Unicode overview https://www.codeproject.com/Articles/38242/Reading-UTF-8-with-C-streams

// lang compat https://learn.microsoft.com/de-de/cpp/overview/visual-cpp-language-conformance?view=msvc-170

#if defined(_WIN32) && defined(_MSC_VER)

#if (__cplusplus == 202302L)
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
#endif // (__cplusplus == 202302L)

// file Stdafx.h

// TODO C++26 use WideCharToMultiByte(CP_UTF8 ..), MultiBytetoWideChar
// and remove following macro to ignore deprecation
// #define _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING

// C++23 use std::atomic<std::shared_ptr<>> for atomic shared_ptr
// and **never** use following macro to ignore deprecation, because it may silently
// miscompile code
// #define _SILENCE_CXX20_OLD_SHARED_PTR_ATOMIC_SUPPORT_DEPRECATION_WARNING
// #include "Stdafx.h"

#endif // defined(_WIN32) && defined(_MSC_VER)

#include <stdint.h>
#include <stdio.h>

int32_t main() {
  fprintf(stdout, "hello world\n");
  return 0;
}
