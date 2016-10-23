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
;#   Blink pattern assignment:                                                 #
;#   +---+ --------------+----------------                                     #
;#   | 7 | Short pulse   |                  ^                                  #
;#   +---+               | Non-recurring    |h                                 #
;#   | 6 | Long pulse    |                  |i                                 #
;#   +---+ --------------+----------------  |g                                 #
;#   | 5 | Fast blink    |                  |h                                 #
;#   +---+               |                  |                                  #
;#   | 4 | Slow blink    |                  |p                                 #
;#   +---+               |                  |r                                 #
;#   | 3 | Single gap    | Recurring        |i                                 #
;#   +---+               |                  |o                                 #
;#   | 2 | Double gap    |                  |                                  #
;#   +---+               |                  |l                                 #
;#   | 1 | Heart beat    |                  |o                                 #
;#   +---+ --------------+----------------  |w                                 #
;#   | 0 | On            | Untimed          v                                  #
;#   +---+ --------------+----------------                                     #
;#                                                                             #
;###############################################################################

;#######################################################x#######################
;# Configuration                                                               #
;###############################################################################
;TIM configuration
;----------------- 
;TIM instance
#ifndef	SCI_OC_TIM
LED_TIM			EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Output compare channel
#ifndef	LED_OC
LED_OC			EQU	3 		;default is OC3
#endif
	
;LED configuration
;----------------- 
;LED A
#ifndef LED_A_BLINK_ON		
#ifndef LED_A_BLINK_OFF		
LED_A_BLINK_OFF		EQU	1 		;blink patterns disabled by default
#endif
#endif
#ifndef	LED_A_PORT
LED_A_PORT		EQU	PTP 		;default is PP
#endif
#ifndef	LED_A_PIN
LED_A_PIN		EQU	PP0 		;default is PP0
#endif

;LED B
#ifndef LED_B_BLINK_ON		
#ifndef LED_B_BLINK_OFF		
LED_B_BLINK_OFF		EQU	1 		;blink patterns disabled by default
#endif
#endif
#ifndef	LED_B_PORT
LED_B_PORT		EQU	PTP 		;default is port P
#endif
#ifndef	LED_B_PIN
LED_B_PIN		EQU	PP1 		;default is PP1
#endif

;LED C
#ifndef LED_C_BLINK_ON		
#ifndef LED_C_BLINK_OFF		
LED_C_BLINK_OFF		EQU	1 		;blink patterns disabled by default
#endif
#endif
#ifndef	LED_C_PORT
LED_C_PORT		EQU	PTP 		;default is port P
#endif
#ifndef	LED_C_PIN
LED_C_PIN		EQU	PP2 		;default is PP2
#endif

;LED D
#ifndef LED_D_BLINK_ON		
#ifndef LED_D_BLINK_OFF		
LED_D_BLINK_OFF		EQU	1 		;blink patterns disabled by default
#endif
#endif
#ifndef	LED_D_PORT
LED_D_PORT		EQU	PTP 		;default is port P
#endif
#ifndef	LED_D_PIN
LED_D_PIN		EQU	PP3 		;default is PP3
#endif

;Non-requrring sequences
#ifndef	LED_NONREC_MASK
LED_NONREC_MASK		EQU	$C0 		;default is patterns 7 and 8
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Timer configuration
;#Timer enable 
#ifdef LED_A_BLINK_ON
LED_TIM_ON		EQU	1
#endif
#ifdef LED_B_BLINK_ON
LED_TIM_ON		EQU	1
#endif
#ifdef LED_C_BLINK_ON
LED_TIM_ON		EQU	1
#endif
#ifdef LED_D_BLINK_ON
LED_TIM_ON		EQU	1
#endif
	
; TIOS 
#ifdef LED_TIM_ON
LED_TIOS_INIT		EQU	1<<LED_OC
#else
LED_TIOS_INIT		EQU	0
#endif
	
;#Output compare register
LED_OC_TC		EQU	TC0+(2*LED_OC)

;#Timer intervall
LED_OC_CNT_RST		EQU	(TIM_FREQ/4)>>16 		;2sec/8

;#Request masks
LED_TIMED_REQS		EQU	$FE 				;mask for timed requests
LED_NONREC_REQS		EQU	$C0 				;mask for non-recurring requests
	
