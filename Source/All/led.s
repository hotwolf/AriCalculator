#ifndef	LED_COMPILED 
#define	LED_COMPILED
;###############################################################################
;# S12CBase - LED - Timer Driver                                               #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
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
;#    The module drives sequential patterns onto the LEDs.                     #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    January 16, 2016                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    TIM - Timer Driver                                                       #
;#                                                                             #
;###############################################################################
;#                                                                             #
;#   Pattern assignment:                                                       #
;#   +---+ --------------+----------------                                     #
;#   | 8 | Short pulse   |                  ^                                  #
;#   +---+               | Non-recurring    |h                                 #
;#   | 7 | Long pulse    |                  |i                                 #
;#   +---+ --------------+----------------  |g                                 #
;#   | 6 | Fast blink    |                  |h                                 #
;#   +---+               |                  |                                  #
;#   | 5 | Slow blink    |                  |                                  #
;#   +---+               |                  |p                                 #
;#   | 4 | Shingle gap   | Recurring        |r                                 #
;#   +---+               |                  |i                                 #
;#   | 3 | Double gap    |                  |o                                 #
;#   +---+               |                  |                                  #
;#   | 2 | Heart beat    |                  |                                  #
;#   +---+ --------------+----------------  |l                                 #
;#   | 1 | On            |                  |o                                 #
;#   +---+               | Untimed          |w                                 #
;#   | 0 | Off           |                  v                                  #
;#   +---+ --------------+----------------                                     #
;#                                                                             #
;###############################################################################

;#######################################################x#######################
;# Configuration                                                               #
;###############################################################################
;LED enables (red is always enabled)
; Green
#ifndef LED_GREEN_ENABLE		
#ifndef LED_GREEN_DISABLE		
LED_GREEN_ENABLE	EQU	1 		;green LED enabled by default
#endif
#endif

;TIM configuration
;TIM instance
#ifndef	SCI_OC_TIM
LED_TIM			EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Output compare channel
#ifndef	LED_OC
LED_OC			EQU	3 		;default is OC3
#endif
	
;I/O configuration
; Red
#ifndef	LED_RED_PORT
LED_RED_PORT		EQU	PORTE 		;default is PE
#endif
#ifndef	LED_RED_PIN
LED_RED_PIN		EQU	PE1 		;default is PE1
#endif
#ifdef LED_GREEN_ENABLE	
; Green
#ifndef	LED_GREEN_PORT
LED_GREEN_PORT		EQU	PORTE 		;default is PE
#endif
#ifndef	LED_GREEN_PIN
LED_GREEN_PIN		EQU	PE0 		;default is PE0
#endif
#endif

;Non-requrring sequences
#ifndef	LED_NONREC_MASK
LED_NONREC_MASK		EQU	#$C0 		;default is patterns 7 and 8
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Timer configuration
; TIOS 
LED_TIOS_INIT		EQU	1<<LED_OC
; TOC7M/D
;LED_TOC7MD_INIT	EQU	0
; TTOV
;LED_TTOV_INIT		EQU	0
; TCTL1/2
;LED_TCTL12_INIT	EQU	0
; TCTL3/4
;LED_TCTL34_INIT	EQU	0
 	
;#Output compare register
LED_OC_REG		EQU	TC0+(2*LED_OC)

;#timer intervall
LED_TIM_INTERVALL	EQU	TIM_FREQ/4 	;2sec/8
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef LED_VARS_START_LIN
			ORG 	LED_VARS_START, LED_VARS_START_LIN
#else
			ORG 	LED_VARS_START
LED_VARS_START_LIN	EQU	@			
#endif	

;#Common variables
LED_REM_TIME		DS	1 				;remaining timer intervalls
LED_SEQ_ITERATOR	DS	1				;sequence iterator

;#Red LED
LED_RED_REQ		DS	1 				;signal requests
LED_RED_CUR_SEQ		DS	1 				;signal selector
	
#ifdef LED_GREEN_ENABLE	
;#Green LED
LED_RED_REQ		DS	1 				;signal requests
LED_RED_CUR_SEQ		DS	1 				;signal selector
#endif	
	
LED_VARS_END		EQU	*
LED_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	LED_INIT, 0
			;Common variables
			CLRD			      		;zero -> D
			STD	LED_REM_TIME			;no remaining time, iterator reset
			;Red LED
			STD	LED_RED_REQ 			;no requests, LED off
#ifdef LED_GREEN_ENABLE	
			;Green LED
			STD	LED_GREEN_REQ 			;no requests, LED off
#endif	
#emac


;#Set signal
; args:   1: color ("RED" or "GREEN")
;         2: signal index (7..0)
; result: none
; SSTACK: none
;         X and Y are preserved 
#macro	LED_SET, 2
			SEI					;start if atomic sequence
			LED_SET_ATOMIC	\1, \2			;set signal
			CLI					;end of atomic sequence
#emac
	
;#Set signal (must be in an atomic sequence -> I-bit set)
; args:   1: color ("RED" or "GREEN")
;         2: signal index (7..0)
; result: none
; SSTACK: none
;         X and Y are preserved 
#macro	LED_SET_ATOMIC, 2
			BSET	 LED_\1_REQ, #(1<<\2) 		;set request
			TIM_BREN LED_TIM,LED_OC, LED_SET_ATOMIC_1;timer already enabled
			TIM_EN	 LED_TIM,LED_OC			;enable timer
			TIM_SET_DLY LED_TIM,#5			;trigger interrupt
