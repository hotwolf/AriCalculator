;###############################################################################
;# S12CForth - FCORE - ANS Forth Core Words                                    #
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
;#    This module attempts to implement the ANS Forth core word and core set   #
;#    extension word set.                                                      #
;#                                                                             #
;#    Forth virtual machine registers are defined as follows:                  #
;#       W   = Working register. 					       #
;#             The W register points to the CFA of the current word, but it    #
;#             may be overwritten.	   			               #
;#             Used for indexed addressing and arithmetics.		       #
;#	       Index Register X is used to implement W.                        #
;#       IP  = Instruction pointer.					       #
;#             Points to the next execution token.			       #
;#       PSP = Parameter Stack Pointer.					       #
;#	       Points one cell beyond the top of the parameter stack           #
;#       RSP = Return stack pointer.					       #
;#	       Points one cell beyond the top of the return stack.             #
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
;#    April 22, 2010                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    PRINT  - Print Routines                                                  #
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
;Valid number base
FCORE_BASE_MIN		EQU	PRINT_BASE_MIN	;2
FCORE_BASE_MAX		EQU	PRINT_BASE_MAX	;PRINT_SYMTAB_END-PRINT_SYMTAB=26
FCORE_BASE_DEF		EQU	PRINT_BASE_DEF	;10
FCORE_SYMTAB		EQU	PRINT_SYMTAB

;Standard error codes
FCORE_EC_UDEFWORD	EQU	FEXCPT_EC_UDEFWORD	;undefined wor
FCORE_EC_0DIV		EQU	FEXCPT_EC_0DIV		;division by zero
FCORE_EC_RESOR		EQU	FEXCPT_EC_RESOR		;result out of range
FCORE_EC_INVALBASE	EQU	FEXCPT_EC_INVALBASE	;invalid BASE
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FCORE_VARS_START
IP			DS	2 	;instruction pointer
BASE			DS	2	;base for numeric I/O
STATE			DS	2	;interpreter state
LAST_NFA		DS	2	;last NFA entry 
FCORE_VARS_END		EQU	*
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FCORE_INIT, 0
			MOVW	#PRINT_BASE_DEF, BASE     ;initialize BASE variable
			MOVW	#FCORE_LAST_NFA, LAST_NFA ;initialize pointer to last NFA
#emac

;#Common word format:
; ===================
;	
;        +-----------------------------+
;  NFA-> |         Previous NFA        |	
;        +--------------+--------------+
;        |PRE|CFA offset| 
;        +--------------+   
;        |              | 
;        |              | 
;        |     Name     | 
;        |              | 
;        |              | 
;        +-----------------------------+
;  CFA-> |       Code Field Address    |	
;        +--------------+--------------+
;        |              | 
;        |              | 
;        |     Data     | 
;        |              | 
;        |              | 
;        +--------------+   
;                              
; args: 1. name of the word
;       2. previous word entry
;       3. precedence bit (1:immediate, 0:compile)
IMMEDIATE	EQU	1
COMPILE		EQU	0
#macro	FHEADER, 3
		ALIGN	1
PREV		DW	\2
NAME_CNT	DB	(NAME_END-NAME_START)&(\3<<7)
NAME_START	FCC	\1
		ALIGN	1
NAME_END	
#emac	

;#Common macros:
;	
;        +-----------+
;        |    CFA    |	
;        +-----------+    +-----------+
;  IP -> | PRIMITIVE | -> |    CFA    | -> ASM code
;        +-----------+    +-----------+
;                         | PRIMITIVE |
;                         +-----------+
;   IP   = PRIMITIVE        
;  [IP]  = CFA	
; [[IP]] = ASM code	
;	

;#Common code fragments	
;NEXT:	jump to the next instruction
#macro	NEXT, 0	
NEXT			LDY	IP			;IP -> Y	        => 3 cycles
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles   
			STY	IP			;	  	  	=> 3 cycles 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         15 cycles
#emac

;SKIP_NEXT: skip next instruction and jump to one after
#macro	SKIP_NEXT, 0	
SKIP_NEXT		LDY	IP			;IP -> Y	        => 3 cycles
			LEAY	2,Y			;IP += 2		=> 2 cycles
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles    
			STY	IP			;		  	=> 3 cycles 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         17 cycles
#emac

;JUMP_NEXT: Read the next word entry and jump to that instruction 
#macro	JUMP_NEXT, 0	
JUMP_NEXT		LDY	[IP]			;[IP] -> Y	        => 6 cycles
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles   
			STY	IP			;	  	  	=> 3 cycles 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         18 cycles
#emac

;EXEC_CFA: Execute a Forth word (CFA) directly from assembler code 
#macro	EXEC_CFA, 3	;args: 1:CFA 2:RS overflow handler, 3:RS underflow handler
			RS_PUSH	IP, \2			;IP -> RS			
			MOVW	#IP_RESUME, IP 		;set next IP
			LDX	#\1			;set W
			JMP	[\1]			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		RS_PULL	IP, \3 			;RS -> IP
#emac
	
;EXEC_CF: Execute a Forth word's code field (CF) directly from assembler code (w/out setting the W register)
#macro	EXEC_CF, 3	;args: 1:CF 2:RS overflow handler, 3:RS underflow handler
			RS_PUSH	IP, \2		;IP -> RS			
			MOVW	#IP_RESUME, IP 		;set next IP
			JOB	\1
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		RS_PULL	IP, \3 		;RS -> IP
#emac

