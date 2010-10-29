;###############################################################################
;# S12CBase - BDM - Bit Level BDM Protocol Driver                              #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#        /RESET +---------- PP5 (KWU)                                         #
;#               |                                                             #
;#               |                                                             #
;#          BKGD +----+----- PB4 (Addressable in DIR mode)                     #
;#               |    |                                                        #
;#    -----------+    +----- PT6 (IC6 negedge detection)                       #
;#                    |                                                        #
;#                    +----- PT5 (IC5 posedge detection)                       #
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
;#       ^                                                               ^     #
;# Step: 1                                                               2     #
;#                                                                             #
;#    Configuration: TC7 -> OC (timeout) ->default                             #
;#    Error Codes:   none                                                      #
;#                                                                             #
;#    Step 1: -Quit if reset monitor is enabled                                #
;#             and previous target reset was detected                          #
;#            -Drive RESET (PP5) low                              	       #
;#            -Drive MODC (PB4) high for NS or low for SS                      #
;#            -Configure timer                                                 #
;#            -Set OC7 timeout to $FFFF                                        #
;#            -Wait for interrupt                                              #
;#             OC7:          -Proceed at step 2                                #
;#                                                                             #
;#    Step 2: -Disable timer                                                   #
;#            -Release RESET (PP5)                                             #
;#            -Restore reset monitor                                           #
;#            -Release MODC (PB4)                                              #
;#            -Clean up                                                        #
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
;#       ^                      ^        ^                                ^    #
;# Step: 1                      2        3                                4    #
;#                                                                             #
;#    Configuration: TC5 -> IC (posedge) ->default                             #
;#                   TC6 -> IC (negedge) ->default                             #
;#                   TC7 -> OC (timeout) ->default                             #
;#    Error Codes: 0: Sync succesful                                           #
;#                 2: Target reset occured during sync (or before)             #
;#                 4: Target is not responding                                 #
;#                                                                             #
;#    Step 1: -Quit if reset monitor is enabled                                #
;#             and previous target reset was detected                          #
;#            -Drive BKGD (PB4) low                                            #
;#            -Configure timer                                                 #
;#            -Enable timer and set OC7 timeout to $FFFF                       #
;#            -Setup reset detection                                           #
;#            -Wait for interrupts                                             #
;#             OC7:          -Proceed at step 2                                #
;#             Target reset: -Target reset error handler                       #
;#                                                                             #
;#    Step 2: -Configure timer and start IC6 (negedge)                         #
;#            -Drive speed-up pulse and release BKGD (PB4)                     #
;#            -Start IC5 (posedge)                                             #
;#            -Start OC7 (timeout=16*(2^16/128))                               #
;#            -Wait for interrupts                                             #
;#             IC5:          -Proceed at step 4                                #
;#             IC6:          -Proceed at step 3                                #
;#             OC7:          -No response error handler                        #
;#             Target reset: -Target reset error handler                       #
;#                                                                             #
;#    Step 3: -Set timeout to IC6 count (negedge)                              #
;#            -Disable IC6 (negedge)                                           #
;#            -Wait                                                            #
;#             IC5:          -Proceed at step 4                                #
;#             OC7:          -No response error handler                        #
;#             Target reset: -Target reset error handler                       #
;#                                                                             #
;#    Step 4: -Capture pulse length                                            #
;#            -Check if timeout has occured                                    #
;#            -Disable timer                                                   #
;#            -Disable reset detection                                         #
;#            -Clean up                                                        #
;#            -Set BDM speed                                                   #
;#                                                                             #
;#    Target reset error handler:                                              #
;#            -Set error code 2                                                #
;#            -Disable timer                                                   #
;#            -Disable reset detection                                         #
;#            -Clean up                                                        #
;#                                                                             #
;#    No response error handler:                                               #
;#            -Set error code 4                                                #
;#            -Disable timer                                                   #
;#            -Disable reset detection                                         #
;#            -Clean up                                                        #
;#                                                                             #
;#    Delay:                                                                   #
;#    ======                                                                   #
;#        <-timeout % 2^16-> <---max. timeout---> <---max. timeout--->         #
;#       ^                  ^                    ^                    ^        #
;#       |                  |                    |                    |        #
;#   calculate      check and decrement  check and decrement         Done      #
;#    timeout           timeout MSW          timeout MSW                       #
;#                                                                             #
;#       ^                  ^                    ^                     ^       #
;# Step: 1                  2                    2                     2       #
;#                                                                             #
;#    Configuration:    TC7 -> OC (timeout) ->default                          #
;#    Error Codes: 0: No problems                                              #
;#                 2: Target reset occured during delay (or before)            #
;#                 4: BDM_SPEED is not set                                     #
;#                                                                             #
;#    Step 1: -Calculate timeout                                               #
;#            -Enable timer and set timeout                                    #
;#            -Setup reset detection                                           #
;#            -Wait for interrupts                                             #
;#             OC7:          -Proceed at step 2                                #
;#             Target reset: -Target reset error handler                       #
;#                                                                             #
;#    Step 2: -If timeout MSW value > 0,                                       #
;#             decrement it and wait for another max. timeout period           #
;#            -Disable timer                                                   #
;#            -Disable reset detection                                         #
;#            -Clean up                                                        #
;#            -Check if BDM_SPEED had been set                                 #
;#                                                                             #
;#    Target reset error handler:                                              #
;#            -Disable timer                                                   #
;#            -Disable reset detection                                         #
;#            -Clean up                                                        #
;#            -Set error code                                                  #
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
;#       ^                    ^                       ^                  ^     #
;# Step:1,2                   3                       3                 2,4    #
;#                                                                             #
;#    Configuration:    TC5 -> IC (posedge) ->default                          #
;#                      TC6 -> IC (negedge) ->default                          #
;#                      TC7 -> OC (timeout) ->default                          #
;#    Error Codes: 0: No problems                                              #
;#                 2: Target reset occured during transmission (or before)     #
;#                 4: BDM_SPEED is not set                                     #
;#                 6: Communication error (BKGD low at start of transmission)  #
;#                                                                             #
;#    Step 1: -Quit if reset monitor is enabled                                #
;#             and previous target reset was detected                          #
;#            -Quit if BDM_SPEED has not been set                              #
;#            -Configure timer                                                 #
;#            -Setup reset detection                                           #
;#            -Proceed at step 2                                               #
;#                                                                             #
;#    Step 2: -Proceed at step 4 if all bits have been received                #
;#            -Setup IC5 (posedge) and OC7 (timeout)                           #
;#            -Drive RX pulse                                                  #
;#            -Set OC7 (timeout) to IC6 + 16*(BDM_SPEED/128)                   #
;#            -Wait                                                            #
;#             IC5:          -Proceed at step 3                                #
;#             Target reset: -Error handler                                    #
;#                                                                             #
;#    Step 3: -Capture the pulse length                                        #
;#            -Decrement data counter                                          #
;#            -Select data MSW or LSW                                          #
;#            -Determine bit value                                             #
;#            -Disable IC5 (posedge)                                           #
;#            -Enable OC7 (timeout)                                            #
;#            -Wait                                                            #
;#             OC7:          -Proceed at step 2                                #
;#             Target reset: -Error handler                                    #
;#                                                                             #
;#    Step 4: -Disable timer                                                   #
;#            -Disable reset detection                                         #
;#            -Clean up                                                        #
;#                                                                             #
;;#    Error:  -Set return value                                               #
;#            -Disable timer                                                   #
;#            -Disable reset detection                                         #
;#            -Clean up                                                        #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#    Quit:   -Disable Disable IC5, IC6, and OC7                               #
;#            -Disable reset detection                                         #
;#            -Clear BDM_SPEED                                                 #
;#            -Return error status                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#    Transmit:                                                                #
;#    =========                                                                #
;#        <----------------------------16 tcycs------------------------->      #
;#        <---------------------13 tcycs-------------------->                  #
;#        <---------------10 tcycs-------------->                              #
;#        <---4 tcycs--->                                                      #
;#    ---+               +-----------------------+-----------+-----------+---  #
;#       |               |                                   |           ^     #
;#       +---------------+-----------------------+-----------+           |     #
;#       ^               ^                       ^           ^           |     #
;#       |               |                       |           |           |     #
;#     start          transmit                capture     transmit      bit    #
;#     pulse            "1"                  bit value      "0"    trasmission #
;#                                                                    complete #
;#                                                                             #
;#       ^                      ^                                        ^     #
;# Step: 1                      2                                        3     #
;#                                                                             #
;#    Configuration: TC5 -> OC/IC (posedge)                                    #
;#                   TC6 -> OC/IC (negedge)                                    #
;#                   TC6 -> OC (timeout) ->default                             #
;#    Error Codes: 0: No problems                                              #
;#                 2: Target reset occured during transmission (or before)     #
;#                 4: BDM_SPEED is not set                                     #
;#                 6: Target out of sync (BKGD low at start of transmission)   #
;#                 8: ACK pulse timed out                                      #
;#                10: ACK pulse too long                                       #
;#                                                                             #
;#    Step 1: -Quit if previous target reset was detected                      #
;#            -Quit if BDM_SPEED has not been set                              #
;#            -Set OC6 to a count in the near future                           #
;#            -Set OC5 to TC6 count 4*(BDM_SPEED/128) or 10*(BDM_SPEED/128)    #
;#            -Set OC7 to 16*(BDM_SPEED/128)                                   #
;#            -Wait                                                            #
;#             OC7:          -Proceed at step 2                                #
;#             Target reset: -Quit with "Unexpected target reset"              #
;#                                                                             #
;#    Step 2: -Disable Disable OC7                                             #
;#            -Disable reset detection                                         #
;#            -Return successfully                                             #
;#                                                                             #
;#    Quit:   -Disable Disable IC5, IC6, and OC7                               #
;#            -Disable reset detection                                         #
;#            -Clear BDM_SPEED                                                 #
;#            -Return error status                                             #
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
;Timer channels                                                                  #
BDM_TCPE		EQU	5	;TC5 drives and detects posedges
BDM_TCNE		EQU	6	;TC6 drives and detects negedges
BDM_TCTO		EQU	7	;TC7 determines timeouts

