#ifndef CUBE_COMPILED
#define CUBE_COMPILED
;###############################################################################
;# S12CBase - CUBE - LED Cube Driver                                           #
;###############################################################################
;#    Copyright 2016 Dirk Heisswolf                                            #
;#    This file is part of the S12CBase framework for NXP's S12C MCU           #
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
;#                                                                             #
;#   Y                              Anode connections:                         #
;#  /         C3---C7---C11--C15    C0: PAD0     C8:  PP0                      #
;#  --X       /    /    /    / |    C1: PAD1     C9:  PP1                      #
;# |        C2---C6---C10--C14 @    C2: PAD2     C10: PP2                      #
;# Z        /    /    /    / |/|    C3: PAD3     C11: PP3                      #
;#        C1---C5---C9---C13 @ @    C4: PAD4     C12: PP4                      #
;#        /    /    /    / |/|/|    C5: PAD5     C13: PP5                      #
;#  L0  C0---C4---C8---C12 @ @ @    C6: PE0      C14: PS2                      #
;#       |    |    |    | /|/|/     C7: PE1      C15: PS3                      #
;#  L1  C0---C4---C8---C12 @ @                                                 #
;#       |    |    |    | /|/       Cathode connections:                       #
;#  L2  C0---C4---C8---C12 @        L0: PT0                                    #
;#       |    |    |    | /         L1: PT1                                    #
;#  L3  C0---C4---C8---C12          L2: PT2                                    #
;#                                  L3: PT3                                    #
;#                                                                             #
;# LED state format (unsigned 64-bit integer):                                 #
;#                                                                             #
;#                  C15         C14         C13         C12                    #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              63       60 59       56 55       52 51       48                #
;#                  C11         C10         C9          C8                     #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              47       44 43       40 39       36 35       32                #
;#                  C7          C6          C5          C4                     #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              31       28 27       24 23       20 19       16                #
;#                  C3          C2          C1          C0                     #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              15       12 11        8  7        4  3        0                #
;#                                                                             #
;#    This is the low level driver for the CUBE module.                        #
;#                                                                             #
;#    This module provides the following functions to the main program:        #
;#    CUBE_QUEUE_FRAME  - This function puts a frame pattern into the display  #
;#                        queue.                                               #
;#    CUBE_QUEUE_FRAMES - This function puts a frame pattern multiple times    #
;#      	          into the display queue.                              #	
;#                        queue.                                               #
;#                                                                             #
;#    The display queue is emptied at FRAMERATE frames/sec. When the display   #
;#    runs empty, the last submitted frame is repeated until new content is    #
;#    provided. Each frame is rebeated SUBFRAMES times.                        #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register definitions                                            #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    GPIO   - GPIO driver                                                     #
;###############################################################################
;# Version History:                                                            #
;#    August 12, 2016                                                          #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Timing
;------
;Frame rate
#ifndef	CUBE_REFRESHRATE
CUBE_REFRESHRATE	EQU	100 		;default is 100 fps
#endif
;Subframe count
#ifndef	CUBE_SUBFRAMES
CUBE_SUBFRAMES		EQU	4 		;default is 4 subframes
#endif

;Buffer
;------
;Buffer depth
#ifndef	CUBE_BUF_DEPTH
CUBE_BUF_DEPTH		EQU	8 		;default is 8 frames
#endif

;API
;---
;API frequency
#ifndef	CUBE_API_FREQ
CUBE_API_FREQ		EQU	20000 		;default is 20kHz
#endif
;API trim value
;CUBE_API_TRIM		EQU	0		;default is no trimming

;Start-up pattern
;----------------
#ifndef	CUBE_START_ALL_ON
#ifndef	CUBE_START_ALL_OFF
CUBE_START_ALL_ON	EQU	1		;default: start with all LEDs lit
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Cube dimensions 
CUBE_COL_CNT		EQU	16 			     ;number of columns in cube
CUBE_LEV_CNT		EQU	 4 			     ;number of levels in cube
CUBE_LED_CNT		EQU	CUBE_COL_CNT*CUBE_LEV_CNT    ;number of LEDs in cube
CUBE_PAT_SIZE		EQU	CUBE_LED_CNT/8		     ;size of a LED pattern in bytes

;Frame sequence
CUBE_COL_IDX_MASK	EQU	(CUBE_COL_CNT-1)<<1 	     ;column index mask
CUBE_COL_PAT_PORT	EQU	DDRT			     ;column pattern port

