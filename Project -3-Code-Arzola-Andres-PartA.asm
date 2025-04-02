# Project 3 Part A

# To compute the Half Debiased Estimate HDE(x) function 
# This function reads in a floating point value, copies it to an integer register, 
# gets the excess 127 exponent of the float, and subtracts 127 from it
# Then it divides it by two, stores it in a float register, translates it to 
# its single precision value, and puts it back in an integer register
# then it prints out the value obtained

# Andres Arzola
# 11/4/2024
# List of Registers used
# $f0, $f1, $f2, $f10, $f12, $v0, $s0, $t0, $t4, $t5, $ra
.data
zeroFloat: .float 0.0
halfFloat : .float 0.5
newLine: .asciiz "\n"

.text
# For printing float output purposes, load float 0.0 into $f10
l.s $f10, zeroFloat #f10 =0.0

#syscall for reading float user input of which to find the root function of
li $v0, 6 #Load service number
syscall 		#Syscall
mfc1 $t0, $f0 #save a copy(move) of input number of which to find the root function from $f0 into $t0, t0= input number 
mfc1 $s0, $f0 ##save a copy(move) of input number of which to find  root function from $f0 into $s0, s0= input number, in order to compute HDE function with it
jal HDE  ##call the function HDE to find thehalf debiased estimate of user input s0, the HDE value serves as the first educated guess for the Newtin's Method approximation


#Print float Syscall
#To Print HDE output value
li $v0, 35		#load service number
# mtc1 $t2, $f12 #load argument register with float HDE answer stored in f1 to print
move $a0, $t2
syscall#syscall

#Exit Syscall
li $v0, 10 #Load $v0 
syscall

#Define HDE function below here
HDE:
	#Shift left to remove S and then shift right to get E
	sll $s0, $s0, 1  #Shift user input Single Precision Floating Point binary format representation to remove S
	srl $t4, $s0, 24 #t4 should contain the excess 127 exponent
	
	#Subtract excess bias from E to get unbiased
	subi $t4, $t4, 127#finally $t4 should should contain the debiased exponent
	
	#divde by 2 
	div $t5, $t4, 2 #finally $t5 should holds the half debiased exponent decimal answer of HDE function
	
	#Convert the binary value t5 to spfpbf into register f1
	mtc1 $t5, $f2		#copy(move) t5 to Co-processor 1  reg f2, f2 = holds HDE float	
	cvt.s.w $f1, $f2 	#convert f2 value to single precision into reg f1, , f1 = holds HDE float in SPFPBF
	mfc1 $t2, $f1		#copy(move) single precision value from Co-processor 1 reg. $f1 to $t2 register, t2 = HDE value spfpbf, this will be needed for Part B of 
#project 
	
	jr $ra			#return to function calling address 
	


