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

;;Dictionary operations:
;;======================	
;;#Look-up word in CORE dictionariy 
;; args:   X: search string (terminated string)
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
;; SSTACK: 8 bytes
;;         X and Y are preserved
;#macro	FCDICT_FIND, 0
;			SSTACK_JOBSR	FCDICT_FIND, 8
;#emac
;
;;#Reverse lookup a CFA and print the corresponding word
;; args:   D: CFA
;; result: C-flag: set if successful
;; SSTACK: 2*FCDICT_TREE_DEPTH + 6 bytes
;;         All registers are preserved
;#macro	FCDICT_REVPRINT_BL, 0
;			SSTACK_JOBSR	FCDICT_REVPRINT_BL, (2*(FCDICT_TREE_DEPTH+3))
;#emac
;	
;;Iterator operations:
;;======================
;;Set interator to first word in CDICT
;; args:   Y: start of iterator structure
;; result: none
;; SSTACK: none
;;         All registers are preserved
;#macro FCDICT_ITERATOR_FIRST, 0
;			FCDICT_ITERATOR_INIT FCDICT_TREE, Y, 0
;#emac
;
;;Reverse search CDICT for matching CFA
;; args:   Y: start of iterator structure
;;         D: CFA
;; result: none
;; SSTACK: 10 bytes
;;         X and Y are preserved
;#macro FCDICT_ITERATOR_REV, 0
; 			SSTACK_JOBSR	FCDICT_ITERATOR_REV, 10
;#emac
;	
;;Advance iterator
;; args:   Y: start of iterator structure
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero in case of empty iterator
;; SSTACK: 6 bytes
;;         X and Y are preserved
;#macro FCDICT_ITERATOR_NEXT, 0
; 			SSTACK_JOBSR	FCDICT_ITERATOR_NEXT, 6
;#emac
;
;;Get length of word referenced by current iterator
;; args:   Y: start of iterator structure
;; result: D: char count 
;; SSTACK: 6 bytes
;;         X and Y are preserved
;#macro FCDICT_ITERATOR_WC, 0
; 			SSTACK_JOBSR	FCDICT_ITERATOR_WC, 6
;#emac
;
;;Print word referenced by current iterator (BLOCKING)
;; args:   Y: start of iterator structure
;; result: none 
;; SSTACK: 16 bytes
;;         All registers are preserved
;#macro FCDICT_ITERATOR_PRINT, 0
; 			SSTACK_JOBSR	FCDICT_ITERATOR_PRINT, 16
;#emac
;
;;Get CFA of word referenced by current iterator
;; args:   Y: start of iterator structure
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero ic case of empty iterator
;; SSTACK: 6 bytes
;;         X and Y are preserved;
;;#macro FCDICT_ITERATOR_CFA, 0
;; 			SSTACK_JOBSR	FCDICT_ITERATOR_CFA, 6
;;#emac
;	
;;Basic tree navigation:
;;======================
;;Set dictionary pointers
;; args:   Y: start of path (iterator structure)
;;         1: branch address if empty iterator
;; result: Y: end of path (iterator structure)
;;         X: leaf node (dictionary tree)
;; SSTACK: 0 bytes
;;         D is preserved
;#macro	FCDICT_SET_PTRS, 1
;			;Y: points to current entry in iterator structure 
;			;X: points to current byte in directory tree 
;			;Check for NULL pointer (iterator pointer in Y)
;			LDX	0,Y 					;check first substring
;			BEQ	\1 					;NULL pointer
;			;Skip to current leaf node (iterator pointer in Y)
;FCDICT_SET_PTRS_1	LDX	2,+Y 					;check next substring
;			BNE	FCDICT_SET_PTRS_1 			;try one more substring
;			LDX	2,-Y 					;check next substring
;#emac
;
;;Skip substring
;; args:   X: node (dictionary tree)
;; result: X: points to first byte after node's sub-string (X+1 if empty string)
;; SSTACK: 0 bytes
;;         Y and D are preserved
;#macro	FCDICT_SUBSTR, 0
;			;Y: points to current entry in CDICT pointer structure 
;			;X: points to cutrrent byte in directory tree 
;			;Check for empty string (iterator pointer in Y, node pointer in X)
;			BRCLR	1,X+, #$FF, FCDICT_SUBSTR_DONE		;empty substring found (check for sibling)
;			;Skip over substring (iterator pointer in Y, string pointer in X)
;			LEAX	-1,X 					;go back to firsct char
;			BRCLR	1,X+, #FIO_TERM, * 			;skip past the end of the substring
;			;Done (iterator pointer in Y, tree pointer in X)
;FCDICT_SUBSTR_DONE	EQU	*
;#emac
;	
;;Skip to next sibling
;; args:   Y: path pointer (iterator structure)
;;         X: node (dictionary tree)
;;         1: branch address if no sibling is found
;; result: X: sibling node (invalid if no sibling is found)
;; SSTACK: 0 bytes
;;         Y and D are preserved
;#macro	FCDICT_SIBLING, 1
;			;Y: points to current entry in CDICT pointer structure 
;			;X: points to cutrrent byte in directory tree 
;			;Skip sub-string (iterator pointer in Y, node pointer in X)
;			FCDICT_SUBSTR					
;			;Check for sibling (iterator pointer in Y, tree pointer in X)
;			BRCLR	1,X+, #$FF, FCDICT_SIBLING_1		;skip branch indicator
;			LEAX	-1,X 					;adjust tree pointer
;FCDICT_SIBLING_1	BRCLR	2,+X, #$FF, \1 				;no sibling found (check for uncle)		
;			;Skip to sibling (iterator pointer in Y, sibling node pointer in X)
;			STX	0,Y 					;update pointer structure
;#emac
;
;;Skip to first child
;; args:   Y: path pointer (iterator structure)
;;         X: node (dictionary tree)
;;         1: branch address if no child is found
;; result: Y: new path pointer (unchanged if no child is found)
;;         X: new node (points low byte of current CFA if no child is found)
;; SSTACK: 0 bytes
;;         D is preserved
;#macro	FCDICT_1ST_CHILD, 1
;			;Y: points to current entry in CDICT pointer structure 
;			;X: points to cutrrent byte in directory tree 
;			;Skip sub-string (iterator pointer in Y, node pointer in X)
;			FCDICT_SUBSTR					
;			;Check for child (iterator pointer in Y, tree pointer in X)
;			TST	0,X 					;check for branch indicator
;			BNE	\1 					;no child found
;			;Skip to child (iterator pointer in Y, child node pointer in X)
;			LDX	1,X  					;skip to child
;			STX	2,+Y 					;update iterator struct
;#emac
;	
;;Skip to parent
;; args:   Y: path pointer (iterator structure)
;;         X: node (dictionary tree)
;;         1: branch address if no parent is found
;;         2: start of path (iterator structure)
;; result: Y: new path pointer (invalid if no parent is found)
;;         X: new node
;; SSTACK: 0 bytes
;;         D is preserved
;#macro	FCDICT_PARENT, 2
;			;Y: points to current entry in CDICT pointer structure 
;			;X: points to cutrrent bye in directory tree 
;			;Update pointer (iterator pointer in Y)
;			MOVW	#NULL, 2,Y- 				;skip to parent node
;			CPY	\2					;check for parent
;			BLO	\1					;no parent found
;			LDX	0,Y 					;update tree pointer
;#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FCDICT_CODE_START_LIN
			ORG 	FCDICT_CODE_START, FCDICT_CODE_START_LIN
