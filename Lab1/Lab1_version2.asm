.data
string_input: .asciiz"Input Number = "
string_Max: .asciiz"\nB = "
string_Min: .asciiz"A = "
.text
.globl main

main:

## Print & Read
	li $v0, 4
	la $a0, string_input
	syscall
	li, $v0, 5
	syscall
	add $t0, $zero, $v0
	addi $s3, $zero, 0
	
## 疭耞: 安input = 3
	beq $t0, 3, special_3
	j non_special
special_3:
	addi $s0, $zero, 2
	addi $t0, $zero, 5
	j print_ans

## 薄猵
non_special:

# 耾奔2计--->耞案计﹚穦耞计琌借计	
	addi $t1, $t0, 0 
rem_1:
	sub $t1, $t1, 2 
	beq $t1, 0, even 
	beq $t1, 1, odd 
	j rem_1 
	
odd:
	addi $t1, $t0, 2
	sub  $t0, $t0, 2
	j find_root
even:
	addi $t1, $t0, 1
	sub  $t0, $t0, 1

# т计root
find_root:
	add  $t5, $zero, $t0	# t5 = num
	addi $t2, $zero, 0	# ret = 0
	addi $t3, $zero, 1	#bit = 1
	sll  $t3, $t3, 30	#bit << 30 ---> 2 ^ 30

find_root_1:
	slt $t8, $t5, $t3
	beq $t8, 0, find_root_2
	srl $t3, $t3, 2
	j find_root_1
	
find_root_2:
	beq $t3, 0, find_root_exit
	add $t4, $t2, $t3
	slt $t8, $t5, $t4
	beq $t8, 0, find_root_2_else
	srl $t2, $t2, 1
	j find_root_2_if_else_exit
	
find_root_2_else:
	sub $t5, $t5, $t4
	srl $t2, $t2, 1
	add $t2, $t2, $t3
	
find_root_2_if_else_exit:
	srl $t3, $t3, 2
	j find_root_2

find_root_exit:
	addi $t3, $zero, 3

#耞琌借计
find_is_prime:
	slt $t8, $t2, $t3
	beq $t8, 1, find_answer
	addi $t4, $t0, 0

judge:
	beq $t4, $t3, is_not_prime
	slt $t9, $t4, $t3
	beq $t9, 0, sub_
	beq $t9, 1, temp
sub_:
	sub $t4, $t4, $t3
	j judge

temp:	
	addi $t3, $t3, 2
	j find_is_prime
	
is_not_prime:
	beq $s3, 1, bigger
	sub $t0, $t0, 2
	j find_root
bigger:
	addi $t0, $t0, 2
	j find_root

find_answer:
	beq $s3, 0, find_bigger_prime
	beq $s3, 1, print_ans
	
find_bigger_prime:
	add  $s0, $zero, $t0 
	add  $t0, $zero, $t1
	addi $s3, $s3, 1
	j find_root
	
## print answer	
print_ans:
	la $a0, string_Min
	li $v0, 4
	syscall
	add $a0, $zero, $s0
	li  $v0, 1
	syscall
	la $a0, string_Max
	li $v0, 4
	syscall
	add $a0, $zero, $t0
	li  $v0, 1
	syscall
