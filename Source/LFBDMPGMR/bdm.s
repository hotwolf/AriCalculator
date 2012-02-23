;###############################################################################
;# S12CBase - BDM - Bit Level BDM Protocol Driver (LFBDMPGMR port)             #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
;#    family.                                                                  #
;#                                                                             #
;#    S12CBase is free software: you can redistribute it and/or modify         #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CBase is distributed in the hope that it will be useful,              #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #
;###############################################################################
;# Description:                                                                #
;#    The module is in charge of driving the low level BDM protocol on the     #
;#    BKGD pin.                                                                #
;#    The timing of the bit protocol depends on the target speed (BDM_SPEED).  #
;#    This 16-bit integer represents the ratio bus cycles/128 target cycles.   #
;#                                                                             #
;#    This driver assumes the following pin connections:                       #
;#                                                                             #
;#      Target                                                                 #
;#    -----------+                                                             #
;#               |                                                             #
;#        /RESET +---------- PT6                                               #
;#               |                                                             #
;#               |                                                             #
;#          BKGD +---------- PT7                                               #
;#               |                                                             #
;#    -----------+                                                             #
;#                                                                             #
;#    BDM Protocoll implementation:                                            #
;#                                                                             #
;#    Reset:                                                                   #
;#    ======                                                                   #
;#        <---------------128 BC at min speed = 2^16 TC----------------->      #
;#    ---+                                                               +---  #
;# RESET |                                                               |     #
;#       +---------------------------------------------------------------+     #
;#                                                                             #
;#    ---+----------------------NS----------------------------------------+    #
;# BKGD  |                                                                +--- #
;#       +----------------------SS----------------------------------------+    #
;#       ^                                                               ^     #
;#       |                                                               |     #
;#     pull                                                           release  #
;#     reset                                                           reset   #
;#                                                                             #
;#                                                                             #
;#    Sync:                                                                    #
;#    =====			+---+    |<---Timer counts==BDM_SPEED--->|     #
;#				|   |					       #
;#    ---+			|   +----+				 +---  #
;#	 |			|        |                               |     #
;#	 +----------------------+   	 +-------------------------------+     #
;#	 ^			^        ^				 ^     #
;#	 |----------------------|--------|-------------------------------|     #
;#         128 BDM cycs at min.   16 BDM           128 BDM cycs	               #
;#	         target speed      cycs			                       #
;#                                                                             #
;#                                                                             #
;#    Delay:                                                                   #
;#    ======                                                                   #
;#        <-timeout % 2^16-> <---max. timeout---> <---max. timeout--->         #
;#       ^                  ^                    ^                    ^        #
;#       |                  |                    |                    |        #
;#   calculate      check and decrement  check and decrement         Done      #
;#    timeout           timeout MSW          timeout MSW                       #
;#                                                                             #
;#                                                                             #
;#    Receive:                                                                 #
;#    ========                                                                 #
;#        <------------------16 BC------------------->                         #
;#        <-----------10 BC------------>                                       #
;#        <---4 BC--->                                                         #
;#    ---+                    :``:                                             #
;#       |            +-----------------+-------------+----------------------  #
;#       +------------+.......:         ^             ^            :.....:     #
;#       ^            ^       ^         |             |            ^     ^     #
;#       |            |       |         |             |            |     |     #
;#     start       release  speed-up  sample    transmission      ACK   Done   #
;#     pulse      BKGD pin   pulse    point       complete       pulse         #
;#                                                                             #
;#                                                                             #
;#    Transmit:                                                                #
;#    =========                                                                #
;#        <------------------16 BC------------------->                         #
;#        <--------------13 BC--------------->                                 #
;#        <---4 BC--->                                                         #
;#    ---+            :```````````````````````:----------+                     #
;#       |            :                       :          +-------------------  #
;#       +------------+.......................:          ^           :.....:   #
;#       ^            ^                       ^          |           ^     ^   #
;#       |            |                       |          |           |     |   #
;#     start      toggle to               toggle to    release      ACK   Done #
;#     pulse      transmit 1              transmit 0    BKGD                   #
;#                                                                             #
;#                                                                             #
;#    The following routines for low bevel BDM communication are provided:     #
;#    BDM_RESET        - reset target (mode determined by target circuitry)    #
;#    BDM_SPECRESET    - reset target into special mode                        #
;#    BDM_SYNC	       - sync target and determine target speed                #
;#    BDM_TX           - transmit data                                         #
;#    BDM_RX           - receive data                                          #
;#    BDM_DELAY        - wait a number of BDM cycles                           #
;#    BDM_ACK          - wait for an ACK pulse                                 #
;#    BDM_SETSPEED     - set target speed                                      #
;#    BDM_GETSPEED     - return target speed                                   #
;#    BDM_WATCHRESET   - watch out for target resets                           #
;#    BDM_IGNORERESET  - ignore target resets                                  #
;###############################################################################
;# Version History:                                                            #
;#    June 24, 2010                                                            #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;Bit positions
RESET			EQU	$40 	;PT6
;MODC			EQU	$80	;PT7
BKGD			EQU	$80	;PT7

;Reset monitor counter 
BDM_RMCNT_FLG		EQU	$01
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	BDM_VARS_START
BDM_SPEED		DS	2	;target speed
BDM_DLY_128		EQU	BDM_SPEED
BDM_DLY_16		DS	2	;16 BDM cycles in timer counts	
BDM_DLY_13		DS	2	;13 BDM cycles in timer counts	
BDM_DLY_10		DS	2	;10 BDM cycles in timer counts	
BDM_DLY_4		DS	2	; 4 BDM cycles in timer counts	
BDM_RP_CODE		DS	2	;RX pulse code pointer
BDM_RP_CNT		DS	2	;RX pulse counter value

BDM_RMCNT		DS	2	;reset monitor count
	
BDM_VARS_END		EQU	*
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	 	BDM_INIT, 0	
 		;Initialize variables
		CLRA
		CLRB
		STD	BDM_SPEED
		STD	BDM_DLY_16
		STD	BDM_DLY_13
		STD	BDM_DLY_10
		STD	BDM_DLY_4						
		MOVW	#BDM_RP_DUMMY, BDM_RP_CODE
		STD	BDM_RP_CODE
		STD	BDM_RMCNT
#emac

;Convert BDM cycles into timer counts
; args:     D: BDM cycles
; result: Y:D: timer counts (0 in case of an error)
; SSTACK: 6 bytes
;         X is preserved
#macro	BDM_BC2TC, 0	
	SSTACK_JOBSR	BDM_BC2TC	
#emac

;Convert timer counts into BDM cycles
; args:     D: timer counts
; result: Y:D: BDM cycles (0 in case of an error)
; SSTACK: 6 bytes
;         X is preserved
#macro	BDM_TC2BC, 0	
	SSTACK_JOBSR	BDM_TC2BC	
#emac

