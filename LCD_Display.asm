$NOLIST
$MODDE2

Wait40us:
	mov R0, #149
	
X1: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, X1 ; 9 machine cycles-> 9*30ns*149=40us
    ret

LCD_command:
	mov	LCD_DATA, A
	clr	LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us

LCD_put:
	mov	LCD_DATA, A
	setb LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us
	
Current_State:

	lcall Wait40us
	djnz R1, Current_State

	; Move to first column of first row	
	mov a, #80H
	lcall LCD_command
	
	
	;---------------EDITZ
	
	mov a, state
	
	cjne a, #0, state1display
	mov a, #'O'
	lcall LCD_put
	mov a, #'F'
	lcall LCD_put
	mov a, #'F'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
    ret
State1Display:
	cjne a, #1, state2display
	mov a, #'R'
	lcall LCD_put
	mov a, #'A'
	lcall LCD_put
	mov a, #'M'
	lcall LCD_put
	mov a, #'P'
	lcall LCD_put
	mov a, #'('
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #')'
	lcall LCD_put
	ret
	
State2Display:
	cjne a, #2, state3display
	mov a, #'S'
	lcall LCD_put
	mov a, #'O'
	lcall LCD_put
	mov a, #'A'
	lcall LCD_put
	mov a, #'K'
	lcall LCD_put
	ret
	
State3Display:
	cjne a, #3, state4display
	mov a, #'R'
	lcall LCD_put
	mov a, #'A'
	lcall LCD_put
	mov a, #'M'
	lcall LCD_put
	mov a, #'P'
	lcall LCD_put
	mov a, #'('
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #')'
	lcall LCD_put
	ret
	
State4Display:
	cjne a, #4, state5display
	mov a, #'R'
	lcall LCD_put
	mov a, #'E'
	lcall LCD_put
	mov a, #'F'
	lcall LCD_put
	mov a, #'L'
	lcall LCD_put
	mov a, #'O'
	lcall LCD_put
	mov a, #'W'
	lcall LCD_put
	ret
	
State5Display:
	mov a, #'C'
	lcall LCD_put
	mov a, #'O'
	lcall LCD_put
	mov a, #'O'
	lcall LCD_put
	mov a, #'L'
	lcall LCD_put
	mov a, #'I'
	lcall LCD_put
	mov a, #'N'
	lcall LCD_put
	mov a, #'G'
	lcall LCD_put
	ret
	
;-------------END EDITZ------------------------


    
Safe_To_Remove:

	lcall Wait40us
	djnz R1, Safe_To_Remove

	; Move to first column of first row	
	mov a, #80H
	lcall LCD_command
		
	; Display letter A
	mov a, #'S'
	lcall LCD_put
	
	mov a, #'a'
	lcall LCD_put
	
	mov a, #'f'
	lcall LCD_put
	
	mov a, #'e'
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #'t'
	lcall LCD_put
	
	mov a, #'o'
	lcall LCD_put

	mov a, #' '
	lcall LCD_put
	
	mov a, #'G'
	lcall LCD_put
	
	mov a, #'r'
	lcall LCD_put
	
	mov a, #'a'
	lcall LCD_put
	
	mov a, #'b'
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
    ret
    
Not_Safe_To_Remove:

	lcall Wait40us
	djnz R1, Not_Safe_To_Remove

	; Move to first column of first row	
	mov a, #80H
	lcall LCD_command
		
	; Display letter A
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put

	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	
	
    ret
  
Display_BCD:  ;Display_BCD numbers on the Hex keys
	mov dptr, #myLUT

	mov r0,x+2
	cjne r0,#0,Turn_on
	sjmp not_100
Turn_on:
	mov a, Temperature+2
	anl a, #0FH
	movc a, @a+dptr
	mov HEX6, a
	sjmp Continue_Dude
	
Not_100:
	mov Hex6,#1111111B
	
Continue_dude:	
	mov a, Temperature+1
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX5, a
	
	mov a, Temperature+1
	anl a, #0FH
	movc a, @a+dptr
	mov HEX4, a

	mov a, Temperature+0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX3, a
	
	mov a, Temperature+0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX2, a
	
	ret

	
