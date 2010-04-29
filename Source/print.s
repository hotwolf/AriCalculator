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
;#    PRINT_STR        - print an unformated   string                          #
;#    PRINT_LSTR       - print a left aligned  string                          #
;#    PRINT_RSTR       - print a right aligned string                          #
;#    PRINT_UINT       - print an unformated   unsigned integer value          #
;#    PRINT_LUINT      - print a left aligned  unsigned integer value          #
;#    PRINT_RUINT      - print a right aligned unsigned integer value          #
;#    PRINT_SINT       - print an unformated   signed   integer value          #
;#    PRINT_LSINT      - print a left aligned  signed   integer value          #
;#    PRINT_RSINT      - print a right aligned signed   integer value          #
;#    PRINT_UDBL       - print an unformated   unsigned double  value          #
;#    PRINT_LUDBL      - print a left aligned  unsigned double  value          #
;#    PRINT_RUDBL      - print a right aligned unsigned double  value          #
;#    PRINT_SDBL       - print an unformated   signed   double  value          #
;#    PRINT_LSDBL      - print a left aligned  signed   double  value          #
;#    PRINT_RSDBL      - print a right aligned signed   double  value          #
;#    PRINT_STRCNT     - count the characters of a string                      #
;#    PRINT_UINTCNT    - count the digits of an unsigned integer value         #
;#    PRINT_SINTCNT    - count the digits of a  signed   integer value         #
;#    PRINT_UDBLCNT    - count the digits of an unsigned double  value         #
;#    PRINT_SDBLCNT    - count the digits of a  signed   double  value         #
;#    PRINT_LINE_BREAK - prints the line break sequence                        #
;#    PRINT_SPCS       - prints a number of space characters                   #
;#    PRINT_SPC        - prints a space character                              #
;#    PRINT_BEEP       - sends a beep                                          #
;#    PRINT_BYTE       - prints a 2-digit hexadecimal number                   #
;#    PRINT_WORD       - prints a 4-digit hexadecimal number                   #
;#    PRINT_BITS       - prints a 8-digit binary number                        #
;#    PRINT_CHAR       - prints a ASCII character                              #
;#    PRINT_UPPER_B    - converts an ASCII character to upper case             #
;#    PRINT_LOWER_B    - converts an ASCII character to lower case             #
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
;#      - Added macros "PRINT_UPPER_B" and "PRINT_LOWER_B"                     #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#ASCII code 
PRINT_SYM_BEEP		EQU	$07 	;acoustic signal
PRINT_SYM_BACKSPACE	EQU	$08 	;backspace symbol
PRINT_SYM_TAB		EQU	$09 	;tab symbol
PRINT_SYM_LF		EQU	$0A 	;line feed symbol
PRINT_SYM_CR		EQU	$0D 	;carriage return symbol
PRINT_SYM_SPACE		EQU	$20 	;space symbol
PRINT_SYM_DEL		EQU	$7F 	;delete symbol

;#String ternination 
PRINT_STRING_TERM	EQU	$80 	;MSB for string termination
	
;Valid number base
PRINT_BASE_MIN	EQU	2		;binary
PRINT_BASE_MAX	EQU	PRINT_SYMTAB_END-PRINT_SYMTAB	;max base value determined by symbol table
PRINT_BASE_DEF	EQU	10		;default base (decimal)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	PRINT_VARS_START
PRINT_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	PRINT_INIT, 0
#emac	

;#Print a signed integer value
; args:   X: signed integer value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_SINT 0
	SSTACK_JOBSR	PRINT_SINT
#emac	

;#Print a left aligned signed integer value
; args:   X: signed integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_LSINT, 0
	SSTACK_JOBSR	PRINT_LSINT
#emac	

;#Print an unsigned integer value
; args:   X: unsigned integer value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_UINT, 0
	SSTACK_JOBSR	PRINT_UINT
#emac	

;#Print a left aligned unsigned integer value
; args:   X: unsigned integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_LUINT, 0
	SSTACK_JOBSR	PRINT_LUINT
#emac	

;#Print a signed double value
; args: Y:X: signed double value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_SDBL, 0
	SSTACK_JOBSR	PRINT_SDBL
#emac	

;#Print a left aligned signed double value
; args: Y:X: signed double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_LSDBL, 0
	SSTACK_JOBSR	PRINT_LSDBL
#emac	

;#Print an unsigned double value
; args: Y:X: unsigned double value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_UDBL, 0
	SSTACK_JOBSR	PRINT_UDBL
#emac	

;#Fix base value
; args:   B: base
; result: B: fixed base (2<=base<=16)
; SSTACK: 2 bytes
;         X, Y and A are preserved
#macro	PRINT_FIX_BASE, 0
	SSTACK_JOBSR	PRINT_FIX_BASE
#emac	

;#Print a left aligned unsigned double value
; args: Y:X: unsigned double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_LUDBL, 0
	SSTACK_JOBSR	PRINT_LUDBL
#emac	

;#Print a right aligned unsigned double value
; args: Y:X: unsigned double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_RUDBL, 0
	SSTACK_JOBSR	PRINT_RUDBL
#emac	

;#Print a right aligned signed double value
; args: Y:X: signed double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_RSDBL, 0
	SSTACK_JOBSR	PRINT_RSDBL
#emac	

;#Print a right aligned unsigned integer value
; args:   X: unsigned integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_RUINT, 0
	SSTACK_JOBSR	PRINT_RUINT
#emac	

;#Print a right aligned signed integer value
; args:   X: signed integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
#macro	PRINT_RSINT, 0
	SSTACK_JOBSR	PRINT_RSINT
#emac	

;#Count digits of an unsigned double value
; args:   Y:X: unsigned double value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
#macro	PRINT_UDBLCNT, 0
	SSTACK_JOBSR	PRINT_UDBLCNT
#emac	

