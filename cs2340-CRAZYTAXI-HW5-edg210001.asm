#	Emre Guzelordu
#	edg210001
#	
#	Design of the cars were done by my girlfriend: Irie Mendez
	
# Instructions: 
#   Connect bitmap display:
#         set pixel dim to 4x4
#         set display dim to 256x512
#	  use $gp as base address
#   Connect keyboard and run
#	use a (left), d (right), space (exit)
#	all other keys are ignored



# set up some constants
# width of screen in pixels
# 256 / 4 = 64
.eqv WIDTH 64
# height of screen in pixels
.eqv HEIGHT 128

.eqv GREY	0x00807E78
.eqv LIGHTGREY	0x00D3D3D3
.eqv WHITE	0xFFFFFFFF
.eqv GREEN	0x007CFC00
.eqv DARKYELLOW	0x00805E00
.eqv YELLOW	0x00FCBA03
.eqv BLACK	0x00000000
.eqv BLUE	0x00029CD9
.eqv RED	0x00E80920
.eqv DARKBLUE	0x000A05A6

.data

		.align 2
GameOver:	.asciiz "Game Over ) ,: \n\0"

.text 
li 	$t6, 27
li 	$t7, 0
li 	$s5, 2 		#set the car at the middle 
j 	drawBackground	#draw the background
j 	sendNewCopCar

mainReturn:

j 	copCar

mainReturnTaxi:

# check for input
lw 	$t5, 0xffff0000  #t1 holds if input available
beq 	$t5, 0, mainReturn   #If no input, keep displaying
	
# process input
lw 	$s3, 0xffff0004
beq	$s3, 32, exit			# input space
beq	$s3, 97, left  			# input a
beq	$s3, 100, right			# input d

draw:
j taxi

# invalid input, ignore


#-----------------------------------------------------------------------------------------------------------------#


exit:				#exit out of the program

li 	$v0, 10
syscall


#-----------------------------------------------------------------------------------------------------------------#


left:				#if the input is "a"
beq 	$s5, 1, draw		#if the car is alredy all the way in the left dont move
addi 	$t5, $s5, 0		#if the car did move store cars last location at $t5
addi 	$s5, $s5, -1		#move the new location to $s5
j 	draw			#delete the old car and print the new car

right:				#if the input is "a"
beq $s5, 3, draw		#if the car is alredy all the way in the right dont move
addi $t5, $s5, 0		#if the car did move store cars last location at $t5
addi $s5, $s5, 1		#move the new location to $s5
j draw				#delete the old car and print the new car


#-----------------------------------------------------------------------------------------------------------------#

draw_pixel:
# s1 = address = $gp + 4*(x + y*width)
mul	$t9, $a1, WIDTH   	# y * WIDTH
add	$t9, $t9, $a0	  	# add X
mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
add	$t9, $t9, $gp	  	# add to base address
sw	$a2, ($t9)	  	# store color at memory location
jr 	$ra

#-----------------------------------------------------------------------------------------------------------------#

getColor:
mul	$t9, $a1, WIDTH   	# y * WIDTH
add	$t9, $t9, $a0	  	# add X
mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
add	$t9, $t9, $gp	  	# add to base address
lw	$s7, ($t9)
jr	$ra


#-----------------------------------------------------------------------------------------------------------------#


drawBackground:		

li 	$a0, 0			#set x to 0
li 	$a1, 0			#set y to 0

li 	$s0, 5			#How thick the grass will be
li 	$s1, 1			#side white Strips
li 	$s2, 2			#road side strips
li 	$s3, 16			#asphalt for lines with stripes
li 	$s4, 52			#asphalt for lines without stripes
li 	$t1, 8			#to take the modulo of the pixels so the stripes have the right amount of space

loop1:				#draws the background

