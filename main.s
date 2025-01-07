.global _main
.align 4

_main:
	mov x2, xzr

loop:
	; compare x2 which is the length of the write syscall to 11, if less increment x2 and continue, otherwise jump to end_loop
	cmp x2, #11
	b.cs end_loop
	add x2, x2, #1


	; write syscall 
	mov x0, #1
	adr x1, content
	mov x16, #4
	svc 0x8

	// save x2 in x3
	mov x3, x2
	
	// write a new line after each character
	mov x0, #1
	adr x1, line
	mov x2, 1
	mov x16, #4
	svc 0x8

	// put back the saved value of x2 into it
	mov x2, x3

	; back to loop
	b loop

end_loop:
	mov x0, #0
	mov x16, #1
	svc 0x8

line: .ascii "\n"
content: .ascii "Hello World"
