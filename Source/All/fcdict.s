#ifndef FCDICT
#define FCDICT
;###############################################################################
;# S12CForth- FCDICT - Core Dictionary of the S12CForth Framework              #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
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
;#    FIO    - Forth communication interface                                   #
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
FCDICT_LINE_WIDTH	EQU	DEFAULT_LINE_WIDTH
	
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
;#Initialization
#macro	FCDICT_INIT, 0
#emac

;#Abort action (to be executed in addition of quit action)
#macro	FCDICT_ABORT, 0
#emac
	
;#Quit action
#macro	FCDICT_QUIT, 0
#emac
	
;#Suspend action
#macro	FCDICT_SUSPEND, 0
#emac

;Functions:
;==========
;#Look-up word in dictionaries 
; args:   X: string pointer (terminated string)
; result: X: execution token (unchanged if word not found)
;	  D: 1=immediate, -1=non-immediate, 0=not found
; SSTACK: 8 bytes
;         Y is preserved
#macro	FCDICT_FIND, 0
			SSTACK_JOBSR	FCDICT_FIND, 8
#emac

;Extract path (word) in dictionary
; args:   X: end of incomplete path
; result: X: end of complete path
;         D: {IMMEDIATE, CFA>>1} of new word
; SSTACK: 4 bytes
;         Y is preserved 
#macro	FCDICT_FIRST_PATH, 0
			SSTACK_JOBSR	FCDICT_FIRST_PATH, 4
#emac

;Find next path (word) in dictionary
; args:   Y: start of path
;         X: end of path
; result: Y: start of next path
;         X: end of next path
;         D: {IMMEDIATE, CFA>>1} of new word, zero if unsuccessful
; SSTACK: 4 bytes
;         Y is preserved 
#macro	FCDICT_NEXT_PATH, 0
			SSTACK_JOBSR	FCDICT_NEXT_PATH, 4
#emac
	
;Find next path (word) in dictionary
; args:   Y: start of path
;         X: end of path
;         D: initial char count
; result: Y: start of path
;         X: end of path
;         D: incremented char count
; SSTACK: 6 bytes
;         X and Y are preserved 
#macro	FCDICT_WORD_LENGTH, 0
			SSTACK_JOBSR	FCDICT_WORD_LENGTH, 6
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

;#Look-up word in CORE dictionary 
; args:   X: string pointer (terminated string)
; result: X: execution token (unchanged if word not found)
;	  D: 1=immediate, -1=non-immediate, 0=not found
; SSTACK: 8 bytes
;         Y is preserved
FCDICT_FIND		EQU	*	
			;Save registers (string pointer in X)
			PSHY						;save Y
			PSHX						;string pointer
			PSHX						;substring pointer	
			;Initialize tree pointer (string pointer in X)
			LDY	#FCDICT_TREE_START			
			;Compare char (string pointer in X, dictionary pointer in Y)
FCDICT_FIND_1		LDAA	1,X+ 					;string char -> A
			BMI	FCDICT_FIND_4				;last char in string
			LDAB	1,Y+ 					;dict char -> B
			BMI	FCDICT_FIND_3	 			;last char in substring
			CBA						;compare chars
			BEQ	FCDICT_FIND_1				;compare next char
			;Mismatch (dictionary pointer in Y)
FCDICT_FIND_2		BRCLR	1,Y+,#$80,* 				;skip to the end of the substring
			BRCLR	2,+Y+#$FF,FCDICT_FIND_5 			;no more branches -> search unsuccessful
			LDX	0,SP	    				;restore string pointer
			JOB	FCDICT_FIND_1				;search next branch
			;Last char in string (string char in A, dict char in B string pointer in X, dictionary pointer in Y)
FCDICT_FIND_3		ANDB	#$7F					;remove termination
			CBA						;compare chars
			BNE	FCDICT_FIND_2 				;mismatch
			LDY	0,Y 					;switch to branch
			STX	0,X 					;update substring pointer
			JOB	FCDICT_FIND_1				;search subbranch
			;Last char in string (char in A, string pointer in X, dictionary pointer in Y)
