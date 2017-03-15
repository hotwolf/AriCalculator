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
;#             DP = Data pointer                                               #
;#             CP = Compile pointer                                            #
;#                  Points to the next free space after the dictionary         #
;#        CP_SAVE = Previous compile pointer                                   #
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
;###############################################################################
;# Relative branch options: 						       #
;#    BRA  20 rr        (PPP)  -> [-128..127]                                  #    									       #
;#    JMP  05 xb 	(PPP)  -> [-16..15]	  xb=$C0 +offset	       #
;#         05 xb ff	(PPP)  -> [-256..255]	  xb=$F8(pos)/$F9(neg)	       #
;#  	   05 xb ee ff  (fPPP) -> [-32768..32767] xb=$FA		       #
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

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
; Memory layout:
; ==============       
;      	                    +----------+----------+	     
;         UDICT_PS_START -> |   User Variables    |	     
;      	                    +----------+----------+	     
;    	                    |    User Variables   | <- [DP]		  
;    	                    |    Pre-Allocation   |		  
;                           +----------+----------+        
;                           |          |          | <-[START_OF_CS]
;                           |  User Dictionary    |	     
;                           |          |          |	     
;                           |          v          |	     
;                       -+- | --- --- --- --- --- |
;             UDICT_PADDING |                     | <- [CP]	     
;                       -+- | --- --- --- --- --- |          
;                           |          ^          | <- [HLD]	     
;                           |         PAD         |	     
;                           | --- --- --- --- --- |          
;                           |                     | <- [PAD]          
;                           .                     .          
;                           .                     .          
;                           | --- --- --- --- --- |          
;                           |          ^          | <- [PSP=Y]	  
;                           |          |          |		  
;                           |   Parameter stack   |		  
;    	                    |          |          |		  
;                           +----------+----------+        
;    	                    |       Canary        |	 		  
;                           +----------+----------+        
;    	                    | CFS Pre-Allocation  | <- [END_OF_PS]		  
;                           +----------+----------+        
;                           |          ^          | <- [CFSP]	  
;                           | Control-flow stack  |		  
;                           +----------+----------+        
;           UDICT_PS_END ->   
;	
; Word format:
; ============       
;                           +--------------+
;                     NFA-> |   Previous   |	
;                           |     NFA      | 
;                           | (rel. addr.) | 
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
; Control structures for compilation:	
; ===================================       
;	
; noname-sys (structures implementation)	
; generated by:	:NONAME
; consumed by:	;
;		
;                           +-------------------+	     
;                           |  FUDICT_CS_NONAME | +0	     
;      	+-------------------+-------------------+	     
;       |             current xt                | +1	     
;      	+-------------------+-------------------+	     
;	
; do-sys (do-loop structures)	
; generated by:	DO ?DO
; altered by:   LEAVE
; consumed by:  +LOOP LOOP
;		
; colon-sys (structures implementation)	
; generated by:	:
; consumed by:	;
;		
;                           +-------------------+	     
;                           |FUDICT_CS_COLON_SYS| +0	     
;      	+-------------------+-------------------+	     
;       |             current NFA               | +1	     
;      	+-------------------+-------------------+	     
;	
; do-sys (do-loop structures)	
; generated by:	DO ?DO
; altered by:   LEAVE
; consumed by:  +LOOP LOOP
;		
;                           +-------------------+	     
;                           | FUDICT_CS_DO_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              LOOP address             | +1	     
;      	+-------------------+-------------------+	     
;       |          previous LEAVE list          | +3	     
;      	+-------------------+-------------------+	     
;	
; case-sys (CASE structures)	
; generated by:	CASE
; checked by:   OF
; altered by:	ENDOF
; consumed by:  ENDCASE
;		
;                           +-------------------+	     
;                           |FUDICT_CS_CASE_SYS | +0	     
;      	+-------------------+-------------------+	     
;       |              ENDOF list               | +1	     
;      	+-------------------+-------------------+	     
;	
; of-sys (OF structures)	
; generated by:	OF
; consumed by:  ENDOF
;	
;                           +-------------------+	     
;                           | FUDICT_CS_OF_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              OF address               | +1	     
;      	+-------------------+-------------------+	     
;	
;	
; orig (control-flow origins) ->conditional	
; generated by:	IF WHILE
; consumed by:  ELSE REPEAT THEN
;	
;                           +-------------------+	     
;                           |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +1	     
;      	+-------------------+-------------------+	     
;		
; orig (control-flow origins) ->unconditional	
; generated by:	AHEAD ELSE
; consumed by:  ELSE REPEAT THEN
;	
;                           +-------------------+	     
;                           |   FUDICT_CS_ORIG  | +0	     
;      	+-------------------+-------------------+	     
;       |             AHEAD address             | +1	     
;      	+-------------------+-------------------+	     
;		
; dest (control-flow destinations)	
; generated by:	BEGIN
; checked by:   WHILE
; consumed by:  REPEAT UNTIL AGAIN
;	
;                           +-------------------+	     
;                           |   FUDICT_CS_DEST  | +0	     
;      	+-------------------+-------------------+	     
;       |             BEGIN address             | +1	     
;      	+-------------------+-------------------+	     
;	
; create (create structure)	
; generated by:	CREATE
; consumed by:  DOES> ;
;	
;                           +-------------------+	     
;                           | FUDICT_CS_CREATE  | +0	     
;      	+-------------------+-------------------+	     
;       |             action pointer            | +1	     
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

;#Control structure codes 
FUDICT_CS_NONAME	EQU	$FF		;control structure "noname-sys"
FUDICT_CS_COLON_SYS	EQU	$FE		;control structure "colon-sys"
FUDICT_CS_DO_SYS	EQU	$FD		;control structure "do-sys"
FUDICT_CS_CASE_SYS	EQU	$FC		;control structure "case-sys"
FUDICT_CS_COND_ORIG	EQU	$FB		;control structure "orig" with conditional branch
FUDICT_CS_ORIG		EQU	$FA		;control structure "orig" without conditional branch
FUDICT_CS_DEST		EQU	$F9  		;control structure "dest"
FUDICT_CS_CREATE	EQU	$F8  		;control structure "create"

;#Flags associated with the current definition
FUDICT_NOINL		EQU	$80 		;no inline

;#Flags associated with the last compiled word
FUDICT_NO_COF		EQU	$00 		;definition doesn't end with a COF
FUDICT_ABS		EQU	$01		;last call is JSR addr
FUDICT_REL8		EQU	$02		;last call is BSR offs8
FUDICT_REL9		EQU	$03		;last call is JSR offs9,PC
FUDICT_REL16		EQU	$04		;last call is JSR offs16,PC

;#INLINE optimization
FUDICT_MAX_INLINE	EQU	8 		;max. CF size for INLINE optimization

;Max. line width
FUDICT_LINE_WIDTH	EQU	FOUTER_LINE_WIDTH

;Data space allocation size
FUDICT_DS_ALLOC_SIZE	EQU	16 		;number of bytes to be allocated at once

;Control-flow stack 
FUDICT_CFS_BOTTOM	EQU	FPS_CFS_BOTTOM
	
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
DP			DS	2		;data pointer (next free space)
START_OF_CS		DS	2		;start of compile space
CP			DS	2 		;compile pointer (next free space) 
CP_SAVE			DS	2 		;compile pointer to revert to in case of an error
						
FUDICT_LAST_NFA		DS	2 		;pointer to the most recent NFA of the UDICT

FUDICT_LEAVE_LIST	EQU	FUDICT_CFS_BOTTOM+4;tracks the forward references during a DO...LOOP compilation 
FUDICT_CFLGS		EQU	FUDICT_CFS_BOTTOM+2;flags associated with the current definition 
FUDICT_LAST_COF		EQU	FUDICT_CFS_BOTTOM+1;flags associated with the last compiled word
;FUDICT_LEAVE_LIST	DS	2 		;tracks the forward references during a DO...LOOP compilation 
;FUDICT_CFLGS		DS	1 		;flags associated with the current definition
;FUDICT_LAST_COF	DS	1		;flags associated with the last compiled word
	
FUDICT_VARS_END		EQU	*
FUDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FUDICT_INIT, 0
			LDD	#UDICT_PS_START
			STD	DP
			STD	START_OF_CS
			STD	CP
			STD	CP_SAVE
			MOVW	#$0000, FUDICT_LEAVE_LIST
			MOVW	#$0000, FUDICT_LAST_NFA
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
; result: X:      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FUDICT_TX_STRING	EQU	STRING_PRINT_BL

