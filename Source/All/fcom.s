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
;#    BASE - S12CBase framework                                                #
;#    FCORE - Forth core words                                                 #
;#    FMEM - Forth memories                                                    #
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
; RS:     none
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
	
;EMIT ( x -- ) Tansmit a byte character
; args:   PSP+0: RX data
; result: none
; SSTACK: 5 bytes
; PS:     none
; RS:     none
; throws: FEXCPT_EC_PSUF
CF_EMIT			EQU	*
			;Try to transmit data (data in D)
CF_EMIT_1		PS_COPY_D 			;copy TX data from PS
			SEI				;disable interrupts
			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
			BCC	CF_EMIT_2		;TX queue is full
			CLI				;enable interrupts
			;Remove parameter from stack
			PS_DROP, 1
			;Done
			NEXT
			;Check for change of NEXT_PTR (I-bit set)
CF_EMIT_2		LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_EMIT_3	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_EMIT_1
			;Wait for any internal system event
CF_EMIT_3		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_EMIT_1		;check NEXT_PTR again

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
	
;.$ ( c-addr -- ) Print a terminated string
; args:   address of a terminated string
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
CF_DOT_STRING		EQU	*
			;Try to print part of the string
CF_DOT_STRING_1		PS_COPY_X
			;Print string (string in X, PSP in Y)
			SEI				;disable interrupts
			STRING_PRINT_NB			;try to write to SCI (SSTACK: 8 bytes)
			BCC	CF_DOT_STRING_2		;string incomplete
			CLI				;enable interrupts
			;Remove parameter from stack
			PS_DROP, 1
			;Done
			NEXT
			;Update string pointer  (string in X, PSP in Y)
CF_DOT_STRING_2		STX	0,Y
			;Check for change of NEXT_PTR (I-bit set)
			LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_DOT_STRING_3	 	;still default next pointer
			CLI				;enable interrupts
			;Execute NOP
			EXEC_CF_JMP	CF_NOP, CF_DOT_STRING_1
			;Wait for any internal system event
CF_DOT_STRING_3		;LED_BUSY_OFF 			;signal inactivity
			ISTACK_WAIT			;wait for next interrupt
			;LED_BUSY_ON 			;signal activity
			JOB	CF_DOT_STRING_1		;check NEXT_PTR again

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
CFA_EMIT		DW	CF_EMIT

;Word: EMIT? ( -- flag )
;flag is true if the user output device is ready to accept data and the execution
;of EMIT in place of EMIT? would not have suffered an indefinite delay. If the
;device status is indeterminate, flag is true.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CFA_EMIT_QUESTION	DW	CF_EKEY_QUESTION

;S12CForth Words:
;================
;Word: .$ ( c-addr -- )
;Print a terminated string
;
;Throws:
;"Parameter stack overflow"
CFA_DOT_STRING		DW	CF_DOT_STRING
	
FCOM_WORDS_END		EQU	*
FCOM_WORDS_END_LIN	EQU	@