FCDICT_FIND_4		CMPA	1,Y+ 					;compare last char	
			BEQ	FCDICT_FIND_6 				;search successful
			;Search unsuccessful
FCDICT_FIND_5		CLRA						;return result
			CLRB						;not found
			LDX	2,SP 					;restore string pointer
			JOB	FCDICT_FIND_7 				;done
			;Search successful (dictionary pointer in Y)
FCDICT_FIND_6		LDX	#$0000 					;clear X
			LDD	0,Y 					;shifted execution token -> D
			LSLD						;unshift execution token, immediate flag -> C
			EXG	D, X 					;execution token -> X
			ROLB						;immediate flag -> D
			LSLB						;D*2 -> D
			SUBD	#$0001					;D-1 -> D
			;Done (result in D, execution token/string pointer X)
FCDICT_FIND_7		SSTACK_PREPULL	8 				;check stack
			LDY	4,+SP					;restore Y	
			;Done
			RTS
	
;Find next path (word) in dictionary
; args:   Y: start of path
;         X: end of path
; result: Y: start of next path
;         X: end of next path
;         D: {IMMEDIATE, CFA>>1} of new word, zero if unsuccessful
; SSTACK: 4 bytes
;         Y is preserved 
FCDICT_NEXT_PATH	EQU	*
			;Path layout:
			; +--------+--------+
			; |   Node pointer  |<- end of path
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |   Node pointer  |
			; +--------+--------+
			; |   Node pointer  |<- start of path
			; +--------+--------+
			;Save registers (start of path in Y, end of path in X)
			PSHY						;save Y	
			;Find sibling of node (end of path in X)
			LDY	0,X 					;leaf node pointer -> Y 
			BRCLR	0,Y, #$FF, FCDICT_NEXT_PATH_2 		;empty string found
FCDICT_NEXT_PATH_1	BRCLR	1,Y+, #$80, * 				;skip past the end of the substring
			BRCLR	0,Y, #$FF, FCDICT_NEXT_PATH_2 		;subtree pointer found
			LEAY	-1,Y
FCDICT_NEXT_PATH_2	BRCLR	3,+Y, #$FF, FCDICT_NEXT_PATH_4 		;no sibling found
			;Sibling found (end of path in X, sibling in Y) 
			STY	0,X 					;switch to sibling
			JOB	FCDICT_NEXT_PATH_3 			;extract full path of sibling
FCDICT_NEXT_PATH_3	EQU	FCDICT_FIRST_PATH_2	
			;Find parent of leaf node (end of path in X)
FCDICT_NEXT_PATH_4	LDY	2,+X 					;switch to parent
			CPX	0,SP 					;check if parent exists
			BLE	FCDICT_NEXT_PATH_1 			;parent
			;Next path does not exist
			CLRA
			CLRB
			JOB	FCDICT_NEXT_PATH_5
FCDICT_NEXT_PATH_5	EQU	FCDICT_FIRST_PATH_4

;Extract path (word) in dictionary
; args:   X: end of incomplete path
; result: X: end of complete path
;         D: {IMMEDIATE, CFA>>1} of new word
; SSTACK: 4 bytes
;         Y is preserved 
FCDICT_FIRST_PATH	EQU	*
			;Path layout:
			; +--------+--------+
			; |   Node pointer  |<- end of path
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |   Node pointer  |
			; +--------+--------+
			; |   Node pointer  |<- start of path
			; +--------+--------+
			;Save registers (end of path in X)
			PSHY						;save Y	
			;Skip over substring (end of path in X)
			LDY	0,X 					;node pointer -> Y 
FCDICT_FIRST_PATH_1	BRCLR	0,Y, #$FF, FCDICT_FIRST_PATH_3		;empty string found
FCDICT_FIRST_PATH_2	BRCLR	1,Y+, #$80, * 				;skip past the end of the substring
			BRCLR	1,Y-, #$FF, FCDICT_FIRST_PATH_5 	;subtree pointer found
			;Get CFA (end of path in X, node pointer in Y)
FCDICT_FIRST_PATH_3	LDD	1,Y
FCDICT_FIRST_PATH_4	SSTACK_PREPULL	4 				;restore stack
			PULY						;restore Y	
			;Done
			RTS
			;Subtree found (end of path in X, node pointer in Y)			