;Buffer
CUBE_BUF_SIZE		EQU	CUBE_BUF_DEPTH*CUBE_PAT_SIZE ;buffer size in bytes
CUBE_BUF_MASK		EQU	(CUBE_BUF_DEPTH-1)*CUBE_PAT_SIZE;mask for index roll-over
	
;API clock divider
CUBE_API_DIV		EQU	(CUBE_API_FREQ/(4*CUBE_REFRESHRATE))-1

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef CUBE_VARS_START_LIN
			ORG 	CUBE_VARS_START, CUBE_VARS_START_LIN
#else
			ORG 	CUBE_VARS_START
CUBE_VARS_START_LIN	EQU	@			
#endif	
			ALIGN	1

;Buffer 
CUBE_BUF		DS	CUBE_BUF_SIZE	;frame buffer
CUBE_BUF_IN		DS	1		;points to the next free space
CUBE_BUF_OUT		DS	1		;points to the oldest entry
	
;Frame sequence
CUBE_COL_IDX		DS	1 		;current column index
CUBE_COL_PAT		DS	1 		;next column pattern
CUBE_SUBFRAME_CNT	DS	1 		;subframe counter
	
CUBE_VARS_END		EQU	*
CUBE_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	CUBE_INIT, 0
			;Initialize buffer
#ifdef CUBE_START_ALL_ON
			LDD	#$FFFF			;start with all LEDs on
#else
			LDD	#$0000			;start with all LEDs off
#endif
			LDX	CUBE_BUF 		;buffer pointer in X
			STD	2,X+			;write initial pattern into
			STD	2,X+			; the buffer
			STD	2,X+			;
			STD	2,X+			;
			MOVW	#(CUBE_PAT_SIZE<<8), 2,X+;initialize in:out
			;Initialize frame sequence (var pointer in X)
#ifdef CUBE_START_ALL_ON
			MOVW	#((CUBE_COL_IDX_MASK<<8)|$0F), 2,X+
#else
			MOVW	#(CUBE_COL_IDX_MASK<<8), 2,X+
#endif
			MOVB	#CUBE_SUBFRAMES, 1,X+   ;initialize subframe counter
			;Initialize API
			MOVW	#CUBE_API_DIV, CPMUAPIRH;set clock divider
#ifdef	CUBE_API_TRIM
			MOVW	#(((APIFE|APIE|APIF)<<8)|CUBE_API_TRIM), CPMUAPICTL
#endif
			MOVB	#(APIFE|APIE|APIF), CPMUAPICTL
#endif
#emac

;#User functions
;#--------------
;#Put a LED pattern into the display queue - non-blocking
; args:   X: pointer to 64-bit LED pattern
; result: C-flag: set if successful
; SSTACK: 9/10 bytes
;         X, Y, and D are preserved
#macro	CUBE_DISP_NB, 0
			SSTACK_JOBSR	CUBE_DISP_NB, CUBE_DISP_NB_SSU
#emac

;#Put a LED pattern into the display queue - blocking
; args:   X: pointer to 64-bit LED pattern
; result: none
; SSTACK: 11/12 bytes
;         X, Y, and D are preserved
#macro	CUBE_DISP_BL, 0
			SSTACK_JOBSR	CUBE_DISP_BL, CUBE_DISP_BL_SSU
#emac

;#Put a LED pattern multiple times into the display queue - non-blocking
; args:   X: pointer to 64-bit LED pattern
;         A: number of repetitions
; result: A: numbrer of remaining repetitions (0 if successful)
;         C-flag: set if successful
; SSTACK: 11/12 bytes
;         X, Y, and B are preserved
#macro	CUBE_DISP_MULT_NB, 0
			SSTACK_JOBSR	CUBE_DISP_MULT_NB, CUBE_DISP_MULT_NB_SSU
#emac

;#Put a LED pattern multiple times into the display queue - blocking
; args:   X: pointer to 64-bit LED pattern
;         A: number of repetitions
; result: A: 0
; SSTACK: 13/14 bytes
;         X, Y, and B are preserved
#macro	CUBE_DISP_MULT_BL, 0
			SSTACK_JOBSR	CUBE_DISP_MULT_BL, CUBE_DISP_MULT_BL_SSU
#emac

;# Macros for internal use
;#------------------------
;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved
#macro	CUBE_MAKE_BL, 2
			;Disable interrupts
LOOP			SEI
			;Call non-blocking function
			//SSTACK_PREPUSH	\2
			JOBSR	\1
			BCC	WAIT 		;function unsuccessful
			;Enable interrupts
			CLI
			;Done
			SSTACK_PREPULL	2
			RTS
			;Wait for next interrupt
