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
;Ticks per ms 
DELAY_TPMS		EQU	TIM_FREQ/1000000			

;Timer interval in ms 
DELAY_INTERVAL		EQU	$10000*1000000/TIM_FREQ	
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DELAY_VARS_START_LIN
			ORG 	DELAY_VARS_START, DELAY_VARS_START_LIN
#else
			ORG 	DELAY_VARS_START
DELAY_VARS_START_LIN	EQU	@			
#endif	

DELAY_LIST_PTR		DS	2 ;start of the counter list

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
