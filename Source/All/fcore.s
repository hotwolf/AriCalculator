#ifndef FCORE_COMPILED
#define FCORE_COMPILED
;###############################################################################
;# S12CForth - FCORE - Forth Core Words                                        #
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
;#    This module implements the ANS Forth core and core extension word set.   #
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
;###############################################################################
;# Version History:                                                            #
;#    April 22, 2010                                                           #
;#      - Initial release                                                      #
;#    October 18, 2016                                                         #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    FEXCPT  - Forth exception words                                          #
;#    FDOUBLE - Forth double-number words                                      #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Prevents idle loop from entering WAIT mode.                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#String termination 
FCORE_TERM			EQU	STRING_TERM
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FCORE_VARS_START_LIN
				ORG 	FCORE_VARS_START, FCORE_VARS_START_LIN
#else
				ORG 	FCORE_VARS_START
FCOREVARS_START_LIN		EQU	@
#endif	
	
FCORE_VARS_END			EQU	*
FCORE_VARS_END_LIN		EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FCORE_INIT, 0
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FCORE_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FCORE_QUIT, 0
#emac
	
;#System integrity monitor
;=========================
#macro	FCORE_MON, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FCORE_CODE_START_LIN
				ORG 	FCORE_CODE_START, FCORE_CODE_START_LIN
#else
				ORG 	FCORE_CODE_START
FCORE_CODE_START_LIN		EQU	@
#endif

;#IO
;===
;#Transmit one char
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FCORE_TX_CHAR			EQU	SCI_TX_BL

;#Prints a MSB terminated string
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FCORE_TX_STRING			EQU	STRING_PRINT_BL

;#########
;# Words #
;#########

;Word: ! ( x a-addr -- )
;Store x at a-addr.
IF_STORE			INLINE	CF_STORE	
CF_STORE			EQU	*
				LDX	2,Y+		;x -> a-addr	
				MOVW	2,Y+, 0,X
CF_STORE_EOI			RTS
	
;# ( ud1 -- ud2 )
;Divide ud1 by the number in BASE giving the quotient ud2 and the remainder n.
;(n is the least-significant digit of ud1.) Convert n to external form and add
;the resulting character to the beginning of the pictured numeric output string.
;An ambiguous condition exists if # executes outside of a <# #> delimited number
;conversion.
;==> FPAD
	
;#> ( xd -- c-addr u )
;Drop xd. Make the pictured numeric output string available as a character
;string. c-addr and u specify the resulting character string. A program may
;replace characters within the string. 
;==> FPAD
	
;#S ( ud1 -- ud2 )
;Convert one digit of ud1 according to the rule for #. Continue conversion
;until the quotient is zero. ud2 is zero. An ambiguous condition exists if #S
;executes outside of a <# #> delimited number conversion.
;==> FPAD
	
;Word: ' ( "<spaces>name" -- xt )
;Skip leading space delimiters. Parse name delimited by a space. Find name and
;return xt, the execution token for name. An ambiguous condition exists if name
;is not found.
IF_TICK				REGULAR
CF_TICK				EQU	*
				MOVW	#FOUTER_SYM_SPACE, 2,-Y ;use SPACE as word seperator
				JOBSR	CF_SKIP_AND_PARSE 	;parse next word
				LDD	0,Y			;check result
				BEQ	CF_TICK_1		;no name
				JOBSR	CF_LU 			;look up word
				LDD	0,Y			;check result
				BEQ	CF_TICK_2		;search failed
				RTS				;done
				;Missing name argument
CF_TICK_1			THROW	FEXCPT_TC_NONAME,	;"Missing name argument"	
				;Unknown word 
CF_TICK_2			THROW	FEXCPT_TC_UDEFWORD	;"Undefined word"	
	
;Word: ( 
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<paren>" -- )
;Parse ccc delimited by ) (right parenthesis). ( is an immediate word.
IF_PAREN			IMMEDIATE
CF_PAREN			EQU	*
				MOVW	#")", 2,-Y 		;delimeter -> PS
				JOBSR	CF_PARSE		;parse TIB
				LEAY	4,Y			;clean up PS
				RTS
	
;Word: * ( n1|u1 n2|u2 -- n3|u3 )
;Multiply n1|u1 by n2|u2 giving the product n3|u3.
IF_STAR				REGULAR
CF_STAR				EQU	*
				LDD	2,Y+ 			;n2    -> D	
				TFR	Y, X 			;save PSP
				SEI 				;start of atomic sequence
				LDY	0,Y			;n1    -> Y
				EMULS	   			;Y * D -> Y:D
				EXG	Y, X			;restore PSP
				CLI				;end of atomic sequence
				STD	0,Y			;n3 -> PS
				TBEQ	X, CF_STAR_1		;result accepted
				IBEQ	X, CF_STAR_1		;result accepted
				THROW	FEXCPT_TC_RESOR		;overflow
CF_STAR_1			RTS				;done
	
;Word: */ ( n1 n2 n3 -- n4 )
;Multiply n1 by n2 producing the intermediate double-cell result d. Divide d by
;n3 giving the single-cell quotient n4. An ambiguous condition exists if n3 is
;zero or if the quotient n4 lies outside the range of a signed number. If d and
;n3 differ in sign, the implementation-defined result returned will be the same
;as that returned by either the phrase >R M* R> FM/MOD SWAP DROP or the phrase
;>R M* R> SM/REM SWAP DROP 
IF_STAR_SLASH			REGULAR
CF_STAR_SLASH			EQU	*
				JOBSR	CF_STAR_SLASH_MOD 	;*/MOD
				MOVW	2,Y+, 0,Y		;remove n4
				RTS				;done
	
;Word: */MOD ( n1 n2 n3 -- n4 n5 )
;Multiply n1 by n2 producing the intermediate double-cell result d. Divide d by
;n3 producing the single-cell remainder n4 and the single-cell quotient n5. An
;ambiguous condition exists if n3 is zero, or if the quotient n5 lies outside
;the range of a single-cell signed integer. If d and n3 differ in sign, the
;implementation-defined result returned will be the same as that returned by
;either the phrase >R M* R> FM/MOD or the phrase >R M* R> SM/REM .
IF_STAR_SLASH_MOD		REGULAR
CF_STAR_SLASH_MOD		EQU	*
				LDX	2,Y+ 			;n3 -> X
				;BEQ	CF_STAR_SLASH_MOD_1	;division by zero
				LDD	0,Y 			;n2 -> D
				PSHY				;save PSP
				SEI 				;start of atomic sequence
				LDY	2,Y			;n1    -> Y
				EMULS	   			;Y * D -> Y:D
				EDIVS	   			;Y:D / X -> Y remainder -> D
				TFR	Y, X			;n5 -> X
				PULY				;restore PSP
				CLI				;end of atomic sequence
				BCS	CF_STAR_SLASH_MOD_1	;division by zero
				BVS	CF_STAR_SLASH_MOD_2	;result out of range
				STD	2,Y			;n4 -> PS
				STX	0,Y			;n5 -> PS
				RTS				;done
CF_STAR_SLASH_MOD_1		THROW	FEXCPT_TC_0DIV		;division by zero
CF_STAR_SLASH_MOD_2		THROW	FEXCPT_TC_RESOR		;result out of range

;Word: + ( n1|u1 n2|u2 -- n3|u3 )
;Add n2|u2 to n1|u1, giving the sum n3|u3.
IF_PLUS				INLINE	CF_PLUS
CF_PLUS				EQU	*
				LDD	2,Y+
				ADDD	0,Y
				STD	0,Y
CF_PLUS_EOI			RTS
	
;Word: +! ( n|u a-addr -- )
;Add n|u to the single-cell number at a-addr.
IF_PLUS_STORE			INLINE	CF_PLUS_STORE
CF_PLUS_STORE			EQU	*
				LDX	2,Y+
				LDD	2,Y+
				ADDD	0,X
				STD	0,X
CF_PLUS_STORE_EOI		RTS			

;+LOOP
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
;==> FUDICT
	
;, ( x -- )
;Reserve one cell of data space and store x in the cell. If the data-space
;pointer is aligned when , begins execution, it will remain aligned when,
;finishes execution. An ambiguous condition exists if the data-space pointer is
;not aligned prior to execution of ,.
;==> FNVDICT

;Word: - ( n1|u1 n2|u2 -- n3|u3 )
;Subtract n2|u2n from n1|u1, giving the difference n3|u3.
IF_MINUS			INLINE	CF_MINUS
CF_MINUS			EQU	*
				LDD	2,Y
				SUBD	2,Y+
				STD	0,Y
CF_MINUS_EOI			RTS
	
;. ( n -- )
;Display n in free field format.
;==> FDOT

;."
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote). Append the run-time semantics given ;"
;below to the current definition.
;Run-time: ( -- )
;Display ccc.
;==>FUDICT
	
;Word: / ( n1 n2 -- n3 )
;Divide n1 by n2, giving the single-cell quotient n3. An ambiguous condition
;exists if n2 is zero. If n1 and n2 differ in sign, the implementation-defined
;result returned will be the same as that returned by either the phrase
;>R S>D R> FM/MOD SWAP DROP or the phrase >R S>D R> SM/REM SWAP DROP .
IF_SLASH			REGULAR
CF_SLASH			EQU	*
				JOBSR	CF_SLASH_MOD 		;\MOD
				MOVW	2,Y+, 0,Y		;remove n3
				RTS				;done
;Word: /MOD ( n1 n2 -- n3 n4 )
;Divide n1 by n2, giving the single-cell remainder n3 and the single-cell
;quotient n4. An ambiguous condition exists if n2 is zero. If n1 and n2 differ
;in sign, the implementation-defined result returned will be the same as that
;returned by either the phrase >R S>D R> FM/MOD or the phrase >R S>D R> SM/REM . 
IF_SLASH_MOD			REGULAR
CF_SLASH_MOD			EQU	*
				LDX	0,Y 			;n2 -> X
				;BEQ	CF_SLASH_MOD_1		;division by zero
				LDD	2,Y			;n1 -> D
				IDIVS 				;D / X -> remainder -> D
				BCS	CF_SLASH_MOD_1		;division by zero
				BVS	CF_SLASH_MOD_2		;result out of range
				STD	2,Y 			;n3 -> PS
				STX	0,Y 			;n4 -> PS
				RTS 				;done
CF_SLASH_MOD_1			THROW	FEXCPT_TC_0DIV		;division by zero
CF_SLASH_MOD_2			THROW	FEXCPT_TC_RESOR		;result out of range

;Word: 0< ( n -- flag )
;flag is true if and only if n is less than zero.
IF_ZERO_LESS			REGULAR
CF_ZERO_LESS			EQU	*
				CLRA					;FALSE -> A
				BRCLR	0,Y,#$80,CF_ZERO_LESS_1		;n is positive
				COMA					;TRUE  -> A
CF_ZERO_LESS_1			TAB					;flag  -> D
				STD	0,Y				;D-> PS
				RTS
	
;Word: 0= ( x -- flag )
;flag is true if and only if x is equal to zero.
IF_ZERO_EQUALS			REGULAR
CF_ZERO_EQUALS			CLRA					;FALSE -> A
				LDX	0,Y				;check x
				BNE	CF_ZERO_EQUALS_1		;x != 0
				COMA					;TRUE  -> A
