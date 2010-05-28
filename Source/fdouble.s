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
NFA_TWO_CONSTANT	FHEADER, "2CONSTANT", FDOUBLE_PREV_NFA, COMPILE
CFA_TWO_CONSTANT	DW	CF_TWO_CONSTANT
CF_TWO_CONSTANT		NEXT
CF_TWO_CONSTANT_RT	EQU	CF_TWO_CONSTANT ;TBD ASAP!!!
	
;2LITERAL 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x1 x2 -- )
;Append the run-time semantics below to the current definition.
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
NFA_TWO_LITERAL		FHEADER, "2LITERAL", NFA_TWO_CONSTANT, COMPILE
CFA_TWO_LITERAL		DW	CF_TWO_LITERAL
CF_TWO_LITERAL		NEXT

;2VARIABLE ( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below. Reserve two
;consecutive cells of data space.
;name is referred to as a two-variable.
;name Execution: ( -- a-addr )
;a-addr is the address of the first (lowest address) cell of two consecutive
;cells in data space reserved by 2VARIABLE when it defined name. A program is
;responsible for initializing the contents.
NFA_TWO_VARIABLE	FHEADER, "2VARIABLE", NFA_TWO_LITERAL, COMPILE
CFA_TWO_VARIABLE	DW	CF_TWO_VARIABLE
CF_TWO_VARIABLE		NEXT

;D+ ( d1|ud1 d2|ud2 -- d3|ud3 )
;Add d2|ud2 to d1|ud1, giving the sum d3|ud3.
NFA_D_PLUS		FHEADER, "D+", NFA_TWO_VARIABLE, COMPILE
CFA_D_PLUS		DW	CF_D_PLUS
CF_D_PLUS		NEXT
	
;D- ( d1|ud1 d2|ud2 -- d3|ud3 )
;Subtract d2|ud2 from d1|ud1, giving the difference d3|ud3.
NFA_D_MINUS		FHEADER, "D-", NFA_D_PLUS, COMPILE
CFA_D_MINUS		DW	CF_D_MINUS
CF_D_MINUS		NEXT
	
;D. ( d -- )
;Display d in free field format.
;
NFA_D_DOT		FHEADER, "D.", NFA_D_MINUS, COMPILE
CFA_D_DOT		DW	CF_D_DOT
CF_D_DOT		NEXT
	
;D.R ( d n -- )
;Display d right aligned in a field n characters wide. If the number of
;characters required to display d is greater than n, all digits are displayed
;with no leading spaces in a field as wide as necessary.
NFA_D_DOT_R		FHEADER, "D.", NFA_D_DOT, COMPILE
CFA_D_DOT_R		DW	CF_D_DOT_R
CF_D_DOT_R		NEXT

;D0< ( d -- flag )
;flag is true if and only if d is less than zero.
NFA_D_ZERO_LESS		FHEADER, "D0<", NFA_D_DOT_R, COMPILE
CFA_D_ZERO_LESS		DW	CF_D_ZERO_LESS
CF_D_ZERO_LESS		NEXT

;D0= ( xd -- flag )
;flag is true if and only if xd is equal to zero.
NFA_D_ZERO_EQUALS	FHEADER, "D0=", NFA_D_ZERO_LESS, COMPILE
CFA_D_ZERO_EQUALS	DW	CF_D_ZERO_EQUALS
CF_D_ZERO_EQUALS	NEXT

;D2* ( xd1 -- xd2 )
;xd2 is the result of shifting xd1 one bit toward the most-significant bit,
;filling the vacated least-significant bit with zero.
NFA_D_TWO_STAR		FHEADER, "D2*", NFA_D_ZERO_EQUALS, COMPILE
CFA_D_TWO_STAR		DW	CF_D_TWO_STAR
CF_D_TWO_STAR		NEXT

;D2/ ( xd1 -- xd2 )
;xd2 is the result of shifting xd1 one bit toward the least-significant bit,
;leaving the most-significant bit unchanged.
NFA_D_TWO_SLASH		FHEADER, "D2/", NFA_D_TWO_STAR, COMPILE
CFA_D_TWO_SLASH		DW	CF_D_TWO_SLASH
CF_D_TWO_SLASH		NEXT
	
;D< 
;d-less-than ( d1 d2 -- flag )
;flag is true if and only if d1 is less than d2.
NFA_D_LESS_THAN		FHEADER, "D<", NFA_D_TWO_SLASH, COMPILE
CFA_D_LESS_THAN		DW	CF_D_TWO_SLASH
CF_D_LESS_THAN		NEXT

;D= ( xd1 xd2 -- flag )
;flag is true if and only if xd1 is bit-for-bit the same as xd2.
NFA_D_EQUALS		FHEADER, "D=", NFA_D_LESS_THAN, COMPILE
CFA_D_EQUALS		DW	CF_D_EQUALS
CF_D_EQUALS		NEXT

;D>S  d -- n )
;n is the equivalent of d. An ambiguous condition exists if d lies outside the
;range of a signed single-cell number.
NFA_D_TO_S		FHEADER, "D>S", NFA_D_EQUALS, COMPILE
CFA_D_TO_S		DW	CF_D_TO_S
CF_D_TO_S		NEXT

