#ifndef DFONT
#define	DFONT	
;###############################################################################
;# AriCalculator - DFONT - Font Generator for the Display Driver               #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU family.   #
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
;#    This is the low level driver for LCD using a ST7565R controller. This    #
;#    driver assumes, that the ST7565R is connected via the 4-wire SPI         #
;#    interface. The default pin mapping matches AriCalculator hardware RevC   #
;#                                                                             #
;#    By convention, the display must be switched to data mode when idle.      #
;#                                                                             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#    VECMAP - Vector Map                                                      #
;#    CLOCK  - Clock driver                                                    #
;#    GPIO   - GPIO driver                                                     #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    GPIO   - GPIO driver                                                     #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    May 19, 2017                                                           #
;#      - Initial release                                                      #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DFONT_VARS_START_LIN
			ORG 	DFONT_VARS_START, DFONT_VARS_START_LIN
#else
			ORG 	DFONT_VARS_START
DFONT_VARS_START_LIN	EQU	@			
#endif	

	
DFONT_VARS_END		EQU	*
DFONT_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	DFONT_INIT, 0
#emac


;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DFONT_CODE_START_LIN
			ORG 	DFONT_CODE_START, DFONT_CODE_START_LIN
#else
			ORG 	DFONT_CODE_START
DFONT_CODE_START_LIN	EQU	@
#endif
	
	
DFONT_CODE_END		EQU	*	
DFONT_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DFONT_TABS_START_LIN
			ORG 	DFONT_TABS_START, DFONT_TABS_START_LIN
#else
			ORG 	DFONT_TABS_START
DFONT_TABS_START_LIN	EQU	@	
#endif	

	
DFONT_TABS_END		EQU	*
DFONT_TABS_END_LIN	EQU	@
#endif
