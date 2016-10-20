#ifndef FOUTER_COMPILED
#define FOUTER_COMPILED
;###############################################################################
;# S12CForth - FOUTER - Forth Outer Interpreter                                #
;###############################################################################
;#    Copyright 2011-2016 Dirk Heisswolf                                       #
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
;#    This module implements the outer interpreter of the S12CForth            #
;#    environment.                                                             #
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
;#           BASE = Default radix (2<=BASE<=36)                                #
;#          STATE = State of the outer interpreter:                            #
;#  		        0: Interpretation State				       #
;#  		       -1: RAM Compile State				       #
;#  		       +1: NV Compile State				       #
;#     NUMBER_TIB = Number of chars in the TIB                                 #
;#          TO_IN = In-pointer of the TIB (>IN)	       			       #
;#       	    (TIB_START+TO_IN) points to the next character	       #
;#  									       #
;#    The following notation is used to describe the stack layout in the word  #
;#    definitions:                                                             #
;#                                                                             #
;#    Symbol          Data type                       Size on stack	       #
;#    ------          ---------                       -------------	       #
;#    flag            flag                            1 cell		       #
;#    true            true flag                       1 cell		       #
;#    false           false flag                      1 cell		       #
;#    char            character                       1 cell		       #
;#    n               signed number                   1 cell		       #
;#    +n              non-negative number             1 cell		       #
;#    u               unsigned number                 1 cell		       #
;#    n|u 1           number                          1 cell		       #
;#    x               unspecified cell                1 cell		       #
;#    xt              execution token                 1 cell		       #
;#    addr            address                         1 cell		       #
;#    a-addr          aligned address                 1 cell		       #
;#    c-addr          character-aligned address       1 cell		       #
;#    d-addr          double address                  2 cells (non-standard)   #
;#    d               double-cell signed number       2 cells		       #
;#    +d              double-cell non-negative number 2 cells		       #
;#    ud              double-cell unsigned number     2 cells		       #
;#    d|ud 2          double-cell number              2 cells		       #
;#    xd              unspecified cell pair           2 cells		       #
;#    colon-sys       definition compilation          implementation dependent #
;#    do-sys          do-loop structures              implementation dependent #
;#    case-sys        CASE structures                 implementation dependent #
;#    of-sys          OF structures                   implementation dependent #
;#    orig            control-flow origins            implementation dependent #
;#    dest            control-flow destinations       implementation dependent #
;#    loop-sys        loop-control parameters         implementation dependent #
;#    nest-sys        definition calls                implementation dependent #
;#    i*x, j*x, k*x 3 any data type                   0 or more cells	       #
;#  									       #
;#    Counted strings are implemented as terminated strings. String            #
;#    termination is done by setting bit 7 in the last character of the        #   
;#    string. Pointers to empty strings have the value $0000.		       #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    February 5, 2013                                                         #
;#      - Initial release                                                      #
;#    October 4, 2016                                                          #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FTIB   - Forth text input buffer                                         #
;#    FRS    - Forth return stack                                              #
;#    FPS    - Forth parameter stack                                           #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
        
;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;                                
;                         +----------+----------+        
;        RS_TIB_START, -> |          |          | |
;           TIB_START     |  Text Input Buffer  | | [NUMBER_TIB]
;                         |          |          | |	       
;                         |          v          | <	       
;                     -+- | --- --- --- --- --- | 	       
;             TIB_PADDING .                     . <- TIB_START+[NUMBER_TIB] 
;                     -+- .                     .            
;                         | --- --- --- --- --- |            
;                         |          ^          | <- [RSP]
;                         |          |          |
;                         |    Return Stack     |
;                         |          |          |
;                         +----------+----------+
;             RS_EMPTY, ->                                 
;           RS_TIB_END
;
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#ASCII code 
FOUTER_SYM_SPACE	EQU	STRING_SYM_SPACE	;space (first printable ASCII character)

;STATE variable 
STATE_INTERPRET		EQU	 0
STATE_COMPILE		EQU	-1
STATE_NVCOMPILE		EQU	 1

;Text input buffer 
TIB_START		EQU	RS_TIB_START

;System prompts
FOUTER_INTERACT_PROMPT	EQU	">"
FOUTER_COMPILE_PROMPT	EQU	"+"
FOUTER_NVCOMPILE_PROMPT	EQU	"@"

;Max. line width
FOUTER_LINE_WIDTH	EQU	79
	
;Valid number base
FOUTER_BASE_MIN		EQU	NUM_BASE_MIN		;binary
FOUTER_BASE_MAX		EQU	NUM_BASE_MAX		;36
FOUTER_BASE_DEFAULT	EQU	NUM_BASE_DEFAULT	;default base (decimal)

;#String termination 
FOUTER_TERM		EQU	STRING_TERM

;#ASCII code 
FOUTER_SYM_BEEP		EQU	STRING_SYM_BEEP		;acoustic signal