user0:	
	;load a with swithes to check what the user wants to set
	mov a, SWA	
	cjne a, #01H, user1
	
	mov a, #0A8H
	lcall LCD_command
	
	;------Display the User Settable Soak Temp
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	mov x+0, soaktemp
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret
	
user1:
	mov a, SWA
	cjne a, #02H, user2
	
	;----move to second line of LCD_Display
	mov a, #0A8H
	lcall LCD_command
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	mov x+0, soaktime
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret	

user2:
	mov a, SWA
	cjne a, #04H, user3
	
	;----move to second line of LCD_Display
	mov a, #0A8H
	lcall LCD_command
	
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	
	mov x+0, reflowtemp
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret	
	
user3:
	mov a, SWA
	cjne a, #08H, done
	
	;----move to second line of LCD_Display
	mov a, #0A8H
	lcall LCD_command	
	
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	
	mov x+0, reflowtime
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret
	
done:
;clear bottom line
	mov a, #0A8H
	lcall LCD_command

clear_top:
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put	
	ret	
	
Current_Temp:
	lcall Wait40us
	djnz R1, Current_Temp

	; Move to first column of first row	
	mov a, #89H
	lcall LCD_command
	mov dptr, #MyLUT
	
	mov r0,bcd+1
	cjne r0,#0,Turn_ona
	sjmp not_100a
Turn_ona:
	mov a, bcd+1
	anl a,#0FH
	orl a,#30H
	lcall LCD_PUT
	
	sjmp Continue_Dudea
	
Not_100a:
	mov a,#' '
	lcall LCD_put
	
Continue_dudea:	
			
	
	mov a, bcd+0
	swap a
	anl a,#0FH
	orl a, #30H
	lcall LCD_PUt
	
	mov a, bcd+0
	anl a,#0FH
	orl a,#30H
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put

	mov a, #'C'
	lcall LCD_put
	

    ret	 
    
    Instruction_Display:
	
	mov a, #80H
	lcall LCD_command
	
	mov a, #'H'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'u'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'u'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	mov a, #0A8H
	lcall LCD_command

	mov a, #'c'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put

	mov a, #0B4H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
 	sjmp Switch0
 	
littlejump:
	ljmp Instruction_Display
	
Switch0:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'c'
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #'0'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'s'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump2


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp Switch1
littlejump2:
	ljmp Switch0
	
Switch1:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'c'
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'s'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump3


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp Switch2
littlejump3:
	ljmp Switch1

Switch2:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'c'
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #'2'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump4


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp Switch3
littlejump4:
	ljmp Switch2
	
Switch3:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'c'
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #'3'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump5


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp key1
littlejump5:
	ljmp Switch3

key1:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'K'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'v'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'c'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump6


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp Key2
littlejump6:
	ljmp Key1
	
Key2:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'K'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'2'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'b'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'v'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'c'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B4H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump7


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp Key3_1
littlejump7:
	ljmp Key2
	
Key3_1:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'I'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'W'
	lcall LCD_put
	mov a, #'A'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	mov a, #'7'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'K'
	lcall LCD_put
	mov a, #'3'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'c'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	
	
	mov a, #0B6H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B6H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall WaitQuaterSec
		
	jb Key.1, littlejump8


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp Key3_2
littlejump8:
	ljmp Key3_1
	
Key3_2:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'I'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'W'
	lcall LCD_put
	mov a, #'A'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	mov a, #'7'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'K'
	lcall LCD_put
	mov a, #'3'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'c'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	
	
	mov a, #0B6H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B6H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	

	lcall WaitQuaterSec
		
	jb Key.1, littlejump9


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
	sjmp help
littlejump9:
	ljmp Key3_2
	
help:
 	mov a, #80H
	lcall LCD_command
	
	mov a, #'T'
	lcall LCD_put
	mov a, #'u'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'c'
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'4'
	lcall LCD_put
	
 	mov a, #0A8H
	lcall LCD_command

	mov a, #'t'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put

	
	mov a, #0B6H
	lcall LCD_command
	
	mov a, #'k'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	
	lcall WaitQuaterSec
	
	mov a, #0B6H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	

	lcall WaitQuaterSec
		
	jb Key.1, littlejump10


    mov a, #080H
	lcall LCD_command
 	lcall clear_top
 	lcall done
 	lcall WaitQuaterSec
	ret
littlejump10:
	ljmp help

   
end
$LIST