;Processing steps 
BDM_STEP_IDLE		EQU	 0	;BDM interface not in use 
BDM_STEP_RESET_1	EQU	 2	;RESET step 1		  
BDM_STEP_SYNC_1		EQU	 4	;SYNC step 1		  
BDM_STEP_SYNC_2		EQU	 6	;SYNC step 2		  
BDM_STEP_SYNC_3		EQU	 8	;SYNC step 3		  
BDM_STEP_DELAY_1	EQU	10	;DELAY step 1              
BDM_STEP_RX_2		EQU	12	;RX step 2		  
BDM_STEP_RX_3		EQU	14	;RX step 3		  

;Bit positions
RESET			EQU	$20 	;PP5
MODC			EQU	$10	;PB4
BKGD			EQU	$10	;PB4
	
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

BDM_STEP		DS	2	;current processing step

BDM_RMCNT		DS	2	;reset monitor count
BDM_FLGS		DS	1	;flags
	
BDM_VARS_END		EQU	*
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	 	BDM_INIT, 0
	
 		;Initialize variables
		
		BDM_SET_SPEED

	
		;Initialize reset detection
		
		;Initialize timer channels

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
			STX	[SSTACK_SP]
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
			STX	[SSTACK_SP]
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
	
;#Reset target
; args:   B: run mode (0:SS, >0:NS)
; result: none
; SSTACK: 8 bytes
;         X, Y and D are preserved
BDM_RESET		EQU	*
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D
	
			;Step 1
