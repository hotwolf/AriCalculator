;###############################################################################
;# S12CForth - FIO - I/O Handler for the S12CForth Framework                   #
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
#macro	FIO_INIT, 0
#emac

;#Turn busy signal on
#macro	FIO_SIGNAL_BUSY_ON, 0
#ifdef LED_CODE_START
			LED_BUSY_ON
#endif
#emac

;#Turn busy signal off
#macro	FIO_SIGNAL_BUSY_OFF, 0
#ifdef LED_CODE_START
			LED_BUSY_OFF
#endif
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

;#Read a byte character from the SCI
; args:   none
; result: PSP+0: RX data
; SSTACK: 6 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_COMERR
;         FEXCPT_EC_COMOF
CF_EKEY			EQU	*
			;Receive one byte
CF_EKEY_1		SEI				;disable interrupts
			SCI_RX_NB			;try to read from SCI (SSTACK: 6 bytes)
			BCS	CF_EKEY_3		;successful
			FIRQ_CHECK_IRQ	CF_EKEY_2	;check if interrupts are pending
			ISTACK_WAIT			;wait for next interrupt
			JOB	CF_EKEY_1		;try again
			;Execute all pending ISRs
CF_EKEY_2		CLI				;enable interrupts
			FIRQ_EXEC_IRQ
			JOB	CF_EKEY_1		;try again
			;One byte has been received (flags in A, data in B)
CF_EKEY_3		CLI				;enable interrupts
			;Check for RX errors (flags in A, data in B)
			BITA	#(NF|FE|PE)
			BNE	FIO_EKEY_4 		;RX error
			;Check for buffer overflows (flags in A, data in B)
			BITA	#(SCI_FLG_SWOR|OR)
			BNE	CF_EKEY_5 		;buffer overflow
			;Push data onto the parameter stack  (flags in A, data in B)
			CLRA
			PS_PUSH_D
			;Done
			NEXT
			;Throw communication error
CF_EKEY_4		FEXCPT_THROW	FEXCPT_EC_COMERR	
			;Throw communication overflow error
CF_EKEY_5		FEXCPT_THROW	FEXCPT_EC_COMOF	
	
;#Check if SCI has received data
; args:   none
; result: PSP+0: flag (true if data is available)
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
CF_EKEY_QUESTION	EQU	*
			;Check stack
			PS_CHECK_OF, 1 			;check parameter stack
			;Push TRUE onto the stack (new PSP in Y)
			MOVW	#TRUE, 0,Y
			STY	PSP
			;Check if read data is available (PSP in Y)
			SCI_RX_READY_NB			 
			BCS	CF_EKEY_QUESTION_1 	;done
			MOVW	#FALSE, 0,Y 		;return false
			;Done
CF_EKEY_QUESTION_1	NEXT
	
;#Tansmit a byte character over the SCI
; args:   PSP+0: RX data
; result: none
; SSTACK: 5 bytes
; PS:     none
; RS:     none
; throws: FEXCPT_EC_PSUF
CF_EMIT			EQU	*
			;Pull data from parameter stack
			PS_PULL_D
			;Teansmit data (data in D)
CF_EMIT_1		SEI				;disable interrupts
			SCI_TX_NB			;try to write to SCI (SSTACK: 5 bytes)
			BCS	CF_EMIT_3		;successful
			FIRQ_CHECK_IRQ	CF_EMIT_2	;check if interrupts are pending
			ISTACK_WAIT			;wait for next interrupt
			JOB	CF_EMIT_1		;try again
			;Execute all pending ISRs
CF_EMIT_2		CLI				;enable interrupts
			FIRQ_EXEC_IRQ
			JOB	CF_EMIT_1		;try again
			;One byte has been transmittet
CF_EMIT_3		CLI				;enable interrupts
			;Done
			NEXT

;#Check if data can be sent over the SCI
; args:   none
; result: PSP+0: flag (true if data is available)
; SSTACK: 4 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
CF_EMIT_QUESTION	EQU	*
			;Check stack
			PS_CHECK_OF, 1 			;check parameter stack
			;Push TRUE onto the stack (new PSP in Y)
			MOVW	#TRUE, 0,Y
			STY	PSP
			;Check if read data is available (PSP in Y)
			SCI_TX_READY_NB			 
			BCS	CF_EMIT_QUESTION_1 	;done
			MOVW	#$FALSE, 0,Y 		;return false
			;Done
			NEXT
	
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

FIO_WORDS_END		EQU	*
FIO_WORDS_END_LIN	EQU	@
