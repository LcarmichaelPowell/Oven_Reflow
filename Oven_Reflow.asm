; Blinky_Int.asm: blinks LEDR0 of the DE2-8052 each second.
; Also generates a 2kHz signal at P0.0 using timer 0 interrupt.
; Also keeps a BCD counter using timer 2 interrupt.


CLK 		  	EQU 33333333
FREQ   		  	EQU 33333333
FREQ_0 		  	EQU 100
FREQ_2 		  	EQU 100
BAUD   		  	EQU 115200
T2LOAD 		  	EQU 65536-(FREQ/(32*BAUD))
TEN_ms_CONSTANT EQU 10000 ; 1/100Hz = 10 ms 
TIMER1_RELOAD   EQU 65536-(CLK/(12*TEN_ms_CONSTANT))
TIMER0_RELOAD 	EQU 65536-(CLK/(12*FREQ_0))
TIMER2_RELOAD 	EQU 65536-(CLK/(12*FREQ_2))
CE_ADC 		  	EQU p0.4
SCLK   		  	EQU p1.4
MOSI   		  	EQU P0.6
MISO   		  	EQU p1.0


org 0000H
	ljmp myprogram
	
org 000BH
	ljmp ISR_timer0
	
org 001BH
	ljmp ISR_timer1


DSEG at 30H
BCD_count	:  ds 1
Cnt_10ms 	:  ds 1
State_Sec	:  ds 1
State_Minute:  ds 1
Seconds  	:  ds 1
Channel     :  ds 1
Minutes  	:  ds 1
Pulse       :  ds 1
pulse2		:  ds 1
Temperature :  ds 2
State       :  ds 1
x			:  ds 4
y			:  ds 4
bcd			:  ds 5
cold_Junk   :  ds 4
hot_Junk    :  ds 4
Reflowtime  :  ds 1
ReflowTemp  :  ds 1
Cnt_10ams   :  ds 1
SoakTemp    :  ds 1
SoakTime    :  ds 1
Buzz_Timer  :  ds 1

BSEG
mf			      :  dbit 1
Buzzer_Flag_Short :  dbit 1
Buzzer_Flag_Long  :  dbit 1
Buzzer_Flag_Six   :  dbit 1
Tilt_flag		  :  dbit 1
Pulse_flag		  :  dbit 1

$include(math32.asm)
$include(LCD_Display.asm)
$include(Temp_Check.asm)
$include(PWM.asm)
$include(Delays.asm)
$include(Buzzer.asm)
$include(SPI.asm)


CSEG

; Look-up table for 7-segment displays
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H

ISR_timer0:
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
	push psw
	push acc
	push dpl
	push dph
	
	clr TF0
	cpl P0.1
	lcall tilt_sensor
	lcall Check_Pulse_State
	mov a, Cnt_10ms
	inc a
	mov Cnt_10ms, a
	
	cjne a, #100, No_reset_Cnt_10ms
	
	mov Cnt_10ms, #0
	lcall Count_Down_Buzz
	lcall Count_down_buzz_long
;State_Sec    The seconds for State Transitions
	mov a, State_Sec
	inc a
	lcall bcd2hex
	mov State_Sec, a
	
;Seconds		Can use this timer incase we decide to have a clock 
	cpl LEDRA.0
	mov a, Seconds
	add a,#1
	da a
	mov Seconds, a
	cjne a,#60H,No_reset_Cnt_10ms
	mov Seconds,#0
	
;Minutes
	mov a,Minutes
	add a,#1
	da a
	mov Minutes,a
	cjne a,#60H,No_reset_Cnt_10ms
	mov Minutes,#0
	
No_reset_Cnt_10ms:
	; Compare the variable 'pwm' against 'Cnt_10ms' and change the output pin
	; accordingly: if Cnt_10ms<=pwm then P0.0=1 else P0.0=0
	mov a, Cnt_10ms
	clr c ; Before subtraction we need to clear the 'borrow'
	subb a, pulse
	jc pwm_GT_Cnt_10ms ; After subtraction the carry is set if pwm>Cnt_10ms
	clr P1.1
	sjmp Done_PWM
pwm_GT_Cnt_10ms:
	setb P1.1
Done_PWM:	
    ; Restore saved registers from the stack in reverse order
    jb Buzzer_Flag_Short,Buzz
    jb Buzzer_Flag_Long,Buzz
    jb Buzzer_Flag_Six,Buzz
    sjmp do_nothing
   
Buzz:
    cpl p3.7
do_nothing:
	 mov a, State
	cjne a,#0,Finish12
	mov Seconds,#0

Finish12:
	lcall Update_Display			; Calls subroutine to display on Hex
	pop dph
	pop dpl
	pop acc
	pop psw
	
	reti

