#ifndef DISP
#define	DISP	
;###############################################################################
;# AriCalculator - DISP - LCD Driver (ST7565R) (AriCalculator RevC)            #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
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
;#    This is the low level driver for LCD using a ST7565R controller. This    #
;#    driver assumes, that the ST7565R is connected via the 4-wire SPI         #
;#    interface. The default pin mapping matches AriCalculator hardware RevC   #
;#                                                                             #
;#    This modules  provides three functions to the main program:              #
;#    DISP_CHECK_BUF - This function checks if the command buffer is able      #
;#                        to accept more data.                                 #
;#    DISP_TX_NB -     This function send one command to the display           #
;#                        without blocking the program flow.                   #
;#    DISP_TX_BL -     This function send one command to the display and       #
;#                        blocks the program flow until it has been            #
;#                        successful.                                          #
;#                                                                             #
;#    For convinience, all of these functions may also be called as macro.     #
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

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Baud rate divider
DISP_SPPR		EQU	((CLOCK_BUS_FREQ/(2*DISP_BAUD))-1)&7
DISP_SPR		EQU	0	

;#SPI configuration
DISP_SPICR1_CONFIG	EQU	%10011110 	;only SPE and SPTIE will be modified
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

;#Status flags
DISP_STAT_BUSY		EQU	$80 		;transmission in progress
DISP_STAT_REPEAT	EQU	$7F 		;repeat counter

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

;#Status flags
DISP_STAT		EQU	((DISP_AUTO_LOC1&1)*DISP_AUTO_LOC1)+((~(DISP_AUTO_LOC1)&1)*DISP_AUTO_LOC2)
			UNALIGN	((~DISP_AUTO_LOC1)&1)

DISP_VARS_END		EQU	*
DISP_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	DISP_INIT, 0
			;Deassert display reset 
			;BSET	DISP_RESET_PORT, #DISP_RESET_PIN
			MOVB	#DISP_RESET_PIN, DISP_RESET_PORT ;shortcut
			;Initialize Variables 
			MOVW	#$0000, DISP_BUF_IN
			CLR	DISP_STAT
			;Initialize SPI	
			MOVW	#((DISP_SPICR1_CONFIG<<8)|DISP_SPICR2_CONFIG), SPICR1
			MOVB	#DISP_SPIBR_CONFIG, SPIBR
			;Setup display	
			LDX	#DISP_SEQ_INIT_START
			LDY	#(DISP_SEQ_INIT_END-DISP_SEQ_INIT_START)
			DISP_STREAM_BL
#emac

;# Essential functions
;---------------------
;#Determine how much space is left on the buffer
; args:   none
; result: B: Space left on the buffer in bytes
; SSTACK: 3 bytes
;         X, Y and B are preserved 
#macro	DISP_BUF_FREE, 0
			SSTACK_JOBSR	DISP_BUF_FREE, 3
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

;#Transmit immediate commands and data (blocking)
; args:   1: buffer entry
; result: B: buffer entry
; SSTACK: 7 bytes
;         X, Y and A are preserved 
#macro	DISP_TX_IMM_BL, 1
			LDAB	#\1
			SSTACK_JOBSR	DISP_TX_BL, 7
#emac

;#Transmit a sequence of commands and data (non-blocking)
; args:   X: pointer to the start of the sequence
;         Y: number of bytes to transmit
; result: X: pointer to the start of the remaining sequence
;         Y: number of remaining bytes to transmit
;         C: 1 = successful, 0=buffer full
; SSTACK: 8 bytes
;         D is preserved 
#macro	DISP_STREAM_NB, 0
			SSTACK_JOBSR	DISP_STREAM_NB, 9
#emac

;#Transmit a sequence of commands and data (non-blocking)
; args:   X: pointer to the start of the sequence
;         Y: number of bytes to transmit
; result: X: points to the byte after the sequence
;         Y: $0000
; SSTACK: 10 bytes
;         D is preserved 
#macro	DISP_STREAM_BL, 0
			SSTACK_JOBSR	DISP_STREAM_NB, 11
#emac

;# Convenience macros
;--------------------
;#Transmit a sequence of commands and data (non-blocking)
; args:   1: pointer to the start of the sequence
;         2: pointer past the end of the sequence
; result: none
; SSTACK: 10 bytes
;         D is preserved 
#macro	DISP_STREAM_FROM_TO_BL, 2
			LDX	#\1
			LDY	#(\2-\1)
			DISP_STREAM_BL
#emac

;#Switch to command input (blocking)
; args:   none
; result: none
; SSTACK: 10 bytes
;         D is preserved 
#macro	DISP_CMD_INPUT_BL, 0
			DISP_STREAM_FROM_TO_BL	DISP_SEQ_CMD_START, DISP_SEQ_CMD_END
#emac

;#Switch to data input (blocking)
; args:   none
; result: none
; SSTACK: 10 bytes
;         D is preserved 
#macro	DISP_DATA_INPUT_BL, 0
			DISP_STREAM_FROM_TO_BL	DISP_SEQ_DATA_START, DISP_SEQ_DATA_END
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

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DISP_CODE_START_LIN
			ORG 	DISP_CODE_START, DISP_CODE_START_LIN
