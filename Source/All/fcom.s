;###############################################################################
;# S12CForth - FCOM - Communication Interface for the S12CForth Framework      #
;###############################################################################
;#    Copyright 2011 Dirk Heisswolf                                            #
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
;#    FPS    - Forth parameter stack                                           #
;#    FINNER - Forth inner interpreter                                         #
;#    FOUTER - Forth outer interpreter                                         #
;#    FEXCPT - Forth exceptions                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FCOM_VARS_START_LIN
			ORG 	FCOM_VARS_START, FCOM_VARS_START_LIN
#else
			ORG 	FCOM_VARS_START
FCOM_VARS_START_LIN	EQU	@
#endif

FCOM_VARS_END		EQU	*
FCOM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FCOM_INIT, 0
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FCOM_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FCOM_QUIT, 0
#emac
	
;#Suspend action
#macro	FCOM_SUSPEND, 0
#emac
		
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FCOM_CODE_START_LIN
			ORG 	FCOM_CODE_START, FCOM_CODE_START_LIN
#else
			ORG 	FCOM_CODE_START
FCOM_CODE_START_LIN	EQU	@
#endif

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
;         FEXCPT_EC_COMOF
CF_EKEY			EQU	*
			;Try to receive data 
CF_EKEY_1		SEI				;disable interrupts
			SCI_RX_NB			;try to read from SCI (SSTACK: 4 bytes)
			BCC	CF_EKEY_2		;no data available
			CLI				;enable interrupts
			;Check for RX errors (flags in A, data in B)
			BITA	#(NF|FE|PE)
			BNE	CF_EKEY_4 		;RX error
			;Check for RX buffer overflow (flags in A, data in B)
			BITA	#(SCI_FLG_SWOR|OR)
			BNE	CF_EKEY_5 		;RX buffer overflow
			;Push data onto the parameter stack  (flags in A, data in B)
			CLRA
			PS_PUSH_D
			;Done
			NEXT
			;Check for change of NEXT_PTR (I-bit set)
CF_EKEY_2		LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_EKEY_3	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_EKEY_1
			;Wait for any internal system event
CF_EKEY_3		LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			LED_BUSY_ON 			;signal activity
			JOB	CF_EKEY_1		;check NEXT_PTR again
			;RX error
CF_EKEY_4		FEXCPT_THROW	FEXCPT_EC_COMERR
			;RX buffer overflow
CF_EKEY_5		FEXCPT_THROW	FEXCPT_EC_COMOF

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
			SCI_RX_READY_NB			;check RX queue (SSTACK: 4 bytes)
			SBCB	#$00			;set or clear all bits in B
			TBA				;B -> A
			;Push the result onto the PS
			PS_PUSH_D
			;Done
			NEXT
	
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
			BCC	CF_EMIT_3		;TX queue is full
			CLI				;enable interrupts
			;Remove parameter from stack
			PS_DROP, 1
			;Done
			NEXT
			;Check for change of NEXT_PTR (data in D, I-bit set)
CF_EMIT_3		LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_EMIT_4	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_EMIT_1
			;Wait for any internal system event (data in D, I-bit set)
CF_EMIT_4		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_EMIT_2		;check NEXT_PTR again
			;JOB	CF_EMIT_1		;maybe more robust?

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
			SCI_TX_READY_NB			;check RX queue (SSTACK: 4 bytes)
			SBCB	#$00			;set or clear all bits in B
			TBA				;B -> A
			;Push the result onto the PS
			PS_PUSH_D
			;Done
			NEXT