BDM_RESET_STEP_1	EQU	*
			;Quit if reset monitor is enabled                                #
			;and previous target reset was detected                          #
			LDX	BDM_RMCNT
			BEQ	BDM_RESET_STEP_1_1
			BRSET	PIFP, #RESET, BDM_RESET_STEP_2_1
			;Drive RESET (PP5) low
BDM_RESET_STEP_1_1	MOVB	#RESET, DDRP
			;Drive MODC (PB4) high for NS or low for SS
			CLR	PORTB
			TBEQ	B, BDM_RESET_STEP_1_2
			MOVB	#$MODC, PORTB
BDM_RESET_STEP_1_2	MOVB	#$MODC, DDRB
			;Configure timer 
			TIM_ENABLE	TIM_BDM			;enable timer
			;Set OC7 timeout to $FFFF
			SEI
			BSET	TIE, #$80			;enable interrupt
			MOVW	TCNT, TC7			;set timeout/clear IF
			;Wait for interrupts 
			MOVW	#BDM_STEP_RESET_1, BDM_STEP	;set current processing step
			ISTACK_RTS
	
	 		;Step 2
BDM_RESET_STEP_2	EQU	*
			;Disable timer
			BCLR	TIE, #$E0		;disable interrupt
			TIM_DISABLE	TIM_BDM		;disable timer
			;Release RESET (PP5)
			CLR	DDRP 	
			;Restore reset monitor
			MOVB	#$FF, PIFP
			;Release MODC (PB4)
			CLR	DDRB
			;Clean up
			MOVW	#BDM_STEP_IDLE, BDM_STEP			
			CLI
			;Done