;#Set BDM_SPEED
; args:   D: BDM_SPEED (timer count of 128 BDM cycles)
; result: none
; SSTACK: 14 bytes
;         X, Y and D are preserved
#macro	BDM_SET_SPEED, 0
	SSTACK_JOBSR	BDM_SET_SPEED	
#emac

;#Start reset monitor
; args:  none
; result: X: Error code:
;            0: No problems
;            2: reset monitors nested too deeply
; SSTACK: 2 bytes
;         D and Y are preserved
#macro	BDM_START_RM, 0
	SSTACK_JOBSR	BDM_START_RM		
#emac

;#End reset monitor
; args:  none
; result: X: Error code:
;            0: No problems
;            2: reset monitor mismatch
;            4: reset has occured
; SSTACK: 2 bytes
;         D and Y are preserved
#macro	BDM_END_RM, 0
	SSTACK_JOBSR	BDM_END_RM		
#emac

;#Terminate all reset monitor
; args:  none
; result: X: Error code:
;            0: No problems
;            2: reset has occured
; SSTACK: 2 bytes
;         D and Y are preserved
#macro	BDM_TERM_ALL_RMS, 0
	SSTACK_JOBSR	BDM_TERM_ALL_RMS		
#emac

;#Reset target
; args:   B: run mode (0:SS, >0:NS)
; result: none
; SSTACK: 8 bytes
;         X, Y and D are preserved
#macro	BDM_RESET, 0
	SSTACK_JOBSR	BDM_RESET
#emac

;#Sync
; args:   none
; result: X: Error code:
;            0: Sync succesful
;            2: Target reset occured during sync (or before)
;            4: Target is not responding
; SSTACK: 20 bytes
;         D and Y are preserved
#macro	BDM_SYNC, 0
	SSTACK_JOBSR	BDM_SYNC
#emac

;#Delay
; args:   X: delay in BDM cycles
; result: X: Error code:
;            0: No problems
;            2: Target reset occured during delay (or before)
;            4: BDM_SPEED not set
; SSTACK: 14 bytes
;         D and Y are preserved
#macro	BDM_DELAY, 0
	SSTACK_JOBSR	BDM_RESET
#emac

;#Receive
; args:   D: ACK timeout [BC]
;         X: data width [bits]
;         Y: data pointer [word pointer]
; result: D: ACK pulse width [BC] (0 in case of a ACK timeout)
;         X: Error code:
;            0: No problems
;            2: Target reset occured during transmission (or before)
;            4: BDM_SPEED not set
;            6: Communication error (BKGD low at start of transmission)
; SSTACK:  bytes
;         Y is preserved
#macro	BDM_RX, 0
	SSTACK_JOBSR	BDM_RX
#emac

;#Transmit
; SSTACK:  16 bytes
; args:   D: ACK timeout [BC] 
;         X: data width [bits]
;         Y: data pointer [word pointer]
; result: D: ACK pulse width [BC] (0 in case of a ACK timeout) 
;         X: Error code:
;            0: No problems
;            2: Target reset occured during transmission (or before)
;            4: BDM_SPEED not set
;            6: Target out of sync (BKGD low at start of transmission)
;         Y is preserved
#macro	BDM_TX, 0
	SSTACK_JOBSR	BDM_TX
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	BDM_CODE_START
	
;Convert BDM cycles into timer counts
; args:     D: BDM cycles
; result: Y:D: timer counts (0 in case of an error)
; SSTACK: 6 bytes
;         X is preserved
BDM_BC2TC		EQU	*	
			;Save registers
			SSTACK_PSHXD				;save index X and accu D
			;Multiply  BDM cycles by BDM_SPEED (BDM cycles in D)
			LDY	BDM_SPEED
			EMUL					;Y * D => Y:D
			;Divide result by 128 BDM cycles (BDM cycles * BDM_SPEED in Y:D)
			EXG	D,Y				;(BDM cycles*BDM_SPEED)/128
			LDX	#128			
			IDIV					;D / X => X,  D % X => D 
			STX	0,SP
			EXG	D,Y			
			LDX	#128			
			EDIV					;Y:D / X => Y,  Y:D % X => D 
			;Round result (quotient in Y, remainder in D, 128 in X)
			FDIV					;D / X => X,  D % X => D
			TFR	X,D	
			LSLD
			TFR	Y,D
			ADCB	#0
			ADCA	#0
			EXG	D,Y
			SSTACK_PULD
			ADCB	#0
			ADCA	#0
			EXG	D,Y
			;Done
			SSTACK_PULX
			SSTACK_RTS
	
;Convert timer counts into BDM cycles
; args:     D: timer counts
; result: Y:D: BDM cycles (0 in case of an error)
; SSTACK: 6 bytes
;         X is preserved
BDM_TC2BC	EQU	*	
			;Save registers
			SSTACK_PSHXD				;save index X and accu D
			;Multiply  BDM cycles by 128 (BDM cycles in D)
			LDY	#128
			EMUL					;Y * D => Y:D
			;Divide result by BDM_SPEED BDM cycles (BDM cycles * BDM_SPEED in Y:D)
			EXG	D,Y				;(BDM cycles*BDM_SPEED)/128
			LDX	BDM_SPEED
			BEQ	BDM_TC2BC_2 			;BDM_SPEED is not set
			IDIV					;D / X => X,  D % X => D 
			STX	0,SP
			EXG	D,Y			
			LDX	BDM_SPEED			
			EDIV					;Y:D / X => Y,  Y:D % X => D 
			;Round result (quotient in Y, remainder in D, 128 in X)
			FDIV					;D / X => X,  D % X => D
			TFR	X,D	
			LSLD
			TFR	Y,D
			ADCB	#0
			ADCA	#0
			EXG	D,Y
			SSTACK_PULD
			ADCB	#0
			ADCA	#0
			EXG	D,Y
			;Done
BDM_TC2BC_1		SSTACK_PULX
			SSTACK_RTS
			;Error 
BDM_TC2BC_2		SSTACK_DEALLOC	1	
			JOB	BDM_TC2BC_1	
	
;#Set BDM_SPEED
; args:   D: BDM_SPEED (timer count of 128 BDM cycles)
; result: none
; SSTACK: 14 bytes
;         X, Y and D are preserved
BDM_SET_SPEED		EQU	*
			;Save registers
			SSTACK_PSHYXD				;save index X, index Y, and accu D
			;Check if the BDM_SPEED value is valid (BDM_DLY_128 in D)
			CPD	#43 				;max. speed
			BLS	BDM_SET_SPEED_3			;BDM_SPEED too low
			;Set BDM_SPEED variable (BDM_DLY_128 in D)
			STD	BDM_SPEED	
			;Set BDM_DLY_16 variable
			LDD	#16
			BDM_BC2TC
			STD	BDM_DLY_16
			;Set BDM_DLY_13 variable
			LDD	#13
			BDM_BC2TC
			STD	BDM_DLY_13
			;Set BDM_DLY_10 variable
			LDD	#10
			BDM_BC2TC
			STD	BDM_DLY_10
			;Set BDM_DLY_4 variable
			LDD	#4
			BDM_BC2TC
			STD	BDM_DLY_4
			;Set BDM_RP_CODE and BDM_RP_CNT variables (BDM_DLY_4 in D)
			SUBD	#2 				;subtract 2 cycles offset of RP code
			BHS	BDM_SET_SPEED_1			;saturate at zero
			CLRA
			CLRB
