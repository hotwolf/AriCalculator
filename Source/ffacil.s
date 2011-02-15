;###############################################################################
;# S12CForth - FFACIL - ANS Forth Facility Words                               #
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
;#    This module implements some of the Facility words (FACILITY) of the ANS  #
;#    Forth standard.                                                          #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FCORE - Forth core words                                                 #
;#    FMEM - Forth memories                                                    #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FFACIL_VARS_START
FFACIL_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FFACIL_INIT, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FFACIL_CODE_START
;Common subroutines:
;=================== 	

;Exceptions:
;===========
;Standard exceptions
FFACIL_THROW_PSOF	EQU	FMEM_THROW_PSOF			;stack overflow
FFACIL_THROW_PSUF	EQU	FMEM_THROW_PSUF			;stack underflow
	
;Common throw routines
FFACIL_THROW_X		EQU	FCORE_THROW_X			;throw error code in X

FFACIL_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FFACIL_TABS_START
FFACIL_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FFACIL_WORDS_START

;#Facility words (FACILITY):
; ==========================

;AT-XY ( u1 u2 -- )
;Perform implementation-dependent steps so that the next character displayed will
;appear incolumn u1, row u2 of the user output device, the upper left corner of
;which is column zero, row zero. An ambiguous condition exists if the operation
;cannot be performed on the user output device with the specified parameters.
NFA_AT_X_Y	EQU	FFACIL_PREV_NFA

;KEY? ( -- flag )
;If a character is available, return true. Otherwise, return false. If
;non-character keyboardevents are available before the first valid character,
;they are discarded and are subsequently unavailable. The character shall be
;returned by the next execution of KEY. After KEY? returns with a value of true,
;subsequent executions of KEY? prior to the execution of KEY or EKEY also return
;true, without discarding keyboard events.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Invalid RX data"
;"RX buffer overflow"
;
			ALIGN	1
NFA_KEY_QUESTION	FHEADER, "KEY?", NFA_AT_X_Y, COMPILE
CFA_KEY_QUESTION	DW	CF_KEY_QUESTION
CF_KEY_QUESTION		PS_CHECK_OF	1, CF_KEY_QUESTION_PSOF	;check for PS overflow (PSP-2 cells -> Y)
			;Search RX queue for ASCII data (PSP-2 in Y)
			SSTACK_JOBSR	FCORE_KEY_QUESTION
			TBEQ	D, CF_KEY_QUESTION_1 		;no ASCII chars available
			TBNE	X, CF_KEY_QUESTION_COMMERR 	;RX error
			LDD	#$FFFF
			;Rueturn result (flag in D, PSP-2 in Y)
CF_KEY_QUESTION_1	STD	0,Y
			STY	PSP
			;Done 
			NEXT

CF_KEY_QUESTION_PSOF	JOB	FFACIL_THROW_PSOF
CF_KEY_QUESTION_COMMERR	JOB	FFACIL_THROW_X

;PAGE ( -- )
;Move to another page for output. Actual function depends on the output device.
;On a terminal, PAGE clears the screen and resets the cursor position to the
;upper left corner. On a printer, PAGE performs a form feed.
NFA_PAGE		EQU	NFA_KEY_QUESTION
	
;#Facility extension words (FACILITY EXT):
; ========================================
	
;EKEY ( -- u ) CHECK!
;Receive one keyboard event u. The encoding of keyboard events is implementation
;defined.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Communication problem"
;
			ALIGN	1
NFA_EKEY		FHEADER, "EKEY", NFA_PAGE, COMPILE
CFA_EKEY		DW	CF_EKEY
CF_EKEY			PS_CHECK_OF	1, CF_EKEY_PSOF	;check for PS overflow (PSP-2 cells -> Y)
			;Wait for data byte
			LED_BUSY_OFF
			SSTACK_JOBSR	FCORE_EKEY       ;(SSTACK: 8 bytes)
			LED_BUSY_ON
			;Check for transmission errors (data in D, error code in X)
			TBNE	X, CF_EKEY_COMMERR
 			;Put received character onto the stack (char in B, PSP in Y)
			STD	0,Y
			STY	PSP
			NEXT

CF_EKEY_PSOF		JOB	FCORE_THROW_PSOF
CF_EKEY_COMMERR		JOB	FCORE_THROW_X
	
