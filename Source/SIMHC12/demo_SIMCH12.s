;###############################################################################
;# S12CForth - Demo (SIMHC12)                                                  #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12C MCU family.  #
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
;#    September 28, 2016                                                       #
;#      - Started subroutine threaded implementation                           #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# COP
COP_DEBUG		EQU	1 		;disable COP
	
;# VECTAB
VECTAB_DEBUG		EQU	1 		;break on false interrupt
	
;# STRING
STRING_ENABLE_FILL_NB	EQU	1 		;enable STRING_FILL_NB
STRING_ENABLE_FILL_BL	EQU	1 		;enable STRING_FILL_BL
STRING_ENABLE_PRINTABLE	EQU	1 		;enable STRING_PRINTABLE

;# FOUTER	
FOUTER_NL_CR		EQU	1 		;interpret CR as line break,
						;ignore LF	
;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_EXTRAM_START, UNMAPPED
;Variables
DEMO_VARS_START		EQU	*
DEMO_VARS_START_LIN	EQU	@
			ORG	DEMO_VARS_END, UNMAPPED

BASE_VARS_START		EQU	*
BASE_VARS_START_LIN	EQU	@
			ORG	BASE_VARS_END, UNMAPPED

FORTH_VARS_START	EQU	*
FORTH_VARS_START_LIN	EQU	@
			ORG	FORTH_VARS_END, UNMAPPED
	
;Stack 
SSTACK_TOP		EQU	* 				;SSTACK, ISTACK, and RS are unified
SSTACK_TOP_LIN		EQU	@
SSTACK_BOTTOM		EQU	MMAP_EXTRAM_END

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
UDICT_PS_START		EQU	SSTACK_TOP			;start of shared DICT/PAD/PS space
UDICT_PS_SIZE		EQU	(((SSTACK_SIZE*2)/3)&$FFFE)	;2/3 of available RAM space
UDICT_PS_END		EQU	SSTACK_TOP+UDICT_PS_SIZE	;end of shared DICT/PAD/PS space

;TIB and return stack;
RS_TIB_START		EQU	UDICT_PS_END			;start of shared TIB/RS space
RS_TIB_END		EQU	SSTACK_BOTTOM			;end of shared TIB/RS space
			
			ORG	MMAP_FLASH3F_START
;Code
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@
			ORG	DEMO_CODE_END, DEMO_CODE_END_LIN

BASE_CODE_START		EQU	*
BASE_CODE_START_LIN	EQU	@
			ORG	BASE_CODE_END, BASE_CODE_END_LIN

FORTH_CODE_START		EQU	*
FORTH_CODE_START_LIN	EQU	@
			ORG	FORTH_CODE_END, FORTH_CODE_END_LIN

;Tables
DEMO_TABS_START		EQU	*
DEMO_TABS_START_LIN	EQU	@
			ORG	DEMO_TABS_END, DEMO_TABS_END_LIN

BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@
			ORG	BASE_TABS_END, BASE_TABS_END_LIN

FORTH_TABS_START		EQU	*
FORTH_TABS_START_LIN	EQU	@
			ORG	FORTH_TABS_END, FORTH_TABS_END_LIN
				
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DEMO_VARS_START_LIN
			ORG 	DEMO_VARS_START, DEMO_VARS_START_LIN
#else
			ORG 	DEMO_VARS_START
#endif	

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
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DEMO_CODE_START_LIN
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN
#else
			ORG 	DEMO_CODE_START
#endif	

;Initialization
			BASE_INIT
			FORTH_INIT
			WELCOME_MESSAGE
	
;Application code
DEMO_LOOP		JOB	*

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
	
DEMO_TABS_END		EQU	*
DEMO_TABS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../All/forth.s							;S12CForth bundle
;#include ../../Subprojects/S12CBase/Source/SIMHC12/base_SIMHC12.s	;Base bundle
#include ../../../S12CBase/Source/SIMHC12/base_SIMHC12.s	        ;Base bundle
