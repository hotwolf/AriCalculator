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

;Skip past the end of a string
; args:   Y:      points to a substring or a termination character
; result: Z-flag: set if termination character was found	
;         N-flag: set if terminated string found	
;         Y:      points past the end of the substring or the termination character
; SSTACK: none
;         X and D are preserved 
#macro	FCDICT_SKIP_STRING, 0
LOOP			TST	1,Y+ 		;check for termination character
			BGT	LOOP		;string termination or termination character not found
#emac

;Switch to next sibling in dictionary tree
; args:   Y: points to a substring or to a termination character
; result: Z-flag: cleared if successful, set if no sibling exists	
;         Y: next sibling
; SSTACK: none
;         X and D are preserved 
#macro	FCDICT_NEXT_SIBLING, 0
			FCDICT_SKIP_STRING 	;skip string
			BEQ	CHECK_FOR_SIBLING
			TST	0,Y
			BNE	CHECK_FOR_SIBLING
			LEAY	1,Y
CHECK_FOR_SIBLING	TST	2,+Y
#emac

;Switch to first child in dictionary tree
; args:   Y: tree pointer
; result: Z-flag: cleared if successful, set if no child exists	
;         Y: first child
; SSTACK: none
;         X and D are preserved 
#macro	FCDICT_FIRST_CHILD, 0
			FCDICT_SKIP_STRING 	;skip string
			BEQ	DONE
			TST	0,Y
			BEQ	DONE
			LDY	0,Y
DONE			EQU	*
#emac

;Print CDICT word as represented on the stack
; args:   none
; result: none
; SSTACK: none
; PS:     1 cell
; RS:     none
; throws: nothing
#macro	FCDICT_PRINT_WORD, 0
			;Stack layout:
			; +--------+--------+
			; |  Substring ptr. | PSP+0
			; +--------+--------+
			; |      PSP+n      | PSP+2
			; +--------+--------+
			; |  Tree pointer   | PSP+4
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |  Tree pointer   | PSP+n-2
			; +--------+--------+
			; |  Root pointer   | PSP+n
			; +--------+--------+	
			;Push substring pointer onto PS
			PS_DUP
			;Print substring
FCDICT_PRINT_WORD_1	PS_DUP
			EXEC_CF	CF_STRING_DOT
			;Increment substring pointer
			LDY	PSP
			LDX	0,Y
			LEAX	2,X
			STX	0,Y
			LEAX	2,X
			CPX	PSP
			BNE	FCDICT_PRINT_WORD_1
			;Drop substring pointer
			PS_DROP	1
#emac

;Count chars of CDICT word as represented on the stack
; args:   none
; result: D: char count
;         Y: PSP
; SSTACK: none
; PS:     none
; RS:     none
; throws: nothing
#macro	FCDICT_COUNT_CHARS, 0
			;Stack layout:
			; +--------+--------+
			; |      PSP+n      | PSP+0
			; +--------+--------+
			; |  Tree pointer   | PSP+2
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |  Tree pointer   | PSP+n-2
			; +--------+--------+
			; |  Root pointer   | PSP+n
			; +--------+--------+	
			;Initialize substring pointer and char counter
			LDY	[PSP]
			CLRA
			CLRB
			;Count substring chars (PSP+n in Y, 0 in D)
FCDICT_COUNT_CHARS_1	LDX	2,Y-
			STRING_SKIP_AND_COUNT
			CPY	PSP
			BHI	FCDICT_COUNT_CHARS_1
#emac
	
;Print space or newline char depending on column length 
; args:   none
; result: none
; SSTACK: ? bytes
; PS:     >=3 cells
; RS:     1 cell
; throws: nothing
#macro	FCDICT_PRINT_SEP, 0
			;Stack layout:
			; +--------+--------+
			; |      PSP+n      | PSP+0
			; +--------+--------+
			; |  Tree pointer   | PSP+2
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |  Tree pointer   | PSP+n-2
			; +--------+--------+
			; |  Root pointer   | PSP+n
			; +--------+--------+	
			; | Column counter  | PSP+n+2
			; +--------+--------+
			;Count chars 
			FCDICT_COUNT_CHARS
			;Check for line overflow (PSP in Y, char count in D)
			TFR	D, X
			LDY	0,Y
			ADDD	2,Y
			CPD	#(FCDICT_LINE_WIDTH+FCDICT_STR_SEP_CNT)
			BHI	FCDICT_PRINT_SEP_2 			;print new line
			;Print word separator (PSP+n in Y, column count in D) 
FCDICT_PRINT_SEP_2	TFR	D, X
			LEAX	FCDICT_STR_SEP_CNT,X
			PS_PUSH	#FCDICT_STR_SEP
			JOB	FCDICT_PRINT_SEP_3
			;Print new line (PSP+n in Y, char count in X) 
			PS_PUSH	#FCDICT_STR_NL
FCDICT_PRINT_SEP_3	STX	2,Y
			EXEC_CF	CF_STRING_DOT
#emac
	
;Compare substring
; args:   Y: reference string pointer (MSB terminated)
;         X: string pointer
;         D: character count
;	  1: branch address in case of a mismatch 
; result: Y: points somewhere inside the reference string
;         X: points to the byte after the matched substring (unchanged on mismatch)
;         D: remaining character count (unchanged on mismatch)
; SSTACK: 6 bytes
;         No registers are preserved 
#macro	FCDICT_COMP_STRING, 1
			;Save registers (ref ptr in Y, str ptr in X, char count in D)
			PSHX						;save X	
			PSHD						;save D				
			PSHD						;remainig char count			
			;Check char count (ref ptr in Y, str ptr in X, char count in D)
