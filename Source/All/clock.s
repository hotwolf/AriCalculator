;###############################################################################
;# S12CBase - CLOCK - Clock Driver                                             #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
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
;#    The module controls the PLL and all clock related features.              #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#    ISTACK - Reset Handler                                                   #
;#    VECMAP - Vector Map                                                      #
;#    COP    - Watchdog Handler                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    August 10, 2012                                                          #
;#      - Added support for linear PC                                          #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;#CRG or CPMU
#ifndef CLOCK_CRG	
#ifndef CLOCK_CPMU	
CLOCK_CPMU		EQU	1		;default CPMU
#endif
#endif
	
;#Bus frequency
#ifndef CLOCK_BUS_FREQ	
CLOCK_BUS_FREQ		EQU	25000000	;default is 25 MHz
CLOCK_VCOFRQ		EQU	$1		;0=[ 32MHz.. 48MHz],
						;2=[>48MHz.. 80MHz],
						;4=[>80MHz..120MHZ]
#endif

;#Reference clock frequency 
#ifndef CLOCK_REF_FREQ
CLOCK_REF_FREQ		EQU	1000000		;default is 1 MHz
CLOCK_REFFRQ		EQU	$0		;0=[  1MHz.. 2MHz],
						;2=[> 2MHz.. 6MHz],
						;3=[> 6MHz..12MHz],
						;4=[>12MHz..]
#endif

;#Oscillator frequency 
#ifndef CLOCK_OSC_FREQ	
CLOCK_IRC		EQU	1		;use IRC if no oscillator
						;frequency is specified
CLOCK_OSC_FREQ		EQU	1000000		;dummy value (1 MHz)
#endif


;###############################################################################
;# Constants                                                                   #
;###############################################################################
CLOCK_SYNR		EQU	(CLOCK_BUS_FREQ/CLOCK_REF_FREQ)-1
CLOCK_REFDV		EQU	(CLOCK_OSC_FREQ/CLOCK_REF_FREQ)-1
CLOCK_POSTDIV		EQU	$00		;no post divider
CLOCK_PLL_CONFIG	EQU	(CLOCK_VCOFRQ<<14)|(CLOCK_SYNR<<8)|(CLOCK_REFFRQ<<6)|CLOCK_REFDV
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef CLOCK_VARS_START_LIN
			ORG 	CLOCK_VARS_START, CLOCK_VARS_START_LIN
#else
			ORG 	CLOCK_VARS_START
CLOCK_VARS_START_LIN	EQU	@			
#endif	

CLOCK_FLGS		DB	1

CLOCK_VARS_END		EQU	*
CLOCK_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	CLOCK_INIT, 0
#ifdef	CLOCK_CPMU
			MOVB	CPMUFLG, CLOCK_FLGS 				;save all status flags
			MOVB	#$FF, CPMUFLG 					;clear all flags
			MOVW	#CLOCK_PLL_CONFIG, CPMUSYNR 			;setup PLL
			CLR	CPMUPOSTDIV 					;disable POSTDIV divider
			;CLR	CPMUINT						;disable PLL lock interrupts
			;MOVB	#LOCKIE, CPMUINT 				;enable PLL lock interrupt
			;MOVB	#PLLSEL, CPMUCLKS 				;enable PLL
			;CLR	CPMUPLL						;no frequency modulation
			;CLR	CPMURTI						;no real time interrupt
			;MOVB	#(RSBCK|CR1|CR2|CR3), CPMUCOP 			;configure COP
			;CLR	CPMULVCTL					;no low-voltage interrupt
			;CLR	CPMUAPICTL					;no API
			;CLR	CPMUAPIRH					;no API
			;CLR	CPMUAPIRL					;no API
			MOVB	#PROT, CPMUPROT					;lock CPMU configuration
#endif
#ifdef	CLOCK_CRG
			MOVB	CRGFLG, CLOCK_FLGS 				;save all status flags
			MOVB	#$FF, CRGFLG 					;clear all flags
			MOVW	#CLOCK_PLL_CONFIG, SYNR				;set PLL frequency (SYNR, REFDV)
			MOVW	#(((RTIE|LOCKIE)<<8)|COPWAI), CRGINT
			;MOVW	#(((RTIE|LOCKIE)<<8)|CWAI|COPWAI), CRGINT
                                                                        	;CRG configuration:
										; real-time interrupt enabled		(RTIE)
										; PLL lock interrupt enabled		(LOCKIE)
										; no self-clock mode interrupt		(~SCMIE)
										; no pseudo-stop			(~PSTP)
										; system/bus clock in wait mode		(~SYSWAI)
										; no reduced oscillator amplitude	(~ROAWAI)
										; PLL in wait mode			(~PLLWAI)
										; core/CPU clock stops in wait mode	(CWAI)
										; RTI keeps running in wait mode	(~RTIWAI)
										; COP stops in wait mode		(COPWAI)
			;BSET	PLLCTL, #(CME|PLLON|AUTO)			; clock monitor enabled			(CME)
										; PLL enabled				(PLLON)
										; automatic bandwith control		(AUTO)
#emac	

;#Wait for PLL
#macro	CLOCK_WAIT_FOR_PLL, 0
LOOP			COP_SERVICE		
#ifdef	CLOCK_CPMU
			BRCLR	CPMUFLG, #LOOP, *
#endif
#ifdef	CLOCK_CRG
			BRCLR	CRGFLG, #LOOP, *
#endif
#emac

;###############################################################################
;# COP configuration                                                           #
;###############################################################################
			;ORG	$FF0E
			;DW	$F8
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef CLOCK_CODE_START_LIN
			ORG 	CLOCK_CODE_START, CLOCK_CODE_START_LIN
#else
			ORG 	CLOCK_CODE_START
CLOCK_VARS_START_LIN	EQU	@			
#endif	

;#Service routine for the PLL lock interrupt
#ifdef	CLOCK_CPMU
CLOCK_ISR		EQU	ERROR_ISR
#endif
#ifdef	CLOCK_CRG
			MOVB	#(PLLSEL|CWAI|COPWAI), CLKSEL 	;switch to PLL
			MOVB	#LOCKIF, CRGFLG 		;clear interrupt flag
			ISTACK_RTI
#endif
	
CLOCK_CODE_END		EQU	*	
CLOCK_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef CLOCK_TABS_START_LIN
			ORG 	CLOCK_TABS_START, CLOCK_TABS_START_LIN
#else
			ORG 	CLOCK_TABS_START
CLOCK_VARS_START_LIN	EQU	@			
#endif	

CLOCK_TABS_END		EQU	*	
CLOCK_TABS_END_LIN	EQU	@	
