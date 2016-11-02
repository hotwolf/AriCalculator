#ifndef FUDICT_COMPILED
#define FUDICT_COMPILED
;###############################################################################
;# S12CForth - FUDICT - User Dictionary and User Variables                     #
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
;#    This module implements the volatile user dictionary.                     #
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
;#             CP = Compile pointer                                            #
;#                  Points to the next free space after the dictionary         #
;#        CP_SAVE = Previous compile pointer                                   #
;#       STRATEGY = Current compile interpreter:                               #
;#  		        0: Compilation inhibited			       #
;#  		       -1: Volatile compile strategy			       #
;#  		       +1: Non-volatile compile strategy (use UDICT as buffer) #
;#  									       #
;#    Non-Volatile compile strategy:                                           #
;#    The non-volatile dictionary space is allocated after scanning the flash  #
;#    memory. When the NVDICT is selected as compile target, the UDICT is      #
;#    cleared and used as a buffer for compilation. During this buffered       #
;#    compilation, the data pointer is tracked in the variable DP. The compile #
;#    pointer is tracked in the variable CP. Dictionary entries in the compile #
;#    in interpretation state. Look-ups in compile state will return address   #
;#    translated CFAs pointing to the intended location within the flash       #
;#    space. Then the compilation of a code sequence is finished, the compile  #
;#    buffer is copied into the flash as a string.                             #
;#                                                                             #
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

;###############################################################################o
;# Memory Layout                                                               #
;###############################################################################
;        
;      	                    +--------------+--------------+	     
;         UDICT_PS_START -> |                             | 	     
;                           |     NVDICT Variables        |	     
;                           |                             | <- [DP]	     
;                           | --- --- --- --- --- --- --- |          
;                           |              |              |	     
;                           |       User Dictionary       |	     
;                           |       User Variables        |	     
;                           |              |              | <- [UDICT_LAST_NFA]	     
;                           |              v              |	     
;                       -+- | --- --- --- --- --- --- --- |
;             UDICT_PADDING |                             | <- [CP]	     
;                       -+- | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [HLD]	     
;                           |             PAD             |	     
;                       -+- | --- --- --- --- --- --- --- |          
;             PS_PADDING |  |                             | <- [PAD]          
;                       -+- .                             .          
;                           .                             .          
;                           | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [PSP]	  
;                           |              |              |		  
;                           |       Parameter stack       |		  
;    	                    |              |              |		  
;                           +--------------+--------------+        
;              PS_EMPTY, ->   
;          UDICT_PS_END
;	
;                           Word format:
;                           +--------------+
;                     NFA-> |   Previous   |	
;                           |     NFA      | 
;                           |              | 
;                           +--------------+
;                   NFA+2-> |     Name     | 
;                           |              | 
;                           |     MSB-     | 
;                           | terminated   | 
;                           |    string    | 
;                           |              | 
;                           +--------------+
;                      IF-> |  Info Field  |	
;                           +--------------+
;                      CF-> |              | 
;                           |  Code Field  | 
;                           |              | 
;                           +--------------+   
;                           |   Optional   | 
;                           |  Data Field  | 
;                           |   for RAM    | 
;                           | Compilation  | 
;                           +--------------+   
;	
;	
; Non-volatile compilation:	
;  	                         DP               CP
;  	 Reserved data space      |                |
;  	------------------------->V                V
;       +-----------------------------------------+------	
;	| NVDICT image in RAM ------------------> |
;	+-----------------------------------------+------
;	^
;	 \
;         \	
;	   \FUDICT_OFFSET
;	    \(source-target)
;            \	
;	      \
;	       \
;       +------+-----------------------------------------	
;	|NVDICT| Target location of NVDICT image
;	+------+-----------------------------------------
;	
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#String termination 
FUDICT_TERM		EQU	STRING_TERM

;#Compile strategies 
NO_COMLILE		EQU	$0000 		;interpretation state
;NV_COMPILE		EQU	$0001 		;non-volentile compile
;COMPILE		EQU	$FFFF 		;volentile compile
	
;#Compile optimization info
;High byte
FUDICT_CI_NOINL		EQU	$80 		;no inline
;Low byte
FUDICT_CI_NONE		EQU	$00
FUDICT_CI_BSR		EQU	$01
FUDICT_CI_JSR		EQU	$02
FUDICT_CI_IF		EQU	$FF
FUDICT_CI_ELSE		EQU	$FE
FUDICT_CI_DO		EQU	$FD
FUDICT_CI_BEGIN		EQU	$FC
FUDICT_CI_WHILE		EQU	$FB
	
;#INLINE optimization
FUDICT_MAX_INLINE	EQU	8 		;max. CF size for INLINE optimization

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FUDICT_VARS_START_LIN
			ORG 	FUDICT_VARS_START, FUDICT_VARS_START_LIN
#else
			ORG 	FUDICT_VARS_START
FUDICT_VARS_START_LIN	EQU	@
#endif

			ALIGN	1	
CP			DS	2 	;compile pointer (next free space in the dictionary space) 
CP_SAVE			DS	2 	;compile pointer to revert to in case of an error
STRATEGY		DS	2	;

FUDICT_LAST_NFA		DS	2 	;pointer to the most recent NFA of the UDICT
FUDICT_OFFSET		DS	2 	;offset = source - target
	
FUDICT_VARS_END		EQU	*
FUDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FUDICT_INIT, 0
			MOVW	DP, CP
			MOVW	#COMPILE, STRATEGY
			MOVW	#$0000, FUDICT_LAST_NFA
			MOVW	#$0000, FUDICT_OFFSET
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FUDICT_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FUDICT_QUIT, 0
			MOVW	CP_SAVE, CP 		;restore cp
#emac

;#System integrity monitor
;=========================
#macro	FUDICT_MON, 0
#emac

;#State restrictions
;===================
;Only execute this CF in compile state (STATE -> D)
#macro	COMPILE_ONLY, 0
			LDD	STATE 			;STATE -> D
			BEQ	FUDICT_THROW_COMPONLY	;throw exception
#emac

;Only execute this CF in interpretation state (STATE -> D)
#macro	INTERPRET_ONLY, 0
			LDD	STATE 			;STATE -> D
			BNE	FUDICT_THROW_COMPNEST	;throw exception
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FUDICT_CODE_START_LIN
			ORG 	FUDICT_CODE_START, FUDICT_CODE_START_LIN
#else
			ORG 	FUDICT_CODE_START
FUDICT_CODE_START_LIN	EQU	@
#endif

;#IO
;===
;#Print a list separator (SPACE or line break)
; args:   D:      char count of next word
;         0,SP:   line counter 
; result: 0,SP;   updated line counter
; SSTACK: 10 bytes
;         Y is preserved
FUDICT_LIST_SEP		EQU	FOUTER_LIST_SEP
	