bge 	$a1, 128, taxi		#when the whole page is covered stop painting
li 	$a0, 0			#set the x to 0 each time the loop is run
li 	$t3, 0			#counter for white stripe and withoutWhiteStripes loop
div 	$a1, $t1			#div and get the remainder from the hi reg
mfhi 	$t2
beq 	$t2, 0, drawWithWhiteLine	#if the remainder is 0 draw white line
j 	drawWithoutWhiteLine		#else draw without white line


whiteStripes:			#draws seven horizontal lines with white lines
beq 	$t3, 7, loop1		#checks how many lines have been drawn
li 	$a0, 0
j 	drawWithWhiteLine

withoutWhiteStripes:		#draws seven horizontal lines without white lines
beq 	$t3, 2, loop1		#checks how many lines have been drawn
li 	$a0, 0
j 	drawWithoutWhiteLine


#-----------------------------------------------------------------------------------------------------------------#


drawWithoutWhiteLine:

li 	$t1, 0			#set the index to 0

firstgreen:
beq 	$s0, $t1, firstWhite	#if the first 5 are colored green go draw the white
addi 	$t1, $t1, 1		#incriment $t1 by 1
li 	$a2, GREEN			#paint the green
jal 	draw_pixel			
addi 	$a0, $a0, 1		#go to the next pixel
j 	firstgreen			


firstWhite:			
li 	$a2, WHITE			#paint a white pixel
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$t1, 0

asphalt:			#paint the concrete

beq 	$s4, $t1, secondWhite
addi 	$t1, $t1, 1
li 	$a2, GREY
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	asphalt

secondWhite:			#paint a white pixel
li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$t1, 0			#set the index to 0

secondGreen:

beq 	$s0, $t1, incriment		#set the index to 0
addi 	$t1, $t1, 1		#if the first 5 are colored green go tot the next row
li 	$a2, GREEN			#paint the green
jal 	draw_pixel
addi 	$a0, $a0, 1		
j 	secondGreen			#go to the next pixel

incriment:			#goes to the next line and increments t3 by 1 
addi 	$a1, $a1, 1
addi 	$t3, $t3, 1
j 	withoutWhiteStripes		


#-----------------------------------------------------------------------------------------------------------------#


drawWithWhiteLine:

li 	$t1, 0

firstgreenStripes:		
beq 	$s0, $t1, firstWhiteStripes	#if the first 5 are colored green go draw the white
addi 	$t1, $t1, 1			#incriment $t1 by 1
li 	$a2, GREEN			#paint it green
jal 	draw_pixel			
addi 	$a0, $a0, 1			#go to the next pixel
j 	firstgreenStripes

firstWhiteStripes:

li 	$a2, WHITE			#paint the white stripe
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$t1, 0

asphaltStripesOne:			#paint the asphalt

beq 	$s3, $t1, secondWhiteStripes
addi 	$t1, $t1, 1
li 	$a2, GREY
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	asphaltStripesOne

secondWhiteStripes:			#paint the second white stripe

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$t1, 0

asphaltStripesTwo:			#paint the asphalt again

beq 	$s3, $t1, thirdWhiteStripes
addi 	$t1, $t1, 1
li 	$a2, GREY
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	asphaltStripesTwo

thirdWhiteStripes:			#paint the third white stripe

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$t1, 0

asphaltStripesThree:		#paint the asphalt again

beq 	$s3, $t1, fourthWhiteStripes
addi 	$t1, $t1, 1
li 	$a2, GREY
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	asphaltStripesThree

fourthWhiteStripes:		#paint the fourth white stripe

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1
li 	$t1, 0

secondGreenStripes:

beq 	$s0, $t1, incrimentStripe	#if the first 5 are colored green go draw the white
addi 	$t1, $t1, 1		#incriment $t1 by 1
li 	$a2, GREEN	
jal 	draw_pixel			
addi 	$a0, $a0, 1
j 	secondGreenStripes

incrimentStripe:		#incriment the y by 1
addi 	$a1, $a1, 1
addi 	$t3, $t3, 1
j 	whiteStripes



#-----------------------------------------------------------------------------------------------------------------#



deleteTaxi:			#deletes the taxi before drawing the new one