#else
			ORG 	FCDICT_CODE_START
FCDICT_CODE_START_LIN	EQU	@
#endif

;#String operations
;==================
;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character 
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
FCDICT_UPPER		EQU	STRING_UPPER

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
CF_LU_CDICT_C		LDAA	0,X 					;first char -> A
			ANDA	#~FCDICT_STR_TERM 			;remove termination
			CBA						;compare chars (A-B)
			BHI	CF_LU_CDICT_D 				;past alphabetical order -> search failed
			BEQ	CF_LU_CDICT_E 				;match
			;Switch to next sibling (tree pointer in X, current char in B)
CF_LU_CDICT_A		TST	1,X+ 					;find end of string
			BPL	CF_LU_CDICT_A 				;skip past the termination
			TST	2,X+ 					;check for BRANCH symbol
			BNE	CF_LU_CDICT_B 				;no BRANCH, check sibling
			LEAX	1,X 					;first char of sibling -> A
CF_LU_CDICT_B		BNE	CF_LU_CDICT_C 				;check sibling
			;Search failed 
CF_LU_CDICT_D		LEAS	6,SP					;clean up return stack
			MOVW	#FALSE, 2,Y- 				;push fail flag onto PS
			RTS						;done
			;First char matches (tree pointer in X)   
CF_LU_CDICT_E		LDD	2,SP 					;string pointer -> D
			ADDD	#1 					;advance string pointer
			CPD	0,SP 					;check for EOS
			BEQ	CF_LU_CDICT_G 				;search string EOS
			STD	2,SP 					;update string pointer
			LDAB	[2,SP] 					;next char -> B
			JOBSR	FCDICT_UPPER 				;make char upper case	
			TST	1,X+ 					;check branch for EOS
			BMI	CF_LU_CDICT_F 				;branch EOS
			LDAA	0,X 					;next char -> A
			ANDA	#~FCDICT_STR_TERM 			;remove termination
			CBA						;compare chars
			BEQ	CF_LU_CDICT_E 				;match
			JOB	CF_LU_CDICT_D 				;mismatch -> search failed
			;Branch EOS  (tree pointer in X)
