;###############################################################################
;# S12CForth - FTOOLS - ANS Forth Programming Tool Words                       #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    This module defines the format of word entries in the Forth dictionary   #
;#    and it implements the basic vocabulary.                                  #
;###############################################################################
;# Version History:                                                            #
;#    April 22, 20010                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    FCORE  - Forth Core Module                                               #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Prevents idle loop from entering WAIT mode.                      #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FTOOLS_VARS_START
FTOOLS_VARS_END		EQU	*
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FTOOLS_INIT, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FTOOLS_CODE_START
;Common subroutines:
;=================== 	
;#Skip to the next [IF], [ELSE], or [THEN] in the TIB 
; args:   none
; result: X: jump table index
;            0: [IF]
;            2: [ELSE]
;            4: [THEN]
; SSTACK: 18 bytes
;         Y and D are preserved
FTOOLS_SKIP		EQU	*	
			;Save registers
			SSTACK_PSHD			;save accu D
			;Parse the next name
FTOOLS_SKIP_1		SSTACK_JOBSR	FCORE_NAME 	;string pointer -> X, char count -> A (SSTACK: 5 bytes)
			;Check for end of line
			TBEQ	X, FTOOLS_SKIP_5 	;parse a new line 
			;Check character count (string pointer in X, char count in A)
			CMPA	#4
			BEQ	FTOOLS_SKIP_4 		;4 chars like [IF]
			CMPA	#6
			BNE	FTOOLS_SKIP_1 		;parse next word
			;6 chars like [ELSE] or [THEN] (string pointer in X)
			LDD	0,X
			CPD	#"[E"
			BEQ	FTOOLS_SKIP_3 		;starts with "[E"
			CPD	#"[T"
			BNE	FTOOLS_SKIP_1 		;parse next word
			;Starts with "[T" (string pointer in X)
			LDD	2,X
			CPD	#"HE"
			BNE	FTOOLS_SKIP_1 		;parse next word
			LDD	4,X
			CPD	#(("N]")|$0080)
			BNE	FTOOLS_SKIP_1 		;parse next word
			LDX	#4
			;Done
FTOOLS_SKIP_2		SSTACK_PULD			;restore accu D
			SSTACK_RTS
			;Starts with "[E" (string pointer in X)
FTOOLS_SKIP_3		LDD	2,X
			CPD	#"LS"
			BNE	FTOOLS_SKIP_1 		;parse next word
			LDD	4,X
			CPD	#(("E]")|$0080)
			BNE	FTOOLS_SKIP_1 		;parse next word
			LDX	#2
			;Done
			JOB	FTOOLS_SKIP_2
			;4 chars like [IF]
FTOOLS_SKIP_4		LDD	0,X
			CPD	#"[I"
			BNE	FTOOLS_SKIP_1 		;parse next word
			LDD	2,X
			CPD	#(("F]")|$0080)
			BNE	FTOOLS_SKIP_1 		;parse next word
			LDX	#0
			;Done
			JOB	FTOOLS_SKIP_2
			;Parse a new line
FTOOLS_SKIP_5		PRINT_LINE_BREAK		;send input prompt (SSTACK: 11 bytes)				
			LDX	#FCORE_SKIP_PROMPT
			PRINT_STR			;(SSTACK: 14 bytes)
			SSTACK_JOBSR	FCORE_QUERY	;(SSTACK: 6 bytes)
			JOB	FTOOLS_SKIP_1 		;parse next word
	
;Exceptions:
;=========== 	
FTOOLS_THROW_PSOF	EQU	FMEM_THROW_PSOF			;"Parameter stack overflow"
FTOOLS_THROW_PSUF	EQU	FMEM_THROW_PSUF			;"Parameter stack underflow"
FTOOLS_THROW_RSOF	EQU	FMEM_THROW_RSOF			;"Return stack overflow"
FTOOLS_THROW_RSUF	EQU	FMEM_THROW_RSUF 		;"Return stack underflow"
FTOOLS_THROW_COMPONLY	EQU	FCORE_THROW_COMPONLY 		;"Compile-only word"
	
