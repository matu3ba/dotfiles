#! Common PowerShell operations

# Other files
# :PWConf windows\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# :Templates templates\powershell
#====variables
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

Time measurements: Measure-Command { CMD }
Get PowerShell version: echo $PSVersionTable

# SHENNANIGAN
# , is join operator which may silently work or break the program
# worse, C# code calls use C# syntax ie
# Add-Type -AssemblyName System.IO.Compression.FileSystem ;
# [System.IO.Compression.ZipFile]::ExtractToDirectory("$NEOVIM_TMP_DIR\$zip_target", "$NEOVIM_TMP_DIR\")

#====variables
#types
$obj | Get-Member
$obj.GetType
#content formatting (try out for PSCustomObject)
Write-Output ($obj | Format-List | Out-String)
Write-Output ($obj | Format-Table | Out-String)

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

# Assumes VSSetup installed, for example via
# Install-Module VSSetup -Scope CurrentUser
function GetMsbuildPath {
  $msbuild_root = Get-VSSetupInstance -All | Select-VSSetupInstance -Require 'Microsoft.VisualStudio.Workload.ManagedDesktop' -Latest
  if (($msbuild_root.installationPath -eq $Null) -or ($msbuild_root.installationPath -eq "")) {
    return ""
  }
  return $msbuild_root.installationPath + '/MSBuild/Current/Bin/MSBuild.exe'
}

#see GetMsbuildPath
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