;BASE_CHECK: Verify the content of the BASE variable (Cdirectly from assembler code (BASE -> D)
#macro	BASE_CHECK, 1	;args: 1:error handler
			LDD	BASE
			CPD	#FCORE_BASE_MIN
			BLO	>\1
			CPD	#FCORE_BASE_MAX
			BHI	>\1
#emac
		
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FCORE_CODE_START
;Exceptions
FCORE_THROW_PSOF	EQU	FMEM_THROW_PSOF			;stack overflow
FCORE_THROW_PSUF	EQU	FMEM_THROW_PSUF			;stack underflow
FCORE_THROW_RSOF	EQU	FMEM_THROW_PSOF			;return stack overflow
FCORE_THROW_RSUF	EQU	FMEM_THROW_RSUF 		;return stack underflow
FCORE_THROW_DICTOF	EQU	FMEM_THROW_DICTOF		;dictionary overflow
FCORE_THROW_PADOF	EQU	FMEM_THROW_PADOF		;pictured numeric output string overflow
FCORE_THROW_TIBOF	EQU	FMEM_THROW_TIBOF		;text input buffer overflow
FCORE_THROW_0DIV	FEXCPT_THROW	FCORE_EC_0DIV		;division by zero
FCORE_THROW_RESOR	FEXCPT_THROW	FCORE_EC_RESOR		;result out of range
FCORE_THROW_INVALBASE	FEXCPT_THROW	FCORE_EC_INVALBASE	;invalid BASE
	
;CF_INNER   ( -- )
			;Execute the first execution token after the CFA (CFA in X)
CF_INNER		EQU		*	
			RS_PUSH		IP, CF_INNER_RSOF	;IP -> RS		=>20 cycles
			LEAY		4,X			;CFA+4 -> IP		=> 2 cycles
			STY		IP			;			=> 3 cycles
			LDX		2,X			;new CFA -> X		=> 3 cycles
			JMP		[0,X]			;JUMP [new CFA]         => 6 cycles
								;                         ---------
								;                         34 cycles
CF_INNER_RSOF		JOB	FCORE_THROW_RSOF
	
;;CF_EXIT   ( -- )
;			;End compiled word
;CF_EXIT			EQU		*	
;			RS_PULL		IP, CF_EXIT_RSUF
;			NEXT
;
;CF_EXIT_RSUF		JOB	FCORE_THROW_RSUF

	
;CF_DUMMY   ( -- )
			;Code field for unimplemented words
CF_DUMMY		EQU		*	
			NEXT

FCORE_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FCORE_TABS_START
;System prompt
FCORE_INPUT_PROMPT	FCS	"> "
FCORE_SYSTEM_PROMPT	FCS	" ok"
	
FCORE_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FCORE_WORDS_START ;(previous NFA: FCORE_PREV_NFA)

;#Core words:
; ===========
	
;! ( x a-addr -- )
;Store x at a-addr.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_STORE		FHEADER, "!", FCORE_PREV_NFA, COMPILE
CFA_STORE		DW	CF_STORE
CF_STORE		PS_CHECK_UF 2, CF_STORE_PSUF 	;check for underflow  (PSP -> Y)
			LDX	2,Y-			;x -> a-addr	
			MOVW	2,Y-, 0,X
			STY	PSP
			NEXT

CF_STORE_PSUF		JOB	FCORE_THROW_PSUF
	
;# ( ud1 -- ud2 )
;Divide ud1 by the number in BASE giving the quotient ud2 and the remainder n.
;(n is the least-significant digit of ud1.) Convert n to external form and add
;the resulting character to the beginning of the pictured numeric output string.
;An ambiguous condition exists if # executes outside of a <# #> delimited number
;conversion.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"PAD buffer overflow"
;"Invalid BASE value"
;
NFA_NUMBER_SIGN		FHEADER, "#", NFA_STORE, COMPILE
CFA_NUMBER_SIGN		DW	CF_NUMBER_SIGN
CF_NUMBER_SIGN		PS_CHECK_UF 2, CF_NUMBER_SIGN_PSUF 	;check for underflow  (PSP -> Y)
			BASE_CHECK	CF_NUMBER_SIGN_INVALBASE	;check BASE value (BASE -> D)
			;Perform division (PSP in Y, BASE in D)
			TFR	D,X				;prepare 1st division
			LDD	0,Y				; (ud1>>16)/BASE
			IDIV					;D/X=>X; remainder=D
			STX	0,Y				;return upper word of the result
			LDX	BASE				;prepare 2nd division
			STY	2,Y
			EXG	D,Y
			EDIV					;Y:D/X=>Y; remainder=>D
			LDX	PSP				;PSP -> X
			STY	2,X
			;Lookup ASCII representation of the remainder (remainder -> D)
			TFR	D,X
			LDAB	[FCORE_SYMTAB,X]
			;Add ASCII character to the PAD buffer
			PAD_CHECK_OF	CF_NUMBER_SIGN_PADOF	;check for PAD overvlow (HLD-1 -> X)
			STAB	1,+X
			STX	HLD
			NEXT
	
CF_NUMBER_SIGN_PSUF		JOB	FCORE_THROW_PSUF
CF_NUMBER_SIGN_PADOF		JOB	FCORE_THROW_PADOF
CF_NUMBER_SIGN_INVALBASE	JOB	FCORE_THROW_INVALBASE
	
;#> ( xd -- c-addr u )
;Drop xd. Make the pictured numeric output string available as a character
;string. c-addr and u specify the resulting character string. A program may
;replace characters within the string. 
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Parameter stack underflow"
;
NFA_NUMBER_SIGN_GREATER		FHEADER, "#>", NFA_NUMBER_SIGN, COMPILE
CFA_NUMBER_SIGN_GREATER		DW	CF_NUMBER_SIGN_GREATER
CF_NUMBER_SIGN_GREATER		PS_CHECK_UFOF	1, CF_NUMBER_SIGN_GREATER_PSUF, 1, CF_NUMBER_SIGN_GREATER_PSOF ;check for under and overflow
				;Return string pointer 
				MOVW	HLD, -2,Y	;HLD     -> c-addr
				;Return string count 
				LDD	PAD		;PAD-HLD -> u
				TFR	D, X
				SUBD	HLD
				STD	0,Y
				;Terminate string
				LDAB	#$80
				ORAB	-1,X
				STAB	-1,X
				NEXT

CF_NUMBER_SIGN_GREATER_PSUF	JOB	FCORE_THROW_PSUF
CF_NUMBER_SIGN_GREATER_PSOF	JOB	FCORE_THROW_PSOF
	
;#S ( ud1 -- ud2 )
;Convert one digit of ud1 according to the rule for #. Continue conversion
;until the quotient is zero. ud2 is zero. An ambiguous condition exists if #S
;executes outside of a <# #> delimited number conversion.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_NUMBER_SIGN_S	FHEADER, "#S", NFA_NUMBER_SIGN_GREATER, COMPILE
CFA_NUMBER_SIGN_S	DW	CF_INNER
			
			DW	CFA_NUMBER_SIGN

			DW	CF_EXIT
	
;' ( "<spaces>name" -- xt ) 	;'
;Skip leading space delimiters. Parse name delimited by a space. Find name and
;return xt, the execution token for name. An ambiguous condition exists if name
;is not found.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_TICK		EQU	NFA_NUMBER_SIGN_S	
;NFA_TICK		FHEADER, "'", NFA_NUMBER_SIGN_S, COMPILE
;CFA_TICK		DW	CF_DUMMY
;			DW	CFA_EXIT

;( 
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<paren>" -- )
;Parse ccc delimited by ) (right parenthesis). ( is an immediate word.
NFA_PAREN		FHEADER, "(", NFA_TICK, IMMEDIATE
CFA_PAREN		DW	CF_INNER
			DW	CFA_LITERAL
			DW	")"
			DW	CFA_PARSE
			DW	CFA_TWO_DROP
			DW	CFA_EXIT
	
;* ( n1|u1 n2|u2 -- n3|u3 )
;Multiply n1|u1 by n2|u2 giving the product n3|u3.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_STAR		FHEADER, "*", NFA_PAREN, COMPILE
CFA_STAR		DW	CF_STAR
CF_STAR			PS_CHECK_UF	2, CF_STAR_PSUF ;check for underflow  (PSP -> Y)
			TFR	Y, X
			LDY	2,X	;n1    -> Y
			LDD	0,X	;n2    -> D
			EMUL		;n1*n2 -> Y:D
			STD	2,+X
			STX	PSP
			NEXT
	
CF_STAR_PSUF		JOB	FCORE_THROW_PSUF
	
;*/ ( n1 n2 n3 -- n4 )
;Multiply n1 by n2 producing the intermediate double-cell result d. Divide d by
;n3 giving the single-cell quotient n4. An ambiguous condition exists if n3 is
;zero or if the quotient n4 lies outside the range of a signed number. If d and
;n3 differ in sign, the implementation-defined result returned will be the same
;as that returned by either the phrase >R M* R> FM/MOD SWAP DROP or the phrase
;>R M* R> SM/REM SWAP DROP 
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;"Quotient out of range"
;
NFA_STAR_SLASH		FHEADER, "*/", NFA_STAR, COMPILE
CFA_STAR_SLASH		DW	CF_STAR_SLASH
CF_STAR_SLASH		PS_CHECK_UF	3, CF_STAR_SLASH_PSUF ;check for underflow  (PSP -> Y)
			TFR	Y, X
			LDY	4,X			;n1    -> Y
			LDD	2,X			;n2    -> D
			EMULS				;n1*n2 -> Y:D
			LDX	0,X			;n3    -> X 
			EDIVS				;Y:D/X -> Y
			BCS	CF_STAR_SLASH_0DIV	;division by zero
			BVS	CF_STAR_SLASH_RESOR	;quotient out of range
			LDX	PSP
			STY	4,+X
			STX	PSP
			NEXT
		
CF_STAR_SLASH_PSUF	JOB	FCORE_THROW_PSUF
CF_STAR_SLASH_0DIV	JOB	FCORE_THROW_0DIV
CF_STAR_SLASH_RESOR	JOB	FCORE_THROW_RESOR
	
;*/MOD ( n1 n2 n3 -- n4 n5 )
;Multiply n1 by n2 producing the intermediate double-cell result d. Divide d by
;n3 producing the single-cell remainder n4 and the single-cell quotient n5. An
;ambiguous condition exists if n3 is zero, or if the quotient n5 lies outside
;the range of a single-cell signed integer. If d and n3 differ in sign, the
;implementation-defined result returned will be the same as that returned by
;either the phrase >R M* R> FM/MOD or the phrase >R M* R> SM/REM .
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;"Quotient out of range"
;
NFA_STAR_SLASH_MOD	FHEADER, "*/MOD", NFA_STAR_SLASH, COMPILE
CFA_STAR_SLASH_MOD	DW	CF_STAR_SLASH
CF_STAR_SLASH_MOD	PS_CHECK_UF	3, CF_STAR_SLASH_MOD_PSUF ;check for underflow  (PSP -> Y)
			TFR	Y, X
			LDY	4,X			;n1    -> Y
			LDD	2,X			;n2    -> D
			EMULS				;n1*n2 -> Y:D
			LDX	0,X			;n3    -> X 
			EDIVS				;Y:D/X -> Y, remainer -> D
			BCS	CF_STAR_SLASH_MOD_0DIV	;division by zero
			BVS	CF_STAR_SLASH_MOD_RESOR	;quotient out of range
			LDX	PSP
			STD	2,+X
			STY	2,+X
			STX	PSP
			NEXT
		
CF_STAR_SLASH_MOD_PSUF	JOB	FCORE_THROW_PSUF
CF_STAR_SLASH_MOD_0DIV	JOB	FCORE_THROW_0DIV
CF_STAR_SLASH_MOD_RESOR	JOB	FCORE_THROW_RESOR

;+ ( n1|u1 n2|u2 -- n3|u3 )
;Add n2|u2 to n1|u1, giving the sum n3|u3.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_PLUS		FHEADER, "+", NFA_STAR_SLASH_MOD, COMPILE
CFA_PLUS		DW	CF_PLUS
CF_PLUS			PS_CHECK_UF	2, CF_PLUS_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+
			ADDD	0,Y
			STD	0,Y
			STY	PSP
			NEXT

CF_PLUS_PSUF	JOB	FCORE_THROW_PSUF
	
;+! ( n|u a-addr -- )
;Add n|u to the single-cell number at a-addr.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_PLUS_STORE		FHEADER, "+!", NFA_PLUS, COMPILE
CFA_PLUS_STORE		DW	CF_PLUS_STORE
CF_PLUS_STORE		PS_CHECK_UF	2, CF_PLUS_STORE_PSUF ;check for underflow  (PSP -> Y)
			LDX	2,Y+
			LDD	0,X
			ADDD	2,Y+
			STD	0,X
			STY	PSP
			NEXT
	
CF_PLUS_STORE_PSUF	JOB	FCORE_THROW_PSUF
	
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
NFA_PLUS_LOOP		FHEADER, "+LOOP", NFA_PLUS_STORE, IMMEDIATE
CFA_PLUS_LOOP		DW	CF_DUMMY

;Run-time of +LOOP

	
;, ( x -- )
;Reserve one cell of data space and store x in the cell. If the data-space
;pointer is aligned when , begins execution, it will remain aligned when,
;finishes execution. An ambiguous condition exists if the data-space pointer is
;not aligned prior to execution of ,.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary space exceeded"
;
NFA_COMMA		FHEADER, ",", NFA_PLUS_LOOP, COMPILE
CFA_COMMA		DW	CF_COMMA
CF_COMMA		PS_CHECK_UF	1, CF_COMMA_PSUF 	;check for PS underflow   (PSP -> Y)
			DICT_CHECK_OF	2, CF_COMMA_DICTOF	;check for DICT overflow (CP+bytes -> X)
			MOVW	2,Y+, -2,X
			STY	PSP
			STX	CP
			NEXT

CF_COMMA_PSUF		JOB	FCORE_THROW_PSUF
CF_COMMA_DICTOF		JOB	FCORE_THROW_DICTOF
	
;- ( n1|u1 n2|u2 -- n3|u3 )
;Subtract n2|u2n from n1|u1, giving the difference n3|u3.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_MINUS		FHEADER, "-", NFA_COMMA, COMPILE
CFA_MINUS		DW	CF_MINUS
CF_MINUS		PS_CHECK_UF	2, CF_MINUS_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y
			SUBD	2,Y+
			STD	0,Y
			STY	PSP
			NEXT

CF_MINUS_PSUF	JOB	FCORE_THROW_PSUF

;. ( n -- )
;Display n in free field format.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Invalid BASE"
;
NFA_DOT			FHEADER, ".", NFA_MINUS, COMPILE
CFA_DOT			DW	CF_DOT
CF_DOT			PS_PULL_X	1, CF_DOT_PSUF 	;pull cell from PS
			BASE_CHECK	CF_DOT_INVALBASE	;check BASE value
			PRINT_SPC			;print a space character
			PRINT_SINT			;print cell as signed integer
			NEXT

CF_DOT_PSUF		JOB	FCORE_THROW_PSUF
CF_DOT_INVALBASE		JOB	FCORE_THROW_INVALBASE
	
;." 			;"
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote). Append the run-time semantics given ;"
;below to the current definition.
;Run-time: ( -- )
;Display ccc.
;
;S12CForth implementation details:
;Interpretation semantics:
;Print string to the terminal
;Throws:
;"Dictionary space exceeded"
;
NFA_DOT_QUOTE		FHEADER, '."', NFA_DOT, IMMEDIATE ;"
CFA_DOT_QUOTE		DW	CF_DOT_QUOTE 		;immediate or compile mode?
CF_DOT_QUOTE		LDD	STATE			
			BEQ	CF_DOT_QUOTE_1 		;immediate mode
			;Compile mode: Check if string is empty
		        
				


	
			DICT_CHECK_OF	4, CFA_DOT_QUOTE_DICTOF ;check dictonary space (CP+bytes -> X)
			MOVW	#CFA_DOT_QUOTE_RT, -4,X




		;Loop though quoted string
CF_DOT_QUOTE_1			

CFA_DOT_QUOTE_DICTOF	JOB	FMEM_THROW_DICTOF
	
;Run-time of ." 
CFA_DOT_QUOTE_RT	DW	CF_DOT_QUOTE_RT
CF_DOT_QUOTE_RT		LDX	IP			;print string at IP
			PRINT_STR
			PRINT_STRCNT 			;advance IP
			LEAX	A,X
			STX	IP
			NEXT


	
;/ ( n1 n2 -- n3 )
;Divide n1 by n2, giving the single-cell quotient n3. An ambiguous condition
;exists if n2 is zero. If n1 and n2 differ in sign, the implementation-defined
;result returned will be the same as that returned by either the phrase
;>R S>D R> FM/MOD SWAP DROP or the phrase >R S>D R> SM/REM SWAP DROP .
;
;S12CForth implementation details:
; - Throws an "Divide by zero" exception
NFA_SLASH		FHEADER, "/", NFA_DOT_QUOTE, COMPILE
CFA_SLASH		DW	CF_SLASH
CF_SLASH		PS_CHECK_UF	2, CF_SLASH_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y			 ;n1   -> D
			LDX	2,Y+			 ;n2   -> X
			BEQ	CF_SLASH_0DIV		 ;divide by zero
			IDIVS				 ;D/X  -> X
			STX	0,Y
			STY	PSP
			NEXT
		
CF_SLASH_PSUF		JOB	FCORE_THROW_PSUF
CF_SLASH_0DIV		JOB	FCORE_THROW_0DIV

;/MOD ( n1 n2 -- n3 n4 )
;Divide n1 by n2, giving the single-cell remainder n3 and the single-cell
;quotient n4. An ambiguous condition exists if n2 is zero. If n1 and n2 differ
;in sign, the implementation-defined result returned will be the same as that
;returned by either the phrase >R S>D R> FM/MOD or the phrase >R S>D R> SM/REM . 
;
;S12CForth implementation details:
; - Throws an "Divide by zero" exception
NFA_SLASH_MOD		FHEADER, "/MOD", NFA_SLASH, COMPILE
CFA_SLASH_MOD		DW	CF_SLASH_MOD
CF_SLASH_MOD		PS_CHECK_UF	2, CF_SLASH_MOD_PSUF	;check for underflow  (PSP -> Y)
			LDD	2,Y				;n1   -> D
			LDX	0,Y				;n2   -> X
			BEQ	CF_SLASH_0DIV		 	;divide by zero
			IDIVS				 	;D/X  -> X, remainder -> D
			STD	2,Y
			STX	0,Y
			NEXT
		
CF_SLASH_MOD_PSUF	JOB	FCORE_THROW_PSUF
CF_SLASH_MOD_0DIV	JOB	FCORE_THROW_0DIV

;0 ( -- 0 ) Non-standard, but common constant!
;Constant 0
NFA_ZERO		FHEADER, "0", NFA_SLASH_MOD, COMPILE
CFA_ZERO		DW	CF_CONSTANT_RT
			DW	0
	
;0< ( n -- flag )
;flag is true if and only if n is less than zero.
NFA_ZERO_LESS		FHEADER, "0<", NFA_ZERO, COMPILE
CFA_ZERO_LESS		DW	CF_ZERO_EQUALS
CF_ZERO_LESS		PS_CHECK_UF 1, CF_ZERO_LESS_PSUF	;(PSP -> Y)
			LDX	0,Y
			BMI	<CF_ZERO_LESS_2
CF_ZERO_LESS_1		MOVW	#$0000, 0,Y
			NEXT
CF_ZERO_LESS_2		EQU	CF_ZERO_EQUALS_1	

CF_ZERO_LESS_PSUF	JOB	FCORE_THROW_PSUF

;0= ( x -- flag )
;flag is true if and only if x is equal to zero.
NFA_ZERO_EQUALS		FHEADER, "0=", NFA_ZERO_LESS, COMPILE
CFA_ZERO_EQUALS		DW	CF_ZERO_EQUALS
CF_ZERO_EQUALS		PS_CHECK_UF 1, CF_ZERO_EQUALS_PSUF	;(PSP -> Y)
			LDX	0,Y
			BNE	<CF_ZERO_EQUALS_2
CF_ZERO_EQUALS_1	MOVW	#$FFFF, 0,Y
			NEXT
CF_ZERO_EQUALS_2	EQU	CF_ZERO_LESS_1

CF_ZERO_EQUALS_PSUF	JOB	FCORE_THROW_PSUF

;1 ( -- 1 ) Non-standard, but common constant!
;Constant 1
NFA_ONE			FHEADER, "1", NFA_ZERO_EQUALS, COMPILE
CFA_ONE			DW	CF_CONSTANT_RT
			DW	1
	
;1+ ( n1|u1 -- n2|u2 )
;Add one (1) to n1|u1 giving the sum n2|u2.
NFA_ONE_PLUS		FHEADER, "1+", NFA_ONE, COMPILE
CFA_ONE_PLUS		DW	CF_ONE_PLUS
CF_ONE_PLUS		PS_CHECK_UF 1, CF_ONE_MINUS_PSUF	;(PSP -> Y)
			LDX	0,Y
			LEAX	1,X
			STX	0,Y
			NEXT

CF_ONE_PLUS_PSUF	JOB	FCORE_THROW_PSUF
	
;1- ( n1|u1 -- n2|u2 ) 
;Subtract one (1) from n1|u1 giving the difference n2|u2.
NFA_ONE_MINUS		FHEADER, "1-", NFA_ONE_PLUS, COMPILE
CFA_ONE_MINUS		DW	CF_ONE_MINUS
CF_ONE_MINUS		PS_CHECK_UF 1, CF_ONE_MINUS_PSUF	;(PSP -> Y)
			LDX	0,Y
			LEAX	-1,X
			STX	0,Y
			NEXT
	
CF_ONE_MINUS_PSUF	JOB	FCORE_THROW_PSUF
	
;2 ( -- 2 ) Non-standard, but common constant!
;Constant 2
NFA_TWO			FHEADER, "2", NFA_ONE_MINUS, COMPILE
CFA_TWO			DW	CF_CONSTANT_RT
			DW	2
	
;2! ( x1 x2 a-addr -- )
;Store the cell pair x1 x2 at a-addr, with x2 at a-addr and x1 at the next
;consecutive cell. It is equivalent to the sequence SWAP OVER ! CELL+ ! .
NFA_TWO_STORE		FHEADER, "2!", NFA_TWO, COMPILE
CFA_TWO_STORE		DW	CF_TWO_STORE
CF_TWO_STORE		PS_CHECK_UF 3, CF_TWO_STORE_PSUF 	;check for underflow  (PSP -> Y)
			LDX	2,Y-				;x -> a-addr	
			MOVW	2,Y-, 2,X+
			MOVW	2,Y-, 0,X
			STY	PSP
			NEXT
	
CF_TWO_STORE_PSUF	JOB	FCORE_THROW_PSUF

;2* ( x1 -- x2 )
;x2 is the result of shifting x1 one bit toward the most-significant bit,
;filling the vacated least-significant bit with zero.
NFA_TWO_STAR		FHEADER, "2*", NFA_TWO_STORE, COMPILE
CFA_TWO_STAR		DW	CF_TWO_STAR
CF_TWO_STAR		PS_CHECK_UF 1, CF_TWO_STAR_PSUF	;(PSP -> Y)
			LDD	0,Y
			LSLD
			STD	0,Y
			NEXT
	
CF_TWO_STAR_PSUF	JOB	FCORE_THROW_PSUF
	
;2/ ( x1 -- x2 )
;x2 is the result of shifting x1 one bit toward the least-significant bit,
;leaving the most-significant bit unchanged.
NFA_TWO_SLASH		FHEADER, "2/", NFA_TWO_STAR, COMPILE
CFA_TWO_SLASH		DW	CF_TWO_SLASH
CF_TWO_SLASH		PS_CHECK_UF 1, CF_TWO_SLASH_PSUF	;(PSP -> Y)
			LDD	0,Y
			LSRD
			STD	0,Y
			NEXT
	
CF_TWO_SLASH_PSUF	JOB	FCORE_THROW_PSUF

;2@ ( a-addr -- x1 x2 )
;Fetch the cell pair x1 x2 stored at a-addr. x2 is stored at a-addr and x1 at
;the next consecutive cell. It is equivalent to the sequence DUP CELL+ @ SWAP @ .
NFA_TWO_FETCH		FHEADER, "2@", NFA_TWO_SLASH, COMPILE
CFA_TWO_FETCH		DW	CF_DUMMY
			DW	CFA_EXIT

;2DROP ( x1 x2 -- )
;Drop cell pair x1 x2 from the stack.
;
;S12CForth implementation details:
; - Doesn't throw any exception, resets the parameter stack on underflow 
NFA_TWO_DROP		FHEADER, "2DROP", NFA_TWO_FETCH, COMPILE
CFA_TWO_DROP		DW	CF_TWO_DROP
CF_TWO_DROP		PS_CHECK_UF	2, CF_TWO_DROP_2	;(PSP -> Y)
			LEAY	4,Y				;drop 2 cells
CF_TWO_DROP_1		STY	PSP
			NEXT
CF_TWO_DROP_2		LDY	#PS_EMPTY 			;reset PS
			JOB	CF_TWO_DROP_1
	
;2DUP ( x1 x2 -- x1 x2 x1 x2 )
;Duplicate cell pair x1 x2.
NFA_TWO_DUP		FHEADER, "2DUP", NFA_TWO_DROP, COMPILE
CFA_TWO_DUP		DW		CF_DUP
CF_TWO_DUP		PS_CHECK_UFOF	2, CF_TWO_DUP_PSUF, 2, CF_DUP_PSOF ;check for under and overflow
			MOVW		6,Y, 2,Y			;duplicate stack entry
			MOVW		4,Y, 0,Y			;duplicate stack entry
			STY		PSP
			NEXT

CF_TWO_DUP_PSUF	JOB	FCORE_THROW_PSUF
CF_TWO_DUP_PSOF	JOB	FCORE_THROW_PSOF

;2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;two-over CORE 
;	( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;Copy cell pair x1 x2 to the top of the stack.
NFA_TWO_OVER		FHEADER, "2OVER", NFA_TWO_DUP, COMPILE
CFA_TWO_OVER		DW	CF_TWO_OVER
CF_TWO_OVER		PS_CHECK_UFOF	4, CF_TWO_OVER_PSUF, 2, CF_TWO_OVER_PSOF;check for under and overflow
			MOVW		8,Y, 0,Y				;duplicate stack entry
			MOVW		10,Y, 2,Y				;duplicate stack entry
			STY		PSP
			NEXT

CF_TWO_OVER_PSUF	JOB	FCORE_THROW_PSUF
CF_TWO_OVER_PSOF	JOB	FCORE_THROW_PSOF

;2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;Exchange the top two cell pairs.
NFA_TWO_SWAP		FHEADER, "2SWAP", NFA_TWO_OVER, COMPILE
CFA_TWO_SWAP		DW	CF_TWO_SWAP
CF_TWO_SWAP		PS_CHECK_UF 4, CF_TWO_SWAP_PSUF	;(PSP -> Y)
			LDD	0,Y
			MOVW	2,Y 6,Y
			MOVW	4,Y 0,Y
			MOVW	6,Y 2,Y
			STD	4,Y
			NEXT
	
CF_TWO_SWAP_PSUF	JOB	FCORE_THROW_PSUF
	
;3 ( -- 3 ) Non-standard, but common constant!
;Constant 3
NFA_THREE		FHEADER, "3", NFA_TWO_SWAP, COMPILE
CFA_THREE		DW	CF_CONSTANT_RT
			DW	3

;4 ( -- 4 ) Non-standard, but common constant!
;Constant 4
NFA_FOUR		FHEADER, "4", NFA_THREE, COMPILE
CFA_FOUR		DW	CF_CONSTANT_RT
			DW	4

;5 ( -- 5 ) Non-standard, but common constant!
;Constant 5
NFA_FIVE		FHEADER, "5", NFA_FOUR, COMPILE
CFA_FIVE		DW	CF_CONSTANT_RT
			DW	5

;6 ( -- 6 ) Non-standard, but common constant!
;Constant 6
NFA_SIX			FHEADER, "6", NFA_FIVE, COMPILE
CFA_SIX			DW	CF_CONSTANT_RT
			DW	6

;7 ( -- 7 ) Non-standard, but common constant!
;Constant 7
NFA_SEVEN		FHEADER, "7", NFA_SIX, COMPILE
CFA_SEVEN		DW	CF_CONSTANT_RT
			DW	7

;8 ( -- 8 ) Non-standard, but common constant!
;Constant 8
NFA_EIGHT		FHEADER, "8", NFA_EIGHT, COMPILE
CFA_EIGHT		DW	CF_CONSTANT_RT
			DW	8
	
;: ( C: "<spaces>name" -- colon-sys )
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
;
;S12CForth implementation details:
; - not implemented, yet 
NFA_COLON		EQU	 NFA_EIGHT
;NFA_COLON		FHEADER, ":", NFA_EIGHT, IMMEDIATE
;CFA_COLON		DW	CF_DUMMY
;			DW	CFA_EXIT

;; 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys -- )
;Append the run-time semantics below to the current definition. End the current
;definition, allow it to be found in the dictionary and enter interpretation
;state, consuming colon-sys. If the data-space pointer is not aligned, reserve
;enough data space to align it.
;Run-time: ( -- ) ( R: nest-sys -- )
;Return to the calling definition specified by nest-sys.
;
;S12CForth implementation details:
; - not implemented, yet 
NFA_SEMICOLON		EQU	NFA_COLON
;NFA_SEMICOLON		FHEADER, ";", NFA_COLON, IMMEDIATE
;CFA_SEMICOLON		DW	CF_DUMMY
;			DW	CFA_EXIT

;< ( n1 n2 -- flag )
;flag is true if and only if n1 is less than n2.
NFA_LESS_THAN		FHEADER, "<", NFA_SEMICOLON, COMPILE
CFA_LESS_THAN		DW	CF_LESS_THAN
CF_LESS_THAN		PS_CHECK_UF 2, CF_LESS_THAN_PSUF	;(PSP -> Y)
			LDD	2,Y
			CPD	2,Y+
			BGE	<CF_LESS_THAN_2
CF_LESS_THAN_1		MOVW	#$0000, 0,Y
			STY	PSP
			NEXT
CF_LESS_THAN_2		EQU	CF_EQUALS_1
	
CF_LESS_THAN_PSUF	JOB	FCORE_THROW_PSUF
	
;<# ( -- )
;Initialize the pictured numeric output conversion process.
;
;S12CForth implementation details:
;-Allocares the PAD buffer
	
NFA_LESS_NUMBER_SIGN	FHEADER, "<#", NFA_LESS_THAN, COMPILE
CFA_LESS_NUMBER_SIGN	DW	CF_DUMMY
			DW	CFA_EXIT




	
;= ( x1 x2 -- flag )
;flag is true if and only if x1 is bit-for-bit the same as x2.
NFA_EQUALS		FHEADER, "=", NFA_LESS_NUMBER_SIGN, COMPILE
CFA_EQUALS		DW	CF_EQUALS
CF_EQUALS		PS_CHECK_UF 2, CF_EQUALS_PSUF	;(PSP -> Y)
			LDD	2,Y
			CPD	2,Y+
			BNE	<CF_EQUALS_2
CF_EQUALS_1		MOVW	#$FFFF, 0,Y
			STY	PSP
			NEXT
CF_EQUALS_2		EQU	CF_LESS_THAN_1
	
CF_EQUALS_PSUF	JOB	FCORE_THROW_PSUF

;> ( n1 n2 -- flag )
;flag is true if and only if n1 is greater than n2.
NFA_GREATER_THAN	FHEADER, ">", NFA_EQUALS, COMPILE
CFA_GREATER_THAN	DW	CF_GREATER_THAN
CF_GREATER_THAN		PS_CHECK_UF 2, CF_GREATER_THAN_PSUF	;(PSP -> Y)
			LDD	2,Y
			CPD	2,Y+
			BLT	<CF_GREATER_THAN_2
CF_GREATER_THAN_1	MOVW	#$0000, 0,Y
			STY	PSP
			NEXT
CF_GREATER_THAN_2	EQU	CF_EQUALS_1
	
CF_GREATER_THAN_PSUF	JOB	FCORE_THROW_PSUF

;>BODY ( xt -- a-addr )
;a-addr is the data-field address corresponding to xt. An ambiguous condition
;exists if xt is not for a word defined via CREATE.
NFA_TO_BODY		FHEADER, ">BODY", NFA_GREATER_THAN, COMPILE
CFA_TO_BODY		DW	CF_DUMMY
			DW	CFA_EXIT

;>IN ( -- a-addr )
;a-addr is the address of a cell containing the offset in characters from the
;start of the input buffer to the start of the parse area.
NFA_TO_IN		FHEADER, ">IN", NFA_TO_BODY, COMPILE
CFA_TO_IN		DW	CF_CONSTANT_RT
			DW	TO_IN

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
NFA_TO_NUMBER		FHEADER, ">NUMBER", NFA_TO_IN, COMPILE
CFA_TO_NUMBER		DW	CF_DUMMY
			DW	CFA_EXIT

;>R 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( x -- ) ( R:  -- x )
;Move x to the return stack.
NFA_TO_R		FHEADER, ">R", NFA_TO_NUMBER, COMPILE
CFA_TO_R		DW	CF_DUMMY
			DW	CFA_EXIT

;?DUP ( x -- 0 | x x )
;Duplicate x if it is non-zero.
NFA_QUESTION_DUP	FHEADER, "?DUP", NFA_TO_R, COMPILE
CFA_QUESTION_DUP	DW	CF_DUMMY
			DW	CFA_EXIT

;@ ( a-addr -- x )
;x is the value stored at a-addr.
NFA_FETCH		FHEADER, "@", NFA_QUESTION_DUP, COMPILE
CFA_FETCH		DW		CF_FETCH
CF_FETCH		PS_CHECK_UF	1, CF_FETCH_PSUF ;check for underflow
			LDX		0,Y		;[TOS]	-> TOS
			MOVW		0,X, 0,Y	;
			NEXT

CF_FETCH_PSUF		JOB	FCORE_THROW_PSUF

	
;ABORT ( i*x -- ) ( R: j*x -- )
;Empty the data stack and perform the function of QUIT, which includes emptying
;the return stack, without displaying a message.
NFA_ABORT		FHEADER, "ABORT", NFA_FETCH, COMPILE
CFA_ABORT		DW	CF_ABORT
CF_ABORT		PS_RESET
			JOB	CF_QUIT
	
;ABORT" 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by a " (double-quote). Append the run-time semantics given
;below to the current definition.
;Run-time: ( i*x x1 --  | i*x ) ( R: j*x --  | j*x )
;Remove x1 from the stack. If any bit of x1 is not zero, display ccc and perform
;an implementation-defined abort sequence that includes the function of ABORT.
NFA_ABORT_QUOTE		FHEADER, 'ABORT"', NFA_ABORT, IMMEDIATE ;"
CFA_ABORT_QUOTE		DW	CF_ABORT_QUOTE
CF_ABORT_QUOTE

;ABORT" run-time semantics
CFA_ABORT_QUOTE_RT	DW	CF_INNER
			DW	CFA_CR			;print a line break
			DW	CFA_DOT_QUOTE_RT	;print the string
			DW	CFA_ABORT		;abort
			DW	CFA_EXIT
	
;ABS ( n -- u )
;u is the absolute value of n.
NFA_ABS			FHEADER, "ABS", NFA_ABORT_QUOTE, COMPILE
CFA_ABS			DW		CF_ABS
CF_ABS			PS_CHECK_UF	1, CF_ABS_PSUF	;check for underflow
			LDD		0,Y		;TOS	-> D
			BPL		CF_ABS_1	;ABS(D)	-> D
			COMA
			COMB
			ADDD		#1
			STD		0,Y 		;D	-> TOS
CF_ABS_1		NEXT

CF_ABS_PSUF		JOB	FCORE_THROW_PSUF
	
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
NFA_ACCEPT		FHEADER, "ACCEPT", NFA_ABS, COMPILE
CFA_ACCEPT		DW	CF_DUMMY
			DW	CFA_EXIT

;ALIGN ( -- )
;If the data-space pointer is not aligned, reserve enough space to align it.
NFA_ALIGN		FHEADER, "ALIGN", NFA_ACCEPT, COMPILE
CFA_ALIGN		DW	CF_DUMMY
			DW	CFA_EXIT

;ALIGNED ( addr -- a-addr )
;a-addr is the first aligned address greater than or equal to addr.
NFA_ALIGNED		FHEADER, "ALIGNED", NFA_ALIGN, COMPILE
CFA_ALIGNED		DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_ALLOT		FHEADER, "ALLOT", NFA_ALIGNED, COMPILE
CFA_ALLOT		DW	CF_DUMMY
			DW	CFA_EXIT

;AND ( x1 x2 -- x3 )
;x3 is the bit-by-bit logical and of x1 with x2.
NFA_AND			FHEADER, "AND", NFA_ALLOT, COMPILE
CFA_AND			DW		CF_AND
CF_AND			PS_PULL_D	2, CF_AND_PSUF	;PS 	 -> D
			ANDA		0,Y		;D & TOS -> D
			ANDB		1,Y
			STD		0,Y 		;D       -> TOS
			NEXT

CF_AND_PSUF		JOB	FCORE_THROW_PSUF
	
;BASE ( -- a-addr )
;a-addr is the address of a cell containing the current number-conversion radix
;{{2...36}}.
NFA_BASE		FHEADER, "BASE", NFA_AND, COMPILE
CFA_BASE		DW	CF_CONSTANT_RT
			DW	BASE

;BEGIN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- dest )
;Put the next location for a transfer of control, dest, onto the control flow
;stack. Append the run-time semantics given below to the current definition.
;Run-time: ( -- )
;Continue execution.
NFA_BEGIN		FHEADER, "BEGIN", NFA_BASE, IMMEDIATE
CFA_BEGIN		DW	CF_DUMMY
			DW	CFA_EXIT

