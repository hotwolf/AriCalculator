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
; Memory layout:
; ==============       
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
;                           |              ^              | <- [PSP=Y]	  
;                           |              |              |		  
;                           |       Parameter stack       |		  
;    	                    |              |              |		  
;                           +--------------+--------------+        
;                           |              ^              | <- [CSP]	  
;                           |     Control-flow stack      |		  
;                           +--------------+--------------+        
;              PS_EMPTY, ->   
;          UDICT_PS_END
;	
;	
; Word format:
; ============       
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
; =========================       
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
;	
; Control structures for compilation:	
; ===================================       
;	
; colon-sys (structures implementation)	
; generated by:	:
; consumed by:	;
;		
;      	+-------------------+-------------------+	     
;       |   compile flags   |FUDICT_CS_COLON_SYS| +0	     
;      	+-------------------+-------------------+	     
;       |             current NFA               | +2	     
;      	+-------------------+-------------------+	     
;       |             current xt                | +4	     
;      	+-------------------+-------------------+	     
;	
; do-sys (do-loop structures)	
; generated by:	DO ?DO
; altered by:   LEAVE
; consumed by:  +LOOP LOOP
;		
;      	+-------------------+-------------------+	     
;       |   compile flags   | FUDICT_CS_DO_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              LOOP address             | +2	     
;      	+-------------------+-------------------+	     
;       |               LEAVE list              | +4	     
;      	+-------------------+-------------------+	     
;	
; case-sys (CASE structures)	
; generated by:	CASE
; checked by:   OF
; altered by:	ENDOF
; consumed by:  ENDCASE
;		
;      	+-------------------+-------------------+	     
;       |   compile flags   |FUDICT_CS_CASE_SYS | +0	     
;      	+-------------------+-------------------+	     
;       |              ENDOF list               | +2	     
;      	+-------------------+-------------------+	     
;	
; of-sys (OF structures)	
; generated by:	OF
; consumed by:  ENDOF
;	
;      	+-------------------+-------------------+	     
;       |   compile flags   | FUDICT_CS_OF_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              OF address               | +2	     
;      	+-------------------+-------------------+	     
;	
;	
; orig (control-flow origins) ->conditional	
; generated by:	IF WHILE
; consumed by:  ELSE REPEAT THEN
;	
;      	+-------------------+-------------------+	     
;       |   compile flags   |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +2	     
;      	+-------------------+-------------------+	     
;		
; orig (control-flow origins) ->unconditional	
; generated by:	AHEAD ELSE
; consumed by:  ELSE REPEAT THEN
;	
;      	+-------------------+-------------------+	     
;       |   compile flags   |   FUDICT_CS_ORIG  | +0	     
;      	+-------------------+-------------------+	     
;       |             AHEAD address             | +2	     
;      	+-------------------+-------------------+	     
;		
; dest (control-flow destinations)	
; generated by:	BEGIN
; checked by:   WHILE
; consumed by:  REPEAT UNTIL AGAIN
;	
;      	+-------------------+-------------------+	     
;       |   compile flags   |   FUDICT_CS_DEST  | +0	     
;      	+-------------------+-------------------+	     
;       |             BEGIN address             | +2	     
;      	+-------------------+-------------------+	     
;	
; Run-time control structures:	
; ============================       
;	
; loop-sys (control-flow destinations)	
; generated by:	DO ?DO
; read by:      I J
; consumed by:  LOOP +LOOP UNLOOP
;	
;      	+-------------------+-------------------+	     
;       |                counter                | +0	     
;      	+-------------------+-------------------+	     
;       |                 limit                 | +2	     
;      	+-------------------+-------------------+	     
;	
; nest-sys (definition calls)	
; generated by:	call of a word
; consumed by:  execution of a word
;	
;      	+-------------------+-------------------+	     
;       |            return address             | +0	     
;      	+-------------------+-------------------+	     
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

;#Control structure codes 
FUDICT_CS_COLON_SYS	EQU	$FF		;control structure "colon-sys"
FUDICT_CS_DO_SYS	EQU	$FE		;control structure "do-sys"
FUDICT_CS_CASE_SYS	EQU	$FD		;control structure "case-sys"
FUDICT_CS_COND_ORIG	EQU	$FC		;control structure "orig" with conditional branch
FUDICT_CS_ORIG		EQU	$FB		;control structure "orig" without conditional branch
FUDICT_CS_DEST		EQU	$FA  		;control structure "dest"

;#Compile flags 
FUDICT_CF_NOINL		EQU	$80 		;no inline
FUDICT_CI_BSR		EQU	$01		;last compile was "BSR"
FUDICT_CI_JSR		EQU	$02		;last compile was "JSR"
FUDICT_CI_COF		EQU	$03 		;clear all COF optimizations

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
			BRCLR	STRATEGY,#$80, CF_LU_UDICT_7
			;Check u ( c-addr u )
			LDD	0,Y			;check if u is zero
			BEQ	CF_LU_UDICT_7 		;empty seaech string (search failed)
			;Initialize interator structure ( c-addr u )
			LDD	FUDICT_LAST_NFA 	;last NFA -> D
CF_LU_UDICT_1		BEQ	CF_LU_UDICT_7 		;empty dictionary (search failed)
			MOVW	#0000, 2,-SP 		;0 -> compile offset
			PSHD				 ;last NFA -> iterator
			;Compare first letter ( c-addr u )
CF_LU_UDICT_2		LDAB	[2,Y] 			;LU char -> B
			JOBSR	FUDICT_UPPER		;make upper case
			LDX	0,SP	 		;UDICT entry -> X
			LDAA	2,+X			;UDICT char -> A, UDICT string -> X
			ANDA	#~FUDICT_TERM		;remove termination
			CBA				;compare chars
			BNE	CF_LU_UDICT_4		;skip to next UDICT entry
			;Compare string lengths ( c-addr u ) (UDICT string -> X) 
			BRCLR	1,X+,#FUDICT_TERM,* 	;skip to end of UDICT string 
			TFR	X, D			;end of UDICT string -> D
			SUBD	0,SP			;subtract UDICT entry offset
			SUBD	#2			;subtract name offsetr
			CPD	0,Y			;compare string lengths
			BNE	CF_LU_UDICT_4		;skip to next UDICT entry
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
CF_LU_UDICT_3		LDX	0,SP			;LU pointer -> X
			LDAB	1,-X			;LU char -> B
			CPX	2,Y			;check LU pointer
			BEQ	CF_LU_UDICT_5		;search successful
			STX	0,SP			;update LU pointer
			LDX	2,SP			;UDICT pointer -> X
			LDAA	1,-X			;UDICT char -> A
			STX	2,SP			;update UDICT pointer
			JOBSR	FUDICT_UPPER		;make LU char upper case
			ANDA	#~FUDICT_TERM		;remove UDICT char termination
			CBA				;compare chars
			BEQ	CF_LU_UDICT_3		;check next char
			LEAS	4,SP			;remove LU and UDICT pointer from RS
			;Skip next entry ( c-addr u )
CF_LU_UDICT_4		LDX	0,SP			;iterator -> X
			LDD	0,X			;previous entry -> D
			BEQ	CF_LU_UDICT_6		;Search failed
			ADDD	2,SP			;add compile offset
			STD	0,SP			;advance iterator
			JOB	CF_LU_UDICT_2		;check next UDICT entry
			;Search successful ( c-addr u )
CF_LU_UDICT_5		LEAS	4,SP	 		;remove LU and UDICT pointer from RS
			LDX	4,SP+	 		;remove iterator from RS
			LEAX	2,X			;skip to start of UDICT string
			BRCLR	1,X+,#FUDICT_TERM,* 	;skip to end of UDICT string 
			INX				;skip over
			STX	2,+Y			;return xy
			RTS
			;Search failed ( c-addr u )
CF_LU_UDICT_6		LEAS	4,SP	 		;clean up RS
CF_LU_UDICT_7		MOVW	#FALSE	2,-Y		;return FALSE flag
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
			BRCLR	STRATEGY,#$80, CF_WORDS_UDICT_4
			;Initialize interator structure 
			LDX	FUDICT_LAST_NFA		;last NFA -> X
