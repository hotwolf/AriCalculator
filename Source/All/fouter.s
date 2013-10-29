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
;#          STATE = 0 -> Interpretation state    	       		       #
;#                  1 -> Compilation state    		       		       #
;#           BASE = Number conversion radix                                    #
;#     NUMBER_TIB = Number of chars in the TIB                                 #
;#          TO_IN = In-pointer of the TIB (>IN)	       			       #
;#       	    (TIB_START+TO_IN) points to the next character	       #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 5, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
;#    FINNER - Forth inner interpreter                                         #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;        
;                         +--------------+--------------+        
;        RS_TIB_START, -> |              |              | |          
;           TIB_START     |       Text Input Buffer     | | [NUMBER_TIB]
;                         |              |              | |	       
;                         |              v              | <	       
;                     -+- | --- --- --- --- --- --- --- | 	       
;          TIB_PADDING |  .                             . <- [TIB_START+NUMBER_TIB] 
;                     -+- .                             .            
;                         | --- --- --- --- --- --- --- |            
;                         |              ^              | <- [RSP]
;                         |              |              |
;                         |        Return Stack         |
;                         |              |              |
;                         +--------------+--------------+
;             RS_EMPTY, ->                                 
;           RS_TIB_END

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Safety distance to return stack
#ifndef TIB_PADDING
TIB_PADDING		EQU	4 		;default is 4 bytes
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
TIB_START		EQU	RS_TIB_START
	
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
STATE			DS	2 		;interpreter state (0:iterpreter, -1:compile)
BASE			DS	2 		;number conversion radix

NUMBER_TIB  		DS	2		;number of chars in the TIB
TO_IN  			DS	2		;in pointer of the TIB (TIB_START+TO_IN point to the next empty byte)
	
FOUTER_VARS_END		EQU	*
FOUTER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FOUTER_INIT, 0
			LED_BUSY_ON
			MOVW	#$0000, STATE	
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FOUTER_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FOUTER_QUIT, 0
#emac
	
;#Suspend action
#macro	FOUTER_SUSPEND, 0
#emac
	
;Break/suspend handling:
;=======================
;#Break: Set break indicator and perform a systewm reset
#macro	SCI_BREAK_ACTION, 0
			RESET_RESTART_NO_MSG	
#emac

;#Suspend: Set suspend flag
#macro	SCI_SUSPEND_ACTION, 0
#emac

;General purpose macros:
;=======================
;#Fix base
; args:   BASE: any base value
; result: D:    range adjusted base value (2<=base<=16)
;         BASE: range adjusted base value (2<=base<=16)
; SSTACK: none
;         X and Y are preserved
#macro	FIX_BASE, 0
			LDD	BASE
			CPD	#NUM_BASE_MAX
			BLS	FIX_BASE_1
			LDD	#NUM_BASE_MAX
			JOB	FIX_BASE_2
FIX_BASE_1		CPD	#NUM_BASE_MIN
			BHS	FIX_BASE_3
			LDD	#NUM_BASE_MIN
FIX_BASE_2		STD	BASE
FIX_BASE_3		EQU	*
#emac

;Functions:
;==========
;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
; args:   A: delimiter
; result: X: string pointer
;	  A: character count (saturated at 255) 	
; SSTACK: 5 bytes
;         Y and B are preserved
#macro	FOUTER_PARSE, 0
			SSTACK_JOBSR	FOUTER_PARSE, 5
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


;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
; args:   A: delimiter
; result: X: string pointer
;	  D: character count	
; SSTACK: 4 bytes
;         Y is preserved
FOUTER_PARSE		EQU	*	
			;Save registers
			PSHY
			;Check for empty string (delimiter in A)
			LDY	TO_IN			;current >IN -> Y
FOUTER_PARSE_1		CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FOUTER_PARSE_7		;return empty string
			BCLR	TIB_START,Y, #$80	;remove termination
			CMPA	TIB_START,Y		
			BEQ	FOUTER_PARSE_2		;skip delimeter
			CMPA	#" "			;check is delimiter is space char
			BNE	FOUTER_PARSE_3		;parse remaining caracters
			CMPA	TIB_START,Y		
			BLS	FOUTER_PARSE_3		;parse remaining caracters
FOUTER_PARSE_2		LEAY	1,Y			;skip delimeter (increment >IN)
			JOB	FOUTER_PARSE_1
			;Parse remaining characters (>IN in Y, delimiter in A)