addi 	$t0, $a0, 0		#set the cordinitas to start on
addi 	$t1, $a1, 30
addi 	$t3, $a1, 0

outerLoop:			#go through line by line delete each horiontal strip

beq 	$t1, $a1, return
addi 	$a0, $t0, -1
addi 	$t2, $a0, 14

innerLoop:			#paint it back to gray
beq 	$t2, $a0, outerLoopFinish
li 	$a2, GREY
jal 	draw_pixel
addi	 $a0, $a0, 1

j 	innerLoop

outerLoopFinish:
addi 	$a1, $a1, 1		#incriment the y by 1
j 	outerLoop

return:				#return back and draw a taxi
addi 	$a0, $t0, 0
addi 	$a1, $t3, 0
j 	drawTaxi

taxi:				#figures out which lane the taxi is on to delete it
beq 	$t5, 3, thirdLaneDelete
beq 	$t5, 2, secondLaneDelete

firstlaneDelete:		#delete on the first collum

li 	$a0, 8
li 	$a1, 80
j 	deleteTaxi

secondLaneDelete:		#delete on the second collum

li 	$a0, 26
li 	$a1, 80
j 	deleteTaxi

thirdLaneDelete:		#delete on the third collum

li 	$a0, 44
li 	$a1, 80
j 	deleteTaxi


#-----------------------------------------------------------------------------------------------------------------#


drawTaxi:			#draw the taxi after deleting the old one

beq 	$s5, 3, thirdLane
beq 	$s5, 2, secondLane

firstlane:			#draws taxi on the first lane

li 	$a0, 8
li 	$a1, 80
j 	firstTaxiLine

secondLane:			#draws taxi on the second lane

li 	$a0, 26
li 	$a1, 80
j 	firstTaxiLine

thirdLane:			#draws taxi on the third lane

li 	$a0, 44
li 	$a1, 80
j 	firstTaxiLine


#-----------------------------------------------------------------------------------------------------------------#


firstTaxiLine:			#now till the 

addi 	$a0, $a0, 1
addi 	$t0, $a0, 10
li 	$t3, 0

taxiLoop1:

beq 	$a0, $t0, secondTaxiLineRepeat
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop1



secondTaxiLineRepeat:

beq 	$t3, 3, thirdTaxiLine
addi 	$t3, $t3, 1



secondTaxiLine:

addi 	$a0, $a0, -11
addi 	$a1, $a1, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, DARKYELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

addi	$t0, $a0, 6

taxiLoop2:

beq 	$a0, $t0, taxiLoop2Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop2

taxiLoop2Out:

li 	$a2, DARKYELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel


j 	secondTaxiLineRepeat

thirdTaxiLine:

addi 	$a0, $a0, -11
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 10

taxiLoop3:

beq 	$a0, $t0, taxiLoop3Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop3


taxiLoop3Out:

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

fourthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop4:

beq 	$a0, $t0, taxiLoop4Out
li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop4

taxiLoop4Out:

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 5

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1


fifthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 8


taxiLoop5:

beq 	$a0, $t0, taxiLoop5Out
li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop5

taxiLoop5Out:

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

sixthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

addi 	$t0, $a0, 6


taxiLoop6:

beq 	$a0, $t0, taxiLoop6Out
li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop6

taxiLoop6Out:

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

seventhTaxiLine:



addi 	$a0, $a0, -13
addi 	$a1, $a1, 1
addi 	$t0, $a0, 14


taxiLoop7:

beq 	$a0, $t0, eighthTaxiLine
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop7

eighthTaxiLine:

addi 	$a0, $a0, -13
addi 	$a1, $a1, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 4


taxiLoop8:

beq 	$a0, $t0, taxiLoop8Out
li 	$a2, DARKYELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop8

taxiLoop8Out:

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 3

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

ninthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop9:

beq 	$a0, $t0, taxiLoop9Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop9

taxiLoop9Out:


li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

tenthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop10:

