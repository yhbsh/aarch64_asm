.global _main
.align 4

.macro syscall num
    mov x16, \num
    svc #0x80
.endm

.macro sys_write fd, buf, len
    mov x0, \fd
    adr x1, \buf
    mov x2, \len
    syscall 4
.endm

.macro sys_exit code
    mov x0, \code
    syscall 1
.endm

_main: 
    mov x3, #0
    bl loop

loop:
    cmp x3, #100
    b.eq end
    sys_write 1, str, 13
    add x3, x3, #1
    bl loop

end:
    sys_exit 0

str: .ascii  "Hello World!\n"
