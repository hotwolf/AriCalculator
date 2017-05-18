#ifndef	KEYS
#define	KEYS
;###############################################################################
;# AriCalculator - KEYS - Keypad Driver (AriCalculator RevC)                   #
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
;#    This is the key pad driver for the AriCalculator hardware RevC.          #
;#                                                                             #
;#    For convinience, all of these functions may also be called as macro.     #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#    VECMAP - Vector Map                                                      #
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
;#           P  P  P  P  P  P
;#           P  P  P  P  P  P
;#           0  1  2  3  4  5
;#               
;#           |  |  |  |  |  |
;#  PAD6 ---29-28-27-26-25-24 |G
;#           |  |  |  |  |  | |
;#  PAD5 ---23-22-21-20-1F-1E |F
;#           |  |  |  |  |  | |
;#  PAD4 ---1D-1C-1B-1A-19-18 |E
;#              |  |  |  |  | |
;#  PAD3 ------16-15-14-13-12 |D
;#              |  |  |  |  | |
;#  PAD2 ------10--F--E--D--C |C
;#              |  |  |  |  | |
;#  PAD1 -------A--9--8--7--6 |B
;#              |  |  |  |  | |
;#  PAD0 -------4--3--2--1--0 |A
;#           ________________
;#           5  4  3  2  1  0
;#           
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;#Column port
#ifndef KEYS_COL_PORT	
KEYS_COL_PORT		EQU	PT1AD		;default is PAD			
KEYS_COL_IE		EQU	PIE1AD		;default is PAD			
KEYS_COL_IF		EQU	PIF1AD		;default is PAD			
#endif
#ifndef KEYS_COL_MSB	
KEYS_COL_MSB		EQU	6 		;default is PAD6
#endif	
#ifndef KEYS_COL_LSB	
KEYS_COL_LSB		EQU	0 		;default is PAD0
#endif
	
;#Row port
#ifndef KEYS_ROW_PORT	
KEYS_ROW_PORT		EQU	PTP		;default is PP	
#endif
#ifndef KEYS_ROW_DDR	
KEYS_ROW_DDR		EQU	DDRP		;default is PP	
#endif
#ifndef KEYS_ROW_MSB	
KEYS_ROW_MSB		EQU	5 		;default is PP5
#endif	
#ifndef KEYS_ROW_LSB	
KEYS_ROW_LSB		EQU	0 		;default is PP0
#endif

;Debounce delay
;--------------
;Output compare channel  
#ifndef	KEYS_TIM
KEYS_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
#ifndef	KEYS_OC
KEYS_OC			EQU	4 		;default is OC4
#endif

;Debounce delay (TIM cycles)
#ifndef	KEYS_DEBOUNCE_DELAY
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
KEYS_COL_MASK		EQU	($FF>>(7-KEYS_COL_MSB))&($FF<<KEYS_COL_LSB)
KEYS_ROW_MASK		EQU	($FF>>(7-KEYS_ROW_MSB))&($FF<<KEYS_ROW_LSB)

;#Timer configuration
; TIOS 
KEYS_TIOS_INIT		EQU	1<<KEYS_OC
;#Output compare register
KEYS_OC_TC		EQU	KEYS_TIM+(TC0-TIOS)+(2*KEYS_OC)

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
			;Recover from buffer overflow 
			TST	KEYS_DELAY_COUNT
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
			;Check for active debounce delay
			TST	KEYS_DELAY_COUNT
			BNE	KEYS_ISR_KWU_3				;debounce delay ongoing
			;Check for missed keystrokes (shortcut)
			BRSET	KEYS_COL_PORT, #KEYS_COL_MASK, KEYS_ISR_KWU_2;all keys released
			;Scan colums for keystrokes
			LDX	#$0000			      		;initialize key code
			LDAA	#(1<<KEYS_ROW_MSB)			;initialize column selector
KEYS_ISR_KWU_1		MOVB	#KEYS_ROW_MASK, KEYS_ROW_PORT 		;drive speed-up pulse
			STAA	KEYS_ROW_DDR 				;drive unselected colums by pull-ups
			CLR	KEYS_ROW_PORT 				;drive selected column low
			NOP						;wait for input synchronizers
			LDAB	#(~KEYS_COL_MASK)			;capture column pattern 
			ORAB	KEYS_COL_PORT
			COMB
			BNE	KEYS_ISR_KWU_4  			;keystroke column detected
			INX	 					;switch to next keycode
			LSRA		      				;switch to next column
			BCC	KEYS_ISR_KWU_1 				;check next column (shortcut for KEYS_ROW_LSB==0)
			;ANDA	#KEYS_ROW_MASK 				;check next column (generic)
			;BNE	KEYS_ISR_KWU_1
			;No keystroke detected 
			MOVB	#KEYS_ROW_MASK, KEYS_ROW_DDR 		;observe all columns
			;Done
KEYS_ISR_KWU_2		ISTACK_RTI
			;Debounce delay is active (disable KWU interrupts)
KEYS_ISR_KWU_3		CLR	KEYS_COL_IE 				;disable interrupts (shortcut for unshared col port)
			;BCLR	KEYS_COL_IE, #KEYS_COL_MASK		;disable interrupts (generic)
			JOB	KEYS_ISR_KWU_2 				;done
			;Keystroke column determined (column selector in A row pattern in B, key code in X, column selector in KEYS_ROW_PORT)
KEYS_ISR_KWU_4		MOVB	#KEYS_ROW_MASK, KEYS_ROW_DDR 		;observe all columns
			STAA	KEYS_COL_IF 				;clear retriggered interrupt flag
			LEAX	-(KEYS_ROW_SIZE*(KEYS_COL_LSB+1)),X 	;consider row offset
KEYS_ISR_KWU_5		LEAX	KEYS_ROW_SIZE,X 			;switch column in keycode
			LSRB						;check next column
			BCC	KEYS_ISR_KWU_5				;check next row
			;Key code determined (key code in X, column selector in DDRP)
			TFR	X,B 					;kec code -> B
			LDAA	KEYS_BUF_IN 				;IN index -> A
			LDX	#KEYS_BUF				;put key code into the buffer
			STAB	A,X
			INCA						;adjust IN index
			ANDA	#KEYS_BUF_MASK
			CMPA	KEYS_BUF_OUT 				;check for buffer overvlow
			BEQ	KEYS_ISR_KWU_3 				;buffer overflow (disable KWU interrupts)
			STAA	KEYS_BUF_IN 				;update IN index
			;Setup debounce delay 
			MOVB	#KEYS_DEBOUNCE_DELAY, KEYS_DELAY_COUNT	;set delay counter
			MOVW	TCNT, (TC0+(2*KEYS_OC))			;set OC to max delay
			TIM_EN	KEYS_TIM, KEYS_OC			;enable timer
			JOB	KEYS_ISR_KWU_3 				;disable KWU interrupts

;#Timer ISR for debounce delay
KEYS_ISR_TIM		EQU	*
			;Clear interrupt flag
			TIM_CLRIF KEYS_TIM, KEYS_OC			;clear TIM interrupt flag
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
KEYS_ISR_TIM_3		TIM_DIS	KEYS_TIM, KEYS_OC			;disable timer	
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