;#Control-flow stack operations
;==============================
;#Allocate CFS space
; args:   D: requested CFS space (in bytes, negative)
; result: X: new CFSP
; SSTACK: 2 bytes
;         No registers are preserved
FUDICT_CFS_ALLOC	EQU	FPS_CFS_ALLOC
	
;#Data space operations
;======================
;#Allocate data space
; args:   D:  requested data space (in bytes)
; result: X: new DP
; SSTACK: 2 bytes
;         No registers are preserved
FUDICT_DS_ALLOC		EQU	*
			;Adjust DP (requested data space in D)
			LDX	DP 			;current DP -> X 
			LEAX	D,X			;new DP -> X			
			CPX	#UDICT_PS_START		;check for lower boundary
			BHS	FUDICT_DS_ALLOC_1	;above lower boundary
			LDX	#UDICT_PS_END 		;fix DP
FUDICT_DS_ALLOC_1	STX	DP 			;update DP
			CPX	START_OF_CS		;check if START_OF_CS has been reached 
			BLO	FUDICT_DS_ALLOC_6 	;no need to move DS
			;Update CP, START_OF_CS, HLD and PAD (requested space in D)
			ADDD	#(FUDICT_DS_ALLOC_SIZE-1);align to allocation size
			ANDB	#~(FUDICT_DS_ALLOC_SIZE-1);aligned requested space -> D
			LDX	PAD			;current PAD -> X
			BEQ	FUDICT_DS_ALLOC_2	;PAD not in use
			LEAX	D,X			;new PAD -> X
			STX	PAD			;update PAD
FUDICT_DS_ALLOC_2	LDX	HLD			;current HLD -> X
			BEQ	FUDICT_DS_ALLOC_3	;HLD not in use
			LEAX	D,X			;new HLD -> X
			STX	HLD			;update HLD
FUDICT_DS_ALLOC_3	LDX	CP			;current CP -> X
			LEAX	D,X			;new CP -> X
			STX	CP			;update CP
			LDX	START_OF_CS		;current START_OF_CS -> X
			LEAX	D,X			;new START_OF_CS -> X
			STX	START_OF_CS		;update START_OF_CS
			LDX	FUDICT_LAST_NFA		;current FUDICT_LAST_NFA -> X
			BEQ	FUDICT_DS_ALLOC_4	;user dictionary is empty
			LEAX	D,X			;new FUDICT_LAST_NFA -> X
			STX	FUDICT_LAST_NFA		;update FUDICT_LAST_NFA
			;Shift content of CS (shift distance in D) 
FUDICT_DS_ALLOC_4	COMA				;1's complement
			COMB				;
			ADDD	#1			;negative shift distance -> D
			LDX	CP			;new CP -> X
FUDICT_DS_ALLOC_5	MOVW	D,X, 2,X-		;move cell
			MOVW	D,X, 2,X-		;move cell (optional)
			MOVW	D,X, 2,X-		;move cell (optional)
			MOVW	D,X, 2,X-		;move cell (optional)
			MOVW	D,X, 2,X-		;move cell (optional)
			MOVW	D,X, 2,X-		;move cell (optional)
			MOVW	D,X, 2,X-		;move cell (optional)
			MOVW	D,X, 2,X-		;move cell (optional)
			CPX	START_OF_CS		;check for start of CS
			BHI	FUDICT_DS_ALLOC_5	;more to shift
FUDICT_DS_ALLOC_6	LDX	DP			;DP -> X
			RTS				;done
	
;#Dictionary operations
;======================
;#Check if a string matches a NF
; args:   X:      NFA
;         PSP+0:  u      (char count)
;         PSP+2;  c-addr (string address)
; result: C-flag: set on match
;         X:      xt on success, unchanged (NFA) on failure
;         PSP:    PSP+4 on success, unchanged on failure
; SSTACK: 12 bytes
;         All registers are preserved
FUDICT_CHECK_NAME	EQU	*
			;Save registers
			PSHD				;save D
			PSHX				;save X
			;Check first char (NFA in X)
			LDAB	[2,Y] 			;first char -> B
			JOBSR	FUDICT_UPPER		;make upper case
			LDAA	2,+X			;UDICT char -> A, UDICT string -> X
			ANDA	#~FUDICT_TERM		;remove termination
			CBA				;compare chars
			BNE	FUDICT_CHECK_NAME_2	;no match		
			;Compare string lengths (UDICT string -> X) 
			PSHX			    	;start of string -> 0,SP
			BRCLR	1,X+,#FUDICT_TERM,* 	;skip to end of UDICT string 
			TFR	X, D			;end of UDICT string -> D
			SUBD	2,SP+			;subtract UDICT entry offset
			CPD	0,Y			;compare string lengths
			BNE	FUDICT_CHECK_NAME_2	;no match		
			;Compare strings (UDICT EOS -> X) 
			; +--------+--------+
			; |  string pointer | SP+0
			; +--------+--------+
			; |  UDICT pointer  | SP+2
			; +--------+--------+
			; |    UDICT EOS    | SP+4
			; +--------+--------+
			PSHX				;UDICT EOS     -> 4,PS
			PSHX				;UDICT pointer -> 2,PS
			LDD	2,Y 			;c-addr        -> D
			ADDD	0,Y			;c-addr+u      -> D
			PSHD				;LU pointer    -> 0,PS
FUDICT_CHECK_NAME_1	LDX	0,SP			;LU pointer -> X
			LDAB	1,-X			;LU char -> B
			CPX	2,Y			;check LU pointer
			BEQ	FUDICT_CHECK_NAME_4	;search successful
			STX	0,SP			;update LU pointer
			LDX	2,SP			;UDICT pointer -> X
			LDAA	1,-X			;UDICT char -> A
			STX	2,SP			;update UDICT pointer
			JOBSR	FUDICT_UPPER		;make LU char upper case
			ANDA	#~FUDICT_TERM		;remove UDICT char termination
			CBA				;compare chars
			BEQ	FUDICT_CHECK_NAME_1	;check next char
			;No match 
			LEAS	6,SP			;remove LU and UDICT pointer from RS
FUDICT_CHECK_NAME_2	PULX				;restore X
			PULD				;restore D
			CLC				;flag failure
			RTS				;done
			;Match 
FUDICT_CHECK_NAME_4	LEAY	4,Y 			;remove C-addr and u from PS
			LEAS	4,SP			;remove LU and UDICT pointer from RS
			PULX				;UDICT EOS -> X
			INX				;skip over IF
			LEAS	2,SP			;don't restore X
			PULD				;restore D
			SEC				;flag success		
			RTS				;done
	
;#Exceptions
;============
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
				MOVW	#STATE_INTERPRET, STATE
				RTS

;Word: ] ( -- )
;Enter compilation state.
IF_RIGHT_BRACKET		IMMEDIATE
CF_RIGHT_BRACKET		EQU	*
				MOVW	#STATE_COMPILE, STATE
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
			;Check u ( c-addr u )
			LDD	0,Y			;check if u is zero
			BEQ	CF_LU_UDICT_2 		;empty seaech string (search failed)
			;Initialize interator structure ( c-addr u )
			LDX	FUDICT_LAST_NFA 	;last NFA -> X
			BEQ	CF_LU_UDICT_2 		;empty dictionary (search failed)
			;Check name ( c-addr u ) (NFA in X)
CF_LU_UDICT_1		JOBSR	FUDICT_CHECK_NAME 	;check name
			BCS	CF_LU_UDICT_3		;match			
			LDD	0,X			;NFA offset-> D
			LEAX	D,X			;next NFA -> X
			BNE	CF_LU_UDICT_1		;next NFA exists
			;Search failed ( c-addr u )
CF_LU_UDICT_2		MOVW	#FALSE, 2,-Y 		;return false flag
			RTS				;done
			;Search successful ( c-addr u )(xt in X)
CF_LU_UDICT_3		STX	2,-Y			;return xt
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
			;Initialize interator structure 
			LDX	FUDICT_LAST_NFA		;last NFA -> X
CF_WORDS_UDICT_1	BEQ	CF_WORDS_UDICT_3	;empty dictionary
			PSHX 				;iterator -> 2,SP
			MOVW	#FUDICT_LINE_WIDTH, 2,-SP;line counter -> 0,SP
			CLRA				;0 -> A
			CLRB				;0 -> B
			;Count chars of name (iterator in X, offset in D) 		
