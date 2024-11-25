//! Minimal C++ or "C with templates and no classes, RAII and OOP".
// Tested with
// flags to strip everything superflous without creating unportable behavior:
// * no stack-walking                  -fno-unwind-tables
// * no unwind table at call boundary  -fno-asynchronous-unwind-tables
// *
// * position independent code pic     -fPIC"
// try cflags.append("-fvisibility=hidden");
// try cflags.append("-fvisibility-inlines-hidden");
// try cflags.append("-fvisibility-global-new-delete=force-hidden");
// * last C++ standard                 -std=c++23

//  .strip = comp.compilerRtStrip(),
//  .stack_check = false,
//  .stack_protector = 0,
//  .red_zone = comp.root_mod.red_zone,
//  .omit_frame_pointer = comp.root_mod.omit_frame_pointer,
//  .valgrind = false,
//  .sanitize_c = false,
//  .sanitize_thread = false,
//  .unwind_tables = false,
//  .pic = comp.root_mod.pic,
//  // necessary so that libunwind can unwind through its own stack frames
//  .unwind_tables = true,
//  .pic = if (target_util.supports_fpic(target)) true e

// .strip = strip,
// .stack_check = false,
// .stack_protector = 0,
// .sanitize_c = false,
// .sanitize_thread = false,
// .red_zone = comp.root_mod.red_zone,
// .omit_frame_pointer = comp.root_mod.omit_frame_pointer,
// .valgrind = false,
// .optimize_mode = optimize_mode,
// .structured_cfg = comp.root_mod.structured_cfg,

// .function_sections = true,
//    .data_sections = true,
//    .omit_frame_pointer = true,
//    .no_builtin = true,

// -fno-emulated-tls
// -fms-extensions

#include <cstdint>
#include <cstdio>
#include <vector>

int32_t main() {
  std::vector<uint32_t> tmp1 = {0, 1, 2, 3, 4};
  fprintf(stdout, "tmp1: ");
  for (auto const &it1 : tmp1) {
    fprintf(stdout, "%u ", it1);
  }
  fprintf(stdout, "\n");
}
