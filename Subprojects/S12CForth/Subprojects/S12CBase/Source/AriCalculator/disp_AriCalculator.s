#ifndef DISP_COMPILED
#define	DISP_COMPILED	
;###############################################################################
;# AriCalculator - DISP - LCD Driver (ST7565R) (AriCalculator RevC)            #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU family.   #
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
;#    This is the low level driver for LCD using a ST7565R controller. This    #
;#    driver assumes, that the ST7565R is connected via the 4-wire SPI         #
;#    interface. The default pin mapping matches AriCalculator hardware RevC   #
;#                                                                             #
;#    By convention, the display must be switched to data mode when idle.      #
;#                                                                             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#    VECMAP - Vector Map                                                      #
;#    CLOCK  - Clock driver                                                    #
;#    GPIO   - GPIO driver                                                     #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    GPIO   - GPIO driver                                                     #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 24, 2012                                                           #
;#      - Initial release                                                      #
;#    August 18, 2017                                                          #
;#      - Made init stream configurable                                        #
;#      - Reduced code size                                                    #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;#Bus frequency
#ifndef CLOCK_BUS_FREQ	
CLOCK_BUS_FREQ		EQU	25000000	;default is 25 MHz
#endif

;#Baud rate
#ifndef DISP_BAUD
DISP_BAUD		EQU	12000000	;default is 12 Mbit/s
#endif

;#RESET output
#ifndef DISP_RESET_PORT
DISP_RESET_PORT		EQU	PTS 		;default is port S	
#endif
#ifndef DISP_RESET_PIN
DISP_RESET_PIN		EQU	PS3		;default is PS3	
#endif
	
;#A0 output
#ifndef DISP_A0_PORT
DISP_A0_PORT		EQU	PTS 		;default is port S	
#endif
#ifndef DISP_A0_PIN
DISP_A0_PIN		EQU	PS4		;default is PS4	
#endif

;#Buffer size
#ifndef DISP_BUF_SIZE
DISP_BUF_SIZE		EQU	16 		;depth of the command buffer
#endif

;#Display initialization stream
;DISP_SEQ_INIT_START	EQU	...		;start of alternatie initialization stream
;DISP_SEQ_INIT_END	EQU	...		;end of alternatie initialization stream
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Baud rate divider
DISP_SPPR		EQU	((CLOCK_BUS_FREQ/(2*DISP_BAUD))-1)&7
DISP_SPR		EQU	0	

;#SPI configuration
DISP_SPICR1_CONFIG	EQU	%00011110 	;only SPE and SPTIE will be modified
				;SSSMCCSL 
				;PPPSPPSS 
				;IETTOHOB 
				;E IRLAEF 
				;  E    E 
DISP_SPICR2_CONFIG	EQU	%00011001
				; X MB SS
				; F OI PP
				; R DD IC
				; W FI S0
				;   ER W
				;   NO A
				;    E I
DISP_SPIBR_CONFIG	EQU	((DISP_SPPR<<4|(DISP_SPR)))
	
;#Escape sequences
DISP_ESC_START		EQU	$E3 		;start of eccape sequence (NOP)
DISP_ESC_ESC		EQU	$FF		;transmit escape character
DISP_ESC_CMD		EQU	$FE		;switch to command mode
DISP_ESC_DATA		EQU	$FD		;switch to data mode

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DISP_VARS_START_LIN
			ORG 	DISP_VARS_START, DISP_VARS_START_LIN
#else
			ORG 	DISP_VARS_START
DISP_VARS_START_LIN	EQU	@			
#endif	

DISP_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1
;#Command buffer  
DISP_BUF		DS	DISP_BUF_SIZE
DISP_BUF_IN		DS	1		;points to the next free space
DISP_BUF_OUT		DS	1		;points to the oldest entry

DISP_AUTO_LOC2		EQU	*		;2nd auto-place location
			UNALIGN	((~DISP_AUTO_LOC1)&1)
;#Repeat counter (0=no repeat, $FF=handle escape character)
DISP_RPTCNT		EQU	((DISP_AUTO_LOC1&1)*DISP_AUTO_LOC1)+((~(DISP_AUTO_LOC1)&1)*DISP_AUTO_LOC2)
	
