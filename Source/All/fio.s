#ifndef FIO
#define FIO
;###############################################################################
;# S12CForth - FIO - Basic I/O Handler for the S12CForth Framework             #
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
;#    GNU General Public Licens for more details.                              #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#    This module is a software layer between the Forth I/O words and the I/O  #
;#    hardware drivers. It can be replaced/customiced to support other I/O     #
;#    channels than the default SCI.                                           #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 3, 2011                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FINNER - Forth inner interpreter                                         #
;#    FPS    - Forth parameter stack                                           #
;#    FEXCPT - Forth exceptions                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Busy/idle signaling
;------------------- 
;Signal activity -> define macros FORTH_SIGNAL_BUSY and FORTH_SIGNAL_IDLE
;#mac FORTH_SIGNAL_BUSY, 0
;	...code to signal activity (inside CF)
;#emac
;#mac FORTH_SIGNAL_IDLE, 0			;X, Y, and D are preserved 
;	...code to signal inactivity (inside CF)
;#emac

//STRING_UPPER is required
STRING_ENABLE_UPPER	EQU	1
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#ASCII code 
FIO_SYM_SPACE		EQU	STRING_SYM_SPACE

;#Line break
FIO_STR_NL		EQU	STRING_STR_NL
FIO_NL_BYTE_COUNT	EQU	STRING_NL_BYTE_COUNT

;#String termination 
FIO_TERM		EQU	STRING_TERM
	
;ASCII C0 codes 
FIO_SYM_LF  		EQU	STRING_SYM_LF
FIO_SYM_CR  		EQU	STRING_SYM_CR
FIO_SYM_BACKSPACE  	EQU	STRING_SYM_BACKSPACE
FIO_SYM_DEL  		EQU	STRING_SYM_DEL
FIO_SYM_TAB  		EQU	STRING_SYM_TAB
FIO_SYM_BEEP  		EQU	STRING_SYM_BEEP
FIO_SYM_SPACE  		EQU	STRING_SYM_SPACE
	
;#Empty string 
FIO_EMPTY_STRING	EQU	STRING_TERM
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FIO_VARS_START_LIN
			ORG 	FIO_VARS_START, FIO_VARS_START_LIN
#else
			ORG 	FIO_VARS_START
FIO_VARS_START_LIN	EQU	@
#endif

FIO_VARS_END		EQU	*
FIO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;===============
#macro	FIO_INIT, 0
#emac

;#Abort action (to be executed in addition of QUIT action)
#macro	FIO_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of SUSPEND action)
#macro	FIO_QUIT, 0
#emac
	
;#Suspend action
#macro	FIO_SUSPEND, 0
#emac
	
;#Low level I/O functions	
;========================
;#Receive one byte - non-blocking
; args:   none
; result: A:      error flags 
;         B:      received data 
;         C-flag: set if successful
; SSTACK: 4 bytes
;         X and Y are preserved 
#macro	FIO_RX_NB, 0
			SCI_RX_NB
#emac


;#Check if there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and B are preserved 
#macro	FIO_RX_READY_NB, 0
			SCI_RX_READY_NB,
#emac

;#Transmit one byte - non-blocking
; args:   B:      data to be send
; result: C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and D are preserved 
#macro	FIO_TX_NB, 0
			SCI_TX_NB
#emac
	
;#Check if TX queue can hold further data
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
#macro	FIO_TX_READY_NB, 0
			SCI_TX_READY_NB
#emac

;#Transmit one byte - blocking
; args:   B: data to be send
; SSTACK: 7 bytes
;         X, Y, and D are preserved 
#macro	FIO_TX_BL, 0
			SCI_TX_BL
#emac

;#Print MSB terminated string - non-blocking
; args:   X:      start of the string
; result: X;      remaining string (points to the byte after the string, if successful)
;         C-flag: set if successful	
; SSTACK: 8 bytes
;         Y and D are preserved
#macro	FIO_PRINT_NB, 0
			STRING_PRINT_NB
#emac	

;#Print MSB terminated string - blocking
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
#macro	FIO_PRINT_BL, 0
			STRING_PRINT_BL
#emac	

;#Print a byte in hexadecimal format  - blocking
; args:   B:   number
; result: none	
; SSTACK: 13 bytes
;         All registers are preserved
#macro	FIO_PRINT_HEX_BYTE_BL, 0	
			SSTACK_JOBSR	FIO_PRINT_HEX_BYTE_BL, 13
