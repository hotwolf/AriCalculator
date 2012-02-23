;###############################################################################
;# S12CBase - CLOCK - Clock Driver                                             #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#    The module controls the PLL and all clock related features.              #
;#    The PLL will be set to 4.096MHz*6 = 49.152MHz (24.576MHz bus clock)      #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    February 22, 2012                                                        #
;#      - Back-ported LFBDMPGMR updates                                        #
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
;# Global Defines:                                                             #
;#    DEBUG - Keeps core clock running in WAIT mode.                           #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
CLOCK_OSC_FREQ	EQU	 4096000 	;oscillator runs at 4.096 MHz
CLOCK_BUS_FREQ	EQU	24576000	;bus frequency is 24.576 MHz
CLOCK_PLL_CFG	EQU	$2305 ;(35+1/5+1) => 49.152MHz (24.576MHz bus clock)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	CLOCK_VARS_START
CLOCK_FLGS		DB	1
CLOCK_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	CLOCK_INIT, 0
		MOVB	CRGFLG, CLOCK_FLGS 				;save all status flags
		MOVB	#$FF, CRGFLG 					;clear all flags
		MOVW	#CLOCK_PLL_CFG, SYNR				;set PLL frequency (SYNR, REFDV)
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
		MOVW	#((CME|PLLON|AUTO)<<8), PLLCTL 			; clock monitor enabled			(CME)

				; PLL enabled				(PLLON)
									; automatic bandwith control		(AUTO)
									; no self-clock mode			(~SCME)
#emac	

;#Wait for PLL
#macro	CLOCK_WAIT_FOR_PLL, 0
LOOP		COP_SERVICE						;service COP
		MOVB	#(PLLSEL|CWAI|COPWAI), CLKSEL 			;switch to PLL
		BRCLR	CLKSEL, #PLLSEL, LOOP 				;wait until the PLL has been selecrt by the ISR
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	CLOCK_CODE_START

;#Service routine for the PLL lock interrupt
CLOCK_ISR		EQU	*
			MOVB	#(PLLSEL|CWAI|COPWAI), CLKSEL 	;switch to PLL
			MOVB	#LOCKIF, CRGFLG 		;clear interrupt flag
			ISTACK_RTI
	
CLOCK_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	CLOCK_TABS_START
CLOCK_TABS_END		EQU	*
