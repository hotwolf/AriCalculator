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
;#   | 0 | Short pulse   |                  ^                                  #
;#   +---+               | Non-recurring    |h                                 #
;#   | 1 | Long pulse    |                  |i                                 #
;#   +---+ --------------+----------------  |g                                 #
;#   | 2 | Fast blink    |                  |h                                 #
;#   +---+               |                  |                                  #
;#   | 3 | Slow blink    |                  |p                                 #
;#   +---+               |                  |r                                 #
;#   | 4 | Shingle gap   | Recurring        |i                                 #
;#   +---+               |                  |o                                 #
;#   | 5 | Double gap    |                  |                                  #
;#   +---+               |                  |l                                 #
;#   | 6 | Heart beat    |                  |o                                 #
;#   +---+ --------------+----------------  |w                                 #
;#   | 7 | On            | Untimed          v                                  #
;#   +---+ --------------+----------------                                     #
;#                                                                             #
;###############################################################################

;#######################################################x########################
;# Configuration                                                               #
;###############################################################################
;TIM configuration
;Output compare channel
#ifndef	LED_OC
LED_OC			EQU	2 		;default is OC2
#endif

;I/O configuration
#ifndef LED_NO_RED	
; Red
#ifndef	LED_RED_PORT
LED_RED_PORT		EQU	PORTE 		;default is PE
#endif
#ifndef	LED_RED_PIN
LED_RED_PIN		EQU	PE1 		;default is PE1
#endif
#endif
#ifndef LED_NO_GREEN	
; Green
#ifndef	LED_GREEN_PORT
LED_GREEN_PORT		EQU	PORTE 		;default is PE
#endif
#ifndef	LED_GREEN_PIN
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

#ifndef LED_NO_RED	
#ifndef	LED_RED_PORT
;#Red LED
LED_RED_REQ		DS	1 				;signal requests
LED_RED_CUR_SEQ		DS	1 				;signal selector
#endif	
#endif	
	
#ifndef LED_NO_GREEN	
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
;#Initialization (0 in D)
#macro	LED_INIT, 0
			;Common variables
			MOVB	#$80, LED_SEQ_ITERATOR		;sequence iterator
#ifndef LED_NO_RED	
			;Red LED
			STD	LED_RED_REQ 			;red LED status
#endif	
#ifndef LED_NO_GREEN	
			;Green LED
			STD	LED_GREEN_REQ 			;green LED status
#endif	
#emac

;#Set signal
; args:   1: color ("RED" or "GREEN")
;         2: signal index (7..0)
; result: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	LED_SET_SIGNAL, 2
			BSET	LED_\1_REQ, #(1<<\2) 		;set request
			BSET	TIE, #(1<<LED_OC)		;enable timer interrupt
			MOVB	#(TEN|TSFRZ), TSCR1		;enable timer
#emac

;#Clear signal
; args:   1: color ("RED" or "GREEN")
;         2: signal index (7..0)
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
#macro	LED_CLR_SIGNAL, 2
			BCLR	LED_\1_REQ, #(1<<\2) 		;clear request
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
			;Clear interrupt flag
			TIM_CLRIF	LED_OC			;clear interrupt flag		
			;Adjust remaining time
			LDAB	LED_REM_TIME			;remaining time -> X
			BEQ	LED_ISR_1			;update LEDs
			DECB					;decrement remaining time
			STAB	LED_REM_TIME			;update remaining time
			ISTACK_RTI				;done
			;Update LEDs
LED_ISR_1		LDY	#LED_SEQ_TAB	 		;sequence table -> Y
#ifndef LED_NO_RED	
			;Update red LED 
			LDAB	LED_RED_CUR_SEQ			;sequence selector -> B 
			LDAB	B,Y				;sequence -> B	       
			ANDB	LED_SEQ_ITERATOR		;LED state -> B	       
			BEQ	LED_ISR_2			;clear LED	       
			BSET	LED_RED_PORT, #LED_RED_PIN	;set LED	       
			JOB	LED_ISR_3			;LED updated	       
LED_ISR_2		BCLR	LED_RED_PORT, #LED_RED_PIN	;clear LED	       
LED_ISR_3		EQU	*				;LED updated	       
#endif
#ifndef LED_NO_GREEN	
			;Update green LED 
			LDAB	LED_GREEN_CUR_SEQ               ;sequence selector -> B
			LDAB	B,Y				;sequence -> B	       
			ANDB	LED_SEQ_ITERATOR		;LED state -> B	       
			BEQ	LED_ISR_4			;clear LED	       
			BSET	LED_GREEN_PORT, #LED_GREEN_PIN	;set LED	       
			JOB	LED_ISR_5			;LED updated	       
LED_ISR_4		BCLR	LED_GREEN_PORT, #LED_GREEN_PIN	;clear LED	       
LED_ISR_5		EQU	*				;LED updated	       
#endif
			;Advance sequence 
			LSR	LED_SEQ_ITERATOR 		;advance sequence iterator
			BCC	LED_ISR_			;set up next timer delay
			;Sequence complete 
			MOVB	#$80, LED_SEQ_ITERATOR		;reset sequence iterator			
#ifndef LED_NO_RED	
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
LED_SEQ_TAB		EQU	*
LED_SEQ_L0NG_PULSE	DB	%01111110
LED_SEQ_SHORT_PULSE	DB	%01000000
LED_SEQ_FAST_BLINK	DB	%01010101
LED_SEQ_SLOW_BLINK	DB	%01111000
LED_SEQ_SINGLE_GAP	DB	%11001111
LED_SEQ_DOUBLE_GAP	DB	%10110111
LED_SEQ_HEART_BEAT	DB	%01010000
LED_SEQ_ON  		DB	%11111111
	
LED_TABS_END		EQU	*
LED_TABS_END_LIN	EQU	@
#endif