ISR_timer1:
	; Timer 1 in 16-bit mode doesn't have autoreload.  So it is up
	; to us to reload the timer:
    mov TH1, #high(TIMER1_RELOAD)
    mov TL1, #low(TIMER1_RELOAD)
    ; Any used register in this ISR must be saved in the stack
    push acc
    push psw ; The carry flag resides in the program status word register
    
    ; Increment the 10 ms counter.  If it is equal to 100 reset it to zero
    inc Cnt_10ams
    mov a, Cnt_10ams
    cjne a, #100, No_reset_Cnt_10ms1
    mov Cnt_10ams, #0
No_reset_Cnt_10ms1:

	; Compare the variable 'pwm' against 'Cnt_10ms' and change the output pin
	; accordingly: if Cnt_10ms<=pwm then P0.0=1 else P0.0=0
	mov a, Cnt_10ams
	clr c ; Before subtraction we need to clear the 'borrow'
	subb a, pulse2
	jc pwm_GT_Cnt_10ms1 ; After subtraction the carry is set if pwm>Cnt_10ms
	clr P0.0
	sjmp Done_PWM1
pwm_GT_Cnt_10ms1:
	setb P0.0
Done_PWM1:	
    
    ; Restore saved registers from the stack in reverse order
    pop psw
    pop acc
	reti

; Initialization for timer 1
Init_Timer1:
	;mov a, TMOD
	;anl a, #00001111B ; Set the bits for timer 1 to zero.  Keep the bits of timer 0 unchanged.
    ;orl a, #00010000B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
    ;mov TMOD, a
	clr TR1 ; Disable timer 1
	clr TF1
    mov TH1, #high(TIMER1_RELOAD)
    mov TL1, #low(TIMER1_RELOAD)
    setb TR1 ; Enable timer 0
    setb ET1 ; Enable timer 0 interrupt
    ret
		
myprogram:  ; Set inputs/outputs depending on what whoever does the board solders 
	mov SP, #7FH
	mov LEDRA,#0
	mov LEDRB,#0
	mov LEDRC,#0
	mov LEDG,#0
	clr Buzzer_flag_long
	clr Buzzer_flag_short
	clr Buzzer_flag_six
	clr Pulse_flag

	clr p0.0
	lcall Init_Timer1 
	
	mov cold_junk,#0
	
	clr p1.1
	mov State_Sec,#0
	mov State_Minute,#0
	mov Seconds,#0
	mov Minutes,#0
	mov State,#0
	mov Pulse,#0
	mov pulse2,#0
	
	lcall InitSerialPort
	
	mov Soaktime,#60    ; set to 60
	mov Reflowtime,#45  ;Set to 45 
	mov reflowtemp,#210	;set to 210 
	mov soaktemp,#150   ;set to 150

	mov BCD_count, #0
    mov Cnt_10ms, #0

	lcall INI_SPI	
	setb LCD_ON  ;All this code is to prep the LCD
  	setb LCD_blON
    clr LCD_EN  ; Default state of enable must be zero
    lcall Wait40us
    mov LCD_MOD, #0xff ; Use LCD_DATA as output port
    clr LCD_RW ;  Only writing to the LCD in this code.
	mov a, #0ch ; Display on command
	lcall LCD_command
	mov a, #38H ; 8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
	mov a, #01H ; Clear screen (Warning, very slow command!)
	lcall LCD_command
	


	orl P0MOD, #00010001b ; make all CEs outputs 
	orl P1MOD, #00010010b
    orl P3MOD, #11111111b ; make all CEs outputs 


   
    mov a, TMOD
	anl a, #11111111B ; Set the bits for timer 0 to zero.  Keep the bits of timer 1 unchanged.
    orl a, #00100001B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
    setb CE_ADC
    mov TMOD, a

	clr TR0 ; Disable timer 0
	clr TF0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    setb TR0 ; Enable timer 0
    setb ET0 ; Enable timer 0 interrupt

    lcall instruction_display
    
    setb EA  ; Enable all interrupts
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;SPI temp send is commented out, needs to be fixed. 
;Hot Junk and cold junk should add correctly,  if they dont check the magnitiude of each calculation and make sure they match up to the right decimal place
;We removed decimal places from the counter since it goes to the 100's and at that point decimals dont matter very much
;--------------------------------------------------------------------------------------------------------------------------------------------------------

M0:		
	;The pins here will need to be changed depending on what whoever made the board decided to use.
	;cpl LEDRA.0
	lcall User_Temp
	lcall cold_junction ; fix cold_junction voltage to temp
 	lcall hot_junction ; fix hot_junction voltage to temp
	lcall add_temperature
	lcall hex2bcd
	lcall current_temp 
	lcall sendtemp				; Sends temp to Serial Port
	jnb SWA.4, skip_help
	lcall instruction_display
