;###############################################################################
;# S12CForth- FCDICT - Core Dictionary of the S12CForth Framework              #
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
;#    This module implements the core dictionary.                              #
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
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FCDICT_VARS_START_LIN
			ORG 	FCDICT_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FCDICT_VARS_START
FCDICT_VARS_START_LIN	EQU	@
#endif
	
FCDICT_VARS_END		EQU	*
FCDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FCDICT_INIT, 0
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FCDICT_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FCDICT_QUIT, 0
#emac
	
;#Suspend action
#macro	FCDICT_SUSPEND, 0
#emac

;Functions:
;==========
;Compare substring
; args:   Y: reference string pointer (MSB terminated)
;         X: string pointer
;         D: character count
; result: C-flag: set on match	
;         Y: points to the byte after the reference string
;         X: points to the byte after the matched substring (unchanged on mismatch)
;         D: remaining character count (unchanged on mismatch)
; SSTACK: 8 bytes
;         No registers are preserved 
#macro	FCDICT_COMP_SUBSTR, 0
			SSTACK_JOBSR	FCDICT_COMP_SUBSTR, 8
#emac
	
;Search word in dictionary
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16 bytes
;         Y and D are preserved 
#macro	FCDICT_SEARCH, 0
			SSTACK_JOBSR	FCDICT_SEARCH, 16
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FCDICT_CODE_START_LIN
			ORG 	FCDICT_CODE_START, FCDICT_CODE_START_LIN
#else
			ORG 	FCDICT_CODE_START
FCDICT_CODE_START_LIN	EQU	@
#endif

;Compare substring
; args:   Y: reference string pointer (MSB terminated)
;         X: string pointer
;         D: character count
; result: C-flag: set on match	
;         Y: points to the byte after the reference string
;         X: points to the byte after the matched substring (unchanged on mismatch)
;         D: remaining character count (unchanged on mismatch)
; SSTACK: 8 bytes
;         No registers are preserved 
FCDICT_COMP_SUBSTR	EQU	*
			;Save registers (ref ptr in Y, str ptr in X, char count in D)
			PSHX						;save X	
			PSHD						;save D				
			PSHD						;remainig char count			
			;Check char count (ref ptr in Y, str ptr in X, char count in D)
			;TBEQ	Y, FCDICT_COMP_SUBSTR_3 		;nothing to compare
			TBEQ	D, FCDICT_COMP_SUBSTR_3 		;nothing to compare
			;Read chars (ref ptr in Y, str ptr in X, char count in D)
FCDICT_COMP_SUBSTR_1	LDAB	1,X+ 					;str char -> B
			ANDB	#$7F		    			;remove termination
			LDAA	1,Y+ 					;ref char -> A
			BMI	FCDICT_COMP_SUBSTR_5			;termination reached
FCDICT_COMP_SUBSTR_2	CBA
			BNE	FCDICT_COMP_SUBSTR_3			;mismatch
			LDD	0,SP			       		;char count -> D
			DBNE	D, FCDICT_COMP_SUBSTR_1 			;check next char
			;String is too short (ref ptr in Y)
FCDICT_COMP_SUBSTR_3	TST	1,Y+ 					;skip past ref termination
			BPL	FCDICT_COMP_SUBSTR_3
			;Mismatch (new ref ptr in Y)
FCDICT_COMP_SUBSTR_4	SSTACK_PREPULL	8 				;restore stack
			PULD						;remove stack entry				
			PULD						;restore D				
			PULX						;restore X				
			CLC						;flag mismatch
			;Done
			RTS
			;Reference string termination reached (ref ptr in Y, str ptr in X, char in B, ref char in A)
FCDICT_COMP_SUBSTR_5	ANDA	#$7F		    			;remove termination
			CBA
			BNE	FCDICT_COMP_SUBSTR_4			;mismatch
			;Match (ref ptr in Y, str ptr in X)
			SSTACK_PREPULL	8 				;restore stack
			PULD						;pull remaining char count
			SUBD	#1 					;adjust char count
			LEAS	4,SP 					;free stack space
			SEC						;flag match
			;Done
			RTS