#emac	
	
;#Print a word in hexadecimal format  - blocking
; args:   D:   number
; result: none	
; SSTACK: 15 bytes
;         All registers are preserved
#macro	FIO_PRINT_HEX_WORD_BL, 0
			SSTACK_JOBSR	FIO_PRINT_HEX_WORD_BL, 15
#emac	

;#Print signed single cell integer
; args:   D:    unsigned single value
;         BASE: base
; result: none
; SSTACK: 26 bytes
;         All registers are preserved
#macro	FIO_PRINT_SSINGLE_BL, 0
			SSTACK_JOBSR	FIO_PRINT_SSINGLE_BL, 26	
#emac	

;#Print signed double cell integer
; args:   Y:X:  unsigned double value
;         BASE: base
; result: none
; SSTACK: 26 bytes
;         All registers are preserved
#macro	FIO_PRINT_SDOUBLE_BL, 0
			SSTACK_JOBSR	FIO_PRINT_SDOUBLE_BL, 26	
#emac	
	
;#Basic string Macros	
;====================
;#Skip string and count characters
; args:   X: start of the string
;         D: initial character count
; result: X: one char past the end of the string
;         D: incremented count     
; SSTACK: none
;        Y is preserved 
#macro	FIO_SKIP_AND_COUNT, 0
			STRING_SKIP_AND_COUNT
#emac

;#Terminated line break
#macro	FIO_NL_TERM, 0
			STRING_NL_TERM
#emac
#macro	FIO_MOVE_NL_TERM, 1
			STRING_MOVE_NL_TERM (\1)
#emac

;#Non-terminated line break
#macro	FIO_NL_NONTERM, 0
			STRING_NL_NONTERM
#emac
#macro	FIO_MOVE_NL_NONTERM, 1
			STRING_MOVE_NL_NONTERM (\1)
#emac
	
;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character 
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
#macro	FIO_UPPER, 0
			STRING_UPPER 
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FIO_CODE_START_LIN
			ORG 	FIO_CODE_START, FIO_CODE_START_LIN
#else
			ORG 	FIO_CODE_START
FIO_CODE_START_LIN	EQU	@
#endif

;Basic IO fiuctions:
;===================
;#Print a word in hexadecimal format  - blocking
; args:   D:   number
; result: none	
; SSTACK: 15 bytes
;         All registers are preserved
FIO_PRINT_HEX_WORD_BL	EQU	*	
			;Print first byte (number in D)
			EXG	A, B
			FIO_PRINT_HEX_BYTE_BL
			;Print second byte (swapped number in D)
			EXG	A, B
			FIO_PRINT_HEX_BYTE_BL
			;Done
			SSTACK_PREPULL	2 					;check subroutine stack
			RTS
	
;#Print a byte in hexadecimal format  - blocking
; args:   B:   number
; result: none	
; SSTACK: 13 bytes
;         All registers are preserved
FIO_PRINT_HEX_BYTE_BL	EQU	*	
			;Save registers (number in B)
			PSHX							;save X	
			PSHD							;save error code
			;Print first digit (number in B)
			LDX	#FIO_SYMTAB 					;start of symbol table -> X
			TBA							;save second digit in A
			LSRB							;extract first digit
			LSRB							;
			LSRB 							;
			LSRB	     						;
			LDAB	B,X 						;look up symbol
			SCI_TX_BL 						;print third digit (SSTACK: 7 bytes)		
			;Print second digit (number in A, symbol table in X)
			ANDA	#$0F 						;extract second digit
			LDAB	A,X 						;look up symbol
			SCI_TX_BL 						;print fourth digit (SSTACK: 7 bytes)
			;Done
			SSTACK_PREPULL	6 					;check subroutine stack
			PULD							;restore D	
			PULX							;restore X	
			RTS

;#Print signed single cell integer
; args:   D:    unsigned single value
;         BASE: base
; result: none
; SSTACK: 26 bytes
;         All registers are preserved
FIO_PRINT_SSINGLE_BL	EQU	*
			;Save registers (integer in D)
			PSHX							;save X	
			PSHY							;save Y	
			PSHD							;save D
			;Sign extend integer (integer in D)
			TFR	D, X 						;D -> X
			SEX	A, D 						;A -> D
			TFR	A, B 						;sign of D -> D
			TFR	D, Y 						;D - Y>
			;Sign extend integer (integer in Y:X)
			JOB	FIO_PRINT_SDOUBLE_BL_1 				;print integer
	
