User_Temp: 
	mov a, SWA
	mov pwm, SWB
M0_0:
	cjne a, #1, M0_1
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decsoaktemp
	inc soaktemp
	ljmp M0_done
decsoaktemp:
	dec soaktemp
	ljmp M0_done
M0_1:
	cjne a, #2, M0_2
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decsoaktime
	inc soaktime
	ljmp M0_done
decsoaktime:
	dec soaktime
	ljmp M0_done
M0_2:
	cjne a, #4, M0_3
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decreflowtemp
	inc reflowtemp
	ljmp M0_done
decreflowtemp:
	dec reflowtemp
	ljmp M0_done
M0_3:
	cjne a, #8, M0_done
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decreflowtime
	inc reflowtime
	ljmp M0_done
decreflowtime:
	dec reflowtime	
M0_done:
	lcall Display_State_LCD
	ret