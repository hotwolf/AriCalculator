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
;#        ABORT:   Restart outer interpreter                                   #
;#        QUIT:    Restart outer interpreter                                   #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 5, 2013                                                         #
;#      - Initial release                                                      #
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


;;Parse restrictions:
;;===================
;;COMPILE_ONLY: Ensure that the system is in compile state
;; args:   none
;; result: none
;; SSTACK: none
;;         X and Y are  preserved
;#macro	COMPILE_ONLY, 0
;			LDD	STATE
;			BEQ	CF_COMPILE_ONLY_1
;#emac
;	
;;INTERPRET_ONLY: Ensure that the system is in interpretation state
;; args:   none
;; result: none
;; SSTACK: none
;;         X and Y are  preserved
;#macro	INTERPRET_ONLY, 0
;			LDD	STATE
;			BNE	CF_INTERPRET_ONLY_1
;#emac
;	
;;Functions:
;;==========
;;#Assemble prompt in TIB
;; args:   none
;; result: none
;; SSTACK: none
;;         No registers are  preserved
;#macro FOUTER_PROMPT, 0
;			;Print line break
;			EXEC_CF	CF_CR 			;line break
;			;Check for SUSPEND mode
;			LDD	SHELL			;check SHELL
;			BEQ	FOUTER_PROMPT_1		;not in SUSPEND mode
;			PS_PUSH	#FOUTER_SUSPEND_PROMPT	;push prompt onto PS
;			EXEC_CF	CF_EMIT			;print prompt
;			;Check COMPILE/INTERACTIVE mode
;FOUTER_PROMPT_1		LDX	#FOUTER_INTERACT_PROMPT	;interactive prompt
;			LDD	STATE 			;check STATE
;			BEQ	FOUTER_PROMPT_2		;print prompt
;			LDX	#FOUTER_COMPILE_PROMPT	;compile prompt -> X
;#ifdef	NVDICT_ON
;			LDD	NVC			;check check for NV compile
;			BEQ	FOUTER_PROMPT_2		;print prompt
;			LDX	#FOUTER_NVCOMPILE_PROMPT	;compile prompt -> X
;#endif
;			;Print prompt
;FOUTER_PROMPT_2		PS_PUSH_X			;push prompt onto PS			
;			EXEC_CF	CF_EMIT			;print prompt
;			EXEC_CF	CF_SPACE		;print space
;#emac
;
;;#Check if a char is a delimiter 
;; args:   A:      delimiter (0=any whitespace)
;;         B:      char
;; result: Z-flag: set if char is a delimiter
;; SSTACK: 0 bytes
;;         All registers preserved
;#macro	FOUTER_CHECK_DELIMITER, 0
;			TBNE	A, CUSTOM_DELIMITER  	;custom delimiter
;			CMPB	#FIO_SYM_SPACE		;" "
;			BEQ	DONE
;			CMPB	#FIO_SYM_TAB		;tab
;			JOB	DONE
;CUSTOM_DELIMITER	CBA				;custom
;DONE			EQU	*
;#emac
;	
;;#Skip delimiter in TIB 
;; args:   A:      delimiter (0=any whitespace)
;;         #TIB:   char count in TIB
;;         >IN:    TIB parse index
;; result: Y:      new >IN
;;	  B:      next char in TIB
;;         C-flag: set if TIB contains parsable content 
;;         #TIB:   new char count in TIB
;;         >IN:    new TIB parse index
;; SSTACK: 2 bytes
;;         A and X are preserved
;#macro	FOUTER_SKIP_DELIMITER, 0
;			SSTACK_JOBSR	FOUTER_SKIP_DELIMITER, 2
;#emac
;
;;#Count and Terminate string at >IN
;; args:   A:      delimiter (0=any whitespace)
;;         Y:      >IN	
;;         #TIB:   char count in TIB
;;         >IN:    parse index (points to a non-delimiter within the parse area)
;; result: D:      char count
;;	  X:      string pointer
;;	  Y:      new >IN 
;;         #TIB:   unchanged
;;         >IN:    new >IN
;; SSTACK: 0 bytes
;;         No registers are preserved
;#macro	FOUTER_COUNT_AND_TERMINATE, 0
;			;Find end of word (delimiter in A, >IN in Y)
;			LEAX	TIB_START,Y 			;strong pointer -> X
;			;Count loop (delimiter in A, start of string in X, new >IN in Y)
;LOOP			LDAB	TIB_START,Y		;get next char
;			ANDB	#~STRING_TERM		;remove termination
;			STAB	TIB_START,Y		;update char	
;			FOUTER_CHECK_DELIMITER		;check for whitespace
;			BEQ	END_OF_WORD		;end of word found
;			INY				
;			CPY	NUMBER_TIB		;check if TIB is parsed
;			BLO	LOOP			;more to parse
;			;End of word found (start of string in X, new >IN in Y)
;END_OF_WORD		BSET	(TIB_START-1),Y,#FIO_TERM;terminate string
;			TFR	Y, D			 ;new >IN -> D
;			SUBD	TO_IN			 ;(new >IN - ols >IN) -> D
;			STY	TO_IN			 ;update >IN
;#emac
;	
;;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
;; args:   A:   delimiter
;;         #TIB: char count in TIB
;;         >IN:  TIB parse index
;; result: X:    string pointer
;;	  D:    character count
;;         >IN:  new TIB parse index
;; SSTACK: 6 bytes
;;         Y is preserved
;#macro	FOUTER_PARSE, 0
;			SSTACK_JOBSR	FOUTER_PARSE, 6
;#emac
;
;;#Look-up word in dictionaries 
;; args:   X: string pointer (terminated string)
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
;; SSTACK: 4 bytes
;;         X and Y are preserved
;#macro	FOUTER_FIND, 0	
;			SSTACK_JOBSR	FOUTER_FIND, 4
;#emac
;
;	
;;#Transform FOUTER_FIND results into FIND format
;; args:   D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
;; result: X: execution token (unchanged if word not found)
;;	  D: 1=immediate, -1=non-immediate, 0=not found
;; SSTACK: 2 bytes
;;         Y is preserved
;#macro	FOUTER_FIND_FORMAT, 0	
;			SSTACK_JOBSR	FOUTER_FIND_FORMAT, 2
;#emac
;	
;;#Fix and load BASE
;; args:   BASE: any base value
;; result: B:    range adjusted base value (2<=base<=16)
;;         BASE: range adjusted base value (2<=base<=16)
;; SSTACK: 0 bytes
;;         X, Y, and A are preserved
;#macro	FOUTER_FIX_BASE, 0
;			;Check BASE value
;			TST	BASE 			;check upper byte
;			BNE	FOUTER_FIX_BASE_1	;BASE >255
;			LDAB	BASE+1 			;BASE -> B
;			CMPB	#NUM_BASE_MAX		;compare BASE against upper limit
;			BHI	FOUTER_FIX_BASE_1	;BASE value is too high
;			CMPB	#NUM_BASE_MIN		;compare BASE against lower limit
;			BHS	FOUTER_FIX_BASE_2	;BASE is value within valid range
;FOUTER_FIX_BASE_1	LDAB	#NUM_BASE_DEFAULT	;return default value
;			MOVW	#NUM_BASE_DEFAULT, BASE	;update BASE
;FOUTER_FIX_BASE_2	EQU	*
;#emac
;	
;;#Remove number prefix from string and extract base and sign information
;; args:   X:    string pointer
;;	  BASE: default base
;; result: X:    trimmed string pointer
;;	  A:    sign (0=positive, -1=negative)
;;	  B:    base
;;	  BASE: NUM_BASE_DEFAULT if invalid
;; SSTACK: 0 bytes
;;         Y is preserved
;#macro	FOUTER_PARSE_PREFIX, 0	
;			;Initialize prefix information (string pointer in X)
;			CLRA				;0 -> A
;			;Check first character (string pointer in X, sign in A)) 
;			LDAB	0,X 			;char -> B
;			BMI	<FOUTER_PARSE_PREFIX_13	;set default base, done
;			;Check for sign	(string pointer in X, sign in A, char in B)
;			CMPB	#"+" 			;check for plus sign
;			BNE	<FOUTER_PARSE_PREFIX_1	;check for minus sign
;			LDAA	#1			;set positive sign (to be set to 0 later)
;			BRA	FOUTER_PARSE_PREFIX_2	;check next char
;FOUTER_PARSE_PREFIX_1	CMPB	#"-" 			;check for minus sign
;			BNE	<FOUTER_PARSE_PREFIX_3	;check for C-style prefix
;			LDAA	#-1			;set negative sign
;FOUTER_PARSE_PREFIX_2	LDAB	1,+X 			;next char -> B
;			BMI	<FOUTER_PARSE_PREFIX_12	;adjust sign, use default base, done
;			;Check for C-style prefix (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_3	CMPB	#"0" 			;check for plus sign
;			BNE	<FOUTER_PARSE_PREFIX_14	;check for ASM-style prefix
;			LDAB	1,+X 			;next char -> B
;			BMI	<FOUTER_PARSE_PREFIX_12	;adjust sign, set default base, done
;			ORAB	#$20			;ignore case
;			;Binary
;			CMPB	"b"			;check for binary selector
;			BNE	<FOUTER_PARSE_PREFIX_5	;check for octal selector	
;FOUTER_PARSE_PREFIX_4	LDAB	#2 			;set base
;			BRA	<FOUTER_PARSE_PREFIX_11	;adjust sign, advance string pointer, done
;			;Octal
;FOUTER_PARSE_PREFIX_5	CMPB	"o"			;check for octal selector		
;			BNE	<FOUTER_PARSE_PREFIX_7	;check for decimal selector
;FOUTER_PARSE_PREFIX_6	LDAB	#8 			;set base
;			BRA	FOUTER_PARSE_PREFIX_11	;adjust sign, advance string pointer, done
;			;Decimal
;FOUTER_PARSE_PREFIX_7	CMPB	"d"			;check for decimal selector		
;			BNE	<FOUTER_PARSE_PREFIX_9	;check for hexadecimal selector
;FOUTER_PARSE_PREFIX_8	LDAB	#8 			;set base
;			BRA	<FOUTER_PARSE_PREFIX_11	;adjust sign, advance string pointer, done
;			;Hexadecimal
;FOUTER_PARSE_PREFIX_9	CMPB	"h"			;check for hexadecimal selector		
;			BEQ	<FOUTER_PARSE_PREFIX_10	;hexadecimal selector found
;			CMPB	"x"			;check for hexadecimal selector	
;			BNE	<FOUTER_PARSE_PREFIX_10 ;adjust sign, set default base, done
;FOUTER_PARSE_PREFIX_10	LDAB	#16 			;set base
;			;Adjust sign, advance string pointer, done (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_11	ASRA				;adjust sign
;			BRA	<FOUTER_PARSE_PREFIX_21	;advance string pointer, done
;			;Adjust sign, set default base, done (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_12	ASRA				;adjust sign
;			;Set default base, done (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_13	FOUTER_FIX_BASE			;load default base
;			BRA	<FOUTER_PARSE_PREFIX_22	;done
;			;Check for ASM-style prefix (string pointer in X, sign in A, char in B)
;			;Binary
;FOUTER_PARSE_PREFIX_14	CMPB	#"%"			;check for binary selector
;			BNE	<FOUTER_PARSE_PREFIX_15	;check for octal selector	
;			LDAB	#2 			;set base
;			BRA	<FOUTER_PARSE_PREFIX_18	;check for sign at 2nd position
;			;Octal
;FOUTER_PARSE_PREFIX_15	CMPB	#"@"			;check for octal selector
;			BNE	<FOUTER_PARSE_PREFIX_16	;check for decimal selector	
;			LDAB	#8 			;set base
;			BRA	<FOUTER_PARSE_PREFIX_18	;check for sign at 2nd position
;			;Decimal
;FOUTER_PARSE_PREFIX_16	CMPB	#"&"			;check for decimal selector
;			BNE	<FOUTER_PARSE_PREFIX_17	;check for hexadecimal selector	
;			LDAB	#10 			;set base
;			BRA	<FOUTER_PARSE_PREFIX_18	;check for sign at 2nd position
;			;Hexadecimal
;FOUTER_PARSE_PREFIX_17	CMPB	#"$"			;check for hexadecimal selector
;			BNE	<FOUTER_PARSE_PREFIX_12	;adjust sign, set default base, done	
;			LDAB	#10 			;set base
;			;Check for sign at 2nd position (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_18	TBNE	A,FOUTER_PARSE_PREFIX_11;adjust sign, advance string pointer
;			LDAA	1,+X 			;next char -> B
;			BMI	<FOUTER_PARSE_PREFIX_19	;set positive sign, done
;			CMPA	#"+" 			;check for plus sign
;			BNE	<FOUTER_PARSE_PREFIX_20	;check for minus sign
;			INX				;advance string pointer
;			;Set positive sign, done (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_19	CLRA				;set positive sign
;			BRA	<FOUTER_PARSE_PREFIX_22	;done
;FOUTER_PARSE_PREFIX_20	CMPA	#"-" 			;set positive sign, done
;			BNE	<FOUTER_PARSE_PREFIX_19	;set positive sign, done
;			LDAA	#-1			;set negative sign
;			;Advance string pointer, done (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_21	INX
;			;Done (string pointer in X, sign in A, char in B)
;FOUTER_PARSE_PREFIX_22	EQU	*
;#emac
;
;;#Convert a character int a digit value
;; args:   B:       char (non-terminated)
;; result: B:       digit (-1 if char was invalid)
;;         N-flag:  set if char was invalid	 
;; SSTACK: 0 bytes
;;         X, Y, and A are preserved
;#macro	FOUTER_CHAR_2_DIGIT, 0	
;			;Check for valid characters
;			;ANDB	#~STRING_TERM 		;remove termination
;			SUBB	#"0"			;remove "0" offset
;			BLO	FOUTER_CHAR_2_DIGIT_1	;invalid char
;			CMPB	#9			;check for valid decimal digit
;			BLS	FOUTER_CHAR_2_DIGIT_2	;done	
;			SUBB	#(("A")-("0"))		;remove "A" offset
;			BLO	FOUTER_CHAR_2_DIGIT_1	;invalid char
;			ADDB	#10			;add numerical offset
;#ifdef NUM_MAX_BASE_16
;			CMPB	#16			;check for valid alphanumeric digit
;#else
;			CMPB	#32			;check for valid alphanumeric digit
;#endif
;			BLO	FOUTER_CHAR_2_DIGIT_2	;done	
;			;Invalid char
;FOUTER_CHAR_2_DIGIT_1	LDAB	#-1	
;			;Done (digit in B)
;FOUTER_CHAR_2_DIGIT_2	TSTB
;#emac
;
;;#Append_digit to double cell
;; args:   1: pointer to address of double cell
;;	  2: address of digit	
;;	  3: address of base (byte)		
;; result: C-flag : set on overflow	
;; SSTACK: 0 bytes
;;         X is preserved
;#macro	FOUTER_APPEND_DIGIT, 3	
;			;Multiply MSW by base 
;			LDY	[\1] 			;MSW -> Y
;			BEQ	 FOUTER_APPEND_DIGIT_2	;skip if MSW is zero
;			CLRA				;base -> D
;			LDAB	\3			;
;			EMUL				;Y*D -> Y:D
;			TBEQ	Y, FOUTER_APPEND_DIGIT_1;no overflow
;			SEC				;signal overflow
;			JOB	FOUTER_APPEND_DIGIT_3	;done
;FOUTER_APPEND_DIGIT_1	STD	[\1]			;update MSW
;			;Multiply LSW by base
;FOUTER_APPEND_DIGIT_2	LDY	\1   			;double cell address -> Y
;			LDY	2,Y 			;LSW -> Y
;			CLRA				;base -> D
;			LDAB	\3			;
;			EMUL				;Y*D -> Y:D
;			;Add digit (lower product in Y:D)
;			ADDB	\2 			;add digit
;			ADCA	#0			;add carry
;			EXG	Y, D			;Y <-> D
;			ADCB	#0			;add carry
;			ADCA	#0			;add carry
;			BCS	FOUTER_APPEND_DIGIT_3	;overflow
;			ADDD	[\1]			;add MSWs
;			BCS	FOUTER_APPEND_DIGIT_3	;overflow
;			STD	[\1]			;update MSW
;			EXG	Y, D			;Y <-> D
;			LDY	\1   			;double cell address -> Y
;			STD	2,Y			;update LSW
;			;Done
;FOUTER_APPEND_DIGIT_3	EQU	*
;#emac
;
;;#Convert a terminated string into a number (appending digits to a given double
;; cell number)
;; args:   X:      string pointer (terminated string)
;;         Y:      double cell pointer (terminated string)
;;         B:      base
;; result: [Y]:    new double cell number
;;	  X:      new string pointer	
;;	  C-flag: set on overflow	
;; SSTACK: 6 bytes
;;         Y and B are preserved
;#macro	FOUTER_TO_NUMBER, 0	
;			SSTACK_JOBSR	FOUTER_TO_NUMBER, 6
;#emac
;
;;#Try to convert a terminated string into an integer 
;; args:   X: string pointer (terminated string)
;; result: Y:X: integer (X is unchanged if word not found)
;;	  D: 1=single cell, 2=double cell, 0=no integer
;; SSTACK: 16 bytes
;;          No registers are preserved
;#macro	FOUTER_INTEGER, 0	
;			SSTACK_JOBSR	FOUTER_INTEGER, 16
;#emac

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

;#########
;# Words #
;#########
	
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
			FORTH_ABORT

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
			FORTH_QUIT
			;Print command line prompt 
CF_QUIT_RT_1		JOBSR	CF_PROMPT
			;Query command line 
			JOBSR	CF_QUERY

			;Loop 
			JOB	CF_QUIT_RT_1






;Word: PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
IF_PARSE		REGULAR
CF_PARSE		EQU	*
	 		;Skip delimeters
			LDAB	1,Y			;delimeter -> A
CF_PARSE_1		LDX	TO_IN 			;>IN -> X
CF_PARSE_2		CPX	NUMBER_TIB		;check if buffer is parsed
			BHS	CF_PARSE_8		;nothing to parse
			CMPB	TIB_START,X		;check for delimeter
			BNE	CF_PARSE_3		;no delimeter
			INX				;advance >IN
			JOB	CF_PARSE_2		;check next character
			;Store string address (delimeter in B, >IN in X) 
CF_PARSE_3		STX	TO_IN			;update >IN
			LEAX	TIB_START,X 		;string address -> X
			STX	0,SP			;push string address
			LEAX	-TIB_START,X		;>IN -> X
			MOVW	#$0001, 2,-SP		;push initial char count
			LDAA	#$01			;char count -> A
			;Count chars (delimeter in B, char count in A, >IN in X)
CF_PARSE_4		INX				;advance >IN
			CPX	NUMBER_TIB		;check if buffer is parsed
			BHS	CF_PARSE_6		;done
			ADDA	#$01			;increment char 
			BCC	CF_PARSE_5		;no carry
			INC	0,SP			;increment MSW
CF_PARSE_5		CMPB	TIB_START,X		;check for delimeter
			BNE	CF_PARSE_4		;no delimeter
			;Done (char count in A, >IN in X)
CF_PARSE_6		STAA	1,SP			;update char count
CF_PARSE_7		STX	TO_IN			;update >IN
			RTS
			;Parse unsuccessful  (char count in A, >IN in X) 
CF_PARSE_8		MOVW	#$0000, 0,SP 		;null string
			MOVW	#$0000, 2,-SP 		;null length
			JOB	CF_PARSE_7		;done

	
;;#Skip delimiter in TIB 
;; args:   A:      delimiter (0=any whitespace)
;;         #TIB:   char count in TIB
;;         >IN:    TIB parse index
;; result: Y:      new >IN
;;	  B:      next char in TIB
;;         C-flag: set if TIB contains parsable content 
;;         #TIB:   new char count in TIB
;;         >IN:    new TIB parse index
;; SSTACK: 2 bytes
;;         A and X are preserved
;FOUTER_SKIP_DELIMITER	EQU	*
;			;Skip delimiter chars 
;			LDY	TO_IN 			;read parse pointer
;FOUTER_SKIP_DELIMITER_1 CPY	NUMBER_TIB		;check if TIB is parsed
;			BHS	FOUTER_SKIP_DELIMITER_2	;TIB is fully parsed
;			LDAB	TIB_START,Y		;check next char
;			ANDB	#~FIO_TERM		;remove termination
;			FOUTER_CHECK_DELIMITER		;check for delimiter
;			BNE	FOUTER_SKIP_DELIMITER_3	;non-delimeter char found
;			;Skip to next chasr (new TO_IN in Y)
;			IBNE	Y, FOUTER_SKIP_DELIMITER_1;increment and loop
;			;No parsable content found
;FOUTER_SKIP_DELIMITER_2	LDY	NUMBER_TIB 		;mark buffer as parsed (redundand)
;			;Parsable content found (new TO_IN in Y)
;FOUTER_SKIP_DELIMITER_3	STY	TO_IN			;update >IN
;			SSTACK_PREPULL	2		;check SSTACK
;			CPY	NUMBER_TIB		;set C if >IN < #TIB
;			RTS				;done
;		
;;#Find the next word (delimited by a selectable character) on the TIB and terminate it. 
;; args:   A:    delimiter (0=any whitespace)
;;         #TIB: char count in TIB
;;         >IN:  TIB parse index
;; result: X:    string pointer
;;	  D:    character count	
;;         #TIB:   new char count in TIB
;;         >IN:  new TIB parse index
;; SSTACK: 6 bytes
;;         Y is preserved
;FOUTER_PARSE		EQU	*	
;			;Save registers
;			PSHY				;save Y
;			;Skip over delimiters (delimiter in A)
;			FOUTER_SKIP_DELIMITER  		;skip over delimiters	
;			BCC	FOUTER_PARSE_2		;TIB is fully parsed
;			;Count chars and terminate word (delimiter in A, >IN in Y)
;			FOUTER_COUNT_AND_TERMINATE
;			;Retore registers 
;FOUTER_PARSE_1		SSTACK_PREPULL	4		;check SSTACK
;			PULY				;restore Y
;			;Done
;			RTS
;			;TIB is fully parsed
;FOUTER_PARSE_2		CLRA				;clear char count
;			CLRB				;
;			TFR	D, X			;empty string
;			JOB	FOUTER_PARSE_1
;	
;;#Look-up word in dictionaries 
;; args:   X: string pointer (terminated string)
;; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
;; SSTACK: 4 bytes
;;         X and Y are preserved
;FOUTER_FIND		EQU	*	
;			;Save registers (string pointer in X)
;			PSHY				;save Y
;			;Search user directory (string pointer in X)
;			FUDICT_FIND			;(SSTACK: 8 bytes)
;			TBNE	D, FOUTER_FIND_1	;search successful
;;			;Search non-volatile user directory (string pointer in X)			
;;			FNVDICT_FIND 			;search FNVDICT
;;			TBNE	D, FOUTER_FIND_1	;search successful
;			;Search core directory
;			FCDICT_FIND 			;search CDICT
;			JOB	FOUTER_FIND_1		;done
;FOUTER_FIND_1		EQU	FOUTER_PARSE_1		;reuse parse exit
;	
;;#Transform FOUTER_FIND results into FIND format
;; args:   D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
;; result: X: execution token (unchanged if word not found)
;;	  D: 1=immediate, -1=non-immediate, 0=not found
;; SSTACK: 2 bytes
;;         Y is preserved
;FOUTER_FIND_FORMAT	EQU	*
;			;Check if conversion is required ({IMMEDIATE, CFA>>1} in D) 
;			TBEQ	D, FOUTER_FIND_FORMAT_1	;word not found
;			;Transform result ({IMMEDIATE, CFA>>1} in D) 
;			LSLD				;CFA -> D, IMMEDIATE-> C-flag
;			TFR	D, X			;CFA -> X
;			LDAB	#$00			;don't touch C-flag
;			ROLB				;IMMEDIATE -> B
;			LSLB				;2*IMMEDIATE -> B
;			DECB				;result -> B
;			SEX	B, D			;result -> D
;			;Done (results in X and D)
;FOUTER_FIND_FORMAT_1	SSTACK_PREPULL	2
;			RTS
;	
;;#Convert a terminated string into a number (appending digits to a given double
;; cell number)
;; args:   X:      string pointer (terminated string)
;;         Y:      double cell pointer (terminated string)
;;         B:      base
;; result: [Y]:    new double cell number
;;	  X:      new string pointer (points first unparsed char)	
;;	  C-flag: set on overflow	
;; SSTACK: 6 bytes
;;         Y and B are preserved
;FOUTER_TO_NUMBER	EQU	*	
;			;Save registers
;			;Stack:  +--------+--------+
;			;        | D. Cell Pointer | SP+0
;			;        +--------+--------+
;			;        |  Digit |  Base  | SP+2
;			;        +--------+--------+
;			PSHD				;save base
;			PSHY				;save double cell pointer
;			;Get next digit (string pointer in X)
;FOUTER_TO_NUMBER_1	LDAB	0,X 			;char -> B
;			ANDB	#~STRING_TERM		;remove termination
;			CMPB	#"_"			;skip filler chars
;			BEQ	FOUTER_TO_NUMBER_2	;next char
;			FOUTER_CHAR_2_DIGIT		;convert char to digit value
;			BMI	FOUTER_TO_NUMBER_3	;invalid char
;			CMPB	3,SP			;check if digit < base
;			BHS	FOUTER_TO_NUMBER_3	;invalid char	
;			STAB	2,SP 			;save digit
;			;Add digit to result (string pointer in X)
;			FOUTER_APPEND_DIGIT (0,SP), (2,SP), (3,SP)
;			BCS	FOUTER_TO_NUMBER_5 	;overflow
;			;Next char (string pointer in X, double cell pointer in Y, double cell pointer in Y)
;FOUTER_TO_NUMBER_2	BRCLR	1,X+, #STRING_TERM, FOUTER_TO_NUMBER_1 ;get next char	
;			;String parsed w/out overflow (string pointer in X)
;FOUTER_TO_NUMBER_3	SSTACK_PREPULL	6 		;check subroutine stack
;			CLC				;signal no overflow
;FOUTER_TO_NUMBER_4	PULY				;return MSW
;			PULD				;return LSW
;			RTS
;			;Overflow (string pointer in X)
;#ifdef	SSTACK_NO_CHECK 
;FOUTER_TO_NUMBER_5	EQU	FOUTER_TO_NUMBER_4 	;shortcut
;#else
;FOUTER_TO_NUMBER_5	SSTACK_PREPULL	8 		;check subroutine stack	
;			SEC				;signal overflow
;			JOB	FOUTER_TO_NUMBER_4 	;done
;#endif
;
;;#Try to convert a terminated string into an integer 
;; args:   X: string pointer (terminated string)
;; result: Y:X: integer (X is unchanged if word not found)
;;	  D: 1=single cell, 2=double cell, 0=no integer
;; SSTACK: 16 bytes
;;          No registers are preserved
;FOUTER_INTEGER		EQU	*	
;			;Save registers (string pointer in X)
;			;Stack:  +--------+--------+
;			;        |  Sign  |  Base  | SP+0
;			;        +--------+--------+
;			;        |   Double Cell   | SP+2
;			;        |     Number      | SP+4
;			;        +--------+--------+
;			;        |  String Pointer | SP+6
;			;        +--------+--------+
;			PSHX				;save string pointer
;			CLRA				;initialize double cell 
;			CLRB				; number
;			PSHD				;
;			PSHD				;
;			PSHD				;allocate space for sign flag
;			;Parse number prefix (string pointer in X)
;			FOUTER_PARSE_PREFIX 		;parse prefix
;			STD	0,SP			;save sign and base
;			;Parse digits (string pointer in X, base in B)
;			LEAY	2,SP 			;double cell pointer -> Y
;			FOUTER_TO_NUMBER		;convert string to number (SSTACK: 6 bytes)
;			BCS	FOUTER_INTEGER_4	;overflow
;			;Single cell integer
;			BRCLR	-1,X,#STRING_TERM,FOUTER_INTEGER_5;check for double cell format
;			LDY	2,SP			;MSW must be zero
;			BNE	FOUTER_INTEGER_4	;overflow			
;			LDD	4,SP			;load LSW
;			BRCLR	0,SP,#$FF,FOUTER_INTEGER_1;positive single cell number
;			TSTA				;LSW must be < 2^15
;			BMI	FOUTER_INTEGER_4	;overflow
;			COMA				;negate LSW
;			COMB				;
;			ADDD	#1			;
;			;DEY				;invert Y	
;FOUTER_INTEGER_1	LDX	#1 			;cell count -> X
;FOUTER_INTEGER_2	EXG	D, X			;D <-> X
;			;Clean up (integer in Y:X, cell count in D)
;FOUTER_INTEGER_3	SSTACK_PREPULL	10 		;check subroutine stack
;			LEAS	8,SP			;free stack space
;			;Done
;			RTS
;			;Overflow/invalid format
;FOUTER_INTEGER_4	LDX	6,SP 			;restore string pointer
;			CLRA				;cell count -> D
;			CLRB				;
;			;TFR	D, Y			;clear Y
;			JOB	FOUTER_INTEGER_3	;clean up stack
;			;Double cell integer (string pointer in X)
;FOUTER_INTEGER_5	LDAB	0,X 			;check string for double cell format
;			CMPB	#((".")|STRING_TERM)	;make sure that string ends with "."	
;			BNE	FOUTER_INTEGER_4	;invalid format
;			LDD	2,SP			;load MSW
;			LDY	4,SP			;load LSW
;			BRCLR	0,SP,#$FF,FOUTER_INTEGER_6;positive double cell number
;			TSTA				;MSW must be < 2^15
;			BMI	FOUTER_INTEGER_4	;overflow
;			COMA				;invert MSW
;			COMB				;
;			LDY	4,SP			;load LSW
;			EXG	D, Y			;D <-> Y
;			COMA				;negate LSW
;			COMB				;
;			ADDD	#1			;
;			EXG	D, Y			;D <-> Y
;			ADCB	#0			;add carry to MSW
;			ADCA	#0			;
;FOUTER_INTEGER_6	EXG	D, Y			;D <-> Y
;			LDX	#2			;cell count -> X
;			JOB	FOUTER_INTEGER_4	;clean up stack
;	
;;Inner interpreter:
;;==================
;;#ABORT_NEXT: Force ABORT
;; args:	  IP:   pointer to next instruction
;; result: IP:   pointer to current instruction
;;         W/X:  new CFA
;;         Y:    IP (=pointer to current instruction)
;; PS:     none
;; RS:     none
;; throws: none
;ABORT_NEXT		EQU	CF_ABORT_SHELL
;
;;#SUSPEND_NEXT: Restore NP and enter SUSPEND Mode
;; args:	  IP:   pointer to next instruction
;; result: IP:   pointer to current instruction
;;         W/X:  new CFA
;;         Y:    IP (=pointer to current instruction)
;; PS:     none
;; RS:     none
;; throws: none
;SUSPEND_NEXT		EQU	*
;#ifdef	IRQ_NEXT
;			MOVW	#IRQ_NEXT, NP 			;switch NP
;#else
;			MOVW	#NEXT,  NP 			;switch NP
;#endif	
;			;JOB	CF_SUSPEND			;enter SUSPEND mode
;	
;;Code fields:
;;============
;;SUSPEND ( -- ) RS:( -- SUSPEND frame)
;;Enter SUSPEND mode.
;; args:   none
;; result: none
;; SSTACK: 16 bytes
;; PS:     0 cells
;; RS:     5 cells
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_RSOF
;;         FEXCPT_EC_COMERR
;CF_SUSPEND		EQU		*
;			;Check return stack space (3-4 cells needed on top of parse area)
;			RS_CHECK_OF	4 			;require 4 cells (
;			;Determine the size of the remaining parse area
;			LDY	RSP 				;RSP -> Y
;			LDX	NUMBER_TIB 			;#TIB -> X
;			TFR	X, D				;#TIB -> D
;			LEAX	TIB_START,X			;end of TIB -> X
;			SUBD	TO_IN				;unparsed char count -> D
;			BEQ	CF_SUSPEND_2			;parse area is empty	
;			ADDD	#1				;word align parse area
;			LSRD					;unparsed word count -> D
;			;Save remaining parse area onto RS (unparsed word count in D,  #TIB in X, RSP in Y)
;CF_SUSPEND_1		MOVW	2,-X, 2,-Y 			;copy loop
;			DBNE	D, CF_SUSPEND_1			;next iteration
;			LDD	NUMBER_TIB			;recalculate unparsed char count
;			SUBD	TO_IN				;unparsed char count -> D
;			;Complete SUSPEND shell frame (unparsed word count in D, new RSP in Y)
;CF_SUSPEND_2		STD	2,-Y 				;push new #TIB onto the RS		
;			MOVW	IP, 2,-Y			;push current IP onto the RS
;			MOVW	SHELL, 2,-Y			;push SHELL onto the RS
;			;STY	PSP				;update PSP (already done in CF_SHELL))
;			STY	SHELL				;update SHELL
;			;Perform SUSPEND ACTION 
;			FORTH_SUSPEND
;			;Start new QUIT shell
;			JOB	CF_QUIT_SHELL
;
;;RESUME ( -- ) RS:( SUSPEND frame -- )
;;Resume from a temporary debug shell.
;; args:   none
;; result: none
;; SSTACK: 16 bytes
;; PS:     0 cell
;; RS:     0 cells
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_RSOF
;;         FEXCPT_EC_COMERR
;CF_RESUME		EQU	*
;			;Restore SHELL
;			LDX	SHELL 				;SHELL -> X
;			BEQ	CF_RESUME_3			;not in SUSPEND mode
;			;SHELL is trusted to be valid -> no checks (SHELL in X)
;			;CPX	RSP 				compare against RSP
;			;BLO	CF_ABORT_SHELL 			;SHELL corrupted
;			;CPX	#(RS_EMPTY-(2*3)) 		;compare against botton of RS
;			;BHI	CF_ABORT_SHELL			;SHELL corrupted
;			;Restore state variables (RSP in X)
;			MOVW	#$0000, TO_IN			;reset parse pointer
;			MOVW	2,X+, SHELL 			;restore SHELL
;			MOVW	2,X+, IP 			;restore IP
;			LDD	2,X+				;unparsed char count -> D
;			STD	 NUMBER_TIB 			;restore #TIB
;			BEQ	CF_RESUME_2			;TIB is empty
;			;Restore TIB (new RSP in X, unparsed char count in D)
;			ADDD	#1				;word align char count
;			LSRD					;unparsed word count -> D
;			LDY	#TIB_START			;TIB_START
;CF_RESUME_1		MOVW	2,X+, 2,Y+			;copy loop
;			DBNE	D, CF_RESUME_1			;next iteration
;			;Done (new RSP in X)
;CF_RESUME_2		STX	RSP 				;update RSP
;CF_RESUME_3		NEXT
;
;;QUERY ( -- ) Query command line input
;;Make the user input device the input source. Receive input into the terminal
;;input buffer,mreplacing any previous contents. Make the result, whose address is
;-;returned by TIB, the input buffer.  Set >IN to zero.
;; args:   none
;; result: #TIB: char count in TIB
;;         >IN:  index pointing to the start of the TIB => 0x0000
;; SSTACK: 8 bytes
;; PS:     1 cell
;; RS:     2 cells
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_RSOF
;;         FEXCPT_EC_COMERR
;CF_QUERY		EQU	*
;			;Reset input buffer
;			MOVW	#0000, NUMBER_TIB 	;zero chars in TIB
;			MOVW	#0000, TO_IN		;parse area to start of TIB
;			;Receive input
;CF_QUERY_1		EXEC_CF	CF_EKEY			;input char -> [PS+0]
;			;Get input (input char in [PS+0])
;			LDD	[PSP] 			;input char -> B
;			;Handle CR - ignore by default (input char in B)
;			CMPB	#FIO_SYM_CR
;#ifdef	FOUTER_NL_CR
;			BEQ	CF_QUERY_8		;command line complete		
;#else
;			BEQ	CF_QUERY_4		;ignore
;#endif
;			;Hanfle LF - newline by default (input char in B and in [PS+0])
;			CMPB	#FIO_SYM_LF	
;#ifdef	FOUTER_NL_LF
;			BEQ	CF_QUERY_8		;command line complete		
;#else
;			BEQ	CF_QUERY_4		;ignore
;#endif
;			;Check for BACKSPACE (input char in B and in [PS+0])
;			CMPB	#FIO_SYM_BACKSPACE	
;			BEQ	CF_QUERY_7	 	;backspace
;			CMPB	#FIO_SYM_DEL	
;			BEQ	CF_QUERY_7	 	;backspace
;			;Check for valid special characters (input char in B and in [PS+0])
;			CMPB	#FIO_SYM_TAB	
;			BEQ	CF_QUERY_2	 	;echo and append to buffer
;			;Check for invalid characters (input char in B and in [PS+0])
;			CMPB	#" " 			;first legal character in ASCII table
;			BLO	CF_QUERY_5		;beep
;			CMPB	#"~"			;last legal character in ASCII table
;			BHI	CF_QUERY_5 		;beep			
;			;Check for buffer overflow (input char in B and in [PS+0])
;CF_QUERY_2		LDX	NUMBER_TIB 		;determine TIB size
;			LEAX	(TIB_START+TIB_PADDING),X
;			CPX	RSP
;			BHS	CF_QUERY_5 		;beep
;			;Append char to input line (input char in B and in [PS+0], TIB pointer+padding in X)
;			STAB	-TIB_PADDING,X 		;append char
;			LDX	NUMBER_TIB		;increment NUMBER_TIB
;			INX
;			STX	NUMBER_TIB			
;			;Echo input char (input char in [PS+0])
;CF_QUERY_3		EXEC_CF	CF_EMIT			;print character
;			JOB	CF_QUERY_1
;			;Ignore input char
;CF_QUERY_4		LDY	PSP 			;drop char from PS
;			LEAY	2,Y
;			STY	PSP
;			JOB	CF_QUERY_1
;			;BEEP			
;CF_QUERY_5		LDD	#FIO_SYM_BEEP		;replace received char by a beep
;CF_QUERY_6		STD	[PSP]
;			JOB	CF_QUERY_3 		;transmit beep
;			;Check for buffer underflow (input char in [PS+0])
;CF_QUERY_7		LDY	NUMBER_TIB 		;compare char count
;			BEQ	CF_QUERY_5		;beep
;			DEY				;decrement #TIB
;			STY	NUMBER_TIB		;
;			LDD	#STRING_SYM_BACKSPACE	;replace received char by a backspace
;			JOB	CF_QUERY_6
;			;Command line complete
;CF_QUERY_8		LDY	PSP 			;drop char from PS
;			LEAY	2,Y
;			STY	PSP
;			LDY	NUMBER_TIB 		;check char count
;			BEQ	CF_QUERY_9 		;command line is empty
;			DEY				;terminate last character
;			BSET	TIB_START,Y, #STRING_TERM
;CF_QUERY_9		NEXT
;
;;PARSE ( char "ccc<char>" -- c-addr u ) Parse the TIB
;;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;;input buffer) and u is the length of the parsed string.  If the parse area was
;;;empty, the resulting string has a zero length.
;; args:   PSP+0: delimiter char (0=any whitespace)
;; result: PSP+0: character count
;;         PSP+2: string pointer
;; SSTACK: 0 bytes
;; PS:     2 cells
;; RS:     1 cell
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_PSUF
;CF_PARSE		EQU	*
;			;Check PS
;			PS_CHECK_UFOF	1, 1 		;check PSP
;			STY	PSP			;new PSP -> Y
;			;Parse next word (PSP in Y) 
;			LDAA	3,Y 			;delimiter -> A
;			FOUTER_PARSE			;parse
;			;Return resuls (PSP in Y, string pointer in X, char count in D)) 
;CF_PARSE_1		STX	2,Y			;return string pointer
;			STD	0,Y			;return char count
;			;Done
;			NEXT
;
;;FIND ( c-addr -- c-addr 0 |  xt 1 | xt -1 )  
;;Find the definition named in the terminated string at c-addr. If the definition is
;;not found, return c-addr and zero.  If the definition is found, return its
;;execution token xt.  If the definition is immediate, also return one (1),
;;otherwise also return minus-one (-1).  For a given string, the values returned
;;by FIND while compiling may differ from those returned while not compiling. 
;; args:   PSP+0: terminated string to match dictionary entry
;; result: PSP+0: 1 if match is immediate, -1 if match is not immediate, 0 in
;;         	 case of a mismatch
;;  	  PSP+2: execution token on match, input string on mismatch
;; SSTACK: ? bytes
;; PS:     1 cell
;; RS:     1 cell
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_PSUF
;CF_FIND			EQU	*
;			;Check PS
;			PS_CHECK_UFOF	1, 1 		;check PSP
;			STY	PSP			;new PSP -> Y
;			;Search dictionaries (PSP in Y) 
;			LDX	2,Y 			;string pointer -> X
;			FOUTER_FIND			;(SSTACK: 4 bytes)
;			FOUTER_FIND_FORMAT		;(SSTACK: 2 bytes)
;			;Return resuls (PSP in Y, xt/string pointer in X, meta info in D)) 
;			JOB	CF_PARSE_1 		;code reuse
;			;STX	2,Y			;return xt/string pointer
;			;STD	0,Y			;return meta info
;			;;Done
;			;NEXT
;
;;Empty the data stack and perform the function of QUIT, which includes emptying
;;the return stack, without displaying a message. 
;; args:   none
;; result: none
;; SSTACK: 8 bytes
;; PS:     1 cell
;; RS:     2 cells
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_RSOF
;;         FEXCPT_EC_COMERR
;CF_ABORT_SHELL		EQU	*
;			;Execute ABORT actions
;			FORTH_ABORT
;			;Execute QUIT actions
;			;JOB	CF_QUIT_SHELL
;
;;QUIT run-time ( -- ) ( R: j*x -- )
;;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;;input device the input source, and enter interpretation state. Do not display a
;;message. Repeat the following: 
;; -Accept a line from the input source into the input buffer, set >IN to zero,
;;  and interpret. 
;; -Display the system prompt if in interpretation state,
;;  all processing has been completed, and no ambiguous condition exists.
;; args:   none
;; result: none
;; SSTACK: 8 bytes
;; PS:     1 cell
;; RS:     2 cells
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_RSOF
;;         FEXCPT_EC_COMERR
;CF_QUIT_SHELL		EQU	*
;			;Execute QUIT actions
;			FORTH_QUIT
;			;Execute SUSPEND actions
;			;JOB	CF_SUSPEND_RT
;
;;SHELL ( -- ) Generic interactive shell
;;Common S12CForth shell. 
;; args:   none
;; result: none
;; SSTACK: 22 bytes
;6; PS:     1 cell
;; RS:     2 cells
;; throws: FEXCPT_EC_PSOF
;;         FEXCPT_EC_RSOF
;;         FEXCPT_EC_COMERR
;CF_SHELL		EQU	*
;			;Set RSP to current shell stack frame (SHELL is trusted to have valid content) 
;			LDX	SHELL 				;shell stack frame -> X
;			BEQ	CF_SHELL_1			;skip for non-suspend shell 
;			STX	RSP				;adjust RSP
;			;Print shell prompt
;CF_SHELL_1		FOUTER_PROMPT 				;assemble prompt in TIB
;			;Query command line
;			EXEC_CF	CF_QUERY 			;query command line
;			;Parse command line
;CF_SHELL_2		CLRA					;set delimiter to any whitespace
;			FOUTER_PARSE				;parse next word
;			TBNE	D, CF_SHELL_3			;word found
;			;Print acknowledge string 
;			PS_PUSH	#FOUTER_SYSTEM_ACK 		;string pointer -> PS
;			EXEC_CF	CF_STRING_DOT			;print string
;			JOB	CF_SHELL_1			;new command line
;			;Lookup word in dictionaries word (string pointer in X)
;CF_SHELL_3		FOUTER_FIND 				;search dictionaries
;			TBEQ	D, CF_SHELL_5			;word not in dictionaries
;			;Compile semantics ({IMMEDIATE, CFA>>1} in D)
;			LSLD					;extract immediate flag
;			BCS	CF_SHELL_4			;interpret, no matter what STATE
;			LDY	STATE 				;check compile state
;			BEQ	CF_SHELL_4			;interpret xt
;			FUDICT_COMPILE_CELL 			;compile xt
;			JOB	CF_SHELL_2 			;parse next word
;			;Interpretation semantics (CFA in D)
;CF_SHELL_4		TFR	D, X	   			;CFA -> X
;			EXEC_CFA_X 				;execute xt
;			JOB	CF_SHELL_2 			;parse next word
;			;Interpret word as number (string pointer in X)
;CF_SHELL_5		FOUTER_INTEGER 				;interpret as integer
;			TBEQ	D, CF_SHELL_9			;syntax error (not an integer)
;			DBEQ	D, CF_SHELL_8			;single cell
;			;DBNE	D, CF_SHELL_9			;syntax error
;			;Double cell number (number in Y:X) 
;			LDD	STATE 				;check compile state
;			BEQ	CF_SHELL_6			;interpret
;			;Compile semantics (number in Y:X)
;			TFR	Y, D		    		;save LSW
;			UDICT_CHECK_OF	6			;CP+6 -> Y
;			STY	CP				;update CP
;			MOVW	#CFA_TWO_LITERAL_RT, -6,Y	;compile xt
;			LDD	-4,Y				;compile MSW
;			LDX	-2,Y				;compile LSW
;			JOB	CF_SHELL_2			;parse next wprd
;			;Interpretation semantics (number in Y:X)
;CF_SHELL_6		TFR	Y, D		    		;push MSW onto PS
;			PS_PUSH_D				;
;CF_SHELL_7		PS_PUSH_X				;push LSW onto PS
;			JOB	CF_SHELL_2			;parse next wprd
;			;Single cell number (number in X) 
;CF_SHELL_8		LDD	STATE 				;check compile state
;			BEQ	CF_SHELL_7			;interpret
;			;Compile semantics (number in X)
;			UDICT_CHECK_OF	4			;CP+4 -> Y
;			STY	CP				;update CP
;			MOVW	#CFA_LITERAL_RT, -4,Y		;compile xt
;			LDX	-2,Y				;compile LSW
;			JOB	CF_SHELL_2			;parse next wprd
;			JOB	CF_SHELL_2			;parse next word
;			;Syntax error (string pointer in X)
;CF_SHELL_9		LDD	#FEXCPT_EC_UDEFWORD 		;set error code
;			FEXCPT_PRINT_ERROR_BL			;print error message
;			JOB	CF_ABORT_SHELL 			;restart ABORT shell			
;	
;
;;>NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) 
;;ud2 is the unsigned result of converting the characters within the string
;;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;;left-to-right until a character that is not convertible, including any "+" or
;;"-", is encountered or the string is entirely converted. c-addr2 is the
;;location of the first unconverted character or the first character past the end
;;of the string if the string was entirely converted. u2 is the number of
;;unconverted characters in the string. If ud2 overflows during the conversion,
;;a "result out of range" exception (-11) is thrown .	
;; args:   PSP+0: character count
;;         PSP+2: string pointer
;;         PSP+4: initial number
;; result: PSP+0: remaining character count
;;         PSP+2: pointer to unconverted substring
;;         PSP+4: resulting number
;; SSTACK: 8 bytes
;; PS:     none
;; RS:     none
;; throws: FEXCPT_EC_PSUF
;;         FEXCPT_EC_RESOR
;CF_TO_NUMBER		EQU	*
;			;Check PS
;			PS_CHECK_UF	4 		;PSP -> Y
;			;Terminate string at character count (PSP in Y)
;			LDX	2,Y 			;string pointer -> X
;			LDD	0,Y			;string length -> D
;			STRING_RESIZE			;adjust termination
;			;Convert string to number (string pointer in X, PSP in Y)
;			FOUTER_FIX_BASE			;BASE -> B
;			LEAY	4,Y			;address of double cell number -> Y
;			FOUTER_TO_NUMBER		;convert number (SSTACK: 8 bytes)
;			BCS	CF_TO_NUMBER_1		;overflow
;			;Save string pointer and char count (new string pointer in X, PSP+4 in Y)
;			LDD	-4,Y 			;old char count -> D
;			ADDD	-2,Y			;old char count + old string pointer -> D
;			STX	-2,Y			;store new string pointer
;			SUBD	-2,Y			;new char count -> D
;			STD	-4,Y 			;store new char count
;			;Done
;			NEXT
;			;Parse overflow
;CF_TO_NUMBER_1		FEXCPT_THROW FEXCPT_EC_RESOR	;throw "result out of range" exception
;	
;;LITERAL run-time semantics ( -- x )
;;Place x on the stack.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;CF_LITERAL_RT		EQU	*
;			PS_CHECK_OF	1		;check for PS overflow (PSP-new cells -> Y)
;			LDX	IP			;push the value at IP onto the PS
;			MOVW	2,X+ 0,Y		; and increment the IP
;			STX	IP
;			STY	PSP
;			NEXT
;
;;2LITERAL run-time semantics ( -- d )
;;Place d on the stack.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;CF_TWO_LITERAL_RT	EQU	*
;			PS_CHECK_OF	2		 ;check for PS overflow (PSP-new cells -> Y)
;			LDX	IP			 ;push the value at IP onto the PS
;			MOVW	2,X+, 0,Y		 ; and increment the IP
;			MOVW	2,X+, 2,Y		 ; and increment the IP
;			STX	IP
;			STY	PSP
;			NEXT
;	
;;COMPILE-ONLY ( -- )
;;Ensures that the outer interpreter is in compile state.
;;
;;S12CForth implementation details:
;;Throws:
;;"Compile-only word"
;CF_COMPILE_ONLY		EQU	* 
;			LDD	STATE			;check state
;			BEQ	CF_COMPILE_ONLY_1	;outer interpreter is in interpretation state
;			NEXT
;CF_COMPILE_ONLY_1	FEXCPT_THROW	FEXCPT_EC_COMPONLY
;	
;;INTERPRET-ONLY ( -- )
;;Ensures that the outer interpreter is in interpretation state.
;;
;;S12CForth implementation details:
;;Throws:
;;"Nested compilation"
;CF_INTERPRET_ONLY	EQU	* 
;			LDD	STATE			;check state
;			BNE	CF_INTERPRET_ONLY_1	;outer interpreter is in compile state
;			NEXT
;CF_INTERPRET_ONLY_1	FEXCPT_THROW	FEXCPT_EC_COMPNEST

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

;Symbol tables
FOUTER_STR_NL		EQU	STRING_STR_NL

;System prompts
FOUTER_STR_OK		FCS	" ok"
	
;Symbol tables
FOUTER_SYMTAB		EQU	NUM_SYMTAB
	
FOUTER_TABS_END		EQU	*
FOUTER_TABS_END_LIN	EQU	@
#endif	

;;###############################################################################
;;# Words                                                                       #
;;###############################################################################
;#ifdef FOUTER_WORDS_START_LIN
;			ORG 	FOUTER_WORDS_START, FOUTER_WORDS_START_LIN
;#else
;			ORG 	FOUTER_WORDS_START
;FOUTER_WORDS_START_LIN	EQU	@
;#endif	
;			ALIGN	1, $FF
;;#ANSForth Words:
;;================
;;Word: QUERY ( -- )
;;Make the user input device the input source. Receive input into the terminal
;;input buffer,mreplacing any previous contents. Make the result, whose address is
;;returned by TIB, the input buffer.  Set >IN to zero.
;;
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;;"Invalid RX data"
;CFA_QUERY		DW	CF_QUERY
;
;;Word: PARSE ( char "ccc<char>" -- c-addr u )
;;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;;input buffer) and u is the length of the parsed string.  If the parse area was
;;empty, the resulting string has a zero length.
;;
;;Throws:
;;"Parameter stack overflow"
;;"Parameter stack underflow"
;CFA_PARSE		DW	CF_PARSE
;
;;Word: >NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) 
;;ud2 is the unsigned result of converting the characters within the string
;;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;;left-to-right until a character that is not convertible, including any "+" or
;;"-", is encountered or the string is entirely converted. c-addr2 is the
;;location of the first unconverted character or the first character past the end
;;of the string if the string was entirely converted. u2 is the number of
;;unconverted characters in the string. If ud2 overflows during the conversion,
;;both result and conversion string are left untouched.
;;
;;Throws:
;;"Parameter stack underflow"
;CFA_TO_NUMBER		DW	CF_TO_NUMBER
;	
;;Word: BASE ( -- a-addr ) 
;;a-addr is the address of a cell containing the current number-conversion radix
;;{{2...36}}. 
;;
;;Throws:
;;"Parameter stack overflow"
;CFA_BASE		DW	CF_CONSTANT_RT
;			DW	BASE
;
;;Word: STATE ( -- a-addr ) 
;;a-addr is the address of a cell containing the compilation-state flag. STATE is
;;true when in compilation state, false otherwise. The true value in STATE is
;;non-zero. Only the following standard words alter the value in STATE:
;; : (colon), ; (semicolon), ABORT, QUIT, :NONAME, [ (left-bracket), and
;; ] (right-bracket). 
;;  Note:  A program shall not directly alter the contents of STATE. 
;;
;;Throws:
;;"Parameter stack overflow"
;CFA_STATE		DW	CF_CONSTANT_RT
;			DW	STATE
;	
;;Word: >IN ( -- a-addr )
;;a-addr is the address of a cell containing the offset in characters from the
;;start of the input buffer to the start of the parse area.  
;;
;;Throws:
;;"Parameter stack overflow"
;CFA_TO_IN		DW	CF_CONSTANT_RT
;			DW	TO_IN
;
;;Word: #TIB ( -- a-addr )
;;a-addr is the address of a cell containing the number of characters in the
;;terminal input buffer.
;;
;;Throws:
;;"Parameter stack overflow"
;CFA_NUMBER_TIB		DW	CF_CONSTANT_RT
;			DW	NUMBER_TIB
;
;;Word: WORDS ( -- )
;;List the definition names in the first word list of the search order. The
;;format of the display is implementation-dependent.
;;WORDS may be implemented using pictured numeric output words. Consequently, its
;;use may corrupt the transient region identified by #>.
;CFA_WORDS		DW	CF_INNER
;			DW	CFA_WORDS_UDICT
;#ifdef NVDICT_ON
;			DW	CFA_WORDS_NVDICT
;#endif
;			DW	CFA_WORDS_CDICT
;			DW	CFA_EOW
;
;;#S12CForth Words:
;;=================
;;Word: SUSPEND ( -- )
;;Execute a temporary debug shell.
;;
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;;"Communication error"
;CFA_SUSPEND		DW	CF_SUSPEND
;
;;Word: RESUME ( -- ) IMMEDIATE
;;Exit suspend mode 
;;
;;Throws:
;;"Return stack underflow"
;CFA_RESUME		DW	CF_RESUME
;
;;LITERAL run-time semantics ( -- x )
;;Place x on the stack.
;;
;;Throws:
;;"Parameter stack overflow"
;CFA_LITERAL_RT		DW	CF_LITERAL_RT
;
;;2LITERAL run-time semantics ( -- x1 x2 )
;;Place cell pair x1 x2 on the stack.
;;
;;Throws:
;;"Parameter stack overflow"
;CFA_TWO_LITERAL_RT	DW	CF_TWO_LITERAL_RT
;
;;Word: COMPILE-ONLY ( -- )
;;Ensures that the outer interpreter is in compile state.
;;
;;S12CForth implementation details:
;;Throws:
;;"Compile-only word"
;CFA_COMPILE_ONLY	DW	CF_COMPILE_ONLY
;	
;;Word: INTERPRET-ONLY ( -- )
;;Ensures that the outer interpreter is in interpretation state.
;;
;;S12CForth implementation details:
;;Throws:
;;"Nested compilation"
;CFA_INTERPRET_ONLY	DW	CF_INTERPRET_ONLY
;	
;FOUTER_WORDS_END	EQU	*
;FOUTER_WORDS_END_LIN	EQU	@
;#endif