;#Count digits of a signed double value
; args:   Y:X: signed double value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
#macro	PRINT_SDBLCNT, 0
	SSTACK_JOBSR	PRINT_SDBLCNT
#emac	

;#Count digits of an unsigned integer value
; args:   X: unsigned integer value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
#macro	PRINT_UINTCNT, 0
	SSTACK_JOBSR	PRINT_UINTCNT
#emac	

;#Count digits of a signed double value
; args:   X: signed double value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
#macro	PRINT_SINTCNT, 0
	SSTACK_JOBSR	PRINT_SINTCNT
#emac	

;#Print spaces
; args:   A: character count
; SSTACK: 12 bytes
;         X, Y and D are preserved
#macro	PRINT_SPCS, 0
	SSTACK_JOBSR	PRINT_SPCS
#emac	

;#Print space
; args:   none
; SSTACK: 12 bytes
;         X, Y and D are preserved
#macro	PRINT_SPC, 0
	SSTACK_JOBSR	PRINT_SPC
#emac	

;#Count characters of a string
; args:   X: start of the string
; result: A: character count (saturated at 255)
; SSTACK: 2 bytes
;         X, Y and B are preserved
#macro	PRINT_STRCNT, 0
	SSTACK_JOBSR	PRINT_STRCNT
#emac
	
;#Print a right aligned string to the SCI
; args:   X: start of the string
;         A: minimum lenght of the output
; SSTACK: 18 bytes
;         X, Y and D are preserved
#macro	PRINT_RSTR, 0
	SSTACK_JOBSR	PRINT_RSTR
#emac	

;#Print a left aligned string to the SCI
; args:   X: start of the string
;         A: minimum lenght of the output
; SSTACK: 14 bytes
;         X, Y and D are preserved
#macro	PRINT_LSTR, 0
	SSTACK_JOBSR	PRINT_LSTR
#emac	

;#Print a string to the SCI (without alignment)
; args:   X: start of the string
; SSTACK: 14 bytes
;         X, Y and D are preserved
#macro	PRINT_STR, 0
	SSTACK_JOBSR	PRINT_STR
#emac	

;#Print a line break to the SCI
; args:   none
; SSTACK: 11 bytes
;         X, Y and D are preserved
#macro	PRINT_LINE_BREAK, 0
	SSTACK_JOBSR	PRINT_LINE_BREAK
#emac	

;#Send a beep to the SCI
; args:   none
; SSTACK: 11 bytes
;         X, Y and D are preserved
#macro	PRINT_BEEP, 0
	SSTACK_JOBSR	PRINT_BEEP
#emac	

;#Print an 8-bit value to the SCI
; args:   B: 8-bit value
; SSTACK: 14 bytes
;         X, Y and D are preserved
#macro	PRINT_BYTE, 0
	SSTACK_JOBSR	PRINT_BYTE
#emac	

;#Print a 16-bit value to the SCI
; args:   D: 16-bit value
; SSTACK: 16 bytes
;         X, Y and D are preserved
#macro	PRINT_WORD, 0
	SSTACK_JOBSR	PRINT_WORD
#emac	

;#Print a unsigned integer value to the SCI
; args:   B: bit field
; SSTACK: 14 bytes
;         X, Y and D are preserved
#macro	PRINT_BITS, 0
	SSTACK_JOBSR	PRINT_BITS
#emac	

;#Transmit one byte (convinience macro to call the SCI_TX subroutine)
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
#macro	PRINT_CHAR, 0
		SCI_TX
#emac

;#Convert a lower case character to upper case
; args:   B: ASCII character (w/ or w/out termination)
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
#macro	PRINT_UPPER_B, 0
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
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
#macro	PRINT_LOWER_B, 0
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
			ORG	PRINT_CODE_START

;#Print a signed integer value
; args:   X: signed integer value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_SINT		EQU	*
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print left aligned unsigned double value
PRINT_SINT_1		CLRA
			JOB	PRINT_SINT_2
	
PRINT_SINT_2		EQU	PRINT_LSINT_1

;#Print a left aligned signed integer value
; args:   X: signed integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_LSINT		EQU	*
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Check if number is negative
PRINT_LSINT_1		CPX	#$0000
			BPL	PRINT_LSINT_3 		;number is positive

			;Number is negative
			;Decrement count
			SUBA	#1
			BCC	PRINT_LSINT_2
			CLRA
				
			;Print minus symbol
PRINT_LSINT_2		TFR	D, Y
			LDAB	#"-"
			SCI_TX				;print character (SSTACK: 8 bytes)
			;Negate number (cnt:base in Y)
			TFR	X, D
			COMA
			COMB
			ADDD	#1
			TFR	D, X

			;Print number (cnt:base in Y)
			TFR	Y, D
			JOB	PRINT_LSINT_3
	
PRINT_LSINT_3		EQU	PRINT_LUINT_1

;#Print an unsigned integer value
; args:   X: unsigned integer value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_UINT		EQU	*
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print left aligned unsigned double value
PRINT_UINT_1		CLRA
			JOB	PRINT_UINT_2
	
PRINT_UINT_2		EQU	PRINT_LUINT_1
	
;#Print a left aligned unsigned integer value
; args:   X: unsigned integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_LUINT		EQU	*
PRINT_LUINT_FTMP3	EQU	$0
PRINT_LUINT_FTMP2	EQU	$1
PRINT_LUINT_FTMP1	EQU	$2
PRINT_LUINT_FTMP0	EQU	$3
PRINT_LUINT_RTMP5	EQU	$4
PRINT_LUINT_RTMP4	EQU	$5
PRINT_LUINT_RTMP3	EQU	$6
PRINT_LUINT_RTMP2	EQU	$7
PRINT_LUINT_RTMP1	EQU	$8
PRINT_LUINT_RTMP0	EQU	$9
PRINT_LUINT_CNT		EQU	$A
PRINT_LUINT_BASE	EQU	$B
PRINT_LUINT_A		EQU	$C
PRINT_LUINT_B		EQU	$D
PRINT_LUINT_X		EQU	$E
PRINT_LUINT_Y		EQU	$10

			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Fix base
