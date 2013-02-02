;###############################################################################
;# S12CBase - Demo (S12DP256-Mini-EVB)                                              #
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
;#    This demo application transmits each byte it receives via the SCI.       #
;#                                                                             #
;# Usage:                                                                      #
;#    1. Upload S-Record                                                       #
;#    2. Execute code at address "START_OF_CODE"                               #
;###############################################################################
;# Version History:                                                            #
;#    November 14, 2012                                                        #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# Clocks
CLOCK_CRG		EQU	1		;CPMU
CLOCK_OSC_FREQ		EQU	10000000	;10 MHz
CLOCK_BUS_FREQ		EQU	50000000	;50 MHz
CLOCK_REF_FREQ		EQU	10000000	;10 MHz
CLOCK_VCOFRQ		EQU	3		;VCO=100MHz
CLOCK_REFFRQ		EQU	2		;Ref=10Mhz

;# Memory map:
MMAP_RAM		EQU	1 		;use RAM memory map

;# Interrupt stack
ISTACK_LEVELS		EQU	1	 	;interrupt nesting not guaranteed
ISTACK_DEBUG		EQU	1 		;don't enter wait mode

;# Subroutine stack
SSTACK_DEPTH		EQU	24	 	;no interrupt nesting
SSTACK_DEBUG		EQU	1 		;debug behavior

;# COP
COP_DEBUG		EQU	1 		;disable COP

;# RESET
RESET_WELCOME		EQU	DEMO_WELCOME 	;welcome message
	
;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs
	
;# SCI
SCI_BLOCKING_ON		EQU	1		;enable blocking subroutines

;# NUM
NUM_BLOCKING_ON		EQU	1		;enable blocking subroutines
	
;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START
;Code
START_OF_CODE		EQU	*	
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@

BASE_CODE_START		EQU	DEMO_CODE_END
BASE_CODE_START_LIN	EQU	DEMO_CODE_END_LIN

;Variables
DEMO_VARS_START		EQU	BASE_CODE_END
DEMO_VARS_START_LIN	EQU	BASE_CODE_END_LIN
	
BASE_VARS_START		EQU	DEMO_VARS_END
BASE_VARS_START_LIN	EQU	DEMO_VARS_END_LIN

;Tables
DEMO_TABS_START		EQU	BASE_VARS_END
DEMO_TABS_START_LIN	EQU	BASE_VARS_END_LIN
	
BASE_TABS_START		EQU	DEMO_TABS_END
BASE_TABS_START_LIN	EQU	DEMO_TABS_END_LIN

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./base_S12DP256-Mini-EVB.s		;S12CBase bundle
	
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
DEMO_LOOP		SCI_RX_BL
			;Ignore RX errors 
			TBNE	A, DEMO_LOOP

			;Print ASCII character (char in B)
			TFR	D, X
			LDAA	#4
			LDAB	#" "
			STRING_FILL_BL
			TFR	X, D
			CLRA
			STRING_MAKE_PRINTABLE_B
			SCI_TX_BL

			;Print hexadecimal value (char in X)
			LDY	#$0000
			LDAB	#16
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#5
			LDAB	#" "
			STRING_FILL_BL
			LDAB	#16
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print decimal value (char in X)
			LDY	#$0000
			LDAB	#10
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#5
			LDAB	#" "
			STRING_FILL_BL
			LDAB	#10
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print octal value (char in X)
			LDY	#$0000
			LDAB	#8
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#5
			LDAB	#" "
			STRING_FILL_BL
			LDAB	#8
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print binary value (char in X)
			LDY	#$0000
			LDAB	#2
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#10
			LDAB	#"0"
			STRING_fill_BL
			LDAB	#2
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print new line
			LDX	#STRING_STR_NL
			STRING_PRINT_BL
			JOB	DEMO_LOOP
	
DEMO_CODE_END		EQU	*	
DEMO_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	DEMO_TABS_START, DEMO_TABS_START_LIN

DEMO_WELCOME		FCC	"This is the S12CBase Demo for the S12DP256-Mini-EVB"
			STRING_NL_NONTERM
			STRING_NL_NONTERM
			FCC	"ASCII  Hex  Dec  Oct       Bin"
			STRING_NL_NONTERM
			FCC	"------------------------------"
			STRING_NL_TERM

DEMO_TABS_END		EQU	*	
DEMO_TABS_END_LIN	EQU	@	