CF_ZERO_EQUALS_1		TAB					;flag  -> D
				STD	0,Y				;D-> PS
				RTS

;Word: 1+ ( n1|u1 -- n2|u2 )
;Add one (1) to n1|u1 giving the sum n2|u2.
IF_ONE_PLUS			INLINE	CF_ONE_PLUS
CF_ONE_PLUS			EQU	*
				LDX	0,Y
				INX
				STX	0,Y
CF_ONE_PLUS_EOI			RTS
	
;Word: 1- ( n1|u1 -- n2|u2 ) 
;Subtract one (1) from n1|u1 giving the difference n2|u2.
IF_ONE_MINUS			INLINE	CF_ONE_MINUS
CF_ONE_MINUS			EQU	*
				LDX	0,Y
				DEX
				STX	0,Y
CF_ONE_MINUS_EOI		RTS

;Word: 2! ( x1 x2 a-addr -- )
;Store the cell pair x1 x2 at a-addr, with x2 at a-addr and x1 at the next
;consecutive cell. It is equivalent to the sequence SWAP OVER ! CELL+ ! .
IF_TWO_STORE			INLINE	CF_TWO_STORE
CF_TWO_STORE			EQU	*
				LDX	2,Y+				;x -> a-addr	
				MOVW	2,Y+, 2,X+
				MOVW	2,Y+, 0,X
CF_TWO_STORE_EOI		RTS
	
;Word: 2* ( x1 -- x2 )
;x2 is the result of shifting x1 one bit toward the most-significant bit,
;filling the vacated least-significant bit with zero.
IF_TWO_STAR			INLINE	CF_TWO_STAR
CF_TWO_STAR			EQU	*
				LDD	0,Y
				LSLD
				STD	0,Y
CF_TWO_STAR_EOI			RTS
	
;Word: 2/ ( x1 -- x2 )
;x2 is the result of shifting x1 one bit toward the least-significant bit,
;leaving the most-significant bit unchanged.
IF_TWO_SLASH			INLINE	CF_TWO_SLASH
CF_TWO_SLASH			EQU	*
				LDD	0,Y
				LSRD
				STD	0,Y
CF_TWO_SLASH_EOI		RTS

;Word: 2@ ( a-addr -- x1 x2 )
;Fetch the cell pair x1 x2 stored at a-addr. x2 is stored at a-addr and x1 at
;the next consecutive cell. It is equivalent to the sequence DUP CELL+ @ SWAP @ .
IF_TWO_FETCH			INLINE	CF_TWO_FETCH
CF_TWO_FETCH			EQU	*
				LDX	0,Y 			;a-addr -> X			
				MOVW	0,X, 2,-Y		;fetch x1
				MOVW	2,X, 2,Y		;fetch x2
CF_TWO_FETCH_EOI		RTS

;2DROP ( x1 x2 -- )
;Drop cell pair x1 x2 from the stack.
;==> FPS

;2DUP ( x1 x2 -- x1 x2 x1 x2 )
;Duplicate cell pair x1 x2.
;==> FPS

;2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;Copy cell pair x1 x2 to the top of the stack.
;==> FPS

;2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;Exchange the top two cell pairs.
;==> FPS

;: ( C: "<spac2es>name" -- colon-sys )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name, called a colon definition. Enter compilation state and
;start the current definition, producing colon-sys. Append the initiation
;semantics given below to the current definition.
;The execution semantics of name will be determined by the words compiled into
;the body of the definition. The current definition shall not be findable in the
;dictionary until it is ended (or until the execution of DOES> in some systems).
;Initiation: ( i*x -- i*x )  ( R:  -- nest-sys )
;Save implementation-dependent information nest-sys about the calling
;definition. The stack effects i*x represent arguments to name.
;name Execution: ( i*x -- j*x )
;Execute the definition name. The stack effects i*x and j*x represent arguments
;to and results from name, respectively.
;==> FUDICT

;; 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys -- )
;Append the run-time semantics below to the current definition. End the current
;definition, allow it to be found in the dictionary and enter interpretation
;state, consuming colon-sys. If the data-space pointer is not aligned, reserve
;enough data space to align it.
;Run-time: ( -- ) ( R: nest-sys -- )
;Return to the calling definition specified by nest-sys.
;==> FUDICT

;Word: < ( n1 n2 -- flag )
;flag is true if and only if n1 is less than n2.
IF_LESS_THAN			REGULAR
CF_LESS_THAN			EQU	*
				CLRA					;FALSE -> A
				LDX	2,Y+ 				;n2 -> X
				CPX	0,Y 				;compare
				BLE	CF_LESS_THAN_1 			;n2 <= n1
				COMA					;TRUE  -> A
CF_LESS_THAN_1			TAB					;flag  -> D
   				STD	0,Y				;D-> PS
				RTS
	
;<# ( -- )
;Initialize the pictured numeric output conversion process.
;==> FPAD
	
;Word: = ( x1 x2 -- flag )
;flag is true if and only if x1 is bit-for-bit the same as x2.
;S12CForth implementation details:
IF_EQUALS			REGULAR
CF_EQUALS			EQU	*
				CLRA					;FALSE -> A
				LDX	2,Y+ 				;x2 -> X
				CPX	0,Y 				;compare
				BNE	CF_EQUALS_1 			;x2 != x1
				COMA					;TRUE  -> A
CF_EQUALS_1			TAB					;flag  -> D
   				STD	0,Y				;D-> PS
				RTS

;Word: > ( n1 n2 -- flag )
;flag is true if and only if n1 is greater than n2.
IF_GREATER_THAN			REGULAR
CF_GREATER_THAN			EQU	*
				CLRA					;FALSE -> A
				LDX	2,Y+ 				;n2 -> X
				CPX	0,Y 				;compare
				BGE	CF_GREATER_THAN_1 		;n2 >= n1
				COMA					;TRUE  -> A
CF_GREATER_THAN_1		TAB					;flag  -> D
   				STD	0,Y				;D-> PS
				RTS

;>BODY ( xt -- a-addr )
;a-addr is the data-field address corresponding to xt. An ambiguous condition
;exists if xt is not for a word defined via CREATE.
;CF_TO_BODY			PS_CHECK_UF	1			;check for underflow
;				;Check CFA (PSP in Y)
;				LDX	0,Y 	;CFA -> X
;				SSTACK_JOBSR	FCORE_TO_BODY
;				TBEQ	X, CF_TO_BODY_NONCREATE 	;error
;				STX	0,Y
;				;Done 	
;				NEXT

;>IN ( -- a-addr )
;a-addr is the address of a cell containing the offset in characters from the
;start of the input buffer to the start of the parse area.
;==> FOUTER 

;>NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 )
;ud2 is the unsigned result of converting the characters within the string
;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;left-to-right until a character that is not convertible, including any + or -,
;is encountered or the string is entirely converted. c-addr2 is the location of
;the first unconverted character or the first character past the end of the
;string if the string was entirely converted. u2 is the number of unconverted
;characters in the string. An ambiguous condition exists if ud2 overflows during
;the conversion. 
;CF_TO_NUMBER			PS_CHECK_UF	4		;(PSP -> Y)
;				;Allocate temporary memory (PSP in Y)
;				SSTACK_ALLOC	10
;				MOVW	BASE, 0,SP
;				MOVW	2,Y,  2,SP
;				MOVW	4,Y,  4,SP
;				MOVW	6,Y,  6,SP
;				MOVW	0,Y, 10,SP
;				;Convert to number
;				SSTACK_JOBSR	FCORE_TO_NUMBER
;				;Return results
;				LDY	PSP
;				MOVW	2,SP,  2,Y
;				MOVW	4,SP,  4,Y
;				MOVW	6,SP,  6,Y
;				MOVW   10,SP,  0,Y
;				;Deallocate temporary memory
;				SSTACK_DEALLOC	10
;				;Done
;				NEXT
;
;>R
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( x -- ) ( R:  -- x )
;Move x to the return stack.
;==> FRS

;?DUP ( x -- 0 | x x )
;Duplicate x if it is non-zero.
;==> FPS

;Word: @ ( a-addr -- x )
;x is the value stored at a-addr.
IF_FETCH			INLINE	CF_FETCH
CF_FETCH			EQU	*
				LDD	[0,Y] 		;x -> D
				STD	0,Y		;x -? PS
CF_FETCH_EOI			RTS				

;ABORT ( i*x -- ) ( R: j*x -- )
;Empty the data stack and perform the function of QUIT, which includes emptying
;the return stack, without displaying a message.
;==> FEXCPT 

;;ABORT" 
;;Interpretation: Interpretation semantics for this word are undefined.
;;Compilation: ( "ccc<quote>" -- )
;;Parse ccc delimited by a " (double-quote). Append the run-time semantics given
;;below to the current definition.
;;Run-time: ( i*x x1 --  | i*x ) ( R: j*x --  | j*x )
;;Remove x1 from the stack. If any bit of x1 is not zero, display ccc and perform
;;an implementation-defined abort sequence that includes the function of ABORT.
;==> FEXCPT 
			
;Word: ABS ( n -- u )
;u is the absolute value of n.
IF_ABS				REGULAR
CF_ABS				EQU	*
				LDD	0,Y 		;n -> D
				BPL	CF_ABS_1	;n == u
				COMA			;negate n
				COMB			;
				ADDD	#1		;
				STD	0,Y 		;u -> PS
CF_ABS_1			RTS			;done
				EQU	CF_ABS_1
	
;ACCEPT ( c-addr +n1 -- +n2 )
;Receive a string of at most +n1 characters. An ambiguous condition exists if
;+n1 is zero or greater than 32,767. Display graphic characters as they are
;received. A program that depends on the presence or absence of non-graphic
;characters in the string has an environmental dependency. The editing
;functions, if any, that the system performs in order to construct the string
;are implementation-defined.
;Input terminates when an implementation-defined line terminator is received.
;When input terminates, nothing is appended to the string, and the display is
;maintained in an implementation-defined way.
;+n2 is the length of the string stored at c-addr.
;CF_ACCEPT			PS_CHECK_UF	2			;PSP -> Y
;				;Parse command line (PSP in Y)
;				LDD	0,Y
;				BMI	CF_ACCEPT_INVALNUM 		;+n1 is negative			
;				LDX	2,Y
;				SSTACK_JOBSR	FCORE_ACCEPT
;				TBNE	X, CF_ACCEPT_COMERR
;				;Stack result (+n2 in D, PSP in Y)
;				STD	2,+Y
;				STY	PSP
;				;Done
;				NEXT

;ALIGN ( -- )
;If the data-space pointer is not aligned, reserve enough space to align it.
;==> FNVDICT
	
;Word: ALIGNED ( addr -- a-addr )
IF_ALIGNED			INLINE	CF_ALIGNED
CF_ALIGNED			EQU	*
				LDD	#$0001
				ADDD	0,Y
				ANDB	#$FE
				STD	0,Y
CF_ALIGNED_EOI			RTS
	