;#Print signed double cell integer
; args:   Y:X:  unsigned double value
;         BASE: base
; result: none
; SSTACK: 26 bytes
;         All registers are preserved
FIO_PRINT_SDOUBLE_BL	EQU	*
			;Save registers (integer in Y:X)
			PSHX							;save X	
			PSHY							;save Y	
			PSHD							;save D
			;Check sign (integer in Y:X)
FIO_PRINT_SDOUBLE_BL_1	CPY	#$0000 						;check if number is negative
			BPL	FIO_PRINT_SDOUBLE_BL_2 				;number is positive
			;Print sign (integer in Y:X)
			LDAB	#"-" 						;sign chharacter
			FIO_TX_BL 						;print sign (SSTACK: 7 bytes)
			;Negate integer (integer in Y:X)
			NUM_NEGATE 						;-(Y:X) -> Y:X
			;Get BASE (integer in Y:X)
FIO_PRINT_SDOUBLE_BL_2	FOUTER_FIX_BASE						;BASE -> B
			;Print integer (integer in Y:X, base in B)
			NUM_REVERSE 						;calculate reverse number (SSTACK: 18 bytes)
			NUM_REVPRINT_BL						;print reverse number (SSTACK: 8 bytes +6 arg bytes)
			NUM_CLEAN_REVERSE					;clean-up reverse number
			;Done 
			SSTACK_PREPULL	8 					;check subroutine stack
			PULD							;restore D	
			PULY							;restore Y	
			PULX							;restore X	
			RTS

;Helper functions for non-blocking numeric printing:
;===================================================
;#Print a word in hexadecimal format  - blocking
; args:   Y
; result: none	
; SSTACK: 15 bytes
;         All registers are preserved
FIO_PRINT_HEX_WORD_BL	EQU	*	




	
;Code fields:	
;============
;EKEY ( -- u )
; Receive one keyboard event u.  The encoding of keyboard events is implementation defined. 
; args:   none
; result: PSP+0: RX data
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_COMERR
CF_EKEY			EQU	*
			;Try to receive data 
CF_EKEY_1		SEI				;disable interrupts
			SCI_RX_NB			;try to read from SCI (SSTACK: 4 bytes)
			BCC	CF_EKEY_2		;no data available
			CLI				;enable interrupts
			;Check for RX errors (flags in A, data in B)
			BITA	#(SCI_FLG_SWOR|OR|NF|FE|PE)
			BNE	CF_EKEY_4 		;RX error
			;Push data onto the parameter stack  (flags in A, data in B)
			CLRA
			PS_PUSH_D
			;Done
			NEXT
			;Wait for any system event
CF_EKEY_2		FINNER_WAIT			;idle	
			JOB	CF_EKEY_1
			;RX error
CF_EKEY_4		FEXCPT_THROW	FEXCPT_EC_COMERR

;EKEY? ( -- flag ) Check for data
; args:   none
; result: PSP+0: flag (true if data is available)
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
CF_EKEY_QUESTION	EQU	*
			;Check if read data is available
			CLRB				;initialize B
			FIO_RX_READY_NB			;check RX queue (SSTACK: 4 bytes)
			SBCB	#$00			;set or clear all bits in B
			TBA				;B -> A
			;Push the result onto the PS
			PS_PUSH_D
			;Done
			NEXT
	
;SPACE ( -- ) Print a space character
; args:   none
; result: none
; SSTACK: 5 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
CF_SPACE		EQU	*
			;Push space character onto PS 
			PS_PUSH	#FIO_SYM_SPACE
			;Print char 
			;JOB	CF_EMIT

;EMIT ( x -- ) Transmit a byte character
; args:   PSP+0: RX data
; result: none
; SSTACK: 5 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
CF_EMIT			EQU	*
			;Read data from PS
CF_EMIT_1		PS_COPY_D 			;copy TX data from PS
			;Try to transmit data (data in D)
CF_EMIT_2		SEI				;disable interrupts
			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
			BCC	CF_EMIT_4		;TX queue is full
			CLI				;enable interrupts
			;Remove parameter from stack
CF_EMIT_3		PS_DROP 1
			;Done
			NEXT
			;Wait for any system event
