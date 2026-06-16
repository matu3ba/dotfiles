global    _start

section   .text
_start:   mov       rax, 1                  ; system call for write
          mov       rdi, 1                  ; file handle 1 is stdout
          mov       rsi, message            ; address of string to output
          mov       rdx, 13                 ; number of bytes
          syscall                           ; invoke operating system to do the write
          mov       rax, 60                 ; system call for exit
          xor       rdi, rdi                ; exit code 0
          syscall                           ; invoke operating system to exit

section   .data
message:  db        "Hello, World", 10      ; note the newline at the end

; $ as assem.s -o assem.o
; .global _start
; .intel_syntax noprefix
;
; _start:
;       mov rax, 1              // sys_write syscall number
;       mov rdi, 1              // stdout file descriptor
;       lea rsi, [hello_world]  // loading effective address of hello_world
;       mov rdx, 14             // length of string
;       syscall
;       mov rax, 60             // sys_exit syscall number
;       mov rdi, 0              // exit code
;       syscall
;
; hello_world:
;       .asciz "Hello, World!\n"
