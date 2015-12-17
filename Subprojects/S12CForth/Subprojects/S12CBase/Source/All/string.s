#ifndef STRING_COMPILED
#define STRING_COMPILED
;###############################################################################
;# S12CBase - STRING - String Printing routines                                #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
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
;#    STRING_PRINT_NB       - print a string (non-blocking)                    #
;#    STRING_PRINT_BL       - print a string (blocking)                        #
;#    STRING_FILL_NB        - print a number of filler characters (non-bl.)    #  
;#    STRING_FILL_BL        - print a number of filler characters (blocking)   #
;#    STRING_UPPER          - convert a character to upper case                #
;#    STRING_LOWER          - convert a character to lower case                #
;#    STRING_PRINTABLE      - make character printable                         #
;#    STRING_SKIP_WS        - skip whitespace characters                       #
;#    STRING_SKIP_AND_COUNT - determine the length of a string                 #
;#    STRING_RESIZE         - change the length of a string                    #
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
;#      - Added macros "STRING_UPPER_B" and "STRING_LOWER_B"                   #
;#    Jul 29, 2010                                                             #
;#      - Fixed STRING_SINTCNT                                                 #
;#    July 2, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added non-blocking functions                                         #
;#    June 10, 2013                                                            #
;#      - Turned STRING_UPPER and STRING_LOWER into subroutines                #
;#      - Added STRING_SKIP_WS                                                 #
;#    June 11, 2013                                                            #
;#      - Added STRING_LENGTH                                                  #
;#    June 11, 2013                                                            #
;#      - Added STRING_LENGTH                                                  #
;#    October 31, 2013                                                         #
;#      - Replaced STRING_LENGTH by STRING_SKIP_AND_COUNT                      #
;#    February 5, 2014                                                         #
;#      - Added #ifdef's for rarely used functions STRING_FILL_BL,             #
;#        STRING_FILL_NB, STRING_SKIP_WS, and STRING_LOWER                     #
;#    March 3, 2014                                                            #
;#      - Added macro STRING_IS_PRINTABLE                                      #
;#    February 18, 2015                                                        #
;#      - Changed configuration options                                        #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Enable Subroutines
;------------------ 
;STRING_ENABLE_FILL_NB		EQU	1	;enable STRING_FILL_NB 
;STRING_ENABLE_FILL_BL		EQU	1	;enable STRING_FILL_BL 
;STRING_ENABLE_UPPER		EQU	1	;enable STRING_UPPER 
;STRING_ENABLE_LOWER		EQU	1	;enable STRING_LOWER 
;STRING_ENABLE_PRINTABLE	EQU	1	;enable STRING_PRINTABLE
;STRING_ENABLE_SKIP_WS		EQU	1	;enable STRING_SKIP_WS

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#ASCII code 
STRING_SYM_BEEP		EQU	$07 	;acoustic signal
STRING_SYM_BACKSPACE	EQU	$08 	;backspace symbol
STRING_SYM_TAB		EQU	$09 	;tab symbol
STRING_SYM_LF		EQU	$0A 	;line feed symbol
STRING_SYM_CR		EQU	$0D 	;carriage return symbol
STRING_SYM_SPACE	EQU	$20 	;space (first printable ASCII character)
STRING_SYM_TILDE	EQU	$7E 	;"~" (last printable ASCII character)
STRING_SYM_DEL		EQU	$7F 	;delete symbol

;#String ternination 
STRING_TERM		EQU	$80 	;MSB for string termination

;#Line break
STRING_NL_1ST		EQU	STRING_SYM_CR
STRING_NL_2ND		EQU	STRING_SYM_LF
#ifndef	STRING_NL_2ND
STRING_NL		EQU	STRING_NL_1ST
STRING_NL_BYTE_COUNT	EQU	1
#else
STRING_NL		EQU	((STRING_NL_1ST<<8)|STRING_NL_2ND)
STRING_NL_BYTE_COUNT	EQU	2
#endif

;#Empty string
STRING_EMPTY		EQU	$0000
	
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
#macro	STRING_PRINT_NB, 0
			SSTACK_JOBSR	STRING_PRINT_NB, 8
#emac	

;#Basic print function - blocking
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
#macro	STRING_PRINT_BL, 0
			SSTACK_JOBSR	STRING_PRINT_BL, 10
#emac	
	
#ifdef STRING_ENABLE_FILL_NB	
;#Print a number of filler characters - non-blocking
; args:   A: number of characters to be printed
;         B: filler character
; result: A: remaining space characters to be printed (0 if successfull)
;         C-flag: set if successful	
; result: none
; SSTACK: 7 bytes
;         X, Y and B are preserved
#macro	STRING_FILL_NB, 0
			SSTACK_JOBSR	STRING_FILL_NB, 7
#emac	
#endif
	
