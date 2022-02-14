//by Roozbeh Ketabi. July 29.
//This is the code stub for merge sort. Refer to the C or Java code (recursive one) for reference.
//This code should take in the size and corresponding number of 8 byte signed integers and print it in the sorted order (descending).

// SUBMISSION
// Hunter Schwartz (additions marked by START and END)

.section .rodata //read only data

    descending_print:      .asciz  "The descending list order is...\n\n"
    enter_size:            .asciz  "Enter the list size [0 to 1000]:  "
    enter_number:          .asciz  "Enter #%4lld:  "

    // note:  lld specifies a long long int
    //        a lld always takes up 64 bits in aarch64
    //        making our data entry/usage a little simpler

    llint_specifier_scan:  .asciz   "%lld"
    llint_specifier_print: .asciz  "%lld "    
    newline:               .asciz     "\n"
    here:                  .asciz    "here\n"


.global main

.text

main:
    //2 arrays of max size 1000 and one size variable
    //[sp+8, sp+16) => size
    //[sp+16, sp+8016) => helper
    //[sp+8016, sp+16016) => arr
    mov x0, #8000 // temp because 8000 doesn't fit in immediate field of sub instruction (range is 0 to 4095)
    sub sp, sp, x0
    mov x19, sp //x19 is head of array (using lowest address in the array as base)
    sub sp, sp, x0
    mov x20, sp //x20 is head of helper
    sub sp, sp, #16 //we need 8 bytes for size variable, extra 8 bytes is wasted to 16byte align sp.
    add x21, sp, #8 // x21 is size variable address

    ldr x0, =newline
    bl printf

    ldr x0, =enter_size
    bl printf

    ldr x0, =llint_specifier_scan
    mov x1, x21
    bl scanf

    ldr x0, =newline
    bl printf

    mov x22, 0 //loop i
    ldr x23, [x21]//sp is where size variable is (x23 is value of size now)
.scaninput_for:
    cmp x22, x23
    b.ge .scaninput_for_exit

    ldr x0, =enter_number
    mov x1, x22
    bl printf

    ldr x0, =llint_specifier_scan
    lsl x1, x22, 3 // x22 is i, offset is scaled by 8
    add x1, x19, x1 //current value of offset and add it to base address
    bl scanf

    add x22, x22, 1
    b .scaninput_for
.scaninput_for_exit:

    ldr x0, =newline
    bl printf

    mov x0, x19 //arr
    mov x1, x20 //helper
    mov x2, 0   //begin
    mov x3, x23 //end (one after last element which is the same as size)
    bl mergesort

    ldr x0, =descending_print
    bl printf

    mov x0, x19 //base
    mov x1, x23 //size
    bl print_array

    mov x0, #16016
    
    add sp, sp, x0

    mov x0, #0
    mov x8, #93 //93 is exit syscall
    svc #0


merge:
    //x0 is base
    //x1 is helper base
    //x2 is begin
    //x3 is mid
    //x4 is end

    mov x9, x2 //x9 is i
    mov x10, x3 //x10 is j
    mov x11, x2 //x11 is current
.merge_while:
    cmp x11, x4
    b.ge .merge_while_exit
    cmp x9, x3
    b.lt .else_if_1
    ldr x12, [x0, x10, lsl 3]
    str x12, [x1, x11, lsl 3]
    add x10, x10, 1
    b .if_else_exit
.else_if_1:
    cmp x10, x4
    b.lt .else_1
    ldr x12, [x0, x9, lsl 3]
    str x12, [x1, x11, lsl 3]
    add x9, x9, 1
    b .if_else_exit
.else_1:
    ldr x12, [x0, x9, lsl 3] //a[i]
    ldr x13, [x0, x10, lsl 3] //a[j]
    cmp x12, x13
    b.lt .inner_else //if (a[i] >= a[j])
    str x12, [x1, x11, lsl 3]
    add x9, x9, 1
    b .if_else_exit
.inner_else: //else
    str x13, [x1, x11, lsl 3]
    add x10, x10, 1
.if_else_exit:
    add x11, x11, 1 //current++
    b .merge_while
.merge_while_exit:
    ret

// ---------------------- DON'T CHANGE ABOVE THIS POINT ----------------------------------------
// ***** START Hunter ***** //


copy:
        //x0 destination array base address
	//x1 source array base address
	//x2 begin (inclusive)
	//x3 end (exclusive)

	mov x9, #0		// counter
	sub x10, x3, x2		// length
	lsl x12, x2, #3
	add x11, x0, x12	// pointer to dest start
	add x12, x1, x12	// pointer to src start

copy_loop:
	cmp x9, x10
	b.ge copy_end
	ldr x13, [x12]
	str x13, [x11]
	add x9, x9, #1
	add x11, x11, #8
	add x12, x12, #8
	b copy_loop
copy_end:	
	ret
	
mergesort:
	//x0 array
	//x1 helper
	//x2 begin
	//x3 end

	sub x4, x3, x2		// length
	cmp x4, #1
	b.le mergesort_exit

	sub sp, sp, #48
	str x30, [sp, #40]
	str x0, [sp, #32]
	str x1, [sp, #24]
	str x2, [sp, #16]
	str x3, [sp, #8]
	str x4, [sp]

	lsr x9, x4, #1		// half-length
	add x3, x2, x9
	bl mergesort

	ldr x0, [sp, #32]
	ldr x1, [sp, #24]
	ldr x2, [sp, #16]
	ldr x3, [sp, #8]
	ldr x4, [sp]

	lsr x9, x4, #1
	add x2, x2, x9
	bl mergesort

	ldr x0, [sp, #32]
	ldr x1, [sp, #24]
	ldr x2, [sp, #16]
	ldr x4, [sp, #8]
	ldr x9, [sp]
	lsr x9, x9, #1
	add x3, x2, x9
	bl merge

	ldr x0, [sp, #32]
	ldr x1, [sp, #24]
	ldr x2, [sp, #16]
	ldr x3, [sp, #8]
	bl copy

	ldr x30, [sp, #40]
	add sp, sp, #48
	
mergesort_exit:
	ret

	// ***** END Hunter ***** //

// ---------------------- DON'T CHANGE BEYOND THIS POINT ----------------------------------------

print_array:
    stp x19, x20, [sp, -16]!
    stp x21, x30, [sp, -16]!

    mov x19, x0
    mov x20, x1
    mov x21, #0 // x21 is i
.for1:
    cmp x21, x20
    b.ge .for1_exit

    ldr x1, [x19, x21, lsl #3]
    ldr x0, =llint_specifier_print
    bl printf

    add x21, x21, #1
    b .for1

.for1_exit:
    ldr x0, =newline
    bl printf

    //ldr x30, [sp], #16
    //shorthand (post-indexing) for following two instructions:
    ldp x21, x30, [sp], 16
    ldp x19, x20, [sp], 16

    ret
    //equivalent of br x30, but hints that it is returning from a procedure.