BDM_SET_SPEED_1		LDX	#3 				;divide by 3
			IDIV					;D / X => X,  D % X => D
			STX	BDM_RP_CNT			;store BDM_RP_CNT	
			BEQ	BDM_SET_SPEED_2			;use different routines if BDM_RP_CNT > 0
			ADDD	#3
BDM_SET_SPEED_2		LSLD					;lookup RP code sequence
			LDX	#BDM_RP_TAB
			LDX	D,X
			STX	BDM_RP_CODE			;store BDM_RP_CODE
			;Done
			SSTACK_PULDXY 				;restore registers
			SSTACK_RTS
			;Error (invalid BDM_SPEED value)
BDM_SET_SPEED_3		SSTACK_PULDXY 				;restore registers
			CLRA
			CLRB
			STD	BDM_DLY_128
			STD	BDM_DLY_16
			STD	BDM_DLY_13
			STD	BDM_DLY_10
			STD	BDM_DLY_4
			STD	BDM_RP_CNT
			MOVW	#BDM_RP_DUMMY, BDM_RP_CODE
			SSTACK_RTS

;#Start reset monitor
; args:  none
; result: X: Error code:
;            0: No problems
;            2: reset monitors nested too deeply
; SSTACK: 2 bytes
;         D and Y are preserved
BDM_START_RM		EQU	*
			;Check reset monitor count 
			LDX	BDM_RMCNT		
			BNE	BDM_START_RM_1 ;increment reset monitor count
			;Clear interrupt flag (reset monitor count in X)
			LDD	OC6
			;Increment reset monitor count (reset monitor count in X)
BDM_START_RM_1		IBEQ	X, BDM_START_RM_3	;monitors nested too deeply
			IBEQ	X, BDM_START_RM_3	;monitors nested too deeply
			STX	BDM_RMCNT
			LDX	#$0000
			;Done
BDM_START_RM_2		SSTACK_RTS
			;Monitors nested too deeply
BDM_START_RM_3		MOVW	#$0000, BDM_RMCNT	;terminate all monitors
			LDX	#$0002
			;Done
			JOB	BDM_START_RM_2
	
;#End reset monitor
; args:  none
; result: X: Error code:
;            0: No problems
;            2: reset monitor mismatch
;            4: reset has occured
; SSTACK: 2 bytes
;         D and Y are preserved
BDM_END_RM		EQU	*
			

	
			;Decrement reset monitor count
			LDX	BDM_RMCNT
			BEQ	BDM_END_RM_2 			;mismatching monitors
			LEAX	-1,X
			STX	BDM_RMCNT
			BRSET	TFLG1, #C6F, BDM_END_RM_3	;reset has been detected
			LDX	#$0000	
			;Done 
BDM_END_RM_1		SSTACK_RTS
			;Mismatching monitors
BDM_END_RM_2		LDD	#$0002				;set return value
			;Done 
			JOB	BDM_END_RM_1
			;Reset has occured	
BDM_END_RM_3		LDD	#$0004				;set return value
			;Done 
			JOB	BDM_END_RM_1
			
;#Terminate all reset monitor
; args:  none
; result: D: Error code:
;            0: No problems
;            2: reset has occured
; SSTACK: 2 bytes
;         X and Y are preserved
BDM_TERM_ALL_RMS	EQU	*
			;Clear monitor count 
			LDX	#$0000	
			STX	BDM_RMCNT
			BRSET	TFLG1, #C6F, BDM_TERM_ALL_RMS_2	;reset has been detected
			;Done 
BDM_TERM_ALL_RMS_1	SSTACK_RTS
			;Reset has occured	
BDM_TERM_ALL_RMS_2	LEAX	2,X
			;Done 
			JOB	BDM_TERM_ALL_RMS_2

#Reset target
; args:   B: run mode (0:SS, >0:NS)
; result: none
; SSTACK: 6 bytes
;         X, Y and D are preserved
BDM_RESET		EQU	*
			;Save registers (run mode in B)
			SSTACK_PSHXD				;save index X, index Y, and accu D	
			;Check if reset monitor is enabled (run mode in B)
			LDX	BDM_RMCNT
			BEQ	BDM_RESET_1 			;reset monitor has been disabled
			;Check if previous reset has been detected (run mode in B)
			BRSET	TFLG1, #C6F, BDM_RESET_4	;reset has been detected
			;Drive MODE on BKGD pin (run mode in B)
BDM_RESET_1		BCLR	PTT, #PT7
			TSTB
			BEQ	BDM_RESET_2 			;SSC mode
			BSET	PTT, #PT7
BDM_RESET_2		BSET	DDRT, #PT7		
			;Drive RESET low 
			BSET	DDRT, PT6 			
			;Wait for at least 2^16 TC 
			SEI
			MOVW	TCNT, TC5 			;set delay and clear interrupt flag
			BSET	TIE, #C5I			;enable interrupt
			;Wait for time out 
BDM_RESET_3		ISTACK_WAIT
			BRCLR	TFLG1, #C5F, BDM_RESET_3	
			;Release RESET 
			BCLR	DDRT, PT6
			;Release BKGD
			BCLR	DDRT, #PT7	
			;Done
BDM_RESET_4		SSTACK_PULDX 			;restore registers
			SSTACK_RTS

;#Sync
; args:   none
; result: X: Error code:
;            0: Sync succesful
;            2: Target reset occured during sync (or before)
;            4: Target is not responding
; SSTACK: 20 bytes
;         D and Y are preserved
BDM_SYNC		EQU	*
			;Save registers
			SSTACK_PSHYD				;save index X, index Y			
			;Check if reset monitor is enabled (run mode in B)
			LDX	BDM_RMCNT
			BEQ	BDM_SYNC_1 			;reset monitor has been disabled
			;Check if previous reset has been detected (run mode in B)
			BRSET	TFLG1, #C6F, BDM_SYNC_		;reset has been detected
			;Drive BKGD pin low
BDM_SYNC_1		BCLR	PTT, #PT7
			;Wait for at least 2^16 TC 
			SEI
			MOVW	TCNT, TC5 			;set delay and clear interrupt flag
			BSET	TIE, #C5I			;enable interrupt
			;Wait for time out 
BDM_SYNC_2		ISTACK_WAIT
			
	
			BRCLR	TFLG1, #C5F, BDM_SYNC_2	





	
			;Enable timer and set OC7 timeout to $FFFF
			TIM_ENABLE	TIM_BDM			;enable timer
			SEI
			BSET	TIE, #$80			;enable interrupt
			MOVW	TCNT, TC7			;set timeout/clear IF
			;Setup reset detection
			LDX	BDM_RMCNT
			BEQ	BDM_SYNC_STEP_1_2
			BSET	PIEP, #RESET	
			;Wait for interrupts 
