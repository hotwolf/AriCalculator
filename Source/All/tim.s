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
;#    The module controls the shared timer module.                             #
;#                                                                             #
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
#ifndef	TIM_DIV_OFF
#ifndef	TIM_DIV_2
#ifndef	TIM_DIV_4
#ifndef	TIM_DIV_8
#ifndef	TIM_DIV_16
#ifndef	TIM_DIV_32
#ifndef	TIM_DIV_64
#ifndef	TIM_DIV_128
TIM_DIV_OFF		EQU	1 	;default no clock divider
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif

;OCPD checks (only disable timer if all OCPD bits are set)
;---------------------------------------------------------
#ifndef	TIM_OCPD_CHECK_ON
#ifndef	TIM_OCPD_CHECK_OFF
TIM_OCPD_CHECK_OFF	EQU	1 		;disable OCPD checks
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Timer frequency
;---------------
#ifdef TIM_DIV_OFF
TIM_FREQ		EQU	CLOCK_BUS_FREQ 		;frequency in Hz
#endif
#ifdef TIM_DIV_2
TIM_FREQ		EQU	CLOCK_BUS_FREQ/2 	;frequency in Hz
#endif
#ifdef TIM_DIV_4
TIM_FREQ		EQU	CLOCK_BUS_FREQ/4 	;frequency in Hz
#endif
#ifdef TIM_DIV_8
TIM_FREQ		EQU	CLOCK_BUS_FREQ/8 	;frequency in Hz
#endif
#ifdef TIM_DIV_16
TIM_FREQ		EQU	CLOCK_BUS_FREQ/16 	;frequency in Hz
#endif
#ifdef TIM_DIV_32
TIM_FREQ		EQU	CLOCK_BUS_FREQ/32 	;frequency in Hz
#endif
#ifdef TIM_DIV_64
TIM_FREQ		EQU	CLOCK_BUS_FREQ/64 	;frequency in Hz
#endif
#ifdef TIM_DIV_128
TIM_FREQ		EQU	CLOCK_BUS_FREQ/128 	;frequency in Hz
#endif
	
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
#ifdef	TIM_DIV_2
			;TSCR2
			MOVB	#$01, TSCR2 			;timer clock = bus clock/2
#endif
#ifdef	TIM_DIV_4
			;TSCR2
			MOVB	#$02, TSCR2 			;timer clock = bus clock/4
#endif
#ifdef	TIM_DIV_8
			;TSCR2
			MOVB	#$03, TSCR2 			;timer clock = bus clock/8
#endif
#ifdef	TIM_DIV_16
			;TSCR2
			MOVB	#$04, TSCR2 			;timer clock = bus clock/16
#endif
#ifdef	TIM_DIV_32
			;TSCR2
			MOVB	#$05, TSCR2 			;timer clock = bus clock/32
#endif
#ifdef	TIM_DIV_64
			;TSCR2
			MOVB	#$06, TSCR2 			;timer clock = bus clock/64
#endif
#ifdef	TIM_DIV_128
			;TSCR2
			MOVB	#$07, TSCR2 			;timer clock = bus clock/128
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
	
;#Disable the timer counter
; args: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CNT_DIS, 0
			TST	TIE
			BNE	DONE
#ifdef	TIM_OCPD_CHECK_ON
			BRSET	OCPD, #$FF, DISABLE
			JOB	DONE
#endif
DISABLE			CLR	TSCR1
DONE			EQU	*
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
			JOB	DONE
#endif
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

;#Branch if channel is enabled
; args: 1: channel number
;       2: branch address
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_BREN, 2
			BRSET	TIE, #(1<<\1), \2
#emac

;#Branch if channel is disnabled
; args: 1: channel number
;       2: branch address
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_BRDIS, 2
			BRCLR	TIE, #(1<<\1), \2
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
;       2: delay (in timer counts)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY_IMM, 2
			LDD	#\2		
			ADDD	TCNT				;RPO
			STD	(TC0+(2*\1))			;PWO
#emac

;#Setup timer delay
; args: 1: channel number
;       D: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY_D, 1
			ADDD	TCNT 				;RPO
			STD	(TC0+(2*\1))			;PWO
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
