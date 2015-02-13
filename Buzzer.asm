$NoList


Make_Buzz_short:
	setb Buzzer_Flag_short
	ret
	
Count_Down_Buzz:
	jnb Buzzer_Flag_short, Count_down_buzz_long
	mov a, Buzz_timer
	add a,#1
	mov Buzz_timer,a
	;cpl p0.0 ; Set this to whatever pin the buzzer is on
	cjne a,#5, Not_Done
	clr Buzzer_Flag_short
	mov Buzz_Timer,#0

Not_Done:
	ret
	
Make_Buzz_long:
	setb Buzzer_Flag_long
	ret
	
Count_Down_Buzz_long:
	jnb Buzzer_Flag_long, not_done
	mov a, Buzz_timer
 	add a,#1
	mov Buzz_timer,a
	;cpl p0.0 ; Set this to whatever pin the buzzer is on
	cjne a,#20, Not_Done
	clr Buzzer_Flag_long
	mov Buzz_Timer,#0	
	ret

Make_Buzz_six:
	setb Buzzer_Flag_six
	lcall WaitHalfSec
	
	clr Buzzer_Flag_six
	lcall WaitHalfSec
	
	setb Buzzer_Flag_six
	lcall WaitHalfSec
	
	clr Buzzer_Flag_six
	lcall WaitHalfSec
	
	setb Buzzer_Flag_six
	lcall WaitHalfSec
	
	clr Buzzer_Flag_six
	lcall WaitHalfSec
	
	setb Buzzer_Flag_six
	lcall WaitHalfSec
	
	clr Buzzer_Flag_six
	lcall WaitHalfSec
	
	setb Buzzer_Flag_six
	lcall WaitHalfSec
	
	clr Buzzer_Flag_six
	lcall WaitHalfSec
	
	setb Buzzer_Flag_six
	lcall WaitHalfSec
	
	clr Buzzer_Flag_six
	lcall WaitHalfSec
	
	ret
	
;----------------------------------------------------------------------------------------------------------------------------------
;Tilt sensor 
;Code had no where else to go
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
Tilt_Sensor:
	jb p0.1, Skip_this_thing
	clr Pulse_flag

Skip_this_thing:
	ret

Check_Pulse_state:
	jnb SWA.5, Float_on_man
	mov pulse2,#20
	sjmp Leave_this

	
float_on_man:
	jb Pulse_flag, keep_going
	mov pulse2,#0
	
Keep_going:
	jnb Pulse_flag, Leave_this
	mov pulse2,#8
	
Leave_this:
	ret
	
$List