BDM_SYNC_STEP_1_2	MOVW	#BDM_STEP_SYNC_1, BDM_STEP	;set current processing step
			ISTACK_RTI

			;Target reset error handler
BDM_SYNC_TGTRST		EQU	*
			;Set error code 2	
			LDX	#$0002
			;Disable interrupts, clean up, and done 
			JOB	BDM_SYNC_NORSP_1
	
			;Step 2
BDM_SYNC_STEP_2		EQU	*
			;Configure timer and start IC6 (negedge)
			BSET	TIE, #$E0 			;enable interrupts
			LDX	TC6				;clear IC6 (negedge) flag
			;Drive speed-up pulse and release BKGD (PB4)
			LDAB	#BKGD
			STAB	PORTB
			STAB	DDRB
			CLR	DDRB
			;Start IC5 (posedge)
			LDX	TC5				;clear IC5 (posedge) flag
			;Start OC7 (timeout=16*(2^16/128))
			LDD	TCNT				;set timeout
			ADDD	#$2000 
			STD	TC7
			;Wait for interrupt 
			MOVW	#BDM_STEP_SYNC_2, BDM_STEP
			ISTACK_RTI	

			;Step 3
BDM_SYNC_STEP_3		EQU	*
			;Set timeout to IC6 count (negedge)
			MOVW	TC6, TC7 			;set new timeout
			;Disable IC6 (negedge)
			BCLR	TIE, #$40 			;disable IC6 interrupt
			;Wait for interrupt 
			MOVW	#BDM_STEP_SYNC_3, BDM_STEP
			ISTACK_RTI
	
			;Step 4
BDM_SYNC_STEP_4		EQU	*
			;Capture pulse length
			LDD	TC5				
			SUBD	TC6
			;Check if timeout has occured (BDM_SPEED in D)
			BRCLR	TFLG1, #$80, BDM_SYNC_STEP_4_1 	;timeout flag not set
			CPD	#$E000				;check if an BSM_SPEED overflow has occured
			BLT	BDM_SYNC_NORSP			;target response is too late
			;Disable timer (BDM_SPEED in D)
BDM_SYNC_STEP_4_1	BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (BDM_SPEED in D)
			CLR	PIEP				;disable reset detection
			;Clean up (BDM_SPEED in D)
			MOVW	#BDM_STEP_IDLE, BDM_STEP			
			CLI
			;Set BDM speed (BDM_SPEED in D)
			SSTACK_JOBSR	BDM_SET_SPEED		;(SSTACK: 14 bytes)
			;Done
			LDX	#$0000
BDM_SYNC_STEP_4_2	SSTACK_PULDY 				;restore registers
			SSTACK_RTS

			;Target reset error handler
BDM_SYNC_NORSP		EQU	*
			;Set error code 4	
			LDX	#$0004
			;Disable timer
BDM_SYNC_NORSP_1	BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection
			CLR	PIEP				;disable reset detection
			;Clean up
			MOVW	#BDM_STEP_IDLE, BDM_STEP			
			CLI
			;Done
			JOB	BDM_SYNC_STEP_4_2

;#Delay
; args:   X: delay in BDM cycles
; result: X: Error code:
;            0: No problems
;            2: Target reset occured during delay (or before)
;            4: BDM_SPEED not set
; SSTACK: 14 bytes
;         D and Y are preserved
BDM_DELAY		EQU	*

BDM_DELAY_TO_MSW	EQU	0 				;timeout (MSW)
BDM_DELAY_TMP		EQU	0 				;timeout (MSW)
BDM_DELAY_D		EQU	0
BDM_DELAY_X		EQU	2
BDM_DELAY_Y		EQU	4
	
			;Save registers
			SSTACK_PSHYXD				;save index X, index Y, and accu D
	
			;Step 1
BDM_DELAY_STEP_1	EQU	*
			;Calculate timeout (delay [BC] in X)
			TFR	X,D
			SSTACK_JOBSR	BDM_BC2TC		;(SSTACK: 6 bytes)
			TFR	SP, X
			MOVW	#6, BDM_DELAY_TMP,X 		;set minimum delay for 
			EMAXD	BDM_DELAY_TMP,X
			STY	BDM_DELAY_TO_MSW,X		;store BDM_DELAY_TO_MSW
			;Enable timer and set timeout (delay LSW [TC] in D)
			TIM_ENABLE	TIM_BDM			;enable timer
			SEI
			ADDD	TCNT	;RPO			;set timeout
			STD	TC7	;PWO
			BSET	TIE, #$80			;enable interrupt
			;Setup reset detection
			LDX	BDM_RMCNT
			BEQ	BDM_DELAY_STEP_1_1
			BRSET	PIFP, #RESET, BDM_DELAY_TGTRST ;previous reset detected
			BSET	PIEP, #RESET	
			;Wait for interrupts 
BDM_DELAY_STEP_1_1	MOVW	#BDM_STEP_DELAY_1, BDM_STEP
			ISTACK_RTI			
	
			;Target reset error handler
BDM_DELAY_TGTRST	EQU	*
			;Disable timer (SP in Y)
			BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (SP in Y)
			CLR	PIEP				;disable reset detection
			;Clean up
			MOVW	#BDM_STEP_IDLE, BDM_STEP			
			CLI
			;Set error code 
			TFR	SP, Y
			MOVW	#$0002, BDM_DELAY_X,Y
			;Done
			JOB	BDM_DELAY_STEP_2_2	
	
			;Step 2
BDM_DELAY_STEP_2	EQU	*
			;If timeout MSW value > 0, decrement it and wait for another max. timeout period
			TFR	SP, Y
			LDX	BDM_DELAY_TO_MSW,Y 		;check timeout MSW value
			BEQ	BDM_DELAY_STEP_2_1
			LEAX	-1,X 				;decrement timeout MSW value
			STX	BDM_DELAY_TO_MSW,Y
			MOVW	TC7, TC7 			;Clear TC7 flag
			ISTACK_RTI
			;Disable timer (SP in Y)
BDM_DELAY_STEP_2_1	BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (SP in Y)
			CLR	PIEP				;disable reset detection
			;Clean up (SP in Y)
			MOVW	#BDM_STEP_IDLE, BDM_STEP			
			CLI
			;Check if BDM_SPEED had been set (SP in Y)
			MOVW	#$0000, BDM_DELAY_X,Y 		;set error code
			LDX	BDM_SPEED
			BNE	BDM_DELAY_STEP_2_2
			MOVW	#$0004, BDM_DELAY_X,Y 		;set error code
			;Done
BDM_DELAY_STEP_2_2	SSTACK_PULDXY 				;restore registers
			SSTACK_RTS
	