DISP_VARS_END		EQU	*
DISP_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	DISP_INIT, 0
			;Deassert display reset 
			;BSET	DISP_RESET_PORT, #DISP_RESET_PIN
			;BCLR	DISP_A0_PIN,     #DISP_A0_PORT
			MOVB	#DISP_RESET_PIN, DISP_RESET_PORT ;shortcut
			;Initialize Variables 
			MOVW	#$0000, DISP_BUF_IN
			CLR	DISP_RPTCNT
			;Initialize SPI	
			MOVW	#((DISP_SPICR1_CONFIG<<8)|DISP_SPICR2_CONFIG), SPICR1
			MOVB	#DISP_SPIBR_CONFIG, SPIBR
			TST	SPISR 						;read SPISR
			TST	SPIDRL			   			;clear SPIF flag
			;Setup display	
			LDX	#DISP_SEQ_INIT_START
			LDD	#DISP_SEQ_INIT_END
			DISP_STREAM_BL
#emac

;# Essential functions
;---------------------
;#Determine how much space is left on the buffer
; args:   none
; result: B: Space left on the buffer in bytes
; SSTACK: 0 bytes
;         X and Y are preserved 
#macro	DISP_BUF_FREE, 0
			;Check if the buffer is full
			LDD	DISP_BUF_IN 					;IN->A; OUT->B
			SBA
			ANDA	#(DISP_BUF_SIZE-1) 				;buffer usage->A
			NEGA
			ADDA	#(DISP_BUF_SIZE-1)
#emac	
	
;#Transmit commands and data (non-blocking)
; args:   B: buffer entry
; result: C: 1=successful, 0=nothing has been done
; SSTACK: 5 bytes
;         X, Y and D are preserved 
#macro	DISP_TX_NB, 0
			SSTACK_JOBSR	DISP_TX_NB, 5
#emac

;#Transmit commands and data (blocking)
; args:   B: buffer entry
; result: none
; SSTACK: 7 bytes
;         X, Y and D are preserved 
#macro	DISP_TX_BL, 0
			SSTACK_JOBSR	DISP_TX_BL, 7
#emac

;#Transmit a sequence of commands and data (non-blocking)
; args:   X: pointer to the start of the sequence
;         D: pointer to the end of the sequence
; result: X: pointer to the start of the remaining sequence
;         C: 1 = successful, 0=buffer full
; SSTACK: 9 bytes
;         Y and D are preserved 
#macro	DISP_STREAM_NB, 0
			SSTACK_JOBSR	DISP_STREAM_NB, 9
#emac

;#Transmit a sequence of commands and data (non-blocking)
; args:   X: pointer to the start of the sequence
;         D: pointer to the end of the sequence
; result: X: points to the byte after the sequence
; SSTACK: 11 bytes
;         Y and D are preserved 
#macro	DISP_STREAM_BL, 0
			SSTACK_JOBSR	DISP_STREAM_BL, 11
#emac

;# Convenience macros
;--------------------
;#Transmit immediate commands and data (blocking)
; args:   1: buffer entry
; result: B: buffer entry
; SSTACK: 7 bytes
;         X, Y and A are preserved 
#macro	DISP_TX_IMM_BL, 1
			LDAB	#\1
			SSTACK_JOBSR	DISP_TX_BL, 7
#emac

;#Switch to command mode (blocking)
; args:   none
; result: none
; SSTACK: 0 bytes
;         X, Y and A are preserved 
#macro	DISP_CMD_MODE_BL, 0
			;Transmit escape sequence
			DISP_TX_IMM_BL	DISP_ESC_START 				;send ecape character
			DISP_TX_IMM_BL	DISP_ESC_CMD 				;switch to command mode
#emac

;#Switch to data mode (blocking)
; args:   none
; result: none
; SSTACK: 0 bytes
;         X, Y and A are preserved 
#macro	DISP_DATA_MODE_BL, 0
			;Transmit escape sequence
			DISP_TX_IMM_BL	DISP_ESC_START 				;send ecape character
			DISP_TX_IMM_BL	DISP_ESC_DATA 				;switch to data mode
#emac

;#Set column (blocking)
; args:   A: column (0 - 127) 
; result: none
; SSTACK: 0 bytes
;         X, Y and A are preserved 
#macro	DISP_SET_COL, 0
			;Set column (column in A)
			TAB	     						;column -> B
			SEC							;add opcode
			RORB							;and shift to lower nibble
			LSRB							;
			LSRB							;
			LSRB							;
			DISP_TX_BL		  				;sent command
			TAB 							;column -> B
			ANDB	#$0F 						;mask column number
			DISP_TX_BL		  				;sent command