;ALLOT ( n -- )
;If n is greater than zero, reserve n address units of data space. If n is less
;than zero, release |n| address units of data space. If n is zero, leave the
;data-space pointer unchanged.
;If the data-space pointer is aligned and n is a multiple of the size of a cell
;when ALLOT begins execution, it will remain aligned when ALLOT finishes
;execution.
;If the data-space pointer is character aligned and n is a multiple of the size
;of a character when ALLOT begins execution, it will remain character aligned
;when ALLOT finishes execution.
;==> FNVDICT
	
;Word: AND ( x1 x2 -- x3 )
;x3 is the bit-by-bit logical and of x1 with x2.
IF_AND				INLINE	CF_AND
CF_AND				EQU	*
				LDD	2,Y+ 			;x2 -> D
				ANDA	0,Y			;x1 & x2 -> D
				ANDB	1,Y			;
				STD	0,Y 			;x3 -> PS
CF_AND_EOI			RTS				;done
	
;BASE ( -- a-addr )
;a-addr is the address of a cell containing the current number-conversion radix
;{{2...36}}.
;==> FOUTER
	
;BEGIN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- dest )
;Put the next location for a transfer of control, dest, onto the control flow
;stack. Append the run-time semantics given below to the current definition.
;Run-time: ( -- )
;Continue execution.
;==> FUDICT
	
;Word: BL ( -- char )
;char is the character value for a space.
IF_BL				INLINE	CF_BL
CF_BL				EQU	*
				MOVW	#" ", 2,-Y 	;SPACE char -> PS
CF_BL_EOI			RTS
	
;Word: C! ( char c-addr -- )
;Store char at c-addr. When character size is smaller than cell size, only the
;number of low-order bits corresponding to character size are transferred.
IF_C_STORE			INLINE	CF_C_STORE
CF_C_STORE			EQU	*
				LDX	3,Y+			;x -> c-addr
				MOVB	1,Y+, 0,X
CF_C_STORE_EOI			RTS

;C, ( char -- )
;Reserve space for one character in the data space and store char in the space.
;If the data-space pointer is character aligned when C, begins execution, it
;will remain character aligned when C, finishes execution. An ambiguous
;condition exists if the data-space pointer is not character-aligned prior to
;execution of C,.
;==> FNVDICT

;Word: C@ ( c-addr -- char )
;Fetch the character stored at c-addr. When the cell size is greater than
;character size, the unused high-order bits are all zeroes.
IF_C_FETCH			INLINE	CF_C_FETCH
CF_C_FETCH			EQU	*
				LDX	0,Y			;c-addr -> X
				CLR	0,Y
				MOVB	0,X, 1,Y
CF_C_FETCH_EOI			RTS

;Word: CELL+ 	( a-addr1 -- a-addr2 )
;Add the size in address units of a cell to a-addr1, giving a-addr2.
IF_CELL_PLUS			INLINE	CF_CELL_PLUS
CF_CELL_PLUS			EQU	*
				LDX	0,Y
				LEAX	2,X
				STX	0,Y
CF_CELL_PLUS_EOI		RTS
	
;Word: CELLS ( n1 -- n2 )
;n2 is the size in address units of n1 cells.
IF_CELLS			INLINE	CF_CELLS
CF_CELLS			EQU	*
				LDD	0,Y
				LSLD
				STD	0,Y
CF_CELLS_EOI			RTS
	
;CHAR 	( "<SPACES>NAME" -- char )
;Skip leading space delimiters. Parse name delimited by a space. Put the value
;of its first character onto the stack.
;CF_CHAR			PS_CHECK_OF	1			;(PSP-2 -> Y)
;				;Parse word (new PSP in Y)
;				SSTACK_JOBSR	FCORE_WORD 	;string pointer -> X (SSTACK: 4 bytes)
;				CLRB
;				TBEQ	X, CF_CHAR_1 		;empty string
;				;Put char onto stack (new PSP in Y)
;				LDAB	0,X
;CF_CHAR_1			CLRA
;				STD	0,Y
;				STY	PSP
;				;Done
;				NEXT
	
;Word: CHAR+ ( c-addr1 -- c-addr2 )
;Add the size in address units of a character to c-addr1, giving c-addr2.
IF_CHAR_PLUS			INLINE	CF_CHAR_PLUS
CF_CHAR_PLUS			EQU	*
				LDX	0,Y
				INX
				STX	0,Y
CF_CHAR_PLUS_EOI		RTS

;Word: CHARS ( n1 -- n2 )
;n2 is the size in address units of n1 characters.
IF_CHARS			INLINE	CF_CHARS
CF_CHARS			EQU	*
CF_CHARS_EOI			RTS

;Word: CLS ( -- empty ) S12CForth extension!
;Empty the parameter stack.
IF_CLS				INLINE	CF_CLS
CF_CLS				EQU	*
				LDY	#PS_EMPTY
CF_CLS_EOI			RTS

;CONSTANT ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a constant.
;name Execution: ( -- x )
;Place x on the stack.
;==> FUDICT
                                                
;Word: COUNT ( c-addr1 -- c-addr2 u )
;Return the character string specification for the counted string stored at
;c-addr1. c-addr2 is the address of the first character after c-addr1. u is the
;contents of the character at c-addr1, which is the length in characters of the
;string at c-addr2.
IF_COUNT			REGULAR
CF_COUNT			EQU	*
				LDX	0,Y 				;c-addr1 -> X
				LDAB	1,X+ 				;u       -> B
				CLRA 					;u       -> D
				STX	0,Y 				;c-addr2 -> PS	
				STD	2,-Y 				;u       -> PS
				RTS 					;done
	
;CR ( -- )
;Cause subsequent output to appear at the beginning of the next line.
;==> FOUTER

;CREATE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. If the
;data-space pointer is not aligned, reserve enough data space to align it. The
;new data-space pointer defines name's data field. CREATE does not allocate data
;space in name's data field.
;name Execution: ( -- a-addr )
;a-addr is the address of name's data field. The execution semantics of name may
;be extended by using DOES>.
;CF_CREATE			;Build header
;				SSTACK_JOBSR	FCORE_HEADER ;NFA -> D, error handler -> X (SSTACK: 10  bytes)
;				TBNE	X, CF_CREATE_ERROR
;				;Update LAST_NFA 
;				STD	LAST_NFA
;				;Append CFA 
;				LDX	CP
;				MOVW	#CF_CREATE_RT, 2,X+
;				;Append default (no) init pointer
;				MOVW	#$0000, 2,X+
;				STX	CP
;				;Update CP saved (CP in X)
;				STX	CP_SAVED
;				;Done 
;				NEXT
;				;Error handler for FCORE_HEADER 
;CF_CREATE_ERROR		JMP	0,X
;
;CREATE run-time semantics
;Push the address of the second cell after the CFA onto the parameter stack
;CF_CREATE_RT			PS_CHECK_OF	1			;overflow check	=> 9 cycles
;				LEAX		4,X			;CFA+4 -> PS	=> 2 cycles
;				STX		0,Y			;		=> 3 cycles
;				STY		PSP			;		=> 3 cycles
;				LDX		-2,X			;new CFA -> X	=> 3 cycles
;				BEQ		CF_CREATE_RT_1		;no init code	=> 1 cycles/3 cycle
;				RS_PUSH_KEEP_X	IP			;IP -> RS	=>20 cycles
;				LEAY		2,X			;IP+2 -> IP	=> 2 cycles
;				STY		IP			;		=> 3 cycles
;				LDX		0,X			;JUMP [new CFA]	=> 3 cycles
;				JMP		[0,X]			;               => 6 cycles
;									;                 ---------
;									;                 52 cycles
;CF_CREATE_RT_1			NEXT					;NEXT
	
;Word: DECIMAL ( -- )
;Set the numeric conversion radix to ten (decimal).
IF_DECIMAL			INLINE	CF_DECIMAL
CF_DECIMAL			EQU	*
				MOVW	#10, BASE
CF_DECIMAL_EOI			RTS

;Word: DEPTH ( -- +n )
;+n is the number of single-cell values contained in the data stack before +n
;was placed on the stack.
IF_DEPTH			INLINE	CF_DEPTH
CF_DEPTH			EQU	*
				LEAX	-PS_EMPTY,Y 			;+n -> X
				STX	2,-Y 				;+n -> PS
CF_DEPTH_EOI			RTS 					;done

;DO
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
;==> FUDICT

;DOES>
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys1 -- colon-sys2 )
;Append the run-time semantics below to the current definition. Whether or not
;the current definition is rendered findable in the dictionary by the
;compilation of DOES> is implementation defined. Consume colon-sys1 and produce
;colon-sys2. Append the initiation semantics given below to the current
;definition.
;Run-time: ( -- ) ( R: nest-sys1 -- )
;Replace the execution semantics of the most recent definition, referred to as
;name, with the name execution semantics given below. Return control to the
;calling definition specified by nest-sys1. An ambiguous condition exists if
;name was not defined with CREATE or a user-defined word that calls CREATE.
;Initiation: ( i*x -- i*x a-addr ) ( R:  -- nest-sys2 )
;Save implementation-dependent information nest-sys2 about the calling
;definition. Place name's data field address on the stack. The stack effects i*x
;represent arguments to name.
;name Execution: ( i*x -- j*x )
;Execute the portion of the definition that begins with the initiation semantics
;appended by the DOES> which modified name. The stack effects i*x and j*x
;represent arguments to and results from name, respectively.
;CF_DOES			COMPILE_ONLY	CF_DOES_COMPONLY 	;ensure that compile mode is on
;				DICT_CHECK_OF	2, CF_DOES_DICTOF	;(CP+2 -> X)
;				MOVW	#CFA_DOES_RT, -2,X
;				STX	CP
;				NEXT
;				
;CF_DOES_COMPONLY		JOB	FCORE_THROW_COMPONLY
;CF_DOES_DICTOF			JOB	FCORE_THROW_DICTOF
;CF_DOES_NONCREATE		JOB	FCORE_THROW_NONCREATE
;
;;DOES> run-time semantics
;CF_DOES_RT			LDY	LAST_NFA
;				LDAA	2,Y
;				LEAY	A,Y
;				LEAY	3,Y
;				LDD	2,Y+
;				CPD	CFA_CREATE_RT
;				BNE	CF_DOES_NONCREATE	;last word was not defined by CREATE
;				MOVW	IP, 0,Y			;add initialization code to CREATEd word
;				JOB	CF_EXIT_RT

;DROP ( x -- )
;Remove x from the stack.
;==> FPS
	
;DUP ( x -- x x )
;Duplicate x.
;==> FPS

;ELSE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig1 -- orig2 )
;Put the location of a new unresolved forward reference orig2 onto the control
;flow stack. Append the run-time semantics given below to the current
;definition. The semantics will be incomplete until orig2 is resolved
;(e.g., by THEN). Resolve the forward reference orig1 using the location
;following the appended run-time semantics.
;Run-time: ( -- )
;Continue execution at the location given by the resolution of orig2.
;==> FUDICT

;Word: EMIT ( x -- )
;If x is a graphic character in the implementation-defined character set,
;display x. The effect of EMIT for all other values of x is
;implementation-defined.
;When passed a character whose character-defining bits have a value between hex
;20 and 7E inclusive, the corresponding standard character, specified by 3.1.2.1
;Graphic characters, is displayed. Because different output devices can respond
;differently to control characters, programs that use control characters to
;perform specific functions have an environmental dependency. Each EMIT deals
;with only one character.
IF_EMIT				REGULAR
CF_EMIT				EQU	*
				LDD	2,Y+
				JOB	FCORE_TX_CHAR

