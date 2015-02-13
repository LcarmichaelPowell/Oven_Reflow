$NOLIST

Read_ADC_cold:
	clr CE_ADC
	mov R0,#00000001B ; Start bit:1
	lcall DO_SPI_G
	
	mov R0,#10000000B ; Single ended, read channel 0
	
	lcall DO_SPI_G
	mov a, R1 ; R1 contains bits 8 and 9
	anl a, #03H ; Make sure other bits are zero
	mov x+1,a
;	mov LEDRB, a ; Display the bits
	
	mov R0, #55H ; It doesn't matter what we transmit...
	lcall DO_SPI_G
;	mov LEDRA, R1 ; R1 contains bits 0 to 7
	mov x+0,r1
	setb CE_ADC
	ret
	
Read_ADC_hot:
	clr CE_ADC
	mov R0,#00000001B ; Start bit:1
	lcall DO_SPI_G
	
	mov R0,#10010000B ; Single ended, read channel 1
	
	lcall DO_SPI_G
	mov a, R1 ; R1 contains bits 8 and 9
	anl a, #03H ; Make sure other bits are zero
	mov x+1,a
;	mov LEDRB, a ; Display the bits
	
	mov R0, #55H ; It doesn't matter what we transmit...
	lcall DO_SPI_G
;	mov LEDRA, R1 ; R1 contains bits 0 to 7
	mov x+0,r1
	setb CE_ADC
	ret


User_Temp: 
	mov a, SWA
	
M0_0:
	cjne a, #1, M0_1
	jb KEY.3, M0_done
	lcall Button_Delay
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
	lcall Button_Delay
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decsoaktime
	mov a,soaktime
	inc soaktime
	ljmp M0_done
decsoaktime:
	dec soaktime
	ljmp M0_done
M0_2:
	cjne a, #4, M0_3
	jb KEY.3, M0_done
	lcall Button_Delay
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
	lcall Button_Delay
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decreflowtime
	inc reflowtime
	ljmp M0_done
decreflowtime:
	dec reflowtime	
M0_done:
	lcall user0
	ret
	
hot_junction:
	mov x+0,#0
	mov x+1,#0
	mov x+2,#0
	mov x+3,#0
	
	lcall Read_ADC_hot 
	
	Load_y(964)
	lcall mul32
	
	load_y(1000)
	lcall div32

	mov x+2,#0
	mov x+3,#0
	
	ret

cold_junction:

	mov x+0,#0
	mov x+1,#0
	mov x+2,#0
	mov x+3,#0
	
	
	lcall read_ADC_cold  ;put channel into x

	load_y(500)
	lcall mul32
	
	load_y(100)
	lcall mul32
	
	load_y(1023)
	lcall div32
	
	load_y(27300)
	lcall sub32
	
	load_y(100)
	lcall div32 
	
	mov cold_junk+0,x+0
	mov cold_junk+1,x+1
	mov cold_junk+2,#0
	mov cold_junk+3,#0
	
	
	ret
	
Add_temperature:
	mov y+0, cold_junk+0
	mov y+1, cold_junk+1
	mov y+2, cold_junk+2
	mov y+3, cold_junk+3
	
	lcall add32
	
	mov a,x+0
	cjne a, #0, continue
	mov a,x+1
	cjne a, #0, continue
	ret
	
	
continue:
	mov temperature,x
	
	ret
$LIST