#emac

;#Set input position (blocking)
; args:   A: column (0 - 127)
;  	  B: page   (0 - 7) 
; result: none
; SSTACK: 0 bytes
;         X, Y and A are preserved 
#macro	DISP_SET_POS, 0
			;Set page (column in A, page in B)			
			ANDB	#$07 						;mask page number
			ORAB	#$B0 						;add opcode
			DISP_TX_BL		  				;sent command
			;Set column (column in A)
			DISP_SET_COL
#emac

;#Transmit a sequence of commands and data (non-blocking)
; args:   1: pointer to the start of the sequence
;         2: pointer past the end of the sequence
; result: none
; SSTACK: 11 bytes
;         Y is preserved 
#macro	DISP_STREAM_FROM_TO_BL, 2
			LDX	#\1
			LDD	#\2
			DISP_STREAM_BL
#emac
	
;# Macros for internal use
;-------------------------
;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function 
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
#macro	DISP_MAKE_BL, 2
			SCI_MAKE_BL \1 \2
#emac

;# Common data streams
;---------------------
;#Command mode
#macro DISP_SEQ_CMD, 0
			DB	DISP_ESC_START 			;escape sequence
			DB	DISP_ESC_CMD			;switch to command mode
#emac

;#Command mode
#macro DISP_SEQ_DATA, 0
			DB	DISP_ESC_START 			;escape sequence
			DB	DISP_ESC_DATA			;switch to data mode
#emac

