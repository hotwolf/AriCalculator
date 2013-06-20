;###############################################################################
;# S12CForth - FOUTER - Forth outer interpreter                                #
;###############################################################################
;#    Copyright 2011-2013 Dirk Heisswolf                                       #
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
;#    This module implements the outer interpreter of the S12CForth            #
;#    environment.                                                             #
;#                                                                             #
;#    The outer interpreter uses these registers:                              #
;#     STATE = 0 -> Interpretation state    		       		       #
;#             1 -> Compilation state    		       		       #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 5, 2013                                                         #
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
#ifdef FOUTER_VARS_START_LIN
			ORG 	FOUTER_VARS_START, FOUTER_VARS_START_LIN
#else
			ORG 	FOUTER_VARS_START
FOUTER_VARS_START_LIN	EQU	@
#endif	
			ALIGN	1	
STATE			DS	2 		;compilation/interpretation state
BASE			DS	2 		;number conversion radix
	
FOUTER_VARS_END		EQU	*
FOUTER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FOUTER_INIT, 0
			MOVW	#$0000, STATE	
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FOUTER_CODE_START_LIN
			ORG 	FOUTER_CODE_START, FOUTER_CODE_START_LIN
#else
			ORG 	FOUTER_CODE_START
FOUTER_CODE_START_LIN	EQU	@
#endif



;Common subroutines:
;===================

;#Read a byte character from the SCI
; args:   none
; result: D: RX data
;         X: error code (0 if everything goes well)	
; SSTACK: 8 bytes
;         Y is preserved
FOUTER_RX_CHAR		EQU	*
			;Receive one byte
			SCI_RX_BL			;(SSTACK: 6 bytes)
			;Check for buffer overflows (flags in A, data in B)
			BITA	#(SCI_FLG_SWOR|OR)
			BNE	FOUTER_RX_CHAR_2 	;buffer overflow
			;Check for RX errors (flags in A, data in B)
			BITA	#(NF|FE|PE)
			BNE	FOUTER_RX_CHAR_3 	;RX error
			;Return data (data in B)
			CLRA
			LDX	#$0000
			;Done
FOUTER_RX_CHAR_1	SSTACK_PREPULL	2
			RTS
			;Buffer overflow
FOUTER_RX_CHAR_2	LDX	#FEXCPT_EC_COMOF
			JOB	FOUTER_RX_CHAR_1
			;RX error
FOUTER_RX_CHAR_3	LDX	#FEXCPT_EC_COMERR
			JOB	FOUTER_RX_CHAR_1
	
;#Transmit a byte character over the SCI
; args:   B: data to be send
; result: none
; SSTACK: 7 bytes
;         X, Y, and D are preserved 
FOUTER_TX_CHAR		EQU	SCI_TX_BL

;#Get command line input and store it into any buffer
; args:   D: buffer size
;         X: buffer pointer
;         Y: prompt string pointer 
; result: D: character count	
;         X: error code (0 if everything goes well)	
; SSTACK: 16 bytes
;         Y is preserved
FOUTER_ACCEPT	EQU	*	
			;Save registers
			SSTACK_PSHYXD
			;Allocate temporary variables
			;+--------+--------+
			;| char limit (D)  | <-SP
			;+--------+--------+
			;| buffer ptr (X)  |  +2
			;+--------+--------+
			;| prompt ptr (Y)  |  +4
			;+--------+--------+
			;| Return address  |  +6
			;+--------+--------+
FOUTER_ACCEPT_CHAR_LIMIT	EQU	0
FOUTER_ACCEPT_BUF_PTR	EQU	2	
			;Signal input request (buffer pointer in X, char count in Y)
			LED_BUSY_OFF




	
			;Initialize counter (buffer pointer in X, char count in Y)
			LDY	#$0000
			;Read input (buffer pointer in X, char count in Y)