FCDICT_COMP_STRING_1	LDD	0,SP			       		;D -> char count
			BEQ	FCDICT_COMP_STRING_2 			;mismatch
			SUBD	#1
			STD	0,SP
			;Read chars (ref ptr in Y, str ptr in X, char count in D)
			LDAB	1,X+ 					;str char -> B
			ANDB	#$7F		    			;remove termination
			STRING_UPPER		     			;check case insensitive
			LDAA	1,Y+ 					;ref char -> A
			BMI	FCDICT_COMP_STRING_3			;termination reached
			CBA
			BEQ	FCDICT_COMP_STRING_1			;check next char			
			;Mismatch (new ref ptr in Y)
FCDICT_COMP_STRING_2	SSTACK_PREPULL	8 				;restore stack
			PULD						;remove stack entry				
			PULD						;restore D				
			PULX						;restore X				
			;Done
			JOB	\1
			;Reference string termination reached (ref ptr in Y, str ptr in X, char in B, ref char in A)
FCDICT_COMP_STRING_3	LEAX	-1,Y 					;set pointer to the end of the string
			ANDA	#$7F		    			;remove termination
			CBA
			BNE	FCDICT_COMP_STRING_2			;mismatch
			;Match (ref ptr in Y, str ptr in X)
			SSTACK_PREPULL	8 				;restore stack
			PULD						;pull remaining char count
			LEAS	4,SP					;remove stack entries
#emac
	
;Search word in dictionary
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16 or 17 bytes
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
FCDICT_SEARCH_1		FCDICT_COMP_STRING	FCDICT_SEARCH_3    	;compare substring
			;Substing matches (tree pointer in Y, string pointer in X, char count in D)
			FCDICT_FIRST_CHILD 				;switch to first child
			BNE	FCDICT_SEARCH_1				;check next substring
			TBNE	D, FCDICT_SEARCH_4 			;search unsuccessful
			LDAA	0,Y
			BEQ	FCDICT_SEARCH_4 			;search unsuccessful
			LDAB	1,Y
			;Search unsuccessful
			SSTACK_PREPULL	8 				;check stack
			SEC						;flag unsuccessful search
			PULX						;remove stack entry				
FCDICT_SEARCH_2		PULX						;restore X				
			PULY						;restore Y				
			;Done
			RTS		
			;Try next sibling (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_3		FCDICT_NEXT_SIBLING 				;skip to next sibling
			BNE	FCDICT_SEARCH_1				;check next substring
			;Search unsuccessful (tree pointer in Y, string pointer in X, char count in D)
FCDICT_SEARCH_4		SSTACK_PREPULL	8 				;check stack
			CLC						;flag successful search
			PULD						;restore D				
			JOB	FCDICT_SEARCH_2

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

;.WORDS-CDICT ( -- )
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
			; |      PSP+n      | PSP+0
			; +--------+--------+
			; |  Tree pointer   | PSP+2
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |  Tree pointer   | PSP+n-2
			; +--------+--------+
			; |  Root pointer   | PSP+n
			; +--------+--------+	
			; | Column counter  | PSP+n+2
			; +--------+--------+
			; 
			;Print header
			PS_PUSH	#FCDICT_WORDS_HEADER
			EXEC_CF	CF_STRING_DOT
			;Initialize stack
			PS_CHECK_OF	3 		;new PSP -> Y
			STY	PSP
			MOVW	#$0000, 4,Y
			MOVW	#FCDICT_TREE, 2,Y
			LEAX	2,Y
			STX     0,Y
			;Find first leaf node (PSP in Y)
CF_WORDS_CDICT_1	LDY	2,Y 			;tree pointer -> Y
			FCDICT_FIRST_CHILD
			BEQ	CF_WORDS_CDICT_2	;first word found
			TFR 	Y, X			;child -> X
			PS_CHECK_OF	1 		;new PSP -> Y
			STY	PSP
			MOVW	2,Y, 0,Y
			STX	2,Y
			JOB	CF_WORDS_CDICT_1	;stack next child
			;First word found
CF_WORDS_CDICT_2	FCDICT_COUNT_CHARS 		;count chars of first wors
			LDX	0,Y			;initialize column counter
			STD	2,X
CF_WORDS_CDICT_3	FCDICT_PRINT_WORD 		;print word
			;Find next sibling 
			LDX	PSP
CF_WORDS_CDICT_4	LDY	2,X
			FCDICT_NEXT_SIBLING
			BEQ	CF_WORDS_CDICT_5		;find leaf node of sibling
			;Find next uncle (PSP in X) 
			LDY	0,X
			STY	2,+Y
			STX	PSP
			CPY	PSP
			BLO	CF_WORDS_CDICT_4 	;check parent
			;Done
			PS_DROP	2
			NEXT
			;Find leaf node of sibling  (sibling in Y, PSP in X) 
CF_WORDS_CDICT_5	STY	2,X 			;switch to sibling
CF_WORDS_CDICT_6	FCDICT_FIRST_CHILD
			BEQ	CF_WORDS_CDICT_7	;word found	
			TFR 	Y, X			;child -> X
			PS_CHECK_OF	1 		;new PSP -> Y
			STY	PSP
			MOVW	2,Y, 0,Y
			STX	2,Y
			TFR	X, Y
			JOB	CF_WORDS_CDICT_6	
			;Word found
CF_WORDS_CDICT_7	FCDICT_PRINT_SEP
			JOB	CF_WORDS_CDICT_3	
	
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
			STRING_NL_NONTERM

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

