;###############################################################################
;# S12CForth - FDOUBLE - ANS Forth Double-Number Words                         #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    This module defines the format of word entries in the Forth dictionary   #
;#    and it implements the basic vocabulary.                                  #
;###############################################################################
;# Version History:                                                            #
;#    April 22, 20010                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    FCORE  - Forth Core Module                                               #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Prevents idle loop from entering WAIT mode.                      #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FDOUBLE_VARS_START
FDOUBLE_VARS_END		EQU	*
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FDOUBLE_INIT, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FDOUBLE_CODE_START
;Exceptions
FDOUBLE_THROW_PSOF	EQU	FMEM_THROW_PSOF			;stack overflow
FDOUBLE_THROW_PSUF	EQU	FMEM_THROW_PSUF			;stack underflow
FDOUBLE_THROW_INVALBASE	EQU	FCORE_THROW_INVALBASE		;invalid BASE value

FDOUBLE_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FDOUBLE_TABS_START
FDOUBLE_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FDOUBLE_WORDS_START ;(previous NFA: FDOUBLE_PREV_NFA)

;2CONSTANT ( x1 x2 "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a two-constant.
;name Execution: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
NFA_TWO_CONSTANT	EQU	FDOUBLE_PREV_NFA
;			ALIGN	1
;NFA_TWO_CONSTANT	FHEADER, "2CONSTANT", FDOUBLE_PREV_NFA, COMPILE
;CFA_TWO_CONSTANT	DW	CF_DUMMY

;2CONSTANT run-time semantics
;Push the contents of the first cell after the CFA onto the parameter stack
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
;CF_TWO_CONSTANT_RT	PS_CHECK_OF	2, CF_TWO_CONSTANT_PSOF	;overflow check	=> 9 cycles
			MOVW		4,X, 2,Y		;[CFA+4] -> PS	=> 5 cycles
			MOVW		2,X, 0,Y		;[CFA+2] -> PS	=> 5 cycles
			STY		PSP			;		=> 3 cycles
			NEXT					;NEXT		=>15 cycles
								; 		  ---------
								;		  37 cycles
CF_TWO_CONSTANT_PSOF	JOB	FCORE_THROW_PSOF
	
;2LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x1 x2 -- )
;Append the run-time semantics below to the current definition.
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
NFA_TWO_LITERAL		EQU	NFA_TWO_CONSTANT
;			ALIGN	1
;NFA_TWO_LITERAL	FHEADER, "2LITERAL", NFA_TWO_CONSTANT, COMPILE
;CFA_TWO_LITERAL	DW	CF_DUMMY

;2LITERAL run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
CFA_TWO_LITERAL_RT	DW	CF_LITERAL_RT
CF_TWO_LITERAL_RT	PS_CHECK_OF	2, CF_LITERAL_PSOF 	;check for PS overflow (PSP-new cells -> Y)
			LDX	IP				;push the value at IP onto the PS
			MOVW	2,X+, 0,Y			; and increment the IP
			MOVW	2,X+, 2,Y			; and increment the IP
			STX	IP
			STY	PSP
			NEXT
			
;2VARIABLE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. Reserve two
;consecutive cells of data space.
;name is referred to as a two-variable.
;name Execution: ( -- a-addr )
;a-addr is the address of the first (lowest address) cell of two consecutive
;cells in data space reserved by 2VARIABLE when it defined name. A program is
;responsible for initializing the contents.
NFA_TWO_VARIABLE	EQU	NFA_TWO_LITERAL
;			ALIGN	1
;NFA_TWO_VARIABLE	FHEADER, "2VARIABLE", NFA_TWO_LITERAL, COMPILE
;CFA_TWO_VARIABLE	DW	CF_DUMMY

;Run-time of VARIABLE
CFA_TWO_VARIABLE_RT	EQU	CFA_VARIABLE_RT		
	
;D+ ( d1|ud1 d2|ud2 -- d3|ud3 )
;Add d2|ud2 to d1|ud1, giving the sum d3|ud3.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_PLUS		FHEADER, "D+", NFA_TWO_VARIABLE, COMPILE
CFA_D_PLUS		DW	CF_D_PLUS
CF_D_PLUS		PS_CHECK_UF 4, CF_D_PLUS_PSUF 	;check for underflow  (PSP -> Y)
			LDD	3,Y
			ADDD	1,Y
			STD	3,Y
			LDD	2,Y
			ADCB	1,Y
			ADCA	0,Y
			STD	2,+Y	
			STY	PSP
			NEXT
	
CF_D_PLUS_PSUF		JOB	FDOUBLE_THROW_PSUF
			