PRINT_LUINT_1		SSTACK_JOBSR	PRINT_FIX_BASE	;adjust base value (SSTACK: 2 bytes)

			;Allocate and initialize local variables
			SSTACK_ALLOC,12			;allocate local variables
			LDY	SSTACK_SP 		;use Y as stack pointer
			STD	PRINT_LUINT_CNT,Y
			STX	PRINT_LUINT_FTMP1,Y
			MOVW	#$0000, PRINT_LUINT_FTMP3,Y
			MOVW	#$0000, PRINT_LUINT_RTMP5,Y
			MOVW	#$0000, PRINT_LUINT_RTMP3,Y
			CLR	PRINT_LUINT_RTMP1,Y
			STAB	PRINT_LUINT_RTMP0,Y

			JOB	PRINT_LUINT_2 		;jump to division loop
	
PRINT_LUINT_2		EQU	PRINT_LUDBL_2
	
;#Print a signed double value
; args: Y:X: signed double value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_SDBL		EQU	*
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print left aligned signed double value
PRINT_SDBL_1		CLRA
			JOB	PRINT_SDBL_2

PRINT_SDBL_2		EQU	PRINT_LSDBL_1
	
;#Print a left aligned signed double value
; args: Y:X: signed double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_LSDBL		EQU	*
PRINT_LSDBL_FTMP3	EQU	$0
PRINT_LSDBL_FTMP2	EQU	$1
PRINT_LSDBL_FTMP1	EQU	$2
PRINT_LSDBL_FTMP0	EQU	$3
PRINT_LSDBL_RTMP5	EQU	$4
PRINT_LSDBL_RTMP4	EQU	$5
PRINT_LSDBL_RTMP3	EQU	$6
PRINT_LSDBL_RTMP2	EQU	$7
PRINT_LSDBL_RTMP1	EQU	$8
PRINT_LSDBL_RTMP0	EQU	$9
PRINT_LSDBL_CNT		EQU	$A
PRINT_LSDBL_BASE	EQU	$B
PRINT_LSDBL_A		EQU	$C
PRINT_LSDBL_B		EQU	$D
PRINT_LSDBL_X		EQU	$E
PRINT_LSDBL_Y		EQU	$10
	
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D
	
			;Check if number is negative 
PRINT_LSDBL_1		CPY	#$0000
			BPL	PRINT_LSDBL_3 		;number is positive

			;Number is negative 
			;Print minus
			LDAB	#"-"
			SCI_TX				;print character (SSTACK: 8 bytes)
	
			;Allocate local variables
			SSTACK_ALLOC,12			;allocate local variables
			LDY	SSTACK_SP 		;use Y as stack pointer

			;Fix base
			LDAB	PRINT_LSDBL_B,Y
			SSTACK_JOBSR	PRINT_FIX_BASE	;adjust base value (SSTACK: 2 bytes)

			;Initialize count and base
			SUBA	#1				;decrement CNT (and saturate at 0)
			BCC	PRINT_LSDBL_2
			CLRA
PRINT_LSDBL_2		STD	PRINT_LSDBL_CNT,Y

			;Initialize reverse temp register
			MOVW	#$0000, PRINT_LSDBL_RTMP5,Y
			MOVW	#$0000, PRINT_LSDBL_RTMP3,Y
			CLR	PRINT_LSDBL_RTMP1,Y
			STAB	PRINT_LSDBL_RTMP0,Y
			
			;Initialize forward temp register
			LDD	PRINT_LSDBL_Y,Y		;negate Y:X
			COMA
			COMB
			EXG	D, X
			COMA
			COMB
			ADDD	#1
			EXG	D, X
			ADCB	#$00
			ADCA	#$00
			STD	PRINT_LSDBL_FTMP3,Y
			STX	PRINT_LSDBL_FTMP1,Y
			

			JOB	PRINT_LSDBL_4 		;jump to LUDBL division loop

PRINT_LSDBL_3		EQU	PRINT_LUDBL_1
PRINT_LSDBL_4		EQU	PRINT_LUDBL_2
	
;#Print an unsigned double value
; args: Y:X: unsigned double value
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_UDBL		EQU	*
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print left aligned unsigned double value
PRINT_UDBL_1		CLRA
			JOB	PRINT_UDBL_2
	
PRINT_UDBL_2		EQU	PRINT_LUDBL_1

;#Fix base value
; args:   B: base
; result: B: fixed base (2<=base<=16)
; SSTACK: 2 bytes
;         X, Y and A are preserved
PRINT_FIX_BASE		EQU	*
			CMPB	#PRINT_BASE_MIN		;base must be at least 2 (binary)
			BHS	PRINT_FIX_BASE_1	;base is at least 2 (binary)
			LDAB	#PRINT_BASE_DEF		;set default base
PRINT_FIX_BASE_1	CMPB	#PRINT_BASE_MAX		;required set of symbols must not exceed the alphabet
			BLS	PRINT_FIX_BASE_2	;base is within valid range
			LDAB	#PRINT_BASE_DEF		;set default base
PRINT_FIX_BASE_2	SSTACK_RTS
	