;#Signal indexes
LED_SEQ_SHORT_PULSE	EQU	7
LED_SEQ_L0NG_PULSE	EQU	6
LED_SEQ_FAST_BLINK	EQU	5
LED_SEQ_SLOW_BLINK	EQU	4
LED_SEQ_SINGLE_GAP	EQU	3
LED_SEQ_DOUBLE_GAP	EQU	2
LED_SEQ_HEART_BEAT	EQU	1
LED_SEQ_ON		EQU	0
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
#ifdef LED_TIM_ON 	
LED_OC_CNT		DS	1 				;OC event counter
LED_SEQ_ITR		DS	1				;sequence iterator
#endif

;#LED status
#ifdef LED_A_BLINK_ON	
LED_A_REQ		DS	1 				;signal requests
LED_A_SEQ		DS	1 				;signal selector
#endif	
#ifdef LED_B_BLINK_ON	
LED_B_REQ		DS	1 				;signal requests
LED_B_SEQ		DS	1 				;signal selector
#endif	
#ifdef LED_C_BLINK_ON	
LED_C_REQ		DS	1 				;signal requests
LED_C_SEQ		DS	1 				;signal selector
#endif	
#ifdef LED_D_BLINK_ON	
LED_D_REQ		DS	1 				;signal requests
LED_D_SEQ		DS	1 				;signal selector
#endif	
#ifdef LED_LED4_ENABLE	
LED_LED4_REQ		DS	1 				;signal requests
LED_LED4_SEQ		DS	1 				;signal selector
#endif	

LED_VARS_END		EQU	*
LED_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	LED_INIT, 0
#ifdef LED_TIM_ON
			;Common variables
			CLRD			      		;zero -> D
			STD	LED_OC_CNT			;no remaining time, iterator reset
			;#LED status
#ifdef LED_A_BLINK_ON	
			STD	LED_A_REQ			;turn off LED A
#endif	
#ifdef LED_B_BLINK_ON	
			STD	LED_B_REQ			;turn off LED B
#endif	
#ifdef LED_C_BLINK_ON	
			STD	LED_C_REQ			;turn off LED C
#endif	
#ifdef LED_D_ENABLE	
			STD	LED_D_REQ			;turn off LED D
#endif	
#endif	
#emac

;#User functions
;#--------------
;#Turn on non-blinking LED
; args:   1: LED index (A..D)
; result: none
; SSTACK: none
;         X,Y and D are preserved 
#macro	LED_ON, 1
			BCLR	LED_\1_PORT, #LED_\1_PIN 	;clear port pin
#emac

;#Turn off non-blinking LED
; args:   1: LED index (A..D)
; result: none
; SSTACK: none
;         X, Y and D are preserved 
#macro	LED_OFF, 1
			BSET	LED_\1_PORT, #LED_\1_PIN 	;set port pin
#emac
	
;#Set blink pattern
; args:   1: LED index (A..D)
;         2: signal index (0..7)
; result: none
; SSTACK: none
;         X, Y and D are preserved 
#macro	LED_SET, 2
			BSET	LED_\1_REQ, #(1<<\2) 		;set request
			TIM_CNT_EN	LED_TIM			;enable timer counter
			TIM_IE	LED_TIM, LED_OC			;enable interrupt
#emac

;#Set blink pattern
; args:   1: LED index (A..D)
;         2: signal index (0..7)
; result: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	LED_CLR, 2
			BCLR	LED_\1_REQ, #(1<<\2) 		;clear request
#emac

;#Helper functions
;#----------------
;#Load LED sequence
; args:   1: LED index (A..D)
;         A: accumulated requests
; result: A: updated accumulated requests
; SSTACK: none
;         Y is preserved 
#macro	LED_LOAD_SEQ, 1
			ORAA	LED_\1_REQ			;accumulate requests in A
			LDAB	LED_\1_REQ			;requests -> B
			BEQ	LED_LOAD_SEQ_4			;no requests (B==0)
			BPL	LED_LOAD_SEQ_1			;no (non-recurring) short pulse requested
			;Short pulse (accumulated requests in A, requests in B)
			BCLR	LED_\1_REQ,#$80			;clear non-recurring short pulse request
			LDAB	LED_SEQ_TAB_SHORT_PULSE		;sequence pattern -> B
			JOB	LED_LOAD_SEQ_4			;update sqeuence
			;Long pulse (accumulated requests in A, requests in B)
LED_LOAD_SEQ_1		LDX	#LED_SEQ_TAB_L0NG_PULSE 	;sequence table pointer -> X
			LSLB					;shift towards MSB
			BPL	LED_LOAD_SEQ_2			;no (non-recurring) long pulse requested
			BCLR	LED_\1_REQ,#$40			;clear non-recurring long pulse request
			JOB	LED_LOAD_SEQ_3			;update sqeuence
			;Other patterns (accumulated requests in A, shifted requests in B)