;D- ( d1|ud1 d2|ud2 -- d3|ud3 )
;Subtract d2|ud2 from d1|ud1, giving the difference d3|ud3.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_MINUS		FHEADER, "D-", NFA_D_PLUS, COMPILE
CFA_D_MINUS		DW	CF_D_MINUS
CF_D_MINUS		PS_CHECK_UF 4, CF_D_MINUS_PSUF 	;check for underflow  (PSP -> Y)
			LDD	3,Y
			SUBD	1,Y
			STD	3,Y			
			LDD	2,Y
			SBCB	1,Y
			SBCA	0,Y
			STD	2,+Y	
			STY	PSP
			NEXT
		
			NEXT
	
CF_D_MINUS_PSUF		JOB	FDOUBLE_THROW_PSUF
	
;D. ( d -- )
;Display d in free field format.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_DOT		FHEADER, "D.", NFA_D_MINUS, COMPILE
CFA_D_DOT		DW	CF_D_DOT
CF_D_DOT		PS_CHECK_UF 2, CF_D_DOT_PSUF 	;check for underflow (PSP -> Y)
			BASE_CHECK CF_D_DOT_INVALBASE	;check BASE value (BASE -> D) 
			LEAY	4,Y
			STY	PSP
			LDX	-2,Y
			LDY	-4,Y
			LDD	BASE
			PRINT_SDBL			;print cells as signed double integer
			NEXT
			
CF_D_DOT_PSUF		JOB	FDOUBLE_THROW_PSUF
CF_D_DOT_INVALBASE	JOB	FDOUBLE_THROW_INVALBASE
		
;D.R ( d n -- )
;Display d right aligned in a field n characters wide. If the number of
;characters required to display d is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
;
;S12CForth implementation details:
; n must be lower than 256 ($100) otherwise it will be saturated at 255 ($FF)
;Throws:
;"Parameter stack underflow"
;"Invalid BASE value"
;
			ALIGN	1
NFA_D_DOT_R		FHEADER, "D.R", NFA_D_DOT, COMPILE
CFA_D_DOT_R		DW	CF_D_DOT_R
CF_D_DOT_R		PS_CHECK_UF 3, CF_D_DOT_R_PSUF 	;check for underflow  (PSP -> Y)
			BASE_CHECK CF_D_DOT_R_INVALBASE	;check BASE value (BASE -> D) 
			TST	1,Y+			;check if n>255 
			BNE	CF_D_DOT_R_2		;saturate n 
			LDAA	5,Y+
CF_D_DOT_R_1		STY	PSP
			LDX	-2,Y
			LDY	-4,Y
			PRINT_SPC			;print a space character
			PRINT_SDBL			;print cells as signed double integer
			NEXT
			;Saturate n
CF_D_DOT_R_2		LDAA	$FF
			LEAY	5,Y
			JOB	CF_D_DOT_R_1
				
CF_D_DOT_R_PSUF		JOB	FDOUBLE_THROW_PSUF
CF_D_DOT_R_INVALBASE	JOB	FDOUBLE_THROW_INVALBASE
	
;D0< ( d -- flag )
;flag is true if and only if d is less than zero.
NFA_D_ZERO_LESS		EQU	NFA_D_DOT_R
;			ALIGN	1
;NFA_D_ZERO_LESS	FHEADER, "D0<", NFA_D_DOT_R, COMPILE
;CFA_D_ZERO_LESS	DW	CF_DUMMY

;D0= ( xd -- flag )
;flag is true if and only if xd is equal to zero.
NFA_D_ZERO_EQUALS	EQU	NFA_D_ZERO_LESS
;			ALIGN	1
;NFA_D_ZERO_EQUALS	FHEADER, "D0=", NFA_D_ZERO_LESS, COMPILE
;CFA_D_ZERO_EQUALS	DW	CF_DUMMY

;D2* ( xd1 -- xd2 )
;xd2 is the result of shifting xd1 one bit toward the most-significant bit,
;filling the vacated least-significant bit with zero.
NFA_D_TWO_STAR		EQU	NFA_D_ZERO_EQUALS
;			ALIGN	1
;NFA_D_TWO_STAR		FHEADER, "D2*", NFA_D_ZERO_EQUALS, COMPILE
;CFA_D_TWO_STAR		DW	CF_DUMMY

;D2/ ( xd1 -- xd2 )
;xd2 is the result of shifting xd1 one bit toward the least-significant bit,
;leaving the most-significant bit unchanged.
NFA_D_TWO_SLASH		EQU	NFA_D_TWO_STAR
;			ALIGN	1
;NFA_D_TWO_SLASH		FHEADER, "D2/", NFA_D_TWO_STAR, COMPILE
;CFA_D_TWO_SLASH		DW	CF_DUMMY
	