;EKEY>CHAR ( u -- u false | char true ) CHECK!
;If the keyboard event u corresponds to a character in the
;implementation-defined character set, return that character and true. Otherwise
;return u and false.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;
			ALIGN	1
NFA_EKEY_TO_CHAR	FHEADER, "EKEY>CHAR", NFA_EKEY, COMPILE
CFA_EKEY_TO_CHAR	DW	CF_EKEY_TO_CHAR
CF_EKEY_TO_CHAR		PS_CHECK_UFOF	1, CF_EKEY_TO_CHAR_PSUF, 1, CF_EKEY_TO_CHAR_PSOF	;check for under and overflow
			;Check data (PSP-2 in Y)
			LDX	#$0000 			;false
			LDD	2,Y
			TBNE	A, CF_EKEY_TO_CHAR_1 	;> 8 bit
			ASCII_ONLY CF_EKEY_TO_CHAR_1 	;no ASCII char
			LDX	#$FFFF 			;true
			;Return result (flag in X, PSP-2 in Y)
CF_EKEY_TO_CHAR_1	STX	0,Y
			STY	PSP
			;Done
			NEXT
			
CF_EKEY_TO_CHAR_PSUF	JOB	FFACIL_THROW_PSUF
CF_EKEY_TO_CHAR_PSOF	JOB	FFACIL_THROW_PSOF
	
;EKEY? ( -- flag )
;If a keyboard event is available, return true. Otherwise return false. The
;event shall be returned by the next execution of EKEY. After EKEY? returns with
;a value of true, subsequent executions of EKEY? prior to the execution of KEY,
;KEY? or EKEY also return true, referring to the same event.	
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_EKEY_QUESTION	FHEADER, "EKEY?", NFA_EKEY_TO_CHAR, COMPILE
CFA_EKEY_QUESTION	DW	CF_EKEY_QUESTION
CF_EKEY_QUESTION	PS_CHECK_OF	1, CF_EKEY_QUESTION_PSOF	;check for PS overflow (PSP-2 cells -> Y)
			;Peek into RX queue (PSP-2 in Y)
			SSTACK_JOBSR	FCORE_EKEY_QUESTION 		;(SSTACK: 2 bytes)
			TBEQ	X, CF_EKEY_QUESTION_1 			;RX queue isempty
			LDX	#$FFFF
CF_EKEY_QUESTION_1	STX	0,Y
			STY	PSP
			;Done
			NEXT

CF_EKEY_QUESTION_PSOF		JOB	FCORE_THROW_PSOF

;EMIT? ( -- flag ) CHECK!
;flag is true if the user output device is ready to accept data and the execution
;of EMIT in place of EMIT? would not have suffered an indefinite delay. If the
;device status is indeterminate, flag is true.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_EMIT_QUESTION	FHEADER, "EMIT?", NFA_EKEY_QUESTION, COMPILE
CFA_EMIT_QUESTION	DW	CF_EMIT_QUESTION
CF_EMIT_QUESTION	PS_CHECK_OF	1, CF_EMIT_QUESTION_PSOF	;check for PS overflow (PSP-2 cells -> Y)
			;Peek into RX queue (PSP+2 in Y)
			SSTACK_JOBSR	FCORE_EMIT_QUESTION 		;(SSTACK: 2 bytes)
			CLRB
			TBEQ	A, CF_EMIT_QUESTION_1 			;RX queue isempty
			LDD	#$FFFF
CF_EMIT_QUESTION_1	STD	0,Y
			STY	PSP
			;Done
			NEXT

CF_EMIT_QUESTION_PSOF		JOB	FCORE_THROW_PSOF

;MS ( u -- )
;Wait at least u milliseconds.
;Note: The actual length and variability of the time period depends upon the
;implementation-defined resolution of the system clock and upon other system and
;computer characteristics beyond the scope of this Standard.
NFA_MS			EQU	NFA_EMIT_QUESTION	
	
;TIME&DATE ( -- +n1 +n2 +n3 +n4 +n5 +n6 )
;Return the current time and date. +n1 is the second {0...59}, +n2 is the minute
;{0...59}, +n3 is the hour {0...23}, +n4 is the day {1...31} +n5 is the month
;{1...12}, and +n6 is the year (e.g., 1991).
NFA_TIME_AND_DATE	EQU	NFA_MS

FFACIL_WORDS_END	EQU	*
FFACIL_LAST_NFA		EQU	NFA_TIME_AND_DATE
