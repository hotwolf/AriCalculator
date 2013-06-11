;###############################################################################
;# S12CForth - S12CForth Framework Bundle (Mini-BDM-Pod)                       #
;###############################################################################
;#    Copyright 2010 - 2013 Dirk Heisswolf                                     #
;#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
;#    family.                                                                  #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#   This module bundles the S12CForth framework into a single include file    #
;#   This version of S12CForth runs on the Mini-BDM-Pod.                       #
;###############################################################################
;# Required Modules:                                                           #
;#     BASE   - S12CBase framework                                             #
;#     FCORE  - Forth core words                                               #
;#     FRAM   - Forth memories                                                 #
;#     FEXCPT - Forth exceptions                                               #
;#     FERROR - S12CBase ERROR wrapper                                         #
;#     FSCI   - S12CBase SCI wrapper                                           #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
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
ISTACK_NO_WAI		EQU	1	 	;keep WAIs out
ISTACK_S12X		EQU	1	 	;S12X interrupt handling

;# Subroutine stack
SSTACK_DEPTH		EQU	27	 	;no interrupt nesting
SSTACK_DEBUG		EQU	1 		;debug behavior

;# COP
COP_DEBUG		EQU	1 		;disable COP

;# RESET
RESET_CODERUN_OFF	EQU	1 		;don't report code runaways
RESET_WELCOME		EQU	DEMO_WELCOME 	;welcome message
	
;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs
	
;# SCI
SCI_FC_XONXOFF		EQU	1 		;XON/XOFF flow control
SCI_HANDLE_BREAK	EQU	1		;react to BREAK symbol
SCI_HANDLE_SUSPEND	EQU	1		;react to SUSPEND symbol
SCI_BD_ON		EQU	1 		;use baud rate detection
SCI_BD_ECT		EQU	1 		;TIM
SCI_BD_IC		EQU	0		;IC0
SCI_BD_OC		EQU	2		;OC2			
SCI_DLY_OC		EQU	3		;OC3
SCI_ERRSIG_ON		EQU	1 		;signal errors
SCI_BLOCKING_ON		EQU	1		;enable blocking subroutines
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FORTH_VARS_START_LIN
			ORG 	FORTH_VARS_START, FORTH_VARS_START_LIN
#else
			ORG 	FORTH_VARS_START
#endif	

BASE_VARS_START		EQU	*
BASE_VARS_START_LIN	EQU	@

FRAM_VARS_START		EQU	BASE_VARS_END	 
FRAM_VARS_START_LIN	EQU	BASE_VARS_END_LIN

FCORE_VARS_START	EQU	FRAM_VARS_END	 
FCORE_VARS_START_LIN	EQU	FRAM_VARS_END_LIN

FEXCPT_VARS_START	EQU	FCORE_VARS_END
FEXCPT_VARS_START_LIN	EQU	FCORE_VARS_END_LIN

;FDOUBLE_VARS_START	EQU	FEXCPT_VARS_END
;FDOUBLE_VARS_START_LIN	EQU	FEXCPT_VARS_END_LIN

;FTOOLS_VARS_START	EQU	FDOUBLE_VARS_END
;FTOOLS_VARS_START_LIN	EQU	FDOUBLE_VARS_END_LIN

;FFACIL_VARS_START	EQU	FTOOLS_VARS_END
;FFACIL_VARS_START_LIN	EQU	FTOOLS_VARS_END_LIN

;FBDM_VARS_START	EQU	FFACIL_VARS_END
;FBDM_VARS_START_LIN	EQU	FFACIL_VARS_END_LIN

;FSCI_VARS_START	EQU	FBDM_VARS_END
;FSCI_VARS_START_LIN	EQU	FBDM_VARS_END_LIN
	
FORTH_VARS_END		EQU	FEXCPT_VARS_START	
FORTH_VARS_END_LIN	EQU	FEXCPT_VARS_START_LIN

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FORTH_INIT, 0
	BASE_INIT
	FRAM_INIT
	FCORE_INIT
	FEXCPT_INIT
	;FDOUBLE_INIT
	;FTOOLS_INIT
	;FFACIL_INIT
	;FBDM_INIT
	;FSCI_INIT
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FORTH_CODE_START_LIN
			ORG 	FORTH_CODE_START, FORTH_CODE_START_LIN
#else
			ORG 	FORTH_CODE_START
#endif	

BASE_CODE_START		EQU	*
BASE_CODE_START_LIN	EQU	@

FRAM_CODE_START		EQU	BASE_CODE_END	 
FRAM_CODE_START_LIN	EQU	BASE_CODE_END_LIN

FCORE_CODE_START	EQU	FRAM_CODE_END	 
FCORE_CODE_START_LIN	EQU	FRAM_CODE_END_LIN

FEXCPT_CODE_START	EQU	FCORE_CODE_END	  
FEXCPT_CODE_START_LIN	EQU	FCORE_CODE_END_LIN