CF_WORDS_UDICT_1	BEQ	CF_WORDS_UDICT_4	;empty dictionary
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
CF_WORDS_UDICT_2	LDX	2,SP 			;iterator -> X
			MOVW	2,X+, 2,SP		;advance iterator
			JOBSR	FUDICT_TX_STRING	;print name
			LDX	2,SP 			;iterator -> X
			BEQ	CF_WORDS_UDICT_3	;done
			INX				;NF pointer -> X
			BRCLR	1,+X,#FUDICT_TERM,*	;skip to last char
			DEX				;adjust NF pointer
			TFR	X, D			;NF pointer -> D
			SUBD	2,SP			;calculate name length
			MOVW	#CF_WORDS_UDICT_2, 2,-SP;push return address (CF_WORDS_UDICT_2)
			JOB	FUDICT_LIST_SEP		;print separator
			;Clean up
CF_WORDS_UDICT_3	LEAS	4,SP 			;clean up stack
CF_WORDS_UDICT_4	RTS				;done

;Word :NONAME ( C:  -- colon-sys )  ( S:  -- xt )
;Create an execution token xt, enter compilation state and start the current
;definition, producing colon-sys. Append the initiation semantics given below
;to the current definition.
;The execution semantics of xt will be determined by the words compiled into the
;body of the definition. This definition can be executed later by using
;xt EXECUTE.
;If the control-flow stack is implemented using the data stack, colon-sys shall
;be the topmost item on the data stack.
;
;Initiation: ( i*x -- i*x ) ( R:  -- nest-sys )
;Save implementation-dependent information nest-sys about the calling
;definition. The stack effects i*x represent arguments to xt.
;
;xt Execution: ( i*x -- j*x )
;Execute the definition specified by xt. The stack effects i*x and j*x represent
;arguments to and results from xt, respectively.
;
;colon-sys:
;      	+-------------------+-------------------+	     
;       |   compile flags   |FUDICT_CS_COLON_SYS| +0	     
;      	+-------------------+-------------------+	     
;       |             current NFA               | +2	     
;      	+-------------------+-------------------+	     
;       |             current CFA               | +4	     
;      	+-------------------+-------------------+	     
;	
IF_COLON_NONAME		IMMEDIATE			
CF_COLON_NONAME		INTERPRET_ONLY			;catch nested compilation

			RTS

	
;Word: : ( C: "<spaces>name" -- colon-sys )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name, called a colon definition. Enter compilation state and
;start the current definition, producing colon-sys. Append the initiation
;semantics given below to the current definition.
;The execution semantics of name will be determined by the words compiled into
;the body of the definition. The current definition shall not be findable in the
;dictionary until it is ended (or until the execution of DOES> in some systems).
;
;Initiation: ( i*x -- i*x ) ( R: -- nest-sys )
;Save implementation-dependent information nest-sys about the calling definition.
;The stack effects i*x represent arguments to name.
;
;name Execution: ( i*x -- j*x )
;Execute the definition name. The stack effects i*x and j*x represent arguments
;to and results from name, respectively.
;
;colon-sys:
;      	+-------------------+-------------------+	     
;       |   compile flags   |FUDICT_CS_COLON_SYS| +0	     
;      	+-------------------+-------------------+	     
;       |             current NFA               | +2	     
;      	+-------------------+-------------------+	     
;       |             current CFA               | +4	     
;      	+-------------------+-------------------+	     
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
			BEQ	CF_COLON_ 		;done
			STD	STATE			;STRATEGY -> STATE
			;Save new NFA ( c-addr u )
			LDX	CP 			;CP -> X
			PSHX				;CP -> RS
			;Compile last NFA ( c-addr u ) (R: NFA )(CP in X)
			MOVW	FUDICT_LAST_NFA, 2,X+ 	;compile last NFA
			;Compile name ( c-addr u ) (R: NFA ) (CP in X) 
			STX	CP			;update CP
			JOBSR	CF_NAME_COMMA_1		;compile name
			;Compile IF (R: NFA ) (CP in X) 
CF_COLON_3		CLR	1,+X 			;
			STX	CP			;update CP
			


			;Compile name ( c-addr u ) (CP in X)
			MOVW	0,Y, 2,-Y 		;( c-addr u   u )
			STX	2,Y			;( c-addr CP u )
			PSHX				;save CP
			JOBSR	CF_MOVE			;copy name
			PULX				;restore CP
CF_COLON_3		LDAB	0,X			;char -> B
			JOBSR	FUDICT_UPPER		;make upper case
			STAB	1,X+			;update char
			CPX	0,SP			;check for EOS
			BLO	CF_COLON_3		;LOOP
			BSET	-1,X,#FUDICT_TERM	;terminate name string



	

			;Push colon-sys ( c-addr u )
			LDAA	#6 			;allocate CS space
			JOBSR	FPS_CS_ALLOC		;
			LDX	CSP			;CSP -> X
			MOVW	#FUDICT_CS_COLON_SYS, 0,X;set colon-sys
			LDD	CP			;CP -> D 
			STD	2,X			;store NFA
			ADDD	0,Y			;CP+name -> D
			ADDD	#$0003			;CP+nane+NFA+IF -> D
			STD	4,X			;store CFA
			LDX	CP			;CP -> X
			STD	CP			;allocate compile space
			;Compile last NFA ( c-addr u ) (compile pointer in X)
			MOVW	FUDICT_LAST_NFA, 2,X+ 	;compile last NFA
			;Compile name ( c-addr u ) (CP in X)
			MOVW	0,Y, 2,-Y 		;( c-addr u   u )
			STX	2,Y			;( c-addr CP u )
			PSHX				;save CP
			JOBSR	CF_MOVE			;copy name
			PULX				;restore CP
CF_COLON_3		LDAB	0,X			;char -> B
			JOBSR	FUDICT_UPPER		;make upper case
			STAB	1,X+			;update char
			CPX	0,SP			;check for EOS
			BLO	CF_COLON_3		;LOOP
			BSET	-1,X,#FUDICT_TERM	;terminate name string
			;Compile IF (compile pointer in X)
			CLR	0,X 			;REGULAR
CF_COLON_4		RTS				;done




;Word: NAME, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( c-addr u  -- )
;Append the the string given by start address c-addr and length u 
;uppercase to the current definition.
IF_NAME_COMMA		IMMEDIATE
CF_NAME_COMMA		COMPILE_ONLY
			;Save current CP ( c-addr u )
CF_NAME_COMMA_1		MOVW	CP, 2,-SP 		;CP -> RS
			JOBSR	CF_STRING_COMMA_1	;copy string
			PULX				;old CP -> X
			CPX	CP			;check fir empty string
			BEQ	CF_NAME_COMMA_3		;empty string
CF_NAME_COMMA_2		LDAB	1,X+			;chasr -> B
			JOBSR	FUDICT_UPPER		;msake upper case
			CPX	CP			;check for end of string
			BLO	CF_NAME_COMMA_2		;handle next char
CF_NAME_COMMA_3		RTS				;done

;Word: STRING, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( c-addr u  -- )
;Append the the string given by start address c-addr and length u to the current
;definition.
IF_STRING_COMMA		IMMEDIATE
CF_STRING_COMMA		COMPILE_ONLY
			;Prepare MOVE ( c-addr u )
CF_STRING_COMMA_1		LDD	0,Y 			;u  -> D
			LDX	CP			;CP -> X
			STX	2,-Y			;CP 0> PS+2
			STD	2,-Y			;u  -> PS+0
			LEAX	D,X			;new CP -> X
			STX	CP			;update CP
			;MOVE string ( addr1 addr2 u )
			JOBSR	CF_MOVE 		;copy string
			;Terminate string 
			LDX	CP			;CP -> X
			BSET	-1,X,#FUDICT_TERM	;terminate string
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
			RTS
	
;Word: COMPILE, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( xt -- )
;Append the execution semantics of the definition represented by xt to the
;execution semantics of the current definition.
IF_COMPILE_COMMA	IMMEDIATE
CF_COMPILE_COMMA	COMPILE_ONLY
			;Remove COF COF optimization flags
			LDX	CSP		   	;CSP -> X
			BCLR	0,X,#FUDICT_CI_COF 	;clear compile flags
			;Get xt ( xt )
CF_COMPILE_COMMA_1	LDX	0,Y 			;xt -> X
			LDAB	-1,X			;IF -> B
			BNE	CF_COMPILE_COMMA_4	;not REGULAR
			;REGULAR word ( xt ) 