CF_LU_CDICT_F		TST	1,X+ 					;check for BRANCH
			BNE	CF_LU_CDICT_D 				;no BRANCH -> search failed
			LDX	0,X 					;switch to branch
			TST	0,X 					;check for empty branch
			BNE	CF_LU_CDICT_C 				;check subtree
			LEAX	3,X 					;skip over empty branch
			JOB	CF_LU_CDICT_C 				;check suntree
			;End of search tree (tree pointer in X)
CF_LU_CDICT_G		TST	1,X+ 					;check branch for EOS
			BPL	CF_LU_CDICT_D 				;no EOS -> search failed
			TST	0,X 					;check for branch
			BNE	CF_LU_CDICT_H 				;no branch
			LDX	1,X 					;switch to branch
			TST	1,X+ 					;check for empty branch
			BNE	CF_LU_CDICT_D 				;no empty branch -> search failed
			;Search successful (X points to xt)
CF_LU_CDICT_H		LEAS	4,SP 					;clean up RS
			STX	2,+Y 					;store result
			RTS						;done
	
	
	
;;Dictionary operations:
;;======================	
;;#Look-up word in CORE dictionary 
;; args:   X: search string (terminated string)
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
;; SSTACK: 8 bytes
;;         X and Y are preserved
;FCDICT_FIND		EQU	*	
;			;Save registers (search string in X)
;			PSHY						;save Y
;			PSHX						;search string pointer
;			PSHX						;search substring pointer	
;			;Initialize tree pointer (search string in X)
;			LDY	#FCDICT_TREE_START 			;start of CDICT -> Y
;			;Compare chars (search string in X, CDICT pointer in Y)
;FCDICT_FIND_1		LDAB	1,X+ 					;search char -> B
;			FIO_UPPER 					;make search char upper case
;			TSTB						;check if char has been terminated
;			BMI	FCDICT_FIND_7				;end of search string
;			LDAA	1,Y+ 					;dict char -> A
;			BEQ	FCDICT_FIND_3 				;empty string (skip to next sibling)
;			BMI	FCDICT_FIND_10	 			;end of CDICT substring
;			CBA						;compare chars
;			BEQ	FCDICT_FIND_1				;compare next char
;			;Skip to next sibling (CDICT pointer in Y)
;FCDICT_FIND_2		BRCLR	1,Y+, #FIO_TERM, * 			;skip past the end of the CDICT substring
;FCDICT_FIND_3		LDX	0,SP 					;reset search substring
;			TST	2,Y+ 					;check for children
;			BNE	FCDICT_FIND_4 				;no childeren found
;			LEAY	1,Y 					;adjust CDICT pointer
;FCDICT_FIND_4		TST	0,Y 					;check for end of branch
;			BNE	FCDICT_FIND_1 				;skip to next char
;			;Search unsuccessful 
;FCDICT_FIND_5		CLRA						;return 0=not found
;			CLRB		  				;
;			;Done (result in D) 
;FCDICT_FIND_6		SSTACK_PREPULL	8 				;check stack
;			LEAS	2,SP 					;clean up tmp vars
;			PULX						;restore X
;			PULY						;restore Y
;			RTS
;			;End of search string (CDICT pointer in Y, CDICT char in A, search char in B)
;FCDICT_FIND_7		LDAA	1,Y+ 					;dict char -> A
;			BPL	FCDICT_find_2 				;skip to nect sibling
;			CBA						;compare chars
;			BNE	FCDICT_FIND_3 				;search unsuccessful
;			BRCLR	0,Y, #$FF, FCDICT_FIND_9 		;check for blank children
;FCDICT_FIND_8		LDD	0,Y
;			JOB	FCDICT_FIND_6 				;search successful
;			;check for blank child (CDICT pointer in Y)
;FCDICT_FIND_9		LDY	1,Y 					;skip to subtree
;			BRCLR	1,Y+, #$FF, FCDICT_FIND_8		;search successful
;			JOB	FCDICT_FIND_5 				;search unsuccessful
;			;End of CDICT substring (CDICT pointer in Y, CDICT char in A, search char in B)
;FCDICT_FIND_10		ANDA	#(~FIO_TERM) 				;remove termination
;			CBA						;compare chars
;			BNE	FCDICT_FIND_3 				;search unsuccessful
;			TST	1,Y+ 					;check for subtree
;			BNE	FCDICT_FIND_5 				;search unsuccessful
;			STX	0,SP 					;set new search substring
;			LDY	0,Y 					;skip to subtree
;			JOB	FCDICT_FIND_1









				;