;BL ( -- char )
;char is the character value for a space.
NFA_B_L			FHEADER, "BL", NFA_BEGIN, COMPILE
CFA_B_L			DW	CF_INNER
			DW	CFA_LITERAL
			DW	PRINT_SYM_SPACE
			DW	CFA_EXIT

;C! ( char c-addr -- )
;Store char at c-addr. When character size is smaller than cell size, only the
;number of low-order bits corresponding to character size are transferred.
NFA_C_STORE		FHEADER, "C!", NFA_B_L, COMPILE
CFA_C_STORE		DW	CF_DUMMY
			DW	CFA_EXIT

;C, ( char -- )
;Reserve space for one character in the data space and store char in the space.
;If the data-space pointer is character aligned when C, begins execution, it
;will remain character aligned when C, finishes execution. An ambiguous
;condition exists if the data-space pointer is not character-aligned prior to
;execution of C,.
NFA_C_COMMA		FHEADER, "C,", NFA_C_STORE, COMPILE
CFA_C_COMMA		DW	CF_DUMMY
			DW	CFA_EXIT

;C@ ( c-addr -- char )
;Fetch the character stored at c-addr. When the cell size is greater than
;character size, the unused high-order bits are all zeroes.
NFA_C_FETCH		FHEADER, "C@", NFA_C_COMMA, COMPILE
CFA_C_FETCH		DW	CF_DUMMY
			DW	CFA_EXIT

;CELL+ 	( a-addr1 -- a-addr2 )
;Add the size in address units of a cell to a-addr1, giving a-addr2.
NFA_CELL_PLUS		FHEADER, "CELL+", NFA_C_FETCH, COMPILE
CFA_CELL_PLUS		DW	CF_DUMMY
			DW	CFA_EXIT
	
;CELLS ( n1 -- n2 )
;n2 is the size in address units of n1 cells.
NFA_CELLS		FHEADER, "CELLS", NFA_CELL_PLUS, COMPILE
CFA_CELLS		DW	CF_DUMMY
			DW	CFA_EXIT

