#!/usr/bin/env sh
# based on https://github.com/ziglang/zig-boots/blob/master/build
set -eu

command -v 'cmake' 1>/dev/null || (
  echo "please install cmake"
  exit 1
)
command -v 'ninja' 1>/dev/null || (
  echo "please install ninja"
  exit 1
)

if test $# -lt 1 || test $# -gt 1; then
  echo "Usage:
$0 \$1
  \$1: path to target dir
"
  exit 1
fi
TARGET_DIR="$1"

echo "bootstrap clang"
mkdir -p "$TARGET_DIR" || (
  ERR=$! && echo "error $ERR during mkdir"
  exit $ERR
)
cd "$TARGET_DIR" || (
  ERR=$! && echo "error $ERR during cd $TARGET_DIR"
  exit $ERR
)

#basic
# cmake "../llvm" \
#   -DCMAKE_BUILD_TYPE=RelWithDebInfo \
#   -DLLVM_ENABLE_PROJECTS='lld;lldb;clang;clang-tools-extra' \
#   -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF \
#   -DLLVM_TOOL_LLVM_LTO_BUILD=OFF \
#   -DLLVM_TOOL_LTO_BUILD=OFF \
#   -DLLDB_INCLUDE_TESTS=OFF

# does not exist in llvm20
# -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF \
# -DLLVM_ENABLE_TERMINFO=OFF \

# extended
cmake "../llvm" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DLLVM_ENABLE_PROJECTS='lld;lldb;clang;clang-tools-extra' \
  -DLLVM_TOOL_LLVM_LTO_BUILD=OFF \
  -DLLVM_TOOL_LTO_BUILD=OFF \
  -DLLDB_INCLUDE_TESTS=OFF \
  -DLLVM_ENABLE_LIBXML2=OFF \
  -DLLVM_ENABLE_LIBEDIT=OFF \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_PARALLEL_LINK_JOBS=1 \
  -G Ninja

#fancy
# cmake "../llvm" \
#   -DCMAKE_BUILD_TYPE=Release \
#   -DLLVM_ENABLE_BINDINGS=OFF \
#   -DLLVM_ENABLE_LIBEDIT=OFF \
#   -DLLVM_ENABLE_LIBPFM=OFF \
#   -DLLVM_ENABLE_LIBXML2=OFF \
#   -DLLVM_ENABLE_OCAMLDOC=OFF \
#   -DLLVM_ENABLE_PLUGINS=OFF \
#   -DLLVM_ENABLE_PROJECTS='lld;lldb;clang;clang-tools-extra' \
#   -DLLVM_ENABLE_TERMINFO=OFF \
#   -DLLVM_ENABLE_Z3_SOLVER=OFF \
#   -DLLVM_ENABLE_ZSTD=OFF \
#   -DLLVM_INCLUDE_UTILS=OFF \
#   -DLLVM_INCLUDE_TESTS=OFF \
#   -DLLVM_INCLUDE_EXAMPLES=OFF \
#   -DLLVM_INCLUDE_BENCHMARKS=OFF \
#   -DLLVM_INCLUDE_DOCS=OFF \
#   -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF \
#   -DLLVM_TOOL_LLVM_LTO_BUILD=OFF \
#   -DLLVM_TOOL_LTO_BUILD=OFF \
#   -DLLVM_TOOL_REMARKS_SHLIB_BUILD=OFF \
#   -DCLANG_BUILD_TOOLS=OFF \
#   -DCLANG_INCLUDE_DOCS=OFF \
#   -DCLANG_INCLUDE_TESTS=OFF \
#   -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF \
#   -DCLANG_TOOL_CLANG_LINKER_WRAPPER_BUILD=OFF \
#   -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF \
#   -DCLANG_TOOL_ARCMT_TEST_BUILD=OFF \
#   -DCLANG_TOOL_C_ARCMT_TEST_BUILD=OFF \
#   -DCLANG_TOOL_LIBCLANG_BUILD=OFF
cmake --build .
# cmake --build . --target clangd
# cmake --build . --target clang
# alternative: ninja install -j 4
# cmake --install . --prefix $HOME/.local/llvm/