;DABS ( d -- ud )
;ud is the absolute value of d.
NFA_D_ABS		FHEADER, "DABS", NFA_D_TO_S, COMPILE
CFA_D_ABS		DW	CF_D_ABS
CF_D_ABS		NEXT

;DMAX ( d1 d2 -- d3 )
;d3 is the greater of d1 and d2.
NFA_D_MAX		FHEADER, "DMAX", NFA_D_ABS, COMPILE
CFA_D_MAX		DW	CF_D_MAX
CF_D_MAX		NEXT

;DMIN ( d1 d2 -- d3 )
;d3 is the lesser of d1 and d2.
NFA_D_MIN		FHEADER, "DMIN", NFA_D_MAX, COMPILE
CFA_D_MIN		DW	CF_D_MIN
CF_D_MIN		NEXT

;DNEGATE ( d1 -- d2 )
;d2 is the negation of d1.
NFA_D_NEGATE		FHEADER, "DNEGATE", NFA_D_MIN, COMPILE
CFA_D_NEGATE		DW	CF_D_NEGATE
CF_D_NEGATE		NEXT

;
;M*/ ( d1 n1 +n2 -- d2 )
;Multiply d1 by n1 producing the triple-cell intermediate result t. Divide t by
;+n2 giving the double-cell quotient d2. An ambiguous condition exists if +n2 is
;zero or negative, or the quotient lies outside of the range of a
;double-precision signed integer.
NFA_M_STAR_SLASH	FHEADER, "M*/", NFA_D_NEGATE, COMPILE
CFA_M_STAR_SLASH	DW	CF_M_STAR_SLASH
CF_M_STAR_SLASH		NEXT

;M+ 
;m-plus DOUBLE 
;	( d1|ud1 n -- d2|ud2 )
;Add n to d1|ud1, giving the sum d2|ud2.
NFA_M_PLUS		FHEADER, "M+", NFA_M_STAR_SLASH, COMPILE
CFA_M_PLUS		DW	CF_M_PLUS
CF_M_PLUS		NEXT

;2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;top of the stack.
NFA_TWO_ROT		FHEADER, "2ROT", NFA_M_PLUS, COMPILE
CFA_TWO_ROT		DW	CF_TWO_ROT
CF_TWO_ROT		NEXT

;DU< ( ud1 ud2 -- flag )
;flag is true if and only if ud1 is less than ud2.
NFA_D_U_LESS		FHEADER, "DU<", NFA_TWO_ROT, COMPILE
CFA_D_U_LESS		DW	CF_D_U_LESS
CF_D_U_LESS		NEXT
	
FDOUBLE_WORDS_END		EQU	*
FDOUBLE_LAST_NFA		EQU	NFA_D_U_LESS
