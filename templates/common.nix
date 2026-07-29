# mega package 2nix converter https://github.com/nix-community/dream2nix
# * nodejs, python, rust
# https://nlnet.nl/project/Dream2nix/

# https://fzakaria.com/2026/08/09/nixpkgs-multiverse-every-version-that-ever-existed

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
