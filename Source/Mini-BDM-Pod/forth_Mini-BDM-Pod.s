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
			ORG	BASE_VARS_END, BASE_VARS_END_LIN

FRS_VARS_START		EQU	*
FRS_VARS_START_LIN	EQU	@
			ORG	FRS_VARS_END, FRS_VARS_END_LIN

FPS_VARS_START		EQU	*
FPS_VARS_START_LIN	EQU	@
			ORG	FPS_VARS_END, FPS_VARS_END_LIN

FUDICT_VARS_START	EQU	*
FUDICT_VARS_START_LIN	EQU	@
			ORG	FUDICT_VARS_END, FUDICT_VARS_END_LIN

FINNER_VARS_START	EQU	*
FINNER_VARS_START_LIN	EQU	@
			ORG	FINNER_VARS_END, FINNER_VARS_END_LIN

FOUTER_VARS_START	EQU	*
FOUTER_VARS_START_LIN	EQU	@
			ORG	FOUTER_VARS_END, FOUTER_VARS_END_LIN

FCORE_VARS_START	EQU	*
FCORE_VARS_START_LIN	EQU	@
			ORG	FCORE_VARS_END, FCORE_VARS_END_LIN

FEXCPT_VARS_START	EQU	*
FEXCPT_VARS_START_LIN	EQU	@
			ORG	FEXCPT_VARS_END, FEXCPT_VARS_END_LIN

;FDOUBLE_VARS_START	EQU	*
;FDOUBLE_VARS_START_LIN	EQU	@
;			ORG	FDOUBLE_VARS_END, FDOUBLE_VARS_END_LIN

;FFLOAT_VARS_START	EQU	*
;FFLOAT_VARS_START_LIN	EQU	@
;			ORG	FFLOAT_VARS_END, FFLOAT_VARS_END_LIN

;FTOOLS_VARS_START	EQU	*
;FTOOLS_VARS_START_LIN	EQU	@
;			ORG	FTOOLS_VARS_END, FTOOLS_VARS_END_LIN

;FFACIL_VARS_START	EQU	*
;FFACIL_VARS_START_LIN	EQU	@
;			ORG	FFACIL_VARS_END, FFACIL_VARS_END_LIN

;FSCI_VARS_START	EQU	*
;FSCI_VARS_START_LIN	EQU	@
;			ORG	FSCI_VARS_END, FSCI_VARS_END_LIN

FORTH_VARS_END		EQU	*	
FORTH_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FORTH_INIT, 0
	BASE_INIT
	FRS_INIT
	FPS_INIT
	FUDICT_INIT
	FINNER_INIT
	FOUTER_INIT
	FCORE_INIT
	FEXCPT_INIT
	;FDOUBLE_INIT
	;FFLOAT_INIT
	;FTOOLS_INIT
	;FFACIL_INIT
	;FSCI_INIT
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FORTH_ABORT, 0
	FRS_ABORT
	FPS_ABORT
	FUDICT_ABORT
	FINNER_ABORT
	FOUTER_ABORT
	FCORE_ABORT
	FEXCPT_ABORT
	;FDOUBLE_ABORT
	;FFLOAT_ABORT
	;FTOOLS_ABORT
	;FFACIL_ABORT
	;FSCI_ABORT
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FORTH_QUIT, 0
	FRS_QUIT
	FPS_QUIT
	FUDICT_QUIT
	FINNER_QUIT
	FOUTER_QUIT
	FCORE_QUIT
	FEXCPT_QUIT
	;FDOUBLE_QUIT
	;FFLOAT_QUIT
	;FTOOLS_QUIT
	;FFACIL_QUIT
	;FSCI_QUIT
#emac
	
;#Suspend action
#macro	FORTH_SUSPEND, 0
	FRS_SUSPEND
	FPS_SUSPEND
	FUDICT_SUSPEND
	FINNER_SUSPEND
	FOUTER_SUSPEND
	FCORE_SUSPEND
	FEXCPT_SUSPEND
	;FDOUBLE_SUSPEND
	;FFLOAT_SUSPEND
	;FTOOLS_SUSPEND
	;FFACIL_SUSPEND
	;FSCI_SUSPEND
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
			ORG	BASE_CODE_END, BASE_CODE_END_LIN

FRS_CODE_START		EQU	*
FRS_CODE_START_LIN	EQU	@
			ORG	FRS_CODE_END, FRS_CODE_END_LIN

FPS_CODE_START		EQU	*
FPS_CODE_START_LIN	EQU	@
			ORG	FPS_CODE_END, FPS_CODE_END_LIN

FUDICT_CODE_START	EQU	*
FUDICT_CODE_START_LIN	EQU	@
			ORG	FUDICT_CODE_END, FUDICT_CODE_END_LIN

