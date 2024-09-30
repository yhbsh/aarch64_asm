.global _simd_add_floats
.align 4

_simd_add_floats:
    // x0 = pointer to array a
    // x1 = pointer to array b
    // x2 = pointer to result array
    // x3 = size of arrays (number of floats)

    // Preserve callee-saved registers
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     d8, d9, [sp, #-16]!

    // Initialize loop counter
    mov     x19, #0

loop:
    // Load 4 floats (16 bytes) from each array
    ld1     {v0.4s}, [x0], #16
    ld1     {v1.4s}, [x1], #16

    // Add the vectors
    fadd    v2.4s, v0.4s, v1.4s

    // Store the result
    st1     {v2.4s}, [x2], #16

    // Increment counter and check if we're done
    add     x19, x19, #4
    cmp     x19, x3
    b.lt    loop

    // Restore callee-saved registers
    ldp     d8, d9, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16

    ret
