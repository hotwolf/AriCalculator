#ifndef FORTH_COMPILED
#define	FORTH_COMPILED
;###############################################################################
;# S12CForth - S12CForth Framework Bundle                                      #
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
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    Program termination options:                                             #
;#      ABORT:                                                                 #
;#      QUIT:                                                                  #
;#                                                                             #
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
;#    February 4, 2015                                                         #
;#      - Initial release                                                      #
;#    September 28, 2016                                                       #
;#      - Started subroutine threaded implementation                           #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;        
;      	  UDICT_PS_START -> +--------------+--------------+	     
;                           |       User Dictionary       |	     
;                           |             PAD             |	     
;                           |       Parameter stack       |		  
;           UDICT_PS_END -> +--------------+--------------+        
;           RS_TIB_START -> +--------------+--------------+        
;                           |       Text Input Buffer     |
;                           |        Return Stack         |
;             RS_TIB_END -> +--------------+--------------+
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Non-volatile dictionary 
#ifndef	NVDICT_ON
#ifndef	NVDICT_OFF
NVDICT_OFF		EQU	1 		;NVDICT disabled by default
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Max. line length
DEFAULT_LINE_WIDTH	EQU	60

;#S12CBASE STRING requirements
;STRING_ENABLE_FILL_NB	EQU	1	;enable STRING_FILL_NB 
;STRING_ENABLE_FILL_BL	EQU	1	;enable STRING_FILL_BL 
;STRING_ENABLE_UPPER	EQU	1	;enable STRING_UPPER 

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FORTH_VARS_START_LIN
			ORG 	FORTH_VARS_START, FORTH_VARS_START_LIN
#else
			ORG 	FORTH_VARS_START
#endif	

FTIB_VARS_START		EQU	*
FTIB_VARS_START_LIN	EQU	@
			ORG	FTIB_VARS_END, FTIB_VARS_END_LIN

FRS_VARS_START		EQU	*
FRS_VARS_START_LIN	EQU	@
			ORG	FRS_VARS_END, FRS_VARS_END_LIN

;FINNER_VARS_START	EQU	*
;FINNER_VARS_START_LIN	EQU	@
;			ORG	FINNER_VARS_END, FINNER_VARS_END_LIN
;
;FIRQ_VARS_START		EQU	*
;FIRQ_VARS_START_LIN	EQU	@
;			ORG	FIRQ_VARS_END, FIRQ_VARS_END_LIN
;
FPS_VARS_START		EQU	*
FPS_VARS_START_LIN	EQU	@
			ORG	FPS_VARS_END, FPS_VARS_END_LIN

;FIO_VARS_START		EQU	*
;FIO_VARS_START_LIN	EQU	@
;			ORG	FIO_VARS_END, FIO_VARS_END_LIN
;
FOUTER_VARS_START	EQU	*
FOUTER_VARS_START_LIN	EQU	@
			ORG	FOUTER_VARS_END, FOUTER_VARS_END_LIN

FCDICT_VARS_START	EQU	*
FCDICT_VARS_START_LIN	EQU	@
			ORG	FCDICT_VARS_END, FCDICT_VARS_END_LIN

;FNVDICT_VARS_START	EQU	*
;FNVDICT_VARS_START_LIN	EQU	@
;			ORG	FNVDICT_VARS_END, FNVDICT_VARS_END_LIN
;	
FUDICT_VARS_START	EQU	*
FUDICT_VARS_START_LIN	EQU	@
			ORG	FUDICT_VARS_END, FUDICT_VARS_END_LIN

;FEXCPT_VARS_START	EQU	*
;FEXCPT_VARS_START_LIN	EQU	@
;			ORG	FEXCPT_VARS_END, FEXCPT_VARS_END_LIN
;
;FCORE_VARS_START	EQU	*
;FCORE_VARS_START_LIN	EQU	@
;			ORG	FCORE_VARS_END, FCORE_VARS_END_LIN
;
;FDOUBLE_VARS_START	EQU	*
;FDOUBLE_VARS_START_LIN	EQU	@
;			ORG	FDOUBLE_VARS_END, FDOUBLE_VARS_END_LIN
;
;FFLOAT_VARS_START	EQU	*
;FFLOAT_VARS_START_LIN	EQU	@
;			ORG	FFLOAT_VARS_END, FFLOAT_VARS_END_LIN
;
;FTOOLS_VARS_START	EQU	*
;FTOOLS_VARS_START_LIN	EQU	@
;			ORG	FTOOLS_VARS_END, FTOOLS_VARS_END_LIN
;
;FFACIL_VARS_START	EQU	*
;FFACIL_VARS_START_LIN	EQU	@
;			ORG	FFACIL_VARS_END, FFACIL_VARS_END_LIN
;
;FSCI_VARS_START		EQU	*
;FSCI_VARS_START_LIN	EQU	@
;			ORG	FSCI_VARS_END, FSCI_VARS_END_LIN

	
FORTH_VARS_END		EQU	*	
FORTH_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;;#Busy/Idle signal 
;#ifnmac	FORTH_SIGNAL_BUSY
;#ifmac	LED_BUSY_ON
;#macro FORTH_SIGNAL_BUSY, 0
;			LED_BUSY_ON 
;#emac
;#endif	
;#endif	
;#ifnmac	FORTH_SIGNAL_IDLE
;#ifmac	LED_BUSY_OFF
;#macro FORTH_SIGNAL_IDLE, 0
;			LED_BUSY_OFF 
;#emac
;#endif	
;#endif	
	
