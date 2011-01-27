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
FDOUBLE_THROW_RESOR	EQU	FCORE_THROW_RESOR		;result out of range
FDOUBLE_THROW_0DIV	EQU	FCORE_THROW_0DIV		;division by zero
FDOUBLE_THROW_INVALBASE	EQU	FCORE_THROW_INVALBASE		;invalid BASE value
FDOUBLE_THROW_INVALNUM	EQU	FCORE_THROW_INVALNUM		;invalid numeric argument

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

;#Double-Number words (DOUBLE):
; =============================
	
;2CONSTANT ( x1 x2 "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name with the execution semantics defined below.
;name is referred to as a two-constant.
;name Execution: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Missing name argument"
;"Dictionary overflow"
			ALIGN	1
NFA_TWO_CONSTANT	FHEADER, "2CONSTANT", FDOUBLE_PREV_NFA, COMPILE
CFA_TWO_CONSTANT	DW	CF_TWO_CONSTANT
CF_TWO_CONSTANT		PS_CHECK_UF 1, CF_TWO_CONSTANT_PSUF	;(PSP -> Y)
			;Build header (PSP -> Y)
			SSTACK_JOBSR	FCORE_HEADER ;NFA -> D, error handler -> X(SSTACK: 10  bytes)
			TBNE	X, CF_TWO_CONSTANT_ERROR
			DICT_CHECK_OF	6, CF_TWO_CONSTANT_DICTOF	;CP+6 -> X
			;Update LAST_NFA (PSP in Y, CP+6 in X)
			STD	LAST_NFA
			;Append CFA (PSP in Y, CP+6 in X)
			MOVW	#CF_TWO_CONSTANT_RT, -6,X
			;Append constant value (PSP in Y, CP in X)
			MOVW	2,Y+, -4,X
			MOVW	2,Y+, -2,X
			STX	CP
			STY	PSP
			;Update CP saved
			STX	CP_SAVED
			;Done 
			NEXT
			;Error handler for FCORE_HEADER 
CF_TWO_CONSTANT_ERROR	JMP	0,X

CF_TWO_CONSTANT_PSUF	JOB	FCORE_THROW_PSUF
CF_TWO_CONSTANT_DICTOF	JOB	FCORE_THROW_DICTOF

;2CONSTANT run-time semantics
;Push the contents of the first cell after the CFA onto the parameter stack
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
CF_TWO_CONSTANT_RT	PS_CHECK_OF	2, CF_TWO_CONSTANT_PSOF	;overflow check	=> 9 cycles
			MOVW		4,X, 2,Y		;[CFA+4] -> PS	=> 5 cycles
			MOVW		2,X, 0,Y		;[CFA+2] -> PS	=> 5 cycles
			STY		PSP			;		=> 3 cycles
			NEXT					;NEXT		=>15 cycles
								; 		  ---------
								;		  37 cycles
CF_TWO_CONSTANT_PSOF	JOB	FCORE_THROW_PSOF		;
	
;2LITERAL (actually part of the ANS Forth double number waid set)
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( x1 x2 -- )
;Append the run-time semantics below to the current definition.
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"
;
			ALIGN	1
NFA_TWO_LITERAL		FHEADER, "2LITERAL", NFA_TWO_CONSTANT, IMMEDIATE
CFA_TWO_LITERAL		DW	CF_TWO_LITERAL
			DW	CFA_TWO_LITERAL_RT
CF_TWO_LITERAL		COMPILE_ONLY	CF_TWO_LITERAL_COMPONLY ;ensure that compile mode is on
			PS_CHECK_UF	1, CF_TWO_LITERAL_PSUF	;(PSP -> Y)
			LDD	2,X
			DICT_CHECK_OF	6, CF_TWO_LITERAL_DICTOF	;(CP+6 -> X)
			;Add run-time CFA to compilation (CP+6 in X, PSP in Y, run-time CFA in D)
			STD	 -6,X
			;Add TOS to compilation (CP+6 in X, PSP in Y, run-time CFA in D)
			MOVW	2,Y+,	-4,X
			MOVW	2,Y+,	-2,X
			STX	CP
			STY	PSP
			;Done 
			NEXT

CF_TWO_LITERAL_PSOF	JOB	FCORE_THROW_PSOF
CF_TWO_LITERAL_PSUF	JOB	FCORE_THROW_PSUF
CF_TWO_LITERAL_DICTOF	JOB	FCORE_THROW_DICTOF	
CF_TWO_LITERAL_COMPONLY	JOB	FCORE_THROW_COMPONLY
	
;2LITERAL run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
			ALIGN	1
CFA_TWO_LITERAL_RT	DW	CF_TWO_LITERAL_RT
CF_TWO_LITERAL_RT	PS_CHECK_OF	2, CF_TWO_LITERAL_PSOF 	;check for PS overflow (PSP-new cells -> Y)
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
;
;S12CForth implementation details:
;Throws:
;"Missing name argument"
;"Dictionary overflow"
			ALIGN	1
NFA_TWO_VARIABLE	FHEADER, "2VARIABLE", NFA_TWO_LITERAL, COMPILE
CFA_TWO_VARIABLE	DW	CF_TWO_VARIABLE
CF_TWO_VARIABLE		;Build header
			SSTACK_JOBSR	FCORE_HEADER 			;NFA -> D, error handler -> X (SSTACK: 10  bytes)
			TBNE	X, CF_TWO_VARIABLE_ERROR
			DICT_CHECK_OF	6, CF_TWO_VARIABLE_DICTOF	;CP+6 -> X
			;Update LAST_NFA 
			STD	LAST_NFA
			;Append CFA 
			MOVW	#CF_TWO_VARIABLE_RT, -6,X
			;Append variable space (CP in X)
			MOVW	#$0000, -4,X
			MOVW	#$0000, -2,X
			STX	CP
			;Update CP saved (CP in X)
			STX	CP_SAVED
			;Done 
			NEXT
			;Error handler for FCORE_HEADER 
CF_TWO_VARIABLE_ERROR	JMP	0,X

CF_TWO_VARIABLE_PSOF	JOB	FCORE_THROW_PSOF
CF_TWO_VARIABLE_DICTOF	JOB	FCORE_THROW_DICTOF

;Run-time of VARIABLE
;Throws:
;"Parameter stack overflow"
CF_TWO_VARIABLE_RT	EQU	CF_VARIABLE_RT		
	
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
			;Add LSWs (PSP -> Y)
			LDD	6,Y
			ADDD	2,Y
			STD	6,Y
			;Add MSWs (PSP -> Y)
			LDD	4,Y
			ADCB	1,Y
			ADCA	0,Y
			STD	4,+Y
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
			;Subtract LSWs (PSP -> Y)
			LDD	6,Y
			SUBD	2,Y
			STD	6,Y
			;Subtract MSWs (PSP -> Y)
			LDD	4,Y
			SBCB	1,Y
			SBCA	0,Y
			STD	4,+Y
			STY	PSP
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
			PRINT_SPC 			;print one space
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
			;Get width (PSP in Y, BASE in D)
			TST	0,Y
			BNE	CF_D_DOT_R_2 		;saturate width
			LDAA	1,Y
			;Get number (PSP in Y, width in A, BASE in B)
CF_D_DOT_R_1		LEAY	6,Y
			STY	PSP
			LDX	-2,Y
			LDY	-4,Y
			;Print number (PSP in Y, width in A, BASE in B)
			PRINT_RSDBL
			NEXT
			;Saturate n (PSP in Y, BASE in D)
CF_D_DOT_R_2		LDAA	$FF
			JOB	CF_D_DOT_R_1
				
CF_D_DOT_R_PSUF		JOB	FDOUBLE_THROW_PSUF
CF_D_DOT_R_INVALBASE	JOB	FDOUBLE_THROW_INVALBASE
	
;D0< ( d -- flag )
;flag is true if and only if d is less than zero.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_ZERO_LESS	FHEADER, "D0<", NFA_D_DOT_R, COMPILE
CFA_D_ZERO_LESS	DW	CF_D_ZERO_LESS
CF_D_ZERO_LESS		PS_CHECK_UF 2, CF_D_ZERO_LESS_PSUF 	;check for underflow (PSP -> Y)
			;Check MSB (PSP in Y)
			LDD	0,Y
			BPL	CF_D_ZERO_LESS_2 		;false	
			;True (PSP in Y)
			LDD	#$FFFF
CF_D_ZERO_LESS_1	STD	2,+Y
			STY	PSP
			;Done
			NEXT
			;False (PSP in Y)
CF_D_ZERO_LESS_2	LDD	#$0000
			JOB	CF_D_ZERO_EQUALS_1

CF_D_ZERO_LESS_PSUF	JOB	FDOUBLE_THROW_PSUF

;D0= ( xd -- flag )
;flag is true if and only if xd is equal to zero.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_ZERO_EQUALS	FHEADER, "D0=", NFA_D_ZERO_LESS, COMPILE
CFA_D_ZERO_EQUALS	DW	CF_D_ZERO_EQUALS
CF_D_ZERO_EQUALS	PS_CHECK_UF 2, CF_D_ZERO_EQUALS_PSUF 	;check for underflow (PSP -> Y)
			;Check MSW (PSP in Y)
			LDD	0,Y
			BNE	CF_D_ZERO_EQUALS_2 		;false
			LDD	2,Y
			BNE	CF_D_ZERO_EQUALS_2 		;false
			;True (PSP in Y)
			LDD	#$FFFF
CF_D_ZERO_EQUALS_1	STD	2,+Y
			STY	PSP
			;Done
			NEXT
			;False (PSP in Y)
CF_D_ZERO_EQUALS_2	LDD	#$0000
			JOB	CF_D_ZERO_EQUALS_1

CF_D_ZERO_EQUALS_PSUF	JOB	FDOUBLE_THROW_PSUF
	
;D2* ( xd1 -- xd2 )
;xd2 is the result of shifting xd1 one bit toward the most-significant bit,
;filling the vacated least-significant bit with zero.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_TWO_STAR		FHEADER, "D2*", NFA_D_ZERO_EQUALS, COMPILE
CFA_D_TWO_STAR		DW	CF_D_TWO_STAR
CF_D_TWO_STAR		PS_CHECK_UF 2, CF_D_TWO_STAR_PSUF 	;check for underflow (PSP -> Y)
			;Shift LSW (PSP in Y)
			LDD	2,Y
			LSLD
			STD	2,Y
			;Shift MSW (PSP in Y)
			LDD	0,Y
			ROLB
			ROLA
			STD	0,Y
			;Done
			NEXT

CF_D_TWO_STAR_PSUF	JOB	FDOUBLE_THROW_PSUF

;D2/ ( xd1 -- xd2 )
;xd2 is the result of shifting xd1 one bit toward the least-significant bit,
;leaving the most-significant bit unchanged.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_TWO_SLASH		FHEADER, "D2/", NFA_D_TWO_STAR, COMPILE
CFA_D_TWO_SLASH		DW	CF_D_TWO_SLASH
CF_D_TWO_SLASH		PS_CHECK_UF 2, CF_D_TWO_SLASH_PSUF 	;check for underflow (PSP -> Y)
			;Shift MSW (PSP in Y)
			LDD	0,Y
			ASRA
			RORB
			STD	0,Y
			;Shift LSW (PSP in Y)
			LDD	2,Y
			RORA
			RORB
			STD	2,Y
			;Done
			NEXT

CF_D_TWO_SLASH_PSUF	JOB	FDOUBLE_THROW_PSUF
	
;D< ( d1 d2 -- flag )
;flag is true if and only if d1 is less than d2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_LESS_THAN		FHEADER, "D<", NFA_D_TWO_SLASH, COMPILE
CFA_D_LESS_THAN		DW	CF_D_LESS_THAN
CF_D_LESS_THAN		PS_CHECK_UF 2, CF_D_LESS_THAN_PSUF 	;check for underflow (PSP -> Y)
			;Compare MSWs (PSP in Y)
			LDD	4,Y
			CPD	0,Y
			BLT	CF_D_LESS_THAN_1		;true
			BGT	CF_D_LESS_THAN_3		;false
			;MSWs are equal (MSW in D, PSP in Y)
			TSTA
			BMI	CF_D_LESS_THAN_4 		;d1 and d2 are negative
			;d1 and d2 are positive (PSP in Y)
			LDD	6,Y
			CPD	2,Y
			BHS	CF_D_LESS_THAN_3		;false	
			;TRUE (PSP in Y)
CF_D_LESS_THAN_1	LDD	#$FFFF
CF_D_LESS_THAN_2	STD	6,+Y 				;Return result
			STY	PSP
			;Done
			NEXT
			;FALSE (PSP in Y)
CF_D_LESS_THAN_3	CLRA
			CLRB
			JOB	CF_D_LESS_THAN_2	
			;d1 and d2 are negative
CF_D_LESS_THAN_4	LDD	6,Y
			CPD	2,Y
			BLS	CF_D_LESS_THAN_3		;false	
			JOB	CF_D_LESS_THAN_1		;true
	
CF_D_LESS_THAN_PSUF	JOB	FDOUBLE_THROW_PSUF

;D= ( xd1 xd2 -- flag )
;flag is true if and only if xd1 is bit-for-bit the same as xd2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_EQUALS		FHEADER, "D=", NFA_D_LESS_THAN, COMPILE
CFA_D_EQUALS		DW	CF_D_EQUALS
CF_D_EQUALS		PS_CHECK_UF 4, CF_D_EQUALS_PSUF 	;check for underflow (PSP -> Y)
			;Compare MSWs (PSP in Y)
			LDD	4,Y
			CPD	0,Y
			BEQ	CF_D_EQUALS_3			;compare LSWs
			;False (PSP in Y)
CF_D_EQUALS_1		LDD	#$0000
CF_D_EQUALS_2		STD	6,+Y
			STY	PSP
			;Done
			NEXT
			;Compare LSWs (PSP in Y)
CF_D_EQUALS_3		LDD	6,Y
			CPD	2,Y
			BNE	CF_D_EQUALS_1
			;True (PSP in Y)
			LDD	#$FFFF
			JOB	CF_D_EQUALS_2
	
CF_D_EQUALS_PSUF	JOB	FDOUBLE_THROW_PSUF

;D>S  ( d -- n )
;n is the equivalent of d. An ambiguous condition exists if d lies outside the
;range of a signed single-cell number.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Result out of range"
;
			ALIGN	1
NFA_D_TO_S		FHEADER, "D>S", NFA_D_EQUALS, COMPILE
CFA_D_TO_S		DW	CF_D_TO_S
CF_D_TO_S		PS_CHECK_UF 2, CF_D_ABS_PSUF 	;check for underflow (PSP -> Y)
			;Check MSW of d (PSP in Y) 
			LDD	2,Y+
			CPD	#$FFFF
			BEQ	CF_D_TO_S_2 		;LSW must be negative
			CPD	#$0000
			BNE	CF_D_TO_S_RESOR		;result is out of range
			;LSW must be positive (new PSP in Y)
			LDD	0,Y
			BMI	CF_D_TO_S_RESOR		;result is out of range			
			;Done (new PSP in Y)
CF_D_TO_S_1		STY	PSP
			NEXT
			;LSW must be positive (new PSP in Y)
CF_D_TO_S_2		LDD	0,Y
			BMI	CF_D_TO_S_1		;result is within range			
			;JOB	CF_D_TO_S_RESOR		;result is out of range	
	
CF_D_TO_S_RESOR		JOB	FDOUBLE_THROW_RESOR
CF_D_TO_S_PSUF		JOB	FDOUBLE_THROW_PSUF
	
;DABS ( d -- ud )
;ud is the absolute value of d.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_ABS		FHEADER, "DABS", NFA_D_TO_S, COMPILE
CFA_D_ABS		DW	CF_D_ABS
CF_D_ABS		PS_CHECK_UF 2, CF_D_ABS_PSUF 	;check for underflow (PSP -> Y)
			;Check sign of d (PSP in Y) 
			BRCLR	0,Y, #$80, CF_D_ABS_1
			JOB	CF_D_NEGATE_1
			;Done
CF_D_ABS_1		NEXT
	
CF_D_ABS_PSUF		JOB	FDOUBLE_THROW_PSUF

;DMAX ( d1 d2 -- d3 )
;d3 is the greater of d1 and d2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_MAX		FHEADER, "DMAX", NFA_D_ABS, COMPILE
CFA_D_MAX		DW	CF_D_MAX
CF_D_MAX		PS_CHECK_UF 4, CF_D_MAX_PSUF 	;check for underflow (PSP -> Y)
			;Compare MSWs (PSP in Y) 
			LDD	4,+Y
			STY	PSP
			CPD	0,Y
			BEQ	CF_D_MAX_2 		;compare LSWs
			BLT	CF_D_MAX_1		;d1 is the lesser value
			STD	0,Y			;copy d2 to d3
			MOVW	-2,Y, 2,Y
			;Done
CF_D_MAX_1		NEXT	
			;Compare MSWs (new PSP in Y) 
CF_D_MAX_2		LDD	-2,Y
			CPD	2,Y
			BLT	CF_D_MAX_1		;d1 is the lesser value
			STD	2,Y			;copy d2 to d3
			MOVW	-4,Y, 0,Y
			JOB	CF_D_MAX_1
	
CF_D_MAX_PSUF		JOB	FDOUBLE_THROW_PSUF

;DMIN ( d1 d2 -- d3 )
;d3 is the lesser of d1 and d2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_MIN		FHEADER, "DMIN", NFA_D_MAX, COMPILE
CFA_D_MIN		DW	CF_D_MIN
CF_D_MIN		PS_CHECK_UF 4, CF_D_MIN_PSUF 	;check for underflow (PSP -> Y)
			;Compare MSWs (PSP in Y) 
			LDD	4,+Y
			STY	PSP
			CPD	0,Y
			BEQ	CF_D_MIN_2 		;compare LSWs
			BGT	CF_D_MIN_1		;d1 is the lesser value
			STD	0,Y			;copy d2 to d3
			MOVW	-2,Y, 2,Y
			;Done
CF_D_MIN_1		NEXT	
			;Compare MSWs (new PSP in Y) 
CF_D_MIN_2		LDD	-2,Y
			CPD	2,Y
			BGT	CF_D_MIN_1		;d1 is the lesser value
			STD	2,Y			;copy d2 to d3
			MOVW	-4,Y, 0,Y
			JOB	CF_D_MIN_1
	
CF_D_MIN_PSUF		JOB	FDOUBLE_THROW_PSUF
	
;DNEGATE ( d1 -- d2 )
;d2 is the negation of d1.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_NEGATE		FHEADER, "DNEGATE", NFA_D_MIN, COMPILE
CFA_D_NEGATE		DW	CF_D_NEGATE
CF_D_NEGATE		PS_CHECK_UF 2, CF_D_NEGATE_PSUF 	;check for underflow (PSP -> Y)
			;Calculate 2's complement of the PS entry (PSP in Y)
CF_D_NEGATE_1		LDD	0,Y 				;invert MSW
			COMA
			COMB
			TFR	D,X
			LDD	2,Y 				;invert LSW
			COMA
			COMB
			ADDD	#1 				;increment LSW
			EXG	D,X				;add carry to MSW
			ADCB	#0
			ADCA	#0
			STD	0,Y
			STX	2,Y
			;Done
			NEXT
	
CF_D_NEGATE_PSUF	JOB	FDOUBLE_THROW_PSUF
	
;
;M*/ ( d1 n1 +n2 -- d2 ) CHECK!
;Multiply d1 by n1 producing the triple-cell intermediate result t. Divide t by
;+n2 giving the double-cell quotient d2. An ambiguous condition exists if +n2 is
;zero or negative, or the quotient lies outside of the range of a
;double-precision signed integer.
;
;S12CForth implementation details:
;+n2 may be negative 
;Throws:
;"Parameter stack underflow"
;"Divide by zero"
;"Quotient out of range"
;"Invalid numeric argument" (only if +n2 must not be negative)
;
CF_M_STAR_SLASH_RESOR		JOB	FDOUBLE_THROW_RESOR
CF_M_STAR_SLASH_0DIV		JOB	FDOUBLE_THROW_0DIV
CF_M_STAR_SLASH_INVALNUM	EQU	FDOUBLE_THROW_INVALNUM
CF_M_STAR_SLASH_PSUF		JOB	FDOUBLE_THROW_PSUF

			ALIGN	1
NFA_M_STAR_SLASH	FHEADER, "M*/", NFA_D_NEGATE, COMPILE
CFA_M_STAR_SLASH	DW	CF_M_STAR_SLASH
CF_M_STAR_SLASH		PS_CHECK_UF	4, CF_M_STAR_SLASH_PSUF ;check for underflow (PSP -> Y)
			;Check +n2 (PSP in Y)
			LDD	0,Y		 		;+n2 -> D
			BEQ	CF_M_STAR_SLASH_0DIV 		;division by zero
			;BMI	CF_M_STAR_SLASH_INVALNUM	;+n2 is negative
			;Allocate temporary memory (PSP in Y)
			SSTACK_ALLOC	6		;allocate 6 bytes
			;+--------+--------+
			;|   Result (MSW)  | <-SP
			;+--------+--------+
			;|   Result        | +2
			;+--------+--------+
			;|   Result (LSW)  | +4
			;+--------+--------+
			MOVW	#$0000, 0,SP
			;Multiply LSW (PSP in Y)
			LDD	2,Y 				;n1      -> D
			LDY	6,Y				;d1(LSW) -> Y
			EMULS					;Y * D => Y:D
			BPL	CF_M_STAR_SLASH_1		;result is positive
			MOVW	#$FFFF, 0,SP
CF_M_STAR_SLASH_1	STY	2,SP				;n1      -> D
			STD	4,SP				;d1(LSW) -> Y
			;Multiply LSW
			LDY	PSP
			LDD	2,Y 				;n1      -> D
			LDY	4,Y				;d1(MSW) -> Y
			EMULS					;Y * D => Y:D
			ADDD	2,SP
			STD	2,SP
			EXG	Y, D
			ADCB	1,SP
			ADCA	0,SP
			STD	0,SP
			EXG	Y, D
			;Divide MSW by +n2 (Result (MSW) in Y:D)
			LDX	[PSP]		 		;+n2 -> X
			EDIVS					;Y:D/X=>Y; remainder=>D
			BVS	CF_M_STAR_SLASH_3 		;result is out of range
			LDX	PSP
			STY	4,SP
			;Divide LSW by +n2 (Remainder in D)
			TFR	D, Y
			LDD	4,SP
			LDX	[PSP]		 		;+n2 -> X	
			EDIVS					;Y:D/X=>Y; remainder=>D
			LDX	PSP
			STY	6,X
			;Deallocate temporary memory (PSP in X)
			SSTACK_DEALLOC	6			;deallocate 6 bytes
			;Adjust PS (PSP in X)
			LEAY	4,X
			STY	PSP
			;Done
CF_M_STAR_SLASH_2	NEXT
			;Result out of range
CF_M_STAR_SLASH_3	SSTACK_DEALLOC	6		
			JOB	CF_M_STAR_SLASH_RESOR

;M+ ( d1|ud1 n -- d2|ud2 )
;Add n to d1|ud1, giving the sum d2|ud2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_M_PLUS		FHEADER, "M+", NFA_M_STAR_SLASH, COMPILE
CFA_M_PLUS		DW	CF_M_PLUS
CF_M_PLUS		PS_CHECK_UF 3, CF_M_PLUS_PSUF 	;check for underflow (PSP -> Y)
			;Add PS entries (PSP in Y)
			LDD	2,Y+ 			;n -> D
			STY	PSP
			ADDD	2,Y 			;n + d1 -> D
			STD	2,Y
			LDD	0,Y 			;C + d2 -> D
			ADCB	#0
			ADCA	#0
			STAA	0,Y
			;Done
			NEXT

CF_M_PLUS_PSUF		JOB	FDOUBLE_THROW_PSUF


;#Double-Number extension words (DOUBLE):
; =======================================
	
;2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;top of the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_TWO_ROT		FHEADER, "2ROT", NFA_M_PLUS, COMPILE
CFA_TWO_ROT		DW	CF_TWO_ROT
CF_TWO_ROT		PS_CHECK_UF 6, CF_TWO_ROT_PSUF 	;check for underflow (PSP -> Y)
			;Swap PS entries (PSP in Y)
			LDD	10,Y 			;save  x1
			MOVW	 6,Y, 10,Y		;x3 -> x1
			MOVW	 2,Y,  6,Y		;x5 -> x3
			STD	 2,Y			;x1 -> x5
			LDD	 8,Y 			;save  x2
			MOVW	 4,Y,  8,Y		;x4 -> x2
			MOVW	 0,Y,  4,Y		;x6 -> x4
			STD	 0,Y			;x2 -> x6
			;Done 
			NEXT

CF_TWO_ROT_PSUF	JOB	FDOUBLE_THROW_PSUF

;DU< ( ud1 ud2 -- flag )
;flag is true if and only if ud1 is less than ud2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_D_U_LESS		FHEADER, "DU<", NFA_TWO_ROT, COMPILE
CFA_D_U_LESS		DW	CF_D_U_LESS
CF_D_U_LESS		PS_CHECK_UF 4, CF_D_U_LESS_PSUF 	;check for underflow (PSP -> Y)
			;Compare MSWs (PSP in Y)
			LDD	4,Y
			CPD	0,Y
			BEQ	CF_D_U_LESS_3			;compare LSWs
			BLO	CF_D_U_LESS_4 			;true
			;False (PSP in Y)
CF_D_U_LESS_1		LDD	#$0000
CF_D_U_LESS_2		STD	6,+Y
			STY	PSP
			;Done
			NEXT
			;Compare LSWs (PSP in Y)
CF_D_U_LESS_3		LDD	6,Y
			CPD	2,Y
			BGE	CF_D_U_LESS_1
			;True (PSP in Y)
CF_D_U_LESS_4		LDD	#$FFFF
			JOB	CF_D_U_LESS_2
	
CF_D_U_LESS_PSUF	JOB	FDOUBLE_THROW_PSUF

	
FDOUBLE_WORDS_END	EQU	*
FDOUBLE_LAST_NFA	EQU	NFA_D_U_LESS
