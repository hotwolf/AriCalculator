#ifndef FINTEGER_COMPILED
#define FINTEGER_COMPILED
;###############################################################################
;# S12CForth - FINTEGER - Integer operations                                   #
;###############################################################################
;#    Copyright 2011-2015 Dirk Heisswolf                                       #
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
;#    This module implements the outer interpreter of the S12CForth            #
;#    environment.                                                             #
;#                                                                             #
;#    The outer interpreter uses these registers:                              #
;#           BASE = Number conversion radix                                    #
;#          STATE = Compilation (>0) or interpretation (=0) state              #
;#     NUMBER_TIB = Number of chars in the TIB                                 #
;#          TO_IN = In-pointer of the TIB (>IN)	       			       #
;#       	    (TIB_OFFSET+TO_IN) points to the next character	       #
;#  									       #
;#    Program termination options:                                             #
;#        ABORT:   Restart outer interpreter                                   #
;#        QUIT:    Restart outer interpreter                                   #
;#        SUSPEND: Restart outer interpreter                                   #
;#                                                                             #
;#        Compile mode if STATE != 0                                           #
;#        SUSPEND mode if    IP != 0                                           #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 5, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FINNER - Forth inner interpreter                                         #
;#    FIO    - Forth communication interface                                   #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
;#    FINNER - Forth inner interpreter                                         #
;#    FIO    - Forth communication interface                                   #
;#    FEXCPT - Forth Exception Handler                                         #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;        
;                         +--------------+--------------+        
;        RS_TIB_START, -> |              |              |
;           TIB_START     |              |              | <- [TIB_OFFSET]          
;                         |              |              | |          
;                         |       Text Input Buffer     | | [NUMBER_TIB]
;                         |              |              | |	       
;                         |              v              | |	       
;                     -+- | --- --- --- --- --- --- --- | v	       
;          TIB_PADDING |  .                             . <- [TIB_OFFSET+NUMBER_TIB] 
;                     -+- .                             .            
;                         | --- --- --- --- --- --- --- |            
;                         |              ^              | <- [RSP]
;                         |              |              |
;                         |        Return Stack         |
;                         |              |              |
;                         +--------------+--------------+
;             RS_EMPTY, ->                                 
;           RS_TIB_END
;
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Safety distance to return stack
;------------------------------- 
#ifndef TIB_PADDING
TIB_PADDING		EQU	4 		;default is 4 bytes
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;STATE variable 
STATE_INTERPRET		EQU	FALSE
STATE_COMPILE		EQU	TRUE

;Text input buffer 
TIB_START		EQU	RS_TIB_START

;Default line width 
DEFAULT_LINE_WIDTH	EQU	80

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FINTEGER_VARS_START_LIN
			ORG 	FINTEGER_VARS_START, FINTEGER_VARS_START_LIN
#else
			ORG 	FINTEGER_VARS_START
FINTEGER_VARS_START_LIN	EQU	@
#endif	
			ALIGN	1	
BASE			DS	2 		;number conversion radix
STATE			DS	2 		;interpreter state (0:iterpreter, -1:compile)
NUMBER_TIB  		DS	2		;number of chars in the TIB
TO_IN  			DS	2		;parse index (TIB_OFFSET+TO_IN -> start of parse area)
	
FINTEGER_VARS_END		EQU	*
FINTEGER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;===============
#macro	FINTEGER_INIT, 0
			MOVW	#$0010, BASE 		;set BASE to decimal
			MOVW	#STATE_INTERPRET, STATE	;interpretation state
			MOVW	#$0000, NUMBER_TIB	;empty TIB
			MOVW	#$0000, TO_IN		;reset parser
#emac

;#Abort action (to be executed in addition of QUIT action)
#macro	FINTEGER_ABORT, 0
			MOVW	#$0010, BASE 		;set BASE to decimal
#emac
	
;#Quit action (to be executed in addition of SUSPEND action)
#macro	FINTEGER_QUIT, 0
			MOVW	#STATE_INTERPRET, STATE	;interpretation state
#emac
	
;#Suspend action
#macro	FINTEGER_SUSPEND, 0
			MOVW	#$0000, NUMBER_TIB	;empty TIB
			MOVW	#$0000, TO_IN		;reset parser
#emac






	
;Functions:
;==========
;#Fix and load BASE
; args:   BASE: any base value
; result: D:    range adjusted base value (2<=base<=16)
;         BASE: range adjusted base value (2<=base<=16)
; SSTACK: none
;         X and Y are preserved
#macro	FINTEGER_FIX_BASE, 0
			SSTACK_JOBSR	FINTEGER_FIX_BASE, 2
#emac

;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
; args:   A:   delimiter
;         #TIB: char count in TIB
;         >IN:  TIB index
; result: X:    string pointer
;	  D:    character count
;         >IN:  new TIB index
; SSTACK: 6 bytes
;         Y is preserved
#macro	FINTEGER_PARSE, 0
			SSTACK_JOBSR	FINTEGER_PARSE, 6
#emac

;#Find the next string (delimited by whitespace) on the TIB and terminate it. 
; args:   #TIB: char count in TIB
;         >IN:  TIB index
; result: X:    string pointer
;	  D:    character count
;         >IN:  new TIB index
; SSTACK: 6 bytes
;         Y is preserved
#macro	FINTEGER_PARSE_WS, 0
			CLRA
			FINTEGER_PARSE
#emac

;#Convert a string into an unsigned number
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if successful (cleared on overflow) 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 10 bytes
;         X, Y, and D are preserved
#macro	FINTEGER_TO_NUMBER, 0
			SSTACK_CHECK_BOUNDARIES	10, 10
			JOBSR	FINTEGER_TO_NUMBER
#emac

;#Check for a sign prefix
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if prefix was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 8 bytes
;         X, Y, and D are preserved
#macro	FINTEGER_TO_SIGN, 0
			SSTACK_CHECK_BOUNDARIES	8, 10
			JOBSR	FINTEGER_TO_SIGN
#emac

;#Check for a filler character
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if filler character was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 10 bytes
;         X, Y, and D are preserved
#macro	FINTEGER_TO_FILLER, 0
			SSTACK_CHECK_BOUNDARIES	8, 10
			JOBSR	FINTEGER_TO_FILLER
#emac

;#Check for an ASM-style base prefix
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if prefix was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 8 bytes
;         X, Y, and D are preserved
#macro	FINTEGER_TO_ABASE, 0
			SSTACK_CHECK_BOUNDARIES	8, 10
			JOBSR	FINTEGER_TO_ABASE
#emac

;#Check for a C-style base prefix
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if prefix was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 10 bytes
;         X, Y, and D are preserved
#macro	FINTEGER_TO_CBASE, 0
			SSTACK_CHECK_BOUNDARIES	10, 10
			JOBSR	FINTEGER_TO_CBASE
#emac

;#Check if the string starts with a valid digit
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if first character is a valid digit	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
 ;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 10 bytes
;         X, Y, and D are preserved
#macro	FINTEGER_PEEK_NUM, 0
			SSTACK_CHECK_BOUNDARIES	10, 10
			JOBSR	FINTEGER_PEEK_NUM
#emac
	
