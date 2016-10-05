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
;;DUP ( x -- x x )
;;Duplicate x.
;;
;;S12CForth implementation details:
;;Throws:	FEXCPT_EC_PSOF
;;        	FEXCPT_EC_PSUF
;CF_DUP			PS_CHECK_UFOF	1, 1			;check for overflow	=>11 cycles
;			MOVW		2,Y, 0,Y		;duplicate last entry	=> 3 cycles
;			JOB		CF_DUP_1
;CF_DUP_1		EQU		CF_CONSTANT_RT_2
;
;;DROP ( x -- )
;;Remove x from the stack.
;;
;;S12CForth implementation details:
;;Doesn't throw any exception, resets the parameter stack on underflow 
;;Throws:	FEXCPT_EC_PSUF
;CF_DROP			PS_CHECK_UF	1			;check for underflow	=> 8 cycles
;			LEAY		2,Y			;PS -> Y		=> 2 cycles 
;			JOB		CF_DROP_1
;CF_DROP_1		EQU		CF_CONSTANT_RT_2
;
;;OVER ( x1 x2 -- x1 x2 x1 )
;;Place a copy of x1 on top of the stack.
;;
;;S12CForth implementation details:
;;Throws:        FEXCPT_EC_PSUF
;;         	FEXCPT_EC_PSOF
;CF_OVER			PS_CHECK_UFOF	2, 1			;check for under and overflow (PSP-2 -> Y)
;			MOVW	4,Y, 0,Y
;			JOB		CF_OVER_1
;CF_OVER_1		EQU		CF_CONSTANT_RT_2
;
;;2DUP ( x1 x2 -- x1 x2 x1 x2 )
;;Duplicate cell pair x1 x2.
;;
;;S12CForth implementation details:
;;Throws:        FEXCPT_EC_PSUF
;;         	FEXCPT_EC_PSOF
;CF_TWO_DUP		PS_CHECK_UFOF	2, 2			;check for under and overflow
;			MOVW		6,Y, 2,Y		;duplicate stack entry
;			MOVW		4,Y, 0,Y		;duplicate stack entry
;			JOB		CF_TWO_DUP_1
;CF_TWO_DUP_1		EQU		CF_CONSTANT_RT_2
;
;;2DROP ( x1 x2 -- )
;;Drop cell pair x1 x2 from the stack.
;;
;;S12CForth implementation details:
;;Throws:        FEXCPT_EC_PSUF
;CF_TWO_DROP		PS_CHECK_UF	2			;check for underflow	=> 8 cycles
;			LEAY		4,Y			;PS -> Y		=> 2 cycles 
;			JOB		CF_TWO_DROP_1
;CF_TWO_DROP_1		EQU		CF_CONSTANT_RT_2
;	
;;2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;;Copy cell pair x1 x2 to the top of the stack.
;;
;;S12CForth implementation details:
;;Throws:	FEXCPT_EC_PSUF
;;         	FEXCPT_EC_PSOF
;CF_TWO_OVER		PS_CHECK_UFOF	4, 2			;check for under and overflow
;			MOVW		8,Y, 0,Y		;duplicate stack entry
;			MOVW		10,Y, 2,Y		;duplicate stack entry
;			JOB		CF_TWO_OVER_1
;CF_TWO_OVER_1		EQU		CF_CONSTANT_RT_2
;
;;SWAP ( x1 x2 -- x2 x1 )
;;Exchange the top two stack items.
;;
;;S12CForth implementation details:
;;Throws:         FEXCPT_EC_PSUF
;CF_SWAP			PS_CHECK_UF	2			;check for underflow (PSP -> Y)
;			;Swap
;			LDD		2,Y
;			MOVW		0,Y, 2,Y
;CF_SWAP_1		STD		0,Y
;			;Done
;			NEXT
;
;;2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;;Exchange the top two cell pairs.
;;
;;S12CForth implementation details:
;;Throws:         FEXCPT_EC_PSUF
;CF_TWO_SWAP		PS_CHECK_UF	4			;(PSP -> Y)
;			LDD		6,Y
;			MOVW		2,Y 6,Y
;			STD		2,Y
;			LDD		4,Y
;			MOVW		0,Y 4,Y
;			JOB		CF_TWO_SWAP_1
;CF_TWO_SWAP_1		EQU		CF_SWAP_1
;	
;;ROT ( x1 x2 x3 -- x2 x3 x1 )
;;Rotate the top three stack entries.
;;
;;S12CForth implementation details:
;;Throws:         FEXCPT_EC_PSUF
;CF_ROT			PS_CHECK_UF	2			;check for underflow
;			;Rotate
;			LDD		4,Y
;			MOVW		2,Y, 4,Y
;			MOVW		0,Y, 2,Y
;			JOB		CF_ROT_1
;CF_ROT_1		EQU		CF_SWAP_1
;
;;2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;;top of the stack.
;;
;;S12CForth implementation details:
;;Throws:         FEXCPT_EC_PSUF
;CF_TWO_ROT		PS_CHECK_UF 	6		;check for underflow (PSP -> Y)
;			;Swap PS entries (PSP in Y)
;			LDD	10,Y 			;save  x1
;			MOVW	 6,Y, 10,Y		;x3 -> x1
;			MOVW	 2,Y,  6,Y		;x5 -> x3
;			STD	 2,Y			;x1 -> x5
;			LDD	 8,Y 			;save  x2
;			MOVW	 4,Y,  8,Y		;x4 -> x2
;			MOVW	 0,Y,  4,Y		;x6 -> x4
;			JOB	CF_TWO_ROT_1
;CF_TWO_ROT_1		EQU	CF_SWAP_1
;
;;.S ( -- ) Copy and display the values currently on the data stack.
;; args:   none
;; result: none
;; SSTACK: 18 bytes
;; PS:      4 cells
;; RS:      1 cell
;; throws: FEXCPT_EC_PSOF
;CF_DOT_S		EQU	*
;			;PS layout:
;			; +--------+--------+
;			; |     Iterator    | PSP+0
;			; +--------+--------+
;			; | Column counter  | PSP+2
;			; +--------+--------+
;			;Print header
;			PS_PUSH	#FPS_DOT_S_HEADER
;			EXEC_CF	CF_STRING_DOT
;			NEXT
;
;;			;Reserve and populate local stack space
;;			FPS_CHECK_OF	2 			;reserve 2 cells
;;			MOVW	#(PS_EMPTY-2), 0,Y		;initialize iterator
;;			MOVW	#, 0,Y				;initialize column counter	
;;			STY	PSP				;update PSP
;;			;Reserve and populate local stack space
;;			FPS_CHECK_OF	4 			;reserve 3 cells
;;			MOVW	PSP, 6,Y			;initialize index
;;			STY	PSP				;update PSP
;;			;Print first column (PSP in Y)
;;			MOVW	BASE, 4,Y			;save BASE
;;			LDD	#PS_EMPTY			;calculate line count
;;			SUBD	6,Y
;;			LSRD
;;			STD	2,Y
;;			LDD	#(PS_EMPTY+6)			;calculate number of PS entries
;;			SUBD	PSP
;;			LSRD
;;			TFR	D, X 				;determine digit count
;;			LDD	#10 				;set BASE to decimal
;;			STD	BASE
;;			LDY	#$0000
;;			NUM_REVERSE 				
;;			TAB					;print line number
;;			CLRA
;;			STD	[PSP]
;;			EXEC_CF	CF_DOT_R
;;			;Print separator
;;			PS_PUSH	#FPS_DOT_S_HEADER
;;			EXEC_CF	CF_STRING_DOT
;			
;	
;;Exceptions:
;;===========
;;Standard exceptions
;#ifndef FPS_NO_CHECK
;#ifdef FPS_DEBUG
;FPS_THROW_PSOF		BGND					;parameter stack overflow
;FPS_THROW_PSUF		BGND					;parameter stack underflow
;#else
;FPS_THROW_PSOF		FEXCPT_THROW	FEXCPT_EC_PSOF		;parameter stack overflow
;FPS_THROW_PSUF		FEXCPT_THROW	FEXCPT_EC_PSUF		;parameter stack underflow
;#endif
;#endif
	
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

