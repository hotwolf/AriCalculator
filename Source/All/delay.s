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
;Timer  counts per ms 
DELAY_TCPMS		EQU	TIM_FREQ/1000000			
 	
;Timer register 
DELAY_TC_REG		EQU	TC0+(2*DELAY_OC)			




	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DELAY_VARS_START_LIN
			ORG 	DELAY_VARS_START, DELAY_VARS_START_LIN
#else
			ORG 	DELAY_VARS_START
DELAY_VARS_START_LIN	EQU	@			
#endif	

DELAY_TIME_LEFT		EQU	* ;remaining delay in timer counts
DELAY_TIME_LEFT_MSW	DS	2 ;remaining delay in ms
DELAY_TIME_LEFT_LSW	DS	2 ;remaining delay in ms

DELAY_VARS_END		EQU	*
DELAY_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	DELAY_INIT, 0


	
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DELAY_CODE_START_LIN
			ORG 	DELAY_CODE_START, DELAY_CODE_START_LIN
#else
			ORG 	DELAY_CODE_START
#endif

;#ISR
;---- 
DELAY_ISR		EQU	*			
			;Clear interrupt flag 
			TIM_CLRIF	DELAY_OC		;clear interrupt flag
			;Check MSW of remaining delay 
			LDX	DELAY_TIME_LEFT_MSW		;remaining time (MSW) -> X
			BNE	DELAY_ISR_ 			;wait a full timer period
			;Check LSW of remaining delay 		
			LDD	DELAY_TIME_LEFT_LSW		;remaining time (LSW) -> D
			BEQ	DELAY_ISR_ 			;delay is over
			BMI	DELAY_ISR_			;delay >= 2^15 timer counts
			;Delay > 2^15 timer counts (remaining timer counts in D)	
			ADDD	DELAY_TC_REG			;update delay
			TFR	D, X
			SUBD	#OFFSET
			SUBD	TCNT
			CPD	



			TFR	D, X
			ADDD	DELAY_TC_REG			;update delay
			STD	DELAY_TC_REG			;set timer channel register
			SUBD	SUV


			TIM_CLRIF	DELAY_OC		;clear interrupt flag
			SUBD 	TCNT
			




			BMI	DELAY_ISR_ 			;delay too short
			
	
			TFR	D, X
			S

			MOVW	$#0000, DELAY_TIME_LEFT_LSW	;update 			
			
			

			TIM_CLRIF	DELAY_OC		;clear interrupt flag
			;Done
			ISTACK_RTS
			;Wait a full timer period (MSW of remaining delay in X)			
DELAY_ISR_		TIM_CLRIF	DELAY_OC		;clear interrupt flag
			DEX					;decrement X
			LDX	DELAY_TIME_LEFT_MSW		;remaining time (MSW) -> X
			;Done
			ISTACK_RTS

DELAY_ISR_			



	
	SUBD	DELAY_TIM_PERIOD	;subtract a full timer period
			BCC	DELAY_ISR_ 		;wait a full timer period


	
	
	
			LDX	DELAY_LISTPTR
			LDD	2,Y
			CMP	DELAY_INTERVAL
			

	
	
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
