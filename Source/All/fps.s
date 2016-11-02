#ifndef FPS_COMPILED
#define FPS_COMPILED
;###############################################################################
;# S12CForth- FPS                                                              #
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
;#    This module implements the parameter stack.                              #
;#                                                                             #
;#    The parameter stack uses these registers:                                #
;#            PSP = Parameter Stack Pointer.				       #
;#	            Points to the top of the parameter stack                   #
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
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;#    October 4, 2016                                                          #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE    - S12CBase framework                                             #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;        
;      	                    +----------+----------+	     
;        UDICT_PS_START, -> |          |          | 	     
;           UDICT_START     |   User Dictionary   |	     
;                           |   User Variables    |	     
;                           |          |          |	     
;                           |          v          |	     
;                       -+- | --- --- --- --- --- |
;             UDICT_PADDING |                     | <- [CP]	     
;                       -+- | --- --- --- --- --- |          
;                           |          ^          | <- [HLD]	     
;                           |         PAD         |	     
;                           | --- --- --- --- --- |          
;                           |                     | <- [PAD]          
;                           .                     .          
;                           .                     .          
;                           | --- --- --- --- --- |          
;                           |          ^          | <- [PSP]	  
;                           |          |          |		  
;                           |   Parameter stack   |		  
;    	                    |          |          |		  
;                           +----------+----------+        
;              PS_EMPTY, ->   
;          UDUCT_PS_END
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Bottom of parameter stack
PS_EMPTY		EQU	UDICT_PS_END-4

;Canary 
FPS_CANARY_MSW		EQU	"Bi"
FPS_CANARY_LSW		EQU	"rd"
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FPS_VARS_START_LIN
			ORG 	FPS_VARS_START, FPS_VARS_START_LIN
#else
			ORG 	FPS_VARS_START

FPS_VARS_START_LIN	EQU	@
#endif	
	
FPS_VARS_END		EQU	*
FPS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FPS_INIT, 0
#emac
	
;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FPS_ABORT, 0
			LDY	#PS_EMPTY 		;reset return stack
			MOVW	#FPS_CANARY_MSW, 0,Y	;insert canary code
			MOVW	#FPS_CANARY_LSW, 2,Y	;
#emac
	
;#Quit action
;============
#macro	FPS_QUIT, 0
#emac
	
;#System integrity monitor
;=========================
#macro	FPS_MON, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FPS_CODE_START_LIN
			ORG 	FPS_CODE_START, FPS_CODE_START_LIN
#else
			ORG 	FPS_CODE_START
FPS_CODE_START_LIN	EQU	@
#endif

;#IO
;===
;#Prints a MSB terminated string
; args:   X:      start of the string
; result: X;      points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FPS_TX_STRING		EQU	STRING_PRINT_BL

;#Print cell value
; args:   D: cell value
; result: none
; SSTACK: 26 bytes
;         X, Y and D are preserved
FPS_TX_CELL		EQU	FOUTER_TX_CELL

;#Count the digits (incl. sign) of cell value
; args:   D: cell value
; result: D: digits (char count)
; SSTACK: 26 bytes
;         X, Y and D are preserved
FPS_CELL_DIGITS		EQU	FOUTER_CELL_DIGITS
	
;#Print a list separator (SPACE or line break)
; args:   D:      char count of next word
;         0,SP:   line counter 
; result: 0,SP;   updated line counter
; SSTACK: 10 bytes
;         Y is preserved
FPS_LIST_SEP		EQU	FOUTER_LIST_SEP
	
;#########
;# Words #
;#########

;Word: ?DUP ( x -- 0 | x x )
;Duplicate x if it is non-zero.
IF_QUESTION_DUP		INLINE	CF_QUESTION_DUP	
CF_QUESTION_DUP		EQU	*
			LDD	0,Y
			BEQ	CF_QUESTION_DUP_1
			STD	2,-Y
