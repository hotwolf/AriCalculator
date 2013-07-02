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
;   FRAM_TIB_RS_START, -> |              |              | |          
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
;     FRAM_TIB_RS_END, ->                                 
;            RS_EMPTY

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;TIB location
;TIB_START		EQU	0

;Safety distance to return stack 
;TIB_PADDING		EQU	4 
	
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
STATE			DS	2 		;interpreter state (0:iterpreter, -1:compile)
BASE			DS	2 		;number conversion radix
NUMBER_TIB  		DS	2		;number of chars in the TIB
TO_IN  			DS	2		;in pointer of the TIB (TIB_START+TO_IN poin
	
FOUTER_VARS_END		EQU	*
FOUTER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FOUTER_INIT, 0
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
FOUTER_ACCEPT_BUF_PTR		EQU	2	
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

;CF_ABORT ( -- ) Abort and start outer interpreter
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
CF_QUIT			EQU	*
			MOVW	#PSP_EMPTY, PSP			;reset parameter stack

;CF_QUIT ( -- ) start outer interpreter
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
CF_QUIT			EQU	*
			MOVW	#RSP_EMPTY, RSP			;reset return stack

;CF_SUSPEND ( -- ) temporarily suspend execution and start outer interpreter
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: 10 bytes
;        D is preserved 
CF_SUSPEND		EQU	*
			;Signal input request
			LED_BUSY_OFF
			;Print prompt INTERPRET, COMPILE, OR SUSPEND
			LDX	#FOUTER_COMPILE_PROMPT		;compile prompt if STATE != 0
			LDD	STATE
			BNE	CF_SUSPEND_1
			LDX	#FOUTER_SUSPEND_PROMPT		;suspend prompt if RSP != RS_BOTTOM 
			LDD	RSPX1X3
			CPD	#RS_EMPTY
			BNE	CF_SUSPEND_1
			LDX	#FOUTER_INTERPRET_PROMPT	;interpretation prompt otherwise 
CF_SUSPEND_1		STRING_PRINT_BL		 		;(SSTACK: 10 bytes)
			;Reset TIB
			LDY	#$0000					
			;Read character (char count in Y)
CF_SUSPEND_2		SCI_RX_BL				;(SSTACK: 6 bytes)
			;Check for errors (flags in A, char in B, char count in Y)
			BITA	#(SCI_FLG_SWOR|OR)		;check for RX buffer overflow
			BNE	CF_SUSPEND_8			;handle RX buffer overflow
			BITA	#(NF|FE|PE)			;check for RX errors
			BNE	CF_SUSPEND_9			;handle RX errors
			;Check for BACKSPACE (char in B, char count in Y)
			CMPB	#STRING_SYM_BACKSPACE	
			BEQ	CF_SUSPEND_6			;handle backspace
			CMPB	#STRING_SYM_DEL	
			BEQ	CF_SUSPEND_5			;handle as backspace
			;Check for ENTER (CR) (char in B, char count in Y)
			CMPB	#STRING_SYM_CR	
			BEQ	CF_SUSPEND_10			;process input
			;Ignore LF  (char in B, char count in Y)
			CMPB	#STRING_SYM_LF
			BEQ	CF_SUSPEND_2			;ignore
			;Check for TIB overflow (char in B, char count in Y)
#ifdef	TIB_PADDING
			LEAX	TIB_PADDING,Y 			;consider TIB padding
			CPX	RSP				;check TIB range
#else
			CPY	RSP				;check TIB range
#endif
			BHS	CF_SUSPEND_7	 		;handle TIB overflow
			;Check for valid special characters (char in B, char count in Y)
			CMPB	#STRING_SYM_TAB	
			BEQ	CF_SUSPEND_3            	;append to buffer and echo 
			;Check for invalid characters (char in B, char count in Y)
			CMPB	#" " 				;first legal character in ASCII table
			BLO	CF_SUSPEND_7	               	;handle invalid input
			CMPB	#"~"				;last legal character in ASCII table
			BHI	CF_SUSPEND_7               	;handle invalid input
			;Append to buffer and echo (char in B, char count in Y)
CF_SUSPEND_3		STAB	TIB_START,Y 			;append input character
			LEAY	1,Y				;increment TIB count
CF_SUSPEND_4		SCI_TX_BL				;(SSTACK: 7 bytes)
			CF_SUSPEND_2				;wait for input
			;Remove most recent character (char in B, char count in Y)
CF_SUSPEND_5		LDAB	#STRING_SYM_BACKSPACE 		;convert DEL to BACKSPACE
CF_SUSPEND_6		TBEQ	Y, CF_SUSPEND_7			;handle empty TIB
			LEAY	-1,Y				;decrement TIB count
			CF_SUSPEND_4				;echo BACKSPACE
			;Beep and ignore (char count in Y)
CF_SUSPEND_7		LDAB	#STRING_SYM_BEEP			
			CF_SUSPEND_4				;echo BEEP
			;Handle communication errors
CF_SUSPEND_8		FEXCEPT_THROW	FEXCPT_EC_COMOF		;throw RX overflow exception
CF_SUSPEND_9		FEXCEPT_THROW	FEXCPT_EC_COMERR	;throw RX error exception
			;Process input (char count in Y)
CF_SUSPEND_10		BSET	(TIB_START-1),Y, #$80 		;terminate last character
			STY	NUMBER_TIB			;update TIB count variable
			MOVW	#$0000, TO_IN			;reset TIB index
			;Look up next word 
			LDX	TO_IN 				;string pointer -> X 
			LEAX	TIB_START,X		
			STRING_SKIP_WS 				;skip white space
			FUDICT_FIND				;parse user dictionary
			TBNE	X, CF_SUSPEND_			;word not found
			FNVDICT_FIND				;parse non-volatile dictionary
			TBNE	X, CF_SUSPEND_			;word not found
			FCDICT_FIND				;parse core dictionary
			TBNE	X, CF_SUSPEND_			;word not found
			

	


	

			LDX	#TIB_START			;set TIB pointer
CF_SUSPEND_		;STRING_SKIP_WS				;skip whitespace (SSTACK: 3 bytes)
			FUDICT_FIND				
			FNVDICT_FIND
			FCDICT_FIND
	
		


;CF_RESUME ( -- )	Execute the first execution token after the CFA (CFA in X)
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
CF_RESUME		EQU	*
			;Check if SHELL points to the bottom of the stack


			MOVW	SHELL, RSP



_




	
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
FOUTER_SUSPEND_PROMPT	FOUTER_PROMPT	"S> "
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
;Word: RESUME ( -- )
;Resume from SUSPEND 
CFA_RESUME		EQU	CF_RESUME

FOUTER_WORDS_END		EQU	*
FOUTER_WORDS_END_LIN	EQU	@
