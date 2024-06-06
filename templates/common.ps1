# https://superuser.com/questions/226828/how-to-monitor-a-folder-and-trigger-a-command-line-action-when-a-file-is-created
# TODO

function Resolve-MsBuild {
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

function MsBuild {
  # msbuild test.sln /t:project /p:Configuration="Release" /p:Platform="x64" /p:BuildProjectReferences=false
  # Notice that what is assigned to /t is the project name in the solution, it can be different from the project file name.
  # Also, as stated in How to: Build specific targets in solutions by using MSBuild.exe:
  #     If the project name contains any of the characters %, $, @, ;, ., (, ), or ', replace them with an _ in the specified target name.
  # You can also build multiple projects at once:
  # msbuild test.sln /t:project1;project2 /p:Configuration="Release" /p:Platform="x64" /p:BuildProjectReferences=false
  # To rebuild or clean, change /t:project to /t:project:clean or /t:project:rebuild

  throw 'TODO: code'
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

# SHENNANIGAN waiting for child processes is weird:
# $proc = Start-Process "$msBuild" -ArgumentList $build_args -NoNewWindow -PassThru
# $handle = $proc.Handle # cache proc.Handle to fix ExitCode to work correctly
# $proc.WaitForExit() # prevent msbuild not being terminated due to subprocess

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

function parseVersion {
  $content = "#define MAJOR_VERSION 7"
  #SHENNANIGAN $content[$i] may get expanded incorrectly
  #$major = [int]$($($content -split " ")[2])
  $major = [int]$($($($content[$i]) -split " ")[2])
  # Write-Output "$major" prints 7
}