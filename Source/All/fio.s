;###############################################################################
;# S12CForth - FIO - I/O Handler for the S12CForth Framework                   #
;###############################################################################
;#    Copyright 2011 Dirk Heisswolf                                            #
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
;#    This module provides a method for assemler level drivers to translate    #
;#    hardware interrupts into interrupts of the Forth program flow.           #
;#                                                                             #
;#    Whenever a driver wants to propagate an interrupt to the Forth system,   #
;#    it puts the xt of the associated ISR Forth word into a FIFI. This is     #
;#    accomplished by calling the FIO_IRQ subroutine.                          #
;#                                                                             #
;#    The S12CForth inner interpreter and the blocking I/O words are checking  #
;#    the content of the FIFO on a regular basis (primary non-blocking         #
;#    S12CForth words are not interrupted). If xt's have been queued, then the #
;#    context of the current program flow is pushed onto the return stack and  #
;#    all queued ISR xt's are executed. ISR words are not interruptable.       #
;#                                                                             #
;#    After all queued ISR xt's have been executed, the previous execution     #
;#    context is pulled from the return stack and the program flow is resumed. #
;#                                                                             #
;#    The inner interpreter uses these registers:                              #
;#         W = Working register. 					       #
;#             The W register points to the CFA of the current word, but it    #
;#             may be overwritten.	   			               #
;#             Used for indexed addressing and arithmetics.		       #
;#	       Index Register X is used to implement W.                        #
;#        IP = Instruction pointer.					       #
;#             Points to the next execution token.			       #
;#  IRQ_STAT = IRQ status register.					       #
;#             The inner interpreter only uses bits 1 and 0. The remaining     #
;#  	       may be used by the interrupt handler.                           #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 3, 2011                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FCORE - Forth core words                                                 #
;#    FMEM - Forth memories                                                    #
;#    FEXCPT - Forth exceptions                                                #
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
			ORG	FIO_VARS_START
FIO_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FIO_INIT, 0
#emac

;FINNER_JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:   IP:  pointer to the new execution token
; result: IP:  subsequentexecution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
#macro	




	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FIO_CODE_START_LIN
			ORG 	FIO_CODE_START, FIO_CODE_START_LIN
#else
			ORG 	FIO_CODE_START
FIO_CODE_START_LIN	EQU	@
#endif







	



FIO_CODE_END		EQU	*
FIO_CODE_END_LIN	EQU	@

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FIO_CODE_START_LIN
			ORG 	FIO_CODE_START, FIO_CODE_START_LIN
#else
			ORG 	FIO_CODE_START
FIO_CODE_START_LIN	EQU	@
#endif





FIO_CODE_END		EQU	*
FIO_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FIO_TABS_START_LIN
			ORG 	FIO_TABS_START, FIO_TABS_START_LIN
#else
			ORG 	FIO_TABS_START
FIO_TABS_START_LIN	EQU	@
#endif	

FIO_TABS_END		EQU	*
FIO_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FIO_WORDS_START_LIN
			ORG 	FIO_WORDS_START, FIO_WORDS_START_LIN
#else
			ORG 	FIO_WORDS_START
FIO_WORDS_START_LIN	EQU	@
#endif	

FIO_WORDS_END		EQU	*
FIO_WORDS_END_LIN	EQU	@