;#Print a left aligned unsigned double value
; args: Y:X: unsigned double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_LUDBL		EQU	*
PRINT_LUDBL1_FTMP3	EQU	$0
PRINT_LUDBL1_FTMP2	EQU	$1
PRINT_LUDBL1_FTMP1	EQU	$2
PRINT_LUDBL1_FTMP0	EQU	$3
PRINT_LUDBL1_RTMP5	EQU	$4
PRINT_LUDBL1_RTMP4	EQU	$5
PRINT_LUDBL1_RTMP3	EQU	$6
PRINT_LUDBL1_RTMP2	EQU	$7
PRINT_LUDBL1_RTMP1	EQU	$8
PRINT_LUDBL1_RTMP0	EQU	$9
PRINT_LUDBL1_CNT	EQU	$A
PRINT_LUDBL1_BASE	EQU	$B
PRINT_LUDBL1_A		EQU	$C
PRINT_LUDBL1_B		EQU	$D
PRINT_LUDBL1_X		EQU	$E
PRINT_LUDBL1_Y		EQU	$10

			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Fix base
PRINT_LUDBL_1		SSTACK_JOBSR	PRINT_FIX_BASE	;adjust base value (SSTACK: 2 bytes)

			;Allocate and initialize local variables
			SSTACK_ALLOC,12			;allocate local variables
			LDY	SSTACK_SP 		;use Y as stack pointer
			STD	PRINT_LUDBL1_CNT,Y
			STX	PRINT_LUDBL1_FTMP1,Y
			LDX	PRINT_LUDBL1_Y,Y
			STX	PRINT_LUDBL1_FTMP3,Y
			MOVW	#$0000, PRINT_LUDBL1_RTMP5,Y
			MOVW	#$0000, PRINT_LUDBL1_RTMP3,Y
			CLR	PRINT_LUDBL1_RTMP1,Y
			STAB	PRINT_LUDBL1_RTMP0,Y
			
			;Division loop (SP in Y)			
PRINT_LUDBL_2		LDAA	PRINT_LUDBL1_CNT,Y 	;decrement the counter
			SUBA	#1			;and keep counter positive
			BCC	PRINT_LUDBL_3
			CLRA
PRINT_LUDBL_3		STAA	PRINT_LUDBL1_CNT,Y 

			;Byte 3/Byte 2 (SP in Y)
			LDX	PRINT_LUDBL1_FTMP3,Y	;tmp3:tmp2 => X
			BEQ	PRINT_LUDBL_4		;division step can be skipped
			CLRA				;base => D
			LDAB	PRINT_LUDBL1_BASE,Y
			EXG	X, D
			IDIV				;D / X => X,  D % X => D 
			STX	PRINT_LUDBL1_FTMP3,Y	;result => tmp3:tmp2

			;Byte 1/Byte 0 (SP in Y, prev, remainder in D)
			TFR	D, X			;remainder => X
PRINT_LUDBL_4		CLRA				;base => D
			LDAB	PRINT_LUDBL1_BASE,Y
			LDY	PRINT_LUDBL1_FTMP1,Y	;tmp1:tmp0 => Y
			EXG	X, Y
			EXG	X, D
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			LDX	SSTACK_SP		;use X as stack pointer
			STY	PRINT_LUDBL1_FTMP1,X	;result => tmp1:tmp0
	
			;Add remainder to the reverse value (SP in X)
			;Byte 1/Byte 0
			ADDD	PRINT_LUDBL1_RTMP1,X
			STD	PRINT_LUDBL1_RTMP1,X
			;Byte 3/Byte 2
			LDD	PRINT_LUDBL1_RTMP3,X
			ADCB	#$00	
			ADCA	#$00
			STD	PRINT_LUDBL1_RTMP3,X
			;Byte 5/Byte 4
			LDD	PRINT_LUDBL1_RTMP5,X
			ADCB	#$00	
			ADCA	#$00
			STD	PRINT_LUDBL1_RTMP5,X

			;check if the reverse value needs to be shifted (SP in X)
			LDD	PRINT_LUDBL1_FTMP1,X
			BNE	PRINT_LUDBL_5 		;reverse value has been generated
			LDD	PRINT_LUDBL1_FTMP3,X
			BEQ	PRINT_LUDBL_6		;reverse value has been generated
	
			;Multiply the reverse value by the base (SP in X)
			;Byte 1/Byte 0
PRINT_LUDBL_5		LDY	PRINT_LUDBL1_RTMP1,X
			CLRA
			LDAB	PRINT_LUDBL1_BASE,X
			EMUL				;Y * D => Y:D
			STD	PRINT_LUDBL1_RTMP1,X
			;Byte 3/Byte 2
			LDD	PRINT_LUDBL1_RTMP3,X
			EXG	D, Y
			STD	PRINT_LUDBL1_RTMP3,X
			CLRA
			LDAB	PRINT_LUDBL1_BASE,X
			EMUL				;Y * D => Y:D
			ADDD	PRINT_LUDBL1_RTMP3,X
			STD	PRINT_LUDBL1_RTMP3,X
			;Byte 5/Byte 4
			LDD	PRINT_LUDBL1_RTMP5,X
			EXG	D, Y
			STD	PRINT_LUDBL1_RTMP5,X
			CLRA
			LDAB	PRINT_LUDBL1_BASE,X
			EMUL				;Y * D => Y:D
			ADDD	PRINT_LUDBL1_RTMP5,X
			STD	PRINT_LUDBL1_RTMP5,X

			;Start new iteration (SP in X)
			TFR	X, Y
			JOB	PRINT_LUDBL_2
			
			;Deallocate forward variable
PRINT_LUDBL_6		SSTACK_DEALLOC,4
			LDY	SSTACK_SP		;use Y as stack pointer
PRINT_LUDBL2_RTMP5	EQU	$0
PRINT_LUDBL2_RTMP4	EQU	$1
PRINT_LUDBL2_RTMP3	EQU	$2
PRINT_LUDBL2_RTMP2	EQU	$3
PRINT_LUDBL2_RTMP1	EQU	$4
PRINT_LUDBL2_RTMP0	EQU	$5
PRINT_LUDBL2_CNT	EQU	$6
PRINT_LUDBL2_BASE	EQU	$7
			
			;Print reverse variable (SP in Y)
			;Byte 5/Byte 4