;D< 
;d-less-than ( d1 d2 -- flag )
;flag is true if and only if d1 is less than d2.
NFA_D_LESS_THAN		EQU	NFA_D_TWO_SLASH
;			ALIGN	1
;NFA_D_LESS_THAN		FHEADER, "D<", NFA_D_TWO_SLASH, COMPILE
;CFA_D_LESS_THAN		DW	CF_DUMMY

;D= ( xd1 xd2 -- flag )
;flag is true if and only if xd1 is bit-for-bit the same as xd2.
NFA_D_EQUALS		EQU	NFA_D_LESS_THAN
;			ALIGN	1
;NFA_D_EQUALS		FHEADER, "D=", NFA_D_LESS_THAN, COMPILE
;CFA_D_EQUALS		DW	CF_DUMMY

;D>S  d -- n )
;n is the equivalent of d. An ambiguous condition exists if d lies outside the
;range of a signed single-cell number.
NFA_D_TO_S		EQU	NFA_D_EQUALS
;			ALIGN	1
;NFA_D_TO_S		FHEADER, "D>S", NFA_D_EQUALS, COMPILE
;CFA_D_TO_S		DW	CF_DUMMY

;DABS ( d -- ud )
;ud is the absolute value of d.
NFA_D_ABS		EQU	NFA_D_TO_S
;			ALIGN	1
;NFA_D_ABS		FHEADER, "DABS", NFA_D_TO_S, COMPILE
;CFA_D_ABS		DW	CF_DUMMY

;DMAX ( d1 d2 -- d3 )
;d3 is the greater of d1 and d2.
NFA_D_MAX		EQU	NFA_D_ABS
;			ALIGN	1
;NFA_D_MAX		FHEADER, "DMAX", NFA_D_ABS, COMPILE
;CFA_D_MAX		DW	CF_DUMMY

;DMIN ( d1 d2 -- d3 )
;d3 is the lesser of d1 and d2.
NFA_D_MIN		EQU	NFA_D_MAX
;			ALIGN	1
;NFA_D_MIN		FHEADER, "DMIN", NFA_D_MAX, COMPILE
;CFA_D_MIN		DW	CF_DUMMY

;DNEGATE ( d1 -- d2 )
;d2 is the negation of d1.
NFA_D_NEGATE		EQU	NFA_D_MIN
;			ALIGN	1
;NFA_D_NEGATE		FHEADER, "DNEGATE", NFA_D_MIN, COMPILE
;CFA_D_NEGATE		DW	CF_DUMMY

;
;M*/ ( d1 n1 +n2 -- d2 )
;Multiply d1 by n1 producing the triple-cell intermediate result t. Divide t by
;+n2 giving the double-cell quotient d2. An ambiguous condition exists if +n2 is
;zero or negative, or the quotient lies outside of the range of a
;double-precision signed integer.
NFA_M_STAR_SLASH	EQU	NFA_D_NEGATE
;			ALIGN	1
;NFA_M_STAR_SLASH	FHEADER, "M*/", NFA_D_NEGATE, COMPILE
;CFA_M_STAR_SLASH	DW	CF_DUMMY

;M+ 
;m-plus DOUBLE 
;	( d1|ud1 n -- d2|ud2 )
;Add n to d1|ud1, giving the sum d2|ud2.
NFA_M_PLUS		EQU	NFA_M_STAR_SLASH
;			ALIGN	1
;NFA_M_PLUS		FHEADER, "M+", NFA_M_STAR_SLASH, COMPILE
;CFA_M_PLUS		DW	CF_DUMMY

;2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;top of the stack.
NFA_TWO_ROT		EQU	NFA_M_PLUS
;			ALIGN	1
;NFA_TWO_ROT		FHEADER, "2ROT", NFA_M_PLUS, COMPILE
;CFA_TWO_ROT		DW	CF_DUMMY

;DU< ( ud1 ud2 -- flag )
;flag is true if and only if ud1 is less than ud2.
NFA_D_U_LESS		EQU	NFA_TWO_ROT
;			ALIGN	1
;NFA_D_U_LESS		FHEADER, "DU<", NFA_TWO_ROT, COMPILE
;CFA_D_U_LESS		DW	CF_DUMMY
	
FDOUBLE_WORDS_END		EQU	*
FDOUBLE_LAST_NFA		EQU	NFA_D_U_LESS