;ENVIRONMENT? ( c-addr u -- false | i*x true )
;c-addr is the address of a character string and u is the string's character
;count. u may have a value in the range from zero to an implementation-defined
;maximum which shall not be less than 31. The character string should contain a
;keyword from 3.2.6 Environmental queries or the optional word sets to be
;checked for correspondence with an attribute of the present environment. If the
;system treats the attribute as unknown, the returned flag is false; otherwise,
;the flag is true and the i*x returned is of the type specified in the table for
;the attribute queried.
;==> FENV

;EVALUATE ( i*x c-addr u -- j*x )
;Save the current input source specification. Store minus-one (-1) in SOURCE-ID
;if it is present. Make the string described by c-addr and u both the input
;source and input buffer, set >IN to zero, and interpret. When the parse area is
;empty, restore the prior input source specification. Other stack effects are
;due to the words EVALUATEd.

;Word: EXECUTE ( i*x xt -- j*x )
;Remove xt from the stack and perform the semantics identified by it. Other
;stack effects are due to the word EXECUTEd.
IF_EXECUTE			REGULAR
CF_EXECUTE			EQU	*
				LDX	2,Y+
				JMP	0,X
	
;EXIT
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: nest-sys -- )
;Return control to the calling definition specified by nest-sys. Before
;executing EXIT within a do-loop, a program shall discard the loop-control
;parameters by executing UNLOOP.
;CF_EXIT			COMPILE_ONLY	CF_EXIT_COMPONLY 	;ensure that compile mode is on
;				DICT_CHECK_OF	2, CF_EXIT_DICTOF	;(CP+2 -> X)
;				;Append CFA (CP+2 in X)
;				MOVW	#CFA_EXIT_RT, -2,X
;				STX	CP
;				;Done 
;				NEXT
;			
;;EXIT run-time semantics
;CF_EXIT_RT			RS_PULL_Y				;RS -> Y (= IP)		=>12 cycles
;				LDX		2,Y+			;IP += 2, CFA -> X	=> 3 cycles
;				STY		IP 			;			=> 3 cycles 
;				JMP		[0,X]			;JUMP [CFA]             => 6 cycles
;								;                         ---------
;								;                         24 cycles			
	
;Word: FILL ( c-addr u char -- )
;If u is greater than zero, store char in each of u consecutive characters of
;memory beginning at c-addr.
IF_FILL				REGULAR
CF_FILL				EQU	*
				LDD	2,Y 			;u -> D
				BEQ	CF_FILL_2		;u is zero
				LDX	4,Y			;c-addre -> X
CF_FILL_1			MOVB	1,Y, 1,X+		;fill byte
				DBNE	D, CF_FILL_1		;loop
CF_FILL_2			LEAY	6,Y			;clean up PS
				RTS				;dome

;FIND ( c-addr -- c-addr 0  |  xt 1  |  xt -1 )
;Find the definition named in the counted string at c-addr. If the definition is
;not found, return c-addr and zero. If the definition is found, return its
;execution token xt. If the definition is immediate, also return one (1),
;otherwise also return minus-one (-1). For a given string, the values returned
;by FIND while compiling may differ from those returned while not compiling.
;CF_FIND		 	PS_CHECK_UFOF	1, 1		;check for over and underflow (PSP-2 -> Y)
;				;Search dictionary (PSP-2 -> Y)
;				LDX	2,Y
;				SSTACK_JOBSR	FCORE_FIND
;				STX	2,Y
;				STD	0,Y
;				STY	PSP
;				;Done 
;				NEXT
		 	
;FM/MOD ( d1 n1 -- n2 n3 )
;Divide d1 by n1, giving the floored quotient n3 and the remainder n2. Input and
;output stack arguments are signed. An ambiguous condition exists if n1 is zero
;or if the quotient lies outside the range of a single-cell signed integer.
;Floored Division Example:
;Dividend Divisor Remainder Quotient
;   10       7        3         1
;  -10       7        4        -2
;   10      -7       -4        -2
;  -10      -7       -3         1
;CF_F_M_SLASH_MOD		PS_CHECK_UF	3, CF_F_M_SLASH_MOD_PSUF ;check for underflow  (PSP -> Y)
;				LDX	0,Y			;get divisor
;				BEQ	CF_F_M_SLASH_MOD_0DIV	;diviide by zero
;				LDD	4,Y			;get dividend
;				LDY	2,Y
;				EDIVS				;Y:D/X=>Y; remainder=>D
;				BVS	CF_F_M_SLASH_MOD_RESOR 	;result out of range
;				BPL	CF_F_M_SLASH_MOD_1	;positive result
;				TBEQ	D, CF_F_M_SLASH_MOD_1	;remainder is zero
;				;Negative result, adust quotient and remainder (quotient in Y, remainder in D)
;				DEY	 			;decrement quotient
;				ADDD	[PSP]
;				;Return result	
;CF_F_M_SLASH_MOD_1		LDX	PSP			;PSP -> X
;				STY	2,+X			;return quotient
;				STD	2,X			;return remainder
;				STX	PSP			;update PSP
;				;Done 
;				NEXT

;HERE ( -- addr )
;addr is the data-space pointer. (points to the next free data space)
;==> FNVDICT
	
;HOLD ( char -- )
;Add char to the beginning of the pictured numeric output string. An ambiguous
;condition exists if HOLD executes outside of a <# #> delimited number
;conversion.
;==> FPAD
				
;I
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- n|u ) ( R:  loop-sys -- loop-sys )
;n|u is a copy of the current (innermost) loop index. An ambiguous condition
;exists if the loop control parameters are unavailable.
;==> FUDICT
	
;IF 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- orig )
;Put the location of a new unresolved forward reference orig onto the control
;flow stack. Append the run-time semantics given below to the current
;definition. The semantics are incomplete until orig is resolved, e.g., by THEN
;or ELSE.
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by the
;resolution of orig.
;==>FUDICT
	
;IMMEDIATE ( -- )
;Make the most recent definition an immediate word. An ambiguous condition
;exists if the most recent definition does not have a name.
;CF_IMMEDIATE			LDX	LAST_NFA  		;find most recent named definition
;				BSET	2,X, #$80 		;set immediate bit
;				;Done 
;				NEXT
	
;Word: INVERT ( x1 -- x2 )
;Invert all bits of x1, giving its logical inverse x2.
IF_INVERT			INLINE	CF_INVERT
CF_INVERT			EQU	*
				LDD	0,Y
				COMA
				COMB
				STD	0,Y
CF_INVERT_EOI			RTS
	
;J
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- n|u ) ( R: loop-sys1 loop-sys2 -- loop-sys1 loop-sys2 )
;n|u is a copy of the next-outer loop index. An ambiguous condition exists if
;the loop control parameters of the next-outer loop, loop-sys1, are unavailable.
;==> FUDICT

;KEY ( -- char )
;Receive one character char, a member of the implementation-defined character
;set. Keyboard events that do not correspond to such characters are discarded
;until a valid character is received, and those events are subsequently
;unavailable.
;All standard characters can be received. Characters received by KEY are not
;displayed.
;Any standard character returned by KEY has the numeric value specified in
;3.1.2.1 Graphic characters. Programs that require the ability to receive
;control characters have an environmental dependency.
;CF_KEY				PS_CHECK_OF	1, CF_KEY_PSOF	;check for PS overflow (PSP-2 cells -> Y)
;				;Wait for data byte
;				LED_BUSY_OFF
;				SSTACK_JOBSR	FCORE_KEY       ;(SSTACK: 8 bytes)
;				LED_BUSY_ON
;				;Check for transmission errors (char in D, PSP in Y, error code in X)
;				TBNE	X, CF_KEY_COMMERR
; 				;Put received character onto the stack (char in B, PSP in Y)
;				STD	0,Y
;				STY	PSP
;				NEXT
;

;LEAVE
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the current loop control parameters. An ambiguous condition exists if
;they are unavailable. Continue execution immediately following the innermost
;syntactically enclosing DO ... LOOP or DO ... +LOOP.
;==> FUDICT
	
;LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x -- )
;Append the run-time semantics given below to the current definition.
;Run-time: ( -- x )
;Place x on the stack.
;==> FUDICT

;LOOP
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
;==> FUDICT
	
;Word: LSHIFT ( x1 u -- x2 )
;Perform a logical left shift of u bit-places on x1, giving x2. Put zeroes into
;the least significant bits vacated by the shift. An ambiguous condition exists
;if u is greater than or equal to the number of bits in a cell.
IF_L_SHIFT			REGULAR
CF_L_SHIFT			EQU	*
				LDX	2,Y+ 				;u -> X
				BEQ	CF_L_SHIFT_2 			;done
				LDD	0,Y 				;x1 -> D
CF_L_SHIFT_1			LSLD 					;D << 1 -> D
				DBNE	X, CF_L_SHIFT_1			;repeat u times
				STD	0,Y 				;x2 -> PS
CF_L_SHIFT_2			RTS 					;done
	
;Word: M* ( n1 n2 -- d )
;d is the signed product of n1 times n2.
IF_M_STAR			REGULAR
CF_M_STAR			EQU	*
				LDD	0,Y 			;n2    -> D	
				TFR	Y, X 			;save PSP
				SEI 				;start of atomic sequence
				LDY	2,Y			;n1    -> Y
				EMULS	   			;Y * D -> Y:D
				EXG	Y, X			;restore PSP
				CLI				;end of atomic sequence
				STD	2,Y			;D -> PS
				STX	0,Y			;
				RTS				;done

;Word: MAX ( n1 n2 -- n3 )
;n3 is the greater of n1 and n2.
IF_MAX				REGULAR	
CF_MAX				EQU	*
				LDD	2,Y+ 				;n2 -> D
				CPD	0,Y 				;compare
				BLE	CF_MAX_1 			;n2 <= n1
				STD	0,Y 				;n2 -> n3
CF_MAX_1			RTS
	
;Word: MIN ( n1 n2 -- n3 )
;n3 is the lesser of n1 and n2.
IF_MIN				REGULAR	
CF_MIN				EQU	*
				LDD	2,Y+ 				;n2 -> D
				CPD	0,Y 				;compare
				BGE	CF_MIN_1 			;n2 >= n1
				STD	0,Y 				;n2 -> n3
CF_MIN_1			RTS
	
;Word: MOD ( n1 n2 -- n3 )
;Divide n1 by n2, giving the single-cell remainder n3. An ambiguous condition
;exists if n2 is zero. If n1 and n2 differ in sign, the implementation-defined
;result returned will be the same as that returned by either the phrase
;>R S>D R> FM/MOD DROP or the phrase >R S>D R> SM/REM DROP.
IF_MOD				REGULAR
CF_MOD				EQU	*
				JOBSR	CF_SLASH_MOD 			;/MOD
				LEAY	2,Y 				;remove n4
				RTS 					;done

;Word: MOVE ( addr1 addr2 u -- )
;If u is grater than zero, copy the contents of u consecutive address units at
;addr1 to the u consecutive address units at addr2. After MOVE completes, the u
;consecutive address units at addr2 contain exactly what the u consecutive
;address units at addr1 contained before the move.
;==>FUDICT
	
