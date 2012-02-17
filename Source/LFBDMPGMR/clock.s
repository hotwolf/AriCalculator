;###############################################################################
;# S12CBase - CLOCK - Clock Driver (LFBDMPGMR port)                            #
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
CLOCK_OSC_FREQ		EQU	10000000 	;oscillator runs at 10 MHz
CLOCK_BUS_FREQ		EQU	50000000	;bus frequency is 50.000 MHz
CLOCK_SYNR		EQU	$C4
CLOCK_REVDV		EQU	$80
CLOCK_POSTDIV		EQU	$00
CLOCK_PLL_CFG		EQU	(CLOCK_SYNR<<8)|CLOCK_REVDV
	
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
		MOVW	#(((RTIE|LOCKIE)<<8)|COPWAI), CRGINT            ;CRG configuration:
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
		MOVW	#((CME|PLLON)<<8), PLLCTL 			; clock monitor enabled			(CME)
									; PLL enabled				(PLLON)
									; no frequency modulation    		(~FM1|~FM0)
									; no self-clock mode			(~SCME)
#emac	

;#Wait for PLL
#macro	CLOCK_WAIT_FOR_PLL, 0
LOOP		COP_SERVICE						;service COP
		BRCLR	CLKSEL, #PLLSEL, LOOP 				;wait until the PLL has been selecrt by the ISR
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	CLOCK_CODE_START

;#Service routine for the PLL lock interrupt
CLOCK_ISR		EQU	*
			MOVB	#(PLLSEL|COPWAI), CLKSEL 	;switch to PLL
			MOVB	#LOCKIF, CRGFLG 		;clear interrupt flag
			ISTACK_RTI
	
CLOCK_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	CLOCK_TABS_START
CLOCK_TABS_END		EQU	*