;#Convert a terminated string into a number
; args:   X:   string pointer
;	  D:   character count
; result: Y:X: number (saturated in case of an overflow)
;	  D:   cell count
;	       or  0 if format is invalid
;	       or -1 in case of an overflow	
; SSTACK: 22 bytes
;         No registers are preserved
#macro	FINTEGER_INTEGER, 0	
			SSTACK_JOBSR	FINTEGER_INTEGER, 22
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FINTEGER_CODE_START_LIN
			ORG 	FINTEGER_CODE_START, FINTEGER_CODE_START_LIN
#else
			ORG 	FINTEGER_CODE_START
FINTEGER_CODE_START_LIN	EQU	@
#endif
	
;#Fix and load BASE
; args:   BASE: any base value
; result: D:    range adjusted base value (2<=base<=16)
;         BASE: range adjusted base value (2<=base<=16)
; SSTACK: 2 bytes
;         X and Y are preserved
FINTEGER_FIX_BASE		EQU	*
			LDD	BASE
			CPD	#NUM_BASE_MAX
			BLS	FINTEGER_FIX_BASE_1
			LDD	#NUM_BASE_MAX
			JOB	FINTEGER_FIX_BASE_2
FINTEGER_FIX_BASE_1	CPD	#NUM_BASE_MIN
			BHS	FINTEGER_FIX_BASE_3
			LDD	#NUM_BASE_MIN
FINTEGER_FIX_BASE_2	STD	BASE
			;Done 
FINTEGER_FIX_BASE_3	SSTACK_PREPULL	2
			RTS

;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
; args:   A:    delimiter (0=any whitespace)
;         #TIB: char count in TIB
;         >IN:  TIB index
; result: X:    string pointer
;	  D:    character count	
;         >IN:  new TIB index
; SSTACK: 6 bytes
;         Y is preserved
FINTEGER_PARSE		EQU	*	
			;Save registers
			PSHY
			;Store TIB end address (delimiter in A)
			TFR	A, X			;delimeter -> XL
			LDD	TIB_OFFSET		;TIB_OFFSET -> D
			LDY	NUMBER_TIB 		;TIB end address -> 0,SP
			LEAY	D,Y
			STY	2,-SP
			LDY	TO_IN 			;parse address -> Y
			LEAY	D,Y
			TFR	X, A 			;delimiter -> A
			;Skip delimeter (parse pointer in Y, delimiter in A)
FINTEGER_PARSE_1		CPY	0,SP 			;check for empty string
			BHS	FINTEGER_PARSE_9		;empty string found
			BCLR	0,Y, #$80		;remove termination		
			LDAB	1,Y+ 			;char -> B
			TBNE	A, FINTEGER_PARSE_2 	;custom delimeter			
			CMPB	STRING_SYM_SPACE	;" "
			BEQ	FINTEGER_PARSE_1		;skip char
			CMPB	STRING_SYM_TAB		;tab
			BEQ	FINTEGER_PARSE_1		;skip char
			JOB	FINTEGER_PARSE_3		;start of word found
FINTEGER_PARSE_2		CBA				;custom delimiter
			BEQ	FINTEGER_PARSE_1		;skip char
			;Start of word found (parse pointer in Y, char in B, delimiter in A) 
FINTEGER_PARSE_3		LEAX	-1,Y 			;start of word -> X
FINTEGER_PARSE_4		CPY	0,SP 			;check for end of buffer
			BHS	FINTEGER_PARSE_7		;end of buffer
			BCLR	0,Y, #$80		;remove termination		
			LDAB	1,Y+ 			;char -> B
			TBNE	A, FINTEGER_PARSE_5 	;custom delimeter			
			CMPB	STRING_SYM_SPACE	;" "
			BEQ	FINTEGER_PARSE_6		;end of word
			CMPB	STRING_SYM_TAB		;tab
			BNE	FINTEGER_PARSE_6		;end of word
			JOB	FINTEGER_PARSE_4		;skip char
FINTEGER_PARSE_5		CBA				;custom delimiter
			BNE	FINTEGER_PARSE_5		;skip char
			;End of word found (parse pointer in Y, char in B, delimiter in A)
FINTEGER_PARSE_6		LEAY	-1,Y	   		;go back to delimeter
FINTEGER_PARSE_7		BSET	-1,Y, #$80 		;terminate last char
			STY	0,SP			;determine char count
			TFR	Y, D
FINTEGER_PARSE_8		SSTACK_PREPULL	6 		;check stack
			SUBD	2,SP+			;determine char count
			;Restore registers 
			PULY
			RTS
			;Empty string found
FINTEGER_PARSE_9		MOVW	TO_IN, NUMBER_TIB
			STD	0,SP
			JOB	FINTEGER_PARSE_8	

;#Convert a string into an unsugned number
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if successful (cleared on overflow) 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 10 bytes
;         X, Y, and D are preserved
FINTEGER_TO_NUMBER	EQU	*
FINTEGER_TO_NUMBER_BASE	EQU	 8 				;base
FINTEGER_TO_NUMBER_STRCNT	EQU	10				;char count
FINTEGER_TO_NUMBER_STRPTR	EQU	12				;string pointer
FINTEGER_TO_NUMBER_NUMHI	EQU	14				;number MSW
FINTEGER_TO_NUMBER_NUMLO	EQU	16				;number LSW
			;Save registers
			PSHY
			PSHX
			PSHD
			;Check string length
FINTEGER_TO_NUMBER_1	LDD	FINTEGER_TO_NUMBER_STRCNT,SP
			BEQ	FINTEGER_TO_NUMBER_3 		;empty input string
			;Read base
			LDD	FINTEGER_TO_NUMBER_BASE,SP 	;sign/base -> D
			ANDA	#$7F				;remove sign bit
			TFR	D, X				;base -> X
			;Read digit from string (base in X)
			LDAB	[FINTEGER_TO_NUMBER_STRPTR,SP] 	;read char
			ANDB	#$7F				;remove termination
			STRING_UPPER				;make upper case (SSTACK: 8 bytes)
			;Convert digit (char in B, base in X)
FINTEGER_TO_NUMBER_2	CMPB	(FINTEGER_SYMTAB-1),X
			BEQ	FINTEGER_TO_NUMBER_5 		;digit found
			DBNE	X, FINTEGER_TO_NUMBER_2		;try next symbol
			;Restore registers
FINTEGER_TO_NUMBER_3	SSTACK_PREPULL	8
			SEC					;flag no overflow
FINTEGER_TO_NUMBER_4	PULD
			PULX
			PULY
			;Done
			RTS
			;Add digit (digit+1 in X)