;Boolean sumbols 
TRUE			EQU	$FFFF
FALSE			EQU	$0000	
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FOUTER_VARS_START_LIN
			ORG 	FOUTER_VARS_START, FOUTER_VARS_START_LIN
#else
			ORG 	FOUTER_VARS_START
FOUTER_VARS_START_LIN	EQU	@
#endif	
			ALIGN	1	
BASE			DS	2 		;default radix
STATE			DS	2 		;interpreter state (0:iterpreter, -1:compile)
	
FOUTER_VARS_END		EQU	*
FOUTER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FOUTER_INIT, 0
			MOVW	#10,    BASE     	;decimal
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FOUTER_ABORT, 0
			MOVW	#$0000, STATE	   	;interpretation state
#emac
	
;#Quit action
;============
#macro	FOUTER_QUIT, 0
#emac

;#System integrity monitor
;=========================
#macro	FOUTER_MON, 0
#emac

;#Word types
;===========
;REGULAR:
;Execute in interactive state, compile reference in compile state
#macro	REGULAR, 0
			DB	$00
#emac

;IMMEDIATE:
;Execute in interactive and in compile state
#macro	IMMEDIATE, 0
			DB	$FF
#emac

;INLINE:
;Execute in interactive state, compile code field in compile state
#macro	INLINE, 1
			DB	\1_EOI-\1
#emac


;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FOUTER_CODE_START_LIN
			ORG 	FOUTER_CODE_START, FOUTER_CODE_START_LIN
#else
			ORG 	FOUTER_CODE_START
FOUTER_CODE_START_LIN	EQU	@
#endif

;#IO
;===
;#Transmit one char
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FOUTER_TX_CHAR		EQU	SCI_TX_BL

;#Prints a MSB terminated string
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FOUTER_TX_STRING	EQU	STRING_PRINT_BL

;#Print cell value
; args:   D: cell value
; result: none
; SSTACK: 26 bytes
;         X, Y and D are preserved
FOUTER_TX_CELL		EQU	*
			;Save registers (cell value in D)
			PSHX					;save X
			PSHY					;save Y
			PSHD					;save D
			;Print sign (cell value in D)
			TFR	D, X		 		;cell value -> X
FOUTER_TX_CELL_1	TSTA					;check if negative
			BPL 	FOUTER_TX_CELL_2		;cell value is positive
			COMA					;1's complement -> D
			COMB					;
			ADDD	#1				;2's complement -> D
			TFR	D, X 				;negated THROW code -> X
			LDAB	#"-"				;print minus sign
			JOBSR	FEXCPT_TX_CHAR 			;(SSTACK: 8 bytes)
			;Print number (absolute cell value in X)
FOUTER_TX_CELL_2	JOBSR	FOUTER_GET_BASE			;BASE -> B
			SEI					;start of atomic sequence 
			LDY	#$0000				;0 -> Y
			JOBSR	NUM_REVERSE			;(SSTACK: 18 bytes)
			LDY	8,SP				;restore Y
			CLI					;end of atomic sequence
			JOBSR	NUM_REVPRINT_BL			;(SSTACK: 10 bytes +6 arg bytes)
			;Restore registers
			PULD					;restore D
			LEAS	2,SP				;Y has already been restored
			PULX					;restore X
			RTS					;done

;#Count the digits (incl. sign) of cell value
; args:   D: cell value
; result: D: digits (char count)
; SSTACK: 26 bytes
;         X, Y and D are preserved
FOUTER_CELL_DIGITS	EQU	*
			;Save registers (cell value in D)
			PSHX					;save X
			PSHY					;save Y
			MOVW	#$0000,	2,-SP			;allocate digit count
			;Count sign (cell value in D)
			TFR	D, X		 		;cell value -> X
			TSTA					;check if negative
			BPL 	FOUTER_CELL_DIGITS_1		;cell value is positive
			COMA					;1's complement -> D
			COMB					;
			ADDD	#1				;2's complement -> D
			TFR	D, X 				;negated THROW code -> X
			MOVB	#$01, 1,SP			;count minus sign
			;Print number (absolute cell value in X)
FOUTER_CELL_DIGITS_1	JOBSR	FOUTER_GET_BASE			;BASE -> B
			SEI					;start of atomic sequence 
			LDY	#$0000				;0 -> Y
			JOBSR	NUM_REVERSE			;(SSTACK: 18 bytes)
			LDY	8,SP				;restore Y
			CLI					;end of atomic sequence
			NUM_CLEAN_REVERSE			;clean up stack
			TFR	A, D				;char count -> D
			CLRA
			ADDD	2,SP+				;add sign 
			;Restore registers (char count in D)
			PULY					;restore Y
			PULX					;restore X
			RTS					;done
	
