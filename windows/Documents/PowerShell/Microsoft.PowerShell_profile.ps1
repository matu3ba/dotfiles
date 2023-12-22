$env:Path += ";$($env:USERPROFILE)\bin"
$env:Path += ";$HOME\.local\bin"
$env:Path += ";C:\Program Files\Mozilla Firefox"
$env:POWERSHELL_TELEMETRY_OPTOUT = $true
$EDITOR = "nvim"
$env:Editor = "nvim"
# SHENNANIGAN alias does not work in pipe, workaround is involved
# https://blog.marco.ninja/posts/2020/12/02/super-charged-cmdlet-aliases/

# git completion https://github.com/dahlbyk/posh-git
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force

# inspiration for fuzzy finding in https://news.ycombinator.com/item?id=38471822

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
New-Alias -Name gca -Value GitCommitAmend -Force -Option AllScope
New-Alias -Name gcn -Value GitCommitNoSign -Force -Option AllScope
New-Alias -Name gd -Value GitDiff -Force -Option AllScope
New-Alias -Name gdNo -Value GitDiffNoColor -Force -Option AllScope
New-Alias -Name gdc -Value GitDiffCache -Force -Option AllScope
New-Alias -Name gdn -Value GitDiffNameOnly -Force -Option AllScope
New-Alias -Name gf -Value GitFetch -Force -Option AllScope
New-Alias -Name glg -Value GitLogStat -Force -Option AllScope
New-Alias -Name gm -Value GitMergeFfonly -Force -Option AllScope
New-Alias -Name gmn -Value GitMergeCommit -Force -Option AllScope
New-Alias -Name gmn -Value GitMergeNoCommit -Force -Option AllScope
New-Alias -Name gp -Value GitPush -Force -Option AllScope
New-Alias -Name gpf -Value GitPushForce -Force -Option AllScope
New-Alias -Name gpsuo -Value GitPushSetUpstreamOrigin -Force -Option AllScope
New-Alias -Name gpsu -Value GitPushSetUpstreamDownstream -Force -Option AllScope
New-Alias -Name gpsuu -Value GitPushSetUpstreamUpstream -Force -Option AllScope
New-Alias -Name grv -Value GitRemoteVerbose -Force -Option AllScope
New-Alias -Name gs -Value GitStatus -Force -Option AllScope
New-Alias -Name gsh -Value GitShow -Force -Option AllScope
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
function GitBranchAll { & git branch -avv $args }
function GitBranchRemote { & git branch --remote $args }
function GitBranchRemoteTracking { & git rev-parse --abbrev-ref --symbolic-full-name '@{u}' }
function GitCommitAmend { & git commit --amend $args }
function GitCommitNoSign { & git commit -v $args }
function GitCommitSign { & git commit -v -S $args }
function GitDiff { & git diff --color $args }
function GitDiffCache { & git diff --cached $args }
function GitDiffNameOnly { & git diff --name-only $args }
function GitDiffNoColor { & git diff --no-color $args }
function GitFetch { & git fetch $args }
function GitLogStat { & git log --stat $args }
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
function GitShowRemote { & git remote show roigin $args }
function GitStashPop { & git stash pop $args }
function GitStashPush { & git stash push $args }
function GitStatus { & git status $args }
function ListDense { & Get-ChildItem $args -Force | Format-Wide Name -AutoSize }
function NvimCmd { & nvim $args }


#====setup

Import-Module posh-git
Invoke-Expression (& { (zoxide init powershell | Out-String) })