FINTEGER_TO_NUMBER_5	LEAX	-1,X
			;Multiply number by base and add digit (digit in X)
			LDY	FINTEGER_TO_NUMBER_NUMLO,SP
			STX	FINTEGER_TO_NUMBER_NUMLO,SP		
			LDD	FINTEGER_TO_NUMBER_BASE,SP
			ANDA	#$7F 				;remove sign bit
			EMUL					;Y * D => Y:D
			ADDD	FINTEGER_TO_NUMBER_NUMLO,SP	;add digit to temp result
			EXG	Y, D
			ADCB	#$00
			ADCA	#$00
			BCS	FINTEGER_TO_NUMBER_6 		;number out of range
			STY	FINTEGER_TO_NUMBER_NUMLO,SP	;store resulting LSW
			LDY	FINTEGER_TO_NUMBER_NUMHI,SP
			STD	FINTEGER_TO_NUMBER_NUMHI,SP
			LDD	FINTEGER_TO_NUMBER_BASE,SP
			ANDA	#$7F 				;remove sign bit			
			EMUL					;Y * D => Y:D
			TBNE	Y, FINTEGER_TO_NUMBER_6 		;number out of range	
			ADDD	FINTEGER_TO_NUMBER_NUMHI,SP	;add digit to temp result
			BCS	FINTEGER_TO_NUMBER_6 		;number out of range
			STD	FINTEGER_TO_NUMBER_NUMHI,SP	;
			;Advanve to next digit
			LDX	FINTEGER_TO_NUMBER_STRCNT,SP
			LEAX	-1,X
			STX	FINTEGER_TO_NUMBER_STRCNT,SP
			LDX	FINTEGER_TO_NUMBER_STRPTR,SP
			LEAX	1,X
			STX	FINTEGER_TO_NUMBER_STRPTR,SP
			JOB	FINTEGER_TO_NUMBER_1
			;Number out fo range
FINTEGER_TO_NUMBER_6	LDD	#$FFFF
			STD	FINTEGER_TO_NUMBER_NUMHI,SP
			STD	FINTEGER_TO_NUMBER_NUMLO,SP
FINTEGER_TO_NUMBER_7	SSTACK_PREPULL	8
			CLC
			JOB	FINTEGER_TO_NUMBER_4

;#Check for a sign prefix
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if prefix was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FINTEGER_TO_SIGN		EQU	*
FINTEGER_TO_SIGN_BASE	EQU	 8 				;base
FINTEGER_TO_SIGN_STRCNT	EQU	10				;char count
FINTEGER_TO_SIGN_STRPTR	EQU	12				;string pointer
FINTEGER_TO_SIGN_NUMHI	EQU	14				;number MSW
FINTEGER_TO_SIGN_NUMLO	EQU	16				;number LSW
			;Save registers
			PSHY
			PSHX
			PSHD
			;Check string length
			LDY	FINTEGER_TO_SIGN_STRCNT,SP
			BEQ	FINTEGER_TO_SIGN_3 		;empty input string
			;Read char from string (char count in Y)
			LDX	FINTEGER_TO_SIGN_STRPTR,SP			
			LDAB	1,X+ 				;read char
			ANDB	#$7F				;remove termination
			CMPB	#"+"				;check for plus prefix
			BEQ	FINTEGER_TO_SIGN_1     		;plus sign found
			CMPB	#"-"				;check for minus prefix
			BNE	FINTEGER_TO_SIGN_3     		;no prefix found
			;Invert sign (char count in Y, new string pointer in X)
			LDAA	#$80
			EORA	FINTEGER_TO_SIGN_BASE,SP
			STAA	FINTEGER_TO_SIGN_BASE,SP
			;Advance string pointer (char count in Y, new string pointer in X)
FINTEGER_TO_SIGN_1	STX	FINTEGER_TO_SIGN_STRPTR,SP 	;update string pointer
			LEAY	-1,Y				;decrement string count
			STY	FINTEGER_TO_SIGN_STRCNT,SP
			;Restore registers
			JOB	FINTEGER_TO_SIGN_2
FINTEGER_TO_SIGN_2	EQU	FINTEGER_TO_NUMBER_3
			;No prefix found 
FINTEGER_TO_SIGN_3	EQU	FINTEGER_TO_NUMBER_7

;#Check for a filler character
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if filler character was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FINTEGER_TO_FILLER	EQU	*
FINTEGER_TO_FILLER_BASE	EQU	 8 				;base
FINTEGER_TO_FILLER_STRCNT	EQU	10				;char count
FINTEGER_TO_FILLER_STRPTR	EQU	12				;string pointer
FINTEGER_TO_FILLER_NUMHI	EQU	14				;number MSW
FINTEGER_TO_FILLER_NUMLO	EQU	16				;number LSW
			;Save registers
			PSHY
			PSHX
			PSHD
			;Check string length
			LDY	FINTEGER_TO_FILLER_STRCNT,SP
			BEQ	FINTEGER_TO_FILLER_2 		;empty input string
			;Read char from string (decremented char count in Y)
			LDX	FINTEGER_TO_FILLER_STRPTR,SP			
			LDAB	1,X+ 				;read first char
			ANDB	#$7F				;remove termination
			CMPB	#"_"
			BEQ	FINTEGER_TO_FILLER_3 		;filler char found
			;No filler char found
FINTEGER_TO_FILLER_1	JOB	FINTEGER_TO_FILLER_2		
FINTEGER_TO_FILLER_2	JOB	FINTEGER_TO_NUMBER_7		
			;Advance to nect character (char count in Y, new string pointer in X)
FINTEGER_TO_FILLER_3	EQU	FINTEGER_TO_SIGN_1
	
;#Check for an ASM-style base prefix
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if prefix was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FINTEGER_TO_ABASE		EQU	*
FINTEGER_TO_ABASE_BASE	EQU	 8 				;base
FINTEGER_TO_ABASE_STRCNT	EQU	10				;char count
FINTEGER_TO_ABASE_STRPTR	EQU	12				;string pointer
FINTEGER_TO_ABASE_NUMHI	EQU	14				;number MSW
FINTEGER_TO_ABASE_NUMLO	EQU	16				;number LSW
			;Save registers
			PSHY
			PSHX
			PSHD
			;Check string length
			LDY	FINTEGER_TO_ABASE_STRCNT,SP
			BEQ	FINTEGER_TO_ABASE_4	 	;empty input string
			;Read char from string (char count in Y)
			LDX	FINTEGER_TO_ABASE_STRPTR,SP			
			LDAB	1,X+ 				;read char
			ANDB	#$7F				;remove termination
			LDAA	#2 				;check for binary prefix 
			CMPB	#"%"
			BEQ	FINTEGER_TO_ABASE_1 		;prefix found
			LDAA	#8				;check for octal prefix 
			CMPB	#"@"
			BEQ	FINTEGER_TO_ABASE_1 		;prefix found
			LDAA	#10				;check for decimal prefix 
			CMPB	#"&"
			BEQ	FINTEGER_TO_ABASE_1 		;prefix found
			LDAA	#16				;check for hexadecimal prefix 
			CMPB	#"$"
			BNE	FINTEGER_TO_ABASE_4 		;no prefix found
			;Set base (base in A, char count in Y, new string pointer in X)
FINTEGER_TO_ABASE_1	STAA	(FINTEGER_TO_ABASE_BASE+1),SP
			BCLR	FINTEGER_TO_ABASE_BASE,SP, #$7F
			;Advance string pointer (char count in Y, new string pointer in X)
FINTEGER_TO_ABASE_2	JOB	FINTEGER_TO_ABASE_3
FINTEGER_TO_ABASE_3	EQU	FINTEGER_TO_SIGN_1
			;No prefix found 
FINTEGER_TO_ABASE_4	EQU	FINTEGER_TO_NUMBER_7

