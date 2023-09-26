if status is-interactive
  # Commands to run in interactive sessions can go here
  # export variables
  # set -x MyVariable SomeValue, --export
  # erase variable
  # set -e MyVariable
  # append/prepend to list $PATH (echo $PATH, count $PATH)
  # set PATH $PATH /usr/local/bin
  # indexing has beginning 1 or backwards from -1, slices $PATH[-1..2]
  # for val in $PATH
  #   echo "entry: $val"
  # end
  # echo In (pwd), running $(uname)
  # set os (uname)
  # Command substitutions without a dollar are not expanded within quotes
  # => ${HOME} is invalid, use {$HOME} is valid. or use $HOME
  # touch "testing_$(date +%s).txt"
  # set myfile "$(cat myfile)"
  # printf '|%s|' $myfile
  # exist status: echo $status
  # set --query returns the number of variables it queried that weren’t set
  # for x in (seq 5)
  #   touch file_$x.txt
  # end
  # remote matching string from path from PATH
  # set PATH (string match -v /usr/local/bin $PATH)
  # universal variables

  set -U fish_greeting # no welcome spam
  # no annoying ../../ typing
  alias ...="cd ../.."
  alias ....="cd ../../.."
  alias .....="cd ../../../.."
  alias ......="cd ../../../../.."
  alias .......="cd ../../../../../.."
  alias ........="cd ../../../../../../.."
  alias .........="cd ../../../../../../../.."
  alias ..........="cd ../../../../../../../../.."
  alias ...........="cd ../../../../../../../../../.."
  alias ............="cd ../../../../../../../../../../.."
  alias .............="cd ../../../../../../../../../../../.."

  # fix $? and $$
  function bind_status
    commandline -i (echo '$status')
  end
  function bind_self
    commandline -i (echo '$fish_pid')
  end
  function fish_user_key_bindings
    bind '$?' bind_status
    bind '$$' bind_self
  end
  # fix !!
  function bangbang --on-event fish_postexec
    abbr -g !! $argv[1]
  end

  #### ported sources ####
  # source "$HOME/dotfiles/.config/shells/aliases"
  # source "$HOME/dotfiles/.config/shells/aliases_git"

  # git abbreviations and aliases
  source "$HOME/.config/fish/git.fish"

  # PATH settings
  fish_add_path "$HOME/.cargo/bin"
  fish_add_path "$HOME/.local/bin"
  fish_add_path "$HOME/.local/appimages"
  # fish_add_path "$HOME/dev/git/zi/zig/master/build" # zig stages 1,2
  # fish_add_path "$HOME/dev/git/zi/zig/master/build/stage3/bin" # zig
  # fish_add_path "$HOME/dev/git/zi/zig/master/buildrel/stage3/bin" # zig stages 3
  fish_add_path "$HOME/dev/git/zi/zig/master/rel/bin" # zig stages 3
  fish_add_path "$HOME/.luarocks/bin"
  fish_add_path "$HOME/.local/nvim/bin" # neovim testing
  fish_add_path "$HOME/dev/git/zi/zigmod/zig-out/bin" # zigmod binary
  fish_add_path "$HOME/dev/git/cpp/llvm-project/build-release/bin" # llvm tooling

  if test "$XDG_SESSION_TYPE" = "wayland"
    set -U QT_QPA_PLATFORM "wayland"
    #set -U GDK_BACKEND "wayland" # breaks Electron based apps
    set -U CLUTTER_BACKEND "wayland"
  end

  set -gx EDITOR "nvim"

  #set -gx GPG_TTY "$(tty)"
  #set -gx SSH_AUTH_SOCK $(gpgconf --list-dirs agent-ssh-socket)
  # gpgconf --launch "gpg-agent"
  # trap "gpgconf --kill gpg-agent" exit
  # gpgconf --kill gpg-agent
  # gpg-connect-agent reloadagent /bye
  # gpg-connect-agent updatestartuptty /bye >/dev/null
  # GIT_VERB=1 git push

  # if test -z (pgrep ssh-agent | string collect)
  # end
  # eval (ssh-agent -c)
  # set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
  # set -gx SSH_AGENT_PID $SSH_AGENT_PID
  # trap "ssh-agent -k" exit

  zoxide init fish | source

  alias l ' ls --color=auto --hyperlink=auto --group-directories-first -h'
  abbr --add -g sus ' systemctl suspend'

  abbr --add -g           via ' {$HOME}/.local/appimages/nvim.appimage'
  abbr --add -g          jvia ' firejail $HOME/.local/appimages/nvim.appimage'
  abbr --add -g          cvia ' {$HOME}/.local/appimages/nvim.appimage -u NONE'
  abbr --add -g          dvia ' {$HOME}/.local/appimages/nvim.appimage -u DEFAULT'
  abbr --add -g        histup ' {$HOME}/.local/appimages/nvim.appimage "/var/log/"' # pacman.log or apt/
  abbr --add -g       aliases ' {$HOME}/.local/appimages/nvim.appimage "$HOME/dotfiles/.config/shells/aliases"'
  abbr --add -g        bashrc ' {$HOME}/.local/appimages/nvim.appimage "$HOME/dotfiles/.bashrc"'
  abbr --add -g        fishrc ' {$HOME}/.local/appimages/nvim.appimage "$HOME/.config/fish/config.fish"'
  abbr --add -g           dfs ' {$HOME}/.local/appimages/nvim.appimage "$HOME/dotfiles/"'
  abbr --add -g   aliases_git ' {$HOME}/.local/appimages/nvim.appimage "$HOME/dotfiles/.config/shells/aliases_git"'
  abbr --add -g   aliases_nix ' {$HOME}/.local/appimages/nvim.appimage "$HOME/dotfiles/.config/shells/aliases_nix"'
  abbr --add -g     templates ' {$HOME}/.local/appimages/nvim.appimage "$HOME/dotfiles/templates"'

  abbr --add -g            vi ' {$HOME}/.local/nvim/bin/nvim'
  abbr --add -g           jvi ' firejail $HOME/.local/nvim/bin/nvim'
  abbr --add -g           cvi ' {$HOME}/.local/nvim/bin/nvim -u NONE'
  abbr --add -g           dvi ' {$HOME}/.local/nvim/bin/nvim -u DEFAULT'
  abbr --add -g      histupvi ' {$HOME}/.local/nvim/bin/nvim "/var/log/"' # pacman.log or apt/
  abbr --add -g     aliasesvi ' {$HOME}/.local/nvim/bin/nvim "$HOME/dotfiles/.config/shells/aliases"'
  abbr --add -g      fishrcvi ' {$HOME}/.local/nvim/bin/nvim "$HOME/dotfiles/.config/fish/config.fish"'
  abbr --add -g aliases_gitvi ' {$HOME}/.local/nvim/bin/nvim "$HOME/dotfiles/.config/shells/aliases_git"'
  abbr --add -g aliases_nixvi ' {$HOME}/.local/nvim/bin/nvim "$HOME/dotfiles/.config/shells/aliases_nix"'
  abbr --add -g   templatesvi ' {$HOME}/.local/nvim/bin/nvim "$HOME/dotfiles/templates"'

  # neovim installation needs manual fixups to remove additional installed parsers, because c and c++ parsers are very broken:
  # rm ~/.local/nvim/lib/nvim/parser/c.so
  # rm ~/.local/nvim/lib/nvim/parser/cpp.so
  abbr --add -g          nb ' {$HOME}/dev/git/cpp/mold/build/mold -run make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/nvim install'
  abbr --add -g        nbnj ' firejail --noprofile {$HOME}/dev/git/cpp/mold/build/mold -run make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/nvim install'
  abbr --add -g      nbnjnm ' firejail --noprofile make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/nvim install'
  abbr --add -g        nbnm ' make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/nvim install'
  # abbr --add -g         nbz ' CC="zcc.sh" make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/nvim DEPS_CMAKE_FLAGS="-DCMAKE_CC_COMPILER=zig\ cc" install'

  abbr --add -g      nbasan ' CMAKE_EXTRA_FLAGS="-DCMAKE_C_COMPILER=clang -DCLANG_ASAN_UBSAN=1" make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/asan_nvim install'

  abbr --add -g  zbcmdeb ' mkdir -p build/ && cd build/ && cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH="$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/host/" -GNinja && /usr/bin/time -v ninja install  && cd ..'
  abbr --add -g  zbdeb ' {$HOME}/dev/git/zi/zig/master/buildrel/stage3/bin/zig build -p deb -Doptimize=Debug --search-prefix "$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/x86_64-linux-musl-native" --zig-lib-dir lib -Dstatic-llvm'
  abbr --add -g  zdeb ' {$HOME}/dev/git/zi/zig/master/rel/bin/zig build -p deb -Doptimize=Debug --search-prefix "$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/x86_64-linux-musl-native" --zig-lib-dir lib -Dstatic-llvm'

  abbr --add -g  zbcmrel ' mkdir -p buildrel/ && cd buildrel/ && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/host/" -GNinja && /usr/bin/time -v ninja install && cd ..'
  abbr --add -g  zbrel ' {$HOME}/dev/git/zi/zig/master/buildrel/stage3/bin/zig build -p rel -Doptimize=ReleaseSafe --search-prefix "$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/x86_64-linux-musl-native" --zig-lib-dir lib -Dstatic-llvm'
  abbr --add -g  zrel ' {$HOME}/dev/git/zi/zig/master/rel/bin/zig build -p rel -Doptimize=ReleaseSafe --search-prefix "$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/x86_64-linux-musl-native" --zig-lib-dir lib -Dstatic-llvm'

  # abbr --add -g  zbcmrel ' mkdir -p buildrel/ && cd buildrel/ && cmake .. -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH="$HOME/.local/llvm/" -GNinja && /usr/bin/time -v ninja install && cd ..'

  abbr --add -g        zd ' ./deb/stage3/bin/zig'
  abbr --add -g        zr ' ./rel/stage3/bin/zig'
  abbr --add -g        zn ' $HOME/dev/git/zi/zig/master/stage3/bin/zig'
  abbr --add -g   arocc ' {$HOME}/dev/git/zi/arocc/zig-out/bin/arocc'
  abbr --add -g  zigdebc ' {$HOME}/dev/git/zi/zig/debug/build/stage3/bin/zig'
  abbr --add -g  zigdeb ' {$HOME}/dev/git/zi/zig/debug/stage3/bin/zig'
  abbr --add -g  zigstd ' {$HOME}/.local/appimages/nvim.appimage {$HOME}/dev/git/zi/zig/master/lib/std'
  abbr --add -g   zup1 ' ./build/stage3/bin/zig build update-zig1'
  abbr --add -g   zdoc ' cd {$HOME}/dev/git/zi/zig/master/buildrel/stage3/lib/zig/docs/'

  abbr --add -g  rmzigallcache ' rm -fr zig-cache/ zig-out/ "$HOME"/.cache/zig/'
  abbr --add -g  rmzigcacherec ' fd -t d -u "zig-out|zig-cache" -x rm -fr {};'

  # firejail
  abbr --add -g   nojail  ' firejail --noprofile'
  abbr --add -g   njfoxPM ' firejail --noprofile firefox --ProfileManager'
  abbr --add -g ffoxnoprofile ' firejail --noprofile firefox --profileManager'

  function mktmpdir -d "create tmp dir, if not existing"
    if test (count $argv) -eq 1
      if ! test -d "$argv[1]"
        echo "directory $argv[1] does not exist, creating.."
        mkdir "$argv[1]"
      end
    else
      echo "invalid argument number"
    end
    # echo "success mktmpdir"
  end
  function rmtmpdir -d "remove tmp dir, if not existing"
    if test (count $argv) -eq 1
      if test -d "$argv[1]"
        echo "directory $argv[1] does exist, deleting recursively.."
        rm -fr "$argv[1]"
      end
    else
      echo "invalid argument number"
    end
  end
  # function firejailNetWhiteList_fromtmpdir -d "tmpdir creation + deletion with spawning jailed process as 1. process, 2. name--net= and 3.--whitelist="
  #   if test (count $argv) -eq 3 -a (test (type -t) = "file")
  #     firejail "--net=$argv[2]" "--whitelist=$argv[3]" "$argv[1]"
  #   end
  # end

  function falketh -d "sandboxing falkon + whitelist download dir"
    set TMP "$HOME/tmpf/falk" && mktmpdir "$TMP" && firejail --net=enp4s0 "--whitelist=$TMP" falkon && rmtmpdir "$TMP"
  end
  function falkwlan -d "sandboxing falkon + whitelist download dir"
    set TMP "$HOME/tmpf/falk" && mktmpdir "$TMP" && firejail --net=wlan0 "--whitelist=$TMP" falkon && rmtmpdir "$TMP"
  end
  function sfalketh -d "sandboxing falkon + whitelist download dir"
    set TMP "$HOME/tmpf/sfalk" && mktmpdir "$TMP" && firejail --net=enp4s0 "--private=$TMP" falkon && rmtmpdir "$TMP"
  end
  function sfalkwlan -d "sandboxing falkon + whitelist download dir"
    set TMP "$HOME/tmpf/sfalk" && mktmpdir "$TMP" && firejail --net=wlan0 "--private=$TMP" falkon && rmtmpdir "$TMP"
  end
  function foxeth -d "sandboxing firefox + whitelist download dir (default profile) "
    set TMP "$HOME/tmpf/fox" && mktmpdir "$TMP" && firejail --net=enp4s0 "--whitelist=$TMP" firefox -P default && rmtmpdir "$TMP"
  end
  function foxwlan -d "sandboxing firefox + whitelist download dir (default profile) "
    set TMP "$HOME/tmpf/fox" && mktmpdir "$TMP" && firejail --net=wlan0 "--whitelist=$TMP" firefox -P default && rmtmpdir "$TMP"
  end
  function sfoxeth -d "sandboxing firefox + private download dir (no profile) "
    set TMP "$HOME/tmpf/sfox" && mktmpdir "$TMP" && firejail --net=enp4s0 "--private=$TMP" firefox && rmtmpdir "$TMP"
  end
  function sfoxwlan -d "sandboxing firefox + private download dir (no profile) "
    set TMP "$HOME/tmpf/sfox" && mktmpdir "$TMP" && firejail --net=wlan0 "--private=$TMP" firefox && rmtmpdir "$TMP"
  end
  function tbirdeth -d "sandboxing thunderbird + private download dir (no profile) "
    set TMP "$HOME/tmpf/tbird" && mktmpdir "$TMP" && firejail --net=enp4s0 "--whitelist=$TMP" thunderbird && rmtmpdir "$TMP"
  end
  function tbirdwlan -d "sandboxing thunderbird + private download dir (no profile) "
    set TMP "$HOME/tmpf/tbird" && mktmpdir "$TMP" && firejail --net=wlan0 "--whitelist=$TMP" thunderbird && rmtmpdir "$TMP"
  end
  alias  schrometh='firejail --net=enp4s0 --private chromium duckduckgo.com'
  alias schromwlan='firejail --net=wlan0 --private chromium duckduckgo.com'

  # rsync
  abbr --add -g rsync_copy ' rsync -avz --progress -h'
  abbr --add -g rsync_move ' rsync -avz --progress -h --remove-source-files'
  abbr --add -g rsync_update ' rsync -avzu --progress -h'
  abbr --add -g rsync_synchronize ' rsync -avzu --delete --progress -h'
  abbr --add -g cpv ' rsync -pogbr -hhh --backup-dir=/tmp/rsync -e /dev/null --progress'

  abbr --add -g du ' dust'
  abbr --add -g rgv ' rg --vimgrep --color always'
  abbr --add -g rgn ' rg --vimgrep'
  abbr --add -g rgp ' rg -p'

  function ccd -d "create dir and cd into it"
    if test (count $argv) -eq 1
      mkdir -p $argv[1] && cd $argv[1]
    else
      echo "invalid argument number"
    end
  end
  function mpvv -d "mpv video watch"
    if test (count $argv) -eq 1
      yt-dlp $argv[1] -o - | mpv - -force-seekable=yes
    else
      echo "invalid argument number"
    end
  end
  function makeWorkTree -d "create worktree into cwd from https url with ending .git"
    if test (count $argv) -eq 1
      set worktreesfolder (basename -s .git "$argv[1]")
      echo "$worktreesfolder"
      mkdir "$worktreesfolder"
      cd "$worktreesfolder"
      git clone --bare "$argv[1]" .bare
      # make sure git knows where the gitdir is
      echo "gitdir: ./.bare" > .git
      git worktree add master
    else
      echo "invalid argument number"
    end
  end

  # Note: Other shells do not know what gpg server is currently attached to.
  function startGpg -d "start gpg with ssh to workaround pinentry-tty bugs"
    gpgconf --launch "gpg-agent"
    set -gx GPG_TTY "$(tty)"
    set -gx SSH_AUTH_SOCK $(gpgconf --list-dirs agent-ssh-socket)
    # idea modify prompt, process name and title
  end
  function reconnectGpg -d "reconnect to gpg client to workaround pinentry-tty bugs"
    gpg-connect-agent updatestartuptty /bye >/dev/null
  end
  function stopGpg -d "stop gpg with ssh to workaround pinentry-tty bugs"
    set -e GPG_TTY
    set -e SSH_AUTH_SOCK
    # idea modify prompt, process name and title
    gpgconf --kill gpg-agent
  end
  #function countdown -d "TODO countdown in seconds shown as H:M:S"
  #  sleep(0.1)
  #end
  #function stopwatch -d "TODO stopwatch showing time running H:M:S since start"
  #  sleep(0.1)
  #end
end

# SHENNANIGAN
# putting shell scripts (stopped) into background, which ask for tty may break
# cpu usage thinking those jobs utilize 100% core usage.
