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
;#    This module implements the volatile user dictionary, user variables, and #
;#    the PAD.                                                                 #
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
	
;#Compile optimizations
FUDICT_OPT_NONE		EQU	$0000
FUDICT_OPT_BSR		EQU	$0001
FUDICT_OPT_JSR		EQU	$0002
	
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
			; |       EOS       | SP+0
			; +--------+--------+
			; |    Iterator     | SP+2
			; +--------+--------+
;			;Check compile strategy
;			BRCLR	STRATEGY,#$80, CF_LU_UDICT_
;			;Initialize interator structure 
;			MOVW	#FUDICT_LAST_NFA, 2,-SP ;last NFA -> iterator
;			LDD	2,Y			;c-addr -> D
;			ADDD	0,Y			;EOS    -> D
;			STD	2,-SP			;store EOS
;			;Check name 
;			LDD	2,SP 			;NFA    -> D
;			ADDD	#2			;SOS    -> D
;			SUBD	2,Y			;offset -> D
			

	
	
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
			BEQ	CF_WORDS_UDICT_2	;empty dictionary
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
			SUBD	0,SP			;calculate name length
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
;           |      Optimization Info      | +0	     
;      	    +--------------+--------------+	     
;           |  Information Field Address  | +2	     
;      	    +--------------+--------------+	     
;           |      Name Field Address     | +4	     
;      	    +--------------+--------------+	     
;
IF_COLON		IMMEDIATE			
CF_COLON		INTERPRET_ONLY			;catch nested compilation
			;Parse name 
CF_COLON_1		LDD	#" " 			;set delimeter
			JOBSR	CF_SKIP_AND_PARSE	;parse name
			LDD	0,Y			;check name
			BNE	CF_COLON_2		;name found
			THROW	FEXCPT_TC_NONAME	;throw "missing name" exception
			;Set STATE ( c-addr u )
			LDD	STRATEGY 		;STRATEGY -> D
			BEQ	CF_COLON_1		;done
			STD	STATE			;STRATEGY -> STATE
			;Push colon-sys ( c-addr u )
			MOVW	0,SP,  6,-SP 		;move return address
			MOVW	#FUDICT_OPT_NONE, 2,SP	;optimization info -> colon-sys
			LDX	CP			;CP -> X
			STX	6,SP		  	;NFA -> colon_sys
			;Allocate compile space ( c-addr u ) (CP in X)
			TFR	X, D			;CP -> D
			ADDD	0,Y			;CP+name -> D
			ADDD	#$0003			;CP+nane+NFA+IF -> D
			STD	CP			;update CP
			SUBD	#1			;IFA -> D
			STD	4,SP			;IFA -> colon-sys
			;Compile last NFA ( c-addr u ) (compile pointer in X)
			MOVW	FUDICT_LAST_NFA, 2,X+ 	;compile last NFA
			;Compile name ( c-addr u ) (compile pointer in X)
			MOVW	2,Y, 2,-Y 		;( c-addr u   c-addr )
			STX	2,-Y			;( c-addr u   c-addr SOS )
			MOVW	4,Y, 2,-Y 		;( c-addr u   c-addr SOS u )
			TFR	X, D			;X -> D
			ADDD	8,Y			;EOS -> D
			STD	8,Y			;(    EOS u   c-addr SOS u )
			STX	6,Y			;(    EOS SOS c-addr SOS u )
			JOBSR	CF_MOVE			;copy name ( EOS SOS )
			LDX	2,Y+			;SOS -> X ( EOS)
CF_COLON_2		LDAB	0,X			;char -> B
			JOBSR	FUDICT_UPPER		;make upper case
			STAB	1,X+			;update char
			CPX	0,SP			;check for EOS
			BLO	CF_COLON_2		;LOOP
			BSET	-1,X,#FUDICT_TERM	;terminate name string
			;Compile IF (compile pointer in X)
			CLR	0,X 			;REGULAR
			RTS				;done

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
			BNE	CF_COMPILE_COMMA_4	;not REGULAR
			;REGULAR word ( xt ) 
CF_COMPILE_COMMA_2	LDX	CP 			;CP   -> X		
			TFR	X,D 			;CP   -> D
			SUBD	FUDICT_OFFSET		;CP-offs -> D
			SUBD	0,Y			;CP-offs-xt -> D
			BCC	CF_COMPILE_COMMA_3	;compile BSR
			CPD	#128			
			BLS	CF_COMPILE_COMMA_3	;compile BSR
			;Compile JSR ( xt ) (CP in X)
			LEAX	3,X 			;allocate compile space
			STX	CP			;update CP
			MOVB	#$16, -3,X		;compile "JSR" opcode
			MOVW	2,Y+, -2,X		;compile xt
			MOVB	#FUDICT_OPT_JSR, 3,SP	;set optimization info
			RTS				;done
			;Compile BSR ( xt ) (CP in X, negated rel. addr in B)