;#Check for a C-style base prefix
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if prefix was found 	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 10 bytes
;         X, Y, and D are preserved
FINTEGER_TO_CBASE		EQU	*
FINTEGER_TO_CBASE_BASE	EQU	 8 				;base
FINTEGER_TO_CBASE_STRCNT	EQU	10				;char count
FINTEGER_TO_CBASE_STRPTR	EQU	12				;string pointer
FINTEGER_TO_CBASE_NUMHI	EQU	14				;number MSW
FINTEGER_TO_CBASE_NUMLO	EQU	16				;number LSW
			;Save registers
			PSHY
			PSHX
			PSHD
			;Check string length
			LDY	FINTEGER_TO_CBASE_STRCNT,SP
			BEQ	FINTEGER_TO_CBASE_2 		;empty input string
			DBEQ	Y, FINTEGER_TO_CBASE_2 		;single char string
			;Read char from string (decremented char count in Y)
			LDX	FINTEGER_TO_CBASE_STRPTR,SP			
			LDAB	1,X+ 				;read first char
			ANDB	#$7F				;remove termination
			CMPB	#"0"
			BNE	FINTEGER_TO_CBASE_2 		;no prefix found
			LDAB	1,X+ 				;read second char
			ANDB	#$7F				;remove termination
			STRING_UPPER				;make upper case (SSTACK: 2 bytes)
			LDAA	#2 				;check for binary prefix 
			CMPB	#"B"
			BEQ	FINTEGER_TO_CBASE_3 		;prefix found
			LDAA	#8				;check for octal prefix 
			CMPB	#"O"
			BEQ	FINTEGER_TO_CBASE_3 		;prefix found
			LDAA	#10				;check for decimal prefix 
			CMPB	#"D"
			BEQ	FINTEGER_TO_CBASE_3 		;prefix found
			LDAA	#16				;check for hexadecimal prefix 
			CMPB	#"H"
			BEQ	FINTEGER_TO_CBASE_3 		;prefix found
			CMPB	#"X"
			BEQ	FINTEGER_TO_CBASE_3 		;prefix found
			;No prefix found
FINTEGER_TO_CBASE_1	JOB	FINTEGER_TO_CBASE_2			
FINTEGER_TO_CBASE_2	EQU	FINTEGER_TO_NUMBER_7			
			;Set base (base in A, char count in Y, new string pointer in X)
FINTEGER_TO_CBASE_3	EQU	FINTEGER_TO_ABASE_1

;#Check if the string starts with a valid digit
; args:   Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; result: C-flag: set if first character is a valid digit	
;         Stack:        +--------+--------+
;			|    Sign/Base    | SP+0
;			+--------+--------+
;			| Rem Char Count  | SP+2
;			+--------+--------+
;			|  Rem Char Ptr   | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
; SSTACK: 10 bytes
;         X, Y, and D are preserved
FINTEGER_PEEK_NUM		EQU	*
FINTEGER_PEEK_NUM_BASE	EQU	 8 				;base
FINTEGER_PEEK_NUM_STRCNT	EQU	10				;char count
FINTEGER_PEEK_NUM_STRPTR	EQU	12				;string pointer
FINTEGER_PEEK_NUM_NUMHI	EQU	14				;number MSW
FINTEGER_PEEK_NUM_NUMLO	EQU	16				;number LSW
			;Save registers	
			PSHY
			PSHX
			PSHD
			;Check string length
			LDD	FINTEGER_PEEK_NUM_STRCNT,SP
			BEQ	FINTEGER_PEEK_NUM_3 		;empty input string
			;Read base
			LDD	FINTEGER_PEEK_NUM_BASE,SP 	;sign/base -> D
			ANDA	#$7F				;remove sign bit
			TFR	D, X				;base -> X
			;Read char from string (base in X)
			LDAB	[FINTEGER_PEEK_NUM_STRPTR,SP]	;read second char
			ANDB	#$7F				;remove termination
			STRING_UPPER				;make upper case (SSTACK: 2 bytes)
			;Convert digit (char in B, base in X)
FINTEGER_PEEK_NUM_1	CMPB	(FINTEGER_SYMTAB-1),X
       			BEQ	FINTEGER_PEEK_NUM_4 		;valid digit found
       			DBNE	X, FINTEGER_PEEK_NUM_1		;try next symbol
       			;No valid digit found
FINTEGER_PEEK_NUM_2	JOB	FINTEGER_PEEK_NUM_3
FINTEGER_PEEK_NUM_3	EQU	FINTEGER_TO_NUMBER_7
       			;Valid digit found
FINTEGER_PEEK_NUM_4	EQU	FINTEGER_TO_NUMBER_3
	
;#Convert a terminated string into a number
; args:   X:   string pointer
;	  D:   character count
; result: Y:X: number (saturated in case of an overflow)
;	  D:   cell count
;	       or  0 if format is invalid
;	       or -1 in case of an overflow	
; SSTACK: 22 bytes
;         No registers are preserved
FINTEGER_INTEGER		EQU	*	
;			;Allocate temporary memory (string pointer in X, char count in D)
;         Stack:        +--------+--------+
;			|      Base       | SP+0
;			+--------+--------+
;			|   String Size   | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|   Number MSW    | SP+6
;			+--------+--------+
;			|   Number LSW    | SP+8
;			+--------+--------+
FINTEGER_INTEGER_BASE	EQU	0 			;base		
FINTEGER_INTEGER_STRCNT	EQU	2			;char count	
FINTEGER_INTEGER_STRPTR	EQU	4			;string pointer	
FINTEGER_INTEGER_NUMHI	EQU	6			;number MSW	
FINTEGER_INTEGER_NUMLO  	EQU	8			;number LSW	
FINTEGER_INTEGER_RET_D	EQU	FINTEGER_INTEGER_STRPTR	;D return value
FINTEGER_INTEGER_RET_Y	EQU	FINTEGER_INTEGER_NUMHI	;Y return value	
FINTEGER_INTEGER_RET_X  	EQU	FINTEGER_INTEGER_NUMLO	;X return value	
			;Initialize stack struckture (string pointer in X, char count in D)
			LDY	#$0000
			PSHY				;number LSW
			PSHY				;number MSW
			PSHX				;string pointer
			PSHD				;char count
			PSHY				;base (must be zero at this point)
			;Parse prefix
			;        v
			;    CHECK SIGN
			;    1 C-flag 0
			;    |        +----------+
			;    v                   v
			;    CHECK ABASE         CHECK ABASE
			;    1 C-flag  0         0 C-flag  1
			;    |         v         v         v
			;    |         CHECK CBASE     CHECK SIGN
			;    |         1 C-flag  0         |
			;    | +-------+         v	   |
			;    | |           DEFAULT BASE    |
			;    | | +---------------+         |       
			;    | | | +-----------------------+        
			;    | | | |        
			;    v v v v
			;    PEEK NUM
			;    1 C-f. 0   
			;    v      v
			;  valid invalid
			FINTEGER_TO_SIGN 			;check for sign prefix
			BCS	FINTEGER_INTEGER_3	;sign prefix found
			FINTEGER_TO_ABASE 		;check for ASM-style base prefix
			BCS	FINTEGER_INTEGER_4	;ASM-style base prefix found
FINTEGER_INTEGER_1	FINTEGER_TO_CBASE 		;check for C-style base prefix
			BCS	FINTEGER_INTEGER_5	;C-style base prefix found
			FINTEGER_FIX_BASE			;set default base
			BRCLR	FINTEGER_INTEGER_BASE,SP, #$80, FINTEGER_INTEGER_2	
			ORAA	#$80	