FTOOLS_CODE_END		EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FTOOLS_TABS_START
FTOOLS_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FTOOLS_WORDS_START ;(previous NFA: FTOOLS_PREV_NFA)

;#Programming-Tools words (TOOLS):
; ================================

;.S ( -- )
;Copy and display the values currently on the data stack. The format of the
;display is implementation-dependent.
;.S may be implemented using pictured numeric output words. Consequently, its
;use may corrupt the transient region identified by #>.
;	
;S12CForth implementation details:
; SSTACK: 24 bytes
;
			ALIGN	1
NFA_DOT_S		FHEADER, ".S", FTOOLS_PREV_NFA, COMPILE
CFA_DOT_S		DW	CF_DOT_S
			;Print header 
CF_DOT_S		PRINT_LINE_BREAK		;(SSTACK: 11 bytes)
			LDX	#CF_DOT_S_HEAD1
			PRINT_STR			;(SSTACK: 14 bytes)
			;Determine the number of PS entries
			LDD	#PS_EMPTY
			SUBD	PSP
			;BEQ	CF_DOT_S_2 		;PS is empty
			BLS	CF_DOT_S_2 		;PS is empty
			LSRD				;number of PS entries -> D
			TFR	D, Y			;current index -> Y
			;Print the rest of the header 
			LDX	#CF_DOT_S_HEAD2
			PRINT_STR			;(SSTACK: 14 bytes)
			;Print line break
CF_DOT_S_1		PRINT_LINE_BREAK		;(SSTACK: 11 bytes)	
			;Print current PS index (highest index in D, current index in Y)
			TFR	D, X 			;calculate max. index width
			LDAB	#10
			;LDAB	BASE+1
			PRINT_UINTCNT			;args: X:integer, B:base
							;number of digits -> A (SSTACK: 13 bytes)
			TFR	Y, X			;print current index
			PRINT_RUINT			;args: X:integer, A:width, B:base (SSTACK: 24 bytes)
			LDAB	#":"			;print colon
			PRINT_CHAR
			;Calculate width of output (current index in Y)
			LDX	#$8000 			;calculate max. data width
			LDAB	BASE+1
			PRINT_SINTCNT			;args: X:integer, B:base
							;number of digits -> A (SSTACK: 13 bytes)
			INCA				;additional whitespace			
			;INCA				;additional whitespace
			;Print current PS cell (current index in Y, BASE in B, output width in A)
			TFR	Y, X			;calculate current stack address
			EXG	X, D
			SUBD	#1
			LSLD
			ADDD	PSP
			EXG	D, X
			LDX	0,X                     ;read current cell
			PRINT_RSINT			;args: X:integer, A:width, B:base (SSTACK: 24 bytes)
			;Prepare next iteration (current index in Y)
			DBEQ	Y, CF_DOT_S_3 		;done
			LDD	#PS_EMPTY		;determine width of PS index
			SUBD	PSP
			LSRD				;number of PS entries -> D
			JOB	CF_DOT_S_1
			;PS is empty 
CF_DOT_S_2		LDX	#CF_DOT_S_EMPTY
			PRINT_STR 			;args: X:string			
			;Done 
CF_DOT_S_3		;PRINT_LINE_BREAK		;new line (SSTACK: 11 bytes)
			NEXT
	
CF_DOT_S_HEAD1		FCS	"Parameter stack"
CF_DOT_S_HEAD2		FCS	":"
CF_DOT_S_EMPTY		FCS	" is empty!"

;? ( a-addr -- )
;Display the value stored at a-addr.
;? may be implemented using pictured numeric output words. Consequently, its use
;may corrupt the transient region identified by #>.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_QUESTION		FHEADER, "?", NFA_DOT_S, COMPILE
CFA_QUESTION		DW	CF_QUESTION
CF_QUESTION		PS_PULL_X	CF_QUESTION_PSUF ;check for underflow  (PSP -> Y)
			PRINT_SPC			;print space
			LDX	0,X			;print variable
			LDAB	BASE+1
			PRINT_SINT			;args: X:integer, B:base (SSTACK: 24 bytes)
			NEXT

CF_QUESTION_PSUF	JOB	FTOOLS_THROW_PSUF