;#String operations
;==================
;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character 
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
FUDICT_UPPER		EQU	STRING_UPPER

;#Prints a MSB terminated string
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FUDICT_TX_STRING	EQU	STRING_PRINT_BL

;#Functions
;==========
;#Throw "interpreting a compile-only word" exception
; args:   none
FUDICT_THROW_COMPONLY	EQU	*
			THROW	FEXCPT_TC_COMPONLY

;#Throw "compiler nesting" exception
; args:   none
FUDICT_THROW_COMPNEST	EQU	*
			THROW	FEXCPT_TC_COMPNEST

;#########
;# Words #
;#########


;Word: [
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: Perform the execution semantics given below.
;Execution: ( -- )
;Enter interpretation state. [ is an immediate word.
IF_LEFT_BRACKET			IMMEDIATE
CF_LEFT_BRACKET			EQU	*
				MOVW	#$0000, STATE
				RTS

;Word: ] ( -- )
;Enter compilation state.
IF_RIGHT_BRACKET		IMMEDIATE
CF_RIGHT_BRACKET		EQU	*
				MOVW	STRATEGY, STATE
				RTS
	
;Word: LU-UDICT ( c-addr u -- xt | c-addr u false )
;Look up a name in the UDICT dictionary. The name is referenced by the start
;address c-addr and the character count u. If successful the resulting execution
;token xt is returned. Otherwise the name reference remains on the parameter
;stack along with a false flag.
;When the UDICT dictionary is used as a buffer for compilation to non-volatile
;memory, xt will reference the code field in the target memory. Therefore it  
;must not be executed before the buffered compilation is flushed into the non-
;volatile memory
IF_LU_UDICT		REGULAR
CF_LU_UDICT		EQU	*
			;RS layout:
			; +--------+--------+
			; |    Iterator     | SP+0
			; +--------+--------+
			; | Compile Offset  | SP+2
			; +--------+--------+
			;Check compile strategy ( c-addr u )
			BRCLR	STRATEGY,#$80, CF_LU_UDICT_6
			;Check u ( c-addr u )
			LDD	0,Y			;check if u is zero
			BEQ	CF_LU_UDICT_6 		;empty seaech string (search failed)
			;Initialize interator structure ( c-addr u )
			LDD	FUDICT_LAST_NFA 	;last NFA -> D
			BEQ	CF_LU_UDICT_6 		;empty dictionary (search failed)
			MOVW	#0000, 2,-SP 		;0 -> compile offset
			PSHD				 ;last NFA -> iterator
			;Compare first letter ( c-addr u )
CF_LU_UDICT_1		LDAB	[2,Y] 			;LU char -> B
			JOBSR	FUDICT_UPPER		;make upper case
			LDX	0,SP	 		;UDICT entry -> X
			LDAA	2,+X			;UDICT char -> A, UDICT string -> X
			ANDA	#~FUDICT_TERM		;remove termination
			CBA				;compare chars
			BNE	CF_LU_UDICT_3		;skip to next UDICT entry
			;Compare string lengths ( c-addr u ) (UDICT string -> X) 
			BRCLR	1,X+,#FUDICT_TERM,* 	;skip to end of UDICT string 
			TFR	X, D			;end of UDICT string -> D
			SUBD	0,SP			;subtract UDICT entry offset
			SUBD	#2			;subtract name offsetr
			CPD	0,Y			;compare string lengths
			BNE	CF_LU_UDICT_3		;skip to next UDICT entry
			;Compare strings ( c-addr u ) (UDICT EOS -> X) 
			; +--------+--------+
			; |    LU pointer   | SP+0
			; +--------+--------+
			; |  UDICT pointer  | SP+2
			; +--------+--------+
			; |    Iterator     | SP+4
			; +--------+--------+
			; | Compile Offset  | SP+6
			; +--------+--------+
			PSHX				;UDICT pointer -> 2,PS
			LDD	2,Y 			;c-addr        -> D
			ADDD	0,Y			;c-addr+u      -> D
			PSHD				;LU pointer    -> 0,PS
CF_LU_UDICT_2		LDX	0,SP			;LU pointer -> X
			LDAB	1,-X			;LU char -> B
			CPX	2,Y			;check LU pointer
			BEQ	CF_LU_UDICT_4		;search successful
			STX	0,SP			;update LU pointer
			LDX	2,SP			;UDICT pointer -> X
			LDAA	1,-X			;UDICT char -> A
			STX	2,SP			;update UDICT pointer
			JOBSR	FUDICT_UPPER		;make LU char upper case
			ANDA	#~FUDICT_TERM		;remove UDICT char termination
			CBA				;compare chars
			BEQ	CF_LU_UDICT_2		;check next char
			LEAS	4,SP			;remove LU and UDICT pointer from RS
			;Skip next entry ( c-addr u )
CF_LU_UDICT_3		LDX	0,SP			;iterator -> X
			LDD	0,X			;previous entry -> D
			BEQ	CF_LU_UDICT_5		;Search failed
			ADDD	2,SP			;add compile offset
			STD	0,SP			;advance iterator
			JOB	CF_LU_UDICT_1		;check next UDICT entry
			;Search successful ( c-addr u )
CF_LU_UDICT_4		LEAS	4,SP	 		;remove LU and UDICT pointer from RS
			LDX	4,SP+	 		;remove iterator from RS
			LEAX	2,X			;skip to start of UDICT string
			BRCLR	1,X+,#FUDICT_TERM,* 	;skip to end of UDICT string 
			INX				;skip over
			STX	2,+Y			;return xy
			RTS
			;Search failed ( c-addr u )
CF_LU_UDICT_5		LEAS	4,SP	 		;clean up RS
CF_LU_UDICT_6		MOVW	#FALSE	2,-Y		;return FALSE flag
			RTS				;done

;Word: WORDS-UDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
;When the UDICT dictionary is used as a buffer for compilation to non-volatile
;memory, no word list is printed 
IF_WORDS_UDICT		REGULAR
CF_WORDS_UDICT		EQU	*
			;RS layout:
			; +--------+--------+
			; |  Line Counter   | SP+0
			; +--------+--------+
			; |    Iterator     | SP+2
			; +--------+--------+
			;Check compile strategy
			BRCLR	STRATEGY,#$80, CF_WORDS_UDICT_3
			;Initialize interator structure 
			LDX	FUDICT_LAST_NFA		;last NFA -> X
			BEQ	CF_WORDS_UDICT_3	;empty dictionary
			PSHX				;iterator -> RS
			INX				;NF pointer -> X
			BRCLR	1,+X,#FUDICT_TERM,*	;skip to last char
			DEX				;adjust NF pointer
			TFR	X, D			;NF pointer -> D
			SUBD	0,SP			;calculate name length
			PSHD				;char count -> line counter
			;Start new line
			JOBSR	CF_CR 			;line break
			;Print word
CF_WORDS_UDICT_1	LDX	2,SP 			;iterator -> X
			MOVW	2,X+, 2,SP		;advance iterator
			JOBSR	FUDICT_TX_STRING	;print name
			LDX	2,SP 			;iterator -> X
			BEQ	CF_WORDS_UDICT_2	;done
			INX				;NF pointer -> X
			BRCLR	1,+X,#FUDICT_TERM,*	;skip to last char
			DEX				;adjust NF pointer
			TFR	X, D			;NF pointer -> D
			SUBD	2,SP			;calculate name length
			MOVW	#CF_WORDS_UDICT_1, 2,-SP;push return address (CF_WORDS_UDICT_1)
			JOB	FUDICT_LIST_SEP		;print separator
			;Clean up
CF_WORDS_UDICT_2	LEAS	4,SP 			;clean up stack
CF_WORDS_UDICT_3	RTS				;done
	
	
;Word: : ( C: "<spaces>name" -- colon-sys )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name, called a colon definition. Enter compilation state and
;start the current definition, producing colon-sys. Append the initiation
;semantics given below to the current definition.
;The execution semantics of name will be determined by the words compiled into
;the body of the definition. The current definition shall not be findable in the
;dictionary until it is ended (or until the execution of DOES> in some systems).
;colon-sys:
;      	    +--------------+--------------+	     
;           |       Compile Info          | +0	     
;      	    +--------------+--------------+	     
;           |  Information Field Address  | +2	     
;      	    +--------------+--------------+	     
;           |      Name Field Address     | +4	     
;      	    +--------------+--------------+	     
;
IF_COLON		IMMEDIATE			
CF_COLON		INTERPRET_ONLY			;catch nested compilation
			;Parse name 
CF_COLON_1		MOVW	#" ", 2,-Y 		;set delimeter
			JOBSR	CF_SKIP_AND_PARSE	;parse name
			LDD	0,Y			;check name
			BNE	CF_COLON_2		;name found
			THROW	FEXCPT_TC_NONAME	;throw "missing name" exception
			;Set STATE ( c-addr u )
CF_COLON_2		LDD	STRATEGY 		;STRATEGY -> D
			BEQ	CF_COLON_4		;done
			STD	STATE			;STRATEGY -> STATE
			;Push colon-sys ( c-addr u )
			MOVW	0,SP,  6,-SP 		;(RS: ret xx  xx  ret)
			MOVW	#FUDICT_CI_NONE, 2,SP	;(RS: ret xx  opt ret)
			LDX	CP			;CP -> X
			STX	6,SP		  	;(RS: NFA xx opt ret)
			;Allocate compile space ( c-addr u ) (CP in X)
			TFR	X, D			;CP -> D
			ADDD	0,Y			;CP+name -> D
			ADDD	#$0003			;CP+nane+NFA+IF -> D
			STD	CP			;update CP
			SUBD	#1			;IFA -> D
			STD	4,SP			;(RS: NFA IFA opt ret)
			;Compile last NFA ( c-addr u ) (compile pointer in X)
			MOVW	FUDICT_LAST_NFA, 2,X+ 	;compile last NFA
			;Compile name ( c-addr u ) (compile pointer in X)
			MOVW	0,Y, 2,-Y 		;( c-addr u   u )
			STX	2,Y			;( c-addr SOS u )
			STX	4,-SP			;( c-addr SOS u ) (RS: NFA IFA opt ret xx SOS)
			LDD	0,Y			;u   -> D
			LEAX	D,X			;EOS -> X
			STX	2,SP			;( c-addr SOS u ) (RS: NFA IFA opt ret EOS SOS)
			JOBSR	CF_MOVE			;copy name (RS: NFA IFA opt ret EOS SOS)
			PULX				;SOS -> X (RS: NFA IFA opt ret EOS)
CF_COLON_3		LDAB	0,X			;char -> B
			JOBSR	FUDICT_UPPER		;make upper case
			STAB	1,X+			;update char
			CPX	0,SP			;check for EOS
			BLO	CF_COLON_3		;LOOP
			PULX				;(RS: NFA IFA opt ret)
			BSET	-1,X,#FUDICT_TERM	;terminate name string
			;Compile IF (compile pointer in X)
			CLR	0,X 			;REGULAR
CF_COLON_4		RTS				;done

;Word: MOVE ( addr1 addr2 u -- )
;If u is grater than zero, copy the contents of u consecutive address units at
;addr1 to the u consecutive address units at addr2. After MOVE completes, the u
;consecutive address units at addr2 contain exactly what the u consecutive
;address units at addr1 contained before the move.
IF_MOVE			REGULAR	
CF_MOVE			EQU	*
			LDD	0,Y 			;u             -> D
			BEQ	CF_MOVE_2 		;done
			ADDD	2,Y			;addr2 + u     -> D
			STD	0,Y			;addr2 + u     -> PS
			LDD	4,Y 			;addr1         -> D
			SUBD	2,Y 			;addr1 - addr2 -> D
			LDX	2,Y 			;addr2         -> X
CF_MOVE_1		MOVB	D,X, 1,X+ 		;copy byte
			CPX	0,Y 			;check range	
			BLO	CF_MOVE_1 		;loop
CF_MOVE_2		LEAY	6,Y			;clean up stack	
			RTS
	
;Word: COMPILE, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( xt -- )
;Append the execution semantics of the definition represented by xt to the
;execution semantics of the current definition.
IF_COMPILE_COMMA	IMMEDIATE
CF_COMPILE_COMMA	COMPILE_ONLY
			;Get xt ( xt )
CF_COMPILE_COMMA_1	LDX	0,Y 			;xt -> X
			LDAB	-1,X			;IF -> B
			BNE	CF_COMPILE_COMMA_6	;not REGULAR
			;REGULAR word ( xt ) 
CF_COMPILE_COMMA_2	LDX	CP 			;CP   -> X		
			TFR	X,D 			;CP   -> D
			SUBD	FUDICT_OFFSET		;CP-offs -> D
			SUBD	0,Y			;CP-offs-xt -> D
			BCC	CF_COMPILE_COMMA_4	;compile BSR
			CPD	#128			
			BLS	CF_COMPILE_COMMA_4	;compile BSR
			;Compile JSR ( xt ) (CP in X)
			LEAX	3,X 			;allocate compile space
			STX	CP			;update CP
			MOVB	#$16, -3,X		;compile "JSR" opcode
			MOVW	2,Y+, -2,X		;compile xt	
			BRSET	3,SP,#80,CF_COMPILE_COMMA_3;unfinished control flow
			MOVB	#FUDICT_CI_JSR, 3,SP	;set compile info
CF_COMPILE_COMMA_3	RTS				;done
			;Compile BSR ( xt ) (CP in X, negated rel. addr in B)
CF_COMPILE_COMMA_4	LEAX	2,X 			;allocate compile space
			STX	CP			;update CP
			MOVB	#$07, -2,X		;compile "BSR" opcode
			NEGB				;rel. addr -> B
			STAB	-1,X			;compile rel. addr
			BRSET	3,SP,#80,CF_COMPILE_COMMA_5;unfinished control flow
			MOVB	#FUDICT_CI_BSR, 3,SP	;set compile info
CF_COMPILE_COMMA_5	BSET	2,SP,#FUDICT_CI_NOINL;forbid INLINE compilation
			RTS				;done
			;Word not REGULAR ( xt ) (xt in X, IF in B)
CF_COMPILE_COMMA_6	CMPB	#IMMEDIATE 		;check for IMMEDIATE word
			BEQ	CF_COMPILE_COMMA_2	;compile as REGULAR word
			LDX	CP			;CP -> X
			STX	2,-Y			;( xt CP )
			CLRA				;u  -> D
			STD	2,-Y			;( xt CP u )
			LEAX	B,X			;allocate compile space
			STX	CP			;update CP
			JOBSR	CF_MOVE			;copy INLINE code
			BRSET	3,SP,#80,CF_COMPILE_COMMA_7;unfinished control flow
			CLR	3,SP			;set compile info
CF_COMPILE_COMMA_7	RTS				;done
	
;Word: ; 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys -- )
;Append the run-time semantics below to the current definition. End the current
;definition, allow it to be found in the dictionary and enter interpretation
;state, consuming colon-sys. If the data-space pointer is not aligned, reserve
;enough data space to align it.
;Run-time: ( -- ) ( R: nest-sys -- )
;Return to the calling definition specified by nest-sys.
IF_SEMICOLON		IMMEDIATE			
CF_SEMICOLON		COMPILE_ONLY			;catch nested compilation
			;Check for optimized word ending