BDM_RESET_STEP_2_1	SSTACK_PULDXY 			;restore registers
			SSTACK_RTS

;#Sync
; args:   none
; result: D: Error code:
;            0: Sync succesful
;            2: Target reset occured during sync (or before)
;            4: Target is not responding
; SSTACK: 20 bytes
;         X and Y are preserved
BDM_SYNC		EQU	*
			;Save registers
			SSTACK_PSHYX			;save index X, index Y
			
			;Step 1
BDM_SYNC_STEP_1		EQU	*
			;Quit if reset monitor is enabled
			;and previous target reset was detected
			LDX	BDM_RMCNT
			BEQ	BDM_SYNC_STEP_1_1
			BRSET	PIFP, #RESET, BDM_SYNC_TGTRST
			;Drive BKGD (PB4) low
BDM_SYNC_STEP_1_1	CLR	PORTB
			MOVB	#BKGD, DDRB
			;Enable timer and set OC7 timeout to $FFFF
			TIM_ENABLE	TIM_BDM			;enable timer
			SEI
			BSET	TIE, #$80			;enable interrupt
			MOVW	TCNT, TC7			;set timeout/clear IF
			;Setup reset detection
			LDX	BDM_RMCNT
			BEQ	BDM_SYNC_STEP_1_2
			PIEP	#RESET	
			;Wait for interrupts 
BDM_SYNC_STEP_1_2	MOVW	#BDM_STEP_SYNC_1, BDM_STEP	;set current processing step
			ISTACK_RTS
	
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
			ISTACK_RTS

			;Step 3
BDM_SYNC_STEP_3		EQU	*
			;Set timeout to IC6 count (negedge)
			MOVW	TC6, TC7 			;set new timeout
			;Disable IC6 (negedge)
			BCLR	TIE, #$40 			;disable IC6 interrupt
			;Wait for interrupt 
			MOVW	#BDM_STEP_SYNC_3, BDM_STEP
			ISTACK_RTS
	
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
			LDD	#$0000
BDM_SYNC_STEP_4_2	SSTACK_PULXY 				;restore registers
			SSTACK_RTS

			;Target reset error handler
BDM_SYNC_TGTRST		EQU	*
			;Set error code 2	
			LDD	#$0002
			;Disable interrupts, clean up, and done 
			JOB	BDM_SYNC_NORSP_1

			;Target reset error handler
BDM_SYNC_NORSP		EQU	*
			;Set error code 4	
			LDD	#$0004
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
; args:   D: delay in BDM cycles
; result: D: Error code:
;            0: No problems
;            2: Target reset occured during delay (or before)
;            4: BDM_SPEED not set
; SSTACK: 14 bytes
;         X and Y are preserved
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
			;Calculate timeout (delay [BC] in D)
			SSTACK_JOBSR	BDM_BC2TC		;(SSTACK: 6 bytes)
			LDX	SSTACK_SP
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
			BRSET	PIFP, #RESET, DDM_DELAY_TGTRST ;previous reset detected
			PIEP	#RESET	
			;Wait for interrupts 
BDM_DELAY_STEP_1_1	MOVW	#BDM_STEP_DELAY_1, BDM_STEP
			ISTACK_RTS			
	
			;Step 2
BDM_DELAY_STEP_2	EQU	*
			;If timeout MSW value > 0, decrement it and wait for another max. timeout period
			LDY	SSTACK_SP
			LDX	BDM_DELAY_TO_MSW,Y 		;check timeout MSW value
			BEQ	BDM_DELAY_STEP_2_1
			LEAX	-1,X 				;decrement timeout MSW value
			STX	BDM_DELAY_TO_MSW,Y
			MOVW	TC7, TC7 			;Clear TC7 flag
			ISTACK_RTS
			;Disable timer (SP in Y)
