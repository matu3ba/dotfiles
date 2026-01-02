#### Tutorial

Based on
* https://sonictk.github.io/asm_tutorial/
* https://cs.lmu.edu/~ray/notes/nasmtutorial/
* https://github.com/guilhermecaldas/nasm-examples-macho64/tree/master/src
Requires nasm.

For output formats: nasm -hf
Showing disassembly
- objdump -h binary
- objdump -dxS -Mintel binary

#### Building

cd templates/assembly/amd64/

* hello_world assembly on windows
  nasm -f win64 -o hello_world_win64.obj hello_world_win64.asm
  link hello_world_win64.obj /subsystem:console /entry:main /out:hello_world_win64.exe
  TODO look how to set subsystem, entry, out on lld-link
  ./hello_world_win64.exe
* hello_world assembly on linux
  nasm -f elf64 -o hello_world_elf64.obj hello_world_linux64.asm
  ld.lld -o hello_world_elf64.exe hello_world_elf64.obj
  ./hello_world_elf64.exe
* hello_world assembly on macos
  nasm -f macho64 -o hello_world_macho64.obj hello_world_mac64.asm
  TODO must specify arch etc
  ld64.lld -o hello_world_macho64.exe hello_world_macho64.obj
  ./hello_world_macho64.exe