PRINT_LUDBL_7		LDX	PRINT_LUDBL2_RTMP5,Y	;tmp5:tmp4 => X
			BEQ	PRINT_LUDBL_8		;division step can be skipped
			CLRA				;base => D
			LDAB	PRINT_LUDBL2_BASE,Y
			EXG	X, D
			IDIV				;D / X => X,  D % X => D 
			STX	PRINT_LUDBL2_RTMP5,Y	;result => tmp3:tmp2

			;Byte 3/Byte 2 (SP in Y, prev, remainder in D)
			TFR	D, X			;remainder => X
PRINT_LUDBL_8		CLRA				;base => D
			LDAB	PRINT_LUDBL2_BASE,Y
			LDY	PRINT_LUDBL2_RTMP3,Y	;tmp3:tmp2 => Y
			EXG	X, Y
			EXG	X, D
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			LDX	SSTACK_SP		;use X as stack pointer
			STY	PRINT_LUDBL2_RTMP3,X	;result => tmp3:tmp2

			;Byte 1/Byte 0 (SP in X, prev, remainder in D)
			TFR	D, Y 			;remainder => Y
			CLRA				;base => X
			LDAB	PRINT_LUDBL2_BASE,X 		
			LDX	PRINT_LUDBL2_RTMP1,X 	;tmp1:tmp0 => D
			EXG	D, X
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			LDX	SSTACK_SP		;use X as stack pointer
			STY	PRINT_LUDBL2_RTMP1,X	;result => tmp1:tmp0
			
			;Print remainder (SP in X, prev, remainder in D)
			LDY	#PRINT_SYMTAB
			LDAB	B,Y
			SCI_TX				;print character (SSTACK: 8 bytes)
			
			;Repeat until the reverse value is $1 (SP in X)
			TFR	X, Y			;use Y as stack pointer
			LDD	PRINT_LUDBL2_RTMP5,Y
			BNE	PRINT_LUDBL_7
			LDD	PRINT_LUDBL2_RTMP3,Y
			BNE	PRINT_LUDBL_7
			LDD	PRINT_LUDBL2_RTMP1,Y
			CPD	#$0001
			BNE	PRINT_LUDBL_7
	
			;Deallocate reverse variable
			SSTACK_DEALLOC,6
			LDX	SSTACK_SP
PRINT_LUDBL3_CNT	EQU	$0
PRINT_LUDBL3_BASE	EQU	$1

			;Print padding (SP in X)
			LDAA	PRINT_LUDBL3_CNT,X
			SSTACK_JOBSR	PRINT_SPCS
			
			;Deallocate local memory and restore registers
			SSTACK_DEALLOC,2		;deallocate local variables
			SSTACK_PULDXY			;RESTORE index X, index Y, and accu D
			SSTACK_RTS
	

;#Print a right aligned unsigned double value
; args: Y:X: unsigned double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_RUDBL		EQU	*
PRINT_RUDBL_A		EQU	$0
PRINT_RUDBL_B		EQU	$1
PRINT_RUDBL_X		EQU	$2
PRINT_RUDBL_Y		EQU	$3
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print padding
PRINT_RUDBL_1		SSTACK_JOBSR	PRINT_UDBLCNT 	;determine the number of digits (SSTACK: 13 bytes)
			NEGA
			LDY	SSTACK_SP		;use Y as stack pointer
			ADDA	PRINT_RUDBL_A,Y		;calculate the size of the padding
			BCC	PRINT_RUDBL_2	
			SSTACK_JOBSR	PRINT_SPCS

			;Print left aligned unsigned double value
PRINT_RUDBL_2		CLRA				;set output width to zero
			LDY	PRINT_RUDBL_Y,Y		;restore Y
			JOB	PRINT_RUDBL_3

PRINT_RUDBL_3		EQU	PRINT_LUDBL_1

;#Print a right aligned signed double value
; args: Y:X: signed double value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_RSDBL		EQU	*
PRINT_RSDBL_A		EQU	$0
PRINT_RSDBL_B		EQU	$1
PRINT_RSDBL_X		EQU	$2
PRINT_RSDBL_Y		EQU	$3
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print padding
PRINT_RSDBL_1		SSTACK_JOBSR	PRINT_SDBLCNT 	;determine the number of digits
			NEGA
			LDY	SSTACK_SP		;use Y as stack pointer
			ADDA	PRINT_RSDBL_A,Y		;calculate the size of the padding
			BCC	PRINT_RSDBL_2	
			SSTACK_JOBSR	PRINT_SPCS

			;Print left aligned unsigned double value
PRINT_RSDBL_2		CLRA				;set output width to zero
			JOB	PRINT_RSDBL_3

PRINT_RSDBL_3		EQU	PRINT_LSDBL_1


;#Print a right aligned unsigned integer value
; args:   X: unsigned integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_RUINT		EQU	*
PRINT_RUINT_A		EQU	$0
PRINT_RUINT_B		EQU	$1
PRINT_RUINT_X		EQU	$2
PRINT_RUINT_Y		EQU	$3

			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print padding
PRINT_RUINT_1		SSTACK_JOBSR	PRINT_UINTCNT 	;determine the number of digits (SSTACK: 13 bytes)
			NEGA
			LDY	SSTACK_SP		;use Y as stack pointer
			ADDA	PRINT_RUINT_A,Y		;calculate the size of the padding
			BCC	PRINT_RUINT_2	
			SSTACK_JOBSR	PRINT_SPCS

			;Print left aligned unsigned double value
PRINT_RUINT_2		CLRA				;set output width to zero
			JOB	PRINT_RUINT_3

PRINT_RUINT_3		EQU	PRINT_LUINT_1

