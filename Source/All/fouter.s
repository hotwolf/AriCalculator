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
;#    FCORE - Forth core words                                                 #
;#    FMEM - Forth memories                                                    #
;#    FEXCPT - Forth exceptions                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;        
;                         +--------------+--------------+        
;        RS_TIB_START, -> |              |              | |          
;           TIB_START     |       Text Input Buffer     | | [TIB_CNT]
;                         |              |              | |	       
;                         |              v              | <	       
;                     -+- | --- --- --- --- --- --- --- | 	       
;          TIB_PADDING |  .                             . <- [TIB_START+TIB_CNT] 
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
;TIB_PADDING		EQU	4 
	
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
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FOUTER_CODE_START_LIN
			ORG 	FOUTER_CODE_START, FOUTER_CODE_START_LIN
#else
			ORG 	FOUTER_CODE_START
FOUTER_CODE_START_LIN	EQU	@
#endif

;Outer interpreter:
;==================
;#Perform ABORT actions
FOUTER_ABORT		EQU	*
			FORTH_ABORT

;#Perform QUIT actions
FOUTER_QUIT		EQU	*
			FORTH_QUIT

;#Query command line input
; args:   none
; result: TIB:     command line	
;         TIB_CNT: char count
; SSTACK: 10 bytes
#macro 	FOUTER_QUERY
			;Print prompt
			LDX	#FOUTER_INTERPRET_PROMPT
			STRING_PRINT_BL				;(SSTACK: 10 bytes)
			;Signal input request
			LED_BUSY_OFF
			;Reset input pointer (X)
FOUTER_QUERY_1		LDX	#TIB_START
	
			;Receive byte
FOUTER_QUERY_2		SCI_RX_BL				;(SSTACK: 6 bytes)

			;Check for errors(input pointer in X, error flags in A, char in B)
			TBNE	A, FOUTER_QUERY_5 		;beep
			
			;Ignore LF
			CMPB	#STRING_SYM_LF
			BEQ	FOUTER_QUERY_2			;ignore
			;Check for ENTER (CR)
			CMPB	#STRING_SYM_CR	
			BEQ	FOUTER_QUERY_7			;input complete

			;Check for BACKSPACE (input pointer in X,char in B)
			CMPB	#STRING_SYM_BACKSPACE	
			BEQ	FOUTER_QUERY_6	 		;check for underflow
			CMPB	#STRING_SYM_DEL	
			BEQ	FOUTER_QUERY_6	 		;check for underflow
	
			;Check for valid special characters (input pointer in X,char in B)
			CMPB	#STRING_SYM_TAB	
			BEQ	FOUTER_QUERY_3	 		;echo and append to buffer

			;Check for invalid characters (char in D, buffer pointer in Y)
			CMPB	#" " 				;first legal character in ASCII table
			BLO	FOUTER_QUERY_5			;beep
			CMPB	#"~"				;last legal character in ASCII table
			BHI	FOUTER_QUERY_5 			;beep	

			;Check for buffer overflow (input pointer in X,char in B)
#ifdef TIB_PADDING
			LEAY	TIB_PADDING,X
			CPY	RSP
			BHS	FOUTER_QUERY_5 			;beep
#else
			CPX	RSP
			BHS	FOUTER_QUERY_5 			;beep
#endif
	
			;Append char to input line (input pointer in X,char in B)
FOUTER_QUERY_3		STAB	1,X+				;store character
FOUTER_QUERY_4		SCI_TX_BL 				;echo character
			JOB	FOUTER_QUERY_2			;get next char

			;BEEP
FOUTER_QUERY_5		LDAB	#STRING_SYM_BEEP		;print beep char
			JOB	FOUTER_QUERY_4			

			;Check for buffer underflow (input pointer in X)
FOUTER_QUERY_6		CPX	#TIB_START
			BLS	FOUTER_QUERY_5 			;beep
			LEAX	-1,X				;decrement pointer
			LDAB	#STRING_SYM_BACKSPACE		;print backspace
			JOB	FOUTER_QUERY_4			
	
			;Input complete  (buffer pointer in X) 
FOUTER_QUERY_7		LEAY	-TIB_START,X 			;calculate char count
			STY	TO_IN
			BEQ	FOUTER_QUERY_8 			;empty command line
			BSET	-1,X, #$80			;terminate command line string
	
			;Signal activity
FOUTER_QUERY_8		LED_BUSY_ON
#emac
FOUTER_QUERY	

;#Echo command line
			LDX	#FOUTER_TIB_PROMPT
			STRING_PRINT_BL
			LDX	TO_IN
			BEQ	FOUTER_QUIT
			LDX	#TIB_START
			STRING_PRINT_BL






	
			JOB	FOUTER_QUIT
FOUTER_TIB_PROMPT	FOUTER_PROMPT	"TIB: "

;Code fields:
;============ 	

;CF_ABORT ( -- ) Abort and start outer interpreter
CF_QUIT			EQU	FOUTER_ABORT

;CF_QUIT ( -- ) start outer interpreter
CF_QUIT			EQU	FOUTER_QUIT

;			STRING_SKIP_WS 				;skip white space
;			FUDICT_FIND				;parse user dictionary
;			TBNE	X, CF_SUSPEND_			;word not found
;			FNVDICT_FIND				;parse non-volatile dictionary
;			TBNE	X, CF_SUSPEND_			;word not found
;			FCDICT_FIND				;parse core dictionary
;			TBNE	X, CF_SUSPEND_			;word not found
			

	
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

FOUTER_WORDS_END	EQU	*
FOUTER_WORDS_END_LIN	EQU	@