;#Print a list separator (SPACE or line break)
; args:   D:      char count of next word
;         0,SP:   line counter 
; result: 0,SP;   updated line counter
; SSTACK: 10 bytes
;         Y is preserved
FOUTER_LIST_SEP		EQU	*
			;Add char count to line counter
			ADDD	2,SP 			;add char count 
			CPD	#FOUTER_LINE_WIDTH	;check line width
			BHS	FOUTER_LIST_SEP_1	;line break required
			;Print SPACE (line counter in D)  
			ADDD	#1 			;count SPACE
			STD	2,SP			;update line counter
			JOB	CF_SPACE		;print SPACE
			;Print line break (line counter in D)  
FOUTER_LIST_SEP_1	SUBD	2,SP 			;restore char count
			STD	2,SP			;update line counter
			JOB	CF_CR			;print line break

;#String operations
;==================
;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character 
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
FOUTER_UPPER		EQU	STRING_UPPER

;#Numbers
;========
;#Fix and load BASE
; args:   BASE: any base value
; result: B:    range adjusted base value (2<=base<=FOUTER_BASE_MAX)
;         BASE: range adjusted base value (2<=base<=FOUTER_BASE_MAX)
; SSTACK: 2 bytes
;         X, Y, and A are preserved
;FOUTER_FIX_BASE		EQU	*
;			;Check BASE value
;			TST	BASE 			;check upper byte
;			BNE	FOUTER_FIX_BASE_1	;BASE >255
;			LDAB	BASE+1 			;BASE -> B
;			CMPB	#FOUTER_BASE_MAX	;compare BASE against upper limit
;			BHI	FOUTER_FIX_BASE_1	;BASE value is too high
;			CMPB	#FOUTER_BASE_MIN	;compare BASE against lower limit
;			BHS	FOUTER_FIX_BASE_2	;BASE is value within valid range
;FOUTER_FIX_BASE_1	LDAB	#FOUTER_BASE_DEFAULT	;return default value
;			MOVW	#FOUTER_BASE_DEFAULT, BASE;update BASE
;FOUTER_FIX_BASE_2	RTS				;done

;#Load BASE
; args:   BASE: any base value
; result: B:    range checked base value (2<=base<=FOUTER_BASE_MAX)
; SSTACK: 2 bytes
;         X, Y, and A are preserved
FOUTER_GET_BASE		EQU	*
			;Check BASE value			
			TST	BASE 			;check upper byte
			BNE	FOUTER_GET_BASE_1	;BASE >255
			LDAB	BASE+1 			;BASE -> B
			CMPB	#FOUTER_BASE_MAX	;compare BASE against upper limit
			BLS	FOUTER_GET_BASE_2	;BASE value valid			
FOUTER_GET_BASE_1	THROW	FEXCPT_TC_INVALBASE	;throw exception
FOUTER_GET_BASE_2	RTS				;done

;#Parse number prefix
; args:   X: string pointer    
;         D: char count
; result: X: updated string pointer
;         A: sign (-1=negative, 0=positive)
;         B: base
; SSTACK: 10 bytes
;         X, Y, and B are preserved
FOUTER_PREFIX		EQU	*
			;Save registers (string pointer in X, char count on D)
			EXG	D, X 			;D <-> X
			LEAX	D,X			;calculate end of string
			PSHX				;end of string  -> 2,SP
			EXG	D, X 			;D <-> X
			CLRA				;positive sign  -> A
			;JOBSR	FOUTER_FIX_BASE		;base           -> B (SSTACK: 2 bytes)
			JOBSR	FOUTER_GET_BASE		;base           -> B (SSTACK: 2 bytes)
			PSHD				;sign:base      -> 0,SP
			;Check for empty string (string pointer in X sign:base in D)
			CPX	2,SP 			;check for empty string
			BEQ	FOUTER_PREFIX_6		;do nothing
			;Sign (string pointer in X) 
			LDAA	1,X+ 			;first char -> A
			CPX	2,SP			;check for more chars
			BEQ	FOUTER_PREFIX_5		;last char (revert parsing)
			CMPA	#"-"			;check for sign
			BNE	FOUTER_PREFIX_1		;no sign change
			MOVB	#$FF, 0,SP		;set negative sign
			LDAA	1,X+ 			;next char -> A
			CPX	2,SP			;check for more chars
			BEQ	FOUTER_PREFIX_5		;last char (revert parsing)
			;Leading zero (string pointer in X, char in A)
FOUTER_PREFIX_1		CMPA	#"0"			;check for sign
			BNE	FOUTER_PREFIX_7		;check ASM-style prefix
			LDAA	1,X+ 			;first char -> A
			CPX	2,SP			;check for more chars
			BEQ	FOUTER_PREFIX_5		;last char (revert parsing)
			;C-style prefix (string pointer in X, char in A)
			PSHX				;save string pointer
			LDX	#FOUTER_C_PFTAB		;C-prefix table -> X
			LDAB	#FOUTER_C_PFTAB_CNT 	;entry count -> B
FOUTER_PREFIX_2		CMPA	2,X+			;check table entry
			BEQ	FOUTER_PREFIX_9 	;C-style prefix found
			DBNE	B, FOUTER_PREFIX_2	;check next table entry
			PULX				;restore string pointer
			;Skip zeros and underscores (string pointer in X)
			JOB	FOUTER_PREFIX_4		;check for underscore