;#Break handler
#ifnmac	SCI_BREAK_ACTION	
#macro	SCI_BREAK_ACTION, 0
	;FOUTER_INVOKE_ABORT
#emac
#endif	

;#Initialization (to be executed in addition of ABORT action)
#macro	FORTH_INIT, 0
	FTIB_INIT
	FRS_INIT
	;FINNER_INIT
	;FIRQ_INIT
	FPS_INIT
	FOUTER_INIT
	FCDICT_INIT
	;FNVDICT_INIT
	FUDICT_INIT
	;FEXCPT_INIT
	;FCORE_INIT
	;FDOUBLE_INIT
	;FFLOAT_INIT
	;FTOOLS_INIT
	;FFACIL_INIT
	;FSCI_INIT
#emac

;#Abort action (to be executed in addition of QUIT action)
#macro	FORTH_ABORT, 0
	FTIB_ABORT
	FRS_ABORT
	;FINNER_ABORT
	;FIRQ_ABORT
	FPS_ABORT
	;FIO_ABORT
	FOUTER_ABORT
	FCDICT_ABORT
	;FNVDICT_ABORT
	FUDICT_ABORT
	;FEXCPT_ABORT
	;FCORE_ABORT
	;FDOUBLE_ABORT
	;FFLOAT_ABORT
	;FTOOLS_ABORT
	;FFACIL_ABORT
	;FSCI_ABORT
#emac
	
;#Quit action
#macro	FORTH_QUIT, 0
	FTIB_QUIT
	FRS_QUIT
	;FINNER_QUIT
	;FIRQ_QUIT
	FPS_QUIT
	;FIO_QUIT
	FOUTER_QUIT
	FCDICT_QUIT
	;FNVDICT_QUIT
	FUDICT_QUIT
	;FEXCPT_QUIT
	;FCORE_QUIT
	;FDOUBLE_QUIT
	;FFLOAT_QUIT
	;FTOOLS_QUIT
	;FFACIL_QUIT
	;FSCI_QUIT
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FORTH_CODE_START_LIN
			ORG 	FORTH_CODE_START, FORTH_CODE_START_LIN
#else
			ORG 	FORTH_CODE_START
#endif	

FTIB_CODE_START		EQU	*
FTIB_CODE_START_LIN	EQU	@
			ORG	FTIB_CODE_END, FTIB_CODE_END_LIN

FRS_CODE_START		EQU	*
FRS_CODE_START_LIN	EQU	@
			ORG	FRS_CODE_END, FRS_CODE_END_LIN

;FINNER_CODE_START	EQU	*
;FINNER_CODE_START_LIN	EQU	@
;			ORG	FINNER_CODE_END, FINNER_CODE_END_LIN
;
;FIRQ_CODE_START		EQU	*
;FIRQ_CODE_START_LIN	EQU	@
;			ORG	FIRQ_CODE_END, FIRQ_CODE_END_LIN
;
FPS_CODE_START		EQU	*
FPS_CODE_START_LIN	EQU	@
			ORG	FPS_CODE_END, FPS_CODE_END_LIN

;FIO_CODE_START		EQU	*
;FIO_CODE_START_LIN	EQU	@
;			ORG	FIO_CODE_END, FIO_CODE_END_LIN
;
FOUTER_CODE_START	EQU	*
FOUTER_CODE_START_LIN	EQU	@
			ORG	FOUTER_CODE_END, FOUTER_CODE_END_LIN

FCDICT_CODE_START	EQU	*
FCDICT_CODE_START_LIN	EQU	@
			ORG	FCDICT_CODE_END, FCDICT_CODE_END_LIN

;FNVDICT_CODE_START	EQU	*
;FNVDICT_CODE_START_LIN	EQU	@
;			ORG	FNVDICT_CODE_END, FNVDICT_CODE_END_LIN
;	
FUDICT_CODE_START	EQU	*
FUDICT_CODE_START_LIN	EQU	@
			ORG	FUDICT_CODE_END, FUDICT_CODE_END_LIN

