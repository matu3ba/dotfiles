$env:Path += ";$($env:USERPROFILE)\bin"
$env:Path += ";$HOME\.local\bin"
$env:Path += ";C:\Program Files\Mozilla Firefox"
$env:POWERSHELL_TELEMETRY_OPTOUT = $true
# PowerShell v6+ has BOM-less UTF-8 as default. Versions below break for
# example git diff/apply due to not using BOM-less UTF-8.
# $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
# $PSDefaultParameterValues['*:Encoding'] = 'utf8'
# Versions below powershell6+ require to change the system configuration. For
# these cases, it is better to use git bash instead.

# Installing new version of powershell called pwsh.exe to fix utf8:
# function GitDiff { & git diff --no-color $args }
# winget search Microsoft.PowerShell
# winget install --id Microsoft.Powershell --source winget
# https://learn.microsoft.com/de-de/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4#msi

# SHENNANIGAN alias does not work in pipe, workaround is involved
# https://blog.marco.ninja/posts/2020/12/02/super-charged-cmdlet-aliases/

New-Alias -Name .. -Value CdUp -Force -Option AllScope
New-Alias -Name ... -Value CdUp2 -Force -Option AllScope
New-Alias -Name .... -Value CdUp3 -Force -Option AllScope
New-Alias -Name ga -Value GitAdd -Force -Option AllScope
New-Alias -Name gap -Value GitApply -Force -Option AllScope
New-Alias -Name gb -Value GitBranch -Force -Option AllScope
New-Alias -Name gc -Value GitCommitSign -Force -Option AllScope
New-Alias -Name gca -Value GitCommitAmend -Force -Option AllScope
New-Alias -Name gcn -Value GitCommitNoSign -Force -Option AllScope
New-Alias -Name gd -Value GitDiff -Force -Option AllScope
New-Alias -Name gdc -Value GitDiffCache -Force -Option AllScope
New-Alias -Name gf -Value GitFetch -Force -Option AllScope
New-Alias -Name glg -Value GitLog -Force -Option AllScope
New-Alias -Name gm -Value GitMergeFfonly -Force -Option AllScope
New-Alias -Name gmn -Value GitMergeCommit -Force -Option AllScope
New-Alias -Name gmn -Value GitMergeNoCommit -Force -Option AllScope
New-Alias -Name gp -Value GitPush -Force -Option AllScope
New-Alias -Name grv -Value GitRemoteVerbose -Force -Option AllScope
New-Alias -Name gs -Value GitStatus -Force -Option AllScope
New-Alias -Name gshow -Value GitShow -Force -Option AllScope
New-Alias -Name gsr -Value GitShowRemote -Force -Option AllScope
New-Alias -Name gsto -Value GitStashPop -Force -Option AllScope
New-Alias -Name gstu -Value GitStashPush -Force -Option AllScope
New-Alias -Name gu -Value GitPullNoRebaseFfonly -Force -Option AllScope
New-Alias -Name l -Value ListDense -Force -Option AllScope
New-Alias -Name v -Value NvimCmd -Force -Option AllScope
function CdUp { & cd .. }
function CdUp2 { & cd ..\.. }
function CdUp3 { & cd ..\..\.. }
function GitAdd { & git add $args }
function GitApply { & git apply $args }
function GitBranch { & git branch $args }
function GitCommitAmend { & git commit --amend $args }
function GitCommitNoSign { & git commit -v $args }
function GitCommitSign { & git commit -v -S $args }
function GitDiff { & git diff $args }
function GitDiffCache { & git diff --cached $args }
function GitFetch { & git fetch $args }
function GitLog { & git log --stat $args }
function GitMergeCommit { & git merge --no-ff --commit $args }
function GitMergeFfonly { & git merge --ff-only $args }
function GitMergeNoCommit { & git merge --no-ff --no-commit $args }
function GitPullNoRebaseFfonly { & git pull --no-rebase --ff-only $args }
function GitPush { & git push $args }
function GitRemoteVerbose { & git remote -v }
function GitShow { & git show $args }
function GitShowRemote { & git remote show roigin $args }
function GitStashPop { & git stash pop $args }
function GitStashPush { & git stash push $args }
function GitStatus { & git status $args }
function ListDense { & Get-ChildItem $args -Force | Format-Wide Name -AutoSize }
function NvimCmd { & nvim $args }

Invoke-Expression (& { (zoxide init powershell | Out-String) })