FOUTER_PREFIX_3		LDAA	1,X+ 			;first char -> A
			CPX	2,SP			;check for more chars
			BEQ	FOUTER_PREFIX_5		;last char (revert parsing)
FOUTER_PREFIX_4		CMPA	#"_"			;check for underscore
			BEQ	FOUTER_PREFIX_3		;skip underscore
			CMPA	#"0"			;check for zero
			BEQ	FOUTER_PREFIX_3		;skip zero
			;Return results (string pointer in X)
FOUTER_PREFIX_5		LEAX	-1,X  			;revert parser to current char
			LDD	4,SP+			;sign:base -> A:B
FOUTER_PREFIX_6		RTS				;done
			;ASM-style prefix (string pointer in X, char in A)
FOUTER_PREFIX_7		PSHX				;save string pointer
			LDX	#FOUTER_ASM_PFTAB	;ASM-prefix table -> X
			LDAB	#FOUTER_ASM_PFTAB_CNT 	;entry count -> B
FOUTER_PREFIX_8		CMPA	2,X+			;check table entry
			BEQ	FOUTER_PREFIX_10 	;ASM-style prefix found
			DBNE	B, FOUTER_PREFIX_8	;check next table entry
			PULX				;restore string pointer
			JOB	FOUTER_PREFIX_5		;prefix parsed
			;C-style prefix found (table pointer in X)
FOUTER_PREFIX_9		MOVB	-1,X, 3,SP 		;update base
			PULX				;restore string pointer
			JOB	FOUTER_PREFIX_3		;skip zeros and underscores
			;ASM-style prefix found (table pointer in X)
FOUTER_PREFIX_10	MOVB	-1,X, 3,SP 		;update base
			PULX				;restore string pointer
			LDAA	1,X+ 			;first char -> A
			CPX	2,SP			;check for more chars
			BEQ	FOUTER_PREFIX_5		;last char (revert parsing)
			CMPA	#"-"			;check second sign position
			BNE	FOUTER_PREFIX_4		;check for zero
			TST	0,SP			;check if result is already negative
			BNE	FOUTER_PREFIX_5		;result is already negative
			MOVB	#$FF, 0,SP		;set negative sign
			JOB	FOUTER_PREFIX_3		;skip zeros and underscores

;#Multiply double integer by base and add new digit
; args:   A:      digit    
;         B:      base
;         X:      number pointer
; result: [X]:    updated number
;         Z-flag: set on success (cleared on overflow) 
; SSTACK: 12 bytes
;         X, Y, and D are preserved
FOUTER_SHIFT_AND_ADD	EQU	*
			;Allocate local variables (num pointer in X, digit:base in D)
			;RS layout:
			; +--------+--------+
			; |  Scratch Space  | SP+0
			; +--------+--------+
			; | Digit  |  Base  | SP+2
			; +--------+--------+
			; | X (Number Ptr.) | SP+4
			; +--------+--------+
			PSHX				;save X
			PSHD				;store digit:base
			PSHA				;initialize scratch
			CLR	1,-SP			; space
			LEAX	3,X			;initialize byte pointer
			;Iterate over all four bytes (byte pointer in X) 
FOUTER_SHIFT_AND_ADD_1	LDAA	0,X 			;operand -> A
			LDAB	3,SP			;base    -> B
			MUL				;A * B -> A:B
			ADDD	0,SP			;add result to scratch
			STAB	1,X-			;B -> result
			TAB				;A      -> B
			LDAA	#$00			;0      -> A
			ADCA	#$00			;C-flag -> A	
			STD	0,SP			;update scratch space			
			CPX	4,SP			;check if done
			BHS	FOUTER_SHIFT_AND_ADD_1	;next iteration
			;Clean up
			LDX	2,SP+ 			;set Z-flag on overflow
			PULD				;restore D
			PULX				;restore X
			RTS				;done
	
;#Negate double integer if necessary
; args:   A:      sign    
;         X:      number pointer
; result: [X]:    updated number
; SSTACK: 4 bytes
;         X, Y, and D are preserved
FOUTER_COND_NEGATE	EQU	*
			;Check sign (num pointer in X, sign in A)	 
			TBEQ	A, FOUTER_NEGATE_1 	;do nothing

;#Negate double integer
; args:   X:      number pointer
; result: [X]:    updated number
; SSTACK: 4 bytes
;         X, Y, and D are preserved
FOUTER_NEGATE		EQU	*
			;Save registers (num pointer in X, sign in A)
			PSHD				;save D
			;One's complement (num pointer in X, sign in A)
			LDD	0,X 			;MSW -> D
			COMA				;invert MSW
			COMB				;
			STD	0,X			;update MSW
			LDD	2,X			;LSW -> D
			COMA				;invert LSW
			COMB				;
			ADDD	#$0001			;negate LSW
			STD	2,X			;update LSW
			LDD	0,X 			;MSW -> D
			ADCB	#$00			;negate MSW
			ADCA	#$00			;
			STD	0,X			;update MSW
			;Restore registers (num pointer in X, sign in A)
			PULD				;restore D
