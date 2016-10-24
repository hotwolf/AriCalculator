#ifndef FDOT
#define FDOT
;###############################################################################
;# S12CForth - FDOT - Forth print routines                                     #
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
;#    GNU General Public Licens for more details.                              #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#    This module implements some basic Forth printing routines.               #
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
;#           BASE = Default radix (2<=BASE<=36)                                #
;#  									       #
;#    The following notation is used to describe the stack layout in the word  #
;#    definitions:                                                             #
;#                                                                             #
;#    Symbol          Data type                       Size on stack	       #
;#    ------          ---------                       -------------	       #
;#    flag            flag                            1 cell		       #
;#    true            true flag                       1 cell		       #
;#    false           false flag                      1 cell		       #
;#    char            character                       1 cell		       #
;#    n               signed number                   1 cell		       #
;#    +n              non-negative number             1 cell		       #
;#    u               unsigned number                 1 cell		       #
;#    n|u 1           number                          1 cell		       #
;#    x               unspecified cell                1 cell		       #
;#    xt              execution token                 1 cell		       #
;#    addr            address                         1 cell		       #
;#    a-addr          aligned address                 1 cell		       #
;#    c-addr          character-aligned address       1 cell		       #
;#    d-addr          double address                  2 cells (non-standard)   #
;#    d               double-cell signed number       2 cells		       #
;#    +d              double-cell non-negative number 2 cells		       #
;#    ud              double-cell unsigned number     2 cells		       #
;#    d|ud 2          double-cell number              2 cells		       #
;#    xd              unspecified cell pair           2 cells		       #
;#    colon-sys       definition compilation          implementation dependent #
;#    do-sys          do-loop structures              implementation dependent #
;#    case-sys        CASE structures                 implementation dependent #
;#    of-sys          OF structures                   implementation dependent #
;#    orig            control-flow origins            implementation dependent #
;#    dest            control-flow destinations       implementation dependent #
;#    loop-sys        loop-control parameters         implementation dependent #
;#    nest-sys        definition calls                implementation dependent #
;#    i*x, j*x, k*x 3 any data type                   0 or more cells	       #
;#  									       #
;#    Counted strings are implemented as terminated strings. String            #
;#    termination is done by setting bit 7 in the last character of the        #   
;#    string. Pointers to empty strings have the value $0000.		       #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    February 3, 2011                                                         #
;#      - Initial release                                                      #
;#    October 17, 2016                                                         #
;#      - Started subroutine threaded implementation and renamed module to     #
;#  	  FDOT								       #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FRS    - Forth return stack                                              #
;#    FPS    - Forth parameter stack                                           #
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
;#ASCII code 
FDOT_SYM_SPACE		EQU	STRING_SYM_SPACE

;#Line break
FDOT_STR_NL		EQU	STRING_STR_NL
FDOT_NL_BYTE_COUNT	EQU	STRING_NL_BYTE_COUNT

;#String termination 
FDOT_TERM		EQU	STRING_TERM
	
;ASCII C0 codes 
FDOT_SYM_LF  		EQU	STRING_SYM_LF
FDOT_SYM_CR  		EQU	STRING_SYM_CR
FDOT_SYM_BACKSPACE  	EQU	STRING_SYM_BACKSPACE
FDOT_SYM_DEL  		EQU	STRING_SYM_DEL
FDOT_SYM_TAB  		EQU	STRING_SYM_TAB
FDOT_SYM_BEEP  		EQU	STRING_SYM_BEEP
FDOT_SYM_SPACE  	EQU	STRING_SYM_SPACE
	
;#Empty string 
FDOT_EMPTY_STRING	EQU	STRING_TERM
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FDOT_VARS_START_LIN
			ORG 	FDOT_VARS_START, FDOT_VARS_START_LIN
#else
			ORG 	FDOT_VARS_START
FDOT_VARS_START_LIN	EQU	@
#endif

FDOT_VARS_END		EQU	*
FDOT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FDOT_INIT, 0
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FDOT_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FDOT_QUIT, 0
#emac
	
;#System integrity monitor
;=========================
#macro	FDOT_MON, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FDOT_CODE_START_LIN
			ORG 	FDOT_CODE_START, FDOT_CODE_START_LIN
#else
			ORG 	FDOT_CODE_START
FDOT_CODE_START_LIN	EQU	@
#endif

;#IO
;===
;#Transmit one char
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FDOT_TX_CHAR		EQU	SCI_TX_BL

;#Prints a MSB terminated string
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FDOT_TX_STRING		EQU	STRING_PRINT_BL

;#########
;# Words #
;#########
;Word: . ( n --  )
;Display n in free field format.
IF_DOT			REGULAR
CF_DOT			EQU	*
			;Set zero char left alignment
			MOVW	#$0000, 2,-Y 		;n2=0 -> PS
			JOB	CF_DOT_R		;use.R

