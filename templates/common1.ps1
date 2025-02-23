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

# mount directory as drive
# net use R: /delete
# subst R: $HOME\somedir
# subst R: /d
# check logical disks of system
# wmic logicaldisk get name
# net use D: /delete /yes
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