FOUTER_ACCEPT_1		SSTACK_JOBSR FOUTER_RX_CHAR, 8		;receive an ASCII character (SSTACK: 8 bytes)
			TBNE	X, FOUTER_ACCEPT_8		;communication error
			LDX	FOUTER_ACCEPT_BUF_PTR,SP
			;Check for BACKSPACE (char in D, buffer pointer in X, char count in Y)
			CMPB	#STRING_SYM_BACKSPACE	
			BEQ	FOUTER_ACCEPT_4 		;remove most recent character
			CMPB	#STRING_SYM_DEL	
			BEQ	FOUTER_ACCEPT_4 		;remove most recent character
			;Check for ENTER (CR) (char in D, buffer pointer in X, char count in Y)
			CMPB	#STRING_SYM_CR	
			BEQ	FOUTER_ACCEPT_6			;process input
			;Ignore LF (char in D, buffer pointer in X, char count in Y)
			CMPB	#STRING_SYM_LF
			BEQ	FOUTER_ACCEPT_1			;ignore
			;Check for buffer overflow (char in D, buffer pointer in X, char count in Y)
			CPY	FOUTER_ACCEPT_CHAR_LIMIT,SP	
			BHS	FOUTER_ACCEPT_5	 		;beep on overflow
			;Check for valid special characters (char in D, buffer pointer in X, char count in Y)
			CMPB	#STRING_SYM_TAB	
			BEQ	FOUTER_ACCEPT_2 		;echo and append to buffer
			;Check for invalid characters (char in D, buffer pointer in X, char count in Y)
			CMPB	#" " 		;first legal character in ASCII table
			BLO	FOUTER_ACCEPT_5			;ignore character
			CMPB	#"~"				;last legal character in ASCII table
			BHI	FOUTER_ACCEPT_5 		;ignore character
			;Echo character and append to buffer (char in D, buffer pointer in X, char count in Y)
FOUTER_ACCEPT_2		LEAY	1,Y			
			STAB	1,X+				;store character
			STX	FOUTER_ACCEPT_BUF_PTR,SP
FOUTER_ACCEPT_3		SSTACK_JOBSR FOUTER_TX_CHAR, 7		;echo a character
			JOB	FOUTER_ACCEPT_1
			;Remove most recent character (buffer pointer in X, char count in Y)
FOUTER_ACCEPT_4		TBEQ	Y, FOUTER_ACCEPT_5		;beep if TIB was empty
			LEAY	-1,Y			
			LEAX	-1,X
			STX	FOUTER_ACCEPT_BUF_PTR,SP
			LDAB	#STRING_SYM_BACKSPACE 		;transmit a backspace character
			JOB	FOUTER_ACCEPT_3
			;Beep
FOUTER_ACCEPT_5		LDAB	#STRING_SYM_BEEP			
			JOB	FOUTER_ACCEPT_3  		;transmit beep
			;Process input (char count in Y)
FOUTER_ACCEPT_6		TBEQ	Y, FOUTER_ACCEPT_6a 		;empty string
			BSET	-1,X, #$80 			;terminate last character
			LDX	#$0000
FOUTER_ACCEPT_7		STY	FOUTER_ACCEPT_CHAR_LIMIT,SP	
			STX	FOUTER_ACCEPT_BUF_PTR,SP
			;Done
			LED_BUSY_ON
			SSTACK_PULDXY
			SSTACK_RTS
			;Communication error (char count in Y, error code in X)
FOUTER_ACCEPT_8		EQU	FOUTER_ACCEPT_7	












	


















	



	



;Code fields:
;============ 	

;CF_ABORT ( -- ) Execute the first execution token after the CFA (CFA in X)
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 


;CF_QUIT ( -- )	Execute the first execution token after the CFA (CFA in X)
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 



;CF_SUSPEND ( -- )	Execute the first execution token after the CFA (CFA in X)
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 




;CF_RESUME ( -- )	Execute the first execution token after the CFA (CFA in X)
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 









	
FOUTER_CODE_END		EQU	*
FOUTER_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FOUTER_TABS_START_LIN
			ORG 	FOUTER_TABS_START, FOUTER_TABS_START_LIN
#else
			ORG 	FOUTER_TABS_START
FOUTER_TABS_START_LIN	EQU	@
#endif	

;System prompts
FOUTER_SUSPEND_PROMPT	FCS	"S> "
FOUTER_INTERPRET_PROMPT	FCS	"> "
FOUTER_COMPILE_PROMPT	FCS	"+ "
FOUTER_SKIP_PROMPT	FCS	"0 "
FOUTER_SYSTEM_PROMPT	FCS	" ok"


FOUTER_TABS_END		EQU	*
FOUTER_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FOUTER_WORDS_START_LIN
			ORG 	FOUTER_WORDS_START, FOUTER_WORDS_START_LIN
#else
			ORG 	FOUTER_WORDS_START
FOUTER_WORDS_START_LIN	EQU	@
#endif	





FOUTER_WORDS_END		EQU	*
FOUTER_WORDS_END_LIN	EQU	@