FOUTER_NEGATE_1		RTS				;done
	
;#Convert digit
; args:   A: char    
;         B: base
; result: A: digit (or char on failure)
;         C-flag: set on success
; SSTACK: 2 bytes
;         X, Y, and B are preserved
FOUTER_CONV_DIGIT	EQU	*
			;Check upper case range (char in A, base in B)
			CMPA	#"A" 			;check upper case range
			BLO	FOUTER_CONV_DIGIT_1	;check number range
			CMPA	#"Z"			;check upper case range
			BHI	FOUTER_CONV_DIGIT_3	;check lower case range
			SUBA	#("A"-10)		;subtract offset
			CBA				;check base 
			BLS	FOUTER_CONV_DIGIT_2	;success
			ADDA	#("A"-10)		;restore char
			JOB	FOUTER_CONV_DIGIT_4	;failure
			;Check number range (char in A, base in B)
FOUTER_CONV_DIGIT_1	CMPA	#"0" 			;check upper case range
			BLO	FOUTER_CONV_DIGIT_4	;invalid char
			CMPA	#"9"			;check upper case range
			BHI	FOUTER_CONV_DIGIT_4	;invalid char
			SUBA	#"0"			;subtract offset
			CBA				;check base 
			BLS	FOUTER_CONV_DIGIT_2	;success
			ADDA	#"0"			;restore char
			JOB	FOUTER_CONV_DIGIT_4	;failure
			;Success 
FOUTER_CONV_DIGIT_2	SEC				;flag success
			RTS				;done
			;Check lower case range (char in A, base in B)
FOUTER_CONV_DIGIT_3	CMPA	#"a" 			;check upper case range
			BLO	FOUTER_CONV_DIGIT_4	;invalid char
			CMPA	#"z"			;check upper case range
			BHI	FOUTER_CONV_DIGIT_4	;invalid char
			SUBA	#("a"-10)		;subtract offset
			CBA				;check base 
			BLS	FOUTER_CONV_DIGIT_2	;success
			ADDA	#("a"-10)		;restore char
			;Failure
FOUTER_CONV_DIGIT_4	CLC				;flag failure
			RTS				;done

;#########
;# Words #
;#########

;Word: >INT ( c-addr u1 -- du 2 | u2 1 | c-addr u1 0 )
;Converts a string into a single or double cell integer. The string is referenced
;by the start address c-addr and the character count u1. If successful the
;resulting integer is returned along with the size of the result. Otherwise the
;string reference remains on the parameter stack along with a zero cell count.
IF_TO_INT		REGULAR
CF_TO_INT		EQU	*
			;RS layout:
			; +--------+--------+
			; |     Absolute    | SP+0
			; +   double cell   +
			; |     integer     | SP+2
			; +--------+--------+
			; |  Sign  |  Base  | SP+4
			; +--------+--------+
			; |  End of string  | SP+6
			; +--------+--------+
			;Allocate pointers
			LDX	2,Y 			;c-addr -> X
			LDD	0,Y			;u1     -> D
			BEQ	CF_TO_INT_7		;empty string
			LEAX	D,X			;end of string -> X
			PSHX				;store end of string
			LDX	2,Y 			;c-addr -> X
			;Parse prefix (string pointer in X, char count on D)
			JOBSR	FOUTER_PREFIX 		;parse prefix
			PSHD				;store sign:base
			;Allocate integer space (string pointer in X, base in B)
			MOVW	#$0000, 2,-SP 		;allocate cleared word
			MOVW	#$0000, 2,-SP 		;allocate cleared word
			;Process digit (string pointer in X, base in B)
CF_TO_INT_1		LDAA	1,X+ 			;char -> A
			JOBSR	FOUTER_CONV_DIGIT	;digit -> A
			BCC	CF_TO_INT_5		;inconvertible character
			PSHX				;save X
			LEAX	2,SP			;integer space -> X
			JOBSR	FOUTER_SHIFT_AND_ADD	;add digit to intager
			BNE	CF_TO_INT_7		;overflow
			PULX				;restore X
CF_TO_INT_2		CPX	6,SP			;check for remaining chars
			BNE	CF_TO_INT_1		;process next digit
			;Single cell integer
			LDD	0,SP 			;check for overflow
			BNE	CF_TO_INT_7		;overflow
			LDD	2,SP			;LSW -> D
			TST	4,SP			;check sign
			BEQ	CF_TO_INT_3		;positive number
			TSTA				;check range
			BMI	CF_TO_INT_7		;overflow
			COMA				;invert LSW
			COMB				;
			ADDD	#$0001			;negate LSW