beq 	$a0, $t0, taxiLoop10Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop10

taxiLoop10Out:

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

eleventhTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop11:

beq 	$a0, $t0, taxiLoop11Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop11

taxiLoop11Out:

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

twelthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1


li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

addi 	$t0, $a0, 8

taxiLoop12:

beq 	$a0, $t0, taxiLoop12Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop12

taxiLoop12Out:

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

tirteenthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

addi 	$t0, $a0, 8

taxiLoop13:

beq 	$a0, $t0, taxiLoop13Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop13

taxiLoop13Out:

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1


li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

fourteenthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop14:

beq 	$a0, $t0, taxiLoop14Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop14

taxiLoop14Out:


li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1


fifteenthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop15:

beq 	$a0, $t0, taxiLoop15Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop15

taxiLoop15Out:

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

sixteenthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop16:

beq 	$a0, $t0, taxiLoop16Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop16

taxiLoop16Out:

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1


seventeenTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 4


taxiLoop17:

beq 	$a0, $t0, taxiLoop17Out
li 	$a2, DARKYELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop17

taxiLoop17Out:

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 4

li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1


addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

addi	$t0, $a0, 12

taxiLoop18:

beq 	$a0, $t0, nineteenthTaxiLine
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop18

nineteenthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

taxiLoop19:

beq 	$a0, $t0, twentythTaxiLine
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop19


twentythTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 6


taxiLoop20:

beq 	$a0, $t0, taxiLoop20Out
li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop20

taxiLoop20Out:

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

twentystTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 8


taxiLoop21:

beq 	$a0, $t0, taxiLoop21Out
li 	$a2, BLUE
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop21

taxiLoop21Out:

li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

twentyndTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 10

taxiLoop22:

beq 	$a0, $t0, taxiLoop22Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop22

taxiLoop22Out:

li 	$a2, BLACK
jal	draw_pixel
addi 	$a0, $a0, 1

twentyrdTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 10

taxiLoop23:

beq 	$a0, $t0, taxiLoop23Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop23

taxiLoop23Out:

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1

twentyfourthTaxiLine:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, 1
addi 	$t0, $a0, 10

taxiLoop24:

beq 	$a0, $t0, taxiLoop24Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop24

taxiLoop24Out:

li 	$a2, BLACK
jal 	draw_pixel
addi 	$a0, $a0, -12
addi 	$a1, $a1, 1
addi 	$a0, $a0, 1
addi 	$t0, $a0, 12

taxiLoop25:

beq 	$a0, $t0, texiLoop26Out
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop25

texiLoop26Out:

addi 	$a0, $a0, -12
addi 	$a1, $a1, 1
addi 	$a0, $a0, 1
addi 	$t0, $a0, 10

taxiLoop26:

beq 	$a0, $t0, mainReturn
li 	$a2, YELLOW
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	taxiLoop26

#-----------------------------------------------------------------------------------------------------------------#

deleteCopCar:			#deletes cop car before starting to draw the new one

addi 	$a0, $t6, 0
addi 	$a1, $t7, -2

addi 	$t0, $a0, 0		#set the cordinitas to start on
addi 	$t1, $a1, 25
addi 	$t3, $a1, 0

outerLoopCop:

beq 	$a1, $t1, returnCop
addi 	$a0, $t0, -1
addi 	$t2, $a0, 12


innerLoopCop:			#paint it back to gray
beq 	$t2, $a0, outerLoopFinishCop
j checkCollison
returnCopLoop21:
li 	$a2, GREY
jal 	draw_pixel
addi	$a0, $a0, 1

j 	innerLoopCop

outerLoopFinishCop:
addi 	$a1, $a1, 1		#incriment the y by 1
j 	outerLoopCop

returnCop:			#return back and draw a copcar
addi 	$a0, $t0, 0
addi 	$a1, $t3, 1
j back



#-----------------------------------------------------------------------------------------------------------------#

firstCop:			

li $t7, 0
addi	$t7, $t7, 1

copCar: 				#depending on what the case is draws the cop car in a diffrent location