LED_SET_ATOMIC_1	EQU	* 				;done
#emac

;#Clear signal
; args:   1: color ("RED" or "GREEN")
;         2: signal index (7..0)
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
#macro	LED_CLR, 2
			BCLR	LED_\1_REQ, #(1<<\2) 		;clear request
#emac

;#Initernal macros
;----------------- 
;#Check requests
; args:   1: color ("RED" or "GREEN")
; result: none
; SSTACK: none
;         X and Y  are preserved 
#macro	LED_CHECK_REQ, 1
			LDAA	#$80 				;initiate request selector
			LDAB	#$08				;initiate sequence selector
LED_CHECK_REQ_1		BITA	LED_\1_REQ			;check request
			BNE	LED_CHECK_REQ_2			;request found
			LSRA					;advance request selector
			DBNE	B, LED_CHECK_REQ_1		;decrement sequence selector
LED_CHECK_REQ_2		COMA					;clear non-recurring requests
			ORAA	#~LED_NONREC_MASK		;
			ANDA	LED_\1_REQ 			;
			STD	LED_\1_REQ 			;update requests and sequence selector
#emac

;#Drive LED
; args:   1: color ("RED" or "GREEN")
;         Y: pointer to sequence table
; result: none
; SSTACK: none
;         X, Y, and A are preserved 
#macro	LED_DRIVE, 1
			LDAB	LED_\1_CUR_SEQ			;sequence selector -> B
			LDAB	B,Y				;sequence -> B	       
			BITB	LED_SEQ_ITERATOR		;LED state -> Z-flag
			BEQ	LED_DRIVE_1			;turn off LED
			BSET	LED_\1_PORT, #LED_\1_PIN	;turn on LED	       
			JOB	LED_DRIVE_2			;done	       
LED_DRIVE_1		BCLR	LED_\1_PORT, #LED_\1_PIN	;turn off LED	       
LED_DRIVE_2		EQU	*				;done	       
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef LED_CODE_START_LIN
			ORG 	LED_CODE_START, LED_CODE_START_LIN
#else
			ORG 	LED_CODE_START
#endif

;#ISR
;---- 
LED_ISR		EQU	*			
			;Check and adjust remaining time
			LDAB	LED_REM_TIME			;remaining time -> X
			BEQ	LED_ISR_1			;
			DECB					;decrement remaining time
			STAB	LED_REM_TIME			;update remaining time
			ISTACK_RTI				;done
			;Advance and check pattern iterator
			LSR	LED_SEQ_ITERATOR 		;advance sequence iterator
			BNE	LED_ISR_			;update LEDs
			MOVB	#$80, LED_SEQ_ITERATOR		;reset sequence iterator
			;Check requests				
			LED_CHECK_REQ	RED 			;check red requests
#ifdef LED_GREEN_ENABLE	
			LED_CHECK_REQ	GREEN 			;check green requests
#endif
			;Drive LEDs
			LDY	#LED_SEQ_TAB  			;sequence table -> Y
			LED_DRIVE_REQ	RED 			;drive red requests
#ifdef LED_GREEN_ENABLE	
			LED_DRIVE_REQ	GREEN 			;drive green requests
#endif
#ifdef LED_GREEN_ENABLE	
			;Check if both LEDs are untimed
			LDAB	LED_RED_CUR_SEQ 		;check red sequence
			ORAB	LED_GREEN_CUR_SEQ 		;check green sequence
			LSRB					;check if both are untimed
			BEQ	LED_ISR_			;both LEDs are untimed
#else
			;Check if red LED is untimed
			BRCLR	LED_RED_CUR_SEQ,#$FE,LED_ISR_1	;LED is untimed
#endif
			;Retrigger timer 
			MOVB	#(LED_TIM_INTERVALL>>16), LED_REM_TIME;update remaining time
			LDD	TC0+(2*LED_OC) 			;update timer delay
			ADDD	#LED_TIM_INTERVALL		;
			STD	TC0+(2*LED_OC)			;
			TIM_CLRIF	LED_TIM, LED_OC		;clear interrupt flag		
			ISTACK_RTI				;done
			;Disable timer 
LED_ISR_1		MOVW	#$0000, LED_REM_TIME		;no remaining time, iterator reset
			TIM_DIS	LED_TIM, LED_OC			;disable timer
			ISTACK_RTI				;done

	
LED_CODE_END		EQU	*
LED_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef LED_TABS_START_LIN
			ORG 	LED_TABS_START, LED_TABS_START_LIN
#else
			ORG 	LED_TABS_START
#endif	
			;Pattern table
LED_SEQ_TAB		EQU	*
LED_SEQ_OFF		DB	%00000000	;prio 0 |
LED_SEQ_ON		DB	%11111111	;prio 1 |
LED_SEQ_HEART_BEAT	DB	%01010000	;prio 2 |h
LED_SEQ_DOUBLE_GAP	DB	%10110111	;prio 3 |i
LED_SEQ_SINGLE_GAP	DB	%11001111	;prio 4 |g
LED_SEQ_SLOW_BLINK	DB	%01111000	;prio 5 |h
LED_SEQ_FAST_BLINK	DB	%01010101	;prio 6 |e
LED_SEQ_SHORT_PULSE	DB	%01000000	;prio 7 |r
LED_SEQ_L0NG_PULSE	DB	%01111110	;prio 8 V

LED_TABS_END		EQU	*
LED_TABS_END_LIN	EQU	@
#endif
