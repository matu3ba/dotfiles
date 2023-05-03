#!/usr/bin/env sh
#
# 1. simple example
gcc -o func_dep.c
gcc -o bar_dep.c
gcc -o simplemain.c
# manually creating static library on linux (.a)
# ar r bar_dep.a func_dep.o
# ranlib libsimplefunc.a

# 2. circular example
gcc -o func_dep.c
gcc -o bar_dep.c
gcc -o frodo_dep.c
ar r libfunc_dep.a func_dep.o frodo_dep.o
ranlib libfunc_dep.a
