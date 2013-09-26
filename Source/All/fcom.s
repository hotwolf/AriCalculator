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

;EKEY ( -- u ) Read a byte character
; args:   none
; result: PSP+0: RX data
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_COMERR
;         FEXCPT_EC_COMOF
CF_EKEY			EQU	*
			;RX loop
CF_EKEY_1		SEI				;disable interrupts
			SCI_RX_NB			;try to read from SCI (SSTACK: 4 bytes)
			BCS	CF_EKEY_2		;successful
			EXEC_CF	CF_WAI			;Wait for any event
			JOB	CF_EKEY_1		;try again			
			;One byte has been received (flags in A, data in B)
CF_EKEY_2		CLI				;enable interrupts
			;Check for RX errors (flags in A, data in B)
			BITA	#(NF|FE|PE)
			BNE	CF_EKEY_3 		;RX error
			;Check for buffer overflows (flags in A, data in B)
			BITA	#(SCI_FLG_SWOR|OR)
			BNE	CF_EKEY_4 		;buffer overflow
			;Push data onto the parameter stack  (flags in A, data in B)
			CLRA
			PS_PUSH_D
			;Done
			NEXT
			;Throw communication error
CF_EKEY_3		FEXCPT_THROW	FEXCPT_EC_COMERR	
			;Throw communication overflow error
CF_EKEY_4		FEXCPT_THROW	FEXCPT_EC_COMOF	
	
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
			;Read data from parameter stack
CF_EMIT_1		PS_COPY_D
			;Teansmit data (data in D)
			SEI				;disable interrupts
			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
			BCS	CF_EMIT_2		;successful
			EXEC_CF	CF_WAI			;Wait for any event
			JOB	CF_EMIT_1		;try again			
			;One byte has been send
CF_EMIT_2		CLI				;enable interrupts
			;Remove parameter from stack
			PS_DROP, 1
			;Done
			NEXT

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
	


;PRINT ( c-addr -- ) Print a terminated string
; args:   address of a terminated string
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
CF_PRINT		EQU	*
			;Read data from parameter stack
CF_PRINT_1		PS_COPY_X
			;Print string (string in X, PSP in Y)
			SEI				;disable interrupts
			STRING_PRINT_NB			;try to write to SCI (SSTACK: 8 bytes)
			BCS	CF_PRINT_2		;successful
			STX	0,Y			;update string pointer
			EXEC_CF	CF_WAI			;Wait for any event
			JOB	CF_PRINT_1		;try again			
			;One byte has been send
CF_PRINT_2		CLI				;enable interrupts
			;Remove parameter from stack
			PS_DROP, 1
			;Done
			NEXT

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

FCOM_WORDS_END		EQU	*
FCOM_WORDS_END_LIN	EQU	@