CF_SEMICOLON_1		LDX	CP 			;CP -> X
			LDAB	3,SP 			;colon-sys(opt. info)
			BMI	CF_SEMICOLON_5		;control structure mismatch
			BNE	CF_SEMICOLON_6		;check for optimization
			;Consider INLINE optimization (CP in X) 
CF_SEMICOLON_2		BRSET	2,SP,#FUDICT_CI_NOINL,CF_SEMICOLON_3;INLINE blocked
			TFR	X, D 			;CP           -> D
			SUBD	4,SP			;CF length +1 -> D
			BCS	CF_SEMICOLON_3		;no INLINE optimization
			CPD	#(FUDICT_MAX_INLINE+1)	;chech CF length
			BHI	CF_SEMICOLON_3		;no INLINE optimization
			DECB				;adjust INLINE size
			STAB	[4,SP]			;set IF to INLINE
			;No optimized word ending (CP in X)
CF_SEMICOLON_3		INX				;increment CP
			STX	CP			;updated CP
			MOVB	#$3D, -1,X		;compile "RTS"
CF_SEMICOLON_4		STX	CP_SAVE 		;secure compiled space
			;Embed word into dictionary 
			MOVW	6,SP, FUDICT_LAST_NFA 	;link word
			MOVW	#INTERPRET, STATE	;leve compile state
			LDX	8,SP+			;clean up colon-sys
			JMP	0,X			;done
			;Control structure misatch
