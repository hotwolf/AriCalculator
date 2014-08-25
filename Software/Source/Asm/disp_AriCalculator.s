#ifndef DISP
#define	DISP	
;###############################################################################
;# S12CBase - DISP - LCD Driver (ST7565R)                                      #
;###############################################################################
;#    Copyright 2010-2014x Dirk Heisswolf                                      #
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
;#    interface.                                                               #
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
DISP_RESET_PORT		EQU	PTJ 		;default is port J	
#endif
#ifndef DISP_RESET_PIN
DISP_RESET_PIN		EQU	PJ0		;default is PJ0	
#endif
	
;#A0 output
#ifndef DISP_A0_PORT
DISP_A0_PORT		EQU	PTS 		;default is port S	
#endif
#ifndef DISP_A0_PIN
DISP_A0_PIN		EQU	PS4		;default is PS4	
#endif

;#Splash screen
#ifndef DISP_SPLASH
#define DISP_SPLASH	
#macro	DISP_SPLASH_STREAM, 0
#emac
#endif

;#Buffer size
#ifndef DISP_BUF_SIZE
DISP_BUF_SIZE		EQU	8 		;depth of the command buffer
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Escape sequences
DISP_ESC_START		EQU	$E3 		;start of eccape sequence (NOP)
DISP_ESC_ESC		EQU	$FF		;transmit escape character
DISP_ESC_CMD		EQU	$FE		;switch to command mode
DISP_ESC_DATA		EQU	$FD		;switch to data mode

;#Baud rate divider
DISP_SPPR		EQU	((CLOCK_BUS_FREQ/(2*DISP_BAUD))-1)&7
DISP_SPR		EQU	0	
	
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
DISP_BUF_IN		DS	1
DISP_BUF_OUT		DS	1

DISP_AUTO_LOC2		EQU	*		;2nd auto-place location

;#Transmission counter (auto-place)
DISP_TXCNT		EQU	((DISP_AUTO_LOC1&1)*DISP_AUTO_LOC1)+((~(DISP_AUTO_LOC1)&1)*DISP_AUTO_LOC2)
			UNALIGN	((~DISP_AUTO_LOC1)&1)

DISP_VARS_END		EQU	*
DISP_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	DISP_INIT, 0
			;Deassert display reset 
			MOVB	#DISP_RESET_PIN, DISP_RESET_PORT	

			;Initialize Variables 
			MOVW	#$0000, DISP_BUF_IN
			CLR	DISP_TXCNT
	
			;Initialize SPI	
			MOVW	#%01011110_00011001, SPICR1
				 ;SSSMCCSL  X MB SS
				 ;PPPSPPSS  F OI PP
				 ;IETTOHOB  R DD IC
				 ;E IRLAEF  W FI S0
				 ;  E    E    ER W
				 ;            NO A
				 ;             E I
			MOVB	#((DISP_SPPR<<4|(DISP_SPR))), SPIBR
			;MOVB	#$FF, SPISR

			;Setup display	
			LDX	#DISP_SETUP_START
			LDY	#(DISP_SETUP_END-DISP_SETUP_START)	
INIT_LOOP		LDAB	1,X+
			JOBSR	DISP_TX_BL
			DBNE	Y, INIT_LOOP
#emac

;# Functions
;-----------
;#Determine how much space is left on the buffer
; args:   none
; result: B: Space left on the buffer in bytes
; SSTACK: 3 bytes
;         X, Y and B are preserved 
#macro	DISP_BUF_FRxEE, 0
			SSTACK_JOBSR	DISP_BUF_FREE, 3
#emac	
	
;#Transmit commands and data (non-blocking)
; args:   B: buffer entry
; result: C: 1=successful, 0=nothing has been done
; SSTACK: 5 bytes
;         X, Y and D are preserved 
#macro	DISP_TX_NB, 0
			JOBSR	DISP_TX_NB
#emac

;#Transmit commands and data (blocking)
; args:   B: buffer entry
; result: none
; SSTACK: 7 bytes
;         X, Y and D are preserved 
#macro	DISP_TX_BL, 0
			JOBSR	DISP_TX_BL
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
			BSET	SPICR1, #SPTIE
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
	
;#SPI ISR for transmitting data to the ST7565R display controller
DISP_ISR		EQU	*
			;Peek into the TX buffer
			LDD	DISP_BUF_IN 					;IN->A, OUT->B
			CBA							;check if buffer is empty
			BEQ	DISP_ISR_4 					;buffer is empty
			;Check transmission counter (OUT in B) 
			LDX	#DISP_BUF
			LDAA	DISP_TXCNT 					
			BNE	DISP_ISR_5 					;repeat transmission
			;Check for escape character (buffer pointer in X, OUT in B)
			LDAA	B,X 						;next char->A
			CMPA	#DISP_ESC_START	
			BEQ	DISP_ISR_6 					;escape character found
			;Transmit character (char in A, OUT in B)
			STAA	SPIDRL 						;transmit character