;.R ( n1 n2 -- ) Print right aligned signed number
; args:   PSP+0: alignment space
;         PSP+1: signed number
; result: none
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF



	
;D.R ( d n -- ) Print right aligned double number
; args:   PSP+0: alignment space
;         PSP+1: signed double number
; result: none
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
CF_D_DOT_R		EQU	* 
			;Check PS
			PS_CHECK_UF	3 		;PSP -> Y
			;Check sign of double number (PSP in Y)
			LDD	2,Y
			BPL	CF_D_DOT_R_3		;positive number
			;Negate double number (PSP in Y)
			CLRA				;clear D
			CLRB	
			TFR	D, X 			;clear X
			SUBD	4,Y
			EXG	D, X
			SBCB	3,Y
			SBCA	2,Y
			STD	2,Y 			;save negated double value
			STX	4,Y
			;Set base (PSP in Y, positive double number in D:X)
			TFR	D, Y
			FIX_BASE 			;base -> D
			;Reverse double number (base in B, positive double number in Y:X)
			NUM_REVERSE			;digit count -> A (SSTACK: 18 bytes)
			NUM_CLEAN_REVERSE 		;clean up SSTACK
			;Calculate alignment (digit count in A)
			LDY	PSP 			;PSP -> Y
			LDX	#$0001			;consider sign
			LEAX	A,X			;sign/digit count -> X
			LDD	0,Y			;calculate number of space chars
			STX	0,Y
			SUBD	0,Y
			BHI	CF_D_DOT_R_2 		;alignment is required
			PS_DROP 1			;drop alignment size from PS
CF_D_DOT_R_1		EXEC_CF_JMP CF_MINUS, CF_D_DOT_R_5;print sign
CF_D_DOT_R_2		STD	0,Y
			EXEC_CF_JMP CF_SPACES, CF_D_DOT_R_1;print alignment		
			;Positive number (PSP in Y, MSW	in D) 
CF_D_DOT_R_3		LDX	4,Y
			TFR	D, Y
			;Set base (positive double number in Y:X)			
			FIX_BASE 			;base -> D
			;Reverse double number (base in B, positive double number in Y:X)
			NUM_REVERSE			;digit count -> A (SSTACK: 18 bytes)
			;Check if alignment is needed (reverse on SSTACK, digit count in A, number in Y:X)
			LDY	PSP 			;PSP -> Y
			TAB				;A -> D
			CLRA
			LDX	0,Y
			STD	0,Y
			TFR	X,D
			SUBD	0,Y
			BHI	CF_D_DOT_R_4 		;alignment is required
			PS_DROP 3			;drop alignment size and number from PS
			JOB	CF_D_DOT_R_7		;print reverse
CF_D_DOT_R_4		STD	0,Y
			NUM_CLEAN_REVERSE 		;clean up SSTACK
			EXEC_CF	CF_SPACES		;print alignment
			;Calculate reverse number
CF_D_DOT_R_5		LDY	PSP 			;PSP -> Y
			LDX	2,Y
			LDY	0,Y
			;Set base (positive double number in Y:X)			
			FIX_BASE 			;base -> D
			;Reverse double number (base in B, positive double number in Y:X)
			NUM_REVERSE			;digit count -> A (SSTACK: 18 bytes)
			;Cleanup PS (reverse on SSTACK)
CF_D_DOT_R_6		PS_DROP	2 			;drop double number
			;Print reverse number (reverse on SSTACK)
CF_D_DOT_R_7		SEI				;disable interrupts
			NUM_REVPRINT_NB			;print digit (SSTACK: 8 bytes)
			BCC	CF_D_DOT_R_8     	;TX queue is full
			CLI				;enable interrupts
			;Clean up stacks (PSP in Y, Base in D)
			NUM_CLEAN_REVERSE 		;clean up SSTACK
			;Done
			NEXT
			;Check for change of NEXT_PTR (PSP in Y, base in D, I-bit set)
CF_D_DOT_R_8		LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_D_DOT_R_9		;still default next pointer
			CLI				;enable interrupts
			;Move reverse number onto the PS
			SSTACK_PREPULL	6
			PS_CHECK_OF	3 		;move reverse to PS
			STY	PSP
			MOVW	2,SP+, 0,Y 
			MOVW	2,SP+, 2,Y 
			MOVW	2,SP+, 4,Y
			;Execute NOP
			EXEC_CF	CF_NOP
			;Move revers back to sstack
			SSTACK_PREPUSH	6
			PS_CHECK_UF	3
			MOVW	2,Y+, 2,-SP
			MOVW	2,Y+, 2,-SP
			MOVW	2,Y+, 2,-SP
			STY	PSP
			JOB	CF_D_DOT_R_7		;try to print more digits
			;Wait for any internal system event (base in B, I-bit set)
CF_D_DOT_R_9		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_D_DOT_R_7		;try to print more digits

;. ( n -- ) Print signed number
; args:   PSP+0: reverse number structure
; result: none
; SSTACK: 18 bytes
; PS:     2 cells
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
CF_DOT			EQU	*

