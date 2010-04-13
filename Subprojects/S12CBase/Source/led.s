;###############################################################################
;# S12CBase - LED - LED Driver                                                 #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    This module controls the LED on the OpenBDM Pod.                         #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    RTI - Real Time Interrupt Handler                                        #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
LED_PAT_COMERR		EQU	%0101_0101
LED_PAT_BUSY		EQU	%1111_0101
LED_FLG_COMERR		EQU	$10	;current COMERR state
LED_FLG_COMERR_NXT	EQU	$08	;next COMERR state
LED_FLG_BUSY		EQU	$04	;current BUSY state
LED_FLG_BUSY_NXT	EQU	$02	;next BUSY state
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	LED_VARS_START
LED_FLGS		DS	1 		;State that is currently signaled
LED_PAT			DS	1 		;State of the current pattern (MSB will be displayed next)
LED_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	LED_INIT, 0
			;RTI_DISABLE
			LED_ON
			CLR	LED_FLGS
#emac

;#Start signaling communication error
#macro	LED_COMERR_ON, 0
			BSET	LED_FLGS, #LED_FLG_COMERR_NXT	;request signal change
			RTI_ENABLE				;start timer
#emac

;#Stop signaling communication error
#macro	LED_COMERR_OFF, 0
			BCLR	LED_FLGS, #LED_FLG_COMERR_NXT	;request signal change
#emac

;#Start busy signal
#macro	LED_BUSY_ON, 0
			BSET	LED_FLGS, #LED_FLG_BUSY_NXT	;request signal change
			RTI_ENABLE				;start timer
#emac
	
;#Stop busy signal
#macro	LED_BUSY_OFF, 0
			BCLR	LED_FLGS, #LED_FLG_BUSY_NXT	;request signal change
#emac

;#Turn LED on
#macro	LED_ON, 0
		MOVB	#PAD7, PTAD
#emac

;#Turn LED off
#macro	LED_OFF, 0
		CLR	PTAD
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	LED_CODE_START
	
;#Interrupt Service Routine
LED_ISR			EQU	*
			;Clear interupt flag
			MOVB	#$80, CRGFLG
	
			;Use jump table
			LDAB	#(LED_FLG_COMERR|LED_FLG_COMERR_NXT|LED_FLG_BUSY|LED_FLG_BUSY_NXT)
			ANDB	LED_FLGS
			SEX	B, X
			JMP	[LED_JMPTAB,X]

			;Deactivate all signals and disable timer
LED_ISR_STOP_ALL	EQU	*
			RTI_DISABLE 			;stop the timer
			CLR	LED_FLGS		;update state flags
			LED_ON				;turn on LED
			ISTACK_RTI
	
			;Activate BUSY signal
LED_ISR_START_BUSY	EQU	*
			MOVB	#LED_PAT_BUSY, LED_PAT	;switch signal pattern
			JOB	LED_ISR_ADVANCE		;advance pattern

			;Activate COMERR signal
LED_ISR_START_COMERR	EQU	*
			MOVB	#LED_PAT_COMERR, LED_PAT;switch signal pattern
			;JOB	LED_ISR_ADVANCE		;advance pattern	

			;Advance signal pattern
LED_ISR_ADVANCE		EQU	*
			LDAA	LED_PAT			;drive MSB of signal pattern
			BMI	LED_ISR_ADVANCE_4 	; to LED
			LED_OFF
			JOB	LED_ISR_ADVANCE_5
LED_ISR_ADVANCE_4	LED_ON
LED_ISR_ADVANCE_5	LSLA				;Rotate LED pattern left
			ADCA	#0
			STAA	LED_PAT

			;Advance flags (accu B contains flags)
			TBA				;update flags 
			LSLA				;current set to next, next remains
			ANDA	#(LED_FLG_BUSY|LED_FLG_COMERR)
			ANDB	#(LED_FLG_BUSY_NXT|LED_FLG_COMERR_NXT)
			ABA
			STAA	LED_FLGS

			ISTACK_RTI
	
LED_CODE_END		EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	LED_TABS_START
;#Jump table to evaluate flag transitions
;						BUSY_NXT----. 	
;						BUSY-------.| 	
;						COMERR_NXT.|| 	
;						COMERR---.||| 	
LED_JMPTAB		EQU	*    			;VVVV
			DW	LED_ISR_STOP_ALL 	;0000 stop signaling
			DW	LED_ISR_START_BUSY 	;0001 set BUSY pattern
			DW	LED_ISR_STOP_ALL 	;0010 stop signaling
			DW	LED_ISR_ADVANCE 	;0011 advance pattern
			DW	LED_ISR_START_COMERR 	;0100 set COMERR pattern
			DW	LED_ISR_START_COMERR 	;0101 set COMERR pattern
			DW	LED_ISR_START_COMERR 	;0110 set COMERR pattern
			DW	LED_ISR_START_COMERR 	;0111 set COMERR pattern
			DW	LED_ISR_STOP_ALL 	;1000 stop signaling
			DW	LED_ISR_START_BUSY 	;1001 set BUSY signal
			DW	LED_ISR_STOP_ALL 	;1010 stop signaling
			DW	LED_ISR_START_BUSY 	;1011 set BUSY signal
			DW	LED_ISR_ADVANCE 	;1100 advance pattern
			DW	LED_ISR_ADVANCE 	;1101 advance pattern
			DW	LED_ISR_ADVANCE 	;1110 advance pattern
			DW	LED_ISR_ADVANCE 	;1111 advance pattern
LED_TABS_END		EQU	*
