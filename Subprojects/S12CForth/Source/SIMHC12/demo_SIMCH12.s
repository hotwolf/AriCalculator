;###############################################################################
;# S12CForth - Demo (SIMHC12)                                                  #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
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
;MMAP_RAM		EQU	1 		;use RAM memory map

;# COP
COP_DEBUG		EQU	1 		;disable COP

;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs

;# SSTACK
SSTACK_DEBUG		EQU	1 
SSTACK_NO_CHECK		EQU	1 
SSTACK_DEPTH		EQU	40

;# ISTACK
ISTACK_DEBUG		EQU	1 
ISTACK_NO_WAI		EQU	1 
ISTACK_NO_CHECK		EQU	1 
	
;# STRING
;STRING_ENABLE_FILL_NB	EQU	1		;enable STRING_FILL_NB 
;STRING_ENABLE_FILL_BL	EQU	1		;enable STRING_FILL_BL

;# FOUTER	
FOUTER_NL_CR		EQU	1 		;interpret CR as line break,
						;ignore LF
	
;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START
;Variables
DEMO_VARS_START		EQU	*
DEMO_VARS_START_LIN	EQU	@
			ORG	DEMO_VARS_END, DEMO_VARS_END_LIN

;Forth stacks, buffers and dictionary 
;      	  UDICT_PS_START -> +--------------+--------------+	     
;                           |       User Dictionary       |	     
;                           |             PAD             |	     
;                           |       Parameter stack       |		  
;           UDICT_PS_END -> +--------------+--------------+        
;           RS_TIB_START -> +--------------+--------------+        
;                           |       Text Input Buffer     |
;                           |        Return Stack         |
;             RS_TIB_END -> +--------------+--------------+
;Dictionary, PAD, and parameter stack 
UDICT_PS_START		EQU	*			;start of shared DICT/PAD/PS space
UDICT_PS_SIZE		EQU	((MMAP_RAM_END-*)*2)/3	;2/3 of available RAM space
UDICT_PS_END		EQU	(*+UDICT_PS_SIZE)&$FFFE	;end of shared DICT/PAD/PS space

;TIB and return stack
RS_TIB_START		EQU	UDICT_PS_END		;start of shared TIB/RS space
RS_TIB_END		EQU	MMAP_RAM_END		;end of shared TIB/RS space

			ORG	MMAP_FLASH3F_START, MMAP_FLASH3F_START_LIN
;Code
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@
			ORG	DEMO_CODE_END, DEMO_CODE_END_LIN

;Tables
DEMO_TABS_START		EQU	*
DEMO_TABS_START_LIN	EQU	@
			ORG	DEMO_TABS_END, DEMO_TABS_END_LIN
;Words
			ALIGN	1
DEMO_WORDS_START	EQU	*
DEMO_WORDS_START_LIN	EQU	@
			ORG	DEMO_WORDS_END, DEMO_WORDS_END_LIN
				
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
			ORG	BASE_VARS_END, BASE_VARS_END_LIN

FORTH_VARS_START	EQU	*
FORTH_VARS_START_LIN	EQU	@
			ORG	FORTH_VARS_END, FORTH_VARS_END_LIN

DEMO_VARS_END		EQU	*
DEMO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################

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
			;Initialization
			BASE_INIT
			FORTH_INIT

;			EXEC_CF	CF_WORDS_CDICT
;			BGND
	
;			LDX	#TEST_WORD
;			FCDICT_FIND
;			BGND
;TEST_WORD		FCS	"words-udictx"
	
			;Enter QUIT shell
			JOB	CF_QUIT_SHELL
	
BASE_CODE_START		EQU	*
BASE_CODE_START_LIN	EQU	@
			ORG	BASE_CODE_END, BASE_CODE_END_LIN

FORTH_CODE_START		EQU	*
FORTH_CODE_START_LIN	EQU	@
			ORG	FORTH_CODE_END, FORTH_CODE_END_LIN

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
	
BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@
			ORG	BASE_TABS_END, BASE_TABS_END_LIN

FORTH_TABS_START		EQU	*
FORTH_TABS_START_LIN	EQU	@
			ORG	FORTH_TABS_END, FORTH_TABS_END_LIN

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

FORTH_WORDS_START	EQU	*
FORTH_WORDS_START_LIN	EQU	@
			ORG	FORTH_WORDS_END, FORTH_WORDS_END_LIN

DEMO_WORDS_END		EQU	*
DEMO_WORDS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../All/forth.s							;S12CForth bundle
;#include ../../Subprojects/S12CBase/Source/SIMHC12/base_SIMHC12.s	;Base bundle
#include ../../../S12CBase/Source/SIMHC12/base_SIMHC12.s	        ;Base bundle
