# powershell script to build Zig with devkit
# assume: 1. devkit in dir devkit, zig in dir zig in same dir
#         2. powershell script executable (exeuciton in shell):
#         Get-Content bZigWinDevKit.ps1 | PowerShell.exe -noprofile -

function CheckLastExitCode {
    if (!$?) {
        exit 1
    }
    return 0
}

$COMMON_DIR = -join('$:\Users\', $env:UserName, '\Desktop')
Set-Location -Path $COMMON_DIR
#cp ~/scr/bZigWinDevKit.ps1 /mnt/c/Users/$USER/Desktop

#grep 'ZIG_LLVM_CLANG_LLD_NAME =' /mnt/c/Users/$USER/Desktop/zig/ci/x86_64-windows-debug.ps1 > /mnt/c/Users/$USER/Desktop/pzdown.txt
$TARGET="x86_64-windows-gnu"
$ZIG_LLVM_CLANG_LLD_NAME="zig+llvm+lld+clang-$TARGET-0.11.0-dev.448+e6e459e9e"
$DEVKIT = "$(Get-Location)\devkit\$ZIG_LLVM_CLANG_LLD_NAME"

Set-Location -Path 'zig'
& $DEVKIT\bin\zig.exe build -p bdeb --search-prefix $DEVKIT --zig-lib-dir lib -Dstatic-llvm -Duse-zig-libcxx -Dtarget=x86_64-windows-gnu
CheckLastExitCode