FCDICT_FIRST_PATH_5	LDY	2,Y 					;switch tree node to subtree
			STY	2,-X 					;append subtree to path
			JOB	FCDICT_FIRST_PATH_1

;Find next path (word) in dictionary
; args:   Y: start of path
;         X: end of path
;         D: initial char count
; result: Y: start of path
;         X: end of path
;         D: incremented char count
; SSTACK: 6 bytes
;         X and Y are preserved 
FCDICT_WORD_LENGTH	EQU	*
			;Save registers (start of path in Y, end of path in X, char count in D)
			PSHY						;save Y				
			PSHX						;save X
			ADDD	#1 					;add length of the separator
			;Count (path pointer in Y, char count in D)
FCDICT_WORD_LENGTH_1	LDX	2,Y-					;string pointer -> X
			BRCLR	0,X, #$FF, FCDICT_WORD_LENGTH_2 	;empty string found
			STRING_SKIP_AND_COUNT 				;count chars of substring
FCDICT_WORD_LENGTH_2	CPY	0,SP 					;check path length
			BHS	FCDICT_WORD_LENGTH_1
			;Restore registers (char count in D)
			SSTACK_PREPULL	6
			PULX						;restore X	
			PULY						;restore Y
			;Done 
			RTS
	
;Code fields:
;============
;FIND-CDICT ( c-addr -- c-addr 0 |  xt 1 | xt -1 )  
;Find the definition named in the terminated string at c-addr. If the definition is
;not found, return c-addr and zero.  If the definition is found, return its
;execution token xt.  If the definition is immediate, also return one (1),
;otherwise also return minus-one (-1).  For a given string, the values returned
;by FIND-CDICT while compiling may differ from those returned while not compiling. 
; args:   PSP+0: terminated string to match dictionary entry
; result: PSP+0: 1 if match is immediate, -1 if match is not immediate, 0 in
;         	 case of a mismatch
;  	  PSP+2: execution token on match, input string on mismatch
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_FIND_CDICT		EQU	*
			;Check PS
			PS_CHECK_UFOF	1, 1 		;new PSP -> Y
			;Search core directory (PSP in Y)
			LDX	2,Y
			FCDICT_FIND 			;(SSTACK: 8 bytes)
			STD	0,Y
			STX	2,Y
			;Done
			NEXT

;WORDS-CDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     FCDICT_TREE_DEPTH+3 cells
; RS:     2 cells
; throws:  FEXCPT_EC_PSOF
CF_WORDS_CDICT		EQU	*
			;PS layout:
			; +--------+--------+
			; |  Start of path  | PSP+0
			; +--------+--------+
			; |    End of path  | PSP+2
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |   Node pointer  | PSP+(2*FCDICT_TREE_DEPTH)+0
			; +--------+--------+
			; |   Node pointer  | PSP+(2*FCDICT_TREE_DEPTH)+2
			; +--------+--------+
			; | Column counter  | PSP+(2*FCDICT_TREE_DEPTH)+4
			; +--------+--------+
CF_WORDS_CDICT_SOP	EQU	0
CF_WORDS_CDICT_EOP	EQU	2
CF_WORDS_CDICT_PATH	EQU	(2*FCDICT_TREE_DEPTH)+2
CF_WORDS_CDICT_COLCNT	EQU	(2*FCDICT_TREE_DEPTH)+4
			;Print header
			PS_PUSH	#FCDICT_WORDS_HEADER
			EXEC_CF	CF_STRING_DOT
			;Initialize PS
			PS_CHECK_OF	FCDICT_TREE_DEPTH+3 	;new PSP -> Y
			STY	PSP
			;Extract first word (PSP in Y)
			LEAY	CF_WORDS_CDICT_PATH,Y 		;start of path -> Y
			TFR	Y, X				;end of path -> X
			MOVW	#FCDICT_TREE, 0,Y 		;start at root
			FCDICT_FIRST_PATH 			;(SSTACK: 4 bytes)
			CLRA
			CLRB
			FCDICT_WORD_LENGTH			;(SSTACK: 6 bytes)
			STD	(CF_WORDS_CDICT_COLCNT-CF_WORDS_CDICT_PATH),Y
			STX	(CF_WORDS_CDICT_EOP-CF_WORDS_CDICT_PATH),Y
			STY	(CF_WORDS_CDICT_SOP-CF_WORDS_CDICT_PATH),Y
			;Print word (start of path in Y, end of path in X)
			STX	(CF_WORDS_CDICT_EOP-CF_WORDS_CDICT_PATH),Y
			STY	(CF_WORDS_CDICT_SOP-CF_WORDS_CDICT_PATH),Y