skip_help:
	lcall waithalfsec
	lcall State_Transition
	sjmp M0
	
Update_Display: 
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;		THERE IS SOMETHING WRONG WITH THE DISPLAY
;			Internally the seconds are counting correctly but they are displaying wrong.
;
;			Update the Display for the Clock 
;
;			It also currently displays the variable I'm using for state transitions so its going to jump all over the place
;			Just plug in Seconds instead of State_Seconds and it will work
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	mov dptr, #myLUT
; Display State_Sec 0
    mov A,Seconds		
    anl A, #0FH
    movc A, @A+dptr
    mov HEX2, A
; Display State_Sec 1
	mov A,Seconds
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX3, A	
;Display Minutes 0
	mov A,Minutes
	anl A, #0FH
    movc A, @A+dptr
    mov HEX4, A
;Display Minutes 1
	mov A,Minutes
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX5, A	
    
    ret
    
INI_SPI:
	orl P0MOD,#01010000b ; Set ce , SCLK, MOSI as outputs
	orl P1MOD,#00010000b
	anl P1MOD,#11111110b ; Set MISO as input
	clr SCLK ; Mode 0,0 default
	ret

DO_SPI_G:
	mov R1,#0 ; Received byte stored in R1
	mov R2,#8 ; Loop counter (8-bits)

DO_SPI_G_LOOP:
	mov a, R0 ; Byte to write is in R0
	rlc a ; Carry flag has bit to write
	mov R0, a
	mov MOSI, c
	setb SCLK ; Transmit
	mov c, MISO ; Read received bit
	mov a, R1 ; Save received bit in R1
	rlc a
	mov R1, a
	clr SCLK
	djnz R2, DO_SPI_G_LOOP
	ret
	
	
State_Transition:  ;Function made to transition states, call it in the main when you want to check the current state/change to another   
			     ; Alternitivly move it into an interupt, im not positive how this is going to function yet.  
	lcall Current_State
	mov a, State ;Moves state into a
	
State0:  ;Functionality for state 0
	cjne a,#0,State1
	mov State_Sec,#0
	mov Seconds,#0
	mov Minutes,#0
	mov Pulse,#0
	mov pulse2,#0
	jb Key.1,Continue_in_State
	jnb Key.1,$
	mov State_Sec,#0
	mov State,#1
	lcall make_buzz_short
	lcall Not_Safe_To_Remove
	mov seconds,#0
	ljmp M0
	
State1:  ;Functionality for state 1
	cjne a,#1,State2
	mov Pulse,#100
	mov a,soaktemp
	clr c
	subb a,Temperature
	jnc State1_Abort
	mov State_Sec,#0
	mov State,#2
	lcall make_buzz_short
	ljmp M0

State1_Abort: ;Checks if 60 seconds pass before Thermocouple hits 50 Degrees
	mov a,#50
	clr c
	subb a,temperature
	jc Continue_in_State
	mov a,#60
	clr c
	subb a,State_Sec
	jnc Continue_in_State
	mov state,#5
	lcall make_buzz_long
	ljmp M0

Continue_in_State:  ;The exit state test failed, Machine will continue in current state its in the middle so that its in range of everything
	jb Key.2,Dont_Abort	; Also checks if user wants to cancel the reflow process 
	mov State,#5
Dont_Abort:
	ret
	
		 
State2: ;Functionality for state 2
	cjne a,#2,State3
	mov Pulse,#20
	mov a,soaktime
	clr c
	subb a,State_Sec
	jnc Continue_in_State
	mov State,#3
	lcall make_buzz_short
	ljmp M0

State3:	;Functionality for state 3
	cjne a,#3,State4
	mov Pulse,#100
	mov State_Sec,#0
	mov a,Reflowtemp
	clr c
	subb a,Temperature
	jnc Continue_in_State
	mov State,#4
	lcall make_buzz_short
	ljmp M0
	
State4:	;Functionality for state 4
	cjne a,#4,State5
	mov Pulse,#20
	mov a,Reflowtime
	clr c
	subb a,State_Sec
	jnc Continue_in_State
	mov State,#5
	lcall make_buzz_long
	ljmp M0
	
State5:	;Functionality for state 5  (State 5 waits to see if temperature is below 60 Degrees to see if its safe to remove 
		;All abort commands revert to state 5 so they can give the oven time to cool down before you pull it out
		;Because The Temperature sensor is not plugged in yet its going to jump from state 5 to 0 instantly
	cjne a,#5,Continue_in_State
	mov Pulse,#0
	setb Tilt_flag
	setb Pulse_flag
	mov a,Temperature
	clr c
	subb a,#60
	jnc Continue_in_State
	mov State,#0
	lcall make_buzz_six
	ljmp M0

	ret	
	
End