;;###############################################################################
;;# Words                                                                       #
;;###############################################################################
;#ifdef FPS_WORDS_START_LIN
;			ORG 	FPS_WORDS_START, FPS_WORDS_START_LIN
;#else
;			ORG 	FPS_WORDS_START
;FPS_WORDS_START_LIN	EQU	@
;#endif	
;			ALIGN	1, $FF
;;#ANSForth Words:
;;================
;;Word: DUP ( x -- x x )
;;Duplicate x.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack overflow"
;;"Return stack overflow"
;CFA_DUP			DW	CF_DUP
;
;;Word: DROP ( x -- )
;;Remove x from the stack.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;CFA_DROP		DW	CF_DROP
;
;;Word: ROT ( x1 x2 x3 -- x2 x3 x1 )
;;Rotate the top three stack entries.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;CFA_ROT			DW	CF_ROT
;
;;Word: OVER ( x1 x2 -- x1 x2 x1 )
;;Place a copy of x1 on top of the stack.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;;"Parameter stack overflow"
;CFA_OVER		DW	CF_OVER
;
;;Word: SWAP ( x1 x2 -- x2 x1 )
;;Exchange the top two stack items.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;CFA_SWAP		DW	CF_SWAP
;
;;Word: 2DUP ( x1 x2 -- x1 x2 x1 x2 )
;;Duplicate cell pair x1 x2.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;;"Parameter stack overflow"
;CFA_TWO_DUP		DW	CF_TWO_DUP
;
;;Word: 2DROP ( x1 x2 -- )
;;Drop cell pair x1 x2 from the stack.
;;
;;S12CForth implementation details:
;; - Doesn't throw any exception, resets the parameter stack on underflow 
;CFA_TWO_DROP		DW	CF_TWO_DROP
;
;;Word: 2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;;top of the stack.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;CFA_TWO_ROT		DW	CF_TWO_ROT	
;
;;Word: 2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;;Copy cell pair x1 x2 to the top of the stack.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;;"Parameter stack overflow"
;CFA_TWO_OVER		DW	CF_TWO_OVER
;
;;Word: 2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;;Exchange the top two cell pairs.
;;
;;S12CForth implementation details:
;;Throws:
;;"Parameter stack underflow"
;CFA_TWO_SWAP		DW	CF_TWO_SWAP
;	
;FPS_WORDS_END		EQU	*
;FPS_WORDS_END_LIN	EQU	@

