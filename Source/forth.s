;###############################################################################
;# S12CForth - S12CForth Framework Bundle                                      #
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
FCORE_VARS_START	EQU	FORTH_VARS_END
FMEM_VARS_START		EQU	FCORE_VARS_END
FEXCPT_VARS_START	EQU	FMEM_VARS_END
FERROR_VARS_START	EQU	FEXCPT_VARS_END
FSCI_VARS_START		EQU	FERROR_VARS_END
BASE_VARS_START 	EQU	FSCI_VARS_START
FORTH_VARS_END		EQU	BASE_VARS_END

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FORTH_INIT, 0
	BASE_INIT
	FCORE_INIT
	FMEM_INIT
	FEXCPT_INIT
	FERROR_INIT
	FSCI_INIT
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
FCORE_CODE_START	EQU	FORTH_VARS_END
FMEM_CODE_START		EQU	FCORE_VARS_END
FEXCPT_CODE_START	EQU	FMEM_VARS_END
FERROR_CODE_START	EQU	FEXCPT_VARS_END
FSCI_CODE_START		EQU	FERROR_VARS_END
BASE_CODE_START		EQU	FSCI_CODE_START
			ORG	BASE_APP_START
	
			;Initialize system			
FORTH_INIT		FORTH_INIT

			;Jump to application code 
#ifdef FORTH_APP_START
			JOB	FORTH_APP_START
#else
FORTH_APP_START		EQU	*
#endif
	
FORTH_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
FCORE_TABS_START	EQU	FORTH_TABS_START
FMEM_TABS_START		EQU	FCORE_TABS_END
FEXCPT_TABS_START	EQU	FMEM_TABS_END
FERROR_TABS_START	EQU	FEXCPT_TABS_END
FSCI_TABS_START		EQU	FERROR_TABS_END
BASE_TABS_START 	EQU	FSCI_TABS_START
			ORG	BASE_TABS_END
#ifndef	MAIN_NAME_STRING
MAIN_NAME_STRING	FCS	"S12CForth"
#endif

#ifndef	MAIN_VERSION_STRING
MAIN_VERSION_STRING	FCS	"V00.00"
#endif
	
FORTH_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FORTH_WORDS_START ;(previous NFA: FCORE_PREV_NFA)


  
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Subprojects/S12CBase/Source/base.s	;S12CBase
#include ./fcore.s				;Forth core words
#include ./fmem.s				;Forth memories
#include ./fexcpt.s				;Forth exceptions
#include ./fdouble.s				;Forth double-number words
#include ./ftools.s				;Forth programming tools words
#include ./ferror.s				;S12CBase error wrapper
#include ./fsci.s				;S12CBase SCI wrapper
#include ./fbdm.s				;S12CBase BDM wrapper