CF_QUESTION_DUP_1	RTS	
CF_QUESTION_DUP_EOI	EQU	CF_QUESTION_DUP_1
	
;Word: DUP ( x -- x x )
;Duplicate x.
IF_DUP			INLINE	CF_DUP	
CF_DUP			EQU	*
			MOVW	0,Y, 2,-Y 			;duplicate x 
CF_DUP_EOI 		RTS					;done
	
;Word: DROP ( x -- )
;Remove x from the stack.
IF_DROP			INLINE	CF_DROP
CF_DROP			EQU	*
			LEAY	2,Y				;remove x 
CF_DROP_EOI		RTS					;done

;Word: OVER ( x1 x2 -- x1 x2 x1 )
;Place a copy of x1 on top of the stack.
IF_OVER			INLINE	CF_OVER
CF_OVER			EQU	*
			MOVW	2,Y, 2,-Y 			;duplicate x1 
CF_OVER_EOI		RTS					;done

;Word: 2DUP ( x1 x2 -- x1 x2 x1 x2 )
;Duplicate cell pair x1 x2.
IF_TWO_DUP		INLINE	CF_TWO_DUP
CF_TWO_DUP		EQU	*
			MOVW	2,Y, 2,-Y 			;duplicate x1
			MOVW	2,Y, 2,-Y 			;duplicate x2
CF_TWO_DUP_EOI		RTS					;done

;Word: 2DROP ( x1 x2 -- )
;Drop cell pair x1 x2 from the stack.
IF_TWO_DROP		INLINE	CF_TWO_DROP
CF_TWO_DROP		EQU	*
			LEAY	4,Y				;remove x1 and x2 
CF_TWO_DROP_EOI		RTS					;done
	
;Word: 2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;Copy cell pair x1 x2 to the top of the stack.
IF_TWO_OVER		INLINE	CF_TWO_OVER
CF_TWO_OVER		EQU	*
			MOVW	6,Y, 2,-Y 			;duplicate x1 
			MOVW	6,Y, 2,-Y 			;duplicate x2 
CF_TWO_OVER_EOI		RTS					;done

;Word: SWAP ( x1 x2 -- x2 x1 )
;Exchange the top two stack items.
IF_SWAP			INLINE	CF_SWAP
CF_SWAP			EQU	*
			LDD	0,Y
			MOVW	2,Y, 0,Y
			STD	2,Y
CF_SWAP_EOI		RTS					;done

;Word: 2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;Exchange the top two cell pairs.
IF_TWO_SWAP		REGULAR
CF_TWO_SWAP		EQU	*
			LDD	0,Y 				;save x4
			MOVW	4,Y, 0,Y			;move x2
			STD	4,Y				;store x4
			LDD	2,Y				;save x3
			MOVW	6,Y, 2,Y			;move x1
			STD	6,y				;store x3
			RTS					;done
	
;Word: ROT ( x1 x2 x3 -- x2 x3 x1 )
;Rotate the top three stack entries.
IF_ROT			INLINE	CF_ROT
CF_ROT			EQU	*
			LDD	0,Y				;save x3
			MOVW	4,Y, 0,Y			;move x1
			MOVW	2,Y, 4,Y			;move x2
			STD	2,Y				;store x3
CF_ROT_EOI		RTS					;done

;Word: 2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;top of the stack.
IF_2ROT			REGULAR
CF_2ROT			EQU	*
			LDD	10,Y 				;save x1
			MOVW	6,Y, 10,Y			;move x3
			MOVW	2,Y, 6,Y			;move x5
			STD	2,Y				;store x1
			LDD	8,Y 				;save x2
			MOVW	4,Y, 8,Y			;move x4
			MOVW	0,Y, 4,Y			;move x6
			STD	0,Y				;store x2
			RTS					;done


;Word: NIP ( x1 x2 -- x2 )
;Drop the first item below the top of stack.
IF_NIP			INLINE	CF_NIP
CF_NIP			EQU	*
			MOVW	0,Y, 2,+Y
