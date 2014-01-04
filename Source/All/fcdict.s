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
;#    BASE - S12CBase framework                                                #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
;#    FCOM   - Forth communication interface                                   #
;#    FINNER - Forth inner interpreter                                         #
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
;Max. line length
FCDICT_LINE_WIDTH	EQU	80
	
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
; args:   Y: dictionary pointer (points to substring)
;         X: string pointer
;         D: character count
;	  1: branch address in case of a mismatch 
; result: Y: points to the byte after the the dictionary substring
;         X: points to the byte after the matched substring (unchanged on mismatch)
;         D: remaining character count (unchanged on mismatch)
; SSTACK: 8 bytes
;         No registers are preserved 
#macro	FCDICT_COMP_STRING, 1
			;Save registers (dict ptr in Y, str ptr in X, char count in D)
			SSTACK_PREPUSH	8
			PSHX						;save X	
			PSHD						;save D				
			PSHD						;remainig char count			
			;Check char count (dict ptr in Y, str ptr in X)
FCDICT_COMP_STRING_1	LDD	0,SP			       		;D -> char count
			BEQ	FCDICT_COMP_STRING_2 			;mismatch
			SUBD	#1
			STD	0,SP
			;Read chars (dict ptr in Y, str ptr in X)
			LDAB	1,X+ 					;str char -> B
			ANDB	#$7F 					;remove termination
			STRING_UPPER		     			;check case insensitive (SSTACK: 2 bytes)
			LDAA	1,Y+ 					;ref char -> A
			BMI	FCDICT_COMP_STRING_4			;termination reached
			CBA
			BEQ	FCDICT_COMP_STRING_1			;check next char			
			;Mismatch (new dict ptr in Y)
FCDICT_COMP_STRING_2	BRCLR	1,Y+, #$80, * 				;skip past the termination of the dictionary string 
FCDICT_COMP_STRING_3	SSTACK_PREPULL	6 				;restore stack
			PULD						;remove stack entry				
			PULD						;restore D				
			PULX						;restore X				
			;Done
			JOB	\1
			;Reference string termination reached (ref ptr in Y, str ptr in X, char in B, ref char in A)
FCDICT_COMP_STRING_4	ANDA	#$7F		    			;remove termination
			CBA
			BNE	FCDICT_COMP_STRING_3			;mismatch
			;Match (ref ptr in Y, str ptr in X)
FCDICT_COMP_STRING_5	SSTACK_PREPULL	6 				;restore stack
			PULD						;pull remaining char count
			LEAS	4,SP					;remove stack entries
#emac
	
;Search word in dictionary
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16 or 17 bytes
;         Y and Y are preserved 
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