CF_COMPILE_COMMA_2	LDX	CP 			;CP   -> X		
			TFR	X,D 			;CP   -> D
			SUBD	FUDICT_OFFSET		;CP-offs -> D
			SUBD	0,Y			;CP-offs-xt -> D
			TBEQ	A,CF_COMPILE_COMMA_3	;compile BSR
			;Compile JSR ( xt ) (CP in X)
			LEAX	3,X 			;allocate compile space
			STX	CP			;update CP
			MOVB	#$16, -3,X		;compile "JSR" opcode
			MOVW	2,Y+, -2,X		;compile xt	
			LDX	CSP		  	;CSP -> X
			BSET	0,X,FUDICT_CI_JSR 	;optimize last JSR
			RTS				;done
			;Compile BSR ( xt ) (CP in X, negated rel. addr in B)
CF_COMPILE_COMMA_3	LEAX	2,X 			;allocate compile space
			STX	CP			;update CP
			MOVB	#$07, -2,X		;compile "BSR" opcode
			NEGB				;rel. addr -> B
			STAB	-1,X			;compile rel. addr
			LDX	CSP		  	;CSP -> X
			BSET	0,X,#(FUDICT_CF_NOINL|FUDICT_CI_BSR);optimize last JSR
			RTS				;done
			;Word not REGULAR ( xt ) (xt in X, IF in B)
CF_COMPILE_COMMA_4	CMPB	#IMMEDIATE 		;check for IMMEDIATE word
			BEQ	CF_COMPILE_COMMA_2	;compile as REGULAR word
			LDX	CSP		  	;CSP -> X
			BRSET	0,X,#FUDICT_CF_NOINL,CF_COMPILE_COMMA_2;inline compilation forbidden
			LDX	CP			;CP -> X
			STX	2,-Y			;( xt CP )
			CLRA				;u  -> D
			STD	2,-Y			;( xt CP u )
			LEAX	B,X			;allocate compile space
			STX	CP			;update CP
			JOB	CF_MOVE			;copy INLINE code
	
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
			;Check colon-sys 
			LDX	CSP 			;CSP -> D
			LDD	1,X			;flags:colon-sys -> D
			CMPB	#FUDICT_CS_COLON_SYS	;check for : definition
			BEQ	CF_SEMICOLON_1 		;check for COF optimization
			CMPB	#FUDICT_CS_NNAME_SYS	;check for :NONAME definition
			BNE	CF_SEMICOLON_2 		;control structure mismatch	
			;Check for COF optimization
CF_SEMICOLON_1		LDX	CP
			BITA	#FUDICT_CI_BSR 		;check for BSR optimization
			BEQ	CF_SEMICOLON_3		;optimize last BSR
			BITA	#FUDICT_CI_JSR 		;check for JSR optimization
			BNE	CF_SEMICOLON_4		;no optimization
			;Optimize last JSR (CP in X)
			LDAA	#$16			;check for JSR ext
			CMPA	-3,X			;compare opcode
			BNE	CF_SEMICOLON_4		;no optimization
			MOVB	#$06, -3,X		;replace JSR by JMP
			JOB	CF_SEMICOLON_5		;finish up
			;Control structure misatch
CF_SEMICOLON_2		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
			;Optimize last BSR (CP in X)
CF_SEMICOLON_3		LDAA	#$07			;check for BSR ext
			CMPA	-2,X			;compare opcode
			BNE	CF_SEMICOLON_4		;no optimization
			MOVB	#$20, -2,X		;replace BSR by BRA
			JOB	CF_SEMICOLON_5		;finish up
			;No COF optimization (CP in X)
CF_SEMICOLON_4		INX
			STX	CP			;updated CP
			MOVB	#$3D, -1,X		;compile "RTS"
			;Consider INLINE optimization (CP in X)
			TFR	X, D			;CP  -> D
			LDX	CSP			;CSP -> X
			BRSET	0,X,#FUDICT_CI_NOINL,CF_SEMICOLON_5;INLINE blocked
			SUBD	4,X			;compile length -> D
			CPD	#(FUDICT_MAX_INLINE+1)	;check CF length
			BHI	CF_SEMICOLON_5		;no INLINE optimization
			DECB				;adjust INLINE size
			LDX	4,X			;xt -> X 
			STAB	-1,X			;set INLINE compile
			;Embed word into dictionary 
CF_SEMICOLON_5		MOVW	CP, CP_SAVE   		;secure compilation
			LDX	CSP 			;CSP -> X
			LDD	2,X			;NFA -> D
			BEQ	CF_SEMICOLON_6		;:NONAME compilation
			STD	FUDICT_LAST_NFA		;update last NFA
			JOB	CF_SEMICOLON_7		;clean up
			;Conclude :NONAME compilation (CSP in X)
CF_SEMICOLON_6		MOVW	4,X, 2,-Y 		;xt -> PS
			;Clean-up
			LDAA	#6 			;deallocate CS space
			JOB	FPS_CS_ALLOC		;

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
			;Remove COF optimization flags
			LDX	CSP  			;CSP -> X
			BCLR	0,X,#FUDICT_CI_COF 	;clear compile flags
			;Allocate compile space 
