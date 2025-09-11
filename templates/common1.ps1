#! Common PowerShell operations

# Other files
# :PWConf windows\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# :Templates templates\powershell
#====common_paths
#====cli
#====file_watcher
#====access_control
#====encoding

# https://4sysops.com/archives/measure-object-computing-the-size-of-folders-and-files-in-powershell/
# https://www.gngrninja.com/script-ninja/2016/5/24/powershell-calculating-folder-sizes

https://devblogs.microsoft.com/scripting/category/windows-powershell/
https://devblogs.microsoft.com/powershell-community/
module handling (distributed profiles) https://devblogs.microsoft.com/powershell-community/creating-a-scalable-customised-running-environment/
misc tweaks tab completion, keybinds, $profile, https://devblogs.microsoft.com/powershell-community/cheat-sheet-console-experience/
$host.Name, $PROFILE, $PROFILE | Get-Member -MemberType NoteProperty, VSCode profile https://devblogs.microsoft.com/powershell-community/how-to-make-use-of-powershell-profile-files/
Get-NetAdapter, Rename-NetAdapter
dir | clip
echo "123" | Set-Clipboard, Get-Clipboard
// beware of encoding horrors in PS5, for example by Get-ChildItem truncating content on piping
file event watcher https://devblogs.microsoft.com/powershell-community/a-reusable-file-system-event-watcher-for-powershell/

Time measurements: Measure-Command
Get PowerShell version: echo $PSVersionTable

# SHENNANIGAN
# , is join operator which may silently work or break the program
# worse, C# code calls use C# syntax ie
# Add-Type -AssemblyName System.IO.Compression.FileSystem ;
# [System.IO.Compression.ZipFile]::ExtractToDirectory("$NEOVIM_TMP_DIR\$zip_target", "$NEOVIM_TMP_DIR\")

# ====common_paths
# echo $profile shows powershell configuration
# $HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# $HOME/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
# $HOME\AppData\Local\Mozilla\Firefox\
# $HOME/AppData/Local/Mozilla/Firefox/
# C:\Users\$USER\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# C:\Users\$($env:username)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

#====cli
# realpath pendant: Resolve-Path Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# copy recursive: cp -r -fo $HOME\dotfiles\.config\nvim $HOME\AppData\Local
#  long form: Copy-Item -Path $HOME\dotfiles\.config\nvim -Destination $HOME\AppData\Local -Recurse -Force
#  Pull all elements into top level destination scope via '-Container:$false'
#  rsync equivalent via robocopy

#local persistent drives from dirs
# if exist Z: net use Z: /delete /yes
# net use Z: \\$dns_name\mailbox /persistent:yes
#mount drive from dirs
# net use R: /delete
# subst R: $HOME\somedir
# subst R: /d
#check logical disks of system
# wmic logicaldisk get name
#more common with $path as "\\$ip\.."
# net use D: /delete /yes
# net use /d $path
# net use $path "$pw" /USER:"$user"
# subst D: /d
# subst D: $HOME\somedir

#====file_watcher
# https://superuser.com/questions/226828/how-to-monitor-a-folder-and-trigger-a-command-line-action-when-a-file-is-created
# https://powershell.one/tricks/filesystem/filesystemwatcher
# in lua for windows file system via winapi lua bindings https://github.com/stevedonovan/winapi with https://stevedonovan.github.io/winapi/api.html#watch_for_file_changes
# or via ETW
# TODO

#====access_control
# icacls is chmod and chown together.
# Permissions:
#   Full access (F)
#   Modify access (M) (includes ‘delete’)
#   Read and execute access (RX)
#   Read-only access (R)
#   Write-only access (W)
# icacls .\fileBackup.ps1
# icacls .\fileBackup.ps1 /grant group\user:RX /t /c
# /t for tree (recursive), /c to continue on error
#
# exceptional cases only: icacls Download /deny group\user:(OI)(CI)F /t /c
# reset: icacls Download /reset /t /c
# icacls Download /save Download_ACL_backup /t
# icacls Download /restore Download_ACL_backup /t
# icacls AdminOnly /setintegritylevel high
# icacls DisabledInheritanceDir /inheritance:d /t /c
#
# Get integrity level: whoami /groups
# A Process must have (at least) the integrity of the binary/process/file it tries
# to access or gets 'permission denied'.

#====encoding
# * git stores internally files as utf-8 and with eol lf
# idea powershell script
# 0. file name + path
# 1. consistent file ending and print otherwise diverging occurences with line number
# 2. file format printing filtering if not in list
# 3. normalize line endings
# 4. reencoding and check if successful

