# Project 3 Part B Template
# Cube root of floating point numbers in Single Precision IEEE floating point format
.data
zeroFloat: .float 0.0
threefloat: .float 3.0
hdeFloat: .float 8.0 # Hardcoded half debiased estimate of user
# input s0 (obtained from Part-A)
newLine: .asciiz "\n"

.text
  # For output purposes
  lwc1 $f10, zeroFloat # $f10 = 0.0
  lwc1 $f8, hdeFloat # $f8 = 6.0
  
  # read float syscall, the float to find the cube root of
  li $v0 6 # read float
  syscall
  #### #### ### # copy Co-proc 1 reg. $f0 to reg.
  mfc1 $t0, $f0 # | $t0 = input number
  #### #### ### # copy Co-proc 1 reg. $f0 to reg.
  mfc1 $s0, $f0 # | $s0 = input number | to calculate half debiased estimate (HDE)
  jal HDE

  # the HDE value serves as the first educated guess for the Newton's Method approximation
  # mfc1 $t2, $f8
  
  # read integer syscall, the number of iterations to run Newton's method
  li $v0 5 # read integer
  syscall
  #### #### ### # move the integer read into $t1 | $t1 = iterations
  add $t1, $v0, $zero
  
  # loop for calling Newton's method $t1 times
loop:
  jal cbrt # call cbrt to calculate the next iteration of Newton's Method
  
  mtc1 $t2, $f4 # copy answer of Newton's estimate from $t2 to $f4
  
  # print the output of the current iteration of Newton's Method as a float
  li $v0, 2 # print float
  add.s $f12, $f4, $f10 # $f12 = $f4 + $f10 | $f12 = $f4
  syscall
  
  # print a new line
  li $v0, 4 # print string
  la $a0, newLine # load new line string
  syscall
  
  # decrement iteration counter $t1
  subi $t1, $t1, 1 # $t1 = $t1 - 1
  beq $t1, $0, exit # if $t1 == 0, exit the program
  bne $t1, $0, loop # else loop again
  
exit:
# exit the program
li $v0, 10 # exit
la $a0, ($v0) # load exit
syscall

cbrt:
  mtc1 $t0, $f0 # copy original user input number to find cube root of from $t0 to Co-proc 1 reg $f0
  mtc1 $t2, $f1 # copy the educated guess approximation HDE value from $t2 to Co-proc 1 reg. $f1

  lwc1 $f2, threefloat # load 3.0 into Co-proc 1 reg. $f2

# x_n+1 = x_n - (x_n^3 - N) / (3 * x_n^2)
NewtonsMethod:
  mul.s $f5, $f1, $f1 # $f5 = $f1 * $f1, i.e. $f5 = x^2
  mul.s $f5, $f5, $f1 # $f5 = $f5 * $f1, i.e. $f5 = x^3
  sub.s $f6, $f5, $f0 # $f6 = $f5 - $f0 = x^3 - N
  div.s $f7, $f6, $f2 # $f7 = (x^3 - N) / 3
  mul.s $f4, $f1, $f1 # $f4 = x^2
  div.s $f4, $f7, $f4 # $f4 = (x^3 - N) / (3 * x^2)
  sub.s $f4, $f1, $f4 # $f4 = x - (x^3 - N) / (3 * x^2)
  
  # copy answer for the next iteration of Newton's Method from Co-proc 1 reg. $f4 to reg. $t2
  mfc1 $t2, $f4 # $t2 = answer
  
  # Netwon's Method sqrt estimate answer is in $f4
  jr $ra
 

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
	mfc1 $t2, $f1		#copy(move) single precision value from Co-processor 1 reg. $f1 to $t2 register, t2 = HDE value spfpbf
	
	jr $ra			#return to function calling address 
