#ifndef FENV
#define FENV
;###############################################################################
;# S12CForth- FENV - Core Dictionary                                         #
;###############################################################################
;#    Copyright 2009-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12C MCU          #
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
;#    This module implements the core dictionary of the S12CForth environment. #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    S12CForth system variables:                                              #
;#           BASE = Default radix (2<=BASE<=16)                                #
;#          STATE = State of the outer interpreter:                            #
;#  		        0: Interpretation State				       #
;#  		       -1: RAM Compile State				       #
;#  		       +1: NV Compile State				       #
;#     NUMBER_TIB = Number of chars in the TIB                                 #
;#          TO_IN = In-pointer of the TIB (>IN)	       			       #
;#       	    (TIB_START+TO_IN) points to the next character	       #
;#  									       #
;#    Program termination options:                                             #
;#        ABORT:                                                               #
;#        QUIT:                                                                #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;#    October 6, 2016                                                          #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;
; CDICT iterator structure:
;
;                           +--------+--------+     
;                       +-> |   Node Pointer  | <- start of path
;                       |   +--------+--------+   |p
;                       |   |   Node Pointer  |   |a   
;                       |   +--------+--------+   |t 
;                       |   :                 :   |h
;          2+           |   +--------+--------+   V
; (2*FENV_TREE_DEPTH) |   |   Node Pointer  | <- end of path
;                       |   +--------+--------+ 
;                       |   |      NULL       | 
;                       |   +--------+--------+ 
;                       |   :                 : 
;                       |   +--------+--------+ 
;                       +-> |      NULL       | <- always NULL
;                           +--------+--------+     
;
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;STRING configuration 
STRING_ENABLE_UPPER	EQU	1
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#String termination 
FENV_STR_TERM		EQU	STRING_TERM

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FENV_VARS_START_LIN
			ORG 	FENV_VARS_START, FENV_VARS_START_LIN
#else
			ORG 	FENV_VARS_START
FENV_VARS_START_LIN	EQU	@
#endif
	
FENV_VARS_END		EQU	*
FENV_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FENV_INIT, 0
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FENV_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FENV_QUIT, 0
#emac
	
;#System integrity monitor
;=========================
#macro	FENV_MON, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FENV_CODE_START_LIN
			ORG 	FENV_CODE_START, FENV_CODE_START_LIN
#else
			ORG 	FENV_CODE_START
FENV_CODE_START_LIN	EQU	@
#endif

;#Directory operations
;=====================
;#Look up a word in a sirectory tree
; args:   X:      root of directory tree
;         Y:      PSP
;         0,Y:    char count 
;         2,Y:    string pointer 
; result: C-flag: set on success   
;         X:      result (cleard on failure)
; SSTACK: 6 bytes
;         Y is preserved
FENV_LU			EQU	FCDICT_LU

;#Handlers
;==========
;#Return TRUE
; args:   none 
; result: none
; SSTACK: 2 bytes
;         Y is preserved
FENV_TRUE		EQU	FENV_DOUBLE_2

;#Return single cell
; args:   X: data pointer
; result: none
; SSTACK: 2 bytes
;         Y is preserved
FENV_SINGLE		EQU	FENV_DOUBLE_1				;return cell

;#Return double cell
; args:   X: data pointer
; result: none
; SSTACK: 2 bytes
;         Y is preserved
FENV_DOUBLE		EQU	*
			MOVW	2,X+, 2,-Y 				;return first cell
FENV_DOUBLE_1		MOVW	2,X+, 2,-Y 				;return second cell
FENV_DOUBLE_2		MOVW	#TRUE, 2,-Y 				;return TRUE
			RTS						;done
;#########
;# Words #
;#########

;ENVIRONMENT? ( c-addr u -- false | i*x true )
;c-addr is the address of a character string and u is the string's character
;count. u may have a value in the range from zero to an implementation-defined
;maximum which shall not be less than 31. The character string should contain a
;keyword from 3.2.6 Environmental queries or the optional word sets to be
;checked for correspondence with an attribute of the present environment. If the
;system treats the attribute as unknown, the returned flag is false; otherwise,
;the flag is true and the i*x returned is of the type specified in the table for
;the attribute queried.
IF_ENVIRONMENT_QUERY	REGULAR
CF_ENVIRONMENT_QUERY	EQU	*
			;Look up word 
			LDX	#FENV_TREE				;tree pointer -> X
			JOBSR	FENV_LU 				;look up word
			BCC	CF_ENVIRONMENT_QUERY_1 			;failure
			;Success (handler code in X) 
			LEAY	4,Y 					;clean up PS
			JMP	2,X+	 				;run handler
			;Failure (FALSE in X) 
CF_ENVIRONMENT_QUERY_1	STX	2,+Y 					;store result
			RTS						;done

FENV_CODE_END		EQU	*
FENV_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FENV_TABS_START_LIN
			ORG 	FENV_TABS_START, FENV_TABS_START_LIN
#else
			ORG 	FENV_TABS_START
FENV_TABS_START_LIN	EQU	@
#endif	
			
FENV_TREE_START		EQU	*	
FENV_TREE		FENV_TREE
FENV_TREE_END		EQU	*	
	
FENV_TABS_END		EQU	*
FENV_TABS_END_LIN	EQU	@