CF_SEMICOLON_5		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
			;Check for optimization (opt. info in B, CP in X)
CF_SEMICOLON_6		DBEQ	B, CF_SEMICOLON_7 	;BSR optimization
			DBNE	B, CF_SEMICOLON_2	;no optimization
			;JSR optimization (CP in X)
			LDAA	#$16			;check for JSR ext
			CMPA	-3,X			;compare opcode
			BNE	CF_SEMICOLON_2		;no optimization
			MOVB	#$06, -3,X		;replace JSR by JMP
			JOB	CF_SEMICOLON_4		;finish up
			;BSR optimization 	
CF_SEMICOLON_7		LDAA	#$07			;check for BSR ext
			CMPA	-2,X			;compare opcode
			BNE	CF_SEMICOLON_2		;no optimization
			MOVB	#$20, -2,X		;replace BSR by BRA
			JOB	CF_SEMICOLON_4		;finish up
	
;Word: CONSTANT ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a constant.
;name Execution: ( -- x )
;Place x on the stack.
IF_CONSTANT		REGULAR
CF_CONSTANT		EQU	*
			;Swap return address <-> compile info
			PULD
			PULX
			PSHD
			PSHX
			;Compile header 
			JOBSR	CF_COLON 		;use standard ":" 
			;Compile body 
			JOBSR	CF_LITERAL_1 		;LITERAL
			;Conclude compilation		
			JOBSR	CF_SEMICOLON_1 		;";"
			;Swap return address <-> compile info
			PULD
			PULX
			PSHD
			JMP	0,X
	
;Word: LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x -- )
;Append the run-time semantics given below to the current definition.
;Run-time: ( -- x )
;Place x on the stack.
IF_LITERAL		IMMEDIATE
CF_LITERAL		COMPILE_ONLY
			;Allocate compile space 
CF_LITERAL_1		LDX	CP 			;CP -> X
			LEAX	5,X			;allocate 5 bytes
			STX	CP			;update CP
			;Compile execution semantics 
			MOVW	#$1800, -5,X		;"MOVW $xxxx, 2,-SP"
			MOVB	#$6E,   -3,X		; => 18006Exxxx
			MOVW	2,Y+,   -2,X		;compile top of PS
			;Set compile info 
			BRSET	3,SP,#80,CF_LITERAL_2	;unfinished control flow
			CLR	3,SP			;no optimization
CF_LITERAL_2		RTS				;done

;Word: 2LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x1 x2 -- )
;Append the run-time semantics below to the current definition.
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
IF_2LITERAL		IMMEDIATE
CF_2LITERAL		COMPILE_ONLY	
CF_2LITERAL_1		JOBSR	CF_SWAP			;(x1 x2 -- x2 x1)
			JOBSR	CF_LITERAL_1		;compile x1
			JOB	CF_LITERAL_1		;compile x2

;Word: S, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( c-addr u  -- )
;Append the the string given by start address c-addr and length u to the
;execution semantics of the current definition.
IF_STRING_COMMA		IMMEDIATE
CF_STRING_COMMA		COMPILE_ONLY
			;Calculate EOS
