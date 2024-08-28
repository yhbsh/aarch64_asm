.global _main
.align 2

// Constants
.equ    FIBONACCI_TERMS, 200     // Number of Fibonacci terms to generate

.data
message: .ascii "Fibonacci Sequence:\n"
message_len = . - message
newline: .ascii "\n"
fib1: .fill 100, 1, '0'    // First Fibonacci number as a string
fib2: .fill 100, 1, '0'    // Second Fibonacci number as a string
temp: .fill 100, 1, '0'    // Temporary buffer for addition

.text
_main:
    // Print the initial message
    mov     x0, #1
    adrp    x1, message@PAGE
    add     x1, x1, message@PAGEOFF
    mov     x2, #message_len
    mov     x16, #4
    svc     #0x80

    // Initialize Fibonacci sequence
    adrp    x19, fib1@PAGE
    add     x19, x19, fib1@PAGEOFF
    adrp    x20, fib2@PAGE
    add     x20, x20, fib2@PAGEOFF
    adrp    x21, temp@PAGE
    add     x21, x21, temp@PAGEOFF

    mov     w22, #'0'
    strb    w22, [x19, #99]   // fib1 = "0"
    mov     w22, #'1'
    strb    w22, [x20, #99]   // fib2 = "1"

    mov     x23, #FIBONACCI_TERMS  // Number of terms to generate

fibonacci_loop:
    // Print current Fibonacci number (fib1)
    mov     x0, x19           // Address of fib1
    bl      _trim_and_print

    // Print newline
    mov     x0, #1
    adrp    x1, newline@PAGE
    add     x1, x1, newline@PAGEOFF
    mov     x2, #1
    mov     x16, #4
    svc     #0x80

    // Calculate next Fibonacci number: temp = fib1 + fib2
    mov     x0, x19   // fib1
    mov     x1, x20   // fib2
    mov     x2, x21   // temp
    bl      _string_add

    // Rotate: fib1 = fib2, fib2 = temp
    mov     x4, x19
    mov     x19, x20
    mov     x20, x21
    mov     x21, x4

    // Decrement counter and loop if not zero
    subs    x23, x23, #1
    b.ne    fibonacci_loop

    // Exit program
    mov     x0, #0
    mov     x16, #1
    svc     #0x80

_string_add:
    // Inputs: x0 = address of first number, x1 = address of second number, x2 = address for result
    mov     x4, #99     // Start from least significant digit
    mov     x5, #0      // Carry

add_loop:
    ldrb    w6, [x0, x4]
    ldrb    w7, [x1, x4]
    sub     w6, w6, #'0'
    sub     w7, w7, #'0'
    add     w8, w6, w7
    add     w8, w8, w5
    mov     w5, #0
    cmp     w8, #10
    b.lt    no_carry
    sub     w8, w8, #10
    mov     w5, #1
no_carry:
    add     w8, w8, #'0'
    strb    w8, [x2, x4]
    subs    x4, x4, #1
    b.pl    add_loop

    ret

_trim_and_print:
    // Input: x0 = address of number string
    mov     x1, x0          // Save start of string
    mov     x2, #0          // Counter for non-zero digits

    // Find first non-zero digit
find_non_zero:
    ldrb    w3, [x1], #1
    cmp     w3, #'0'
    b.ne    found_non_zero
    add     x2, x2, #1
    cmp     x2, #99
    b.lt    find_non_zero
    
    // If all zeros, just print '0'
    mov     x1, x0
    mov     x2, #1
    b       print_number

found_non_zero:
    sub     x1, x1, #1      // Move back to first non-zero digit
    mov     x3, x0
    add     x3, x3, #100
    sub     x2, x3, x1      // Calculate length to print

print_number:
    mov     x0, #1          // File descriptor 1 is stdout
    mov     x16, #4         // macOS write system call
    svc     #0x80
    ret
