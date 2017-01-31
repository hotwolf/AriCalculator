;###############################################################################
;# S12CBase - Set Serial Number (Mini-BDM-Pod)                                 #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12 MCU family.    #
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
;#    January 30, 2017                                                         #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;#Serial Number:				 123456789ABCDE
			SERIAL_NUMBER		"Dirk's BDM Pod"
			;SERIAL_NUMBER		"29-Jan-2017"
	
;#Memory map:
MMAP_S12XEP100		EQU	1 		;S12XEP100
MMAP_RAM		EQU	1 		;use RAM memory map

;#COP
COP_DEBUG		EQU	1 		;disable COP

;#Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs

;#STRING
STRING_ENABLE_FILL_NB	EQU	1 		;enable STRING_FILL_NB
STRING_ENABLE_FILL_BL	EQU	1 		;enable STRING_FILL_BL
STRING_ENABLE_PRINTABLE	EQU	1 		;enable STRING_PRINTABLE

;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_F9_START, MMAP_RAM_F9_START_LIN
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
			ORG	DEMO_TABS_END, DEMO_TABS_END_LIN

BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@
			ORG	BASE_TABS_END, BASE_TABS_END_LIN

;Stack 
SSTACK_TOP		EQU	*
SSTACK_TOP_LIN		EQU	@
SSTACK_BOTTOM		EQU	VECTAB_START
SSTACK_BOTTOM_LIN	EQU	VECTAB_START_LIN
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################

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
;#Welcome message
#macro	WELCOME_MESSAGE, 0
			RESET_BR_ERR	DONE		;severe error detected 
			LDX	#WELCOME_MESSAGE	;print welcome message
			STRING_PRINT_BL
DONE			EQU	*
#emac

#macro	SERIAL_NUMBER, 1
			ORG	RO_CONTENT, RO_CONTENT_LIN
			FILL	$FF, 16
			ORG	RO_CONTENT, RO_CONTENT_LIN
			FCZ	/1
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN

;Initialization
			BASE_INIT
			WELCOME_MESSAGE
	
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

			;Program first phrase
			CLR	FCCOBIX
			MOVW	#$0700, FCCOB
			INC	FCCOBIX
			MOVW	#$0001, FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+0), FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+2), FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+4), FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+6), FCCOB
			MOVB	#$80, FSTAT
			BRCLR	FSTAT,#$80,*
	
			;Program second phrase
			CLR	FCCOBIX
			MOVW	#$0700, FCCOB
			INC	FCCOBIX
			MOVW	#$0001, FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+8), FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+10), FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+12), FCCOB
			INC	FCCOBIX
			MOVW	#(RO_CONTENT+14), FCCOB
			MOVB	#$80, FSTAT
			BRCLR	FSTAT,#$80,*
			BRA	*
	
DEMO_CODE_END		EQU	*	
DEMO_CODE_END_LIN	EQU	@	

;			;Overwrite SWI interrupt vector
;			ORG	VEC_SWI
;			DW	DEMO_DUMP_TRACE
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	DEMO_TABS_START, DEMO_TABS_START_LIN

;#Welcome message
#ifndef	WELCOME_MESSAGE
WELCOME_MESSAGE		FCC	"Program Once!"
			STRING_NL_TERM
#endif

RO_CONTENT		EQU	*
RO_CONTENT_LIN		EQU	@
			DS	16

DEMO_TABS_END		EQU	*	
DEMO_TABS_END_LIN	EQU	@	

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./base_Mini-BDM-Pod.s		;S12CBase bundle
	

