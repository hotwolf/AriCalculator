;###############################################################################
;# S12CBase - Demo (Mini-BDM-Pod)                                              #
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
;# Memory map:
MMAP_S12XEP100		EQU	1 		;S12XEP100
MMAP_RAM		EQU	1 		;use RAM memory map

;# COP
COP_DEBUG		EQU	1 		;disable COP

;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs

;# STRING
STRING_ENABLE_FILL_NB	EQU	1 		;enable STRING_FILL_NB
STRING_ENABLE_FILL_BL	EQU	1 		;enable STRING_FILL_BL
STRING_ENABLE_PRINTABLE	EQU	1 		;enable STRING_PRINTABLE

;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_FC_START, MMAP_RAM_FC_START_LIN
;Code
START_OF_CODE		EQU	*	
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@
			ORG	DEMO_CODE_END, DEMO_CODE_END_LIN
	
BASE_CODE_START		EQU	*
BASE_CODE_START_LIN	EQU	@
			ORG	BASE_CODE_END, BASE_CODE_END_LIN

;Variables
DEMO_VARS_START		EQU	*
DEMO_VARS_START_LIN	EQU	@
			ORG	DEMO_VARS_END, DEMO_VARS_END_LIN
	
BASE_VARS_START		EQU	*
BASE_VARS_START_LIN	EQU	@
			ORG	BASE_VARS_END, BASE_VARS_END_LIN

;Tables
DEMO_TABS_START		EQU	*
DEMO_TABS_START_LIN	EQU	@
			ORG	DEMO_TABS_END, DEMO_CODE_END_LIN
	
BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./base_Mini-BDM-Pod.s		;S12CBase bundle
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	DEMO_VARS_START, DEMO_VARS_START_LIN

;			ALIGN	16
;DEMO_TRACE		DS	8*64

DEMO_VARS_END		EQU	*
DEMO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
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
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN

;Initialization
			BASE_INIT
	
;;Setup trace buffer
;			;Configure DBG module
;			CLR	DBGC1
;			;MOVB	#$40, DBGTCR  ;trace CPU in normal mode
;			MOVB	#$4C, DBGTCR  ;trace CPU in pure PC mode
;			MOVB	#$02, DBGC2   ;Comparators A/B outside range
;			MOVB	#$02, DBGSCRX ;first match triggers final state
;			;Comperator A
;			MOVW	#(((BRK|TAG|COMPE)<<8)|(MMAP_RAM_START_LIN>>16)), DBGXCTL
;			MOVW	#(MMAP_RAM_START_LIN&$FFFF),                      DBGXAM
;			;Comperator A
;			MOVB	#$01, DBGC1
;			MOVW	#(((BRK|TAG|COMPE)<<8)|(MMAP_RAM_END_LIN>>16)), DBGXCTL
;			MOVW	#(MMAP_RAM_END_LIN&$FFFF),                      DBGXAM
;			;Arm DBG module
;			MOVB	#ARM, DBGC1
			
;Application code
			;Print header string
			LDX	#DEMO_HEADER
			STRING_PRINT_BL

			;Loop
DEMO_LOOP		SCI_RX_BL
			;Ignore RX errors 
			ANDA	#(SCI_FLG_SWOR|OR|NF|FE|PF)
			BNE	DEMO_LOOP
			;TBNE	A, DEMO_LOOP

			;Print ASCII character (char in B)
			TFR	D, X
			LDAA	#4
			LDAB	#" "
			STRING_FILL_BL
			TFR	X, D
			CLRA
			STRING_PRINTABLE
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
			LDAA	#2
			LDAB	#" "
			STRING_FILL_BL
			LDY	#$0000
			LDAB	#2
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#8
			LDAB	#"0"
			STRING_fill_BL
			LDAB	#2
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print new line
			LDX	#STRING_STR_NL
			STRING_PRINT_BL
			JOB	DEMO_LOOP

;			;Dump trace buffer
;DEMO_DUMP_TRACE		CLR	DBGC1
;			LDD	2*64
;			LDX	#DEMO_TRACE
;			STX	DBGTBH
;DEMO_DUMP_TRACE_1	LDY	DBGTBH
;			MOVW	DBGTBH, 2,X+
;			STY	2,X+
;			DBNE	D, DEMO_DUMP_TRACE_1
;			BGND
	
DEMO_CODE_END		EQU	*	
DEMO_CODE_END_LIN	EQU	@	

;			;Overwrite SWI interrupt vector
;			ORG	VEC_SWI
;			DW	DEMO_DUMP_TRACE
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	DEMO_TABS_START, DEMO_TABS_START_LIN

DEMO_HEADER		STRING_NL_NONTERM
			STRING_NL_NONTERM
			FCC	"ASCII  Hex  Dec  Oct       Bin"
			STRING_NL_NONTERM
			FCC	"------------------------------"
			STRING_NL_TERM

DEMO_TABS_END		EQU	*	
DEMO_TABS_END_LIN	EQU	@	




