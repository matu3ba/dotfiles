# powershell script to parse devkit version and install Zig
# assume: 1. devkit in dir devkit, zig in dir zig in same dir
#         2. cmake installed (download possible on https://cmake.org/download/)
#         3. ninja installed (pip install ninja) + in path
# addStandaloneTests
#
# TODO: parse pip show output
# $env:Path += ';C:\Users\hafer\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.10_qbz5n2kfra8p0\LocalCache\local-packages\Python310\site-packages\ninja'
#         (TODO)
#         4. powershell scripts executable (execution in shell):
#         Get-Content bZig.ps1 | PowerShell.exe -noprofile -


$draftpathninja = pip show ninja
$pathninja = $draftpathninja[7].Split(" ")[1]
$joinpath = -join("'", $pathninja, "\ninja'")
$env:Path += $joinpath

function CheckLastExitCode {
    if (!$?) {
        exit 1
    }
    return 0
}

# replace with other dir, if needed
$COMMON_DIR = -join('C:\Users\', $env:UserName, '\Desktop')
Set-Location -Path $COMMON_DIR
$line = Get-ChildItem -Path .\zig\ci\x86_64-windows.ps1 -Recurse | Select-String -Pattern 'ZIG_LLVM_CLANG_LLD_NAME ='
$splitted = $line -split "-"
$version_raw = -join($splitted[3], "-", $splitted[4])
$VERSION = $version_raw.Substring(0,$version_raw.Length-1)
$TARGET = "x86_64-windows-gnu"
$ZIG_LLVM_CLANG_LLD_NAME = "zig+llvm+lld+clang-$TARGET-$VERSION"
$MCPU = "baseline"
$PREFIX_PATH = "$(Get-Location)\$ZIG_LLVM_CLANG_LLD_NAME"
$ZIG = "$PREFIX_PATH\bin\zig.exe"
$ZIG_LIB_DIR = "$(Get-Location)\lib"

$CMAKE = -join('C:\Users\', $env:UserName, '\Desktop\cmake\bin\cmake.exe')

Set-Location -Path 'zig'
Write-Output "Preparing dirs.."
Remove-Item -Path 'build' -Recurse -Force -ErrorAction Ignore
New-Item -Path 'build' -ItemType Directory
Set-Location -Path 'build'

Write-Output "Preparing cmake.."
& $CMAKE .. `
  -GNinja `
  -DCMAKE_INSTALL_PREFIX="stage3-release" `
  -DCMAKE_PREFIX_PATH="$($PREFIX_PATH -Replace "\\", "/")" `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_C_COMPILER="$($ZIG -Replace "\\", "/");cc;-target;$TARGET;-mcpu=$MCPU" `
  -DCMAKE_CXX_COMPILER="$($ZIG -Replace "\\", "/");c++;-target;$TARGET;-mcpu=$MCPU" `
  -DZIG_TARGET_TRIPLE="$TARGET" `
  -DZIG_TARGET_MCPU="$MCPU" `
  -DZIG_STATIC=ON
CheckLastExitCode

Write-Output "building+installing.."
ninja install
CheckLastExitCode