;Word: NEGATE ( n1 -- n2 )
;Negate n1, giving its arithmetic inverse n2.
IF_NEGATE			INLINE	CF_NEGATE
CF_NEGATE			EQU	*
				LDD	0,Y
				COMA
				COMB
				ADDD	#1
				STD	0,Y
CF_NEGATE_EOI			RTS
	
;Word: OR ( x1 x2 -- x3 )
;x3 is the bit-by-bit inclusive-or of x1 with x2.
IF_OR				INLINE	CF_OR
CF_OR				EQU	*
				LDD	2,Y+
				ORAA	0,Y
				ORAB	1,Y
				STD	0,Y
CF_OR_EOI			RTS
	
;OVER ( x1 x2 -- x1 x2 x1 )
;Place a copy of x1 on top of the stack.
;==> FPS

;POSTPONE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Find name.
;Append the compilation semantics of name to the current definition. An
;ambiguous condition exists if name is not found.
;CF_POSTPONE		COMPILE_ONLY	CF_POSTPONE_COMPONLY 	;ensure that compile mode is on
;			DICT_CHECK_OF	2, CF_POSTPONE_DICTOF	;(CP+2 -> X)
;			;Parse name (CP+2 -> X)
;			TFR	X, Y
;			SSTACK_JOBSR	FCORE_NAME 		;string pointer -> X
;			TBEQ	X, CF_POSTPONE_NONAME
;			;Search dictionary (string pointer in X, CF+2 in Y)
;			SSTACK_JOBSR	FCORE_FIND 		;CFA -> X, status -> D
;			TBEQ	D, CF_POSTPONE_UDEFWORD
;			;Compile CFA
;			STX	-2,Y
;			STY	CP
;			;Done
;			NEXT

;QUIT ( -- )  ( R:  i*x -- )
;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;input device the input source, and enter interpretation state. Do not display a
;message. Repeat the following:
;Accept a line from the input source into the input buffer, set >IN to zero, and
;interpret.
;Display the implementation-defined system prompt if in interpretation state,
;all processing has been completed, and no ambiguous condition exists.
;==> FEXCPT
	
;R> 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x ) ( R:  x -- )
;Move x from the return stack to the data stack.
;CF_R_FROM		RS_CHECK_UF 	1		;check for RS underflow (RSP -> X)
;			PS_CHECK_OF	1		;check for PS overflow (PSP-2 -> Y)
;			;LDX	RSP
;			MOVW	2,X+, 0,Y
;			STX	RSP
;			STY	PSP
;			NEXT
	
;R@ 
;r-fetch CORE 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x ) ( R:  x -- x )
;Copy x from the return stack to the data stack.
;CF_R_FETCH		RS_CHECK_UF 	1		;check for RS underflow (RSP -> X)
;			PS_CHECK_OF	1		;check for PS overflow (PSP-2 -> Y)
;			;LDX	RSP
;			MOVW	0,X, 0,Y
;			STY	PSP
;			NEXT
	
;RECURSE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( -- )
;Append the execution semantics of the current definition to the current
;definition. An ambiguous condition exists if RECURSE appears in a definition
;after DOES>.
;CF_RECURSE		COMPILE_ONLY				;ensure that compile mode is on
;			PS_CHECK_UF	1			;(PSP -> Y)
;			DICT_CHECK_OF	2			;(CP+2 -> X)
;			;Check the parameter stack (PSP in Y, CP+2 in X)
;			LDD	0,Y
;			BNE	CF_RECURSE_1 			;named compilation
;			;:NONAME compilation (PSP in Y, CP+2 in X)	
;			PS_CHECK_UF	2			;(PSP -> Y)
;			LDD	2,Y
;			;Named compilation (PSP in Y, CP+2 in X, xt in D)
;CF_RECURSE_1		STD	0,X
;			STX	CP
;			;Done
;			NEXT
	
;REPEAT 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest. Resolve the forward reference orig using the
;location following the appended run-time semantics.
;Run-time: ( -- )
;Continue execution at the location given by dest.
;==> FUDICT

;ROT ( x1 x2 x3 -- x2 x3 x1 )
;Rotate the top three stack entries.
;==> FPS

;Word: RSHIFT ( x1 u -- x2 )
;Perform a logical right shift of u bit-places on x1, giving x2. Put zeroes into
;the most significant bits vacated by the shift. An ambiguous condition exists
;if u is greater than or equal to the number of bits in a cell.
IF_R_SHIFT			REGULAR
CF_R_SHIFT			EQU	*
				LDX	2,Y+ 				;u -> X
				BEQ	CF_R_SHIFT_2 			;done
				LDD	0,Y 				;x1 -> D
CF_R_SHIFT_1			LSRD 					;D >> 1 -> D
				DBNE	X, CF_R_SHIFT_1			;repeat u times
				STD	0,Y 				;x2 -> PS
CF_R_SHIFT_2			RTS 					;done
				EQU	CF_R_SHIFT_2

;S"
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote). Append the run-time semantics given
;below to the current definition.
;Run-time: ( -- c-addr u )
;Return c-addr and u describing a string consisting of the characters ccc. A
;program shall not alter the returned string.
;CF_S_QUOTE			COMPILE_ONLY				;ensure that compile mode is on
;				;Parse quote
;				LDAA	#$22 				;double quote
;				SSTACK_JOBSR	FCORE_PARSE		;string pointer -> X, character count -> A
;				TBEQ	X, CF_S_QUOTE_2 		;empty quote		
;				;Check remaining space in dictionary (string pointer in X, character count in A)
;				IBEQ	A, CF_S_QUOTE_STROF		;add CFA to count
;				TAB
;				CLRA
;				ADDD	#1
;				TFR	X, Y
;				DICT_CHECK_OF_D				;check for dictionary overflow
;				;Append run-time CFA (string pointer in Y)
;				LDX	CP
;				MOVW	#CFA_S_QUOTE_RT, 2,X+
;				;Append quote (CP in X, string pointer in Y)
;				CPSTR_Y_TO_X
;CF_S_QUOTE_1			STX	CP
;				;Done
;				NEXT
;				;Empty string
;CF_S_QUOTE_2			DICT_CHECK_OF	6			;check for dictionary overflow
;				MOVW	#CFA_TWO_LITERAL_RT, -6,X 	;add CFA
;				MOVW	#$0000, 	-2,X 		;zero pointer
;				MOVW	#$0000, 	-2,X 		;zero count
;				JOB	CF_S_QUOTE_1
;
;S" run-time semantics
;CF_S_QUOTE_RT			PS_CHECK_OF	2			;check for PS overflow (PSP-4 -> Y)
;				;Push string pointer onto PS (PSP-4 in Y)
;				LDX	IP
;				STX	2,Y
;				;Count characters (PSP-4 in Y, string pointer in X)
;				PRINT_STRCNT
;				;Adjust IP (PSP-4 in Y, string pointer in X, char count in A)
;				LEAX	A,X
;				STX	IP
;				;Push character count onto PS (PSP-4 in Y, char count in A)
;				EXG	A, D
;				STD	0,Y
;				STY	PSP
;				;Done
;				NEXT
	
;Word: S>D ( n -- d )
;Convert the number n to the double-cell number d with the same numerical value.
IF_S_TO_D			INLINE	CF_S_TO_D		
CF_S_TO_D			EQU	*
				LDAB	0,Y
				SEX	B, D
				TAB
				STD	2,-Y
CF_S_TO_D_EOI			RTS
	
;SIGN ( n -- )
;If n is negative, add a minus sign to the beginning of the pictured numeric
;output string. An ambiguous condition exists if SIGN executes outside of a
;<# #> delimited number conversion.
;CF_SIGN			PS_CHECK_UF	1		;check for underflow	(PSP -> Y)
;				PAD_CHECK_OF			;check for PAD overvlow (HLD -> X)
;				;Add sign character to the PAD buffer
;				LDD	2,Y+
;				BPL	CF_SIGN_1
;				MOVB	#"-", 1,-X
;				STX	HLD
;CF_SIGN_1			STY	PSP
;				NEXT
	
;Word: SM/REM ( d1 n1 -- n2 n3 )
;Divide d1 by n1, giving the symmetric quotient n3 and the remainder n2. Input
;and output stack arguments are signed. An ambiguous condition exists if n1 is
;zero or if the quotient lies outside the range of a single-cell signed integer.
;Symmetric Division Example:
;Dividend Divisor Remainder Quotient
;   10       7        3         1
;  -10       7       -3        -1
;   10      -7        3        -1
;  -10      -7       -3         1
IF_S_M_SLASH_REM		REGULAR
CF_S_M_SLASH_REM		EQU	*
				LDX	2,Y+			;n1      -> X
				;BEQ	CF_S_M_SLASH_REM_1	;diviide by zero
				LDD	2,Y 			;d1(LSW) -> D
				PSHY				;save PSP
				SEI 				;start of atomic sequence
				LDY	0,Y			;d1(MSW) -> Y
				EDIVS	   			;Y:D / X -> Y remainder -> D
				TFR	Y, X			;n5 -> X
				PULY				;restore PSP
				CLI				;end of atomic sequence
				BCS	CF_S_M_SLASH_REM_1	;division by zero
				BVS	CF_S_M_SLASH_REM_2	;result out of range
				STD	2,Y			;n2 -> PS
				STX	0,Y			;n3 -> PS
				RTS				;done
CF_S_M_SLASH_REM_1		THROW	FEXCPT_TC_0DIV		;division by zero
CF_S_M_SLASH_REM_2		THROW	FEXCPT_TC_RESOR		;result out of range

;SOURCE ( -- c-addr u )
;c-addr is the address of, and u is the number of characters in, the input
;buffer.
;==> FOUTER
	
;SPACE ( -- )
;Display one space.
;==> FOUTER
	
;SPACES ( n -- )
;If n is greater than zero, display n spaces.
;==> FDOT
	
;STATE ( -- a-addr )
;a-addr is the address of a cell containing the compilation-state flag. STATE is
;true when in compilation state, false otherwise. The true value in STATE is
;non-zero, but is otherwise implementation-defined. Only the following standard
;words alter the value in STATE: : (colon), ; (semicolon), ABORT, QUIT, :NONAME,
;[ (left-bracket), and ] (right-bracket).
;Note: A program shall not directly alter the contents of STATE.
;==> FOUTER
	
;SWAP ( x1 x2 -- x2 x1 )
;Exchange the top two stack items.
;==> FPS

;THEN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig -- )
;Append the run-time semantics given below to the current definition. Resolve
;the forward reference orig using the location of the appended run-time
;semantics.
;Run-time: ( -- )
;Continue execution.
;==> FUDICT

