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
	
## 特殊判斷: 假如input = 3
	beq $t0, 3, special_3
	j non_special
special_3:
	addi $s0, $zero, 2
	addi $t0, $zero, 5
	j print_ans

## 一般情況
non_special:

# 濾掉2的倍數--->判斷奇偶數，一定只會判斷奇數是否質數	
	rem  $t1, $t0, 2
	beq  $t1, $zero, even
	addi $t1, $t0, 2
	sub  $t0, $t0, 2
	j find_root
even:
	addi $t1, $t0, 1
	sub  $t0, $t0, 1

# 找數的root
find_root:
	add  $t5, $zero, $t0	# t5 = num
	addi $t2, $zero, 0	# ret = 0
	addi $t3, $zero, 1	#bit = 1
	sll  $t3, $t3, 30	#bit << 30 ---> 2 ^ 30

find_root_1:
	ble $t3, $t5, find_root_2	# if t5 > t3 branch to find_root_2 num>bit
	srl $t3, $t3, 2
	j find_root_1
	
find_root_2:
	beq $t3, 0, find_root_exit
	add $t4, $t2, $t3
	ble $t4, $t5, find_root_2_else
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

#判斷是否為質數
find_is_prime:
	bgt $t3, $t2, find_answer
	rem $t4, $t0, $t3
	beq $t4, $zero, is_not_prime 
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