;DUMP ( addr u -- )
;Display the contents of u consecutive addresses starting at addr. The format of
;the display is implementation dependent.
;DUMP may be implemented using pictured numeric output words. Consequently, its
;use may corrupt the transient region identified by #>.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
CF_DUMP_PSUF		JOB	FTOOLS_THROW_PSUF 	;(fits better here)
	
			ALIGN	1
NFA_DUMP		FHEADER, "DUMP", NFA_QUESTION, COMPILE
CFA_DUMP		DW	CF_DUMP
CF_DUMP			PS_CHECK_UF	2, CF_DUMP_PSUF ;check for underflow (PSP -> Y)
			;Check if u>0 (PSP -> Y)
			LDD	0,Y
			BEQ	CF_DUMP_7 		;nothing to do
			;Print header (PSP -> Y)
			PRINT_LINE_BREAK		;new line (SSTACK: 11 bytes)
			LDX	#CF_DUMP_HEADER
			PRINT_STR 			;args: X:string
			;Calculate end address (PSP in Y)
			LDD	2,Y 			;load start address
			TFR	D, X			;start address -> X
			ADDD	0,Y			;calculate end address
			STD	0,Y			;replace u by end address
			;Calculate block address (PSP in Y, start address in X)
			TFR	X, D			;calculate block address
			ANDB	#$F0
			STD	2,Y			;replace start address by block address	
			;Print base block address (PSP in Y, start address in X, block address in D)
CF_DUMP_1		PRINT_LINE_BREAK		;new line (SSTACK: 11 bytes)
			PRINT_WORD			;args: D:number (SSTACK: 16 bytes)
			;Print leading spaces (PSP in Y, current address in X, block address in D)
			TFR	X, D 			;calculate the number of leading spaces
			SUBD	2,Y			;number of missing bytes -> B
			BEQ	CF_DUMP_3 		;no spaces required							
			LDAA	#3			;3 spaces per missing byte
CF_DUMP_2		PRINT_SPCS			;args: A:spaces (SSTACK: 12 bytes)
			DBNE	B, CF_DUMP_2
			;Calculate next block address (PSP in Y) 
CF_DUMP_3		LDD	2,Y
			ADDD	#$10
			STD	2,Y	
			;Print data (PSP in Y, current address in X)
CF_DUMP_4		PRINT_SPC 			;print 1 space
			LDAB	1,X+			;print byte
			PRINT_BYTE
			CPX	0,Y 			;check if end address has been reached
			BEQ	CF_DUMP_5		;done
			CPX	2,Y			;check if end of line has been reached
			BNE	CF_DUMP_4		;more bytes to print in this line
			;Print next line (PSP in Y, current address in X)
			LDD	2,Y
			JOB	CF_DUMP_1
			;Print trailing spaces (PSP in Y)
CF_DUMP_5		LDD	2,Y
			SUBD	0,Y
			BEQ	CF_DUMP_7			
			LDAA	#3			;3 spaces per missing byte
CF_DUMP_6		PRINT_SPCS			;args: A:spaces (SSTACK: 12 bytes)
			DBNE	B, CF_DUMP_6
			;Done (PSP in Y)
CF_DUMP_7		LEAY	4,Y
			STY	PSP
			NEXT			
		
;CF_DUMP_HEADER		FCS	"---- -0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -A -B -C -D -E -F"		
;CF_DUMP_HEADER		FCS	"------0--1--2--3--4--5--6--7--8--9--A--B--C--D--E--F"		
;CF_DUMP_HEADER		FCS	"____ _0 _1 _2 _3 _4 _5 _6 _7 _8 _9 _A _B _C _D _E _F"		
CF_DUMP_HEADER		FCS	"______0__1__2__3__4__5__6__7__8__9__A__B__C__D__E__F"		
	
;SEE ( "<spaces>name" -- )
;Display a human-readable representation of the named word's definition. The
;source of the representation (object-code decompilation, source block, etc.)
;and the particular form of the display is implementation defined.
;SEE may be implemented using pictured numeric output words. Consequently, its
;use may corrupt the transient region identified by #>.
NFA_SEE			EQU	NFA_DUMP
;			ALIGN	1
;NFA_SEE		FHEADER, "SEE", NFA_DUMP, COMPILE
;CFA_SEE		DW	CF_SEE
;CF_SEE			NEXT

