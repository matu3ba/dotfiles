$env:Path += ";$($env:USERPROFILE)\bin"
$env:Path += ";$HOME\.local\bin"
# $env:Path += ";$HOME\llvm\bin"
$env:Path += ";C:\Program Files\LLVM\bin"
$env:Path += ";C:\Program Files\Mozilla Firefox"
$env:Path += ";C:\Program Files\Python312\Scripts\pip.exe"
$env:Path += ";C:\Program Files\Wireshark"
$env:Path += ";C:\Program Files\7-Zip"
$env:POWERSHELL_TELEMETRY_OPTOUT = $true
$EDITOR = "nvim"
$env:Editor = "nvim"

# help Start-Process
#Start-Process
# [-FilePath] <string> [[-ArgumentList] <string[]>] [-Credential <pscredential>]
# [-WorkingDirectory <string>] [-LoadUserProfile] [-NoNewWindow] [-PassThru]
# [-RedirectStandardError <string>] [-RedirectStandardInput <string>]
# [-RedirectStandardOutput <string>] [-WindowStyle <ProcessWindowStyle>]
# [-Wait] [-UseNewEnvironment] [-Environment <hashtable>] [-WhatIf] [-Confirm]
# [<CommonParameters>]

#====common
# copy to clipboard including newline: pwd | clip
# copy to clipboard no newline: pwd | Set-Clipboard
# copy to mounted network shares does not work, must use UNC paths
# \\IP\share
# SHENNANIGAN robocopy necessary for network paths/UNC paths
# robocopy $src $dest filename
# robocopy $src $dest *.exe

# Installing Windows Terminal
# https://github.com/microsoft/terminal/releases
# Add-AppxPackage -Path C:\Path\App-Package.msixbundle
# [Environment]::Is64BitOperatingSystem
# [System.Environment]::OSVersion.Version

# Installing Wezterm
# https://github.com/wez/wezterm/releases
# winget install wez.wezterm

# Installing new version of powershell called pwsh.exe to fix utf8:
# function GitDiff { & git diff --no-color $args }
# winget search Microsoft.PowerShell
# winget install --id Microsoft.Powershell --source winget
# https://learn.microsoft.com/de-de/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4#msi

# git completion https://github.com/dahlbyk/posh-git
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
# Install-Module VSSetup -Scope CurrentUser
# confirm trust
# inspiration for fuzzy finding in https://news.ycombinator.com/item?id=38471822

# SHENNANIGAN unix line endings need
# gdNo > some.diff
# git apply --ignore-whitespace some.diff

# DevShell to be used from Powershell
# https://intellitect.com/blog/enter-vsdevshell-powershell/
# https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022
# & "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1"

#====shortcuts
# within shell: Get-PSReadLineKeyHandler
# https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/keyboard-shortcuts-for-the-windows-powershell-ise?view=powershell-7.4
# https://keycombiner.com/collections/powershell/
# AcceptSuggestion
Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+d" -Function DeleteCharOrExit
Set-PSReadlineKeyHandler -Chord "Ctrl+u" -Function RevertLine