;Search word in dictionary
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16 bytes
;         Y and D are preserved 
FCDICT_SEARCH		EQU	*
			;Save registers (string pointer in X, char count in D)
			PSHY						;save Y
			PSHX						;save X
			PSHD						;save D	
			;Set dictionary tree pointer (string pointer in X, char count in D)
			LDY	#FCDICT_TREE
			;Compare substring (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_1		FCDICT_COMP_SUBSTR   				;compare substring (SSTACK: 8 bytes)
			BCS	FCDICT_SEARCH_4 			;substring matches
			TST	0,Y					;check for STRING_TERMINATION
			BNE	FCDICT_SEARCH_2 			;no STRING_TERMINATION
			LEAY	1,Y 					;skip STRING_TERMINATION
FCDICT_SEARCH_2		TST	2,+Y 					;check for END_OF_SUBTREE
			BNE	FCDICT_SEARCH_1 			;compare next substring
			;Search unsuccessful
FCDICT_SEARCH_3		SSTACK_PREPULL	8 				;restore stack
			PULX						;restore X				
			PULD						;restore D				
			PULY						;restore Y				
			CLC						;flag unsuccessful search
			;Done
			RTS		
			;Substring matches (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_4		TST	0,Y					;check for STRING_TERMINATION
			BNE	FCDICT_SEARCH_6 			;switch to subtree
			TBNE	D, FCDICT_SEARCH_3			;search unsuccessful
			;Search successful (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_5		LDD	1,+Y 					;IMMEDIATE/CFA -> X
			SSTACK_PREPULL	8 				;restore stack
			PULX						;discards saved D content				
			PULX						;restore X				
			PULY						;restore Y				
			SEC						;flag successful search
			;Done
			RTS		
			;Switch to subtree (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_6		LDY	0,Y					;switch to subtree
			TST	0,Y					;check for STRING_TERMINATION
			BNE	FCDICT_SEARCH_1 			;compare substring
			TBEQ	D, FCDICT_SEARCH_5			;search successful
			JOB	FCDICT_SEARCH_3				;search unsuccessful

;Code fields:
;============
;SEARCH-CDICT ( c-addr u -- 0 | xt 1 | xt -1 ) 
;Find the definition in the core dictionary identified by the string c-addr u in
;the word list identified by wid. If the definition is not found, return zero.
;If thedefinition is found, return its execution token xt and one (1) if the
;definition is immediate, minus-one (-1) otherwise. 
; args:   PSP+0: char count
;         PSP+1: string pointer
; result: PSP+0: CFA
;         PSP+1: COMPILE (1) or IMMEDIATE (-1)
; or
;         PSP+0: false flag
; SSTACK: 16 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSUF
CF_SEARCH_CDICT		EQU	*
			;Check PS
			PS_CHECK_UF	2 		;PSP -> Y
			;Search core directory (PSP in Y)
			LDX	2,Y
			LDD	0,Y
			FCDICT_SEARCH 			;(SSTACK: 16 bytes)
			BCC	CF_SEARCH_CDICT_2	;search unsuccessfull
			;Search sucessfull (PSP in Y, IMMEDIATE/CFA in D)
			LDX	#$0000
			LSLD
			EXG	D,X
			SBCB	#$00
			SBCA	#$00
			STD	0,Y
			STX	2,Y
			;Done
CF_SEARCH_CDICT_1	NEXT
			;Search sucessfull (PSP in Y)
CF_SEARCH_CDICT_2	MOVW	#$0000, 2,+Y
			STY	PSP
			JOB	CF_SEARCH_CDICT_1 	;done
	
FCDICT_CODE_END		EQU	*
FCDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FCDICT_TABS_START_LIN
			ORG 	FCDICT_TABS_START, FCDICT_TABS_START_LIN
#else
			ORG 	FCDICT_TABS_START
FCDICT_TABS_START_LIN	EQU	@
#endif	

;#Dictionary tree
FCDICT_TREE		FCDICT_TREE

FCDICT_TABS_END		EQU	*
FCDICT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FCDICT_WORDS_START_LIN
			ORG 	FCDICT_WORDS_START, FCDICT_WORDS_START_LIN
#else
			ORG 	FCDICT_WORDS_START
FCDICT_WORDS_START_LIN	EQU	@
#endif	

;S12CForth Words:
;================

;Word: SEARCH-CDICT ( c-addr u -- 0 | xt 1 | xt -1 ) 
;Find the definition in the core dictionary identified by the string c-addr u in
;the word list identified by wid. If the definition is not found, return zero.
;If thedefinition is found, return its execution token xt and one (1) if the
;definition is immediate, minus-one (-1) otherwise. 
CFA_SEARCH_CDICT	DW	CF_SEARCH_CDICT
	
FCDICT_WORDS_END		EQU	*
FCDICT_WORDS_END_LIN	EQU	@