CF_STRING_COMMA_1	LDD	0,Y 			;u      -> D
			LDX	2,Y			;c-addr -> X
			LEAX	D,X			;EOS    -> X
			STX	0,Y			;EOS	-> PS
			;Allocate compile space (u in D)
			LDX	CP 			;CP     -> X
			LEAX	D,X			;new CP -> X
			STX	CP			;update CP
			;Calculate memory offset (new CP in X) 
			TFR	X, D			;new CP -> D
			SUBD	0,Y			;offset -> D
			;Copy loop (memory offset in D)
			LDX	2,Y 			;string -> X
CF_STRING_COMMA_2	MOVB	0,X, D,X		;copy char
			BCLR	D,X,FUDICT_TERM		;remove termination
			INX				;advance 
			CPX	0,Y			;check for EOS
			BNE	CF_STRING_COMMA_2	;loop
			DEX				;go back to last char
			BSET	D,X,FUDICT_TERM		;terminate string
			LEAY	4,Y			;clean up PS
			;Set compile info 
			BRSET	3,SP,#80,CF_STRING_COMMA_3;unfinished control flow
			CLR	3,SP 			;disable optimization
CF_STRING_COMMA_3	RTS				;done


;Word: .(
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<paren>" -- )
;Parse and display ccc delimited by ) (right parenthesis). .( is an immediate
;word.
IF_DOT_PAREN		IMMEDIATE
CF_DOT_PAREN		EQU	*
			;Parse "ccc<quote>"
			MOVW	#")", 2,-Y 		;"-delimiter -> PS
			JOB	CF_DOT_QUOTE_1
	
;Word: ."
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote). Append the run-time semantics given
;below to the current definition.
IF_DOT_QUOTE		IMMEDIATE
CF_DOT_QUOTE		EQU	*
			;Parse "ccc<quote>"
			MOVW	#$22, 2,-Y 		;"-delimiter -> PS
CF_DOT_QUOTE_1		JOBSR	CF_PARSE		;parse "ccc<quote>"
			LDD	0,Y			;check u
			BEQ	CF_DOT_QUOTE_2		;empty string
			;Check state ( c-addr u )
			LDD	STATE 			;STATE -> D
			BNE	CF_DOT_QUOTE_3		;compilation semantics
			;Interpretation semantics ( c-addr u )
			JOB	CF_STRING_DOT		;print message
			;Empty string ( c-addr u )
CF_DOT_QUOTE_2		LEAY	4,Y 			;clean up stack
			RTS				
			;Compilation semantics ( c-addr u )
CF_DOT_QUOTE_3		PULX				;return addr -> X
			PULD				;compile info -> D
			PSHX				;return addr -> 2,SP
			PSHD				;compile info -> 0,SP
			MOVW	#CF_DOT_QUOTE_RT, 2,-Y 	;runtime semantics -> PS
			JOBSR	CF_COMPILE_COMMA_1	;compile word
			JOBSR	CF_STRING_COMMA_1	;compile string
			PULD				;compile info -> D
			;CLRB				;no optimization
			PULX				;return addr -> X
			PSHD				;compile info -> 0,SP
			JMP	0,X			;done
;Run-time: ( -- )
;Display ccc.
IF_DOT_QUOTE_RT		REGULAR
CF_DOT_QUOTE_RT		EQU	*
			;Print string 
			PULX				;string pointer -> X
			JOBSR	FUDICT_TX_STRING	;print string
			JMP	0,X			;continue after string

;Word: IF 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- orig )
;Put the location of a new unresolved forward reference orig onto the control
;flow stack. Append the run-time semantics given below to the current
;definition. The semantics are incomplete until orig is resolved, e.g., by THEN
;or ELSE.
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by the
;resolution of orig.
IF_IF			IMMEDIATE
CF_IF			COMPILE_ONLY
			;Allocate 6 bytes of compile space 
			LDX	CP 			;CP -> X
			LEAX	6,X			;alloate space
			STX	CP			;update CP
			;Compile inline code (CP in X) 
			MOVW	#$EC71, -6,X 		;"LDD 2,Y+"
			;MOVW	#$1827, -4,X		;"LBEQ"
			;MOVW	#$0000, -2,X		;"qq rr"
			LEAX	-4,X 			;orig -> X
			;Put orig onto the control flow stack 
			;                              +--------+--------+              
			;                              |  Return Address | ...     
			;                              +--------+--------+	       
			;                              |  New Comp. Info | SP+0     
			; +--------+--------+	   ==> +--------+--------+	       
			; |  Return Address | SP+0     |      orig       | SP+2     
			; +--------+--------+	       +--------+--------+	       
			; | Old Comp. Info  | SP+2     | Old Comp. Info  | SP+4     
			; +--------+--------+          +--------+--------+           
			PULD				;return address -> D
			PSHX				;orig           -> 2,SP
			TFR	D, X			;return address -> X
			LDAA	2,SP			;inherit high byte of compile info
			LDAB	#FUDICT_CI_IF		;set control flow
			PSHD				;new compilation info -> 0,SP
			JMP	0,X			;done

;Word: ELSE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig1 -- orig2 )
;Put the location of a new unresolved forward reference orig2 onto the control
;flow stack. Append the run-time semantics given below to the current
;definition. The semantics will be incomplete until orig2 is resolved
;(e.g., by THEN). Resolve the forward reference orig1 using the location
;following the appended run-time semantics.
;Run-time: ( -- )
;Continue execution at the location given by the resolution of orig2.
IF_ELSE			IMMEDIATE
CF_ELSE			COMPILE_ONLY
			;Check compile info 
			LDAB	3,SP 			;compile info -> B
			CMPB	#FUDICT_CI_IF		;check for matching "IF"
			BNE	CF_ELSE_4		;control structure mismatch
			;Update compile info 
			; +--------+--------+              
			; |  Return Address | SP+0    
			; +--------+--------+	       
			; |  New Comp. Info | SP+2     
			; +--------+--------+	       
			; |   orig1/orig2   | SP+4     
			; +--------+--------+	       
			MOVB	#FUDICT_CI_ELSE, 3,SP 	;update compile info
			LDD	4,SP			;orig1 -> D
			LDX	CP			;orig2 -> X
			STX	4,SP			;set orig2
			;Allocate compile space (orig1 in D, CP in X) 
			LEAX	3,X			;alloate space
			STX	CP			;update CP
			;Calculate branch distance (orig1 in D, CP in X)