CF_EMIT_4		FINNER_WAIT			;idle	
			JOB	CF_EMIT_1

;.SIGN ( n -- ) Print "-" if n is negative.
; args:   PSP+0: number
; result: none
; SSTACK: 8 bytes
; PS:     0 cells
; RS:     2 cell
; throws: FEXCPT_EC_PSUF
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Return stack overflow"
CF_DOT_SIGN		EQU	*
			;Check PS
			PS_CHECK_UF 1 			;PSP -> Y
			;Check sign count (PSP in Y)
			BRCLR	0,Y, #$80, CF_DOT_SIGN_1;positive
			;Print minus (PSP in Y)
			MOVW	#"-", 0,Y 		;push minus char onto PS	
			JOB	CF_DOT_SIGN_2		;print minus char
			;Positive
CF_DOT_SIGN_1		EQU	CF_EMIT_3 		;clean up
			;Negative 	
CF_DOT_SIGN_2		EQU	CF_EMIT_1 		;print minus char
	
;EMIT? ( -- flag ) Check if data can be sent over the SCI
; args:   none
; result: PSP+0: flag (true if data is available)
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
CF_EMIT_QUESTION	EQU	*
			;Check if read data is available
			CLRB				;initialize B
			FIO_TX_READY_NB			;check RX queue (SSTACK: 4 bytes)
			SBCB	#$00			;set or clear all bits in B
			TBA				;B -> A
			;Push the result onto the PS
			PS_PUSH_D
			;Done
			NEXT

;SPACES ( n -- ) If n is greater than zero, display n spaces.
; args:   PSP+0: number of spaces to print
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cell
; throws: FEXCPT_EC_PSUF
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Return stack overflow"
CF_SPACES		EQU	*
			;Check PS
CF_SPACES_1		PS_CHECK_UF 1 			;PSP -> Y
			;Check space count (PSP in Y)
			LDX	0,Y	   		;get space count
			BLE	CF_SPACES_2 		;done
			DEX				;decrement space count
			STX	0,Y	   		;update space count
			;Print space
			EXEC_CF	CF_SPACE 		;print space
			JOB	CF_SPACES_1
			;Clean-up
CF_SPACES_2		PS_DROP	1 			;drop argument
			NEXT

;CR ( -- ) Cause subsequent output to appear at the beginning of the next line.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
CF_CR			EQU	*
			;Push string pointer onto PS
			PS_PUSH	#FIO_STR_NL
			;Print string 
			;JOB	CF_STRING_DOT
	
;$. ( c-addr -- ) Print a MSB terminated string
; args:   PS+0: address of a terminated string
; result: none
; SSTACK: 8 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_STRING_DOT		EQU	*
			;Try to print part of the string
CF_STRING_DOT_1		PS_COPY_X
			;Print string (string in X, PSP in Y)
CF_STRING_DOT_2		SEI				;disable interrupts
			FIO_PRINT_NB			;try to write to SCI (SSTACK: 8 bytes)
			BCC	CF_STRING_DOT_3		;string incomplete
			CLI				;enable interrupts
			;Remove parameter from stack
			PS_DROP, 1
			;Done
			NEXT
			;Update string pointer (string in X, PSP in Y)
CF_STRING_DOT_3		STX	0,Y
			;Wait for any system event
			FINNER_WAIT			;idle	
			JOB	CF_STRING_DOT_1		;check NEXT pointer again

;REVERSE. ( reverse -- ) Prints a three cell reverse number
; args:   PSP+0: reverse number (high word)
;         PSP+2: reverse number (middle word)
;         PSP+4: reverse number (low word)
; result: none
; SSTACK: 18 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_REVERSE_DOT		EQU	CF_REVERSE_DOT_2 
			;Store intermediate result (PSP in Y)
CF_REVERSE_DOT_1	MOVW	0,Y, 2,SP+
			MOVW	2,Y, 2,SP+
			MOVW	4,Y, 2,SP+
			;Wait for any system event
			FINNER_WAIT			;idle	
			;Check PS
