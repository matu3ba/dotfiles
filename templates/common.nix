# mega package 2nix converter https://github.com/nix-community/dream2nix
# * nodejs, python, rust
# https://nlnet.nl/project/Dream2nix/

# https://fzakaria.com/2026/08/09/nixpkgs-multiverse-every-version-that-ever-existed
# default linker path could be better https://github.com/NixOS/nixpkgs/issues/490000
# - no dynamic linker workarounds
# environment.stub-ld.enable = false;
# environment.ldso = pkgs.stdenv.cc.bintools.dynamicLinker;
# * GPU drivers may break
# * cross-compilation should use buildFHSEnv https://nixos.org/manual/nixpkgs/stable/#sec-fhs-environments

#==container_building
# The post in https://sgt.hootr.club/blog/docker-protips/ with FROM scratch looks
# excellent, but looks generally what production stuff uses (might be missing
# some debug stuff for k8).
# https://tmp.bearblog.dev/minimal-containers-using-nix/ has nix vs alpine
# example showing that layers would need replacements.
# https://github.com/nlewo/nix2container only shows what is fast.
#==container_composition
# * podman compose
#   - cwd-based configurations very annoying
#   - Podman/Docker compose has no tooling for diagnostics and tagging
#     stateful/stateless containers for use case groups, so automation is error
#     prone, requires building from scratch or requires compose file duplication.
# * podman pod
#   - cluster config files?
# * podman system
# * quadlet

# no package manager to simplify fetching dev tooling for nix
# no debugger, only repl https://nixos-and-flakes.thiscute.world/best-practices/debugging.

# https://learnxinyminutes.com/docs/nix/

# debugging nix:
# nix repl and throwing in trace calls in places, like printf debugging
# arcane flags to trace things
#

# bad parts
# 1. depends on what is injected in the modules, not what the module pulls in
# -> hard to trace out the module dependency graph or how you should call it,
#    when you're looking at
# -> one file, you have no idea where the referenced symbols came from
# 2. how weakly typed it is

# based on https://www.vimjoyer.com/course/

builtins.typeOf [] # list
builtins.length [1 2 3] 3
builtins.head [1 2 3] # [1]
builtins.tail [1 2 3] # [2 3]
builtins.typeof []
let
  tools = [ "git" "vim" "curl"];
in
"tools:${toString (builtins.length tools)}"
# 3

builtins.filter
(money: money > 100)
[ 10 50 100 200 ]
# [ 200 ]

builtins.map
(money: money + 10)
[ 10 20 30 ]
# [ 20 30 40 ]

builtins.attrNames {
  castle = "online";
  gate = "online";
  tower = "online";
}
# [ "castle" "gate" "tower" ]

builtins.attrValues {
  checking = 25;
  savings = 100;
}
# [ 25 100 ]

let
  balance = 200;
in
"balance=${toString balance}"
"balance=200"

# lib is much bigger
lib.reverseList [ "git" "vim" ]
# [ "vim" "git" ]

let
  coins = [ 10 20 50 100 ];
in
{
  firstTwo = lib.take 2 coins;
  afterTwo = lib.drop 2 coins;
}
# { afterTwo = [ 50 100 ]; firstTwo = [ 10 20 ]; }

lib.unique [ "git" "git" ]
# [ "git" ]

lib.concatStringsSep " + " [ "CPU" "RAM" "SSD" ]
# "CPU + RAM + SSD"

{
  isNixFile = lib.hasSuffix ".nix" "flake.nix";
  isHidden = lib.hasPrefix "." "flake.nix";
}
# { isHidden = false; isNixFile = true; }

lib.any
(coin: coin >= 100)
[ 5 20 100 10 ]
# true

lib.all
(coin: coin >= 100)
[ 5 20 100 10 ]
# false

lib.mapAttrs
(name: pixels: pixels * 2)
{
  width = 20;
  height = 35;
}
# { height = 70; width = 40; }

lib.mapAttrs
(name: pixels: name + ":" + toString pixels)
{
  width = 20;
  height = 35;
}
# { height = "height:35"; width = "width:20"; }

let
  wantsDebugger = true;
in
[ "git" "vim" ]
++ lib.optional wantsDebugger "gdb"
# [ "git" "vim" "gdb" ]

let
  wantsDebugger = true;