li	$v0, 32				
li	$a0, 30
syscall 


beq 	$a1, 160, sendNewCopCar		#if the cop is out of the display send another cop
beq	$t7, 0, firstCop


addi $a1, $t7, 0
addi $a0, $t6, 10

scootCopCarDown:			#scoots cop car down by two pixels

addi	$t7, $t7, 2


j deleteCopCar

back:

j drawCopCar

#-----------------------------------------------------------------------------------------------------------------#

sendNewCopCar:				#get a random number and send a cop car int the lane of that random number

li 	$v0, 42				#get the random number
li	$a1, 4
syscall 

beq 	$a0, 0, sendNewCopCar		#if 0 choose again
beq 	$a0, 4, sendNewCopCar		#if 4 choose again
addi 	$s6, $a0, 0			#put the number in $s6 so you can keep using $a0

beq	$s6, 2, SecondLaneCop		#depending on the number sned the car to that lane

beq	$s6, 3, ThirdLaneCop

firstLaneCop:				#set the corinates then send the cop car

li 	$a0, 9
li	$a1, -20
j drawCopCar

SecondLaneCop:				#set the corinates then send the cop car

li 	$a0, 27
li	$a1, -20
j drawCopCar

ThirdLaneCop:				#set the corinates then send the cop car

li 	$a0, 45
li	$a1, -20


#-----------------------------------------------------------------------------------------------------------------#

drawCopCar:				#draw the cop car

addi 	$t6, $a0, 0
addi 	$t7, $a1, 0

copCarLine1:

addi 	$t0, $a0, 9
addi 	$a0, $a0, 1

copLoop1:

beq	$t0, $a0, copCarLine2
li 	$a2, WHITE
jal 	draw_pixel
addi 	$a0, $a0, 1
j 	copLoop1

copCarLine2:
addi	$a1, $a1, 1
addi	$a0, $a0, -9
addi 	$t0, $a0, 10

copLoop2:

beq 	$t0, $a0, copCarLine3
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j	copLoop2

copCarLine3:

li $t3, 0

copLoop3Repeat:

beq $t3, 2, copCarLine5

addi	$a1, $a1, 1
addi	$a0, $a0, -10

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

addi 	$t0, $a0, 8

copLoop4:

beq 	$t0, $a0, copLoop4Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j	copLoop4

copLoop4Out:

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$t3, $t3, 1
j 	copLoop3Repeat

copCarLine5:

addi	$a1, $a1, 1
addi	$a0, $a0, -10


li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$t0, $a0, 6

copLoop5:

beq $a0, $t0, copLoop5Out
li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1
j copLoop5

copLoop5Out:

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

copCarLine6:

addi	$a1, $a1, 1
addi	$a0, $a0, -10


li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$t0, $a0, 4

copLoop6:

beq 	$a0, $t0, copLoop6Out
li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop6

copLoop6Out:

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$a1, $a1, 1
addi	$t3, $a1, 2

copCarLine7:

beq 	$a1, $t3, copCarLine8
addi	$a0, $a0, -10
addi 	$t0, $a0, 10


copLoop7:

beq 	$a0, $t0, copLoop7Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop7

copLoop7Out:
addi $a1, $a1, 1
j	copCarLine7

copCarLine8:

addi	$a0, $a0, -10

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, LIGHTGREY
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, LIGHTGREY
jal	draw_pixel
addi	$a0, $a0, 1


li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, -9

copCarLine9:

addi	$a1, $a1, 1


li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1
addi	$t0, $a0, 6

copLoop9:

beq 	$a0, $t0, copLoop9Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop9

copLoop9Out:

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$a1, $a1, 1
addi	$a0, $a0, -10


copCarLine10:

addi	$t0, $a0, 10

copLoop10:
beq 	$a0, $t0, copLoop10Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop10

copLoop10Out:

addi 	$a1, $a1, 1
addi	$a0, $a0, -10