;#Print a right aligned signed integer value
; args:   X: signed integer value
;         A: minimum lenght of the output
; 	  B: base   (2<=base<=16)
; SSTACK: 24 bytes
;         X, Y and D are preserved
PRINT_RSINT		EQU	*
PRINT_RSINT_A		EQU	$0
PRINT_RSINT_B		EQU	$1
PRINT_RSINT_X		EQU	$2
PRINT_RSINT_Y		EQU	$3

			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Print padding
PRINT_RSINT_1		SSTACK_JOBSR	PRINT_SINTCNT 	;determine the number of digits (SSTACK: 13 bytes)
			NEGA
			LDY	SSTACK_SP		;use Y as stack pointer
			ADDA	PRINT_RSINT_A,Y		;calculate the size of the padding
			BCC	PRINT_RSINT_2	
			SSTACK_JOBSR	PRINT_SPCS

			;Print left aligned signed double value
PRINT_RSINT_2		CLRA				;set output width to zero
			JOB	PRINT_RSINT_3

PRINT_RSINT_3		EQU	PRINT_LSINT_1

;#Count digits of an unsigned double value
; args:   Y:X: unsigned double value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
PRINT_UDBLCNT		EQU	*
PRINT_UDBLCNT_TMP3	EQU	$0
PRINT_UDBLCNT_TMP2	EQU	$1
PRINT_UDBLCNT_TMP1	EQU	$2
PRINT_UDBLCNT_TMP0	EQU	$3
PRINT_UDBLCNT_BASE	EQU	$4
PRINT_UDBLCNT_CNT	EQU	$5
PRINT_UDBLCNT_B		EQU	$6
PRINT_UDBLCNT_X		EQU	$7
PRINT_UDBLCNT_Y		EQU	$9
	
			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Fix base
PRINT_UDBLCNT_1		SSTACK_JOBSR	PRINT_FIX_BASE	;adjust base value (SSTACK: 2 bytes)

			;Allocate and initialize local variables
			SSTACK_ALLOC,5			;allocate local variables
			LDY	SSTACK_SP 		;use Y as stack pointer
			CLR	PRINT_UDBLCNT_CNT,Y
			STAB	PRINT_UDBLCNT_BASE,Y
			MOVW	PRINT_UDBLCNT_Y,Y PRINT_UDBLCNT_TMP3,Y
			STX	PRINT_UDBLCNT_TMP1,Y

			;Division loop (SP in Y)			
PRINT_UDBLCNT_2		INC	PRINT_UDBLCNT_CNT,Y 	;increment the counter
			
			;Byte 3/Byte 2 (SP in Y)
			LDX	PRINT_UDBLCNT_TMP3,Y	;tmp3:tmp2 => X
			BEQ	PRINT_UDBLCNT_3		;division step can be skipped
			CLRA				;base => D
			LDAB	PRINT_UDBLCNT_BASE,Y
			EXG	X, D
			IDIV				;D / X => X,  D % X => D 
			STX	PRINT_UDBLCNT_TMP3,Y	;result => tmp3:tmp2

			;Byte 1/Byte 0 (SP in Y, prev, remainder in D)
			TFR	D, X			;remainder => X
PRINT_UDBLCNT_3		CLRA				;base => D
			LDAB	PRINT_UDBLCNT_BASE,Y
			LDY	PRINT_UDBLCNT_TMP1,Y	;tmp1:tmp0 => Y
			EXG	X, Y
			EXG	X, D
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			LDX	SSTACK_SP		;use X as stack pointer
			STY	PRINT_UDBLCNT_TMP1,X	;result => tmp1:tmp0
			TFR	X, Y			;use Y as stack pointer
			BNE	PRINT_UDBLCNT_2		;result is not zero, yet
			LDX	PRINT_UDBLCNT_TMP3,Y	;tmp3:tmp2 => X
			BNE	PRINT_UDBLCNT_2		;result is not zero, yet

			;Deallocate local memory and restore registers
			SSTACK_DEALLOC,5		;deallocate local variables
			SSTACK_PULDXY			;RESTORE index X, index Y, and accu D
			SSTACK_RTS

;#Count digits of a signed double value
; args:   Y:X: signed double value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
PRINT_SDBLCNT		EQU	*
PRINT_SDBLCNT_TMP3	EQU	$0
PRINT_SDBLCNT_TMP2	EQU	$1
PRINT_SDBLCNT_TMP1	EQU	$2
PRINT_SDBLCNT_TMP0	EQU	$3
PRINT_SDBLCNT_BASE	EQU	$4
PRINT_SDBLCNT_CNT	EQU	$5
PRINT_SDBLCNT_B		EQU	$6
PRINT_SDBLCNT_X		EQU	$7
PRINT_SDBLCNT_Y		EQU	$9

			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D
			
			;Check if number is negative 
PRINT_SDBLCNT_1		CPY	#$0000
			BPL	PRINT_SDBLCNT_2		;number is positive

			;Fix base
			SSTACK_JOBSR	PRINT_FIX_BASE	;adjust base value (SSTACK: 2 bytes)

			;Allocate and initialize local variables
			SSTACK_ALLOC,5			;allocate local variables
			LDY	SSTACK_SP 		;use Y as stack pointer
			MOVB	#$01, PRINT_SDBLCNT_CNT,Y
			STAB	PRINT_SDBLCNT_BASE,Y	
			LDD	PRINT_SDBLCNT_Y,Y
			COMA				;negate Y:X
			COMB
			EXG	D, X
			COMA
			COMB
			ADDD	#1
			EXG	D, X
			ADCA	#$00
			ADCB	#$00
			STD	PRINT_SDBLCNT_TMP3,Y
			STX	PRINT_SDBLCNT_TMP1,Y
			
			JOB	PRINT_SDBLCNT_3	;jump to UDBLCNT division loop

