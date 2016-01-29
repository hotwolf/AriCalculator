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
;TIM configuration
;Output compare channel
#ifndef	LED_OC
LED_OC			EQU	2 		;default is OC2
#endif

;I/O configuration
#ifdef LED_RED_ENABLE	
; Red
#ifndef	LED_RED_PORT
LED_RED_PORT		EQU	PORTE 		;default is PE
#endif
#ifndef	LED_RED_PIN
LED_RED_PIN		EQU	PE1 		;default is PE1
#endif
#endif
#ifdef LED_GREEN_ENABLE	
; Green
#ifndef	LED_GREEN_PORT
LED_GREEN_PORT		EQU	PORTE 		;default is PE
#endif
\ifndef	LED_GREEN_PIN
LED_GREEN_PIN		EQU	PE0 		;default is PE0
#endif
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

#ifdef LED_RED_ENABLE	
#ifndef	LED_RED_PORT
;#Red LED
LED_RED_REQ		DS	1 				;signal requests
LED_RED_CUR_SEQ		DS	1 				;signal selector
#endif	
#endif	
	
#ifdef LED_GREEN_ENABLE	
#ifndef	LED_GREEN_PORT
;#Green LED
LED_RED_REQ		DS	1 				;signal requests
LED_RED_CUR_SEQ		DS	1 				;signal selector
#endif	
#endif	
	
LED_VARS_END		EQU	*
LED_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	LED_INIT, 0
			;Common variables
			CLR	LED_REM_TIME	       		;start with no remaining time
			MOVB	#$80, LED_SEQ_ITERATOR		;sequence iterator
#ifdef LED_RED_ENABLE	
			;Red LED
			MOVW	#$0000,	LED_RED_REQ 		;red LED status
#endif	
#ifdef LED_GREEN_ENABLE	
			;Green LED
			MOVW	#$0000,	LED_GREEN_REQ 		;green LED status
#endif	
#emac


;#Set signal
; args:   1: color ("RED" or "GREEN")
;         2: signal index (7..0)
; result: none
; SSTACK: none
;         X, and Y, and D are preserved 
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
			TIM_BREN LED_OC, LED_SET_ATOMIC_1	;timer already enabled
			TIM_EN	 LED_OC				;enable timer
			TIM_SET_DLY_IMM	#5			;trigger interrupt
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






;#Update LED
; args:   1: color ("RED" or "GREEN")
;         Y: points to sequence table
; result: none
; SSTACK: none
;         X, Y, and A are preserved 
#macro	LED_UPDATE, 1
			LDAB	LED_\1_CUR_SEQ			;sequence selector -> B
			BITB	#$FE				;checl for on or off
			BEQ	LED_UPDATE_2			;do nothing
			LDAB	B,Y				;sequence -> B	       
			ANDB	LED_SEQ_ITERATOR		;LED state -> B	       
			BEQ	LED_UPDATE_1			;clear LED	       
			BSET	LED_\1_PORT, #LED_\1_PIN	;set LED	       
			JOB	LED_UPDATE_2			;LED updated	       
LED_UPDATE_1		BCLR	LED_\1_PORT, #LED_\1_PIN	;clear LED	       
LED_UPDATE_2		EQU	*				;LED updated	       
#emac

;#Check requests
; args:   1: color ("RED" or "GREEN")
;         Y: points to sequence table
; result: none
; SSTACK: none
;         X, Y, and A are preserved 
#macro	LED_CHECK_REQ, 1
			LDAB	

	
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
			;Clear interrupt flag
			TIM_CLRIF	LED_OC			;clear interrupt flag		
			;Adjust remaining time
			LDAB	LED_REM_TIME			;remaining time -> X
			BEQ	LED_ISR_1			;update LEDs
			DECB					;decrement remaining time
			STAB	LED_REM_TIME			;update remaining time
			ISTACK_RTI				;done
			;Check for pattern transition
LED_ISR_1		BRCLR	LED_SEQ_ITERATOR, #$7F, LED_ISR_
			;Update LEDs
         		LDY	#LED_SEQ_TAB	 		;sequence table -> Y
#ifdef LED_RED_ENABLE	
			;Update red LED (sequence table in Y)
			LED_UPDATE	RED
#endif
#ifdef LED_GREEN_ENABLE	
			;Update green LED (sequence table in Y)
			LED_UPDATE	GREEN
#endif
			;Advance sequence 
			LSR	LED_SEQ_ITERATOR 		;advance sequence iterator
			BEQ	LED_ISR_			;handle next request
			



				;Sequence complete 
			MOVB	#$80, LED_SEQ_ITERATOR		;reset sequence iterator			
#ifdef LED_RED_ENABLE	
			;Check requests for red LED 
			CLRA					;
			LDAB	#80
			BITA	LED_RED_REQ
			BNE	LED_ISR_ 			;request found
			INCA
			LSRB
			TBNE	

	
			;Update output compare register asap
			LDD	LED_TIME_LEFT_LSW		;remaining time (LSW) -> D
			ADDD	LED_OC_REG
			STD	LED_OC_REG
			;Clear interrupt flag
			TIM_CLRIF	LED_OC			;clear interrupt flag		
			



			;Check MSB of remaining delay 
			LDAB	LED_TIME_LEFT_MSB		;remaining time (MSB) -> B
			BNE	LED_ISR_ 			;wait for a full timer period
			;Check LSW of remaining delay 		
			LDD	LED_TIME_LEFT_LSW		;remaining time (LSW) -> D
			BEQ	DELAY_ISR_2 			;delay is over
			ADDD	LED_OC_REG
			STD	LED_OC_REG



			MOVW	#$0000, DELAY_TIME_LEFT_LSW	;update remaining time
			BMI	DELAY_ISR_4			;delay >= 2^15 timer counts


	

LED_REMTC_MSB		DS	1				;remaining timer counts (MSB)
LED_REMTC_LSW		DS	2 				;remaining timer counts (LSW)







	
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
LED_SEQ_TAB		EQU	*-2
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
