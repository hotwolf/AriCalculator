#ifndef	KEYS
#define	KEYS
;###############################################################################
;# S12CBase - KEYS - Keypad Driver                                             #
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
;#    This is the low level driver for LCD using a ST7565R controller. This    #
;#    driver assumes, that the ST7565R is connected via the 4-wire SPI         #
;#    interface.                                                               #
;#                                                                             #
;#    This modules  provides three functions to the main program:              #
;#    DISPLAY_CHECK_BUF - This function checks if the command buffer is able   #
;#                        to accept more data.                                 #
;#    DISPLAY_TX_NB -     This function send one command to the display        #
;#                        without blocking the program flow.                   #
;#    DISPLAY_TX_BL -     This function send one command to the display and    #
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
;#
;# Keypad layout:
;#
;#           P  P  P  P  P
;#           P  P  P  P  P
;#           0  1  2  3  4
;#           
;#           |  |  |  |  |
;#  PAD6 ---1D-1C-1B-1A-19
;#           |  |  |  |  |
;#  PAD5 ---18-17-16-15-14
;#           |  |  |  |  |
;#  PAD4 ---13-12-11-10--F
;#           |  |  |  |  |
;#  PAD3 ----E--D--C--B--A
;#           |  |  |  |  |
;#  PAD2 ----9--8--7--6--5
;#           |  |  |  |  |
;#  PAD1 ----4--3--2--1--O
;#
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;#Column port
#ifndef KEYS_COL_PORT	
KEYS_COL_PORT		EQU	PT0AD		;default is PAD			
KEYS_COL_IE		EQU	PIE0AD		;default is PAD			
KEYS_COL_IF		EQU	PIF0AD		;default is PAD			
#endif
#ifndef KEYS_COL_MSB	
KEYS_COL_MSB		EQU	6 		;default is PAD6
#endif	
#ifndef KEYS_COL_LSB	
KEYS_COL_LSB		EQU	1 		;default is PAD1
#endif
	
;#Row port
#ifndef KEYS_ROW_PORT	
KEYS_ROW_PORT		EQU	DDRP		;default is PP	
#endif
#ifndef KEYS_ROW_MSB	
KEYS_ROW_MSB		EQU	4 		;default is PP4
#endif	
#ifndef KEYS_ROW_LSB	
KEYS_ROW_LSB		EQU	0 		;default is PP0
#endif

;Debounce delay
;--------------
;Output compare channel  
#ifndef	KEYS_OC
KEYS_OC			EQU	$5		;default is OC5	(must be >4)		
#endif

;Debounce delay (TIM cycles)
#ifndef	SCI_BD_OC
KEYS_DEBOUNCE_DELAY	EQU	5		;default is 5*2.6214ms			
#endif
	
;Buffer
;------
;#Buffer size
#ifndef KEYS_BUF_SIZE
KEYS_BUF_SIZE		EQU	8 		;depth of the command buffer
#endif

;Blocking subroutines
;-------------------- 
;Enable blocking subroutines
#ifndef	KEYS_BLOCKING_ON
#ifndef	KEYS_BLOCKING_OFF
KEYS_BLOCKING_OFF	EQU	1 		;blocking functions disabled by default
#endif
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Buffer
KEYS_BUF_MASK		EQU	KEYS_BUF_SIZE-1 ;index mask

;#Keypad dimensions
KEYS_COL_SIZE		EQU	1+KEYS_COL_MSB-KEYS_COL_LSB
KEYS_ROW_SIZE		EQU	1+KEYS_ROW_MSB-KEYS_ROW_LSB
	
;#Port masks
KEYS_COL_MASK		EQU	($FF>>(7-KEYS_COL_MSB))|($FF<<KEYS_COL_LSB)
KEYS_ROW_MASK		EQU	($FF>>(7-KEYS_ROW_MSB))|($FF<<KEYS_ROW_LSB)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef KEYS_VARS_START_LIN
			ORG 	KEYS_VARS_START, KEYS_VARS_START_LIN
#else
			ORG 	KEYS_VARS_START
KEYS_VARS_START_LIN	EQU	@			
#endif	

KEYS_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1

;#Command buffer  
KEYS_BUF		DS	2*KEYS_BUF_SIZE
KEYS_BUF_IN		DS	1		;points to the next free space
KEYS_BUF_OUT		DS	1		;points to the oldest entry
	
KEYS_AUTO_LOC2		EQU	*		;2nd auto-place location

