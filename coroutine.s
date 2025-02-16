section .bss
stack1 resb 1024          ; Stack for coroutine 1
stack1_end:
stack2 resb 1024          ; Stack for coroutine 2
stack2_end:

section .data
saved_rsp dq 0            ; Store RSP of paused coroutine

section .text
global _start

switch_coroutine:
    push rbp              ; Save base pointer
    mov rbp, rsp          ; Save current stack pointer
    mov [saved_rsp], rsp  ; Store RSP in memory

    mov rsp, rdi          ; Load new stack pointer (argument)
    pop rbp
    ret                   ; Resume execution at new stack

_start:
    mov rsp, stack1_end   ; Set stack for coroutine 1

    mov rdi, stack2_end   ; Argument for switch_coroutine (new stack)
    call switch_coroutine

    ; Code after coroutine switch (back in coroutine 1)
    mov rdi, stack1_end   ; Switch back to coroutine 1
    call switch_coroutine

    ; Exit syscall (macOS uses syscall, not int 0x80)
    mov rax, 0x2000001    ; syscall: exit
    xor rdi, rdi          ; exit code 0
    syscall
