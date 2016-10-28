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

;HLD			DS	2	;pointer for pictured numeric output
;PAD                     DS	2	;end of the PAD buffer

FPAD_VARS_END		EQU	*
FPAD_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FPAD_INIT, 0
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











	



	
;
;;Search word in dictionary
;; args:   X: string pointer
;;         D: char count 
;; result: C-flag: set if word is in the dictionary	
;;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
;; SSTACK: 16  bytes
;;         X and Y are preserved 
;FPAD_SEARCH		EQU	*
;
;
;	;;TBD 
;
;
;	
;;PAD_ALLOC: allocate the PAD buffer (PAD_SIZE bytes if possible) (PAD -> D)
;; args:   none
;; result: D: PAD (= HLD), $0000 if no space is available
;; SSTACK: 2
;;        X and Y are preserved 
;FPAD_PAD_ALLOC	EQU	*
;			;Calculate available space
;			LDD	PSP
;			SUBD	CP
;			;BLS	FPAD_PAD_ALLOC_4 	;no space available at all
;			;Check if requested space is available
;			CPD	#(PAD_SIZE+PS_PADDING)
;			BLO	FPAD_PAD_ALLOC_3	;reduce size
;			LDD	CP
;			ADDD	#PAD_SIZE
;			;Allocate PAD
;FPAD_PAD_ALLOC_1	STD	PAD
;			STD	HLD
;			;Done 
;FPAD_PAD_ALLOC_2	SSTACK_PREPULL	2
;			RTS
;			;Reduce PAD size 
;FPAD_PAD_ALLOC_3	CPD	#(PAD_MINSIZE+PS_PADDING)
;			BLO	FPAD_PAD_ALLOC_4		;not enough space available
;			LDD	PSP
;			SUBD	#PS_PADDING
;			JOB	FPAD_PAD_ALLOC_1 		;allocate PAD
;			;Not enough space available
;FPAD_PAD_ALLOC_4	LDD 	$0000 				;signal failure
;			JOB	FPAD_PAD_ALLOC_2		;done
;
;;Code fields:
;;============
;
;;Exceptions:
;;===========
;;Standard exceptions
;#ifndef FPAD_NO_CHECK
;#ifdef FPAD_DEBUG
;FIDICT_THROW_DICTOF	BGND					;parameter stack overflow
;FIDICT_THROW_PADOF	BGND					;PAD overflow
;#else
;FPAD_THROW_DICTOF	THROW	FEXCPT_EC_DICTOF		;parameter stack overflow
;FPAD_THROW_PADOF	THROW	FEXCPT_EC_PADOF			;PAD overflow
;#endif
;#endif
;
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

FPAD_TABS_END		EQU	*
FPAD_TABS_END_LIN	EQU	@
#endif
