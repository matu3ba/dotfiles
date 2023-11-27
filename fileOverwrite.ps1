## Force overwrite specified configurations from src and dest
## File format of $WIN_SRC_DEST:
##   # comments
##   src $HOME\dotfiles\.config\nvim
##   dest $HOME\AppData\Local
## Result: cp -r -fo $HOME\dotfiles\.config\nvim $HOME\AppData\Local
param(
  [switch] $dry = $false,
  [switch] $verbose = $false
)
$CWD_START = $PWD
$DOTFILE_PATH = "$HOME\dotfiles"
$WIN_SRC_DEST = "$HOME\dotfiles\win_src_dest"

function CheckLastExitCode {
    if (!$?) {
        exit 1
    }
    return 0
}

if ($verbose) {
  if (-Not ($dry)) {
    Write-Output $('dry mode, not overwriting paths from ' + $WIN_SRC_DEST)
  } else {
    Write-Output $('overwriting paths from ' + $WIN_SRC_DEST)
  }
}

$content = Get-Content -Path $WIN_SRC_DEST
$SrcPath = ""
$DestPath = ""
if ($verbose) { Write-Output("lines: $($content.Length)") }
for ($i=0; $i -lt $content.Length; $i+=1) {
  if (($content[$i] -eq "") -Or ($content[$i].StartsWith("#"))) {
    continue
  }
  if (-Not ($content[$i].StartsWith("src "))) {
    Write-Output "'${WIN_SRC_DEST}:$($i+1)': no prefix 'src ', exiting.. "; exit 1;
  }
  $SrcPath = $content[$i].Substring(4)
  if ($verbose) { Write-Output $SrcPath }
  $i+=1
  if (-Not ($content[$i].StartsWith("dest "))) {
    Write-Output "'${WIN_SRC_DEST}:$($i+1)': no prefix 'dest ', exiting.. "; exit 1;
  }
  $DestPath = $content[$i].Substring(5)
  $Cmd = "cp -r -fo $SrcPath $DestPath"
  $IexecCmd = '& ' + $Cmd
  if ($verbose) { Write-Output $Cmd }
  # Write-Output $IexecCmd
  # cp -r -fo $SrcPath $DestPath
  if (-Not ($dry)) {
    Invoke-Expression $IexecCmd
  }
  CheckLastExitCode
}