;#Delay counter (>0 during debounce delay, 0 otherwise)
KEYS_DELAY_COUNT	EQU	((KEYS_AUTO_LOC1&1)*KEYS_AUTO_LOC1)+(((~KEYS_AUTO_LOC1)&1)*KEYS_AUTO_LOC2)
			UNALIGN	((~KEYS_AUTO_LOC1)&1)
KEYS_VARS_END		EQU	*
KEYS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	KEYS_INIT, 0
			;Initialize timer
			BSET	TIOS, #(1<<KEYS_OC)
			;BCLR	TCTL2, #(3<<(2*(KEYS_OC-4)))
			;BCLR	TIE, #(1<<KEYS_OC)
			;Check for any key 
			;MOVB	#KEY_PP_MASK, DDRP 	;drive all columns low
			;Clear delay counter
			CLR	KEYS_DELAY_COUNT
			;Clear input buffer
			MOVW	#$0000, KEYS_BUF_IN 	;clear input buffer
			;Observe all columns
			;MOVB	#KEYS_ROW_MASK,	KEYS_ROW_PORT 		;drive all colums (shortcut for unshared row port)
			;BSET	KEYS_ROW_PORT, #KEYS_ROW_MASK		;drive all colums (generic)
			;Clear and enable row interrupts
			MOVB	#KEYS_COL_MASK, KEYS_COL_IF
			MOVB	#KEYS_COL_MASK, KEYS_COL_IE
#emac

;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function 
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
#macro	KEYS_MAKE_BL, 2
			SCI_MAKE_BL	\1, \2
#emac

;#Run a non-blocking subroutine as if it was blocking	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function 
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
#macro	KEYS_CALL_BL, 2
			SCI_CALL_BL	\1, \2
#emac
	
;#Receive one keystroke - non-blocking
; args:   none
; result: A:      key code
;         C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and B are preserved 
#macro	KEYS_GET_NB, 0
			SSTACK_JOBSR	KEY_GET_NB, 5
#emac

;#Receive one byte - blocking
; args:   none
; result: A: key code
; SSTACK: 7 bytes
;         X, Y, and B are preserved 
#ifdef	KEYS_BLOCKING_ON
#macro	KEYS_GET_BL, 0
			SSTACK_JOBSR	KEYS_GET_BL, 6
#emac
#else
#macro	KEYS_GET_BL, 0
			KEYS_CALL_BL 	KEYS_GET_NB, 4
#emac
#endif

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef KEYS_CODE_START_LIN
			ORG 	KEYS_CODE_START, KEYS_CODE_START_LIN
#else
			ORG 	KEYS_CODE_START
#endif

;#Receive one keystroke - non-blocking
; args:   none
; result: A:      key code
;         C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and B are preserved 
KEYS_GET_NB		EQU	*
			;Save registers
			PSHB
			PSHX
			;Check if there is data in the RX queue
			LDD	KEYS_BUF_IN 				;A:B=in:out
			SBA		   				;A=in-out
			BEQ	KEYS_GET_NB_3 				;RX buffer is empty
			;Pull entry from the buffer (out-index in B)
			LDX	#KEYS_BUF
			LDAA	B,X
			INCB					        ;increment out pointer
			ANDB	#KEYS_BUF_MASK
			STAB	KEYS_BUF_OUT
			TST	KEYS_DELAY_COUNT
			;Recover from buffer overflow 
			BNE	KEYS_GET_NB_1		    		;debounce delay active
			MOVB	#KEYS_COL_MASK, KEYS_COL_IE 		;enable KWU interrupt
			;Restore registers
KEYS_GET_NB_1		SSTACK_PREPULL	5
			SEC						;flag success
KEYS_GET_NB_2		PULX
			PULB
			;Done
			RTS
			STAB	KEYS_BUF_OUT
			;RX buffer is empty
KEYS_GET_NB_3		SSTACK_PREPULL	5	
			CLC						;flag problem
			JOB	KEYS_GET_NB_2

;#Receive one byte - blocking
; args:   none
; result: A: key code
; SSTACK: 7 bytes
;         X, Y, and B are preserved 
#ifdef	KEYS_BLOCKING_ON
KEYS_GET_BL		EQU	*
			KEYS_MAKE_BL	KEYS_GET_NB, 7
#endif

;#Keyboard wakeup ISR for column port (PAD)
KEYS_ISR_KWU		EQU	*
			;Clear interrupt flag
			MOVB	#KEYS_COL_MASK, KEYS_COL_IF 		;clear interrupt flag
			;Check for any keystroke (shortcut)
			BRSET	KEYS_COL_PORT, #KEYS_COL_MASK, KEYS_ISR_KWU_2;all keys released
			;Scan colums for keystrokes
			LDX	#$0000 					;initialize column count
			LDAA	#(1<<KEYS_ROW_MSB)			;initialize column selector
