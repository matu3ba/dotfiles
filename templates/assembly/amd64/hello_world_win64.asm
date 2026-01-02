bits 64 ; 64 bit
default rel ; relative addressing mode (and always use lea to get your addresses)

segment .data
    msg db "Hello world!", 0xd, 0xa, 0 ; data segment with string hello world and permissions

segment .text ; text segment for executable program code
    global main   ; ???
    extern ExitProcess ; extern symbol ExitProcess
    extern printf      ; extern symbol printf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    lea     rcx, [msg]
    call    printf

    xor     rax, rax
    call    ExitProcess
