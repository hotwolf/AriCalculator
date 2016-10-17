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
;#    Program termination options:                                             #
;#        ABORT:   Parameter stack is cleared                                  #
;#        QUIT:    Parameter stack is untouched                                #
;#        SUSPEND: Parameter stack is untouched                                #
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
PS_EMPTY		EQU	UDICT_PS_END

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
#emac
	
;#Quit action
;============
#macro	FPS_QUIT, 0
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
;#Transmit one char
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FPS_TX_CHAR		EQU	SCI_TX_BL

;#Revert cell
; args:   X: cell pointer
; result: D: number of digits
;         SP+0: MSB   
;         SP+1:  |    
;         SP+2:  |reverse  
;         SP+3:  |number  
;         SP+4:  |    
;         SP+5: LSB   
; SSTACK: 26 bytes
;         X and Y are preserved
FPS_REVERT_CELL		EQU	SCI_TX_BL
			;Save registers (cell pointer in X) 
			PSHX					;save X
			PSHY					;save Y
			MOVW	#$0000, 2,-SP			;allocate space for char count
			;check sign (cell pointer in X) 
			LDD	0,X				;cell -> D	
			BPL	FPS_REVERT_CELL_1		;positive
			MOVB	#$01, 1,SP			;increment char count
			COMA					;1's complement -> D
			COMB					;
			ADDD	#1				;2's complement -> D
			;Revert cell (absolute cell value in D)  
FPS_REVERT_CELL_1	TFR	D, X 				;absolute cell value - > X
			JOBSR	FOUTER_GET_BASE			;BASE -> B
			SEI					;start of atomic sequence
			JOBSR	NUM_REVERSE			;(SSTACK: 18 bytes)
			LDY	8,SP				;restore Y
			CLI					;end of atomic sequence
			TAB					;char count -> D
			CLRA					;
			ADDD	6,SP 				;add sign length
			LDX	10,SP				;restore X
			;Adjust stack (digit count in D) 
			;SP+ 0: MSB   	                   
			;SP+ 2:  |rev.num.    	        
			;SP+ 4: LSB   	      	           
			;SP+ 6: char count    	      SP+ 0: return addr.    
			;SP+ 8: Y  	      ==>     SP+ 2: MSB   	    	      
			;SP+10: X   	      	      SP+ 4:  |rev.num.      	      
			;SP+12: return addr.   	      SP+ 8: LSB   	   
			MOVW	12,SP,	6,SP			;move return address
			MOVW	2,SP+,	6,SP 			;move RHV
			MOVW	2,SP+,	6,SP 			;move RMV
			MOVW	2,SP+,	6,SP 			;move RLV
			RTS

	
;#########
;# Words #
;#########

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
			LDD	0,Y 				;save x2
			MOVW	2,Y, 0,Y			;move x1
			STD	2,Y				;store x2
CF_SWAP_EOI		RTS					;done

;Word: 2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;Exchange the top two cell pairs.
IF_TWO_SWAP		INLINE	CF_TWO_SWAP
CF_TWO_SWAP		EQU	*
			LDD	0,Y 				;save x4
			MOVW	4,Y, 0,Y			;move x2
			STD	4,Y				;store x4
			LDD	2,Y				;save x3
			MOVW	6,Y, 2,Y			;move x1
			STD	6,y				;store x3
CF_TWO_SWAP_EOI		RTS					;done
	
;Word: ROT ( x1 x2 x3 -- x2 x3 x1 )
;Rotate the top three stack entries.
IF_ROT			INLINE	CF_ROT
CF_ROT			EQU	*
			LDD	4,Y 				;save x1
			MOVW	2,Y, 4,Y			;move x2
			MOVW	0,Y, 2,Y			;move x3
			STD	0,Y				;store x1
CF_ROT_EOI		RTS					;done

;Word: 2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;top of the stack.
IF_2ROT			INLINE	CF_2ROT
CF_2ROT			EQU	*
			LDD	10,Y 				;save x1
			MOVW	6,Y, 10,Y			;move x3
			MOVW	2,Y, 6,Y			;move x5
			STD	2,Y				;store x1
			LDD	8,Y 				;save x2
			MOVW	4,Y, 8,Y			;move x4
			MOVW	0,Y, 4,Y			;move x6
			STD	0,Y				;store x2
CF_2ROT_EOI		RTS					;done

;Word: .S ( -- ) Copy and display the values currently on the data stack.
IF_DOT_S		REGULAR
CF_DOT_S		EQU	*
			;Store iterator 
			PSHY					;store PSP
			LEAS	2,SP				;allicate column counter
			LDX	#PS_EMPTY			;first PS entry -> X
			CPX	2,SP				;check if PS is empty
			BHI	CF_DOT_S_3			;PS is empty
			;Print first cell (cell pointer in X) 
			JOBSR	FPS_REVERT_CELL 		;calculate reverse cell number
			STD	6,SP				;update column counter
CF_DOT_S_1		BRCLR	2,X-,#$80,CF_DOT_S_2		;don't print minus sign
			LDAB	#"-"				;print minus sign
			JOBSR	FPS_TX_CHAR			;
CF_DOT_S_2		JOBSR	FOUTER_GET_BASE			;BASE -> B
			JOBSR	NUM_REVPRINT_BL			;print cell
			;Print consecutive cells (cell pointer in X) 
			CPX	2,SP				;check if PS is empty
			BHI	CF_DOT_S_3			;all cells printed			
			JOBSR	FPS_REVERT_CELL 		;calculate reverse cell number
			MOVW	6,SP, 2,-SP			;douplicate column counter
			JOBSR	FOUTER_LIST_SEP			;print separator
			MOVW	2,SP+, 6,SP			;update loulumn counter
			JOB	CF_DOT_S_1			;repeat
			;Done
CF_DOT_S_3		LEAS	4,SP 				;free stack space
			RTS					;done
	
;;Code fields:
;;============
;;2CONSTANT run-time semantics ( -- d )
;;Push the contents of the first cell after the CFA onto the parameter stack
;;
;;S12CForth implementation details:
;;Throws:	FEXCPT_EC_PSOF
;CF_TWO_CONSTANT_RT	PS_CHECK_OF	2			;overflow check	=> 9 cycles
;			MOVW		4,X, 2,Y		;[CFA+6] -> PS	=> 5 cycles
;			JOB		CF_TWO_CONSTANT_RT_1
;CF_TWO_CONSTANT_RT_1	EQU		CF_CONSTANT_RT_1
;
;;CONSTANT run-time semantics ( -- x )
;;Push the contents of the first cell after the CFA onto the parameter stack
;;
;;S12CForth implementation details:
;;Throws:	FEXCPT_EC_PSOF
;CF_CONSTANT_RT		PS_CHECK_OF	1			;overflow check	=> 9 cycles
;CF_CONSTANT_RT_1	MOVW		2,X, 0,Y		;[CFA+2] -> PS	=> 5 cycles
;CF_CONSTANT_RT_2	STY		PSP			;		=> 3 cycles
;			NEXT					;NEXT		=>15 cycles
;								; 		  ---------
;								;		  32 cycles
;
	
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

FPS_TABS_END		EQU	*
FPS_TABS_END_LIN	EQU	@
#endif	
