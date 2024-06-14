# https://superuser.com/questions/226828/how-to-monitor-a-folder-and-trigger-a-command-line-action-when-a-file-is-created
# TODO

function GetLastExitCode {
  return !$?
}

function CheckExitCode {
  $code = getLastExitCode
  if ($code -ne 0) {
    exit $code
  }
}

function ResolveMsBuild {
  # TODO args: msbuild_version solution/project file
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
function runMsbuild {
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
  [string] $msBuild = ResolveMsBuild
  Write-Verbose "build_args: $($build_args -join ' ')"
  return sane_StartProcess $msBuild $build_args $at
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

# TODO get stacktrace in powershell
#https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions?view=powershell-7.4
# https://stackoverflow.com/questions/795751/can-i-get-detailed-exception-stacktrace-in-powershell

# TODO find installed software
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

# read from file: Get-Content -Path FILEPATH
# substitute \t with ' ' in string $str = $mixed_str -replace ("`t", " ")

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

# caller responsible to validate paths
# $at is filepath to start process at
# $exe_dir means executable uses current directory
# $at and $exe_dir are mutually exclusive
function sane_StartProcess {
  param(
    [string] $exe_path,
    [string[]] $exe_args = @(),
    [string] $at = "."
    [switch] $exe_dir = $false
  )
  if ($exe_dir -and ($at -ne ".")) { throw '$cd_path and $exe_dir were set' }

  [int] $st = 0
  [string] $at_pa = $at
  if ($exe_dir) {
    $at_pa = Split-Path -parent $exe_path
  }
  if (Test-Path $exe_path) {
      Write-Verbose "pwd $at_pa, exec $exe_path $exe_args"
    }
    try {
      if (-Not ($dry)) {
        $proc = Start-Process $exe_path -WorkingDirectory $at_pa -ArgumentList $exe_args -NoNewWindow -PassThru
        $handle = $proc.Handle
        $proc.WaitForExit()
        $st = $proc.WaitForExit()
      }
    }
    Write-Verbose "st: $st"
    return $st
  } else {
    throw "Could not find file " + $exe_path
  }
}

# SHENNANIGAN Microsoft Website onrobocopy help is incomplete and unhelpful.
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

# src dest files expect
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
# $EndDate=[datetime]”01/01/2014 00:00”
# NEW-TIMESPAN –Start $StartDate –End $EndDate
#https://learn.microsoft.com/de-de/powershell/module/microsoft.powershell.utility/tee-object?view=powershell-7.4
# https://www.pdq.com/powershell/tee-object/
#https://stackoverflow.com/questions/52970939/right-usage-of-21-tee-or-tee-with-powershell
# https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process

# <NMakeBuildCommandLine>rem vs.ps1 parameters: build_mode
# powershell -NoProfile -ExecutionPolicy unrestricted -file "$(SolutionDir)vs.ps1" $(Configuration)</NMakeBuildCommandLine>

# SHENNANIGAN xcopy has one of the worst behaviors
# Adding a wildcard (*) to the end of the destination will suppress this prompt and default to copying as a file
# xcopy file7.dll file.dll* /y /c /f /q

# TODO fix this
#https://stackoverflow.com/questions/49870753/functions-had-inline-decision-re-evaluated-but-remain-unchanged