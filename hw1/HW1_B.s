.data

title1: .string "Input n=5, Output:"
title2: .string "Input n=8, Output:"
title3: .string "Input n=0, Output:"
str_open_bracket: .string " ["
str_close_bracket_newline: .string "]\n"
str_comma_space: .string ", "

.text
.globl main

main:
    addi sp, sp, -48
    sw ra, 44(sp)   
      
    addi a0, zero, 5
    addi a1, sp, 20
    jal countBits_fill
    addi s0, a0, 0
    lui a0, %hi(title1)
    addi a0, a0, %lo(title1)
    addi a1, sp, 20
    addi a2, s0, 0
    jal print_array

    addi a0, zero, 8
    addi a1, sp, 0
    jal countBits_fill
    addi s0, a0, 0
    lui a0, %hi(title2)
    addi a0, a0, %lo(title2)
    addi a1, sp, 0
    addi a2, s0, 0
    jal print_array

    addi a0, zero, 0
    addi a1, sp, 0
    jal countBits_fill
    addi s0, a0, 0
    lui a0, %hi(title3)
    addi a0, a0, %lo(title3)
    addi a1, sp, 0
    addi a2, s0, 0
    jal print_array

    lw ra, 44(sp)     
    addi sp, sp, 48   
    addi a7, zero, 10
    ecall

count_leading_zeros:
    bne a0, zero, .L_clz_start
    addi a0, zero, 32
    jalr zero, ra, 0

.L_clz_start:
    addi t0, zero, 0
    addi t1, a0, 0
    lui t2, 0xFFFF0
    and t3, t1, t2
    bne t3, zero, .L_clz_check8
    addi t0, t0, 16   
    slli t1, t1, 16   

.L_clz_check8:
    lui t2, 0xFF000   
    and t3, t1, t2
    bne t3, zero, .L_clz_check4
    addi t0, t0, 8    
    slli t1, t1, 8    

.L_clz_check4:
    lui t2, 0xF0000   
    and t3, t1, t2
    bne t3, zero, .L_clz_check2
    addi t0, t0, 4    
    slli t1, t1, 4    

.L_clz_check2:
    lui t2, 0xC0000   
    and t3, t1, t2
    bne t3, zero, .L_clz_check1
    addi t0, t0, 2      
    slli t1, t1, 2      

.L_clz_check1:
    lui t2, 0x80000   
    and t3, t1, t2
    bne t3, zero, .L_clz_done
    addi t0, t0, 1      

.L_clz_done:
    addi a0, t0, 0
    jalr zero, ra, 0

countBits_fill:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)  
    sw s1, 8(sp)   
    sw s2, 4(sp)    
    sw s3, 0(sp)    
    addi s0, a0, 0
    addi s1, a1, 0
    sw zero, 0(s1)  
    addi s2, zero, 1

.L_for_loop_start:
    blt s0, s2, .L_for_loop_end
    addi a0, s2, 0
    jal ra, count_leading_zeros
    addi t0, zero, 31
    sub t1, t0, a0  
    addi t2, zero, 1
    sll s3, t2, t1 
    sub t0, s2, s3  
    slli t1, t0, 2  
    add t2, s1, t1  
    lw t3, 0(t2)    
    addi t3, t3, 1  

    slli t1, s2, 2  
    add t2, s1, t1  
    sw t3, 0(t2)    
    addi s2, s2, 1
    jal zero, .L_for_loop_start

.L_for_loop_end:
    addi a0, s0, 1
    lw s3, 0(sp)
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    jalr zero, ra, 0

print_array:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)    
    sw s1, 4(sp)    
    sw s2, 0(sp)    
    addi s0, a0, 0
    addi s1, a1, 0
    addi s2, a2, 0
    addi a0, s0, 0
    addi a7, zero, 4
    ecall
    lui a0, %hi(str_open_bracket)
    addi a0, a0, %lo(str_open_bracket)
    addi a7, zero, 4
    ecall
    addi t0, zero, 0

.L_print_loop:
    bge t0, s2, .L_print_loop_end 
    slli t1, t0, 2  
    add t2, s1, t1  
    lw a0, 0(t2)    
    addi a7, zero, 1
    ecall
    addi t3, s2, -1 
    bge t0, t3, .L_skip_comma 
    lui a0, %hi(str_comma_space)
    addi a0, a0, %lo(str_comma_space)
    addi a7, zero, 4
    ecall

.L_skip_comma:
    addi t0, t0, 1
    jal zero, .L_print_loop

.L_print_loop_end:
    lui a0, %hi(str_close_bracket_newline)
    addi a0, a0, %lo(str_close_bracket_newline)
    addi a7, zero, 4
    ecall
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jalr zero, ra, 0