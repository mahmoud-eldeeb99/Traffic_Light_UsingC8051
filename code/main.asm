$NOMOD51	 ;to suppress the pre-defined addresses by keil
$include (C8051F020.H)		; to declare the device peripherals	with it's addresses

ORG 00H
;diable the watch dog
MOV WDTCN,#11011110B ;0DEH
MOV WDTCN,#10101101B ;0ADH

; config of clock
MOV OSCICN , #14H ; 2MH clock
;config cross bar
MOV XBR0 , #00H
MOV XBR1 , #00H
MOV XBR2 , #040H  ; Cross bar enabled , weak Pull-up enabled

LJMP INIT

ORG 400H
TBL:    		DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,80H,90H    ;7seg data for comm. anode type

ORG 30H


MAX EQU 43H
CURRENT_COUNT EQU 40H
FREQUENCY EQU 44H

; only executed in the start of running
INIT: 		  MOV P1,#00H     ;enables in pins 0 and 1 of the two 7segs (P1.0, P1.1)
						MOV P2,#00H     ;data pins of the 7segs
						MOV P0MDOUT, #0FFH			;configuring switch pins as digital inputs with internal pull-ups enabled
						MOV P3MDOUT, #00H			;configurations of leds as outputs
						ACALL RED     ; initial traffic state
						MOV DPTR,#TBL
						CLR A
						MOV MAX, #20		; store the MAX COUNTER NUMBER in the location 42h
						MOV CURRENT_COUNT,MAX     
						MOV FREQUENCY, #40		; iterative display count
						MOV R0,FREQUENCY      

;continous instructions to be executed (repeatedly) (by FREQUENCY times per 1 count down)
DISPLAY:		MOV A,CURRENT_COUNT
						MOV B,#10
						DIV AB
						MOV 41H,A
						MOV 42H,B
						SETB P1.0
						CLR P1.1
						MOV A,41H
						MOVC A,@A+DPTR
						MOV P2,A
						ACALL DELAY
						MOV P1,#00H
						SETB P1.1
						CLR P1.0
						MOV A,42H
						MOVC A,@A+DPTR
						MOV P2,A
						ACALL DELAY
						MOV P1,#00H
						SJMP X3
X2:					SJMP DISPLAY

X3:					ACALL SWITCHES
						DJNZ R0,X2
						MOV R0,FREQUENCY
						DJNZ CURRENT_COUNT,DISPLAY
						MOV CURRENT_COUNT,MAX
						ACALL UPDATE_TRAFFIC
						LJMP DISPLAY
	
DELAY:  		MOV R4,#5
H2:     		MOV R5,#0FFH
H1:     		DJNZ R5,H1
						DJNZ R4,H2
						RET

BLUE:				MOV P3, #02H
						RET

RED:
						MOV P3, #01H
						RET

YELLOW:
						MOV P3, #04H
						RET

UPDATE_TRAFFIC:
						MOV A, P3
						ANL A, #11111110B
						JZ BLUE
						MOV A, P3
						ANL A, #11111101B
						JZ YELLOW
						MOV A, P3
						ANL A, #11111011B
						JZ RED
						RET

SWITCHES:		CLR A
						MOV A, P0
						ANL A, #00000001B
						JZ DECREASE
						MOV A, P0
						ANL A, #00000010B
						JZ INCREASE
						MOV A, P0
						ANL A, #00000100B
						JZ FAST
						MOV A, P0
						ANL A, #00001000B
						JZ MEDUIM
						MOV A, P0
						ANL A, #00010000B
						JZ SLOW
						RET

FAST:				MOV FREQUENCY, #3
						MOV R0,FREQUENCY
						RET

MEDUIM:			MOV FREQUENCY, #20
						MOV R0,FREQUENCY
						RET

SLOW:				MOV FREQUENCY, #40
						MOV R0,FREQUENCY
						RET

INCREASE:		MOV A, MAX
						ADD A, #5
						MOV MAX, A
X4:					ACALL SHOW_MAX
						MOV A, P0
						ANL A, #00000010B
						JZ X4
						RET

DECREASE:		MOV A, MAX
						SUBB A, #5
						MOV MAX, A
X5:					ACALL SHOW_MAX
						MOV A, P0
						ANL A, #00000001B
						JZ X5
						RET

SHOW_MAX:		MOV A,MAX
						MOV B,#10
						DIV AB
						MOV 41H,A
						MOV 42H,B
						SETB P1.0
						CLR P1.1
						MOV A,41H
						MOVC A,@A+DPTR
						MOV P2,A
						ACALL DELAY
						MOV P1,#00H
						SETB P1.1
						CLR P1.0
						MOV A,42H
						MOVC A,@A+DPTR
						MOV P2,A
						ACALL DELAY
						MOV P1,#00H
						RET

END