CF_LITERAL_1		LDX	CP 			;CP -> X
			LEAX	5,X			;allocate 5 bytes
			STX	CP			;update CP
			;Compile execution semantics 
			MOVW	#$1800, -5,X		;"MOVW $xxxx, 2,-SP"
			MOVB	#$6E,   -3,X		; => 18006Exxxx
			MOVW	2,Y+,   -2,X		;compile top of PS
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




	
;;Word: .(
;;Compilation: Perform the execution semantics given below.
;;Execution: ( "ccc<paren>" -- )
;;Parse and display ccc delimited by ) (right parenthesis). .( is an immediate
;;word.
;IF_DOT_PAREN		IMMEDIATE
;CF_DOT_PAREN		EQU	*
;			;Parse "ccc<quote>"
;			MOVW	#")", 2,-Y 		;"-delimiter -> PS
;			JOB	CF_DOT_QUOTE_1
;	
;;Word: ."
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( "ccc<quote>" -- )
;;Parse ccc delimited by " (double-quote). Append the run-time semantics given
;;below to the current definition.
;IF_DOT_QUOTE		IMMEDIATE
;CF_DOT_QUOTE		EQU	*
;			;Parse "ccc<quote>"
;			MOVW	#$22, 2,-Y 		;"-delimiter -> PS
;CF_DOT_QUOTE_1		JOBSR	CF_PARSE		;parse "ccc<quote>"
;			LDD	0,Y			;check u
;			BEQ	CF_DOT_QUOTE_2		;empty string
;			;Check state ( c-addr u )
;			LDD	STATE 			;STATE -> D
;			BNE	CF_DOT_QUOTE_3		;compilation semantics
;			;Interpretation semantics ( c-addr u )
;			JOB	CF_STRING_DOT		;print message
;			;Empty string ( c-addr u )
;CF_DOT_QUOTE_2		LEAY	4,Y 			;clean up stack
;			RTS				
;			;Compilation semantics ( c-addr u )
;CF_DOT_QUOTE_3		PULX				;return addr -> X
;			PULD				;compile info -> D
;			PSHX				;return addr -> 2,SP
;			PSHD				;compile info -> 0,SP
;			MOVW	#CF_DOT_QUOTE_RT, 2,-Y 	;runtime semantics -> PS
;			JOBSR	CF_COMPILE_COMMA_1	;compile word
;			JOBSR	CF_STRING_COMMA_1	;compile string
;			PULD				;compile info -> D
;			;CLRB				;no optimization
;			PULX				;return addr -> X
;			PSHD				;compile info -> 0,SP
;			JMP	0,X			;done
;;Run-time: ( -- )
;;Display ccc.
;IF_DOT_QUOTE_RT		REGULAR
;CF_DOT_QUOTE_RT		EQU	*
;			;Print string 
;			PULX				;string pointer -> X
;			JOBSR	FUDICT_TX_STRING	;print string
;			JMP	0,X			;continue after string
;
;;Word: ?DO
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: -- do-sys )
;;Put do-sys onto the control-flow stack. Append the run-time semantics given
;;below to the current definition. The semantics are incomplete until resolved by
;;a consumer of do-sys such as LOOP.
;;Run-time: ( n1|u1 n2|u2 -- ) ( R: --  | loop-sys )
;;If n1|u1 is equal to n2|u2, continue execution at the location given by the
;;consumer of do-sys. Otherwise set up loop control parameters with index n2|u2
;;and limit n1|u1 and continue executing immediately following ?DO. Anything
;;already on the return stack becomes unavailable until the loop control
;;parameters are discarded. An ambiguous condition exists if n1|u1 and n2|u2 are
;;not both of the same type.
;IF_QUESTION_DO		IMMEDIATE
;CF_QUESTION_DO		COMPILE_ONLY
;			;Allocate 13 bytes of compile space 
;			LDX	CP 			;CP -> X
;			LEAX	13,X			;alloate space
;			STX	CP			;update CP
;			LEAX	-13,X			;alloate space
;			;Compile inline code (old CP in X) 
;			MOVW	#$EC42,	2,X+ 		;compile "LDD 2,Y"
;			MOVW	#$3BEC,	2,X+ 		;compile "PSHD LDD"
;			MOVW	#$733B,	2,X+ 		;compile "4,Y+ PSHD"
;			MOVW	#$AC82,	2,X+ 		;compile "CPD 2,SP"
;			MOVW	#$2603,	2,X+ 		;compile "BNE *+5"
;			MOVW	#$0000, 0,X		;end of LEAVE list
;			;Put do-sys onto the control flow stack (LEAVE list in X)
;			;                              +--------+--------+              
;			;                              |  Return Address | ...     
;			;                              +--------+--------+	       
;			;                              |  New Comp. Info | SP+0     
;			;                              +--------+--------+	       
;			;                              |    LEAVE list   | SP+2     
;			; +--------+--------+	   ==> +--------+--------+	       
;			; |  Return Address | SP+0     |   LOOP address  | SP+4     
;			; +--------+--------+	       +--------+--------+	       
;			; | Old Comp. Info  | SP+2     | Old Comp. Info  | SP+6     
;			; +--------+--------+          +--------+--------+           
;			PSHX				;LEAVE list -> 2,SP
;			LDAA	4,SP			;inherit high byte of compile info
;			LDAB	#FUDICT_CI_DO_SYS	;set control flow
;			PSHD				;new compilation info -> 0,SP
;			LEAX	3,X			;LOOP address -> X
;			LDD	4,SP			;Return address -> D
;			EXG	X, D			;X <-> D
;			STD	4,SP			;set LOOP address
;			JMP	0,X			;done
;
;;Word: DO
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: -- do-sys )
;;Place do-sys onto the control-flow stack. Append the run-time semantics given
;;below to the current definition. The semantics are incomplete until resolved
;;by a consumer of do-sys such as LOOP.
;;;Run-time: ( n1|u1 n2|u2 -- ) ( R: -- loop-sys )
;;Set up loop control parameters with index n2|u2 and limit n1|u1. An ambiguous
;;condition exists if n1|u1 and n2|u2 are not both the same type. Anything
;;already on the return stack becomes unavailable until the loop-control
;;parameters are discarded.
;IF_DO			IMMEDIATE
;CF_DO			COMPILE_ONLY
;			;Allocate 6 bytes of compile space 
;			LDX	CP 			;CP -> X
;			LEAX	6,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (old CP in X) 
;			MOVW	#$EC42,	-6,X 		;compile "LDD 2,Y"
;			MOVW	#$3BEC,	-4,X 		;compile "PSHD LDD"
;			MOVW	#$733B,	-2,X 		;compile "4,Y+ PSHD"
;			;Put do-sys onto the control flow stack (LEAVE list in X)
;			;                              +--------+--------+              
;			;                              |  Return Address | ...     
;			;                              +--------+--------+	       
;			;                              |  New Comp. Info | SP+0     
;			;                              +--------+--------+	       
;			;                              |    LEAVE list   | SP+2     
;			; +--------+--------+	   ==> +--------+--------+	       
;			; |  Return Address | SP+0     |   LOOP address  | SP+4     
;			; +--------+--------+	       +--------+--------+	       
;			; | Old Comp. Info  | SP+2     | Old Comp. Info  | SP+6     
;			; +--------+--------+          +--------+--------+           
;			MOVW	#$0000, 2,-SP		;LEAVE list -> 2,SP
;			LDAA	4,SP			;inherit high byte of compile info
;			LDAB	#FUDICT_CI_DO_SYS	;set control flow
;			PSHD				;new compilation info -> 0,SP
;			LDD	4,SP			;Return address -> D
;			EXG	X, D			;X <-> D
;			STD	4,SP			;set LOOP address
;			JMP	0,X			;done
;
;;Word: LEAVE
;;Interpretation: Interpretation semantics for this word are undefined.
;;Execution: ( -- ) ( R: loop-sys -- )
;;Discard the current loop control parameters. An ambiguous condition exists if
;;they are unavailable. Continue execution immediately following the innermost
;;syntactically enclosing DO ... LOOP or DO ... +LOOP.
;IF_LEAVE		IMMEDIATE
;CF_LEAVE		COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DO_SYS	;check for matching "do-sys"
;			BNE	CF_LEAVE_1		;control structure mismatch			
;			;Allocate compile space 
;			LDX	CP  			;CP -> X
;			LEAX	3,X			;alloate space
;			STX	CP			;update CP
;			;Update compile info (CP in X)
;			; +--------+--------+              
;			; |  Return Address | SP+0     
;			; +--------+--------+	       
;			; |  New Comp. Info | SP+2     
;			; +--------+--------+	       
;			; |    LEAVE list   | SP+4     
;			; +--------+--------+	       
;			; |   LOOP address  | SP+6     
;			; +--------+--------+	       
;			; | Old Comp. Info  | SP+8     
;			; +--------+--------+           
;			MOVW	4,SP, 3,-X 		;add entry to LEAVE list
;			STX	4,SP			;
;			RTS				;done
;			;Control structure misatch
;CF_LEAVE_1		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
;
;;Word: LOOP
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: do-sys -- )
;;Append the run-time semantics given below to the current definition. Resolve
;;the destination of all unresolved occurrences of LEAVE between the location
;;given by do-sys and the next location for a transfer of control, to execute the
;;words following the LOOP.
;;Run-time: ( -- ) ( R:  loop-sys1 --  | loop-sys2 )
;;An ambiguous condition exists if the loop control parameters are unavailable.
;;Add one to the loop index. If the loop index is then equal to the loop limit,
;;discard the loop parameters and continue execution immediately following the
;;loop. Otherwise continue execution at the beginning of the loop.
;IF_LOOP			IMMEDIATE
;CF_LOOP			COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DO_SYS	;check for matching "do-sys"
;			BNE	CF_LOOP_5		;control structure mismatch			
;			;Calculate branch distance 
;			LDX	CP 			;CP -> X
;			LDD	6,SP 			;LOOP address -> D
;			SUBD	CP			;LOOP address - CP -> D
;			SUBD	#7			;subtract INLINE code offset
;			CMPA	#$FF			;check if ling branch is required
;			BNE	CF_LOOP_6		;comlile long branch code
;			;Reserve compile space for short branch code (rr in B, CP in X) 
;			LEAX	9,X			;advance CP
;			STX	CP			;update CP
;			;Compile short branch code (rr in B, CP in X) 
;			;30            PULX
;			;08            INX
;			;34            PSHX
;			;AE 82         CPX     2,SP
;			;26 rr         BNE     start of LOOP body
;			;1B 84         LEAS    4,SP
;			MOVW	#$3008, -9,X 		;compile "PULX INX"
;			MOVW	#$34AE, -7,X 		;compile "PSHX CPX"
;			MOVW	#$8226, -5,X 		;compile "2,SP BNE"
;CF_LOOP_1		STAB		-3,X		;compile "rr"
;CF_LOOP_2		MOVW	#$1B84	-2,X		;compile "LEAS 4,SP"
;			;Resolve LEAVE list (CP in X) 
;			LEAX	-2,X 			;LEAVE target -> X
;			STX	6,SP			;store LEAVE target (LOOP address no longer needed)
;			LDX	4,SP			;LEAVE source -> X
;			BEQ	CF_LOOP_4		;conclude compilation
;			BSET	2,SP,#FUDICT_CI_NOINL	;forbid inline compilation
;CF_LOOP_3		LDD	0,X			;next LEAVE source -> D
;			MOVB	#$06, 1,X+		;compile "JMP"
;			MOVW	6,SP, 0,X		;compile "hhll"
;			TFR	D, X			;next LEAVE source -> X
;			TBNE	X, CF_LOOP_3	;resolve next LEAVE
;			;Conclude compilation
;			; +--------+--------+                                      
;			; |  Return Address | SP+0                               
;			; +--------+--------+	                                 
;			; |  New Comp. Info | SP+2                                
;			; +--------+--------+	                                 
;			; |    LEAVE list   | SP+4                                
;			; +--------+--------+	   ==> +--------+--------+	          
;			; |   LOOP address  | SP+6     |  Return Address | SP+0  
;			; +--------+--------+  	       +--------+--------+	       
;			; | Old Comp. Info  | SP+8     | Old Comp. Info  | SP+2  
;			; +--------+--------+          +--------+--------+        
;CF_LOOP_4		LDAA	2,SP	 		;maintain high byte of compile info
;			LDAB	#FUDICT_CI_NONE		;no optimization
;			STD	8,SP			;update compilation info
;			LDX	8,SP+			;return address -> X
;			JMP	0,X			;done
;			;Control structure misatch
;CF_LOOP_5		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
;			;Reserve compile space for long branch code (qqrr in D, CP in X) 
;CF_LOOP_6		LEAX	11,X			;advance CP
;			STX	CP			;update CP
;			;Compile long branch code (qqrr in D, CP in X) 
;			;30             PULX
;			;08             INX
;			;34             PSHX
;			;AE 82          CPX     2,SP
;			;18 26 qq rr    LBNE    start of loop body
;			;1B 84          LEAS    4,SP
;			MOVW	#$3008, -11,X 		;compile "PULX INX"
;			MOVW	#$34AE,  -9,X 		;compile "PSHX CPX"
;			MOVW	#$8218,  -7,X 		;compile "2,SP LBNE"
;			MOVB	#$26,    -5,X 		;compile "LBNE"
;CF_LOOP_7		STD		 -4,X		;compile "qq rr"
;			JOB	CF_LOOP_2		;compile "LEAS 4,SP"
;	
;;Word: +LOOP
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: do-sys -- )
;;Append the run-time semantics given below to the current definition. Resolve
;;the destination of all unresolved occurrences of LEAVE between the location
;;given by do-sys and the next location for a transfer of control, to execute the
;;words following +LOOP.
;;Run-time: ( n -- ) ( R: loop-sys1 -- | loop-sys2 )
;;An ambiguous condition exists if the loop control parameters are unavailable.
;;Add n to the loop index. If the loop index did not cross the boundary between
;;the loop limit minus one and the loop limit, continue execution at the beginning
;;of the loop. Otherwise, discard the current loop control parameters and continue
;;execution immediately following the loop.
;IF_PLUS_LOOP		IMMEDIATE
;CF_PLUS_LOOP		COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DO_SYS	;check for matching "do-sys"
;			BNE	CF_LOOP_5		;control structure mismatch			
;			;Calculate branch distance 
;			LDX	CP 			;CP -> X
;			LDD	6,SP 			;LOOP address -> D
;			SUBD	CP			;LOOP address - CP -> D
;			SUBD	#7			;subtract INLINE code offset
;			CMPA	#$FF			;check if ling branch is required
;			BNE	CF_PLUS_LOOP_1		;comlile long branch code
;			;Reserve compile space for short branch code (rr in B, CP in X) 
;			LEAX	10,X			;advance CP
;			STX	CP			;update CP
;			;Compile short branch code (rr in B, CP in X) 
;			;3A           PULD
;			;E3 71        ADDD    2,Y+
;			;3B           PSHD
;			;AC 82        CPD     2,SP
;			;26 rr        BNE     start of LOOP body
;			;1B 84        LEAS    4,SP
;			MOVW	#$3AE3, -10,X 		;compile "PULD ADDD"
;			MOVW	#$71EB	 -8,X		;compile "2,Y+ PSHD"
;			MOVW	#$AC82	 -6,X		;compile "CPD 2,SP"
;			MOVB	#$26	 -4,X		;compile "BNE"
;			JOB	CF_LOOP_1		;compile "rr"
;			;Reserve compile space for long branch code (qqrr in D, CP in X) 
;CF_PLUS_LOOP_1		LEAX	12,X			;advance CP
;			STX	CP			;update CP
;			;Compile long branch code (qqrr in D, CP in X) 
;			;3A             PULD
;			;E3 71          ADDD    2,Y+
;			;3B             PSHD
;			;AC 82          CPD     2,SP
;			;18 26 qq rr    LBNE    start of loop body
;			;1B 84          LEAS    4,SP
;			MOVW	#$3AE3, -12,X 		;compile "PULD ADDD"
;			MOVW	#$713B, -10,X 		;compile "2,Y+ PSHD"
;			MOVW	#$AC82	 -8,X		;compile "CPD 2,SP"
;			MOVW	#$1826	 -6,X		;compile "LBNE"
;			JOB	CF_LOOP_7		;compile "qq rr"
;	
;;Word: UNLOOP
;;Interpretation: Interpretation semantics for this word are undefined.
;;Execution: ( -- ) ( R: loop-sys -- )
;;Discard the loop-control parameters for the current nesting level. An UNLOOP is
;;required for each nesting level before the definition may be EXITed. An
;;ambiguous condition exists if the loop-control parameters are unavailable.
;IF_UNLOOP		IMMEDIATE
;CF_UNLOOP		COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DO_SYS	;check for matching "do-sys"
;			BNE	CF_UNLOOP_1		;control structure mismatch			
;			;Allocate 2 bytes of compile space 
;			LDX	CP 			;CP -> X
;			LEAX	2,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (CP in X) 
;			MOVW	#$1B84, -2,X 		;compile "LEAS 4,SP"
;			RTS				;done
;			;Control structure misatch
;CF_UNLOOP_1		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
;
;;Word: I
;;Interpretation: Interpretation semantics for this word are undefined.
;;Execution: ( -- n|u ) ( R:  loop-sys -- loop-sys )
;;n|u is a copy of the current (innermost) loop index. An ambiguous condition
;;exists if the loop control parameters are unavailable.
;IF_I			IMMEDIATE
;CF_I			COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DO_SYS	;check for matching "do-sys"
;			BNE	CF_UNLOOP_1		;control structure mismatch			
;			;Allocate 4 bytes of compile space 
;			LDX	CP 			;CP -> X
;			LEAX	4,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (CP in X) 
;			MOVW	#$1802, -4,X 		;compile "MOVW"
;			MOVW	#$806E, -2,X 		;compile "0,SP, 2,-Y"
;			RTS				;done
;
;;Word: J
;;Interpretation: Interpretation semantics for this word are undefined.
;;Execution: ( -- n|u ) ( R: loop-sys1 loop-sys2 -- loop-sys1 loop-sys2 )
;;n|u is a copy of the next-outer loop index. An ambiguous condition exists if
;;the loop control parameters of the next-outer loop, loop-sys1, are unavailable.
;IF_J			IMMEDIATE
;CF_J			COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DO_SYS	;check for matching "do-sys"
;			BNE	CF_UNLOOP_1		;control structure mismatch			
;			;Allocate 4 bytes of compile space 
;			LDX	CP 			;CP -> X
;			LEAX	4,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (CP in X) 
;			MOVW	#$1802, -4,X 		;compile "MOVW"
;			MOVW	#$846E, -2,X 		;compile "4,SP, 2,-Y"
;			RTS				;done
;	
;;Word: IF 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: -- orig )
;;Put the location of a new unresolved forward reference orig onto the control
;;flow stack. Append the run-time semantics given below to the current
;;definition. The semantics are incomplete until orig is resolved, e.g., by THEN
;;or ELSE.
;;Run-time: ( x -- )
;;If all bits of x are zero, continue execution at the location specified by the
;;resolution of orig.
;IF_IF			IMMEDIATE
;CF_IF			COMPILE_ONLY
;			;Allocate 6 bytes of compile space 
;			LDX	CP 			;CP -> X
;			LEAX	6,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (CP in X) 
;			MOVW	#$EC71, -6,X 		;"LDD 2,Y+"
;			;MOVW	#$1827, -4,X		;"LBEQ"
;			;MOVW	#$0000, -2,X		;"qq rr"
;			LEAX	-4,X 			;orig -> X
;			;Put orig onto the control flow stack (orig in X)
;			;                              +--------+--------+              
;			;                              |  Return Address | ...     
;			;                              +--------+--------+	       
;			;                              |  New Comp. Info | SP+0     
;			; +--------+--------+	   ==> +--------+--------+	       
;			; |  Return Address | SP+0     |      orig       | SP+2     
;			; +--------+--------+	       +--------+--------+	       
;			; | Old Comp. Info  | SP+2     | Old Comp. Info  | SP+4     
;			; +--------+--------+          +--------+--------+           
;			PULD				;return address -> D
;			PSHX				;orig           -> 2,SP
;			TFR	D, X			;return address -> X
;			LDAA	2,SP			;inherit high byte of compile info
;			LDAB	#FUDICT_CI_COND_ORIG	;set control flow
;			PSHD				;new compilation info -> 0,SP
;			JMP	0,X			;done
;
;;Word: ELSE 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: orig1 -- orig2 )
;;Put the location of a new unresolved forward reference orig2 onto the control
;;flow stack. Append the run-time semantics given below to the current
;;definition. The semantics will be incomplete until orig2 is resolved
;;(e.g., by THEN). Resolve the forward reference orig1 using the location
;;following the appended run-time semantics.
;;Run-time: ( -- )
;;Continue execution at the location given by the resolution of orig2.
;IF_ELSE			IMMEDIATE
;CF_ELSE			COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_COND_ORIG	;check for matching conditional "orig"
;			BNE	CF_ELSE_4		;control structure mismatch
;			;Update compile info 
;			; +--------+--------+              
;			; |  Return Address | SP+0    
;			; +--------+--------+	       
;			; |  New Comp. Info | SP+2     
;			; +--------+--------+	       
;			; |   orig1/orig2   | SP+4     
;			; +--------+--------+	       
;			MOVB	#FUDICT_CI_ORIG, 3,SP 	;update compile info
;			LDD	4,SP			;orig1 -> D
;			LDX	CP			;orig2 -> X
;			STX	4,SP			;set orig2
;			;Allocate compile space (orig1 in D, CP in X) 
;			LEAX	3,X			;alloate space
;			STX	CP			;update CP
;			;Calculate branch distance (orig1 in D, CP in X)
;CF_ELSE_1		COMA				;invert D
;			COMB				;-orig1-1 -> D
;			LEAX	D,X			;CP-orig1-1 -> X
;			DEX				;qq rr -> X
;			COMA				;invert D
;			COMB				;orig1 -> D
;			EXG	X, D			;X <-> D
;			;Compile IF forward reference (orig1 in X, qq rr in D)
;			TBEQ	A, CF_ELSE_2 		;compile BEQ
;			;Compile LBEQ (orig1 in X, qq rr in D)		
;			MOVW	#$1827, 2,X+		;compile "LBEQ"
;			STD	0,X			;compile "qq rr"
;			JOB	CF_ELSE_3 		;set compile info
;			;Compile BEQ (orig1 in X, qq rr in D)
;CF_ELSE_2		MOVB	#$27, 1,X+		;compile "BEQ"
;			STAB	1,X+			;compile "rr"
;			MOVW	#$A7A7, 0,X		;compile "NOP NOP"
;CF_ELSE_3		RTS				;done
;			;Control structure misatch
;CF_ELSE_4		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
;	
;;Word: THEN 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: orig -- )
;;Append the run-time semantics given below to the current definition. Resolve
;;the forward reference orig using the location of the appended run-time
;;semantics.
;;Run-time: ( -- )
;;Continue execution.
;IF_THEN			IMMEDIATE
;CF_THEN			COMPILE_ONLY
;			;Check compile info 
;CF_THEN_1		LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_ORIG		;check for matching "orig"
;			BEQ	CF_THEN_2		;conclude "ELSE"
;			CMPB	#FUDICT_CI_COND_ORIG	;check for matching conditional "orig"
;			BNE	CF_THEN_3		;conrol structure mismatch
;			;Conclude "IF"
;			; +--------+--------+                                           
;			; |  Return Address | SP+0                                  
;			; +--------+--------+	                                    
;			; |  New Comp. Info | SP+2                                  
;			; +--------+--------+	   ==>  +--------+--------+	         
;			; |      orig       | SP+4      |  Return Address | SP+0    
;			; +--------+--------+	        +--------+--------+	         
;			; | Old Comp. Info  | SP+6      | Old Comp. Info  | SP+2    
;			; +--------+--------+           +--------+--------+          
;			LDAA	2,SP	 		;maintain high byte of compile info
;			LDAB	#FUDICT_CI_NONE		;no optimization
;			STD	6,SP			;update compilation info
;			MOVB	2,SP, 6,SP 		;maintain high byte of compile info
;			MOVB	#FUDICT_CI_NONE, 7,SP	;no optimization
;			LDD	4,SP			;orig -> D
;			MOVW	0,SP, 4,+SP		;move return address
;			LDX	CP			;CP -> X
;			JOB	CF_ELSE_1		;conclude "IF"
;			;Conclude "ELSE"
;CF_THEN_2		LDAA	2,SP	 		;maintain high byte of compile info
;			ORAA	#FUDICT_CI_NOINL	;forbid INLINE compiling
;			LDAB	#FUDICT_CI_NONE		;no optimization
;			STD	6,SP			;update compilation info
;			LDX	4,SP			;orig -> X
;			MOVW	0,SP, 4,+SP		;move return address
;			LDD	CP			;CP -> D
;			SUBD	FUDICT_OFFSET		;CP-offset -> D
;			MOVB	#$06, 1,X+		;compile "JMP"
;			STD	0,X			;compile "hh ll"
;			RTS				;done
;			;Control structure misatch
;CF_THEN_3		EQU	CF_ELSE_4
;	
;
;;Word: REPEAT 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: orig dest -- )
;;Append the run-time semantics given below to the current definition, resolving
;;the backward reference dest. Resolve the forward reference orig using the
;;location following the appended run-time semantics.
;;Run-time: ( -- )
;;Continue execution at the location given by dest.
;IF_REPEAT		IMMEDIATE
;CF_REPEAT		COMPILE_ONLY
;			;Run CF_AGAIN
;			;                              +--------+--------+                                      
;			;                              |  Return Address | ...                             
;			; +--------+--------+          +--------+--------+                                      
;			; |  Return Address | SP+0     |    Comp. Info   | SP+0                             
;			; +--------+--------+	       +--------+--------+	                               
;			; |    Comp. Info   | SP+2     |      dest       | SP+2                             
;			; +--------+--------+          +--------+--------+             
;			; |      dest       | SP+4     |   Comp. Info    | SP+4    
;			; +--------+--------+	       +--------+--------+	        
;			; |    Comp. Info   | SP+6     |  Return Address | SP+6    
;			; +--------+--------+      ==> +--------+--------+           
;			; |   Cond. orig    | SP+8     |   Cond. orig    | SP+8    
;			; +--------+--------+          +--------+--------+           
;			; |   Comp. Info    | SP+10    |   Comp. Info    | SP+10    
;			; +--------+--------+          +--------+--------+          
;			PULX				;return address   -> X
;			PULD				;compilation info -> D
;			MOVW	0,SP, 2,-SP		;dest             -> 2,SP
;			MOVW	4,SP, 2,SP		;compilation info -> 4,SP
;			STX	4,SP			;return addr      -> 6,SP
;			PSHD				;compilation info -> 0,SP
;			JOBSR	CF_AGAIN_1
;			;Run CF_THEN
;			; +--------+--------+          +--------+--------+             
;			; |    Comp. Info   | SP+0     |  Return Address | SP+0    
;			; +--------+--------+	       +--------+--------+	        
;			; |  Return Address | SP+2     |    Comp. Info   | SP+2    
;			; +--------+--------+      ==> +--------+--------+           
;			; |   Cond. orig    | SP+4     |   Cond. orig    | SP+4    
;			; +--------+--------+          +--------+--------+           
;			; |   Comp. Info    | SP+6     |   Comp. Info    | SP+6    
;			; +--------+--------+          +--------+--------+          
;			PULD				;compilation info -> D
;			PULX				;return address   -> X
;			PSHD				;compilation info -> 2,SP
;			PSHX				;return address   -> 0,SP
;			JOB	CF_THEN_1
;		
;;Word: AGAIN 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: dest -- )
;;Append the run-time semantics given below to the current definition, resolving
;;the backward reference dest.
;;Run-time: ( -- )
;;Continue execution at the location specified by dest. If no other control flow
;;words are used, any program code after AGAIN will not be executed.
;IF_AGAIN		IMMEDIATE
;CF_AGAIN		COMPILE_ONLY
;			;Check compile info 
;CF_AGAIN_1		LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DEST		;check for matching "dest"
;			BNE	CF_AGAIN_5		;control structure mismatch
;			;Calculate branch distance
;			LDX	CP 			;CP -> X
;			LDD	4,SP 			;dest -> D
;			SUBD	CP			;branch distance -> D
;			CMPA	#$FF			;check for sort branch
;			BNE	CF_AGAIN_4		;long branch -> jump
;			;Reserve compile space for short branch code (rr in B, CP in X) 					
;			LEAX	2,X			;advance CP
;			STX	CP			;update CP
;			;Compile short branch code (rr in B, CP in X) 
;			;20 rr         BRA  start of LOOP body
;			MOVB	#$20,   -2,X 		;compile "BRA"
;CF_AGAIN_2		STAB		-1,X		;compile "rr"
;			;Update compile info
;			; +--------+--------+                                      
;			; |  Return Address | SP+0                               
;			; +--------+--------+	                                 
;			; |  New Comp. Info | SP+2                                
;			; +--------+--------+	   ==> +--------+--------+	          
;			; |      dest       | SP+4     |  Return Address | SP+0  
;			; +--------+--------+  	       +--------+--------+	       
;			; | Old Comp. Info  | SP+6     | Old Comp. Info  | SP+2  
;			; +--------+--------+          +--------+--------+        	
;CF_AGAIN_3		LDAA	2,SP	 		;maintain high byte of compile info
;			LDAB	#FUDICT_CI_NONE		;no optimization
;			STD	6,SP			;update compilation info
;			LDX	6,SP+			;return address -> X
;			JMP	0,X			;done
;			;Reserve compile space for jump code  (CP in X)					
;CF_AGAIN_4		LEAX	3,X			;advance CP
;			STX	CP			;update CP
;			;Compile jump code (CP in X)
;			BSET	2,SP,#FUDICT_CI_NOINL	;forbid inline compilation
;			;06 hh ll      JMP  start of LOOP body
;			MOVB	#$06, -3,X 		;compile "JMP"
;			LDD	4,SP			;dest -> D
;			SUBD	FUDICT_OFFSET		;dest-offet -D
;			STD	-2,X			;compile "hh ll"
;			JOB	CF_AGAIN_3		;update compile info
;			;Control structure misatch
;CF_AGAIN_5		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
;
;;Word: UNTIL 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: dest -- )
;;Append the run-time semantics given below to the current definition, resolving
;;the backward reference dest.
;;Run-time: ( x -- )
;;If all bits of x are zero, continue execution at the location specified by
;;dest.
;IF_UNTIL		IMMEDIATE
;CF_UNTIL		COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DEST		;check for matching "dest"
;			BNE	CF_AGAIN_5		;control structure mismatch
;			;Calculate branch distance
;			LDX	CP 			;CP -> X
;			LDD	4,SP 			;dest -> D
;			SUBD	CP			;branch distance -> D
;			CMPA	#$FF			;check for sort branch
;			BNE	CF_UNTIL_1		;long branch
;			;Reserve compile space for short branch code (rr in B, CP in X) 					
;			LEAX	4,X			;advance CP
;			STX	CP			;update CP
;			;Compile short branch code (rr in B, CP in X) 
;			;EC 71	       LDD 2,Y+
;			;27 rr         BEQ  start of LOOP body
;			MOVW	#$EC71, -4,X 		;"LDD 2,Y+"
;			MOVB	#$27,   -2,X 		;compile "BRA"
;			JOB	CF_AGAIN_2		;compile "rr"
;			;Reserve compile space for long branch code (qqrr in D, CP in X)					
;CF_UNTIL_1		LEAX	6,X			;advance CP
;			STX	CP			;update CP
;			;Compile long branch code (qqrr in D, CP in X)
;			;EC 71	       LDD 2,Y+
;			;18 27 qq rr   LBEQ  start of LOOP body
;			MOVW	#$EC71, -6,X 		;compile "LDD 2,Y+"
;			MOVW	#$1827, -4,X 		;compile "LBEQ"
;			STD	        -2,X		;compile "qq rr"
;			JOB	CF_AGAIN_3		;update compile info
;
;;Word: BEGIN 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: -- dest )
;;Put the next location for a transfer of control, dest, onto the control flow
;;stack. Append the run-time semantics given below to the current definition.
;;Run-time: ( -- )
;;Continue execution.
;IF_BEGIN		IMMEDIATE
;CF_BEGIN		COMPILE_ONLY
;			;Put dest onto the control flow stack
;			;                              +--------+--------+              
;			;                              |  Return Address | ...     
;			;                              +--------+--------+	       
;			;                              |  New Comp. Info | SP+0     
;			; +--------+--------+	   ==> +--------+--------+	       
;			; |  Return Address | SP+0     |       dest      | SP+2     
;			; +--------+--------+	       +--------+--------+	       
;			; | Old Comp. Info  | SP+2     | Old Comp. Info  | SP+4     
;			; +--------+--------+          +--------+--------+           
;			PULX				;return address -> X
;			MOVW	CP, 2,-SP		;dest -> 2,SP
;			LDAA	2,SP			;inherit high byte of compile in
;			LDAB	#FUDICT_CI_DEST		;set control flow
;			PSHD				;new compilation info -> 0,SP
;			RTS				;done
;	
;;Word: WHILE 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: dest -- orig dest )
;;Put the location of a new unresolved forward reference orig onto the control
;;flow stack, under the existing dest. Append the run-time semantics given below
;;to the current definition. The semantics are incomplete until orig and dest are
;;resolved (e.g., by REPEAT).
;;Run-time: ( x -- )
;;If all bits of x are zero, continue execution at the location specified by the
;;resolution of orig.
;IF_WHILE		IMMEDIATE
;CF_WHILE		COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_DEST		;check for matching "dest"
;			BNE	CF_WHILE_1		;control structure mismatch
;			;Allocate 6 bytes of compile space 
;			LDX	CP 			;CP -> X
;			LEAX	6,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (CP in X) 
;			MOVW	#$EC71, -6,X 		;"LDD 2,Y+"
;			;MOVW	#$1827, -4,X		;"LBEQ"
;			;MOVW	#$0000, -2,X		;"qq rr"
;			LEAX	-4,X 			;orig -> X
;			;Put dest onto the control flow stack (orig in X)
;			;                              +--------+--------+             
;			;                              |  Return Address | ...    
;			;                              +--------+--------+	      
;			;                              |  Old Comp. Info | SP+0    
;			; +--------+--------+          +--------+--------+             
;			; |  Return Address | SP+0     |      dest       | SP+2    
;			; +--------+--------+	       +--------+--------+	      
;			; |  New Comp. Info | SP+2     |  New Comp. Info | SP+4    
;			; +--------+--------+      ==> +--------+--------+           
;			; |       dest      | SP+4     |   Cond. orig    | SP+6    
;			; +--------+--------+          +--------+--------+           
;			; | Old Comp. Info  | SP+6     | Old Comp. Info  | SP+8    
;			; +--------+--------+          +--------+--------+          
;			TFR	X, D 			;orig -> D
;			PULX				;return address -> X
;			MOVW	2,SP, 2,-SP		;dest -> 2,SP
;			MOVW	2,SP, 2,-SP		;compilation info -> 0,SP
;			MOVB	#FUDICT_CI_COND_ORIG, 5,SP;set new compilation info
;			STD	6,SP			;orig -> 6,SP
;			JMP	0,X			;done
;			;Control structure misatch
;CF_WHILE_1		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
;
;;Word: CASE
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: -- case-sys )
;;Mark the start of the CASE ... OF ... ENDOF ... ENDCASE structure. Append the
;;run-time semantics given below to the current definition.
;;Run-time: ( -- )
;;Continue execution.
;IF_CASE			IMMEDIATE
;CF_CASE			COMPILE_ONLY
;			;Put dest onto the control flow stack (orig in X)
;			;                              +--------+--------+             
;			;                              |  Return Address | ...    
;			;                              +--------+--------+             
;			;                              |  New Comp. Info | SP+0   
;			; +--------+--------+          +--------+--------+             
;			; |  Return Address | SP+0 ==> |     case-sys    | SP+2    
;			; +--------+--------+	       +--------+--------+	      
;			; |  Old Comp. Info | SP+2     |  Old Comp. Info | SP+4    
;			; +--------+--------+          +--------+--------+           
;			PULX				;return address -> X
;			MOVW	#$0000, 2,-SP		;case-sys       -> 2,SP
;			LDAA	2,SP	 		;maintain high byte of compile info
;			LDAB	#FUDICT_CI_CASE_SYS	;no optimization
;			PSHD				;compilation info -> 0,SP
;			JMP	0,X			;done
;
;;Word: OF
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: -- of-sys )
;;Put of-sys onto the control flow stack. Append the run-time semantics given
;;below to the current definition. The semantics are incomplete until resolved by
;;a consumer of of-sys such as ENDOF.
;;Run-time: ( x1 x2 --   | x1 )
;;If the two values on the stack are not equal, discard the top value and
;;continue execution at the location specified by the consumer of of-sys, e.g.,
;;following the next ENDOF. Otherwise, discard both values and continue execution
;;in line.
;IF_OF			IMMEDIATE
;CF_OF			COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_CASE_SYS	;check for matching "case-sys"
;			BNE	CF_OF_1			;control structure mismatch
;			;Allocate compile space 
;			LDX	CP 			;CP -> X
;			LEAX	10,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (CP in X) 
;			;EC 71           LDD     2,Y+
;			;AC 40           CPD     0,Y
;			;18 26 FF EA     LBNE    IF_OF
;			;26 E8           BNE     IF_OF
;			;19 42           LEAY    2,Y
;			MOVW	#$EC71, -10,X 		;compile "LDD 2,Y+"
;			MOVW	#$AC40,  -8,X 		;compile "CPD 0,Y"
;			MOVW	#$1942,  -2,X 		;compile "LEAY 2,Y"
;			;Put of-sys onto the control flow stack (orig in X)
;			;                              +--------+--------+             
;			;                              |  Return Address | ...    
;			;                              +--------+--------+             
;			;                              | New Comp. Info  | SP+0    
;			; +--------+--------+          +--------+--------+             
;			; |  Return Address | SP+0 ==> |     of-sys      | SP+2    
;			; +--------+--------+	       +--------+--------+	      
;			; |   Comp. Info    | SP+2     |    Comp. Info   | SP+4    
;			; +--------+--------+          +--------+--------+           
;			; |    case-sys     | SP+4     |    case-sys     | SP+6    
;			; +--------+--------+          +--------+--------+           
;			; |   Comp. Info    | SP+6     |    Comp. Info   | SP+8    
;			; +--------+--------+          +--------+--------+           
;			LEAX	-6,X 			;of-sys -> X
;			PULD				;return address -> D
;			PSHX				;of-sys -> 2,SP
;			TFR	D, X			;return address -> X
;			LDAA	2,SP			;inherit high byte of compile info
;			LDAB	#FUDICT_CI_OF_SYS	;set control flow
;			PSHD				;new compilation info -> 0,SP
;			JMP	0,X			;done
;			;Control structure misatch
;CF_OF_1			THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
;
;;Word: ENDOF
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: case-sys1 of-sys -- case-sys2 )
;;Mark the end of the OF ... ENDOF part of the CASE structure. The next location
;;for a transfer of control resolves the reference given by of-sys. Append the
;;run-time semantics given below to the current definition. Replace case-sys1
;;with case-sys2 on the control-flow stack, to be resolved by ENDCASE.
;;Run-time: ( -- )
;;Continue execution at the location specified by the consumer of case-sys2.
;IF_ENDOF		IMMEDIATE
;CF_ENDOF		COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_OF_SYS	;check for matching "of-sys"
;			BNE	CF_ENDOF_A		;control structure mismatch
;			;Allocate compile space
;			LDX	CP  			;CP -> X
;			LEAX	3,X			;alloate space
;			STX	CP			;update CP
;			;Calculate branch distance (CP in X)
;			TFR	X, D 			;CP -> D
;			SUBD	4,SP			;CP - of-sys -> D
;			LDX	4,SP			;of-sys -> X
;			;Compile OF forward reference (of-sys in X, qq rr in D)
;			TBEQ	A, CF_ENDOF_B 		;compile BNE
;			;Compile LBEQ (of-sys in X, qq rr in D)		
;			MOVW	#$1826, 2,X+		;compile "LBNE"
;			STD	0,X			;compile "qq rr"
;			JOB	CF_ENDOF_C 		;set compile info
;			;Compile BEQ (of-sys in X, qq rr in D)
;CF_ENDOF_B		MOVB	#$26, 1,X+		;compile "BNE"
;			STAB	1,X+			;compile "rr"
;			MOVW	#$A7A7, 0,X		;compile "NOP NOP"
;			;Update control flow stack 
;			; +--------+--------+             
;			; |  Return Address | SP+0    
;			; +--------+--------+             
;			; | New Comp. Info  | SP+2    
;			; +--------+--------+          +--------+--------+             
;			; |      of-sys     | SP+4 ==> |  Return Address | ...    
;			; +--------+--------+	       +--------+--------+	      
;			; |   Comp. Info    | SP+6     |    Comp. Info   | SP+2    
;			; +--------+--------+          +--------+--------+           
;			; |    case-sys1    | SP+8     |    case-sys2    | SP+4    
;			; +--------+--------+          +--------+--------+           
;			; |   Comp. Info    | SP+10    |    Comp. Info   | SP+6    
;			; +--------+--------+          +--------+--------+           
;CF_ENDOF_C		LDX	CP 			;CP -> X
;			MOVW	8,SP, 3,-X		;link in OF structure 
;			STX	8,SP			;case-sys2 -> 4,SP
;			MOVB	2,SP 6,SP		;maintain high byte of compile info
;			LDX	6,X+			;return address -> X
;			JMP	0,X			;done
;			;Control structure misatch
;CF_ENDOF_A		EQU	CF_OF_1			;exception -22 "control structure mismatch"
;
;;Word: ENDCASE
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( C: case-sys -- )
;;Mark the end of the CASE ... OF ... ENDOF ... ENDCASE structure. Use case-sys
;;to resolve the entire structure. Append the run-time semantics given below to
;;the current definition.
;;Run-time: ( x -- )
;;Discard the case selector x and continue execution.
;IF_ENDCASE		IMMEDIATE
;CF_ENDCASE		COMPILE_ONLY
;			;Check compile info 
;			LDAB	3,SP 			;compile info -> B
;			CMPB	#FUDICT_CI_CASE_SYS	;check for matching "case-sys"
;			BNE	CF_ENDCASE_A		;control structure mismatch
;			;Allocate compile space 
;			LDX	CP 			;CP -> X
;			LEAX	2,X			;alloate space
;			STX	CP			;update CP
;			;Compile inline code (CP in X) 
;			;19 42           LEAY    2,Y
;			MOVW	#$1942,  -2,X 		;compile "LEAY 2,Y"
;			;Resolve ENDCASE list (CP in X) 
;			LDX	6,SP	     		;case-sys -> X
;			BEQ	CF_ENDCASE_B 		;nothing to resolve
;CF_ENDCASE_C		BSET	2,SP,#FUDICT_CI_NOINL	;forbid inline compilation
;			LDD	0,X			;next ENDOF -> D
;			MOVB	#$06, 1,X+		;compile "JMP"
;			LDD	CP			;CP -> D
;			SUBD	FUDICT_OFFSET		;CP-offset -> D
;			STX	0,X			;compile "hhll"
;			TFR	D, X			;next ENDOF -> X
;			TBNE	X, CF_ENDCASE_C		;resolve next LEAVE
;			;Update control flow stack 
;			; +--------+--------+                 
;			; |  Return Address | SP+0   
;			; +--------+--------+	             
;			; |   Comp. Info    | SP+2        
;			; +--------+--------+      ==> +--------+--------+           
;			; |    case-sys     | SP+4     |  Return Address | ...    
;			; +--------+--------+          +--------+--------+           
;			; |   Comp. Info    | SP+6     |    Comp. Info   | SP+0    
;			; +--------+--------+          +--------+--------+           
;CF_ENDCASE_B		PULX				;return addr -> X
;			LDAA	0,SP	 		;maintain high byte of compile info
;			LDAB	#FUDICT_CI_NONE		;no optimization
;			STD	4,SP			;update compilation info
;			LDX	6,SP+			;return address -> X
;			JMP	0,X			;done			
;			;Control structure misatch
;CF_ENDCASE_A		EQU	CF_OF_1			;exception -22 "control structure mismatch"

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