;CHAR 	( "<spaces>name" -- char )
;Skip leading space delimiters. Parse name delimited by a space. Put the value
;of its first character onto the stack.
NFA_CHAR		FHEADER, "CHAR", NFA_CELLS, COMPILE
CFA_CHAR		DW	CF_DUMMY
			DW	CFA_EXIT

;CHAR+ ( c-addr1 -- c-addr2 )
;Add the size in address units of a character to c-addr1, giving c-addr2.
NFA_CHAR_PLUS		FHEADER, "CHAR+", NFA_CHAR, COMPILE
CFA_CHAR_PLUS		DW	CF_DUMMY
			DW	CFA_EXIT

;CHARS ( n1 -- n2 )
;n2 is the size in address units of n1 characters.
NFA_CHARS		FHEADER, "CHARS", NFA_CHAR_PLUS, COMPILE
CFA_CHARS		DW	CF_DUMMY
			DW	CFA_EXIT

;CONSTANT ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a constant.
;name Execution: ( -- x )
;Place x on the stack.
NFA_CONSTANT		FHEADER, "CONSTANT", NFA_CHARS, COMPILE
CFA_CONSTANT		DW	CF_DUMMY
			DW	CFA_EXIT

;CONSTANT run-time semantics
;Push the contents of the first cell after the CFA onto the parameter stack
CF_CONSTANT_RT		PS_CHECK_OF	1, CF_CONSTANT_PSOF	;overflow check	=> 9 cycles
			MOVW		2,X, 0,Y		;[CFA+2] -> PS	=> 5 cycles
			STY		PSP			;		=> 3 cycles
			NEXT					;NEXT		=>15 cycles
								; 		  ---------
								;		  32 cycles
CF_CONSTANT_PSOF	JOB	FCORE_THROW_PSOF
                                                
;COUNT ( c-addr1 -- c-addr2 u )
;Return the character string specification for the counted string stored at
;c-addr1. c-addr2 is the address of the first character after c-addr1. u is the
;contents of the character at c-addr1, which is the length in characters of the
;string at c-addr2.
NFA_COUNT		FHEADER, "COUNT", NFA_CONSTANT, COMPILE
CFA_COUNT		DW	CF_DUMMY
			DW	CFA_EXIT

;CR ( -- )
;Cause subsequent output to appear at the beginning of the next line.
NFA_CR			FHEADER, "CR", NFA_COUNT, COMPILE
CFA_CR			DW	CF_CR
CF_CR			PRINT_LINE_BREAK	;(SSTACK: 11 bytes)
			NEXT	

;CREATE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. If the
;data-space pointer is not aligned, reserve enough data space to align it. The
;new data-space pointer defines name's data field. CREATE does not allocate data
;space in name's data field.
;name Execution: ( -- a-addr )
;a-addr is the address of name's data field. The execution semantics of name may
;be extended by using DOES>.
NFA_CREATE		FHEADER, "CREATE", NFA_CR, COMPILE
CFA_CREATE		DW	CF_DUMMY
			DW	CFA_EXIT

;DECIMAL ( -- )
;Set the numeric conversion radix to ten (decimal).
NFA_DECIMAL		FHEADER, "DECIMAL", NFA_CREATE, COMPILE
CFA_DECIMAL		DW	CF_DECIMAL
CF_DECIMAL		MOVW	#10, BASE
			NEXT

;DEPTH ( -- +n )
;+n is the number of single-cell values contained in the data stack before +n
;was placed on the stack.
NFA_DEPTH		FHEADER, "DEPTH", NFA_DECIMAL, COMPILE
CFA_DEPTH		DW	CF_DEPTH
CF_DEPTH		PS_CHECK_OF	1, CF_DEPTH_PSOF	;check for overflow
			LDD	PSP		 		;calculate stack depth
			SUBD	PS_EMPTY
			STD	0,Y
			STY	PSP
			NEXT

CF_DEPTH_PSOF		JOB	FCORE_THROW_PSOF
	
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
NFA_DO			FHEADER, "DO", NFA_DEPTH, COMPILE
CFA_DO			DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_DOES		FHEADER, "DOES", NFA_DO, IMMEDIATE
CFA_DOES		DW	CF_DUMMY
			DW	CFA_EXIT

;DROP ( x -- )
;Remove x from the stack.
;
;S12CForth implementation details:
; - Doesn't throw any exception, resets the parameter stack on underflow 
NFA_DROP		FHEADER, "DROP", NFA_DOES, COMPILE
CFA_DROP		DW		CF_DROP
CF_DROP			PS_CHECK_UF	1, CF_DROP_2	 	;check for underflow
			LEAY		2,Y			;increment stack pointer
CF_DROP_1		STY		PSP
			NEXT
CF_DROP_2		LDY	#PS_EMPTY 			;reset PS
			JOB	CF_DROP_1
	
;DUP ( x -- x x )
;Duplicate x.
NFA_DUP			FHEADER, "DUP", NFA_DROP, COMPILE
CFA_DUP			DW		CF_DUP
CF_DUP			PS_CHECK_UFOF	1, CF_DUP_PSUF, 1, CF_DUP_PSOF 	;check for under and overflow
			MOVW		2,Y, 0,Y			;duplicate stack entry
			STY		PSP
			NEXT

CF_DUP_PSUF		JOB	FCORE_THROW_PSUF
CF_DUP_PSOF		JOB	FCORE_THROW_PSOF
	
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
NFA_ELSE		FHEADER, "ELSE", NFA_DUP, IMMEDIATE
CFA_ELSE		DW	CF_DUMMY
			DW	CFA_EXIT

;EMIT ( x -- )
;If x is a graphic character in the implementation-defined character set,
;display x. The effect of EMIT for all other values of x is
;implementation-defined.
;When passed a character whose character-defining bits have a value between hex
;20 and 7E inclusive, the corresponding standard character, specified by 3.1.2.1
;Graphic characters, is displayed. Because different output devices can respond
;differently to control characters, programs that use control characters to
;perform specific functions have an environmental dependency. Each EMIT deals
;with only one character.
NFA_EMIT		FHEADER, "EMIT", NFA_DUP, COMPILE
CFA_EMIT		DW	CF_EMIT
CF_EMIT			PS_PULL_D	1, CF_EMIT_PSUF		;PS -> D (=char)
			SCI_TX					;print character (SSTACK: 8 bytes)
			NEXT
			
CF_EMIT_PSUF		JOB	FCORE_THROW_PSUF

;EMPTY ( -- ) Non-standard S12CForth extension!
;Delete all user defined words
NFA_EMPTY		FHEADER, "EMPTY", NFA_EMIT, COMPILE
CFA_EMPTY		DW	CF_EMPTY
CF_EMPTY		MOVW	#FCORE_LAST_NFA, LAST_NFA 	;set last NFA
			MOVW	#DICT_START,	 CP		;set compile pointer	
			NEXT
	
;ENVIRONMENT? ( c-addr u -- false | i*x true )
;c-addr is the address of a character string and u is the string's character
;count. u may have a value in the range from zero to an implementation-defined
;maximum which shall not be less than 31. The character string should contain a
;keyword from 3.2.6 Environmental queries or the optional word sets to be
;checked for correspondence with an attribute of the present environment. If the
;system treats the attribute as unknown, the returned flag is false; otherwise,
;the flag is true and the i*x returned is of the type specified in the table for
;the attribute queried.
NFA_ENVIRONMENT_QUERY	FHEADER, "ENVIRONMENT?", NFA_EMPTY, COMPILE
CFA_ENVIRONMENT_QUERY	DW	CF_DUMMY
			DW	CFA_EXIT

;EVALUATE ( i*x c-addr u -- j*x )
;Save the current input source specification. Store minus-one (-1) in SOURCE-ID
;if it is present. Make the string described by c-addr and u both the input
;source and input buffer, set >IN to zero, and interpret. When the parse area is
;empty, restore the prior input source specification. Other stack effects are
;due to the words EVALUATEd.
NFA_EVALUATE		FHEADER, "EVALUATE", NFA_ENVIRONMENT_QUERY, COMPILE
CFA_EVALUATE		DW	CF_DUMMY
			DW	CFA_EXIT

;EXECUTE ( i*x xt -- j*x )
;Remove xt from the stack and perform the semantics identified by it. Other
;stack effects are due to the word EXECUTEd.
NFA_EXECUTE		FHEADER, "EXECUTE", NFA_EVALUATE, COMPILE
CFA_EXECUTE		DW	CF_EXECUTE
CF_EXECUTE		PS_PULL_X	1, CF_EXECUTE_PSUF	;PS -> X (=CFA)		=>12 cycles
			JMP		[0,X]			;JUMP [CFA]             => 6 cycles
								;                         ---------
								;                         18 cycles
			
CF_EXECUTE_PSUF		JOB	FCORE_THROW_PSUF
	
;EXIT 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: nest-sys -- )
;Return control to the calling definition specified by nest-sys. Before
;executing EXIT within a do-loop, a program shall discard the loop-control
;parameters by executing UNLOOP.
NFA_EXIT		FHEADER, "EXIT", NFA_EXECUTE, COMPILE
CFA_EXIT		DW	CF_EXIT
CF_EXIT			RS_PULL_Y	CF_EXIT_RSUF		;RS -> Y (= IP)		=>12 cycles
			LDX		2,Y+			;IP += 2, CFA -> X	=> 3 cycles
			STY		IP 			;			=> 3 cycles 
			JMP		[0,X]			;JUMP [CFA]             => 6 cycles
								;                         ---------
								;                         24 cycles
			
CF_EXIT_RSUF		JOB	FCORE_THROW_RSUF
	
;FILL ( c-addr u char -- )
;If u is greater than zero, store char in each of u consecutive characters of
;memory beginning at c-addr.
NFA_FILL		FHEADER, "FILL", NFA_EXIT, COMPILE
CFA_FILL		DW	CF_DUMMY
			DW	CFA_EXIT

;FIND ( c-addr -- c-addr 0  |  xt 1  |  xt -1 )
;Find the definition named in the counted string at c-addr. If the definition is
;not found, return c-addr and zero. If the definition is found, return its
;execution token xt. If the definition is immediate, also return one (1),
;otherwise also return minus-one (-1). For a given string, the values returned
;by FIND while compiling may differ from those returned while not compiling.
;
;S12CForth implementation details:
;The search is case insensitive	
;Throws:
;"Parameter stack overflow"
;"Parameter stack underflow"
;
NFA_FIND	 	FHEADER, "FIND", NFA_FILL, COMPILE
CFA_FIND	 	DW	CF_FIND
CF_FIND		 	PS_CHECK_UFOF	1, CF_FIND_PSUF, 1, CF_FIND_PSOF	;check for over and underflow (PSP-new cells -> Y)
			;Initialize search
			LDX	LAST_NFA
			;Try to match first two characters 
			LDY	2,Y   						;start of word -> Y
			LDD	0,Y 						;First two characters -> D 
			BITA	#$80 						;check if word os only one character long
			BNE	CF_FIND_6					;single character word
			;Search multy character word (first 2 characters in D, current NFA in X, start of word in Y)
CF_FIND_1		CPD	3,X 						;compare first 2 characters
			BEQ	CF_FIND_4 					;first 2 characters match
			;Parse next NFA	(current NFA in X, start of word in Y)
CF_FIND_2		LDX	0,X 						;check next NFA
			BNE	CF_FIND_1 					;next iteration
			;Search was unsuccessfull (current NFA in X)
CF_FIND_3		LDY	PSP 						;push 0 onto PS
			MOVW	#$0000, 2,-Y
			STY	PSP
			NEXT
			;First 2 characters match (current NFA in X, start of word in Y)
CF_FIND_4		BITB	#$80 						;check if search is over
			BNE	CF_FIND_7 					;search was sucessful
			;Compare the remaining characters of the current NFA (current NFA in X, start of word in Y, index in A)
			LDAA	#2 						;set index to 3rd cfaracter
CF_FIND_5		LEAX	3,X 						;set X to start of name
			LDAB	A,X 						;Compare current character
			LEAX	-3,X 						;set X to NFA
			CMPA	A,Y
			BNE	CF_FIND_2 					;parse next NFA
			BITA	#$80 						;check if search is done
			BNE	CF_FIND_7					;search was successful
			IBNE	A, CF_FIND_5					;parsse next character
			;Name is too long -> search unsuccessful 
			JOB	CF_FIND_3
			;Search single character word (current NFA in X, first character in A)
CF_FIND_6		CMPA	3,X 						;compare first character
			BNE	CF_FIND_2 					;parse next NFA
			;Search was successful(current NFA in X)
CF_FIND_7		LDY	PSP						;put CFA onto PS
			LDAA	2,X 						
			TAB
			ANDA	#$7F
			LEAX	A,X
			STX	0,Y
			LDX	#$FFFF						;check immediate bit
			BITB	#$80	
			BEQ	CF_FIND_8 					;compile word
			LEAX	2,X 						;immediate word
CF_FIND_8		STX	2,-Y 						;push flag onto PS
			STY	PSP
			NEXT
		 	
CF_FIND_PSUF	 	JOB	FCORE_THROW_PSUF
CF_FIND_PSOF	 	JOB	FCORE_THROW_PSOF
	
;FM/MOD 
;f-m-slash-mod CORE 
;	( d1 n1 -- n2 n3 )
;Divide d1 by n1, giving the floored quotient n3 and the remainder n2. Input and
;output stack arguments are signed. An ambiguous condition exists if n1 is zero
;or if the quotient lies outside the range of a single-cell signed integer.
NFA_F_M_SLASH_MOD	FHEADER, "F_M_SLASH_MOD", NFA_FIND, COMPILE
CFA_F_M_SLASH_MOD	DW	CF_DUMMY
			DW	CFA_EXIT

;HERE ( -- addr )
;addr is the data-space pointer.
;Throws:
;"Parameter stack overflow"
;
NFA_HERE		FHEADER, "HERE", NFA_F_M_SLASH_MOD, COMPILE
CFA_HERE		DW	CF_CONSTANT_RT
			DW	CP

;HOLD ( char -- )
;Add char to the beginning of the pictured numeric output string. An ambiguous
;condition exists if HOLD executes outside of a <# #> delimited number
;conversion.
NFA_HOLD		FHEADER, "HOLD", NFA_HERE, COMPILE
CFA_HOLD		DW	CF_DUMMY
			DW	CFA_EXIT

;I 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- n|u ) ( R:  loop-sys -- loop-sys )
;n|u is a copy of the current (innermost) loop index. An ambiguous condition
;exists if the loop control parameters are unavailable.
NFA_I			FHEADER, "I", NFA_HOLD, COMPILE
CFA_I			DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_IF			FHEADER, "IF", NFA_I, COMPILE
CFA_IF			DW	CF_DUMMY
			DW	CFA_EXIT

;IMMEDIATE ( -- )
;Make the most recent definition an immediate word. An ambiguous condition
;exists if the most recent definition does not have a name.
NFA_IMMEDIATE		FHEADER, "IMMEDIATE", NFA_IF, COMPILE
CFA_IMMEDIATE		DW	CF_DUMMY
			DW	CFA_EXIT