# only checks for exceptions and externally invoked commands
# does not check function return values
# function returns are wonky and functions must suppress all command output,
# for example with [void](command..)
# or use # $proc = Start-Process "$msBuild" .. with $proce.ExitCode
# Probably flushing/dropping stdout works to use simple integers for fn returns.
function GetLastExitCode {
  return !$?
}

# for msbuild step use exit code 0 or 1
# if needed, use global param to script:
# param(
#   [switch] $in_msbuild = $false
# )
function msbuild_CheckExitCode {
  $last_exit_code = GetLastExitCode
  if ($last_exit_code -ne 0) {
    if ($in_msbuild) {
      Write-Host "error $last_exit_code, exiting.."
      exit 1
    } else {
      exit $last_exit_code
    }
  }
}

function CheckExitCode {
  $code = getLastExitCode
  if ($code -ne 0) {
    exit $code
  }
}

function ResolveMsBuild2015 {
  #& "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe" .\Solution.sln
  $msb2017 = Resolve-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\MSBuild\*\bin\msbuild.exe" -ErrorAction SilentlyContinue
  if($msb2017) {
    # Write-Host "Found MSBuild 2017 (or later)."
    $msb2017_first = $msb2017 | Select-Object -First 1
    Write-Verbose "Found MSBuild 2015 at $msb2017_first"
    return $msb2017_first
  }
  $msBuild2015 = "${env:ProgramFiles(x86)}\MSBuild\14.0\bin\msbuild.exe"
  if(-not (Test-Path $msBuild2015)) {
    throw 'Could not find MSBuild 2015.'
  }
  Write-Verbose "Found MSBuild 2015 at $msBuild2015"
  return $msBuild2015
}

# SHENNANIGAN Parallel cleanup is broken in msbuild
function runMsbuild2015 {
  # msbuild test.sln /t:project /p:Configuration="Release" /p:Platform="x64" /p:BuildProjectReferences=false
  # Notice that what is assigned to /t is the project name in the solution, it can be different from the project file name.
  # Also, as stated in How to: Build specific targets in solutions by using MSBuild.exe:
  #     If the project name contains any of the characters %, $, @, ;, ., (, ), or ', replace them with an _ in the specified target name.
  # You can also build multiple projects at once:
  # msbuild test.sln /t:project1;project2 /p:Configuration="Release" /p:Platform="x64" /p:BuildProjectReferences=false
  # To rebuild or clean, change /t:project to /t:project:clean or /t:project:rebuild
  param (
    [string[]] $build_args
    [string] $at = "."
  )
  [string] $msBuild = ResolveMsBuild2015
  Write-Verbose "build_args: $($build_args -join ' ')"
  return sane_StartProcess $msBuild $build_args $at
}