#ifdef STRING_ENABLE_FILL_NB	
#ifdef STRING_ENABLE_FILL_BL	
;#Print a number of filler characters - blocking (uncomment if needed)
; args:   A: number of characters to be printed
;         B: filler character
; result: A: $00
; SSTACK: 9 bytes
;         X, Y and B are preserved
#macro	STRING_FILL_BL, 0
			SSTACK_JOBSR	STRING_FILL_BL, 9
#emac	
#endif
#endif
	
#ifdef STRING_ENABLE_UPPER	
;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: lower case ASCII character 
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
#macro	STRING_UPPER, 0
			SSTACK_JOBSR	STRING_UPPER, 2
#emac
#endif

#ifdef STRING_ENABLE_LOWER	
;#Convert an upper case character to lower case (uncomment if needed)
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
#macro	STRING_LOWER, 0
			SSTACK_JOBSR	STRING_LOWER, 2
#emac
#endif

;#Check if ASCII character is printable
; args:   B: ASCII character (w/out termination)
;         1: branch address if char is not printable	 
; result: none
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
#macro	STRING_IS_PRINTABLE, 1
			CMPB	#$20		;" "
			BLO	\1
			CMPB	#$7E		;"~"
			BHI	\1
#emac

#ifdef STRING_ENABLE_PRINTABLE	
;#Make ASCII character printable
; args:   B: ASCII character (w/out termination)
; result: B: printable ASCII character or "."
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
#macro	STRING_PRINTABLE, 0	
			SSTACK_JOBSR	STRING_PRINTABLE, 2
#emac
#endif

#ifdef STRING_ENABLE_SKIP_WS	
;#Skip whitespace (uncomment if needed)
; args:   X:      start of the string
; result: X;      trimmed string
; SSTACK: 3 bytes
;         Y and D are preserved 
#macro	STRING_SKIP_WS, 0	
			SSTACK_JOBSR	STRING_SKIP_WS, 3	
#emac
#endif
	
;#Skip string and count characters
; args:   X: start of the string
;         D: initial character count
; result: X: one char past the end of the string
;         D: incremented count     
; SSTACK: none
;        Y is preserved 
#macro	STRING_SKIP_AND_COUNT, 0
LOOP			ADDD	#1
			BRCLR	1,X+, #STRING_TERM, LOOP
#emac

;#Change the length of a terminated string
; args:   X: start of the string
;         D: new character count
; result: X: one char past the end of the string
;         D: zero   
; SSTACK: none
;        X and Y are preserved 
#macro	STRING_RESIZE, 0
			;Set new termination (sting pointer in X, char count in D) 
			LEAX	-1,X 			;adjust string pointer
			BSET	D,X, #STRING_TERM	;terminate string
			JOB	END_OF_LOOP		;next char
			;Remove terminations within the string (sting pointer in X, string index in D)
LOOP_START		BCLR	D,X, #STRING_TERM	;remove termination
END_OF_LOOP		DBNE	D, LOOP_START		;next char
			LEAX	1,X 			;adjust string pointer
#emac
	
;#Terminated line break
#macro	STRING_NL_TERM, 0
			DB	STRING_NL_1ST	
#ifdef	STRING_NL_2ND
			DB	(STRING_NL_2ND|STRING_TERM)	
#endif
#emac

#macro	STRING_MOVE_NL_TERM, 1
#ifndef	STRING_NL_2ND
			MOVB	#(STRING_NL|STRING_TERM), \1
#else	
			MOVW	#(STRING_NL|STRING_TERM), \1
#endif
#emac
	
;#Non-terminated line break
#macro	STRING_NL_NONTERM, 0
			DB	STRING_NL_1ST	
#ifdef	STRING_NL_2ND
			DB	STRING_NL_2ND
#endif
#emac

#macro	STRING_MOVE_NL_NONTERM, 1
#ifndef	STRING_NL_2ND
			MOVB	#STRING_NL, \1
#else	
			MOVW	#STRING_NL, \1
#endif
#emac

;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function (min. 4)
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
#macro	STRING_MAKE_BL, 2
			SCI_MAKE_BL \1, \2
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
; result: X:      remaining string (points to the byte after the string, if successful)
;         C-flag: set if successful	
; SSTACK: 8 bytes
;         Y and D are preserved
STRING_PRINT_NB		EQU	*
			;Save registers (string pointer in X)
			PSHB				;save B	
			;Print characters (string pointer in X)
STRING_PRINT_NB_1	LDAB	1,X+ 			;get next ASCII character
			BMI	STRING_PRINT_NB_3	;last character
			JOBSR	SCI_TX_NB		;print character non blocking (SSTACK: 5 bytes)
			BCS	STRING_PRINT_NB_1
			;Adjust string pointer (next string pointer in X)
STRING_PRINT_NB_2	DEX
			;Restore registers (string pointer in X)
			SSTACK_PREPULL	3
			PULB
			;Signal failure (string pointer in X)
			CLC
			;Done
			RTS
			;Print last character (next string pointer in X, last char in B)