WAIT			ISTACK_WAIT
			;Try again
			SSTACK_PREPUSH	\2
			JOB	LOOP	
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef CUBE_CODE_START_LIN
			ORG 	CUBE_CODE_START, CUBE_CODE_START_LIN
#else
			ORG 	CUBE_CODE_START
#endif
	
;#Put a LED pattern into the display queue - non-blocking
; args:   X: pointer to 64-bit LED pattern
; result: C-flag: set if successful
; SSTACK: 9/10 bytes
;         X, Y, and D are preserved
;#ifcpu	S12X		
;CUBE_DISP_NB_SSU	EQU	10 					;SSTACK usage
;#else
CUBE_DISP_NB_SSU	EQU	9 					;SSTACK usage
;#endif	
CUBE_DISP_NB		EQU	*
			;Save registers (data pointer in X)
			PSHY						;save Y
			PSHX						;save X
			PSHD						;save D
			CLC						;default result: failure
;#ifcpu	S12X		
;			PSHCW						;save CCRW (incl. default result)
;#else
			PSHC						;save CCRW (incl. default result)
;#endif	
			;Check if there is room for this entry (data pointer in X)
			LDD	CUBE_BUF_IN 				;in:out -> D
			ADDA	#CUBE_PAT_SIZE 				;increment index
			ANDA	#CUBE_BUF_MASK 				;roll-over index
			CBA						;check if buffer is full
			BEQ	CUBE_DISP_NB_1 				;buffer is full
			;Copy LED pattern into buffer (data pointer in X, new in in A)
			LDY	CUBE_BUF 				;buffer pointer -> Y
			LDAB	CUBE_BUF_IN 				;old in -> B
			LEAY	B,Y 					;add in offset
			MOVW	2,X+, 2,Y+ 				;copy data C15:C12
			MOVW	2,X+, 2,Y+ 				;copy data C15:C12
			MOVW	2,X+, 2,Y+ 				;copy data C15:C12
			MOVW	2,X+, 2,Y+ 				;copy data C15:C12
			STAA	CUBE_BUF_IN 				;update in index
			;Signal success
;#ifcpu	S12X		
;			BSET	1,SP, #1				;set C-flag
;#else
			BSET	0,SP, #1				;set C-flag
;#endif	
			;Done
CUBE_DISP_NB_1		SSTACK_PREPULL	 CUBE_DISP_NB_SSU		;check SSTACK
			RTI						

	
;#Put a LED pattern into the display queue - blocking
; args:   X: pointer to 64-bit LED pattern
; result: none
; SSTACK: 11/12 bytes
;         X, Y, and D are preserved
CUBE_DISP_BL_SSU	EQU	CUBE_DISP_NB_SSU+2 			;SSTACK usage
CUBE_DISP_BL		EQU	*
			CUBE_MAKE_BL	CUBE_DISP_NB, CUBE_DISP_NB_SSU

;#Put a LED pattern multiple times into the display queue - non-blocking
; args:   X: pointer to 64-bit LED pattern
;         A: number of repetitions
; result: A: numbrer of remaining repetitions (0 if successful)
;         C-flag: set if successful
; SSTACK: 11/12 bytes
;         X, Y, and B are preserved
CUBE_DISP_MULT_NB_SSU	EQU	CUBE_DISP_NB_SSU+2	
CUBE_DISP_MULT_NB	EQU	*
			;Queue LED pattern (remaining repetitions in A) 
CUBE_DISP_MULT_NB_1	SSTACK_JOBSR	CUBE_DISP_NB, CUBE_DISP_NB_SSU
			BCC	CUBE_DISP_MULT_NB_2 	;unsuccessful
			DBNE	A, CUBE_DISP_MULT_NB_1	;decrement repetitions and repeat
			;Signal sucess (0 in A)
			SEC
			;Done
CUBE_DISP_MULT_NB_2	RTS

;#Put a LED pattern multiple times into the display queue - blocking
; args:   X: pointer to 64-bit LED pattern
;         A: number of repetitions
; result: A: 0
; SSTACK: 13/14 bytes
;         X, Y, and B are preserved
CUBE_DISP_MULT_BL_SSU	EQU	CUBE_DISP_MULT_NB_SSU+2	
CUBE_DISP_MULT_BL	EQU	*
			CUBE_MAKE_BL	CUBE_DISP_MULT_NB, CUBE_DISP_MULT_NB_SSU