CF_REVERSE_DOT_2	PS_CHECK_UF 3 			;PSP -> Y
			;Copy reverse number to the sunroutine stack (PSP in Y)
			SSTACK_PREPUSH	6 		;check subroutine stack
			MOVW	4,Y, 2,-SP
			MOVW	2,Y, 2,-SP
			MOVW	0,Y, 2,-SP
			;Try to print reverse number (PSP in Y)
			FOUTER_FIX_BASE			;BASE -> B
			SEI				;disable interrupts
			NUM_REVPRINT_NB			;print as many chars as possible
			BCC	CF_REVERSE_DOT_1	;not finished
			;Clean up (PSP in Y)
			LEAS	6,SP 			;clean up subroutine stack
			LEAY	6,Y			;clean up PS
			STY	PSP			;update PSP
			NEXT

;. ( n -- ) Print signed number
; args:   PSP+0: reverse number structure
; result: none
; SSTACK: 18 ytes
; PS:     4 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_DOT		EQU	* 
			;Check PS
			PS_CHECK_UFOF	2, 3 		;require thee additional cell
			;Set parameters (new PSP in Y)
			MOVW	#$0000, 4,Y 		;set min.space
			MOVW	#$0000, 6,Y 		;set MSW
			JOB	 CF_D_DOT_R_1
	
;.R ( n1 n2 -- ) Print right aligned signed number
; args:   PSP+0: alignment space
;         PSP+1: signed number
; result: none
; SSTACK: 18 ytes
; PS:     3 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_DOT_R		EQU	* 
			;Check PS
			PS_CHECK_UFOF	2, 3 		;require thee additional cells
			;Set parameters (new PSP in Y)
			MOVW	6,Y, 4,Y 		;set min.space
			MOVW	#$0000, 6,Y 		;set MSW
			JOB	 CF_D_DOT_R_1

;. ( n -- ) Print signed number
; args:   PSP+0: reverse number structure
; result: none
; SSTACK: 18 ytes
; PS:     4 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_DOT		EQU	* 
			;Check PS
			PS_CHECK_UFOF	2, 3 		;require thee additional cell
			;Set parameters (new PSP in Y)
			MOVW	#$0000, 4,Y 		;set min.space
			MOVW	#$0000, 6,Y 		;set MSW
			JOB	 CF_D_DOT_R_1
	
;.R ( n1 n2 -- ) Print right aligned signed number
; args:   PSP+0: alignment space
;         PSP+1: signed number
; result: none
; SSTACK: 18 ytes
; PS:     3 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_DOT_R		EQU	* 
			;Check PS
			PS_CHECK_UFOF	2, 3 		;require thee additional cells
			;Set parameters (new PSP in Y)
			MOVW	6,Y, 4,Y 		;set min.space
			;. ( n -- ) Print signed number
; args:   PSP+0: reverse number structure
; result: none
; SSTACK: 18 ytes
; PS:     4 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_DOT		EQU	* 
			;Check PS
			PS_CHECK_UFOF	2, 3 		;require thee additional cell
			;Set parameters (new PSP in Y)
			MOVW	#$0000, 4,Y 		;set min.space
			MOVW	#$0000, 6,Y 		;set MSW
			JOB	 CF_D_DOT_R_1
	
;.R ( n1 n2 -- ) Print right aligned signed number
; args:   PSP+0: alignment space
;         PSP+1: signed number
; result: none
; SSTACK: 18 ytes
; PS:     3 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_DOT_R		EQU	* 
			;Check PS
			PS_CHECK_UFOF	2, 3 		;require thee additional cells
			;Set parameters (new PSP in Y)
			MOVW	6,Y, 4,Y 		;set min.space
			MOVW	#$0000, 6,Y 		;set MSW
			JOB	 CF_D_DOT_R_1
			LDAA	8,Y 			;sign extend LSW		
			CLRB
				
			LSLA				;MSB of LSW -> C-flag
			SBCB	#0
			SEX	
	
			LDD	8,Y			;LSW -> D
			ANDA	#$80
			CLRB
			LSLD
			
	
			MOVW	#$0000, 6,Y 		;set MSW
			JOB	 CF_D_DOT_R_1

;D. ( d  -- ) Print right aligned double number
; args:   PSP+0: alignment space
;         PSP+1: signed double number
; result: none
; SSTACK: 18 bytes
; PS:     3 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_D_DOT		EQU	* 
			;Check PS
			PS_CHECK_UFOF	2, 3 		;require thee additional cells
			;Set parameters (new PSP in Y)
			MOVW	#0000, 4,Y 		;set min.space
			JOB	 CF_D_DOT_R_1
	
