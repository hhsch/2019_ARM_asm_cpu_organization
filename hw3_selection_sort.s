// selection_sort.s
//
// Pete Dobbins
//
// SUBMISSION
// Hunter Schwartz (additions marked by START and END)
// Section 16684
// HW 3
// 9 July, 2019
.data
	you_entered:     .asciz "You entered this list:  "
	// EDIT should say descending
	ascending_sort:  .asciz "The descending sorted list:  "
	newline:         .asciz "\n"
	request_number:  .asciz "Enter Integer #%d:  "
	print_int:       .asciz "%d "

	int_specifier:   .asciz "%d"
	int_buffer:      .space 4

.global main
.text

main:
	// scan 10 values from user
	MOV X19, #10         // length
	MOV X20, #0          // counter

	// Update SP to store 10 new values
	ADD X21, SP, #0      // save base address of 10 values
	SUB SP, SP, #80      // open up space

init_loop:

	SUBS X15, X20, X19
	B.GE init_complete

	// Request number
	// Load request string into X0
	LDR X0, =request_number
	ADD X1, X20, #1
	BL printf

	// Load requested type into X0
	// Load destination buffer into X1
	LDR X0, =int_specifier
	LDR X1, =int_buffer
	BL scanf

	LDR X10, =int_buffer
	LDR X11, [X10, #0]

	// take the value the user entered and put it into the next
	// position for the stored values (stack moves down, so SUB)
	// base - offset (counter) -> X21 - X13
	LSL X13, X20, 3
	SUB X12, X21, X13
	STR X11, [X12, #0]

	ADD X20, X20, #1

	B init_loop


init_complete:

	LDR X0, =you_entered
	BL printf

	// setup parameters to pass
	// call print_array
	MOV X0, X21         // pass base address
	MOV X1, X19         // pass length
	BL print_array


	// setup parameters to pass
	// call selection_sort
	MOV X0, X21
	MOV X1, X19 
	BL selection_sort


	LDR X0, =ascending_sort
	BL printf

	// setup parameters to pass
	// call print_array
	MOV X0, X21
	MOV X1, X19
	BL print_array

	B exit

// ***** START Hunter ***** //
selection_sort:
	// I originally wrote this function without
	// looking at the assignment, it was written
	// to take a pointer to an array's LOW memory
	// address, and to sort it low-to-high; this
	// will be fine since it will be sorted from
	// high-to-low from the perspective of the
	// pointer to the high memory base of the array.
	// I just first need to calculate the low
	// address of the array.
	mov x9, x1
	lsl x9, x9, #3
	sub x0, x0, x9
	add x0, x0, #8		// now points to low address of array
	sub sp, sp, #16
	str x30, [sp, #0]
	bl sort			// links to my actual sort
	ldr x30, [sp, #0]
	add sp, sp, #16
	br x30

sort:
	// x0 base address (argument)
	// x1 length (argument)
	// x2 counter
	// x3 next address to move
	mov x2, #0	// initialize counter
	mov x3, #0	// initialize element to swap
	sub sp, sp, #16
	str x30, [sp, #0]
sort_condition:
	cmp x2, x1
	b.ge sort_return
sort_body:
	bl find_minimum		// stores minimum in x3
	cmp x2, x3		// only swap if smallest is not itself
	b.eq sort_post
	bl swap
sort_post:
	add x2, x2, #1
	b sort_condition
sort_return:
	ldr x30, [sp, #0]
	add sp, sp, #16
	br x30

find_minimum:
	// x0 pointer to unsorted 
	// x1 number of elements (only called if greater than 0)
	// x2 initial offset
	// x3 returns offset of least element
	mov x9, x2		// position of smallest
	lsl x10, x9, #3
	add x10, x10, x0
	ldr x10, [x10, #0]	// contents of smallest
	add x11, x2, #1		// counter
min_condition:
	cmp x11, x1
	b.ge min_return
min_body:
	lsl x12, x11, #3
	add x12, x12, x0
	ldr x12, [x12, #0]
	cmp x12, x10
	b.ge min_post
	mov x9, x11
	mov x10, x12
min_post:
	add x11, x11, #1
	b min_condition
min_return:
	mov x3, x9
	br x30

swap:
	// x0 base address
	// x1 length
	// x2 off1
	// x3 off2
	mov x9, x2	// calculating addresses
	lsl x9, x9, #3
	add x9, x9, x0
	mov x10, x3
	lsl x10, x10, #3
	add x10, x10, x0
	ldr x11, [x9]	// contents in off1
	ldr x12, [x10]	// contents in off2
	str x12, [x9]	// swap
	str x11, [x10]
swap_return:
	br x30
	
print_array:
	sub sp, sp, #32
	mov x9, #0		// counter
	str x0, [sp, #8]	// base address
	str x1, [sp, #16]	// size
	str x30, [sp, #24]	// link address
print_array_loop:
	ldr x10, [sp, #16]
	cmp x9, x10		// return if at end of array
	b.ge print_array_return
	ldr x0, =print_int
	mov x10, x9
	lsl x10, x10, #3
	ldr x11, [sp, #8]
	sub x11, x11, x10	// calculate address of next element
	ldr x1, [x11, #0]
	str x9, [sp, #0]
	bl printf
	ldr x9, [sp, #0]
	add x9, x9, #1	// increment counter
	b print_array_loop
print_array_return:
	ldr x0, =newline
	bl printf
	ldr x30, [sp, #24]
	add sp, sp, #32
	br x30
	
// ***** END Hunter ***** //

exit:
	MOV X0, #0
	MOV X8, #93
	SVC #0
