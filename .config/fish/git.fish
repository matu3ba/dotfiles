## git abbreviations to get the nice shell completions ##
abbr --add -g glogs 'git --no-pager log --name-only'
abbr --add -g glogs 'git --no-pager show --name-only'
abbr --add -g gwt   'git worktree'
abbr --add -g grst  'git restore'
abbr --add -g g     'git'
abbr --add -g ga    'git add'
abbr --add -g gau   'git add -u' # add modified files
abbr --add -g gap   'git apply'
abbr --add -g gapr  'git apply -R'

abbr --add -g gb    'git branch'
abbr --add -g gba   'git branch -avv'
abbr --add -g gbd   'git branch -d'
abbr --add -g gbD   'git branch -D'
abbr --add -g gbr   'git branch --remote'

abbr --add -g gfap  'git fetch --all --prune'
abbr --add -g gpdel 'git push --delete'
abbr --add -g grpr  'git remote prune'
abbr --add -g grv   'git remote -v'

abbr --add -g gco   'git remote checkout'
abbr --add -g gc    'git commit -v'
abbr --add -g gcmsg 'git commit -m'
abbr --add -g gca   'git commit --amend'

abbr --add -g gd    'git diff'
abbr --add -g gdn   'git diff --name-only'
abbr --add -g gdc   'git diff --cached'
abbr --add -g gds   'git diff --shortstat'
# git diff untracked
alias gdu='git ls-files --others --exclude-standard -z | xargs -0 -n 1 git --no-pager diff /dev/null'
abbr --add -g gdfa  'git diff --name-only --diff-filter=A'
abbr --add -g gwch  'git whatchanged -p --abbrev-commit --pretty=medium'
abbr --add -g gcomf 'git commit -v --fixup'

abbr --add -g gf    'git fetch'
abbr --add -g gfrg  'git ls-files | rg'
#git push set upstream
alias gpsu='git push --set-upstream downstream $(git branch --show-current)'
# git reverse parse head
alias grph='git rev-parse HEAD'

abbr --add -g gs   'git status'
abbr --add -g gsh  'git show'
abbr --add -g gshm 'git show'
abbr --add -g gsb  'git show'
abbr --add -g gss  'git show'

abbr --add -g grb  'git rebase'
alias grbm='git rebase master'
alias grbM='git rebase main'
alias grbi='git rebase -i'
alias grbisq='git rebase -i --autosquash'

alias gsafe='test -n "$(git status --porcelain)" || echo safe'
alias grbium='git rebase --interactive upstream/master'
alias grbiuM='git rebase --interactive upstream/main'
alias grmdel='git rm $(git ls-files --deleted)'

alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'

alias gk='gitk --all --branches'
alias gke='gitk --all $(git log -g --pretty=%h)'

alias gur='git pull --rebase'
alias gu='git pull --no-rebase --ff-only'
abbr --add -g glgs 'git log -S' # git log search 'regex' -- file

alias glg='git log --stat'
alias glgp='git log --stat -p'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glo='git log --oneline --decorate'
alias gloga='git log --oneline --decorate --graph --all'
alias glogp="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

alias glsm='git ls-files -m'
alias glss='git ls-files -s'
alias glsa='git ls-files -mo --exclude-standard' # all non ignored

alias gm='git merge --ff-only'

alias gp='git push'
alias gpdry='git push --dry-run'
alias gpf='git push --force'

alias gstu='git stash push'
alias gsto='git stash pop'

alias gssa='git stash show --all'
alias gsap0='git stash apply stash@{0}'

alias gsi='git submodule init'
alias gsu='git submodule update'
