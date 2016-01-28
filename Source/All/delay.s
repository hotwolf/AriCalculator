#ifndef	DELAY_COMPILED 
#define	DELAY_COMPILED
;###############################################################################
;# S12CBase - DELAY - Delay Driver                                             #
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
;#    January20, 2016                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    TIM - Timer Driver                                                       #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;TIM configuration
;Output compare channel
#ifndef	DELAY_OC
DELAY_OC		EQU	3 		;default is OC2
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Timer configuration
; TIOS 
DELAY_TIOS_INIT		EQU	1<<DELAY_OC
; TOC7M/D
;DELAY_TOC7MD_INIT	EQU	0
; TTOV
;DELAY_TTOV_INIT	EQU	0
; TCTL1/2
;DELAY_TCTL12_INIT	EQU	0
; TCTL3/4
;DELAY_TCTL34_INIT	EQU	0

;#Output compare register
DELAY_OC_REG		EQU	TC0+(2*DELAY_OC)
	
;#Shortest OC period (8 bus cycles)
DELAY_MIN_TC		EQU	8*(CLOCK_BUS_FREQ/TIM_FREQ)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DELAY_VARS_START_LIN
			ORG 	DELAY_VARS_START, DELAY_VARS_START_LIN
#else
			ORG 	DELAY_VARS_START
DELAY_VARS_START_LIN	EQU	@			
#endif	

DELAY_REM_TIME		DS	2 		;counts remaining timer intervalls
	
DELAY_VARS_END		EQU	*
DELAY_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (0 in D)
#macro	DELAY_INIT, 0
#emac
	
;#Wait for a given time (or longer)
; args:   D: delay in ms
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
#mac DELAY_WAIT_MS, 0
			SSTACK_JOBSR	DELAY_WAIT_MS, 6
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DELAY_CODE_START_LIN
			ORG 	DELAY_CODE_START, DELAY_CODE_START_LIN
#else
			ORG 	DELAY_CODE_START
#endif

;#Wait for a given time (or longer)
; args:   D: delay in ms
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
DELAY_WAIT_MS		EQU	*
			;Save registers (ms delay in D)
			PSHY					;save Y
			PSHD					;save D
			;Calculate tc delay (ms delay in D)
			LDY	#(TIM_FREQ/1000) 		;TIM freq in kHz -> Y
			EMUL					;D * Y -> Y:D
			;Adjust tc delay if LSW is to short (tc delay in Y:D)
			EXG	D, Y 				;tc delay ->D:Y
			CPY	#DELAY_MIN_TC			;check for min. timer delay
			SBCB	#0				;subtract one
			SBCA	#0				; timer intervall
			BCS	DELAY_WAIT_MS_3 		;do nothing
			EXG	D, Y 				;adjusted tc delay ->Y:D
			;Set up timer (adjusted tc delay in Y:D)
			SEI		       			;start of atomoc sequence
			STD	DELAY_REM_TIME			;set remainig time counter
			TIM_EN		DELAY_OC		;enable timer
			TIM_SET_DLY_D	DELAY_OC		;RPO PWO OPwP
			TIM_CLRIF	DELAY_OC		;|<------->| 8 bus cycles
			;Wait until delay is over
DELAY_WAIT_MS_1		BRCLR	TIE, #(1<<DELAY_OC), DELAY_WAIT_MS_2;check IF
			ISTACK_WAI				;wait for any event
			SEI					;prevent interrupts
			JOB	DELAY_WAIT_MS_1			;check IF
			;Done
DELAY_WAIT_MS_2		CLI					;end of atomic sequence
DELAY_WAIT_MS_3		SSTACK_PREPULL	6			;check SSTACK
			PULD					;restore D
			PULY					;restore Y
			RTS
	
;#ISR
;---- 
DELAY_ISR		EQU	*			
			;Clear interrupt flag
			TIM_CLRIF	DELAY_OC		;clear interrupt flag		
			;Adjust remaining time
			LDX	DELAY_REM_TIME			;remaining time -> X
			BEQ	DELAY_ISR_1			;delay is over
			DEX					;decrement remaining time
			STX	DELAY_REM_TIME			;update remaining time
			ISTACK_RTI				;done
			;Delay is over 
DELAY_ISR_1		TIM_DIS	DELAY_OC 			;disable timer
			ISTACK_RTI				;done
			
DELAY_CODE_END		EQU	*
DELAY_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DELAY_TABS_START_LIN
			ORG 	DELAY_TABS_START, DELAY_TABS_START_LIN
#else
			ORG 	DELAY_TABS_START
#endif	

DELAY_TABS_END		EQU	*
DELAY_TABS_END_LIN	EQU	@
#endif
