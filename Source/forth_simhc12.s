;###############################################################################
;# S12CForth - S12CForth Framework Bundle (SIMHC12 Version)                    #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#   This version of OpenBDC contains modifications to run on the SIM68HC12    #
;#   simulator.                                                                #
;###############################################################################
;# Required Modules:                                                           #
;#     BASE   - S12CBase framework                                             #
;#     FCORE  - Forth core words                                               #
;#     FMEM   - Forth memories                                                 #
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
;# Global Defines:                                                             #
;#    DEBUG - Turns off functionality tha hinders debugging.                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
BASE_VARS_START 	EQU	FORTH_VARS_START
FCORE_VARS_START	EQU	BASE_VARS_END
FEXCPT_VARS_START	EQU	FCORE_VARS_END
FDOUBLE_VARS_START	EQU	FEXCPT_VARS_END
FTOOLS_VARS_START	EQU	FDOUBLE_VARS_END
FFACIL_VARS_START	EQU	FTOOLS_VARS_END
FBDM_VARS_START		EQU	FFACIL_VARS_END
FSCI_VARS_START		EQU	FBDM_VARS_END
FMEM_VARS_START		EQU	FSCI_VARS_END	
FMEM_VARS_END		EQU	FORTH_VARS_END

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FORTH_INIT, 0
	FCORE_INIT
	FMEM_INIT
	FEXCPT_INIT
	FDOUBLE_INIT
	FTOOLS_INIT
	FFACIL_INIT
	FBDM_INIT
	FSCI_INIT
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
BASE_CODE_START		EQU	FORTH_CODE_START
FCORE_CODE_START	EQU	BASE_CODE_END
FMEM_CODE_START		EQU	FCORE_CODE_END
FEXCPT_CODE_START	EQU	FMEM_CODE_END
FDOUBLE_CODE_START	EQU	FEXCPT_CODE_END
FTOOLS_CODE_START	EQU	FDOUBLE_CODE_END
FFACIL_CODE_START	EQU	FTOOLS_CODE_END
FBDM_CODE_START		EQU	FFACIL_CODE_END
FSCI_CODE_START		EQU	FBDM_CODE_END
FORTH_CODE_END		EQU	FSCI_CODE_END

			ORG	BASE_APP_START	
			;Initialize system			
FORTH_INIT		FORTH_INIT
			;Jump to application code 
#ifdef FORTH_APP_START
			JOB	FORTH_APP_START
BASE_APP_END		EQU	*
#else
FORTH_APP_START		EQU	*
BASE_APP_END		EQU	FORTH_APP_END
#endif
	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
BASE_TABS_START		EQU	FORTH_TABS_START
FCORE_TABS_START	EQU	BASE_TABS_END
FMEM_TABS_START		EQU	FCORE_TABS_END
FEXCPT_TABS_START	EQU	FMEM_TABS_END
FDOUBLE_TABS_START	EQU	FEXCPT_TABS_END
FTOOLS_TABS_START	EQU	FDOUBLE_TABS_END
FFACIL_TABS_START	EQU	FTOOLS_TABS_END
FBDM_TABS_START		EQU	FFACIL_TABS_END
FSCI_TABS_START		EQU	FBDM_TABS_END
			ORG	FSCI_TABS_END

#ifndef	MAIN_NAME_STRING
MAIN_NAME_STRING	FCS	"S12CForth (for SIMHC12)"
#endif

#ifndef	MAIN_VERSION_STRING
MAIN_VERSION_STRING	FCS	"V00.04"
#endif
	
FORTH_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
FFACIL_WORDS_START	EQU	FORTH_WORDS_P1_START
FTOOLS_WORDS_START	EQU	FFACIL_WORDS_END
FDOUBLE_WORDS_START	EQU	FTOOLS_WORDS_END	
FEXCPT_WORDS_START     	EQU	FDOUBLE_WORDS_END
FMEM_WORDS_START     	EQU	FEXCPT_WORDS_END
FCORE_WORDS_START     	EQU	FMEM_WORDS_END
FORTH_WORDS_P1_END	EQU	FCORE_WORDS_END

FSCI_WORDS_START	EQU	FORTH_WORDS_P2_START
FBDM_WORDS_START	EQU	FSCI_WORDS_END
FORTH_WORDS_P2_END	EQU	FBDM_WORDS_END
	
			;Connect dictionaries 
FSCI_PREV_NFA     	EQU	$0000
FBDM_PREV_NFA		EQU	FSCI_LAST_NFA
FFACIL_PREV_NFA		EQU	FBDM_LAST_NFA
FTOOLS_PREV_NFA		EQU	FFACIL_LAST_NFA
FDOUBLE_PREV_NFA	EQU	FTOOLS_LAST_NFA
FEXCPT_PREV_NFA		EQU	FDOUBLE_LAST_NFA
FMEM_PREV_NFA		EQU	FEXCPT_LAST_NFA
FCORE_PREV_NFA		EQU	FMEM_LAST_NFA
FORTH_PREV_NFA		EQU	FCORE_LAST_NFA
  
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Subprojects/S12CBase/Source/base_simhc12.s	;S12CBase
#include ./fcore.s					;Forth core words
#include ./fmem.s					;Forth memories
#include ./fexcpt.s					;Forth exceptions
#include ./fdouble.s					;Forth double-number words
#include ./ftools.s					;Forth programming tools words
#include ./ffacil.s					;Forth facility words
#include ./fbdm.s					;S12CBase BDM wrapper
#include ./fsci.s					;S12CBase SCI wrapper
