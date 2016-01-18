#ifndef	TIM_COMPILED 
#define	TIM_COMPILED
;###############################################################################
;# S12CBase - TIM - Timer Driver                                               #
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
;#    The module controls the timer. The eight timer channes are used as       #
;#    follows:                                                                 #
;#      IC0:     SCI baud rate detection (capture posedges on RX pin)          #
;#      IC1:     SCI baud rate detection (capture negedges on RX pin)          #
;#      OC2:     SCI baud rate detection (timeout)                             #
;#      OC3:     SCI (timeout)                                                 #
;#      OC4:     delay driver                                                  #
;#      OC5:     unasigned                                                     #
;#      OC6:     unasigned                                                     #
;#      OC7:     unasigned                                                     #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    February 22, 2012                                                        #
;#      - Back-ported LFBDMPGMR updates                                        #
;#    November 14, 2012                                                        #
;#      - Total redo                                                           #
;#    January 15, 2016                                                         #
;#      - Implemented configurable initialization                              #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Clock divider
;-------------
#ifndef	TIM_DIV2_ON
#ifndef	TIM_DIV2_OFF
TIM_DIV2_OFF		EQU	1 	;default no clock divider
#endif
#endif

; OCPD checks (only disable timer if all OCPD bits are set)
;-------------
#ifndef	TIM_OCPD_CHECK_ON
#ifndef	TIM_OCPD_CHECK_OFF
TIM_OCPD_CHECK_OFF	EQU	1 		;disable OCPD checks
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef TIM_VARS_START_LIN
			ORG 	TIM_VARS_START, TIM_VARS_START_LIN
#else
			ORG 	TIM_VARS_START
TIM_VARS_START_LIN	EQU	@			
#endif	

TIM_VARS_END		EQU	*
TIM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	TIM_INIT, 0
#ifdef TIM_TIOS_INIT
			;TIOS 
			MOVB	#TIM_TIOS_INIT, TIOS
#endif
#ifdef TIM_TOCMD_INIT
			;TOC7M/TOC7D
			MOVW	#TIM_TOCMD_INIT, TOCM
#endif
#ifdef TIM_TTOV_INIT
			;TTOV 
			MOVB	#TIM_TTOV_INIT, TTOV
#endif
#ifdef TIM_TCTL12_INIT
			;TCTL1/TCTL2
			MOVW	#TIM_TCTL12_INIT, TCTL1
#endif
#ifdef TIM_TCTL34_INIT
			;TCTL3/TCTL4
			MOVW	#TIM_TCTL34_INIT, TCTL3
#endif
#ifdef	TIM_DIV2_ON
			;TSCR2
			MOVB	#$01, TSCR2 			;run on half bus frequency
#endif
#ifdef	TIM_OCPD_CHECK_ON
			;OCPD
			MOVW	#$FF, OCPD 			;disconnect all IO
#endif	
#emac

;#Enable multiple timer channels
; args: 1: channels  mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_EN, 1
			MOVB	#\1, TFLG1 			;clear interrupt flags
			BSET	TIE, #\1			;enable interrupts
			MOVB	#(TEN|TSFRZ), TSCR1		;enable timer
#emac

;#Enable one timer channel
; args: 1: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_EN, 1
			TIM_MULT_EN	($1<<\1)
#emac

;#Enable the timer counter only
; args: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CNT_EN, 0
			MOVB	#(TEN|TSFRZ), TSCR1		;enable timer
#emac
	
;#Disable multiple timer channels
; args: 1: channel mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_DIS, 1
			BCLR	TIE, #\1
			BNE	DONE
#ifdef	TIM_OCPD_CHECK_ON
			BRSET	OCPD, #$FF, DISABLE
#endif			JOB	DONE
DISABLE			CLR	TSCR1
DONE			EQU	*
#emac

;#Disable one timer channel
; args: 1: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_DIS, 1
			TIM_MULT_DIS	(1<<\1)
#emac

;#Disable the timer counter
; args: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CNT_DIS, 0
			TST	TIE
			BNE	DONE
#ifdef	TIM_OCPD_CHECK_ON
			BRSET	OCPD, #$FF, DISABLE
#endif			JOB	DONE
DISABLE			CLR	TSCR1
DONE			EQU	*
#emac
	
;#Clear multiple interrupt flags
; args: 1: channel mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_CLRIF, 1
			MOVB	#\1, TFLG1
#emac

;#Clear one interrupt flag
; args: 1: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CLRIF, 1
			TIM_MULT_CLRIF	(1<<\1)
#emac

	
;#Setup timer delay
; args: 1: channel number
;       2: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY_IMM, 2
#ifdef	TIM_DIV2_ON
			LDD	#(\2>>1)
#else
			LDD	#\2		
#endif
			ADDD	TCNT				;RPO
			STD	(TC0+(2*\1))			;PWO
#emac

;#Setup timer delay
; args: 1: channel number
;       D: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY_D, 1
#ifdef	TIM_DIV2_ON
			LSRD
#endif
			ADDD	TCNT
			STD	(TC0+(2*\1))
#emac

;#Setup timer delay if timer channel is inactive
; args: 1: channel number
;       D: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_START_DLY, 1
			BRSET	TIE, #(1<<\1), DONE 		;skip if timer channel is already active
			TIM_SET_DLY	\1			
			BSET	TIE, #(1<<\1)			;enable interrupts
			MOVB	#(TEN|TSFRZ), TSCR1		;enable timer
DONE			EQU		*
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef TIM_CODE_START_LIN
			ORG 	TIM_CODE_START, TIM_CODE_START_LIN
#else
			ORG 	TIM_CODE_START
#endif

TIM_CODE_END		EQU	*
TIM_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef TIM_TABS_START_LIN
			ORG 	TIM_TABS_START, TIM_TABS_START_LIN
#else
			ORG 	TIM_TABS_START
#endif	

TIM_TABS_END		EQU	*
TIM_TABS_END_LIN	EQU	@
#endif
