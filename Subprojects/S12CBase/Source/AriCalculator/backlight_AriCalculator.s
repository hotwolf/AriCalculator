#ifndef	BACKLIGHT
#define	BACKLIGHT
;###############################################################################
;# S12CBase - BACKLIGHT - Backlight Driver (AriCalculator)                     #
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
;#    This module controls the BACKLIGHT on the OpenBDM Pod.                   #
;###############################################################################
;# Version History:                                                            #
;#    June 3, 2015                                                             #
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
;TIM configuration
;----------------- 
;TIM instance
#ifndef	BACKLIGHT_TIM
BACKLIGHT_TIM		EQU	TIM 		;default is the TIM
#endif
;Output compare channel
#ifndef	BACKLIGHT_OC
BACKLIGHT_OC		EQU	5 		;default is OC5
#endif

;Port configuration
;------------------ 
#ifndef	BACKLIGHT_PORT
BACKLIGHT_PORT		EQU	PTT
#endif
#ifndef	BACKLIGHT_PIN
BACKLIGHT_PIN		EQU	PT5
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;TIM configuration
;----------------- 
BACKLIGHT_TIOS_INIT	EQU	1<<BACKLIGHT_OC
BACKLIGHT_TTOV_INIT	EQU	1<<BACKLIGHT_OC
BACKLIGHT_TCTL12_INIT	EQU	2<<(2*BACKLIGHT_OC)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef BACKLIGHT_VARS_START_LIN
			ORG 	BACKLIGHT_VARS_START, BACKLIGHT_VARS_START_LIN
#else
			ORG 	BACKLIGHT_VARS_START
BACKLIGHT_VARS_START_LIN	EQU	@			
#endif	
	
BACKLIGHT_VARS_END		EQU	*
BACKLIGHT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	BACKLIGHT_INIT, 0
			;Initialize GPIO
			;BCLR	BACKLIGHT_PORT, #BACKLIGHT_PIN
			;BSET	BACKLIGHT_DDR,  #BACKLIGHT_PIN
			;Initialize TIM
			MOVW	#$0000, (TC0+(2*BACKLIGHT_OC))	;clear brightness
#emac
	
;#Set backlight brightness
; args:   B: brightness
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
#macro	BACKLIGHT_SET, 0
			SSTACK_JOBSR	BACKLIGHT_SET, 4
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef BACKLIGHT_CODE_START_LIN
			ORG 	BACKLIGHT_CODE_START, BACKLIGHT_CODE_START_LIN
#else
			ORG 	BACKLIGHT_CODE_START
BACKLIGHT_CODE_START_LIN	EQU	@			
#endif	

;#Set backlight brightness
; args:   D: brightness
; result: none
; SSTACK: 2 bytes
;         X, Y, and D are preserved 
BACKLIGHT_SET			EQU	*
				;Check for zero (brightness in D) 
				TBEQ	D, BACKLIGHT_SET_2 	;turn backlight off
				IBEQ	D, BACKLIGHT_SET_5	;turn on full brightness
				;Enable PWM (brightness-1 in D) 
				SUBD	#1 			;restore brightness value
				STD	(TC0+(2*BACKLIGHT_OC))	;set brightness
				BCLR	OCPD, #(1<<BACKLIGHT_OC);enable port output
					;Initialize timer
			BSET	TIOS,  #(1<<BACKLIGHT_OC) 	;configure OC
			BSET	TTOV,  #(1<<BACKLIGHT_OC) 	;toggle on overflow
			;BCLR	TCTL1, #(1<<(2*(BACKLIGHT_OC-4)))
			BSET	TCTL1, #(1<<(2*(BACKLIGHT_OC-4))+1)
			;BCLR	TIE,   #(1<<BACKLIGHT_OC) 	;disable interrupts
			;MOVW	#$0000, (TC0+(2*BACKLIGHT_OC))	;set brightness
			;BSET	OCPD,  #(1<<BACKLIGHT_OC) 	;disable port output
		MOVB	#(TEN|TSFRZ), TSCR1	;enable timer
				;Done (brightness in D) 
BACKLIGHT_SET_1			SSTACK_PREPULL	2
				RTS
				;Turn backlight off
BACKLIGHT_SET_2			BCLR	BACKLIGHT_PORT, #BACKLIGHT_PIN
BACKLIGHT_SET_3			BSET	OCPD,  #(1<<BACKLIGHT_OC) 	;disable port output
				TST	TIE
				BNE	BACKLIGHT_SET_1
				BRSET	OCPD, #$FF, BACKLIGHT_SET_4
				JOB	BACKLIGHT_SET_1
BACKLIGHT_SET_4			CLR	TSCR1 			;disable timer
				JOB	BACKLIGHT_SET_1
				;Turn on full brightness
BACKLIGHT_SET_5			SUBD	#1 			;restore brightness value
				BSET	BACKLIGHT_PORT, #BACKLIGHT_PIN
				JOB	BACKLIGHT_SET_3

BACKLIGHT_CODE_END		EQU	*	
BACKLIGHT_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef BACKLIGHT_TABS_START_LIN
				ORG 	BACKLIGHT_TABS_START, BACKLIGHT_TABS_START_LIN
#else
				ORG 	BACKLIGHT_TABS_START
BACKLIGHT_TABS_START_LIN	EQU	@			
#endif	

BACKLIGHT_GAMMA_TAB		DW	$0000			;brightness level  0 (dark)
				DW	$0000			;brightness level  1
				DW	$0000			;brightness level  2
				DW	$0000			;brightness level  3
				DW	$0000			;brightness level  4
				DW	$0000			;brightness level  5
				DW	$0000			;brightness level  6
				DW	$0000			;brightness level  7
				DW	$0000			;brightness level  8
				DW	$0000			;brightness level  9
				DW	$0000			;brightness level 10
				DW	$0000			;brightness level 11
				DW	$0000			;brightness level 12
				DW	$0000			;brightness level 13
				DW	$0000			;brightness level 14
				DW	$FFFF			;brightness level 15 (light)
	
BACKLIGHT_TABS_END		EQU	*	
BACKLIGHT_TABS_END_LIN	EQU	@	
#endif	