#====aliases
New-Alias -Name .. -Value CdUp -Force -Option AllScope
New-Alias -Name ... -Value CdUp2 -Force -Option AllScope
New-Alias -Name .... -Value CdUp3 -Force -Option AllScope
New-Alias -Name ga -Value GitAdd -Force -Option AllScope
New-Alias -Name gap -Value GitApply -Force -Option AllScope
New-Alias -Name gb -Value GitBranch -Force -Option AllScope
New-Alias -Name gba -Value GitBranchAll -Force -Option AllScope
New-Alias -Name gbr -Value GitBranchRemote -Force -Option AllScope
New-Alias -Name gbrt -Value GitBranchRemoteTracking -Force -Option AllScope
New-Alias -Name gc -Value GitCommitSign -Force -Option AllScope
New-Alias -Name gcf -Value GitCommitFixup -Force -Option AllScope
New-Alias -Name gcs -Value GitCommitSquash -Force -Option AllScope
New-Alias -Name gca -Value GitCommitAmend -Force -Option AllScope
New-Alias -Name gcn -Value GitCommitNoSign -Force -Option AllScope
New-Alias -Name gd -Value GitDiff -Force -Option AllScope
New-Alias -Name gdNo -Value GitDiffNoColor -Force -Option AllScope
New-Alias -Name gdc -Value GitDiffCache -Force -Option AllScope
New-Alias -Name gdcn -Value GitDiffCacheNoPager -Force -Option AllScope
New-Alias -Name gdn -Value GitDiffNameOnly -Force -Option AllScope
New-Alias -Name gf -Value GitFetch -Force -Option AllScope
New-Alias -Name glg -Value GitLogStat -Force -Option AllScope
New-Alias -Name gladogs -Value GitLogADogs -Force -Option AllScope
New-Alias -Name gm -Value GitMergeFfonly -Force -Option AllScope
New-Alias -Name gmc -Value GitMergeCommit -Force -Option AllScope
New-Alias -Name gmn -Value GitMergeNoCommit -Force -Option AllScope
New-Alias -Name gp -Value GitPush -Force -Option AllScope
New-Alias -Name gpf -Value GitPushForce -Force -Option AllScope
New-Alias -Name gpsuo -Value GitPushSetUpstreamOrigin -Force -Option AllScope
New-Alias -Name gpsu -Value GitPushSetUpstreamDownstream -Force -Option AllScope
New-Alias -Name gpsuu -Value GitPushSetUpstreamUpstream -Force -Option AllScope
New-Alias -Name grv -Value GitRemoteVerbose -Force -Option AllScope
New-Alias -Name gs -Value GitStatus -Force -Option AllScope
New-Alias -Name gsh -Value GitShow -Force -Option AllScope
New-Alias -Name gshn -Value GitShowNameOnly -Force -Option AllScope
New-Alias -Name gsr -Value GitShowRemote -Force -Option AllScope
New-Alias -Name gsto -Value GitStashPop -Force -Option AllScope
New-Alias -Name gstu -Value GitStashPush -Force -Option AllScope
New-Alias -Name gu -Value GitPullNoRebaseFfonly -Force -Option AllScope
New-Alias -Name l -Value ListDense -Force -Option AllScope
New-Alias -Name v -Value NvimCmd -Force -Option AllScope
New-Alias -Name zbdeb -Value NvimCmd -Force -Option AllScope
New-Alias -Name zcbrel -Value ZigCrossBuildRelease -Force -Option AllScope
New-Alias -Name zcrel -Value ZigCrossRelease -Force -Option AllScope
# New-Alias -Name zdeb -Value ZigBuildDebug -Force -Option AllScope
# New-Alias -Name zbllvm -Value ZigDebug -Force -Option AllScope
# New-Alias -Name zbsrel -Value ZigBootstrapRelease -Force -Option AllScope
# New-Alias -Name zbrel -Value ZigBuildRelease -Force -Option AllScope
# New-Alias -Name zrel -Value ZigRelease -Force -Option AllScope

#====utils
function HasGit { & git rev-parse --is-inside-work-tree }
function GitCommitSha { & git rev-parse HEAD }
# (0 ok, 1 not)
function GitVersionControlled { param([string]$path) & git ls-files --error-unmatch $path }
#git config --get remote.origin.url
function GitRelPathToRootDir { & git rev-parse --show-cdupgit rev-parse --show-cdup }
function GitBranch { & git rev-parse --abbrev-ref HEAD }
function GitCommitCheck {
  [string[]] $diffed_file = [string[]]$(git --no-pager diff --name-only)
  [string[]] $cached_file = [string[]]$(git --no-pager diff --cached --name-only)
  if ($diffed_file.Length -eq 0) { return 0; }
  if ($cached_file.Length -eq 0) { Write-Host "no files staged"; return 1; }
  $cmp = Compare-Object $diffed_file $cached_file -PassThru -IncludeEqual -ExcludeDifferent
  if ($cmp.Length -eq 0) { return 0; }
  else {
    Write-Host "changed and staged files: $cmp"
    return 1;
  }
}
function GitCommitCount { & git rev-list REV.. --count }
function GitCommitDate { return & git show --no-patch --format=%ad --date=format:'%Y-%m-%d' HEAD }
function GitCommitAuthorName { return & git show --no-patch --format=%an HEAD }
function GitCommitAuthorMail { return & git log -1 --pretty=format:%ce HEAD }
# or #return & "git show --no-patch --format=%ce HEAD"
function GitCommitTime { return & git show --no-patch --format=%ad --date=format:'%H:%M:%S' HEAD }
function GitShortCommitID { return & git rev-parse --short HEAD }
function GitFullCommitID { return & git rev-parse HEAD }