;#Receive
; args:   D: ACK timeout [BC]
;         X: data width [bits]
;         Y: data pointer [word pointer]
; result: D: ACK pulse width [BC] (0 in case of a ACK timeout)
;         X: Error code:
;            0: No problems
;            2: Target reset occured during transmission (or before)
;            4: BDM_SPEED not set
;            6: Communication error (BKGD low at start of transmission)
; SSTACK:  bytes
;         Y is preserved	
BDM_RX			EQU	*
			;Save registers
BDM_RX_ACK_TO_TC_MSW	EQU	0
BDM_RX_ACK_TO_TC_LSW	EQU	2	
BDM_RX_DATA_CNT		EQU	4
BDM_RX_DATA_PTR		EQU	6
BDM_RX_Y		EQU	8
			SSTACK_PSHY				;save index X, index Y, and accu D
			SSTACK_ALLOC	8
	
			;Step 1
BDM_RX_STEP_1		EQU	*	
			;Quit if reset monitor is enabled
			;and previous target reset was detected (BC timeout in D, bit count in X)
			LDY	BDM_RMCNT
			BEQ	BDM_RX_STEP_1_1
			BRSET	PIFP, #$20, BDM_RX_TGTRST
			;Quit if BDM_SPEED is not set (BC timeout in D, bit count in X)
BDM_RX_STEP_1_1		LDY	BDM_SPEED
			BEQ	BDM_RX_NOSPD 			;BDM_SPEED not set
			;Initialize local variables (BC timeout in D, bit count in X)
			TFR	SP, Y
			STX	BDM_RX_DATA_CNT,Y
			BEQ	BDM_RX_NOP 			;nothing to do
			LDX	BDM_RX_Y,Y
			STX	BDM_RX_DATA_PTR,Y
			;Clear MSW of the data field (BC timeout in D, stack pointer in Y, data pointer in X) 
			MOVW	#$0000, 0,X
			;Calculate timeout (BC timeout in D)
			SSTACK_JOBSR	BDM_BC2TC		;(SSTACK: 6 bytes)
			TFR	SP, Y
			STY	BDM_RX_ACK_TO_TC_MSW,Y		;store BDM_RX_ACK_TO_TC_MSW
			STD	BDM_RX_ACK_TO_TC_LSW,Y		;store BDM_RX_ACK_TO_TC_MSW
			;Enable timer (stack pointer in Y)	
			TIM_ENABLE	TIM_BDM			;enable timer
			;Setup reset detection (stack pointer in Y)
			SEI
			LDX	BDM_RMCNT
			BEQ	BDM_RX_STEP_1_2
			BSET	PIEP, #$20	
			;Quit if BKGD is driven low
BDM_RX_STEP_1_2		BRCLR	PORTB, #BKGD, BDM_RX_COMERR
			;Proceed at step 2
	
			;Step 2
BDM_RX_STEP_2		EQU	*
			;Setup IC5 (posedge) and OC7 (timeout)
			BSET	TIE, #$A0			;enable interrupt
			LDD	TC5 				;clear IC5 (posedge) IF
			;Drive RX pulse
			LDAA	#BKGD
			JMP	[BDM_RP_CODE]

			;Target reset
BDM_RX_TGTRST		EQU	*
			;Set error status 
			LDX	#$0002
			JOB	BDM_RX_ACK_TO_1

			;Communication error
BDM_RX_COMERR		EQU	*
			;Set error status 
			LDX	#$0006
			JOB	BDM_RX_ACK_TO_1

BDM_RP_DONE		EQU	*
			;Set OC7 (timeout) to IC6 + 16*(BDM_SPEED/128)
			LDD	TC6
			ADDD	BDM_DLY_16
			STD	TC7
			;Wait for interrupts 
			MOVW	#BDM_STEP_RX_2, BDM_STEP	;set current processing step
			ISTACK_RTI
	
			;Step 3
BDM_RX_STEP_3		EQU	*
			;Capture the pulse length
			LDD	TC5 				;posedge
			SUBD	TC6				;negedge
			;Determine and store bit value (pulse length in D)
			TFR	D,X
			TFR	SP, Y
			LDD	[BDM_RX_DATA_PTR,Y]
			LSLD	
			CPX	BDM_DLY_10 			;compare pulse length with 10 cycle delay
			ADCB	#$00
			EORB	#$01
			STD	[BDM_RX_DATA_PTR,Y]
			;Decrement data counter and check if transmission is complete (SP in Y)
			LDD	BDM_RX_DATA_CNT,Y 		
			DBEQ	D, BDM_RX_STEP_4		;last bit has been received
			STD	BDM_RX_DATA_CNT,Y
			BITB	#$0F
			BNE	BDM_RX_STEP_3_1			;space left in current data word
			LDX	BDM_RX_DATA_PTR,Y		;increment data pointer
			LEAX	2,X
			STX	BDM_RX_DATA_PTR,Y
			;Disable IC5 (posedge)
BDM_RX_STEP_3_1		BCLR	TIE, #$20			;disable interrupt
			;Wait for interrupts 
			MOVW	#BDM_STEP_RX_3, BDM_STEP	;set current processing step
			ISTACK_RTI	

			;Step 4
BDM_RX_STEP_4		EQU	*
			;Check if ACK pulse is expected
			TFR	SP, Y
			LDD	BDM_RX_ACK_TO_TC_LSW,Y
			BNE	BDM_RX_STEP_4_1
			LDX	BDM_RX_ACK_TO_TC_MSW,Y
			BEQ	BDM_RX_ACK_TO
			;Add end of bit timing to the ACK timeout (ACK timeout (LSW) in D, SP in Y)
BDM_RX_STEP_4_1		ADDD	TC7
			STD	TC7
			ADCB	BDM_RX_ACK_TO_TC_MSW+1,Y
			ADCA	BDM_RX_ACK_TO_TC_MSW,Y
			STD	BDM_RX_ACK_TO_TC_MSW,Y
			;Enable IC5 (posedge) and OC7 (timeout)
			BSET	TIE, #$A0			;enable interrupt			
			;Wait for interrupt 
			MOVW	#BDM_STEP_RX_4, BDM_STEP	;set current processing step
			ISTACK_RTI	
			
			;Step 5
BDM_RX_STEP_5		EQU	*
			;If timeout MSW value > 0, decrement it and wait for another
			;full timer period. Otherwise go to ACK timeout handler
			LDX	0,SP 				;check timeout MSW value
			BEQ	BDM_RX_ACK_TO			
			LEAX	-1,X 				;decrement timeout MSW value
			STX	0,SP
			MOVW	TC7, TC7 			;Clear TC7 flag
			ISTACK_RTI

			;Step 6