;TYPE ( c-addr u -- )
;If u is greater than zero, display the character string specified by c-addr and
;u.
;When passed a character in a character string whose character-defining bits
;have a value between hex 20 and 7E inclusive, the corresponding standard
;character, specified by 3.1.2.1 graphic characters, is displayed. Because
;different output devices can respond differently to control characters,
;programs that use control characters to perform specific functions have an
;environmental dependency.
;CF_TYPE			PS_CHECK_UF	2		;check for underflow (PSP -> Y)
;				;Pull args from PS
;				LEAY	4,Y
;				STY	PSP
;				LDX	-2,Y			;c-addr -> X
;				LDY	-4,Y			;u -> Y
;				BEQ	CF_TYPE_3		;done
;				;Print string
;CF_TYPE_1			LDAB	1,X+
;				ANDB	#$7F 			;remove termination
;				CMPB	#$20
;				BLO	CF_TYPE_2
;				CMPB	#$7E
;				BHI	CF_TYPE_2
;				PRINT_CHAR
;CF_TYPE_2			DBNE	Y, CF_TYPE_1
;				;Done
;CF_TYPE_3			NEXT
	
;U. ( u -- )
;Display u in free field format.
;==> FDOT

;Word: U< ( u1 u2 -- flag )
;flag is true if and only if u1 is less than u2.
IF_U_LESS_THAN			REGULAR
CF_U_LESS_THAN			EQU	*
				CLRA					;FALSE -> A
				LDX	2,Y+ 				;u2 -> X
				CPX	0,Y 				;compare
				BLS	CF_U_LESS_THAN_1 			;u2 <= u1
				COMA					;TRUE  -> A
CF_U_LESS_THAN_1		TAB					;flag  -> D
   				STD	0,Y				;D-> PS
				RTS

;Word: UM* ( u1 u2 -- ud )
;Multiply u1 by u2, giving the unsigned double-cell product ud. All values and
;arithmetic are unsigned.
IF_U_M_STAR			REGULAR
CF_U_M_STAR			EQU	*
				LDD	0,Y 			;u2    -> D	
				TFR	Y, X 			;save PSP
				SEI 				;start of atomic sequence
				LDY	2,Y			;u1    -> Y
				EMULS	   			;Y * D -> Y:D
				EXG	Y, X			;restore PSP
				CLI				;end of atomic sequence
				STD	2,Y			;ud -> PS
				STX	0,Y			;
				RTS

;Word: UM/MOD ( ud u1 -- u2 u3 )
;Divide ud by u1, giving the quotient u3 and the remainder u2. All values and
;arithmetic are unsigned. An ambiguous condition exists if u1 is zero or if the
;quotient lies outside the range of a single-cell unsigned integer.
IF_U_M_SLASH_MOD		REGULAR
CF_U_M_SLASH_MOD		EQU	*
				LDX	2,Y+ 			;u1      -> X
				;BEQ	CF_U_M_SLASH_MOD_1	;division by zero
				LDD	2,Y			;ud(LSW) -> D
				PSHY				;save PSP
				SEI 				;start of atomic sequence
				LDY	0,Y			;ud(MAS) -> Y
				EDIV	   			;Y:D / X -> Y remainder -> D
				TFR	Y, X			;n5 -> X
				PULY				;restore PSP
				CLI				;end of atomic sequence
				BCS	CF_U_M_SLASH_MOD_1	;division by zero
				BVS	CF_U_M_SLASH_MOD_2	;result out of range
				STD	2,Y			;n4 -> PS
				STX	0,Y			;n5 -> PS
				RTS				;done
CF_U_M_SLASH_MOD_1		THROW	FEXCPT_TC_0DIV		;division by zero
CF_U_M_SLASH_MOD_2		THROW	FEXCPT_TC_RESOR		;result out of range

;UNLOOP
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the loop-control parameters for the current nesting level. An UNLOOP is
;required for each nesting level before the definition may be EXITed. An
;ambiguous condition exists if the loop-control parameters are unavailable.
;==> FUDICT

;UNTIL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by
;dest.
;==> FUDICT
			
;VARIABLE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. Reserve one
;cell of data space at an aligned address.
;name is referred to as a variable.
;name Execution: ( -- a-addr )
;a-addr is the address of the reserved cell. A program is responsible for
;initializing the contents of the reserved cell.
;CF_VARIABLE			;Build header
;				SSTACK_JOBSR	FCORE_HEADER ;NFA -> D, error handler -> X (SSTACK: 10 bytes)
;				TBNE	X, CF_VARIABLE_ERROR
;				;Update LAST_NFA 
;				STD	LAST_NFA
;				;Append CFA 
;				LDX	CP
;				MOVW	#CF_VARIABLE_RT, 2,X+
;				;Append variable space (CP in X)
;				MOVW	#$0000, 2,X+
;				STX	CP
;				;Update CP saved (CP in X)
;				STX	CP_SAVED
;				;Done 
;				NEXT
;				;Error handler for FCORE_HEADER 
;CF_VARIABLE_ERROR		JMP	0,X
;
;;VARIABLE run-time semantics
;;Push the address of the first cell after the CFA onto the parameter stack
;CF_VARIABLE_RT			PS_CHECK_OF	1		;overflow check	=> 9 cycles
;				LEAX		2,X		;CFA+2 -> PS	=> 2 cycles
;				STX		0,Y		;		=> 3 cycles
;				STY		PSP		;		=> 3 cycles
;				NEXT				;NEXT		=>15 cycles
;								; 		  ---------
;								;		  32 cycles
	
;WHILE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- orig dest )
;Put the location of a new unresolved forward reference orig onto the control
;flow stack, under the existing dest. Append the run-time semantics given below
;to the current definition. The semantics are incomplete until orig and dest are
;resolved (e.g., by REPEAT).
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by the
;resolution of orig.
;==> FUDICT
	
;WORD ( char "<chars>ccc<char>" -- c-addr )
;Skip leading delimiters. Parse characters ccc delimited by char. An ambiguous
;condition exists if the length of the parsed string is greater than the
;implementation-defined length of a counted string.
;c-addr is the address of a transient region containing the parsed word as a
;counted string. If the parse area was empty or contained no characters other
;than the delimiter, the resulting string has a zero length. A space, not
;included in the length, follows the string. A program may replace characters
;within the string.
;Note: The requirement to follow the string with a space is obsolescent and is
;included as a concession to existing programs that use CONVERT. A program shall
;not depend on the existence of the space.
;CF_WORD			PS_CHECK_UF	1		;check for underflow
;				;Pull argument from PS (PSP in Y)
;				LDD	0,Y
;				;Parse quote (PSP in Y, char in D)
;				TBA
;				SSTACK_JOBSR	FCORE_PARSE	;skip to the starting delimiter
;				TBA
;				SSTACK_JOBSR	FCORE_PARSE	;string pointer -> X
;				STX	0,Y	
;				;Done
;				NEXT

;Word: XOR ( x1 x2 -- x3 )
;x3 is the bit-by-bit exclusive-or of x1 with x2.
IF_XOR				INLINE	CF_XOR
CF_XOR				EQU	*
				LDD	2,Y+ 			;x1 ^ x2 -> D
				EORA	0,Y
				EORB	1,Y
				STD	0,Y 			;return result
CF_XOR_EOI			RTS
	
