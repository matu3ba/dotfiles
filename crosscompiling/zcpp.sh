#!/bin/sh
# workaround for programs not respecting spaces in CXX variables

zig c++ "$@"
