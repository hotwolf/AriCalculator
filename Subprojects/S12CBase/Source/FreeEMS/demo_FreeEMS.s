;###############################################################################
;# S12CBase - Demo (FreeEMS)                                                   #
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
;#    Syntax check, doesn't do anything                                        #
;###############################################################################
;# Version History:                                                            #
;#    July  8, 2014                                                            #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# Memory map:
MMAP_FLASH		EQU	1 		;use RAM memory map

;# RESET
RESET_WELCOME		EQU	DEMO_WELCOME 	;welcome message
	
;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs
	
;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
;Variables
DEMO_VARS_START		EQU	MMAP_RAM_START
DEMO_VARS_START_LIN	EQU	MMAP_RAM_START_LIN
	
BASE_VARS_START		EQU	DEMO_VARS_END
BASE_VARS_START_LIN	EQU	DEMO_VARS_END_LIN




			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN




;Code
START_OF_CODE		EQU	DEMO_CODE_START	
DEMO_CODE_START		EQU	MMAP_FLASH_FF_START
DEMO_CODE_START_LIN	EQU	MMAP_FLASH_FF_START_LIN

BASE_CODE_START		EQU	DEMO_CODE_END
BASE_CODE_START_LIN	EQU	DEMO_CODE_END_LIN


;Tables
DEMO_TABS_START		EQU	BASE_CODE_END
DEMO_TABS_START_LIN	EQU	BASE_CODE_END_LIN
	
BASE_TABS_START		EQU	DEMO_TABS_END
BASE_TABS_START_LIN	EQU	DEMO_TABS_END_LIN

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./base_FreeEMS.s		;S12CBase bundle
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	DEMO_VARS_START, DEMO_VARS_START_LIN

DEMO_VARS_END		EQU	*
DEMO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN

;Initialization
			BASE_INIT
;Application code
			BGND
	
DEMO_CODE_END		EQU	*	
DEMO_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	DEMO_TABS_START, DEMO_TABS_START_LIN

DEMO_WELCOME		FCC	"This is the S12CBase Demo for the FreeEMS board"
			STRING_NL_TERM

DEMO_TABS_END		EQU	*	
DEMO_TABS_END_LIN	EQU	@	




