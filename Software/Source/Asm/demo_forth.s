;###############################################################################
;# AriCalculator - Demo - Forth                                                #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
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
;# LRE or flash
#ifndef DEMO_LRE
#ifndef DEMO_FLASH
DEMO_LRE		EQU	1 		;default is LRE
#endif
#endif

;# Memory map:
MMAP_S12G240		EQU	1 		;S12G240
#ifdef DEMO_LRE
MMAP_RAM		EQU	1 		;use RAM memory map
#else
MMAP_FLASH		EQU	1 		;use FLASH memory map
#endif

;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs
		
;# COP debug
COP_DEBUG		EQU     1		;disable COP	

;# ISTACK debug
#ifdef DEMO_LRE
ISTACK_DEBUG		EQU     1		;don't execute WAI
#endif

;# String
;STRING_ENABLE_FILL_NB	EQU	1		;enable STRING_FILL_NB 
;STRING_ENABLE_FILL_BL	EQU	1		;enable STRING_FILL_BL 
	
;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START, MMAP_RAM_START 
#ifdef DEMO_LRE
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
#endif
	
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
UDICT_PS_END		EQU	((MMAP_RAM_END-*)*2)/3	;end of shared DICT/PAD/PS space
	
;TIB and return stack
RS_TIB_START		EQU	UDICT_PS_END		;start of shared TIB/RS space
RS_TIB_END		EQU	MMAP_RAM_END		;end of shared TIB/RS space
	
#ifndef DEMO_LRE
			ORG	$E000, $3E000
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

			ALIGN 	7, $FF ;align to D-Bug12XZ programming granularity
#endif

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
;#Busy signal 
#macro FORTH_SIGNAL_BUSY, 0
			LED_BUSY_ON 
#emac
#macro FORTH_SIGNAL_IDLE, 0
			LED_BUSY_OFF 
#emac

;Break handler
#macro	SCI_BREAK_ACTION, 0
			FORCE_SRESET
#emac
	
;Suspend handler
#macro	SCI_SUSPEND_ACTION, 0
			FORCE_SUSPEND
#emac

;VBAT -> busy LED
#macro	VMON_VBAT_LVACTION, 0
			LED_ERR_ON
#emac
#macro	VMON_VBAT_HVACTION, 0
			LED_ERR_OFF LED_NOP, LED_NOP
#emac

;VUSB -> error LED
#macro	VMON_VUSB_LVACTION, 0
			SCI_DISABLE
#emac
#macro	VMON_VUSB_HVACTION, 0
			SCI_ENABLE
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
			;Initialization
			BASE_INIT
			FORTH_INIT

			;Enter QUIT shell
			JOB	CF_QUIT_RT
	
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
;# Forth words                                                                 #
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
;#include ./base_AriCalculator.s	   				;S12CBase
#include ../../../../S12CForth/Source/All/forth.s	        ;.........latest S12CForth
;#include ../../../Subprojects/S12CForth/Source/All/forth.s	;S12CForth
#include ./base_AriCalculator.s	   				;S12CBase