function ResolveMsBuild {
  param (
    # version[e|p|c] for enterprise, professional, community
    [string] $msvc_version
  )
  [int] $year = [int]$($msvc_version -replace "[^0-9]" , '')
  [string] $type = [string]$($msvc_version -replace "[0-9]" , '')

  switch ($year) {
    2015 { throw 'Visual Studio 2015 is unsupported.' }
    2019 { throw 'Visual Studio 2019 is unsupported.' }
    2022 {
      [string] $wip_pa = ""
      switch ($type) {
        "c" { $wip_pa = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" }
        "e" { $wip_pa = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" }
        "p" { $wip_pa = "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" }
        default { throw "Unknown Visual Studio 2022 type $_ unsupported" }
      }
      [string] $check_pa = Resolve-Path $wip_pa
      if($check_pa) { return $check_pa }
      throw "Could not find msbuild at $wip_pa."
    }
    default { throw "Detected version year $year unsupported." }
  }
}

function runMsbuild {
  param (
    # msbuild: /m for parallelism, /nr:false to prevent failing builds getting stuck
    # Debug problems via -v:Lvl Lvl is q,m,n,d,diag
    # msbuild project.sln /t:Build /p:Configuration=Release /p:Platform=x64 /nologo /v:d
    # sane default @(".\SolutionFile.sln", "/t:Build", "/p:Configuration=Release", "/p:Platform=x64", "/nologo", "/m")
    [string[]] $build_args,
    # version[e|p|c] for enterprise, professional, community
    [string] $msvc_version = "2022e"
  )
  [string] $msBuild = ResolveMsBuild $msvc_version
  Write-Host "Start-Process $msBuild -ArgumentList $build_args -NoNewWindow -PassThru"
  $proc = Start-Process "$msBuild" -ArgumentList $build_args -NoNewWindow -PassThru
  $handle = $proc.Handle # cache proc.Handle to fix ExitCode to work correctly
  $proc.WaitForExit() # early terminate on msbuild error instead of waiting 15min
  if ($proc.ExitCode -ne 0) {
    Write-Error "build error: $($proc.ExitCode), exiting.."
    exit 2
  }
}

function easytypos_param {
  param (
    [string] action1 = "echo"
    # SHENNANIGAN very easy typos in param
    # [string] action2 = "echo",
  )
}

# alternative: tasklist, taskkill
# function checkThrowServer {
#   # to make -Verbose etc working
#   [CmdletBinding()] param (
#     [switch] $killprocs = $false
#   )
#   $cur_proc = Get-Process | Where {$_.ProcessName -eq "Server"} | & "echo"
#   if ($cur_proc -ne "") {
#     if ($killprocs) {
#       & Get-Process | Where {$_.ProcessName -eq "Server"} | Stop-Process -Force
#     } else {
#       throw 'execute: Get-Process | Where {$_.ProcessName -eq "Server"} | Stop-Process -Force'
#     }
#   }
# }
# function checkThrowClient {
#   $cur_proc = Get-Process | Where {$_.ProcessName -eq "Client"} | & "echo"
#   if ($cur_proc -ne "") {
#     throw 'execute: Get-Process | Where {$_.ProcessName -eq "Client"} | Stop-Process -Force'
#   }
# }

function RunActionOnProcess {
  param (
    [string] action = "echo"
  )
  Get-Process | Where {$_.ProcessName -eq "Server"} | & $action
  # Get-Process | Where {$_.ProcessName -eq "Server"} | Stop-Process -Force
}

function RunInDir {
param (
  [string] dirpath = "."
)
  try {
      Push-Location
      Set-Location "$dirpath"
      git status
  }
  finally {
      Pop-Location
  }
}

function basic_FileOperations {
param (
  [string] git_dir = "."
)
  #
  if (-not (Test-Path "$git_dir\.git\")) {
    [string[]] $files =  @("file1", "file2")
    $git_dir_files = $files.ForEach({"${git_dir}\$_"})

    $content = Get-Content -Path ".\GitCommit.txt"
    if (Test-Path "$git_dir\..\bakgit\") { throw "found existing path $git_dir\..\bakgit\" }
    Move-Item -Path "$git_dir" "$git_dir\..\bakgit\"
    Remove-Item -Path "$git_dir" -Recurse -Force -ErrorAction Ignore
    git clone "some_repo.git" "$git_dir"
    CheckExitCode
    git clean -f -X -d
    CheckExitCode
}

function basic_7z {
param (
  [string] $7zpath = "",
  [string] $destpath = "",
  [string[]] $pa_files = @("")
)
  if (-not (Test-Path "$7zpath")) {
    Write-Host "ERROR: Abort, no 7z path $7zpath"
    return 1
  }

  $zipname = "${version}_Name.zip"
  # $zipname = "${version}_NamePdb.zip"
  # $pdbpw = "123456"
  $zippath = "$destpath\$zipname"
  if (-not (Test-Path "$zippath")) {
    Write-Host "# 1: zip files into $zipname .."
    $tmp_7zargs = @("a", "-bsp1", "-mx5", "$zippath")
    # $tmp_7zargs = @("a", "-bsp1", "-mx5", "-p$pdbpw", "$zippath")
    [string[]] $7zargs = $tmp_7zargs + $pa_files
    Write-Host "# 2: 7z args: $7zargs"
    $st = sane_StartProcess $7z $7zargs
    if ($st -ne 0) { return $st }
  }
}

function basic_wixinstaller {
  # TODO
}

function basic_stringops {
  # concat
  [string[]] $files1 = @("t1", "t2")
  [string[]] $files2 = @("t3", "t4")
  $files = $files1 + $files2
  for ($i=0; $i -lt $files.Length; $i+=1) {
    Write-Host "$($files[$i])"
  }

  # parse
  # see ResolveMsBuild
  [string]$gitcommit = [string]$(git rev-parse HEAD)
  [int] $year = [int]$($msvc_version -replace "[^0-9]" , '')
  [string] $filepath = "README.md"
  [string] $verified = "unknown"
  $sigcheck_output = sigcheck.exe -accepteula -q $filepath
  # or foreach ($mixed_line_str in (sigcheck.exe -accepteula -q $filepath))
  foreach ($mixed_line_str in $sigcheck_output) {
    # searching for line with 'Verified:   ...'
    $line_str = $mixed_line_str -replace ("`t", " ")
    $line = $line_str -split " "
    # Write-Debug "${line_str}, length: $($line.Length)"
    if (($line.Length -eq 2) -and ($line[1] -eq "Verified:")) {
      # Write-Debug " >>>> ${line_str} 1 $($line[1])"
      $verified = [string]$line[2]
      Write-Debug "${verified}"
    }
  }
}
