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

;Break/suspend handling:
;=======================
;#Fix base
; args:   BASE: any base value
; result: D:    range adjusted base value (2<=base<=16)
;         BASE: range adjusted base value (2<=base<=16)
; SSTACK: none
;         X and Y are preserved
#macro	FIX_BASE, 0
			LDD	BASE
			CPD	#16
			BLS	FIX_BASE_1
			LDD	#16
			JOB	FIX_BASE_2
FIX_BASE_1		CPD	#2
			BHS	FIX_BASE_3
			LDD	#2
FIX_BASE_2		STD	BASE
FIX_BASE_3		EQU	*
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
; args:   address of a terminated string
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
			MOVW	#$0000, NUMBER_TIB
			MOVW	#TIB_START, TO_IN
			;Receive input
CF_QUERY_1		EXEC_CF	CF_EKEY				;input car -> [PS+0]
			;Check input (input car in [PS+0])
			LDD	[PSP] 				;input char -> B
			;Ignore LF (input car in B)
			CMPB	#STRING_SYM_LF
			BEQ	CF_QUERY_1			;ignore
			;Check for ENTER (CR) (input car in B and in [PS+0])
			CMPB	#STRING_SYM_CR	
			BEQ	CF_QUERY_7			;input complete		
			;Check for BACKSPACE (input char in B and in [PS+0])
			CMPB	#STRING_SYM_BACKSPACE	
			BEQ	CF_QUERY_6	 		;check for underflow
			CMPB	#STRING_SYM_DEL	
			BEQ	CF_QUERY_6	 		;check for underflow
			;Check for valid special characters (input char in B and in [PS+0])
			CMPB	#STRING_SYM_TAB	
			BEQ	CF_QUERY_2	 		;echo and append to buffer
			;Check for invalid characters (input char in B and in [PS+0])
			CMPB	#" " 				;first legal character in ASCII table
			BLO	CF_QUERY_4			;beep
			CMPB	#"~"				;last legal character in ASCII table
			BHI	CF_QUERY_4 			;beep			
			;Check for buffer overflow (input char in B and in [PS+0])
			LDY	NUMBER_TIB
			LEAY	(TIB_PADDING+TIB_START),Y
			CPY	RSP
			BHS	CF_QUERY_4 			;beep
			;Append char to input line (input char in B and in [PS+0])
CF_QUERY_2		LDY	NUMBER_TIB
			STAB	TIB_START,Y			;store character
			LEAY	1,Y				;increment char count
			STY	NUMBER_TIB
			;Echo input char (input char in [PS+0])
CF_QUERY_3		EXEC_CF	CF_EMIT				;print character
			JOB	CF_QUERY_1
			;BEEP			
CF_QUERY_4		LDD	#STRING_SYM_BEEP		;replace received char by a beep
CF_QUERY_5		STD	[PSP]
			JOB	CF_QUERY_3 			;transmit beep
			;Check for buffer underflow (input char in [PS+0])
CF_QUERY_6		LDY	NUMBER_TIB 			;decrement char count
			BEQ	CF_QUERY_4			;underflow -> beep
			LEAY	-1,Y
			STY	NUMBER_TIB
			LDD	#STRING_SYM_BACKSPACE		;replace received char by a backspace
			JOB	CF_QUERY_5
			;Input complete
CF_QUERY_7		LDY	NUMBER_TIB
			BEQ	CF_QUERY_8 			;command line is empty
			BSET	(TIB_START-1),Y, #$80		;terminate last character
			
CF_QUERY_8		NEXT
	
	
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
