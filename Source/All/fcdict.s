#ifndef FCDICT
#define FCDICT
;###############################################################################
;# S12CForth- FCDICT - Core Dictionary                                         #
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
;                       +-> |   Node pointer  | <- start of path
;                       |   +--------+--------+   |p
;                       |   |   Node pointer  |   |a   
;                       |   +--------+--------+   |t 
;                       |   :                 :   |h
;          2+           |   +--------+--------+   V
; (2*FCDICT_TREE_DEPTH) |   |   Node pointer  | <- end of path
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
;Max. line length
FCDICT_LINE_WIDTH	EQU	DEFAULT_LINE_WIDTH

;NULL pointer
#ifndef NULL
NULL			EQU	$0000
#endif

;#String termination 
FCDICT_STR_TERM		EQU	STRING_TERM

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FCDICT_VARS_START_LIN
			ORG 	FCDICT_VARS_START, FCDICT_VARS_START_LIN
#else
			ORG 	FCDICT_VARS_START
FCDICT_VARS_START_LIN	EQU	@
#endif
	
FCDICT_VARS_END		EQU	*
FCDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FCDICT_INIT, 0
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FCDICT_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FCDICT_QUIT, 0
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

;#IO
;===
;#Print a list separator (SPACE or line break)
; args:   D:      char count of next word
;         0,SP:   line counter 
; result: 0,SP;   updated line counter
; SSTACK: 10 bytes
;         Y is preserved
FCDICT_LIST_SEP		EQU	FOUTER_LIST_SEP
	
;#String operations
;==================
;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character 
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
FCDICT_UPPER		EQU	STRING_UPPER

;#Prints a MSB terminated string
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FCDICT_TX_STRING	EQU	STRING_PRINT_BL

;#########
;# Words #
;#########

;Word: LU-CDICT ( c-addr u -- xt | c-addr u false )
;Look up a name in the CDICT dictionary. The name is referenced by the start
;address c-addr and the character count u. If successful the resulting execution
;token xt is returned. Otherwise the name reference remains on the parameter
;stack along with a false flag.
IF_LU_CDICT		REGULAR
CF_LU_CDICT		EQU	*
			;Prepare search
			LDD	2,Y 					;c-addr -> D
			PSHD						;string pointer -> 2,SP
			ADDD	0,Y 					;calculate EOS
			;SUBD	#1     
			PSHD						;EOS            -> 0,SP
			;Get char of search string  
			LDAB	[2,SP] 					;current char -> B
			JOBSR	FCDICT_UPPER 				;make char upper case	
			;Check first chars on current tree level (current char in B)  
			LDX	#FCDICT_TREE				;tree pointer -> X
CF_LU_CDICT_1		LDAA	0,X 					;first char -> A
			ANDA	#~FCDICT_STR_TERM 			;remove termination
			CBA						;compare chars (A-B)
			BHI	CF_LU_CDICT_3 				;past alphabetical order -> search failed
			BEQ	CF_LU_CDICT_4 				;match
			;Switch to next sibling (tree pointer in X, current char in B)
CF_LU_CDICT_2		TST	1,X+ 					;find end of string
			BPL	CF_LU_CDICT_2 				;skip past the termination
			TST	2,X+ 					;check for BRANCH symbol
			BNE	CF_LU_CDICT_1 				;no BRANCH, check sibling
			LEAX	1,X 					;first char of sibling -> A
             		JOB	CF_LU_CDICT_1 				;check sibling
			;Search failed 
CF_LU_CDICT_3		LEAS	4,SP					;clean up return stack
			MOVW	#FALSE, 2,-Y 				;push fail flag onto PS
			RTS						;done
			;First char matches (tree pointer in X)   
CF_LU_CDICT_4		LDD	2,SP 					;string pointer -> D
			ADDD	#1 					;advance string pointer
			CPD	0,SP 					;check for EOS
			BEQ	CF_LU_CDICT_6 				;search string EOS
			STD	2,SP 					;update string pointer
			LDAB	[2,SP] 					;next char -> B
			JOBSR	FCDICT_UPPER 				;make char upper case	
			TST	1,X+ 					;check branch for EOS
			BMI	CF_LU_CDICT_5 				;branch EOS
			LDAA	0,X 					;next char -> A
			ANDA	#~FCDICT_STR_TERM 			;remove termination
			CBA						;compare chars
			BEQ	CF_LU_CDICT_4 				;match
			JOB	CF_LU_CDICT_3 				;mismatch -> search failed
			;Branch EOS  (tree pointer in X)
CF_LU_CDICT_5		TST	1,X+ 					;check for BRANCH
			BNE	CF_LU_CDICT_3 				;no BRANCH -> search failed
			LDX	0,X 					;switch to branch
			TST	0,X 					;check for empty branch
			BNE	CF_LU_CDICT_1 				;check subtree
			LEAX	3,X 					;skip over empty branch
			JOB	CF_LU_CDICT_1 				;check suntree
			;End of search tree (tree pointer in X)