CF_WORDS_CDICT_1	EXEC_CF	CF_FCDICT_PRINT_WORD
			LDY	PSP				;PSP -> Y
			LDX	CF_WORDS_CDICT_EOP,Y		;end of path -> X
			LEAY	CF_WORDS_CDICT_PATH,Y 		;start of path -> Y
			;Find next word (start of path in Y, end of path in X)
			FCDICT_NEXT_PATH 			;(SSTACK: 4 bytes)
			TBEQ	D, CF_WORDS_CDICT_3		;done
			STX	(CF_WORDS_CDICT_EOP-CF_WORDS_CDICT_PATH),Y
			STY	(CF_WORDS_CDICT_SOP-CF_WORDS_CDICT_PATH),Y
			;Print separator (start of path in Y, end of path in X)
			LDD	(CF_WORDS_CDICT_COLCNT-CF_WORDS_CDICT_PATH),Y
			FCDICT_WORD_LENGTH			;(SSTACK: 6 bytes)
			CPD	#(FCDICT_LINE_WIDTH+1)
			BHI	CF_WORDS_CDICT_2 		;line break required
			;Print space character (start of path in Y, end of path in X, char count in D)
			STD	(CF_WORDS_CDICT_COLCNT-CF_WORDS_CDICT_PATH),Y
			EXEC_CF	CF_SPACE
			JOB	CF_WORDS_CDICT_1
			;Print line break (start of path in Y, end of path in X, char count in D)
CF_WORDS_CDICT_2	SUBD	(CF_WORDS_CDICT_COLCNT-CF_WORDS_CDICT_PATH),Y
			STD	(CF_WORDS_CDICT_COLCNT-CF_WORDS_CDICT_PATH),Y
			EXEC_CF	CF_CR
			JOB	CF_WORDS_CDICT_1
			;Done
CF_WORDS_CDICT_3	PS_CHECK_UF	FCDICT_TREE_DEPTH+3 	;PSP -> Y
			LEAY	(2*(FCDICT_TREE_DEPTH+3)),Y
			STY	PSP
			NEXT

;.WORD-CDICT ( xt --  xt u )
;Reverse lookup an xt and print the associated word. Keep xt on the PS and
;return the number of printed characters u. 
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     FCDICT_TREE_DEPTH+3 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSUF
;         FEXCPT_EC_PSOF
CF_DOT_WORD_CDICT		EQU	*
			;PS layout:
			; +--------+--------+
			; |  Start of path  | PSP+0
			; +--------+--------+
			; |    End of path  | PSP+2
			; +--------+--------+
			; :                 : 
			; +--------+--------+
			; |   Node pointer  | PSP+(2*FCDICT_TREE_DEPTH)+0
			; +--------+--------+
			; |   Node pointer  | PSP+(2*FCDICT_TREE_DEPTH)+2
			; +--------+--------+
			; |        u        | PSP+(2*FCDICT_TREE_DEPTH)+4
			; +--------+--------+
			; |        xt       | PSP+(2*FCDICT_TREE_DEPTH)+6
			; +--------+--------+