;WORDS ( -- )
;List the definition names in the first word list of the search order. The
;format of the display is implementation-dependent.
;WORDS may be implemented using pictured numeric output words. Consequently, its
;use may corrupt the transient region identified by #>.
			ALIGN	1
NFA_WORDS		FHEADER, "WORDS", NFA_SEE, COMPILE
CFA_WORDS		DW	CF_WORDS
CF_WORDS
			;Print line break
			LDY	LAST_NFA		;current NFA -> Y
			CLRB				;remaining chars -> B
				
			;Print next word (current NFA in Y, remaining chars -> B)
CF_WORDS_1		LEAX	3,Y	     		;current string pointer -> X
			PRINT_STRCNT			;string length -> A
			INCA				;add one whitespace
			EXG	A, B
			SBA
			EXG	A, B
			BCS	CF_WORDS_3 		;line is too long
			PRINT_SPC			;print whitespace
CF_WORDS_2		PRINT_STR 			;print string (args: X:string)
			LDY	0,Y			;advance NFA pointer
			BNE	CF_WORDS_1		;more words to display
			TBA
			PRINT_SPCS
			NEXT			
			;Start a new line (current NFA in Y, current string pointer -> X, remaining chars -1 in B)
CF_WORDS_3		PRINT_LINE_BREAK		;new line (SSTACK: 11 bytes)
			LDAB	#(CF_WORDS_LINE_WIDTH+1)
			EXG 	A, B
			SBA
			EXG	A, B
			JOB	CF_WORDS_2

CF_WORDS_LINE_WIDTH	EQU	75

;#Programming-Tools extension words (TOOLS EXT):
; ==============================================
	
;;CODE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation:    ( C: colon-sys -- )
;Append the run-time semantics below to the current definition. End the current
;definition, allow it to be found in the dictionary, and enter interpretation
;state, consuming colon-sys.
;Subsequent characters in the parse area typically represent source code in a
;programming language, usually some form of assembly language. Those characters
;are processed in an implementation-defined manner, generating the corresponding
;machine code. The process continues, refilling the input buffer as needed,
;until an implementation-defined ending sequence is processed.
;Run-time:       ( -- ) ( R: nest-sys -- )
;Replace the execution semantics of the most recent definition with the name
;execution semantics given below. Return control to the calling definition
;specified by nest-sys. An ambiguous condition exists if the most recent
;definition was not defined with CREATE or a user-defined word that calls
;CREATE.
;name Execution: ( i*x -- j*x )
;Perform the machine code sequence that was generated following ;CODE.
NFA_SEMICOLON_CODE	EQU	NFA_WORDS 
;			ALIGN	1
;NFA_SEMICOLON_CODE	FHEADER, ";CODE", NFA_WORDS, COMPILE 
;CFA_SEMICOLON_CODE	DW	CF_DUMMY

;AHEAD 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation:    ( C: -- orig )
;Put the location of a new unresolved forward reference orig onto the control
;flow stack. Append the run-time semantics given below to the current
;definition. The semantics are incomplete until orig is resolved
;(e.g., by THEN).
;        Run-time: ( -- )
;Continue execution at the location specified by the resolution of orig.
NFA_AHEAD		EQU	NFA_SEMICOLON_CODE

;ASSEMBLER ( -- )
;Replace the first word list in the search order with the ASSEMBLER word list.
;
;S12CForth implementation details:
;not implemented 
NFA_ASSEMBLER		EQU	NFA_AHEAD

;BYE ( -- )
;Return control to the host operating system, if any.
			ALIGN	1
NFA_BYE			FHEADER, "BYE", NFA_ASSEMBLER, COMPILE 
CFA_BYE			DW	CF_QUIT