in
[ "git" "vim" ]
++ lib.optionals wantsDebugger [ "gdb" "strace" ]
# [ "git" "vim" "gdb" "strace" ]

{
  direct = lib.range 3 6;
  grouped = lib.lists.range 3 6;
}
# { direct = [ 3 4 5 6 ]; grouped = [ 3 4 5 6 ]; }

# ./tools is path value
# Points at the directory. Nothing inside it is evaluated merely because a file named default.nix exists.

# import ./tools is evaluate
# import sees a directory, opens tools/default.nix, evaluates its expression, and returns that value.

# "${./tools}" is store snapshot
# String coercion copies the directory contents into the Nix store and produces
# a string such as /nix/store/…-tools.
see also builtins.typeOf ./tools or import ./tools or "${./tools}"

let
  name = "vimjoyer";
  shell = "fish";
in
{ inherit name; }
# { name = "vimjoyer"; }

let
  user = {
    name = "yurii";
    shell = "fish";
    port = 22;
  };
in
{ inherit (user) name shell;
# { name = "yurii"; shell = "fish"; }

rec {
  version = "1.0";
  name = "my-program-${version}";
}
# { name = "my-program-1.0"; version = "1.0"; }

let
  defaults = {
    port = 3000;
    host = "localhost";
  };
in
defaults // { port = 8080; }
# { host = "localhost"; port = 8080; }

let
  settings = {
    port = 3000;
  };
in
settings.host or "localhost"
# "localhost"

# completely trivial different usage of ? here for attribute sets vs functions
let
  settings = {
    port = 3000;
  };
in
{
  hasPort = settings ? port;
  hasHost = settings ? host;
}
# { hasHost = false; hasPort = true; }

let
  tools = {
    git = "git";
    vim = "vim";
  };
in
with tools; [ git vim ]
# [ "git" "vim" "ripgrep" ]

# prefer inherit over with (weaker claim; name in scope keeps field)

let
  port = 8080;
in
''
listen ${toString port};
port: ''${ port }
Use ''' for literal quotes.
''
# "listen 8080;\nport: ${port}\nUse '' for literal quotes."

# A nix module is an attribute set or function returning attribute set with
# imports of modules getting merged into a list.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.git pkgs.ripgrep ];
}
# vs attribute set
{

}

{ ... }:
{
  imports = [
    # ./users.nix
  ];
}

# One can instead also write nix modules inline and let them be concatenated.
# This is what I prefer to do.

# The exact rule always belongs to the option’s declared type, and priorities
# like mkForce can still change which definitions take part.
{ lib, ... }:
{
  programs.firefox.enable = lib.mkForce false;
}

# mkDefault uses the same idea, but is weakest condition: mkDefault < value < mkForce
{ lib, ... }:
{
  networking.hostName = lib.mkDefault "nixos";
}

# lib.mkMerge offers several at once
# config holds the merged result, and any module may read it.

# options holds what another file may choose.
# non-optional config holds what this module adds to the machine once every file’s choices have been merged.
# While a module only answers, NixOS lets you drop the wrapper and reads the whole file as config.
# on error: move setting down into config like so:
{ lib, ... }:
{
  options = {
    services.my-program.enable = lib.mkEnableOption "my program service";
  };
  config.networking.firewall.enable = true;
}

{ lib, ... }:
{
  options = {
    services.my-program = {
      enable = lib.mkEnableOption "my program service";
      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        example = 8080;
        description = "TCP port on which the my-program service listens";
      };
    };
  };
  config = { };
}

# Open the selected port only while my-program is enabled.
{ config, lib, ... }:
let
  cfg = config.services.my-program;
in
{
  options = {
    services.my-program = {
      enable = lib.mkEnableOption "my program service";

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        example = 8080;
        description = "TCP port used by my-program.";
      };
    };
  };
  config = {
    networking.firewall.allowedTCPPorts = lib.optional cfg.enable cfg.port;
  };
}
# Put the settings a caller may choose under options, and what follows from them under config.
# Use mkEnableOption for the usual off-by-default switch.
# Use mkOption to give every richer value a type, default, example, and description.
# The type is a gate, and default is the only one of the four that reaches the machine.
# Read merged values back through config, usually named cfg at the top of the file.
# Keep declarations and their effect in one module, then set them from another.

# >nix flake show
# >nix flake build
# >nix flake shell
# >nix flake shell nixpkgs#hello
# >nix flake run nixpkgs#hello