PRINT_SDBLCNT_2		EQU	PRINT_UDBLCNT_1
PRINT_SDBLCNT_3		EQU	PRINT_UDBLCNT_2

	
;#Count digits of an unsigned integer value
; args:   X: unsigned integer value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
PRINT_UINTCNT		EQU	*
PRINT_UINTCNT_TMP3	EQU	$0
PRINT_UINTCNT_TMP2	EQU	$1
PRINT_UINTCNT_TMP1	EQU	$2
PRINT_UINTCNT_TMP0	EQU	$3
PRINT_UINTCNT_BASE	EQU	$4
PRINT_UINTCNT_CNT	EQU	$5
PRINT_UINTCNT_B		EQU	$6
PRINT_UINTCNT_X		EQU	$7
PRINT_UINTCNT_Y		EQU	$9

			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Fix base
PRINT_UINTCNT_1		SSTACK_JOBSR	PRINT_FIX_BASE	;adjust base value (SSTACK: 2 bytes)

			;Allocate and initialize local variables
			SSTACK_ALLOC,5			;allocate local variables
			LDY	SSTACK_SP 		;use Y as stack pointer
			CLR	PRINT_UDBLCNT_CNT,Y
			STAB	PRINT_UDBLCNT_BASE,Y
			MOVW	#$0000, PRINT_UDBLCNT_TMP3,Y
			STX	PRINT_UDBLCNT_TMP1,Y

			JOB	PRINT_UINTCNT_2		;jump to the division loop

PRINT_UINTCNT_2		EQU	PRINT_UDBLCNT_2

;#Count digits of a signed double value
; args:   X: signed double value
; 	  B: base   (2<=base<=16)
; result: A: number of digits
; SSTACK: 13 bytes
;         X, Y and B are preserved
PRINT_SINTCNT		EQU	*
PRINT_SINTCNT_TMP3	EQU	$0
PRINT_SINTCNT_TMP2	EQU	$1
PRINT_SINTCNT_TMP1	EQU	$2
PRINT_SINTCNT_TMP0	EQU	$3
PRINT_SINTCNT_BASE	EQU	$4
PRINT_SINTCNT_CNT	EQU	$5
PRINT_SINTCNT_B		EQU	$6
PRINT_SINTCNT_X		EQU	$7
PRINT_SINTCNT_Y		EQU	$9

			;Save registers
			SSTACK_PSHYXD			;save index X, index Y, and accu D

			;Check if value is negative
PRINT_SINTCNT_1		CPX	#$0000
			BPL	PRINT_SINTCNT_2

			;Number is negative 
			;Fix base
			SSTACK_JOBSR	PRINT_FIX_BASE	;adjust base value (SSTACK: 2 bytes)
			
			;Allocate and initialize local variables
			SSTACK_ALLOC,5			;allocate local variables
			LDY	SSTACK_SP 		;use Y as stack pointer
			MOVB	#$01,	PRINT_UDBLCNT_CNT,Y
			STAB	PRINT_UDBLCNT_BASE,Y
			MOVW	#$0000, PRINT_UDBLCNT_TMP3,Y
			TFR	X, D
			COMA
			COMB
			ADDD	#1
			STD	PRINT_UDBLCNT_TMP1,Y

			JOB	PRINT_SINTCNT_2		;jump to the division loop

PRINT_SINTCNT_2		EQU	PRINT_UINTCNT_2
	
;#Print spaces
; args:   A: character count
; SSTACK: 12 bytes
;         X, Y and D are preserved
PRINT_SPCS		EQU	*
			;Save registers
			SSTACK_PSHD 			;save  accu D

			;Print loop
			TBEQ	A, PRINT_SPCS_2 	;don't print anything if A=0 ;'
			LDAB	#PRINT_SYM_SPACE
PRINT_SPCS_1		SCI_TX				;print character (SSTACK: 8 bytes)
			DBNE	A, PRINT_SPCS_1
	
			;Restore registers
PRINT_SPCS_2		SSTACK_PULD 			;restore accu D
			SSTACK_RTS

;#Count characters of a string
; args:   X: start of the string
; result: A: character count (saturated at 255)
; SSTACK: 2 bytes
;         X, Y and B are preserved
PRINT_STRCNT		EQU	*
			;Count loop 
			CLRA				;clear counter
PRINT_STRCNT_1		TST	A,X			;check for string termination
			BMI	PRINT_STRCNT_3		;last char
			INCA				;increment count
			BNE	PRINT_STRCNT_1		;no overflow 
PRINT_STRCNT_2		COMA				;overflow -> keep value at maximum
			SSTACK_RTS
PRINT_STRCNT_3		INCA				;count last char
			BEQ	PRINT_STRCNT_2		;overflow
			SSTACK_RTS

;#Print a right aligned string to the SCI
; args:   X: start of the string
;         A: minimum lenght of the output
; SSTACK: 18 bytes
;         X, Y and D are preserved
PRINT_RSTR		EQU	*
			;Save registers
			SSTACK_PSHXD 			;save index Y and accu D

			;Count characters
PRINT_RSTR_1		TAB
			SSTACK_JOBSR	PRINT_STRCNT 	;char count => A  (SSTACK: 2 bytes)
			EXG	A, B
			SBA				;output length - chars => A
			BCS	PRINT_RSTR_2
			SSTACK_JOBSR	PRINT_SPCS 	;print padding (SSTACK: 12 bytes)
PRINT_RSTR_2		CLRA			
			
			;Print left aligned string 	
			JOB	PRINT_RSTR_3

PRINT_RSTR_3		EQU	PRINT_LSTR_1
		
;#Print a left aligned string to the SCI
; args:   X: start of the string
;         A: minimum lenght of the output
; SSTACK: 14 bytes
;         X, Y and D are preserved
PRINT_LSTR		EQU	*
			;Save registers
			SSTACK_PSHXD 			;save index Y and accu D
	
			;Print and count characters