FOUTER_PARSE_3		LEAX	TIB_START,Y 		;string pointer -> X
FOUTER_PARSE_4		LEAY	1,Y			;increment >IN		
			CPY	NUMBER_TIB		;check for the end of the input buffer
			BHS	FOUTER_PARSE_5		;return parsed string
			BCLR	TIB_START,Y, #$80	;remove termination
			CMPA	TIB_START,Y		
			BEQ	FOUTER_PARSE_5		;delimeter found
			CMPA	#" "			;check is delimiter is space char
			BNE	FOUTER_PARSE_4		;parse remaining caracters
			CMPA	TIB_START,Y		
			BLS	FOUTER_PARSE_4		;parse remaining caracters
			;Delimeter found (>IN in Y, string pointer in X)
FOUTER_PARSE_5		STY	TO_IN 			;update >IN
			LEAY	TIB_START,Y		;end delimiter position -> Y
			BSET	-1,Y, #$80 		;terminate previous character
			TFR	X, D			;calculate character count
			COMA
			COMB
			ADDD	#1
			LEAY	D,Y
			TFR	Y, D
			;Restore registers (string pointer in X, char count in D)
FOUTER_PARSE_6		SSTACK_PREPULL	4
			PULY
			;Done (string pointer in X, char count in D)
			RTS
			;Return enpty string
FOUTER_PARSE_7		MOVW	NUMBER_TIB, TO_IN 	;mark parse area emptu
			CLRA				;clear char count
			CLRB
			TFR	D, X 			;clear string pointer
			JOB	FOUTER_PARSE_6		;done

;Code fields:
;============
;.PROMPT ( -- ) Print the command line prompt
; args:   address of a terminated string
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     1 cells
; throws: FEXCPT_EC_PSUF
CF_DOT_PROMPT		EQU	*
			;Select the prompt  
			LDX	#FOUTER_INTERPRET_PROMPT
			LDD	STATE
			BEQ	CF_DOT_PROMPT_1
			LDX	#FOUTER_COMPILE_PROMPT
CF_DOT_PROMPT_1		PS_PUSH_X 				;push prompt pointer onto the PS
			;Print the prompt (prompt pointer in [PS+0])
			JOB	CF_STRING_DOT

;QUERY ( -- ) Query command line input
;Make the user input device the input source. Receive input into the terminal input buffer, 
;replacing any previous contents. Make the result, whose address is returned by TIB, the input 
;buffer.  Set >IN to zero.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
;         FEXCPT_EC_COMOF
CF_QUERY		EQU	*
			;Print prompt
			EXEC_CF	CF_DOT_PROMPT
			;Reset input buffer
			CLRA
			CLRB
			STD	NUMBER_TIB
			STD	TO_IN
			;Receive input
CF_QUERY_1		EXEC_CF	CF_EKEY				;input car -> [PS+0]
			;Check input (input car in [PS+0])
			LDD	[PSP] 				;input char -> B
			;Ignore LF (input car in B)
			CMPB	#STRING_SYM_LF
			BEQ	CF_QUERY_4			;ignore
			;Check for ENTER (CR) (input car in B and in [PS+0])
			CMPB	#STRING_SYM_CR	
			BEQ	CF_QUERY_8			;input complete		
			;Check for BACKSPACE (input char in B and in [PS+0])
			CMPB	#STRING_SYM_BACKSPACE	
			BEQ	CF_QUERY_7	 		;check for underflow
			CMPB	#STRING_SYM_DEL	
			BEQ	CF_QUERY_7	 		;check for underflow
			;Check for valid special characters (input char in B and in [PS+0])
			CMPB	#STRING_SYM_TAB	
			BEQ	CF_QUERY_2	 		;echo and append to buffer
			;Check for invalid characters (input char in B and in [PS+0])
			CMPB	#" " 				;first legal character in ASCII table
			BLO	CF_QUERY_5			;beep
			CMPB	#"~"				;last legal character in ASCII table
			BHI	CF_QUERY_5 			;beep			
			;Check for buffer overflow (input char in B and in [PS+0])
			LDY	NUMBER_TIB
			LEAY	(TIB_PADDING+TIB_START),Y
			CPY	RSP
			BHS	CF_QUERY_5 			;beep
			;Append char to input line (input char in B and in [PS+0])
CF_QUERY_2		LDY	NUMBER_TIB
			STAB	TIB_START,Y			;store character
			LEAY	1,Y				;increment char count
			STY	NUMBER_TIB
			;Echo input char (input char in [PS+0])
CF_QUERY_3		EXEC_CF	CF_EMIT				;print character
			JOB	CF_QUERY_1
			;Ignore input char
CF_QUERY_4		LDY	PSP 				;drop char from PS
			LEAY	2,Y
			STY	PSP
			JOB	CF_QUERY_1
			;BEEP			
