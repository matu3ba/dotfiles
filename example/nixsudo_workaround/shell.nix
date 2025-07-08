# https://gist.github.com/Jayman2000/366d389f5d54cc3ea762e0a7b142dfe9
# unclear usage https://github.com/NixOS/nixpkgs/issues/42117
# Example workaround for sudo+FHS environments+nix-shell - Example shell.nix for
# working around <https://github.com/NixOS/nixpkgs/issues/42117>.
{ pkgs ? import <nixpkgs> {} }:

let
  fhsName = "example-fhs";
  # For whatever reason, nix-shell doesn’t change my powerline prompt when
  # running nix-shell --pure with an FHS environment.
  bashFixPrompt = ''
    unset=PROMPT_COMMAND
    PS1="(${fhsName}) \\$ "
  '';
  bashFirstInitFile = pkgs.writeText "bash-init-file-1"
    ''
      ${bashFixPrompt}
      echo '============WORKAROUND FOR BUG #42117============'
      echo 'This shell.nix uses an FHS environment to make'
      echo 'scirpts that use “#!/bin/bash” work.'
      echo 'Unfortunately, there’s a bug that prevents sudo'
      echo 'working in FHS environments:'
      echo '<https://github.com/NixOS/nixpkgs/issues/42117>'
      echo
      # Thank you, ptierno <https://stackoverflow.com/users/2671317/ptierno> and
      # sashoalm <https://stackoverflow.com/users/492336/sashoalm> for this
      # idea: <https://stackoverflow.com/a/18216122>.
      #
      # (CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0/> and
      # CC BY-SA 4.0 <https://creativecommons.org/licenses/by-sa/4.0/>)
      if [ "$EUID" -eq 0 ]; then
        echo 'Please run:'
        echo -e '\tsudo -u <your-username> -- bash --init-file "${bashSecondInitFile}"'
      else
        echo 'ERROR: for the workaround to work, you'
        echo 'have to run nix-shell as root.'
        echo '(e.g., sudo nix-shell).'
        exit 1
      fi
    '';
  bashSecondInitFile = pkgs.writeText "bash-init-file-2"
    ''
      ${bashFixPrompt}
      echo 'Workaround successful.'
    '';
in (pkgs.buildFHSEnv {
  name=fhsName;
  targetPkgs = pkgs: [ pkgs.bash ];
  runScript=''bash --init-file "${bashFirstInitFile}"'';
}).env