FINNER_CODE_START	EQU	*
FINNER_CODE_START_LIN	EQU	@
			ORG	FINNER_CODE_END, FINNER_CODE_END_LIN

FOUTER_CODE_START	EQU	*
FOUTER_CODE_START_LIN	EQU	@
			ORG	FOUTER_CODE_END, FOUTER_CODE_END_LIN

FCORE_CODE_START	EQU	*
FCORE_CODE_START_LIN	EQU	@
			ORG	FCORE_CODE_END, FCORE_CODE_END_LIN

FEXCPT_CODE_START	EQU	*
FEXCPT_CODE_START_LIN	EQU	@
			ORG	FEXCPT_CODE_END, FEXCPT_CODE_END_LIN

;FDOUBLE_CODE_START	EQU	*
;FDOUBLE_CODE_START_LIN	EQU	@
;			ORG	FDOUBLE_CODE_END, FDOUBLE_CODE_END_LIN

;FFLOAT_CODE_START	EQU	*
;FFLOAT_CODE_START_LIN	EQU	@
;			ORG	FFLOAT_CODE_END, FFLOAT_CODE_END_LIN

;FTOOLS_CODE_START	EQU	*
;FTOOLS_CODE_START_LIN	EQU	@
;			ORG	FTOOLS_CODE_END, FTOOLS_CODE_END_LIN

;FFACIL_CODE_START	EQU	*
;FFACIL_CODE_START_LIN	EQU	@
;			ORG	FFACIL_CODE_END, FFACIL_CODE_END_LIN

;FSCI_CODE_START	EQU	*
;FSCI_CODE_START_LIN	EQU	@
;			ORG	FSCI_CODE_END, FSCI_CODE_END_LIN

FORTH_CODE_END		EQU	*	
FORTH_CODE_END_LIN	EQU	@
	
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
			ORG	BASE_TABS_END, BASE_TABS_END_LIN

FRS_TABS_START		EQU	*
FRS_TABS_START_LIN	EQU	@
			ORG	FRS_TABS_END, FRS_TABS_END_LIN

FPS_TABS_START		EQU	*
FPS_TABS_START_LIN	EQU	@
			ORG	FPS_TABS_END, FPS_TABS_END_LIN

FUDICT_TABS_START	EQU	*
FUDICT_TABS_START_LIN	EQU	@
			ORG	FUDICT_TABS_END, FUDICT_TABS_END_LIN

FINNER_TABS_START	EQU	*
FINNER_TABS_START_LIN	EQU	@
			ORG	FINNER_TABS_END, FINNER_TABS_END_LIN

FOUTER_TABS_START	EQU	*
FOUTER_TABS_START_LIN	EQU	@
			ORG	FOUTER_TABS_END, FOUTER_TABS_END_LIN

FCORE_TABS_START	EQU	*
FCORE_TABS_START_LIN	EQU	@
			ORG	FCORE_TABS_END, FCORE_TABS_END_LIN

FEXCPT_TABS_START	EQU	*
FEXCPT_TABS_START_LIN	EQU	@
			ORG	FEXCPT_TABS_END, FEXCPT_TABS_END_LIN

;FDOUBLE_TABS_START	EQU	*
;FDOUBLE_TABS_START_LIN	EQU	@
;			ORG	FDOUBLE_TABS_END, FDOUBLE_TABS_END_LIN

;FFLOAT_TABS_START	EQU	*
;FFLOAT_TABS_START_LIN	EQU	@
;			ORG	FFLOAT_TABS_END, FFLOAT_TABS_END_LIN

;FTOOLS_TABS_START	EQU	*
;FTOOLS_TABS_START_LIN	EQU	@
;			ORG	FTOOLS_TABS_END, FTOOLS_TABS_END_LIN

;FFACIL_TABS_START	EQU	*
;FFACIL_TABS_START_LIN	EQU	@
;			ORG	FFACIL_TABS_END, FFACIL_TABS_END_LIN

;FSCI_TABS_START	EQU	*
;FSCI_TABS_START_LIN	EQU	@
;			ORG	FSCI_TABS_END, FSCI_TABS_END_LIN

FORTH_TABS_END		EQU	*	
FORTH_TABS_END_LIN	EQU	@

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
  
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Subprojects/S12CBase/Source/base_Mini-BDM_Pod.s	;S12CBase
#include ./frs.s						;return stack
#include ./fps.s						;parameter stack 
#include ./fudict.s						;user dictionary
#include ./finner.s						;inner interpreter
#include ./fouter.s						;outer interpreter
#include ./fcore.s						;core words
#include ./fexcpt.s						;exceptions
;#include ./fdouble.s						;double-number words
;#include ./ffloat.s						;floating point words
;#include ./ftools.s						;programming tools words
;#include ./ffacil.s						;facility words
;#include ./fsci.s						;S12CBase SCI wrapper
