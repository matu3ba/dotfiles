$env:Path += ";$($env:USERPROFILE)\bin"
$env:Path += ";C:\Program Files\Mozilla Firefox"

New-Alias -Name .. -Value CdUp -Force -Option AllScope
New-Alias -Name ... -Value CdUp2 -Force -Option AllScope
New-Alias -Name .... -Value CdUp3 -Force -Option AllScope
New-Alias -Name ga -Value GitAdd -Force -Option AllScope
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
New-Alias -Name gpsto -Value GitStashPop -Force -Option AllScope
New-Alias -Name gpstu -Value GitStashPush -Force -Option AllScope
New-Alias -Name grv -Value GitRemoteVerbose -Force -Option AllScope
New-Alias -Name gs -Value GitStatus -Force -Option AllScope
New-Alias -Name gshow -Value GitShow -Force -Option AllScope
New-Alias -Name gsr -Value GitShowRemote -Force -Option AllScope
New-Alias -Name gu -Value GitPullNoRebaseFfonly -Force -Option AllScope
New-Alias -Name l -Value ListDense -Force -Option AllScope
New-Alias -Name v -Value NvimCmd -Force -Option AllScope
function CdUp { & cd .. }
function CdUp2 { & cd ..\.. }
function CdUp3 { & cd ..\..\.. }
function GitAdd { & git add $args }
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
function NvimCmd { & nvim }

Invoke-Expression (& { (zoxide init powershell | Out-String) })