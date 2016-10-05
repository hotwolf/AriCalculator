#ifndef FTIB_COMPILED
#define FTIB_COMPILED
;###############################################################################
;# S12CForth - FTIB - Text Input Buffer                                        #
;###############################################################################
;#    Copyright 2011-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12C MCU          #
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
;#    This module implements the text input buffer of the S12CForth            #
;#    environment.                                                             #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    S12CForth system variables:                                              #
;#     NUMBER_TIB = Number of chars in the TIB                                 #
;#          TO_IN = In-pointer of the TIB (>IN)	       			       #
;#       	    (TIB_START+TO_IN) points to the next character	       #
;#  									       #
;#    Program termination options:                                             #
;#      ABORT:                                                                 #
;#      QUIT:                                                                  #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    September 30, 2016                                                       #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FRS    - Forth return stack                                              #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
        
;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;                                
;                         +----------+----------+        
;        RS_TIB_START, -> |          |          | |
;           TIB_START     |  Text Input Buffer  | | [NUMBER_TIB]
;                         |          |          | |	       
;                         |          v          | <	       
;                     -+- | --- --- --- --- --- | 	       
;             TIB_PADDING .                     . <- TIB_START+[NUMBER_TIB] 
;                     -+- .                     .            
;                         | --- --- --- --- --- |            
;                         |          ^          | <- [RSP]
;                         |          |          |
;                         |    Return Stack     |
;                         |          |          |
;                         +----------+----------+
;             RS_EMPTY, ->                                 
;           RS_TIB_END
;
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Line break handling:
#ifndef FTIB_NL_LF
#ifndef FTIB_NL_CR
FTIB_NL_LF		EQU	1 			;interpret LF as line break, ignore CR
#endif
#endif
	
;#TAB width
#ifndef FTIB_TAB_WIDTH
FTIB_TAB_WIDTH		EQU	5 			;default is 5 characters
#endif

;#Padding between RS and TIB
#ifndef TIB_PADDING
TIB_PADDING		EQU	10 			;default is 10 bytes
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Mapping
TIB_START		EQU	RS_TIB_START 		;start of TIB

;#ASCII code 
FTIB_SYM_EOT		EQU	STRING_SYM_EOT	 	;EOT (ctrl-D)
FTIB_SYM_BEEP		EQU	STRING_SYM_BEEP		;acoustic signal
FTIB_SYM_BACKSPACE	EQU	STRING_SYM_BACKSPACE	;backspace symbol
FTIB_SYM_TAB		EQU	STRING_SYM_TAB		;tab symbol
FTIB_SYM_LF		EQU	STRING_SYM_LF		;line feed symbol
FTIB_SYM_CR		EQU	STRING_SYM_CR		;carriage return symbol
FTIB_SYM_SPACE		EQU	STRING_SYM_SPACE	;space (first printable ASCII character)
FTIB_SYM_TILDE		EQU	STRING_SYM_TILDE	;"~" (last printable ASCII character)
FTIB_SYM_DEL		EQU	STRING_SYM_DEL		;delete symbol

;#Status flags
FTIB_FLG_ERR		EQU	SCI_FLG_SWOR|OR|NF|FE|PF;SCI error flags
FTIB_FLG_CTRL		EQU	SCI_FLG_CTRL		;unescaped control char
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FTIB_VARS_START_LIN
			ORG 	FTIB_VARS_START, FTIB_VARS_START_LIN
#else
			ORG 	FTIB_VARS_START
FTIB_VARS_START_LIN	
#endif
			ALIGN	1	