;INVERT ( x1 -- x2 )
;Invert all bits of x1, giving its logical inverse x2.
NFA_INVERT		FHEADER, "INVERT", NFA_IMMEDIATE, COMPILE
CFA_INVERT		DW	CF_INVERT
CF_INVERT		PS_CHECK_UF	1, CF_INVERT_PSUF	;(PSP -> Y)
			LDD	0,Y
			COMA
			COMB
			STD	0,Y
			NEXT
			
CF_INVERT_PSUF		JOB	FCORE_THROW_PSUF
	
;J 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- n|u ) ( R: loop-sys1 loop-sys2 -- loop-sys1 loop-sys2 )
;n|u is a copy of the next-outer loop index. An ambiguous condition exists if
;the loop control parameters of the next-outer loop, loop-sys1, are unavailable.
NFA_J			FHEADER, "J", NFA_INVERT, COMPILE
CFA_J			DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_KEY			FHEADER, "KEY", NFA_J, COMPILE
CFA_KEY			DW	CF_KEY
CF_KEY			PS_CHECK_OF	1, CF_KEY_PSOF	;check for PS overflow (PSP-new cells -> Y)
			;Wait for data byte 
CF_KEY_1		SCI_RX				;receive one byte
			;Check for transmission errors 
			BITA	#(NF|FE|PE)		;ignore data if a transmission error has occured
			BNE	CF_KEY_1	
			;Check for illegal characters
			CMPB	#" " 			;first legal character in ASCII table
			BLO	CF_KEY_1
			CMPB	#"~"			;last legal character in ASCII table
			BHI	CF_KEY_1
 			;Put received character onto the stack
			CLRA
			STD	0,Y
			STY	PSP
			NEXT

CF_KEY_PSOF		JOB	FCORE_THROW_PSOF
		
;LEAVE 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the current loop control parameters. An ambiguous condition exists if
;they are unavailable. Continue execution immediately following the innermost
;syntactically enclosing DO ... LOOP or DO ... +LOOP.
NFA_LEAVE		FHEADER, "LEAVE", NFA_KEY, COMPILE
CFA_LEAVE		DW	CF_DUMMY
			DW	CFA_EXIT

;LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x -- )
;Append the run-time semantics given below to the current definition.
;Run-time: ( -- x )
;Place x on the stack.
NFA_LITERAL		FHEADER, "LITERAL", NFA_LEAVE, IMMEDIATE
CFA_LITERAL		DW	CF_DUMMY
			DW	CFA_EXIT

;LITERAL run-time semantics
CFA_LITERAL_RT		DW	CF_LITERAL_RT
CF_LITERAL_RT		PS_CHECK_OF	1, CF_LITERAL_PSOF 	;check for PS overflow (PSP-new cells -> Y)
			LDX	IP				;push the value at IP onto the PS
			MOVW	2,X+ 0,Y			; and increment the IP
			STX	IP
			STY	PSP
			NEXT
			
CF_LITERAL_PSOF		JOB	FCORE_THROW_PSOF	
	
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
NFA_LOOP		FHEADER, "LOOP", NFA_LITERAL, IMMEDIATE
CFA_LOOP		DW	CF_DUMMY
			DW	CFA_EXIT

;LSHIFT ( x1 u -- x2 )
;Perform a logical left shift of u bit-places on x1, giving x2. Put zeroes into
;the least significant bits vacated by the shift. An ambiguous condition exists
;if u is greater than or equal to the number of bits in a cell.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_L_SHIFT		FHEADER, "LSHIFT", NFA_LOOP, COMPILE
CFA_L_SHIFT		DW	CF_L_SHIFT
CF_L_SHIFT		PS_CHECK_UF	2, CF_L_SHIFT_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+	;u -> X
			BEQ	CF_L_SHIFT_2
			ANDB	#$0F
			TFR	B, X
			LDD	0,Y 	;x1 -> D
CF_L_SHIFT_1		LSLD		;shift loop
			DBNE	X, CF_L_SHIFT_1
			STD	0,Y	
CF_L_SHIFT_2		STY	PSP	
			NEXT
			
CF_L_SHIFT_PSUF		JOB	FCORE_THROW_PSUF		
	
;6.1.1810 M* 
;m-star CORE 
;	( n1 n2 -- d )
;d is the signed product of n1 times n2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_M_STAR		FHEADER, "M*", NFA_L_SHIFT, COMPILE
CFA_M_STAR		DW	CF_M_STAR
CF_M_STAR		PS_CHECK_UF	2, CF_M_STAR_PSUF ;check for underflow  (PSP -> Y)
			TFR	Y, X
			LDD	2,X
			LDY	0,X
			EMULS		;D * Y => Y:D
			STD	2,X
			STY	0,X
			NEXT
	
CF_M_STAR_PSUF		JOB	FCORE_THROW_PSUF		

;6.1.1870 MAX ( n1 n2 -- n3 )
;n3 is the greater of n1 and n2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_MAX			FHEADER, "MAX", NFA_M_STAR, COMPILE
CFA_MAX			DW	CF_MAX
CF_MAX			PS_CHECK_UF	2, CF_MAX_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+
			CPD	0,Y
			BLE	CF_MAX_1
			MOVW	-2,Y, 0,Y
CF_MAX_1		STY	PSP
			NEXT
		
CF_MAX_PSUF		JOB	FCORE_THROW_PSUF		
	
;6.1.1880 MIN ( n1 n2 -- n3 )
;n3 is the lesser of n1 and n2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_MIN			FHEADER, "MIN", NFA_MAX, COMPILE
CFA_MIN			DW	CF_MIN
CF_MIN			PS_CHECK_UF	2, CF_MIN_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+
			CPD	0,Y
			BGE	CF_MIN_1
			MOVW	-2,Y, 0,Y
CF_MIN_1		STY	PSP
			NEXT

CF_MIN_PSUF		JOB	FCORE_THROW_PSUF		

;MOD ( n1 n2 -- n3 )
;Divide n1 by n2, giving the single-cell remainder n3. An ambiguous condition
;exists if n2 is zero. If n1 and n2 differ in sign, the implementation-defined
;result returned will be the same as that returned by either the phrase
;>R S>D R> FM/MOD DROP or the phrase >R S>D R> SM/REM DROP.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Division by zero"
;
NFA_MOD			FHEADER, "MOD", NFA_MIN, COMPILE
CFA_MOD			DW	CF_MOD
CF_MOD			PS_CHECK_UF	2, CF_MOD_PSUF ;check for underflow  (PSP -> Y)
			LDX	2,Y+
			BEQ	CF_MOD_0DIV
			LDD	0,Y
			IDIVS	;D/X=>X, D%X=>D
			STD	0,Y
			STY	PSP
			NEXT

CF_MOD_PSUF		JOB	FCORE_THROW_PSUF		
CF_MOD_0DIV		JOB	FCORE_THROW_0DIV
	
;MOVE ( addr1 addr2 u -- )
;If u is grater than zero, copy the contents of u consecutive address units at
;addr1 to the u consecutive address units at addr2. After MOVE completes, the u
;consecutive address units at addr2 contain exactly what the u consecutive
;address units at addr1 contained before the move.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_MOVE		FHEADER, "MOVE", NFA_MOD, COMPILE
CFA_MOVE		DW	CF_MOVE
CF_MOVE			PS_CHECK_UF	3, CF_MOVE_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+			;load parameters
			BEQ	CF_MOVE_3		;u is zero
			LDX	4,Y+
			STY	PSP
			LDY	-2,Y
			;Copy loop
CF_MOVE_1		MOVW	2,Y+, 2,X+
			DBNE	D, CF_MOVE_1
CF_MOVE_2		NEXT
			;u is zero 
CF_MOVE_3		LEAY	4,Y			
			STY	PSP
			JOB	CF_MOVE_2

CF_MOVE_PSUF		JOB	FCORE_THROW_PSUF		
	
;NAME ("<spaces>ccc<space>" -- c-addr ) Non-standard S12CForth extension!
;Parse whitespace separated word: 
;Skip leading whitespaces (" ", TAB, and non-printables). Parse characters ccc
;delimited by a whitespace (" ", TAB, or non-printable character). c-addr is
;the address of a terminated upper-case string. A resulting string of zero
; length will return the address $0000.
NFA_NAME		FHEADER, "NAME", NFA_MOVE, COMPILE
CFA_NAME		DW	CF_NAME
CF_NAME			PS_CHECK_OF	1, CF_NAME_PSOF ;(PSP-new cells -> Y)
			;Skip leading whitespaces
			LDX	TO_IN			;current >IN -> X	
CF_NAME_1		CPX	NUMBER_TIB		;check for the end of the input buffer
			BHI	CF_NAME_5		;return empty string
			LDAB	TIB_START,X
			LEAX	1,X			;increment string pointer
			CMPB	#"!"	
			BLO	CF_NAME_1 		;whitespace
			CMPB	#"~"
			BHI	CF_NAME_1		;whitespace
			;Push start address onto the PS (index of 2nd character in X) 
			LEAX	TIB_START-1,X 		;calculate string pointer
			STX	0,Y			;push string pointer onto the stack
			STY	PSP
			LEAX	-TIB_START,X 		;revert >IN	
			;Convert to upper-case andind trailing whitespace  (index of 1st character in X)
CF_NAME_2		LDD	TIB_START,X		;next two characters -> D
			CMPA	#"A"			;convert current character to upper case
			BLO	CF_NAME_3
			CMPA	#"Z"
			BHI	CF_NAME_3
			SUBA	#$20			;"a"-"A"
CF_NAME_3		STAA	TIB_START,X
			LEAX	1,X			;increment string pointer
			CMPB	#"!"	
			BLO	CF_NAME_4 		;terminate string
			CMPB	#"~"
			BHI	CF_NAME_4		;terminate strung
			CPX	NUMBER_TIB		;check for the end of the input buffer
			BLS	CF_NAME_2		;check next character
			;Terminate string (last character in A, pointer to last character in X)
CF_NAME_4		ORAA	$80			;add termination bit to last character
			STAA	 TIB_START-1,X
			;Adjust >IN pointer
			STX	TO_IN
			NEXT
			;Return empty string
CF_NAME_5		STX	TO_IN			;update >IN pointer
			MOVW	#$0000 0,Y		;push $0000 onto the stack
			STY	PSP
			NEXT
			
CF_NAME_PSOF		JOB	FCORE_THROW_PSOF
		
;NEGATE ( n1 -- n2 )
;Negate n1, giving its arithmetic inverse n2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_NEGATE		FHEADER, "NEGATE", NFA_NAME, COMPILE
CFA_NEGATE		DW	CF_NEGATE
CF_NEGATE		PS_CHECK_UF	1, CF_NEGATE_PSUF ;check for underflow  (PSP -> Y)
			LDD	0,Y
			COMA
			COMB
			ADDD	#1
			STD	0,Y
			NEXT

CF_NEGATE_PSUF		JOB	FCORE_THROW_PSUF		
	
;OR ( x1 x2 -- x3 )
;x3 is the bit-by-bit inclusive-or of x1 with x2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
NFA_OR			FHEADER, "OR", NFA_NEGATE, COMPILE
CFA_OR			DW	CF_OR
CF_OR			PS_CHECK_UF	2, CF_OR_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+
			ORAA	0,Y
			ORAB	1,Y
			STD	0,Y
			NEXT

CF_OR_PSUF		JOB	FCORE_THROW_PSUF		
	
;OVER ( x1 x2 -- x1 x2 x1 )
;Place a copy of x1 on top of the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
NFA_OVER		FHEADER, "OVER", NFA_OR, COMPILE
CFA_OVER		DW	CF_OVER
CF_OVER			PS_CHECK_UFOF	2, CF_OVER_PSUF, 1, CF_OVER_PSOF ;check for under and overflow (PSP-2 -> Y)
			MOVW	4,Y, 0,Y
			STY	PSP
			NEXT

CF_OVER_PSUF		JOB	FCORE_THROW_PSUF
CF_OVER_PSOF		JOB	FCORE_THROW_PSOF

;POSTPONE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Find name.
;Append the compilation semantics of name to the current definition. An
;ambiguous condition exists if name is not found.
NFA_POSTPONE		FHEADER, "POSTPONE", NFA_OVER, COMPILE
CFA_POSTPONE		DW	CF_DUMMY
			DW	CFA_EXIT

;QUIT ( -- )  ( R:  i*x -- )
;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;input device the input source, and enter interpretation state. Do not display a
;message. Repeat the following:
;Accept a line from the input source into the input buffer, set >IN to zero, and
;interpret.
;Display the implementation-defined system prompt if in interpretation state,
;all processing has been completed, and no ambiguous condition exists.
;
;S12CForth implementation details:
;Throws:
;"Return stack underflow"
;"Return stack overflow"
;
NFA_QUIT		FHEADER, "QUIT", NFA_POSTPONE, COMPILE
CFA_QUIT		DW	CF_QUIT
			;Empty RS and go into interpretation state 
CF_QUIT			RS_RESET		;empty the return stack
			MOVW	#$0000, STATE	;enter interpretation state
			;Print input prompt 
CF_QUIT_1		PRINT_LINE_BREAK	;send input prompt
			LDX	#FCORE_INPUT_PROMPT
			PRINT_STR
			;Query comand line
			LED_BUSY_OFF
			EXEC_CF	CF_QUERY, CF_QUIT_RSOF, CF_QUIT_RSUF	;get command line
			LED_BUSY_ON
			;Parse next word of the command line
CF_QUIT_2		EXEC_CF	CF_WORD, CF_QUIT_RSOF, CF_QUIT_RSUF	;parse next word
			LDD	[PSP]		;check if there is a word left
			BEQ	CF_QUIT_9 	;no words left
			;Check STATE 
			LDD	STATE
			BEQ	CF_QUIT_5 	;interpretation state
			;Compile state
			;=============
			EXEC_CF	CF_FIND, CF_QUIT_RSOF, CF_QUIT_RSUF 	;search for word in dictionary
			;Check return value (PS: c-addr 0 | xt 1 | xt -1) 
			LDY 	PSP
			LDD	2,Y+
			BEQ	CF_QUIT_3 	;word not in dictionary	
			DBEQ	D, CF_QUIT_6	;immediate word
			;Compile word (PS: xt -1, PSP+2 in Y)
			LDX	CP		;CP -> X
			MOVW	2,Y+, 2,X+	;compile
			STY	PSP
			STX	CP
			JOB	CF_QUIT_2 	;parse next word			
			;Check if word is an immediate value (PS: c-addr 0, PSP+2 in Y)
CF_QUIT_3		STY	PSP 		;update PSP
			EXEC_CF	CF_NUMBER, CF_QUIT_RSOF, CF_QUIT_RSUF
			;Check return value (PS: c-addr 0 | x 1 | xd 2)
			LDY 	PSP
			LDD	2,Y+
			BEQ	CF_QUIT_8 	;undefined word
			DBNE	D, CF_QUIT_4	;double cell immediate value
			;Single cell immediate value (PS: x 1, PSP+2 in Y)
			LDX	CP
			MOVW	#CF_LITERAL_RT, 2,X+
			MOVW	2,Y+, 2,X+
			STX	CP
			STY	PSP
			JOB	CF_QUIT_2 	;parse next word			
			;Double cell immediate value (PS: xd 2, PSP+2 in Y)
