;###############################################################################
;# S12CForth - FRS - Return Stack                                              #
;###############################################################################
;#    Copyright 2010-2013 Dirk Heisswolf                                       #
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
;#    This module implements the return stack of the S12CForth virtual         #
;#    machine.                                                                 #
;#                                                                             #
;#    The return stack uses this register:                                     #
;#       RSP = Return stack pointer					       #
;#  	       The RSP points th the most recent stack entry. It points to     #
;#  	       FRS_BOTTOM if the stack is empty. 			       #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    January 25, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    - none                                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Stack layout                                                               #
;###############################################################################
;	
;	
;                           |                             | 	       
;          soft boundary->  | --- --- --- --- --- --- --- | 	       
;                           .                             . <- [FRS_MAX_PTR]	       
;                           .                             .            
;                           | --- --- --- --- --- --- --- |            
;                           |              ^              | <- RSP
;                           |              |              |
;                           |        Return Stack         |
;                           |              |              |
;          hard boundary->  +--------------+--------------+
;            FRS_BOTTOM ->                                                                   

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Hard boundary (bottom)
;FRS_BOTTOM		EQU	FMEM_VARS_END 

;Soft boundary (top)
;FRS_MAX_PTR		EQU	FMEM_VARS_END 
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FRS_VARS_START_LIN
			ORG 	FRS_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FRS_VARS_START
FRS_VARS_START_LIN	EQU	@
#endif	

RSP			DS	2 			;return stack pointer
	
FRS_VARS_END		EQU	*
FRS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FRS_INIT, 0
			MOVW	#FRS_BOTTOM,	RSP 	;initialize stack pointer
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

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FRS_WORDS_START_LIN
			ORG 	FRS_WORDS_START, FRS_WORDS_START_LIN
#else
			ORG 	FRS_WORDS_START
FRS_WORDS_START_LIN	EQU	@
#endif	

FRS_WORDS_END		EQU	*
FRS_WORDS_END_LIN	EQU	@


