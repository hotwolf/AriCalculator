;###############################################################################
;# S12CForth - Demo (Mini-BDM-Pod)                                             #
;###############################################################################
;#    Copyright 2010-2013 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
;#    family.                                                                  #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without ev_INITen the implied warranty of      #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#    This is a demo of the S12CForth framework.                               #
;#                                                                             #
;# Usage:                                                                      #
;#    1. Upload S-Record                                                       #
;#    2. Execute code at address "START_OF_CODE"                               #
;###############################################################################
;# Version History:                                                            #
;#    May 27, 2013                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN
;Code
START_OF_CODE		EQU	*	
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@

FORTH_CODE_START	EQU	DEMO_CODE_END
FORTH_CODE_START_LIN	EQU	DEMO_CODE_END_LIN

;Tables
DEMO_TABS_START		EQU	FORTH_CODE_END
DEMO_TABS_START_LIN	EQU	FORTH_CODE_END_LIN
	
FORTH_TABS_START	EQU	DEMO_TABS_END
FORTH_TABS_START_LIN	EQU	DEMO_TABS_END_LIN
	
;Variables
DEMO_VARS_START		EQU	FORTH_TABS_END
DEMO_VARS_START_LIN	EQU	FORTH_TABS_END_LIN
	
FORTH_VARS_START	EQU	DEMO_VARS_END
FORTH_VARS_START_LIN	EQU	DEMO_VARS_END_LIN

;TIB and return stack
FRAM_TIB_RS_START	EQU	DEMO_VARS_END		;start of shared TIB/RS space
FRAM_TIB_RS_END		EQU	FRAM_TIB_RS_START+128	;end of shared TIB/RS space

;Dictionary, PAD, and parameter stack 
FRAM_DICT_PS_START	EQU	FRAM_TIB_RS_END		;start of shared DICT/PAD/PS space
FRAM_DICT_PS_END	EQU	MMAP_RAM_END		;end of shared DICT/PAD/PS space

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./forth_Mini-BDM-Pod.s		;S12CForth bundle
	
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

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN

;Initialization
			FORTH_INIT

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




	



	

;			;Dump trace buffer
;DEMO_DUMP_TRACE	CLR	DBGC1
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

DEMO_TABS_END		EQU	*	
DEMO_TABS_END_LIN	EQU	@	