;FEXCPT_CODE_START	EQU	*
;FEXCPT_CODE_START_LIN	EQU	@
;			ORG	FEXCPT_CODE_END, FEXCPT_CODE_END_LIN
;
;FCORE_CODE_START	EQU	*
;FCORE_CODE_START_LIN	EQU	@
;			ORG	FCORE_CODE_END, FCORE_CODE_END_LIN
;
;FDOUBLE_CODE_START	EQU	*
;FDOUBLE_CODE_START_LIN	EQU	@
;			ORG	FDOUBLE_CODE_END, FDOUBLE_CODE_END_LIN
;
;FFLOAT_CODE_START	EQU	*
;FFLOAT_CODE_START_LIN	EQU	@
;			ORG	FFLOAT_CODE_END, FFLOAT_CODE_END_LIN
;
;FTOOLS_CODE_START	EQU	*
;FTOOLS_CODE_START_LIN	EQU	@
;			ORG	FTOOLS_CODE_END, FTOOLS_CODE_END_LIN
;
;FFACIL_CODE_START	EQU	*
;FFACIL_CODE_START_LIN	EQU	@
;			ORG	FFACIL_CODE_END, FFACIL_CODE_END_LIN
;
;FSCI_CODE_START		EQU	*
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

FTIB_TABS_START		EQU	*
FTIB_TABS_START_LIN	EQU	@
			ORG	FTIB_TABS_END, FTIB_TABS_END_LIN

FRS_TABS_START		EQU	*
FRS_TABS_START_LIN	EQU	@
			ORG	FRS_TABS_END, FRS_TABS_END_LIN

;FINNER_TABS_START	EQU	*
;FINNER_TABS_START_LIN	EQU	@
;			ORG	FINNER_TABS_END, FINNER_TABS_END_LIN
;
;FIRQ_TABS_START		EQU	*
;FIRQ_TABS_START_LIN	EQU	@
;			ORG	FIRQ_TABS_END, FIRQ_TABS_END_LIN
;
FPS_TABS_START		EQU	*
FPS_TABS_START_LIN	EQU	@
			ORG	FPS_TABS_END, FPS_TABS_END_LIN

;FIO_TABS_START		EQU	*
;FIO_TABS_START_LIN	EQU	@
;			ORG	FIO_TABS_END, FIO_TABS_END_LIN
;
FOUTER_TABS_START	EQU	*
FOUTER_TABS_START_LIN	EQU	@
			ORG	FOUTER_TABS_END, FOUTER_TABS_END_LIN

FCDICT_TABS_START	EQU	*
FCDICT_TABS_START_LIN	EQU	@
			ORG	FCDICT_TABS_END, FCDICT_TABS_END_LIN

;FNVDICT_TABS_START	EQU	*
;FNVDICT_TABS_START_LIN	EQU	@
;			ORG	FNVDICT_TABS_END, FNVDICT_TABS_END_LIN
;	
FUDICT_TABS_START	EQU	*
FUDICT_TABS_START_LIN	EQU	@
			ORG	FUDICT_TABS_END, FUDICT_TABS_END_LIN

;FEXCPT_TABS_START	EQU	*
;FEXCPT_TABS_START_LIN	EQU	@
;			ORG	FEXCPT_TABS_END, FEXCPT_TABS_END_LIN
;
;FCORE_TABS_START	EQU	*
;FCORE_TABS_START_LIN	EQU	@
;			ORG	FCORE_TABS_END, FCORE_TABS_END_LIN
;
;FDOUBLE_TABS_START	EQU	*
;FDOUBLE_TABS_START_LIN	EQU	@
;			ORG	FDOUBLE_TABS_END, FDOUBLE_TABS_END_LIN
;
;FFLOAT_TABS_START	EQU	*
;FFLOAT_TABS_START_LIN	EQU	@
;			ORG	FFLOAT_TABS_END, FFLOAT_TABS_END_LIN
;
;FTOOLS_TABS_START	EQU	*
;FTOOLS_TABS_START_LIN	EQU	@
;			ORG	FTOOLS_TABS_END, FTOOLS_TABS_END_LIN
;
;FFACIL_TABS_START	EQU	*
;FFACIL_TABS_START_LIN	EQU	@
;			ORG	FFACIL_TABS_END, FFACIL_TABS_END_LIN
;
;FSCI_TABS_START	EQU	*
;FSCI_TABS_START_LIN	EQU	@
;			ORG	FSCI_TABS_END, FSCI_TABS_END_LIN

FORTH_TABS_END		EQU	*	
FORTH_TABS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include .//ftib.s					;text input buffer
#include .//frs.s					;return stack
#include .//fps.s					;parameter stack 
;#include .//fio.s					;communication interface 
;#include .//fexcpt.s					;exceptions
;#include .//finner.s					;inner interpreter
#include .//fouter.s					;outer interpreter
;#include .//firq.s					;interrupt requests
#include .//fcdict.s					;core dictionary
#include .//fcdict_tree.s				;core dictionary search tree
;#include .//fnvdict.s					;non-volatile dictionary
#include .//fudict.s					;user dictionary
;#include .//fcore.s					;core words
;#include .//fdouble.s					;double-number words
;#include .//ffloat.s					;floating point words
;#include .//ftools.s					;programming tools words
;#include .//ffacil.s					;facility words
;#include .//fsci.s					;S12CBase SCI wrapper
#endif
	