CF_TO_INT_3		STD	2,Y			;return u2
			MOVW	#$0001, 0,Y		;return 1
CF_TO_INT_4		LEAS	8,SP			;free stack space
			RTS				;done
			;Inconvertible (string pointer in X, char in A, base in B)
CF_TO_INT_5		CMPA	#"_"			;check for filler
			BEQ	CF_TO_INT_2		;skip char
			CMPA	#"."			;check double indicator
			BNE	CF_TO_INT_7		;failure
			CPX	6,SP			;check if period is the last char
			BNE	CF_TO_INT_7		;failure
			;Double cell integer
			TSX				;integer space -> X
			TST	4,SP			;check sign
			BEQ	CF_TO_INT_6		;positive number
			TST	0,SP			;check range
			BMI	CF_TO_INT_7		;overflow
			JOBSR	FOUTER_NEGATE		;negate double integer
CF_TO_INT_6		MOVW	2,SP, 2,Y		;return LSW
			MOVW	0,SP, 0,Y		;return MSW
			MOVW	#$0002, 2,-Y		;return 2
			JOB	CF_TO_INT_4		;clean up and done
			;Failure 
CF_TO_INT_7		MOVW	#$0000, 2,-Y		;return 0
			JOB	CF_TO_INT_4		;clean up and done
	
;Word: SPACE ( -- ) Print whitespace
;Print one space character.	
IF_SPACE		REGULAR
CF_SPACE		EQU	*
			LDAB	#FOUTER_SYM_SPACE 	;SPACE char -> B
			JOB	FOUTER_TX_CHAR		;print SPACE char

;Word: CR ( -- ) Print line break
;Cause subsequent output to appear at the beginning of the next line.
IF_CR			REGULAR
CF_CR			EQU	*
			LDX 	#FOUTER_STR_NL 		;line break sequence -> X
			JOB	FOUTER_TX_STRING	;print line break sequence

;Word: NOP ( -- ) No operation 
;Do nothing.
IF_NOP			REGULAR
CF_NOP			EQU	*
			RTS				;done

;Word: PROMPT ( -- ) Print shell prompt
;Prints a STATE specific command line prompt.
IF_PROMPT		REGULAR
CF_PROMPT		EQU	*
			JOBSR	CF_CR			;line break
			MOVW	#CF_SPACE, 2,-SP	;push return address	
			LDAB	#FOUTER_INTERACT_PROMPT	;interactive prompt -> B
			LDX	STATE			;check STATE
			BEQ	FOUTER_TX_CHAR		;print interactive prompt
			BPL	CF_PROMPT_1		;NV compile
			LDAB	#FOUTER_COMPILE_PROMPT	;RAM compile prompt -> B 
CF_PROMPT_1		JOB	FOUTER_TX_CHAR		;print RAM compile prompt
			LDAB	#FOUTER_NVCOMPILE_PROMPT;NV compile prompt -> B 
			JOB	FOUTER_TX_CHAR		;print NV compile prompt
	
;ABORT run-time ( i*x -- ) ( R: j*x -- )
;Empty the data stack and perform the function of QUIT, which includes emptying
;the return stack, without displaying a message.
CF_ABORT_RT		EQU	*
			;Execute QUIT actions
			FORTH_ABORT 			;perform all ABORT actions

;QUIT run-time ( -- ) ( R: j*x -- )
;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;input device the input source, and enter interpretation state. Do not display a
;message. Repeat the following: 
; -Accept a line from the input source into the input buffer, set >IN to zero,
;  and interpret. 
; -Display the system prompt if in interpretation state,
;  all processing has been completed, and no ambiguous condition exists.
CF_QUIT_RT		EQU	*
			;Execute QUIT actions
			FORTH_QUIT			;perform all ABORT actions
			;Query loop 
CF_QUIT_RT_1		JOBSR	CF_PROMPT 		;print prompt
			JOBSR	CF_QUERY		;query command line 
			;Parse loop 
CF_QUIT_RT_2		MOVW	#FOUTER_SYM_SPACE, 2,-Y ;use SPACE as word seperator
			JOBSR	CF_SKIP_AND_PARSE 	;parse next word
			LDD	0,Y			;check result
			BNE	CF_QUIT_RT_3		;word parsed
			LEAY	4,Y			;clean up PS
			LDX	#FOUTER_STR_OK		;ok string -> X
			MOVW	#CF_QUIT_RT_1, 2,-SP	;push return address (querry loop)
			JOB	FOUTER_TX_STRING	;print string
			;Check for compile state (c-addr u)
CF_QUIT_RT_3		LDD	STATE 			;check STATE
			BEQ	CF_QUIT_RT_6		;interpret
			;Compile (c-addr u)
			JOBSR	CF_LU 			;look up word
			LDX	2,Y+			;xt -> X
			BEQ	CF_QUIT_RT_4		;unknown word
			BRSET	-1,X, #$FF, CF_QUIT_RT_7;execute immediate word
			STX	2,-Y			;xt -> PS
			MOVW	#CF_QUIT_RT_2, 2,-SP	;push return address (parse loop)
			JOB	CF_COMPILE_COMMA_1	;compile word