CF_LU_CDICT_6		TST	1,X+ 					;check branch for EOS
			BPL	CF_LU_CDICT_3 				;no EOS -> search failed
			TST	0,X 					;check for branch
			BNE	CF_LU_CDICT_7 				;no branch
			LDX	1,X 					;switch to branch
			TST	1,X+ 					;check for empty branch
			BNE	CF_LU_CDICT_3 				;no empty branch -> search failed
			;Search successful (X points to xt)
CF_LU_CDICT_7		LEAS	4,SP 					;clean up RS
			MOVW	0,X, 2,+Y 				;store result
			RTS						;done
	
;Word: WORDS-CDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
;Every word must be shorter than 256 characters! 
IF_WORDS_CDICT		REGULAR
CF_WORDS_CDICT		EQU	*
			;RS layout:
			; +--------+--------+
			; |  Line counter   | SP+0
			; +--------+--------+
			; |                 | SP+2
			; +                 +
			; :    Iterator     :
			; +                 +
			; |                 | SP+(2*(CDICT_TREE_DEPTH))
			; +--------+--------+
			;Start new line
			JOBSR	CF_CR 					;line break
			;Initialize interator structure 
			LEAS	-((2*FCDICT_TREE_DEPTH)+2),SP		;allocate stack space
			MOVW	#FCDICT_FIRST_CC, 0,SP			;initialize line cointer
			FCDICT_INIT_ITERATOR	FCDICT_TREE, SP, 2 	;initialize iterator
			;Print word 
CF_WORDS_CDICT_1	LDAA	#(2*FCDICT_TREE_DEPTH) 			;stack offset -> A
CF_WORDS_CDICT_2	LDX	A,SP 					;substring -> X
			BEQ	CF_WORDS_CDICT_3 			;all substrings printed
			TST	0,X 					;check for empty string
			BEQ	CF_WORDS_CDICT_3 			;all substrings printed 
			JOBSR	FCDICT_TX_STRING 			;print substring
			DECA						;skip to next tree level
			DBNE	A, CF_WORDS_CDICT_2 			;print substring
			;Advance iterator
CF_WORDS_CDICT_3	LDAA	#2 					;stack offset -> A
CF_WORDS_CDICT_4	LDX	A,SP 					;branch -> X
			BEQ	CF_WORDS_CDICT_11			;no branch
CF_WORDS_CDICT_5	TST	1,X+ 					;skip to sibling
			BEQ	CF_WORDS_CDICT_6 			;empty string
			BPL	CF_WORDS_CDICT_5 			;no termination
CF_WORDS_CDICT_6	TST	2,X+ 					;skip over address
			BNE	CF_WORDS_CDICT_7			;no BRANCH symbol
			LEAX	1,X					;skip over BRANCH symbll
CF_WORDS_CDICT_7	TST	0,X 					;check for next sibling
			BEQ	CF_WORDS_CDICT_10 			;no sibling
			STX	A,SP 					;update iterator
CF_WORDS_CDICT_8	TST	1,X+ 					;skip over sibling
			BEQ	CF_WORDS_CDICT_9 			;empty string			
			BPL	CF_WORDS_CDICT_8 			;no termination
CF_WORDS_CDICT_9	TST	1,X+ 					;check for children
			BNE	CF_WORDS_CDICT_12 			;count chars
			LDX	0,X  					;switch to branch
			SUBA	#2	 				;switch to lower tree level
			STX	A,SP 					;store child node
			JOB	CF_WORDS_CDICT_8 			;skip over child node
CF_WORDS_CDICT_10	MOVW	#$0000, A,SP 				;invalidate current level
CF_WORDS_CDICT_11	ADDA	#2 					;switch to higher tree level
			CMPA	#(2*FCDICT_TREE_DEPTH) 			;check if tree is parsed
			BLE	CF_WORDS_CDICT_4 			;advance next higher level 
			;Done
			LEAS	((2*FCDICT_TREE_DEPTH)+2),SP		;free stack space
			JOB	CF_CR 					;line break
			;Count chars 
CF_WORDS_CDICT_12	LDD	#((2*FCDICT_TREE_DEPTH)<<8) 		;stack offset -> A, 0 -> B
CF_WORDS_CDICT_13	LDX	A,SP 					;substring -> X
			BEQ	CF_WORDS_CDICT_15 			;all substrings counted
			TST	0,X 					;check for empty string
			BEQ	CF_WORDS_CDICT_15 			;all substrings counted 
CF_WORDS_CDICT_14	INCB						;increment 
			BRCLR	1,X+, #FCDICT_STR_TERM, CF_WORDS_CDICT_14;loop over string
			DECA						;skip to next tree level
			DBNE	A, CF_WORDS_CDICT_13			;count substring
CF_WORDS_CDICT_15	CLRA						;char count -> D 
			MOVW	#CF_WORDS_CDICT_1, 2,-SP 		;push return address
			JOB	FCDICT_LIST_SEP				
	
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
			
FCDICT_TREE_START	EQU	*	
FCDICT_TREE		FCDICT_TREE
FCDICT_TREE_END		EQU	*	
	
FCDICT_TABS_END		EQU	*
FCDICT_TABS_END_LIN	EQU	@
