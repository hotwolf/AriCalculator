#ifndef	LED_COMPILED 
#define	LED_COMPILED
;###############################################################################
;# S12CBase - LED - Timer Driver                                               #
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
;#    January 16, 2016                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    TIM - Timer Driver                                                       #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;TIM configuration
;Output compare channel
#ifndef	LED_OC
LED_OC			EQU	2 		;default is OC2
#endif

;I/O configuration
; Red
#ifndef LED_NO_RED	
#ifndef	LED_PORT_RED
LED_PORT_RED		EQU	PORTE 		;default is PE
#endif
#ifndef	LED_PIN_RED
LED_PORT_RED		EQU	PE1 		;default is PE1
#endif
#endif
; Green
#ifndef LED_NO_GREEN	
#ifndef	LED_PORT_GREEN
LED_PORT_GREEN		EQU	PORTE 		;default is PE
#endif
#ifndef	LED_PIN_GREEN
LED_PORT_GREEN		EQU	PE0 		;default is PE0
#endif
#endif

#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Timer configuration
; TIOS 
LED_TIOS_INIT		EQU	1<<LED_OC
; TOC7M/D
;SCI_TOC7MD_INIT	EQU	0
; TTOV
;SCI_TTOV_INIT		EQU	0
; TCTL1/2
;SCI_TCTL12_INIT	EQU	0
; TCTL3/4
;SCI_TCTL34_INIT	EQU	0
 	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef LED_VARS_START_LIN
			ORG 	LED_VARS_START, LED_VARS_START_LIN
#else
			ORG 	LED_VARS_START
LED_VARS_START_LIN	EQU	@			
#endif	

LED_VARS_END		EQU	*
LED_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	LED_INIT, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef LED_CODE_START_LIN
			ORG 	LED_CODE_START, LED_CODE_START_LIN
#else
			ORG 	LED_CODE_START
#endif

LED_CODE_END		EQU	*
LED_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef LED_TABS_START_LIN
			ORG 	LED_TABS_START, LED_TABS_START_LIN
#else
			ORG 	LED_TABS_START
#endif	

LED_TABS_END		EQU	*
LED_TABS_END_LIN	EQU	@
#endif