FINTEGER_INTEGER_2	STD	FINTEGER_INTEGER_BASE,SP
			JOB	FINTEGER_INTEGER_5	;check if next character is a valid digit
FINTEGER_INTEGER_3	FINTEGER_TO_ABASE 		;check for ASM-style base prefix
			BCS	FINTEGER_INTEGER_5	;ASM-style base prefix found
			JOB	FINTEGER_INTEGER_1	;check for C-style base prefix
FINTEGER_INTEGER_4	FINTEGER_TO_SIGN  		;check for sign prefix
FINTEGER_INTEGER_5	FINTEGER_PEEK_NUM			;check if next character is a valid digit
			BCC	FINTEGER_INTEGER_7	;invalid format
			;Parse number 
FINTEGER_INTEGER_6	FINTEGER_TO_NUMBER 		;parse digits
			BCC	FINTEGER_INTEGER_13	;overflow occured
			LDD	FINTEGER_INTEGER_STRCNT,SP;check number of remaing chars
			BEQ	FINTEGER_INTEGER_10	;all digits parsed
			DBEQ	D, FINTEGER_INTEGER_12	;one char left to parse
			FINTEGER_TO_FILLER		;check for filler char
			BCS	FINTEGER_INTEGER_6	;filler char found
			;Invalid format 
FINTEGER_INTEGER_7	MOVW	#0, FINTEGER_INTEGER_RET_D,SP	
FINTEGER_INTEGER_8	MOVW	#0, FINTEGER_INTEGER_RET_Y,SP	
			MOVW	#0, FINTEGER_INTEGER_RET_X,SP
			;Return result 
FINTEGER_INTEGER_9	SSTACK_PREPULL	12 		;free stack space
			LEAS	4,SP
			PULD
			PULY
			PULX
			RTS
			;Single cell integer found
FINTEGER_INTEGER_10	LDD	FINTEGER_INTEGER_NUMHI,SP ;check for overflow
			BNE	FINTEGER_INTEGER_13	;overflow	
			MOVW	#1, FINTEGER_INTEGER_RET_D,SP;return cell count
			BRCLR	FINTEGER_INTEGER_BASE,SP, #$80, FINTEGER_INTEGER_9;positive number
			LDY	FINTEGER_INTEGER_NUMLO,SP ;check for overflow
			BMI	FINTEGER_INTEGER_13	;overflow
			;Calculate 2's complement (NUMHI in D, NUMHI in Y)
FINTEGER_INTEGER_11	COMA
			COMB
			EXG	D, Y
			COMA
			COMB
			ADDD	#1			
			EXG	D, Y
			ADCB	#0
			ADCA	#0
			STY	FINTEGER_INTEGER_NUMLO,SP
			STD	FINTEGER_INTEGER_NUMHI,SP
			JOB	FINTEGER_INTEGER_9	;return result
			;Parse last character
FINTEGER_INTEGER_12	LDAB	[FINTEGER_INTEGER_STRPTR,SP]
			ANDB	#$7F			;remove termination
			CMPB	#"."			;check for double
			BNE	FINTEGER_INTEGER_7	;invalid format
			MOVW	#2, FINTEGER_INTEGER_RET_D,SP;return cell count
			BRCLR	FINTEGER_INTEGER_BASE,SP, #$80, FINTEGER_INTEGER_9;positive number
			LDY	FINTEGER_INTEGER_NUMLO,SP
			LDD	FINTEGER_INTEGER_NUMHI,SP ;check for overflow
			BPL	FINTEGER_INTEGER_11	;calculate 2's complement
			;Overflow 
FINTEGER_INTEGER_13	MOVW	#-1, FINTEGER_INTEGER_RET_D,SP
			JOB	FINTEGER_INTEGER_8	

;Search word in dictionary tree
; args:   Y: dictionary tree pointer
;         X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16  bytes
;         X and Y are preserved 
FINTEGER_TREE_SEARCH	EQU	*
			;Save registers (tree pointer in Y, string pointer in X, char count in D)
			PSHY						;save Y
			PSHX						;save X
			PSHD						;save D	
			;Compare substring (tree pointer in Y, string pointer in X, char count in D)
FINTEGER_TREE_SEARCH_1	FCDICT_COMP_STRING	FINTEGER_TREE_SEARCH_5    ;compare substring (SSTACK: 8 bytes)
			;Substing matches (tree pointer in Y, string pointer in X, char count in D)
			BRCLR	0,Y, #$FF, FINTEGER_TREE_SEARCH_4 	;branch detected
			TBNE	D, FINTEGER_TREE_SEARCH_7 		;dictionary word too short -> unsuccessful
			;Search successful (tree pointer in Y, string pointer in X, char count in D)
FINTEGER_TREE_SEARCH_2	SSTACK_PREPULL	8 				;check stack
			LDD	0,Y 					;get CFA
			SEC						;flag unsuccessful search
			PULX						;remove stack entry				
FINTEGER_TREE_SEARCH_3	PULX						;restore X				
			PULY						;restore Y				
			;Done
			RTS		
			;Branch detected (tree pointer in Y, string pointer in X, char count in D) 
FINTEGER_TREE_SEARCH_4	LDY	1,Y 					;switch to subtree
			TST	0,Y 					;check for STRING_TERMINATION
			BNE	FINTEGER_TREE_SEARCH_1			;no end of dictionary word reached 
			LEAY	1,Y 					;skip zero string
			;Empty substring (tree pointer in Y, string pointer in X, char count in D)
			TBEQ	D, FINTEGER_TREE_SEARCH_2 		;match
			LEAY	2,Y 					;switch to next sibling
			JOB	FINTEGER_TREE_SEARCH_1			;Parse sibling
			;Try next sibling (tree pointer in Y, string pointer in X, char count in D)
FINTEGER_TREE_SEARCH_5	BRCLR	1,Y+, #$FF, FINTEGER_TREE_SEARCH_6	;check for BRANCH
			LEAY	1,Y					;skip over CFA
			JOB	FINTEGER_TREE_SEARCH_1			;compare next sibling	
FINTEGER_TREE_SEARCH_6	BRCLR	2,+Y, #$FF, FINTEGER_TREE_SEARCH_7 	;END_OF_BRANCH -> unsuccessful
			JOB	FINTEGER_TREE_SEARCH_1			;compare next sibling	
			;Search unsuccessful (tree pointer in Y, string pointer in X, char count in D)
FINTEGER_TREE_SEARCH_7	SSTACK_PREPULL	8 				;check stack
			CLC						;flag successful search
			PULD						;restore D				
			JOB	FINTEGER_TREE_SEARCH_3
	

;Code fields:
;============

;RESUME ( -- )
;Resume from a temporary debug shell.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_RESUME		EQU	*
			;Check if SUSPEND_MARKER is already set
			LDX	SUSPEND_MARKER	
			TBNE	X, CF_RESUME_ 			;SUSPEND_MARKER is already set
			;Resore SUSPEND context	(SUSPEND_MARKER in X)
			RS_CHECK_UF 5				;check for underflow
			MOVW	2,X+, BASE			;restore conversion radix
			MOVW	2,X+, STATE			;restore compile state
			MOVW	2,X+, TO_IN			;restore parse index
			MOVW	2,X+, IP			;restore instruction pointer
			MOVW	2,X+, HANDLER			;restore exception handler
			MOVW	#$0000, SUSPEND_MARKER		;clear SUSPEND_MARKER	
			STX	RSP				;X -> RSP	
			;Restore TIB
			LDD	TIB_OFFSET			;restore char count
			SUBD	#TIB_START
			STD	NUMBER_TIB
			MOVW	#TIB_START,TIB_OFFSET		;reset TIB
			;Done
			NEXT


