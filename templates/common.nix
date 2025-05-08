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