;[ 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: Perform the execution semantics given below.
;Execution: ( -- )
;Enter interpretation state. [ is an immediate word.
;==> FUDICT

;[']
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Find name.
;Append the run-time semantics given below to the current definition.
;An ambiguous condition exists if name is not found.
;Run-time: ( -- xt )
;Place name's execution token xt on the stack. The execution token returned by
;the compiled phrase ['] X is the same value returned by ' X outside of
;compilation state.
;CF_BRACKET_TICK		COMPILE_ONLY
;				JOB		CF_POSTPONE
	
;[CHAR]
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Append the
;run-time semantics given below to the current definition.
;Run-time: ( -- char )
;Place char, the value of the first character of name, on the stack.
;CF_BRACKET_CHAR		COMPILE_ONLY	CF_CHAR
;				LDD	2,X
;				DICT_CHECK_OF	4				;(CP+4 -> X)
;				;Add run-time CFA to compilation (CP+4 in X, run-time CFA in D)
;				STD	 -4,X
;				;Parse word (CP+4 in X)
;				TFR	X, Y
;				SSTACK_JOBSR	FCORE_WORD 			;string pointer -> X (SSTACK: 4 bytes)
;				CLRB
;				TBEQ	X, CF_BRACKET_CHAR_1 			;empty string
;				;Add char to compilation (string pointer in X, CP+4 in Y)
;				LDAB	0,X
;CF_BRACKET_CHAR_1		CLRA
;				STD	-2,Y
;				STY	CP
;				;Done
;				NEXT
	
;] ( -- )
;Enter compilation state.
;==> FUDICT

;#Core extension words (CORE EXT)
; ===============================
	
;#TIB ( -- a-addr )
;a-addr is the address of a cell containing the number of characters in the
;terminal input buffer.
;Note: This word is obsolescent and is included as a concession to existing
;      implementations.
;==> FTIB
	
;.(
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<paren>" -- )
;Parse and display ccc delimited by ) (right parenthesis). .( is an immediate
;word.
;==> FUDICT
	
;.R ( n1 n2 -- )
;Display n1 right aligned in a field n2 characters wide. If the number of
;characters required to display n1 is greater than n2, all digits are displayed
;with no leading spaces in a field as wide as necessary.
;==> FDOT

;Word: 0<> ( x -- flag )
;flag is true if and only if x is not equal to zero.
IF_ZERO_NOT_EQUALS		REGULAR
CF_ZERO_NOT_EQUALS		CLRA					;FALSE -> A
				LDX	0,Y				;check x
				BEQ	CF_ZERO_NOT_EQUALS_1		;x == 0
				COMA					;TRUE  -> A
CF_ZERO_NOT_EQUALS_1		TAB					;flag  -> D
				STD	0,Y				;D-> PS
				RTS

;Word: 0> ( n -- flag )
;flag is true if and only if n is greater than zero.
IF_ZERO_GREATER			REGULAR
CF_ZERO_GREATER			EQU	*
				CLRA					;FALSE -> A
				BRSET	0,Y,#$80,CF_ZERO_GREATER_1	;n is negative
				COMA					;TRUE  -> A
CF_ZERO_GREATER_1		TAB					;flag  -> D
				STD	0,Y				;D-> PS
				RTS

;2>R
;Interpretation: Interpretation semantics for this word are undefined.
;Execution:      ( x1 x2 -- ) ( R:  -- x1 x2 )
;Transfer cell pair x1 x2 to the return stack. Semantically equivalent to
;SWAP >R >R .
;CF_TWO_TO_R			PS_CHECK_UF	2		;(PSP -> Y)
;				RS_CHECK_OF	2		;
;				;Move stack entries (PSP in Y)
;				LDX	RSP
;				MOVW	2,Y,  2,-X
;				MOVW	4,Y+, 2,-X
;				STY	PSP
;				STX	RSP
;				NEXT

;2R>
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x1 x2 ) ( R:  x1 x2 -- )
;Transfer cell pair x1 x2 from the return stack. Semantically equivalent to
;R> R> SWAP .
;CF_TWO_FROM_R			PS_CHECK_OF	2		;check for PS overflow (PSP-4 -> Y)	
;				RS_CHECK_UF	2		;(RSP -> X)
;				;Move stack entries
;				MOVW	2,X+, 0,Y
;				MOVW	2,X+, 2,Y
;				STY	PSP
;				STX	RSP
;				NEXT

;2R@
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x1 x2 ) ( R:  x1 x2 -- x1 x2 )
;Copy cell pair x1 x2 from the return stack. Semantically equivalent to
;R> R> 2DUP >R >R SWAP .
;CF_TWO_R_FETCH			PS_CHECK_OF	2		;check for PS overflow (PSP-4 -> Y)	
;				RS_CHECK_UF	2		;(RSP -> X)
;				;Move stack entries
;				MOVW	2,X+, 2,Y
;				MOVW	2,X+, 0,Y
;				STY	PSP
;				NEXT

;:NONAME ( C:  -- colon-sys )  ( S:  -- xt )
;Create an execution token xt, enter compilation state and start the current
;definition, producing colon-sys. Append the initiation semantics given below
;to the current definition.
;The execution semantics of xt will be determined by the words compiled into the
;body of the definition. This definition can be executed later by using
;xt EXECUTE.
;If the control-flow stack is implemented using the data stack, colon-sys shall
;be the topmost item on the data stack.
;Initiation: ( i*x -- i*x ) ( R:  -- nest-sys )
;Save implementation-dependent information nest-sys about the calling
;definition. The stack effects i*x represent arguments to xt.
;xt Execution: ( i*x -- j*x )
;Execute the definition specified by xt. The stack effects i*x and j*x represent
;arguments to and results from xt, respectively.
;CF_COLON_NONAME		INTERPRET_ONLY				;check for nested definition
;				PS_CHECK_OF	2			;(PSP-4 -> Y)
;				DICT_CHECK_OF	2			;(CP+2 -> X)
;				;Push xt and $0000 onto the PS (PSP-4 in Y, CP+2 -> X)
;				LDX	CP
;				STX	2,Y
;				MOVW	#$0000, 0,Y
;				STY	PSP
;				;Append CFA (CP in X)
;				MOVW	#CF_INNER, 2,X+
;				STX	CP
;				;Enter compile state 
;				MOVW	#$0001, STATE
;				;Done 
;				NEXT

;<> ( x1 x2 -- flag )
;flag is true if and only if x1 is not bit-for-bit the same as x2.
IF_NOT_EQUALS			REGULAR
CF_NOT_EQUALS			EQU	*
				CLRA					;FALSE -> A
				LDX	2,Y+ 				;x2 -> X
				CPX	0,Y 				;compare
				BEQ	CF_NOT_EQUALS_1 		;x2 == x1
				COMA					;TRUE  -> A
CF_NOT_EQUALS_1			TAB					;flag  -> D
   				STD	0,Y				;D-> PS
				RTS

;?DO
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
;==> FUDICT

;AGAIN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( -- )
;Continue execution at the location specified by dest. If no other control flow
;words are used, any program code after AGAIN will not be executed.
;==> FUDICT

;C"
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote) and append the run-time semantics given
;below to the current definition.
;Run-time: ( -- c-addr )
;Return c-addr, a counted string consisting of the characters ccc. A program
;shall not alter the returned string.
;CF_C_QUOTE			COMPILE_ONLY				;ensure that compile mode is on
;				;Parse quote
;				LDAA	#$22 				;double quote
;				SSTACK_JOBSR	FCORE_PARSE		;string pointer -> X, character count -> A
;				TBEQ	X, CF_C_QUOTE_2 		;empty quote		
;				;Check remaining space in dictionary (string pointer in X, character count in A)
;				IBEQ	A, CF_C_QUOTE_STROF		;add CFA to count
;				TAB
;				CLRA
;				ADDD	#1
;				TFR	X, Y
;				DICT_CHECK_OF_D				;check for dictionary overflow
;				;Append run-time CFA (string pointer in Y)
;				LDX	CP
;				MOVW	#CFA_C_QUOTE_RT, 2,X+
;				;Append quote (CP in X, string pointer in Y)
;				CPSTR_Y_TO_X
;CF_C_QUOTE_1			STX	CP
;				;Done
;				NEXT
;				;Empty string
;CF_C_QUOTE_2			DICT_CHECK_OF	6			;check for dictionary overflow
;				MOVW	#CFA_TWO_LITERAL_RT, -6,X 	;add CFA
;				MOVW	#$0000, 	-2,X 		;zero pointer
;				MOVW	#$0000, 	-2,X 		;zero count
;				JOB	CF_C_QUOTE_1
;				
;CF_C_QUOTE_STROF		JOB	FCORE_THROW_STROF
;				
;;C" run-time semantics		
;CF_C_QUOTE_RT			PS_CHECK_OF	1			;check for PS overflow (PSP-2 -> Y)
;				;Push string pointer onto PS (PSP-2 in Y)
;				LDX	IP
;				STX	0,Y
;				STY	PSP
;				;Count characters (PSP-4 in Y, string pointer in X)
;				PRINT_STRCNT
;				;Adjust IP (PSP-4 in Y, string pointer in X, char count in A)
;				LEAX	A,X
;				STX	IP
;				;Done
;				NEXT

;CASE
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- case-sys )
;Mark the start of the CASE ... OF ... ENDOF ... ENDCASE structure. Append the
;run-time semantics given below to the current definition.
;Run-time: ( -- )
;Continue execution.
;==> FUDICT

;COMPILE, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( xt -- )
;Append the execution semantics of the definition represented by xt to the
;execution semantics of the current definition.
;==> FUDICT
	
;CONVERT ( ud1 c-addr1 -- ud2 c-addr2 ) CHECK!
;ud2 is the result of converting the characters within the text beginning at the
;first character after c-addr1 into digits, using the number in BASE, and adding
;each digit to ud1 after multiplying ud1 by the number in BASE. Conversion
;continues until a character that is not convertible is encountered. c-addr2 is
;the location of the first unconverted character. An ambiguous condition exists
;if ud2 overflows.
;Note: This word is obsolescent and is included as a concession to existing
;implementations. Its function is superseded by >NUMBER.
;CF_CONVERT			PS_CHECK_UF	3		;(PSP -> Y)
;				;Allocate temporary memory (PSP in Y)
;				SSTACK_ALLOC	10
;				MOVW	BASE,   0,X
;				MOVW	0,Y,    2,X
;				MOVW	2,Y,    4,X
;				MOVW	4,Y,    6,X
;				MOVW	#$FFFF, 8,X
;				;Convert to number
;				SSTACK_JOBSR	FCORE_TO_NUMBER
;				;Return results
;				LDY	PSP
;				MOVW	2,SP,  0,Y
;				MOVW	4,SP,  2,Y
;				;Deallocate temporary memory
;				SSTACK_DEALLOC	10
;				;Done
;				NEXT

;ENDCASE
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys -- )
;Mark the end of the CASE ... OF ... ENDOF ... ENDCASE structure. Use case-sys
;to resolve the entire structure. Append the run-time semantics given below to
;the current definition.
;Run-time: ( x -- )
;Discard the case selector x and continue execution.
;==> FUDICT

;ENDOF
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys1 of-sys -- case-sys2 )
;Mark the end of the OF ... ENDOF part of the CASE structure. The next location
;for a transfer of control resolves the reference given by of-sys. Append the
;run-time semantics given below to the current definition. Replace case-sys1
;with case-sys2 on the control-flow stack, to be resolved by ENDCASE.
;Run-time: ( -- )
;Continue execution at the location specified by the consumer of case-sys2.
;==> FUDICT

;Word: ERASE ( addr u -- )
;If u is greater than zero, clear all bits in each of u consecutive address
;units of memory beginning at addr .
IF_ERASE			REGULAR
CF_ERASE			EQU	*
				LDX	2,Y 				;c-addr -> X
				LDD	4,Y+ 				;u      -> D
				BEQ	CF_ERASE_1 			;u is zero
CF_ERASE_1			CLR	1,X+ 				;clear one byte
				DBNE	D, CF_ERASE_1 			;loop
CF_ERASE_2			RTS

;EXPECT ( c-addr +n -- )
;Receive a string of at most +n characters. Display graphic characters as they
;are received. A program that depends on the presence or absence of non-graphic
;characters in the string has an environmental dependency. The editing
;functions, if any, that the system performs in order to construct the string of
;characters are implementation-defined.
;Input terminates when an implementation-defined line terminator is received or
;when the string is +n characters long. When input terminates, nothing is
;appended to the string and the display is maintained in an
;implementation-defined way.
;Store the string at c-addr and its length in SPAN.
;Note: This word is obsolescent and is included as a concession to existing
;implementations. Its function is superseded by 6.1.0695 ACCEPT.
;==> FTIB

;Word: FALSE ( -- false )
;Return a false flag.
IF_FALSE			INLINE	CF_FALSE
CF_FALSE			EQU	*
				MOVW	#FALSE, 2,-Y
CF_FALSE_EOI			RTS
	
;Word: HEX ( -- )
;Set contents of BASE to sixteen.
IF_HEX				INLINE	CF_HEX
CF_HEX				EQU	*
				MOVW	#16, BASE
CF_HEX_EOI			RTS

;MARKER ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name Execution: ( -- )
;Restore all dictionary allocation and search order pointers to the state they
;had just prior to the definition of name. Remove the definition of name and all
;subsequent definitions. Restoration of any structures still existing that could
;refer to deleted definitions or deallocated data space is not necessarily
;provided. No other contextual information such as numeric base is affected.
;CF_MARKER			;Build header
;				SSTACK_JOBSR	FCORE_HEADER	;NFA -> D, error handler -> X (SSTACK: 10  bytes)
;				TBNE	X, CF_MARKER_ERROR
;				;Update LAST_NFA (NFA in D)
;				STD	LAST_NFA
;				;Append CFA and data field (NFA in D)
;				LDX	CP
;				MOVW	#CF_MARKER_RT, 2,X+
;				STD	 2,X+ 			;store NFA in data field
;				;Update CP saved (CP in X)
;				STX	CP
;				STX	CP_SAVED
;				;Done 
;				NEXT
;				;Error handler for FCORE_HEADER 
;CF_MARKER_ERROR		JMP	0,X
;MARKER run-time semantics
;Restore old last NFA an CP
;CF_MARKER_RT			;Restore last NFA
;				LDX		2,X 			;NFA -> X
;				MOVW		0,X, LAST_NFA		;Restore last NFA
;				;Restore CP 
;				STX		CP
;				STX		CP_SAVED
;				;Done
;				NEXT

;NIP ( x1 x2 -- x2 )
;Drop the first item below the top of stack.
;==> FPS

;OF
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
;==> FUDICT

;PAD ( -- c-addr )
;c-addr is the address of a transient region that can be used to hold data for
;intermediate processing.
;CF_PAD				PS_CHECK_OF	1		;overflow check	(PSP-2 -> Y)
;				;Allocate PAD if it is deallocated or empty
;				LDD	PAD
;				CPD	HLD
;				BNE	CF_PAD_1 		;PAD already allocated
;				PAD_ALLOC
;CF_PAD_1			STD	0,Y
;				STY	PSP
;				;Done 
;				NEXT

;PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char.
;c-addr is the address (within the input buffer) and u is the length of the
;parsed string. If the parse area was empty, the resulting string has a zero
;length.
;==> FOUTER

;PICK ( xu ... x1 x0 u -- xu ... x1 x0 xu )
;Remove u. Copy the xu to the top of the stack. An ambiguous condition exists if
;there are less than u+2 items on the stack before PICK is executed.
;==> FPS