#else
			ORG 	DISP_CODE_START
#endif
	
;# Essential functions
;---------------------
;#Determine how much space is left on the buffer
; args:   none
; result: A: Space left on the buffer in bytes
; SSTACK: 3 bytes
;         X, Y and B are preserved 
DISP_BUF_FREE		EQU	*
			;Save registers
			PSHB							;push accu B onto the SSTACK
			;Check if the buffer is full
			LDD	DISP_BUF_IN 					;IN->A; OUT->B
			SBA
			ANDA	#(DISP_BUF_SIZE-1) 				;buffer usage->A
			NEGA
			ADDA	#(DISP_BUF_SIZE-1)
			;Restore registers
			SSTACK_PREPULL	3
			PULB							;pull accu B from the SSTACK
			;Done
			RTS
	
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
;         Y: number of bytes to transmit
; result: X: pointer to the start of the remaining sequence
;         Y: number of remaining bytes to transmit
;         C: 1 = successful, 0=buffer full
; SSTACK: 8 bytes
;         D is preserved 
DISP_STREAM_NB		EQU	*
			;Save registers (start pointer in X, byte count in Y)
			PSHB							;push accu B onto the SSTACK
			;Transmit next byte (start pointer in X, byte count in Y)
DISP_STREAM_NB_1	LDAB	1,X+ 						;get data
			DISP_TX_NB 						;transmit data (SSTACK: 5 bytes)
			BCC	DISP_STREAM_NB_3				;TX buffer is full
			DBNE	Y, DISP_STREAM_NB_1 				;transmit next byte
			;Successful transmission (new start pointer in X, $0000 in Y)
			SSTACK_PREPULL	3
			SEC							;signal success
DISP_STREAM_NB_2	PULB							;pull accu B from the SSTACK
			;Done
			RTS
			;TX buffer is full (new start pointer+1 in X, new byte count in Y)
DISP_STREAM_NB_3	LEAX	-1,X 						;restore pointer
			;Unsucessful transmission (new start pointer in X, new byte count in Y)			
			SSTACK_PREPULL	3
			CLC							;signal success
			JOB	DISP_STREAM_NB_2 				; done

;#Transmit a sequence of commands and data (non-blocking)
; args:   X: pointer to the start of the sequence
;         Y: number of bytes to transmit
; result: X: points to the byte after the sequence
;         Y: $0000
; SSTACK: 10 bytes
;         D is preserved 
DISP_STREAM_BL		EQU	*
			DISP_MAKE_BL	DISP_STREAM_NB, 8	
	
;#SPI ISR for transmitting data to the ST7565R display controller
;--------------------------
DISP_ISR		EQU	*
			;Check SPIF flag
			LDAA	SPISR 						;read the status register
			BITA	#SPIF 						;check SPIF flag (transmission complete)
			BEQ	DISP_ISR_1 					;check SPTEF flag (transmit buffer empty) 
			TST	SPIDRL			   			;clear SPIF flag
			BCLR	DISP_STAT, #DISP_STAT_BUSY 			;clear busy indicator
			;Check SPTEF flag (SPISR in A)
DISP_ISR_1		BITA	#SPTEF						;check SPTEF flag (transmit buffer empty)
			BEQ	DISP_ISR_4					;Spi's transmit buffer is full
			;Check if TX buffer has data
			LDD	DISP_BUF_IN 					;IN->A, OUT->B
			CBA							;check if buffer is empty
			BEQ	DISP_ISR_5 					;TX buffer is empty
			;Check transmission counter (OUT in B) 
			LDX	#DISP_BUF
			LDAA	DISP_STAT
 			ANDA	#DISP_STAT_REPEAT
			BNE	DISP_ISR_7 					;repeat transmission
			;Check for escape character (buffer pointer in X, OUT in B)
			LDAA	B,X 						;next char->A
			CMPA	#DISP_ESC_START	
			BEQ	DISP_ISR_8 					;escape character found
			;Transmit character (char in A, OUT in B)
DISP_ISR_2		STAA	SPIDRL 						;transmit character
			BSET	DISP_STAT, #DISP_STAT_BUSY 			;set busy indicator
DISP_ISR_3		INCB							;advance OUT index
			ANDB	#(DISP_BUF_SIZE-1)
			STAB	DISP_BUF_OUT
			;Done
DISP_ISR_4		ISTACK_RTI
			;Wait for more TX data
DISP_ISR_5		BRSET 	DISP_STAT, #DISP_STAT_BUSY, DISP_ISR_6 		;check for ongoing transmission
			MOVB	#DISP_SPICR1_CONFIG, SPICR1 			;disable SPI
			JOB	DISP_ISR_4 					;done
DISP_ISR_6		MOVB	#(SPE|DISP_SPICR1_CONFIG), SPICR1 		;disable transmit buffer empty interrupt
			JOB	DISP_ISR_4 					;done
			;Repeat transmission (buffer pointer in X, OUT in B, DISP_STAT_REPEAT in A)