;CODE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name, called a code definition, with the execution semantics
;defined below.
;Subsequent characters in the parse area typically represent source code in a
;programming language, usually some form of assembly language. Those characters
;are processed in an implementation-defined manner, generating the corresponding
;machine code. The process continues, refilling the input buffer as needed,
;until an implementation-defined ending sequence is processed.
;name Execution: ( i*x -- j*x )
;Execute the machine code sequence that was generated following CODE.
NFA_CODE		EQU	NFA_BYE
;			ALIGN	1
;NFA_CODE		FHEADER, "CODE", NFA_BYE, COMPILE 
;CFA_CODE		DW	CF_DUMMY

;CS-PICK
;Interpretation: Interpretation semantics for this word are undefined.
;Execution:      ( C: destu ... orig0|dest0 -- destu ... orig0|dest0 destu )
;                ( S: u -- )
;Remove u. Copy destu to the top of the control-flow stack. An ambiguous
;condition exists if there are less than u+1 items, each of which shall be an
;orig or dest, on the control-flow stack before CS-PICK is executed.
;If the control-flow stack is implemented using the data stack, u shall be the
;topmost item on the data stack.
NFA_C_S_PICK		EQU	NFA_CODE 

;CS-ROLL 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution:      ( C: origu|destu origu-1|destu-1 ... orig0|dest0 --
;                 origu-1|destu-1 ... orig0|dest0 origu|destu )( S: u -- )
;Remove u. Rotate u+1 elements on top of the control-flow stack so that
;origu|destu is on top of the control-flow stack. An ambiguous condition exists
;if there are less than u+1 items, each of which shall be an orig or dest, on
;the control-flow stack before CS-ROLL is executed.
;If the control-flow stack is implemented using the data stack, u shall be the
;topmost item on the data stack.
NFA_C_S_ROLL		EQU	NFA_C_S_PICK

;EDITOR ( -- )
;Replace the first word list in the search order with the EDITOR word list.
;
;S12CForth implementation details:
;not implemented 
NFA_EDITOR		EQU	NFA_C_S_ROLL 

;FORGET ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Find name, then
;delete name from the dictionary along with all words added to the dictionary
;after name. An ambiguous condition exists if name cannot be found.
;If the Search-Order word set is present, FORGET searches the compilation word
;list. An ambiguous condition exists if the compilation word list is deleted.
;An ambiguous condition exists if FORGET removes a word required for correct
;execution.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
;
;S12CForth implementation details:
;Throws:
;"Missing name argument"
;"Undefined word"
;
			ALIGN	1
NFA_FORGET		FHEADER, "FORGET", NFA_EDITOR, COMPILE 
CFA_FORGET		DW	CF_FORGET
CF_FORGET		;Parse name
			SSTACK_JOBSR	FCORE_NAME 		;(SSTACK: 5 bytes)
			TBEQ	X, CF_FORGET_NONAME
			;Find NFA in dictionary (string pointer in X) 
			SSTACK_JOBSR	FCORE_FIND_NFA 		;(SSTACK: 8 bytes)			
			TBEQ	X, CF_FORGET_UDEFWORD
			;Restore old last NFA 
			MOVW	0,X, LAST_NFA
			;See if the word is located in RAM (NFA in X)
			CPX	#DICT_START
			BLE	CF_FORGET_2 			;name not in user dictionary
			CPX	#DICT_MAX
			BGT	CF_FORGET_2 			;name not in user dictionary
			;Name is in user dictionary (NFA in X)
CF_FORGET_1		STX	CP
			STX	CP_SAVED
			;Done
			NEXT
			;Name is in user sictionary (NFA in X)
CF_FORGET_2		LDX	#DICT_START
			JOB	CF_FORGET_1

CF_FORGET_NONAME	JOB	FCORE_THROW_NONAME
CF_FORGET_UDEFWORD	JOB	FCORE_THROW_UDEFWORD
	
;STATE ( -- a-addr )
;Extend the semantics of 6.1.2250 STATE to allow ;CODE to change the value in
;STATE. A program shall not directly alter the contents of STATE.
NFA_STATE_TOOLS		EQU	NFA_FORGET
	
