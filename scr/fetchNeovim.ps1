# idea once merged: build from source with zig https://github.com/neovim/neovim/pull/28344
$NEOVIM_RELEASES_URL = "https://api.github.com/repos/neovim/neovim/releases"
$NEOVIM_TMP_DIR = "$HOME\tmp"
$NEOVIM_URL_ZIP = "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip"
$VERSION = "0.12.0"
function CheckLastExitCode {
  param ( [string] $pwd)
  if (!$?) {
      Set-Location -Path "$pwd"
      exit 1
  }
  return 0
}
function IfExistDelFile {
  param ( [string] $filepath, [string] $pwd)
  if (Test-Path "$filepath") {
    Write-Output "Removing $filepath.."
    Remove-Item -Path "$filepath"
    CheckLastExitCode($pwd)
  } else {
      Write-Output "Nonexist $filepath.."
  }
}
function IfExistDelDir {
  param ( [string] $dirpath, [string] $pwd)
  if (Test-Path "$dirpath") {
    Remove-Item -Path "$dirpath" -Recurse -Force
    CheckLastExitCode($pwd)
  } else {
      Write-Output "Nonexist $dirpath.."
  }
}
function MoveNvimItem {
  param (
      [string] $unzip_target
    , [string] $target_path
    , [string] $itempath
    , [string] $pwd
  )
  # Write-Output "1 $unzip_target, 2 $target_path, 3 $itempath, 4 $pwd, $HOME\tmp\"
  # Write-Output "$HOME\tmp\$unzip_target\$itempath pa2 $target_path\$itempath"
  [string] $unzippath = "$HOME\tmp\$unzip_target"
  [string] $src = "$unzippath\$itempath"
  [string] $dest = "$target_path\$itempath"
  Write-Output "in MoveNvimItem: $src $dest"
  Move-Item -Path "$src" -Destination "$dest"
  CheckLastExitCode($pwd)
}
function MoveUnpackedNeovim {
  param (
      [string] $unzip_target
    , [string] $target_path
    , [string] $pwd
  )
  Write-Output "$unzip_target, $target_path"
  Write-Output "bin\cat.exe $pwd"
  MoveNvimItem $unzip_target $target_path 'bin\cat.exe' $pwd
  MoveNvimItem $unzip_target $target_path 'bin\dbghelp.dll' $pwd
  MoveNvimItem $unzip_target $target_path 'bin\lua51.dll' $pwd
  MoveNvimItem $unzip_target $target_path 'bin\nvim.exe' $pwd
  MoveNvimItem $unzip_target $target_path 'bin\nvim.pdb' $pwd
  MoveNvimItem $unzip_target $target_path 'bin\tee.exe' $pwd
  MoveNvimItem $unzip_target $target_path 'bin\win32yank.exe' $pwd
  MoveNvimItem $unzip_target $target_path 'bin\xxd.exe' $pwd
  MoveNvimItem $unzip_target $target_path 'lib\nvim' $pwd
  MoveNvimItem $unzip_target $target_path 'share\applications' $pwd
  MoveNvimItem $unzip_target $target_path 'share\locale' $pwd
  MoveNvimItem $unzip_target $target_path 'share\man' $pwd
  MoveNvimItem $unzip_target $target_path 'share\nvim' $pwd
}

$PWD = Get-Location
Write-Output "$PWD"
Set-Location -Path "$HOME"
if (!(Test-Path "$NEOVIM_TMP_DIR")) {
  New-Item -Path "$NEOVIM_TMP_DIR" -ItemType Directory
}

if (Get-Process -ProcessName nvim -ErrorAction SilentlyContinue) {
  Write-Output "there exist opened nvim instances, exiting.."
  Set-Location -Path "$PWD"
  exit 2
}
$neovim_release_json = $(Invoke-WebRequest $NEOVIM_RELEASES_URL | convertfrom-json)
CheckLastExitCode($PWD)
if ($neovim_release_json[0]."tag_name" -ne "nightly") {
  Write-Output "did not find tag nightly"
  Set-Location -Path "$PWD"
  exit 3
}
$COMMIT = $neovim_release_json[0]."target_commitish"
$zip_target = "nvim-windows-x86_64-$VERSION-$COMMIT.zip"
$unzip_target = "nvim-windows-x86_64-$VERSION-$COMMIT"

if (Test-Path "$NEOVIM_TMP_DIR\$zip_target") {
  Write-Output  "Neovim already up to date"
  Set-Location -Path "$PWD"
  exit 0
} else {
  Write-Output  "Neovim not up to date, fetching zip into $NEOVIM_TMP_DIR\$zip_target"
  Invoke-WebRequest -Uri "$NEOVIM_URL_ZIP" -OutFile "$NEOVIM_TMP_DIR\$zip_target"
  CheckLastExitCode($PWD)
}

Write-Output "Deleting old Neovim instance.."
IfExistDelFile "$HOME\.local\bin\cat.exe" $PWD
IfExistDelFile "$HOME\.local\bin\dbghelp.dll" $PWD
IfExistDelFile "$HOME\.local\bin\lua51.dll" $PWD
IfExistDelFile "$HOME\.local\bin\nvim.exe" $PWD
IfExistDelFile "$HOME\.local\bin\nvim.pdb" $PWD
IfExistDelFile "$HOME\.local\bin\tee.exe" $PWD
IfExistDelFile "$HOME\.local\bin\win32yank.exe" $PWD
IfExistDelFile "$HOME\.local\bin\xxd.exe" $PWD
IfExistDelDir "$HOME\.local\lib\nvim" $PWD
IfExistDelDir "$HOME\.local\share\applications" $PWD
IfExistDelDir "$HOME\.local\share\locale" $PWD
IfExistDelDir "$HOME\.local\share\man" $PWD
IfExistDelDir "$HOME\.local\share\nvim" $PWD

$zip_target = "nvim-windows-x86_64-0.12.0-e27f7125d66f6026adacbbad00bbf6e66a6ba883.zip"
$unzip_target = "nvim-windows-x86_64-0.12.0-e27f7125d66f6026adacbbad00bbf6e66a6ba883"
Write-Output "Unpacking $NEOVIM_TMP_DIR\$zip_target .."
New-Item -Path "$NEOVIM_TMP_DIR\$unzip_target" -ItemType Directory
CheckLastExitCode($PWD)
Expand-Archive -Path "$NEOVIM_TMP_DIR\$zip_target" -DestinationPath "$NEOVIM_TMP_DIR\$unzip_target"
CheckLastExitCode($PWD)
Move-Item -Path "$NEOVIM_TMP_DIR\$unzip_target\nvim-win64\*" -Destination "$NEOVIM_TMP_DIR\$unzip_target"
CheckLastExitCode($PWD)
Remove-Item -Path "$NEOVIM_TMP_DIR\$unzip_target\nvim-win64" -Recurse -Force
CheckLastExitCode($PWD)

MoveUnpackedNeovim $unzip_target "$HOME\.local" $PWD

Write-Output "Unpacking finished, Zig was updated."
Set-Location -Path "$PWD"
exit 0