CF_WORDS_UDICT_2	LEAX	D,X		    	;relative 0-> absolute address			
			STX	2,SP			;advance iterator
			INX				;NF pointer -> X
			BRCLR	1,+X,#FUDICT_TERM,*	;skip to last char
			DEX				;adjust NF pointer
			TFR	X, D			;NF pointer -> D
			SUBD	2,SP			;calculate name length
			;Print separator (char count in D) 
			JOBSR	FUDICT_LIST_SEP		;print separator
			;Print word
			LDX	2,SP 			;iterator -> X
			LEAX	2,X			;NF pointer -> X
			JOBSR	FUDICT_TX_STRING	;print name
			;Advance interator 
			LDX	2,SP 			;iterator -> X
			LDD	0,X			;offset -> D
			BNE	CF_WORDS_UDICT_2	;next iteration
			;Clean up
			LEAS	4,SP 			;clean up stack
CF_WORDS_UDICT_3	RTS				;done

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
;noname-sys:
;                           +-------------------+	     
;                           |  FUDICT_CS_NONAME | +0	     
;      	+-------------------+-------------------+	     
;       |             current xt                | +3	     
;      	+-------------------+-------------------+	     
IF_COLON_NONAME		IMMEDIATE			
CF_COLON_NONAME		INTERPRET_ONLY			;catch nested compilation
			;Prepare anonymous compilation 
			LDX	CP			;CP -> X
			INX				;skip over info field
			PSHX				;xt _> 0,sp
			JOB	CF_COLON_3		;compile IF
	
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
;                           +-------------------+	     
;                           |FUDICT_CS_COLON_SYS| +0	     
;      	+-------------------+-------------------+	     
;       |             current NFA               | +1	     
;      	+-------------------+-------------------+	     
IF_COLON		IMMEDIATE			
CF_COLON		INTERPRET_ONLY			;catch nested compilation
			;Parse name 
CF_COLON_1		MOVW	#" ", 2,-Y 		;set delimeter
			JOBSR	CF_SKIP_AND_PARSE	;parse name
			LDD	0,Y			;check name
			BEQ	CF_COLON_5		;missing name
			;Check for recompilation of last name ( c-addr u )
			LDX	FUDICT_LAST_NFA		;last NFA -> X
			PSHX				;last NFA -> 0,SP
			JOBSR	FUDICT_CHECK_NAME 	;check name
			BCS	CF_COLON_6		;match			
			;Compile new NFA ( c-addr u ) (R: NFA )
			LDX	CP 			;CP -> X
			LDD	0,SP 			;last NFA -> D
			BEQ	CF_COLON_2		;first UDICT entry
			SUBD	CP			;NFA offset -> D
CF_COLON_2		STX	0,SP			;new NFA -> 0,SP
			STD 	2,X+ 			;compile new NFA
			STX	CP			;update CP
			;Compile name ( c-addr u ) (R: NFA ) 
			JOBSR	CF_NAME_COMMA_1		;compile name
CF_COLON_3		LDX	CP			;CP -> X
			CLR	1,X+			;set default IF
			STX	CP			;update CP
			;Set STATE ( ) (R: NFA )
			MOVW	#STATE_COMPILE, STATE 	;set compile state
			;Push colon-sys onto the control stack ( ) (R: NFA ) (CP in X)
			LDD	#3 			;five bytes for colon-sys frame
			LDX	CFSP			;CFSP -> X
			CPD	FUDICT_CFS_BOTTOM	;check for compile variables
			BNE	CF_COLON_4		;compile variables already allocated
CF_COLON_4		ADDB	#4		 	;four bytes for compile variables
			JOBSR	FUDICT_CFS_ALLOC	;new CFSP -> X
			MOVB	#FUDICT_CS_COLON_SYS, 0,X;set CS code
			MOVW	2,SP+, 1,X		;set NFA
			;Initialize compile cariables
			MOVW	#$0000, FUDICT_LEAVE_LIST;clear leave list
			MOVW	#$0000, FUDICT_CFLGS	;clear flags
			RTS				;done
			;Missing name 
CF_COLON_5		THROW	FEXCPT_TC_NONAME	;throw "Missing name argument" exception
			;Remove last UDICT entry 
CF_COLON_6		LDX	FUDICT_LAST_NFA		;last NFA -> X
			LEAX	2,X			;start of name -> X
			BRCLR	1,X+,#FUDICT_TERM,*	;skip to last char
			STX	CP			;reset CP
			LDX	FUDICT_LAST_NFA		;last NFA -> X
			LDD	0,X			;offset -> D
			BEQ	CF_COLON_8		;no prior NF
			LEAX	D,X			;previous NFA -> X
			STX	FUDICT_LAST_NFA		;remove nast UDICT entry
CF_COLON_7		LDX	CP			;CP -> X
			JOB	CF_COLON_3		;set compile state
CF_COLON_8		STD	FUDICT_LAST_NFA		;remove nast UDICT entry
			JOB	CF_COLON_7		;set compile state

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
CF_NAME_COMMA_2		LDAB	0,X			;char -> B
			JOBSR	FUDICT_UPPER		;msake upper case
			STAB	1,X+ 			;update string
			ANDB	#~FUDICT_TERM		;remove termination
			CMPB	#"!"			;check for lowest valid char
			BLO	CF_NAME_COMMA_4		;invalid char
			CMPB	#"~"			;check for lowest valid char
			BHI	CF_NAME_COMMA_4		;invalid char	
			CPX	CP			;check for end of string
			BLO	CF_NAME_COMMA_2		;handle next char
CF_NAME_COMMA_3		RTS				;done
			;Invalid char
CF_NAME_COMMA_4		THROW	FEXCPT_TC_INVALNAME 	;"invalid name argument"

;Word: STRING, ;
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( c-addr u  -- )
;Append the the string given by start address c-addr and length u to the current
;definition.
IF_STRING_COMMA		IMMEDIATE
CF_STRING_COMMA		COMPILE_ONLY
			;Prepare MOVE ( c-addr u )
CF_STRING_COMMA_1	LDD	0,Y 			;u  -> D
			LDX	CP			;CP -> X
			STX	0,Y			;CP -> PS+2
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
			;Check if u > 0
			LDD	0,Y 			;u             -> D
			BEQ	CF_MOVE_3 		;done
			;Check if addr1 > addr2 (u in D)
			LDX	2,Y 			;addr2         -> X
			CPX	4,Y			;compare addresses
			BHI	CF_MOVE_4		;addr1 < addr2
			BEQ	CF_MOVE_3 		;addr1 = addr2 -> done
			;addr1 > addr2 (u in D, addr2 in X)
			;       +-------------------+	     
			;  +----|addr1              |	     
			;  V    +-------------------+	     
			; +-------------------+	     
			; |addr2              |	     
			; +-------------------+	     
			LEAX	D,X			;addr2 + u     -> D
CF_MOVE_1		STX	0,Y			;addr2 + u     -> PS
			LDD	4,Y 			;addr1         -> D
			SUBD	2,Y 			;addr1 - addr2 -> D
			LDX	2,Y 			;addr2         -> X
CF_MOVE_2		MOVB	D,X, 1,X+ 		;copy byte
			CPX	0,Y 			;check range	
			BLO	CF_MOVE_2 		;loop
CF_MOVE_3		LEAY	6,Y			;clean up stack	
			RTS
			;addr1 < addr2 (u in D, addr2 in X)
			; +-------------------+	     
			; |addr1              |----+	     
			; +-------------------+	   V  
			;       +-------------------+	     
			;       |addr2              |	     
			;       +-------------------+	     
CF_MOVE_4		ADDD	4,X 			;addr1 + u     -> D
			EXG	D, X			;addr1 + u     -> X, addr2 -> D
			SUBD	4,X			;addr2 - addr1 -> D
CF_MOVE_5		MOVB	D,X, 1,X-		;copy byte
			CPX	6,Y			;check range
			BHS	CF_MOVE_5		;loop
			JOB	CF_MOVE_3		;done
	
;Word: COMPILE, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( xt -- )
;Append the execution semantics of the definition represented by xt to the
;execution semantics of the current definition.
IF_COMPILE_COMMA	IMMEDIATE
CF_COMPILE_COMMA	COMPILE_ONLY
			;Check for INLINE compilation
CF_COMPILE_COMMA_1	LDX	0,Y 			;xt -> X
			LDAB	-1,X			;IF -> B
			BEQ	CF_COMPILE_COMMA_2	;no INLINE compilation
			COMB				;invert IF
			BEQ	CF_COMPILE_COMMA_2	;no INLINE compilation
			COMB				;restore IF
			;STX	0,Y 			;addr1 -> PSP+4
			LDX	CP			;CP -> X
			STX	2,-Y 			;addr2 -> PSP+2
			LEAX	B,X			;allocate compile space
			STX 	CP			;update CP
			CLRA				;IF -> D
			STD	2,-Y			;u -> PSP+0
			JOB	CF_MOVE			;copy inline code
			;Check xt target
CF_COMPILE_COMMA_2	LDD	2,Y+ 			;xt -> D
			CPD	DP			;check lower range
			BLO	CF_COMPILE_COMMA_3  	;compile absolute call
			CPD	CP			;check upper range
			BHI	CF_COMPILE_COMMA_3  	;compile absolute call
			;Check relative call distance (xt in D)
			;BSET	FUDICT_CFLGS, #FUDICT_NOINL;no inline
			MOVB	#FUDICT_NOINL, FUDICT_CFLGS;no inline
			SUBD	CP 			;call distance -> D
			CPD	#(2-128)		;check for short branch
			BLT	CF_COMPILE_COMMA_4	;medium or long branch distance
			;Compile short distance call (call distance in D)
			MOVB	#FUDICT_REL8, FUDICT_LAST_COF;last call is BSR
			SUBB	#2			;rr -> B
			LDX	CP			;CP -> X
			LEAX	2,X			;allocate 2 bytes
			STX 	CP			;update CP
			LDAA	#$07			;"BSR" -> A
			STD	-2,X			;compile "BSR rr"
			RTS				;done
			;Compile absolute  call (xt in D)
CF_COMPILE_COMMA_3	#FUDICT_ABS, FUDICT_LAST_COF	;last call is JSR
			LDX	CP			;CP -> X
			LEAX	3,X			;allocate 3 bytes
			STX 	CP			;update CP
			MOVB	#$16, -3,X		;compile "JSR"
			STD	-2,X			;compile "hh ll"
			RTS				;done
			;Check relative call distance (CFSP in X, call distance in D)
CF_COMPILE_COMMA_4	CPD	#(3-256)		;check for short branch
			BLT	CF_COMPILE_COMMA_5	;long branch distance		
			;Compile medium distance call (call distance in D)
			MOVB	#FUDICT_REL9, FUDICT_LAST_COF;last call is JSR x,PC
			SUBB	#3			;ff -> B
			LDX	CP			;CP -> X
			LEAX	3,X			;allocate 3 bytes
			STX 	CP			;update CP
			MOVW	#$15F9, -3,X		;compile "JSR xb" (IDX1)
			STAB	-1,X			;compile "ff"
			RTS				;done
			;Compile long distance call (CFSP in X, call distance in D)
CF_COMPILE_COMMA_5	MOVB	#FUDICT_REL16, FUDICT_LAST_COF;last call is JSR x,PC
			SUBD	#4			;ee ff -> D
			LDX	CP			;CP -> X
			LEAX	4,X			;allocate 4 bytes
			STX 	CP			;update CP
			MOVW	#$15FA, -4,X		;compile "JSR xb" (IDX2)
			STD	-2,X			;compile "ee ff"
			RTS				;done
	
;Word: ; 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys -- )
;Append the run-time semantics below to the current definition. End the current
;definition, allow it to be found in the dictionary and enter interpretation
;state, consuming colon-sys. If the data-space pointer is not aligned, reserve
;enough data space to align it.
;Run-time: ( -- ) ( R: nest-sys -- )
;Return to the calling definition specified by nest-sys.
;
;noname-sys:
;                           +-------------------+	     
;                           |  FUDICT_CS_NONAME | +0	     
;      	+-------------------+-------------------+	     
;       |             current xt                | +1	     
;      	+-------------------+-------------------+	     
;	
;colon-sys:
;                           +-------------------+	     
;                           |FUDICT_CS_COLON_SYS| +0	     
;      	+-------------------+-------------------+	     
;       |             current NFA               | +1	     
;      	+-------------------+-------------------+	     
IF_SEMICOLON		IMMEDIATE			
CF_SEMICOLON		COMPILE_ONLY			;compile-only word
			;Check control flow stack 
CF_SEMICOLON_1		LDX	CFSP 			;CFSP -> X
			CPX	#(FUDICT_CFS_BOTTOM-7)	;check CFS level
			BNE	CF_SEMICOLON_4		;control structure mismatch (wrong CFS level)
			LDAB	0,X 			;CS code -> B			
			;Colon definition  (CFSP in X, CS code in B)
			CMPB	#FUDICT_CS_COLON_SYS	;check for unfinished COLON definition
			BNE	CF_SEMICOLON_2		;check for :NONAME
			MOVW	1,X, FUDICT_LAST_NFA	;add word to dictionary
			BRCLR	1,X+,#FUDICT_TERM,*	;skip to IF	
			JOB	CF_SEMICOLON_3		;conclude definition
			;:NONAME definition  (CFSP in X, CS code in B)
CF_SEMICOLON_2		CMPB	#FUDICT_CS_NONAME	;check for control structure misatch
			BNE	CF_SEMICOLON_5		;control structure misatch			
			MOVW	1,X-, 2,-Y		;push xt onto PS
			;Set info field (IF pointer in X)
CF_SEMICOLON_3		CLR	0,X 			;REGULAR -> IF
			BRSET	FUDICT_CFLGS,FUDICT_NOINL,CF_SEMICOLON_4;no inline word
			LDD	CP 			;CP -> D
			INX				;xt -> X
			PSHX				;xt -> 0,SP
			SUBD	2,SP+			;code length -> D
			CPD	#FUDICT_MAX_INLINE	;check against max. INLINE length
			BHI	CF_SEMICOLON_4		;too long for INLINE
			STAB	-1,X			;mark as INLINE word
			;Conclude definition
CF_SEMICOLON_4		JOBSR	CF_EXIT_1 		;compile EXIT
			;Remove colon-sys 
			LDD	#-3			;deallocate 6 bytes
			JOBSR	FUDICT_CFS_ALLOC	;
			MOVW	#STATE_INTERPRET, STATE ;set interpretation state
			;Align data space
			JOBSR	CF_ALIGN
			;Secure CP
			MOVW	CP, CP_SAVE
			RTS				;done	
			;Control structure misatch
CF_SEMICOLON_5		THROW	FEXCPT_TC_CTRLSTRUC	;exception -22 "control structure mismatch"

;Word: EXIT 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys -- colon-sys )
;Append the run-time semantics below to the current definition.
;Run-time: ( -- ) ( R: nest-sys -- )
;Return to the calling definition specified by nest-sys.
IF_EXIT			IMMEDIATE			
CF_EXIT			COMPILE_ONLY			;compile-only word
			;Check if COF optimization can be applied
CF_EXIT_1		LDX	CP			;CP         -> X
			LDAB	FUDICT_LAST_COF 	;COF status -> B
			;JSR addr -> JMP addr (CP in X, COF info in B)
			DBNE	B, CF_EXIT_2		;not JSR addr
			LDAB	-3,X 			;opcode -> B
			CMPB	#$16			;check for "JSR"
			BNE	CF_EXIT_6		;mismatch
			MOVB	#$06, -3,X		;"JSR" -> "JMP"
			RTS				;done
			;BSR offs8 -> BRA offs8 (CP in X)
CF_EXIT_2		DBNE	B, CF_EXIT_3		;not BSR offs8
			LDAB	-2,X 			;opcode -> B
			CMPB	#$07			;check for "BSR"
			BNE	CF_EXIT_6		;mismatch
			MOVB	#$20, -2,X		;"BSR" -> "BRA"
			RTS				;done
			;JSR offs9,PC -> JMP offs9,PC (CP in X)
CF_EXIT_3		DBNE	B, CF_EXIT_4		;not JSR offs9,PC
			LDAB	-3,X 			;opcode -> B
			CMPB	#$15			;check for "JSR"
			BNE	CF_EXIT_6		;mismatch
			MOVB	#$05, -3,X		;"JSR" -> "JMP"
			RTS				;done
			;JSR offs16,PC -> JMP offs16,PC (CP in X)
CF_EXIT_4		DBNE	B, CF_EXIT_5		;not JSR offs16,PC
			LDAB	-4,X 			;opcode -> B
			CMPB	#$15			;check for "JSR"
			BNE	CF_EXIT_6		;mismatch
			MOVB	#$05, -4,X		;"JSR" -> "JMP"
			RTS				;done
			;Compile "RTS" (CP in X)			
CF_EXIT_5		INX				;allocate 1 byte
			STX 	CP			;update CP
			MOVB	#$3D, -1,X		;compile "RTS"
			RTS				;done
			;Control structure misatch
;CF_EXIT_6		THROW	FEXCPT_TC_CTRLSTRUC	;exception -22 "control structure mismatch"
CF_EXIT_6		EQU	CF_SEMICOLON_5		;exception -22 "control structure mismatch"
	
;Word: VARIABLE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. Reserve one
;cell of data space at an aligned address.
;name is referred to as a variable.
;name Execution: ( -- a-addr )
;a-addr is the address of the reserved cell. A program is responsible for
;initializing the contents of the reserved cell.
IF_VARIABLE		REGULAR	
CF_VARIABLE		EQU	*
			;Create word definition
			JOBSR	CF_CREATE 		;Create word definition
			;Allocate one CELL of data space 
			LDD	#2 			;allocate one CELL
			JOB	FUDICT_DS_ALLOC		;
	
;Word: CREATE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. If the
;data-space pointer is not aligned, reserve enough data space to align it. The
;new data-space pointer defines name's data field. CREATE does not allocate data
;space in name's data field.
;name Execution: ( -- a-addr )
;a-addr is the address of name's data field. The execution semantics of name may
;be extended by using DOES>.
IF_CREATE		REGULAR	
CF_CREATE		EQU	*
			;Interpretation and execution semantics 
			;======================================
			;Align DP
			JOBSR	CF_ALIGN 		;align DP
			;Push DP onro the PS
			MOVW	DP, 2,-Y 		;DP -> 0,Y
			;Constant definition
			JOB	CF_CONSTANT 		;define CONSTANT

;Word: ALIGN ( -- )
;If the data-space pointer is not aligned, reserve enough space to align it.
IF_ALIGN		REGULAR	
CF_ALIGN		EQU	*
			;Align data space 
			LDD	#1 			;1 -> D
			BRSET	DP+1,#$01,CF_ALLOT_1	;allocate alignment byte
			RTS				;no alignment required

;Word: ALLOT ( n -- )
;If n is greater than zero, reserve n address units of data space. If n is less
;than zero, release |n| address units of data space. If n is zero, leave the
;data-space pointer unchanged.
;If the data-space pointer is aligned and n is a multiple of the size of a cell
;when ALLOT begins execution, it will remain aligned when ALLOT finishes
;execution.
;If the data-space pointer is character aligned and n is a multiple of the size
;of a character when ALLOT begins execution, it will remain character aligned
;when ALLOT finishes execution.
IF_ALLOT		REGULAR	
CF_ALLOT		EQU	*
			;Pull n 
			LDD	2,Y+ 			;n -> D
			;Allocate data space 
CF_ALLOT_1		JOB	FUDICT_DS_ALLOC
	
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
			LEAX	5,X			;allocate 5 bytes
			STX	CP			;update CP
			;Compile execution semantics
			MOVW	#$1800, -5,X		;"MOVW $xxxx, 2,-SP"
			MOVB	#$6E,   -3,X		; => 18006Exxxx
			MOVW	2,Y+, -2,X		;compile x
CF_LITERAL_2		RTS				;done

;Word: 2LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x1 x2 -- )
;Append the run-time semantics below to the current definition.
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
IF_TWO_LITERAL		IMMEDIATE
CF_TWO_LITERAL		COMPILE_ONLY	
CF_TWO_LITERAL_1	JOBSR	CF_SWAP			;(x1 x2 -- x2 x1)
			JOBSR	CF_LITERAL_1		;compile x1
			JOB	CF_LITERAL_1		;compile x2

;Word: 2CONSTANT ( x1 x2 "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a constant.
;name Execution: ( -- x1 x2 )
;Place x1 and x2 on the stack.
IF_TWO_CONSTANT		REGULAR
CF_TWO_CONSTANT		EQU	*
			;Compile header 
			JOBSR	CF_COLON 		;use standard ":" 
			;Compile body 
			JOBSR	CF_TWO_LITERAL_1 	;2LITERAL
			;Conclude compilation		
			JOB	CF_SEMICOLON_1 		;";"
	
;Word: DOES>
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
			//Compile semantics
IF_DOES			IMMEDIATE	
CF_DOES			COMPILE_ONLY
			//Compile execution semantics
CF_DOES_1		CLR	FUDICT_LAST_COF		;mark code reachable
			MOVW	#CF_DOES_RT, 2,Y- 	;execution semantics -> PSP+0
			JOB	CF_COMPILE_COMMA_2	;compile execution semantics

			//Execution semantics
IF_DOES_RT		REGULAR	
CF_DOES_RT		EQU	*
			;Check CFS
			LDX	CFSP 			;CFSP -> X
			CPX	#(FUDICT_CFS_BOTTOM-4)	;check CFS level
			BHI	CF_DOES_RT_1		;control structure mismatch
			LDAB	FUDICT_LAST_COF		;COF status -> B
			CLR	FUDICT_LAST_COF		;reset COF status
			;Un-terminate last compilation (COF status in B)
			LDX	CP 			;CP in X
			;JMP addr -> JSR addr (CP in X, COF info in B)
			DBNE	B, CF_DOES_RT_2		;not JMP addr
			LDAB	-3,X 			;opcode -> B
			CMPB	#$06			;check for "JMP"
			BNE	CF_DOES_RT_1		;mismatch
			MOVB	#$16, -3,X		;"JMP" -> "JSR"
			JOB	CF_DOES_RT_3		;enhance previous definition
			;Control structure misatch
CF_DOES_RT_1		THROW	FEXCPT_TC_CTRLSTRUC	;exception -22 "control structure mismatch"			
			;BRA offs8 -> BSR offs8 (CP in X)
CF_DOES_RT_2		DBNE	B, CF_DOES_RT_3		;not BRA offs8
			LDAB	-2,X 			;opcode -> B
			CMPB	#$20			;check for "BRA"
			BNE	CF_DOES_RT_1		;mismatch
			MOVB	#$07, -2,X		;"BRA" -> "BSR"
			JOB	CF_DOES_RT_6		;enhance previous definition
			;JMP offs9,PC -> JSR offs9,PC (CP in X)
CF_DOES_RT_3		DBNE	B, CF_DOES_RT_4		;not JMP offs9,PC
			LDAB	-3,X 			;opcode -> B
			CMPB	#$05			;check for "JMP"
			BNE	CF_DOES_RT_1		;mismatch
			MOVB	#$15, -3,X		;"JMP" -> "JSR"
			JOB	CF_DOES_RT_6		;enhance previous definition
			;JMP offs16,PC -> JSR offs16,PC (CP in X)
CF_DOES_RT_4		DBNE	B, CF_DOES_RT_5		;not JMP offs16,PC
			LDAB	-4,X 			;opcode -> B
			CMPB	#$05			;check for "JMP"
			BNE	CF_DOES_RT_1		;mismatch
			MOVB	#$15, -4,X		;"JSR" -> "JMP"
			JOB	CF_DOES_RT_6		;enhance previous definition
			;Remove "RTS" (CP in X)			
CF_DOES_RT_5		LDAB	-1,X 			;opcode -> B
			CMPB	#$3D			;check for "RTS"
			BNE	CF_DOES_RT_1		;mismatch
			DEX				;remove "RTS"
			STX	CP			;update CP
			;Enhance previous definition
CF_DOES_RT_6		MOVW	2,SP+, 2,-Y 		;return address -> PSP+0
			JOBSR	CF_COMPILE_COMMA_2	;compile return address
			JOB	CF_SEMICOLON_1		;terminate enhanced definition
		
;Word: , ( x -- )
;Reserve one cell of data space and store x in the cell. If the data-space
;pointer is aligned when , begins execution, it will remain aligned when,
;finishes execution. An ambiguous condition exists if the data-space pointer is
;not aligned prior to execution of ,.
IF_COMMA		REGULAR	
CF_COMMA		EQU	*
			;Allocate one CELL of data space
			LDD	#2 			;2 -> D
			JOBSR	FUDICT_DS_ALLOC		;allocate data space
			;Store x in allocated space  
			LDX	DP 			;DP -> X
			MOVW	2,Y+, -2,X		;copy x
			RTS				;done
	
;C, ( char -- )
;Reserve space for one character in the data space and store char in the space.
;If the data-space pointer is character aligned when C, begins execution, it
;will remain character aligned when C, finishes execution. An ambiguous
;condition exists if the data-space pointer is not character-aligned prior to
;execution of C,.
IF_C_COMMA		REGULAR	
CF_C_COMMA		EQU	*
			;Allocate one char of data space (DP in X)
			LDD	#1 			;1 -> D
			JOBSR	FUDICT_DS_ALLOC		;allocate data space
			;Store char in allocated space (DP in X)
			STAB	-1,X			;char -> DS
			RTS				;done

;Word: HERE ( -- addr )
;addr is the data-space pointer. (points to the next free data space)
IF_HERE			REGULAR	
CF_HERE			EQU	*
			;Push DP onto trhe PS
			MOVW	DP, 2,-Y	     	;DP -> PS
			RTS			       	;done

;;Word: UNUSED ( -- u )
;u is the amount of space remaining in the region addressed by HERE, in address
;units.
IF_UNUSED		REGULAR	
CF_UNUSED		EQU	*
			;Calculate remaining space
			TFR	Y, D 			;PSP -> D
			LDX	PAD			;check if PAD is active
			BNE	CF_UNUSED_2		;PAD is active
			;PAD is inactive (PSP in D) 
			SUBD	CP 			;calculate remaining space
CF_UNUSED_1		STD	2,-Y			;push result onto PS
			RTS				;done
			;PAD is active (PSP in D) 
CF_UNUSED_2		SUBD	PAD 			;calculate remaining space
			JOB	CF_UNUSED_1		;push result onto PS

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
			JOB	CF_TYPE			;print message
			;Empty string ( c-addr u )
CF_DOT_QUOTE_2		LEAY	4,Y 			;clean up stack
			RTS				
			;Compilation semantics ( c-addr u )
CF_DOT_QUOTE_3		MOVW	#CF_DOT_QUOTE_RT, 2,-Y 	;runtime semantics -> PS
			JOBSR	CF_COMPILE_COMMA_1	;compile word
			CLR	FUDICT_LAST_COF		;reset COF state
			JOB	CF_STRING_COMMA_1	;compile string
			
;Run-time: ( -- )
;Display ccc.
IF_DOT_QUOTE_RT		REGULAR
CF_DOT_QUOTE_RT		EQU	*
			;Print string 
			PULX				;string pointer -> X
			JOBSR	FUDICT_TX_STRING	;print string
			JMP	0,X			;continue after string

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
;
;do-sys:	
;                           +-------------------+	     
;                           | FUDICT_CS_DO_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              LOOP address             | +1	     
;      	+-------------------+-------------------+	     
;       |          previous LEAVE list          | +3	     
;      	+-------------------+-------------------+	     
IF_QUESTION_DO		IMMEDIATE
CF_QUESTION_DO		COMPILE_ONLY
			;Allocate 13 bytes of compile space 
			LDX	CP 			;CP -> X
			LEAX	10,X			;alloate first 10 bytes
			TFR	X, D			;LEAVE list -> D
			LEAX	 4,X			;alloate 4 more bytes
			STX	CP			;update CP
			;Compile inline code (new CP in X, LEAVE list in D) 
			MOVW	#$EC42,	-14,X 		;compile "LDD 2,Y"
			MOVW	#$3BEC,	-12,X 		;compile "PSHD LDD"
			MOVW	#$733B,	-10,X 		;compile "4,Y+ PSHD"
			MOVW	#$AC82,	 -8,X 		;compile "CPD 2,SP"
			MOVW	#$2604,	 -6,X 		;compile "BNE *+5"
			MOVW	#$05FA,  -4,X		;"JMP 0,PC"
			MOVW	#$0000,  -2,X		;
			JOB	CF_DO_1			;do-sys -> CS

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
;
;do-sys:	
;                           +-------------------+	     
;                           | FUDICT_CS_DO_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              LOOP address             | +1	     
;      	+-------------------+-------------------+	     
;       |          previous LEAVE list          | +3	     
;      	+-------------------+-------------------+	     
IF_DO			IMMEDIATE
CF_DO			COMPILE_ONLY
			;Allocate 6 bytes of compile space 
			LDX	CP 			;CP -> X
			LEAX	6,X			;alloate space
			STX	CP			;update CP
			;Compile inline code (old CP in X) 
			MOVW	#$EC42,	-6,X 		;compile "LDD 2,Y"
			MOVW	#$3BEC,	-4,X 		;compile "PSHD LDD"
			MOVW	#$733B,	-2,X 		;compile "4,Y+ PSHD"
			CLRA				;empty LEAVE list
			CLRB				; -> D
			;Put do-sys onto the control flow stack (LEAVE list in D)
CF_DO_1			PSHD				;save LEAVE list
			LDD	#5 			;alllocate 6 bytes of CFS space
			JOBSR	FUDICT_CFS_ALLOC	;new CFSP -> X
			MOVB	#FUDICT_CS_DO_SYS, 0,X	;set CS code
			CLR	FUDICT_LAST_COF		;reset COF status
			PULD				;LEAVE list -> D
			MOVW	CP, 1,X			;store LOOP address
			MOVW	FUDICT_LEAVE_LIST, 3,X	;store previous LEAVE list
			STD	FUDICT_LEAVE_LIST	;store LEAVE list
			MOVW	CP, 2,X			;store LOOP address
			RTS				;done

;Word: LEAVE
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the current loop control parameters. An ambiguous condition exists if
;they are unavailable. Continue execution immediately following the innermost
;syntactically enclosing DO ... LOOP or DO ... +LOOP.
;
;do-sys:	
;                           +-------------------+	     
;                           | FUDICT_CS_DO_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              LOOP address             | +1	     
;      	+-------------------+-------------------+	     
;       |          previous LEAVE list          | +3	     
;      	+-------------------+-------------------+	     
IF_LEAVE		IMMEDIATE
CF_LEAVE		COMPILE_ONLY
			;Allocate compile space
			LDX	CP  			;CP -> X
			TFR	X, D			;CP -> D
			LEAX	4,X			;alloate space
			STX	CP			;update CP
			;Update LEAVE list (old CP in D, new CP in X)
			MOVW	#$05FA, -4,X		;"JMP 0,PC"		
			MOVW	FUDICT_LEAVE_LIST, -2,X	;store LEAVE list
			STD	FUDICT_LEAVE_LIST	;update LEAVE list
			RTS				;done

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
;
;do-sys:	
;                           +-------------------+	     
;                           | FUDICT_CS_DO_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              LOOP address             | +1	     
;      	+-------------------+-------------------+	     
;       |          previous LEAVE list          | +3	     
;      	+-------------------+-------------------+	     
IF_LOOP			IMMEDIATE
CF_LOOP			COMPILE_ONLY
			;Check compile info 
			LDX	CFSP 			;CFSP -> X
			LDAB	0,X 			;compile info -> B
			CMPB	#FUDICT_CS_DO_SYS	;check for matching "do-sys"
			BNE	CF_LOOP_5		;control structure mismatch			
			;Calculate branch distance (CFSP in X) 
			LDD	1,X 			;LOOP address -> D
			SUBD	CP			;LOOP address - CP -> D	
			CPD	#(-128+7)		;check if long branch is required
			BLT	CF_LOOP_6		;compile long branch code
			;BRA	CF_LOOP_6		;force long branch code compilation
			;Reserve compile space for short branch code (branch distance in B) 
			LDX	CP  			;CP -> X
			LEAX	9,X			;advance CP
			STX	CP			;update CP
			;Compile short branch code (branch distance in D, CP in X) 
			SUBB	#7			;rr -> B
			;30            PULX
			;08            INX
			;34            PSHX
			;AE 82         CPX     2,SP
			;26 rr         BNE     start of LOOP body
			;1B 84         LEAS    4,SP
			MOVW	#$3008, -9,X 		;compile "PULX INX"
			MOVW	#$34AE, -7,X 		;compile "PSHX CPX"
			MOVW	#$8226, -5,X 		;compile "2,SP BNE"
CF_LOOP_1		STAB		-3,X		;compile "rr"
CF_LOOP_2		MOVW	#$1B84	-2,X		;compile "LEAS 4,SP"
			;Resolve LEAVE list (CP in X) 
			LEAX	-2,X 			;LEAVE target -> X
			PSHX				;LEAVE target -> 2,SP
CF_LOOP_3		LDX	FUDICT_LEAVE_LIST	;LEAVE list -> X
			BEQ	CF_LOOP_4		;empty LEAVE list
			MOVW	2,X, FUDICT_LEAVE_LIST	;advance LEAVE list	
			PSHX				;LEAVE source -> 0,SP
			LDD	2,SP			;LEAVE target -> D
			SUBD	2,SP+			;branch distance -> D
			CPD	#(255+3)		;check for short AHEAD branch
			BHI	CF_LOOP_8		;long LEAVE branch
			;BRA	CF_LOOP_8		;force long LEAVE branch
			;Short LEAVE branch (LEAVE source in X, LEAVE target in 0,SP, branch distance -> D)
			SUBB	#3 			;rr -> B
			LDAA	#$F8			;xb -> A
			STD	1,X			;resolve IF address
			CLR	3,X			;clear extra byte
			JOB	CF_LOOP_3		;LEAVE list -> X
			;Remove do-sys 
CF_LOOP_4		PULD				;clean up RS
			LDX	CFSP 			;CFSP -> X
			MOVW	3,X, FUDICT_LEAVE_LIST	;restore previous LEAVE list
			CLR	FUDICT_LAST_COF		;reset COF state
			LDD	#-6			;do-sys length -> D
			JOBSR	FUDICT_CFS_ALLOC	;deallocate do-sys
			RTS				;done
			;Control structure misatch
CF_LOOP_5		THROW	FEXCPT_TC_CTRLSTRUC 	;exception -22 "control structure mismatch"
			;Reserve compile space for long branch code (qqrr in D) 
CF_LOOP_6		LDX	CP   			;CP -> X
			LEAX	11,X			;advance CP
			STX	CP			;update CP
			;Compile long branch code (qqrr in D, CP in X) 
			SUBD	#9 			;qqrr -> D
			;30             PULX
			;08             INX
			;34             PSHX
			;AE 82          CPX     2,SP
			;18 26 qq rr    LBNE    start of loop body
			;1B 84          LEAS    4,SP
			MOVW	#$3008, -11,X 		;compile "PULX INX"
			MOVW	#$34AE,  -9,X 		;compile "PSHX CPX"
			MOVW	#$8218,  -7,X 		;compile "2,SP LBNE"
			MOVB	#$26,    -5,X 		;compile "LBNE"
CF_LOOP_7		STD		 -4,X		;compile "qq rr"
			JOB	CF_LOOP_2		;compile "LEAS 4,SP"
			;Long LEAVE branch (LEAVE source in X, LEAVE target in 0,SP, branch distance -> D)
CF_LOOP_8		SUBD	#4			;subtract instruction length
			STD	2,X			;resolve IF address
			JOB	CF_LOOP_3		;LEAVE list -> X

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
;
;do-sys:	
;                           +-------------------+	     
;                           | FUDICT_CS_DO_SYS  | +0	     
;      	+-------------------+-------------------+	     
;       |              LOOP address             | +1	     
;      	+-------------------+-------------------+	     
;       |          previous LEAVE list          | +3	     
;      	+-------------------+-------------------+	     
IF_PLUS_LOOP		IMMEDIATE
CF_PLUS_LOOP		COMPILE_ONLY
			;Check compile info 
			LDX	CFSP 			;CFSP -> X
			LDAB	0,X 			;compile info -> B
			CMPB	#FUDICT_CS_DO_SYS	;check for matching "do-sys"
			BNE	CF_LOOP_5		;control structure mismatch			
			;Calculate branch distance (CFSP in X)
			LDD	1,X 			;LOOP address -> D
			SUBD	CP			;LOOP address - CP -> D	
			CPD	#(-128+8)		;check if long branch is required
			BLT	CF_PLUS_LOOP_1		;compile long branch code
			;BRA	CF_PLUS_LOOP_1		;force long branch code compilation
			;Reserve compile space for short branch code (branch distance in B) 
			LDX	CP  			;CP -> X
			LEAX	10,X			;advance CP
			STX	CP			;update CP
			;Compile short branch code (branch distance in B, CP in X) 
			SUBB	#8			;rr -> B
			;3A           PULD
			;E3 71        ADDD    2,Y+
			;3B           PSHD
			;AC 82        CPD     2,SP
			;2D rr        BLT     start of LOOP body
			;1B 84        LEAS    4,SP
			MOVW	#$3AE3, -10,X 		;compile "PULD ADDD"
			MOVW	#$713B	 -8,X		;compile "2,Y+ PSHD"
			MOVW	#$AC82	 -6,X		;compile "CPD 2,SP"
			MOVB	#$2D	 -4,X		;compile "BLT"
			JOB	CF_LOOP_1		;compile "rr"
			;Reserve compile space for long branch code (qqrr in D, CP in X) 
CF_PLUS_LOOP_1		LDX	CP  			;CP -> X
			LEAX	12,X			;advance CP
			STX	CP			;update CP
			;Compile long branch code (qqrr in D, CP in X) 
			SUBD	#10 			;qqrr -> D
			;3A             PULD
			;E3 71          ADDD    2,Y+
			;3B             PSHD
			;AC 82          CPD     2,SP
			;18 2D qq rr    LBNE    start of loop body
			;1B 84          LEAS    4,SP
			MOVW	#$3AE3, -12,X 		;compile "PULD ADDD"
			MOVW	#$713B, -10,X 		;compile "2,Y+ PSHD"
			MOVW	#$AC82	 -8,X		;compile "CPD 2,SP"
			MOVW	#$182D	 -6,X		;compile "LBLT"
			JOB	CF_LOOP_7		;compile "qq rr"
	
;Word: UNLOOP
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the loop-control parameters for the current nesting level. An UNLOOP is
;required for each nesting level before the definition may be EXITed. An
;ambiguous condition exists if the loop-control parameters are unavailable.
IF_UNLOOP		IMMEDIATE
CF_UNLOOP		COMPILE_ONLY
			;Allocate 2 bytes of compile space 
			LDX	CP			;CP -> X
			LEAX	2,X			;alloate space
			STX	CP			;update CP
			;Compile inline code (CP in X) 
			MOVW	#$1B84, -2,X		;compile "LEAS 4,SP"
			RTS				;done

;Word: I
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- n|u ) ( R:  loop-sys -- loop-sys )
;n|u is a copy of the current (innermost) loop index. An ambiguous condition
;exists if the loop control parameters are unavailable.
IF_I			IMMEDIATE
CF_I			COMPILE_ONLY
			;Allocate 4 bytes of compile space 
			LDX	CP			;CP -> X
			LEAX	4,X			;alloate space
			STX	CP			;update CP
			;Compile inline code (CP in X) 
			MOVW	#$1802, -4,X		;compile "MOVW"
			MOVW	#$806E, -2,X		;compile "0,SP, 2,-Y"
			RTS				;done

;Word: J
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- n|u ) ( R: loop-sys1 loop-sys2 -- loop-sys1 loop-sys2 )
;n|u is a copy of the next-outer loop index. An ambiguous condition exists if
;the loop control parameters of the next-outer loop, loop-sys1, are unavailable.
IF_J			IMMEDIATE
CF_J			COMPILE_ONLY
			;Allocate 4 bytes of compile space 
			LDX	CP			;CP -> X
			LEAX	4,X			;alloate space
			STX	CP			;update CP
			;Compile inline code (CP in X) 
			MOVW	#$1802, -4,X		;compile "MOVW"
			MOVW	#$846E, -2,X		;compile "4,SP, 2,-Y"
			RTS				;done
	
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
;	
;orig (conditional)	
;                           +-------------------+	     
;                           |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +1	     
;      	+-------------------+-------------------+	     
IF_IF			IMMEDIATE
CF_IF			COMPILE_ONLY
			;Put new control structure onto the control flow stack 
			LDD	#3 			;allocate 4 bytes of CFS space
			JOBSR	FUDICT_CFS_ALLOC	;new CFSP -> X
			MOVB	#FUDICT_CS_COND_ORIG, 0,X;set CF code
			CLR	FUDICT_LAST_COF		;reset COF status
			;Allocate 6 bytes of compile space (CFSP in X)
			LDD	CP 			;CP -> D
			ADDD	#2			;IF address -> D
			STD	1,X			;set IF address 
			TFR	D,X			;CP+2 -> X
			LEAX	4,X			;allocate 4 more bytes
			STX	CP			;update CP
			;Compile inline code (CP in X) 
			MOVW	#$EC71, -6,X		;"LDD 2,Y+"
			MOVW	#$1827, -4,X		;"LBEQ"
			MOVW	#$A7A7, -2,X		;"qq rr" (NOP NOP) 
			RTS				;done

;Word: AHEAD
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- orig )
;Put the location of a new unresolved forward reference orig onto the control
;flow stack. Append the run-time semantics given below to the current
;definition. The semantics are incomplete until orig is resolved (e.g., by THEN).
;Run-time: ( -- )
;Continue execution at the location specified by the resolution of orig.
;		
;orig (unconditional):	
;                           +-------------------+	     
;                           |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +1	     
;      	+-------------------+-------------------+	     
IF_AHEAD		IMMEDIATE
CF_AHEAD		COMPILE_ONLY
			;Put new control structure onto the contril flow stack 
			LDD	#4 			;allocate 4 bytes of CFS space
			JOBSR	FUDICT_CFS_ALLOC	;new CFSP -> X
			MOVB	#FUDICT_CS_ORIG, 0,X	;set CF code
			CLR	FUDICT_LAST_COF		;reset COF status
			;Allocate 4 bytes of compile space (CFSP in X)
			JOB	CF_ELSE_1
			;LDD	CP 			;CP -> D
			;STD	1,X			;set AHEAD address 
			;TFR	D,X			;CP -> X
			;LEAX	4,X			;allocate 4 more bytes
			;STX	CP			;update CP
			;;Compile inline code (CP in X) 
			;MOVW	#$05FA, -4,X		;"JMP 0,PC"
			;MOVW	#$0000, -2,X		;
			;RTS				;done
	
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
;		
;orig (conditional)	
;                           +-------------------+	     
;                           |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +1	     
;      	+-------------------+-------------------+	     
;		
; orig (unconditional):	
;                           +-------------------+	     
;                           |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +1	     
;      	+-------------------+-------------------+	     
IF_ELSE			IMMEDIATE
CF_ELSE			COMPILE_ONLY
			;Check compile structure
			LDX	CFSP 			;CFSP -> X
			LDAB	0,X			;control structure -> B
			CMPB	#FUDICT_CS_COND_ORIG	;check for conditional orig
			BNE	CF_ELSE_2		;control structure mismatch
			;Update control structure (CFSP in X)
			MOVB	#FUDICT_CS_ORIG, 0,X 	;unconditional orig -> control structure			
			;Resolve IF branch (CFSP in X)
			LDD	CP 			;CP -> D
			SUBD	1,X			;distance -> D
			CPD	#(127-2)		;check for short IF branch
			BHI	CF_ELSE_3		;long IF branch
			;BRA	CF_ELSE_3		;force long IF branch
			;Short IF branch  (CFSP in X, distance-2 -> D)
			ADDB	#2 			;distance -> D
			LDAA	#$27			;"BEQ" -> A
			STD	[1,X]			;resolve IF address
			;Allocate 4 bytes of compile space (CFSP in X)
CF_ELSE_1		LDD	CP 			;CP -> D
			STD	1,X			;set AHEAD address 
			TFR	D,X			;CP -> X
			LEAX	4,X			;allocate 4 more bytes
			STX	CP			;update CP
			;Compile inline code (CP in X) 
			MOVW	#$05FA, -4,X		;"JMP 0,PC"
			MOVW	#$0000, -2,X		;
			RTS				;done
			;Control structure misatch
CF_ELSE_2		THROW	FEXCPT_TC_CTRLSTRUC	;exception -22 "control structure mismatch"
			;Long IF branch  (CFSP in X, distance -> D)
CF_ELSE_3		LDX	1,X 			;IF address -> X
			STD	2,X			;resolve IF address
			LDX	CFSP			;CFSP -> X
			JOB	CF_ELSE_1		;allocate CS
	
;Word: THEN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig -- )
;Append the run-time semantics given below to the current definition. Resolve
;the forward reference orig using the location of the appended run-time
;semantics.
;Run-time: ( -- )
;Continue execution.
;		
;orig (conditional)	
;                           +-------------------+	     
;                           |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +1	     
;      	+-------------------+-------------------+	     
;		
; orig (unconditional):	
;                           +-------------------+	     
;                           |FUDICT_CS_ORIG_COND| +0	     
;      	+-------------------+-------------------+	     
;       |              IF address               | +1	     
;      	+-------------------+-------------------+	     
IF_THEN			IMMEDIATE
CF_THEN			COMPILE_ONLY
			;Check compile info 
CF_THEN_1		LDX	CFSP			;CFSP -> X
			LDAB	0,X			;compile info -> B
			CMPB	#FUDICT_CS_ORIG		;check for matching "orig"
			BEQ	CF_THEN_6		;conclude "AHEAD"
			CMPB	#FUDICT_CS_COND_ORIG	;check for matching conditional "orig"
			BNE	CF_THEN_3		;conrol structure mismatch
			;Resolve IF branch (CFSP in X)
			LDD	CP 			;CP -> D
			SUBD	1,X			;distance -> D
			CPD	#(127+2)		;check for short IF branch
			BHI	CF_THEN_4		;long IF branch
			;BRA	CF_THEN_4		;force long IF branch
			;Short IF branch  (CFSP in X, distance-2 -> D)
			SUBB	#2 			;distance -> D
			LDAA	#$27			;"BEQ" -> A
			STD	[1,X]			;resolve IF address
			;Clean up control flow stack (CFSP in X)
CF_THEN_2		LDD	#-3			;allocate 4 bytes
			JOB	FUDICT_CFS_ALLOC	; of CFS space
			;Control structure misatch
CF_THEN_3		EQU	CF_ELSE_2 		;exception -22 "control structure mismatch"
			;THROW	FEXCPT_TC_CTRLSTRUC	;exception -22 "control structure mismatch"
			;Long IF/AHEAD branch  (CFSP in X, distance -> D)
CF_THEN_4		LDX	1,X 			;IF address -> X
			SUBD	#4			;subtract instruction length
			STD	2,X			;resolve IF address
CF_THEN_5		LDX	CFSP			;CFSP -> X			
			JOB	CF_THEN_2		;clean up control flow stack
			;Resolve AHEAD branch (CFSP in X)
CF_THEN_6		LDD	CP 			;CP -> D
			SUBD	2,X			;distance -> D
			CPD	#(255+3)		;check for short AHEAD branch
			BHI	CF_THEN_4		;long IF branch
			;BRA	CF_THEN_4		;force long IF branch
			;Short AHEAD branch  (CFSP in X, distance-2 -> D)
			SUBB	#3 			;distance -> D
			LDAA	#$F8			;xb -> A
			LDX	2,X			;AHEAD address -> X
			STD	1,X			;resolve IF address
			;CLR	3,X			;clear extra byte
			JOB	CF_THEN_5		;CFSP -> X
	
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
;			CMPB	#FUDICT_CS_DEST		;check for matching "dest"
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
;			LDAB	#FUDICT_CF_NONE		;no optimization
;			STD	6,SP			;update compilation info
;			LDX	6,SP+			;return address -> X
;			JMP	0,X			;done
;			;Reserve compile space for jump code  (CP in X)					
;CF_AGAIN_4		LEAX	3,X			;advance CP
;			STX	CP			;update CP
;			;Compile jump code (CP in X)
;			BSET	2,SP,#FUDICT_CF_NOINL	;forbid inline compilation
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
;			CMPB	#FUDICT_CS_DEST		;check for matching "dest"
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
;			LDAB	#FUDICT_CS_DEST		;set control flow
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
;			CMPB	#FUDICT_CS_DEST		;check for matching "dest"
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
;			MOVB	#FUDICT_CS_COND_ORIG, 5,SP;set new compilation info
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
;			LDAB	#FUDICT_CS_CASE_SYS	;no optimization
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
;			CMPB	#FUDICT_CS_CASE_SYS	;check for matching "case-sys"
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
;			LDAB	#FUDICT_CS_OF_SYS	;set control flow
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
;			CMPB	#FUDICT_CS_OF_SYS	;check for matching "of-sys"
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
;			CMPB	#FUDICT_CS_CASE_SYS	;check for matching "case-sys"
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
;CF_ENDCASE_C		BSET	2,SP,#FUDICT_CF_NOINL	;forbid inline compilation
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
;			LDAB	#FUDICT_CF_NONE		;no optimization
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

