;###############################################################################
;# S12CBase - PRINT - Print routines                                           #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
;#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
;#    family.                                                                  #
;#                                                                             #
;#    S12CBase is free software: you can redistribute it and/or modify         #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CBase is distributed in the hope that it will be useful,              #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #
;###############################################################################
;# Description:                                                                #
;#    This module implements various print routines for the SCI driver:        #
;#    STRING_PRINT_NB  - print a string (non-blocking)                         #
;#    STRING_PRINT_BL  - print a string (blocking)                             #
;#    STRING_SPACES_NB - print a number of spaces (non-blocking)               #
;#    STRING_SPACES_BL - print a number of spaces (blocking)                   #
;#    STRING_UPPER_B   - convert a character to upper case                     #
;#    STRING_LOWER_B   - convert a character to lower case                     #
;#                                                                             #
;#    Each of these functions has a coresponding macro definition              #
;###############################################################################
;# Required Modules:                                                           #
;#    SCI    - SCI driver                                                      #
;#    SSTACK - Subroutine Stack Handler                                        #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    Apr  4, 2010                                                             #
;#      - Initial release                                                      #
;#    Apr 29, 2010                                                             #
;#      - Added macros "STRING_UPPER_B" and "STRING_LOWER_B"                     #
;#    Jul 29, 2010                                                             #
;#      - fixed STRING_SINTCNT                                                  #
;#    July 2, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added non-blocking functions                                         #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#ASCII code 
STRING_SYM_BEEP		EQU	$07 	;acoustic signal
STRING_SYM_BACKSPACE	EQU	$08 	;backspace symbol
STRING_SYM_TAB		EQU	$09 	;tab symbol
STRING_SYM_LF		EQU	$0A 	;line feed symbol
STRING_SYM_CR		EQU	$0D 	;carriage return symbol
STRING_SYM_SPACE	EQU	$20 	;space symbol
STRING_SYM_DEL		EQU	$7F 	;delete symbol

;#String ternination 
STRING_STRING_TERM	EQU	$80 	;MSB for string termination

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef STRING_VARS_START_LIN
			ORG 	STRING_VARS_START, STRING_VARS_START_LIN
#else
			ORG 	STRING_VARS_START
#endif	

STRING_VARS_END		EQU	*
STRING_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	STRING_INIT, 0
#emac	

;#Functions	
;#Basic print function - non-blocking
; args:   X:      start of the string
; result: X;      remaining string (points to the byte after the string, if successful)
;         C-flag: set if successful	
; SSTACK: 8 bytes
;         Y and D are preserved
#macro	STRING_PRINT_NB
			SSTACK_PREPUSH	8
			JOBSR	STRING_PRINT_NB
#emac	

;#Basic print function - blocking
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
#macro	STRING_PRINT_BL
			SSTACK_PREPUSH	10
			JOBSR	STRING_PRINT_BL
#emac	

;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: lower case ASCII character 
; SSTACK: none
;         X, Y, and A are preserved 
#macro	STRING_UPPER_B, 0
	CMPB	#$61		;"a"
	BLO	DONE
	CMPB	#$7A		;"z"
	BLS	ADJUST
	CMPB	#$EA		;"a"+$80
	BLO	DONE
	CMPB	#$FA		;"z"+$80
	BHI	DONE
ADJUST	SUBB	#$20		;"a"-"A"	
DONE	EQU	*
#emac

;#Convert an upper case character to lower case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character
; SSTACK: none
;         X, Y, and B are preserved 
#macro	STRING_LOWER_B, 0
	CMPB	#$41		;"A"
	BLO	DONE
	CMPB	#$5A		;"Z"
	BLS	ADJUST
	CMPB	#$C1		;"A"+$80
	BLO	DONE
	CMPB	#$DA		;"Z"+$80
	BHI	DONE
ADJUST	ADDB	#$20		;"a"-"A"	
DONE	EQU	*
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef STRING_CODE_START_LIN
			ORG 	STRING_CODE_START, STRING_CODE_START_LIN
#else
			ORG 	STRING_CODE_START
#endif

;#Basic print function - non-blocking
; args:   X:      start of the string
; result: X;      remaining string (points to the byte after the string, if successful)
;         C-flag: set if successful	
; SSTACK: 8 bytes
;         Y and D are preserved
STRING_PRINT_NB		EQU	*
			;Save registers (string pointer in X)
			PSHB				;save B	
			;Print characters (string pointer in X)
STRING_PRINT_NB_1	LDAB	1,X+ 			;get next ASCII character
			BMI	STRING_PRINT_NB_3	;last character
			SCI_TX_NB			;print character non blocking (SSTACK: 5 bytes)
			BCS	STRING_PRINT_NB_1
			;Adjust string pointer (next string pointer in X)
STRING_PRINT_NB_2	LEAX	-1,X
			;Restore registers (string pointer in X)
			SSTACK_PREPULL	8
			PULB
			;Signal failure (string pointer in X)
			CLC
			;Done
			RTS
			;Print last character (next string pointer in X, last char in B)
STRING_PRINT_NB_3	ANDB	#$7F 			;remove termination bit
			SCI_TX_NB			;print character non blocking (SSTACK: 5 bytes)
			BCC	STRING_PRINT_NB_2
			;Restore registers (next string pointer in X)
			SSTACK_PREPULL	8
			PULB
			;Signal success (next string pointer in X)
			SEC
			;Done
			RTS

;#Basic print function - blocking
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
STRING_PRINT_BL		EQU	*
			SCI_MAKE_BL	STRING_PRINT_NB, 10
	
;#Print spaces - non-blocking
; args:   A: number of space characters to be printed
; result: A: remaining space characters to be printed (0 if successfull)
;         C-flag: set if successful	
; result: none
; SSTACK: 8 bytes
;         X, Y and B are preserved
STRING_SPACES_NB	EQU	*
			;Save registers (requested spaces in A)
			PSHB				;save B	
			;Print characters (requested spaces in A)
			LDAB	#STRING_SYM_SPACE 	;preload space character
			TBEQ	A, STRING_SPACES_NB_2	;nothing to do
STRING_SPACES_NB_1	SCI_TX_NB			;print character non blocking (SSTACK: 5 bytes)
			BCC	STRING_SPACES_NB_3	;unsuccessful
			DBNE	STRING_PRINT_NB_1
			;Restore registers (remaining spaces in A)
STRING_SPACES_NB_2	SSTACK_PREPULL	8
			PULB
			;Signal success (remaining spaces in A)
			SEC
			;Done
			RTS
			;Restore registers (remaining spaces in A)
STRING_SPACES_NB_3	SSTACK_PREPULL	8
			PULB
			;Signal failure (remaining spaces in A)
			CLC
			;Done
			RTS

;#Print spaces - blocking
; args:   A: number of space characters to be printed
; result: A: $00
; SSTACK: 10 bytes
;         Y and D are preserved
STRING_SPACES_BL	EQU	*
			SCI_MAKE_BL	STRING_SPACES_NB, 10
	
STRING_CODE_END		EQU	*	
STRING_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef STRING_TABS_START_LIN
			ORG 	STRING_TABS_START, STRING_TABS_START_LIN
#else
			ORG 	STRING_TABS_START
#endif	

STRING_TABS_END		EQU	*
STRING_TABS_END_LIN	EQU	@
