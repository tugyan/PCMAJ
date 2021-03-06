DUTY_CYCLE_HI DATA 2
DUTY_CYCLE_LO DATA 3
MOT1_FW BIT P0.0
MOT1_BW BIT P0.1
MOT2_FW BIT P0.2
MOT2_BW BIT P0.3
ISX_AXIS BIT 0
IS_FW BIT 1

ORG 0
LJMP MAIN

ORG 001BH
DUTY_CYCLE_END:
	LJMP CLEAR_PWM

ORG 00ABH
MAIN:
	MOV IE, #10001000b
	MOV DUTY_CYCLE_HI, #088h
	MOV DUTY_CYCLE_LO, #01Dh
	MOV TMOD, #00010000b
	SETB IS_FW
	SETB ISX_AXIS

	ANL P2, #0F0h	;Clear pins so that first cycle will be empty
	ACALL LOOP
	MOV DUTY_CYCLE_HI, #0E5h
	MOV DUTY_CYCLE_LO, #0F6h
	ACALL LOOP
	SJMP $
BWX:	
	JNB ISX_AXIS, BWY	;Check if we will send x axis
	JB IS_FW, FWX	;Check if we will turn forward or backwards
	SETB MOT1_BW
	CLR MOT1_FW
	RET
FWX:
	SETB MOT1_FW
	CLR MOT1_BW
	RET

BWY: 	JB IS_FW, FWY
	SETB MOT2_BW
	CLR MOT2_FW
	RET
FWY:
	SETB MOT2_FW
	CLR MOT2_BW
	
	RET

CLEAR_PWM:
	JNB ISX_AXIS, CLEAR_FWY
	CLR MOT1_BW
	CLR MOT1_FW
	SJMP NEXT_CYCLE

CLEAR_FWY:
	CLR MOT2_FW
	CLR MOT2_BW
	SJMP NEXT_CYCLE

NEXT_CYCLE:
	CLR TR1
	MOV TH1, DUTY_CYCLE_HI
	MOV TL1, DUTY_CYCLE_LO
	RETI
LOOP:
	MOV TH1, DUTY_CYCLE_HI
	MOV TL1, DUTY_CYCLE_LO
	ACALL BWX
	SETB TR1
	RET

END