DISP_ISR_7		MOVB	B,X, SPIDRL 					;Transmit data
			DECA	
			ORAA	#DISP_STAT_BUSY
			STAA	DISP_STAT
			JOB	DISP_ISR_4 					;done
			;Escape character found (buffer pointer in X, OUT in B)
DISP_ISR_8		INCB							;skip ESC character 
			ANDB	#(DISP_BUF_SIZE-1)
			CMPB	DISP_BUF_IN 					;check if ESC command is available
			BEQ	DISP_ISR_5 					;ESC sequence is incomplete
			;Evaluate the escape command (buffer pointer in X, new OUT in B)
			LDAA	B,X 						;ESC command -> A
			IBEQ	A, DISP_ISR_10					;$FF: transmit escape character
			IBEQ	A, DISP_ISR_11 					;$FE: switch to command mode
			IBEQ	A, DISP_ISR_12					;$FD: switch to data mode
			;Set TX counter (TX count+3 in A, new OUT in B)
			SUBA	#4 						;adjust repeat count
			BRCLR	DISP_STAT, #DISP_STAT_BUSY, DISP_ISR_9		;transmission in progress
			ORAA	#DISP_STAT_BUSY
DISP_ISR_9		STAA	DISP_STAT 					;set TX count
			JOB	DISP_ISR_3					;remove ESC sequence from TX buffer
			;Transmit escape character (new OUT in B) 
DISP_ISR_10		LDAA	#DISP_ESC_START
			JOB	DISP_ISR_2
			;Switch to command mode (new OUT in B) 
DISP_ISR_11		BRCLR	DISP_A0_PORT, #DISP_A0_PIN, DISP_ISR_3		;already in command mode
			BRSET	DISP_STAT, #DISP_STAT_BUSY, DISP_ISR_6		;transmission in progress
			;BCLR	DISP_A0_PORT, #DISP_A0_PIN 			;switch to command mode
			MOVB	#DISP_RESET_PIN, DISP_A0_PORT  			; shortcut
			JOB	DISP_ISR_3					;escape sequence processed
			;Switch to data mode (new OUT in B) 
DISP_ISR_12		BRSET	DISP_A0_PORT, #DISP_A0_PIN, DISP_ISR_3		;already in data mode
			BRSET	DISP_STAT, #DISP_STAT_BUSY, DISP_ISR_6		;transmission in progress
			;BSET	DISP_A0_PORT, #DISP_A0_PIN 			;switch to data mode
			MOVB	#(DISP_A0_PIN|DISP_RESET_PIN), DISP_A0_PORT  	; shortcut
			JOB	DISP_ISR_3					;escape sequence processed	
	
DISP_CODE_END		EQU	*	
DISP_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DISP_TABS_START_LIN
			ORG 	DISP_TABS_START, DISP_TABS_START_LIN
#else
			ORG 	DISP_TABS_START
#endif	

;#Setup stream
DISP_SEQ_INIT_START	DB	$40 				;start display at line 0
			;DB	$A0				;flip display
			;DB	$C8				;Normal COM0~COM63
			DB	$A1				;flip display
			DB	$C0				;Reverse COM63~COM0
			DB	$A2				;set bias 1/9 (Duty 1/65) ;
			DB	$2F 				;enabable booster, regulator and follower
			DB	$F8				;set booster to 4x
			DB	$00
			DB	$27				;set ref value to 6.5
			DB	$81				;set alpha value to 47
			DB	$10                             ;V0=alpha*(1-(ref/162)*2.1V =[4V..13.5V]
			DB	$AC				;no static indicator
			DB	$00
			DB	$AF 				;enable display
DISP_SEQ_INIT_END	EQU	*

;#Switch to command input
DISP_SEQ_CMD_START	DB	DISP_ESC_START
			DB	DISP_ESC_CMD
DISP_SEQ_CMD_END	EQU	*
	
;#Switch to data input
DISP_SEQ_DATA_START	DB	DISP_ESC_START
			DB	DISP_ESC_DATA
DISP_SEQ_DATA_END	EQU	*

;;#Clear screen
;DISP_SEQ_CLEAR_START	DB  $B0 $10 $04                     	;set page 0
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;			DB  $B1 $10 $04                     	;set page 1
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;			DB  $B2 $10 $04                     	;set page 2
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;			DB  $B3 $10 $04                     	;set page 3
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;			DB  $B4 $10 $04                     	;set page 4
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;			DB  $B5 $10 $04                     	;set page 5
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;			DB  $B6 $10 $04                     	;set page 6
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;			DB  $B7 $10 $04                     	;set page 7
;			DB  DISP_ESC_START DISP_ESC_DATA    	;switch to data input
;			DB  DISP_ESC_START $80 $00          	;repeat 128 times
;			DB  DISP_ESC_START DISP_ESC_CMD    	;switch to command input
;DISP_SEQ_CLEAR_END	EQU	*
	
DISP_TABS_END		EQU	*
DISP_TABS_END_LIN	EQU	@
#endif