;ISR
;---
;#API ISR
CUBE_ISR		EQU	*
			;Drive pre-determined column pattern 
			LDAA	#2 			;column index increment -> A
			LDAB	CUBE_COL_IDX		;old column index -> B
			ABA				;new column index -> A
			ANDA	#CUBE_COL_IDX_MASK	;
			STAA	CUBE_COL_IDX		;update colum index
			LDX	CUBE_COL_PORT_TAB 	;port look-up table -> X
			LEAX	B,X
			LDY	CUBE_COL_PIN_TAB	;pin look-up table -> Y
			LDAB	A,Y			;new column pin -> B
			CLR	[0,X]			;disable old column
			MOVB	CUBE_COL_PAT, CUBE_COL_PAT_PORT;update column pattern
			STAB	[2,X]			;enable new column
			;Update subframe count (new column index in A) 
			CMPA	#CUBE_COL_IDX_MASK 	;check if pattern is complete
			BNE	CUBE_ISR_1 		;pattern not complete
			DEC	CUBE_SUBFRAME_CNT	;decrement subframe count
			BNE	CUBE_ISR_1		;frame not complete
			;Advance pattern buffer
			LDD	CUBE_BUF_IN 		;in -> A, out -> B
			ADDB	#CUBE_PAT_SIZE		;increment out
			ANDB	CUBE_BUF_MASK
			CBA	
			BEQ	CUBE_ISR_1 		;keep last pattern in queue
			STAB	CUBE_BUF_OUT		;update out
			;Update column pattern
CUBE_ISR_1		LDX	CUBE_BUF 		;buffer pointer -> X
			;LDAA	CUBE_BUF_OUT		;out -> A
			;LDAB	CUBE_COL_IDX		;column index -> B
			LDD	CUBE_BUF_OUT		;out -> A, column index -> B
			ADDA	#CUBE_PAT_SIZE		;calculate offset
			LSRB                            ; to access column pattern
			LSRB				;
			SBA				;
			LDAA	A,X			;raw column patern -> A
			BRCLR	CUBE_COL_IDX,#2,CUBE_ISR_2;no shift required
			LSRA				;shift column pattern to lower nibble
			LSRA				;
			LSRA				;
			LSRA				;
CUBE_ISR_2		ANDA	#$0F			;mask column pattern
			STAA	CUBE_COL_PAT		;update column pattern
			;Done	
			ISTACK_RTI
	
CUBE_CODE_END		EQU	*
CUBE_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef CUBE_TABS_START_LIN
			ORG 	CUBE_TABS_START, CUBE_TABS_START_LIN
#else
			ORG 	CUBE_TABS_START
#endif	

;Column port table
;-----------------
CUBE_COL_PORT_TAB	DW	DDR1AD	;C0:  PAD0 
			DW	DDR1AD	;C1:  PAD1
			DW	DDR1AD	;C2:  PAD2
			DW	DDR1AD	;C3:  PAD3
			DW	DDR1AD	;C4:  PAD4
			DW	DDR1AD	;C5:  PAD5
			DW	DDRE	;C6:  PE0 
			DW	DDRE	;C7:  PE1 
			DW	DDRP	;C8:  PP0  
			DW	DDRP	;C9:  PP1  
			DW	DDRP	;C10: PP2  
			DW	DDRP	;C11: PP3  
        		DW	DDRP	;C12: PP4  
        		DW	DDRP	;C13: PP5  
        		DW	DDRS	;C14: PS2  
        		DW	DDRS	;C15: PS3  
	
;Column pin table
;----------------
CUBE_COL_PIN_TAB	DB	DDR1AD0	;C0:  PAD0 
			DB	DDR1AD1	;C1:  PAD1
			DB	DDR1AD2	;C2:  PAD2
			DB	DDR1AD3	;C3:  PAD3
			DB	DDR1AD4	;C4:  PAD4
			DB	DDR1AD5	;C5:  PAD5
			DB	DDRE0	;C6:  PE0 
			DB	DDRE1	;C7:  PE1 
			DB	DDRP0	;C8:  PP0  
			DB	DDRP1	;C9:  PP1  
			DB	DDRP2	;C10: PP2  
			DB	DDRP3	;C11: PP3  
        		DB	DDRP4	;C12: PP4  
        		DB	DDRP5	;C13: PP5  
        		DB	DDRS2	;C14: PS2  
        		DB	DDRS3	;C15: PS3  
	
CUBE_TABS_END		EQU	*
CUBE_TABS_END_LIN	EQU	@
#endif