CF_QUIT_4		LDX	CP
			MOVW	#CF_TWO_LITERAL_RT, 2,X+
			MOVW	2,Y+, 2,X+
			MOVW	2,Y+, 2,X+
			STX	CP
			STY	PSP
			JOB	CF_QUIT_2 	;parse next word
			;Interpretation state
			;====================
CF_QUIT_5		EXEC_CF	CF_FIND, CF_QUIT_RSOF, CF_QUIT_RSUF	;search for word in dictionary
			;Check return value (PS: c-addr 0 | xt 1 | xt -1) 
			LDY 	PSP
			LDD	2,Y+
			BEQ	CF_QUIT_7 	;word not in dictionary	
			;Execute word (PS: xt -1, PSP+2 in Y)
CF_QUIT_6		STY	PSP	
			EXEC_CF CF_EXECUTE, CF_QUIT_RSOF, CF_QUIT_RSUF
			JOB	CF_QUIT_2 	;parse next word
			;Check if word is an immediate value (PS: c-addr 0, PSP+2 in Y)
CF_QUIT_7		STY	PSP 		;update PSP
			EXEC_CF	CF_NUMBER, CF_QUIT_RSOF, CF_QUIT_RSUF
			;Check return value (PS: c-addr 0 | x 1 | xd 2)
			LDY 	PSP
			LDD	2,Y+
			BEQ	CF_QUIT_3 	;word not in dictionary	
			;Leave immediate value on the PS (PS: x 1 | xd 2, PSP+2 in Y) 
			STY	PSP
			JOB	CF_QUIT_2 	;parse next word
			;Undefined word 
CF_QUIT_8		FEXCPT_THROW	FCORE_EC_UDEFWORD
			;No words left
CF_QUIT_9		LDD	STATE	  	;check state
			BNE	CF_QUIT 	;interpretationcompile state
			;Print "ok" 
			LDX	#FCORE_SYSTEM_PROMPT
			PRINT_STR
			JOB CF_QUIT

CF_QUIT_RSUF		EQU	FCORE_THROW_RSUF
CF_QUIT_RSOF		EQU	FCORE_THROW_RSOF
	
;R> 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x ) ( R:  x -- )
;Move x from the return stack to the data stack.
;
;S12CForth implementation details:
;Throws:
;"Return stack underflow"
;"Parameter stack overflow"
;
NFA_R_FROM		FHEADER, "R>", NFA_QUIT, COMPILE
CFA_R_FROM		DW	CF_R_FROM
CF_R_FROM		RS_CHECK_UF 	1, CF_R_FROM_RSUF	;check for RS underflow 
			PS_CHECK_OF	1, CF_R_FROM_PSOF 	;check for PS overflow (PSP-2 -> Y)
			LDX	RSP
			MOVW	2,X+, 0,Y
			STX	RSP
			STY	PSP
			NEXT
	
CF_R_FROM_RSUF		JOB	FCORE_THROW_RSUF
CF_R_FROM_PSOF		JOB	FCORE_THROW_PSOF
	
;R@ 
;r-fetch CORE 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x ) ( R:  x -- x )
;Copy x from the return stack to the data stack.
NFA_R_FETCH		FHEADER, "R@", NFA_R_FROM, COMPILE
CFA_R_FETCH		DW	CF_R_FETCH
CF_R_FETCH		RS_CHECK_UF 	1, CF_R_FETCH_RSUF	;check for RS underflow 
			PS_CHECK_OF	1, CF_R_FETCH_PSOF 	;check for PS overflow (PSP-2 -> Y)
			LDX	RSP
			MOVW	0,X, 0,Y
			STY	PSP
			NEXT
	
CF_R_FETCH_RSUF		JOB	FCORE_THROW_RSUF
CF_R_FETCH_PSOF		JOB	FCORE_THROW_PSOF

;RECURSE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( -- )
;Append the execution semantics of the current definition to the current
;definition. An ambiguous condition exists if RECURSE appears in a definition
;after DOES>.
NFA_RECURSE		FHEADER, "RECURSE", NFA_R_FETCH, COMPILE
CFA_RECURSE		DW	CF_DUMMY
			DW	CFA_EXIT

;REPEAT 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest. Resolve the forward reference orig using the
;location following the appended run-time semantics.
;Run-time: ( -- )
;Continue execution at the location given by dest.
NFA_REPEAT		FHEADER, "REPEAT", NFA_RECURSE, COMPILE
CFA_REPEAT		DW	CF_DUMMY
			DW	CFA_EXIT

;ROT ( x1 x2 x3 -- x2 x3 x1 )
;Rotate the top three stack entries.
NFA_ROT			FHEADER, "ROT", NFA_REPEAT, COMPILE
CFA_ROT			DW	CF_DUMMY
			DW	CFA_EXIT

;RSHIFT ( x1 u -- x2 )
;Perform a logical right shift of u bit-places on x1, giving x2. Put zeroes into
;the most significant bits vacated by the shift. An ambiguous condition exists
;if u is greater than or equal to the number of bits in a cell.
NFA_R_SHIFT		FHEADER, "RSHIFT", NFA_ROT, COMPILE
CFA_R_SHIFT		DW	CF_R_SHIFT
CF_R_SHIFT		PS_CHECK_UF	2, CF_R_SHIFT_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+	;u -> X
			BEQ	CF_R_SHIFT_2
			ANDB	#$0F
			TFR	B, X
			LDD	0,Y 	;x1 -> D
CF_R_SHIFT_1		LSRD		;shift loop
			DBNE	X, CF_R_SHIFT_1
			STD	0,Y	
CF_R_SHIFT_2		STY	PSP	
			NEXT
			
CF_R_SHIFT_PSUF		JOB	FCORE_THROW_PSUF		
	
;S" 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote). Append the run-time semantics given
;below to the current definition.
;Run-time: ( -- c-addr u )
;Return c-addr and u describing a string consisting of the characters ccc. A
;program shall not alter the returned string.
NFA_S_QUOTE		FHEADER, 'S"', NFA_R_SHIFT, COMPILE ;"
CFA_S_QUOTE		DW	CF_DUMMY
			DW	CFA_EXIT

;S>D ( n -- d )
;Convert the number n to the double-cell number d with the same numerical value.
NFA_S_TO_D		FHEADER, "S>D", NFA_S_QUOTE, COMPILE
CFA_S_TO_D		DW	CF_DUMMY
			DW	CFA_EXIT

;SIGN ( n -- )
;If n is negative, add a minus sign to the beginning of the pictured numeric
;output string. An ambiguous condition exists if SIGN executes outside of a
;<# #> delimited number conversion.
NFA_SIGN		FHEADER, "SIGN", NFA_S_TO_D, COMPILE
CFA_SIGN		DW	CF_DUMMY
			DW	CFA_EXIT
	
;SM/REM ( d1 n1 -- n2 n3 )
;Divide d1 by n1, giving the symmetric quotient n3 and the remainder n2. Input
;and output stack arguments are signed. An ambiguous condition exists if n1 is
;zero or if the quotient lies outside the range of a single-cell signed integer.
NFA_S_M_SLASH_REM	FHEADER, "SM/REM", NFA_SIGN, COMPILE
CFA_S_M_SLASH_REM	DW	CF_DUMMY
			DW	CFA_EXIT

;SOURCE ( -- c-addr u )
;c-addr is the address of, and u is the number of characters in, the input
;buffer.
NFA_SOURCE		FHEADER, "SOURCE", NFA_S_M_SLASH_REM, COMPILE
CFA_SOURCE		DW	CF_DUMMY
			DW	CFA_EXIT

;SPACE ( -- )
;Display one space.
NFA_SPACE		FHEADER, "SPACE", NFA_SOURCE, COMPILE
CFA_SPACE		DW	CF_SPACE
CF_SPACE		PRINT_SPC			;print one space
			NEXT

;SPACES ( n -- )
;If n is greater than zero, display n spaces.
NFA_SPACES		FHEADER, "SPACES", NFA_SPACE, COMPILE
CFA_SPACES		DW	CF_SPACES
CF_SPACES		PS_PULL_D	1,CF_SPACES_PSUF	;pop PS
			TAB
			PRINT_SPCS				;print spaces
			NEXT
			
CF_SPACES_PSUF		JOB	FCORE_THROW_PSUF
	
;STATE ( -- a-addr )
;a-addr is the address of a cell containing the compilation-state flag. STATE is
;true when in compilation state, false otherwise. The true value in STATE is
;non-zero, but is otherwise implementation-defined. Only the following standard
;words alter the value in STATE: : (colon), ; (semicolon), ABORT, QUIT, :NONAME,
;[ (left-bracket), and ] (right-bracket).
;Note: A program shall not directly alter the contents of STATE.
NFA_STATE		FHEADER, "STATE", NFA_SPACES, COMPILE
CFA_STATE		DW	CF_CONSTANT_RT
			DW	STATE

;SWAP ( x1 x2 -- x2 x1 )
;Exchange the top two stack items.
NFA_SWAP		FHEADER, "SWAP", NFA_STATE, COMPILE
CFA_SWAP		DW	CF_DUMMY
			DW	CFA_EXIT

;THEN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig -- )
;Append the run-time semantics given below to the current definition. Resolve
;the forward reference orig using the location of the appended run-time
;semantics.
;Run-time: ( -- )
;Continue execution.
NFA_THEN		FHEADER, "THEN", NFA_SWAP, IMMEDIATE
CFA_THEN		DW	CF_DUMMY
			DW	CFA_EXIT

;TYPE ( c-addr u -- )
;If u is greater than zero, display the character string specified by c-addr and
;u.
;When passed a character in a character string whose character-defining bits
;have a value between hex 20 and 7E inclusive, the corresponding standard
;character, specified by 3.1.2.1 graphic characters, is displayed. Because
;different output devices can respond differently to control characters,
;programs that use control characters to perform specific functions have an
;environmental dependency.
NFA_TYPE		FHEADER, "TYPE", NFA_THEN, COMPILE
CFA_TYPE		DW	CF_DUMMY
			DW	CFA_EXIT

;U. ( u -- )
;Display u in free field format.
NFA_U_DOT		FHEADER, "U.", NFA_TYPE, COMPILE
CFA_U_DOT		DW	CF_DUMMY
			DW	CFA_EXIT

;U< ( u1 u2 -- flag )
;flag is true if and only if u1 is less than u2.
NFA_U_LESS_THEN		FHEADER, "U>", NFA_U_DOT, COMPILE
CFA_U_LESS_THEN		DW	CF_DUMMY
			DW	CFA_EXIT

;UM* ( u1 u2 -- ud )
;Multiply u1 by u2, giving the unsigned double-cell product ud. All values and
;arithmetic are unsigned.
NFA_U_M_STAR		FHEADER, "UM*", NFA_U_LESS_THEN, COMPILE
CFA_U_M_STAR		DW	CF_DUMMY
			DW	CFA_EXIT

;UM/MOD ( ud u1 -- u2 u3 )
;Divide ud by u1, giving the quotient u3 and the remainder u2. All values and
;arithmetic are unsigned. An ambiguous condition exists if u1 is zero or if the
;quotient lies outside the range of a single-cell unsigned integer.
NFA_U_M_SLASH_MOD	FHEADER, "UM/MOD", NFA_U_M_STAR, COMPILE
CFA_U_M_SLASH_MOD	DW	CF_DUMMY
			DW	CFA_EXIT

;UNLOOP 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the loop-control parameters for the current nesting level. An UNLOOP is
;required for each nesting level before the definition may be EXITed. An
;ambiguous condition exists if the loop-control parameters are unavailable.
NFA_UNLOOP		FHEADER, "UNLOOP", NFA_U_M_SLASH_MOD, COMPILE
CFA_UNLOOP		DW	CF_DUMMY
			DW	CFA_EXIT

;UNTIL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by
;dest.
NFA_UNTIL		FHEADER, "UNTIL", NFA_UNLOOP, COMPILE
CFA_UNTIL		DW	CF_DUMMY
			DW	CFA_EXIT

;UNTIL run-time semantics 
CFA_UNTIL_RT		DW	CF_UNTIL_RT
CF_UNTIL_RT		PS_PULL_X	1, CF_UNTIL_PSUF
			CPX	#$0000		;check is cell equals 0
			BEQ	CF_UNTIL_RT_1	;cell is zero 
			SKIP_NEXT		;increment IP and do NEXT
CF_UNTIL_RT_1		JUMP_NEXT
			
CF_UNTIL_PSUF		JOB	FCORE_THROW_PSUF	

;VARIABLE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. Reserve one
;cell of data space at an aligned address.
;name is referred to as a variable.
;name Execution: ( -- a-addr )
;a-addr is the address of the reserved cell. A program is responsible for
;initializing the contents of the reserved cell.
NFA_VARIABLE		FHEADER, "VARIABLE", NFA_UNTIL, COMPILE
CFA_VARIABLE		DW	CF_DUMMY
			DW	CFA_EXIT

;Run-time of VARIABLE
CFA_VARIABLE_RT		DW	CF_VARIABLE_RT	
CF_VARIABLE_RT		PS_CHECK_OF	1, CF_VARIABLE_PSOF	;overflow check	=> 9 cycles
			LEAX		2,X			;CFA+2 -> PS	=> 2 cycles
			STX		0,Y			;		=> 3 cycles
			STY		PSP			;		=> 3 cycles
			NEXT					;NEXT		=>15 cycles
							; 		  ---------
							;		  32 cycles
CF_VARIABLE_PSOF	JOB	FCORE_THROW_PSOF
	
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
NFA_WHILE		FHEADER, "WHILE", NFA_VARIABLE, COMPILE
CFA_WHILE		DW	CF_DUMMY
			DW	CFA_EXIT

;WHILE run-time semantics 
CFA_WHILE_RT		EQU	CFA_UNTIL_RT 	;same as UNTIL run-time semantics
	
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
;
;S12CForth implementation details:
;The resulting counted string is implemented as terminated string (bit 7 of
;of the last character is set). A resulting string of zero length will return
;the address $0000.
;Throws:
;"Parameter stack underflow"
;"TIB pointer out of range"

NFA_WORD		FHEADER, "WORD", NFA_WHILE, COMPILE
CFA_WORD		DW	CF_WORD
CF_WORD			PS_CHECK_OF	1, CF_WORD_PSOF ;(PSP -> Y)
			TIB_CHECK_OF	0, CF_WORD_TIBOF
			
			;Skip leading delimeters
			LDX	TO_IN			;current >IN -> X	
CF_WORD_1		CPX	NUMBER_TIB		;check for the end of the input buffer
			BHI	CF_WORD_4		;return empty string
			LDAB	TIB_START,X
			LEAX	1,X
			CMPB	1,Y	
			BEQ	CF_WORD_1
			;Beginning of word detected (X points to the 2nd character of the word) 
			LEAX	TIB_START-1,X 		;calculate string pointer
			STX	0,Y			;put string pointer on TOS
			LEAX	-TIB_START,X 		;revert >IN 	
			;Find trailing delimeter  (X points to the 1st character of the word)