NUMBER_TIB  		DS	2		;number of chars in the TIB
TO_IN  			DS	2		;parse index (parse area empty if >IN = #TIB) 
	
FTIB_VARS_END		EQU	*
FTIB_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FTIB_INIT, 0
#emac

;#Abort action (executed along with QUIT action)
;=============
#macro	FTIB_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FTIB_QUIT, 0
			MOVW	#$0000, NUMBER_TIB	;empty TIB
			MOVW	#$0000, TO_IN		;reset parser
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FTIB_CODE_START_LIN
			ORG 	FTIB_CODE_START, FTIB_CODE_START_LIN
#else
			ORG 	FTIB_CODE_START
FTIB_CODE_START_LIN	EQU	@
#endif

;#IO
;===
;#Receive one char
; args:   none
; result: A: error flags
;         B: received data
; SSTACK: 7 bytes
;         X and Y are preserved
FTIB_RX_CHAR		EQU	SCI_RX_BL

;#Transmit one char
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FTIB_TX_CHAR		EQU	SCI_TX_BL

;#########
;# Words #
;#########
	
;Word: QUERY ( -- ) Query command line input
;Make the user input device the input source. Receive input into the terminal
;input buffer,mreplacing any previous contents. Make the result, whose address is
;returned by TIB, the input buffer.  Set >IN to zero.
IF_QUERY		DB	0
CF_QUERY		EQU	*
			;Allocate temporary #TIB pointers 
			MOVW	NUMBER_TIB, 2,-SP 	;old #TIB -> SP+0
			LDX	#$0000		 	;new #TIB -> X
			;Wait for input
CF_QUERY_1		JOBSR	FTIB_RX_CHAR 		;flags:char -> A:B
			;Check for communication errors (flags:char in A:B, new #TIB in X)
			BITA	#FTIB_FLG_ERR 		;check for error flags	
			BEQ	CF_QUERY_4 		;no error
CF_QUERY_2		LDAB	#FTIB_SYM_BEEP		;beep symbol -> B
CF_QUERY_3		MOVW	#CF_QUERY_1, 2,-SP	;push return address onto stack
			JOB	FTIB_TX_CHAR		;print char
			;Check for printable ASCII code (flags:char in A:B, new #TIB in X)
CF_QUERY_4		BITA	#FTIB_FLG_CTRL 		;check for control chars
			BNE	CF_QUERY_6		;handle control chars
			CMPB	#FTIB_SYM_SPACE		;check lower range of printable chars
			BLO	CF_QUERY_2		;out of range (beep)
			CMPB	#FTIB_SYM_DEL		;check upper range of printable chars
			BEQ	CF_QUERY_2		;out of range (beep)
			;Append char to TIB (char in B, new #TIB in X)
			CPX	0,SP 			;check if old TIB content is overwritten
			BHS	CF_QUERY_5		;old TIB is still intact (char is only appended)
			MOVW	#$0000,     0,SP 	;clear old #TIB	
CF_QUERY_5		STS	2,-SP			;temporarily push SP onto the stack
			LEAX	(TIB_START+TIB_PADDING+8),X;TIB+padding -> X
			CPX	2,SP+			;check boundary
			LEAX	-(TIB_START+TIB_PADDING+8),X;new #TIB -> X
			BHS	CF_QUERY_2		;TIB overflow (beep)
			INX				;increment #TIB
			STX	NUMBER_TIB		;update #TIB
			STAB	(TIB_START-1),X		;append char
			JOB	CF_QUERY_3		;print char
			;Handle DEL (new #TIB in X)
CF_QUERY_6		CMPB	#FTIB_SYM_DEL		;check for DEL char
			BNE	CF_QUERY_9		;no DEL char
			TBEQ	X, CF_QUERY_2 		;no input (beep)
CF_QUERY_7		LDAB	#FTIB_SYM_BACKSPACE	;backspace char -> B
CF_QUERY_8		JOBSR	FTIB_TX_CHAR		;send backspace to terminal
			DBNE	X, CF_QUERY_8		;repeat until input line is empty
			MOVW	0,SP, NUMBER_TIB	;update #TIB
			JOB	CF_QUERY_1		;wait new input
			;Handle BACKSPACE (char in B, new #TIB in X)
CF_QUERY_9		CMPB	#FTIB_SYM_BACKSPACE 	;check for BACKSPACE char
			BNE	CF_QUERY_10		;no BACKSPACE
			TBEQ	X, CF_QUERY_2 		;no input (beep)
			DEX				;decrement #TIB
			CPX	0,SP			;check if old TIB content is affected
			BLE	CF_QUERY_3		;transmit BACKSPACE char
			STX	NUMBER_TIB		;update #TIB
			JOB	CF_QUERY_3		;transmit BACKSPACE char
			;Handle TAB (char in B, new #TIB in X)
CF_QUERY_10		CMPB	#FTIB_SYM_TAB	 	;check for TAB char
			BNE	CF_QUERY_13		;no TAB			
			CPX	0,SP 			;check if old TIB content is overwritten
			BHS	CF_QUERY_11		;old TIB is still intact (char is only appended)
			MOVW	#$0000,     0,SP 	;clear old #TIB	
CF_QUERY_11		PSHX				;save new #TIB
			TFR	X, D			;new #TIB -> D
			LDX	#FTIB_TAB_WIDTH		;tab width -> X
			IDIV				;X/D->X, X%D->D
			PULX				;restore #TIB
			LDAA	#FTIB_TAB_WIDTH		;tab width -> A
			SBA				;A - B -> A
			LDAB	#FTIB_SYM_SPACE		;SPACE char -> B
CF_QUERY_12		STS	2,-SP			;temporarily push SP onto the stack
			LEAX	(TIB_START+TIB_PADDING+8),X;TIB+padding -> X
			CPX	2,SP+			;check boundary
			LEAX	-(TIB_START+TIB_PADDING+8),X;new #TIB -> X
			BHS	CF_QUERY_2		;TIB overflow (beep)
			INX				;increment #TIB
			STX	NUMBER_TIB		;update #TIB
			STAB	(TIB_START-1),X		;append char
			JOBSR	FTIB_TX_CHAR		;print SPACE char
			DBNE	A, CF_QUERY_12		;try to print next SPACE char
			JOB	CF_QUERY_1		;wait new input
			;Handle restore (char in B, new #TIB in X)
CF_QUERY_13		CMPB	#FTIB_SYM_EOT	 	;check for EOT char
			BNE	CF_QUERY_17		;no resore			
			LDD	0,SP			;check if last input is still valid
			BEQ	CF_QUERY_2		;last input is invalid (beep)
			TFR	X, D			;new #TIB -> D
			SUBD	0,SP			;new #TIB - old #TIB -> D
			BEQ	CF_QUERY_7		;input line already restored -> remove it
			BMI	CF_QUERY_16		;restore missing chars
			TFR	D, X			;new #TIB - old #TIB -> X
			LDAB	#FTIB_SYM_BACKSPACE	;BACKSPACE char -> B
CF_QUERY_14		JOBSR	FTIB_TX_CHAR		;print BACKSPACE char
			DBNE	X, CF_QUERY_14		;try to print next SPACE char
CF_QUERY_15		LDX	0,SP			;new TIB = old TIB
			JOB	CF_QUERY_1		;wait new input
CF_QUERY_16		LDAB	TIB_START,X		;next char -> B
			JOBSR	FTIB_TX_CHAR		;print char
			INX				;advance new #TIB
			CPX	0,SP			;compate new #TIB against old #TIB
			BLO	CF_QUERY_16		;repeat until input line is restored
			JOB	CF_QUERY_15		;command line has been restored
			;Check for line breaks (char in B, new #TIB in X)			
CF_QUERY_17		CMPB	#FTIB_SYM_CR
#ifdef	FOUTER_NL_CR
			BEQ	CF_QUERY_18		;command line complete		
#else
			BEQ	CF_QUERY_1		;ignore
#endif
			CMPB	#FTIB_SYM_LF	
#ifdef	FOUTER_NL_LF
			BEQ	CF_QUERY_18		;command line complete		
#else
			BEQ	CF_QUERY_1		;ignore
#endif
			JOB	CF_QUERY_2		;invalid char (beep)
			;Command line complete (new #TIB in X)
CF_QUERY_18		STX	NUMBER_TIB 		;update #TIB
			LEAS	2,SP			;stack space
			RTS				;done

FTIB_CODE_END		EQU	*
FTIB_CODE_END_LIN	EQU	@

	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FTIB_TABS_START_LIN
			ORG 	FTIB_TABS_START, FTIB_TABS_START_LIN
#else
			ORG 	FTIB_TABS_START
FTIB_TABS_START_LIN	EQU	@
#endif	
	
FTIB_TABS_END		EQU	*
FTIB_TABS_END_LIN	EQU	@
