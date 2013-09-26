;###############################################################################
;# S12CForth- FRS - Return Stack for the Forth VM                              #
;###############################################################################
;#    Copyright 2010 - 2013 Dirk Heisswolf                                     #
;#    This file is part of the S12CForth frsework for Freescale's S12C MCU     #
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
;#    This module implements the return stack.                                 #
;#                                                                             #
;#    The return stack uses these registers:                                   #
;#            RSP = Return stack pointer.				       #
;#	            Points to the top of the return stack.                     #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    FEXCPT - Forth Exception Handler                                         #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;         
;                           +--------------+--------------+        
;          RS_TIB_START, -> |              |              | |          
;             TIB_START     |       Text Input Buffer     | | [TIB_CNT]
;                           |              |              | |	       
;                           |              v              | <	       
;                       -+- | --- --- --- --- --- --- --- | 	       
;            TIB_PADDING |  .                             . <- [TIB_START+TIB_CNT] 
;                       -+- .                             .            
;                           | --- --- --- --- --- --- --- |            
;                           |              ^              | <- [RSP]
;                           |              |              |
;                           |        Return Stack         |
;                           |              |              |
;                           +--------------+--------------+
;             RS_EMPTY, ->                                 
;           RS_TIB_END
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Debug option for stack over/underflows
;FRS_DEBUG		EQU	1
	
;Disable stack range checks
;FRS_NO_CHECK	EQU	1 

;Boundaries
;RS_TIB_START		EQU	0
;RS_TIB_END		EQU	0
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Bottom of return stack
RS_EMPTY		EQU	RS_TIB_END

;Error codes
#ifndef	FRS_NO_CHECK
FRS_EC_OF		EQU	FEXCPT_EC_RSOF		;RS overflow   (-5)
FRS_EC_UF		EQU	FEXCPT_EC_RSUF		;RS underflow  (-6)
#endif

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FRS_VARS_START_LIN
			ORG 	FRS_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FRS_VARS_START
FRS_VARS_START_LIN	EQU	@
#endif	

RSP			DS	2 	;return stack pointer (top of stack)

FRS_VARS_END		EQU	*
FRS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FRS_INIT, 0
			;Initialize return stack
			MOVW	#RS_EMPTY,	RSP		
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FRS_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FRS_QUIT, 0
			;Reset return stack
			MOVW	#RS_EMPTY,	RSP		
#emac
	
;#Suspend action
#macro	FRS_SUSPEND, 0
#emac
		
	
;#Return stack
;RS_RESET: reset the parameter stack
; args:   none
; result: none
; SSTACK: none
;        X, Y and D are preserved 
#macro	RS_RESET, 0
			MOVW	#RS_EMPTY,	RSP	
#emac

;RS_CHECK_UF: check for a minimum number of stack entries (RSP -> X)
; args:   1: required stack content (cells)
; result: X: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSUF
;        Y and D are preserved 
#macro	RS_CHECK_UF, 1
			LDX	RSP 			;=> 3 cycles
#ifndef	FRS_NO_CHECK
			CPX	#(RS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	FRS_THROW_RSUF		;=> 3 cycles/ 4 cycles
							;  -------------------
							;   8 cycles/ 9 cycles
#endif
#emac

;RS_CHECK_OF: check if there is room for a number of stack entries (X modified)
; args:   1: required stack space (cells)
; result: none
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        Y and D are preserved 
#macro	RS_CHECK_OF, 1
#ifndef	FRS_NO_CHECK
			LDX	NUMBER_TIB		;=> 3 cycles
			LEAX	(TIB_START+(2*\1)),X	;=> 2 cycles
			CPX	RSP			;=> 3 cycles
			BHI	FRS_THROW_RSOF		;=> 3 cycles/ 4 cycles
							;  -------------------
							;  11 cycles/12 cycles
#endif
#emac
	
;RS_CHECK_OF_KEEP_X: check if there is room for a number of stack entries (Y modified)
; args:   1: required stack space (cells)
; result: none
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        X and D are preserved 
#macro	RS_CHECK_OF_KEEP_X, 1
#ifndef	FRS_NO_CHECK
			LDY	NUMBER_TIB		;=> 3 cycles
			LEAY	(TIB_START+(2*\1)),Y	;=> 2 cycles
			CPY	RSP			;=> 3 cycles
			BHI	FRS_THROW_RSOF		;=> 3 cycles/ 4 cycles
							;  -------------------
							;  11 cycles/12 cycles
#endif
#emac
	
;RS_PULL: pull one entry from the return stack  (RSP -> X)
; args:   1: address of variable to pull data into
; result: X: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSUF
;        Y and D are preserved 
#macro	RS_PULL, 1
			RS_CHECK_UF	1		;check for underflow	=> 8 cycles
			MOVW		2,X+, \1	;RS -> X		=> 3 cycles 
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         14 cycles
#emac	
	
;RS_PULL_Y: pull one entry from the return stack into index Y
; args:   none
; result: X: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSUF
;        Y and D are preserved 
#macro	RS_PULL_Y, 0	;1:underflow handler  
			RS_CHECK_UF	1		;check for underflow	=> 8 cycles
			LDY		2,X+		;RS -> X		=> 3 cycles 
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         14 cycles
#emac	
	
;RS_PUSH: push a variable onto the return stack (RSP -> X)
; args:   1: address of variable to push data from
; result: X: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        Y and D are preserved
#macro	RS_PUSH, 1	;1:variable
			RS_CHECK_OF	1		;check for overflow	=>11 cycles
			LDX		RSP		;var -> RS		=> 3 cycles
			MOVW		\1, 2,-X	;			=> 5 cycles
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         22 cycles
#emac	

;RS_PUSH: push a variable onto the return stack and don't touch index X
; args:   1: variable
; result: Y: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        X and D are preserved
#macro	RS_PUSH_KEEP_X, 1	;1:variable
#ifndef	FRS_NO_CHECK
			LDY	NUMBER_TIB		;=> 3 cycles
			LEAY	(TIB_START+2),Y		;=> 2 cycles
			CPY	RSP			;=> 3 cycles
			BHI	FRS_THROW_RSOF		;=> 3 cycle / 4 cycles
#endif
			LDY	RSP			;=> 3 cycles
			MOVW	\1, 2,-Y		;=> 5 cycles
			STY	RSP			;=> 3 cycles
							;  ---------
							;  22 cycles
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

			;JOB	FRS_PAD_ALLOC_2	;done

;Exceptions:
;===========
;Standard exceptions
#ifndef FRS_NO_CHECK
#ifdef FRS_DEBUG
FRS_THROW_PSOF		BGND					;return stack overflow
FRS_THROW_PSUF		BGND					;return stack underflow
#else
FRS_THROW_PSOF		FEXCPT_THROW	FEXCPT_EC_RSOF		;return stack overflow
FRS_THROW_PSUF		FEXCPT_THROW	FEXCPT_EC_RSUF		;return stack underflow
#endif
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