;D.R ( d n -- ) Print right aligned double number
; args:   PSP+0: alignment space
;         PSP+1: signed double number
; result: none
; SSTACK: 18 ytes
; PS:     2 cells
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_D_DOT_R		EQU	* 
;			                    PS layout:	  
;			                    +----------------+
;                                           |  Left margin   | PSP+0
;                                           +----------------+
;                       PS input:           |      Sign      | PSP+2
;                       +----------------+  +----------------+
;                       |   Min. space   |  |                | PSP+4
;                       +----------------+  +                +
;                       |     Signed     |  | Reverse number | PSP+6
;                       + double number  +  +                +
;                       |                |  |                | PSP+8
;                       +----------------+  +----------------+
			;Check PS
			PS_CHECK_UFOF	3, 2 		;require two additional cells
CF_D_DOT_R_1 		STY	PSP			;update PSP
			;Check min space (new PSP in Y)			
			LDD	4,Y 			;min. space -> D
			BPL	CF_D_DOT_R_2		;min. space > 0
			CLRA				;saturate min. space
			CLRB				; at zero
			;Check if number is negative (PSP in Y, min. space in D)			
CF_D_DOT_R_2		LDX	6,Y 			;MSW -> X
			STX	2,Y			;set sign
			BPL	CF_D_DOT_R_4		;positive number
			;Decrement min. space (PSP in Y, MSW in X, min. space in D)
			SUBD	#1 			;consider minus sign
			BPL	CF_D_DOT_R_3		;min. space > 0
			CLRA				;saturate min. space
			CLRB				; at zero
CF_D_DOT_R_3		STD	0,Y			;set left margin
			;Negate number (PSP in Y, MSW in X))
			TFR	X, D			;MSW -> D
			COMA				;calculate 1's
			COMB				; complement of MSW
			TFR	D, X			;MSW -> X
			LDD	8,Y			;LSW -> D
			COMA				;calculate 1's				
			COMB				; complement of LSW
			ADDD	#1			;calculate 2's complement
			EXG	D, X			;MSW -> D, LSW -> X			
			ADCD	#0			;calculate 2's complement
			TFR	D, Y			;MSW -> Y
			JOB	CF_D_DOT_R_5		;calculate reverse number
			;Positive number (PSP in Y, MSW in X, min. space in D)
CF_D_DOT_R_4		STD	0,Y			;set left margin
			LDY	8,Y			;LSW -> Y
			EXG	X, Y			;MSW -> Y, LSW -> X
			;Calculate reverse number (number in Y:X)
CF_D_DOT_R_5		FOUTER_FIX_BASE			;BASE -> B
			NUM_REVERSE			;calculate reverse number
			LDY	PSP			;PSP -> Y
			MOVW	2,SP+,4,Y		;copy reverse
			MOVW	2,SP+,6,Y		; number
			MOVW	2,SP+,8,Y		; onto PS 
			CLRB				;A -> D
			TAB				;
			SUBD	0,Y			;calculate left margin
			BPL	CF_D_DOT_R_6		;no margin required
			;Print left margin (PSP in Y, negated left margin in D)
			COMA				;calculate 1's
			COMB				; complement
			ADDD	#1			;calculate 2's complement
			STD	0,Y			;update left margin
			EXEC_CF	CF_SPACES		;print left margin
			JOB	CF_D_DOT_R_7		;print sign
			;No margin required (PSP in Y)
CF_D_DOT_R_6		LEAY	2,Y 			;drop margin count
			STY	PSP			;update PST
			;Print sign (PSP in Y)			
CF_D_DOT_R_7		EXEC_CF	CF_SIGN_DOT 		;print sign
			;Print reverse number			
			EXEC_CF	CF_REVERSE_DOT 		;print sign
			NEXT				;done
	
FIO_CODE_END		EQU	*
FIO_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FIO_TABS_START_LIN
			ORG 	FIO_TABS_START, FIO_TABS_START_LIN
#else
			ORG 	FIO_TABS_START
FIO_TABS_START_LIN	EQU	@
#endif	

;Symbol table
FIO_SYMTAB		EQU	NUM_SYMTAB
	
;Line break
FIO_STR_NL		EQU	STRING_STR_NL
	
;Cell prefix
;FIO_CELL_PREFIX		FCS	"$"
FIO_CELL_PREFIX		FCS	"0x"
	
FIO_TABS_END		EQU	*
FIO_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FIO_WORDS_START_LIN
			ORG 	FIO_WORDS_START, FIO_WORDS_START_LIN
