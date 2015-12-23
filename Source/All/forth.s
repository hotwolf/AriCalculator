#ifndef FORTH_COMPILED
#define	FORTH_COMPILED
;###############################################################################
;# S12CForth - S12CForth Framework Bundle                                      #
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
;#    February 4, 2015                                                         #
;#      - Initial release                                                      #
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
;#Stack protection
;FRS
;FRS_NO_CHECK		EQU	1 		;disable range checks
	
;FPS
;FPS_NO_CHECK		EQU	1 		;disable range checks

;S12CBase subroutine stack size 
#ifndef SSTACK_DEPTH
SSTACK_DEPTH		EQU	32
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#S12CBASE STRING requirements
STRING_ENABLE_FILL_NB	EQU	1	;enable STRING_FILL_NB 
STRING_ENABLE_FILL_BL	EQU	1	;enable STRING_FILL_BL 
STRING_ENABLE_UPPER	EQU	1	;enable STRING_UPPER 

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FORTH_VARS_START_LIN
			ORG 	FORTH_VARS_START, FORTH_VARS_START_LIN
#else
			ORG 	FORTH_VARS_START
#endif	

FRS_VARS_START		EQU	*
FRS_VARS_START_LIN	EQU	@
			ORG	FRS_VARS_END, FRS_VARS_END_LIN

FINNER_VARS_START	EQU	*
FINNER_VARS_START_LIN	EQU	@
			ORG	FINNER_VARS_END, FINNER_VARS_END_LIN

FIRQ_VARS_START		EQU	*
FIRQ_VARS_START_LIN	EQU	@
			ORG	FIRQ_VARS_END, FIRQ_VARS_END_LIN

FPS_VARS_START		EQU	*
FPS_VARS_START_LIN	EQU	@
			ORG	FPS_VARS_END, FPS_VARS_END_LIN

FIO_VARS_START		EQU	*
FIO_VARS_START_LIN	EQU	@
			ORG	FIO_VARS_END, FIO_VARS_END_LIN

FOUTER_VARS_START	EQU	*
FOUTER_VARS_START_LIN	EQU	@
			ORG	FOUTER_VARS_END, FOUTER_VARS_END_LIN

FCDICT_VARS_START	EQU	*
FCDICT_VARS_START_LIN	EQU	@
			ORG	FCDICT_VARS_END, FCDICT_VARS_END_LIN

FNVDICT_VARS_START	EQU	*
FNVDICT_VARS_START_LIN	EQU	@
			ORG	FNVDICT_VARS_END, FNVDICT_VARS_END_LIN

FUDICT_VARS_START	EQU	*
FUDICT_VARS_START_LIN	EQU	@
			ORG	FUDICT_VARS_END, FUDICT_VARS_END_LIN

FEXCPT_VARS_START	EQU	*
FEXCPT_VARS_START_LIN	EQU	@
			ORG	FEXCPT_VARS_END, FEXCPT_VARS_END_LIN

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
;#Busy/Idle signal 
#ifnmac	FORTH_SIGNAL_BUSY
#ifmac	LED_BUSY_ON
#macro FORTH_SIGNAL_BUSY, 0
			LED_BUSY_ON 
#emac
#endif	
#endif	
#ifnmac	FORTH_SIGNAL_IDLE
#ifmac	LED_BUSY_OFF
#macro FORTH_SIGNAL_IDLE, 0
			LED_BUSY_OFF 
#emac
#endif	
#endif	
	
;#Break handler
#ifnmac	SCI_BREAK_ACTION	
#macro	SCI_BREAK_ACTION, 0
	;FOUTER_INVOKE_ABORT
#emac
#endif	
	
;#Suspend handler
#ifnmac	SCI_SUSPEND_ACTION
#macro	SCI_SUSPEND_ACTION, 0
	;FOUTER_INVOKE_SUSPEND
#emac
#endif	

;#Initialization
#macro	FORTH_DEFAULT_INIT, 0
	FRS_INIT
	FINNER_INIT
	FIRQ_INIT
	FPS_INIT
	FOUTER_INIT
	FCDICT_INIT
	FNVDICT_INIT
	FUDICT_INIT
	FEXCPT_INIT
	;FCORE_INIT
	;FDOUBLE_INIT
	;FFLOAT_INIT
	;FTOOLS_INIT
	;FFACIL_INIT
	;FSCI_INIT
#emac
	;Customization option
#ifnmac	FORTH_INIT
#macro	FORTH_INIT, 0
	FORTH_DEFAULT_INIT
#emac
#endif	

;#Abort action (to be executed in addition of quit action)
#macro	FORTH_DEFAULT_ABORT, 0
	FRS_ABORT
	FINNER_ABORT
	FIRQ_ABORT
	FPS_ABORT
	FIO_ABORT
	FOUTER_ABORT
	FCDICT_ABORT
	FNVDICT_ABORT
	FUDICT_ABORT
	FEXCPT_ABORT
	;FCORE_ABORT
	;FDOUBLE_ABORT
	;FFLOAT_ABORT
	;FTOOLS_ABORT
	;FFACIL_ABORT
	;FSCI_ABORT
