; what happens in vDSO?
__vdso_clock_gettime:
push rbp
mov rbp, rsp
push r14
push rbx
and rsp, -16
sub rsp, 0x20
cmp edi, 0x17
ja  _doSyscall
mov eax, 0x1
mov ecx, edi
lea r11, [rip-26966]
shl eax, cl
mov edx, eax
and edx, 0x883


; to get the idea of what code is used in comments (not literal)
; const auto *cfg = clock_data_for(clk_id);
; uint64_t seq, ns, aux;
; do {
;   seq = cfg->seq; // "volatile" read
;   if (seq & 1) continue;
;   const uint64_t delta = __builtin_ia32_rdtscp(&aux) - cfg->cycle_last;
;   ns = (delta * cfg->mult + cfg->base) >> cfg->shift;
; } while (cfg->seq != seq); // "volatile" read
; return ns;

; ...
je _slowPath
mov r9d, [r11]
mov r10d, r9d
and r10d, 0x1
jne _seqlockFail
mov eax, [r11+0x4]
cmp eax, 0x1
jne _notTsc
rdtscp                    ; __builtin_ia32_rdtscp(&aux)
xchg ax, ax
shl rdx, 0x20
or rdx, rax
btr rdx, 0x3f
movsxd r8, edi
; ..mul / shift / ret
