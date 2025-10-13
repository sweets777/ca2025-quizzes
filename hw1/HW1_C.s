# Ripes an RV32I assembler.
# Convert bfloat16 binary string to its decimal value.
# This version avoids the use of 'li', 'mv', and 'andi' instructions.

.data
test_cases:
    .string "0011111110000000"
    .string "1011111110000000"
    .string "0000000000001111"
case_count:
    .word 3

# String literals for output
str_case:   .string "Case "
str_colon:  .string ": "
str_arrow:  .string " -> "
str_newline:.string "\n"
str_nan:    .string "NaN"


.text
.globl main

main:
    # Load test case info
    la   s0, test_cases
    la   s1, case_count
    lw   s1, 0(s1)
    addi s2, x0, 1

loop_cases:
    # Check if all cases are processed
    beq  s1, zero, end_program

    # Print "Case X: [binary string] -> "
    addi a7, x0, 4
    la   a0, str_case
    ecall
    addi a7, x0, 1
    addi a0, s2, 0
    ecall
    addi a7, x0, 4
    la   a0, str_colon
    ecall
    addi a7, x0, 4
    addi a0, s0, 0
    ecall
    addi a7, x0, 4
    la   a0, str_arrow
    ecall

    # --- parse_b16 ---
    # Convert the 16-char binary string to a 16-bit integer
    addi a1, s0, 0
    add  t0, x0, x0
    add  t1, x0, x0
    addi t2, x0, 16

parse_loop:
    beq  t1, t2, parse_done
    lb   t3, 0(a1)
    slli t0, t0, 1
    addi a1, a1, 1
    addi t1, t1, 1
    addi t4, x0, 49
    bne  t3, t4, parse_loop
    ori  t0, t0, 1
    j    parse_loop

parse_done:
    # Now t0 holds the 16-bit bfloat16 value

    # --- bf16bits_to_float32 ---
    # Extract sign bit from bfloat16 (bit 15)
    srli t1, t0, 15
    slli t1, t1, 31

    # Extract exponent from bfloat16 (bits 7-14)
    # To isolate the 8 exponent bits, we shift away the 7 mantissa bits
    # and then shift back to remove the sign bit.
    slli t2, t0, 17         # Shift left by (32-15)=17. Now: S EEEEEEEE 0...0
    srli t2, t2, 24         # Shift right by (32-8)=24. Now: 0...0 EEEEEEEE
    
    # Extract mantissa from bfloat16 (bits 0-6)
    # Replaces 'andi t3, t0, 0x7F'
    slli t3, t0, 25         # Shift left by (32-7)=25 to remove upper bits
    srli t3, t3, 25         # Shift right by 25 to restore position
    slli t3, t3, 16         # Shift mantissa to float32 position

    # Check for special cases: Inf / NaN (exponent is all 1s)
    addi t4, x0, 255
    beq  t2, t4, check_inf_nan

    # Check for special cases: Zero / Subnormal (exponent is all 0s)
    beq  t2, zero, check_subnormal

    # --- Normalized number ---
    slli t2, t2, 23
    or   a0, t1, t2
    or   a0, a0, t3
    j    print_float

check_inf_nan:
    bne  t3, zero, print_nan
    addi t2, x0, 255
    slli t2, t2, 23
    or   a0, t1, t2
    j    print_float

print_nan:
    addi a7, x0, 4
    la   a0, str_nan
    ecall
    j    next_case

check_subnormal:
    beq  t3, zero, handle_zero

    # Subnormal calculation
    addi t4, x0, 6
    slli t3, t3, 16
    
find_leading_one:
    blt t4, zero, skip_subnormal_norm 
    slli t5, t3, 1 
    srli t5, t5, 31 
    beq t5, zero, shift_and_next
    
    # Leading one found. Calculate new exponent: exp_new = 120 + t4
    addi t5, t4, 120
    slli t5, t5, 23
    
    # Normalize mantissa and clear implicit leading bit.
    # Replaces 'andi t3, t3, 0x7FFFFF' (keep lower 23 bits)
    addi t6, t4, 1
    sll t3, t3, t6
    slli t3, t3, 9          # Shift left by (32-23)=9
    srli t3, t3, 9          # Shift right by 9 to clear the implicit bit
    
    or a0, t1, t5
    or a0, a0, t3
    j print_float
    
shift_and_next:
    slli t3, t3, 1
    addi t4, t4, -1
    j find_leading_one

skip_subnormal_norm:
    j next_case
    
handle_zero:
    addi a0, t1, 0
    j print_float

print_float:
    addi a7, x0, 2
    ecall
    j    next_case

next_case:
    addi a7, x0, 4
    la   a0, str_newline
    ecall
    addi s0, s0, 17
    addi s2, s2, 1
    addi s1, s1, -1
    j    loop_cases

end_program:
    addi a7, x0, 10
    ecall