CF_COMPILE_COMMA_3	LEAX	2,X 			;allocate compile space
			STX	CP			;update CP
			MOVB	#$07, -2,X		;compile "BSR" opcode
			NEGB				;rel. addr -> B
			STAB	-1,X			;compile rel. addr
			MOVB	#FUDICT_OPT_BSR, 3,SP	;set optimization info
			RTS				;done
			;Word not REGULAR ( xt ) (xt in X, IF in B)
CF_COMPILE_COMMA_4	CMPB	#IMMEDIATE 		;check for IMMEDIATE word
			BEQ	CF_COMPILE_COMMA_2	;compile as REGULAR word
			LDX	CP			;CP -> X
			STX	2,-Y			;( xt CP )
			CLRA				;u  -> D
			STD	2,-Y			;( xt CP u )
			LEAX	B,X			;allocate compile space
			STX	CP			;update CP
			JOBSR	CF_MOVE			;copy INLINE code
			CLR	3,SP			;set optimization info
			RTS				;done

	
;Word ; 
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
			LDX	CP 			;CP -> X
			LDAB	3,SP 			;colon-sys(opt. info)
			BNE	CF_SEMICOLON_4		;check for optimization
			;Consider INLINE optimization (CP in X) 
CF_SEMICOLON_1		TFR	X, D 			;CP           -> D
			SUBD	4,Y			;CF length +1 -> D
			BCS	CF_SEMICOLON_2		;no INLINE optimization
			CPD	#(FUDICT_MAX_INLINE+1)	;chech CF length
			BHI	CF_SEMICOLON_2		;no INLINE optimization
			STAB	[4,Y]			;set IF to INLINE
			;No optimized word ending (CP in X)
CF_SEMICOLON_2		INX				;increment CP
			STX	CP			;updated CP
			MOVB	#$3D, -1,X		;compile "RTS"
CF_SEMICOLON_3		STX	CP_SAVE 		;secure compiled space
			;Embed word into dictionary 
			MOVW	6,SP, FUDICT_LAST_NFA 	;link word
			JMP	8,SP+			;done
			;Check for optimization (opt. info in B, CP in X)
CF_SEMICOLON_4		DBEQ	B, CF_SEMICOLON_5 	;BSR optimization
			DBNE	B, CF_SEMICOLON_1	;no optimization
			;JSR optimization (CP in X)
			LDAA	#$16			;check for JSR ext
			CMPA	-3,X			;compare opcode
			BNE	CF_SEMICOLON_1		;no optimization
			MOVB	#$06, -3,X		;replace JSR by JMP
			JOB	CF_SEMICOLON_3		;finish up
			;BSR optimization 	
CF_SEMICOLON_5		LDAA	#$07			;check for BSR ext
			CMPA	-2,X			;compare opcode
			BNE	CF_SEMICOLON_1		;no optimization
			MOVB	#$20, -2,X		;replace BSR by BRA
			JOB	CF_SEMICOLON_3		;finish up
	
;Word: CONSTANT ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a constant.
;name Execution: ( -- x )
;Place x on the stack.
IF_CONSTANT		REGULAR
CF_CONSTANT		EQU	*
			;Compile header 
			JOBSR	CF_COLON 		;use standard ":" 
			;Compile body 
			JOBSR	CF_LITERAL_1 		;LITERAL
			;Conclude compilation		
			JOB	CF_SEMICOLON_1 		;";"

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
			LEAX	5,SP			;allocate 5 bytes
			STX	CP			;update CP
			;Compile execution semantics 
			MOVW	#$1800, -5,X		;"MOVW $xxxx, 2,-SP"
			MOVB	#$6E,   -3,X		; => 18006Exxxx
			MOVW	2,Y+,   -2,X		;compile top of PS
			;Set optimizer information 
			CLR	3,SP			;no optimization
			RTS				;done

;Word: 2LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x1 x2 -- )
;Append the run-time semantics below to the current definition.
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
IF_2LITERAL		IMMEDIATE
CF_2LITERAL		EQU	*	
			JOBSR	CF_SWAP			;(x1 x2 -- x2 x1)
			JOBSR	CF_LITERAL		;compile x1
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
			LDX	2,Y 			;string -> X				;