CF_QUIT_RT_4		JOBSR	CF_TO_INT 		;convert to integer
			LDD	2,Y+			;check result
			BEQ	CF_QUIT_RT_9		;syntax error
			DBEQ	D, CF_QUIT_RT_5		;compile single cell
			JOBSR	CF_LITERAL		;compile literal
CF_QUIT_RT_5		JOBSR	CF_LITERAL		;compile literal
			;Interpret (c-addr u)
CF_QUIT_RT_6		JOBSR	CF_LU 			;look up word
			LDX	2,Y+			;xt -> X
			BEQ	CF_QUIT_RT_8		;unknown word
CF_QUIT_RT_7		MOVW	#CF_QUIT_RT_2, 2,-SP	;push return address (parse loop)
			MOVW	#CF_MONITOR, 2,-SP	;push return address (CF_MONITOR)
			JMP	0,X 			;execute
CF_QUIT_RT_8		JOBSR	CF_TO_INT		;convert to integer
			LDD	2,Y+			;check result
			BNE	CF_QUIT_RT_2		;parse loop
			;Syntax (c-addr u)
CF_QUIT_RT_9		MOVW	#CF_ABORT_RT, 2,-SP	;push return address (CF_ABORT_RT)
			JOB	CF_DOT_SYNERR		;print error message

;Word: SKIP&PARSE ( char "ccc<char>" -- c-addr u )
;Skip over any sequence of char at >IN and execute PARSE.
IF_SKIP_AND_PARSE	REGULAR
CF_SKIP_AND_PARSE	EQU	*
	 		;Skip delimeters
			LDAB	1,Y			;delimeter -> A
			LDX	TO_IN 			;>IN -> X
CF_SKIP_AND_PARSE_1	CPX	NUMBER_TIB		;check if buffer is parsed
			BHS	CF_PARSE_6		;nothing to parse
			CMPB	TIB_START,X		;check for delimeter
			BNE	CF_PARSE_1		;no delimeter
			INX				;advance >IN
			JOB	CF_SKIP_AND_PARSE_1	;check next character
	
;Word: PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
IF_PARSE		REGULAR
CF_PARSE		EQU	*
	 		;Read deliniter and >IN
			LDAB	1,Y			;delimeter -> A
			LDX	TO_IN			;>IN       -> X
			CMPB	TIB_START,X		;check for delimeter
			BEQ	CF_PARSE_6		;empty string
			;Store string address (delimeter in B, >IN in X) 
CF_PARSE_1		LEAX	TIB_START,X 		;string address -> X
			STX	0,Y			;push string address
			LEAX	-TIB_START,X		;>IN -> X
			MOVW	#$0000, 2,-Y		;push initial char count
			LDAA	#$00			;char count -> A
			;Count chars (delimeter in B, char count in A, >IN in X)
CF_PARSE_2		INX				;advance >IN
			CPX	NUMBER_TIB		;check if buffer is parsed
			BHI	CF_PARSE_4		;done
			ADDA	#$01			;increment char 
			BCC	CF_PARSE_3		;no carry
			INC	0,Y			;increment MSW
CF_PARSE_3		CMPB	TIB_START,X		;check for delimeter
			BNE	CF_PARSE_2		;no delimeter
			;Done (char count in A, >IN in X)
CF_PARSE_4		STAA	1,Y			;update char count
CF_PARSE_5		STX	TO_IN			;update >IN
			RTS				;done
			;Parse unsuccessful  (char count in A, >IN in X) 
CF_PARSE_6		MOVW	#$0000, 0,Y 		;null string
			MOVW	#$0000, 2,-Y 		;null length
			JOB	CF_PARSE_5		;done

;Word: LU ( c-addr u -- xt | c-addr u false )
;Look up a name in any dictionary. The name is referenced by the start address
;c-addr and the character count u. If successful the resulting execution token
;xt is returned. Otherwise the name reference remains on the parameter stack 
;along with a false flag. The dictionaries are searchef in the following order: 
;UDICT -> NVDICT -> CDICT  
IF_LU			REGULAR
CF_LU			EQU	*
			;Search UDICT 
			JOBSR	CF_LU_UDICT 		;search UDICT
			LDD	0,Y			;check result
			BNE	CF_LU_1			;successful
			;Search NVDICT
			LEAY	2,Y 			;remove fail flag
			JOBSR	CF_LU_NVDICT		;search NVDICT
			LDD	0,Y			;check result
			BNE	CF_LU_1			;successful
			;Search CDICT
			LEAY	2,Y			;remove fail flag			
			JOB	CF_LU_CDICT		;search CDICT
CF_LU_1			RTS				;done

;Word: WORDS ( -- )
;List the definition names in all available dictionaries in compile order.
IF_WORDS		REGULAR
CF_WORDS		EQU	*
			JOBSR	CF_WORDS_UDICT
			JOBSR	CF_WORDS_NVDICT
			JOB	CF_WORDS_CDICT

