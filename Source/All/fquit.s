;###############################################################################
;# S12CForth - FQUIT - Text interpreter                                        #
;###############################################################################
;#    Copyright 2011-2013 Dirk Heisswolf                                       #
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
;#    This module provides a method for assembler level drivers to translate   #
;#    hardware interrupts into interrupts of the Forth program flow.           #
;#                                                                             #
;#    Whenever a driver wants to propagate an interrupt to the Forth system,   #
;#    it puts the xt of the associated ISR Forth word into a FIFI. This is     #
;#    accomplished by calling the FIRQ_IRQ subroutine.                         #
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
;#    The IRQ handler uses these registers:                                    #
;#     	ISTAT = Tell swhich interrupt levels ate currently blocked             #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 5, 2013                                                         #
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
#ifdef FQUIT_VARS_START_LIN
			ORG 	FQUIT_VARS_START, FQUIT_VARS_START_LIN
#else
			ORG 	FQUIT_VARS_START
FQUIT_VARS_START_LIN	EQU	@
#endif	

FQUIT_VARS_END		EQU	*
FQUIT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FQUIT_INIT, 0
#emac

;#Quit action
#macro	FQUIT_QUIT, 0
			FRAM_QUIT


	
#emac

;#Abort action (also in case of break or error)
#macro	FQUIT_ABORT, 0



	
#emac
	
	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FQUIT_CODE_START_LIN
			ORG 	FQUIT_CODE_START, FQUIT_CODE_START_LIN
#else
			ORG 	FQUIT_CODE_START
FQUIT_CODE_START_LIN	EQU	@
#endif


;#Get command line input and store it into any buffer
; args:   D: buffer size
;         X: buffer pointer
; result: D: character count	
;         X: error code (0 if everything goes well)	
; SSTACK: ?? bytes
;         Y is preserved
FQUIT_ACCEPT		EQU	*
			;Save registers
			SSTACK_PSHYXD
			;Stack layout
			;+--------+--------+
			;| char limit (D)  | <-SP
			;+--------+--------+
			;| buffer ptr (X)  |  +2
			;+--------+--------+
			;|        Y        |  +4
			;+--------+--------+
			;| Return address  |  +6
			;+--------+--------+
FQUIT_ACCEPT_CHAR_LIMIT	EQU	0
FQUIT_ACCEPT_BUF_PTR	EQU	2	
			;Signal input request
			FIO_BUSY_OFF

















	
CF_QUIT_XS		EQU	*
			FQUIT_QUIT
			FIO_PRINT FIO_NL
			FIO_PRINT FQUIT_INTERPRET_PROMPT





CF_SUSPPEND_XS		EQU	*	
			FIO_PRINT FIO_NL
			FIO_PRINT FQUIT_SUSPEND_PROMPT




	
FQUIT_CODE_END		EQU	*
FQUIT_CODE_END_LIN	EQU	@

	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FQUIT_TABS_START_LIN
			ORG 	FQUIT_TABS_START, FQUIT_TABS_START_LIN
#else
			ORG 	FQUIT_TABS_START
FQUIT_TABS_START_LIN	EQU	@
#endif	

;System prompts
FQUIT_SUSPEND_PROMPT	FCS	"S> "
FQUIT_INTERPRET_PROMPT	FCS	"> "
FQUIT_COMPILE_PROMPT	FCS	"+ "
FQUIT_SKIP_PROMPT	FCS	"0 "
FQUIT_SYSTEM_PROMPT	FCS	" ok"


FQUIT_TABS_END		EQU	*
FQUIT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FQUIT_WORDS_START_LIN
			ORG 	FQUIT_WORDS_START, FQUIT_WORDS_START_LIN
#else
			ORG 	FQUIT_WORDS_START
FQUIT_WORDS_START_LIN	EQU	@
#endif	





FQUIT_WORDS_END		EQU	*
FQUIT_WORDS_END_LIN	EQU	@