;Word: .R ( n1 n2 --  )
;Display n1 right aligned in a field n2 characters wide.  If the number of
;characters required to display n1 is greater than n2, all digits are displayed
;with no leading spaces in a field as wide as necessary.
IF_DOT_R		REGULAR 
CF_DOT_R		EQU	* 
			;Sign extend u
			MOVW	0,Y, 2,-Y 		;duplicate n
			LDAB	4,Y			;sign extend
			SEX	B, D			; n1
			TAB				;
			STD	2,Y			;n1 -> d
			JOB	CF_D_DOT_R		;use D.R

;Word: U. ( u --  )
;Display u in free field format.
IF_U_DOT		REGULAR
CF_U_DOT		EQU	*
			;Set zero char left alignment
			MOVW	#$0000, 2,-Y 		;n=0 -> PS
			JOB	CF_U_DOT_R		;use U.R

;Word: U.R ( u n -- )
;Display u right aligned in a field n characters wide. If the number of
;characters required to display u is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
IF_U_DOT_R		REGULAR 
CF_U_DOT_R		EQU	* 
			;Zero extend u
			MOVW	0,Y, 2,-Y 		;duplicate n
			MOVW	#$0000, 2,Y		;zero extend u
			JOB	CF_D_DOT_R		;use D.R
	
;Word: D. ( d --  )
;Display d in free field format. 
IF_D_DOT		REGULAR
CF_D_DOT		EQU	*
			;Set zero char left alignment
			MOVW	#$0000, 2,-Y 		;n=0 -> PS
			JOB	CF_D_DOT_R		;use D.R

;Word: D.R ( d n --  )
;Display d right aligned in a field n characters wide. If the number of
;characters required to display d is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
IF_D_DOT_R		REGULAR 
CF_D_DOT_R		EQU	*
			;Get BASE ( d n )
			JOBSR	FOUTER_GET_BASE 	;BASE -> B
			;Get number ( d n )
			LDX	4,Y 			;LSW -> X
			PSHY				;save PSP
			SEI				;start atomic sequence
			LDY	2,Y 			;MSW -> Y
			BPL	CF_D_DOT_R_1		;number is positive
			;Revert negative number (number im Y:X, BASE in B) 
			NUM_NEGATE 			;negate Y:X
			JOBSR	NUM_REVERSE		;build reverse number
			LDY	6,SP			;restore PSP
			CLI				;end of atomic sequence
			INCA				;increment char count
			NEGA				;negate char count
			SEX	A,D			;sign-extend char count
			ADDD	0,Y			;n - char count -> D
			STD	0,Y			;update n
			JOBSR	CF_SPACES		;print left alignment
			LDAB	#"-"			;print minus sign 
			MOVW	#CF_D_DOT_R_2, 2,-SP	;push return address (CF_D_DOT_R_2)
			JOB	FDOT_TX_CHAR		;print  minus sign
			;Revert positive number (number im Y:X, BASE in B)
CF_D_DOT_R_1		JOBSR	NUM_REVERSE		;build reverse number
			LDY	6,SP			;restore PSP
			CLI				;end of atomic sequence
			TFR	D, X			;save BASE in X
			NEGA				;negate char count
			SEX	A,D			;sign-extend char count
			ADDD	0,Y			;n - char count -> D
			STD	0,Y			;update n
			JOBSR	CF_SPACES		;print left alignment
			;Print reverted number (char count:BASE in X)
CF_D_DOT_R_2		JOBSR	FOUTER_GET_BASE 	;BASE -> B
			JOBSR	NUM_REVPRINT_BL		;print number
			LEAS	2,SP			;clean up RS
			LEAY	4,Y			;clean up PS
			JOB	CF_SPACE		;print one more space
			
;Word: SPACES ( n -- )
;If n is greater than zero, display n spaces.
IF_SPACES		REGULAR
CF_SPACES		EQU	*
			LDX	2,Y+ 			;pick up argument
			BLE	CF_SPACES_2		;skip if n <= 0
CF_SPACES_1		JOBSR	CF_SPACE		;print SPACE
			DBNE	X, CF_SPACES_1		;loop
CF_SPACES_2		RTS				;done

FDOT_CODE_END		EQU	*
FDOT_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FDOT_TABS_START_LIN
			ORG 	FDOT_TABS_START, FDOT_TABS_START_LIN
#else
			ORG 	FDOT_TABS_START
FDOT_TABS_START_LIN	EQU	@
#endif	

;Symbol table
FDOT_SYMTAB		EQU	NUM_SYMTAB
	
;Line break
FDOT_STR_NL		EQU	STRING_STR_NL
	
FDOT_TABS_END		EQU	*
FDOT_TABS_END_LIN	EQU	@
#endif