LED_LOAD_SEQ_2		INX					;advance table pointer
			LSLB					;shift towards MSB
			BPL	LED_LOAD_SEQ_2			;check next sequence
LED_LOAD_SEQ_3		LDAB	0,X				;sequence pattern -> B
LED_LOAD_SEQ_4		STAB	LED_\1_SEQ			;sore new sequence
#emac
	
;#Update LED according to its sequence pattern
; args:   1: LED index (A..D)
;         B: sequence iterator
; result: none
; SSTACK: none
;         X, Y and D are preserved 
#macro	LED_UPDATE, 1
			BITB	LED_\1_SEQ 			;check sequence pattern
			BEQ	LED_UPDATE_1			;turn on LED
			LED_OFF	\1				;turn off LED
			JOB	DONE				;done
LED_UPDATE_1		LED_ON	\1				;turn on LED
DONE			EQU	*				;done
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef LED_CODE_START_LIN
			ORG 	LED_CODE_START, LED_CODE_START_LIN
#else
			ORG 	LED_CODE_START
#endif

#ifdef	LED_TIM_ON	
;#ISR
;---- 
LED_ISR			EQU	*			
			;Clear interrupt flag
			TIM_CLRIF LED_TIM, LED_OC 		;clear IF
			;Check and adjust remaining time
			LDD	LED_OC_CNT			;OC counter -> A, seq. iterator -> B
			TBEQ	A, LED_ISR_1			;OC event count surpassed
			DBEQ	A, LED_ISR_1			;OC event count reached
			STAA	LED_OC_CNT			;update OC event count
			ISTACK_RTI				;done
			;Advance sequence iterator iterator (0 in A, sequence iterator in B)
LED_ISR_1		MOVB	#LED_OC_CNT_RST, LED_OC_CNT 	;reset OC event count
			LSRB			 		;shift sequence iterator
			BNE	LED_ISR_2			;update LEDs
			;Load sequence patterns (0 in A)
#ifdef LED_A_BLINK_ON	
			LED_LOAD_SEQ	A 			;load sequence for LED A
#endif	
#ifdef LED_B_BLINK_ON	
			LED_LOAD_SEQ	B 			;load sequence for LED B
#endif	
#ifdef LED_C_BLINK_ON	
			LED_LOAD_SEQ	C 			;load sequence for LED C
#endif	
#ifdef LED_D_BLINK_ON	
			LED_LOAD_SEQ	D 			;load sequence for LED D
#endif
			LDAB	#$80
			;Check if timer is needed (ORed requests in A, sequence iterator in B)
			BITA	#LED_TIMED_REQS			;check if timer is still required
			BNE	LED_ISR_2			;timer is still required
			TIM_DIS	LED_TIM, LED_OC			;disable timer
			CLR	LED_OC_CNT			;clear OC event count
			;Update LEDs (sequence iterator in B)
LED_ISR_2		STAB	LED_SEQ_ITR 			;update sequence iterator
#ifdef LED_A_BLINK_ON	
			LED_UPDATE	A 			;update LED A
#endif	
#ifdef LED_B_BLINK_ON	
			LED_UPDATE	B 			;update LED B
#endif	
#ifdef LED_C_BLINK_ON	
			LED_UPDATE	C 			;update LED C
#endif	
#ifdef LED_D_BLINK_ON	
			LED_UPDATE	D 			;update LED D
#endif
			ISTACK_RTI				;done
#endif
	
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
LED_SEQ_TAB_SHORT_PULSE	DB	%01000000	;prio 7 ^
LED_SEQ_TAB_L0NG_PULSE	DB	%01111110	;prio 6 |h
LED_SEQ_TAB_FAST_BLINK	DB	%01010101	;prio 5 |i
LED_SEQ_TAB_SLOW_BLINK	DB	%01111000	;prio 4 |g
LED_SEQ_TAB_SINGLE_GAP	DB	%11001111	;prio 3 |h
LED_SEQ_TAB_DOUBLE_GAP	DB	%10110111	;prio 2 |e
LED_SEQ_TAB_HEART_BEAT	DB	%01010000	;prio 1 |r
LED_SEQ_TAB_ON		DB	%11111111	;prio 0 |

LED_TABS_END		EQU	*
LED_TABS_END_LIN	EQU	@
#endif
