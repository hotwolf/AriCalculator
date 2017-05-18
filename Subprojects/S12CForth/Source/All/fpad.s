#ifndef FPAD_COMPILED
#define FPAD_COMPILED
;###############################################################################
;# S12CForth- FPAD - Scratch pad                                               #
;###############################################################################
;#    Copyright 2009-2016 Dirk Heisswolf                                       #
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
;#    This module implements the volatile user dictionary, user variables, and #
;#    the PAD.                                                                 #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    The following registers are implemented:                                 #
;#            HLD = Pointer for pictured numeric output			       #
;#                  Points to the first character on the PAD                   #
;#                                                                             #
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
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;#    October 16, 2016                                                         #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    FEXCPT - Forth Exception Handler                                         #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;        
;      	                    +--------------+--------------+	     
;         UDICT_PS_START -> |                             | 	     
;                           |     NVDICT Variables        |	     
;                           |                             | <- [DP]	     
;                           | --- --- --- --- --- --- --- |          
;                           |              |              |	     
;                           |       User Dictionary       |	     
;                           |       User Variables        |	     
;                           |              |              | <- [UDICT_LAST_NFA]	     
;                           |              v              |	     
;                       -+- | --- --- --- --- --- --- --- |
;             UDICT_PADDING |                             | <- [CP]	     
;                       -+- | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [HLD]	     
;                           |             PAD             |	     
;                       -+- | --- --- --- --- --- --- --- |          
;             PS_PADDING |  |                             | <- [PAD]          
;                       -+- .                             .          
;                           .                             .          
;                           | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [PSP]	  
;                           |              |              |		  
;                           |       Parameter stack       |		  
;    	                    |              |              |		  
;                           +--------------+--------------+        
;              PS_EMPTY, ->   
;          UDICT_PS_END
;	
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FPAD_VARS_START_LIN
	ORG 	FPAD_VARS_START, FPAD_VARS_START_LIN
#else
			ORG 	FPAD_VARS_START
FPAD_VARS_START_LIN	EQU	@
#endif

HLD			DS	2	;pointer for pictured numeric output
PAD                     DS	2	;end of the PAD buffer

FPAD_VARS_END		EQU	*
FPAD_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FPAD_INIT, 0
			MOVW	#$0000, HLD
			MOVW	#$0000, PAD
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FPAD_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FPAD_QUIT, 0
#emac

;#System integrity monitor
;=========================
#macro	FPAD_MON, 0
#emac

;;#Initialization
;#macro	FPAD_INIT, 0
;;#ifndef FNVDICT_INFO
;;			;Initialize the compile data pointer
;;			MOVW	#UDICT_PS_START, CP
;;	
;;	
;;			MOVW	#0000, UDICT_LAST_NFA
;;			LDD	#UDICT_PS_START
;;			STD	CP
;;			STD	CP_SAVED
;;	
;;			;Initialize PAD (DICT_START in D)
;;			STD	PAD 		;Pad is allocated on demand
;;			STD	HLD
;;
;#emac
;
;;#Abort action (to be executed in addition of quit action)
;#macro	FPAD_ABORT, 0
;#emac
;	
;;#Quit action
;#macro	FPAD_QUIT, 0
;#emac
;	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FPAD_CODE_START_LIN
			ORG 	FPAD_CODE_START, FPAD_CODE_START_LIN
#else
			ORG 	FPAD_CODE_START
FPAD_CODE_START_LIN	EQU	@
#endif


;#########
;# Words #
;#########

;<# ( -- )
;Initialize the pictured numeric output conversion process.
;CF_LESS_NUMBER_SIGN	PAD_ALLOC
;			NEXT



;#> ( xd -- c-addr u )
;Drop xd. Make the pictured numeric output string available as a character
;string. c-addr and u specify the resulting character string. A program may
;replace characters within the string. 
;CF_NUMBER_SIGN_GREATER		EQU	*	
;				;Check PAD length (PSP in Y)
;				LDD	PAD					;PAD-HLD -> u
;				TFR	D, X
;				SUBD	HLD
;				STD	0,Y
;				BEQ	CF_NUMBER_SIGN_GREATER_2 		;zero length string
;				;Terminate string (PSP in Y, PAD in X)
;				BSET	1,X, #$80 				;set termination bit in last characer
;				;Return string pointer (PSP in Y, PAD in X)
;				MOVW	HLD, 2,Y				;HLD -> c-addr
;				;Done
;CF_NUMBER_SIGN_GREATER_1	NEXT
;				;Zero-length string (PSP in Y, PAD in X, 0 in D)
;CF_NUMBER_SIGN_GREATER_2	STD	2,Y
;				JOB	CF_NUMBER_SIGN_GREATER_1