BDM_RX_STEP_6		EQU	*
			;Capture the pulse length
			LDD	TC5 				;posedge
			SUBD	TC6				;negedge
			;Disable timer (pulse length in D)
			BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (pulse length in D)
			CLR	PIEP				;disable reset detection
			;Clean up
			MOVW	#BDM_STEP_IDLE, BDM_STEP
			CLI
			;Convert pulse length into BCs (pulse length in D)
			BDM_TC2BC
			TBEQ	Y, BDM_RX_ACK_TO 		;pulse length is too long
			;Set error status 
			LDX	#$0000
			;Restore registers
			SSTACK_DEALLOC	8
			SSTACK_PULY
			SSTACK_RTS

			;Nothing to do
BDM_RX_NOP		EQU	BDM_RX_ACK_TO
	
			;BDM_SPEED not set
BDM_RX_NOSPD		EQU	*
			;Set error status 
			LDX	#$0004
			JOB	BDM_RX_ACK_TO_1

			;ACK Error
BDM_RX_ACK_TO		EQU	*
			;Set error status 
			CLRA
			CLRB
			;Disable timer (error status in X)
BDM_RX_ACK_TO_1		BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (error status in X)
			CLR	PIEP				;disable reset detection
			;Clean up (error status in X)
			MOVW	#BDM_STEP_IDLE, BDM_STEP
			CLI
			;Set ACK status 
			CLRA
			CLRB
			;Restore registers (error status in X)
			SSTACK_DEALLOC	8
			SSTACK_PULY
			SSTACK_RTS

;#Code sequences to build the RX pulse

;Pull BKGD pin low for 2 timer counts
; -> PORTA must be cleared
; -> Accu A must contain the value BDM_BKGD_PIN
; -> Interrupts must be disabled
BDM_RP_2C		EQU	*
			STAB	DDRB		;drive BKGD low
			CLR	DDRB		;relrase BKGD (2 pcycs)
BDM_RP_DUMMY		JOB	BDM_RP_DONE	;return to program flow

;Pull BKGD pin low for 3 timer counts
; -> PORTA must be cleared
; -> Accu A must contain the value BDM_BKGD_PIN
; -> Interrupts must be disabled
BDM_RP_3C	EQU	*
			STAB	DDRB		;drive BKGD low
			NOP			;1 pcyc delay
			CLR	DDRB		;relrase BKGD (2 pcycs)
			JOB	BDM_RP_DONE	;return to program flow

;Pull BKGD pin low for 4 timer counts
; -> PORTA must be cleared
; -> Accu A must contain the value BDM_BKGD_PIN
; -> Interrupts must be disabled
BDM_RP_4C		EQU	*
			STAB	DDRB		;drive BKGD low
			NOP			;1 pcyc delay
			NOP			;1 pcyc delay
			CLR	DDRB		;relrase BKGD (2 pcycs)
			JOB	BDM_RP_DONE	;return to program flow
	
;Pull BKGD pin low for (3*X)+2 timer counts
; -> PORTA must be cleared
; -> Accu A must contain the value BDM_BKGD_PIN
; -> Interrupts must be disabled
BDM_RP_3X2C		EQU	*
			LDX	BDM_RP_CNT
			STAB	DDRA		;drive BKGD low
			DBNE	X, *		;3*X pcycs
			CLR	DDRA		;relrase BKGD (2 pcycs)
			JOB	BDM_RP_DONE	;return to program flow

;Pull BKGD pin low for (3*X)+3 timer counts
; -> PORTA must be cleared
; -> Accu A must contain the value BDM_BKGD_PIN
; -> Interrupts must be disabled
BDM_RP_3X3C		EQU	*
			LDX	BDM_RP_CNT
			STAB	DDRA		;drive BKGD low
			DBNE	X, *		;3*X pcycs
			NOP			;1 pcyc
			CLR	DDRA		;relrase BKGD (2 pcycs)
			JOB	BDM_RP_DONE	;return to program flow

;Pull BKGD pin low for (3*X)+4 timer counts
; -> PORTA must be cleared
; -> Accu A must contain the value BDM_BKGD_PIN
; -> Interrupts must be disabled
BDM_RP_3X4C		EQU	*
			LDX	BDM_RP_CNT
			STAB	DDRA		;drive BKGD low
			DBNE	X, *		;3*X pcycs
			NOP			;1 pcyc
			NOP			;1 pcyc
			CLR	DDRA		;relrase BKGD (2 pcycs)
			JOB	BDM_RP_DONE	;return to program flow

;#Transmit
; args:   D: ACK timeout [BC] 
;         X: data width [bits]
;         Y: data pointer [word pointer]
; result: D: ACK pulse width [BC] (0 in case of a ACK timeout) 
;         X: Error code:
;            0: No problems
;            2: Target reset occured during transmission (or before)
;            4: BDM_SPEED not set
;            6: Target out of sync (BKGD low at start of transmission)
; SSTACK:  16 bytes
;         Y is preserved
			;Target reset
BDM_TX_TGTRST		EQU	*
			;Set error status 
			LDX	#$0002
			JOB	BDM_TX_ACK_TO_1

			;Communication error
BDM_TX_COMERR		EQU	*
			;Set error status 
			LDX	#$0006
			JOB	BDM_TX_ACK_TO_1
	
BDM_TX			EQU	*
			;Save registers
BDM_TX_ACK_TO_TC_MSW	EQU	0
BDM_TX_ACK_TO_TC_LSW	EQU	2	
BDM_TX_DATA_CNT		EQU	4
BDM_TX_DATA_PTR		EQU	6
BDM_TX_DATA_SHIFT	EQU	8
BDM_TX_DATA_TIMING	EQU	10
BDM_TX_Y		EQU	12
			SSTACK_PSHY				;save index X, index Y, and accu D
			SSTACK_ALLOC	12
	
			;Step 1
BDM_TX_STEP_1		EQU	*	
			;Quit if reset monitor is enabled
			;and previous target reset was detected (BC timeout in D,  bit count in X)
			LDY	BDM_RMCNT
			BEQ	BDM_TX_STEP_1_1
			BRSET	PIFP, #$20, BDM_TX_TGTRST
			;Check if BDM_SPEED is set (BC timeout in D,  bit count in X)
BDM_TX_STEP_1_1		LDY	BDM_SPEED
			BEQ	BDM_TX_NOSPD 			;BDM_SPEED not set
			;Quit if BKGD is driven low (BC timeout in D,  bit count in X)
			BRCLR	PORTB, #BKGD, BDM_TX_COMERR
			;Quit if data count is zero (BC timeout in D,  bit count in X)
			TFR	SP, Y			;store data count
			STX	BDM_TX_DATA_CNT,Y
			BEQ	BDM_TX_NOP			;nothing to do	
			;Calculate ACK timeout (BC timeout in D, stack pointer in Y)
			ADDD	#12 				;add 12 BDM cycles to the timeout
			TFR	Y,X
			SSTACK_JOBSR	BDM_BC2TC		;(SSTACK: 6 bytes)
			STY	BDM_TX_ACK_TO_TC_MSW,X		;set BDM_TX_ACK_TO_TC_MSW
			STD	BDM_TX_ACK_TO_TC_LSW,X		;set BDM_TX_ACK_TO_TC_LSW
			;Put left aligned data MSW into shifter (stack pointer in X)
			LDY	BDM_TX_Y,X 			;store data pointer
			STY	BDM_TX_DATA_PTR,X
			LDD	0,Y		  		;get data MSW
			LDD	BDM_TX_DATA_CNT,X		;get the position of the MSW
			CLRA
			DECB
			ANDB	#$0F
			EXG	D,Y
			JMP	BDM_TX_STEP_1_2,Y