CF_ELSE_1		COMA				;invert D
			COMB				;-orig1-1 -> D
			LEAX	D,X			;CP-orig1-1 -> X
			DEX				;qq rr -> X
			COMA				;invert D
			COMB				;orig1 -> D
			EXG	X, D			;X <-> D
			;Compile IF forward reference (orig1 in X, qq rr in D)
			TBEQ	A, CF_ELSE_2 		;compile BEQ
			;Compile LBEQ (orig1 in X, qq rr in D)		
			MOVW	#$1827, 2,X+		;compile "LBEQ"
			STD	0,X			;compile "qq rr"
			JOB	CF_ELSE_3 		;set compile info
			;Compile BEQ (orig1 in X, qq rr in D)
CF_ELSE_2		MOVB	#$27, 1,X+		;compile "BEQ"
			STAB	1,X+			;compile "rr"
			MOVW	#$A7A7, 0,X		;compile "NOP NOP"
CF_ELSE_3		RTS				;done
			;Control structure misatch
CF_ELSE_4		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
	
;Word: THEN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig -- )
;Append the run-time semantics given below to the current definition. Resolve
;the forward reference orig using the location of the appended run-time
;semantics.
;Run-time: ( -- )
;Continue execution.
IF_THEN			IMMEDIATE
CF_THEN			COMPILE_ONLY
			;Check compile info 
			LDAB	3,SP 			;compile info -> B
			CMPB	#FUDICT_CI_ELSE		;check for matching "ELSE"
			BEQ	CF_THEN_1		;conclude "ELSE"
			CMPB	#FUDICT_CI_IF		;check for matching "IF"
			BNE	CF_THEN_2		;conrol structure mismatch
			;Conclude "IF"
			; +--------+--------+                                           
			; |  Return Address | SP+0                                  
			; +--------+--------+	                                    
			; |  New Comp. Info | SP+2                                  
			; +--------+--------+	   ==>  +--------+--------+	         
			; |      orig       | SP+4      |  Return Address | SP+0    
			; +--------+--------+	        +--------+--------+	         
			; | Old Comp. Info  | SP+6      | Old Comp. Info  | SP+2    
			; +--------+--------+           +--------+--------+          
			LDAA	2,SP	 		;maintain high byte of compile info
			LDAB	#FUDICT_CI_NONE		;no optimization
			STD	6,SP			;update compilation info
			MOVB	2,SP, 6,SP 		;maintain high byte of compile info
			MOVB	#FUDICT_CI_NONE, 7,SP	;no optimization
			LDD	4,SP			;orig -> D
			MOVW	0,SP, 4,+SP		;move return address
			LDX	CP			;CP -> X
			JOB	CF_ELSE_1		;conclude "IF"
			;Conclude "ELSE"
CF_THEN_1		LDAA	2,SP	 		;maintain high byte of compile info
			ORAA	#FUDICT_CI_NOINL	;forbid INLINE compiling
			LDAB	#FUDICT_CI_NONE		;no optimization
			STD	6,SP			;update compilation info
			LDX	4,SP			;orig -> X
			MOVW	0,SP, 4,+SP		;move return address
			LDD	CP			;CP -> D
			SUBD	FUDICT_OFFSET		;CP-offset -> D
			MOVB	#$06, 1,X+		;compile "JMP"
			STD	0,X			;compile "hh ll"
			RTS				;done
			;Control structure misatch
CF_THEN_2		EQU	CF_ELSE_4
	
;Word: CASE
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- case-sys )
;Mark the start of the CASE ... OF ... ENDOF ... ENDCASE structure. Append the
;run-time semantics given below to the current definition.
;Run-time: ( -- )
;Continue execution.
IF_CASE			IMMEDIATE
CF_CASE			COMPILE_ONLY

;CF_CASE			COMPILE_ONLY			;ensure that compile mode is on
;				PS_CHECK_OF	1		;(PSP-2 -> Y)
;				;Push initial case-sys ($0000) onto the PS
;				MOVW	#$0000, 0,Y
;				STY	PSP
;				NEXT

;Word: OF
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- of-sys )
;Put of-sys onto the control flow stack. Append the run-time semantics given
;below to the current definition. The semantics are incomplete until resolved by
;a consumer of of-sys such as ENDOF.
;Run-time: ( x1 x2 --   | x1 )
;If the two values on the stack are not equal, discard the top value and
;continue execution at the location specified by the consumer of of-sys, e.g.,
;following the next ENDOF. Otherwise, discard both values and continue execution
;in line.
IF_OF			IMMEDIATE
CF_OF			COMPILE_ONLY

;CF_OF				EQU	CF_IF		
;
;OF run-time semantics
;CF_OF_RT			PS_CHECK_UF	2		;check for underflow (PSP -> Y)
;				;Check stacked values 
;				LDD	2,Y+
;				CPD	0,Y
;				BEQ	CF_OF_RT_1 		;values are equal
;				;Values are not equal
;				STY	PSP 			;update PSP
;				JUMP_NEXT			;go to the next ckeck
;				;Values are equal
;CF_OF_RT_1			LEAY	2,Y			;update PSP
;				STY	PSP
;				SKIP_NEXT 			;execute conditional code


;Word: ENDOF
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys1 of-sys -- case-sys2 )
;Mark the end of the OF ... ENDOF part of the CASE structure. The next location
;for a transfer of control resolves the reference given by of-sys. Append the
;run-time semantics given below to the current definition. Replace case-sys1
;with case-sys2 on the control-flow stack, to be resolved by ENDCASE.
;Run-time: ( -- )
;Continue execution at the location specified by the consumer of case-sys2.
IF_ENDOF		IMMEDIATE
CF_ENDOF		COMPILE_ONLY

;				;ENDOF compile semantics (run-time CFA in [X+2])
;CF_ENDOF			COMPILE_ONLY				;ensure that compile mode is on
;				PS_CHECK_UF	2			;(PSP -> Y)
;				LDD	2,X	
;				DICT_CHECK_OF	4			;(CP+4 -> X)
;				;Add run-time CFA to compilation (CP+4 in X, PSP in Y, run-time CFA in D)
;				STD	-4,X
;				MOVW	2,Y, 2,-X 	;temporarily put case-sys1 in CFA address
;				STX	2,Y		;replace case-sys1 by pointer to CFA address
;				LEAX	2,X			
;				STX	CP
;				;Append current CP to last OF
;				LDX	2,Y+
;				MOVW	CP, 0,X
;				STY	PSP
;				;Done
;				NEXT


;Word: ENDCASE
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys -- )
;Mark the end of the CASE ... OF ... ENDOF ... ENDCASE structure. Use case-sys
;to resolve the entire structure. Append the run-time semantics given below to
;the current definition.
;Run-time: ( x -- )
;Discard the case selector x and continue execution.
IF_ENDCASE		IMMEDIATE
CF_ENDCASE		COMPILE_ONLY

