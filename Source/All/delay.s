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
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DELAY_VARS_START_LIN
			ORG 	DELAY_VARS_START, DELAY_VARS_START_LIN
#else
			ORG 	DELAY_VARS_START
DELAY_VARS_START_LIN	EQU	@			
#endif	

DELAY_AUTO_LOC1		ALIGN	1
DELAY_AUTO_LOC1_SEL	EQU	*-DELAY_AUTO_LOC1		;1st auto-place location

DELAY_REMTC_LSW		DS	2 				;remaining timer counts
DELAT_REMTC_MSB		EQU	(DELAY_AUTO_LOC1_SEL*DELAY_AUTO_LOC1)+(DELAY_AUTO_LOC2_SEL*DELAY_AUTO_LOC2)

DELAY_AUTO_LOC2		UNALIGN	(1-DELAY_AUTO_LOC1_SEL)		;2nd auto-place location
DELAY_AUTO_LOC2_SEL	EQU	*-DELAY_AUTO_LOC2
	
DELAY_VARS_END		EQU	*
DELAY_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (0 in D)
#macro	DELAY_INIT, 0
			STAA	DELAT_REMTC_MSB
			STD	DELAT_REMTC_LSW
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
; SSTACK: 2 or 4 bytes
;         X, Y, and D are preserved 
DELAY_WAIT_MS		EQU	*

			;Save registers ()
			PSHY
			PSHX
			PSHD
			MOVB	DELAY_REM_TC_MSB, 1,-SP


			;Calculate timer counts (ms delay in D)
			LDY	#(TIM_FREQ/1000) 		;TIM freq in kHz -> Y
			TFR	Y, X				;TIM freq in kHz -> X
			IDIV					;D / X -> X remainder -> D
			EXG	X, D				
			STAB	DELAY_REM_TC_MSB
			EXG	X, Y
			CLRA
			CLRB
			EDIV					;Y:D / X -> Y remmainder -> D
			STY	DELAY_REM_TC_LSW
	
	

	
;#ISR
;---- 
DELAY_ISR		EQU	*			
			;Clear interrupt flag
			TIM_CLRIF	DELAY_OC		;clear interrupt flag		
			;Check MSW of remaining delay 
			LDX	DELAY_TIME_LEFT_MSW		;remaining time (MSW) -> X
			BNE	DELAY_ISR_3 			;wait for a full timer period
			;Check LSW of remaining delay 		
			LDD	DELAY_TIME_LEFT_LSW		;remaining time (LSW) -> D
			BEQ	DELAY_ISR_2 			;delay is over
			MOVW	#$0000, DELAY_TIME_LEFT_LSW	;update remaining time
			BMI	DELAY_ISR_4			;delay >= 2^15 timer counts
			;Delay < 2^15 timer counts (LSW of remaining timer counts in D)
			ADDD	DELAY_TC_REG			;calculate new output compare value
			STD	DELAY_TC_REG			;update delay
			CPD 	TCNT				;check if output compare was missed
			BPL	DELAY_ISR_2			;output compare still ahead (done)
			;Delay is over 
DELAY_ISR_1		TIM_DIS	DELAY_OC 			;disable timer
DELAY_ISR_2		ISTACK_RTI				;done
			;Wait for a full timer period (MSW of emaining timer counts in X)
DELAY_ISR_3		DEX					;subtract one timer intervall
			STX	DELAY_TIME_LEFT_MSW		;update remaining time
			ISTACK_RTI				;done
			;Delay >= 2^15 timer counts (LSW of remaining timer counts in D)
DELAY_ISR_4		ADDD	DELAY_TC_REG			;calculate new output compare value
			STD	DELAY_TC_REG			;update delay
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
