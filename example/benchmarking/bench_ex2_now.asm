; what happens in now() ?
std::chrono::_V2::steady_clock::now():
sub rsp, 0x18                 ; timespec ts
mov edi, 0x01                 ; param0 = CLOCK_MONOTONIC
mov rsi, rsp                  ; param = &ts
call __clock_get_time         ; clock_gettime(CLOCK_MONOTONIC, &ts)
imul rax, [rsp], 0x3b9aca00   ; r = ts.tv_sec * 1 billion
add rax, [rsp+0x8]            ; r += ts.tv_nsec
add rsp, 0x18                 ; restore stack
ret                           ; return r

; interesting: uses CLOCK_MONOTONIC