;ABORT run-time ( i*x -- ) ( R: j*x -- ) 
;Empty the data stack and perform the function of QUIT, which includes emptying
;the return stack, without displaying a message. 
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_ABORT_RT		EQU	*
			;Execute ABORT actions
			FORTH_ABORT
			;Execute QUIT actions
			;JOB	CF_QUIT_RT

;QUIT run-time ( -- ) ( R: j*x -- )
;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;input device the input source, and enter interpretation state. Do not display a
;message. Repeat the following: 
; -Accept a line from the input source into the input buffer, set >IN to zero,
;  and interpret. 
; -Display the system prompt if in interpretation state,
;  all processing has been completed, and no ambiguous condition exists.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_QUIT_RT		EQU	*
			;Execute QUIT actions
			FORTH_QUIT
			;Execute SUSPEND actions
			;JOB	CF_SUSPEND_RT

;SUSPEND ( -- )
;Execute a temporary debug shell.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     0 cells
; RS:     5 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_SUSPEND_RT		EQU	*
			;Execute SUSPEND actions
			FORTH_SUSPEND
			;Start shell
			JOB	CF_SHELL
	
;SHELL ( -- ) Generic interactive shell
;Common S12CForth shell. 
; args:   none
; result: none
; SSTACK: 22 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_SHELL		EQU	*
			;Print shell prompt			
CF_SHELL_1
			;Query command line



			;Parse command line
	


			;Interpret
	

	
			;New line
CF_SHELL_1		EXEC_CF	CF_CR 				;print line break
			;Print SUSPEND prompt			
			LDD	IP 				;check IP
			BEQ	CF_SHELL_2			;skip SUSPEND prpmpt
			PS_PUSH	#FINTEGER_SUSPEND_PROMPT		;print SUSPEND prompt
			EXEC_CF	CF_EMIT				
CF_SHELL_2		EQU	*			
			;Print NVC prompt			
#ifmac	NVC_PROMPT
			NVC_PROMPT
#endif	
			;Print COMPILE prompt			
			LDD	STATE				;check STATE
			BEQ	CF_SHELL_3 			;print interacive prompt
			LDD	#FINTEGER_COMPILE_PROMPT		;print compile prompt
			JOB	CF_SHELL_4
			;Print interactive prompt			
CF_SHELL_3		LDD	#FINTEGER_INTERACT_PROMPT		;print interactive prompt
CF_SHELL_4		PS_PUSH_D				;push string pointer onto PS
			EXEC_CF	CF_STRING_DOT			;print prompt
			;Query command line
			EXEC_CF	CF_QUERY



			;Parse command line
CF_SHELL_5        	FINTEGER_PARSE_WS
			TBEQ	D, CF_SHELL_1      	;parse next line



;			TBNE	D, CF_SHELL_7      	;parse next line
;			JOB	CF_SHELL_1
			;Search UDICT (string pointer in X, char count in D)
CF_SHELL_7		EQU	*	
#ifdef	NVC
			LDY	NVC	  		;ignore UDICT in NVCOMPILE mode
			BNE	CF_SHELL_8 		;skip UDICT search
#endif
;TBD			FUDICT_SEARCH	   		;search UDICT
;TBD			BCS	CF_SHELL_9		;process word	
CF_SHELL_8		EQU	*
#ifdef	NVC
			;Search NVDICT (string pointer in X, char count in D)
			FNVDICT_SEARCH
			BCS	CF_SHELL_9		;process word	
#endif
			;Search CDICT (string pointer in X, char count in D)
			FCDICT_SEARCH
			BCC	CF_SHELL_12		;evaluate string as integer	
			;Process word ({IMMEDIATE, CFA>>1} in D)
CF_SHELL_9		LSLD				;extract CFA
			BCS	CF_SHELL_10		;execute immediate word
			LDY	STATE			;check STATE
			BNE	CF_SHELL_11		;compile word	
			;Execute word (CFA in D)
CF_SHELL_10 		TFR	D, X
			EXEC_CFA_X
			JOB	CF_SHELL_6		;parse next word
			;Compile word (CFA in D)
CF_SHELL_11	;TBD	UDICT_COMPILE_WORD	 	;compile to UDICT or NVDICT buffer
			JOB	CF_SHELL_6		;parse next word
			;Evaluate string as integer (string pointer in X, char count in D) 
CF_SHELL_12		FINTEGER_INTEGER	     		;(SSTACK: 22 bytes)
			DBNE	D, CF_SHELL_14 		;double cell integer
			;Process single cell integer (number in X)
			LDD	STATE			;check STATE
			BNE	CF_SHELL_13		;compile number as literal
			;Push single cell integer onto PS (number in X)
			PS_CHECK_OF	1 		;new PSP -> Y
			STY	PSP			;update PSP
			STX	0,Y	   		;push number onto PS
			JOB	CF_SHELL_6		;parse next word
			;Compile single cell integern integer as literal (number in X)
CF_SHELL_13	;TBD	UDICT_COMPILE_LIT	 	;compile to UDICT or NVDICT buffer
			JOB	CF_SHELL_6		;parse next word
			;Check for valid double cell integer (cell count-1 in D,  number in Y:X)
CF_SHELL_14		DBNE	D, CF_SHELL_16 		;invalid number
			;Process double number (number in Y:X)
			LDD	STATE			;check STATE
			BNE	CF_SHELL_15		;compile number as literal
			;Push double number onto PS (number in Y:X)
			TFR	Y, D
			PS_CHECK_OF	2 		;new PSP -> Y
			STY	PSP			;update PSP
			STD	0,Y			;push double number onto PS
			STX	2,Y
			JOB	CF_SHELL_4		;parse next word
			;Compile double number as literal (number in Y:X)
CF_SHELL_15	;TBD	UDICT_COMPILE_DLIT	 	;compile to UDICT or NVDICT buffer
			JOB	CF_SHELL_6		;parse next word
			;Unknown word (or number out of range)
CF_SHELL_16		THROW	 FEXCPT_EC_UDEFWORD
	
;QUERY ( -- ) Query command line input
;Make the user input device the input source. Receive input into the terminal
;input buffer,mreplacing any previous contents. Make the result, whose address is
;returned by TIB, the input buffer.  Set >IN to zero.
; args:   none
; result: #TIB: char count in TIB
;         >IN:  index pointing to the start of the TIB => 0x0000
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_QUERY		EQU	*
			;Reset input buffer
			MOVW	#0000, NUMBER_TIB 	;zero chars in TIB
			MOVW	#0000, TO_IN		;parse area to start of TIB
			;Receive input