STRING_PRINT_NB_3	ANDB	#$7F 			;remove termination bit
			JOBSR	SCI_TX_NB		;print character non blocking (SSTACK: 5 bytes)
			BCC	STRING_PRINT_NB_2
			;Restore registers (next string pointer in X)
			SSTACK_PREPULL	3
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

#ifdef	STRING_ENABLE_FILL_NB	
;#Print a number of filler characters - non-blocking (uncomment if needed)
; args:   A: number of characters to be printed
;         B: filler character
; result: A: remaining space characters to be printed (0 if successfull)
;         C-flag: set if successful	
; result: none
; SSTACK: 7 bytes
;         X, Y and B are preserved
STRING_FILL_NB		EQU	*
			;Print characters (requested spaces in A)
			TBEQ	A, STRING_FILL_NB_2	;nothing to do
STRING_FILL_NB_1	JOBSR	SCI_TX_NB		;print character non blocking (SSTACK: 5 bytes)
			BCC	STRING_FILL_NB_3	;unsuccessful
			DBNE	A, STRING_FILL_NB_1
			;Restore registers (remaining spaces in A)
STRING_FILL_NB_2	SSTACK_PREPULL	2
			;Signal success (remaining spaces in A)
			SEC
			;Done
			RTS
			;Restore registers (remaining spaces in A)
STRING_FILL_NB_3	SSTACK_PREPULL	2
			;Signal failure (remaining spaces in A)
			CLC
			;Done
			RTS
#endif
	
#ifdef	STRING_ENABLE_FILL_NB
#ifdef	STRING_ENABLE_FILL_BL
;#Print a number of filler characters - blocking (uncomment if needed)
; args:   A: number of characters to be printed
;         B: filler character
; result: A: $00
; SSTACK: 9 bytes
;         X, Y and B are preserved
STRING_FILL_BL		EQU	*
			SCI_MAKE_BL	STRING_FILL_NB, 7	
#endif
#endif

#ifdef	STRING_ENABLE_UPPER
;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; result: B: lower case ASCII character 
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
STRING_UPPER		EQU	*
			CMPB	#$61		;"a"
			BLO	STRING_UPPER_2
			CMPB	#$7A		;"z"
			BLS	STRING_UPPER_1
			CMPB	#$E1		;"a"+$80
			BLO	STRING_UPPER_2
			CMPB	#$FA		;"z"+$80
			BHI	STRING_UPPER_2
STRING_UPPER_1		SUBB	#$20		;"a"-"A"	
			;Done
			SSTACK_PREPULL	2
STRING_UPPER_2		RTS
#endif

#ifdef STRING_ENABLE_LOWER
;#Convert an upper case character to lower case (uncomment if needed)
; args:   B: ASCII character (w/ or w/out termination)
; result: B: upper case ASCII character
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
STRING_LOWER		EQU	*
			CMPB	#$41		;"A"
			BLO	STRING_LOWER_2
			CMPB	#$5A		;"Z"
			BLS	STRING_LOWER_1
			CMPB	#$C1		;"A"+$80
			BLO	STRING_LOWER_2
			CMPB	#$DA		;"Z"+$80
			BHI	STRING_LOWER_2
STRING_LOWER_1		ADDB	#$20		;"a"-"A"	
			;Done
STRING_LOWER_2		RTS
#endif 

#ifdef STRING_ENABLE_PRINTABLE	
;#Make ASCII character printable
; args:   B: ASCII character (w/out termination)
; result: B: printable ASCII character or "."
; SSTACK: 2 bytes
;         X, Y, and A are preserved 
STRING_PRINTABLE	EQU	*
			CMPB	#$20		;" "
			BLO	STRING_PRINTABLE_1
			CMPB	#$7E		;"~"
			BLS	STRING_PRINTABLE_2
STRING_PRINTABLE_1	LDAB	#$2E		;"."	
			;Done
			SSTACK_PREPULL	2
STRING_PRINTABLE_2	RTS
#endif 
	
#ifdef STRING_ENABLE_SKIP_WS
;#Skip whitespace (uncomment if needed)
; args:   X: start of the string
; result: X: trimmed string
; SSTACK: 3 bytes
;         Y and D are preserved 
STRING_SKIP_WS		EQU	*	
			;Save registers (string pointer in X)
			PSHB				;save B	
			;Skip whitespace (string pointer in X)
STRING_SKIP_WS_1	LDAB	1,X+ 			;check character
			BMI	STRING_SKIP_WS_2	;adjust pointer
			CMPB	#$20			;" "
			BLS	STRING_SKIP_WS_1  	;check next character
STRING_SKIP_WS_2	DEX	
			;Restore registers (updated string pointer in X)
			SSTACK_PREPULL	3
			PULB
			;Done
			RTS
#endif
	
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

;Common strings 
;STRING_STR_EXCLAM_NL	DB	"!" 	;exclamation mark + new line
STRING_STR_NL		STRING_NL_TERM	;new line

STRING_TABS_END		EQU	*
STRING_TABS_END_LIN	EQU	@
#endif