;FDOUBLE_CODE_START	EQU	FEXCPT_CODE_END
;FDOUBLE_CODE_START_LIN	EQU	FEXCPT_CODE_END_LIN

;FTOOLS_CODE_START	EQU	FDOUBLE_CODE_END
;FTOOLS_CODE_START_LIN	EQU	FDOUBLE_CODE_END_LIN

;FFACIL_CODE_START	EQU	FTOOLS_CODE_END
;FFACIL_CODE_START_LIN	EQU	FTOOLS_CODE_END_LIN

;FBDM_CODE_START	EQU	FFACIL_CODE_END
;FBDM_CODE_START_LIN	EQU	FFACIL_CODE_END_LIN

;FSCI_CODE_START	EQU	FBDM_CODE_END
;FSCI_CODE_START_LIN	EQU	FBDM_CODE_END_LIN

FORTH_CODE_END		EQU	FEXCPT_CODE_END	  	
FORTH_CODE_END_LIN	EQU	FEXCPT_CODE_END_LIN
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FORTH_TABS_START_LIN
			ORG 	FORTH_TABS_START, FORTH_TABS_START_LIN
#else
			ORG 	FORTH_TABS_START
#endif	

#ifndef	MAIN_NAME_STRING
MAIN_NAME_STRING	FCS	"S12CForth for Mini-BDM-Pod"
#endif

#ifndef	MAIN_VERSION_STRING
MAIN_VERSION_STRING	FCS	"V00.00"
#endif
	
BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@

FRAM_TABS_START		EQU	BASE_TABS_END	 
FRAM_TABS_START_LIN	EQU	BASE_TABS_END_LIN

FCORE_TABS_START	EQU	FRAM_TABS_END	 
FCORE_TABS_START_LIN	EQU	FRAM_TABS_END_LIN

FEXCPT_TABS_START	EQU	FCORE_TABS_END	  
FEXCPT_TABS_START_LIN	EQU	FCORE_TABS_END_LIN

;FDOUBLE_TABS_START	EQU	FEXCPT_TABS_END
;FDOUBLE_TABS_START_LIN	EQU	FEXCPT_TABS_END_LIN

;FTOOLS_TABS_START	EQU	FDOUBLE_TABS_END
;FTOOLS_TABS_START_LIN	EQU	FDOUBLE_TABS_END_LIN

;FFACIL_TABS_START	EQU	FTOOLS_TABS_END
;FFACIL_TABS_START_LIN	EQU	FTOOLS_TABS_END_LIN

;FBDM_TABS_START	EQU	FFACIL_TABS_END
;FBDM_TABS_START_LIN	EQU	FFACIL_TABS_END_LIN

;FSCI_TABS_START	EQU	FBDM_TABS_END
;FSCI_TABS_START_LIN	EQU	FBDM_TABS_END_LIN
	
FORTH_TABS_END		EQU	FEXCPT_TABS_END	  	  	
FORTH_TABS_END_LIN	EQU	FEXCPT_TABS_END_LIN

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
;FFACIL_WORDS_START	EQU	FORTH_WORDS_P1_START
;FTOOLS_WORDS_START	EQU	FFACIL_WORDS_END
;FDOUBLE_WORDS_START	EQU	FTOOLS_WORDS_END	
;FEXCPT_WORDS_START     	EQU	FDOUBLE_WORDS_END
;FRAM_WORDS_START     	EQU	FEXCPT_WORDS_END
;FCORE_WORDS_START     	EQU	FRAM_WORDS_END
;FORTH_WORDS_P1_END	EQU	FCORE_WORDS_END
;
;FSCI_WORDS_START	EQU	FORTH_WORDS_P2_START
;FBDM_WORDS_START	EQU	FSCI_WORDS_END
;FORTH_WORDS_P2_END	EQU	FBDM_WORDS_END
;	
;			;Connect dictionaries 
;FSCI_PREV_NFA     	EQU	$0000
;FBDM_PREV_NFA		EQU	FSCI_LAST_NFA
;FFACIL_PREV_NFA		EQU	FBDM_LAST_NFA
;FTOOLS_PREV_NFA		EQU	FFACIL_LAST_NFA
;FDOUBLE_PREV_NFA	EQU	FTOOLS_LAST_NFA
;FEXCPT_PREV_NFA		EQU	FDOUBLE_LAST_NFA
;FRAM_PREV_NFA		EQU	FEXCPT_LAST_NFA
;FCORE_PREV_NFA		EQU	FRAM_LAST_NFA
;FORTH_PREV_NFA		EQU	FCORE_LAST_NFA
  
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Subprojects/S12CBase/Source/base_simhc12.s	;S12CBase
#include ./fram.s					;Forth memories
#include ./fcore.s					;Forth core words
#include ./fexcpt.s					;Forth exceptions
;#include ./fdouble.s					;Forth double-number words
;#include ./ftools.s					;Forth programming tools words
;#include ./ffacil.s					;Forth facility words
;#include ./fbdm.s					;S12CBase BDM wrapper
;#include ./fsci.s					;S12CBase SCI wrapper
