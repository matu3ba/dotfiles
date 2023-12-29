$ZIG_URL_JSON = "https://ziglang.org/download/index.json"
$ZIG_TMP_DIR = "$HOME\tmp"

function CheckLastExitCode ($pwd) {
    if (!$?) {
        Set-Location -Path "$pwd"
        exit 1
    }
    return 0
}

$PWD = Get-Location
Write-Output "$PWD"

Set-Location -Path "$HOME"

if (!(Test-Path "$ZIG_TMP_DIR")) {
  New-Item -Path "$ZIG_TMP_DIR" -ItemType Directory
}

$ZIG_BUILDS = Invoke-RestMethod -Uri "$ZIG_URL_JSON"
CheckLastExitCode($PWD)
$ZIG_TARBALL = $ZIG_BUILDS.master."x86_64-windows".tarball
Write-Output  $ZIG_BUILDS.master."x86_64-windows".tarball
Write-Output  $ZIG_BUILDS.master."x86_64-windows".shasum
Write-Output  $ZIG_BUILDS.master."x86_64-windows".size
$ZIP_TARGET = Split-Path  -Leaf $ZIG_TARBALL
$ZIP_TARGET_BASENAME = Split-Path -LeafBase $ZIP_TARGET

$UNZIP_TARGET_ZIG = "$ZIG_TMP_DIR\$ZIP_TARGET_BASENAME\zig.exe"
$UNZIP_TARGET_LIB = "$ZIG_TMP_DIR\$ZIP_TARGET_BASENAME\lib"

Write-Output "unzip zig: $UNZIP_TARGET_ZIG"
Write-Output "unzip lib: $UNZIP_TARGET_LIB"

if (Test-Path "$ZIG_TMP_DIR\$ZIP_TARGET") {
  Write-Output  "Zig already up to date"
  Set-Location -Path "$PWD"
  exit 0
} else {
  Write-Output  "Zig not up to date, fetching zip into $ZIG_TMP_DIR\$ZIP_TARGET"
}
Invoke-WebRequest -Uri "$ZIG_TARBALL" -OutFile "$ZIG_TMP_DIR\$ZIP_TARGET"
CheckLastExitCode($PWD)

Write-Output  "Deleting old Zig instance.."
Remove-Item -Path "$HOME\bin\zig.exe" -ErrorAction Ignore
Remove-Item -Path "$HOME\bin\lib" -Recurse -Force -ErrorAction Ignore
CheckLastExitCode($PWD)

Write-Output "Unpacking $ZIG_TMP_DIR\$ZIP_TARGET .."

Add-Type -AssemblyName System.IO.Compression.FileSystem ;
[System.IO.Compression.ZipFile]::ExtractToDirectory("$ZIG_TMP_DIR\$ZIP_TARGET", "$ZIG_TMP_DIR\")
CheckLastExitCode($PWD)

# move unpacked zig and lib to "$HOME\bin"
Move-Item -Path "$UNZIP_TARGET_ZIG" -Destination "$HOME\bin"
CheckLastExitCode($PWD)
Move-Item -Path "$UNZIP_TARGET_LIB" -Destination "$HOME\bin"
CheckLastExitCode($PWD)

Write-Output "Unpacking finished, Zig was updated."
Set-Location -Path "$PWD"
exit 0