CF_QUERY_5		LDD	#STRING_SYM_BEEP		;replace received char by a beep
CF_QUERY_6		STD	[PSP]
			JOB	CF_QUERY_3 			;transmit beep
			;Check for buffer underflow (input char in [PS+0])
CF_QUERY_7		LDY	NUMBER_TIB 			;decrement char count
			BEQ	CF_QUERY_4			;underflow -> beep
			LEAY	-1,Y
			STY	NUMBER_TIB
			LDD	#STRING_SYM_BACKSPACE		;replace received char by a backspace
			JOB	CF_QUERY_6
			;Input complete
CF_QUERY_8		LDY	PSP 				;drop char from PS
			LEAY	2,Y
			STY	PSP
			LDY	NUMBER_TIB 			;check char count
			BEQ	CF_QUERY_9 			;command line is empty
			BSET	(TIB_START-1),Y, #$80		;terminate last character
CF_QUERY_9		NEXT

;PARSE ( char "ccc<char>" -- c-addr u ) Parse the TIB
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
; args:   PSP+0: delimiter char
; result: PSP+0: character count
;         PSP+1: string pointer
; SSTACK: 5 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_PARSE		EQU	*
			;Check PS
			PS_CHECK_UFOF	1, 1 		;new PSP -> Y
			STY	PSP
			;Get delimiter char (PSP in Y)
			LDAA	3,Y
			;Parse TIB (delimiter char in A, PSP in Y)  
			FOUTER_PARSE 			;(SSTACK: 5 bytes)
			;Pass results to PS (char count in A, string pointer in X, PSP in Y)
			STX	2,Y
			TAB
			CLRA
			STD	0,Y
			;Done
			NEXT
			
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

;Prompt string definition format
; args:   1: P
#macro	FOUTER_PROMPT, 1
			STRING_NL_NONTERM
			FCS	\1
#emac
	
;System prompts
FOUTER_INTERPRET_PROMPT	FOUTER_PROMPT	"> "
FOUTER_COMPILE_PROMPT	FOUTER_PROMPT	"+ "


FOUTER_SKIP_PROMPT	FOUTER_PROMPT	"0 "
FOUTER_SYSTEM_ACK	FCS		" ok"

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
			ALIGN	1
;#ANSForth Words:
;================
;Word: QUERY ( -- )
;Make the user input device the input source. Receive input into the terminal input buffer, 
;replacing any previous contents. Make the result, whose address is returned by TIB, the input 
;buffer.  Set >IN to zero.
;
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
;"Invalid RX data"
;"RX buffer overflow"
CFA_QUERY		DW	CF_QUERY

;Word: PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
;
;Throws:
;"Parameter stack overflow"
;"Parameter stack underflow"
CFA_PARSE		DW	CF_PARSE
	
;Word: STATE ( -- a-addr ) 
;a-addr is the address of a cell containing the compilation-state flag.  STATE is true when in 
;compilation state, false otherwise.  The true value in STATE is non-zero, but is otherwise 
;implementation-defined.  Only the following standard words alter the value in STATE:  : 
;(colon), ; (semicolon), ABORT, QUIT, :NONAME, [ (left-bracket), and ] (right-bracket). 
;  Note:  A program shall not directly alter the contents of STATE. 
;
;Throws:
;"Parameter stack overflow"
CFA_STATE		DW	CF_PS_PUSH
			DW	STATE

;Word: BASE ( -- a-addr ) 
;a-addr is the address of a cell containing the current number-conversion radix {{2...36}}. 
;
;Throws:
;"Parameter stack overflow"
CFA_BASE		DW	CF_PS_PUSH
			DW	BASE

;Word: >IN ( -- a-addr ) 
;a-addr is the address of a cell containing the offset in characters from the start of the input 
;buffer to the start of the parse area.  
;
;Throws:
;"Parameter stack overflow"
CFA_TO_IN		DW	CF_PS_PUSH
			DW	TO_IN

;Word: #TIB ( -- a-addr ) 
;a-addr is the address of a cell containing the number of characters in the terminal input buffer.
;
;Throws:
;"Parameter stack overflow"
CFA_NUMBER_TIB		DW	CF_PS_PUSH
			DW	NUMBER_TIB

;S12CForth Words:
;================
;Word: .PROMPT ( -- )
;Print the command line prompt (interpretation or compilation)
;
;Throws:
;"Parameter stack overflow"
CFA_DOT_PROMPT		DW	CF_DOT_PROMPT
	
FOUTER_WORDS_END	EQU	*
FOUTER_WORDS_END_LIN	EQU	@
