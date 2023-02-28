#!/usr/bin/env sh
# initialize pretty printers for gdb
# gdb not recognize ${HOME} or $HOME

# Zig
echo 'source ~/dev/git/zig/zig/master/tools/zig_gdb_pretty_printers.py' >> "${HOME}/.gdbinit"
echo 'source ~/dev/git/zig/zig/master/tools/stage1_gdb_pretty_printers.py' >> "${HOME}/.gdbinit"
echo 'source ~/dev/git/zig/zig/master/tools/stage2_gdb_pretty_printers.py' >> "${HOME}/.gdbinit"

# idea C/C++