;Word: .$ ( c-addr u  -- ) Print a string
;Ptint a string given by the start address c-addr and the character count u.
IF_DOT_STRING		REGULAR
CF_DOT_STRING		EQU	*
			;Print string
			LDD	2,Y 			;c-addr -> D
			LDX	0,Y			;u      -> X
			LEAX	D,X			;end of string -> X
			STX	2,+Y			;end of string -> PS
			TFR	D, X			;c-addr -> X			
CF_DOT_STRING_1		LDAB	1,X+			;char          -> B
			ANDB	#~FOUTER_TERM		;remove any termination
			JOBSR	FOUTER_TX_CHAR		;print char
			CPX	0,Y			;check for end of string
			BNE	CF_DOT_STRING_1		;loop
			RTS				;done
	
;Word: \ 
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<eol>"-- )
;Parse and discard the remainder of the parse area. \ is an immediate word.
IF_BACKSLASH			IMMEDIATE
CF_BACKSLASH			EQU	*
				MOVW	NUMBER_TIB, TO_IN ;set >IN do the last character 
				RTS

;Word: .SYNERR ( c-addr u -- ) Print a syntax error message
;Print a syntax error message, referencing the word given by the start address
;c-addr and the character count u. Then throw an abort exception.
IF_DOT_SYNERR		REGULAR
CF_DOT_SYNERR		EQU	*
			;Print left string 
			LDX	#FOUTER_STR_SYNERR_LEFT ;left side message -> X
			JOBSR	FOUTER_TX_STRING	;print substring
			;Print word
			JOBSR	CF_DOT_STRING 		;print string
			;Print right string 
			LDX	#FOUTER_STR_SYNERR_RIGHT;right side message -> X 
			JOB	FOUTER_TX_STRING	;print substring

;Word: >IN ( -- a-addr )
;a-addr is the address of a cell containing the offset in characters from the
;start of the input buffer to the start of the parse area.
IF_TO_IN		INLINE	CF_TO_IN
CF_TO_IN		EQU	*
			MOVW	#TO_IN, 2,-Y 	;>IN -> PS
CF_TO_IN_EOI		RTS

;Word: BASE ( -- a-addr )
;a-addr is the address of a cell containing the current number-conversion radix
;{{2...36}}.
IF_BASE			INLINE	CF_BASE
CF_BASE			EQU	*
			MOVW	#BASE, 2,-Y 	;BASE -> PS
CF_BASE_EOI		RTS

;Word: STATE ( -- a-addr )
;a-addr is the address of a cell containing the compilation-state flag. STATE is
;true when in compilation state, false otherwise. The true value in STATE is
;non-zero, but is otherwise implementation-defined. Only the following standard
;words alter the value in STATE: : (colon), ; (semicolon), ABORT, QUIT, :NONAME,
;[ (left-bracket), and ] (right-bracket).
;Note: A program shall not directly alter the contents of STATE.
IF_STATE		INLINE	CF_STATE
CF_STATE		EQU	*
			MOVW	#STATE, 2,-Y 	;STATE -> PS
CF_STATE_EOI		RTS
	
FOUTER_CODE_END		EQU	*
FOUTER_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FOUTER_TABS_START_LIN
			ORG 	FOUTER_TABS_START, FOUTER_TABS_START_LIN
#else
			ORG 	FOUTER_TABS_START
FOUTER_TABS_START_LIN	EQU	@
#endif	

;Line break
FOUTER_STR_NL		EQU	STRING_STR_NL

;System prompts
FOUTER_STR_OK		FCS	" ok"

;Error messages 
FOUTER_STR_SYNERR_LEFT	DB	FOUTER_SYM_BEEP
			STRING_NL_NONTERM
			FCC	"!!! Syntax Error: "
FOUTER_STR_SYNERR_RIGHT	DB	$A2 				;quote (terminated)

;Prefix tables 
FOUTER_ASM_PFTAB	DB	"%" 	 2
			DB	"@"	 8
			DB	"#"	10
   			DB	"&"	10
   			DB	"$"	16
FOUTER_ASM_PFTAB_END	EQU	*   
FOUTER_ASM_PFTAB_CNT	EQU	(*-FOUTER_ASM_PFTAB)/2

FOUTER_C_PFTAB		DB	"b" 	 2
			DB	"B" 	 2
			DB	"o"	 8
			DB	"O"	 8
   			DB	"d"	10
   			DB	"D"	10
   			DB	"h"	16
   			DB	"H"	16
   			DB	"x"	16
   			DB	"X"	16
FOUTER_C_PFTAB_END	EQU	*   
FOUTER_C_PFTAB_CNT	EQU	(*-FOUTER_C_PFTAB)/2
	
FOUTER_TABS_END		EQU	*
FOUTER_TABS_END_LIN	EQU	@
#endif	