#else
			ORG 	FIO_WORDS_START
FIO_WORDS_START_LIN	EQU	@
#endif	
			ALIGN	1, $FF
;#ANSForth Words:
;================
;Word: EKEY ( u --  )
;Receive one keyboard event u.  The encoding of keyboard events is implementation
;defined.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
;"Invalid RX data"
CFA_EKEY		DW	CF_EKEY

;Word: EKEY? ( -- flag )
;If a keyboard event is available, return true. Otherwise return false. The
;event shall be returned by the next execution of EKEY. After EKEY? returns with
;a value of true, subsequent executions of EKEY? prior to the execution of KEY,
;KEY? or EKEY also return true, referring to the same event.	
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CFA_EKEY_QUESTION	DW	CF_EKEY_QUESTION

;Word: EMIT ( x -- )
;If x is a graphic character in the implementation-defined character set,
;display x. The effect of EMIT for all other values of x is
;implementation-defined.
;When passed a character whose character-defining bits have a value between hex
;20 and 7E inclusive, the corresponding standard character is displayed. Because
;different output devices can respond differently to control characters, programs
;that use control characters to perform specific functions have an environmental
;dependency. Each EMIT deals with only one character.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Return stack overflow"
CFA_EMIT		DW	CF_EMIT

;Word: EMIT? ( -- flag )
;flag is true if the user output device is ready to accept data and the execution
;of EMIT in place of EMIT? would not have suffered an indefinite delay. If the
;device status is indeterminate, flag is true.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
CFA_EMIT_QUESTION	DW	CF_EMIT_QUESTION

;Word: SPACE ( -- )
;Print a space character
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
CFA_SPACE		DW	CF_SPACE

;Word: SPACES ( n -- )
;If n is greater than zero, display n spaces.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Return stack overflow"
CFA_SPACES		DW	CF_SPACES

;Word: CR ( -- )
;Cause subsequent output to appear at the beginning of the next line.
;
;Throws:
;"Parameter stack overflow"
CFA_CR			DW	CF_CR
	
;S12CForth Words:
;================
	
;Word: $. ( c-addr -- )
;Print a terminated string
;
;Throws:
;"Parameter stack overflow"
CFA_STRING_DOT		DW	CF_STRING_DOT
	
FIO_WORDS_END		EQU	*
FIO_WORDS_END_LIN	EQU	@
#endif