CF_QUERY_1		EXEC_CF	CF_EKEY			;input char -> [PS+0]
			;Check input (input car in [PS+0])
			LDD	[PSP] 			;input char -> B
			;Ignore LF (input car in B)
			CMPB	#STRING_SYM_LF
			BEQ	CF_QUERY_4		;ignore
			;Check for ENTER (CR) (input car in B and in [PS+0])
			CMPB	#STRING_SYM_CR	
			BEQ	CF_QUERY_8		;input complete		
			;Check for BACKSPACE (input char in B and in [PS+0])
			CMPB	#STRING_SYM_BACKSPACE	
			BEQ	CF_QUERY_7	 	;check for underflow
			CMPB	#STRING_SYM_DEL	
			BEQ	CF_QUERY_7	 	;check for underflow
			;Check for valid special characters (input char in B and in [PS+0])
			CMPB	#STRING_SYM_TAB	
			BEQ	CF_QUERY_2	 	;echo and append to buffer
			;Check for invalid characters (input char in B and in [PS+0])
			CMPB	#" " 			;first legal character in ASCII table
			BLO	CF_QUERY_5		;beep
			CMPB	#"~"			;last legal character in ASCII table
			BHI	CF_QUERY_5 		;beep			
			;Check for buffer overflow (input char in B and in [PS+0])
CF_QUERY_2		LDX	TIB_OFFSET 		;TIB_OFFSET -> X
			LEAX	TIB_PADDING,X		;TIB_OFFSET+TIB_PADDING -> X
			EXG	D, X
			ADDD	NUMBER_TIB
			EXG	D, X
			CPD	RSP
			BHS	CF_QUERY_5 		;beep
			;Append char to input line (input char in B and in [PS+0], TIB pointer+padding in X)
			STAB	-TIB_PADDING,X 		;append char
			LDX	NUMBER_TIB		;increment NUMBER_TIB
			LEAX	1,X
			STX	NUMBER_TIB			
			;Echo input char (input char in [PS+0])
CF_QUERY_3		EXEC_CF	CF_EMIT			;print character
			JOB	CF_QUERY_1
			;Ignore input char
CF_QUERY_4		LDY	PSP 			;drop char from PS
			LEAY	2,Y
			STY	PSP
			JOB	CF_QUERY_1
			;BEEP			
CF_QUERY_5		LDD	#STRING_SYM_BEEP	;replace received char by a beep
CF_QUERY_6		STD	[PSP]
			JOB	CF_QUERY_3 		;transmit beep
			;Check for buffer underflow (input char in [PS+0])
CF_QUERY_7		LDY	NUMBER_TIB 		;compare char count
			BEQ	CF_QUERY_5		;beep
			LDD	#STRING_SYM_BACKSPACE	;replace received char by a backspace
			JOB	CF_QUERY_6
			;Input complete
CF_QUERY_8		LDY	PSP 			;drop char from PS
			LEAY	2,Y
			STY	PSP
			LDY	NUMBER_TIB 		;check char count
			BEQ	CF_QUERY_9 		;command line is empty
			LEAY	-1,Y			;terminate last character
			LDD	TIB_OFFSET
			BSET	D,Y, #$80
CF_QUERY_9		NEXT

;PARSE ( char "ccc<char>" -- c-addr u ) Parse the TIB
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
; args:   PSP+0: delimiter char
; result: PSP+0: character count
;         PSP+1: string pointer
; SSTACK: 5 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_PARSE		EQU	*
			;Check PS
			PS_CHECK_UFOF	1, 1 		;new PSP -> Y
			STY	PSP
			;Get delimiter char (PSP in Y)
			LDAA	3,Y
			;Parse TIB (delimiter char in A, PSP in Y)  
			FINTEGER_PARSE 			;(SSTACK: 5 bytes)
			;Pass results to PS (char count in A, string pointer in X, PSP in Y)
			STX	2,Y
			TAB
			CLRA
			STD	0,Y
			;Done
			NEXT

;>NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) 
;ud2 is the unsigned result of converting the characters within the string
;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;left-to-right until a character that is not convertible, including any "+" or
;"-", is encountered or the string is entirely converted. c-addr2 is the
;location of the first unconverted character or the first character past the end
;of the string if the string was entirely converted. u2 is the number of
;unconverted characters in the string. If ud2 overflows during the conversion,
;both result and conversion string are left untouched.	
; args:   PSP+0: character count
;         PSP+1: string pointer
;         PSP+2: initial number
; result: PSP+0: remaining character count
;         PSP+1: pointer to unconverted substring
;         PSP+2: resulting number
; SSTACK: 18 bytes
; PS:     none
; RS:     none
; throws: FEXCPT_EC_PSUF
CF_TO_NUMBER		EQU	*
			;Check PS
			PS_CHECK_UF	4 		;PSP -> Y			
			;Check SSTACK (PSP in Y)
			SSTACK_PREPUSH	18
			;Copy parameters from PS to SSTACK (PSP in Y)
			MOVW	6,Y, 2,SP- 		;number LSW
			MOVW	4,Y, 2,SP-		;number MSW
			MOVW	2,Y, 2,SP-		;string pointer
			MOVW	0,Y, 2,SP-		;char count
			;copy BASE to SSTACK (PSP in Y)
			FINTEGER_FIX_BASE
			PSHD
			;Try to convert string to number  (PSP in Y)
			FINTEGER_TO_NUMBER		;(SSTACK: 8 bytes)
			BCC	CF_TO_NUMBER_1		;numeric overflow
			;Copy parameters from SSTACK to PS (PSP in Y)
			SSTACK_PREPULL	10
			MOVW	2,SP, 0,Y 		;char count
			MOVW	4,SP, 2,Y 		;string pointer
			MOVW	6,SP, 4,Y 		;number MSW
			MOVW	8,SP, 6,Y 		;number LSW
			;Clean up SSTACK
CF_TO_NUMBER_1		LEAS	10,SP
			;Done
			NEXT
	
;INTEGER ( c-addr u -- d s | n 1 | 0) Interpret string as integer
;Interpret string as integer value and return a single or double cell number
;along with the cell count. If the interpretation was unsuccessful, return a
;FALSE flag
; args:   PSP+0: char count
;         PSP+1: string pointer
; result: PSP+0: cell count
;         PSP+1: double value
; or
;         PSP+0: cell count
;         PSP+1: single value
; or
;         PSP+0: false flag
; SSTACK: 22 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_INTEGER		EQU	*
			;Check PS
			PS_CHECK_UFOF	2, 1 		;new PSP -> Y
			STY	PSP
			;Interpret string (PSP in Y)
			LDD	2,Y
			LDX	4,Y
			FINTEGER_INTEGER			;(SSTACK: 22 bytes)
			STD	0,Y			;store cell count
			DBEQ	D, CF_INTEGER_4		;single cell
			DBNE	D, CF_INTEGER_2		;not an integer (done)
			;Double cell value (integer in Y:X) 
			TFR	Y, D
			LDY	PSP
			STD	2,Y
			STX	4,Y
			;Done
CF_INTEGER_1		NEXT
			;Not an integer 
CF_INTEGER_2		LDY	PSP
			MOVW	#$0000, 4,+Y
CF_INTEGER_3		STY	PSP
			JOB	CF_INTEGER_1 		;done
			;Single cell value (integer in X) 
CF_INTEGER_4		LDY	PSP
			MOVW	#$0001, 2,+Y
			JOB	CF_INTEGER_3

