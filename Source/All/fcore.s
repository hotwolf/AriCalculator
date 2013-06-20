;###############################################################################
;# S12CForth - FCORE - ANS Forth Core                                          #
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
;#    This module implements the S12CForth core inner interpreter              #
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

;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Valid number base
FCORE_BASE_MIN		EQU	NUM_BASE_MIN		;2
FCORE_BASE_MAX		EQU	NUM_BASE_MAX		;16
FCORE_BASE_DEFAULT	EQU	NUM_BASE_DEFAULT	;10
FCORE_SYMTAB		EQU	NUM_SYMTAB
	
;IRQ flags
IRQ_BREAK		EQU	$80
IRQ_SUSPEND		EQU	$40
IRQ_STEP_IN		EQU	$20
IRQ_STEP_OVER		EQU	$10
IRQ_QUEUE		EQU	$08
	
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



IRQ			DS





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

;Inner interpreter:
;==================
;#NEXT:	jump to the next instruction
; args:	  IP:   pointer to next instruction
;	  ATTN: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	NEXT, 0	
			JOB	NEXT			;run next instruction	=> 3 cycles	 3 bytes
#emac
	
;#SKIP_NEXT: skip next instruction and jump to one after
; args:	  IP:   pointer to next instruction
;	  ATTN: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	SKIP_NEXT, 0	
			JOB	SKIP_NEXT		;run next instruction	=> 3 cycles	 3 bytes
#emac

;#JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:	  IP:   pointer to next instruction
;	  ATTN: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	JUMP_NEXT, 0	
			JOB	JUMP_NEXT		;run next instruction	=> 3 cycles	 3 bytes
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

;Inner interpreter:
;==================
;#NEXT:	jump to the next instruction
; args:	  IP:   pointer to next instruction
;	  ATTN: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
NEXT			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			TST	IRQ			;check for IRQs	        => 3 cycles	 3 bytes
			BNE	IRQ_HANDLER		;execute IRQs	      	=> 1 cycle	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         19 cycles	19 bytes

;#SKIP_NEXT: skip next instruction and jump to one after
; args:	  IP:   pointer to next instruction
;	  ATTN: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
SKIP_NEXT		LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			TST	IRQ			;check for IRQs	        => 3 cycles	 3 bytes
			BMI	IRQ_HANDLER		;execute IRQs	      	=> 1 cycle	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;		  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         21 cycles	21 bytes

;#JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:	  IP:   pointer to next instruction
;	  ATTN: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
JUMP_NEXT		LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
			LDD	IRQ_QUEUE		;check for IRQs	        => 3 cycles	 3 bytes
			BMI	IRQ_HANDLER		;execute IRQs	      	=> 1 cycle	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         22 cycles	20 bytes











	
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
FCORE_NVCOMPILE_PROMPT	FCS	"NV+ "
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

