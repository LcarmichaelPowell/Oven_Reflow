$NoList

; Send a character through the serial port
putchar:
    JNB TI, putchar
    CLR TI
    MOV SBUF, a
    RET

; Send a constant-zero-terminated string through the serial port
SendString:
    CLR A
    MOVC A, @A+DPTR
    JZ SSDone
    LCALL putchar
    INC DPTR
    SJMP SendString
Sendtemp: ;Sends the current temp through the Serial Port

	mov a,bcd+0
	cjne a, #0, contin
	mov a,bcd+1
	cjne a, #0, contin
	sjmp Skip2
Contin:	
	mov a, bcd+1
	anl a,#0FH
	orl a,#30H
	lcall putchar
	
	mov a, bcd+0
	swap a
	anl a,#0FH
	orl a, #30H
	lcall putchar
	
	mov a, bcd+0
	anl a,#0FH
	orl a,#30H
	lcall putchar
	
	mov a, #'\r'
	lcall putchar
	
	mov a, #'\n'
	lcall putchar
	
	lcall small_delay
	ret
	
SSDone:
skip2:
    ret


InitSerialPort:
	clr TR2 ; Disable timer 2
	mov T2CON, #30H ; RCLK=1, TCLK=1 
	mov RCAP2H, #high(T2LOAD)  
	mov RCAP2L, #low(T2LOAD)
	setb TR2 ; Enable timer 2
	mov SCON, #52H
	ret

$List