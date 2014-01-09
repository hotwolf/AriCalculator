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
;# Memory map:
MMAP_RAM		EQU	1 		;use RAM memory map

;# Interrupt stack
ISTACK_LEVELS		EQU	1	 	;interrupt nesting not guaranteed
ISTACK_NO_CHECK		EQU	1 		;disable range checks
ISTACK_DEBUG		EQU	1 		;don't enter wait mode
ISTACK_NO_WAI		EQU	1	 	;keep WAIs out

;# Subroutine stack
SSTACK_NO_CHECK		EQU	1 		;disable range checks
SSTACK_DEBUG		EQU	1 		;debug behavior

;# COP
COP_DEBUG		EQU	1 		;disable COP

;# RESET
RESET_CODERUN_OFF	EQU	1 		;don't report code runaways
RESET_WELCOME		EQU	DEMO_WELCOME 	;welcome message
	
;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs
	
;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN
;Code
START_OF_CODE		EQU	*	

DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@
			ORG	DEMO_CODE_END, DEMO_CODE_END_LIN
	
FORTH_CODE_START	EQU	*
FORTH_CODE_START_LIN	EQU	@
			ORG	FORTH_CODE_END, FORTH_CODE_END_LIN

;Tables
DEMO_TABS_START		EQU	*
DEMO_TABS_START_LIN	EQU	@
			ORG	DEMO_TABS_END, DEMO_TABS_END_LIN
	
FORTH_TABS_START	EQU	*
FORTH_TABS_START_LIN	EQU	@
			ORG	FORTH_TABS_END, FORTH_TABS_END_LIN
	
;Variables
DEMO_VARS_START		EQU	*
DEMO_VARS_START_LIN	EQU	@
			ORG	DEMO_VARS_END, DEMO_VARS_END_LIN
	
FORTH_VARS_START	EQU	*
FORTH_VARS_START_LIN	EQU	@
			ORG	FORTH_VARS_END, FORTH_VARS_END_LIN

;Words
			ALIGN	1
DEMO_WORDS_START	EQU	*
DEMO_WORDS_START_LIN	EQU	@
			ORG	DEMO_WORDS_END, DEMO_WORDS_END_LIN
	
FORTH_WORDS_START	EQU	*
FORTH_WORDS_START_LIN	EQU	@
			ORG	FORTH_WORDS_END, FORTH_WORDS_END_LIN
	
;TIB and return stack
RS_TIB_START		EQU	*			;start of shared TIB/RS space
RS_TIB_SIZE		EQU	(MMAP_RAM_END-*)/2
RS_TIB_END		EQU	*+RS_TIB_SIZE		;end of shared TIB/RS space
				
;Dictionary, PAD, and parameter stack 
UDICT_PS_START		EQU	RS_TIB_END		;start of shared DICT/PAD/PS space
UDICT_PS_END		EQU	MMAP_RAM_END		;end of shared DICT/PAD/PS space

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
			
;Application code

			EXEC_CF	CF_WORDS_CDICT
			
DEMO_LOOP		EXEC_CF	CF_DOT_PROMPT
			EXEC_CF	CF_QUERY
			LDD	NUMBER_TIB
			TBEQ	D, DEMO_LOOP

DEMO_LOOP_INNER		LDAA	#" "	
			FOUTER_PARSE
			TBEQ	D  , DEMO_LOOP
	
			TFR	X, Y
			LDX	#DEMO_STRING_PROMPT
			STRING_PRINT_BL
			TFR	Y,  X
			STRING_PRINT_BL
			TFR	Y,  X

DEMO_LOOP_FDICT		FCDICT_SEARCH
			BCC	DEMO_LOOP_INTEGER
			LDX	#DEMO_COMPILE_PROMPT
			LSLD
			BCC	DEMO_LOOP_FDICT_1
			LDX	#DEMO_COMPILE_PROMPT
DEMO_LOOP_FDICT_1	STRING_PRINT_BL
			PS_PUSH_D
			EXEC_CF	CF_HEX_DOT	
			JOB	DEMO_LOOP_INNER
	
DEMO_LOOP_INTEGER	FOUTER_INTEGER
			TBEQ	D, DEMO_LOOP_FORMAT
			DBEQ	D, DEMO_LOOP_SINGLE
			DBNE	D, DEMO_LOOP_RANGE

DEMO_LOOP_DOUBLE	TFR	Y, D
			PS_PUSH_X
			PS_PUSH_D
			LDX	#DEMO_DOUBLE_PROMPT
			STRING_PRINT_BL
			EXEC_CF	CF_D_DOT	
			JOB	DEMO_LOOP_INNER			

DEMO_LOOP_SINGLE	PS_PUSH_X
			LDX	#DEMO_SINGLE_PROMPT
			STRING_PRINT_BL
			PS_DUP
			EXEC_CF	CF_DOT
			LDX	#DEMO_WORD_START_STRING
			STRING_PRINT_BL
			EXEC_CF	CF_DOT_WORD_CDICT
			PS_PULL_D
			TBNE	D, DEMO_LOOP_SINGLE_1
			PS_DROP	1
			LDX	#DEMO_NONAME_STRING
			JOB	DEMO_LOOP_SINGLE_2
DEMO_LOOP_SINGLE_1	LDX	#DEMO_WORD_END_STRING	
DEMO_LOOP_SINGLE_2	STRING_PRINT_BL	
			JOB	DEMO_LOOP_INNER

DEMO_LOOP_FORMAT	LDX	#DEMO_FORMAT_PROMPT
			STRING_PRINT_BL
			JOB	DEMO_LOOP_INNER

DEMO_LOOP_RANGE		LDX	#DEMO_RANGE_PROMPT
			STRING_PRINT_BL
			JOB	DEMO_LOOP_INNER
	
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

;#Welcome string
DEMO_WELCOME		FCS	"This is the S12CForth Demo for the Mini-BDM-Pod"

DEMO_STRING_PROMPT	FOUTER_PROMPT	"STRING:"
DEMO_SINGLE_PROMPT	FOUTER_PROMPT	"SINGLE:"
DEMO_DOUBLE_PROMPT	FOUTER_PROMPT	"DOUBLE:"
DEMO_COMPILE_PROMPT	FOUTER_PROMPT	"COMPILE WORD:"
DEMO_IMMEDIATE_PROMPT	FOUTER_PROMPT	"IMMEDIATE WORD:"
DEMO_RANGE_PROMPT	FOUTER_PROMPT	"Integer out of range!"
DEMO_FORMAT_PROMPT	FOUTER_PROMPT	"Syntax error!"
DEMO_WORD_START_STRING	FCS		"  ("
DEMO_NONAME_STRING	FCC		"NONAME"
DEMO_WORD_END_STRING	FCS		")"
			
DEMO_TABS_END		EQU	*	
DEMO_TABS_END_LIN	EQU	@	

;###############################################################################
;# Demo words                                                                  #
;###############################################################################
#ifdef DEMO_WORDS_START_LIN
			ORG 	DEMO_WORDS_START, DEMO_WORDS_START_LIN
#else
			ORG 	DEMO_WORDS_START
#endif	

DEMO_WORDS_END		EQU	*	
DEMO_WORDS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./forth_Mini-BDM-Pod.s		;S12CForth bundle
	