BDM_DELAY_STEP_2_1	BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection (SP in Y)
			CLR	PIEP				;disable reset detection
			;Clean up (SP in Y)
			MOVW	#BDM_STEP_IDLE, BDM_STEP			
			CLI
			;Check if BDM_SPEED had been set (SP in Y)
			LDX	BDM_SPEED
			BNE	BDM_DELAY_STEP_2_2
			MOVW	#4, BDM_DELAY_D,Y 		;set error code
			;Done
BDM_DELAY_STEP_2_2	SSTACK_PULDXY 				;restore registers
			SSTACK_RTS
	
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
			LDY	SSTACK_SP
			MOVW	#2, BDM_DELAY_D,Y
			;Done
			JOB	BDM_DELAY_STEP_2_2	
	
;#Receive
; args:   D: data width [bits]
;         X: ACK timeout [BC] 
;         Y: data pointer [word pointer]
; result: D: Error code:
;            0: No problems
;            2: Target reset occured during transmission (or before)
;            4: BDM_SPEED not set
;            6: Communication error (BKGD low at start of transmission)
;         X: ACK pulse width [BC] (0 in case of a ACK timeout) 
; SSTACK:  bytes
;         Y is preserved
BDM_RX			EQU	*
			;Save registers
BDM_RX_ACK_TO_TC_MSW	EQU	0
BDM_RX_ACK_TO_TC_LSW	EQU	0	
BDM_RX_ACK_WIDTH_BC	EQU	0	
BDM_RX_ACK_WIDTH_TC	EQU	0	
BDM_RX_DATA_CNT		EQU	0
BDM_RX_DATA_PTR		EQU	0
BDM_RX_D		EQU	2
BDM_RX_X		EQU	4
BDM_RX_Y		EQU	6
			SSTACK_PSHYXD				;save index X, index Y, and accu D
			SSTACK_ALLOC	10
	
			;Step 1
BDM_RX_STEP_1		EQU	*	
			;Quit if reset monitor is enabled
			;and previous target reset was detected (bit count in D, BC timeout in X)
			LDY	BDM_RMCNT
			BEQ	BDM_RX_STEP_1_1
			BRSET	PIFP, #$20, BDM_RX_TGTRST
			;Check if BDM_SPEED is set (bit count in D, BC timeout in X)
			LDY	BDM_SPEED
			BEQ	BDM_RX_ 			;BDM_SPEED noty set
			;Initialize local variables (bit count in D, BC timeout in X)
			LDY	SSTACK_SP
			STD	BDM_RX_DATA_CNT,Y
			BEQ	BDM_RX_STEP_ 			;nothing to do
			MOVW	BDM_RX_Y,Y BDM_RX_DATA_PTR,Y	
			;Calculate timeout (BC timeout in X)
			TFR	X,D
			SSTACK_JOBSR	BDM_BC2TC		;(SSTACK: 6 bytes)
			LDX	SSTACK_SP
			STY	BDM_DELAY_TO_MSW,Y		;store BDM_DELAY_TO_MSW
			STD	BDM_DELAY_TO_LSW,Y		;store BDM_DELAY_TO_MSW
		



	MOVW	#6, BDM_RX_TMP,Y 		;set minimum delay for 
			EMAXD	BDM_DELAY_TMP,Y
			STY	BDM_DELAY_TO_MSW,Y		;store BDM_DELAY_TO_MSW
			


	
			;Quit if reset monitor is enabled
			;and previous target reset was detected (bit count in D, BC timeout in X)
			LDY	BDM_RMCNT
			BEQ	BDM_RX_STEP_1_1
			BRSET	PIFP, #$20, BDM_RX_ERROR
			


			;Quit if BDM_SPEED is not set (bit count in D, BC timeout in X)
