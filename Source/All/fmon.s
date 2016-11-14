#ifndef FMON
#define FMON
;###############################################################################
;# S12CForth - FMON - System Integrity Monitor                                 #
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
;#    This module implements the exception handling of the S12CForth virtual   #
;#    machine. The following Forth variables belong to this module:            #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    The following notation is used to describe the stack layout in the word  #
;#    definitions:                                                             #
;#                                                                             #
;#    Symbol          Data type                       Size on stack	       #
;#    ------          ---------                       -------------	       #
;#    flag            flag                            1 cell		       #
;#    true            true flag                       1 cell		       #
;#    false           false flag                      1 cell		       #
;#    char            character                       1 cell		       #
;#    n               signed number                   1 cell		       #
;#    +n              non-negative number             1 cell		       #
;#    u               unsigned number                 1 cell		       #
;#    n|u 1           number                          1 cell		       #
;#    x               unspecified cell                1 cell		       #
;#    xt              execution token                 1 cell		       #
;#    addr            address                         1 cell		       #
;#    a-addr          aligned address                 1 cell		       #
;#    c-addr          character-aligned address       1 cell		       #
;#    d-addr          double address                  2 cells (non-standard)   #
;#    d               double-cell signed number       2 cells		       #
;#    +d              double-cell non-negative number 2 cells		       #
;#    ud              double-cell unsigned number     2 cells		       #
;#    d|ud 2          double-cell number              2 cells		       #
;#    xd              unspecified cell pair           2 cells		       #
;#    colon-sys       definition compilation          implementation dependent #
;#    do-sys          do-loop structures              implementation dependent #
;#    case-sys        CASE structures                 implementation dependent #
;#    of-sys          OF structures                   implementation dependent #
;#    orig            control-flow origins            implementation dependent #
;#    dest            control-flow destinations       implementation dependent #
;#    loop-sys        loop-control parameters         implementation dependent #
;#    nest-sys        definition calls                implementation dependent #
;#    i*x, j*x, k*x 3 any data type                   0 or more cells	       #
;#  									       #
;#    Counted strings are implemented as terminated strings. String            #
;#    termination is done by setting bit 7 in the last character of the        #   
;#    string. Pointers to empty strings have the value $0000.		       #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    October 20, 2016                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FMON_VARS_START_LIN
			ORG 	FMON_VARS_START, FMON_VARS_START_LIN
#else				
			ORG 	FMON_VARS_START
FMON_VARS_START_LIN	EQU	@
#endif				
				
FMON_VARS_END		EQU	*
FMON_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FMON_INIT, 0
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FMON_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FMON_QUIT, 0
#emac

;#System integrity monitor
;=========================
#macro	FMON_MON, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FMON_CODE_START_LIN
			ORG 	FMON_CODE_START, FMON_CODE_START_LIN
#else
			ORG 	FMON_CODE_START
FMON_CODE_START_LIN	EQU	@
#endif
	
;#########
;# Words #
;#########
	
;Word: MONITOR ( -- )
;Run system integrity checks. Throw exceptions if necessary.
IF_MONITOR		REGULAR
CF_MONITOR		EQU	*
			FORTH_MON
			RTS
	
FMON_CODE_END		EQU	*
FMON_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
;Tabes in unpaged address space
;------------------------------ 
#ifdef FMON_TABS_START_LIN
			ORG 	FMON_TABS_START, FMON_TABS_START_LIN
#else
			ORG 	FMON_TABS_START
FMON_TABS_START_LIN	EQU	@
#endif

FMON_TABS_END		EQU	*
FMON_TABS_END_LIN	EQU	@

#endif
	
	