CF_STRING_COMMA_2	MOVB	0,X, D,X		;copy char
			BCLR	D,X,FUDICT_TERM		;remove termination
			INX				;advance 
			CPX	0,Y			;check for EOS
			BNE	CF_STRING_COMMA_2	;loop
			DEX				;go back to last char
			BSET	D,X,FUDICT_TERM		;terminate string
	
;;Word: CELL, 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Execution: ( x -- )
;;Append cell value x the to the current definition.
;IF_CELL_COMMA		IMMEDIATE
;CF_CELL_COMMA		COMPILE_ONLY
;			;Pull argument from PS 
;CF_CELL_COMMA_1		LDD	2,Y+ 			;x -> D
;			;Allocate compile space (x ion D)
;CF_CELL_COMMA_2		LDX	CP 			;CP -> X
;			LEAX	2,X			;allocate 5 bytes
;			STX	CP			;update CP
;			;Compile execution semntics (x in D)
;			STD	 -2,X			;compile top of PS
;			MOVB	#FUDICT_CTYPE_NONE, FUDICT_LAST_CTYPE;set optimizer info
;			RTS
;
;;Word: CHAR, 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Execution: ( char -- )
;;Append the char value to the current definition.
;IF_CHAR_COMMA		IMMEDIATE
;CF_CHAR_COMMA		COMPILE_ONLY
;			;Pull argument from PS 
;CF_CHAR_COMMA_1		LDD	2,Y+ 			;x -> D
;			;Allocate compile space (x ion D)
;CF_CHAR_COMMA_2		LDX	CP 			;CP -> X
;			INX				;allocate 5 bytes
;			STX	CP			;update CP
;			;Compile execution semntics (x in D)
;			STAB	 -1,X			;compile top of PS
;			MOVB	#FUDICT_CTYPE_NONE, FUDICT_LAST_CTYPE;set optimizer info
;			RTS

;;Word: NVCBUF, 
;;Interpretation: throws "compilation only" error
;;Execution: ( xt n -- )
;;Append the execution semanticsFUDICT_OFFSET of xt to the current definition.
;;xt is the target address of a word in the non-volatile compile buffer.
;IF_XT_COMMA		IMMEDIATE
;CF_XT_COMMA		COMPILE_ONLY
;			;Check IF ( xt n ) 
;CF_XT_COMMA_1		LDD	0,Y			;tgt xt -> D
;			ADDD	FUDICT_OFFSET		;src xt -> D
;			TFR	D, X			;src xt -> X
;CF_XT_COMMA_2		BRCLR	-1,X,#$FF,CF_XT_COMMA_4	;regular word
;			BRSET	-1,X,#$FF,CF_XT_COMMA_4	;immediate word
;			;Inline word (src. xt in X and D) 
;			SUBD	CP 			;copy offset -> D
;			MOVB	-1,X, 1,-SP		;copy count  -> RS
;			LDX	CP			;CP          -> D
;CF_XT_COMMA_3		MOVB	D,X, 1,X+		;copy byte
;			DEC	0,SP			;decrement counter
;			BNE	CF_XT_COMMA_3		;loop
;			INS				;clean up RS
;			MOVB	#FUDICT_CTYPE_INLINE, FUDICT_LAST_CTYPE;set optimizer info
;			INY				;clean up PS
;			RTS				;done
;			;Regular compile 
;CF_XT_COMMA_4		LDD	CP 			;src addr -> D
;			ADDD	FUDICT_OFFSET		;tgt addr -> D	
;			SUBD	0,Y			
;	
;
;			CMPA	#$FF	     		;check negative branch range
;			BEQ	CF_XT_COMMA_5		;compile BSR
;			TSTA				;check negative branch range
;			BEQ	CF_XT_COMMA_5		;compile BSR
;			;Compile JSR (phys. xt in X, comp. offset in D) 
;			LDX	CP 			;CP -> X
;			LEAX	3,X			;allocate compile space
;			STY	CP			;update CP
;			MOVB	#$16, -3,X		;JSR-opcode
;			MOVW	0,SP, -2,X		;XT address
;			MOVB	#FUDICT_CTYPE_JSR, FUDICT_LAST_CTYPE;set optimizer info
;			INY				;clean up PS
;			RTS				;done
;			;Compile BSR (phys. xt in X, comp. offset in D) 
;CF_XT_COMMA_5		LDX	CP 			;CP -> X
;			LEAX	2,X			;allocate compile space
;			STY	CP			;update CP
;			MOVB	#$07, -1,X		;JSR-opcode
;			STAB	0,X			;relative XT address
;			MOVB	#FUDICT_CTYPE_BSR, FUDICT_LAST_CTYPE;set optimizer info
;			INY				;clean up PS
;			RTS				;done
	

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