BDM_RX_STEP_1_1		LDY	BDM_SPEED 			;BDM cycles*BDM_SPEED
			BEQ	BDM_RX_ERROR					
			;Quit if data width is zero (bit count in D, BC timeout in X)
			TBEQ	D, BDM_RX_ERROR
			;Quit if BKGD is zero (bit count in D, BC timeout in X)
			BRCLR	PORTB, #BKGD, BDM_RX_ERROR
			;Calculate ACK timeout (bit count in D, BC timeout in X)
			EXG	X,D
			BDM_BC2TC
			STY	[SSTACK_SP] 			;Y -> BDM_RX_ACK_TO_TC_MSW
			LDY	SSTACK_SP
			STD	BDM_RX_ACKTC_LSW,Y 		;D -> BDM_RX_ACK_TO_TC_LSW
			;Copy bit count (stack pointer in Y, bit count in X)
			STX	BDM_RX_DATA_CNT,Y	
			;Copy data pointer and clear data field (stack pointer in Y)
			LDX	BDM_RX_Y,Y
			MOVW	#$0000, 0,X
			STX	BDM_RX_DATA_PTR,Y
			;Configure timer (stack pointer in Y)	
			TIM_ENABLE	TIM_BDM			;enable timer
			BCLR	TIOS, #$60
			;Setup reset detection (stack pointer in Y)
			SEI
			LDX	BDM_RMCNT
			BEQ	BDM_RX_STEP_1_2
			PIEP	#$20	
			;Proceed at step 2
	
			;Step 2
BDM_RX_STEP_2		EQU	*
			;Setup IC5 (posedge) and OC7 (timeout)
			LDD	TC5 				;clear IC5 (posedge) IF
			BSET	TIE, #$A0			;enable interrupt
			;Drive RX pulse
			LDAA	#BKGD
			JMP	[BDM_RP_CODE]
BDM_RP_DONE		EQU	*
			;Set OC7 (timeout) to IC6 + 16*(BDM_SPEED/128)
			LDD	TC6
			ADDD	BDM_DLY_16
			STD	TC7
			;Wait for interrupt 
			MOVW	#BDM_STEP_RX_2, BDM_STEP	;set current processing step
			ISTACK_RTS
			
			;Step 3
BDM_RX_STEP_3		EQU	*
			;Capture the pulse length
			LDD	TC5 				;posedge
			SUBD	TC6				;negedge
			;Determine and store bit value (pulse length in D)
			LDY	SSTACK_SP
			TFR	D,X
			LDD	[BDM_RX_DATA_PTR,Y]
			CPD	BDM_DLY_10 			;compare pulse length with 10 cycle delay
			ROLB					;shift result into data bit
			ROLA
			EORB	#$01
			STD	[BDM_RX_DATA_PTR,Y]
			;Decrement data counter (SP in Y)
			LDD	BDM_RX_DATA_CNT,Y 		
			DBEQ	D, BDM_RX_STEP_4		;last bit has been received
			STD	BDM_RX_DATA_CNT,Y
			BITB	#$0F
			BNE	BDM_RX_STEP_3_1			;space left in current data word
			LDX	BDM_RX_DATA_PTR,Y		;decrement data pointer
			MOVW	#$0000,	2,-X			;and clear next data word
			STX	BDM_RX_DATA_PTR,Y
			;Disable IC5 (posedge)
BDM_RX_STEP_3_1		BCLR	TIE, #$20			;disable interrupt
			;Enable OC7 (timeout)
			;BSET	TIE, #$80			;enable interrupt
			;Wait for interrupt 
			MOVW	#BDM_STEP_RX_3, BDM_STEP	;set current processing step
			ISTACK_RTS	

			;Step 4
BDM_RX_STEP_4		EQU	*
			;Check if ACK pulse is expected
			LDY	SSTACK_SP
			LDD	BDM_RX_ACK_WIDTH_BC,Y
			BEQ	BDM_RX_STEP_
			;ADD end of bit timing to the ACK TIMEOUT (SP in Y)
			LDD	TC7
			ADDD	BDM_RX_ACK_TO_TC_LSW,Y
			STD	TC7
			ADCB	BDM_RX_ACK_TO_TC_MSW+1,Y
			ADCA	BDM_RX_ACK_TO_TC_MSW1,Y
			STD	BDM_RX_ACK_TO_TC_MSW,Y
			;Enable IC5 (posedge) and OC7 (timeout)
			BSET	TIE, #$A0			;enable interrupt			
			;Wait for interrupt 
			MOVW	#BDM_STEP_RX_4, BDM_STEP	;set current processing step
			ISTACK_RTS	
			
			;Step 5
