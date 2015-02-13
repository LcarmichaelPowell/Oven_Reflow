$NOLIST

;Adjust_PWM:
	mov a,Pulse   	
   	cjne a,#100,Not_Full_Power
   	setb p1.1
;	sjmp Done_PWM

Not_Full_Power:
    cjne a,#20,Turn_Off
    setb p1.1
   	lcall Small_Delay
  
   	clr p1.1
   	lcall Small_Delay
   	lcall Small_Delay
   	lcall Small_Delay
   	lcall Small_Delay
 	;sjmp Done_PWM

Turn_off:
	clr p1.1
;Done_PWM:	
	ret
	

$LIST