CF_WORD_2		LEAX	1,X
			CPX	NUMBER_TIB		;check for the end of the input buffer
			BHI	CF_WORD_3		;terminate word
			LDAB	TIB_START,X
			CMPB	1,Y
			BNE	CF_WORD_2
			;Terminate word (X holds next >IN value)
CF_WORD_3		LDAB	1,-X			;terminate word
			ORAB	$80
			STAB	2,X+			;adcance >IN pointer past the delimeter
			STX	TO_IN			;update >IN pointer
			NEXT
			;Return empty string
CF_WORD_4		STX	TO_IN			;update >IN pointer
			MOVW	#$0000 0,Y		;push $0000 onto the stack
			NEXT
			
CF_WORD_PSOF		JOB	FCORE_THROW_PSOF
CF_WORD_TIBOF		JOB	FCORE_THROW_TIBOF
		
;XOR ( x1 x2 -- x3 )
;x3 is the bit-by-bit exclusive-or of x1 with x2.
NFA_XOR			FHEADER, "XOR", NFA_WORD, COMPILE
CFA_XOR			DW	CF_DUMMY
			DW	CFA_EXIT

;[ 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: Perform the execution semantics given below.
;Execution: ( -- )
;Enter interpretation state. [ is an immediate word.
NFA_LEFT_BRACKET	FHEADER, "[", NFA_XOR, IMMEDIATE
CFA_LEFT_BRACKET	DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_BRACKET_TICK	FHEADER, "[']", NFA_LEFT_BRACKET, IMMEDIATE
CFA_BRACKET_TICK	DW	CF_DUMMY
			DW	CFA_EXIT

;[CHAR] 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Append the
;run-time semantics given below to the current definition.
;Run-time: ( -- char )
;Place char, the value of the first character of name, on the stack.
NFA_BRACKET_CHAR	FHEADER, "[CHAR]", NFA_BRACKET_TICK, IMMEDIATE
CFA_BRACKET_CHAR	DW	CF_DUMMY
			DW	CFA_EXIT

;] ( -- )
;Enter compilation state.
NFA_RIGHT_BRACKET	FHEADER, "]", NFA_BRACKET_CHAR, IMMEDIATE
CFA_RIGHT_BRACKET	DW	CF_DUMMY
			DW	CFA_EXIT

;#Core extension words:
; =====================

;CP ( -- addr)
;Compile pointer (points to the next free byte after the user dictionary)
NFA_CP			FHEADER, "CP", NFA_RIGHT_BRACKET, COMPILE
CFA_CP			DW	CF_VARIABLE_RT
			DW	CP
	
;#TIB ( -- a-addr )
;a-addr is the address of a cell containing the number of characters in the
;terminal input buffer.
;Note: This word is obsolescent and is included as a concession to existing
;      implementations.
NFA_NUMBER_TIB		FHEADER, "#TIB", NFA_CP, COMPILE
CFA_NUMBER_TIB		DW	CF_CONSTANT_RT
			DW	NUMBER_TIB

;.( 
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<paren>" -- )
;Parse and display ccc delimited by ) (right parenthesis). .( is an immediate
;word.
NFA_DOT_PAREN		FHEADER, ".(", NFA_NUMBER_TIB, IMMEDIATE
CFA_DOT_PAREN		DW	CF_DUMMY
			DW	CFA_EXIT

;.R ( n1 n2 -- )
;Display n1 right aligned in a field n2 characters wide. If the number of
;characters required to display n1 is greater than n2, all digits are displayed
;with no leading spaces in a field as wide as necessary.
NFA_DOT_R		FHEADER, ".R", NFA_DOT_PAREN, COMPILE
CFA_DOT_R		DW	CF_DUMMY
			DW	CFA_EXIT

;0<> ( x -- flag )
;flag is true if and only if x is not equal to zero.
NFA_ZERO_NOT_EQUALS	FHEADER, "0<>", NFA_DOT_R, COMPILE
CFA_ZERO_NOT_EQUALS	DW	CF_DUMMY
			DW	CFA_EXIT

;0> ( n -- flag )
;flag is true if and only if n is greater than zero.
NFA_ZERO_GREATER	FHEADER, "0>", NFA_ZERO_NOT_EQUALS, COMPILE
CFA_ZERO_GREATER	DW	CF_DUMMY
			DW	CFA_EXIT

;2>R 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution:      ( x1 x2 -- ) ( R:  -- x1 x2 )
;Transfer cell pair x1 x2 to the return stack. Semantically equivalent to
;SWAP >R >R .
NFA_TWO_TO_R		FHEADER, "2>R", NFA_ZERO_GREATER, COMPILE
CFA_TWO_TO_R		DW	CF_DUMMY
			DW	CFA_EXIT

;2R> 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x1 x2 ) ( R:  x1 x2 -- )
;Transfer cell pair x1 x2 from the return stack. Semantically equivalent to
;R> R> SWAP .
NFA_TWO_FROM_R		FHEADER, "2R>", NFA_TWO_TO_R, COMPILE
CFA_TWO_FROM_R		DW	CF_DUMMY
			DW	CFA_EXIT

;2R@ 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x1 x2 ) ( R:  x1 x2 -- x1 x2 )
;Copy cell pair x1 x2 from the return stack. Semantically equivalent to
;R> R> 2DUP >R >R SWAP .
NFA_TWO_R_FETCH		FHEADER, "2R@", NFA_TWO_FROM_R, COMPILE
CFA_TWO_R_FETCH		DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_COLON_NONAME	FHEADER, ":NONAME", NFA_TWO_R_FETCH, IMMEDIATE
CFA_COLON_NONAME	DW	CF_DUMMY
			DW	CFA_EXIT

;<> ( x1 x2 -- flag )
;flag is true if and only if x1 is not bit-for-bit the same as x2.
NFA_NOT_EQUALS		FHEADER, "<>", NFA_COLON_NONAME, COMPILE
CFA_NOT_EQUALS		DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_QUESTION_DO		FHEADER, "?DO", NFA_NOT_EQUALS, COMPILE
CFA_QUESTION_DO		DW	CF_DUMMY
			DW	CFA_EXIT

;AGAIN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( -- )
;Continue execution at the location specified by dest. If no other control flow
;words are used, any program code after AGAIN will not be executed.
NFA_AGAIN		FHEADER, "AGAIN", NFA_QUESTION_DO, COMPILE
CFA_AGAIN		DW	CF_DUMMY
			DW	CFA_EXIT

;Run-time of AGAIN 
CFA_AGAIN_RT		DW	CF_AGAIN_RT
CF_AGAIN_RT		JUMP_NEXT

;C" 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote) and append the run-time semantics given
;below to the current definition.
;Run-time: ( -- c-addr )
;Return c-addr, a counted string consisting of the characters ccc. A program
;shall not alter the returned string.
NFA_C_QUOTE		FHEADER, 'C"', NFA_AGAIN, COMPILE ;"
CFA_C_QUOTE		DW	CF_DUMMY
			DW	CFA_EXIT

;CASE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- case-sys )
;Mark the start of the CASE ... OF ... ENDOF ... ENDCASE structure. Append the
;run-time semantics given below to the current definition.
;Run-time: ( -- )
;Continue execution.
NFA_CASE		FHEADER, "CASE", NFA_C_QUOTE, COMPILE
CFA_CASE		DW	CF_DUMMY
			DW	CFA_EXIT

;COMPILE, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( xt -- )
;Append the execution semantics of the definition represented by xt to the
;execution semantics of the current definition.
NFA_COMPILE_COMMA	FHEADER, "COMPILE,", NFA_CASE, COMPILE
CFA_COMPILE_COMMA	DW	CF_DUMMY
			DW	CFA_EXIT

;CONVERT ( ud1 c-addr1 -- ud2 c-addr2 )
;ud2 is the result of converting the characters within the text beginning at the
;first character after c-addr1 into digits, using the number in BASE, and adding
;each digit to ud1 after multiplying ud1 by the number in BASE. Conversion
;continues until a character that is not convertible is encountered. c-addr2 is
;the location of the first unconverted character. An ambiguous condition exists
;if ud2 overflows.
;Note: This word is obsolescent and is included as a concession to existing
;implementations. Its function is superseded by >NUMBER.
NFA_CONVERT		FHEADER, "CONVERT", NFA_COMPILE_COMMA, COMPILE
CFA_CONVERT		DW	CF_DUMMY
			DW	CFA_EXIT

;ENDCASE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys -- )
;Mark the end of the CASE ... OF ... ENDOF ... ENDCASE structure. Use case-sys
;to resolve the entire structure. Append the run-time semantics given below to
;the current definition.
;Run-time: ( x -- )
;Discard the case selector x and continue execution.
NFA_ENDCASE		FHEADER, "ENDCASE", NFA_CONVERT, COMPILE
CFA_ENDCASE		DW	CF_DUMMY
			DW	CFA_EXIT

;ENDOF 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys1 of-sys -- case-sys2 )
;Mark the end of the OF ... ENDOF part of the CASE structure. The next location
;for a transfer of control resolves the reference given by of-sys. Append the
;run-time semantics given below to the current definition. Replace case-sys1
;with case-sys2 on the control-flow stack, to be resolved by ENDCASE.
;Run-time: ( -- )
;Continue execution at the location specified by the consumer of case-sys2.
NFA_ENDOF		FHEADER, "ENDOF", NFA_ENDCASE, COMPILE
CFA_ENDOF		DW	CF_DUMMY
			DW	CFA_EXIT

;ERASE ( addr u -- )
;If u is greater than zero, clear all bits in each of u consecutive address
;units of memory beginning at addr .
NFA_ERASE		FHEADER, "ERASE", NFA_ENDOF, COMPILE
CFA_ERASE		DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_EXPECT		FHEADER, "EXPECT", NFA_ERASE, COMPILE
CFA_EXPECT		DW	CF_DUMMY
			DW	CFA_EXIT

FALSE ( -- false )
;Return a false flag.
NFA_FALSE		FHEADER, "FALSE", NFA_EXPECT, COMPILE
CFA_FALSE		DW	CF_CONSTANT_RT
			DW	$0000

;HEX ( -- )
;Set contents of BASE to sixteen.
NFA_HEX			FHEADER, "HEX", NFA_FALSE, COMPILE
CFA_HEX			DW	CF_HEX
CF_HEX			MOVW	#16, BASE
			NEXT

;MARKER ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name Execution: ( -- )
;Restore all dictionary allocation and search order pointers to the state they
;had just prior to the definition of name. Remove the definition of name and all
;subsequent definitions. Restoration of any structures still existing that could
;refer to deleted definitions or deallocated data space is not necessarily
;provided. No other contextual information such as numeric base is affected.
NFA_MARKER		FHEADER, "MARKER", NFA_HEX, COMPILE
CFA_MARKER		DW	CF_DUMMY
			DW	CFA_EXIT

;NIP ( x1 x2 -- x2 )
;Drop the first item below the top of stack.
NFA_NIP			FHEADER, "NIP", NFA_MARKER, COMPILE
CFA_NIP			DW	CF_DUMMY
			DW	CFA_EXIT

;NUMBER ( c-addr -- c-addr 0 | u 1 | n 1 | ud 2 | d 2 ) Non-standard S12CForth extension!
;Convert terminated the string at c-addr into a number. The value of BASE is the
;radix for the conversion. 	
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;"Invalid BASE value"
;
NFA_NUMBER		FHEADER, "NUMBER", NFA_NIP, COMPILE
CFA_NUMBER		DW	CF_NUMBER
CF_NUMBER		PS_CHECK_UFOF	1, CF_NUMBER_PSUF, 1, CF_NUMBER_PSOF ;check for under and overflow (PSP-2 -> Y)
			BASE_CHECK	CF_NUMBER_INVALBASE	;check BASE value (BASE -> D) 
			;Allocate temporay memory 
			;+--------+--------+
			;|   Result MSW    | <-SSTACK_SP (in X)
			;+--------+--------+
			;|   Result LSW    |
			;+--------+--------+
			;|  Current Digit  |
			;+--------+--------+
			;| String Pointer  |
			;+--------+--------+
			;|  Flags |
			;+--------+
CF_NUMBER_RESHI		EQU	0
CF_NUMBER_RESLO		EQU	2
CF_NUMBER_DIGIT		EQU	4
CF_NUMBER_STRPTR	EQU	6		
CF_NUMBER_FLAGS		EQU	8
CF_NUMBER_NEG		EQU	$80
CF_NUMBER_DBL		EQU	$40
CF_NUMBER_TERM		EQU	$20
	
			SSTACK_ALLOC	9 		;allocate 9 bytes
			;Initialize temporary memory
			LDX	SSTACK_SP 		;SP -> X
			CLRA				;Clear result field
			CLRB
			STD	CF_NUMBER_RESHI,X
			STD	CF_NUMBER_RESLO,X
			STD	CF_NUMBER_DIGIT,X
			LDY	2,Y	
			STY	CF_NUMBER_STRPTR,X
			STAB	CF_NUMBER_FLAGS,X
			;Check for minus sign (string pointer in Y, SP in X)
			LDAB	0,Y
			CMPB	#"-"
			BNE	CF_NUMBER_1 		;convert character to digit
			BSET	CF_NUMBER_FLAGS,X, CF_NUMBER_NEG ;remember sign	
			LDAB	1,+Y
			;Check for string termination (character in B, string pointer in Y, SP in X) 
CF_NUMBER_1		TSTB				
			BPL	CF_NUMBER_2 		;not last character
			BSET	CF_NUMBER_FLAGS,X, CF_NUMBER_TERM ;remember termination
			ANDB	#$7F			;remove termination	
			;Convert character to digit (character in B, string pointer in Y, SSTACK_SP in X)
CF_NUMBER_2		;[0-9]
			CMPB	#"0"
			BLO	CF_NUMBER_5 		;[,.]
			CMPB	#"9"
			BHI	CF_NUMBER_3 		;[A-Z]
			SUBB	#"0"			;subtract offset
			JOB	CF_NUMBER_7 		;check digit
			;[A-Z]
CF_NUMBER_3		CMPB	#"A"
			BLO	CF_NUMBER_9 		;not a number
			CMPB	#"Z"
			BHI	CF_NUMBER_4		;[a-z]
			SUBB	#("A"-10)		;subtract offset
			JOB	CF_NUMBER_7 		;check digit
			;[a-z] 
CF_NUMBER_4		CMPB	#"a"			
			BLO	CF_NUMBER_6 		;[_]
			CMPB	#"z"
			BHI	CF_NUMBER_9		;not a number
			SUBB	#("A"-10)		;subtract offset
			JOB	CF_NUMBER_7 		;check digit
			;[,.]
CF_NUMBER_5		CMPB	#","
			BEQ	CF_NUMBER_8 		;ignore character
			CMPB	#"."
			BEQ	CF_NUMBER_10 		;force double
			JOB	CF_NUMBER_9		;not a number
			;[_]
CF_NUMBER_6		CMPB	#"_"
			BEQ	CF_NUMBER_8 		;ignore character
			JOB	CF_NUMBER_9		;not a number	
			;Check digit (digit in D, SP in X, string pointer in Y)