;U. ( u -- ) Print unsigned number
; args:   PSP+0: reverse number structure
; result: none
; SSTACK: 18 bytes
; PS:     2 cells
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
CF_U_DOT		EQU	*
	
;REVERSE. ( reverse -- ) Print reverse number
; args:   PSP+0: reverse number structure
; result: none
; SSTACK: 8 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
;CF_REVERSE_DOT		EQU	*
;			;PS layout (byte addresses):
;			; PSP+0: MSB   
;			; PSP+1:  |    
;			; PSP+2:  |reverse  
;			; PSP+3:  |number  
;			; PSP+4:  |    
;			; PSP+5: LSB   			
;			;Copy reverse number onto the SSTACK
;CF_REVERSE_DOT_1	PS_CHECK_UF	3 		;PSP -> Y
;			SSTACK_PREPUSH	6
;			MOVW	4,Y, 2,-SP
;			MOVW	2,Y, 2,-SP
;			MOVW	0,Y, 2,-SP
;			;Load base (PSP in Y)
;CF_REVERSE_DOT_2	FIX_BASE 			;base -> D
;			;Try to print a digit (PSP in Y, base in D)	
;CF_REVERSE_DOT_3	SEI				;disable interrupts
;			NUM_REVPRINT_NB			;print digit (SSTACK: 8 bytes)
;			BCC	CF_REVERSE_DOT_4	;TX queue is full
;			CLI				;enable interrupts
;			;Clean up stacks (PSP in Y, Base in D)
;			NUM_CLEAN_REVERSE 		;clean up SSTACK
;			PS_DROP, 3			;clean up PS
;			;Done
;			NEXT
;			;Check for change of NEXT_PTR (PSP in Y, base in D, I-bit set)
;CF_REVERSE_DOT_4	LDX	NEXT_PTR		;check for default NEXT pointer
;			CPX	#NEXT
;			BEQ	CF_REVERSE_DOT_5	 ;still default next pointer
;			CLI				;enable interrupts
;			;Move reverse number onto the PS (PSP in Y, base in D, I-bit set)
;			MOVW	2,SP+, 0,Y 
;			MOVW	2,SP+, 2,Y 
;			MOVW	2,SP+, 4,Y 
;			;Execute NOP
;			EXEC_CF_JMP	CF_NOP, CF_REVERSE_DOT_1
;			;Wait for any internal system event (base in B, I-bit set)
;CF_REVERSE_DOT_5	;LED_BUSY_OFF 			;signal inactivity
;			ISTACK_WAIT			;wait for next interrupt
;			;LED_BUSY_ON 			;signal activity
;			JOB	CF_REVERSE_DOT_3	;check NEXT_PTR again

;SPACE ( -- ) Print a space character
; args:   none
; result: none
; SSTACK: 5 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
CF_SPACE		EQU	*
			;Try to transmit space character
CF_SPACE_1		LDAB	#" " 			;space char -> B
CF_SPACE_2		SEI				;disable interrupts
			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
			BCC	CF_SPACE_3		;TX queue is full
			CLI				;enable interrupts
			;Done
			NEXT
			;Check for change of NEXT_PTR (space char in B, I-bit set)
CF_SPACE_3		LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_SPACE_4	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_SPACE_1
			;Wait for any internal system event (space char in B, I-bit set)
CF_SPACE_4		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_SPACE_2		;check NEXT_PTR again
			;JOB	CF_SPACE_1		;maybe more robust?

;SPACES ( n -- ) Transmit n space characters
; args:   PSP+0: number of space characters
; result: none
; SSTACK: 5 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
CF_SPACES		EQU	*
			;Try to transmit space characters
CF_SPACES_1		PS_COPY_X 			;space count from PS
			BLE	CF_SPACES_3		;n < 1
			;Try to transmit space character (char count in X)
			LDAB	#" " 			;space char -> B
CF_SPACES_2		SEI				;disable interrupts
			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
			BCC	CF_SPACES_4		;TX queue is full
			CLI				;enable interrupts
			;Decrement char count (char count in X, space char in B) 
			DBNE	X, CF_SPACES_2
			;Remove parameter from stack