;QUERY ( -- )
;Make the user input device the input source. Receive input into the terminal
;input buffer, replacing any previous contents. Make the result, whose address
;is returned by TIB, the input buffer. Set >IN to zero.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
;==> FOUTER

;REFILL ( -- flag )
;Attempt to fill the input buffer from the input source, returning a true flag
;if successful.
;When the input source is the user input device, attempt to receive input into
;the terminal input buffer. If successful, make the result the input buffer, set
;>IN to zero, and return true. Receipt of a line containing no characters is
;considered successful. If there is no input available from the current input
;source, return false.
;When the input source is a string from EVALUATE, return false and perform no
;other action.
;CF_REFILL_COMERR		JMP	0,X
;CF_REFILL			PS_CHECK_OF	1			;check for PS overflow (PSP-2 -> Y)
;				;Query command line
;				SSTACK_JOBSR	FCORE_QUERY   		;(SSTACK: 18 bytes)
;				TBNE	X, CF_QUERY_COMERR   		;communication error
;				;Push return status 
;				MOVW	#-1, 0,Y
;				STY	PSP
;				;Done 
;				NEXT

;RESTORE-INPUT ( xn ... x1 n -- flag )
;Attempt to restore the input source specification to the state described by x1
;through xn. flag is true if the input source specification cannot be so
;restored.
;An ambiguous condition exists if the input source represented by the arguments
;is not the same as the current input source.
	
;ROLL ( xu xu-1 ... x0 u -- xu-1 ... x0 xu )
;Remove u. Rotate u+1 items on the top of the stack. An ambiguous condition
;exists if there are less than u+2 items on the stack before ROLL is executed.
;==> FPS

;SAVE-INPUT ( -- xn ... x1 n )
;x1 through xn describe the current state of the input source specification for
;later use by RESTORE-INPUT.

;SOURCE-ID ( -- 0 | -1 )
;Identifies the input source as follows:
;SOURCE-ID       Input source
;-1              String (via EVALUATE)
; 0              User input device
;==> FOUTER
	
;SPAN ( -- a-addr )
;a-addr is the address of a cell containing the count of characters stored by
;the last execution of EXPECT.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
;==> FTIB 

;TIB ( -- c-addr )
;c-addr is the address of the terminal input buffer.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
;==> FTIB 

;TO
;Interpretation: ( x "<spaces>name" -- )
;Skip leading spaces and parse name delimited by a space. Store x in name. An
;ambiguous condition exists if name was not defined by VALUE.
;Compilation: ( "<spaces>name" -- )
;Skip leading spaces and parse name delimited by a space. Append the run-time
;semantics given below to the current definition. An ambiguous condition exists
;if name was not defined by VALUE.
;Run-time: ( x -- )
;Store x in name.
;Note: An ambiguous condition exists if either POSTPONE or [COMPILE] is applied
;to TO.
;CF_TO_NONAME		JOB	FCORE_THROW_NONAME
;CF_TO_UDEFWORD		JOB	FCORE_THROW_UDEFWORD
;CF_TO_NONCREATE		JOB	FCORE_THROW_NONCREATE
;CF_TO				PS_CHECK_UF	1		;check for underflow
;				;Parse name (PSP in Y)
;				SSTACK_JOBSR	FCORE_NAME 		;(SSTACK: 5 bytes)
;				TBEQ	X, CF_TO_NONAME
;				;Lookup name in dictionary (PSP in Y, string pointer in X)
;				SSTACK_JOBSR	FCORE_FIND 		;(SSTACK: 4 bytes)
;				TBEQ	D, CF_TO_UDEFWORD ;check for underflow
;				;Locate body (PSP in Y, CFA in X)
;				SSTACK_JOBSR	FCORE_TO_BODY		 ;(SSTACK: 4 bytes)
;				TBEQ	X, CF_TO_NONCREATE
;				;Store data in body (PSP in Y, pointer to body in X)
;				MOVW	2,Y+, 0,X
;				STY	PSP
;				;Done
;				NEXT

;Word: TRUE ( -- true )
;Return a true flag, a single-cell value with all bits set.
IF_TRUE				INLINE	CF_TRUE
CF_TRUE				EQU	*
				MOVW	#TRUE, 2,-Y
CF_TRUE_EOI			RTS

;TUCK ( x1 x2 -- x2 x1 x2 )
;Copy the first (top) stack item below the second stack item.
;==> FPS

;U.R ( u n -- )
;Display u right aligned in a field n characters wide. If the number of
;characters required to display u is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
;==> FDOT

;Word: U> ( u1 u2 -- flag )
;flag is true if and only if u1 is greater than u2.
IF_U_GREATER_THAN		REGULAR
CF_U_GREATER_THAN		EQU	*
				CLRA					;FALSE -> A
				LDX	2,Y+ 				;u2 -> X
				CPX	0,Y 				;compare
				BHS	CF_U_GREATER_THAN_1 		;u2 >= u1
				COMA					;TRUE  -> A
CF_U_GREATER_THAN_1		TAB					;flag  -> D
   				STD	0,Y				;D-> PS
				RTS
	
;UNUSED ( -- u )
;u is the amount of space remaining in the region addressed by HERE, in address
;units.
;==> FNVDICT
			
;Word: VALUE ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below, with an initial
;value equal to x.
;name is referred to as a value.
;name Execution: ( -- x )
;Place x on the stack. The value of x is that given when name was created, until
;the phrase x TO name is executed, causing a new value of x to be associated
;with name.
;S12CForth implementation details: same semantics as CONSTANT
IF_VALUE			EQU	IF_CONSTANT
CF_VALUE			EQU	CF_CONSTANT
	
;WITHIN ( n1|u1 n2|u2 n3|u3 -- flag )
;Perform a comparison of a test value n1|u1 with a lower limit n2|u2 and an
;upper limit n3|u3, returning true if either
;(n2|u2 < n3|u3 and (n2|u2 <= n1|u1 and n1|u1 < n3|u3)) or
;(n2|u2 > n3|u3 and (n2|u2 <= n1|u1 or n1|u1 < n3|u3)) is true, returning false
;otherwise. An ambiguous condition exists if n1|u1, n2|u2, and n3|u3 are not all
;the same type.
;CF_WITHIN			PS_CHECK_UF	3		;check for underflow  (PSP -> Y)
;				;Pull boundaries from PS
;				LDX	2,Y+ 			;u3 -> X
;				LDD	2,Y+			;u2 -> D
;				STY	PSP
;				;Compare boundaries (PSP in Y, u2 in D, u3 in X)
;				CPD	-4,Y
;				BHI	CF_WITHIN_3 		;u2 > u3
;				;u2 <= u3 (PSP in Y, upper boundary in D, lower boundary in X)
;				CPD	0,Y
;				BHI	CF_WITHIN_4 		;fail
;				CPX	0,Y
;				BLS	CF_WITHIN_4 		;fail
;				;Pass (PSP in Y)
;CF_WITHIN_1			LDD	#$FFFF
;CF_WITHIN_2			STD	 0,Y
;				;Done 
;				NEXT
;				;u2 > u3 (PSP in Y, upper boundary in D, lower boundary in X)
;CF_WITHIN_3			CPD	0,Y
;				BLS	CF_WITHIN_1 		;pass
;				CPX	0,Y
;				BHI	CF_WITHIN_1 		;pass
;				;Fail (PSP in Y) 
;CF_WITHIN_4			CLRA
;				CLRB
;				JOB	CF_WITHIN_2

;[COMPILE] 
;Intrepretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Find name. If
;name has other than default compilation semantics, append them to the current
;definition; otherwise append the execution semantics of name. An ambiguous
;condition exists if name is not found.
;
;;S12CForth implementation details:
;;Same semantics as POSTPONE

;\ 
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<eol>"-- )
;Parse and discard the remainder of the parse area. \ is an immediate word.
;==> FOUTER

;#Non-standard S12CForth extensions
; =================================
;Word: BINARY ( -- )
;Set the numeric conversion radix to two (binary).
IF_BINARY			INLINE	CF_BINARY
CF_BINARY			EQU	*
				MOVW	#2, BASE
CF_BINARY_EOI			RTS
	
;;CP ( -- addr)
;;Compile pointer (points to the next free byte after the user dictionary)

;EMPTY ( -- )
;Delete all user defined words
;CF_EMPTY			;Clear dictionary
;				MOVW	#FCORE_LAST_NFA, LAST_NFA 	;set last NFA
;				LDD	#DICT_START			;set compile pointer
;				STD	CP
;				STD	CP_SAVED
;				;Reset PS
;				PS_RESET
;				;Done		
;				NEXT
;
	
FCORE_CODE_END		EQU	*
FCORE_CODE_END_LIN	EQU	@
			
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FCORE_TABS_START_LIN
			ORG 	FCORE_TABS_START, FCORE_TABS_START_LIN
#else
			ORG 	FCORE_TABS_START
FCORE_TABS_START_LIN	EQU	@
#endif	


;#Environment
; ===========
;Environment: /COUNTED-STRING ( -- n true)
;Maximum size of a counted string, in characters
ENV_COUNTED_STRING	DW	FENV_SINGLE
			DW	$00FF
	
;Environment: /HOLD ( -- n true)
;Size of the pictured numeric output string buffer, in characters
;==> FPAD 

;Environment: /PAD ( -- n true)
;Size of the scratch area pointed to by PAD, in characters
;==> FPAD 

;Environment: ADDRESS-UNIT-BITS ( -- n true)
;Size of one address unit, in bits
ENV_ADDRESS_UNIT_BITS	DW	FENV_SINGLE
			DW	8

;Environment: CORE ( -- true)
;True if complete core word set present
ENV_CORE		DW	FENV_TRUE

;Environment: CORE-EXT ( -- true)
;True if core extensions word set present
ENV_CORE_EXT		EQU	ENV_CORE

;Environment: FLOORED ( -- true)
;True if floored division is the default
ENV_FLOORED		EQU	ENV_CORE

;Environment: MAX-CHAR ( -- u true)
;Maximum value of any character in the implementation-defined character set
ENV_MAX_CHAR		EQU	ENV_COUNTED_STRING
			;DW	FENV_SINGLE
			;DW	$00FF

;Environment: MAX-D ( -- d true)
;Largest usable signed double number
ENV_MAX_D		DW	FENV_DOUBLE
			DW	$FFFF
			DW	$7FFF

;Environment: MAX-N ( -- n true)
;Largest usable signed integer
ENV_MAX_N		DW	FENV_SINGLE
			DW	$7FFF

;Environment: MAX-U ( -- u true)
;Largest usable unsigned integer
ENV_MAX_U		DW	FENV_SINGLE
			DW	$FFFF

;Environment: MAX-UD ( -- ud true)
;Largest usable unsigned double number
ENV_MAX_UD		DW	FENV_DOUBLE
			DW	$FFFF
			DW	$FFFF

;Environment: RETURN-STACK-CELLS ( -- n true)
;Maximum size of the return stack, in cells
;==> FRS 

;Environment: STACK-CELLS ( -- n true)
;Maximum size of the data stack, in cells
;==> FPS 
	
FCORE_TABS_END		EQU	*
FCORE_TABS_END_LIN	EQU	@
#endif	