;[ELSE]
;Compilation: Perform the execution semantics given below.
;Execution:   ( "<spaces>name" ... -- )
;Skipping leading spaces, parse and discard space-delimited words from the parse
;area, including nested occurrences of [IF] ... [THEN] and
;[IF] ... [ELSE] ... [THEN], until the word [THEN] has been parsed and
;discarded. If the parse area becomes exhausted, it is refilled as with REFILL.
;[ELSE] is an immediate word.
;
;S12CForth implementation details:
;Throws:
;"Return stack overflow"
;"Return stack underflow"
;"Compile-only word"
;
			ALIGN	1
NFA_BRACKET_ELSE	FHEADER, "[ELSE]", NFA_STATE_TOOLS, IMMEDIATE
CFA_BRACKET_ELSE	DW	CF_BRACKET_ELSE
CF_BRACKET_ELSE		COMPILE_ONLY	CF_BRACKET_IF_COMPONLY	;ensure that compile mode is on
			;Skip to next [THEN]. Skip over nested [IF]s.	
CF_BRACKET_ELSE_1	SSTACK_JOBSR	FTOOLS_SKIP
			JMP	[CF_BRACKET_ELSE_TAB,X]

CF_BRACKET_ELSE_TAB	DW	CF_BRACKET_ELSE_3 		;[IF]
			DW	CF_BRACKET_ELSE_1		;[ELSE]
			DW	CF_BRACKET_ELSE_2		;[THEN]

			;Done 
CF_BRACKET_ELSE_2	NEXT
			;Nested [IF]
CF_BRACKET_ELSE_3	EXEC_CF	CF_BRACKET_ELSE, CF_BRACKET_ELSE_RSOF, CF_BRACKET_ELSE_RSUF
			JOB	CF_BRACKET_ELSE_1	
	
CF_BRACKET_ELSE_RSUF		JOB	FTOOLS_THROW_RSUF
CF_BRACKET_ELSE_RSOF		JOB	FTOOLS_THROW_RSOF
CF_BRACKET_ELSE_COMPONLY	JOB	FTOOLS_THROW_COMPONLY

;[IF]
;Compilation: Perform the execution semantics given below.
;Execution:  ( flag | flag "<spaces>name" ... -- )
;If flag is true, do nothing. Otherwise, skipping leading spaces, parse and
;discard space-delimited words from the parse area, including nested occurrences
;of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], until either the word [ELSE]
;or the word [THEN] has been parsed and discarded. If the parse area becomes
;exhausted, it is refilled as with REFILL. [IF] is an immediate word.
;An ambiguous condition exists if [IF] is POSTPONEd, or if the end of the input
;buffer is reached and cannot be refilled before the terminating [ELSE] or
;[THEN] is parsed.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Return stack overflow"
;"Return stack underflow"
;"Compile-only word"
;
			ALIGN	1
NFA_BRACKET_IF		FHEADER, "[IF]", NFA_BRACKET_ELSE, IMMEDIATE 
CFA_BRACKET_IF		DW	CF_BRACKET_IF
CF_BRACKET_IF		COMPILE_ONLY	CF_BRACKET_IF_COMPONLY	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_BRACKET_IF_PSUF	;(PSP -> Y)
			;Check flag (PSP in Y) 
			LDD	2,Y+
			STY	PSP
			TBNE	D, CF_BRACKET_IF_2		;do nothing
			;Done 
			;Skip to next [ELSE] or [THEN]. Skip over nested [IF]s.	
CF_BRACKET_IF_1		SSTACK_JOBSR	FTOOLS_SKIP
			TBEQ	X, CF_BRACKET_IF_3
			;Done 
CF_BRACKET_IF_2		NEXT
			;nested [IF]
CF_BRACKET_IF_3		EQU	CF_BRACKET_ELSE_1
		
CF_BRACKET_IF_PSUF	JOB	FTOOLS_THROW_PSUF
CF_BRACKET_IF_COMPONLY	JOB	FTOOLS_THROW_COMPONLY

;[THEN]
;Compilation: Perform the execution semantics given below.
;Execution:   ( -- )
;Does nothing. [THEN] is an immediate word.
;
;S12CForth implementation details:
;Throws:
;"Compile-only word"
;
			ALIGN	1