DISP_ISR_1		INCB							;advance OUT index
			ANDB	#(DISP_BUF_SIZE-1)
			STAB	DISP_BUF_OUT
			;Done
DISP_ISR_2		MOVB	#%01111110, SPICR1 				;enable TX buffer empty interrupt
				 ;SSSMCCSL
				 ;PPPSPPSS
				 ;IETTOHOB
				 ;E IRLAEF
				 ;  E    E
DISP_ISR_3		ISTACK_RTI
			;Transmit buffer is empty
DISP_ISR_4		MOVB	#%01011110, SPICR1 				;enable TX buffer empty interrupt
				 ;SSSMCCSL
				 ;PPPSPPSS
				 ;IETTOHOB
				 ;E IRLAEF
				 ;  E    E
			JOB	DISP_ISR_3
			;Repeat last transmission  (buffer pointer in X, TX count in A, OUT in B)
DISP_ISR_5		DECA 							;decrement TX counter
			STAA	DISP_TXCNT
			MOVB	B,X, SPIDRL 					;transmit byte
			JOB	DISP_ISR_2
			;Escape character found (buffer pointer in X, OUT in B) 
DISP_ISR_6		LDAA	DISP_BUF_IN 					;make sure that the escape command is in the buffer
			SBA
			ANDA	#(DISP_BUF_SIZE-1)
			CMPA	#2
			BLO	DISP_ISR_4 					;wait for the escape command
			;Evaluate the escape command (buffer pointer in X, OUT in B)
			LDAA	#1 						;get escape command
			ABA
			ANDA	#(DISP_BUF_SIZE-1)
			LDAA	A,X 						;escape command->A
			IBEQ	A, DISP_ISR_8 					;transmit escape character
			IBEQ	A, DISP_ISR_9 					;switch to command mode
			IBEQ	A, DISP_ISR_10 					;switch to data mode
			;Set TX counter (TX count+3 in A, OUT in B)
			SUBA	#3 						;restore TX count
			STAA	DISP_TXCNT 					;set TX count
			;Remove escape sequence from buffer (OUT in B) 
DISP_ISR_7		INCB						
			JOB	DISP_ISR_1
			;Transmit escape character (OUT in B) 
DISP_ISR_8		MOVB	#DISP_ESC_START, SPIDRL
			JOB	DISP_ISR_7
			;Switch to command mode (OUT in B) 
DISP_ISR_9		BRCLR	DISP_A0_PORT, #DISP_A0_PIN, DISP_ISR_7 		;already in command mode
			BRCLR	SPISR, #SPIF, DISP_ISR_11			;transmission in progress
			BCLR	DISP_A0_PORT, #DISP_A0_PIN 			;switch to command mode
			JOB	DISP_ISR_7 					;escape sequence processed
			;Switch to data mode (OUT in B) 
DISP_ISR_10		BRSET	DISP_A0_PORT, #DISP_A0_PIN, DISP_ISR_7 		;already in data mode
			BRCLR	SPISR, #SPIF, DISP_ISR_11			;transmission in progress
			BSET	DISP_A0_PORT, #DISP_A0_PIN 			;switch to data mode
			JOB	DISP_ISR_7 					;escape sequence processed	
			;Wait for ongoing transmission to complete
DISP_ISR_11		MOVB	#%11011110, SPICR1 				;enable TX buffer empty interrupt
				 ;SSSMCCSL
				 ;PPPSPPSS
				 ;IETTOHOB
				 ;E IRLAEF
				 ;  E    E
			JOB	DISP_ISR_3
	
DISP_CODE_END		EQU	*	
DISP_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DISP_START_LIN
			ORG 	DISP_TABS_START, DISP_TABS_START_LIN
#else
			ORG 	DISP_TABS_START
#endif	

;#Setup stream
DISP_SETUP_START	DB	$40 				;start display at line 0
			DB	$A0				;flip display
			DB	$C8				;COM0 -> 
			;DB	$A1				;flip display
			;DB	$C0				;COM0 -> 
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

			DISP_SPLASH_STREAM 			;display splash screen
DISP_SETUP_END		EQU	*

DISP_TABS_END		EQU	*
DISP_TABS_END_LIN	EQU	@
#endif