;				;ENDCASE compile semantics (run-time CFA in [X+2])
;CF_ENDCASE			COMPILE_ONLY				;ensure that compile mode is on
;				PS_CHECK_UF	1			;(PSP -> Y)
;				LDD	2,X	
;				DICT_CHECK_OF	2			;(CP+2 -> X)
;				;Add run-time CFA to compilation (CP+2 in X, PSP in Y, run-time CFA in D)
;				STD	-2,X
;				STX	CP
;				;Read case-sys (PSP in Y)
;				LDX	2,Y+ 				;get case-sys
;				STY	PSP				;update PSP
;				TBEQ	X, CF_ENDCASE_2			;done
;				;Loop through all ENDOFs 
;CF_ENDCASE_1			LDY	0,X 				;get pointer to next ENDOF
;				MOVW	CP, 0,X				;append the correct address
;				TFR	Y, X
;				TBNE	X, CF_ENDCASE_1	
;				;Done 
;CF_ENDCASE_2			NEXT
;				
;CFA_ENDCASE_RT			EQU	CFA_DROP


;Word: ?DO
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- do-sys )
;Put do-sys onto the control-flow stack. Append the run-time semantics given
;below to the current definition. The semantics are incomplete until resolved by
;a consumer of do-sys such as LOOP.
;Run-time: ( n1|u1 n2|u2 -- ) ( R: --  | loop-sys )
;If n1|u1 is equal to n2|u2, continue execution at the location given by the
;consumer of do-sys. Otherwise set up loop control parameters with index n2|u2
;and limit n1|u1 and continue executing immediately following ?DO. Anything
;already on the return stack becomes unavailable until the loop control
;parameters are discarded. An ambiguous condition exists if n1|u1 and n2|u2 are
;not both of the same type.
IF_QUESTION_DO		IMMEDIATE
CF_QUESTION_DO		COMPILE_ONLY
	
;				;?DO compile semantics (run-time CFA in [X+2])
;CF_QUESTION_DO			COMPILE_ONLY					;ensure that compile mode is on
;				PS_CHECK_OF	2				;(PSP-4 -> Y)
;				LDD		2,X	
;				DICT_CHECK_OF	4				;(CP+4 -> X)
;				;Add run-time CFA to compilation (CP+4 in X, PSP-4 in Y)
;				STD	-4,X
;				MOVW	#$0000, 2,-X
;				;Stack do-sys onto PS (CP+2 in X, PSP-4 in Y)
;				STX	0,Y
;				LEAX	2,X
;				STX	2,Y
;				STY	PSP
;				STX	CP
;				;Done
;				NEXT
;
;;?DO run-time semantics
;CF_QUESTION_DO_RT		PS_CHECK_UF	2		;(PSP -> Y)
;				RS_CHECK_OF	2		;
;				;Compare args on PS
;				LDD	2,Y+
;				CPD	2,Y+
;				BEQ	CF_QUESTION_DO_RT_1
;				;Move loop-sys from PS to RS
;				STY	PSP
;				LDX	RSP	
;				MOVW	-4,Y, 4,-X 		;copy index
;				MOVW	-2,Y, 2,X 		;copy limit
;				STX	RSP
;				SKIP_NEXT
;				;Done
;CF_QUESTION_DO_RT_1		STY	PSP
;				JUMP_NEXT


;Word: DO
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- do-sys )
;Place do-sys onto the control-flow stack. Append the run-time semantics given
;below to the current definition. The semantics are incomplete until resolved
;by a consumer of do-sys such as LOOP.
;;Run-time: ( n1|u1 n2|u2 -- ) ( R: -- loop-sys )
;Set up loop control parameters with index n2|u2 and limit n1|u1. An ambiguous
;condition exists if n1|u1 and n2|u2 are not both the same type. Anything
;already on the return stack becomes unavailable until the loop-control
;parameters are discarded.
IF_DO			IMMEDIATE
CF_DO			COMPILE_ONLY


;CF_DO				COMPILE_ONLY	CF_DO_COMPONLY 	;ensure that compile mode is on
;				PS_CHECK_OF	2		;(PSP-4 -> Y)
;				LDD		2,X	
;				DICT_CHECK_OF	2, CF_DO_DICTOF	;(CP+2 -> X)
;				;Add run-time CFA to compilation (CP+2 in X, PSP-4 in Y)
;				STD	-2,X
;				;Stack do-sys onto PS (CP+2 in X, PSP-4 in Y)
;				STX	2,Y
;				MOVW	#$0000, 0,Y
;				STY	PSP
;				STX	CP
;				;Done
;				NEXT
;
;CF_DO_DICTOF			JOB	FCORE_THROW_DICTOF
;CF_DO_COMPONLY			JOB	FCORE_THROW_COMPONLY	
;				
;DO run-time semantics		
;CF_DO_RT			PS_CHECK_UF	2		;(PSP -> Y)
;				RS_CHECK_OF	2		;
;				;Move loop-sys from PS to RS
;				LDX	RSP	
;				MOVW	2,Y+, 4,-X 		;copy index
;				MOVW	2,Y+, 2,X 		;copy limit
;				STX	RSP
;				STY	PSP
;				;Done
;				NEXT

;Word: +LOOP
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: do-sys -- )
;Append the run-time semantics given below to the current definition. Resolve
;the destination of all unresolved occurrences of LEAVE between the location
;given by do-sys and the next location for a transfer of control, to execute the
;words following +LOOP.
;Run-time: ( n -- ) ( R: loop-sys1 -- | loop-sys2 )
;An ambiguous condition exists if the loop control parameters are unavailable.
;Add n to the loop index. If the loop index did not cross the boundary between
;the loop limit minus one and the loop limit, continue execution at the beginning
;of the loop. Otherwise, discard the current loop control parameters and continue
;execution immediately following the loop.
IF_PLUS_LOOP		IMMEDIATE
CF_PLUS_LOOP		COMPILE_ONLY

;CF_PLUS_LOOP			EQU	CF_LOOP
;
;LOOP run-time semantics
;CF_PLUS_LOOP_RT		PS_CHECK_UF	1	;(PSP -> Y)
;				RS_CHECK_UF	2	;(RSP -> X)
;				;Increment and check index (RSP in X, PSP in Y)
;				LDD	0,X
;				ADDD	2,Y-
;				STY	PSP
;				CPD	2,X
;				BEQ	CF_LOOP_RT_1
;				;Limit not reached (RSP in X)
;				STD	0,X
;				JUMP_NEXT
;				;Limit reached (RSP in X)
;CF_PLUS_LOOP_RT_1		LEAX	4,X
;				STX	RSP
;				SKIP_NEXT