;;move to CORE
;	
;Code fields:
;============	
;;U. ( u -- ) Print unsigned number
;; args:   PSP+0: reverse number structure
;; result: none
;; SSTACK: 18 bytes
;; PS:     2 cells
;; RS:     1 cell
;; throws: FEXCPT_EC_PSUF
;CF_U_DOT		EQU	*			
;			;Check PS
;			PS_CHECK_UFOF	1, 1 		;new PSP -> Y
;			;Convert to double number (new PSP in Y)
;			STY 	PSP
;			MOVW	#$0000, 0,Y
;			;Print unsigned number (PSP in Y) 
;			JOB	CF_D_DOT_R_7
;
;;HEX. ( u -- ) Print unsigned number
;; args:   PSP+0: reverse number structure
;; result: none
;; SSTACK: 5 bytes
;; PS:     1 cell
;; RS:     1 cell
;; throws: FEXCPT_EC_PSUF
;CF_HEX_DOT		EQU	*			
;			;Check PS
;			PS_CHECK_UFOF	1, 1 		;new PSP -> Y
;			;Push initial nibble count onto (new PSP in Y)
;			STY	PSP
;			MOVB	#4, 1,Y
;			;Look up digit symbol (PSP in Y)
;CF_HEX_DOT_1		LDAA	2,Y 			;MSB -> A
;			LSRA				;calculate table offset
;			LSRA
;			LSRA
;			LSRA
;			LDX	#FIO_SYMTAB 		;look up digit symbol
;			LDAB	A,X
;			;Print  digit (digit symbol in B, PSP in Y)
;			SEI				;disable interrupts
;			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
;			BCC	CF_HEX_DOT_2		;TX queue is full
;			CLI				;enable interrupts
;			;Switch to next digit (PSP in Y)
;			LDD	2,Y
;			LSLD
;			LSLD
;			LSLD
;			LSLD
;			STD	2,Y
;			DEC	1,Y
;			BNE	CF_HEX_DOT_1		;more digits to ptint
;			;Remove parameter2 from stack
;			PS_DROP, 2
;			;Done
;			NEXT
;			;Check for change of NEXT_PTR (PSP in Y)
;CF_HEX_DOT_2		LDX	NEXT_PTR		;check for default NEXT pointer
;			CPX	#NEXT
;			BEQ	CF_HEX_DOT_3	 	;still default next pointer
;			CLI				;enable interrupts
;			;Execute NOP
;			EXEC_CF	CF_NOP
;			PS_CHECK_UF	2 		;PSP -> Y
;			JOB    	CF_HEX_DOT_1
;			;Wait for any internal system event
;CF_HEX_DOT_3		EQU	*
;#ifmac FORTH_SIGNAL_IDLE
;			FORTH_SIGNAL_IDLE		;signal inactivity
;#endif
;			ISTACK_WAIT			;wait for next interrupt
;#ifmac FORTH_SIGNAL_BUSY
;			FORTH_SIGNAL_BUSY		;signal activity
;#endif
;			JOB	CF_HEX_DOT_1		;check NEXT_PTR again
;	
;;SPACES ( n -- ) Transmit n space characters
;; args:   PSP+0: number of space characters
;; result: none
;; SSTACK: 5 bytes
;; PS:     none
;; RS:     1 cell
;; throws: FEXCPT_EC_PSUF
;CF_SPACES		EQU	*
;			;Try to transmit space characters
;CF_SPACES_1		PS_COPY_X 			;space count from PS
;			BLE	CF_SPACES_3		;n < 1
;			;Try to transmit space character (char count in X)
;			LDAB	#FIO_SYM_SPACE 			;space char -> B
;CF_SPACES_2		SEI				;disable interrupts
;			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
;			BCC	CF_SPACES_4		;TX queue is full
;			CLI				;enable interrupts
;			;Decrement char count (char count in X, space char in B) 
;			DBNE	X, CF_SPACES_2
;			;Remove parameter from stack
;CF_SPACES_3		PS_DROP, 1
;			;Done
;			NEXT
;			;Update string pointer (char count X, PSP in Y)
;CF_SPACES_4		STX	0,Y
;			;Check for change of NEXT_PTR (char count in X, space char in B, I-bit set)
;			LDY	NEXT_PTR		;check for default NEXT pointer
;			CPY	#NEXT
;			BEQ	CF_SPACES_5	 	;still default next pointer
;			CLI				;enable interrupts
;			;Execute NOP
;			EXEC_CF	CF_NOP
;			JOB    	CF_SPACES_1
;			;Wait for any internal system event (char count in X, space char in B, I-bit set)
;CF_SPACES_5		EQU	*
;#ifmac FORTH_SIGNAL_IDLE
;			FORTH_SIGNAL_IDLE		;signal inactivity
;#endif
;			ISTACK_WAIT			;wait for next interrupt
;#ifmac FORTH_SIGNAL_BUSY
;			FORTH_SIGNAL_BUSY		;signal activity:   PSP+0: alignment space
;     
;#endif
;			JOB	CF_SPACES_1		;check NEXT_PTR again
;
;Word: CR ( -- )
;Cause subsequent output to appear at the beginning of the next line.
; args:   address of a terminated string
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
	
;;Word: . ( n --  )
;;Display n in free field format.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;CFA_DOT			DW	CF_DOT
;
;;Word: .R ( n1 n2 --  )
;;Display n1 right aligned in a field n2 characters wide.  If the number of
;;characters required to display n1 is greater than n2, all digits are displayed
;;with no leading spaces in a field as wide as necessary.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;CFA_DOT_R		DW	CF_DOT_R
;
;;Word: D. ( d --  )
;;Display d in free field format. 
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;CFA_D_DOT		DW	CF_D_DOT
;	
;;Word: D.R ( d n --  )
;;Display d right aligned in a field n characters wide. If the number of
;;characters required to display d is greater than n, all digits are displayed
;;with no leading spaces in a field as wide as necessary.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;CFA_D_DOT_R		DW	CF_D_DOT_R
;
;;Word: U. ( u --  )
;;Display u in free field format.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;CFA_U_DOT		DW	CF_U_DOT
;
;
;;Word: HEX. ( u --  )
;;Display u as 4 digit hexadecimal number.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;CFA_HEX_DOT		DW	CF_HEX_DOT
