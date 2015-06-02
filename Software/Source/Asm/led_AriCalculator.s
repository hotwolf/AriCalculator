#ifndef	LED
#define	LED
;###############################################################################
;# S12CBase - LED - LED Driver (AriCalculator)                                 #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12C(X) MCU  #
;#    families.                                                                #
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
;#    This module controls the LED on the OpenBDM Pod.                         #
;###############################################################################
;# Version History:                                                            #
;#    January 7, 2015                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Ports
LED_PORT		EQU	PORTE
LED_RED			EQU	PE1	
LED_GREEN		EQU	PE0		
LED_ALL			EQU	LED_GREEN|LED_RED
LED_BUSY		EQU	LED_GREEN
LED_ERR			EQU	LED_RED

;#Timer channels
LED_OC			EQU	6		;delay timer OC6

;#Error status
LED_STATE_DLYCNT    	EQU	$FFF8	 	;delay counter
LED_STATE_ERR     	EQU	$0004	 	;untimed error
LED_STATE_ERRBEEP	EQU	$0002	 	;error beep
LED_STATE_COMERR	EQU	$0001	 	;comunication error

;#Error signals
LED_ERRBEEP_CNT		EQU	-190<<3		;error beep:    2 sec
LED_COMERR_ON_CNT	EQU 	 -95<<3		;com error on:  0.5 sec
LED_COMERR_OFF_CNT	EQU	-190<<3		;com error off: 1 sec
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef LED_VARS_START_LIN
			ORG 	LED_VARS_START, LED_VARS_START_LIN
#else
			ORG 	LED_VARS_START
LED_VARS_START_LIN	EQU	@			
#endif	
			ALIGN	1

			;#Delay counter and flags
LED_STATE		DS	2		;value of the SCIBD register *LED_BMUL
	
LED_VARS_END		EQU	*
LED_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	LED_INIT, 0
			;Initialize LEDs
			;LED_OFF			;turn all LEDs off
			;Initialize timer
			BSET	TIOS, #(1<<LED_OC)
			;BCLR	TCTL2, #(3<<(2*(LED_OC-4)))
			;BCLR	TIE, #(1<<LED_OC)
			;Initialize variable
			MOVW	#$0000,	LED_STATE
#emac
	
;# Busy Signal #################################################################
;#Set busy signal
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	LED_BUSY_ON, 0
			BCLR	LED_PORT, #LED_BUSY 	;turn LED on
#emac
	
;#Clear busy signal
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	LED_BUSY_OFF, 0
			BSET	LED_PORT, #LED_BUSY	;turn LED off
#emac

;# Error Signal ################################################################
;#Set untimed error signal
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	LED_ERR_ON, 0
			BSET	LED_STATE+1, #LED_STATE_ERR		;set signal status
			BCLR	LED_PORT, #LED_ERR			;turn LED on
			TIM_DIS	LED_OC 					;disable timer
#emac
	
;#Clear untimed error signal
; args:   1: macro to start atomic code
;         2: macro to end atomic code
; result: none
; SSTACK: none
;         X, Y, and A are preserved 
#macro	LED_ERR_OFF, 2
			\1		 				;start atomic code section
			;Update status
			LDAB	LED_STATE+1				;flags -> B
			ANDB 	#(~(LED_STATE_ERR|LED_STATE_ERRBEEP))	;clear untimed error and beep request
			;Check for communication error (flags in B)
			BITB	#LED_STATE_COMERR			;check if untimed error or is active
			BEQ	DONE					;untimed error is active
			MOVB	#(LED_COMERR_OFF_CNT>>8), LED_STATE 	;set counter
			ANDB	#(LED_STATE_DLYCNT&$FF)	
			ORAB	#(LED_COMERR_OFF_CNT&LED_STATE_DLYCNT&$FF)
			MOVW	TCNT, (TC0+(2*LED_OC)) 			;enable timer
			TIM_EN	LED_OC	
			;Turn off LED (flags in B)
DONE			BSET	LED_PORT, #LED_ERR			;turn LED off
			STAB	LED_STATE+1				;set state
			\2	 					;end atomic code section
#emac