CF_NUMBER_7		CPD	BASE 			;check if digit < BASE
			BHS	CF_NUMBER_9		;not a number
			STD	CF_NUMBER_DIGIT,X 	;store digit
			STY	CF_NUMBER_STRPTR,X	;store string pointer
			;Multiply result by base (SP in X)
			LDY	CF_NUMBER_RESLO,X
			LDD	BASE
			EMUL				;Y * D => Y:D
			STD	CF_NUMBER_RESLO,X
			LDD	CF_NUMBER_RESHI,X
			STY	CF_NUMBER_RESHI,X
			LDY	BASE
			EMUL				;Y * D => Y:D
			TBNE	Y, CF_NUMBER_9		;number out of range 	
			ADDD	CF_NUMBER_RESHI,X
			BCS	CF_NUMBER_9		;number out of range
			STD	CF_NUMBER_RESHI,X
			;Add digit to result (SP in X)
			LDD	CF_NUMBER_RESLO,X
			ADDD	CF_NUMBER_DIGIT,X
			STD	CF_NUMBER_RESLO,X
			LDD	#$0000
			ADCB	CF_NUMBER_RESHI+1,X
			ADCA	CF_NUMBER_RESHI,X
			BCS	CF_NUMBER_9		;number out of range
			STD	CF_NUMBER_RESHI,X
			;Read next character (SP in X)
CF_NUMBER_8		BRSET	CF_NUMBER_FLAGS,X, CF_NUMBER_TERM, CF_NUMBER_11 ;done
			LDY	CF_NUMBER_STRPTR,X 	;read next character and advance pointer
			LDAB	1,+X
			STY	CF_NUMBER_STRPTR,X
			JOB	CF_NUMBER_1 		;next iteration
			;Not a number 
CF_NUMBER_9		LDY	PSP 			;push 0 onto the PS
			MOVW	#0, 2,-Y
			STY	PSP	
			SSTACK_DEALLOC	9 		;free 9 bytes
			NEXT
			;Force double number (SP in X)
CF_NUMBER_10		BSET	CF_NUMBER_FLAGS, CF_NUMBER_DBL	
			;2's complement if needed (SP in X)
CF_NUMBER_11		BRCLR	CF_NUMBER_FLAGS,X, CF_NUMBER_NEG, CF_NUMBER_12 ;check for minus sign
			LDD	CF_NUMBER_RESHI,X
			COMA
			COMB
			TFR	D, Y
			LDD	CF_NUMBER_RESLO,X
			COMA
			COMB
			ADDD	#1
			STD	CF_NUMBER_RESLO,X
			TFR	Y, D
			ADCB	#$00
			ADCA	#$00
			BVS	CF_NUMBER_9 		;2's complement overflow
			STD	CF_NUMBER_RESHI,X
			;Determine format of negative number (SP in X, result(hi) in D)
			CPD	#$FFFF
			BEQ	CF_NUMBER_14 		;store double value
			BRSET	CF_NUMBER_FLAGS,X, CF_NUMBER_DBL, CF_NUMBER_14 ;store double value
			JOB	CF_NUMBER_13 		;store single value
			;Positive number 
CF_NUMBER_12		BRSET	CF_NUMBER_FLAGS,X, CF_NUMBER_DBL, CF_NUMBER_14 ;store double value
			LDD	CF_NUMBER_RESHI,X
			BNE	CF_NUMBER_14 		;store double value
			;Store single value (SP in X)
CF_NUMBER_13		LDY	PSP
			MOVW	CF_NUMBER_RESLO,X, 2,Y+
			MOVW	#$0001, 0,Y
			STY	PSP
			SSTACK_DEALLOC	9 		;free 9 bytes
			NEXT
			;Store double value (SP in X)
CF_NUMBER_14		PS_CHECK_OF	2, CF_NUMBER_PSOF ;check for overflow (PSP-4 -> Y)
			MOVW	CF_NUMBER_RESHI,X, 2,Y
			MOVW	CF_NUMBER_RESLO,X, 4,Y
			MOVW	#$0002, 	   0,Y
			STY	PSP
			SSTACK_DEALLOC	9 		;free 9 bytes
			NEXT
	
CF_NUMBER_PSUF		JOB	FCORE_THROW_PSUF
CF_NUMBER_PSOF		JOB	FCORE_THROW_PSOF
CF_NUMBER_INVALBASE	JOB	FCORE_THROW_INVALBASE

		
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
NFA_OF			FHEADER, "OF", NFA_NUMBER, COMPILE
CFA_OF			DW	CF_DUMMY
			DW	CFA_EXIT

;PAD ( -- c-addr )
;c-addr is the address of a transient region that can be used to hold data for
;intermediate processing.
NFA_PAD			FHEADER, "PAD", NFA_OF, COMPILE
CFA_PAD			DW	CF_DUMMY
			DW	CFA_EXIT

;PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char.
;c-addr is the address (within the input buffer) and u is the length of the
;parsed string. If the parse area was empty, the resulting string has a zero
;length.
NFA_PARSE		FHEADER, "PARSE", NFA_PAD, COMPILE
CFA_PARSE		DW	CF_PARSE
CF_PARSE		

;PICK ( xu ... x1 x0 u -- xu ... x1 x0 xu )
;Remove u. Copy the xu to the top of the stack. An ambiguous condition exists if
;there are less than u+2 items on the stack before PICK is executed.
NFA_PICK		FHEADER, "PICK", NFA_PARSE, COMPILE
CFA_PICK		DW	CF_DUMMY
			DW	CFA_EXIT

;QUERY ( -- )
;Make the user input device the input source. Receive input into the terminal
;input buffer, replacing any previous contents. Make the result, whose address
;is returned by TIB, the input buffer. Set >IN to zero.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
NFA_QUERY		FHEADER, "QUERY", NFA_PICK, COMPILE
CFA_QUERY		DW	CF_QUERY
CF_QUERY		PRINT_LINE_BREAK	;send input prompt
			LDX	#FCORE_INPUT_PROMPT
			PRINT_STR
			MOVW	#$0000, NUMBER_TIB ;clear TIB
CF_QUERY_1		SCI_RX			;receive a character
			;Check for transmission errors (character in B) 
			BITA	#(NF|FE|PE) 	;check for: noise, frame errors, parity errors
			BNE	CF_QUERY_1	;ignore transmission errors
			;Check for ignored characters (character in B)
			CMPB	#PRINT_SYM_LF	
			BEQ	CF_QUERY_1	;ignore character	
			;Check for BACKSPACE (character in B)
			CMPB	#PRINT_SYM_BACKSPACE	
			BEQ	CF_QUERY_3 	;remove most recent character
			CMPB	#PRINT_SYM_DEL	
			BEQ	CF_QUERY_3 	;remove most recent character	
			;Check for ENTER (character in B)
			CMPB	#PRINT_SYM_CR	
			BEQ	CF_QUERY_4 	;process input
			;Check for TIB overflow (character in B)
			TIB_CHECK_OF  1, CF_QUERY_9 ;beep on overflow
			;Check for valid special characters (character in B, next free TIB location in X)
			CMPB	#PRINT_SYM_TAB	
			BEQ	CF_QUERY_2 	;echo and append to TIB
			;Check for invalid characters (character in B, next free TIB location in X)
			CMPB	#" "
			BLO	CF_QUERY_9 	;beep
			CMPB	#"~"
			BHI	CF_QUERY_9 	;beep
			;Echo character and append to TIB (character in B, next free TIB location in X)
CF_QUERY_2		STAB	0,X		;store character
			LEAX	1-TIB_START,X	;increment TIB counter
			STX	NUMBER_TIB
			SCI_TX			;echo a character
			JOB	CF_QUERY_1
			;Remove most recent character
CF_QUERY_3		LDX	NUMBER_TIB	;decrement TIB counter
			BEQ	CF_QUERY_9 	;beep if TIB was empty
			LEAX	-1,X
			STX	NUMBER_TIB	
			LDAB	#PRINT_SYM_BACKSPACE ;transmit a backspace character
			SCI_TX
			JOB	CF_QUERY_1	
CF_QUERY_4		;Process input (next free TIB location -> X)
			
;			;Terminate each word of the input string
;			LDX	NUMBER_TIB	;terminate each word of the input string
;			BEQ	CF_QUERY_8 	;empty input string
;CF_QUERY_5		LDAA	TIB_START-1,X	;check for whitespace characters
;			CMPA	#"!"		;non-printables are treated as whitespace 
;			BLO 	CF_QUERY_7	;whitespace
;			CMPA	#"~"		;
;			BHI	CF_QUERY_7	;whitespace
;			;End of string detected
;			ORAA	#$80		;terminate string
;			STAA	TIB_START-1,X
;			;Find next whitespace  
;CF_QUERY_6		LEAX	-1,X
;			CPX	#$0000
;			BEQ	CF_QUERY_8 	;all words terminated
;			LDAA	TIB_START-1,X	;check for whitespace characters
;			CMPA	#"!"		;non-printables are treated as whitespace 
;			BLO 	CF_QUERY_7	;whitespace
;			CMPA	#"~"		;
;			BLS	CF_QUERY_6	;non-whitespace
;			;Find next non-whitespace
;CF_QUERY_7		LEAX	-1,X
;			CPX	#$0000
;			BNE	CF_QUERY_5
;			;All words terminated
			
CF_QUERY_8		MOVW	#$0000, TO_IN 	;set >IN to zero	
			NEXT
			;Beep
CF_QUERY_9		PRINT_BEEP		;beep
			JOB	CF_QUERY_1 	;receive next character
	
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
NFA_REFILL		FHEADER, "REFILL", NFA_QUERY, COMPILE
CFA_REFILL		DW	CF_DUMMY
			DW	CFA_EXIT

;RESTORE-INPUT ( xn ... x1 n -- flag )
;Attempt to restore the input source specification to the state described by x1
;through xn. flag is true if the input source specification cannot be so
;restored.
;An ambiguous condition exists if the input source represented by the arguments
;is not the same as the current input source.
NFA_RESTORE_INPUT	FHEADER, "RESTORE-INPUT", NFA_REFILL, COMPILE
CFA_RESTORE_INPUT	DW	CF_DUMMY
			DW	CFA_EXIT

;ROLL ( xu xu-1 ... x0 u -- xu-1 ... x0 xu )
;Remove u. Rotate u+1 items on the top of the stack. An ambiguous condition
;exists if there are less than u+2 items on the stack before ROLL is executed.
NFA_ROLL		FHEADER, "ROLL", NFA_RESTORE_INPUT, COMPILE
CFA_ROLL		DW	CF_DUMMY
			DW	CFA_EXIT

;SAVE-INPUT ( -- xn ... x1 n )
;x1 through xn describe the current state of the input source specification for
;later use by RESTORE-INPUT.
NFA_SAVE_INPUT		EQU	NFA_ROLL

;SOURCE-ID ( -- 0 | -1 )
;Identifies the input source as follows:
;SOURCE-ID       Input source
;-1              String (via EVALUATE)
; 0              User input device
NFA_SOURCE_ID		FHEADER, "SOURCE_ID", NFA_SAVE_INPUT, COMPILE
CFA_SOURCE_ID		DW	CF_DUMMY
			DW	CFA_EXIT

;SPAN ( -- a-addr )
;a-addr is the address of a cell containing the count of characters stored by
;the last execution of EXPECT.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
NFA_SPAN		FHEADER, "SPAN", NFA_SOURCE_ID, COMPILE
CFA_SPAN		DW	CF_DUMMY
			DW	CFA_EXIT

;TIB ( -- c-addr )
;c-addr is the address of the terminal input buffer.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
NFA_TIB			FHEADER, "TIB", NFA_SPAN, COMPILE
CFA_TIB			DW	CF_DUMMY
			DW	CFA_EXIT

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
NFA_TO			FHEADER, "TO", NFA_TIB, COMPILE
CFA_TO			DW	CF_DUMMY
			DW	CFA_EXIT

;TRUE ( -- true )
;Return a true flag, a single-cell value with all bits set.
NFA_TRUE		FHEADER, "TRUE", NFA_TO, COMPILE
CFA_TRUE		DW	CF_CONSTANT_RT
			DW	$FFFF

;TUCK ( x1 x2 -- x2 x1 x2 )
;Copy the first (top) stack item below the second stack item.
NFA_TUCK		FHEADER, "TUCK", NFA_TRUE, COMPILE
CFA_TUCK		DW	CF_DUMMY
			DW	CFA_EXIT

;U.R ( u n -- )
;Display u right aligned in a field n characters wide. If the number of
;characters required to display u is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
NFA_U_DOT_R		FHEADER, "U.R", NFA_TUCK, COMPILE
CFA_U_DOT_R		DW	CF_DUMMY
			DW	CFA_EXIT

;U> 
;u-greater-than CORE EXT 
;	( u1 u2 -- flag )
;flag is true if and only if u1 is greater than u2.
NFA_U_GREATER_THAN	FHEADER, "U>", NFA_U_DOT_R, COMPILE
CFA_U_GREATER_THAN	DW	CF_DUMMY
			DW	CFA_EXIT

;UNUSED ( -- u )
;u is the amount of space remaining in the region addressed by HERE , in address
;units.
NFA_UNUSED		FHEADER, "UNUSED", NFA_U_GREATER_THAN, COMPILE
CFA_UNUSED		DW	CF_DUMMY
			DW	CFA_EXIT

;VALUE ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below, with an initial
;value equal to x.
;name is referred to as a value.
;name Execution: ( -- x )
;Place x on the stack. The value of x is that given when name was created, until
;the phrase x TO name is executed, causing a new value of x to be associated
;with name.
NFA_VALUE		FHEADER, "VALUE", NFA_UNUSED, COMPILE
CFA_VALUE		DW	CF_DUMMY
			DW	CFA_EXIT

;WITHIN ( n1|u1 n2|u2 n3|u3 -- flag )
;Perform a comparison of a test value n1|u1 with a lower limit n2|u2 and an
;upper limit n3|u3, returning true if either
;(n2|u2 < n3|u3 and (n2|u2 <= n1|u1 and n1|u1 < n3|u3)) or
;(n2|u2 > n3|u3 and (n2|u2 <= n1|u1 or n1|u1 < n3|u3)) is true, returning false
;otherwise. An ambiguous condition exists if n1|u1, n2|u2, and n3|u3 are not all
;the same type.
NFA_WITHIN		FHEADER, "WITHIN", NFA_VALUE, COMPILE
CFA_WITHIN		DW	CF_DUMMY
			DW	CFA_EXIT

;[COMPILE] 
;Intrepretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Find name. If
;name has other than default compilation semantics, append them to the current
;definition; otherwise append the execution semantics of name. An ambiguous
;condition exists if name is not found.
NFA_BRACKET_COMPILE	FHEADER, "[COMPILE]", NFA_WITHIN, COMPILE
CFA_BRACKET_COMPILE	DW	CF_DUMMY
			DW	CFA_EXIT

;\ 
;backslash CORE EXT 
;	Compilation: Perform the execution semantics given below.
;	Execution: ( "ccc<eol>"-- )
;Parse and discard the remainder of the parse area. \ is an immediate word.
NFA_BACKSLASH		FHEADER, "\", NFA_BRACKET_COMPILE, COMPILE ;"
CFA_BACKSLASH		DW	CF_DUMMY
			DW	CFA_EXIT
	
FCORE_WORDS_END		EQU	*
FCORE_LAST_NFA		EQU	NFA_BACKSLASH