#see GetMsbuildPath
function ResolveMsBuild_old {
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
  [string] $msBuild = ResolveMsBuild_old $msvc_version
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
  # see ResolveMsBuild_old
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

#Get-Process | Sort-Object -Property WS | Select-Object -Last 5
#Get-Process | Select-Object -Property ProcessName, Id, WS
# Select-Object -Skip 1

# selecting newest/oldest events in event protocol
$a = Get-WinEvent -LogName "Windows PowerShell"
$a | Select-Object -Index 0, ($a.count - 1)

function rename_files_for_manual_checks {
  Get-ChildItem *.txt -ReadOnly |
    Rename-Item -NewName {$_.BaseName + "-ro.txt"} -PassThru |
    Select-Object -First 5 -Wait
}

function filter_childitems {
  Get-ChildItem .\* -Include "MyProject.Data*.dll", "EntityFramework*.dll"
  Get-ChildItem -Filter "*.dll" .\* | Where-Object { $_.Name -match '^MyProject.Data.*|^EntityFramework.*' }
}

function show_object_properties {
  $object = [pscustomobject]@{Name="CustomObject";Expand=@(1,2,3,4,5)}
  $object | Select-Object -ExpandProperty Expand -Property Name
  $object | Select-Object -ExpandProperty Expand -Property Name | Get-Member
}

# always write output: Write-Host
# write to stdout: Write-Output
# write on switch -Debug: Write-Debug
# write in red color with Write-Host: Write-Warning
# write non-terminatign error class: Write-Error/Throw
# * can be used to terminate via $ErrorActionPreference = "Stop";
# * Write-Error "Unable to connect to server." -Category ConnectionError
# * use throw, if you want program execution to stop
# write on switch -Verbose: Write-Verbose
# write process: Write-Progress -Activity "Activity $activity" -PercentComplete $perc

# idea get stacktrace in powershell
#https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions?view=powershell-7.4
# https://stackoverflow.com/questions/795751/can-i-get-detailed-exception-stacktrace-in-powershell

# idea find installed software
# https://devblogs.microsoft.com/scripting/use-powershell-to-find-installed-software/

# execute fn as another powershell session
#powershell -command "& { . <path>\script1.ps1; My-Func }"
# execute fn from current powershell session
#. .\script.ps1
#My-Func

function param_string_array {
  # usage if escaping needed (wsl): pwsh -Command ./myScript.ps1 -Hosts "host1,host2,host3" -VLAN 2
  # usage if no escaping needed: .\myScript.ps1 -Hosts host1,host2,host3 -VLAN 2
  param (
    [string[]] $hosts = @("t1", "t2")
  )

  "hosts: $($data -join ',')"
  # [system.String]::Join(" ", $hosts)
  # output: "t1 t2"
}

# Debug problems via -v:Lvl Lvl is q,m,n,d,diag
# msbuild project.sln /t:Build /p:Configuration=Release /p:Platform=x64 -nologo -v:d

# SHENNANIGAN Start-Process stdout and stderr not accessible without setting RedirectStandardError = $true
# https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process
function StartProcess_stdout {
  $pinfo = New-Object System.Diagnostics.ProcessStartInfo
  $pinfo.FileName = "ping.exe"
  $pinfo.RedirectStandardError = $true
  $pinfo.RedirectStandardOutput = $true
  $pinfo.UseShellExecute = $false
  $pinfo.Arguments = "localhost"
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $pinfo
  $p.Start() | Out-Null
  $p.WaitForExit()
  $stdout = $p.StandardOutput.ReadToEnd() # relevant line to flush stdout when there pipe into file
  $stderr = $p.StandardError.ReadToEnd()
  Write-Host "stdout: $stdout"
  Write-Host "stderr: $stderr"
  Write-Host "exit code: " + $p.ExitCode
}

# taken from
# [string[]] $build_args = @(".\project.sln", "/t:Build", "/p:Configuration=Release", "/p:Platform=x64", "-nologo", "/m", "/nr:false"),
# Write-Verbose "build_args: $($build_args -join ' ')"
# # Write-Verbose [system.String]::Join(" ", $build_args)
# $proc = Start-Process "$msBuild" -ArgumentList $build_args -NoNewWindow -PassThru
# $handle = $proc.Handle # cache proc.Handle to fix ExitCode to work correctly
# $proc.WaitForExit() # prevent msbuild not being terminated due to subprocess
# if ($proc.ExitCode -ne 0) {
#   Write-Error "build error: $($proc.ExitCode), exiting.."
#   exit 2
# }

# Write-Verbose "build_args: $($build_args -join ' ')"
# Write-Verbose [system.String]::Join(" ", $build_args)
# write-output "Server is $env:serverName"
# escaping semicolon works via `;

#if ($content_build[$i].StartsWith("#define VERSION ")) {
    #  Write-Output(">>> line ${i}: $($content_build[$i])")
    #  $build_str = $($content_build[$i]) # array of strings may get incorrectly expanded without surrounding $() leaving out version number
    #  Write-Output(" str: $build_str")
#}

# read from file: Get-Content -Path FILEPATH
# substitute \t with ' ' in string $str = $mixed_str -replace ("`t", " ")
# subst /d D:

function parseVersion {
  $content = @("#define MAJOR_VERSION 0", "#define MINOR_VERSION 1", "#define MINOR_VERSION 2")
  for ($i=0; $i -lt $content.Length; $i+=1) {
    if ($content[$i].StartsWith("#define MAJOR_VERSION ")) {
      #SHENNANIGAN $content[$i] may get expanded incorrectly
      #$major = [int]$($($content -split " ")[2])
      $major = [int]$($($($content[$i]) -split " ")[2])
      # Write-Output "$major" prints 7
    }
    if ($content[$i].StartsWith("#define MINOR_VERSION ")) {
      $minor = [int]$($($($content[$i]) -split " ")[2])
    }
    if ($content[$i].StartsWith("#define HOTFIX_VERSION ")) {
      $hotfix = [int]$($($($content[$i]) -split " ")[2])
    }
  }
}

# https://stackoverflow.com/questions/45760457/how-can-i-run-a-powershell-script-with-white-spaces-in-the-path-from-the-command
# fix publication not working by rewriting it in powershell
# underlying problem: %%a not getting correctly expanded no matter what I tried

# SHENNANIGAN waiting for child processes is weird:
# $proc = Start-Process "$msBuild" -ArgumentList $build_args -NoNewWindow -PassThru
# $handle = $proc.Handle # cache proc.Handle to fix ExitCode to work correctly
# $proc.WaitForExit() # prevent msbuild not being terminated due to subprocess

function sane_BinaryDiff {
  param(
    [string] $src_file,
    [string] $dest_file,
    [switch] $short = $false
  )
  $hash1 = (Get-FileHash $src_file).Hash
  $hash2 = (Get-FileHash $dest_file).Hash
  if ($hash1 -ne $hash2) {
    if ($short) { return 1 }
    Write-Host "delta ${src_file} ${dest_file}"
    # idea: getting line number in text diffs
    # $src_cont = Get-Content "${src_file}"  | %{$i = 1} { new-object psobject -prop @{LineNum=$i;Text=$_}; $i++}
    # $dest_cont = Get-Content "${dest_file}" | %{$i = 1} { new-object psobject -prop @{LineNum=$i;Text=$_}; $i++}
    # $cmp = Compare-Object $src_cont $dest_cont -Property Text -PassThru -IncludeEqual
    $cmp = Compare-Object -ReferenceObject $(Get-Content $src_file) -DifferenceObject $(Get-Content $dest_file)
    for ($i=0; $i -lt $cmp.Length; $i+=1) {
      Write-Host "$($cmp[$i].SideIndicator) $($cmp[$i].InputObject)"
    }
    return 1
  } else {
    return 0
  }
}

# Start process with arguments with cwd : (current cwd xor cwd $at xor excutable directory).
function sane_StartProcess {
  param(
    [string] $exe_path,
    [string[]] $exe_args = @(),
    [string] $at = ".",
    [switch] $exe_dir = $false,
    [switch] $dry = $false
  )
  if ($exe_dir -and ($at -ne ".")) { throw '$cd_path and $exe_dir were set' }

  [int] $st = 0
  [string] $at_pa = $at
  if ($exe_dir) {
    $at_pa = Split-Path -parent $exe_path
  }
  if (Test-Path $exe_path) {
    Write-Verbose "pwd $at_pa, exec $exe_path $exe_args"
    try {
      if (-Not ($dry)) {
        $proc = Start-Process $exe_path -WorkingDirectory $at_pa -ArgumentList $exe_args -NoNewWindow -PassThru
        $handle = $proc.Handle
        $proc.WaitForExit()
        $st = $proc.ExitCode
      }
    } catch {
      $st = 1
      Write-Verbose "Exception: $_"
      return $st
    }
    Write-Verbose "st: $st"
    return $st
  } else {
    throw "Could not find file " + $exe_path
  }
}

# SHENNANIGAN Microsoft Website on robocopy help is incomplete and unhelpful.
# complete one from https://ss64.com/nt/robocopy-exit.html
#   Error    Meaning if set
#    0       No errors occurred, and no copying was done.
#            The source and destination directory trees are completely synchronized.
#    1       One or more files were copied successfully (that is, new files have arrived).
#    2       Some Extra files or directories were detected. No files were copied
#            Examine the output log for details.
#    4       Some Mismatched files or directories were detected.
#            Examine the output log. Housekeeping might be required.
#    8       Some files or directories could not be copied
#            (copy errors occurred and the retry limit was exceeded).
#            Check these errors further.
#    16      Serious error. Robocopy did not copy any files.
#            Either a usage error or an error due to insufficient access privileges
#            on the source or destination directories.
#These can be combined, giving a few extra exit codes:
#    3 (2+1) Some files were copied. Additional files were present. No failure was encountered.
#    5 (4+1) Some files were copied. Some files were mismatched. No failure was encountered.
#    6 (4+2) Additional files and mismatched files exist. No files were copied and no failures were encountered.
#            This means that the files already exist in the destination directory
#    7 (4+1+2) Files were copied, a file mismatch was present, and additional files were present.

# SHENNANIGAN robocopy docs incorrect on error => !$? >= 8, it is error !$? > 8
# robocopy $SRC $TARGET *.dll
# if (!$? -gt 8) { Write-Output "error: " !$?; return !$?; }

# SHENNANIGAN robocopy does not support filepath and subdir selection
# it only supports filepath exclusion
# robocopy $src $dest *.* /compress /xd $excl_dirs /xf $excl_files /eta /j
# robocopy $src $dest /s /compress /xd $excl_dirs /xf $excl_files /eta /j

# src dest files expect
# based on https://ss64.com/nt/robocopy-exit.html
# expect: no_error([0-7]), no_copy (0/4), all_copy(1/5), never_copy(8/16)
# never_copy tests for things like access denied or no connection to remote
# returns 0 (ok), 1 (error), 2 (connection,access), 3 (invalid args)
function sane_robocopy {
  param(
    [string] $src,
    [string] $dest,
    [string[]] $files,
    [string] $expect
  )
  if (($expect -ne "no_error") -and ($expect -ne "no_copy") -and ($expect -ne "all_copy") -and ($expect -ne "never_copy")) {
    return 3 # invalid args
  }
  # copy subdirs exclusive empty ones, compress, show expected time, copy unbuffered
  # [string[]] $flags = @("/s", "/compress", "/eta", "/j")
  [string[]] $tmp = @("$src", "$dest")
  [string[]] $robocopy_args = $tmp + $files
  $proc = Start-Process "robocopy" -ArgumentList $robocopy_args -NoNewWindow -PassThru
  $handle = $proc.Handle # cache proc.Handle to fix ExitCode to work correctly
  $proc.WaitForExit() # early terminate on error
  if ($expect -eq "no_error") {
    if ($proc.ExitCode -lt 8) { return 0 } else { return 1 }
  } elseif ($expect -eq "no_copy") {
    if (($proc.ExitCode -eq 0) -Or ($proc.ExitCode -eq 4)) {
      return 0
    } elseif ($proc.ExitCode -ge 8) {
      return 2
    }
    return 1
  } elseif ($expect -eq "all_copy") {
    if (($proc.ExitCode -eq 1) -Or ($proc.ExitCode -eq 5)) {
      return 0
    } elseif ($proc.ExitCode -ge 8) {
      return 2
    }
    return 1
  } elseif ($expect -eq "never_copy") {
    if ($proc.ExitCode -ge 8) { return 0 } else { return 1 }
  }
}

function sane_checkFileTreeEndingEncoding {
  param (
    # expect_eol: {lf, cllf, ..}
    [string] $expect_eol,
    # expect_encoding: {}
    [string] $expect_encoding,
    # exclude_file_endings: {}
    [string[]] $exclude_file_endings
  )

  # idea
}

# invoke rcopy, wait for termination and return result handle
# with -dry returns "DONT_USE_THIS" otherwise Start-Process handle
function simple_robocopy {
  param(
    [string[]] $rcopy_args,
    [switch] $dry = $false
  )
  if ($dry) {
    Write-Host "robocopy $($rcopy_args -join ' ')"
    return "DONT_USE_THIS"
  } else {
    $proc = Start-Process "robocopy" -ArgumentList $rcopy_args -NoNewWindow -PassThru
    $handle = $proc.Handle # cache proc.Handle to fix ExitCode to work correctly
    $proc.WaitForExit() # early terminate on error
    return $proc
  }
}

# icacls.exe .\vs.ps1 /grant NT-AUTORIT├äT\SYSTEM:RX

function comparisonOperators {
  #Equality
  #    -eq, -ieq, -ceq - equals
  #    -ne, -ine, -cne - not equals
  #    -gt, -igt, -cgt - greater than
  #    -ge, -ige, -cge - greater than or equal
  #    -lt, -ilt, -clt - less than
  #    -le, -ile, -cle - less than or equal
  #Matching
  #    -like, -ilike, -clike - string matches wildcard pattern
  #    -notlike, -inotlike, -cnotlike - string doesn't match wildcard pattern
  #    -match, -imatch, -cmatch - string matches regex pattern
  #    -notmatch, -inotmatch, -cnotmatch - string doesn't match regex pattern
  #Replacement
  #    -replace, -ireplace, -creplace - replaces strings matching a regex pattern
  #Containment
  #    -contains, -icontains, -ccontains - collection contains a value
  #    -notcontains, -inotcontains, -cnotcontains - collection doesn't contain a value
  #    -in - value is in a collection
  #    -notin - value isn't in a collection
  #Type
  #    -is - both objects are the same type
  #    -isnot - the objects aren't the same type
}

function stopWatch {
  $stopWatch = New-Object -TypeName 'System.Diagnostics.Stopwatch'
  $stopWatch.Start()
  $stopWatch.Stop()
  Write-Host "$($stopWatch.Elapsed)"
  Write-Host "$($stopWatch.Elapsed.Hours):$($stopWatch.Elapsed.Minutes):$($stopWatch.Elapsed.Seconds).$($stopWatch.Elapsed.Milliseconds)"
  Write-Host "$($stopWatch.Elapsed.TotalDays) d"
  Write-Host "$($stopWatch.Elapsed.TotalHours) h"
  Write-Host "$($stopWatch.Elapsed.TotalMinutes) min"
  Write-Host "$($stopWatch.Elapsed.TotalSeconds) s"
  Write-Host "$($stopWatch.Elapsed.TotalMilliseconds) ms"
}
# $StartDate=(GET-DATE)
# $EndDate=[datetime]ÔÇØ01/01/2014 00:00ÔÇØ
# NEW-TIMESPAN ÔÇôStart $StartDate ÔÇôEnd $EndDate
#https://learn.microsoft.com/de-de/powershell/module/microsoft.powershell.utility/tee-object?view=powershell-7.4
# https://www.pdq.com/powershell/tee-object/
#https://stackoverflow.com/questions/52970939/right-usage-of-21-tee-or-tee-with-powershell
# https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process

# <NMakeBuildCommandLine>rem vs.ps1 parameters: build_mode
# powershell -NoProfile -ExecutionPolicy unrestricted -file "$(SolutionDir)vs.ps1" $(Configuration)</NMakeBuildCommandLine>

# SHENNANIGAN xcopy has one of the worst behaviors
# Adding a wildcard (*) to the end of the destination will suppress this prompt and default to copying as a file
# xcopy file7.dll file.dll* /y /c /f /q

# idea fix this
# https://stackoverflow.com/questions/49870753/functions-had-inline-decision-re-evaluated-but-remain-unchanged
# re-evaluated inline decision was fixed for cached data in VS2022 Version 17.11.2
# However, VS2022 still assumes artefacts were generated from last input and re-evaluates
# on different input (ie msbuild instead of graphical, other selection of projects to build etc)

function prefix_array() {
  param (
    [Parameter(Mandatory, Position=0)] [string[]] arr1,
    [Parameter(Mandatory, Position=1)] [string] src
  )
  return arr1.ForEach({"${src}\$_"})
}

function extract_numbers() {
  $my_string = "Start0123456789End"
  $numbers_only = $my_string -replace "[^0-9]" , ''
  return $numbers_only
}

function switch_case() {

  # break statement is optional to ensure only the applied condition is matched,
  # if multiple conditions are satisfied
  # when only one conditions is satisfied, break is superfluous

  # switch [-regex|-wildcard|-exact][-casesensitive] (<value>)
  # {
  #     "string"|number|variable|{ expression } { statementlist }
  #     default { statementlist }
  # }
  # switch [-regex|-wildcard|-exact][-casesensitive] -file <filename>
  # {
  #     "string"|number|variable|{ expression } { statementlist }
  #     default { statementlist }
  # }

  $arrayNum = @(1,2)
  switch ($arrayNum) {
      1 {"It is one." }
      2 {"It is two." }
      default {"Not found"}
  }

  # also works with replacement arg $_
  switch -file .\random.txt {
      {$_ -match 'she'} { $_ }
  }
}

function Switch-Item {
  param ([switch]$on)
  if ($on) { "Switch on" }
  else { "Switch off" }
}

# search for executable location
function where_pendant() {
  Get-Command Get-Command
}


# https://stackoverflow.com/questions/8609204/union-and-intersection-in-powershell
function union_intersection() {
  $a = (1,2,3,4)
  $b = (1,3,4,5)
  # union
  Compare-Object $a $b -PassThru -IncludeEqual
  # intersection
  Compare-Object $a $b -PassThru -IncludeEqual -ExcludeDifferent
}

function htop() { systeminfo |find "Available Physical Memory" }

# Measure time (without memory)
function time() { Measure-Command }