BDM_TX_STEP_1_2		LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			LSLD
			TBNE	Y, BDM_TX_STEP_1_3 		;update shift data
			LDY	BDM_TX_DATA_PTR,X
			LDD	2,-Y
			STY	BDM_TX_DATA_PTR,X
BDM_TX_STEP_1_3		STD	BDM_TX_DATA_SHIFT,X	
			;Determine timing of initial bit transmission (bit value in C, stack pointer in X)
			LDY	BDM_DLY_4
			BCS	BDM_TX_STEP_1_4
			LDY	BDM_DLY_13
			;Enable timer (pulse length in Y, stack pointer in X)
BDM_TX_STEP_1_4		TIM_ENABLE	TIM_BDM			;enable timer
			;Setup reset detection (pulse length in Y, stack pointer in X)
			LDD	BDM_RMCNT
			SEI
			BEQ	BDM_TX_STEP_1_5
			BSET	PIEP, #RESET	
BDM_TX_STEP_1_5		;Set OC registers to a save value in the future (pulse length in Y, stack pointer in X)
BDM_TX_STEP_1_6		BCLR	TCTL1, #$FC			;disconnect OC6 output logic
			BSET	TIOS,  #$C0			;configure OC6 and OC7
			MOVW	TCNT, TC7 			;write save values to OC6 and OC7
			MOVW	TCNT, TC6
			BCLR	TIOS,  #$40
			;Configure OC6/OC7 output logic (pulse length in Y, stack pointer in X)
			BSET	TCTL1, #$20 			;drive negedge on OC6 events
			MOVW	#$4040, TOC7M			;drive posedge on OC6 events
			BSET	TIE, #$80			;enable interrupt on posedge
			;Check the state of the OC6 flipflop (bit timing in X, stack pointer in Y)
			BRSET	BDM_FLGS, #BDM_FLG_OC6FF, BDM_TX_STEP_1_7	;Transmit first bit - OC6FF set
			;Transmit first bit - OC6FF cleared (pulse length in Y, stack pointer in X)
			LDD	TCNT		 	;2 cycs
			ADDD	#11		 	;2 cycs
			LEAY	D,Y		 	;2 cycs
			STY	TC7		 	;2 cycs
			BSET	TIOS,  #$E0	 	;rPwO
			BSET	BDM_FLGS, #BDM_FLG_OC6FF
			;Prepare next bit 
			JOB	BDM_TX_STEP_1_8
			;Transmit first bit - OC6FF set (pulse length in Y, stack pointer in X)
BDM_TX_STEP_1_7		BSET	TIOS,  #$E0
			LDD	TCNT		     	;2 cycs
			ADDD	#10		     	;2 cycs
			STD	TC6		     	;2 cycs
			LEAY	D,Y		     	;2 cycs
			STY	TC7		     	;2 cycs
			;Prepare next bit (stack pointer in X)
BDM_TX_STEP_1_8		TFR	X,Y
			JOB	BDM_TX_STEP_2_2

			;Step 2
BDM_TX_STEP_2		EQU	*	
			;Check if end of bit timing has been missed
			TFR	SP, Y
			LDD	TC6 				;determine time unlil end of bit timing
			ADDD	BDM_DLY_16
			TFR	D,X			
			SUBD	TCNT 			;RPO
			EXG	D,X			;P
			CPX	#16			;PO
			BLT	BDM_TX_STEP_2_1		;PPP/P
			LDD	TCNT			;RPf	;start transmission immediately
			ADDD	#12			;PO
BDM_TX_STEP_2_1		STD	TC6			;PW
			ADDD	BDM_TX_DATA_TIMING,Y	;RPO
			STD	TC7			;PW
			;Update step (stack pointer in Y)
BDM_TX_STEP_2_2		LDX	BDM_TX_DATA_CNT,Y
			DBEQ	X, BDM_TX_STEP_2_6		;no more bits to transmi
			MOVW	#BDM_STEP_TX_2A, BDM_STEP	;update step
			STX	BDM_TX_DATA_CNT,Y		;update counter
			;Shift data (stack pointer in Y, bit count in X)
			LDD	BDM_TX_DATA_SHIFT,Y
			LSLD
			EXG	D,X
			BITB	#$0F
			BNE	BDM_TX_STEP_2_3
			LDX	BDM_TX_DATA_PTR,Y 		;increment data pointer
			LDD	2,+X
			STX	BDM_TX_DATA_PTR,Y
			TFR	D,X
BDM_TX_STEP_2_3		STY	BDM_TX_DATA_PTR,Y
			;Determine bit timing (stack pointer in Y, data bit in C)
			LDD	BDM_DLY_4
			BCS	BDM_TX_STEP_2_4
			LDD	BDM_DLY_13
BDM_TX_STEP_2_4		STD	BDM_TX_DATA_TIMING,Y	
			;Wait for interrupts 
BDM_TX_STEP_2_5		ISTACK_RTI
			;No more bits left to transmit (stack pointer in Y)
BDM_TX_STEP_2_6		MOVW	#BDM_STEP_TX_2B, BDM_STEP	;update step
			;Clear IC5 interrupt flag 
			LDD	TC5
			;Check if ACK pulse is requested (stack pointer in Y)
			LDD	BDM_TX_ACK_TO_TC_LSW,Y
			BNE	BDM_TX_STEP_2_5		;ACK pulse expected
			LDD	BDM_TX_ACK_TO_TC_MSW,Y
			BNE	BDM_TX_STEP_2_5		;ACK pulse expected
			;No ACK pulse expected
			MOVW	#BDM_STEP_TX_2C, BDM_STEP	;update step
			;Wait for interrupts 
			JOB	BDM_TX_STEP_2_5	
			
			;Step 3
BDM_TX_STEP_3		EQU	*
			;Set default configuration for IC6 and OC7
			BCLR	TCTL1, #$FC			;disconnect OC6 output logic
			BCLR	TIOS,  #$40
			;Make sure that ACK pulse has not been missed
			BRCLR	TFLG1, #$20, BDM_TX_STEP_3_1
			LDD	TC5
			SUBD	TC7
			CPD	#4
			BGT	BDM_TX_ACK_TO
			;Setup ACK timeout	
BDM_TX_STEP_3_1		TFR	SP, Y
			LDD	#6
			EMAXD	BDM_TX_ACK_TO_TC_LSW,Y
			ADDD	TCNT 		;RPf
			STD	TC7		;PW
			;Wait for interrupts
			BSET	TIE, #$A0
			MOVW	#BDM_STEP_TX_3, BDM_STEP	;update step
			ISTACK_RTI

			;Step 4