NFA_BRACKET_THEN	FHEADER, "[THEN]", NFA_BRACKET_IF, IMMEDIATE
CFA_BRACKET_THEN	DW	CF_BRACKET_THEN
CF_BRACKET_THEN		COMPILE_ONLY	CF_BRACKET_THEN_COMPONLY	;ensure that compile mode is on
			;Done 
			NEXT
			
CF_BRACKET_THEN_COMPONLY	JOB	FTOOLS_THROW_COMPONLY
	
;.RS ( -- ) !!! Not part of the ANS Forth standard !!!
;Copy and display the values currently on the data stack. The format of the
;display is implementation-dependent.
;.S may be implemented using pictured numeric output words. Consequently, its
;use may corrupt the transient region identified by #>.
;	
;S12CForth implementation details:
; SSTACK: 24 bytes
;
			ALIGN	1
NFA_DOT_RS		FHEADER, ".RS", NFA_BRACKET_THEN, COMPILE
CFA_DOT_RS		DW	CF_DOT_RS
			;Print header 
CF_DOT_RS		PRINT_LINE_BREAK		;(SSTACK: 11 bytes)
			LDX	#CF_DOT_RS_HEAD1
			PRINT_STR			;(SSTACK: 14 bytes)
			;Determine the number of RS entries
			LDD	#RS_EMPTY
			SUBD	RSP
			;BEQ	CF_DOT_RS_2 		;RS is empty
			BLS	CF_DOT_RS_2 		;RS is empty
			LSRD				;number of RS entries -> D
			TFR	D, Y			;current index -> Y
			;Print the rest of the header 
			LDX	#CF_DOT_RS_HEAD2
			PRINT_STR			;(SSTACK: 14 bytes)
			;Print line break
CF_DOT_RS_1		PRINT_LINE_BREAK		;(SSTACK: 11 bytes)	
			;Print current RS index (highest index in D, current index in Y)
			TFR	D, X 			;calculate max. index width
			LDAB	#10
			;LDAB	BASE+1
			PRINT_UINTCNT			;args: X:integer, B:base
							;number of digits -> A (SSTACK: 13 bytes)
			TFR	Y, X			;print current index
			PRINT_RUINT			;args: X:integer, A:width, B:base (SSTACK: 24 bytes)
			LDAB	#":"			;print colon
			PRINT_CHAR
			;Calculate width of output (current index in Y)
			LDX	#$FFFF 			;calculate max. data width
			;LDAB	BASE+1
			LDAB	#16
			PRINT_UINTCNT			;args: X:integer, B:base
							;number of digits -> A (SSTACK: 13 bytes)
			INCA				;additional whitespace			
			;INCA				;additional whitespace
			;Print current RS cell (current index in Y, BASE in B, output width in A)
			TFR	Y, X			;calculate current stack address
			EXG	X, D
			SUBD	#1
			LSLD
			ADDD	RSP
			EXG	D, X
			LDX	0,X                     ;read current cell
			PRINT_RUINT			;args: X:integer, A:width, B:base (SSTACK: 24 bytes)
			;Prepare next iteration (current index in Y)
			DBEQ	Y, CF_DOT_RS_3 		;done
			LDD	#RS_EMPTY		;determine width of RS index
			SUBD	RSP
			LSRD				;number of RS entries -> D
			JOB	CF_DOT_RS_1
			;RS is empty 
CF_DOT_RS_2		LDX	#CF_DOT_RS_EMPTY
			PRINT_STR 			;args: X:string			
			;Done 
CF_DOT_RS_3		;PRINT_LINE_BREAK		;new line (SSTACK: 11 bytes)
			NEXT
	
CF_DOT_RS_HEAD1		FCS	"Return stack"
;CF_DOT_RS_HEAD2	FCS	":"
CF_DOT_RS_HEAD2		EQU	CF_DOT_S_HEAD2
;CF_DOT_RS_EMPTY	FCS	" is empty!"
CF_DOT_RS_EMPTY		EQU	CF_DOT_S_EMPTY
	
FTOOLS_WORDS_END		EQU	*
FTOOLS_LAST_NFA			EQU	NFA_DOT_RS