;;#Reverse lookup a CFA and print the corresponding word
;; args:   D: CFA
;; result: C-flag: set if successful
;; SSTACK: 2*FCDICT_TREE_DEPTH + 6 bytes
;;         All registers are preserved
;FCDICT_REVPRINT_BL	EQU	*
;			;Save registers (CFA in D)
;			PSHY						;save Y	
;			;Allocate iterator structure (CFA in D)
;			LEAS	(-2*(FCDICT_TREE_DEPTH+1)),SP 		;allocate space for iterator
;			TFR	SP, Y 					;start of iterator -> Y
;			;Reverse lookup (start of iterator in Y, CFA in D)
;			FCDICT_ITERATOR_REV				;reverse lookup
;			TST	0,Y 					;check for empty iterator
;			BEQ	FCDICT_REVPRINT_BL_2 			;search unsucessful
;			;Print word (start of iterator in Y, CFA in D)
;			FCDICT_ITERATOR_PRINT 				;print word (SSTACK: 16 bytes)
;			;Report sucess (CFA in D)
;			SSTACK_PREPULL (2*(FCDICT_TREE_DEPTH+3)) 	;check stack
;			SEC				 		;flag success
;			;Done (CFA in D)
;FCDICT_REVPRINT_BL_1	LEAS	(2*(FCDICT_TREE_DEPTH+1)),SP 		;deallocate iterator space
;			PULY						;restore Y	
;			RTS
;			;Report failure (CFA in D)
;FCDICT_REVPRINT_BL_2	SSTACK_PREPULL (2*(FCDICT_TREE_DEPTH+3)) 	;check stack
;			CLC				 		;flag failure
;			JOB	FCDICT_REVPRINT_BL_1 			;done
;	
;;Iterator operations:
;;====================
;;Reverse search CDICT for matching CFA
;; args:   Y: start of iterator structure
;;         D: CFA
;; result: none
;; SSTACK: 10 bytes
;;         X and Y are preserved
;FCDICT_ITERATOR_REV	EQU	*
;			;Save registers (start of iterator in Y, CFA in D)
;			PSHD						;save D
;			;Get first CFA (start of iterator in Y)
;			FCDICT_ITERATOR_FIRST 				;set iterator
;			LDD	#(FCDICT_FIRST_CFA>>1) 			;1st CFA -> D
;			;Check CFA (start of iterator in Y, {IMMEDIATE, CFA>>1} in D)		
;FCDICT_ITERATOR_REV_1	TBEQ	D, FCDICT_ITERATOR_REV_2		;search unsuccessful 	
;			LSLD						;remove Immediate flag
;			CPD	0,SP 					;Compare CFAs
;			BEQ	FCDICT_ITERATOR_REV_2 			;search successful
;			;Get next CFA (start of iterator in Y)
;			FCDICT_ITERATOR_NEXT 				;advance iterator (SSTACK: 6 bytes)
;			JOB	FCDICT_ITERATOR_REV_1
;			;Done
;FCDICT_ITERATOR_REV_2	SSTACK_PREPULL	2 				;restore stack
;			PULD						;restore D	
;			RTS
;	
;;Advance iterator
;; args:   Y: start of iterator structure
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero in case of empty iterator
;; SSTACK: 6 bytes
;;         X and Y are preserved
;FCDICT_ITERATOR_NEXT	EQU	*
;			;Save registers (start of iterator in Y)
;			PSHX						;save X
;			PSHY						;save Y	
;			;Set default result (start of iterator in Y)
;			CLRA
;			CLRB
;			;Set tree and iterator pointers (start of iterator in Y)
;			FCDICT_SET_PTRS FCDICT_ITERATOR_NEXT_5		;empty iterator found
;			;Check for sibling (iterator pointer in Y, node pointer in X) 
;FCDICT_ITERATOR_NEXT_1	FCDICT_SIBLING FCDICT_ITERATOR_NEXT_3 		;no sibling found
;			;Check for descendands (iterator pointer in Y, node pointer in X)
;FCDICT_ITERATOR_NEXT_2	FCDICT_1ST_CHILD FCDICT_ITERATOR_NEXT_4 	;leaf node found
;			JOB FCDICT_ITERATOR_NEXT_2 			;check for further child
;			;Check for uncle (iterator pointer in Y, node pointer in X)
;FCDICT_ITERATOR_NEXT_3	FCDICT_PARENT FCDICT_ITERATOR_NEXT_5, (0,SP)    ;empty iterator found
;			JOB FCDICT_ITERATOR_NEXT_1 			;check for descendands of uncle
;			;Next iterator found (iterator pointer in Y, node pointer in X)
;FCDICT_ITERATOR_NEXT_4	LDD	0,X 					;get CFA
;			;Done
;FCDICT_ITERATOR_NEXT_5	SSTACK_PREPULL	6 				;restore stack
;			PULY						;restore Y	
;			PULX						;restore X	
;			RTS
;	
;;Get length of word referenced by current iterator
;; args:   Y: start of iterator structure
;; result: D: char count 
;; SSTACK: 6 bytes
;;         X and Y are preserved
;FCDICT_ITERATOR_WC	EQU	*
;			;Save registers (start of iterator in Y)
;			PSHX						;save X
;			PSHY						;save Y	
;			;Reset char count (start of iterator in Y)
;			CLRA
;			CLRB
;			;Count loop (iterator pointer in Y, char count in D)
;FCDICT_ITERATOR_WC_1	LDX	2,Y+
;			BEQ	FCDICT_ITERATOR_WC_2 			;done
;			FIO_SKIP_AND_COUNT 				;count chars in substring
;			JOB	FCDICT_ITERATOR_WC_1 			;skip to next substring
;			;Done
;FCDICT_ITERATOR_WC_2	SSTACK_PREPULL	6 				;restore stack
;			PULY						;restore Y	
;			PULX						;restore X	
;			RTS
;
;;Print word referenced by current iterator (BLOCKING)
;; args:   Y: start of iterator structure
;; result: none
;; SSTACK: 16 bytes
;;         All registers are preserved
;FCDICT_ITERATOR_PRINT	EQU	*
;			;Save registers (start of iterator in Y)
;			PSHX						;save X
;			PSHY						;save Y	
;			;Count loop (iterator pointer in Y, char count in D)
;FCDICT_ITERATOR_PRINT_1	LDX	2,Y+
;			BEQ	FCDICT_ITERATOR_PRINT_2 		;done
;			FIO_PRINT_BL					;print substring (SSTACK: 10 bytes)
;			JOB	FCDICT_ITERATOR_PRINT_1 		;skip to next substring
;			;Done
;FCDICT_ITERATOR_PRINT_2	SSTACK_PREPULL	6 				;restore stack
;			PULY						;restore Y	
;			PULX						;restore X	
;			RTS
;	
;;Get CFA of word referenced by current iterator
;; args:   Y: start of iterator structure
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero ic case of empty iterator
;; SSTACK: 6 bytes
;;         X and Y are preserved;
;;FCDICT_ITERATOR_CFA	EQU	*
;;			;Save registers (start of iterator in Y)
;;			PSHX						;save X
;;			PSHY						;save Y	
;;			;Set default result (start of iterator in Y)
;;			CLRA
;;			CLRB
;;			;Set tree and iterator pointers (start of iterator in Y, default result in D)
;;			FCDICT_SET_PTRS FCDICT_ITERATOR_CFA_1 		;empty iterator found
;;			;Skip over sub-string (string pointer in X, default result in D)
;;			BRCLR	1,X+, #FIO_TERM, * 			;skip past string termination
;;			LDAA	1,X+ 					;check for leaf node
;;			BEQ	FCDICT_ITERATOR_CFA_1 			;not a leaf node (invalid iterator) 
;;			LDAB	0,X	 				;get complete result
;;FCDICT_ITERATOR_CFA_1	SSTACK_PREPULL	6 				;restore stack
;;			PULY						;restore Y	
;;			PULX						;restore X	
;;			RTS
;				
;;Code fields:
;;============
;;FIND-CDICT ( c-addr -- c-addr 0 |  xt 1 | xt -1 )  
;;Find the definition named in the terminated string at c-addr. If the definition is
;;not found, return c-addr and zero.  If the definition is found, return its
;;execution token xt.  If the definition is immediate, also return one (1),
;;otherwise also return minus-one (-1).  For a given string, the values returned
;;by FIND-CDICT while compiling may differ from those returned while not compiling. 
;; args:   PSP+0: terminated string to match dictionary entry
;; result: PSP+0: 1 if match is immediate, -1 if match is not immediate, 0 in
;;         	 case of a mismatch
;;  	  PSP+2: execution token on match, input string on mismatch
;; SSTACK: 8 bytes
;; PS:     1 cell
;; RS:     1 cell
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_PSUF
;CF_FIND_CDICT		EQU	*
;			;Check PS
;			PS_CHECK_UFOF	1, 1 		;new PSP -> Y
;			;Search core directory (PSP in Y)
;			LDX	2,Y
;			FCDICT_FIND 			;(SSTACK: 8 bytes)
;			FOUTER_FIND_FORMAT		;(SSTACK: 2 bytes)
;			STD	0,Y
;			STX	2,Y
;			;Done
;			NEXT
;
;;WORDS-CDICT ( -- )
;;List the definition names in the core dictionary in alphabetical order.
;; args:   none
;; result: none
;; SSTACK: 8 bytes
;; PS:     FCDICT_TREE_DEPTH+3 cells
;; RS:     2 cells
;; throws:  FEXCPT_EC_PSOF
;CF_WORDS_CDICT		EQU	*
;			;PS layout:
;			; +--------+--------+
;			; |                 | PSP+0
;			; +                 +
;			; :     Iterator    :
;			; +                 +
;			; |                 | PSP+(2*FCDICT_TREE_DEPTH)
;			; +--------+--------+
;			; |  Iterator ptr   | PSP+(2*FCDICT_TREE_DEPTH)+2
;			; +--------+--------+
;			; | Column counter  | PSP+(2*FCDICT_TREE_DEPTH)+4
;			; +--------+--------+
;CF_WORDS_CDICT_ITPTR	EQU	(2*(FCDICT_TREE_DEPTH+1)) 	;iterator pointer offset
;CF_WORDS_CDICT_COLCNT	EQU	(2*(FCDICT_TREE_DEPTH+2)) 	;column counter offset
;			;Print header
;			PS_PUSH	#FCDICT_WORDS_HEADER
;			EXEC_CF	CF_STRING_DOT
;			;Allocate stack space
;			PS_CHECK_OF	FCDICT_TREE_DEPTH+3 	;new PSP -> Y
;			STY	PSP
;			;Initialize iterator and column counter (PSP in Y)
;			FCDICT_ITERATOR_FIRST 			;initialize iterator
;			MOVW #FCDICT_LINE_WIDTH, CF_WORDS_CDICT_COLCNT,Y;initialize column counter
;			;Check column width (PSP in Y)
;CF_WORDS_CDICT_1	FCDICT_ITERATOR_WC 			;word length -> D (SSTACK: 6 bytes)
;			TFR	D, X                            ;word length -> X
;			ADDD	CF_WORDS_CDICT_COLCNT,Y		;add to line width
;			CPD	#(FCDICT_LINE_WIDTH+1)		;check line width
;			BLS	CF_WORDS_CDICT_2 		;insert white space
;			;Insert line break (PSP in Y, word length in X)			
;			STX	CF_WORDS_CDICT_COLCNT,Y		;set column counter
;			EXEC_CF	CF_CR 				;print line break
;			JOB	CF_WORDS_CDICT_3		;print word
;			;Insert white space (PSP in Y, new column count in D)			
;CF_WORDS_CDICT_2	ADDD	#1				;count space char
;			STD	CF_WORDS_CDICT_COLCNT,Y		;update column counter
;			EXEC_CF	CF_SPACE			;print whitespace
;			;Print word						
;CF_WORDS_CDICT_3	LDY	PSP				;PSP -> Y
;			STY	CF_WORDS_CDICT_ITPTR,Y		;reset itertator pointer
;			LDX	0,Y				;substring -> X
;CF_WORDS_CDICT_4	PS_PUSH_X				;print substring
;			EXEC_CF	CF_STRING_DOT			;
;			LDY	PSP				;PSP -> Y
;			LDX	CF_WORDS_CDICT_ITPTR,Y		;get itertator pointer
;			LEAX	2,X				;get substring pointer
;			STX	CF_WORDS_CDICT_ITPTR,Y		;update itertator pointer
;			LDX	0,X				;substring -> X
;			BEQ	CF_WORDS_CDICT_5	 	;substring exists
;			TST	0,X				;check for empty substring
;			BNE	CF_WORDS_CDICT_4
;			;Skip to next word						
;CF_WORDS_CDICT_5	LDY	PSP				;iterator pointer -> Y
;			FCDICT_ITERATOR_NEXT			;advance iterator (SSTACK: 6 bytes)
;			TST	0,Y				;check for empty iterator
;			BNE	CF_WORDS_CDICT_1		;print next word
;			;Clean up (PSP in Y)						
;                	PS_CHECK_UF	FCDICT_TREE_DEPTH+3 	;PSP -> Y
;			LEAY	(2*(FCDICT_TREE_DEPTH+3)),Y
;			STY	PSP
;			NEXT

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

;#Header line for WORDS output 
FCDICT_WORDS_HEADER	STRING_NL_NONTERM
			FCS	"Core Dictionary:"
			;FCS	"CDICT:"
			
;#Dictionary tree
FCDICT_TREE_START	EQU	*	
FCDICT_TREE		FCDICT_TREE
FCDICT_TREE_END		EQU	*	

FCDICT_TABS_END		EQU	*
FCDICT_TABS_END_LIN	EQU	@