;#Display configuration
#macro DISP_SEQ_CONFIG, 0
			;DISP_SEQ_CMD				;switch to command mode
			;Initialize the display
			DB	$40 				;start display at line 0
			;DB	$A0				;flip display
			;DB	$C8				;reverse COM63~COM0
			DB	$A1				;flip display
			DB	$C0				;normal COM0~COM63
			DB	$A2				;set bias 1/9 (Duty 1/65) ;
			DB	$2F 				;enabable booster, regulator and follower
			DB	$F8				;set booster to 4x
			DB	$00				;
			DB	$27				;set ref value to 6.5
			DB	$81				;set alpha value to 47
			DB	$10                             ;V0=alpha*(1-(ref/162)*2.1V =[4V..13.5V]
			DB	$AC				;no static indicator
			DB	$00				;
			DB	$AF 				;enable display
			;DB	$B0				;select page 0
			;DB	$10				;select column 0
			;DB	$00				;
#emac

;#Clear screen
#macro DISP_SEQ_CLEAR, 0
			DB  $B0 $10 $00                     	;set page 0
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
			DB  $B1 $10 $00                     	;set page 1
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
			DB  $B2 $10 $00                     	;set page 2
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
			DB  $B3 $10 $00                     	;set page 3
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
			DB  $B4 $10 $00                     	;set page 4
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
			DB  $B5 $10 $00                     	;set page 5
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
			DB  $B6 $10 $00                     	;set page 6
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
			DB  $B7 $10 $00                     	;set page 7
			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
			DB  DISP_ESC_START $7F $00          	;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
#emac	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DISP_CODE_START_LIN
			ORG 	DISP_CODE_START, DISP_CODE_START_LIN
#else
			ORG 	DISP_CODE_START
DISP_CODE_START_LIN	EQU	@	
#endif
	
;# Essential functions
;---------------------
;#Transmit commands and data (non-blocking)
; args:   B: buffer entry
; result: C: 1 = successful, 0=buffer full
; SSTACK: 5 bytes
;         X, Y and D are preserved 
DISP_TX_NB		EQU	*
			;Save registers (buffer entry in B)
			PSHX							;push index X onto the SSTACK
			PSHA							;push accu A onto the SSTACK
			;Store buffer entry (buffer entry in B)
			LDX	#DISP_BUF 					;buffer address->X
			LDAA	DISP_BUF_IN
			STAB	A,X		  				;write data into buffer
			INCA			  				;advance IN index
			ANDA	#(DISP_BUF_SIZE-1) 				;buffer usage->A
			CMPA	DISP_BUF_OUT 					;check if the buffer is full
			BEQ	DISP_TX_NB_2 					;buffer is full
			STAA	DISP_BUF_IN
			;Enable SPI transmit interrupt 
			MOVB	#(SPE|SPTIE|DISP_SPICR1_CONFIG), SPICR1
			;Return positive status
			SSTACK_PREPULL	5
			SEC							;return positive status
DISP_TX_NB_1		PULA							;pull accu A from the SSTACK
			PULX							;pull index B from the SSTACK
			;Done
			RTS
			;Return negative status
DISP_TX_NB_2		SSTACK_PREPULL	5
			CLC							;return negative status
			JOB	DISP_TX_NB_1	

;#Transmit commands and data (blocking)
; args:   B: buffer entry
; result: none
; SSTACK: 7 bytes
;         X, Y and D are preserved 
DISP_TX_BL		EQU	*
			DISP_MAKE_BL	DISP_TX_NB, 5	

;#Transmit a sequence of commands and data (non-blocking)
; args:   X: pointer to the start of the sequence
;         D: pointer to the end of the sequence
; result: X: pointer to the start of the remaining sequence
;         C: 1 = successful, 0=buffer full
; SSTACK: 9 bytes
;         Y and D are preserved 
DISP_STREAM_NB		EQU	*
			;Save registers (start pointer in X, end pointer in D)
			PSHD							;push accu D onto the SSTACK
			;Transmit next byte (start pointer in X, end pointer in D)
DISP_STREAM_NB_1	LDAB	1,X+ 						;get data
			DISP_TX_NB 						;transmit data (SSTACK: 5 bytes)
			BCC	DISP_STREAM_NB_3				;TX buffer is full
			CPX	0,SP 						;check if stream is complete
			BLO	DISP_STREAM_NB_1 				;transmit next byte
			;Successful transmission (new start pointer in X, $0000 in Y)
			SSTACK_PREPULL	3
			SEC							;signal success
DISP_STREAM_NB_2	PULD							;pull accu B from the SSTACK
			;Done
			RTS
			;TX buffer is full (new start pointer+1 in X, new byte count in Y)
DISP_STREAM_NB_3	DEX	 						;restore pointer
			;Unsucessful transmission (new start pointer in X, new byte count in Y)			
			SSTACK_PREPULL	3
			CLC							;signal success
			JOB	DISP_STREAM_NB_2 				; done

;#Transmit a sequence of commands and data (non-blocking)
; args:   X: pointer to the start of the sequence
;         D: pointer to the end of the sequence
; result: X: points to the byte after the sequence
; SSTACK: 11 bytes
;         Y and D are preserved 
DISP_STREAM_BL		EQU	*
			DISP_MAKE_BL	DISP_STREAM_NB, 8	
	
;#SPI ISR for transmitting data to the ST7565R display controller
;----------------------------------------------------------------
;+-------------------------------------------------------------+
;| !!! This ISR will not work if a mode switch is required !!! |
;| !!!   before the first character has been transmitted   !!! |
;+-------------------------------------------------------------+	
DISP_ISR		EQU	*
			;Check and clear SPIF flag
			;SPIF cleared: transmssion still ongoing 
			;SPIF set:     transmssion complete
			;Check if DISP buffer is empty
			LDD	DISP_BUF_IN 					;IN->A, OUT->B
			CBA							;check if 
			BEQ	DISP_ISR_6 					;DISP buffer is empty
			;Check repeat/escape status (OUT in B) 
			;DISP_RPTCNT = $00:      no repeat loop, escaping enabled 
			;DISP_RPTCNT = $01:      last iteration if a repeat loop, escaping disabled 
			;DISP_RPTCNT = $02..$FD: repeat loop ongoing, escaping disabled 
			;DISP_RPTCNT = $FF:      escape sequence started 
			LDX	#DISP_BUF 					;buffer pointer -> X
			LDAB	B,X 						;char -> B
			LDAA	DISP_RPTCNT 					;repeat counter -> A
			BNE     DISP_ISR_7 					;repeat loop or escape sequence in progress
		        ;Check for new escape character (repeat counter in A, char in B) 
			CMPB	#DISP_ESC_START					;check for escape character
			BEQ	DISP_ISR_8 					;escape character found	
			;Transmit character (repeat counter in A, char in B) 
DISP_ISR_1		BRCLR	SPISR,#SPTEF,DISP_ISR_5 			;wait for TX buffer to be empty
DISP_ISR_2		TST	SPIDRL			   			;clear SPIF flag
			STAB	SPIDRL 						;transmit character
			;Check repeat count (repeat counter in A) 
			TBEQ	A, DISP_ISR_4 					;repeat count is zero
			DBNE	A, DISP_ISR_9 					;decrement repeat count
DISP_ISR_3    		CLR	DISP_RPTCNT	   				;clear repeat count
			;Advance OUT index 
DISP_ISR_4		LDAB	DISP_BUF_OUT		   			;OUT -> B
			INCB			   				;increment OUT
			ANDB	#(DISP_BUF_SIZE-1) 				;wrap OUT
			STAB	DISP_BUF_OUT 					;update OUT
			;Done
DISP_ISR_5		ISTACK_RTI   						;return
			;DISP buffer is empty 
DISP_ISR_6		MOVB	#(SPE|DISP_SPICR1_CONFIG), SPICR1 		;disable transmit buffer empty interrupt
			JOB	DISP_ISR_5 					;done
			;Repeat loop or escape sequence in progress (repeat counter in A, char in B)
DISP_ISR_7		CMPA	#$FF 						;check for ongoing escape sequence
			BNE	DISP_ISR_1 					;repeat loop in progress
			;Conclude ongoing escape sequence(escaped char in B)
			IBEQ	B, DISP_ISR_10					;$FF: transmit escape character
			TBA							;repeat count+1 -> A
			IBEQ	B, DISP_ISR_11 					;$FE: switch to command mode
			IBEQ	B, DISP_ISR_12					;$FD: switch to data mode
			;Set new repeat count
			STAA	DISP_RPTCNT	 				;update repeat count
			JOB	DISP_ISR_4 					;advance out index
			;Escape character found
DISP_ISR_8		MOVB	#DISP_ESC_ESC, DISP_RPTCNT 			;flag new escape sequence
			JOB	DISP_ISR_4 					;advance out index
			;Update repeat count (decremented repeat counter in A)
DISP_ISR_9		STAA	DISP_RPTCNT 					;update repeat count
			JOB	DISP_ISR_5 					;done
			;Transmit escape character 
DISP_ISR_10		BRCLR	SPISR,#SPTEF,DISP_ISR_5 			;wait for TX buffer to be empty
			LDD	#DISP_ESC_START					;repeat counter -> A, escape char -> B
			STAA	DISP_RPTCNT	 				;update repeat count
			JOB	DISP_ISR_2	 				;transmit escape char
			;Switch to command mode
DISP_ISR_11		BRCLR	DISP_A0_PORT,#DISP_A0_PIN,DISP_ISR_3 		;command mode already set
			BRCLR	SPISR,#SPIF,DISP_ISR_5 				;wait for TX to be complete
			;BCLR	DISP_A0_PORT, #DISP_A0_PIN 			;switch to command mode
			MOVB	#DISP_RESET_PIN, DISP_A0_PORT  			; shortcut
			JOB	DISP_ISR_3					;clear repeat counter and advance OUT
			;Switch to data mode
DISP_ISR_12		BRSET	DISP_A0_PORT,#DISP_A0_PIN,DISP_ISR_3		;command mode already set
			BRCLR	SPISR,#SPIF,DISP_ISR_5 				;wait for TX to be complete
			;BSET	DISP_A0_PORT, #DISP_A0_PIN 			;switch to data mode
			MOVB	#(DISP_A0_PIN|DISP_RESET_PIN), DISP_A0_PORT  	; shortcut
			JOB	DISP_ISR_3					;clear repeat counter and advance OUT
	
DISP_CODE_END		EQU	*	
DISP_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DISP_TABS_START_LIN
			ORG 	DISP_TABS_START, DISP_TABS_START_LIN
#else
			ORG 	DISP_TABS_START
DISP_TABS_START_LIN	EQU	@	
#endif	

#ifndef DISP_SEQ_INIT_START
DISP_SEQ_INIT_START	EQU	*
			DISP_SEQ_CONFIG 		;configure display
DISP_SEQ_INIT_END	EQU	*
#endif
	
DISP_TABS_END		EQU	*
DISP_TABS_END_LIN	EQU	@
#endif
