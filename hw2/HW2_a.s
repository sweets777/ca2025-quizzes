.data

test_cases:
    .string "0011111110000000"
    .string "1011111110000000"
    .string "0000000000001111"
case_count:
    .word 3

str_case:   .string "Case "
str_colon:  .string ": "
str_arrow:  .string " -> "
str_newline:.string "\n"
str_nan:    .string "NaN"

.text
.globl main

main:
    lui s0, %hi(test_cases)
    addi s0, s0, %lo(test_cases)
    lui s1, %hi(case_count)
    addi s1, s1, %lo(case_count)
    lw s1, 0(s1)
    addi s2, x0, 1

loop_cases:
    beq s1, zero, end_program
    addi a7, x0, 4
    lui a0, %hi(str_case)
    addi a0, a0, %lo(str_case)
    ecall
    addi a7, x0, 1
    addi a0, s2, 0
    ecall
    addi a7, x0, 4
    lui a0, %hi(str_colon)
    addi a0, a0, %lo(str_colon)
    ecall
    addi a7, x0, 4
    addi a0, s0, 0
    ecall
    addi a7, x0, 4
    lui a0, %hi(str_arrow)
    addi a0, a0, %lo(str_arrow)
    ecall

    addi a1, s0, 0
    add t0, x0, x0
    add t1, x0, x0
    addi t2, x0, 16

parse_loop:
    beq t1, t2, parse_done
    lb t3, 0(a1)
    slli t0, t0, 1
    addi a1, a1, 1
    addi t1, t1, 1
    addi t4, x0, 49
    bne t3, t4, parse_loop
    ori t0, t0, 1
    jal zero, parse_loop

parse_done:
    srli t1, t0, 15
    slli t1, t1, 31
    slli t2, t0, 17
    srli t2, t2, 24
    slli t3, t0, 25
    srli t3, t3, 25
    
    addi t4, x0, 255
    beq t2, t4, check_inf_nan
    beq t2, zero, check_subnormal

    slli t2, t2, 23
    slli t3, t3, 16
    or a0, t1, t2
    or a0, a0, t3
    jal zero, print_float

check_inf_nan:
    bne t3, zero, print_nan
    addi t2, x0, 255
    slli t2, t2, 23
    or a0, t1, t2
    jal zero, print_float

print_nan:
    addi a7, x0, 4
    lui a0, %hi(str_nan)
    addi a0, a0, %lo(str_nan)
    ecall
    jal zero, next_case

check_subnormal:
    beq t3, zero, handle_zero
    slli t3, t3, 16
    or a0, t1, t3
    jal zero, print_float

handle_zero:
    addi a0, t1, 0
    jal zero, print_float

print_float:
    addi a7, x0, 2
    ecall
    jal zero, next_case

next_case:
    addi a7, x0, 4
    lui a0, %hi(str_newline)
    addi a0, a0, %lo(str_newline)
    ecall
    addi s0, s0, 17
    addi s2, s2, 1
    addi s1, s1, -1
    jal zero, loop_cases

end_program:
    addi a7, x0, 10
    ecall