CF_SPACES_3		PS_DROP, 1
			;Done
			NEXT
			;Check for change of NEXT_PTR (char count in X, space char in B, I-bit set)
CF_SPACES_4		LDY	NEXT_PTR		;check for default NEXT pointer
			CPY	#NEXT
			BEQ	CF_SPACES_5	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_SPACES_1
			;Wait for any internal system event (char count in X, space char in B, I-bit set)
CF_SPACES_5		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_SPACES_2		;check NEXT_PTR again
			;JOB	CF_SPACES_1		;maybe more robust?

;MINUS ( -- ) Print a minus character
; args:   none
; result: none
; SSTACK: 5 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSUF
CF_MINUS		EQU	*
			;Try to transmit MINUS character
CF_MINUS_1		LDAB	#"-" 			;MINUS char -> B
CF_MINUS_2		SEI				;disable interrupts
			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
			BCC	CF_MINUS_3		;TX queue is full
			CLI				;enable interrupts
			;Done
			NEXT
			;Check for change of NEXT_PTR (MINUS char in B, I-bit set)
CF_MINUS_3		LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_MINUS_4	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_MINUS_1
			;Wait for any internal system event (MINUS char in B, I-bit set)
CF_MINUS_4		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_MINUS_2		;check NEXT_PTR again
			;JOB	CF_MINUS_1		;maybe more robust?
	
;$. ( c-addr -- ) Print a terminated string
; args:   address of a terminated string
; result: none
; SSTACK: 8 bytes
; PS:     none
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
CF_STRING_DOT		EQU	*
			;Try to print part of the string
CF_STRING_DOT_1		PS_COPY_X
			;Print string (string in X, PSP in Y)
CF_STRING_DOT_2		SEI				;disable interrupts
			STRING_PRINT_NB			;try to write to SCI (SSTACK: 8 bytes)
			BCC	CF_STRING_DOT_3		;string incomplete
			CLI				;enable interrupts
			;Remove parameter from stack
			PS_DROP, 1
			;Done
			NEXT
			;Update string pointer (string in X, PSP in Y)
CF_STRING_DOT_3		STX	0,Y
			;Check for change of NEXT_PTR (I-bit set)
			LDY	NEXT_PTR		;check for default NEXT pointer
			CPY	#NEXT
			BEQ	CF_STRING_DOT_4	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_STRING_DOT_1
			;Wait for any internal system event (string in X)
CF_STRING_DOT_4		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_STRING_DOT_2		;check NEXT_PTR again
			;JOB	CF_STRING_DOT_1		;maybe more robust?
	
FCOM_CODE_END		EQU	*
FCOM_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FCOM_TABS_START_LIN
			ORG 	FCOM_TABS_START, FCOM_TABS_START_LIN
#else
			ORG 	FCOM_TABS_START
FCOM_TABS_START_LIN	EQU	@
#endif	

FCOM_TABS_END		EQU	*
FCOM_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FCOM_WORDS_START_LIN
			ORG 	FCOM_WORDS_START, FCOM_WORDS_START_LIN
#else
			ORG 	FCOM_WORDS_START
FCOM_WORDS_START_LIN	EQU	@
#endif	
			ALIGN	1
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
;"RX buffer overflow"
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

;Word: D.R ( d n --  )
;Display d right aligned in a field n characters wide. If the number of
;characters required to display d is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
CFA_D_DOT_R	DW	CF_D_DOT_R
	
;Word: SPACE ( -- )
;Display one space.
;
;S12CForth implementation details:
;Throws:
;"Return stack overflow"
CFA_SPACE		DW	CF_SPACE

;Word: EMIT ( n -- )
;If n is greater than zero, display n spaces.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Return stack overflow"
CFA_SPACES		DW	CF_SPACES
	
;S12CForth Words:
;================
;Word: MINUS ( -- )
;Display a minus character.
;
;S12CForth implementation details:
;Throws:
;"Return stack overflow"
CFA_MINUS		DW	CF_MINUS

;Word: $. ( c-addr -- )
;Print a terminated string
;
;Throws:
;"Parameter stack overflow"
CFA_STRING_DOT		DW	CF_STRING_DOT
	
FCOM_WORDS_END		EQU	*
FCOM_WORDS_END_LIN	EQU	@