copCarLine11:

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, RED
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, DARKBLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, RED
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, DARKBLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, RED
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, DARKBLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

addi 	$a1, $a1, 1
addi	$a0, $a0, -10


copCarLine12:

addi	$t0, $a0, 10

copLoop12:
beq 	$a0, $t0, copLoop12Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop12

copLoop12Out:

addi 	$a1, $a1, 1
addi	$a0, $a0, -10
addi	$t3, $a1, 2


copCarLine13:

beq 	$a1, $t3, copCarLine14

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

addi	$t0, $a0, 6

copLoop13:

beq	$t0, $a0, copLoop13Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j copLoop13


copLoop13Out:

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a1, $a1, 1
addi	$a0, $a0, -9
j	copCarLine13


copCarLine14:

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, LIGHTGREY
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, LIGHTGREY
jal	draw_pixel
addi	$a0, $a0, 1


li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, -10

copCarLine15:

addi	$a1, $a1, 1
addi	$t0, $a0, 12

copLoop15:
beq 	$a0, $t0, copLoop15Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop15

copLoop15Out:

addi 	$a1, $a1, 1
addi	$a0, $a0, -11

copCarLine16:

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
addi	$t0, $a0, 4

copLoop16:

beq $t0, $a0, copLoop16Out
li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop16

copLoop16Out:

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

addi 	$a1, $a1, 1
addi	$a0, $a0, -10

copCarLine17:

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

addi	$t0, $a0, 6

copLoop17:

beq $t0, $a0, copLoop17Out
li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop17

copLoop17Out:

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$a1, $a1, 1
addi	$a0, $a0, -10

copCarLine18:

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

addi	$t0, $a0, 4

copLoop18:

beq $t0, $a0, copLoop18Out
li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop18

copLoop18Out:

li	$a2, BLUE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$a1, $a1, 1
addi	$a0, $a0, -10

copCarLine19:

li	$a2, BLACK
jal	draw_pixel
addi	$a0, $a0, 1

addi	$t0, $a0, 8

copLoop19:

beq $t0, $a0, copLoop19Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop19

copLoop19Out:

li	$a2, BLACK
jal	draw_pixel
addi 	$a1, $a1, 1
addi	$a0, $a0, -9
addi 	$t3, $a1, 2

copCarline20:

beq 	$t3, $a1, copCarline21 

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, LIGHTGREY
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$t0, $a0, 4

copLoop20:

beq 	$t0, $a0, copLoop20Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop20

copLoop20Out:

li	$a2, LIGHTGREY
jal	draw_pixel
addi	$a0, $a0, 1
addi 	$t0, $a0, 4

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1

li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
addi	$a1, $a1, 1
addi	$a0, $a0, -10
j 	copCarline20


copCarline21:
addi	$a0, $a0, 1
addi	$t0, $a0, 8

copLoop21:

beq 	$t0, $a0, copLoop21Out
li	$a2, WHITE
jal	draw_pixel
addi	$a0, $a0, 1
j 	copLoop21

copLoop21Out:

j 	mainReturnTaxi

checkCollison:

bgt	$a1, 118, returnCopLoop21	#checks for collision by checking if its in the screen
blt	$a1, 60, returnCopLoop21	
jal 	getColor			#get color and check if its yellow
beq	$s7, YELLOW, exitFailure	#if yellow exit bc if failure
j	returnCopLoop21


exitFailure:
li	$a0, 0
li	$a1, 0
li	$t0, 64
li	$t1, 128
j 	paintTheScreenRed

paintTheScreenRed:			#paints the screen red letting the people know the game is over

li	$v0, 32
li	$a0, 30
syscall

beq 	$a1, $t1, exit			#when done painting exit the program
li	$a0, 0

insideRedLoop:			
beq 	$a0, $t1, insideRedLoopOut
li	$a2, RED
jal	draw_pixel
addi	$a0, $a0, 1
j	insideRedLoop

insideRedLoopOut:

addi	$a1, $a1, 1			#increment $a1 by 1
j paintTheScreenRed