PRINT_LSTR_1		LDAB	1,X+ 			;get next ASCII character
			BMI	PRINT_LSTR_2		;last character
			SCI_TX				;print character (SSTACK: 8 bytes)
			SUBA	#$01			;decrement length counter
			BCC	PRINT_LSTR_1		;length counter is positive
			CLRA				;keep lenght counter at zero (if negative)
			JOB	PRINT_LSTR_1
	
			;Print last character
PRINT_LSTR_2		ANDB	#$7F 			;remove termination bit
			SCI_TX				;print character (SSTACK: 8 bytes)
			SUBA	#$01			;decrement length counter
			BLS	PRINT_LSTR_4		;length counter is zero or negative
						
			;Print padding
			LDAB	#PRINT_SYM_SPACE
PRINT_LSTR_3		SCI_TX				;print character (SSTACK: 8 bytes)
			DBNE	A, PRINT_LSTR_3
			
			;Restore registers
PRINT_LSTR_4		SSTACK_PULDX 			;restore index Y and accu D
			SSTACK_RTS

;#Print a string to the SCI (without alignment)
; args:   X: start of the string
; SSTACK: 14 bytes
;         X, Y and D are preserved
PRINT_STR		EQU	*
			;Save registers
			SSTACK_PSHXD 			;save index Y and accu D

			;print left alignend string without padding
PRINT_STR_1		CLRA				;no min. string length
			JOB	PRINT_STR_2	
	
PRINT_STR_2		EQU	PRINT_LSTR_1
	
;#Print a line break to the SCI
; args:   none
; SSTACK: 11 bytes
;         X, Y and D are preserved
PRINT_LINE_BREAK	EQU	*
			;Save registers
			SSTACK_PSHB 			;save accu B	

			;Print CR symbol
			LDAB	#PRINT_SYM_CR
			SCI_TX				;print character (SSTACK: 8 bytes)
			;;Print LF symbol
			;LDAB	#PRINT_SYM_LF
			;SCI_TX				;print character (SSTACK: 8 bytes)

			;Save registers
			SSTACK_PULB 			;restore accu B
			SSTACK_RTS

;#Print a space character to the SCI
; args:   none
; SSTACK: 11 bytes
;         X, Y and D are preserved
PRINT_SPC		EQU	*
			;Save registers
			SSTACK_PSHB 			;save accu B	

			;Print space character
			LDAB	#" "
			SCI_TX				;print character (SSTACK: 8 bytes)

			;Save registers
			SSTACK_PULB 			;restore accu B
			SSTACK_RTS

;#Send a beep to the SCI
; args:   none
; SSTACK: 11 bytes
;         X, Y and D are preserved
PRINT_BEEP		EQU	*
			;Save registers
			SSTACK_PSHB 			;save accu B	

			;Print beep symbol
			LDAB	#PRINT_SYM_BEEP
			SCI_TX				;print character (SSTACK: 8 bytes)

			;Save registers
			SSTACK_PULB 			;restore accu B
			SSTACK_RTS

;#Print an 8-bit value to the SCI
; args:   B: 8-bit value
; SSTACK: 14 bytes
;         X, Y and D are preserved
PRINT_BYTE		EQU	*
			;Save registers
			SSTACK_PSHYD			;save Y and D (SSTACK: 4 bytes)

			;Print most significant digit
			LDY	#PRINT_SYMTAB		
			TBA				;save number in A
			LSRB				;shift upper nibble to the right
			LSRB	
			LSRB					
			LSRB	
			LDAB	B,Y 			;look up ASCII value
			SCI_TX				;print character (SSTACK: 8 bytes)

			;Print least significant digit
			ANDA	#$0F
			LDAB	A,Y 			;look up ASCII value
			SCI_TX				;print character (SSTACK: 8 bytes)

			;Restore registers
			SSTACK_PULDY			;restore Y and D
			SSTACK_RTS

;#Print a 16-bit value to the SCI
; args:   D: 16-bit value
; SSTACK: 16 bytes
;         X, Y and D are preserved
PRINT_WORD		EQU	*
			;Print most significant digit
			EXG	A, B
			SSTACK_JOBSR	PRINT_BYTE

			;Print least significant digit
			EXG	A, B
			SSTACK_JOBSR	PRINT_BYTE

			;Return
			SSTACK_RTS

;#Print a unsigned integer value to the SCI
; args:   B: bit field
; SSTACK: 14 bytes
;         X, Y and D are preserved
PRINT_BITS		EQU	*
			;Save registers
			SSTACK_PSHYD			;save Y and D (SSTACK: 4 bytes)

			;Bit loop
			LDY	#8	     		;loop counter
			TBA				;byte -> A
PRINT_BITS_1		LDAB	#"X"			;"TRUE" symbol
			LSLA				;check MSB
			BCS	PRINT_BITS_2		;MSB is set
			LDAB	#"."			;"FALSE" symbol
PRINT_BITS_2		SCI_TX				;print character (SSTACK: 8 bytes)
			DBNE	Y, PRINT_BITS_1
	
			;Restore registers
			SSTACK_PULDY			;restore Y and D
			SSTACK_RTS
	
PRINT_CODE_END		EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	PRINT_TABS_START
PRINT_SYMTAB		DB	"0"
			DB	"1"
			DB	"2"
			DB	"3"
			DB	"4"
			DB	"5"
			DB	"6"
			DB	"7"
			DB	"8"
			DB	"9"
			DB	"A"
			DB	"B"
			DB	"C"
			DB	"D"
			DB	"E"
			DB	"F"
			DB	"G"
			DB	"H"
			DB	"I"
			DB	"J"
			DB	"K"
			DB	"L"
			DB	"M"
			DB	"N"
			DB	"O"
			DB	"P"
			DB	"Q"
			DB	"R"
			DB	"S"
			DB	"T"
			DB	"U"
			DB	"V"
			DB	"W"
			DB	"X"
			DB	"Y"
			DB	"Z"
PRINT_SYMTAB_END	DB	*

PRINT_TABS_END		EQU	*