;RESUME ( -- ) IMMEDIATE
;Exit suspend mode 
;
;Throws:
;"Return stack underflow"
CF_RESUME		EQU	*
#ifdef HANDLER
			RS_PULL5	HANDLER, TO_IN, NUMBER_TIB, TIB_OFFSET, IP
#else
			RS_PULL4	TO_IN, NUMBER_TIB, TIB_OFFSET, IP
#endif

			LDX	NEXT_WATCH 
			STX	NEXT_PTR
			JMP	0,X 			;jump to next watch
	
;LITERAL run-time semantics
;Run-time: ( -- x )
;Place x on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CF_LITERAL_RT		EQU	*
			PS_CHECK_OF	1		;check for PS overflow (PSP-new cells -> Y)
			LDX	IP			;push the value at IP onto the PS
			MOVW	2,X+ 0,Y		; and increment the IP
			STX	IP
			STY	PSP
			NEXT

;2LITERAL run-time semantics
;Run-time: ( -- d )
;Place d on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CF_TWO_LITERAL_RT	EQU	*
			PS_CHECK_OF	2		 ;check for PS overflow (PSP-new cells -> Y)
			LDX	IP			 ;push the value at IP onto the PS
			MOVW	2,X+, 0,Y		 ; and increment the IP
			MOVW	2,X+, 2,Y		 ; and increment the IP
			STX	IP
			STY	PSP
			NEXT
	
FINTEGER_CODE_END		EQU	*
FINTEGER_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FINTEGER_TABS_START_LIN
			ORG 	FINTEGER_TABS_START, FINTEGER_TABS_START_LIN
#else
			ORG 	FINTEGER_TABS_START
FINTEGER_TABS_START_LIN	EQU	@
#endif	

;Symbol tables
FINTEGER_SYMTAB		EQU	NUM_SYMTAB
	
;System prompts
FINTEGER_SUSPEND_PROMPT	EQU	"!"
#ifdef NVC
FINTEGER_NVCOMPILE_PROMPT	FCS	"@ "
#endif
FINTEGER_COMPILE_PROMPT	FCS	"+ "
FINTEGER_INTERACT_PROMPT	FCS	"> "

FINTEGER_SYSTEM_ACK	FCS	" ok"

;;SUSPEND information
;FINTEGER_SUSPEND_INFO_1	FCS	"Suspended! IP:"
;FINTEGER_SUSPEND_INFO_2	FCS	" -> "
;FINTEGER_SUSPEND_INFO_3	STRING_NL_TERM
;			DB	FINTEGER_SUSPEND_PROMPT

	
FINTEGER_TREE_EOB		EQU	$00 	;end of branch
FINTEGER_TREE_BI		EQU	$00 	;branch indicator
FINTEGER_TREE_ES		EQU	$00 	;empty string
	
FINTEGER_TABS_END		EQU	*
FINTEGER_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FINTEGER_WORDS_START_LIN
			ORG 	FINTEGER_WORDS_START, FINTEGER_WORDS_START_LIN
#else
			ORG 	FINTEGER_WORDS_START
FINTEGER_WORDS_START_LIN	EQU	@
#endif	
			ALIGN	1
;#ANSForth Words:
;================
;Word: QUERY ( -- )
;Make the user input device the input source. Receive input into the terminal
;input buffer,mreplacing any previous contents. Make the result, whose address is
;returned by TIB, the input buffer.  Set >IN to zero.
;
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
;"Invalid RX data"
CFA_QUERY		DW	CF_QUERY

;Word: PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
;
;Throws:
;"Parameter stack overflow"
;"Parameter stack underflow"
CFA_PARSE		DW	CF_PARSE

;Word: >NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) 
;ud2 is the unsigned result of converting the characters within the string
;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;left-to-right until a character that is not convertible, including any "+" or
;"-", is encountered or the string is entirely converted. c-addr2 is the
;location of the first unconverted character or the first character past the end
;of the string if the string was entirely converted. u2 is the number of
;unconverted characters in the string. If ud2 overflows during the conversion,
;both result and conversion string are left untouched.
;
;Throws:
;"Parameter stack underflow"
CFA_TO_NUMBER		DW	CF_TO_NUMBER
	
;Word: BASE ( -- a-addr ) 
;a-addr is the address of a cell containing the current number-conversion radix
;{{2...36}}. 
;
;Throws:
;"Parameter stack overflow"
CFA_BASE		DW	CF_CONSTANT_RT
			DW	BASE

;Word: STATE ( -- a-addr ) 
;a-addr is the address of a cell containing the compilation-state flag. STATE is
;true when in compilation state, false otherwise. The true value in STATE is
;non-zero. Only the following standard words alter the value in STATE:
; : (colon), ; (semicolon), ABORT, QUIT, :NONAME, [ (left-bracket), and
; ] (right-bracket). 
;  Note:  A program shall not directly alter the contents of STATE. 
;
;Throws:
;"Parameter stack overflow"
CFA_STATE		DW	CF_CONSTANT_RT
			DW	STATE
	
;Word: >IN ( -- a-addr )
;a-addr is the address of a cell containing the offset in characters from the
;start of the input buffer to the start of the parse area.  
;
;Throws:
;"Parameter stack overflow"
CFA_TO_IN		DW	CF_CONSTANT_RT
			DW	TO_IN

;Word: #TIB ( -- a-addr )
;a-addr is the address of a cell containing the number of characters in the
;terminal input buffer.
;
;Throws:
;"Parameter stack overflow"
CFA_NUMBER_TIB		DW	CF_CONSTANT_RT
			DW	NUMBER_TIB

;Word: WORDS ( -- )
;List the definition names in the first word list of the search order. The
;format of the display is implementation-dependent.
;WORDS may be implemented using pictured numeric output words. Consequently, its
;use may corrupt the transient region identified by #>.
CFA_WORDS		DW	CF_INNER
			DW	CFA_WORDS_CDICT
			DW	CFA_EOW

;#S12CForth Words:
;=================
;Word: INTEGER ( c-addr u -- d s | n 1 | 0)
;Interpret string as integer value and return a single or double cell number
;along with the cell count. If the interpretation was unsuccessful, return a
;FALSE flag
;
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
CFA_INTEGER		DW	CF_INTEGER

;Word: SUSPEND ( -- )
;Execute a temporary debug shell.
;
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
;"Communication error"
CFA_SUSPEND		DW	CF_SUSPEND

;Word: RESUME ( -- ) IMMEDIATE
;Exit suspend mode 
;
;Throws:
;"Return stack underflow"
CFA_RESUME		DW	CF_RESUME

;Word: TIB-OFFSET ( -- a-addr )
;a-addr is the address of a cell containing the number of characters in the
;terminal input buffer.
;
;Throws:
;"Parameter stack overflow"
CFA_TIB_OFFSET		DW	CF_CONSTANT_RT
			DW	TIB_OFFSET

;LITERAL run-time semantics
;Run-time: ( -- x )
;Place x on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CFA_LITERAL_RT		DW	CF_LITERAL_RT

;2LITERAL run-time semantics
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CFA_TWO_LITERAL_RT	DW	CF_TWO_LITERAL_RT

FINTEGER_WORDS_END	EQU	*
FINTEGER_WORDS_END_LIN	EQU	@
#endif