BDM_TX_STEP_4		EQU	*
			;If timeout MSW value > 0, decrement it and wait for another
			;full timer period. Otherwise go to ACK timeout handler
			LDX	0,SP 				;check timeout MSW value
			BEQ	BDM_TX_ACK_TO			
			LEAX	-1,X 				;decrement timeout MSW value
			STX	0,SP
			MOVW	TC7, TC7 			;Clear TC7 flag
			ISTACK_RTI

			;Step 5
BDM_TX_STEP_5		EQU	*
			;Capture the pulse length
			LDD	TC5 				;posedge
			SUBD	TC6				;negedge
			;Disable timer (pulse length in D)
			BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (pulse length in D)
			CLR	PIEP				;disable reset detection
			;Clean up
			MOVW	#BDM_STEP_IDLE, BDM_STEP
			CLI
			;Convert pulse length into BCs (pulse length in D)
			BDM_TC2BC
			TBEQ	Y, BDM_TX_ACK_TO 		;pulse length is too long
			;Set error status 
			LDX	#$0000
			;Restore registers
			SSTACK_DEALLOC	12
			SSTACK_PULY
			SSTACK_RTS

			;ACK Error
BDM_TX_ACK_TO		EQU	*
			;Set error status 
			LDX	#$0000
			;Disable timer (error status in X)
BDM_TX_ACK_TO_1		BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (error status in X)
			CLR	PIEP				;disable reset detection
			;Clean up (error status in X)
			MOVW	#BDM_STEP_IDLE, BDM_STEP
			CLI
			;Set ACK status 
			CLRA
			CLRB
			;Restore registers (error status in X)
			SSTACK_DEALLOC	8
			SSTACK_PULY
			SSTACK_RTS

			;Nothing to do
BDM_TX_NOP		EQU	BDM_TX_ACK_TO
	
			;BDM_SPEED not set
BDM_TX_NOSPD		EQU	*
			;Set error status 
			LDX	#$0004
			JOB	BDM_TX_ACK_TO_1

;#TC5 (posedge) handler
BDM_ISR_TC5		EQU	*
			;Perform step specific action
			LDX	BDM_STEP
			JMP	[BDM_TC6_TAB,X]

;#TC6 (negedge) handler
BDM_ISR_TC6		EQU	*
			;Perform step specific action
			LDX	BDM_STEP
			JMP	[BDM_TC6_TAB,X]

;#TC7 (timeout) handler
BDM_ISR_TC7		EQU	*
			;Perform step specific action
			LDX	BDM_STEP
			JMP	[BDM_TC7_TAB,X]

;#Target reset handler 
BDM_ISR_TGTRST		EQU	*
	
			;Stop driving the BKGD pin immediately  
			CLR	DDRB 		;switch PB4 to input
			BCLR	TCTL1, #$03	;disconnect OC5 and OC6 from output

			;Disable PP5 KWU 
			CLR	PIEP

			;Perform step specific action
			LDX	BDM_STEP
			JMP	[BDM_TGTRST_TAB,X]
	
BDM_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	BDM_TABS_START
;#IRQ jump tables
;TC5 jump table 
BDM_TC5_TAB		EQU	*
			DW	ERROR_ISR		;BDM interface not in use 
			DW	ERROR_ISR		;RESET step 1		  
			DW	ERROR_ISR		;SYNC step 1		  
			DW	BDM_SYNC_STEP_4		;SYNC step 2		  
			DW	BDM_SYNC_STEP_4		;SYNC step 3		  
			DW	ERROR_ISR		;DELAY step 1             
			DW	BDM_RX_STEP_3		;RX step 2             
			DW	ERROR_ISR		;RX step 3             
			DW	BDM_RX_STEP_6		;RX step 4             
			DW	ERROR_ISR		;TX step 2a
			DW	ERROR_ISR		;TX step 2b
			DW	ERROR_ISR		;TX step 2c
			DW	BDM_TX_STEP_5		;TX step 3

BDM_TC6_TAB		EQU	*			
			DW	ERROR_ISR		;BDM interface not in use 
			DW	ERROR_ISR		;RESET step 1		  
			DW	ERROR_ISR		;SYNC step 1		  
			DW	BDM_SYNC_STEP_3		;SYNC step 2		  
			DW	ERROR_ISR		;SYNC step 3		  
			DW	ERROR_ISR		;DELAY step 1             
			DW	ERROR_ISR		;RX step 2             
			DW	ERROR_ISR		;RX step 3             
			DW	ERROR_ISR		;RX step 4             
			DW	ERROR_ISR		;TX step 2a
			DW	ERROR_ISR		;TX step 2b
			DW	ERROR_ISR		;TX step 2c
			DW	ERROR_ISR		;TX step 3
							
BDM_TC7_TAB		EQU	*			
			DW	ERROR_ISR		;BDM interface not in use 
			DW	BDM_RESET_STEP_2	;RESET step 1		  
			DW	BDM_SYNC_STEP_2		;SYNC step 1		  
			DW	BDM_SYNC_NORSP		;SYNC step 2		  
			DW	BDM_SYNC_NORSP		;SYNC step 3		  
			DW	BDM_DELAY_STEP_2	;DELAY step 1             
			DW	BDM_RX_ACK_TO		;RX step 2             
			DW	BDM_RX_STEP_2		;RX step 3             
			DW	BDM_RX_STEP_5		;RX step 4             
			DW	BDM_TX_STEP_2		;TX step 2a
			DW	BDM_TX_STEP_3		;TX step 2b
			DW	BDM_TX_ACK_TO		;TX step 2c
			DW	BDM_TX_STEP_4		;TX step 3
							
BDM_TGTRST_TAB		EQU	*			
			DW	ERROR_ISR		;BDM interface not in use 
			DW	ERROR_ISR		;RESET step 1		  
			DW	BDM_SYNC_TGTRST		;SYNC step 1		  
			DW	BDM_SYNC_TGTRST		;SYNC step 2		  
			DW	BDM_SYNC_TGTRST		;SYNC step 3		  
			DW	BDM_DELAY_TGTRST	;DELAY step 1             
			DW	BDM_RX_TGTRST		;RX step 2             
			DW	BDM_RX_TGTRST		;RX step 3             
			DW	BDM_RX_TGTRST		;RX step 4             
			DW	BDM_TX_TGTRST		;TX step 2a
			DW	BDM_TX_TGTRST		;TX step 2b
			DW	BDM_TX_TGTRST		;TX step 2c
			DW	BDM_TX_TGTRST		;TX step 3

;#RX pulse jump table
BDM_RP_TAB		EQU	*
			DW	BDM_RP_2C
			DW	BDM_RP_3C
			DW	BDM_RP_4C
			DW	BDM_RP_3X2C
			DW	BDM_RP_3X3C
			DW	BDM_RP_3X4C
	
BDM_TABS_END		EQU	*



