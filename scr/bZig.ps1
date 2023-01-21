# powershell script to build Zig with devkit
# assume: 1. devkit in dir devkit, zig in dir zig in same dir
#         2. powershell script executable (execution in shell):
#         Get-Content bZig.ps1 | PowerShell.exe -noprofile -

function CheckLastExitCode {
    if (!$?) {
        exit 1
    }
    return 0
}

Write-Output "cding into $COMMON_DIR.."
$COMMON_DIR = -join('C:\Users\', $env:UserName, '\Desktop')
Set-Location -Path $COMMON_DIR
# WSL
#cp ~/scr/bZigWinDevKit.ps1 /mnt/c/Users/$USER/Desktop
#grep 'ZIG_LLVM_CLANG_LLD_NAME =' /mnt/c/Users/$USER/Desktop/zig/ci/x86_64-windows-debug.ps1 > /mnt/c/Users/$USER/Desktop/pzdown.txt
# git bash
#cp ~/scr/bZigWinDevKit.ps1 /c/Users/$USERNAME/Desktop
#grep 'ZIG_LLVM_CLANG_LLD_NAME =' /c/Users/$USERNAME/Desktop/zig/ci/x86_64-windows-debug.ps1 > /c/Users/$USERNAME/Desktop/pzdown.txt

# we should use Windows, because git bash complains about broken symlinks
# Expand-Archive devkit.zip -DestinationPath devkit # very slow
# Write-Output "Extracting..."
# Add-Type -AssemblyName System.IO.Compression.FileSystem ;
# [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/$ZIG_LLVM_CLANG_LLD_NAME.zip", "$PWD")

$TARGET="x86_64-windows-gnu"
$ZIG_LLVM_CLANG_LLD_NAME="zig+llvm+lld+clang-$TARGET-0.11.0-dev.448+e6e459e9e"
$DEVKIT = "$(Get-Location)\devkit\$ZIG_LLVM_CLANG_LLD_NAME"

#$ZIGEXEC = "$DEVKIT\bin\zig.exe"
# master build, if DEVKIT is too old
$ZIGEXEC = "$(Get-Location)\zignew\zig.exe"

Set-Location -Path 'zig'
& $ZIGEXEC build -p bdeb --search-prefix $DEVKIT --zig-lib-dir lib -Dstatic-llvm -Duse-zig-libcxx -Dtarget=x86_64-windows-gnu
CheckLastExitCode