;Search word in dictionary
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16 or 17 bytes
;         X and Y are preserved 
FCDICT_SEARCH		EQU	*
			;Save registers (string pointer in X, char count in D)
			PSHY						;save Y
			PSHX						;save X
			PSHD						;save D	
			;Set dictionary tree pointer (string pointer in X, char count in D)
			LDY	#FCDICT_TREE
			;Compare substring (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_1		FCDICT_COMP_STRING	FCDICT_SEARCH_3    	;compare substring (SSTACK: 8 bytes)
			;Substing matches (tree pointer in Y, string pointer in X, char count in D)
			BRCLR	0,Y, #$FF, FCDICT_SEARCH_5 		;leaf node reached
			LDY	0,Y 					;switch to subtree
			TST	0,Y 					;check for STRING_TERMINATION
			BNE	FCDICT_SEARCH_1				;no end of dictionary word reached 
			;Subtree starts with STRING_TERMINATION (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_2		TBEQ	D, FCDICT_SEARCH_6 			;match
			LEAY	3,Y 					;switch to next sibling
			JOB	FCDICT_SEARCH_1				;Parse sibling
			;Try next sibling (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_3		BRCLR	1,Y+, #$FF, FCDICT_SEARCH_4		;check for STRING_TERMINATION
			LEAY	1,Y					;skip over CFA
			JOB	FCDICT_SEARCH_1				;compare next sibling	
FCDICT_SEARCH_4		BRCLR	2,+Y, #$FF, FCDICT_SEARCH_8 		;check for END_OF_SUBTREE
			JOB	FCDICT_SEARCH_1				;compare next sibling	
			;Leaf node found (tree pointer in Y, string pointer in X, char count in D) 
FCDICT_SEARCH_5		TBNE	D, FCDICT_SEARCH_8 			;mismatch
			;Search successful (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_6		SSTACK_PREPULL	8 				;check stack
			LDD	1,Y 					;get CFA
			SEC						;flag unsuccessful search
			PULX						;remove stack entry				
FCDICT_SEARCH_7		PULX						;restore X				
			PULY						;restore Y				
			;Done
			RTS		
			;Search unsuccessful (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_8		SSTACK_PREPULL	8 				;check stack
			CLC						;flag successful search
			PULD						;restore D				
			JOB	FCDICT_SEARCH_7

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

;WORDS-CDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
; args:   none
; result: none
; SSTACK: ? bytes
; PS:     >=3 cells
; RS:     1 cell
; throws: nothing
CF_WORDS_CDICT		EQU	*
			;Stack layout:
			; +--------+--------+
			; | Subtree pointer | PSP+0
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; | Subtree pointer | PSP+n-6
			; +--------+--------+
			; |  Root pointer   | PSP+n-4
			; +--------+--------+	
			; |      $0000      | PSP+n-2
			; +--------+--------+	
			; | Column counter  | PSP+n
			; +--------+--------+
			; 
			;Print header
			PS_PUSH	#FCDICT_WORDS_HEADER
			EXEC_CF	CF_STRING_DOT
			;Initialize PS
			PS_CHECK_OF	2 			;new PSP -> Y
			STY	PSP
			MOVW	#$0000, 2,Y
			MOVW	#$0000, 0,Y	
			LDX	#FCDICT_TREE
			;Stack word (subtree tree pointer in X, PSP in Y)
CF_WORDS_CDICT_1	PS_PUSH_X 				;stack subtree
			BRCLR	0,X, #$FF, CF_WORDS_CDICT_2 	;check for empty string
			BRCLR	1,X+, #$80, * 			;skip past the end of the substring
			LDD	0,X				;check for STRING_TERMINATION
			TBEQ	A, CF_WORDS_CDICT_2		;end of word
			TFR	D, X				;follow subtree
			JOB	CF_WORDS_CDICT_1 		;	
			;Count chars (PSP in Y)
CF_WORDS_CDICT_2	CLRA					;initialize char count
			CLRB	
			LDX	2,Y+ 				;subtree pointer -> X			
			BRCLR	0,X, #$FF, CF_WORDS_CDICT_4 	;check for empty string
CF_WORDS_CDICT_3	STRING_SKIP_AND_COUNT			;count chars
CF_WORDS_CDICT_4	LDX	2,Y+						
			BNE	CF_WORDS_CDICT_3
			;Push subtree pointer (char count in D, PSP+n in Y)
			LEAX	-4,Y
			PS_PUSH_X
			;Print separator (char count in D, PSP+n-4 in X) 
			LDY	4,X				;check for first line
			BEQ	CF_WORDS_CDICT_5		;first line (no separator required)
			LEAY	D,Y				;new line width -> Y
			CPY	#(FCDICT_LINE_WIDTH-1)		;check line width
			BLS	CF_WORDS_CDICT_6		;word separator required
			STD	4,X				;set new char count
			EXEC_CF	CF_CR				;print line break
			JOB	CF_WORDS_CDICT_7		;print word
CF_WORDS_CDICT_5	STD	4,X				;set new line count
			JOB	CF_WORDS_CDICT_7		;print word
CF_WORDS_CDICT_6	STY	4,X				;update line count
			EXEC_CF	CF_SPACE			;print word separator (space)
			;Print word
CF_WORDS_CDICT_7	PS_CHECK_UF 1	 			;PSP -> Y
			LDX	0,Y				;subtree pointer -> X 
			CPX	PSP				;check for end of word
			BLS	CF_WORDS_CDICT_8		;end of word found
			BRCLR	[0,X], #$FF, CF_WORDS_CDICT_8 	;check for empty string
			LDD	2,X-				;string pointer -> D
			STX	0,Y							
			PS_PUSH_D 				;print substring
			EXEC_CF	CF_STRING_PRINT
			JOB	CF_WORDS_CDICT_7 		;print next substring
			;Drop subtree pointer
CF_WORDS_CDICT_8	PS_DROP	1	
			;Switch to next sibling (PSP in Y)
			LDX	0,Y			   	;old subtree -> X
CF_WORDS_CDICT_9	BRCLR	0,X, #$FF, CF_WORDS_CDICT_10 	;empty substring
			BRCLR	1,X+, #$80, * 			;skip past the end of the substring
			BRCLR	0,X, #$FF, CF_WORDS_CDICT_10 	;no subtree
			JOB	CF_WORDS_CDICT_1		;follow subtree
			;Switch to next uncle
CF_WORDS_CDICT_10	PS_DROP	1 				;drop current subtree
			LDX	0,Y			   	;parent subtree -> X
			BNE	CF_WORDS_CDICT_9		;find sibling of parent
			;Cleanup PS
			PS_DROP	2 				;drop char count
			;Done
			NEXT

;.WORD-CDICT ( xt -- flag )
;Reverse lookup an xt and print the associated word. Return true if xt was found, false otherwise
; args:   none
; result: none
; SSTACK: ? bytes
; PS:     >=3 cells
; RS:     1 cell
; throws: nothing
CF_DOT_WORD_CDICT		EQU	*
			;Stack layout:
			; +--------+--------+
			; | Subtree pointer | PSP+0
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; | Subtree pointer | PSP+n-6
			; +--------+--------+
			; |  Root pointer   | PSP+n-4
			; +--------+--------+	
			; |      $0000      | PSP+n-2
			; +--------+--------+	
			; |       xt        | PSP+n
			; +--------+--------+
			; 
			;Initialize PS
			PS_CHECK_UFOF	1, 1 	;new PSP -> Y
			STY	PSP
			MOVW	#$0000, 0,Y	
			LDX	#FCDICT_TREE
			;Stack word (subtree tree pointer in X, PSP in Y)
CF_DOT_WORD_CDICT_1	PS_PUSH_X 				;stack subtree
			BRCLR	0,X, #$FF, CF_WORDS_CDICT_2 	;check for empty string
			BRCLR	1,X+, #$80, * 			;skip past the end of the substring
			LDD	0,X				;check for STRING_TERMINATION
			TBEQ	A, CF_WORDS_CDICT_2		;end of word
			TFR	D, X				;follow subtree
			JOB	CF_WORDS_CDICT_1 		;	

	;; TBD

	
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

;#New line string
FCDICT_STR_NL		EQU	STRING_STR_NL

;#Word separator string
FCDICT_STR_SEP		FCS	" "
FCDICT_STR_SEP_CNT	*-FCDICT_PRINT_SEP_WS

;#Header line for WORDS output 
FCDICT_WORDS_HEADER	STRING_NL_NONTERM
			FCC	"Core Dictionary:"
			STRING_NL_TERM

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

;Word: WORDS-CDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
CFA_WORDS_CDICT		DW	CF_WORDS_CDICT
	
FCDICT_WORDS_END	EQU	*
FCDICT_WORDS_END_LIN	EQU	@

