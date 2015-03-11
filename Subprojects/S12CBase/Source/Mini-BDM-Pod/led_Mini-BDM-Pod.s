#ifndef	LED_COMPILED
#define	LED_COMPILED
;###############################################################################
;# S12CBase - LED - LED Driver (Mini-BDM-Port)                                 #
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
;#    This module controls the LED on the OpenBDM Pod.                         #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    January 2, 2012                                                          #
;#      - Removed sequential patterns                                          #
;#    August 7, 2012                                                           #
;#      - Added support for linear PC                                          #
;###############################################################################
;# Required Modules:                                                           #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
LED_PORT		EQU	PTP
LED_GREEN1		EQU	PTP7		
LED_GREEN2		EQU	PTP6
LED_GREEN3		EQU	PTP5
LED_RED			EQU	PTP4	
LED_BICOLOR		EQU	PTP2|PTP3
LED_BICOLOR_GREEN	EQU	PTP3
LED_BICOLOR_RED		EQU	PTP2
LED_ALL			EQU	LED_GREEN1|LED_GREEN2|LED_GREEN3|LED_RED|LED_BICOLOR

LED_BUSY		EQU	LED_GREEN3
LED_COMERR		EQU	LED_RED
	
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
			LED_OFF
#emac

;#Start signaling communication error
#macro	LED_COMERR_ON, 0
			BCLR	LED_PORT, #LED_COMERR
#emac

;#Stop signaling communication error
#macro	LED_COMERR_OFF, 0
			BSET	LED_PORT, #LED_COMERR
#emac

;#Start busy signal
#macro	LED_BUSY_ON, 0
			BCLR	LED_PORT, #LED_BUSY
#emac
	
;#Stop busy signal
#macro	LED_BUSY_OFF, 0
			BSET	LED_PORT, #LED_BUSY
#emac

;#Turn LED on (do nothing)
#macro	LED_ON, 0
#emac

;#Turn LED off (turn all LEDs off)
#macro	LED_OFF, 0
			BSET	LED_PORT, #(LED_ALL)
#emac

;#Turn green bi-color LED on
#macro	LED_BICOLOR_GREEN, 0
			BSET	LED_PORT, #LED_BICOLOR_RED
			BCLR	LED_PORT, #LED_BICOLOR_GREEN
#emac

;#Turn red bi-color LED on
#macro	LED_BICOLOR_RED, 0
			BSET	LED_PORT, #LED_BICOLOR_GREEN
			BCLR	LED_PORT, #LED_BICOLOR_RED
#emac

;#Turn bi-color LED off
#macro	LED_BICOLOR_OFF, 0
			BSET	LED_PORT, #(LED_BICOLOR_GREEN|LED_BICOLOR_RED)
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef LED_CODE_START_LIN
			ORG 	LED_CODE_START, LED_CODE_START_LIN
#else
			ORG 	LED_CODE_START
LED_CODE_START_LIN	EQU	@			
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
LED_TABS_START_LIN	EQU	@			
#endif	

LED_TABS_END		EQU	*	
LED_TABS_END_LIN	EQU	@	
#endif	
