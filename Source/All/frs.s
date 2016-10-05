#ifndef FRS_COMPILED
#define FRS_COMPILED
;###############################################################################
;# S12CForth- FRS - Return Stack                                               #
;###############################################################################
;#    Copyright 2011-2016 Dirk Heisswolf                                       #
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
;#    This module is a container for all return stack related code.            #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      PSP (parameter stack pointer) = Y                                      #
;#      RSP (return stack pointer)    = SP                                     #
;#  									       #
;#    Program termination options:                                             #
;#      ABORT:                                                                 #
;#      QUIT:                                                                  #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;#    September 30, 2016                                                       #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE    - S12CBase framework                                             #
;#    FTIB    - Forth text input buffer                                        #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;         
;                         +----------+----------+        
;        RS_TIB_START, -> |          |          | |
;           TIB_START     |  Text Input Buffer  | | [NUMBER_TIB]
;                         |          |          | |	       
;                         |          v          | <	       
;                     -+- | --- --- --- --- --- | 	       
;             TIB_PADDING .                     . <- TIB_START+[NUMBER_TIB] 
;                     -+- .                     .            
;                         | --- --- --- --- --- |            
;                         |          ^          | <- [RSP]
;                         |          |          |
;                         |    Return Stack     |
;                         |          |          |
;                         +----------+----------+
;             RS_EMPTY, ->                                 
;           RS_TIB_END
;
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Bottom of return stack
RS_EMPTY		EQU	RS_TIB_END

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FRS_VARS_START_LIN
			ORG 	FRS_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FRS_VARS_START
FRS_VARS_START_LIN	EQU	@
#endif	

FRS_VARS_END		EQU	*
FRS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FRS_INIT, 0
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FRS_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FRS_QUIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FRS_CODE_START_LIN
			ORG 	FRS_CODE_START, FRS_CODE_START_LIN
#else
			ORG 	FRS_CODE_START
FRS_CODE_START_LIN	EQU	@
#endif
	
FRS_CODE_END		EQU	*
FRS_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FRS_TABS_START_LIN
			ORG 	FRS_TABS_START, FRS_TABS_START_LIN
#else
			ORG 	FRS_TABS_START
FRS_TABS_START_LIN	EQU	@
#endif	

FRS_TABS_END		EQU	*
FRS_TABS_END_LIN	EQU	@