;#Error beep replacement
; args:   1: macro to start atomic code
;         2: macro to end atomic code
; result: none
; SSTACK: none
;         X and Y are preserved 
#macro	LED_ERRBEEP, 2
			\1		 				;start atomic code section
			;Check for untimed error nested beep 
			LDAB	LED_STATE+1				;flags -> B
			BITB	#(LED_STATE_ERR|LED_STATE_ERRBEEP)	;check if untimed error or is active
			BNE	DONE					;untimed error is active
			;Start error beep (flags in B) 
			LDAA	#(LED_ERRBEEP_CNT>>8) 			;set counter
			ANDB	#(LED_STATE_DLYCNT&$FF)	
			ORAB	#(LED_ERRBEEP_CNT&LED_STATE_DLYCNT&$FF)
			MOVW	TCNT, (TC0+(2*LED_OC)) 			;enable timer
			TIM_EN	LED_OC	
			BCLR	LED_PORT, #LED_ERR			;turn LED on
			STD	LED_STATE				;set state
DONE			\2	 					;end atomic code section
#emac
	
;#Set comunication error signal
; args:   1: macro to start atomic code
;         2: macro to end atomic code
; result: none
; SSTACK: none
;         X and Y are preserved 
#macro	LED_COMERR_ON, 2
			\1		 				;start atomic code section
			;Check for running error signals 
			LDAB	LED_STATE+1				;flags -> B
			BITB	#(LED_STATE_ERR|LED_STATE_ERRBEEP|LED_STATE_COMERR);check if untimed error or is active
			BNE	DONE					;untimed error is active
			;Start error beep (flags in B)
			LDAA	#(LED_COMERR_ON_CNT>>8) 		;set counter
			ANDB	#(LED_STATE_DLYCNT&$FF)	
			ORAB	#(LED_COMERR_ON_CNT&LED_STATE_DLYCNT&$FF)
			MOVW	TCNT, (TC0+(2*LED_OC)) 			;enable timer
			TIM_EN	LED_OC	
			BCLR	LED_PORT, #LED_ERR			;turn LED on
			STD	LED_STATE				;set state
DONE			\2	 					;end atomic code section
#emac
	
;#Clear comunication error signal
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	LED_COMERR_OFF, 0
			BCLR	LED_STATE, #LED_STATE_COMERR		;set signal status
#emac

;#Empty macro
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	LED_NOP, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef LED_CODE_START_LIN
			ORG 	LED_CODE_START, LED_CODE_START_LIN
#else
			ORG 	LED_CODE_START
LED_CODE_START_LIN	EQU	@			
#endif	

;#Timer triggered ISR
LED_ISR			EQU	*
			;Clear interrupt flag
			TIM_CLRIF	LED_OC	
			;Increment counter
			LDD	LED_STATE 				;increment delay counter
			ADDD	#$0008
			BCC	LED_ISR_4 				;no overflow
			;End of delay (state in D)
			ANDB	#~LED_STATE_ERRBEEP 			;clear error beep flag
			BITB	#LED_STATE_COMERR 			;check if com error is active
			BEQ	LED_ISR_2 				;com error is inactive 
			;Check LED status (state in D)
			ANDB	#(LED_STATE_DLYCNT&$FF)			;clear delay count
			BRCLR	LED_PORT, #LED_ERR, LED_ISR_1		;LED is on
			;Turn LED on (state in D)
			LDAA	#(LED_COMERR_ON_CNT>>8) 		;set counter
			ORAB	#(LED_COMERR_ON_CNT&LED_STATE_DLYCNT&$FF)
			BCLR	LED_PORT, #LED_ERR			;turn LED on
			JOB	LED_ISR_4
			;Turn LED off (state in D)
LED_ISR_1		LDAA	#(LED_COMERR_OFF_CNT>>8) 		;set counter
			ORAB	#(LED_COMERR_OFF_CNT&LED_STATE_DLYCNT&$FF)
			JOB	LED_ISR_3
			;Turn off error LED 
LED_ISR_2		TIM_DIS	LED_OC 					;disable timer	
LED_ISR_3		BSET	LED_PORT, #LED_ERR			;turn LED off
LED_ISR_4		STD	LED_STATE				;update state
			;Done
			ISTACK_RTI
	
LED_CODE_END		EQU	*	
LED_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef LED_TABS_START_LIN
			ORG 	LED_TABS_START, LED_TABS_START_LIN
#else
			ORG 	LED_TABS_START
LED_TABS_START_LIN	EQU	@			
#endif	

LED_TABS_END		EQU	*	
LED_TABS_END_LIN	EQU	@	
#endif	