KEYS_ISR_KWU_1		STAA	KEYS_ROW_PORT				;drive column selector 
			LDAB	KEYS_COL_PORT 				;capture column pattern 
			COMB
			ANDB	#KEYS_COL_MASK
			BNE	KEYS_ISR_KWU_3  			;keystroke column determined
			LEAX	1,X 					;increment column count
			LSRA		      				;switch to next column
			BCC	KEYS_ISR_KWU_1 				;check next column (shortcut for KEYS_ROW_LSB==0)
			;ANDA	#KEYS_ROW_MASK 				;check next column (generic)
			;BNE	KEYS_ISR_KWU_1
			;No keystroke detected 
			MOVB	#KEYS_ROW_MASK, KEYS_ROW_PORT 		;observe all columns (shortcut for unshared row port)
			;BSET	KEYS_ROW_PORT, #KEYS_ROW_MASK		;observe all columns (generic)
			;Done
KEYS_ISR_KWU_2		ISTACK_RTI
			;Keystroke column determined (row pattern in B, column count in X, column selector in KEYS_ROW_PORT)
KEYS_ISR_KWU_3		MOVB	#KEYS_ROW_MASK, KEYS_ROW_PORT 		;observe all columns (shortcut for unshared row port)
			;BSET	KEYS_ROW_PORT, #KEYS_ROW_MASK		;observe all columns (generic)
			LEAX	-(KEYS_ROW_SIZE*(KEYS_COL_LSB+1)),X 	;consider row offset
KEYS_ISR_KWU_4		LEAX	KEYS_ROW_SIZE,X 			;switch column in keycode
			LSRB						;check next column
			BCC	KEYS_ISR_KWU_4				;check next row
			;Key code determined (key code in X, column selector in DDRP)
			TFR	X,B 					;kec code -> B
			LDAA	KEYS_BUF_IN 				;IN index -> A
			LDX	KEYS_BUF				;put key code into the buffer
			STAB	A,X
			INCA						;adjust IN index
			ANDA	#KEYS_BUF_MASK
			CMPA	KEYS_BUF_OUT 				;check for buffer overvlow
			BEQ	KEYS_ISR_KWU_5 				;buffer overflow
			;Setup debounce delay 
			MOVB	#KEYS_DEBOUNCE_DELAY, KEYS_DELAY_COUNT	;set delay counter
			MOVW	TCNT, (TC0+(2*KEYS_OC))			;set OC to max delay
			TIM_EN	KEYS_OC					;enable timer
			;Stop keypad obervation
KEYS_ISR_KWU_5		CLR	KEYS_COL_IE 				;disable interrupts (shortcut for unshared col port)
			;BCLR	KEYS_COL_IE, #KEYS_ROW_MASK		;disable interrupts (generic)
			JOB	KEYS_ISR_KWU_2
			
;#Timer ISR for debounce delay
KEYS_ISR_TIM		EQU	*
			;Clear interrupt flag
			TIM_CLRIF	KEYS_OC				;clear TIM interrupt flag
			;Decrement delay count 
			DEC	KEYS_DELAY_COUNT
			BEQ	KEYS_ISR_TIM_2 				;debounce delay is over
			;Done
KEYS_ISR_TIM_1		ISTACK_RTI
			;Check if all keys have been released
KEYS_ISR_TIM_2		MOVB	#KEYS_COL_MASK, KEYS_COL_IF 		;clear KWU interrupt flag
			BRSET	KEYS_COL_PORT, #KEYS_COL_MASK, KEYS_ISR_TIM_3;all keys released
			MOVB	#KEYS_DEBOUNCE_DELAY, KEYS_DELAY_COUNT	;restart delay counter
			JOB	KEYS_ISR_TIM_1 				;done
			;All keys have been released
KEYS_ISR_TIM_3		TIM_DIS		KEYS_OC				;disable timer
			MOVB	#KEYS_COL_MASK, KEYS_COL_IE 		;enable KWU interrupt
			JOB	KEYS_ISR_TIM_1 				;done
			
KEYS_CODE_END		EQU	*
KEYS_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef KEYS_TABS_START_LIN
			ORG 	KEYS_TABS_START, KEYS_TABS_START_LIN
#else
			ORG 	KEYS_TABS_START
#endif3

KEYS_TABS_END		EQU	*
KEYS_TABS_END_LIN	EQU	@
#endif