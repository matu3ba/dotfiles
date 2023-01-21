# powershell script to build Zig with devkit
# assume: 1. devkit in dir devkit, zig in dir zig in same dir
#         2. powershell script executable (execution in shell):
#         Get-Content uZigWinDevKit.ps1 | PowerShell.exe -noprofile -

$TARGET="x86_64-windows-gnu"
$ZIG_LLVM_CLANG_LLD_NAME="zig+llvm+lld+clang-$TARGET-0.11.0-dev.448+e6e459e9e"
$DEVKIT = "$(Get-Location)\devkit\$ZIG_LLVM_CLANG_LLD_NAME"

$COMMON_DIR = -join('$:\Users\', $env:UserName, '\Desktop')
Set-Location -Path $COMMON_DIR

New-Item "devkit" -Type Directory

Write-Output "Extracting..."
Add-Type -AssemblyName System.IO.Compression.FileSystem ;
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/devkit.zip", "$PWD/devkit")