BDM_RX_STEP_5		EQU	*
			;If timeout MSW value > 0, decrement it and wait for another max. timeout period
			LDX	[SSTACK_SP] 			;check timeout MSW value
			BEQ	BDM_RX_ACK_ERROR			
			LEAX	-1,X 				;decrement timeout MSW value
			STX	[SSTACK_SP]
			MOVW	TC7, TC7 			;Clear TC7 flag
			ISTACK_RTS

			;Step 6
BDM_RX_STEP_6		EQU	*
			;Capture the pulse length
			LDD	TC5 				;posedge
			SUBD	TC6				;negedge
			;Stop blocking interrupts
			BCLR	TIE, #$E0			;disable interrupt
			CLI
			;Convert pulse length in BC (pulse length in D)
			BDM_TC2BC
			TBEQ	Y, BDM_RX_ACK_ERROR 		;pulse length is too long
			LDY	SSTACK_SP
			STD	BDM_RX_ACK_WIDTH_BC,Y
	


	
			;Step 4
BDM_RX_STEP_4		EQU	*
			;Disable timer
			BCLR	TIE, #$E0 			;disable timer interrupts	
			TIM_DISABLE	TIM_BDM			;disable timer
			;Disable reset detection
			CLR	PIEP				;disable reset detection
			;Clean up
			MOVW	#BDM_STEP_IDLE, BDM_STEP
			CLI
			;Done
			SSTACK_DEALLOC	1			;free allocated memory
			SSTACK_PULDXY 				;restore registers
			SSTACK_RTS

			;Error handler
BDM_RX_ERROR		EQU	*
			;Set return value 
			LDX	SSTACK_SP
			CLRA
			CLRB
			STD	BDM_RX_D,Y
			;Disable timer, disable reset detection, clean up
			JOB	BDM_RX_STEP_4	
	
	
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
; args:   D: data width [bits]
;         X: ACK timeout [BC] 
;         Y: data pointer [word pointer]
; result: D: Error code:
;            0: No problems
;            2: Target reset occured during transmission (or before)
;            4: BDM_SPEED not set
;            6: Target out of sync (BKGD low at start of transmission)
;            8: ACK pulse timed out
;           10: ACK pulse too long
;         X: ACK pulse width [BC] (0 in case of a ACK timeout) 
; SSTACK:  bytes
;         Y is preserved
BDM_TX			EQU	*







	
	


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
			BCLR	TCL1, #$03	;disconnect OC5 and OC6 from output

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
							
BDM_TC6_TAB		EQU	*			
			DW	ERROR_ISR		;BDM interface not in use 
			DW	ERROR_ISR		;RESET step 1		  
			DW	ERROR_ISR		;SYNC step 1		  
			DW	BDM_SYNC_STEP_3		;SYNC step 2		  
			DW	ERROR_ISR		;SYNC step 3		  
			DW	ERROR_ISR		;DELAY step 1             
			DW	ERROR_ISR		;RX step 2             
			DW	ERROR_ISR		;RX step 3             
							
BDM_TC7_TAB		EQU	*			
			DW	ERROR_ISR		;BDM interface not in use 
			DW	BDM_RESET_STEP_2	;RESET step 1		  
			DW	BDM_SYNC_STEP_2		;SYNC step 1		  
			DW	BDM_SYNC_ERROR		;SYNC step 2		  
			DW	BDM_SYNC_ERROR		;SYNC step 3		  
			DW	BDM_DELAY_STEP_2	;DELAY step 1             
			DW	BDM_RX_ERROR		;RX step 2             
			DW	BDM_RX_STEP_2		;RX step 3             
							
BDM_TGTRST_TAB		EQU	*			
			DW	ERROR_ISR		;BDM interface not in use 
			DW	ERROR_ISR		;RESET step 1		  
			DW	BDM_SYNC_ERROR		;SYNC step 1		  
			DW	BDM_SYNC_ERROR		;SYNC step 2		  
			DW	BDM_SYNC_ERROR		;SYNC step 3		  
			DW	BDM_DELAY_ERROR		;DELAY step 1             
			DW	BDM_RX_ERROR		;RX step 2             
			DW	BDM_RX_ERROR		;RX step 3             

;#RX pulse jump table
BDM_RP_TAB		EQU	*
			DW	BDM_RP_2C
			DW	BDM_RP_3C
			DW	BDM_RP_4C
			DW	BDM_RP_3X2C
			DW	BDM_RP_3X3C
			DW	BDM_RP_3X4C
	
BDM_TABS_END		EQU	*



