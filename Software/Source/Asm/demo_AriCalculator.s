;###############################################################################
;# AriCalculator - Demo                                                        #
;###############################################################################
;#    Copyright 2010-2014 Dirk Heisswolf                                       #
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
;#    This demo application transmits each byte it receives via the SCI.       #
;#                                                                             #
;# Usage:                                                                      #
;#    1. Upload S-Record                                                       #
;#    2. Execute code at address "START_OF_CODE"                               #
;###############################################################################
;# Version History:                                                            #
;#    August 18, 2014                                                          #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Welcome message
;---------------
RESET_WELCOME		EQU	DEMO_WELCOME
	
;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START
;Code
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@
			ORG	DEMO_CODE_END, 	DEMO_CODE_END_LIN

;Variables
DEMO_VARS_START		EQU	*
DEMO_VARS_START_LIN	EQU	@
			ORG	DEMO_VARS_END, 	DEMO_VARS_END_LIN

;Tables
DEMO_TABS_START		EQU	*
DEMO_TABS_START_LIN	EQU	@
			ORG	DEMO_TABS_END, 	DEMO_TABS_END_LIN
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DEMO_VARS_START_LIN
			ORG 	DEMO_VARS_START, DEMO_VARS_START_LIN
#else
			ORG 	DEMO_VARS_START
#endif	

BASE_VARS_START		EQU	*
BASE_VARS_START_LIN	EQU	@
			ORG	BASE_VARS_END, 	BASE_VARS_END_LIN

DISP_VARS_START		EQU	*
DISP_VARS_START_LIN	EQU	@
			ORG	DISP_VARS_END, 	DISP_VARS_END_LIN

KEYS_VARS_START		EQU	*
KEYS_VARS_START_LIN	EQU	@
			ORG	KEYS_VARS_END, 	KEYS_VARS_END_LIN

DEMO_VARS_END		EQU	*
DEMO_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	DEMO_INIT, 0
			BASE_INIT
			DISP_INIT
			KEYS_INIT
#emac

;Break handler
#macro	SCI_BREAK_ACTION, 0
			LED_BUSY_ON
#emac
	
;Suspend handler
#macro	SCI_SUSPEND_ACTION, 0
			LED_BUSY_OFF
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DEMO_CODE_START_LIN
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN
#else
			ORG 	DEMO_CODE_START
#endif	

;Application code
START_OF_CODE		EQU	*		;Start of code
			BASE_INIT		;initialization
DEMO_LOOP		ISTACK_WAIT		;idle loop
			JOB	DEMO_LOOP
	
BASE_CODE_START		EQU	*
BASE_CODE_START_LIN	EQU	@
			ORG	BASE_CODE_END, 	BASE_CODE_END_LIN

DISP_CODE_START		EQU	*
DISP_CODE_START_LIN	EQU	@
			ORG	DISP_CODE_END, 	DISP_CODE_END_LIN

KEYS_CODE_START		EQU	*
KEYS_CODE_START_LIN	EQU	@
			ORG	KEYS_CODE_END, 	KEYS_CODE_END_LIN

DEMO_CODE_END		EQU	*
DEMO_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DEMO_TABS_START_LIN
			ORG 	DEMO_TABS_START, DEMO_TABS_START_LIN
#else
			ORG 	DEMO_TABS_START
#endif	

DEMO_WELCOME		FCS	"This is the AriCalculator Demo"

BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@
			ORG	BASE_TABS_END, 	BASE_TABS_END_LIN

DISP_TABS_START		EQU	*
DISP_TABS_START_LIN	EQU	@
			ORG	DISP_TABS_END, 	DISP_TABS_END_LIN

KEYS_TABS_START		EQU	*
KEYS_TABS_START_LIN	EQU	@
			ORG	KEYS_TABS_END, 	KEYS_TABS_END_LIN

DEMO_TABS_END		EQU	*
DEMO_TABS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./gpio_AriCalculator.s	   									;I/O setup
#include ./vectab_AriCalculator.s									;Vector table
#include ./disp_AriCalculator.s										;Display driver
#include ./disp_splash.s										;Splash screen image
#include ./keys_AriCalculator.s										;keypad driver
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/S12G-Micro-EVB/base_S12G-Micro-EVB.s;RAM memory map
	

