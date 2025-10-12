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
# Test 1 : n = 5 
    li a0, 5         
    addi a1, sp, 20   
    jal countBits_fill
    mv s0, a0         
    la a0, title1     
    addi a1, sp, 20   
    mv a2, s0         
    jal print_array

# Test 2 : n = 8 
    li a0, 8          
    mv a1, sp         
    jal countBits_fill
    mv s0, a0         
    la a0, title2     
    mv a1, sp         
    mv a2, s0        
    jal print_array

# Test 3 : n = 0 
    li a0, 0          
    mv a1, sp         
    jal countBits_fill
    mv s0, a0         
    la a0, title3     
    mv a1, sp        
    mv a2, s0         
    jal print_array

    lw ra, 44(sp)     
    addi sp, sp, 48   
    li a7, 10         
    ecall

count_leading_zeros:
    bnez a0, .L_clz_start 
    li a0, 32             
    ret                   

.L_clz_start:
    li t0, 0        
    mv t1, a0         
    lui t2, 0xFFFF0   
    and t3, t1, t2
    bnez t3, .L_clz_check8
    addi t0, t0, 16   
    slli t1, t1, 16   

.L_clz_check8:
    lui t2, 0xFF000   
    and t3, t1, t2
    bnez t3, .L_clz_check4
    addi t0, t0, 8   
    slli t1, t1, 8    

.L_clz_check4:
    lui t2, 0xF0000   
    and t3, t1, t2
    bnez t3, .L_clz_check2
    addi t0, t0, 4   
    slli t1, t1, 4    

.L_clz_check2:
    lui t2, 0xC0000   
    and t3, t1, t2
    bnez t3, .L_clz_check1
    addi t0, t0, 2    
    slli t1, t1, 2    

.L_clz_check1:
    lui t2, 0x80000   
    and t3, t1, t2
    bnez t3, .L_clz_done
    addi t0, t0, 1    

.L_clz_done:
    mv a0, t0         
    ret

countBits_fill:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)  
    sw s1, 8(sp)   
    sw s2, 4(sp)    
    sw s3, 0(sp)    
    mv s0, a0       
    mv s1, a1      
    sw zero, 0(s1)  
    li s2, 1        

.L_for_loop_start:
    bgt s2, s0, .L_for_loop_end 
    mv a0, s2      
    jal ra, count_leading_zeros
    li t0, 31
    sub t1, t0, a0  
    li t2, 1
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
    j .L_for_loop_start

.L_for_loop_end:
    addi a0, s0, 1
    lw s3, 0(sp)
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    ret

print_array:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)    
    sw s1, 4(sp)    
    sw s2, 0(sp)    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv a0, s0
    li a7, 4      
    ecall
    la a0, str_open_bracket
    li a7, 4
    ecall
    li t0, 0        # i = 0

.L_print_loop:
    bge t0, s2, .L_print_loop_end 
    slli t1, t0, 2  
    add t2, s1, t1  
    lw a0, 0(t2)    
    li a7, 1       
    ecall
    addi t3, s2, -1 # t3 = size - 1
    bge t0, t3, .L_skip_comma 
    la a0, str_comma_space
    li a7, 4
    ecall

.L_skip_comma:
    addi t0, t0, 1
    j .L_print_loop

.L_print_loop_end:
    la a0, str_close_bracket_newline
    li a7, 4
    ecall
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret