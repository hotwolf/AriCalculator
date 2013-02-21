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
;#    April 22, 2010                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    FMEM    - Forth memories                                                 #
;#    FEXCPT  - Forth exception words                                          #
;#    FDOUBLE - Forth double-number words                                      #
;#    PRINT   - Print Routines                                                 #
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
;Valid number base
FCORE_BASE_MIN		EQU	NUM_BASE_MIN		;2
FCORE_BASE_MAX		EQU	NUM_BASE_MAX		;PRINT_SYMTAB_END-PRINT_SYMTAB=26
FCORE_BASE_DEFAULT	EQU	NUM_BASE_DEFAULT	;10
FCORE_SYMTAB		EQU	NUM_SYMTAB
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FCORE_VARS_START_LIN
			ORG 	FCORE_VARS_START, FCORE_VARS_START_LIN
#else
			ORG 	FCORE_VARS_START
#endif	
			ORG	FCORE_VARS_START
IP			DS	2 	;instruction pointer
BASE			DS	2	;base for numeric I/O
STATE			DS	2	;interpreter state (0:iterpreter, -1:compile)
LAST_NFA		DS	2	;last NFA entry 
ABORT_QUOTE_MSG		DS	2	;message of last ABORT" call
FCORE_VARS_END		EQU	*
	
FCORE_VARS_END		EQU	*
FCORE_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FCORE_INIT, 0
			MOVW	#PRINT_BASE_DEF, BASE		;initialize BASE variable
			MOVW	#$0000, STATE
			MOVW	#FCORE_LAST_NFA, LAST_NFA 	;initialize pointer to last NFA
			MOVW	#$0000, ABORT_QUOTE_MSG
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
PREV		DW	\2
NAME_CNT	DB	((NAME_END-NAME_START)&$7F)|(\3<<7)
NAME_START	FCS	\1
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
NEXT			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         15 cycles	12 bytes
#emac

;SKIP_NEXT: skip next instruction and jump to one after
#macro	SKIP_NEXT, 0	
SKIP_NEXT		LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;		  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         17 cycles	14 bytes
#emac

;JUMP_NEXT: Read the next word entry and jump to that instruction 
#macro	JUMP_NEXT, 0	
JUMP_NEXT		LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         18 cycles	13 bytes
#emac

;EXEC_CFA: Execute a Forth word (CFA) directly from assembler code 
#macro	EXEC_CFA, 3	;args: 1:CFA 2:RS overflow handler, 3:RS underflow handler
			RS_PUSH	IP, \2			;IP -> RS			
			MOVW	#IP_RESUME, IP 		;set next IP
			LDX	#\1			;set W
			JMP	[0,X]			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		RS_PULL	IP, \3 			;RS -> IP
#emac
	
;EXEC_CF: Execute a Forth word's code field (CF) directly from assembler code (w/out setting the W register)
#macro	EXEC_CF, 3	;args: 1:CF 2:RS overflow handler, 3:RS underflow handler
			RS_PUSH	IP, \2			;IP -> RS			
			MOVW	#IP_RESUME, IP 		;set next IP
			JOB	\1
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		RS_PULL	IP, \3 			;RS -> IP
#emac

;BASE_CHECK: Verify the content of the BASE variable (Cdirectly from assembler code (BASE -> D)
#macro	BASE_CHECK, 1	;args: 1:error handler
			LDD	BASE
			CPD	#FCORE_BASE_MIN
			BLO	>\1
			CPD	#FCORE_BASE_MAX
			BHI	>\1
#emac

;COMPILE_ONLY: Ensure that the system is in compile state
#macro	COMPILE_ONLY, 1	;args: 1:error handler
			LDD	STATE
			BEQ	\1
#emac
	
;INTERPRET_ONLY: Ensure that the system is in interpretation state
#macro	INTERPRET_ONLY, 1	;args: 1:error handler
			LDD	STATE
			BNE	\1
#emac

;ASCII_ONLY: Ensure that accu B contains an ASCII character
#macro	ASCII_ONLY, 1	;args: 1:error handler
			CMPB	#" " 		;first legal character in ASCII table
			BLO	\1		;ignore character
			CMPB	#"~"		;last legal character in ASCII table
			BHI	\1		;ignore character
#emac
	
;CPSTR_X_TO_Y: Copy a string at X to the location at Y (X, Y, and D are modified)
#macro	CPSTR_X_TO_Y, 0	;args: none
LOOP			LDD	2,X+
			STAA	1,Y+
			BMI	DONE	
			STAB	1,Y+
			BPL	LOOP
DONE			EQU	*	
#emac

;CPSTR_Y_TO_X: Copy a string at X to the location at Y (X, Y, and D are modified)
#macro	CPSTR_Y_TO_X, 0	;args: none
LOOP			LDD	2,Y+
			STAA	1,X+
			BMI	DONE	
			STAB	1,X+
			BPL	LOOP
DONE			EQU	*	
#emac

;DEBUG: Ensure that the system is in interpretation state
#macro	DEBUG, 1	;args: 1:message
ADDR			PRINT_LINE_BREAK
			SSTACK_PSHYXD
			LDX	#MSG
			PRINT_STR
			LDD	#ADDR
			PRINT_WORD
			EXEC_CF	CF_DOT_S, CF_QUIT_RSOF, CF_QUIT_RSUF	;debug: show stack
			SSTACK_PULDXY
			JOB	DONE
MSG			FCC	\1
			FCS     " @"	
DONE			EQU	*

#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FCORE_CODE_START_LIN
			ORG 	FCORE_CODE_START, FCORE_CODE_START_LIN
#else
			ORG 	FCORE_CODE_START
#endif

;Common subroutines:
;===================

;#Get command line input and store it into any buffer
; args:   D: buffer size
;         X: buffer pointer
; result: D: character count	
;         X: error code (0 if everything goes well)	
; SSTACK: 16 bytes
;         Y is preserved
FCORE_ACCEPT		EQU	*	
			;Save registers
			SSTACK_PSHYXD
			;Allocate temporary variables
			;+--------+--------+
			;| char limit (D)  | <-SP
			;+--------+--------+
			;| buffer ptr (X)  |  +2
			;+--------+--------+
			;|        Y        |  +4
			;+--------+--------+
			;| Return address  |  +6
			;+--------+--------+
FCORE_ACCEPT_CHAR_LIMIT	EQU	0
FCORE_ACCEPT_BUF_PTR	EQU	2	
			;Signal input request
			LED_BUSY_OFF
			;Initialize counter 
			LDY	#$0000
			;Read input (buffer pointer in X, char count in Y)
			LED_BUSY_OFF			
FCORE_ACCEPT_1		SSTACK_JOBSR	FCORE_EKEY		;receive an ASCII character (SSTACK: 8 bytes)
			TBNE	X, FCORE_ACCEPT_7		;communication error
			LDX	FCORE_ACCEPT_BUF_PTR,SP
			;Check for BACKSPACE (char in D, buffer pointer in X, char count in Y)
			CMPB	#PRINT_SYM_BACKSPACE	
			BEQ	FCORE_ACCEPT_3 			;remove most recent character
			CMPB	#PRINT_SYM_DEL	
			BEQ	FCORE_ACCEPT_3 			;remove most recent character
			;Check for ENTER (CR) (char in D, buffer pointer in X, char count in Y)
			CMPB	#PRINT_SYM_CR	
			BEQ	FCORE_ACCEPT_5			;process input
			;Ignore LF (char in D, buffer pointer in X, char count in Y)
			CMPB	#PRINT_SYM_LF
			BEQ	FCORE_ACCEPT_1			;ignore
			;Check for buffer overflow (char in D, buffer pointer in X, char count in Y)
			CPY	FCORE_ACCEPT_CHAR_LIMIT,SP	
			BHS	FCORE_ACCEPT_4	 		;beep on overflow
			;Check for valid special characters (char in D, buffer pointer in X, char count in Y)
			CMPB	#PRINT_SYM_TAB	
			BEQ	FCORE_ACCEPT_2 			;echo and append to buffer
			;Check for invalid characters (char in D, buffer pointer in X, char count in Y)
			ASCII_ONLY	FCORE_ACCEPT_4 	
			;Echo character and append to buffer (char in D, buffer pointer in X, char count in Y)
FCORE_ACCEPT_2		LEAY	1,Y			
			STAB	1,X+				;store character
			STX	FCORE_ACCEPT_BUF_PTR,SP
			SSTACK_JOBSR	FCORE_EMIT		;echo a character
			JOB	FCORE_ACCEPT_1
			;Remove most recent character (buffer pointer in X, char count in Y)
FCORE_ACCEPT_3		TBEQ	Y, FCORE_ACCEPT_4		;beep if TIB was empty
			LEAY	-1,Y			
			LEAX	-1,X
			STX	FCORE_ACCEPT_BUF_PTR,SP
			LDAB	#PRINT_SYM_BACKSPACE 		;transmit a backspace character
			SSTACK_JOBSR	FCORE_EMIT
			JOB	FCORE_ACCEPT_1
			;Beep
FCORE_ACCEPT_4		PRINT_BEEP		;beep
			JOB	FCORE_ACCEPT_1 	;receive next character
			;Process input (char count in Y)
FCORE_ACCEPT_5		LDX	#$0000
FCORE_ACCEPT_6		STY	FCORE_ACCEPT_CHAR_LIMIT,SP	
			STX	FCORE_ACCEPT_BUF_PTR,SP
			;Done
			LED_BUSY_ON
			SSTACK_PULDXY
			SSTACK_RTS
			;Communication error (char count in Y, error code in X)
FCORE_ACCEPT_7		EQU	FCORE_ACCEPT_6	

;#Read a byte character from the SCI
; args:   none
; result: D: RX data
;         X: error code (0 if everything goes well)	
; SSTACK: 8 bytes
;         Y is preserved
FCORE_EKEY		EQU	*
			;Receive one byte
			SCI_RX			;(SSTACK: 6 bytes)
			;Check for buffer overflows (flags in A, data in B)
			BITA	#(SCI_FLG_SWOR|OR)
			BNE	FCORE_EKEY_2 	;buffer overflow
			;Check for RX errors (flags in A, data in B)
			BITA	#(NF|FE|PE)
			BNE	FCORE_EKEY_3 	;RX error
			;Return data (data in B)
			CLRA
			LDX	#$0000
			;Done
FCORE_EKEY_1		SSTACK_RTS
			;Buffer overflow
FCORE_EKEY_2		LDX	#FEXCPT_EC_COMOF
			JOB	FCORE_EKEY_1
			;RX error
FCORE_EKEY_3		LDX	#FEXCPT_EC_COMERR
			JOB	FCORE_EKEY_1


;#Check if RX data is available from the SCI
; args:   none
; result: D: oldest queue entry (random value if X is zero)
;         X: number of entries in RX queue
; SSTACK: 2 bytes
;         Y is preserved 
FCORE_EKEY_QUESTION	EQU	SCI_RX_PEEK
	
;#Send a byte character over the SCI
; args:   B: byte
; result: none
; SSTACK: 8 bytes
;         X, Y and D are preserved
FCORE_EMIT		EQU	SCI_TX	
			
;#Check if TX data can be send
; args:   none
; result: A: number of entries left in queue
; SSTACK: 3 bytes
;         X, Y, and B are preserved 
FCORE_EMIT_QUESTION	EQU	SCI_TX_PEEK	
			
;#Find a name in the dictionary and return the xt 
; args:   X: string pointer
; result: X: CFA/string pointer
;         D: status (0:name not cound, 1:immediate, or -1:compile)
; SSTACK: 8 bytes
;         Y is preserved

FCORE_FIND		EQU	*	
			;Find NFA
			TFR	X,D
			SSTACK_JOBSR	FCORE_FIND_NFA 				;(SSTACK: 8 bytes)
			TBEQ	X, FCORE_FIND_2			
			;Search was successful (current NFA in X)
			LEAX	2,X						;determine current CFA
			LDAB	1,X+ 
			SEX	B, D 						;save immediate flag
			ANDB	#$7F
			LEAX	B,X
			COMA
			TAB							;determine return status
			ORAB	#$01	
			;Done
FCORE_FIND_1		SSTACK_RTS
			;Search was unsuccessful (0 in X)
FCORE_FIND_2		EXG	D,X
			JOB	FCORE_FIND_1	

;#Find a name in the dictionary and return the NFA 
; args:   X: string pointer
; result: X: NFA (0:name not cound)
; SSTACK: 6 bytes
;         D and Y are preserved
FCORE_FIND_NFA		EQU	*	
			;Save registers
			SSTACK_PSHYD
			;Initialize search (start of word in X)
			LDY	LAST_NFA
			;Check for zero-length string (start of word in X)
			TBEQ	X, FCORE_FIND_NFA_3  				;empty string
			;Try to match first two characters (current NFA in Y, start of word in X)
FCORE_FIND_NFA_1	LDD	0,X 						;first two characters -> D 
			BMI	FCORE_FIND_NFA_6				;single character word
			;Search multy character word (first 2 characters in D, current NFA in Y, start of word in X)
			CPD	3,Y 						;compare first 2 characters
			BEQ	FCORE_FIND_NFA_4 				;first 2 characters match
			;Parse next NFA	(current NFA in Y, start of word in X)
FCORE_FIND_NFA_2	LDY	0,Y 						;check next NFA
			BNE	FCORE_FIND_NFA_1 				;next iteration
			;Search was unsuccessfull (current NFA in Y, start of word in X)
FCORE_FIND_NFA_3	LDX	#$0000 						;set return status
			JOB	FCORE_FIND_NFA_8 				;done
			;First 2 characters match (current NFA in Y, start of word in X)
FCORE_FIND_NFA_4	TSTB							;check if search is over
			BMI	FCORE_FIND_NFA_7 				;search was sucessful
			;Compare the remaining characters of the current NFA (current NFA in Y, start of word in X, index in A)
			LDAA	#2 						;set index to 3rd cfaracter
FCORE_FIND_NFA_5	LEAY	3,Y 						;set Y to start of name
			LDAB	A,Y 						;Compare current character
			LEAY	-3,Y 						;set Y to NFA
			CMPB	A,X
			BNE	FCORE_FIND_NFA_2 				;parse next NFA
			TSTB	 						;check if search is done
			BMI	FCORE_FIND_NFA_7				;search was successful
			IBNE	A, FCORE_FIND_NFA_5				;parse next character
			;Name is too long -> search unsuccessful 
			JOB	FCORE_FIND_NFA_3
			;Search single character word (current NFA in Y, first character in A)
FCORE_FIND_NFA_6	CMPA	3,Y 						;compare first character
			BNE	FCORE_FIND_NFA_2 				;parse next NFA			
			;Search was successful(current NFA in Y)
FCORE_FIND_NFA_7	TFR	Y,X		
			;Restore registers 
FCORE_FIND_NFA_8	SSTACK_PULDY
			SSTACK_RTS
	
;#Parse TIB for a name and create a definition header
; args:   X: string pointer
; result: D: NFA
;         X: error hanldler (0=no errors, FCORE_THROW_DICTOF, or FCORE_THROW_NONAME)	
; SSTACK: 10  bytes
;          Y is  preserved
FCORE_HEADER		EQU	*	
			;Save registers
			SSTACK_PSHY
			;Read next word
			SSTACK_JOBSR	FCORE_NAME 			;string pointer -> X, char count -> A (STACK: 5 bytes)
			TBEQ	X, FCORE_HEADER_NONAME 			;zero length name
			IBEQ	A, FCORE_HEADER_STROF 			;name longer then 254 characters
			DECA
			;Check for Dictionary overflow (string pointer in X, char count in A)
			TFR	X, Y
			TAB
			ADDA	#7 					;prev. NFA, CFA offs., CFA, 1 cell
			DICT_CHECK_OF_A	FCORE_HEADER_DICTOF		;(CP+7 -> X)
			;Build header (string pointer in  Y, char count in B)
			LDX	CP	       				;CP -> X
			MOVW	LAST_NFA, 2,X+ 				;append LAST_NFA 
			STAB	1,X+ 					;append character count
			;Append name (new CP in X, string pointer in Y)
FCORE_HEADER_1		CPSTR_Y_TO_X
			;Return result (new CP in X)
FCORE_HEADER_2		LDD	CP
			STX	CP
			LDX	#$0000
			;Restore registers 
FCORE_HEADER_3		SSTACK_PULY
			SSTACK_RTS
			;No name was given 
FCORE_HEADER_NONAME	LDX	#FCORE_THROW_NONAME
			JOB	FCORE_HEADER_3
			;Dictionary overflow
FCORE_HEADER_DICTOF	LDX	#FCORE_THROW_DICTOF
			JOB	FCORE_HEADER_3
			;Parsed string overflow
FCORE_HEADER_STROF	LDX	#FCORE_THROW_STROF
			JOB	FCORE_HEADER_3

;#Read an ASCII character from the SCI
; args:   none
; result: D: ASCII character	
;         X: error code (0 in case of no errors)
; SSTACK: 10 bytes
;         Y is preserved
FCORE_KEY		EQU	*	
			;Read byte from SCI 
FCORE_KEY_1		SSTACK_JOBSR	FCORE_EKEY	;receive one byte (SSTACK: 8 bytes)
			TBNE	X, FCORE_KEY_2		;transmission error
			;Check if it is a valid ASCII character
			ASCII_ONLY	FCORE_KEY_1
 			;Done
FCORE_KEY_2		SSTACK_RTS

;#Check if ASCII data is available from the SCI
; args:   none
; result: D: number of entries in RX queue
;         X: error code (0 in case of no errors)
; SSTACK: 4 bytes
;         Y is preserved 
FCORE_KEY_QUESTION	EQU	*
			;Peek into RX queue
			SCI_RX_PEEK				;(SSTACK: 2 bytes)
			TBEQ	X, FCORE_KEY_QUESTION_2		;RX queue is empty
			;Check if ASCII character is available (flags in A, data in B, number of chars in X)
			ASCII_ONLY	FCORE_KEY_QUESTION_4	;non-ASCII character
			;RX queue contains ASCII data (RX errors are not reported)
			TFR	X, D
			LDX	#$0000
			;Done
FCORE_KEY_QUESTION_1	SSTACK_RTS
			;RX queue is empty
FCORE_KEY_QUESTION_2	LDX	#$0000
FCORE_KEY_QUESTION_3	CLRA
			CLRB
			JOB	FCORE_KEY_QUESTION_1
			;Drop oldest RX queue entry (flags in A, data in B, number of chars in X)
FCORE_KEY_QUESTION_4	SCI_RX_DROP	
			;Check for buffer overflows (flags in A, data in B, number of chars in X)
			LDX	#FEXCPT_EC_COMOF
			BITA	#(SCI_FLG_SWOR|OR)
			BNE	FCORE_KEY_QUESTION_3	;buffer overflow
			;Check for RX errors (flags in A, data in B, number of chars in X)
			LDX	#FEXCPT_EC_COMERR
			BITA	#(NF|FE|PE)
			BNE	FCORE_KEY_QUESTION_3 	;RX error
			;Peek again
			JOB	FCORE_KEY_QUESTION
	
;#Find the next whitespace delimitered string on the TIB, make it upper case and
; terminate it. 
; args:   none
; result: X: string pointer
;	  A: character count (saturated at 255) 
; SSTACK: 5 bytes
;         Y and B are preserved
FCORE_NAME		EQU	*	
			;Save registers
			SSTACK_PSHYB			;save index Y and accu B
			;Skip leading whitespaces
			LDY	TO_IN			;current >IN -> Y	
FCORE_NAME_1		CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FCORE_NAME_7		;return empty string
			LDAB	TIB_START,Y
			LEAY	1,Y			;increment string pointer
			CMPB	#"!"	
			BLO	FCORE_NAME_1 		;whitespace
			CMPB	#"~"
			BHI	FCORE_NAME_1		;whitespace
			;Save start address in X (index of 2nd character in Y)
			LEAY	-1,Y 			;revert >IN		
			LEAX	TIB_START,Y 		;calculate string pointer
			;Convert to upper-case and add trailing whitespace  (index of 1st character in Y, string pointer in X)
FCORE_NAME_2		LDD	TIB_START,Y		;next two characters -> D
			CMPA	#"a"			;convert current character to upper case
			BLO	FCORE_NAME_3
			CMPA	#"z"
			BHI	FCORE_NAME_3
			SUBA	#$20			;"a"-"A"
		        STAA	TIB_START,Y
FCORE_NAME_3		LEAY	1,Y			;increment string pointer
			CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FCORE_NAME_4 		;terminate string	
			CMPB	#"!"	
			BLO	FCORE_NAME_4 		;terminate string
			CMPB	#"~"
			BLS	FCORE_NAME_2		;check next character
			;Terminate string (last character in A, pointer to last character in Y, string pointer in X)
FCORE_NAME_4		ORAA	#$80			;add termination bit to last character
			STAA	 TIB_START-1,Y	
			;Adjust >IN pointer (pointer to last character in Y, string pointer in X)
			TFR	Y,D
			ADDD	#1 			;skip the trailing whitespace
			EMIND	NUMBER_TIB-*,PC		;don't go beyond the end of the TIB
			STD	TO_IN
			;Calculate character count (pointer to last character in Y, string pointer in X)
			TFR	X, D 			;string pointer -> D
			COMA				;negate D
			COMB
			LEAY	TIB_START+1,Y		;(-D-1) + (Y+1) -> Y
			LEAY	D,Y 			
			TFR	Y, D			;character count -> D
			;Saturate count at 255 (character count in D)
			TBEQ	A, FCORE_NAME_5
			LDAB	#$FF
FCORE_NAME_5		TBA			
			;Done
FCORE_NAME_6		SSTACK_PULBY			;restore accu B and index Y
			SSTACK_RTS
			;Return empty string
FCORE_NAME_7		MOVW	NUMBER_TIB, TO_IN	;update >IN pointer
			LDX	#$0000			;set string pointer to 
			CLRA
			JOB	FCORE_NAME_6

;#Convert a terminated string into a number
; args:   X:   string pointer
; result: Y:X: number
;	  D:   size (0 if not a number)	
; SSTACK: 20 bytes
;         No registers are preserved
FCORE_NUMBER		EQU	*	
;			;Allocate temporary memory
			SSTACK_ALLOC	10 		;allocate 18 bytes
;         Stack:        +--------+--------+
;			|      Base       | SP+0
;			+--------+--------+
;			|   Char Pointer  | SP+2
;			+--------+--------+
;			|  New Result MSW | SP+4
;			+--------+--------+
;			|  New Result LSW | SP+6
;			+--------+--------+
;			| String Pointer  | SP+8
;			+--------+--------+
FCORE_NUMBER_BASE	EQU	0		
FCORE_NUMBER_CHRPTR	EQU	2
FCORE_NUMBER_RESHI	EQU	4
FCORE_NUMBER_RESLO	EQU	6
FCORE_NUMBER_STRPTR	EQU	8
FCORE_NUMBER_SIZE	EQU	FCORE_NUMBER_CHRPTR

			MOVW	BASE, FCORE_NUMBER_BASE,SP
			STX	FCORE_NUMBER_CHRPTR,SP
			MOVW	#$0000, FCORE_NUMBER_RESHI,SP
			MOVW	#$0000, FCORE_NUMBER_RESLO,SP
			STX	FCORE_NUMBER_STRPTR,SP

			;Skip sign (char pointer in X)
			LDAB	0,X
			ANDB	#$7F 			;remove termination
			CMPB	#"-"
			BNE	FCORE_NUMBER_1 		;check for base modifier
			BRSET	1,X+, #$80, FCORE_NUMBER_7;not a number
			STX	FCORE_NUMBER_CHRPTR,SP
			LDAB	0,X	
			;Handle base modifier (char in B, char pointer in X)
FCORE_NUMBER_1		CMPB	#"%" 			;check for binary modifier
			BNE	FCORE_NUMBER_2		;no binary modifier
			MOVW	#2, FCORE_NUMBER_BASE,SP
			JOB	FCORE_NUMBER_4 		;skip to next char
FCORE_NUMBER_2		CMPB	#"&" 			;check for decimal modifier
			BNE	FCORE_NUMBER_3		;no decimal modifier
			MOVW	#10, FCORE_NUMBER_BASE,SP
			JOB	FCORE_NUMBER_4 		;skip to next char
FCORE_NUMBER_3		CMPA	#"$" 			;check for hexadecimal modifier
			BNE	FCORE_NUMBER_5		;no hexadecimal modifier
			MOVW	#16, FCORE_NUMBER_BASE,SP			
FCORE_NUMBER_4		BRSET	1,X+, #$80, FCORE_NUMBER_7;not a number
			STX	FCORE_NUMBER_CHRPTR,SP
			;Skip to first digit (char pointer in X) 
FCORE_NUMBER_5		SSTACK_JOBSR	FCORE_PROC_DIGIT
			JMP	[FCORE_NUMBER_TAB_1,Y]

FCORE_NUMBER_TAB_1	DW	FCORE_NUMBER_6 		;first digit processed
			DW	FCORE_NUMBER_4		;try to next digit
			DW	FCORE_NUMBER_7		;not a number

			;First digit procesed (char pointer in X)
FCORE_NUMBER_6		BRSET	1,X+, #$80, FCORE_NUMBER_8 ;handle sign
			STX	FCORE_NUMBER_CHRPTR,SP
			SSTACK_JOBSR	FCORE_PROC_DIGIT
			JMP	[FCORE_NUMBER_TAB_2,Y]

FCORE_NUMBER_TAB_2	DW	FCORE_NUMBER_6 		;first digit processed
			DW	FCORE_NUMBER_6		;try to next digit
			DW	FCORE_NUMBER_7		;not a number

			;Not a number (char pointer in X)
FCORE_NUMBER_7		MOVW	#0, FCORE_NUMBER_SIZE,SP;default size: double word	
			JOB	FCORE_NUMBER_10	  	;return result

			;Handle sign (char pointer+1 in X)
FCORE_NUMBER_8		MOVW	#2, FCORE_NUMBER_SIZE,SP;default size: double word	
			LDAB	[FCORE_NUMBER_STRPTR,SP]
			CMPB	#"-"
			BEQ	FCORE_NUMBER_11 	;negative number
			;Positive number (char pointer+1 in X) 
			LDD	FCORE_NUMBER_RESHI,SP	;determine the size of the number 
			BNE	FCORE_NUMBER_10		;return result
			;Check for forced double value (char pointer+1 in X)
FCORE_NUMBER_9		LDAB	-1,X
			CMPB	#((".")|$80)
			BEQ	FCORE_NUMBER_10		;return result
			MOVW	#1, FCORE_NUMBER_SIZE,SP;set size to word
			;Return result (char pointer in X)
FCORE_NUMBER_10		LDD	FCORE_NUMBER_SIZE,SP
			LDY	FCORE_NUMBER_RESHI,SP
			LDX	FCORE_NUMBER_RESLO,SP
			SSTACK_DEALLOC	10      	;free memory
			SSTACK_RTS
			;Negative number (char pointer+1 in X) 
FCORE_NUMBER_11		LDD	FCORE_NUMBER_RESHI,SP	;calculate 2's complement
			COMA
			COMB
			STD	FCORE_NUMBER_RESHI,SP
			LDD	FCORE_NUMBER_RESLO,SP	;calculate 2's complement
			COMA
			COMB
			ADDD	#1
			STD	FCORE_NUMBER_RESLO,SP
			LDD	FCORE_NUMBER_RESHI,SP
			ADCB	#0
			ADCA	#0
			STD	FCORE_NUMBER_RESHI,SP
			BCS	FCORE_NUMBER_7		;overflow (not a number)
			;Check negative size (MSW in D, char pointer+1 in Y, stack pointer in X)
			IBNE	D, FCORE_NUMBER_10	;return result
			TST	FCORE_NUMBER_RESLO,SP
			BPL	FCORE_NUMBER_10		;return result
			JOB	FCORE_NUMBER_9		;check for forced double value


;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
; args:   A: delimiter
; result: X: string pointer
;	  A: character count (saturated at 255) 	
; SSTACK: 5 bytes
;         Y and B are preserved
FCORE_PARSE		EQU	*	
			;Save registers
			SSTACK_PSHYB			;save index X and accu B
			;Check for empty string (delimiter in A)
			CLRB	      			;0 -> B
			LDY	TO_IN			;current >IN -> Y
			;LEAY	1,Y			;ignore first space character
			CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FCORE_PARSE_4		;return empty string
			LEAX	TIB_START,Y		;save start of string
			CMPA	0,X			;check for double quote
			BEQ	FCORE_PARSE_4		;return empty string		
			;Parse remaining characters (>IN in Y, delimiter in A, string pointer in X)
FCORE_PARSE_1		ADDB	#1 			;increment B
			SBCB	#0			;saturate B
			LEAY	1,Y 			;increment >IN
			CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FCORE_PARSE_2		;terminate previous character
			CMPA	TIB_START,Y		;check for double parse
			BNE	FCORE_PARSE_1		;check next character
			;Terminate previous character (>IN in Y, delimiter in A, string pointer in X) 
FCORE_PARSE_2		BSET	TIB_START-1,Y, #$80 	;set termination bit
FCORE_PARSE_3		EXG	Y,D
			ADDD	#1			;increment >IN
			EMIND	NUMBER_TIB-*,PC		;don't go beyond the end of the TIB
			EXG	Y,D
			STY	TO_IN			;update >IN
			TBA				;character count -> A
			;Done
			SSTACK_PULBY			;restore accu B and index X
			SSTACK_RTS
			;Empty string 
FCORE_PARSE_4		LDX	#$0000
			JOB	FCORE_PARSE_3
	
;#Process one digit in a string to number conversion
; args:   Stack:        +--------+--------+
;			|      Base       | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|    Result MSW   | SP+6
;			+--------+--------+
;			|    Result LSW   | SP+8
;			+--------+--------+
; result: Y:	Status (0: everything ok, 2:fill char, 4:not a number) 	
;         Stack:        +--------+--------+
;			|      Base       | SP+0
;			+--------+--------+
;			|   Char Pointer  | SP+2
;			+--------+--------+
;			|  New Result MSW | SP+4
;			+--------+--------+
;			|  New Result LSW | SP+8
;			+--------+--------+
; SSTACK: 8 bytes
;         D and X are preserved
;
FCORE_PROC_DIGIT	EQU	*	
			;Allocate temporary variables
			SSTACK_PSHYXD	
			;+--------+--------+
			;|    D (Status)   | SP+0
			;+--------+--------+
			;|        X        | SP+2
			;+--------+--------+
			;|        Y        | SP+4
			;+--------+--------+
			;|  Return value   | SP+6
			;+--------+--------+
			;|      Base       | SP+8
			;+--------+--------+
			;|   Char Pointer  | SP+10
			;+--------+--------+
			;|    Result MSW   | SP+12
			;+--------+--------+
			;|    Result LSW   | SP+14
			;+--------+--------+
FCORE_PROC_DIGIT_D	EQU	0		
FCORE_PROC_DIGIT_X	EQU	2		
FCORE_PROC_DIGIT_Y	EQU	4		
FCORE_PROC_DIGIT_RETURN	EQU	6		
FCORE_PROC_DIGIT_BASE	EQU	8		
FCORE_PROC_DIGIT_CHRPTR	EQU	10
FCORE_PROC_DIGIT_RESHI	EQU	12
FCORE_PROC_DIGIT_RESLO	EQU	14
			;Read next character
			;LDX	FCORE_PROC_DIGIT_CHRPTR,SP
			;LDAB	1,X+
			;STX	FCORE_PROC_DIGIT_CHRPTR,SP		
			LDAB	[FCORE_PROC_DIGIT_CHRPTR,SP]
			;Ignore termination (character in B)
			ANDB	#$7F
			;Convert character to digit (unterminated character in B)
			;[0-9]
			CMPB	#"0"
			BLO	FCORE_PROC_DIGIT_3 	;[,.]
			CMPB	#"9"
			BHI	FCORE_PROC_DIGIT_1 	;[A-Z]
			SUBB	#"0"			;subtract offset
			JOB	FCORE_PROC_DIGIT_5	;check digit
			;[A-Z]
FCORE_PROC_DIGIT_1	CMPB	#"A"
			BLO	FCORE_PROC_DIGIT_8	;not a number
			CMPB	#"Z"
			BHI	FCORE_PROC_DIGIT_2	;[a-z]
			SUBB	#("A"-10)		;subtract offset
			JOB	FCORE_PROC_DIGIT_5 	;check digit
			;[a-z] 
FCORE_PROC_DIGIT_2	CMPB	#"a"			
			BLO	FCORE_PROC_DIGIT_4 	;[_]
			CMPB	#"z"
			BHI	FCORE_PROC_DIGIT_8	;not a number
			SUBB	#("A"-10)		;subtract offset
			JOB	FCORE_PROC_DIGIT_5 	;check digit
			;[,.]
FCORE_PROC_DIGIT_3	CMPB	#","
			BEQ	FCORE_PROC_DIGIT_7 	;filler character
			CMPB	#"."
			BEQ	FCORE_PROC_DIGIT_7 	;filler character
			JOB	FCORE_PROC_DIGIT_8	;not a number
			;[_]
FCORE_PROC_DIGIT_4	CMPB	#"_"
			BEQ	FCORE_PROC_DIGIT_7 	;filler character
			JOB	FCORE_PROC_DIGIT_8	;not a number	
			;Check digit (digit in B)
FCORE_PROC_DIGIT_5	CLRA				;digit in D
			CPD	FCORE_PROC_DIGIT_BASE,SP;check if digit < BASE
			BHS	FCORE_PROC_DIGIT_8	;not a number
			STD	FCORE_PROC_DIGIT_Y,SP   ;store digit
			;Multiply result by base
			LDY	FCORE_PROC_DIGIT_RESLO,SP
			LDD	FCORE_PROC_DIGIT_BASE,SP
			EMUL				;Y * D => Y:D
			STD	FCORE_PROC_DIGIT_RESLO,SP
			LDD	FCORE_PROC_DIGIT_RESHI,SP
			STY	FCORE_PROC_DIGIT_RESHI,SP
			LDY	FCORE_PROC_DIGIT_BASE,SP
			EMUL				;Y * D => Y:D
			TBNE	Y, FCORE_PROC_DIGIT_8	;number out of range 	
			ADDD	FCORE_PROC_DIGIT_RESHI,SP
			BCS	FCORE_PROC_DIGIT_8	;number out of range
			STD	FCORE_PROC_DIGIT_RESHI,SP
			;Add digit to result
			LDD	FCORE_PROC_DIGIT_RESLO,SP
			ADDD	FCORE_PROC_DIGIT_Y,SP
			STD	FCORE_PROC_DIGIT_RESLO,SP
			LDD	#$0000
			ADCB	FCORE_PROC_DIGIT_RESHI+1,SP
			ADCA	FCORE_PROC_DIGIT_RESHI,SP
			BCS	FCORE_PROC_DIGIT_8	;number out of range
			STD	FCORE_PROC_DIGIT_RESHI,SP
			;Set status
			MOVW	#$0000, FCORE_PROC_DIGIT_Y,SP
			;Done
FCORE_PROC_DIGIT_6	SSTACK_PULDXY
			SSTACK_RTS
			;Filler char
FCORE_PROC_DIGIT_7	MOVW	#$0002, FCORE_PROC_DIGIT_Y,SP
			JOB	FCORE_PROC_DIGIT_6 	;done		
			;Not a number
FCORE_PROC_DIGIT_8	MOVW	#$0004, FCORE_PROC_DIGIT_Y,SP
			JOB	FCORE_PROC_DIGIT_6 	;done		
	
;#Locate the cody of a CREATEd word 
; args:   X: pointer to CFA
; result: X: pointer to BODY (0 in case of a non-CREATEd word)
; SSTACK: 4 bytes
;         Y and D are preserved
FCORE_TO_BODY		EQU	*	
			;Save registers
			SSTACK_PSHD
			;Get CFA 
			LDD	0,X	;CF  -> D
			LEAX	2,X
			;Check if it is a VARIABLE definition 
			CPD	#CF_VARIABLE_RT
			BEQ	FCORE_TO_BODY_1 	;done
			;Check if it is a CONSTANT definition 
			CPD	#CF_CONSTANT_RT
			BEQ	FCORE_TO_BODY_1 	;done
			;Check if it is a CREATE definition
			LEAX	2,X
			CPD	#CF_CREATE_RT
			BEQ	FCORE_TO_BODY_1 	;done
			;Non-CREATED word
			LDX	#$0000	
			;Restore registers 
FCORE_TO_BODY_1		SSTACK_PULD
			SSTACK_RTS

;#Convert a terminated string into a number
; args:   Stack:        +--------+--------+
;			|      Base       | SP+2
;			+--------+--------+
;			|   Char Pointer  | SP+4
;			+--------+--------+
;			|    Result MSW   | SP+6
;			+--------+--------+
;			|    Result LSW   | SP+8
;			+--------+--------+
;			|   String Size   | SP+10
;			+--------+--------+
; result: Y:     Status (0: everything ok, 2:overflow) 	
;         Stack:        +--------+--------+
;			|      Base       | SP+0
;			+--------+--------+
;			|   Char Pointer  | SP+2
;			+--------+--------+
;			|  New Result MSW | SP+4
;			+--------+--------+
;			|  New Result LSW | SP+6
;			+--------+--------+
;			| Remaining Chars | SP+8
;			+--------+--------+
; SSTACK: 20 bytes
;         No registers are preserved
FCORE_TO_NUMBER		EQU	*
FCORE_TO_NUMBER_BASE	EQU	2		
FCORE_TO_NUMBER_CHRPTR	EQU	4
FCORE_TO_NUMBER_RESHI	EQU	6
FCORE_TO_NUMBER_RESLO	EQU	8
FCORE_TO_NUMBER_CHRCNT	EQU	10
			;Process one character 
FCORE_TO_NUMBER_1	SSTACK_PULX
			SSTACK_JOBSR	FCORE_PROC_DIGIT
			SSTACK_PSHX
			JMP	[FCORE_TO_NUMBER_TAB,Y]

FCORE_TO_NUMBER_TAB	DW	FCORE_TO_NUMBER_2 		;process next digit
			DW	FCORE_TO_NUMBER_2		;process next digit
			DW	FCORE_TO_NUMBER_3		;stop
			
			;Process next number
FCORE_TO_NUMBER_2	LDD	FCORE_TO_NUMBER_CHRCNT,SP
			DBEQ	D, FCORE_TO_NUMBER_3		;stop
			STD	FCORE_TO_NUMBER_CHRCNT,SP
			LDY	FCORE_TO_NUMBER_CHRPTR,Y
			LEAY	1,Y
			STY	FCORE_TO_NUMBER_CHRPTR,Y
			JOB	FCORE_TO_NUMBER_1
			;Stop 
FCORE_TO_NUMBER_3	SSTACK_RTS	
	
;#Find the next whitespace delimitered string on the TIB, and don't modify the string
; args:   none
; result: X: string pointer
;	  D: character count
; SSTACK: 4 bytes
;         Y is preserved
FCORE_WORD		EQU	*	
			;Save registers
			SSTACK_PSHY			;save index Y
			;Skip leading whitespaces
			LDY	TO_IN			;current >IN -> Y	
FCORE_WORD_1		CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FCORE_WORD_5		;return empty string
			LDAB	TIB_START,Y
			LEAY	1,Y			;increment string pointer
			CMPB	#"!"	
			BLO	FCORE_WORD_1 		;whitespace
			CMPB	#"~"
			BHI	FCORE_WORD_1		;whitespace
			;Save start address in X (index of 2nd character in Y)
			LEAY	-1,Y 			;revert >IN		
			LEAX	TIB_START,Y 		;calculate string pointer
			;Find the end of the string (index of 1st character in Y, string pointer in X)
FCORE_WORD_2		LDD	TIB_START,Y		;next two characters -> D
			LEAY	1,Y			;increment string pointer
			CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FCORE_WORD_3 		;terminate string	
			CMPB	#"!"	
			BLO	FCORE_WORD_3 		;terminate string
			CMPB	#"~"
			BLS	FCORE_WORD_2		;check next character
			;Adjust >IN pointer (pointer to last character in Y, string pointer in X)
FCORE_WORD_3		TFR	Y,D
			ADDD	#1			;skip the trailing whitespace
			EMIND	TIB_START,Y		;don't go beyond the end of the TIB
			STD	TO_IN
			;Calculate character count (pointer to last character in Y, string pointer in X)
			TFR	X, D 			;string pointer -> D
			COMA				;negate D
			COMB
			LEAY	TIB_START+1,Y		;(-D-1) + (Y+1) -> Y
			LEAY	D,Y 			
			TFR	Y, D			;character count -> D
			;Done
FCORE_WORD_4		SSTACK_PULY			;restore index Y
			SSTACK_RTS
			;Return empty string
FCORE_WORD_5		MOVW	NUMBER_TIB, TO_IN	;update >IN pointer
			LDX	#$0000			;set string pointer to 
			CLRA
			JOB	FCORE_WORD_4

;#Get command line input and store it into the TIB
; args:   none
; result: D: character count	
;         X: error handler (0 if everything goes well)	
; SSTACK: 18 bytes
;         Y is preserved
FCORE_QUERY		EQU	*	
			;Determine the TIB size limit
			LDD	RSP
			SUBD	#TIB_START
			;Get command line (char limit in D)
			LDX	#TIB_START
			SSTACK_JOBSR	FCORE_ACCEPT	;(SSTACK: 16 bytes)
			;Update #TIB and >IN (char count in D, error status in X)
			STD	NUMBER_TIB
			MOVW	#$0000, TO_IN
			;Done (char count in D, error status in X)
			SSTACK_RTS
	
;Exceptions:
;===========
;Standard exceptions
FCORE_THROW_ABORT	FEXCPT_THROW	FEXCPT_EC_ABORT		;ABORT
FCORE_THROW_ABORTQ	FEXCPT_THROW	FEXCPT_EC_ABORTQ	;ABORT"
FCORE_THROW_PSOF	EQU	FMEM_THROW_PSOF			;stack overflow
FCORE_THROW_PSUF	EQU	FMEM_THROW_PSUF			;stack underflow
FCORE_THROW_RSOF	EQU	FMEM_THROW_PSOF			;return stack overflow
FCORE_THROW_RSUF	EQU	FMEM_THROW_RSUF 		;return stack underflow
FCORE_THROW_DOOF	FEXCPT_THROW	FEXCPT_EC_DOOF		;DO-loop nested too deeply	
FCORE_THROW_DICTOF	EQU	FMEM_THROW_DICTOF		;dictionary overflow
FCORE_THROW_0DIV	FEXCPT_THROW	FEXCPT_EC_0DIV		;division by zero
FCORE_THROW_RESOR	FEXCPT_THROW	FEXCPT_EC_RESOR		;result out of range
FCORE_THROW_UDEFWORD	FEXCPT_THROW	FEXCPT_EC_UDEFWORD	;undefined word
FCORE_THROW_COMPONLY	FEXCPT_THROW	FEXCPT_EC_COMPONLY	;interpreting a compile-only word
FCORE_THROW_NONAME	FEXCPT_THROW	FEXCPT_EC_NONAME	;missing name argument
FCORE_THROW_PADOF	EQU	FMEM_THROW_PADOF		;pictured numeric output string overflow
FCORE_THROW_STROF	FEXCPT_THROW	FEXCPT_EC_STROF		;parsed string overflow
FCORE_THROW_CTRLSTRUC	FEXCPT_THROW	FEXCPT_EC_CTRLSTRUC	;control structure mismatch
FCORE_THROW_INVALNUM	FEXCPT_THROW	FEXCPT_EC_INVALNUM	;invalid numeric argument
FCORE_THROW_COMPNEST	FEXCPT_THROW	FEXCPT_EC_COMPNEST	;compiler nesting
FCORE_THROW_NONCREATE	FEXCPT_THROW	FEXCPT_EC_NONCREATE	;invalid usage of non-CREATEd definition
;FCORE_THROW_INVALNAME	FEXCPT_THROW	FEXCPT_EC_INVALNAME	;invalid name
FCORE_THROW_INVALBASE	FEXCPT_THROW	FEXCPT_EC_INVALBASE	;invalid BASE
FCORE_THROW_QUIT	FEXCPT_THROW	FEXCPT_EC_QUIT		;QUIT

;Non-Standard exceptions
FCORE_THROW_NOMSG	EQU		FEXCPT_THROW_NOMSG	;empty message string
FCORE_THROW_DICTPROT	FEXCPT_THROW	FEXCPT_EC_DICTPROT	;destruction of dictionary structure
;FCORE_THROW_COMERR	FEXCPT_THROW	FEXCPT_EC_COMERR	;invalid RX data
;FCORE_THROW_COMOF	FEXCPT_THROW	FEXCPT_EC_COMOF		;RX buffer overflow

;Common throw routines
FCORE_THROW_X		TFR	X, D 				;throw error code in X
			JOB	FEXCPT_THROW

;Common code fields:
;=================== 	
;CF_INNER   ( -- )
			;Execute the first execution token after the CFA (CFA in X)
CF_INNER		EQU		*
			RS_PUSH_KEEP_X	IP, CF_INNER_RSOF	;IP -> RS		=>20 cycles
			LEAY		4,X			;CFA+4 -> IP		=> 2 cycles
			STY		IP			;			=> 3 cycles
			LDX		2,X			;new CFA -> X		=> 3 cycles
			JMP		[0,X]			;JUMP [new CFA]         => 6 cycles
								;                         ---------
							;                         34 cycles
CF_INNER_RSOF		JOB	FCORE_THROW_RSOF
	
;CF_NOP   ( -- )
			;No operation
CF_NOP			EQU		*	
			NEXT

FCORE_CODE_END		EQU	*
FCORE_CODE_END_LIN	EQU	@
			
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FCORE_TABS_START_LIN
			ORG 	FCORE_TABS_START, FCORE_TABS_START_LIN
#else
			ORG 	FCORE_TABS_START
#endif	

;System prompt
FCORE_SUSPEND_PROMPT	FCS	"S "
FCORE_INTERPRET_PROMPT	FCS	"> "
FCORE_COMPILE_PROMPT	FCS	"+ "
FCORE_SKIP_PROMPT	FCS	"0 "
FCORE_SYSTEM_PROMPT	FCS	" ok"

;Character conversion for NAME
;			;	 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
;FCORE_NAME_TAB		DB	$00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 ;$0x
;			DB	$00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 ;$1x
;			DB      $00 "!" $22 "#" "$" "%"	"&" $27 "(" ")" "*" "+" "," "-" "." "/" ;$2x
;			DB	"0" "1" "2" "3" "4" "5" "6" "7" "8" "9" ":" ";" "<" "=" ">" "?" ;$3x
;			DB	"@" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" ;$4x
;			DB	"P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" "[" $5C "]" "^" "_" ;$5x
;			DB	$60 "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" ;$6x
;			DB	"P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" "{" "|" "}" "~" $00 ;$7x
									
FCORE_TABS_END		EQU	*
FCORE_TABS_END_LIN	EQU	@

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FCORE_WORDS_START ;(previous NFA: FCORE_PREV_NFA)

;#Core words (CORE):
; ==================
	
;! ( x a-addr -- )
;Store x at a-addr.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_STORE		FHEADER, "!", FCORE_PREV_NFA, COMPILE
CFA_STORE		DW	CF_STORE
CF_STORE		PS_CHECK_UF 2, CF_STORE_PSUF 	;check for underflow  (PSP -> Y)
			LDX	2,Y+			;x -> a-addr	
			MOVW	2,Y+, 0,X
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
			ALIGN	1
NFA_NUMBER_SIGN		FHEADER, "#", NFA_STORE, COMPILE
CFA_NUMBER_SIGN		DW	CF_NUMBER_SIGN
CF_NUMBER_SIGN		PS_CHECK_UF	2, CF_NUMBER_SIGN_PSUF 	;check for underflow  (PSP -> Y)
			BASE_CHECK	CF_NUMBER_SIGN_INVALBASE;check BASE value (BASE -> D)
			;Perform division (PSP in Y, BASE in D)
			TFR	D,X				;prepare 1st division
			LDD	0,Y				; (ud1>>16)/BASE
			IDIV					;D/X=>X; remainder=D
			STX	0,Y				;return upper word of the result
			LDX	BASE				;prepare 2nd division
			LDY	2,Y
			EXG	D,Y
			EDIV					;Y:D/X=>Y; remainder=>D
			LDX	PSP				;PSP -> X
			STY	2,X
			;Lookup ASCII representation of the remainder (remainder -> D)
			TFR	D,X
			LDAB	FCORE_SYMTAB,X
			;Add ASCII character to the PAD buffer
			PAD_CHECK_OF	CF_NUMBER_SIGN_PADOF	;check for PAD overvlow (HLD -> X)
			STAB	1,-X
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
;String in PAD (at c-addr) is terminated. 
;Throws:
;"Parameter stack underflow"
;
				ALIGN	1
NFA_NUMBER_SIGN_GREATER		FHEADER, "#>", NFA_NUMBER_SIGN, COMPILE
CFA_NUMBER_SIGN_GREATER		DW	CF_NUMBER_SIGN_GREATER
CF_NUMBER_SIGN_GREATER		PS_CHECK_UF	2, CF_NUMBER_SIGN_GREATER_PSUF ;check for underflow
				;Check PAD length (PSP in Y)
				LDD	PAD					;PAD-HLD -> u
				TFR	D, X
				SUBD	HLD
				STD	0,Y
				BEQ	CF_NUMBER_SIGN_GREATER_2 		;zero length string
				;Terminate string (PSP in Y, PAD in X)
				BSET	1,X, #$80 				;set termination bit in last characer
				;Return string pointer (PSP in Y, PAD in X)
				MOVW	HLD, 2,Y				;HLD -> c-addr
				;Done
CF_NUMBER_SIGN_GREATER_1	NEXT
				;Zero-length string (PSP in Y, PAD in X, 0 in D)
CF_NUMBER_SIGN_GREATER_2	STD	2,Y
				JOB	CF_NUMBER_SIGN_GREATER_1

CF_NUMBER_SIGN_GREATER_PSUF	JOB	FCORE_THROW_PSUF
	
;#S ( ud1 -- ud2 )
;Convert one digit of ud1 according to the rule for #. Continue conversion
;until the quotient is zero. ud2 is zero. An ambiguous condition exists if #S
;executes outside of a <# #> delimited number conversion.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"PAD buffer overflow"
;"Invalid BASE value"
;
			ALIGN	1
NFA_NUMBER_SIGN_S	FHEADER, "#S", NFA_NUMBER_SIGN_GREATER, COMPILE
CFA_NUMBER_SIGN_S	DW	CF_NUMBER_SIGN_S
CF_NUMBER_SIGN_S	PS_CHECK_UF	2, CF_NUMBER_SIGN_S_PSUF 	;check for underflow  (PSP -> Y)
			BASE_CHECK	CF_NUMBER_SIGN_S_INVALBASE;check BASE value (BASE -> D)
			;Perform division (PSP in Y, BASE in D)
CF_NUMBER_SIGN_S_1	TFR	D,X				;prepare 1st division
			LDD	0,Y				; (ud1>>16)/BASE
			IDIV					;D/X=>X; remainder=D
			STX	0,Y				;return upper word of the result
			LDX	BASE				;prepare 2nd division
			LDY	2,Y
			EXG	D,Y
			EDIV					;Y:D/X=>Y; remainder=>D
			LDX	PSP				;PSP -> X
			STY	2,X
			;Lookup ASCII representation of the remainder (LSB of quotient in Y, remainder in D)
			TFR	D,X
			LDAB	FCORE_SYMTAB,X
			;Add ASCII character to the PAD buffer (LSB of quotient in Y)
			PAD_CHECK_OF	CF_NUMBER_SIGN_S_PADOF	;check for PAD overvlow (HLD -> X)
			STAB	1,-X
			STX	HLD
			;Check if quotient is zero
			LDD	BASE
			LDY	PSP
			LDX	2,Y
			BNE	CF_NUMBER_SIGN_S_1
			LDX	0,Y
			BNE	CF_NUMBER_SIGN_S_1
			;Quotient is zero
			NEXT

CF_NUMBER_SIGN_S_PSUF		JOB	FCORE_THROW_PSUF
CF_NUMBER_SIGN_S_PADOF		JOB	FCORE_THROW_PADOF
CF_NUMBER_SIGN_S_INVALBASE	JOB	FCORE_THROW_INVALBASE
	
;' ( "<spaces>name" -- xt ) 	;'
;Skip leading space delimiters. Parse name delimited by a space. Find name and
;return xt, the execution token for name. An ambiguous condition exists if name
;is not found.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Missing name argument"
;"Undefined word"
			ALIGN	1
NFA_TICK		FHEADER, "'", NFA_NUMBER_SIGN_S, COMPILE
CFA_TICK		DW	CF_TICK
CF_TICK			PS_CHECK_OF	1, CF_TICK_PSOF 	;check for PS overflow (PSP-2 -> Y)	
			;Parse name (PSP-2 in Y) 
			SSTACK_JOBSR	FCORE_NAME 		;string pointer -> X
			TBEQ	X, CF_TICK_NONAME			
			;Search dictionary (string pointer in X, PSP-2 in Y)
			SSTACK_JOBSR	FCORE_FIND 		;CFA -> X, status -> D
			TBEQ	D, CF_TICK_UDEFWORD
			STX	0,Y
			STY	PSP
			;Done
			NEXT
	
CF_TICK_PSOF		JOB	FCORE_THROW_PSOF	
CF_TICK_NONAME		JOB	FCORE_THROW_NONAME
CF_TICK_UDEFWORD	JOB	FCORE_THROW_UDEFWORD
	
;( 
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<paren>" -- )
;Parse ccc delimited by ) (right parenthesis). ( is an immediate word.
			ALIGN	1
NFA_PAREN		FHEADER, "(", NFA_TICK, IMMEDIATE
CFA_PAREN		DW	CF_PAREN
CF_PAREN		;Skip TIB to next ")"
			LDAA	#")"
			SSTACK_JOBSR	FCORE_PARSE
			;Done
			NEXT
	
;* ( n1|u1 n2|u2 -- n3|u3 )
;Multiply n1|u1 by n2|u2 giving the product n3|u3.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
			ALIGN	1
NFA_STAR_SLASH		FHEADER, "*/", NFA_STAR, COMPILE
CFA_STAR_SLASH		DW	CF_STAR_SLASH
CF_STAR_SLASH		PS_CHECK_UF	3, CF_STAR_SLASH_PSUF ;check for underflow (PSP -> Y)
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
;10
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;"Quotient out of range"
;
			ALIGN	1
NFA_STAR_SLASH_MOD	FHEADER, "*/MOD", NFA_STAR_SLASH, COMPILE
CFA_STAR_SLASH_MOD	DW	CF_STAR_SLASH_MOD
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
			STY	2,+X
			STD	2,X
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
			ALIGN	1
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
			ALIGN	1
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
;
;S12CForth implementation details:
;do-sys format:     ( orig dest -- )
;loop-sys format: (R: limit index -- ) 
;Throws:
;"Parameter stack underflow"
;"Dictionary underflow"
;"Compile-only word"
			ALIGN	1
NFA_PLUS_LOOP		FHEADER, "+LOOP", NFA_PLUS_STORE, IMMEDIATE
CFA_PLUS_LOOP		DW	CF_PLUS_LOOP
			DW	CFA_PLUS_LOOP_RT
CF_PLUS_LOOP		EQU	CF_LOOP

CF_PLUS_LOOP_PSUF	JOB	FCORE_THROW_PSUF
CF_PLUS_LOOP_RSUF	JOB	FCORE_THROW_RSUF
	
;LOOP run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
CFA_PLUS_LOOP_RT	DW	CF_PLUS_LOOP_RT
CF_PLUS_LOOP_RT		PS_CHECK_UF	1, CF_PLUS_LOOP_PSUF	;(PSP -> Y)
			RS_CHECK_UF	2, CF_PLUS_LOOP_RSUF	;(RSP -> X)
			;Increment and check index (RSP in X, PSP in Y)
			LDD	0,X
			ADDD	2,Y-
			STY	PSP
			CPD	2,X
			BEQ	CF_LOOP_RT_1
			;Limit not reached (RSP in X)
			STD	0,X
			JUMP_NEXT
			;Limit reached (RSP in X)
CF_PLUS_LOOP_RT_1	LEAX	4,X
			STX	RSP
			SKIP_NEXT
	
;, ( x -- )
;Reserve one cell of data space and store x in the cell. If the data-space
;pointer is aligned when , begins execution, it will remain aligned when,
;finishes execution. An ambiguous condition exists if the data-space pointer is
;not aligned prior to execution of ,.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;
			ALIGN	1
NFA_COMMA		FHEADER, ",", NFA_PLUS_LOOP, COMPILE
CFA_COMMA		DW	CF_COMMA
CF_COMMA		PS_CHECK_UF	1, CF_COMMA_PSUF 	;check for PS underflow   (PSP -> Y)
			DICT_CHECK_OF	2, CF_COMMA_DICTOF	;check for DICT overflow (CP+bytes -> X)
			MOVW	2,Y+, -2,X
			STY	PSP
			STX	CP
			STX	CP_SAVED
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
			ALIGN	1
NFA_MINUS		FHEADER, "-", NFA_COMMA, COMPILE
CFA_MINUS		DW	CF_MINUS
CF_MINUS		PS_CHECK_UF	2, CF_MINUS_PSUF ;check for underflow (PSP -> Y)
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
			ALIGN	1
NFA_DOT			FHEADER, ".", NFA_MINUS, COMPILE
CFA_DOT			DW	CF_DOT
CF_DOT			PS_PULL_X	CF_DOT_PSUF 	;pull cell from PS
			BASE_CHECK	CF_DOT_INVALBASE;check BASE value
			PRINT_SPC			;print a space character
			PRINT_SINT			;print cell as signed integer
			NEXT

CF_DOT_PSUF		JOB	FCORE_THROW_PSUF
CF_DOT_INVALBASE	JOB	FCORE_THROW_INVALBASE
	
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
;Trows:
;"Dictionary overflow"
;"Parsed string overflow"
;
CF_DOT_QUOTE_DICTOF	JOB	FCORE_THROW_DICTOF
CF_DOT_QUOTE_STROF	JOB	FCORE_THROW_STROF
	
			ALIGN	1
NFA_DOT_QUOTE		FHEADER, '."', NFA_DOT, IMMEDIATE ;"
CFA_DOT_QUOTE		DW	CF_DOT_QUOTE 		;compilation semantics
CF_DOT_QUOTE		;Parse quote
			LDAA	#$22 				;double quote
CF_DOT_QUOTE_1		SSTACK_JOBSR	FCORE_PARSE		;string pointer -> X, character count -> A
			TBEQ	X, CF_DOT_QUOTE_2 		;empty quote		
			;Check state (string pointer in X, character count in A)
			LDY	STATE		 		;ensure that compile mode is on
			BEQ	CF_DOT_QUOTE_3			;interpetation mode
			;Check remaining space in dictionary (string pointer in X, character count in A)
			IBEQ	A, CF_DOT_QUOTE_STROF		;add CFA to count
			TAB
			CLRA
			ADDD	#1
			TFR	X, Y
			DICT_CHECK_OF_D	CF_DOT_QUOTE_DICTOF 	;check for dictionary overflow
			;Append run-time CFA (string pointer in Y)
			LDX	CP
			MOVW	#CFA_DOT_QUOTE_RT, 2,X+
			;Append quote (CP in X, string pointer in Y)
			CPSTR_Y_TO_X
			STX	CP
			;Done
CF_DOT_QUOTE_2		NEXT
			;Print quote in interpretaion state (string pointer in X)
CF_DOT_QUOTE_3		PRINT_STR	
			JOB	CF_DOT_QUOTE_2	
	
;." run-time semantics
;S12CForth implementation details:
;Interpretation semantics:
;Print string to the terminal
;Throws:
;
			ALIGN	1
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
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;
			ALIGN	1
NFA_SLASH		FHEADER, "/", NFA_DOT_QUOTE, COMPILE
CFA_SLASH		DW	CF_SLASH
CF_SLASH		PS_CHECK_UF	2, CF_SLASH_PSUF ;check for underflow (PSP -> Y)
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
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;
			ALIGN	1
NFA_SLASH_MOD		FHEADER, "/MOD", NFA_SLASH, COMPILE
CFA_SLASH_MOD		DW	CF_SLASH_MOD
CF_SLASH_MOD		PS_CHECK_UF	2, CF_SLASH_MOD_PSUF	;check for underflow  (PSP -> Y)
			LDD	2,Y				;n1   -> D
			LDX	0,Y				;n2   -> X
			BEQ	CF_SLASH_0DIV		 	;divide by zero
			IDIVS				 	;D/X  -> X, remainder -> D
			STD	0,Y
			STX	2,Y
			NEXT
		
CF_SLASH_MOD_PSUF	JOB	FCORE_THROW_PSUF
CF_SLASH_MOD_0DIV	JOB	FCORE_THROW_0DIV
	
;0< ( n -- flag )
;flag is true if and only if n is less than zero.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_ZERO_LESS		FHEADER, "0<", NFA_SLASH_MOD, COMPILE
CFA_ZERO_LESS		DW	CF_ZERO_LESS
CF_ZERO_LESS		PS_CHECK_UF 1, CF_ZERO_LESS_PSUF	;(PSP -> Y)
			LDX	0,Y
			BMI	<CF_ZERO_LESS_2
CF_ZERO_LESS_1		MOVW	#$0000, 0,Y
			NEXT
CF_ZERO_LESS_2		EQU	CF_ZERO_EQUALS_1	

CF_ZERO_LESS_PSUF	JOB	FCORE_THROW_PSUF

;0= ( x -- flag )
;flag is true if and only if x is equal to zero.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_ZERO_EQUALS		FHEADER, "0=", NFA_ZERO_LESS, COMPILE
CFA_ZERO_EQUALS		DW	CF_ZERO_EQUALS
CF_ZERO_EQUALS		PS_CHECK_UF 1, CF_ZERO_EQUALS_PSUF	;(PSP -> Y)
			LDX	0,Y
			BNE	<CF_ZERO_EQUALS_2
CF_ZERO_EQUALS_1	MOVW	#$FFFF, 0,Y
			NEXT
CF_ZERO_EQUALS_2	EQU	CF_ZERO_LESS_1

CF_ZERO_EQUALS_PSUF	JOB	FCORE_THROW_PSUF

;1+ ( n1|u1 -- n2|u2 )
;Add one (1) to n1|u1 giving the sum n2|u2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_ONE_PLUS		FHEADER, "1+", NFA_ZERO_EQUALS, COMPILE
CFA_ONE_PLUS		DW	CF_ONE_PLUS
CF_ONE_PLUS		PS_CHECK_UF 1, CF_ONE_MINUS_PSUF	;(PSP -> Y)
			LDX	0,Y
			LEAX	1,X
			STX	0,Y
			NEXT

CF_ONE_PLUS_PSUF	JOB	FCORE_THROW_PSUF
	
;1- ( n1|u1 -- n2|u2 ) 
;Subtract one (1) from n1|u1 giving the difference n2|u2.
			ALIGN	1
NFA_ONE_MINUS		FHEADER, "1-", NFA_ONE_PLUS, COMPILE
CFA_ONE_MINUS		DW	CF_ONE_MINUS
CF_ONE_MINUS		PS_CHECK_UF 1, CF_ONE_MINUS_PSUF	;(PSP -> Y)
			LDX	0,Y
			LEAX	-1,X
			STX	0,Y
			NEXT
	
CF_ONE_MINUS_PSUF	JOB	FCORE_THROW_PSUF
	
;2! ( x1 x2 a-addr -- )
;Store the cell pair x1 x2 at a-addr, with x2 at a-addr and x1 at the next
;consecutive cell. It is equivalent to the sequence SWAP OVER ! CELL+ ! .
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_TWO_STORE		FHEADER, "2!", NFA_ONE_MINUS, COMPILE
CFA_TWO_STORE		DW	CF_TWO_STORE
CF_TWO_STORE		PS_CHECK_UF 3, CF_TWO_STORE_PSUF 	;check for underflow  (PSP -> Y)
			LDX	2,Y+				;x -> a-addr	
			MOVW	2,Y+, 2,X+
			MOVW	2,Y+, 0,X
			STY	PSP
			NEXT
	
CF_TWO_STORE_PSUF	JOB	FCORE_THROW_PSUF

;2* ( x1 -- x2 )
;x2 is the result of shifting x1 one bit toward the most-significant bit,
;filling the vacated least-significant bit with zero.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
			ALIGN	1
NFA_TWO_FETCH		FHEADER, "2@", NFA_TWO_SLASH, COMPILE
CFA_TWO_FETCH		DW	CF_TWO_FETCH
CF_TWO_FETCH		PS_CHECK_UFOF	1, CF_TWO_FETCH_PSUF, 1, CF_TWO_FETCH_PSOF	;check for under and overflow
			;Fetch data (PSP-2 in Y)
			LDX	2,Y
			MOVW	2,X, 2,Y
			MOVW	0,X, 0,Y
			STY	PSP
			;Done
			NEXT
	
CF_TWO_FETCH_PSUF	JOB	FCORE_THROW_PSUF
CF_TWO_FETCH_PSOF	JOB	FCORE_THROW_PSOF

;2DROP ( x1 x2 -- )
;Drop cell pair x1 x2 from the stack.
;
;S12CForth implementation details:
; - Doesn't throw any exception, resets the parameter stack on underflow 
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
			ALIGN	1
NFA_TWO_DUP		FHEADER, "2DUP", NFA_TWO_DROP, COMPILE
CFA_TWO_DUP		DW		CF_TWO_DUP
CF_TWO_DUP		PS_CHECK_UFOF	2, CF_TWO_DUP_PSUF, 2, CF_TWO_DUP_PSOF	;check for under and overflow
			MOVW		6,Y, 2,Y				;duplicate stack entry
			MOVW		4,Y, 0,Y				;duplicate stack entry
			STY		PSP
			NEXT

CF_TWO_DUP_PSUF		JOB	FCORE_THROW_PSUF
CF_TWO_DUP_PSOF		JOB	FCORE_THROW_PSOF

	
;2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;Copy cell pair x1 x2 to the top of the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_TWO_SWAP		FHEADER, "2SWAP", NFA_TWO_OVER, COMPILE
CFA_TWO_SWAP		DW	CF_TWO_SWAP
CF_TWO_SWAP		PS_CHECK_UF 4, CF_TWO_SWAP_PSUF	;(PSP -> Y)
			LDD	0,Y
			LDX	2,Y
			MOVW	4,Y 0,Y
			MOVW	6,Y 2,Y
			STD	4,Y
			STX	6,Y
			NEXT
	
CF_TWO_SWAP_PSUF	JOB	FCORE_THROW_PSUF
	
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
;
;S12CForth implementation details:
;colon-sys is the NFA if the new definition. $0000 is used for :NONAME
;definitions. 
;Throws:
;"Parameter stack overflow"
;"Missing name argument"
;"Dictionary overflow"
;"Compiler nesting"
;
			ALIGN	1
NFA_COLON		FHEADER, ":", NFA_TWO_SWAP, IMMEDIATE
CFA_COLON		DW	CF_COLON
CF_COLON		INTERPRET_ONLY	CF_COLON_COMPNEST	;check for nested definition
			PS_CHECK_OF	1, CF_COLON_PSOF 	;check for PS overflow (PSP-2 -> Y)	
			;Build header (PSP-2 -> Y)
			SSTACK_JOBSR	FCORE_HEADER ;NFA -> D, error handler -> X(SSTACK: 10  bytes)
			TBNE	X, CF_COLON_ERROR
			;Push NFA onto PS (PSP-2 -> Y) 
			STD	0,Y
			STY	PSP
			;Append CFA 
			LDX	CP
			MOVW	#CF_INNER, 2,X+
			STX	CP
			;Enter compile state 
			MOVW	#$0001, STATE
			;Done 
			NEXT
			;Error handler for FCORE_HEADER 
CF_COLON_ERROR		JMP	0,X
	
CF_COLON_PSOF		JOB	FCORE_THROW_PSOF
CF_COLON_COMPNEST	JOB	FCORE_THROW_COMPNEST

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
;colon-sys is the NFA if the new definition. $0000 is used for :NONAME
;definitions. 
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
	
			ALIGN	1
NFA_SEMICOLON		FHEADER, ";", NFA_COLON, IMMEDIATE
CFA_SEMICOLON		DW	CF_SEMICOLON
CF_SEMICOLON		COMPILE_ONLY	CF_SEMICOLON_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_SEMICOLON_CTRLSTRUC;(PSP -> Y)
			DICT_CHECK_OF	2, CF_SEMICOLON_DICTOF	;(CP+2 -> X)
			;Check colon-sys (PSP in Y, CP+2 in X)
			LDX	0,Y
			BEQ	CF_SEMICOLON_2 			;:NONAME definition	
			;Verify NFA (NFA in X, PSP in Y)
			LDAA	2,+X
			BMI	CF_SEMICOLON_CTRLSTRUC		;NFA is not valid: word is immediate
			INCA					;check if CFA points to CF_INNER
			LDD	A,X
			CPD	#CF_INNER
			BNE	CF_SEMICOLON_CTRLSTRUC		;NFA is not valid: wrong CFA
			;Set previous NFA (PSP in Y)
			MOVW	2,Y+, LAST_NFA
CF_SEMICOLON_1		STY	PSP
			;Add "EXIT" to the compilation
			LDX	CP
			MOVW	#CFA_EXIT_RT, 2,X+
			STX	CP
			;Update CP_SAVED
			MOVW	CP, CP_SAVED
			;Leave compile state 
			MOVW	#$0000, STATE
			;Done 
			NEXT
			;:NONAME definition
CF_SEMICOLON_2		PS_CHECK_UF	2, CF_SEMICOLON_CTRLSTRUC;(PSP -> Y)
			LDX	2,+Y				;Check if the correct CFA was stored
			LDD	0,X
			CPD	#CF_INNER
			BEQ	CF_SEMICOLON_1			;CFA is not valid:
			;JOB	CF_SEMICOLON_CTRLSTRUC
	
CF_SEMICOLON_CTRLSTRUC	JOB	FCORE_THROW_CTRLSTRUC
CF_SEMICOLON_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_SEMICOLON_DICTOF	JOB	FCORE_THROW_DICTOF

	
;< ( n1 n2 -- flag )
;flag is true if and only if n1 is less than n2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_LESS_THAN		FHEADER, "<", NFA_SEMICOLON, COMPILE
CFA_LESS_THAN		DW	CF_LESS_THAN
CF_LESS_THAN		PS_CHECK_UF 2, CF_LESS_THAN_PSUF 	;check for underflow  (PSP -> Y)
			LDD	2,Y			;u1 -> D
			MOVW	#$FFFF, 2,Y		;TRUE
			CPD	2,Y+
			BLT	CF_LESS_THAN_1
			MOVW	#$0000, 0,Y
CF_LESS_THAN_1		STY	PSP
			NEXT
	
CF_LESS_THAN_PSUF	JOB	FCORE_THROW_PSUF
	
;<# ( -- )
;Initialize the pictured numeric output conversion process.
;
;S12CForth implementation details:
;-Allocates the PAD buffer
			ALIGN	1
NFA_LESS_NUMBER_SIGN	FHEADER, "<#", NFA_LESS_THAN, COMPILE
CFA_LESS_NUMBER_SIGN	DW	CF_LESS_NUMBER_SIGN
CF_LESS_NUMBER_SIGN	PAD_ALLOC
			NEXT
	
;= ( x1 x2 -- flag )
;flag is true if and only if x1 is bit-for-bit the same as x2.
;S12CForth implementation details:
;
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_EQUALS		FHEADER, "=", NFA_LESS_NUMBER_SIGN, COMPILE
CFA_EQUALS		DW	CF_EQUALS
CF_EQUALS		PS_CHECK_UF 2, CF_EQUALS_PSUF 	;check for underflow  (PSP -> Y)
			LDD	2,Y			;u1 -> D
			MOVW	#$FFFF, 2,Y		;TRUE
			CPD	2,Y+
			BEQ	CF_EQUALS_1
			MOVW	#$0000, 0,Y
CF_EQUALS_1		STY	PSP
			NEXT	
	
CF_EQUALS_PSUF	JOB	FCORE_THROW_PSUF

;> ( n1 n2 -- flag )
;flag is true if and only if n1 is greater than n2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_GREATER_THAN	FHEADER, ">", NFA_EQUALS, COMPILE
CFA_GREATER_THAN	DW	CF_GREATER_THAN
CF_GREATER_THAN		PS_CHECK_UF 2, CF_GREATER_THAN_PSUF 	;check for underflow  (PSP -> Y)
			LDD	2,Y			;u1 -> D
			MOVW	#$FFFF, 2,Y		;TRUE
			CPD	2,Y+
			BGT	CF_GREATER_THAN_1
			MOVW	#$0000, 0,Y
CF_GREATER_THAN_1	STY	PSP
			NEXT
	
CF_GREATER_THAN_PSUF	JOB	FCORE_THROW_PSUF

;>BODY ( xt -- a-addr )
;a-addr is the data-field address corresponding to xt. An ambiguous condition
;exists if xt is not for a word defined via CREATE.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Illegal operation on non-CREATEd definition"
;
			ALIGN	1
NFA_TO_BODY		FHEADER, ">BODY", NFA_GREATER_THAN, COMPILE
CFA_TO_BODY		DW	CF_TO_BODY
CF_TO_BODY		PS_CHECK_UF	1, CF_TO_BODY_PSUF ;check for underflow
			;Check CFA (PSP in Y)
			LDX	0,Y 	;CFA -> X
			SSTACK_JOBSR	FCORE_TO_BODY
			TBEQ	X, CF_TO_BODY_NONCREATE 	;error
			STX	0,Y
			;Done 	
			NEXT
	
CF_TO_BODY_PSUF		JOB	FCORE_THROW_PSUF
CF_TO_BODY_NONCREATE	JOB	FCORE_THROW_NONCREATE
	
;>IN ( -- a-addr )
;a-addr is the address of a cell containing the offset in characters from the
;start of the input buffer to the start of the parse area.
			ALIGN	1
NFA_TO_IN		FHEADER, ">IN", NFA_TO_BODY, COMPILE
CFA_TO_IN		DW	CF_CONSTANT_RT
			DW	TO_IN

;>NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) CHECK!
;ud2 is the unsigned result of converting the characters within the string
;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;left-to-right until a character that is not convertible, including any + or -,
;is encountered or the string is entirely converted. c-addr2 is the location of
;the first unconverted character or the first character past the end of the
;string if the string was entirely converted. u2 is the number of unconverted
;characters in the string. An ambiguous condition exists if ud2 overflows during
;the conversion. 
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_TO_NUMBER		FHEADER, ">NUMBER", NFA_TO_IN, COMPILE
CFA_TO_NUMBER		DW	CF_TO_NUMBER
CF_TO_NUMBER		PS_CHECK_UF	4, CF_TO_NUMBER_PSUF	;(PSP -> Y)
			;Allocate temporary memory (PSP in Y)
			SSTACK_ALLOC	10
			MOVW	BASE, 0,SP
			MOVW	2,Y,  2,SP
			MOVW	4,Y,  4,SP
			MOVW	6,Y,  6,SP
			MOVW	0,Y, 10,SP
			;Convert to number
			SSTACK_JOBSR	FCORE_TO_NUMBER
			;Return results
			LDY	PSP
			MOVW	2,SP,  2,Y
			MOVW	4,SP,  4,Y
			MOVW	6,SP,  6,Y
			MOVW   10,SP,  0,Y
			;Deallocate temporary memory
			SSTACK_DEALLOC	10
			;Done
			NEXT

CF_TO_NUMBER_PSUF	JOB	FCORE_THROW_PSUF

;>R
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( x -- ) ( R:  -- x )
;Move x to the return stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Return stack overerflow"
;
			ALIGN	1
NFA_TO_R		FHEADER, ">R", NFA_TO_NUMBER, COMPILE
CFA_TO_R		DW	CF_TO_R
CF_TO_R			;Check stacks
			PS_CHECK_UF	1, CF_TO_R_PSUF	;(PSP -> Y)
			RS_CHECK_OF	1, CF_TO_R_RSOF
			;Move data
			LDX	RSP
			MOVW	2,Y+, 2,-X
			STY	PSP
			STX	RSP	
			;Done
			Next

CF_TO_R_PSUF		JOB	FCORE_THROW_PSUF
CF_TO_R_RSOF		JOB	FCORE_THROW_RSOF
	
;?DUP ( x -- 0 | x x )
;Duplicate x if it is non-zero.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overerflow"
;
			ALIGN	1
NFA_QUESTION_DUP	FHEADER, "?DUP", NFA_TO_R, COMPILE
CFA_QUESTION_DUP	DW	CF_QUESTION_DUP
CF_QUESTION_DUP		PS_CHECK_UF	1, CF_QUESTION_DUP_PSUF	;(PSP -> Y)
			;Check value
			LDD	0,Y
			BEQ	CF_QUESTION_DUP_1 	;done
			;Duplicate stack entry (x in D)
			PS_CHECK_OF	1, CF_QUESTION_DUP_PSOF	;(PSP-2 -> Y)
			STD	0,Y
			STY	PSP
			;Done
CF_QUESTION_DUP_1	NEXT	
	
CF_QUESTION_DUP_PSUF		JOB	FCORE_THROW_PSUF
CF_QUESTION_DUP_PSOF		JOB	FCORE_THROW_PSOF
	
;@ ( a-addr -- x )
;x is the value stored at a-addr.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
			ALIGN	1
NFA_ABORT		FHEADER, "ABORT", NFA_FETCH, COMPILE
CFA_ABORT		DW	CF_ABORT
CF_ABORT		JOB	FCORE_THROW_ABORT

;ABORT run-time semantics
CFA_ABORT_RT		DW	CF_ABORT_RT
CF_ABORT_RT		PS_RESET
			JOB	CF_QUIT_RT
	
;ABORT" 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by a " (double-quote). Append the run-time semantics given
;below to the current definition.
;Run-time: ( i*x x1 --  | i*x ) ( R: j*x --  | j*x )
;Remove x1 from the stack. If any bit of x1 is not zero, display ccc and perform
;an implementation-defined abort sequence that includes the function of ABORT.
;
;S12CForth implementation details:
;Throws:
;"Dictionary overflow"
;"Compile-only word"
;"Parsed string overflow"
;"Empty message string"

				;
			ALIGN	1
NFA_ABORT_QUOTE		FHEADER, 'ABORT"', NFA_ABORT, IMMEDIATE ;"
CFA_ABORT_QUOTE		DW	CF_ABORT_QUOTE
CF_ABORT_QUOTE		COMPILE_ONLY	CF_ABORT_QUOTE_COMPONLY ;ensure that compile mode is on
			;Parse quote
			LDAA	#$22 				;double quote
			SSTACK_JOBSR	FCORE_PARSE		;string pointer -> X, character count -> A
			TBEQ	X, CF_ABORT_QUOTE_NOMSG 		;empty quote		
			;Check remaining space in dictionary (string pointer in X, character count in A)
			IBEQ	A, CF_ABORT_QUOTE_STROF		;add CFA to count
			TAB
			CLRA
			ADDD	#1
			TFR	X, Y
			DICT_CHECK_OF_D	CF_ABORT_QUOTE_DICTOF 	;check for dictionary overflow
			;Append run-time CFA (string pointer in Y)
			LDX	CP
			MOVW	#CFA_ABORT_QUOTE_RT, 2,X+
			;Append quote (CP in X, string pointer in Y)
			CPSTR_Y_TO_X
			STX	CP
			;Done
			NEXT
				
CF_ABORT_QUOTE_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_ABORT_QUOTE_DICTOF	JOB	FCORE_THROW_DICTOF
CF_ABORT_QUOTE_STROF	JOB	FCORE_THROW_STROF
CF_ABORT_QUOTE_PSUF	JOB	FCORE_THROW_PSUF
CF_ABORT_QUOTE_NOMSG	JOB	FCORE_THROW_NOMSG
	
;ABORT" run-time semantics
; 
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
			ALIGN	1
CFA_ABORT_QUOTE_RT	DW	CF_ABORT_QUOTE_RT
CF_ABORT_QUOTE_RT	PS_CHECK_UF	1, CF_ABORT_QUOTE_PSUF;check for underflow
			;Check x1
			LDD	2,Y+
			BEQ	CF_ABORT_QUOTE_RT_2 	;all bita are zero
			STY	PSP
			;Update current ABORT" message
			MOVW	IP, ABORT_QUOTE_MSG
			;Throw exception
CF_ABORT_QUOTE_RT_1	JOB	FCORE_THROW_ABORTQ 	;string pointer is i IP
			;Resume
CF_ABORT_QUOTE_RT_2	STY	PSP 			;update PSP
			LDX	IP			;skip over the abort message
			PRINT_STRCNT			;char count -> A
			LEAX	A,X
			STX	IP	
			NEXT	
			
;ABS ( n -- u )
;u is the absolute value of n.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
	
;ACCEPT ( c-addr +n1 -- +n2 ) CHECK!
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
;
;S12CForth implementation details:
;Input is captured in the TIB and afterwards copied to c-addr.
;;Throws:
;"Parameter stack underflow"
;"Invalid numeric argument"	
;"Invalid RX data"
;"RX buffer overflow"
;
			ALIGN	1
NFA_ACCEPT		FHEADER, "ACCEPT", NFA_ABS, COMPILE
CFA_ACCEPT		DW	CF_ACCEPT
CF_ACCEPT		PS_CHECK_UF	2, CF_ACCEPT_PSUF	;PSP -> Y
			;Parse command line (PSP in Y)
			LDD	0,Y
			BMI	CF_ACCEPT_INVALNUM 		;+n1 is negative			
			LDX	2,Y
			SSTACK_JOBSR	FCORE_ACCEPT
			TBNE	X, CF_ACCEPT_COMERR
			;Stack result (+n2 in D, PSP in Y)
			STD	2,+Y
			STY	PSP
			;Done
			NEXT
	
CF_ACCEPT_PSUF		JOB	FCORE_THROW_PSUF
CF_ACCEPT_INVALNUM	JOB	FCORE_THROW_INVALNUM
CF_ACCEPT_COMERR	JMP	0,X
	
;ALIGN ( -- )
;If the data-space pointer is not aligned, reserve enough space to align it.
			ALIGN	1
NFA_ALIGN		FHEADER, "ALIGN", NFA_ACCEPT, COMPILE
CFA_ALIGN		DW	CF_NOP

;ALIGNED ( addr -- a-addr )
;a-addr is the first aligned address greater than or equal to addr.
			ALIGN	1
NFA_ALIGNED		FHEADER, "ALIGNED", NFA_ALIGN, COMPILE
CFA_ALIGNED		DW	CF_NOP

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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Destruction of dictionary structure"
;
			ALIGN	1
NFA_ALLOT		FHEADER, "ALLOT", NFA_ALIGNED, COMPILE
CFA_ALLOT		DW	CF_ALLOT
CF_ALLOT		PS_CHECK_UF	1, CF_ALLOT_PSUF;PSP -> Y
			;Get argument
			LDD	2,Y+
			BEQ	CF_ALLOT_2 		;done
			BMI	CF_ALLOT_3		;deallocate data space
			;Allocate data space (new PSP in Y)
			DICT_CHECK_OF_D	CF_ALLOT_DICTOF ;CP+bytes -> X
CF_ALLOT_1		STX	CP
			STX	CP_SAVED
			;Done (new PSP in Y)
CF_ALLOT_2		STY	PSP
			NEXT
			;Deallocate data space (new PSP in Y) 
CF_ALLOT_3		LDX	CP
			LEAX	D,X
			CPX	LAST_NFA
			BLS	CF_ALLOT_DICTPROT
			JOB	CF_ALLOT_1
	
CF_ALLOT_PSUF		JOB	FCORE_THROW_PSUF	
CF_ALLOT_DICTOF		JOB	FCORE_THROW_DICTOF	
CF_ALLOT_DICTPROT	JOB	FCORE_THROW_DICTPROT

;AND ( x1 x2 -- x3 )
;x3 is the bit-by-bit logical and of x1 with x2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_AND			FHEADER, "AND", NFA_ALLOT, COMPILE
CFA_AND			DW		CF_AND
CF_AND			PS_CHECK_UF	2, CF_AND_PSUF 	;PSP     -> Y
			LDD	2,Y+
			ANDA	0,Y			;D & TOS -> D
			ANDB	1,Y
			STD	0,Y 			;D       -> TOS
			STY	PSP
			NEXT

CF_AND_PSUF		JOB	FCORE_THROW_PSUF
	
;BASE ( -- a-addr )
;a-addr is the address of a cell containing the current number-conversion radix
;{{2...36}}.
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_BEGIN		FHEADER, "BEGIN", NFA_BASE, IMMEDIATE
CFA_BEGIN		DW	CF_BEGIN
CF_BEGIN		COMPILE_ONLY	CF_BEGIN_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_OF	1, CF_BEGIN_PSOF	;overflow check	=> 9 cycles
			MOVW	CP, 0,Y
			STY	PSP
			NEXT

CF_BEGIN_PSOF		JOB	FCORE_THROW_PSOF	
CF_BEGIN_COMPONLY	JOB	FCORE_THROW_COMPONLY
	
;BL ( -- char )
;char is the character value for a space.
			ALIGN	1
NFA_B_L			FHEADER, "BL", NFA_BEGIN, COMPILE
CFA_B_L			DW	CF_CONSTANT_RT
			DW	PRINT_SYM_SPACE

;C! ( char c-addr -- )
;Store char at c-addr. When character size is smaller than cell size, only the
;number of low-order bits corresponding to character size are transferred.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_C_STORE		FHEADER, "C!", NFA_B_L, COMPILE
CFA_C_STORE		DW	CF_C_STORE
CF_C_STORE		PS_CHECK_UF 2, CF_C_STORE_PSUF 	;check for underflow  (PSP -> Y)
			LDX	2,Y+			;x -> a-addr
			LDD	2,Y+
			STAB	0,X
			STY	PSP
			NEXT

CF_C_STORE_PSUF		JOB	FCORE_THROW_PSUF

;C, ( char -- )
;Reserve space for one character in the data space and store char in the space.
;If the data-space pointer is character aligned when C, begins execution, it
;will remain character aligned when C, finishes execution. An ambiguous
;condition exists if the data-space pointer is not character-aligned prior to
;execution of C,.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary space exceeded"
;
			ALIGN	1
NFA_C_COMMA		FHEADER, "C,", NFA_C_STORE, COMPILE
CFA_C_COMMA		DW	CF_C_COMMA
CF_C_COMMA		PS_CHECK_UF	1, CF_C_COMMA_PSUF 	;check for PS underflow   (PSP -> Y)
			DICT_CHECK_OF	1, CF_C_COMMA_DICTOF	;check for DICT overflow (CP+bytes -> X)
			LDD	2,Y+
			STAB	-1,X
			STY	PSP
			STX	CP
			STX	CP_SAVED
			NEXT

CF_C_COMMA_PSUF		JOB	FCORE_THROW_PSUF
CF_C_COMMA_DICTOF	JOB	FCORE_THROW_DICTOF

;C@ ( c-addr -- char )
;Fetch the character stored at c-addr. When the cell size is greater than
;character size, the unused high-order bits are all zeroes.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_C_FETCH		FHEADER, "C@", NFA_C_COMMA, COMPILE
CFA_C_FETCH		DW	CF_C_FETCH
CF_C_FETCH		PS_CHECK_UF	1, CF_C_FETCH_PSUF 	;check for underflow
			LDX		0,Y			;[TOS]	-> TOS
			CLRA
			LDAB		0,X
			STD		0,Y
			NEXT

CF_C_FETCH_PSUF		JOB	FCORE_THROW_PSUF

;CELL+ 	( a-addr1 -- a-addr2 )
;Add the size in address units of a cell to a-addr1, giving a-addr2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_CELL_PLUS		FHEADER, "CELL+", NFA_C_FETCH, COMPILE
CFA_CELL_PLUS		DW	CF_CELL_PLUS
CF_CELL_PLUS		PS_CHECK_UF 1, CF_CELL_PLUS_PSUF 	;check for underflow  (PSP -> Y)
			;a-addr1 + 2 -> a-addr2
			LDD	0,Y
			ADDD	#2
			STD	0,Y
			;Done
			NEXT
	
CF_CELL_PLUS_PSUF	JOB	FCORE_THROW_PSUF
	
;CELLS ( n1 -- n2 )
;n2 is the size in address units of n1 cells.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_CELLS		FHEADER, "CELLS", NFA_CELL_PLUS, COMPILE
CFA_CELLS		DW	CF_CELLS
CF_CELLS		PS_CHECK_UF 1, CF_CELLS_PSUF 	;check for underflow  (PSP -> Y)
			;n1 * 2 -> n2
			LDD	0,Y
			LSLD
			STD	0,Y
			;Done
			NEXT
	
CF_CELLS_PSUF		JOB	FCORE_THROW_PSUF
			
;CHAR 	( "<SPACES>NAME" -- char )
;Skip leading space delimiters. Parse name delimited by a space. Put the value
;of its first character onto the stack.
;
;S12CForth implementation details:
;Returns "0" in case of a zero length string
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_CHAR		FHEADER, "CHAR", NFA_CELLS, COMPILE
CFA_CHAR		DW	CF_CHAR
CF_CHAR			PS_CHECK_OF	1, CF_CHAR_PSOF ;(PSP-2 -> Y)
			;Parse word (new PSP in Y)
			SSTACK_JOBSR	FCORE_WORD 	;string pointer -> X (SSTACK: 4 bytes)
			CLRB
			TBEQ	X, CF_CHAR_1 		;empty string
			;Put char onto stack (new PSP in Y)
			LDAB	0,X
CF_CHAR_1		CLRA
			STD	0,Y
			STY	PSP
			;Done
			NEXT
	
CF_CHAR_PSOF		JOB	FCORE_THROW_PSOF

;CHAR+ ( c-addr1 -- c-addr2 )
;Add the size in address units of a character to c-addr1, giving c-addr2.
			ALIGN	1
NFA_CHAR_PLUS		FHEADER, "CHAR+", NFA_CHAR, COMPILE
CFA_CHAR_PLUS		DW	CF_ONE_PLUS

;CHARS ( n1 -- n2 )
;n2 is the size in address units of n1 characters.
			ALIGN	1
NFA_CHARS		FHEADER, "CHARS", NFA_CHAR_PLUS, COMPILE
CFA_CHARS		DW	CF_NOP

;CLS ( -- empty ) S12CForth extension!
			ALIGN	1
NFA_CLS			FHEADER, "CLS", NFA_CHARS, COMPILE
CFA_CLS			DW	CF_CLS
CF_CLS			;Reset PS
			PS_RESET
			;Done
			NEXT
	
;CONSTANT ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a constant.
;name Execution: ( -- x )
;Place x on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Missing name argument"
;"Dictionary overflow"
			ALIGN	1
NFA_CONSTANT		FHEADER, "CONSTANT", NFA_CLS, COMPILE
CFA_CONSTANT		DW	CF_CONSTANT
CF_CONSTANT		PS_CHECK_UF 1, CF_CONSTANT_PSUF	;(PSP -> Y)
			;Build header (PSP in Y)
			SSTACK_JOBSR	FCORE_HEADER ;NFA -> D, error handler -> X(SSTACK: 10  bytes)
			TBNE	X, CF_CONSTANT_ERROR
			;Update LAST_NFA (PSP in Y)
			STD	LAST_NFA
			;Append CFA (PSP in Y)
			LDX	CP
			MOVW	#CF_CONSTANT_RT, 2,X+
			;Append constant value (PSP in Y, CP in X)
			MOVW	2,Y+, 2,X+
			STX	CP
			STY	PSP
			;Update CP saved (CP in X)
			STX	 CP_SAVED
			;Done 
			NEXT
			;Error handler for FCORE_HEADER 
CF_CONSTANT_ERROR	JMP	0,X

CF_CONSTANT_PSUF	JOB	FCORE_THROW_PSUF
CF_CONSTANT_PSOF	JOB	FCORE_THROW_PSOF
	
;CONSTANT run-time semantics
;Push the contents of the first cell after the CFA onto the parameter stack
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
CF_CONSTANT_RT		PS_CHECK_OF	1, CF_CONSTANT_PSOF	;overflow check	=> 9 cycles
			MOVW		2,X, 0,Y		;[CFA+2] -> PS	=> 5 cycles
			STY		PSP			;		=> 3 cycles
			NEXT					;NEXT		=>15 cycles
								; 		  ---------
								;		  32 cycles
                                                
;COUNT ( c-addr1 -- c-addr2 u )
;Return the character string specification for the counted string stored at
;c-addr1. c-addr2 is the address of the first character after c-addr1. u is the
;contents of the character at c-addr1, which is the length in characters of the
;string at c-addr2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
			ALIGN	1
NFA_COUNT		FHEADER, "COUNT", NFA_CONSTANT, COMPILE
CFA_COUNT		DW	CF_COUNT
CF_COUNT		PS_CHECK_UFOF	1, CF_COUNT_PSUF, 1, CF_COUNT_PSOF ;check for under and overflow
			;Count characters (PSP-2 in Y)
			LDX	2,Y
			PRINT_STRCNT
			;TAB
			;CLRA
			EXG	A, D
			STD	0,Y
			STY	PSP
			;Done
			NEXT
	
CF_COUNT_PSUF		JOB	FCORE_THROW_PSUF
CF_COUNT_PSOF		JOB	FCORE_THROW_PSOF

;CR ( -- )
;Cause subsequent output to appear at the beginning of the next line.
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Missing name argument"
;"Dictionary overflow"
			ALIGN	1
NFA_CREATE		FHEADER, "CREATE", NFA_CR, COMPILE
CFA_CREATE		DW	CF_CREATE
CF_CREATE		;Build header
			SSTACK_JOBSR	FCORE_HEADER ;NFA -> D, error handler -> X (SSTACK: 10  bytes)
			TBNE	X, CF_CREATE_ERROR
			;Update LAST_NFA 
			STD	LAST_NFA
			;Append CFA 
			LDX	CP
			MOVW	#CF_CREATE_RT, 2,X+
			;Append default (no) init pointer
			MOVW	#$0000, 2,X+
			STX	CP
			;Update CP saved (CP in X)
			STX	CP_SAVED
			;Done 
			NEXT
			;Error handler for FCORE_HEADER 
CF_CREATE_ERROR	JMP	0,X

CF_CREATE_PSOF		JOB	FCORE_THROW_PSOF
CF_CREATE_RSOF		JOB	FCORE_THROW_RSOF

;CREATE run-time semantics
;Push the address of the second cell after the CFA onto the parameter stack
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
			ALIGN	1
CFA_CREATE_RT		DW	CF_CREATE_RT	
CF_CREATE_RT		PS_CHECK_OF	1, CF_CREATE_PSOF	;overflow check	=> 9 cycles
			LEAX		4,X			;CFA+4 -> PS	=> 2 cycles
			STX		0,Y			;		=> 3 cycles
			STY		PSP			;		=> 3 cycles
			LDX		-2,X			;new CFA -> X	=> 3 cycles
			BEQ		CF_CREATE_RT_1		;no init code	=> 1 cycles/3 cycle
			RS_PUSH_KEEP_X	IP, CF_CREATE_RSOF	;IP -> RS	=>20 cycles
			LEAY		2,X			;IP+2 -> IP	=> 2 cycles
			STY		IP			;		=> 3 cycles
			LDX		0,X			;JUMP [new CFA]	=> 3 cycles
			JMP		[0,X]			;               => 6 cycles
								;                 ---------
								;                 52 cycles
CF_CREATE_RT_1		NEXT					;NEXT
	
;DECIMAL ( -- )
;Set the numeric conversion radix to ten (decimal).
			ALIGN	1
NFA_DECIMAL		FHEADER, "DECIMAL", NFA_CREATE, COMPILE
CFA_DECIMAL		DW	CF_DECIMAL
CF_DECIMAL		MOVW	#10, BASE
			NEXT

;DEPTH ( -- +n )
;+n is the number of single-cell values contained in the data stack before +n
;was placed on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_DEPTH		FHEADER, "DEPTH", NFA_DECIMAL, COMPILE
CFA_DEPTH		DW	CF_DEPTH
CF_DEPTH		PS_CHECK_OF	1, CF_DEPTH_PSOF	;check for overflow
			LDD	#PS_EMPTY
			SUBD	PSP
			LSRD
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
;
;S12CForth implementation details:
;do-sys format:     ( orig dest -- ) (dest=0 in case of DO)
;loop-sys format: (R: limit index -- ) 
;Throws:
;"DO-loop nested too deeply"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_DO			FHEADER, "DO", NFA_DEPTH, IMMEDIATE
CFA_DO			DW	CF_DO
			DW	CFA_DO_RT
			;DO compile semantics (run-time CFA in [X+2])
CF_DO			COMPILE_ONLY	CF_DO_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_OF	2, CF_DO_PSOF	;(PSP-4 -> Y)
			LDD		2,X	
			DICT_CHECK_OF	2, CF_DO_DICTOF	;(CP+2 -> X)
			;Add run-time CFA to compilation (CP+2 in X, PSP-4 in Y)
			STD	-2,X
			;Stack do-sys onto PS (CP+2 in X, PSP-4 in Y)
			STX	2,Y
			MOVW	#$0000, 0,Y
			STY	PSP
			STX	CP
			;Done
			NEXT

CF_DO_PSOF		JOB	FCORE_THROW_PSOF
CF_DO_PSUF		JOB	FCORE_THROW_PSUF
CF_DO_RSOF		JOB	FCORE_THROW_RSOF
CF_DO_DICTOF		JOB	FCORE_THROW_DICTOF
CF_DO_COMPONLY		JOB	FCORE_THROW_COMPONLY	
	
;DO run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"DO-loop nested too deeply"
			ALIGN	1
CFA_DO_RT		DW	CF_DO_RT
CF_DO_RT		PS_CHECK_UF	2, CF_DO_PSUF	;(PSP -> Y)
			RS_CHECK_OF	2, CF_DO_RSOF	;
			;Move loop-sys from PS to RS
			LDX	RSP	
			MOVW	2,Y+, 4,-X 		;copy index
			MOVW	2,Y+, 2,X 		;copy limit
			STX	RSP
			STY	PSP
			;Done
			NEXT
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
;
;S12CForth implementation details:
;colon-sys is the NFA if the new definition. $0000 is used for :NONAME
;definitions. 
;Throws:
;"Parameter stack overflow"
;"Return stack underflow"
;"Dictionary overflow"
;"Compile-only word"
			ALIGN	1
NFA_DOES		FHEADER, "DOES>", NFA_DO, IMMEDIATE
CFA_DOES		DW	CF_DOES
CF_DOES			COMPILE_ONLY	CF_DOES_COMPONLY 	;ensure that compile mode is on
			DICT_CHECK_OF	2, CF_DOES_DICTOF	;(CP+2 -> X)
			MOVW	#CFA_DOES_RT, -2,X
			STX	CP
			NEXT

;CF_DOES_PSUF		JOB	FCORE_THROW_PSUF
CF_DOES_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_DOES_DICTOF		JOB	FCORE_THROW_DICTOF
CF_DOES_NONCREATE	JOB	FCORE_THROW_NONCREATE

;DOES> run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Illegal operation on non-CREATEd definition"
			ALIGN	1
CFA_DOES_RT		DW	CF_DOES_RT	
			;Check if the most re 
CF_DOES_RT		LDY	LAST_NFA
			LDAA	2,Y
			LEAY	A,Y
			LEAY	3,Y
			LDD	2,Y+
			CPD	CFA_CREATE_RT
			BNE	CF_DOES_NONCREATE	;last word was not defined by CREATE
			MOVW	IP, 0,Y			;add initialization code to CREATEd word
			JOB	CF_EXIT_RT

;DROP ( x -- )
;Remove x from the stack.
;
;S12CForth implementation details:
;Doesn't throw any exception, resets the parameter stack on underflow 
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Control structure mismatch"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_ELSE		FHEADER, "ELSE", NFA_DUP, IMMEDIATE
CFA_ELSE		DW	CF_ELSE
			DW	CFA_ELSE_RT
			;ELSE compile semantics (run-time CFA in [X+2])
CF_ELSE			COMPILE_ONLY	CF_ELSE_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_ELSE_PSUF		;(PSP -> Y)
			LDD	2,X	
			DICT_CHECK_OF	4, CF_ELSE_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP in Y, run-time CFA in D)
			STD     -4,X
			MOVW	#$0000, -2,X
			STX	CP
			;Append current CP to last IF or ELSE
			STX	[0,Y]
			;Stack orig2 onto the PS
			LEAX	-2,X
			STX	0,Y
			;Done 
			NEXT

CF_ELSE_PSUF		JOB	FCORE_THROW_PSUF
CF_ELSE_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_ELSE_DICTOF		JOB	FCORE_THROW_DICTOF

CFA_ELSE_RT		EQU	CFA_AGAIN_RT
	
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_EMIT		FHEADER, "EMIT", NFA_ELSE, COMPILE
CFA_EMIT		DW	CF_EMIT
CF_EMIT			PS_PULL_D	CF_EMIT_PSUF		;PS -> D (=char)
			PRINT_CHAR				;print character (SSTACK: 8 bytes)
			NEXT
			
CF_EMIT_PSUF		JOB	FCORE_THROW_PSUF

;ENVIRONMENT? ( c-addr u -- false | i*x true )
;c-addr is the address of a character string and u is the string's character
;count. u may have a value in the range from zero to an implementation-defined
;maximum which shall not be less than 31. The character string should contain a
;keyword from 3.2.6 Environmental queries or the optional word sets to be
;checked for correspondence with an attribute of the present environment. If the
;system treats the attribute as unknown, the returned flag is false; otherwise,
;the flag is true and the i*x returned is of the type specified in the table for
;the attribute queried.
NFA_ENVIRONMENT_QUERY	EQU	NFA_EMIT

;EVALUATE ( i*x c-addr u -- j*x )
;Save the current input source specification. Store minus-one (-1) in SOURCE-ID
;if it is present. Make the string described by c-addr and u both the input
;source and input buffer, set >IN to zero, and interpret. When the parse area is
;empty, restore the prior input source specification. Other stack effects are
;due to the words EVALUATEd.
NFA_EVALUATE		EQU	NFA_ENVIRONMENT_QUERY

;EXECUTE ( i*x xt -- j*x )
;Remove xt from the stack and perform the semantics identified by it. Other
;stack effects are due to the word EXECUTEd.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_EXECUTE		FHEADER, "EXECUTE", NFA_EVALUATE, COMPILE
CFA_EXECUTE		DW	CF_EXECUTE
CF_EXECUTE		PS_PULL_X	CF_EXECUTE_PSUF		;PS -> X (=CFA)		=>12 cycles
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
;
;S12CForth implementation details:
;Run-time throws:
;"Compile-only word"
;"Dictionary overflow"
			ALIGN	1
NFA_EXIT		FHEADER, "EXIT", NFA_EXECUTE, IMMEDIATE
CFA_EXIT		DW	CF_EXIT
CF_EXIT			COMPILE_ONLY	CF_EXIT_COMPONLY 	;ensure that compile mode is on
			DICT_CHECK_OF	2, CF_EXIT_DICTOF	;(CP+2 -> X)
			;Append CFA (CP+2 in X)
			MOVW	#CFA_EXIT_RT, -2,X
			STX	CP
			;Done 
			NEXT
			
CF_EXIT_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_EXIT_RSUF		JOB	FCORE_THROW_RSUF
CF_EXIT_DICTOF		JOB	FCORE_THROW_DICTOF
	
;EXIT run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Return stack underflow"
			ALIGN	1
CFA_EXIT_RT		DW	CF_EXIT_RT
CF_EXIT_RT		RS_PULL_Y	CF_EXIT_RSUF		;RS -> Y (= IP)		=>12 cycles
			LDX		2,Y+			;IP += 2, CFA -> X	=> 3 cycles
			STY		IP 			;			=> 3 cycles 
			JMP		[0,X]			;JUMP [CFA]             => 6 cycles
								;                         ---------
								;                         24 cycles			
	
;FILL ( c-addr u char -- )
;If u is greater than zero, store char in each of u consecutive characters of
;memory beginning at c-addr.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_FILL		FHEADER, "FILL", NFA_EXIT, COMPILE
CFA_FILL		DW	CF_FILL
CF_FILL			PS_CHECK_UF	3, CF_FILL_PSUF ;check for underflow (PSP -> Y)
			;Pull args fron stack
			LDD	6,Y+ 			;char -> X	
			STY	PSP
			LDX	-2,Y 			;c-addr -> D
			LDY	-4,Y			;u -> Y
			BEQ	CF_FILL_2		;done
			;Fill memory (c-addr in X, u in Y, char in D)
CF_FILL_1		STAB	1,X+
			DBNE	Y, CF_FILL_1
			;Done
CF_FILL_2		NEXT	

CF_FILL_PSUF		JOB	FCORE_THROW_PSUF
	
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
			ALIGN	1
NFA_FIND	 	FHEADER, "FIND", NFA_FILL, COMPILE
CFA_FIND	 	DW	CF_FIND
CF_FIND		 	PS_CHECK_UFOF	1, CF_FIND_PSUF, 1, CF_FIND_PSOF	;check for over and underflow (PSP-2 -> Y)
			;Search dictionary (PSP-2 -> Y)
			LDX	2,Y
			SSTACK_JOBSR	FCORE_FIND
			STX	2,Y
			STD	0,Y
			STY	PSP
			;Done 
			NEXT
		 	
CF_FIND_PSUF	 	JOB	FCORE_THROW_PSUF
CF_FIND_PSOF	 	JOB	FCORE_THROW_PSOF
	
;FM/MOD
;f-m-slash-mod CORE 
;	( d1 n1 -- n2 n3 )
;Divide d1 by n1, giving the floored quotient n3 and the remainder n2. Input and
;output stack arguments are signed. An ambiguous condition exists if n1 is zero
;or if the quotient lies outside the range of a single-cell signed integer.
;Floored Division Example:
;Dividend Divisor Remainder Quotient
;   10       7        3         1
;  -10       7        4        -2
;   10      -7       -4        -2
;  -10      -7       -3         1
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;"Quotient out of range"
;
			ALIGN	1
NFA_F_M_SLASH_MOD	FHEADER, "FM/MOD", NFA_FIND, COMPILE
CFA_F_M_SLASH_MOD	DW	CF_F_M_SLASH_MOD
CF_F_M_SLASH_MOD	PS_CHECK_UF	3, CF_F_M_SLASH_MOD_PSUF ;check for underflow  (PSP -> Y)
			LDX	0,Y			;get divisor
			BEQ	CF_F_M_SLASH_MOD_0DIV	;diviide by zero
			LDD	4,Y			;get dividend
			LDY	2,Y
			EDIVS				;Y:D/X=>Y; remainder=>D
			BVS	CF_F_M_SLASH_MOD_RESOR 	;result out of range
			BPL	CF_F_M_SLASH_MOD_1	;positive result
			TBEQ	D, CF_F_M_SLASH_MOD_1	;remainder is zero
			;Negative result, adust quotient and remainder (quotient in Y, remainder in D)
			LEAY	-1,Y 			;decrement quotient
			ADDD	[PSP]
			;Return result	
CF_F_M_SLASH_MOD_1	LDX	PSP			;PSP -> X
			STY	2,+X			;return quotient
			STD	2,X			;return remainder
			STX	PSP			;update PSP
			;Done 
			NEXT

CF_F_M_SLASH_MOD_PSUF	JOB	FCORE_THROW_PSUF
CF_F_M_SLASH_MOD_0DIV	JOB	FCORE_THROW_0DIV
CF_F_M_SLASH_MOD_RESOR	JOB	FCORE_THROW_RESOR

;HERE ( -- addr )
;addr is the data-space pointer. (points to the next free data space)
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_HERE		FHEADER, "HERE", NFA_F_M_SLASH_MOD, COMPILE
CFA_HERE		DW	CF_CONSTANT_RT
			DW	CP

;HOLD ( char -- )
;Add char to the beginning of the pictured numeric output string. An ambiguous
;condition exists if HOLD executes outside of a <# #> delimited number
;conversion.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"PAD buffer overflow"
;
			ALIGN	1
NFA_HOLD		FHEADER, "HOLD", NFA_HERE, COMPILE
CFA_HOLD		DW	CF_HOLD
CF_HOLD			PS_CHECK_UF	1, CF_HOLD_PSUF ;check for underflow	(PSP -> Y)
			PAD_CHECK_OF	CF_HOLD_PADOF	;check for PAD overvlow (HLD -> X)
			;Add ASCII character to the PAD buffer (PSP -> Y, HLD -> X)
			LDD	2,Y+
			STAB	1,-X
			STX	HLD
			STY	PSP
			NEXT

CF_HOLD_PSUF		JOB	FCORE_THROW_PSUF
CF_HOLD_PADOF		JOB	FCORE_THROW_PADOF
				
;I
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- n|u ) ( R:  loop-sys -- loop-sys )
;n|u is a copy of the current (innermost) loop index. An ambiguous condition
;exists if the loop control parameters are unavailable.
;
;S12CForth implementation details:
;loop-sys has the following format: (R: limit index -- ) 
;Throws:
;"Parameter stack overflow"
;"Return stack underflow"
;
			ALIGN	1
NFA_I			FHEADER, "I", NFA_HOLD, COMPILE
CFA_I			DW	CF_I
CF_I			RS_CHECK_UF	2, CF_I_RSUF	;(RSP -> X)
			PS_CHECK_OF	1, CF_I_PSOF	;(PSP-2 -> Y)
			;Copy index onto PS
			MOVW	0,X, 0,Y
			STY	PSP
			;Done 
			NEXT

CF_I_RSUF		JOB	FCORE_THROW_RSUF
CF_I_PSOF		JOB	FCORE_THROW_PSOF
	
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_IF			FHEADER, "IF", NFA_I, IMMEDIATE
CFA_IF			DW	CF_IF
			DW	CFA_IF_RT
			;IF compile semantics (run-time CFA in [X+2])
CF_IF			COMPILE_ONLY	CF_IF_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_OF	1, CF_IF_PSOF	;(PSP-2 -> Y)
			LDD	2,X	
			DICT_CHECK_OF	4, CF_IF_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP-2 in Y, run-time CFA in D)
			STD	 -4,X
			MOVW	#$0000,	-2,X
			STX	CP
			;Stack orig onto the PS (CP+4 in X, PSP-2 in Y)
			LEAX	-2,X
			STX	0,Y 			;default false action = true action
			STY	PSP
			;Done 
			NEXT

CF_IF_PSOF		JOB	FCORE_THROW_PSOF
CF_IF_PSUF		JOB	FCORE_THROW_PSUF
CF_IF_COMPONLY		JOB	FCORE_THROW_COMPONLY
CF_IF_DICTOF		JOB	FCORE_THROW_DICTOF
	
;IF run-time semantics
;Jump to the a address at IP if the valoue at the PS TOS is false
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
CFA_IF_RT		DW	CF_IF_RT
CF_IF_RT		PS_CHECK_UF	1, CF_IF_PSUF ;check for underflow (PSP -> Y)
			;Check flag (PSP -> Y)
			LDD	2,Y+
			BEQ	CF_IF_RT_1 ;flag is false
			;Flag is true (PSP -> Y)
			STY	PSP
			SKIP_NEXT
			;Flag is false
CF_IF_RT_1		STY	PSP
			JUMP_NEXT
			
;IMMEDIATE ( -- )
;Make the most recent definition an immediate word. An ambiguous condition
;exists if the most recent definition does not have a name.
;
;S12CForth implementation details:
;Modifies most recent (user-defined) named definition. Nothing happens if the
;most recent definition is a CORE word.
;
			ALIGN	1
NFA_IMMEDIATE		FHEADER, "IMMEDIATE", NFA_IF, COMPILE
CFA_IMMEDIATE		DW	CF_IMMEDIATE
CF_IMMEDIATE		;Modify most recent header
			LDX	LAST_NFA  		;find most recent named definition
			BSET	2,X, #$80 		;set immediate bit
			;Done 
			NEXT
	
;INVERT ( x1 -- x2 )
;Invert all bits of x1, giving its logical inverse x2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
;
;S12CForth implementation details:
;loop-sys has the following format: (R: limit index -- ) 
;Throws:
;"Parameter stack overflow"
;"Return stack underflow"
;
			ALIGN	1
NFA_J			FHEADER, "J", NFA_INVERT, COMPILE
CFA_J			DW	CF_J
CF_J			RS_CHECK_UF	4, CF_J_RSUF	;(RSP -> X)
			PS_CHECK_OF	1, CF_J_PSOF	;(PSP-2 -> Y)
			;Copy index onto PS
			MOVW	4,X, 0,Y
			STY	PSP
			;Done 
			NEXT

CF_J_RSUF		JOB	FCORE_THROW_RSUF
CF_J_PSOF		JOB	FCORE_THROW_PSOF

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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Invalid RX data"
;"RX buffer overflow"
;
			ALIGN	1
NFA_KEY			FHEADER, "KEY", NFA_J, COMPILE
CFA_KEY			DW	CF_KEY
CF_KEY			PS_CHECK_OF	1, CF_KEY_PSOF	;check for PS overflow (PSP-2 cells -> Y)
			;Wait for data byte
			LED_BUSY_OFF
			SSTACK_JOBSR	FCORE_KEY       ;(SSTACK: 8 bytes)
			LED_BUSY_ON
			;Check for transmission errors (char in D, PSP in Y, error code in X)
			TBNE	X, CF_KEY_COMMERR
 			;Put received character onto the stack (char in B, PSP in Y)
			STD	0,Y
			STY	PSP
			NEXT

CF_KEY_PSOF		JOB	FCORE_THROW_PSOF
CF_KEY_COMMERR		JOB	FCORE_THROW_X
		
;LEAVE
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the current loop control parameters. An ambiguous condition exists if
;they are unavailable. Continue execution immediately following the innermost
;syntactically enclosing DO ... LOOP or DO ... +LOOP.
;
;S12CForth implementation details:
;do-sys format:     ( orig dest -- )
;loop-sys format: (R: limit index -- ) 
;Throws:
;"Parameter stack overflow"
;"Dictionary underflow"
;"Compile-only word"
;
			ALIGN	1
NFA_LEAVE		FHEADER, "LEAVE", NFA_KEY, IMMEDIATE
CFA_LEAVE		DW	CF_LEAVE
			DW	CFA_LEAVE_RT
			;LEAVE compile semantics (run-time CFA in [X+2])
CF_LEAVE		COMPILE_ONLY	CF_LEAVE_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	2, CF_LEAVE_PSUF	;(PSP -> Y)
			LDD		2,X	
			DICT_CHECK_OF	4, CF_LEAVE_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP in Y)
			STD	-4,X
			MOVW	0,Y, 2,-X 			;swap orig in do-ysy
			STX	0,Y 				
			LEAX	2,X
			STX	CP
			;Done
			NEXT

CF_LEAVE_PSUF		JOB	FCORE_THROW_PSUF
CF_LEAVE_RSUF		JOB	FCORE_THROW_RSUF
CF_LEAVE_DICTOF		JOB	FCORE_THROW_DICTOF
CF_LEAVE_COMPONLY	JOB	FCORE_THROW_COMPONLY	
			
;LEAVE run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Return stack underflow"
;
			ALIGN	1
CFA_LEAVE_RT		DW	CF_LEAVE_RT
CF_LEAVE_RT		RS_CHECK_UF	2, CF_LEAVE_RSUF	;(RSP -> X)
			;Clean up RS (RSP in X)
			LEAX	4,X
			STX	RSP
			;Leave loop
			JUMP_NEXT
	
;LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x -- )
;Append the run-time semantics given below to the current definition.
;Run-time: ( -- x )
;Place x on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow" 
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_LITERAL		FHEADER, "LITERAL", NFA_LEAVE, IMMEDIATE
CFA_LITERAL		DW	CF_LITERAL
			DW	CFA_LITERAL_RT
			;LITERAL compile semantics (run-time CFA in [X+2])
CF_LITERAL		COMPILE_ONLY	CF_LITERAL_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_LITERAL_PSUF	;(PSP -> Y)
			LDD	2,X
			DICT_CHECK_OF	4, CF_LITERAL_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP in Y, run-time CFA in D)
			STD	 -4,X
			;Add TOS to compilation (CP+4 in X, PSP in Y, run-time CFA in D)
			MOVW	2,Y+,	-2,X
			STX	CP
			STY	PSP
			;Done 
			NEXT
				
CF_LITERAL_PSOF		JOB	FCORE_THROW_PSOF	
CF_LITERAL_PSUF		JOB	FCORE_THROW_PSUF	
CF_LITERAL_DICTOF	JOB	FCORE_THROW_DICTOF	
CF_LITERAL_COMPONLY	JOB	FCORE_THROW_COMPONLY
	
;LITERAL run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
			ALIGN	1
CFA_LITERAL_RT		DW	CF_LITERAL_RT
CF_LITERAL_RT		PS_CHECK_OF	1, CF_LITERAL_PSOF 	;check for PS overflow (PSP-new cells -> Y)
			LDX	IP				;push the value at IP onto the PS
			MOVW	2,X+ 0,Y			; and increment the IP
			STX	IP
			STY	PSP
			NEXT

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
;
;S12CForth implementation details:
;do-sys format:     ( orig dest -- )
;loop-sys format: (R: limit index -- ) 
;Throws:
;"Parameter stack underflow"
;"Dictionary underflow"
;"Compile-only word"
			ALIGN	1
NFA_LOOP		FHEADER, "LOOP", NFA_LITERAL, IMMEDIATE
CFA_LOOP		DW	CF_LOOP
			DW	CFA_LOOP_RT
			;LEAVE compile semantics (run-time CFA in [X+2])
CF_LOOP			COMPILE_ONLY	CF_LOOP_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	2, CF_LOOP_PSUF	;(PSP -> Y)
			LDD		2,X	
			DICT_CHECK_OF	4, CF_LOOP_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP in Y)
			STD	-4,X
			MOVW	2,Y, -2,X
			STX	CP
			;Read do-sys (PSP+4 in Y)
			LDX	4,Y+ 				;get case-sys
			STY	PSP				;update PSP
			TBEQ	X, CF_LOOP_2			;done
			;Loop through all LEAVESs 
CF_LOOP_1		LDY	0,X 				;get pointer to next LEAVE or DO
			MOVW	CP, 0,X				;append the correct address
			TFR	Y, X
			TBNE	X, CF_LOOP_1	
			;Done 
CF_LOOP_2		NEXT

CF_LOOP_PSUF		JOB	FCORE_THROW_PSUF
CF_LOOP_RSUF		JOB	FCORE_THROW_RSUF
CF_LOOP_DICTOF		JOB	FCORE_THROW_DICTOF
CF_LOOP_COMPONLY	JOB	FCORE_THROW_COMPONLY

;LOOP run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Return stack underflow"
;
CFA_LOOP_RT		DW	CF_LOOP_RT
CF_LOOP_RT		RS_CHECK_UF	2, CF_LOOP_RSUF	;(RSP -> X)
			;Increment and check index (RSP in X)
			LDD	0,X
			ADDD	#1
			CPD	2,X
			BEQ	CF_LOOP_RT_1
			;Limit not reached (RSP in X)
			STD	0,X
			JUMP_NEXT
			;Limit reached (RSP in X)
CF_LOOP_RT_1		LEAX	4,X
			STX	RSP
			SKIP_NEXT
	
;LSHIFT ( x1 u -- x2 )
;Perform a logical left shift of u bit-places on x1, giving x2. Put zeroes into
;the least significant bits vacated by the shift. An ambiguous condition exists
;if u is greater than or equal to the number of bits in a cell.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
			ALIGN	1
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
			ALIGN	1
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
			ALIGN	1
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
			ALIGN	1
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
			ALIGN	1
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
	
;NEGATE ( n1 -- n2 )
;Negate n1, giving its arithmetic inverse n2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_NEGATE		FHEADER, "NEGATE", NFA_MOVE, COMPILE
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
			ALIGN	1
NFA_OR			FHEADER, "OR", NFA_NEGATE, COMPILE
CFA_OR			DW	CF_OR
CF_OR			PS_CHECK_UF	2, CF_OR_PSUF ;check for underflow  (PSP -> Y)
			LDD	2,Y+
			ORAA	0,Y
			ORAB	1,Y
			STD	0,Y
			STY	PSP
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
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Dictionary overflow"
;"Missing name argument"
;"Undefined word"
;"Compile-only word"
			ALIGN	1
NFA_POSTPONE		FHEADER, "POSTPONE", NFA_OVER, IMMEDIATE
CFA_POSTPONE		DW	CF_POSTPONE
CF_POSTPONE		COMPILE_ONLY	CF_POSTPONE_COMPONLY 	;ensure that compile mode is on
			DICT_CHECK_OF	2, CF_POSTPONE_DICTOF	;(CP+2 -> X)
			;Parse name (CP+2 -> X)
			TFR	X, Y
			SSTACK_JOBSR	FCORE_NAME 		;string pointer -> X
			TBEQ	X, CF_POSTPONE_NONAME
			;Search dictionary (string pointer in X, CF+2 in Y)
			SSTACK_JOBSR	FCORE_FIND 		;CFA -> X, status -> D
			TBEQ	D, CF_POSTPONE_UDEFWORD
			;Compile CFA
			STX	-2,Y
			STY	CP
			;Done
			NEXT

CF_POSTPONE_DICTOF	JOB	FCORE_THROW_DICTOF	
CF_POSTPONE_NONAME	JOB	FCORE_THROW_NONAME
CF_POSTPONE_UDEFWORD	JOB	FCORE_THROW_UDEFWORD	
CF_POSTPONE_COMPONLY	JOB	FCORE_THROW_COMPONLY
	
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
;QUIT
;
			ALIGN	1
NFA_QUIT		FHEADER, "QUIT", NFA_POSTPONE, COMPILE
CFA_QUIT		DW	CF_QUIT
CF_QUIT			JOB	FCORE_THROW_QUIT

;QUIT run-time semantics
;
;S12CForth implementation details:
;Throws (and handles):
;"Parameter stack overflow" 
;"Return stack underflow"
;"Return stack overflow"
;"Dictionary overflow"
;"Undefined worrd"
;
			ALIGN	1
CFA_QUIT_RT		DW	CF_QUIT_RT
FCORE_ENTRY		EQU		*
			;Empty RS and go into interpretation state 
CF_QUIT_RT		RS_RESET					;empty the return stack
			LDD	#$0000
			STD	HANDLER					;clear exception handler
			STD	STATE					;enter interpretation state
			MOVW	CP_SAVED, CP				;restore compile pointer
			;Print input prompt
CF_QUIT_RT_1		PRINT_LINE_BREAK	;send input prompt				
			LDX	#FCORE_INTERPRET_PROMPT
			LDD	STATE
			BEQ	CF_QUIT_RT_2
			LDX	#FCORE_COMPILE_PROMPT
CF_QUIT_RT_2		PRINT_STR			
			;Query comand line	
			SSTACK_JOBSR	FCORE_QUERY			;get command line
			TBNE	X, CF_QUIT_COMERR   			;communication error			
			;Parse next word of the command line
CF_QUIT_RT_3		SSTACK_JOBSR	FCORE_NAME			;parse next word (string pointer -> X)
			TBEQ	X, CF_QUIT_RT_5				;last word parsed
			;Look up word in dictionary (string pointer in X)
			SSTACK_JOBSR	FCORE_FIND 			;search dictionary (xt -> X, status -> D)
			TBEQ	D, CF_QUIT_RT_7 			;word not found -> see if it is a number
			DBEQ	D, CF_QUIT_RT_4 			;immediate word -> execute
			INTERPRET_ONLY	CF_QUIT_RT_6 			;check state
			;Execute word (xt in X) 
CF_QUIT_RT_4		MOVW	#CF_QUIT_RT_IP_DONE, IP 		;set next IP
			JMP	[0,X]					;execute CF
CF_QUIT_RT_IP_DONE	DW	CF_QUIT_RT_CFA_DONE			
CF_QUIT_RT_CFA_DONE	DW	CF_QUIT_RT_3

; 			;Return stack underflow 
;CF_QUIT_RSUF		LDY	#CF_QUIT_MSG_RSUF 			;print standard error message
; 			JOB	CF_QUIT_ERROR
; 			;Return stack overflow 
;CF_QUIT_RSOF		LDY	#CF_QUIT_MSG_RSOF 			;print standard error message	
; 			JOB	CF_QUIT_ERROR
; 			;Undefined word (PSP+2 in Y)
CF_QUIT_UDEFWORD	LDY	#CF_QUIT_MSG_UDEFWORD			;print standard error message	
			JOB	CF_QUIT_ERROR
 			;Undefined word (PSP+2 in Y)
CF_QUIT_DICTOF		LDY	#CF_QUIT_MSG_DICTOF			;print standard error message	
			JOB	CF_QUIT_ERROR
 			;Communication problem (PSP+2 in Y, error code in X)
CF_QUIT_COMERR		TFR	X, Y
			CPX	#-((FEXCPT_MSGTAB_END-FEXCPT_MSGTAB_START)/2) 	;check for standard error code
			BLO	CF_QUIT_ERROR					;custom error message
			TFR	X,D
			LDX     #FEXCPT_MSGTAB_END 				;look-up standard error message
			LSLD
			LDY	D,X
			;JOB	CF_QUIT_ERROR
CF_QUIT_ERROR		ERROR_PRINT
			PS_RESET
			JOB	CF_QUIT_RT
	
			;Last word parsed
CF_QUIT_RT_5		INTERPRET_ONLY	CF_QUIT_RT_1 			;don't print "ok" in compile state
			LDX	#FCORE_SYSTEM_PROMPT 			;print "ok"
			PRINT_STR
			JOB	CF_QUIT_RT_1
			;Compile word (xt in X, status in D) 
CF_QUIT_RT_6		TFR	X, Y
			DICT_CHECK_OF	2, CF_QUIT_DICTOF 		;(CP+2 -> X)
			STY     -2,X
			STX	CP
			JOB	CF_QUIT_RT_3 				;parse next word	
			;Word was not found (string pointer in X)
CF_QUIT_RT_7		SSTACK_JOBSR	FCORE_NUMBER 			;convert to number (value -> Y:X, size -> D)
			TBEQ	D, CF_QUIT_UDEFWORD			;undefined word
			DBNE	D, CF_QUIT_RT_9				;double number
			;Single number 
			INTERPRET_ONLY	CF_QUIT_RT_8 			;compile
			;Stack single number 
			PS_PUSH_X	CF_QUIT_PSOF
			JOB	CF_QUIT_RT_3
			;Compile single number (number in X)
CF_QUIT_RT_8		TFR	X, D
			DICT_CHECK_OF	4, CF_QUIT_DICTOF 		;(CP+4 -> X)
			MOVW	#CFA_LITERAL_RT, -4,X 			;add CFA
			STD	 -2,X 					;add number
			STX	CP 					;update CP
			JOB	CF_QUIT_RT_3 				;interpret next word 
			;Double number 
CF_QUIT_RT_9		INTERPRET_ONLY	CF_QUIT_RT_10 			;compile
			;Stack doublelnumber (number in Y:X)
			TFR	Y, D
			PS_CHECK_OF	2, CF_QUIT_PSOF 		;(PSP+4 -> Y)
			STX	2,Y
			STD	0,Y
			STY	PSP
			JOB	CF_QUIT_RT_3
			;Compile double number (number in Y:X)
CF_QUIT_RT_10		TFR	X, D
			DICT_CHECK_OF	6, CF_QUIT_DICTOF 		;(CP+6 -> X)
			MOVW	#CFA_TWO_LITERAL_RT, -6,X 		;add CFA
			STD	-2,X 					;add number
			STY	-4,X 					;add number
			STX	CP 					;update CP
			JOB	CF_QUIT_RT_3 				;interpret next word 
		
			;Error handlers 
 			;Return stack overflow 
CF_QUIT_PSOF		LDY	#CF_QUIT_MSG_PSOF 			;print standard error message	
 			JOB	CF_QUIT_ERROR

CF_QUIT_MSG_PSOF	EQU	FEXCPT_MSG_PSOF
CF_QUIT_MSG_RSUF	EQU	FEXCPT_MSG_RSUF
CF_QUIT_MSG_RSOF	EQU	FEXCPT_MSG_RSOF
CF_QUIT_MSG_UDEFWORD	EQU	FEXCPT_MSG_UDEFWORD
CF_QUIT_MSG_DICTOF	EQU	FEXCPT_MSG_DICTOF
;CF_QUIT_MSG_COMERR	EQU	FEXCPT_MSG_COMERR
	
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
			ALIGN	1
NFA_R_FROM		FHEADER, "R>", NFA_QUIT, COMPILE
CFA_R_FROM		DW	CF_R_FROM
CF_R_FROM		RS_CHECK_UF 	1, CF_R_FROM_RSUF	;check for RS underflow (RSP -> X)
			PS_CHECK_OF	1, CF_R_FROM_PSOF 	;check for PS overflow (PSP-2 -> Y)
			;LDX	RSP
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
;
;S12CForth implementation details:
;Throws:
;"Return stack underflow"
;"Parameter stack overflow"
;
			ALIGN	1
NFA_R_FETCH		FHEADER, "R@", NFA_R_FROM, COMPILE
CFA_R_FETCH		DW	CF_R_FETCH
CF_R_FETCH		RS_CHECK_UF 	1, CF_R_FETCH_RSUF	;check for RS underflow (RSP -> X)
			PS_CHECK_OF	1, CF_R_FETCH_PSOF 	;check for PS overflow (PSP-2 -> Y)
			;LDX	RSP
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
;
;S12CForth implementation details:
;The following parameter stack layout is expected:
;Named compilation:   ( xt -- xt ) 
;:NONAME compilation: ( xt 0 -- xt 0 ) 
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_RECURSE		FHEADER, "RECURSE", NFA_R_FETCH, IMMEDIATE
CFA_RECURSE		DW	CF_RECURSE
CF_RECURSE		COMPILE_ONLY	CF_RECURSE_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_RECURSE_CTRLSTRUC;(PSP -> Y)
			DICT_CHECK_OF	2, CF_RECURSE_DICTOF	;(CP+2 -> X)
			;Check the parameter stack (PSP in Y, CP+2 in X)
			LDD	0,Y
			BNE	CF_RECURSE_1 			;named compilation
			;:NONAME compilation (PSP in Y, CP+2 in X)	
			PS_CHECK_UF	2, CF_RECURSE_CTRLSTRUC;(PSP -> Y)
			LDD	2,Y
			;Named compilation (PSP in Y, CP+2 in X, xt in D)
CF_RECURSE_1		STD	0,X
			STX	CP
			;Done
			NEXT
	
CF_RECURSE_CTRLSTRUC	JOB	FCORE_THROW_CTRLSTRUC
CF_RECURSE_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_RECURSE_DICTOF	JOB	FCORE_THROW_DICTOF

;REPEAT 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest. Resolve the forward reference orig using the
;location following the appended run-time semantics.
;Run-time: ( -- )
;Continue execution at the location given by dest.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_REPEAT		FHEADER, "REPEAT", NFA_RECURSE, IMMEDIATE
CFA_REPEAT		DW	CF_REPEAT
			DW	CFA_REPEAT_RT
CF_REPEAT		;REPEAT compile semantics (run-time CFA in [X+2])
			COMPILE_ONLY	CF_REPEAT_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_REPEAT_PSUF	;(PSP -> Y)
			LDD	2,X	
			DICT_CHECK_OF	4, CF_REPEAT_DICTOF	;(CP+4-> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP in Y)
			STD	-4,X
			MOVW	2,Y+, -2,X
			STX	CP
			;Add address to CFA_WHILE_RT
			LDX	2,Y+
			STY	PSP
			MOVW	CP, 0,X
			;Done 
			NEXT

CF_REPEAT_PSUF		JOB	FCORE_THROW_PSUF
CF_REPEAT_DICTOF	JOB	FCORE_THROW_DICTOF
CF_REPEAT_COMPONLY	JOB	FCORE_THROW_COMPONLY

;REPEAT run-time semantics 
CFA_REPEAT_RT		EQU	CFA_AGAIN_RT 	;same as AGAIN run-time semantics
	
;ROT ( x1 x2 x3 -- x2 x3 x1 )
;Rotate the top three stack entries.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_ROT			FHEADER, "ROT", NFA_REPEAT, COMPILE
CFA_ROT			DW	CF_ROT
CF_ROT			PS_CHECK_UF	2, CF_ROT_PSUF ;check for underflow
			;Rotate
			LDD	4,Y
			MOVW	2,Y, 4,Y
			MOVW	0,Y, 2,Y
			STD	0,Y
			;Done
			NEXT
				
CF_ROT_PSUF		JOB	FCORE_THROW_PSUF
	
;RSHIFT ( x1 u -- x2 )
;Perform a logical right shift of u bit-places on x1, giving x2. Put zeroes into
;the most significant bits vacated by the shift. An ambiguous condition exists
;if u is greater than or equal to the number of bits in a cell.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
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
;
;S12CForth implementation details:
;The string will be terminated
;Throws:
;"Dictionary overflow"
;"Compile-only word"
;"Parsed string overflow"
;
			ALIGN	1
NFA_S_QUOTE		FHEADER, 'S"', NFA_R_SHIFT, IMMEDIATE ;"
CFA_S_QUOTE		DW	CF_S_QUOTE
CF_S_QUOTE		COMPILE_ONLY	CF_S_QUOTE_COMPONLY ;ensure that compile mode is on
			;Parse quote
			LDAA	#$22 				;double quote
			SSTACK_JOBSR	FCORE_PARSE		;string pointer -> X, character count -> A
			TBEQ	X, CF_S_QUOTE_2 		;empty quote		
			;Check remaining space in dictionary (string pointer in X, character count in A)
			IBEQ	A, CF_S_QUOTE_STROF		;add CFA to count
			TAB
			CLRA
			ADDD	#1
			TFR	X, Y
			DICT_CHECK_OF_D	CF_S_QUOTE_DICTOF 	;check for dictionary overflow
			;Append run-time CFA (string pointer in Y)
			LDX	CP
			MOVW	#CFA_S_QUOTE_RT, 2,X+
			;Append quote (CP in X, string pointer in Y)
			CPSTR_Y_TO_X
CF_S_QUOTE_1		STX	CP
			;Done
			NEXT
			;Empty string
CF_S_QUOTE_2		DICT_CHECK_OF	6, CF_S_QUOTE_DICTOF 	;check for dictionary overflow
			MOVW	#CFA_TWO_LITERAL_RT, -6,X 		;add CFA
			MOVW	#$0000, 	-2,X 			;zero pointer
			MOVW	#$0000, 	-2,X 			;zero count
			JOB	CF_S_QUOTE_1
	
CF_S_QUOTE_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_S_QUOTE_DICTOF	JOB	FCORE_THROW_DICTOF
CF_S_QUOTE_STROF	JOB	FCORE_THROW_STROF
CF_S_QUOTE_PSOF		JOB	FCORE_THROW_PSOF

;S" run-time semantics
;S12CForth implementation details:
;Interpretation semantics:
;Print string to the terminal
;Throws:
;"Parameter stack overflow"
			ALIGN	1
CFA_S_QUOTE_RT		DW	CF_S_QUOTE_RT
CF_S_QUOTE_RT		PS_CHECK_OF	2, CF_S_QUOTE_PSOF 	;check for PS overflow (PSP-4 -> Y)
			;Push string pointer onto PS (PSP-4 in Y)
			LDX	IP
			STX	2,Y
			;Count characters (PSP-4 in Y, string pointer in X)
			PRINT_STRCNT
			;Adjust IP (PSP-4 in Y, string pointer in X, char count in A)
			LEAX	A,X
			STX	IP
			;Push character count onto PS (PSP-4 in Y, char count in A)
			EXG	A, D
			STD	0,Y
			STY	PSP
			;Done
			NEXT
	
;S>D ( n -- d )
;Convert the number n to the double-cell number d with the same numerical value.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Parameter stack underflow"
;
			ALIGN	1
NFA_S_TO_D		FHEADER, "S>D", NFA_S_QUOTE, COMPILE
CFA_S_TO_D		DW	CF_S_TO_D	
CF_S_TO_D		PS_CHECK_UFOF	1, CF_S_TO_D_PSUF, 1, CF_S_TO_D_PSOF	;check for under and overflow
			STY	PSP
			MOVW	#$0000, 0,Y 	;positive
			LDD	2,Y
			BPL	CF_S_TO_D_1
			MOVW	#$FFFF, 0,Y 	;negative
			;Done
CF_S_TO_D_1		NEXT	

CF_S_TO_D_PSUF		JOB	FCORE_THROW_PSUF
CF_S_TO_D_PSOF		JOB	FCORE_THROW_PSOF
	
;SIGN ( n -- )
;If n is negative, add a minus sign to the beginning of the pictured numeric
;output string. An ambiguous condition exists if SIGN executes outside of a
;<# #> delimited number conversion.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"PAD buffer overflow"
;
			ALIGN	1
NFA_SIGN		FHEADER, "SIGN", NFA_S_TO_D, COMPILE
CFA_SIGN		DW	CF_SIGN
CF_SIGN			PS_CHECK_UF	1, CF_SIGN_PSUF ;check for underflow	(PSP -> Y)
			PAD_CHECK_OF	CF_SIGN_PADOF	;check for PAD overvlow (HLD -> X)
			;Add sign character to the PAD buffer
			LDD	2,Y+
			BPL	CF_SIGN_1
			MOVB	#"-", 1,-X
			STX	HLD
CF_SIGN_1		STY	PSP
			NEXT


CF_SIGN_PSUF		JOB	FCORE_THROW_PSUF
CF_SIGN_PADOF		JOB	FCORE_THROW_PADOF
	
;SM/REM ( d1 n1 -- n2 n3 )
;Divide d1 by n1, giving the symmetric quotient n3 and the remainder n2. Input
;and output stack arguments are signed. An ambiguous condition exists if n1 is
;zero or if the quotient lies outside the range of a single-cell signed integer.
;Symmetric Division Example:
;Dividend Divisor Remainder Quotient
;   10       7        3         1
;  -10       7       -3        -1
;   10      -7        3        -1
;  -10      -7       -3         1
;
;S12CForth implementation details: 
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;"Quotient out of range"
;
			ALIGN	1
NFA_S_M_SLASH_REM	FHEADER, "SM/REM", NFA_SIGN, COMPILE
CFA_S_M_SLASH_REM	DW	CF_S_M_SLASH_REM
CF_S_M_SLASH_REM	PS_CHECK_UF	2, CF_S_M_SLASH_REM_PSUF ;check for underflow  (PSP -> Y)
			LDX	0,Y			;get divisor
			BEQ	CF_S_M_SLASH_REM_0DIV	;diviide by zero
			LDD	4,Y			;get dividend
			LDY	2,Y
			EDIVS				;Y:D/X=>Y; remainder=>D
			BVS	CF_S_M_SLASH_REM_RESOR 	;result out of range
			LDX	PSP			;PSP -> X
			STY	2,+X			;return quotient
			STD	2,X			;return remainder
			STX	PSP			;update PSP
			;Done 
			NEXT

CF_S_M_SLASH_REM_PSUF	JOB	FCORE_THROW_PSUF
CF_S_M_SLASH_REM_0DIV	JOB	FCORE_THROW_0DIV
CF_S_M_SLASH_REM_RESOR	JOB	FCORE_THROW_RESOR

;SOURCE ( -- c-addr u )
;c-addr is the address of, and u is the number of characters in, the input
;buffer.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_SOURCE		FHEADER, "SOURCE", NFA_S_M_SLASH_REM, COMPILE
CFA_SOURCE		DW	CF_SOURCE
CF_SOURCE		PS_CHECK_OF	1, CF_SOURCE_PSOF	;check for PS overflow (PSP-new cells -> Y)
			;Return TIB start address 
			MOVW	#TIB_START, 2,Y
			;Return character count
			MOVW	NUMBER_TIB, 0,Y
			STY	PSP 				;update PSP
			;Done
			NEXT
	
CF_SOURCE_PSOF		JOB	FCORE_THROW_PSOF
	
;SPACE ( -- )
;Display one space.
			ALIGN	1
NFA_SPACE		FHEADER, "SPACE", NFA_SOURCE, COMPILE
CFA_SPACE		DW	CF_SPACE
CF_SPACE		PRINT_SPC				;print one space
			NEXT

;SPACES ( n -- )
;If n is greater than zero, display n spaces.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_SPACES		FHEADER, "SPACES", NFA_SPACE, COMPILE
CFA_SPACES		DW	CF_SPACES
CF_SPACES		PS_PULL_D	CF_SPACES_PSUF		;pop PS
			TBEQ	D, CF_SPACES_2	
			TBNE	A, CF_SPACES_3
			TBA
			;Print spaces 
CF_SPACES_1		PRINT_SPCS				;print spaces
			;Done
CF_SPACES_2		NEXT
	`		;Saturate
CF_SPACES_3		LDAA	#$FF
			JOB	CF_SPACES_1
	
CF_SPACES_PSUF		JOB	FCORE_THROW_PSUF
	
;STATE ( -- a-addr )
;a-addr is the address of a cell containing the compilation-state flag. STATE is
;true when in compilation state, false otherwise. The true value in STATE is
;non-zero, but is otherwise implementation-defined. Only the following standard
;words alter the value in STATE: : (colon), ; (semicolon), ABORT, QUIT, :NONAME,
;[ (left-bracket), and ] (right-bracket).
;Note: A program shall not directly alter the contents of STATE.
			ALIGN	1
NFA_STATE		FHEADER, "STATE", NFA_SPACES, COMPILE
CFA_STATE		DW	CF_CONSTANT_RT
			DW	STATE

;SWAP ( x1 x2 -- x2 x1 )
;Exchange the top two stack items.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_SWAP		FHEADER, "SWAP", NFA_STATE, COMPILE
CFA_SWAP		DW	CF_SWAP
CF_SWAP			PS_CHECK_UF	2, CF_SWAP_PSUF ;check for underflow (PSP -> Y)
			;Swap
			LDD	0,Y
			MOVW	2,Y, 0,Y
			STD	2,Y
			;Done
			NEXT

CF_SWAP_PSUF		JOB	FCORE_THROW_PSUF

;THEN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: orig -- )
;Append the run-time semantics given below to the current definition. Resolve
;the forward reference orig using the location of the appended run-time
;semantics.
;Run-time: ( -- )
;Continue execution.
;
;S12CForth implementation details:
;Throws:
;"Parameter Stack underflow"
;"Compile-only word"
			ALIGN	1
NFA_THEN		FHEADER, "THEN", NFA_SWAP, IMMEDIATE
CFA_THEN		DW	CF_THEN
CF_THEN			COMPILE_ONLY	CF_THEN_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_THEN_PSUF 	;check for underflow (PSP -> Y)
			;Append current CP to last IF or ELSE
			LDX	2,Y+
			MOVW	CP, 0,X
			STY	PSP
			;Done
			NEXT

CF_THEN_PSUF		JOB	FCORE_THROW_PSUF
CF_THEN_COMPONLY	JOB	FCORE_THROW_COMPONLY

;TYPE ( c-addr u -- )
;If u is greater than zero, display the character string specified by c-addr and
;u.
;When passed a character in a character string whose character-defining bits
;have a value between hex 20 and 7E inclusive, the corresponding standard
;character, specified by 3.1.2.1 graphic characters, is displayed. Because
;different output devices can respond differently to control characters,
;programs that use control characters to perform specific functions have an
;environmental dependency.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_TYPE		FHEADER, "TYPE", NFA_THEN, COMPILE
CFA_TYPE		DW	CF_TYPE
CF_TYPE			PS_CHECK_UF	2, CF_TYPE_PSUF ;check for underflow (PSP -> Y)
			;Pull args from PS
			LEAY	4,Y
			STY	PSP
			LDX	-2,Y			;c-addr -> X
			LDY	-4,Y			;u -> Y
			BEQ	CF_TYPE_3		;done
			;Print string
CF_TYPE_1		LDAB	1,X+
			ANDB	#$7F 			;remove termination
			CMPB	#$20
			BLO	CF_TYPE_2
			CMPB	#$7E
			BHI	CF_TYPE_2
			PRINT_CHAR
CF_TYPE_2		DBNE	Y, CF_TYPE_1
			;Done
CF_TYPE_3		NEXT
	
CF_TYPE_PSUF		JOB	FCORE_THROW_PSUF

;U. ( u -- )
;Display u in free field format.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Invalid BASE"
;
			ALIGN	1
NFA_U_DOT		FHEADER, "U.", NFA_TYPE, COMPILE
CFA_U_DOT		DW	CF_U_DOT
CF_U_DOT		PS_PULL_X	CF_U_DOT_PSUF 		;pull cell from PS
			BASE_CHECK	CF_U_DOT_INVALBASE	;check BASE value
			PRINT_SPC				;print a space character
			PRINT_UINT				;print cell as signed integer
			NEXT

CF_U_DOT_PSUF		JOB	FCORE_THROW_PSUF
CF_U_DOT_INVALBASE	JOB	FCORE_THROW_INVALBASE

;U< ( u1 u2 -- flag )
;flag is true if and only if u1 is less than u2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_U_LESS_THAN		FHEADER, "U<", NFA_U_DOT, COMPILE
CFA_U_LESS_THAN		DW	CF_U_LESS_THAN
CF_U_LESS_THAN		PS_CHECK_UF 2, CF_U_LESS_THAN_PSUF 	;check for underflow  (PSP -> Y)
			LDD	2,Y			;u1 -> D
			MOVW	#$FFFF, 2,Y		;TRUE
			CPD	2,Y+
			BLO	CF_U_LESS_THAN_1
			MOVW	#$0000, 0,Y
CF_U_LESS_THAN_1	STY	PSP
			NEXT
	
CF_U_LESS_THAN_PSUF	JOB	FCORE_THROW_PSUF

;UM* ( u1 u2 -- ud )
;Multiply u1 by u2, giving the unsigned double-cell product ud. All values and
;arithmetic are unsigned.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_U_M_STAR		FHEADER, "UM*", NFA_U_LESS_THAN, COMPILE
CFA_U_M_STAR		DW	CF_U_M_STAR
CF_U_M_STAR		PS_CHECK_UF 2, CF_U_M_STAR_PSUF	;(PSP -> Y)
			TFR	Y, X			;PSP -> X
			LDY	0,X
			LDD	2,X
			EMUL				;Y * D => Y:D
			STD	2,X
			STY	0,X
			;Done 
			NEXT

CF_U_M_STAR_PSUF	JOB	FCORE_THROW_PSUF

;UM/MOD ( ud u1 -- u2 u3 )
;Divide ud by u1, giving the quotient u3 and the remainder u2. All values and
;arithmetic are unsigned. An ambiguous condition exists if u1 is zero or if the
;quotient lies outside the range of a single-cell unsigned integer.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;"Quotient out of range"
;
			ALIGN	1
NFA_U_M_SLASH_MOD	FHEADER, "UM/MOD", NFA_U_M_STAR, COMPILE
CFA_U_M_SLASH_MOD	DW	CF_U_M_SLASH_MOD
CF_U_M_SLASH_MOD	PS_CHECK_UF	3, CF_U_M_SLASH_MOD_PSUF ;check for underflow  (PSP -> Y)
			LDX	0,Y			;get divisor
			BEQ	CF_U_M_SLASH_MOD_0DIV	;diviide by zero
			LDD	4,Y			;get dividend
			LDY	2,Y
			EDIV				;Y:D/X=>Y; remainder=>D
			BVS	CF_U_M_SLASH_MOD_RESOR 	;result out of range
			LDX	PSP			;PSP -> X
			STY	2,+X			;return quotient
			STD	2,X			;return remainder
			STX	PSP			;update PSP
			;Done 
			NEXT

CF_U_M_SLASH_MOD_PSUF	JOB	FCORE_THROW_PSUF
CF_U_M_SLASH_MOD_0DIV	JOB	FCORE_THROW_0DIV
CF_U_M_SLASH_MOD_RESOR	JOB	FCORE_THROW_RESOR

;UNLOOP
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- ) ( R: loop-sys -- )
;Discard the loop-control parameters for the current nesting level. An UNLOOP is
;required for each nesting level before the definition may be EXITed. An
;ambiguous condition exists if the loop-control parameters are unavailable.
;
;S12CForth implementation details:
;loop-sys has the following format: (R: limit index -- ) 
;Throws:
;"Return stack underflow"
;
			ALIGN	1
NFA_UNLOOP		FHEADER, "UNLOOP", NFA_U_M_SLASH_MOD, COMPILE
CFA_UNLOOP		DW	CF_UNLOOP
CF_UNLOOP		RS_CHECK_UF	2, CF_UNLOOP_RSUF	;(RSP -> X)
			;Discard loop-sys
			LEAX	4,X
			STX	RSP
			;Done
			NEXT

CF_UNLOOP_RSUF		JOB	FCORE_THROW_RSUF
	
;UNTIL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( x -- )
;If all bits of x are zero, continue execution at the location specified by
;dest.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_UNTIL		FHEADER, "UNTIL", NFA_UNLOOP, IMMEDIATE
CFA_UNTIL		DW	CF_UNTIL
			DW	CFA_UNTIL_RT

CF_UNTIL		EQU	CF_LITERAL
	
CF_UNTIL_PSUF		JOB	FCORE_THROW_PSUF
CF_UNTIL_DICTOF		JOB	FCORE_THROW_DICTOF
CF_UNTIL_COMPONLY	JOB	FCORE_THROW_COMPONLY

;UNTIL run-time semantics 
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
			ALIGN	1
CFA_UNTIL_RT		DW	CF_UNTIL_RT
CF_UNTIL_RT		PS_PULL_X	CF_UNTIL_PSUF
			CPX	#$0000		;check is cell equals 0
			BEQ	CF_UNTIL_RT_1	;cell is zero 
			SKIP_NEXT		;increment IP and do NEXT
CF_UNTIL_RT_1		JUMP_NEXT
			
;VARIABLE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. Reserve one
;cell of data space at an aligned address.
;name is referred to as a variable.
;name Execution: ( -- a-addr )
;a-addr is the address of the reserved cell. A program is responsible for
;initializing the contents of the reserved cell.
;
;S12CForth implementation details:
;Throws:
;"Missing name argument"
;"Dictionary overflow"
			ALIGN	1
NFA_VARIABLE		FHEADER, "VARIABLE", NFA_UNTIL, COMPILE
CFA_VARIABLE		DW	CF_VARIABLE
CF_VARIABLE		;Build header
			SSTACK_JOBSR	FCORE_HEADER ;NFA -> D, error handler -> X (SSTACK: 10 bytes)
			TBNE	X, CF_VARIABLE_ERROR
			;Update LAST_NFA 
			STD	LAST_NFA
			;Append CFA 
			LDX	CP
			MOVW	#CF_VARIABLE_RT, 2,X+
			;Append variable space (CP in X)
			MOVW	#$0000, 2,X+
			STX	CP
			;Update CP saved (CP in X)
			STX	CP_SAVED
			;Done 
			NEXT
			;Error handler for FCORE_HEADER 
CF_VARIABLE_ERROR	JMP	0,X

CF_VARIABLE_PSOF	JOB	FCORE_THROW_PSOF
	
;VARIABLE run-time semantics
;Push the address of the first cell after the CFA onto the parameter stack
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CF_VARIABLE_RT		PS_CHECK_OF	1, CF_VARIABLE_PSOF	;overflow check	=> 9 cycles
			LEAX		2,X			;CFA+2 -> PS	=> 2 cycles
			STX		0,Y			;		=> 3 cycles
			STY		PSP			;		=> 3 cycles
			NEXT					;NEXT		=>15 cycles
							; 		  ---------
							;		  32 cycles
	
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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack ovderflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_WHILE		FHEADER, "WHILE", NFA_VARIABLE, IMMEDIATE
CFA_WHILE		DW	CF_WHILE
			DW	CFA_WHILE_RT
			;WHILE compile semantics (run-time CFA in [X+2])
CF_WHILE		COMPILE_ONLY	CF_WHILE_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UFOF	1, CF_WHILE_PSUF, 1, CF_WHILE_PSOF ;check for under and overflow (PSP-2 -> Y)	
			LDD	2,X	
			DICT_CHECK_OF	4, CF_WHILE_DICTOF	;(CP+4-> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP-2 in Y)
			STD	 -4,X
			STX	-2,X
			STX	CP
			;Move dest to TOS
			MOVW	2,Y, 0,Y
			LEAX	-2,X
			STX	2,Y
			STY	PSP
			;Done
			NEXT
	
CF_WHILE_PSUF		JOB	FCORE_THROW_PSUF
CF_WHILE_PSOF		JOB	FCORE_THROW_PSOF
CF_WHILE_DICTOF		JOB	FCORE_THROW_DICTOF
CF_WHILE_COMPONLY	JOB	FCORE_THROW_COMPONLY
	
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
			ALIGN	1
NFA_WORD		FHEADER, "WORD", NFA_WHILE, COMPILE
CFA_WORD		DW		CF_WORD
CF_WORD			PS_CHECK_UF	1, CF_WORD_PSUF	;check for underflow
			;Pull argument from PS (PSP in Y)
			LDD	0,Y
			;Parse quote (PSP in Y, char in D)
			TBA
			SSTACK_JOBSR	FCORE_PARSE	;skip to the starting delimiter
			TBA
			SSTACK_JOBSR	FCORE_PARSE	;string pointer -> X
			STX	0,Y	
			;Done
			NEXT

CF_WORD_PSUF		JOB	FCORE_THROW_PSUF
	
;XOR ( x1 x2 -- x3 )
;x3 is the bit-by-bit exclusive-or of x1 with x2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_XOR			FHEADER, "XOR", NFA_WORD, COMPILE
CFA_XOR			DW	CF_XOR
CF_XOR			PS_CHECK_UF 2, CF_XOR_PSUF	;(PSP -> Y)
			;XOR
			LDD	2,Y+ 			;x1 ^ x2 -> D
			EORA	0,Y
			EORB	1,Y
			STD	0,Y 			;return result
			STY	PSP			;update PSP
			;Done
			NEXT
	
CF_XOR_PSUF		JOB	FCORE_THROW_PSUF

;[ 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: Perform the execution semantics given below.
;Execution: ( -- )
;Enter interpretation state. [ is an immediate word.
			ALIGN	1
NFA_LEFT_BRACKET	FHEADER, "[", NFA_XOR, IMMEDIATE
CFA_LEFT_BRACKET	DW	CF_LEFT_BRACKET
CF_LEFT_BRACKET		MOVW	#$0000, STATE
			;Done 
			NEXT

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
;
;S12CForth implementation details:
;Interpretation semantics: see ' (tick)
;Compilation semantics:    see POSTPONE
	
;Throws:
;"Dictionary overflow"
;"Undefined word"

			ALIGN	1
NFA_BRACKET_TICK	FHEADER, "[']", NFA_LEFT_BRACKET, IMMEDIATE
CFA_BRACKET_TICK	DW	CF_BRACKET_TICK
CF_BRACKET_TICK		COMPILE_ONLY	CF_TICK
			JOB		CF_POSTPONE
	
;[CHAR]
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Append the
;run-time semantics given below to the current definition.
;Run-time: ( -- char )
;Place char, the value of the first character of name, on the stack.
;
;S12CForth implementation details:
;Returns "0" in case of a zero length string
;Interpretation semantcs: see CHAR
;Throws:
;"Dictionary overflow"
;
			ALIGN	1
NFA_BRACKET_CHAR	FHEADER, "[CHAR]", NFA_BRACKET_TICK, IMMEDIATE
CFA_BRACKET_CHAR	DW	CF_BRACKET_CHAR
			DW	CFA_LITERAL_RT	
			;[CHAR] compile semantics (run-time CFA in [X+2])
CF_BRACKET_CHAR		COMPILE_ONLY	CF_CHAR
			LDD	2,X
			DICT_CHECK_OF	4, CF_BRACKET_CHAR_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, run-time CFA in D)
			STD	 -4,X
			;Parse word (CP+4 in X)
			TFR	X, Y
			SSTACK_JOBSR	FCORE_WORD 			;string pointer -> X (SSTACK: 4 bytes)
			CLRB
			TBEQ	X, CF_BRACKET_CHAR_1 			;empty string
			;Add char to compilation (string pointer in X, CP+4 in Y)
			LDAB	0,X
CF_BRACKET_CHAR_1	CLRA
			STD	-2,Y
			STY	CP
			;Done
			NEXT
	
CF_BRACKET_CHAR_DICTOF	JOB	FCORE_THROW_DICTOF
	
;] ( -- )
;Enter compilation state.
			ALIGN	1
NFA_RIGHT_BRACKET	FHEADER, "]", NFA_BRACKET_CHAR, IMMEDIATE
CFA_RIGHT_BRACKET	DW	CF_RIGHT_BRACKET
CF_RIGHT_BRACKET	MOVW	#$0001, STATE
			;Done 
			NEXT

;#Core extension words (CORE EXT):
; ================================
	
;#TIB ( -- a-addr )
;a-addr is the address of a cell containing the number of characters in the
;terminal input buffer.
;Note: This word is obsolescent and is included as a concession to existing
;      implementations.
			ALIGN	1
NFA_NUMBER_TIB		FHEADER, "#TIB", NFA_RIGHT_BRACKET, COMPILE
CFA_NUMBER_TIB		DW	CF_CONSTANT_RT
			DW	NUMBER_TIB

;.(
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<paren>" -- )
;Parse and display ccc delimited by ) (right parenthesis). .( is an immediate
;word.
;
;S12CForth implementation details:
;Interpretation semantics:
;Print string to the terminal
;Trows:
;"Dictionary overflow"
;"Parsed string overflow"
;
			ALIGN	1
NFA_DOT_PAREN		FHEADER, ".(", NFA_NUMBER_TIB, IMMEDIATE
CFA_DOT_PAREN		DW	CF_DOT_PAREN
CF_DOT_PAREN		;Parse quote
			LDAA	#")" 				;right parenthesis
			;JOB	CF_DOT_QUOTE_1
			SSTACK_JOBSR	FCORE_PARSE		;string pointer -> X, character count -> A
			TBEQ	X, CF_DOT_PAREN_1
			;Print quote (string pointer in X)
			PRINT_STR	
			;Done
CF_DOT_PAREN_1		NEXT
				
;.R ( n1 n2 -- )
;Display n1 right aligned in a field n2 characters wide. If the number of
;characters required to display n1 is greater than n2, all digits are displayed
;with no leading spaces in a field as wide as necessary.
			ALIGN	1
NFA_DOT_R		FHEADER, ".R", NFA_DOT_PAREN, COMPILE
CFA_DOT_R		DW	CF_DOT_R
CF_DOT_R		PS_CHECK_UF 2, CF_DOT_R_PSUF 	;check for underflow  (PSP -> Y)
			BASE_CHECK	CF_DOT_R_INVALBASE	;check BASE value (BASE -> D)
			;Saturate n at $FF
			TST	2,Y+ 			;n2 -> A
			BNE	CF_DOT_R_2
			LDAA	-1,Y
			;Read u
CF_DOT_R_1		LDX	2,Y+ 			;u -> X
			STY	PSP			;update PSP
			PRINT_RSINT			;print number
			NEXT
			;set n to $FF (saturate) 
CF_DOT_R_2		LDAA	#$FF
			JOB	CF_DOT_R_1

CF_DOT_R_PSUF		JOB	FCORE_THROW_PSUF
CF_DOT_R_INVALBASE	JOB	FCORE_THROW_INVALBASE
	
;0<> ( x -- flag )
;flag is true if and only if x is not equal to zero.
			ALIGN	1
NFA_ZERO_NOT_EQUALS	FHEADER, "0<>", NFA_DOT_R, COMPILE
CFA_ZERO_NOT_EQUALS	DW	CF_ZERO_NOT_EQUALS
CF_ZERO_NOT_EQUALS	PS_CHECK_UF 1, CF_ZERO_NOT_EQUALS_PSUF 	;check for underflow (PSP -> Y)
			LDD	0,Y
			MOVW	#$FFFF, 0,Y		;TRUE
			CPD	#$0000
			BNE	CF_ZERO_NOT_EQUALS_1
			MOVW	#$0000, 0,Y
CF_ZERO_NOT_EQUALS_1	STY	PSP
			NEXT
	
CF_ZERO_NOT_EQUALS_PSUF	JOB	FCORE_THROW_PSUF

;0> ( n -- flag )
;flag is true if and only if n is greater than zero.
			ALIGN	1
NFA_ZERO_GREATER	FHEADER, "0>", NFA_ZERO_NOT_EQUALS, COMPILE
CFA_ZERO_GREATER	DW	CF_ZERO_GREATER
CF_ZERO_GREATER		PS_CHECK_UF 1, CF_ZERO_GREATER_PSUF 	;check for underflow (PSP -> Y)
			LDD	0,Y
			MOVW	#$FFFF, 0,Y		;TRUE
			CPD	#$0000
			BGT	CF_ZERO_GREATER_1
			MOVW	#$0000, 0,Y
CF_ZERO_GREATER_1	STY	PSP
			NEXT
	
CF_ZERO_GREATER_PSUF	JOB	FCORE_THROW_PSUF
	
;2>R
;Interpretation: Interpretation semantics for this word are undefined.
;Execution:      ( x1 x2 -- ) ( R:  -- x1 x2 )
;Transfer cell pair x1 x2 to the return stack. Semantically equivalent to
;SWAP >R >R .
;
;S12CForth implementation details:
;Interpretation semantics: same as execution semantics 
;Throws:
;"Parameter stack underflow"
;"Return stack overflow"
			ALIGN	1
NFA_TWO_TO_R		FHEADER, "2>R", NFA_ZERO_GREATER, COMPILE
CFA_TWO_TO_R		DW	CF_TWO_TO_R
CF_TWO_TO_R		PS_CHECK_UF	2, CF_TWO_TO_PSUF	;(PSP -> Y)
			RS_CHECK_OF	2, CF_TWO_TO_RSOF	;
			;Move stack entries (PSP in Y)
			LDX	RSP
			MOVW	2,Y,  2,-X
			MOVW	4,Y+, 2,-X
			STY	PSP
			STX	RSP
			NEXT

CF_TWO_TO_PSUF		JOB	FCORE_THROW_PSUF
CF_TWO_TO_RSOF		JOB	FCORE_THROW_RSOF
	
;2R>
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x1 x2 ) ( R:  x1 x2 -- )
;Transfer cell pair x1 x2 from the return stack. Semantically equivalent to
;R> R> SWAP .
;
;S12CForth implementation details:
;Interpretation semantics: same as execution semantics 
;Throws:
;"Parameter stack overflow"
;"Return stack underflow"
;
			ALIGN	1
NFA_TWO_FROM_R		FHEADER, "2R>", NFA_TWO_TO_R, COMPILE
CFA_TWO_FROM_R		DW	CF_TWO_FROM_R
CF_TWO_FROM_R		PS_CHECK_OF	2, CF_TWO_FROM_R_PSOF 	;check for PS overflow (PSP-4 -> Y)	
			RS_CHECK_UF	2, CF_TWO_FROM_R_RSUF	;(RSP -> X)
			;Move stack entries
			MOVW	2,X+, 0,Y
			MOVW	2,X+, 2,Y
			STY	PSP
			STX	RSP
			NEXT

CF_TWO_FROM_R_PSOF	JOB	FCORE_THROW_PSOF
CF_TWO_FROM_R_RSUF	JOB	FCORE_THROW_RSUF
	
;2R@
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( -- x1 x2 ) ( R:  x1 x2 -- x1 x2 )
;Copy cell pair x1 x2 from the return stack. Semantically equivalent to
;R> R> 2DUP >R >R SWAP .
;
;S12CForth implementation details:
;Interpretation semantics: same as execution semantics 
;Throws:
;"Parameter stack overflow"
;"Return stack underflow"
;
			ALIGN	1
NFA_TWO_R_FETCH		FHEADER, "2R@", NFA_TWO_FROM_R, COMPILE
CFA_TWO_R_FETCH		DW	CF_TWO_R_FETCH
CF_TWO_R_FETCH		PS_CHECK_OF	2, CF_TWO_R_FETCH_PSOF 	;check for PS overflow (PSP-4 -> Y)	
			RS_CHECK_UF	2, CF_TWO_R_FETCH_RSUF	;(RSP -> X)
			;Move stack entries
			MOVW	2,X+, 2,Y
			MOVW	2,X+, 0,Y
			STY	PSP
			NEXT

CF_TWO_R_FETCH_PSOF	JOB	FCORE_THROW_PSOF
CF_TWO_R_FETCH_RSUF	JOB	FCORE_THROW_RSUF
	
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
;
;S12CForth implementation details:
;colon-sys is the NFA if the new definition. $0000 is used for :NONAME
;definitions. 
;Throws:
;"Parameter stack overflow"
;"Compiler nesting"
;"Dictionary overflow"
;
			ALIGN	1
NFA_COLON_NONAME	FHEADER, ":NONAME", NFA_TWO_R_FETCH, IMMEDIATE
CFA_COLON_NONAME	DW	CF_COLON_NONAME
CF_COLON_NONAME		INTERPRET_ONLY	CF_COLON_NONAME_COMPNEST	;check for nested definition
			PS_CHECK_OF	2, CF_COLON_NONAME_PSOF 	;(PSP-4 -> Y)
			DICT_CHECK_OF	2, CF_COLON_NONAME_DICTOF		;(CP+2 -> X)
			;Push xt and $0000 onto the PS (PSP-4 in Y, CP+2 -> X)
			LDX	CP
			STX	2,Y
			MOVW	#$0000, 0,Y
			STY	PSP
			;Append CFA (CP in X)
			MOVW	#CF_INNER, 2,X+
			STX	CP
			;Enter compile state 
			MOVW	#$0001, STATE
			;Done 
			NEXT

CF_COLON_NONAME_PSOF		JOB	FCORE_THROW_PSOF
CF_COLON_NONAME_COMPNEST	JOB	FCORE_THROW_COMPNEST
CF_COLON_NONAME_DICTOF		JOB	FCORE_THROW_DICTOF
	
;<> ( x1 x2 -- flag )
;flag is true if and only if x1 is not bit-for-bit the same as x2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
CF_NOT_EQUALS_PSUF	JOB	FCORE_THROW_PSUF

			ALIGN	1
NFA_NOT_EQUALS		FHEADER, "<>", NFA_COLON_NONAME, COMPILE
CFA_NOT_EQUALS		DW	CF_NOT_EQUALS
CF_NOT_EQUALS		PS_CHECK_UF 2, CF_NOT_EQUALS_PSUF 	;check for underflow  (PSP -> Y)
			LDD	2,Y			;u1 -> D
			MOVW	#$FFFF, 2,Y		;TRUE
			CPD	2,Y+
			BNE	CF_NOT_EQUALS_1
			MOVW	#$0000, 0,Y
CF_NOT_EQUALS_1		STY	PSP
			NEXT
			
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
;
;S12CForth implementation details:
;do-sys format:     ( orig dest -- )
;loop-sys format: (R: limit index -- ) 
;Throws:
;"Parameter stack overflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_QUESTION_DO		FHEADER, "?DO", NFA_NOT_EQUALS, IMMEDIATE
CFA_QUESTION_DO		DW	CF_QUESTION_DO
			DW	CFA_QUESTION_DO_RT
			;?DO compile semantics (run-time CFA in [X+2])
CF_QUESTION_DO		COMPILE_ONLY	CF_QUESTION_DO_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_OF	2, CF_QUESTION_DO_PSOF		;(PSP-4 -> Y)
			LDD		2,X	
			DICT_CHECK_OF	4, CF_QUESTION_DO_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP-4 in Y)
			STD	-4,X
			MOVW	#$0000, 2,-X
			;Stack do-sys onto PS (CP+2 in X, PSP-4 in Y)
			STX	0,Y
			LEAX	2,X
			STX	2,Y
			STY	PSP
			STX	CP
			;Done
			NEXT

CF_QUESTION_DO_PSOF	JOB	FCORE_THROW_PSOF
CF_QUESTION_DO_PSUF	JOB	FCORE_THROW_PSUF
CF_QUESTION_DO_RSOF	JOB	FCORE_THROW_RSOF
CF_QUESTION_DO_DICTOF	JOB	FCORE_THROW_DICTOF
CF_QUESTION_DO_COMPONLY	JOB	FCORE_THROW_COMPONLY	
	
;?DO run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Return stack undererflow"
			ALIGN	1
CFA_QUESTION_DO_RT	DW	CF_QUESTION_DO_RT
CF_QUESTION_DO_RT	PS_CHECK_UF	2, CF_QUESTION_DO_PSUF	;(PSP -> Y)
			RS_CHECK_OF	2, CF_QUESTION_DO_RSOF	;
			;Compare args on PS
			LDD	2,Y+
			CPD	2,Y+
			BEQ	CF_QUESTION_DO_RT_1
			;Move loop-sys from PS to RS
			STY	PSP
			LDX	RSP	
			MOVW	-4,Y, 4,-X 		;copy index
			MOVW	-2,Y, 2,X 		;copy limit
			STX	RSP
			SKIP_NEXT
			;Done
CF_QUESTION_DO_RT_1	STY	PSP
			JUMP_NEXT

;AGAIN 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: dest -- )
;Append the run-time semantics given below to the current definition, resolving
;the backward reference dest.
;Run-time: ( -- )
;Continue execution at the location specified by dest. If no other control flow
;words are used, any program code after AGAIN will not be executed.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_AGAIN		FHEADER, "AGAIN", NFA_QUESTION_DO, IMMEDIATE
CFA_AGAIN		DW	CF_AGAIN
			DW	CFA_AGAIN_RT
CF_AGAIN		EQU	CF_LITERAL
	
;AGAIN run-time semantics
			ALIGN	1
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
;
;S12CForth implementation details:
;The string will be terminated
;Throws:
;"Dictionary overflow"
;"Compile-only word"
;"Parsed string overflow"
;
			ALIGN	1
NFA_C_QUOTE		FHEADER, 'C"', NFA_AGAIN, IMMEDIATE ;"
CFA_C_QUOTE		DW	CF_C_QUOTE
CF_C_QUOTE		COMPILE_ONLY	CF_C_QUOTE_COMPONLY ;ensure that compile mode is on
			;Parse quote
			LDAA	#$22 				;double quote
			SSTACK_JOBSR	FCORE_PARSE		;string pointer -> X, character count -> A
			TBEQ	X, CF_C_QUOTE_2 		;empty quote		
			;Check remaining space in dictionary (string pointer in X, character count in A)
			IBEQ	A, CF_C_QUOTE_STROF		;add CFA to count
			TAB
			CLRA
			ADDD	#1
			TFR	X, Y
			DICT_CHECK_OF_D	CF_C_QUOTE_DICTOF 	;check for dictionary overflow
			;Append run-time CFA (string pointer in Y)
			LDX	CP
			MOVW	#CFA_C_QUOTE_RT, 2,X+
			;Append quote (CP in X, string pointer in Y)
			CPSTR_Y_TO_X
CF_C_QUOTE_1		STX	CP
			;Done
			NEXT
			;Empty string
CF_C_QUOTE_2		DICT_CHECK_OF	6, CF_C_QUOTE_DICTOF 	;check for dictionary overflow
			MOVW	#CFA_TWO_LITERAL_RT, -6,X 		;add CFA
			MOVW	#$0000, 	-2,X 			;zero pointer
			MOVW	#$0000, 	-2,X 			;zero count
			JOB	CF_C_QUOTE_1
	
CF_C_QUOTE_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_C_QUOTE_DICTOF	JOB	FCORE_THROW_DICTOF
CF_C_QUOTE_STROF	JOB	FCORE_THROW_STROF
CF_C_QUOTE_PSOF		JOB	FCORE_THROW_PSOF

;C" run-time semantics
;S12CForth implementation details:
;Interpretation semantics:
;Print string to the terminal
;Throws:
;"Parameter stack overflow"
			ALIGN	1
CFA_C_QUOTE_RT		DW	CF_C_QUOTE_RT
CF_C_QUOTE_RT		PS_CHECK_OF	1, CF_C_QUOTE_PSOF 	;check for PS overflow (PSP-2 -> Y)
			;Push string pointer onto PS (PSP-2 in Y)
			LDX	IP
			STX	0,Y
			STY	PSP
			;Count characters (PSP-4 in Y, string pointer in X)
			PRINT_STRCNT
			;Adjust IP (PSP-4 in Y, string pointer in X, char count in A)
			LEAX	A,X
			STX	IP
			;Done
			NEXT
	
;CASE
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: -- case-sys )
;Mark the start of the CASE ... OF ... ENDOF ... ENDCASE structure. Append the
;run-time semantics given below to the current definition.
;Run-time: ( -- )
;Continue execution.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Compile-only word"
;
CF_CASE_PSOF		JOB	FCORE_THROW_PSOF	
CF_CASE_COMPONLY	JOB	FCORE_THROW_COMPONLY

			ALIGN	1
NFA_CASE		FHEADER, "CASE", NFA_C_QUOTE, IMMEDIATE
CFA_CASE		DW	CF_CASE
CF_CASE			COMPILE_ONLY	CF_CASE_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_OF	1, CF_CASE_PSOF 	;(PSP-2 -> Y)
			;Push initial case-sys ($0000) onto the PS
			MOVW	#$0000, 0,Y
			STY	PSP
			NEXT

;COMPILE, 
;Interpretation: Interpretation semantics for this word are undefined.
;Execution: ( xt -- )
;Append the execution semantics of the definition represented by xt to the
;execution semantics of the current definition.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
CF_COMPILE_COMMA_PSUF		JOB	FCORE_THROW_PSUF
CF_COMPILE_COMMA_DICTOF		JOB	FCORE_THROW_DICTOF
CF_COMPILE_COMMA_COMPONLY	JOB	FCORE_THROW_COMPONLY
	
			ALIGN	1
NFA_COMPILE_COMMA	FHEADER, "COMPILE,", NFA_CASE, IMMEDIATE
CFA_COMPILE_COMMA	DW	CF_COMPILE_COMMA
CF_COMPILE_COMMA	COMPILE_ONLY	CF_COMPILE_COMMA_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_COMPILE_COMMA_PSUF 	;check for PS underflow   (PSP -> Y)
			DICT_CHECK_OF	2, CF_COMPILE_COMMA_DICTOF	;check for DICT overflow (CP+bytes -> X)
			MOVW	2,Y+, -2,X
			STY	PSP
			STX	CP
			NEXT

;CONVERT ( ud1 c-addr1 -- ud2 c-addr2 ) CHECK!
;ud2 is the result of converting the characters within the text beginning at the
;first character after c-addr1 into digits, using the number in BASE, and adding
;each digit to ud1 after multiplying ud1 by the number in BASE. Conversion
;continues until a character that is not convertible is encountered. c-addr2 is
;the location of the first unconverted character. An ambiguous condition exists
;if ud2 overflows.
;Note: This word is obsolescent and is included as a concession to existing
;implementations. Its function is superseded by >NUMBER.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_CONVERT		FHEADER, "CONVERT", NFA_COMPILE_COMMA, COMPILE
CFA_CONVERT		DW	CF_CONVERT
CF_CONVERT		PS_CHECK_UF	3, CF_CONVERT_PSUF	;(PSP -> Y)
			;Allocate temporary memory (PSP in Y)
			SSTACK_ALLOC	10
			MOVW	BASE,   0,X
			MOVW	0,Y,    2,X
			MOVW	2,Y,    4,X
			MOVW	4,Y,    6,X
			MOVW	#$FFFF, 8,X
			;Convert to number
			SSTACK_JOBSR	FCORE_TO_NUMBER
			;Return results
			LDY	PSP
			MOVW	2,SP,  0,Y
			MOVW	4,SP,  2,Y
			;Deallocate temporary memory
			SSTACK_DEALLOC	10
			;Done
			NEXT

CF_CONVERT_PSUF		JOB	FCORE_THROW_PSUF
	
;ENDCASE
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys -- )
;Mark the end of the CASE ... OF ... ENDOF ... ENDCASE structure. Use case-sys
;to resolve the entire structure. Append the run-time semantics given below to
;the current definition.
;Run-time: ( x -- )
;Discard the case selector x and continue execution.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_ENDCASE		FHEADER, "ENDCASE", NFA_CONVERT, IMMEDIATE
CFA_ENDCASE		DW	CF_ENDCASE
			DW	CFA_ENDCASE_RT
			;ENDCASE compile semantics (run-time CFA in [X+2])
CF_ENDCASE		COMPILE_ONLY	CF_ENDCASE_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	1, CF_ENDCASE_PSUF	;(PSP -> Y)
			LDD	2,X	
			DICT_CHECK_OF	2, CF_ENDCASE_DICTOF	;(CP+2 -> X)
			;Add run-time CFA to compilation (CP+2 in X, PSP in Y, run-time CFA in D)
			STD	-2,X
			STX	CP
			;Read case-sys (PSP in Y)
			LDX	2,Y+ 				;get case-sys
			STY	PSP				;update PSP
			TBEQ	X, CF_ENDCASE_2			;done
			;Loop through all ENDOFs 
CF_ENDCASE_1		LDY	0,X 				;get pointer to next ENDOF
			MOVW	CP, 0,X				;append the correct address
			TFR	Y, X
			TBNE	X, CF_ENDCASE_1	
			;Done 
CF_ENDCASE_2		NEXT
	
CF_ENDCASE_PSUF		JOB	FCORE_THROW_PSUF
CF_ENDCASE_DICTOF	JOB	FCORE_THROW_DICTOF
CF_ENDCASE_COMPONLY	JOB	FCORE_THROW_COMPONLY

CFA_ENDCASE_RT		EQU	CFA_DROP
	
;ENDOF
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: case-sys1 of-sys -- case-sys2 )
;Mark the end of the OF ... ENDOF part of the CASE structure. The next location
;for a transfer of control resolves the reference given by of-sys. Append the
;run-time semantics given below to the current definition. Replace case-sys1
;with case-sys2 on the control-flow stack, to be resolved by ENDCASE.
;Run-time: ( -- )
;Continue execution at the location specified by the consumer of case-sys2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_ENDOF		FHEADER, "ENDOF", NFA_ENDCASE, IMMEDIATE
CFA_ENDOF		DW	CF_ENDOF
			DW	CFA_ENDOF_RT
			;ENDOF compile semantics (run-time CFA in [X+2])
CF_ENDOF		COMPILE_ONLY	CF_ENDOF_COMPONLY 	;ensure that compile mode is on
			PS_CHECK_UF	2, CF_ENDOF_PSUF	;(PSP -> Y)
			LDD	2,X	
			DICT_CHECK_OF	4, CF_ENDOF_DICTOF	;(CP+4 -> X)
			;Add run-time CFA to compilation (CP+4 in X, PSP in Y, run-time CFA in D)
			STD	-4,X
			MOVW	2,Y, 2,-X 	;temporarily put case-sys1 in CFA address
			STX	2,Y		;replace case-sys1 by pointer to CFA address
			LEAX	2,X			
			STX	CP
			;Append current CP to last OF
			LDX	2,Y+
			MOVW	CP, 0,X
			STY	PSP
			;Done
			NEXT

CF_ENDOF_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_ENDOF_DICTOF		JOB	FCORE_THROW_DICTOF
CF_ENDOF_PSUF		JOB	FCORE_THROW_PSUF

CFA_ENDOF_RT		EQU	CFA_AGAIN_RT
	
;ERASE ( addr u -- )
;If u is greater than zero, clear all bits in each of u consecutive address
;units of memory beginning at addr .
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
CF_ERASE_PSUF		JOB	FCORE_THROW_PSUF
	
			ALIGN	1
NFA_ERASE		FHEADER, "ERASE", NFA_ENDOF, COMPILE
CFA_ERASE		DW	CF_ERASE
CF_ERASE		PS_CHECK_UF	2, CF_ERASE_PSUF	;(PSP -> Y)
			;Get args
			LDD	4,Y+
			BEQ	CF_ERASE_2 			;nothing to do
			LDX	-2,Y
			;Erase loop
CF_ERASE_1		CLR	1,X+
			DBNE	D, CF_ERASE_1
			;Done
CF_ERASE_2		STY	PSP
			NEXT
	
;EXPECT ( c-addr +n -- ) CHECK!
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
;
;S12CForth implementation details:
;Input is captured in the TIB and afterwards copied to c-addr.
;Throws:
;"Parameter stack underflow"
;"Invalid numeric argument"	
;"RX buffer overflow"
;
CF_EXPECT_PSUF		JOB	FCORE_THROW_PSUF
CF_EXPECT_INVALNUM	JOB	FCORE_THROW_INVALNUM
CF_EXPECT_COMERR	JMP	0,X

			ALIGN	1
NFA_EXPECT		FHEADER, "EXPECT", NFA_ERASE, COMPILE
CFA_EXPECT		DW	CF_EXPECT
CF_EXPECT		PS_CHECK_UF	2, CF_EXPECT_PSUF	;PSP -> Y
			;Parse command line (PSP in Y)
			LDD	2,Y+
			BMI	CF_EXPECT_INVALNUM 		;+n is negative			
			LDX	0,Y
			SSTACK_JOBSR	FCORE_ACCEPT
			TBNE	X, CF_EXPECT_COMERR
			;Update PSP (new PSP in Y)
			STY	PSP
			;Done
			NEXT
	
;FALSE ( -- false )
;Return a false flag.
			ALIGN	1
NFA_FALSE		FHEADER, "FALSE", NFA_EXPECT, COMPILE
CFA_FALSE		DW	CF_CONSTANT_RT
			DW	$0000
	
;HEX ( -- )
;Set contents of BASE to sixteen.
			ALIGN	1
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
;
;S12CForth implementation details:
;Throws:
;"Missing name argument"
;"Dictionary overflow"
;
			ALIGN	1
NFA_MARKER		FHEADER, "MARKER", NFA_HEX, COMPILE
CFA_MARKER		DW	CF_MARKER
CF_MARKER		;Build header
			SSTACK_JOBSR	FCORE_HEADER	;NFA -> D, error handler -> X (SSTACK: 10  bytes)
			TBNE	X, CF_MARKER_ERROR
			;Update LAST_NFA (NFA in D)
			STD	LAST_NFA
			;Append CFA and data field (NFA in D)
			LDX	CP
			MOVW	#CF_MARKER_RT, 2,X+
			STD	 2,X+ 			;store NFA in data field
			;Update CP saved (CP in X)
			STX	CP
			STX	CP_SAVED
			;Done 
			NEXT
			;Error handler for FCORE_HEADER 
CF_MARKER_ERROR		JMP	0,X

;MARKER run-time semantics
;Restore old last NFA an CP
;
;S12CForth implementation details:
;
			ALIGN	1
CFA_MARKER_RT		DW	CF_MARKER_RT	
CF_MARKER_RT		;Restore last NFA
			LDX		2,X 			;NFA -> X
			MOVW		0,X, LAST_NFA		;Restore last NFA
			;Restore CP 
			STX		CP
			STX		CP_SAVED
			;Done
			NEXT
	
			
;NIP ( x1 x2 -- x2 )
;Drop the first item below the top of stack.
CF_NIP_PSUF		JOB	FCORE_THROW_PSUF	

			ALIGN	1
NFA_NIP			FHEADER, "NIP", NFA_MARKER, COMPILE
CFA_NIP			DW	CF_NIP
CF_NIP			PS_CHECK_UF 2, CF_NIP_PSUF 	;check for underflow  (PSP -> Y)
			;NIP 
			LDD	2,Y+
			STD	0,Y
			STY	PSP
			;Done 
			NEXT

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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_OF			FHEADER, "OF", NFA_NIP, IMMEDIATE
CFA_OF			DW	CF_OF
			DW	CFA_OF_RT
CF_OF			EQU	CF_IF		
	
CF_OF_PSUF	JOB	FCORE_THROW_PSUF
CF_OF_PSOF	JOB	FCORE_THROW_PSOF
CF_OF_COMPONLY	JOB	FCORE_THROW_COMPONLY
CF_OF_DICTOF	JOB	FCORE_THROW_DICTOF
	
;OF run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
CFA_OF_RT		DW	CF_OF_RT
CF_OF_RT		PS_CHECK_UF	2, CF_OF_PSUF ;check for underflow (PSP -> Y)
			;Check stacked values 
			LDD	2,Y+
			CPD	0,Y
			BEQ	CF_OF_RT_1 		;values are equal
			;Values are not equal
			STY	PSP 			;update PSP
			JUMP_NEXT			;go to the next ckeck
			;Values are equal
CF_OF_RT_1		LEAY	2,Y			;update PSP
			STY	PSP
			SKIP_NEXT 			;execute conditional code
	
;PAD ( -- c-addr )
;c-addr is the address of a transient region that can be used to hold data for
;intermediate processing.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
CF_PAD_PSOF		JOB	FCORE_THROW_PSOF
	
			ALIGN	1
NFA_PAD			FHEADER, "PAD", NFA_OF, COMPILE
CFA_PAD			DW	CF_PAD
CF_PAD			PS_CHECK_OF	1, CF_PAD_PSOF	;overflow check	(PSP-2 -> Y)
			;Allocate PAD if it is deallocated or empty
			LDD	PAD
			CPD	HLD
			BNE	CF_PAD_1 		;PAD already allocated
			PAD_ALLOC
CF_PAD_1		STD	0,Y
			STY	PSP
			;Done 
			NEXT

;PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char.
;c-addr is the address (within the input buffer) and u is the length of the
;parsed string. If the parse area was empty, the resulting string has a zero
;length.
;
;S12CForth implementation details:
;The resulting  string is implemented as terminated string (bit 7 of
;of the last character is set). A resulting string of zero length will return
;the address $0000.
;Throws:
;"Parameter stack underflow"
CF_PARSE_PSUF		JOB	FCORE_THROW_PSUF
CF_PARSE_PSOF		JOB	FCORE_THROW_PSOF

			ALIGN	1
NFA_PARSE		FHEADER, "PARSE", NFA_PAD, COMPILE
CFA_PARSE		DW	CF_PARSE
CF_PARSE		PS_CHECK_UFOF	1, CF_PARSE_PSUF, 1, CF_PARSE_PSOF	;check for under and overflow
			;Pull argument from PS (PSP-2 in Y)
			LDD	2,Y
			;Parse quote (PSP-2 in Y, char in D)
			TBA
			SSTACK_JOBSR	FCORE_PARSE	;string pointer -> X, character count -> A
			STX	2,Y
			;TAB
			;CLRA
			EXG	A,D
			STD	0,Y
			STY	PSP
			;Done
			NEXT

;PICK ( xu ... x1 x0 u -- xu ... x1 x0 xu )
;Remove u. Copy the xu to the top of the stack. An ambiguous condition exists if
;there are less than u+2 items on the stack before PICK is executed.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
CF_PICK_PSUF		JOB	FCORE_THROW_PSUF

			ALIGN	1
NFA_PICK		FHEADER, "PICK", NFA_PARSE, COMPILE
CFA_PICK		DW	CF_PICK
CF_PICK			PS_CHECK_UF 1, CF_PICK_PSUF 	;check for underflow  (PSP -> Y)
			;Check if u+1 items are on the PS (PSP in Y)
			TFR	Y, D
			ADDD	0,Y
			ADDD	0,Y
			CPD	#PS_EMPTY-4
			BHI	CF_PICK_PSUF
			;Move xu to TOS (PSP in Y)
			LDD	0,Y			;u -> D
			TFR	Y, X 			;PSP+2*u -> X
			LEAX	D,X
			LEAX	D,X
			MOVW	2,X, 0,Y 		;xu -> TOS
			;Done 
			NEXT

;QUERY ( -- )
;Make the user input device the input source. Receive input into the terminal
;input buffer, replacing any previous contents. Make the result, whose address
;is returned by TIB, the input buffer. Set >IN to zero.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
;
;S12CForth implementation details:
;Throws:
;"Invalid numeric argument"	
;"RX buffer overflow"
;
			ALIGN	1
NFA_QUERY		FHEADER, "QUERY", NFA_PICK, COMPILE
CFA_QUERY		DW	CF_QUERY
CF_QUERY		;Query command line
			SSTACK_JOBSR	FCORE_QUERY 	;(SSTACK: 18 bytes)
			TBNE	X, CF_QUERY_COMERR	;communication error
			;Done 
			NEXT

CF_QUERY_COMERR		JMP	0,X
	
;REFILL ( -- flag )
;Attempt to fill the input buffer from the input source, returning a true flag;if successful.
;When the input source is the user input device, attempt to receive input into
;the terminal input buffer. If successful, make the result the input buffer, set
;>IN to zero, and return true. Receipt of a line containing no characters is
;considered successful. If there is no input available from the current input
;source, return false.
;When the input source is a string from EVALUATE, return false and perform no
;other action.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Invalid numeric argument"	
;"RX buffer overflow"
;
CF_REFILL_PSOF		JOB	FCORE_THROW_PSOF
CF_REFILL_COMERR	JMP	0,X

NFA_REFILL		FHEADER, "REFILL", NFA_QUERY, COMPILE
CFA_REFILL		DW	CF_REFILL
CF_REFILL		PS_CHECK_OF	1, CF_REFILL_PSOF 	;check for PS overflow (PSP-2 -> Y)
			;Query command line
			SSTACK_JOBSR	FCORE_QUERY   		;(SSTACK: 18 bytes)
			TBNE	X, CF_QUERY_COMERR   		;communication error
			;Push return status 
			MOVW	#-1, 0,Y
			STY	PSP
			;Done 
			NEXT
			
;RESTORE-INPUT ( xn ... x1 n -- flag )
;Attempt to restore the input source specification to the state described by x1
;through xn. flag is true if the input source specification cannot be so
;restored.
;An ambiguous condition exists if the input source represented by the arguments
;is not the same as the current input source.
NFA_RESTORE_INPUT	EQU	NFA_REFILL

;ROLL ( xu xu-1 ... x0 u -- xu-1 ... x0 xu )
;Remove u. Rotate u+1 items on the top of the stack. An ambiguous condition
;exists if there are less than u+2 items on the stack before ROLL is executed.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
CF_ROLL_PSUF		JOB	FCORE_THROW_PSUF
	
			ALIGN	1
NFA_ROLL		FHEADER, "ROLL", NFA_RESTORE_INPUT, COMPILE
CFA_ROLL		DW	CF_ROLL
CF_ROLL			PS_CHECK_UF 1, CF_ROLL_PSUF 	;check for underflow  (PSP -> Y)
			;Check if u+1 items are on the PS (PSP in Y)
			TFR	Y, D
			ADDD	0,Y
			ADDD	0,Y
			CPD	#PS_EMPTY-4
			BHI	CF_ROLL_PSUF
			;Move xu to TOS (PSP in Y)
			LDD	0,Y			;u -> D
			BEQ	CF_ROLL_3
			TFR	Y, X 			;PSP+2*u -> X
			LEAX	D,X
			LEAX	D,X
			MOVW	2,X, 0,Y 		;xu -> TOS
			;Shift stack items (u in D, PSP+2*u in X)
			LEAY	2,X			;PSP+2*u+2 -> Y
			ADDD	#1			;u+1 -> D
CF_ROLL_1		MOVW	2,X-, 2,Y- 
			DBNE	D, CF_ROLL_1
			STY	PSP 			;update PSP
CF_ROLL_2		NEXT
			;Nothing to do (PSP in Y)
CF_ROLL_3		LEAY	2,Y			;Remove TOS
			STY	PSP
			JOB	CF_ROLL_2
	
;SAVE-INPUT ( -- xn ... x1 n )
;x1 through xn describe the current state of the input source specification for
;later use by RESTORE-INPUT.
NFA_SAVE_INPUT		EQU	NFA_ROLL

;SOURCE-ID ( -- 0 | -1 )
;Identifies the input source as follows:
;SOURCE-ID       Input source
;-1              String (via EVALUATE)
; 0              User input device
NFA_SOURCE_ID		EQU	NFA_SAVE_INPUT

;SPAN ( -- a-addr )
;a-addr is the address of a cell containing the count of characters stored by
;the last execution of EXPECT.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
			ALIGN	1
NFA_SPAN		FHEADER, "SPAN", NFA_SOURCE_ID, COMPILE
CFA_SPAN		DW	CF_CONSTANT_RT
			DW	TO_IN

;TIB ( -- c-addr )
;c-addr is the address of the terminal input buffer.
;Note: This word is obsolescent and is included as a concession to existing
;implementations.
			ALIGN	1
NFA_TIB			FHEADER, "TIB", NFA_SPAN, COMPILE
CFA_TIB			DW	CF_CONSTANT_RT
			DW	TIB_START

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
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Missing name argument"
;"Undefined word"
;"invalid usage of non-CREATEd definition"
;
CF_TO_PSUF 		JOB	FCORE_THROW_PSUF
CF_TO_NONAME		JOB	FCORE_THROW_NONAME
CF_TO_UDEFWORD		JOB	FCORE_THROW_UDEFWORD
CF_TO_NONCREATE		JOB	FCORE_THROW_NONCREATE

			ALIGN	1
NFA_TO			FHEADER, "TO", NFA_TIB, COMPILE
CFA_TO			DW	CF_TO
CF_TO			PS_CHECK_UF	1, CF_TO_PSUF ;check for underflow
			;Parse name (PSP in Y)
			SSTACK_JOBSR	FCORE_NAME 		;(SSTACK: 5 bytes)
			TBEQ	X, CF_TO_NONAME
			;Lookup name in dictionary (PSP in Y, string pointer in X)
			SSTACK_JOBSR	FCORE_FIND 		;(SSTACK: 4 bytes)
			TBEQ	D, CF_TO_UDEFWORD ;check for underflow
			;Locate body (PSP in Y, CFA in X)
			SSTACK_JOBSR	FCORE_TO_BODY		 ;(SSTACK: 4 bytes)
			TBEQ	X, CF_TO_NONCREATE
			;Store data in body (PSP in Y, pointer to body in X)
			MOVW	2,Y+, 0,X
			STY	PSP
			;Done
			NEXT

;TRUE ( -- true )
;Return a true flag, a single-cell value with all bits set.
			ALIGN	1
NFA_TRUE		FHEADER, "TRUE", NFA_TO, COMPILE
CFA_TRUE		DW	CF_CONSTANT_RT
			DW	$FFFF

;TUCK ( x1 x2 -- x2 x1 x2 )
;Copy the first (top) stack item below the second stack item.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
CF_TUCK_PSUF		JOB	FCORE_THROW_PSUF
CF_TUCK_PSOF		JOB	FCORE_THROW_PSOF
	
			ALIGN	1
NFA_TUCK		FHEADER, "TUCK", NFA_TRUE, COMPILE
CFA_TUCK		DW	CF_TUCK
CF_TUCK			PS_CHECK_UFOF	2, CF_TUCK_PSUF, 1, CF_TUCK_PSOF ;(PSP-new cells -> Y)
			;Tuck 
			LDD	2,Y 		;x2 -> D
			MOVW	4,Y, 2,Y	;tuck
			STD	4,Y
			STD	0,Y
			STY	PSP 		;update PSP
			NEXT

;U.R ( u n -- )
;Display u right aligned in a field n characters wide. If the number of
;characters required to display u is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Invalid BASE value"
;
CF_U_DOT_R_PSUF		JOB	FCORE_THROW_PSUF
CF_U_DOT_R_INVALBASE	JOB	FCORE_THROW_INVALBASE
	
			ALIGN	1
NFA_U_DOT_R		FHEADER, "U.R", NFA_TUCK, COMPILE
CFA_U_DOT_R		DW	CF_U_DOT_R
CF_U_DOT_R		PS_CHECK_UF 2, CF_U_DOT_R_PSUF 	;check for underflow  (PSP -> Y)
			BASE_CHECK	CF_U_DOT_R_INVALBASE	;check BASE value (BASE -> D)
			;Saturate n at $FF
			TST	2,Y+ 			;n -> A
			BNE	CF_U_DOT_R_2
			LDAA	-1,Y
			;Read u
CF_U_DOT_R_1		LDX	2,Y+ 			;u -> X
			STY	PSP			;update PSP
			PRINT_RUINT			;print number
			NEXT
			;set n to $FF (saturate) 
CF_U_DOT_R_2		LDAA	#$FF
			JOB	CF_U_DOT_R_1

;U> 
;u-greater-than CORE EXT 
;	( u1 u2 -- flag )
;flag is true if and only if u1 is greater than u2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
CF_U_GREATER_THAN_PSUF	JOB	FCORE_THROW_PSUF

			ALIGN	1
NFA_U_GREATER_THAN	FHEADER, "U>", NFA_U_DOT_R, COMPILE
CFA_U_GREATER_THAN	DW	CF_U_GREATER_THAN
CF_U_GREATER_THAN	PS_CHECK_UF 2, CF_U_GREATER_THAN_PSUF 	;check for underflow  (PSP -> Y)
			LDD	2,Y			;u1 -> D
			MOVW	#$FFFF, 2,Y		;TRUE
			CPD	2,Y+
			BHI	CF_U_GREATER_THAN_1
			MOVW	#$0000, 0,Y
CF_U_GREATER_THAN_1	STY	PSP
			NEXT
	
;UNUSED ( -- u )
;u is the amount of space remaining in the region addressed by HERE, in address
;units.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
CF_UNUSED_PSOF	JOB	FCORE_THROW_PSOF

			ALIGN	1
NFA_UNUSED		FHEADER, "UNUSED", NFA_U_GREATER_THAN, COMPILE
CFA_UNUSED		DW	CF_UNUSED
CF_UNUSED		PS_CHECK_OF	1, CF_UNUSED_PSOF	;overflow check	(PSP-new cells -> Y)
			TFR	Y, D				;UNUSED = PSP-CP
			SUBD	CP
			STD	0,Y
			STY	PSP
			NEXT
			
;VALUE ( x "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below, with an initial
;value equal to x.
;name is referred to as a value.
;name Execution: ( -- x )
;Place x on the stack. The value of x is that given when name was created, until
;the phrase x TO name is executed, causing a new value of x to be associated
;with name.
;
;S12CForth implementation details:
;Same semantics as CONSTANT
;
CF_WITHIN_PSUF		JOB	FCORE_THROW_PSUF		


			ALIGN	1
NFA_VALUE		FHEADER, "VALUE", NFA_UNUSED, COMPILE
CFA_VALUE		DW	CF_CONSTANT

;WITHIN ( n1|u1 n2|u2 n3|u3 -- flag )
;Perform a comparison of a test value n1|u1 with a lower limit n2|u2 and an
;upper limit n3|u3, returning true if either
;(n2|u2 < n3|u3 and (n2|u2 <= n1|u1 and n1|u1 < n3|u3)) or
;(n2|u2 > n3|u3 and (n2|u2 <= n1|u1 or n1|u1 < n3|u3)) is true, returning false
;otherwise. An ambiguous condition exists if n1|u1, n2|u2, and n3|u3 are not all
;the same type.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_WITHIN		FHEADER, "WITHIN", NFA_VALUE, COMPILE
CFA_WITHIN		DW	CF_WITHIN
CF_WITHIN		PS_CHECK_UF	3, CF_WITHIN_PSUF ;check for underflow  (PSP -> Y)
			;Pull boundaries from PS
			LDX	2,Y+ 			;u3 -> X
			LDD	2,Y+			;u2 -> D
			STY	PSP
			;Compare boundaries (PSP in Y, u2 in D, u3 in X)
			CPD	-4,Y
			BHI	CF_WITHIN_3 		;u2 > u3
			;u2 <= u3 (PSP in Y, upper boundary in D, lower boundary in X)
			CPD	0,Y
			BHI	CF_WITHIN_4 		;fail
			CPX	0,Y
			BLS	CF_WITHIN_4 		;fail
			;Pass (PSP in Y)
CF_WITHIN_1		LDD	#$FFFF
CF_WITHIN_2		STD	 0,Y
			;Done 
			NEXT
			;u2 > u3 (PSP in Y, upper boundary in D, lower boundary in X)
CF_WITHIN_3		CPD	0,Y
			BLS	CF_WITHIN_1 		;pass
			CPX	0,Y
			BHI	CF_WITHIN_1 		;pass
			;Fail (PSP in Y) 
CF_WITHIN_4		CLRA
			CLRB
			JOB	CF_WITHIN_2

;[COMPILE] 
;Intrepretation: Interpretation semantics for this word are undefined.
;Compilation: ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Find name. If
;name has other than default compilation semantics, append them to the current
;definition; otherwise append the execution semantics of name. An ambiguous
;condition exists if name is not found.
;
;S12CForth implementation details:
;Same semantics as POSTPONE
			
			ALIGN	1
NFA_BRACKET_COMPILE	FHEADER, "[COMPILE]", NFA_WITHIN, IMMEDIATE
CFA_BRACKET_COMPILE	DW	CF_POSTPONE

;\ 
;backslash CORE EXT 
;Compilation: Perform the execution semantics given below.
;Execution: ( "ccc<eol>"-- )
;Parse and discard the remainder of the parse area. \ is an immediate word.
			ALIGN	1
NFA_BACKSLASH		FHEADER, "\", NFA_BRACKET_COMPILE, IMMEDIATE ;"
CFA_BACKSLASH		DW	CF_BACKSLASH
CF_BACKSLASH		MOVW	NUMBER_TIB, TO_IN ;set >IN do the last character 
			NEXT

;#Non-standard S12CForth extensions:
; ==================================

;0 ( -- 0 )
;Constant 0
			ALIGN	1
NFA_ZERO		FHEADER, "0", NFA_BACKSLASH, COMPILE
CFA_ZERO		DW	CF_CONSTANT_RT
			DW	0

;1 ( -- 1 )
;Constant 1
			ALIGN	1
NFA_ONE			FHEADER, "1", NFA_ZERO, COMPILE
CFA_ONE			DW	CF_CONSTANT_RT
			DW	1
	
;2 ( -- 2 )
;Constant 2
			ALIGN	1
NFA_TWO			FHEADER, "2", NFA_ONE, COMPILE
CFA_TWO			DW	CF_CONSTANT_RT
			DW	2
	
;3 ( -- 3 )
;Constant 3
			ALIGN	1
NFA_THREE		FHEADER, "3", NFA_TWO, COMPILE
CFA_THREE		DW	CF_CONSTANT_RT
			DW	3

;4 ( -- 4 )
;Constant 4
			ALIGN	1
NFA_FOUR		FHEADER, "4", NFA_THREE, COMPILE
CFA_FOUR		DW	CF_CONSTANT_RT
			DW	4

;5 ( -- 5 )
;Constant 5
			ALIGN	1
NFA_FIVE		FHEADER, "5", NFA_FOUR, COMPILE
CFA_FIVE		DW	CF_CONSTANT_RT
			DW	5

;6 ( -- 6 )
;Constant 6
			ALIGN	1
NFA_SIX			FHEADER, "6", NFA_FIVE, COMPILE
CFA_SIX			DW	CF_CONSTANT_RT
			DW	6

;7 ( -- 7 )
;Constant 7
			ALIGN	1
NFA_SEVEN		FHEADER, "7", NFA_SIX, COMPILE
CFA_SEVEN		DW	CF_CONSTANT_RT
			DW	7

;8 ( -- 8 )
;Constant 8
			ALIGN	1
NFA_EIGHT		FHEADER, "8", NFA_SEVEN, COMPILE
CFA_EIGHT		DW	CF_CONSTANT_RT
			DW	8

;BINARY ( -- )
;Set the numeric conversion radix to two (binary).
			ALIGN	1
NFA_BINARY			FHEADER, "BINARY", NFA_EIGHT, COMPILE
CFA_BINARY			DW	CF_BINARY
CF_BINARY			MOVW	#2, BASE
			NEXT
	
;CP ( -- addr)
;Compile pointer (points to the next free byte after the user dictionary)
			ALIGN	1
NFA_CP			FHEADER, "CP", NFA_BINARY, COMPILE
CFA_CP			DW	CF_CONSTANT_RT
			DW	CP

;EMPTY ( -- )
;Delete all user defined words
			ALIGN	1
NFA_EMPTY		FHEADER, "EMPTY", NFA_CP, COMPILE
CFA_EMPTY		DW	CF_EMPTY
CF_EMPTY		;Clear dictionary
			MOVW	#FCORE_LAST_NFA, LAST_NFA 	;set last NFA
			LDD	#DICT_START			;set compile pointer
			STD	CP
			STD	CP_SAVED
			;Reset PS
			PS_RESET
			;Done		
			NEXT

;NAME ("<spaces>ccc<space>" -- c-addr )
;Parse whitespace separated word: 
;Skip leading whitespaces (" ", TAB, and non-printables). Parse characters ccc
;delimited by a whitespace (" ", TAB, or non-printable character). c-addr is
;the address of a terminated upper-case string. A resulting string of zero
; length will return the address $0000.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
CF_NAME_PSOF		JOB	FCORE_THROW_PSOF

			ALIGN	1
NFA_NAME		FHEADER, "NAME", NFA_EMPTY, COMPILE
CFA_NAME		DW	CF_NAME
CF_NAME			PS_CHECK_OF	1, CF_NAME_PSOF ;(PSP-2 -> Y)
			;Parse name (new PSP in Y)
			SSTACK_JOBSR	FCORE_NAME 	;string pointer -> X (SSTACK: 6 bytes)
			;Stack result (new PSP in Y, string pointer in X)
			STX	 0,Y
			STY	PSP
			NEXT
	

;NUMBER ( c-addr -- c-addr 0 | u 1 | n 1 | ud 2 | d 2 )
;Convert terminated the string at c-addr into a number. The value of BASE is the
;radix for the conversion. 	
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;"Invalid BASE value"
;
CF_NUMBER_PSUF		JOB	FCORE_THROW_PSUF
CF_NUMBER_PSOF		JOB	FCORE_THROW_PSOF
CF_NUMBER_INVALBASE	JOB	FCORE_THROW_INVALBASE

			ALIGN	1
NFA_NUMBER		FHEADER, "NUMBER", NFA_NAME, COMPILE
CFA_NUMBER		DW	CF_NUMBER
			;Check BASE value 
CF_NUMBER		BASE_CHECK	CF_NUMBER_INVALBASE	;check BASE value (BASE -> D)
			;Check minimum stack requirements 
			PS_CHECK_UFOF	1, CF_NUMBER_PSUF, 1, CF_NUMBER_PSOF ;check for under and overflow (PSP-2 -> Y)
			;Convert string
			LDX	2,Y	
			SSTACK_JOBSR	FCORE_NUMBER ;value -> Y:X, size -> D (SSTACK: 12 bytes)
			;Check result
			CPD	#$0001
			BLO	CF_NUMBER_3
			BHI	CF_NUMBER_2
			;Single number
			LDY	PSP
			STX	2,Y-
			STD	0,Y
CF_NUMBER_1		STY	PSP
			NEXT
			;Double number
CF_NUMBER_2		TFR	Y,D
			LDY	PSP
			STX	2,Y-
			STD	2,Y-
			MOVW	#$0002, 0,Y
			JOB	CF_NUMBER_1
			;Not a number
CF_NUMBER_3		LDY	PSP
			STD	2,-Y
			JOB	CF_NUMBER_1

FCORE_WORDS_END		EQU	*
FCORE_LAST_NFA		EQU	NFA_NUMBER