CF_DOT_WORD_CDICT_SOP	EQU	0
CF_DOT_WORD_CDICT_EOP	EQU	2
CF_DOT_WORD_CDICT_PATH	EQU	(2*FCDICT_TREE_DEPTH)+2
CF_DOT_WORD_CDICT_CCNT  EQU	(2*FCDICT_TREE_DEPTH)+4
CF_DOT_WORD_CDICT_XT    EQU	(2*FCDICT_TREE_DEPTH)+6
			;Initialize PS
			PS_CHECK_UFOF	1, (FCDICT_TREE_DEPTH+3);new PSP -> Y
			STY	PSP
			;Extract first word (PSP in Y)
			LEAY	CF_DOT_WORD_CDICT_PATH,Y 	;start of path -> Y
			TFR	Y, X				;end of path -> X
			MOVW	#FCDICT_TREE, 0,Y 		;start at root
			FCDICT_FIRST_PATH 			;(SSTACK: 4 bytes)
			;Compare xts  (start of path in Y, end of path in X, xt in D)
CF_DOT_WORD_CDICT_1	LSLD
			CPD	(CF_DOT_WORD_CDICT_XT-CF_DOT_WORD_CDICT_PATH),Y
			BEQ	CF_DOT_WORD_CDICT_2 		;xt found
			;Check next word (start of path in Y, end of path in X)
			FCDICT_NEXT_PATH 			;(SSTACK: 4 bytes)
			TBNE	D, CF_DOT_WORD_CDICT_1		;compare xts
			;xt not found
			PS_CHECK_UF	FCDICT_TREE_DEPTH+4 	;PSP -> Y
			LEAY	(2*(FCDICT_TREE_DEPTH+2)),Y
			STY	PSP
			MOVW	#$0000, 0,Y
			NEXT
			;xt found (start of path in Y, end of path in X)
CF_DOT_WORD_CDICT_2	CLRA	
			CLRB
			FCDICT_WORD_LENGTH 			;determine word length
			STD	(CF_DOT_WORD_CDICT_CCNT-CF_DOT_WORD_CDICT_PATH),Y
			STX	(CF_DOT_WORD_CDICT_EOP-CF_DOT_WORD_CDICT_PATH),Y
			STY	(CF_DOT_WORD_CDICT_SOP-CF_DOT_WORD_CDICT_PATH),Y
			EXEC_CF	CF_FCDICT_PRINT_WORD
			PS_CHECK_UF	FCDICT_TREE_DEPTH+4 	;PSP -> Y
			LEAY	(2*(FCDICT_TREE_DEPTH+2)),Y
			STY	PSP
			MOVW	#TRUE, 0,Y
			NEXT

;FCDICT_PRINT_WORD ( addr0 addr1 --  addr0 addr0 )
;print all terminated strings which are listed in the memory range from addr0 addr1
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
;         FEXCPT_EC_PSOF
CF_FCDICT_PRINT_WORD	EQU	*
			;Check and update path pointers
CF_FCDICT_PRINT_WORD_1	PS_CHECK_UF	2			;PSP -> Y
			LDX	0,Y
			CPX	2,Y
			BLO	CF_FCDICT_PRINT_WORD_2 		;done
			LDD	2,X-
			STX	0,Y
			;Print sybstring (string pointer in D)
			TFR	D, Y
			BRCLR	0,Y, #$FF, CF_FCDICT_PRINT_WORD_1;empty string found
			PS_PUSH_D
			EXEC_CF	CF_STRING_DOT
			JOB	CF_FCDICT_PRINT_WORD_1
			;Done
CF_FCDICT_PRINT_WORD_2	NEXT

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
			FCS	"Core Dictionary:"

;#Dictionary tree
FCDICT_TREE_START	EQU	*	
FCDICT_TREE		FCDICT_TREE
FCDICT_TREE_END		EQU	*	

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
;Word: FIND-CDICT ( c-addr -- c-addr 0 |  xt 1 | xt -1 )  
;Find the definition named in the terminated string at c-addr. If the definition is
;not found, return c-addr and zero.  If the definition is found, return its
;execution token xt.  If the definition is immediate, also return one (1),
;otherwise also return minus-one (-1).  For a given string, the values returned
;by FIND-CDICT while compiling may differ from those returned while not compiling. 
CFA_FIND_CDICT		DW	CF_FIND_CDICT

;Word: WORDS-CDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
CFA_WORDS_CDICT	DW	CF_WORDS_CDICT
	
FCDICT_WORDS_END	EQU	*
FCDICT_WORDS_END_LIN	EQU	@
#endif