;Word: LOOP
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: do-sys -- )
;Append the run-time semantics given below to the current definition. Resolve
;the destination of all unresolved occurrences of LEAVE between the location
;given by do-sys and the next location for a transfer of control, to execute the
;words following the LOOP.
;Run-time: ( -- ) ( R:  loop-sys1 --  | loop-sys2 )
;An ambiguous condition exists if the loop control parameters are unavailable.
;Add one to the loop index. If the loop index is then equal to the loop limit,
;discard the loop parameters and continue execution immediately following the
;loop. Otherwise continue execution at the beginning of the loop.
IF_LOOP			IMMEDIATE
CF_LOOP			COMPILE_ONLY

;				ALIGN	1
;NFA_LOOP			FHEADER, "LOOP", NFA_LITERAL, IMMEDIATE
;CFA_LOOP			DW	CF_LOOP
;				DW	CFA_LOOP_RT
;				;LEAVE compile semantics (run-time CFA in [X+2])
;CF_LOOP				COMPILE_ONLY	CF_LOOP_COMPONLY 	;ensure that compile mode is on
;				PS_CHECK_UF	2, CF_LOOP_PSUF	;(PSP -> Y)
;				LDD		2,X	
;				DICT_CHECK_OF	4, CF_LOOP_DICTOF	;(CP+4 -> X)
;				;Add run-time CFA to compilation (CP+4 in X, PSP in Y)
;				STD	-4,X
;				MOVW	2,Y, -2,X
;				STX	CP
;				;Read do-sys (PSP+4 in Y)
;				LDX	4,Y+ 				;get case-sys
;				STY	PSP				;update PSP
;				TBEQ	X, CF_LOOP_2			;done
;				;Loop through all LEAVESs 
;CF_LOOP_1			LDY	0,X 				;get pointer to next LEAVE or DO
;				MOVW	CP, 0,X				;append the correct address
;				TFR	Y, X
;				TBNE	X, CF_LOOP_1	
;				;Done 
;CF_LOOP_2			NEXT
;
;LOOP run-time semantics
;CFA_LOOP_RT			DW	CF_LOOP_RT
;CF_LOOP_RT			RS_CHECK_UF	2, CF_LOOP_RSUF	;(RSP -> X)
;				;Increment and check index (RSP in X)
;				LDD	0,X
;				ADDD	#1
;				CPD	2,X
;				BEQ	CF_LOOP_RT_1
;				;Limit not reached (RSP in X)
;				STD	0,X
;				JUMP_NEXT
;				;Limit reached (RSP in X)
;CF_LOOP_RT_1			LEAX	4,X
;				STX	RSP
;				SKIP_NEXT

;Word: BEGIN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- dest )
;Put the next location for a transfer of control, dest, onto the control flow
;stack. Append the run-time semantics given below to the current definition.
;Run-time: ( -- )
;Continue execution.
IF_BEGIN		IMMEDIATE
CF_BEGIN		COMPILE_ONLY

;NFA_BEGIN			FHEADER, "BEGIN", NFA_BASE, IMMEDIATE
;CFA_BEGIN			DW	CF_BEGIN
;CF_BEGIN			COMPILE_ONLY	CF_BEGIN_COMPONLY 	;ensure that compile mode is on
;				PS_CHECK_OF	1			;overflow check	=> 9 cycles
;				MOVW	CP, 0,Y
;				STY	PSP
;				NEXT
	
;Word: UNTIL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by
;dest.
IF_UNTIL		IMMEDIATE
CF_UNTIL		COMPILE_ONLY

;CF_UNTIL			EQU	CF_LITERAL
;	
;;UNTIL run-time semantics 
;CF_UNTIL_RT			PS_PULL_X
;				CPX	#$0000		;check is cell equals 0
;				BEQ	CF_UNTIL_RT_1	;cell is zero 
;				SKIP_NEXT		;increment IP and do NEXT
;CF_UNTIL_RT_1			JUMP_NEXT

;Word: AGAIN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( -- )
;Continue execution at the location specified by dest. If no other control flow
;words are used, any program code after AGAIN will not be executed.
IF_AGAIN		IMMEDIATE
CF_AGAIN		COMPILE_ONLY

;CF_AGAIN			EQU	CF_LITERAL
;	
;;AGAIN run-time semantics
;CF_AGAIN_RT			JUMP_NEXT

;Word: WHILE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- orig dest )
;Put the location of a new unresolved forward reference orig onto the control
;flow stack, under the existing dest. Append the run-time semantics given below
;to the current definition. The semantics are incomplete until orig and dest are
;resolved (e.g., by REPEAT).
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by the
;resolution of orig.
IF_WHILE		IMMEDIATE
CF_WHILE		COMPILE_ONLY

;CF_WHILE			COMPILE_ONLY				;ensure that compile mode is on
;				PS_CHECK_UFOF	1, 1			;check for under and overflow (PSP-2 -> Y)	
;				LDD	2,X	
;				DICT_CHECK_OF	4			;(CP+4-> X)
;				;Add run-time CFA to compilation (CP+4 in X, PSP-2 in Y)
;				STD	 -4,X
;				STX	-2,X
;				STX	CP
;				;Move dest to TOS
;				MOVW	2,Y, 0,Y
;				LEAX	-2,X
;				STX	2,Y
;				STY	PSP
;				;Done
;				NEXT

;Word: REPEAT 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest. Resolve the forward reference orig using the
;location following the appended run-time semantics.
;Run-time: ( -- )
;Continue execution at the location given by dest.
IF_REPEAT		IMMEDIATE
CF_REPEAT		COMPILE_ONLY

;CF_REPEAT		;REPEAT compile semantics (run-time CFA in [X+2])
;			COMPILE_ONLY				;ensure that compile mode is on
;			PS_CHECK_UF	1			;(PSP -> Y)
;			LDD	2,X	
;			DICT_CHECK_OF	4			;(CP+4-> X)
;			;Add run-time CFA to compilation (CP+4 in X, PSP in Y)
;			STD	-4,X
;			MOVW	2,Y+, -2,X
;			STX	CP
;			;Add address to CFA_WHILE_RT
;			LDX	2,Y+
;			STY	PSP
;			MOVW	CP, 0,X
;			;Done 
;			NEXT

	
FUDICT_CODE_END		EQU	*
FUDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FUDICT_TABS_START_LIN
			ORG 	FUDICT_TABS_START, FUDICT_TABS_START_LIN
#else
			ORG 	FUDICT_TABS_START
FUDICT_TABS_START_LIN	EQU	@
#endif	

;#New line string
FUDICT_STR_NL		EQU	STRING_STR_NL

FUDICT_TABS_END		EQU	*
FUDICT_TABS_END_LIN	EQU	@
