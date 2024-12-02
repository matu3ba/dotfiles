# x86_64-windows CI script to clean cache, if necessary
function CheckLastExitCode {
    if (!$?) { exit 1 }
    return 0
}

$MAX_SIZE_B = 2147483648 #2 GB = 2*(1024)**3 B
[string] $ZIG_CACHE_DIR = $(zig env | jq '. "global_cache_dir"')
$CHECK_SIZE_B = ((gci $ZIG_CACHE_DIR | measure Length -s).Sum
if ($CHECK_SIZE_B -gt $MAX_SIZE_B) {
  Remove-Item -Recurse -Force -ErrorAction Ignore -Path $ZIG_CACHE_DIR
  CheckLastExitCode
}

zig env
CheckLastExitCode

zig build -Dno_opt_deps -Dno_cross test --summary all
CheckLastExitCode