CF_NIP_EOI		RTS					;done
	
;Word: TUCK ( x1 x2 -- x2 x1 x2 )
;Copy the first (top) stack item below the second stack item.
IF_TUCK			INLINE	CF_TUCK
CF_TUCK			EQU	*
			LDD	0,Y
			MOVW	2,Y, 0,Y
			STD	2,Y
			STD	2,-Y
CF_TUCK_EOI		RTS					;done
	
;Word: PICK ( xu ... x1 x0 u -- xu ... x1 x0 xu )
;Remove u. Copy the xu to the top of the stack. An ambiguous condition exists if
;there are less than u+2 items on the stack before PICK is executed.
IF_PICK			INLINE	CF_PICK
CF_PICK			EQU	*
			LDD	2,Y+ 				;u   -> D
			LSLD					;2*D -> D
			MOVW	D,Y, 2,-Y			;pick xu
CF_PICK_EOI		RTS					;done

;Word: ROLL ( xu xu-1 ... x0 u -- xu-1 ... x0 xu )
;Remove u. Rotate u+1 items on the top of the stack. An ambiguous condition
;exists if there are less than u+2 items on the stack before ROLL is executed.
IF_ROLL			REGULAR
CF_ROLL			EQU	*
			LDD	2,Y+ 				;u -> D
			LEAX	D,Y				;X points
			LEAX	D,X				; to xu
			MOVW	D,Y, 2,-Y			;pick xu
			DBEQ	D, CF_ROLL_2			;u == 0
CF_ROLL_1		MOVW	-2,X, 2,X+			;replace xn by xn-1
			DBNE	D, CF_ROLL_1			;loop
CF_ROLL_2		MOVW	2,Y+, 0,Y			;replace x1 by x0
			RTS					;done
	
;Word: .S ( -- ) Copy and display the values currently on the data stack.
IF_DOT_S		REGULAR
CF_DOT_S		EQU	*
			;Start on new line 
			JOBSR	CF_CR 				;line break
			;RS layout:
			; +--------+--------+
			; |  Line counter   | SP+0
			; +--------+--------+
			; |    Iterator     | SP+2
			; +--------+--------+
			;Allocate iterator 
			MOVW	#(PS_EMPTY-2), 2,-SP 		;first PS entry -> iterator
			CPY	0,SP				;check for empty PS
			BHI	CF_DOT_S_2			;PS is empty
			LDD	[0,SP]				;first cell -> D
			JOBSR	FPS_CELL_DIGITS			;char count  -> D
			PSHD					;set up line counter
			;Print loop 
			LDX	2,SP	    			;iterator -> X
CF_DOT_S_1		LDD	2,X- 				;cell -> D
			STX	2,SP				;advance iterator
			JOBSR	FPS_TX_CELL			;print cell
			CPY	2,SP				;check for further PS entries
			BHI	CF_DOT_S_3			;no further entries
			LDD	0,X				;next cell -> D
			JOBSR	FPS_CELL_DIGITS			;char count  -> D
			JOBSR	FPS_LIST_SEP			;print separator
			JOB	CF_DOT_S_1			;print next cell
			;Print "empty" message
CF_DOT_S_2		LEAS	2,SP				;free stack space
			LDX	#FPS_STR_EMPTY			;string pointer -> X
			JOB	FPS_TX_STRING			;print "empty" string
			;Done		
CF_DOT_S_3		LEAS	4,SP 				;free stack space
			RTS					;done

FPS_CODE_END		EQU	*
FPS_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FPS_TABS_START_LIN
			ORG 	FPS_TABS_START, FPS_TABS_START_LIN
#else
			ORG 	FPS_TABS_START
FPS_TABS_START_LIN	EQU	@
#endif	

;PS empty message
FPS_STR_EMPTY		FCS	"empty"
	
FPS_TABS_END		EQU	*
FPS_TABS_END_LIN	EQU	@
#endif	