#emac
	;Customization option
#ifnmac	FORTH_ABORT
#macro	FORTH_ABORT, 0
	FORTH_DEFAULT_ABORT
#emac
#endif	
	
;#Quit action
#macro	FORTH_DEFAULT_QUIT, 0
	FRS_QUIT
	FINNER_QUIT
	FIRQ_QUIT
	FPS_QUIT
	FIO_QUIT
	FOUTER_QUIT
	FCDICT_QUIT
	FNVDICT_QUIT
	FUDICT_QUIT
	FEXCPT_QUIT
	;FCORE_QUIT
	;FDOUBLE_QUIT
	;FFLOAT_QUIT
	;FTOOLS_QUIT
	;FFACIL_QUIT
	;FSCI_QUIT
#emac
	;Customization option
#ifnmac	FORTH_QUIT
#macro	FORTH_QUIT, 0
	FORTH_DEFAULT_QUIT
#emac
#endif	
	
;#Suspend action
#macro	FORTH_DEFAULT_SUSPEND, 0
	FRS_SUSPEND
	FINNER_SUSPEND
	FIRQ_SUSPEND
	FPS_SUSPEND
	FIO_SUSPEND
	FOUTER_SUSPEND
	FCDICT_SUSPEND
	FNVDICT_SUSPEND
	FUDICT_SUSPEND
	FEXCPT_SUSPEND
	;FCORE_SUSPEND
	;FDOUBLE_SUSPEND
	;FFLOAT_SUSPEND
	;FTOOLS_SUSPEND
	;FFACIL_SUSPEND
	;FSCI_SUSPEND
#emac
	;Customization option
#ifnmac	FORTH_SUSPEND
#macro	FORTH_SUSPEND, 0
	FORTH_DEFAULT_SUSPEND
#emac
#endif	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FORTH_CODE_START_LIN
			ORG 	FORTH_CODE_START, FORTH_CODE_START_LIN
#else
			ORG 	FORTH_CODE_START
#endif	

FRS_CODE_START		EQU	*
FRS_CODE_START_LIN	EQU	@
			ORG	FRS_CODE_END, FRS_CODE_END_LIN

FINNER_CODE_START	EQU	*
FINNER_CODE_START_LIN	EQU	@
			ORG	FINNER_CODE_END, FINNER_CODE_END_LIN

FIRQ_CODE_START		EQU	*
FIRQ_CODE_START_LIN	EQU	@
			ORG	FIRQ_CODE_END, FIRQ_CODE_END_LIN

FPS_CODE_START		EQU	*
FPS_CODE_START_LIN	EQU	@
			ORG	FPS_CODE_END, FPS_CODE_END_LIN

FIO_CODE_START		EQU	*
FIO_CODE_START_LIN	EQU	@
			ORG	FIO_CODE_END, FIO_CODE_END_LIN

FOUTER_CODE_START	EQU	*
FOUTER_CODE_START_LIN	EQU	@
			ORG	FOUTER_CODE_END, FOUTER_CODE_END_LIN

FCDICT_CODE_START	EQU	*
FCDICT_CODE_START_LIN	EQU	@
			ORG	FCDICT_CODE_END, FCDICT_CODE_END_LIN

FNVDICT_CODE_START	EQU	*
FNVDICT_CODE_START_LIN	EQU	@
			ORG	FNVDICT_CODE_END, FNVDICT_CODE_END_LIN

FUDICT_CODE_START	EQU	*
FUDICT_CODE_START_LIN	EQU	@
			ORG	FUDICT_CODE_END, FUDICT_CODE_END_LIN

FEXCPT_CODE_START	EQU	*
FEXCPT_CODE_START_LIN	EQU	@
			ORG	FEXCPT_CODE_END, FEXCPT_CODE_END_LIN

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

;#Welcome message
#ifndef	WELCOME_MESSAGE
WELCOME_MESSAGE		FCC	"Hello, this is S12CForth!"
			STRING_NL_TERM
#endif

FRS_TABS_START		EQU	*
FRS_TABS_START_LIN	EQU	@
			ORG	FRS_TABS_END, FRS_TABS_END_LIN

FINNER_TABS_START	EQU	*
FINNER_TABS_START_LIN	EQU	@
			ORG	FINNER_TABS_END, FINNER_TABS_END_LIN

FIRQ_TABS_START		EQU	*
FIRQ_TABS_START_LIN	EQU	@
			ORG	FIRQ_TABS_END, FIRQ_TABS_END_LIN

FPS_TABS_START		EQU	*
FPS_TABS_START_LIN	EQU	@
			ORG	FPS_TABS_END, FPS_TABS_END_LIN

FIO_TABS_START		EQU	*
FIO_TABS_START_LIN	EQU	@
			ORG	FIO_TABS_END, FIO_TABS_END_LIN

FOUTER_TABS_START	EQU	*
FOUTER_TABS_START_LIN	EQU	@
			ORG	FOUTER_TABS_END, FOUTER_TABS_END_LIN