# function CreateChangeDirectory { & md -ea 0 buildrel\ && cd buildrel\ }
function CdUp { & cd .. }
function CdUp2 { & cd ..\.. }
function CdUp3 { & cd ..\..\.. }
function GitAdd { & git add $args }
function GitApply { & git apply --ignore-whitespace $args }
function GitBranch { & git branch $args }
function GitBranchAll { & git branch -avv $args }
function GitBranchRemote { & git branch --remote $args }
function GitBranchRemoteTracking { & git rev-parse --abbrev-ref --symbolic-full-name '@{u}' }
function GitCommitAmend { & git commit --amend $args }
function GitCommitNoSign { & git commit -v $args }
function GitCommitSign { & git commit -v -S $args }
function GitCommitFixup { & git commit --fixup $args }
function GitCommitSquash { & git rebase -i --autosquash $args }
function GitDiff { & git diff --color $args }
function GitDiffCache { & git diff --cached $args }
function GitDiffCacheNoPager { & git --no-pager diff --cached $args }
function GitDiffNameOnly { & git --no-pager diff --name-only $args }
function GitDiffNoColor { & git --no-pager diff --no-color $args }
function GitFetch { & git fetch $args }
function GitLogStat { & git log --stat $args }
function GitLogADogs { & git log --all --decorate  --oneline --graph --simplify-by-decoration $args }
function GitMergeCommit { & git merge --no-ff --commit $args }
function GitMergeFfonly { & git merge --ff-only $args }
function GitMergeNoCommit { & git merge --no-ff --no-commit $args }
function GitPullNoRebaseFfonly { & git pull --no-rebase --ff-only $args }
function GitPush { & git push $args }
function GitPushForce { & git push --force-if-includes --force-with-lease $args }
function GitPushSetUpstreamOrigin { & git push --set-upstream origin $(git branch --show-current) $args }
function GitPushSetUpstreamDownstream { & git push --set-upstream downstream $(git branch --show-current) $args }
function GitPushSetUpstreamUpstream { & git push --set-upstream upstream $(git branch --show-current) $args }
function GitRemoteVerbose { & git remote -v }
function GitShow { & git show $args }
function GitShowNameOnly { & git show --name-only $args }
function GitShowRemote { & git remote show roigin $args }
function GitStashPop { & git stash pop $args }
function GitStashPush { & git stash push $args }
function GitStatus { & git status $args }
function ListDense { & Get-ChildItem $args -Force | Format-Wide Name -AutoSize }
function MakeWorkTree {
  # https://powershell.one/powershell-internals/attributes/parameters
  # param (
  #     [switch] $IsValueNameRegularExpression = $True
  # )
  # $PSBoundParameters.ContainsKey('IsValueNameRegularExpression')
  # $IsValueNameRegularExpression.IsPresent
  param (
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
    [Parameter(Mandatory, Position=0)] [string] $GitPath
  )
  $worktreesfolder = Split-Path -Path $GitPath -LeafBase
  mkdir $worktreesfolder
  pushd
  cd $worktreesfolder
  git clone --bare "$GitPath" .bare
  # make sure git knows where the gitdir is
  echo "gitdir: ./.bare" > .git
  git worktree add master
  popd
}
function MakePath {
  param (
    [Parameter(Mandatory, Position=0)] [string] $Path
  )
  New-Item -Path "$Path" -Force
}
function ZigCrossBuildRelease { & ..\..\zig-bootstrap\master\out-win\host\bin\zig.exe build -p rel --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-gnu-native" -Dstatic-llvm -Doptimize=ReleaseSafe --zig-lib-dir lib }
function ZigCrossRelease { & ..\master\rel\zig.exe build -p rel --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-gnu-native" -Dstatic-llvm -Doptimize=ReleaseSafe --zig-lib-dir lib }

# New-Alias -Name zcbrel -Value ZigCrossBuildRelease -Force -Option AllScope
# New-Alias -Name zcrel -Value ZigCrossRelease -Force -Option AllScope

#====filter
filter fgrep($keyword) { if ( ($_ | Out-String) -like “*$keyword*”) { $_ } }
filter fsed($before,$after) { %{$_ -replace $before,$after} }
filter xargs { & $args[0] ($args[1..$args.length] + $_) }

#====whereis
# gcm pwsh.exe
# where pwsh.exe

#====setup

Import-Module posh-git
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# icacls.exe .\vs.ps1 /grant NT-AUTORITÄT\SYSTEM:RX

# net use \\$IP\d $PW /USER:$USER
# robocopy .\builddir\bin\ \\$IP\$DRIVE\$DIR *.dll
# robocopy .\builddir\bin\ \\$IP\$DRIVE\$DIR *.pdb
# robocopy .\builddir\bin\ \\$IP\$DRIVE\$DIR *.exe

# shutdown
# /r restart, /s shutdown, /a/ abort shutdown, /c "comment"
# wmic os where Primary='TRUE' reboot
# remote
# PsShutdown.exe -u username -p password \\Remotecomputer
# -t 15:30
# -r restart

# idea commands from https://www.windows-commandline.com/
# ideally winrm

#====problem_bootstrap_zig
# cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows"
# cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows" -DZIG_TARGET_MCPU=baseline
# cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-gnu"
# cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-gnu" -DZIG_TARGET_MCPU=baseline
# cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-msvc"
# cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-msvc" -DZIG_TARGET_MCPU=baseline
# cmake --build . --target install

# ABI problems for msvc
# function ZigBuildDebug { & .\buildrel\stage3\bin\zig build -p deb -Doptimize=Debug --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-native" --zig-lib-dir lib -Dstatic-llvm }
# function ZigDebug { & ..\master\rel\bin\zig build -p deb -Doptimize=Debug --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-native" --zig-lib-dir lib -Dstatic-llvm }
# function ZigBuildRelease { &  .\buildrel\stage3\bin\zig build -p rel -Doptimize=ReleaseSafe --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-native" --zig-lib-dir lib -Dstatic-llvm }
# function ZigRelease { &  ..\master\rel\bin\zig build -p rel -Doptimize=ReleaseSafe --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-native" --zig-lib-dir lib -Dstatic-llvm }
# In "x64 Native Tools Command Prompt for VS 2019":
# Run in repo zig-bootstrap: .\build.bat
# Run in repo zig: cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-gnu"
#                  cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="..\..\zig-bootstrap\master\out-win\host\" -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -GNinja
#                  cmake --build . --target install
# => zig build-exe zig ReleaseFast x86_64-windows-gnu 1 errors
#      error: lld-link: duplicate symbol: atexit
# function ZigBuildDebug { & .\buildrel\stage3\bin\zig build -p deb -Doptimize=Debug --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-gnu-native" --zig-lib-dir lib -Dstatic-llvm }
# function ZigDebug { & ..\master\rel\bin\zig build -p deb -Doptimize=Debug --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-gnu-native" --zig-lib-dir lib -Dstatic-llvm }
# function ZigBuildRelease { &  .\buildrel\stage3\bin\zig build -p rel -Doptimize=ReleaseSafe --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-gnu-native" --zig-lib-dir lib -Dstatic-llvm }
# function ZigRelease { &  ..\master\rel\bin\zig build -p rel -Doptimize=ReleaseSafe --search-prefix "..\..\zig-bootstrap\master\out-win\x86_64-windows-gnu-native" --zig-lib-dir lib -Dstatic-llvm }

#====SHENNANIGAN
# SHENNANIGAN zig
# Get-VSSetupInstance | Select-VSSetupInstance -Latest -Require Microsoft.VisualStudio.Component.VC.Tools.x86.x64
# SHENNANIGAN vswhere more reliable than dedicated api https://gitlab.kitware.com/cmake/cmake/-/issues/19241
# function ZigBootstrapRelease { & { md -ea 0 buildrel\ } && & { cd buildrel\ && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="..\..\zig-bootstrap\master\out-win\host\" -GNinja } && & { cd buildrel\ && Measure-Command ninja install } }
# cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="..\..\zig-bootstrap\master\out-win\host\" -G "Visual Studio 16 2019"
# Getting correct msvc paths is annoying https://devblogs.microsoft.com/cppblog/finding-the-visual-c-compiler-tools-in-visual-studio-2017/
# idea
# https://cmake.org/cmake/help/latest/variable/MSVC.html
# https://github.com/microsoft/vswhere/wiki/Find-VC
# function ZigBootstrapRelease {
#   & md -ea 0 buildrel\
#   && cd buildrel\
#   && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="..\..\zig-bootstrap\master\out-win\host\" -GNinja
#   && Measure-Command ninja install && cd ..
# }
# Known to work is
# 1. usage within "Visual Studio Command Prompt":
# cmake -help
# cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="..\..\zig-bootstrap\master\out-win\host\" -GNinja
# 2. setting up environment flags in cmd
# "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x64
# cmake.exe -G "Ninja" ..
# 3. https://stackoverflow.com/questions/2124753/how-can-i-use-powershell-with-the-visual-studio-command-prompt
# SHENNANIGAN varying setup depending on compiler version
# SHENNANIGAN might or might not need -DMSVC_TOOLSET_VERSION=140
# idea:
# * query paths with vswhere in cmd: "c:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -all
#   + how does this work within powershell?
# * build things

# SHENNANIGAN slow startup speed of pwsh.exe, faster startup with -nologo and with virus scanner exception

# SHENNANIGAN alias does not work in pipe, workaround is involved
# https://blog.marco.ninja/posts/2020/12/02/super-charged-cmdlet-aliases/

# SHENNANIGAN Adjusting Windows Terminal with non-Windows things is a horrible user experience
# https://stackoverflow.com/questions/71045716/adding-msys-to-windows-terminal