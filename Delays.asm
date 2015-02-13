$NOLIST
;For a 33.33MHz clock, one cycle takes 30ns
WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
WaitQuaterSec:
	mov R2, #40
S3: mov R1, #250
S2: mov R0, #250
S1: djnz R0, S1
	djnz R1, S2
	djnz R2, S3
	ret
Small_Delay:
	mov R2, #40
L6: mov R1, #40
L5: mov R0, #140
L4: djnz R0, L4
	djnz R1, L5
	djnz R2, L6
	ret

Button_Delay:
	mov R2, #20
L9: mov R1, #20
L8: mov R0, #50
L7: djnz R0, L7
	djnz R1, L8
	djnz R2, L9
	ret
	
$LIST