FCDICT_TABS_START	EQU	*
FCDICT_TABS_START_LIN	EQU	@
			ORG	FCDICT_TABS_END, FCDICT_TABS_END_LIN

FNVDICT_TABS_START	EQU	*
FNVDICT_TABS_START_LIN	EQU	@
			ORG	FNVDICT_TABS_END, FNVDICT_TABS_END_LIN

FUDICT_TABS_START	EQU	*
FUDICT_TABS_START_LIN	EQU	@
			ORG	FUDICT_TABS_END, FUDICT_TABS_END_LIN

FEXCPT_TABS_START	EQU	*
FEXCPT_TABS_START_LIN	EQU	@
			ORG	FEXCPT_TABS_END, FEXCPT_TABS_END_LIN

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
;# Forth words                                                                 #
;###############################################################################
#ifdef FORTH_WORDS_START_LIN
			ORG 	FORTH_WORDS_START, FORTH_WORDS_START_LIN
#else
			ORG 	FORTH_WORDS_START
#endif	
			ALIGN	1, $FF
	
FRS_WORDS_START		EQU	*
FRS_WORDS_START_LIN	EQU	@
			ORG	FRS_WORDS_END, FRS_WORDS_END_LIN

FINNER_WORDS_START	EQU	*
FINNER_WORDS_START_LIN	EQU	@
			ORG	FINNER_WORDS_END, FINNER_WORDS_END_LIN

FIRQ_WORDS_START		EQU	*
FIRQ_WORDS_START_LIN	EQU	@
			ORG	FIRQ_WORDS_END, FIRQ_WORDS_END_LIN

FPS_WORDS_START		EQU	*
FPS_WORDS_START_LIN	EQU	@
			ORG	FPS_WORDS_END, FPS_WORDS_END_LIN

FIO_WORDS_START		EQU	*
FIO_WORDS_START_LIN	EQU	@
			ORG	FIO_WORDS_END, FIO_WORDS_END_LIN

FOUTER_WORDS_START	EQU	*
FOUTER_WORDS_START_LIN	EQU	@
			ORG	FOUTER_WORDS_END, FOUTER_WORDS_END_LIN

FCDICT_WORDS_START	EQU	*
FCDICT_WORDS_START_LIN	EQU	@
			ORG	FCDICT_WORDS_END, FCDICT_WORDS_END_LIN

FNVDICT_WORDS_START	EQU	*
FNVDICT_WORDS_START_LIN	EQU	@
			ORG	FNVDICT_WORDS_END, FNVDICT_WORDS_END_LIN

FUDICT_WORDS_START	EQU	*
FUDICT_WORDS_START_LIN	EQU	@
			ORG	FUDICT_WORDS_END, FUDICT_WORDS_END_LIN

FEXCPT_WORDS_START	EQU	*
FEXCPT_WORDS_START_LIN	EQU	@
			ORG	FEXCPT_WORDS_END, FEXCPT_WORDS_END_LIN

;FCORE_WORDS_START	EQU	*
;FCORE_WORDS_START_LIN	EQU	@
;			ORG	FCORE_WORDS_END, FCORE_WORDS_END_LIN
;
;FDOUBLE_WORDS_START	EQU	*
;FDOUBLE_WORDS_START_LIN	EQU	@
;			ORG	FDOUBLE_WORDS_END, FDOUBLE_WORDS_END_LIN
;
;FFLOAT_WORDS_START	EQU	*
;FFLOAT_WORDS_START_LIN	EQU	@
;			ORG	FFLOAT_WORDS_END, FFLOAT_WORDS_END_LIN
;
;FTOOLS_WORDS_START	EQU	*
;FTOOLS_WORDS_START_LIN	EQU	@
;			ORG	FTOOLS_WORDS_END, FTOOLS_WORDS_END_LIN
;
;FFACIL_WORDS_START	EQU	*
;FFACIL_WORDS_START_LIN	EQU	@
;			ORG	FFACIL_WORDS_END, FFACIL_WORDS_END_LIN
;
;FSCI_WORDS_START	EQU	*
;FSCI_WORDS_START_LIN	EQU	@
;			ORG	FSCI_WORDS_END, FSCI_WORDS_END_LIN

FORTH_WORDS_END		EQU	*	
FORTH_WORDS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../All/frs.s						;return stack
#include ../All/fps.s						;parameter stack 
#include ../All/fio.s						;communication interface 
#include ../All/fexcpt.s					;exceptions
#include ../All/finner.s					;inner interpreter
#include ../All/fouter.s					;outer interpreter
#include ../All/firq.s						;interrupt requests
#include ../All/fcdict.s					;core dictionary
#include ../All/fcdict_tree.s					;core dictionary search tree
#include ../All/fnvdict.s					;non-volatile dictionary
#include ../All/fudict.s					;user dictionary
;#include ../All/fcore.s					;core words
;#include ../All/fdouble.s					;double-number words
;#include ../All/ffloat.s					;floating point words
;#include ../All/ftools.s					;programming tools words
;#include ../All/ffacil.s					;facility words
;#include ../All/fsci.s						;S12CBase SCI wrapper
#endif
	