;Word: # ( ud1 -- ud2 )
;Divide ud1 by the number in BASE giving the quotient ud2 and the remainder n.
;(n is the least-significant digit of ud1.) Convert n to external form and add
;the resulting character to the beginning of the pictured numeric output string.
;An ambiguous condition exists if # executes outside of a <# #> delimited number
;conversion.
IF_NUMBER_SIGN			REGULAR
CF_NUMBER_SIGN			EQU	*
				;Get BASE 
				JOBSR	FOUTER_GET_BASE			;BASE     -> B
				SEX	B, X 				;BASE     -> X
				LDD	0,Y 				;ud1(MSW) -> D
				IDIV					;D/X=>X; remainder=D




	
;CF_NUMBER_SIGN			EQU	*
;				BASE_CHECK	CF_NUMBER_SIGN_INVALBASE;check BASE value (BASE -> D)
;				;Perform division (PSP in Y, BASE in D)
;				TFR	D,X				;prepare 1st division
;				LDD	0,Y				; (ud1>>16)/BASE
;				IDIV					;D/X=>X; remainder=D
;				STX	0,Y				;return upper word of the result
;				LDX	BASE				;prepare 2nd division
;				LDY	2,Y
;				EXG	D,Y
;				EDIV					;Y:D / X -> Y; remainder -> D
;				LDX	PSP				;PSP -> X
;				STY	2,X
;				;Lookup ASCII representation of the remainder (remainder -> D)
;				TFR	D,X
;				LDAB	FCORE_SYMTAB,X
;				;Add ASCII character to the PAD buffer
;				PAD_CHECK_OF	CF_NUMBER_SIGN_PADOF	;check for PAD overvlow (HLD -> X)
;				STAB	1,-X
;				STX	HLD
;				NEXT






;#S ( ud1 -- ud2 )
;Convert one digit of ud1 according to the rule for #. Continue conversion
;until the quotient is zero. ud2 is zero. An ambiguous condition exists if #S
;executes outside of a <# #> delimited number conversion.
;CF_NUMBER_SIGN_S		PS_CHECK_UF	2					;check for underflow  (PSP -> Y)
;				BASE_CHECK	CF_NUMBER_SIGN_S_INVALBASE		;check BASE value (BASE -> D)
;				;Perform division (PSP in Y, BASE in D)
;CF_NUMBER_SIGN_S_1		TFR	D,X						;prepare 1st division
;				LDD	0,Y						; (ud1>>16)/BASE
;				IDIV							;D/X=>X; remainder=D
;				STX	0,Y						;return upper word of the result
;				LDX	BASE						;prepare 2nd division
;				LDY	2,Y
;				EXG	D,Y
;				EDIV							;Y:D/X=>Y; remainder=>D
;				LDX	PSP						;PSP -> X
;				STY	2,X
;				;Lookup ASCII representation of the remainder (LSB of quotient in Y, remainder in D)
;				TFR	D,X
;				LDAB	FCORE_SYMTAB,X
;				;Add ASCII character to the PAD buffer (LSB of quotient in Y)
;				PAD_CHECK_OF	CF_NUMBER_SIGN_S_PADOF			;check for PAD overvlow (HLD -> X)
;				STAB	1,-X
;				STX	HLD
;				;Check if quotient is zero
;				LDD	BASE
;				LDY	PSP
;				LDX	2,Y
;				BNE	CF_NUMBER_SIGN_S_1
;				LDX	0,Y
;				BNE	CF_NUMBER_SIGN_S_1
;				;Quotient is zero
;				NEXT
;
;CF_NUMBER_SIGN_S_PADOF		JOB	FCORE_THROW_PADOF
;CF_NUMBER_SIGN_S_INVALBASE	JOB	FCORE_THROW_INVALBASE


;HOLD ( char -- )
;Add char to the beginning of the pictured numeric output string. An ambiguous
;condition exists if HOLD executes outside of a <# #> delimited number
;conversion.
;CF_HOLD			PS_CHECK_UF	1, CF_HOLD_PSUF ;check for underflow	(PSP -> Y)
;				PAD_CHECK_OF	CF_HOLD_PADOF	;check for PAD overvlow (HLD -> X)
;				;Add ASCII character to the PAD buffer (PSP -> Y, HLD -> X)
;				LDD	2,Y+
;				STAB	1,-X
;				STX	HLD
;				STY	PSP
;				NEXT



	


FPAD_CODE_END		EQU	*
FPAD_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FPAD_TABS_START_LIN
			ORG 	FPAD_TABS_START, FPAD_TABS_START_LIN
#else
			ORG 	FPAD_TABS_START
FPAD_TABS_START_LIN	EQU	@
#endif	

;Environment: /HOLD ( -- n true)
;Size of the pictured numeric output string buffer, in characters
ENV_HOLD		DW	FENV_SINGLE
			DW	32767

;Environment: /PAD ( -- n true)
;Size of the scratch area pointed to by PAD, in characters
ENV_PAD			DW	FENV_SINGLE
			DW	0000






	
FPAD_TABS_END		EQU	*
FPAD_TABS_END_LIN	EQU	@
#endif
