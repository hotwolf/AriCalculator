;###############################################################################
;# S12CForth- FPS - Parameter Stack of the Forth VM                            #
;###############################################################################
;#    Copyright 2010 - 2013 Dirk Heisswolf                                     #
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
;        UDICT_PS_START, -> |              |              | 	     
;           UDICT_START     |       User Dictionary       |	     
;                           |       User Variables        |	     
;                           |              |              |	     
;                           |              v              |	     
;                       -+- | --- --- --- --- --- --- --- |
;             UDICT_PADDING |                             | <- [CP]	     
;                       -+- | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [HLD]	     
;                           |             PAD             |	     
;                           | --- --- --- --- --- --- --- |          
;                           |                             | <- [PAD]          
;                           .                             .          
;                           .                             .          
;                           | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [PSP]	  
;                           |              |              |		  
;                           |       Parameter stack       |		  
;    	                    |              |              |		  
;                           +--------------+--------------+        
;              PS_EMPTY, ->   
;          UDUCT_PS_END
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Debug option for stack over/underflows
;FPS_DEBUG		EQU	1 
	
;Disable stack range checks
;FPS_NO_CHECK	EQU	1 

;Boundaries
;UDICT_PS_START		EQU	0
;UDICT_PS_END		EQU	0

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Bottom of parameter stack
PS_EMPTY		EQU	UDICT_PS_END

;Error codes
#ifndef FPS_NO_CHECK	EQU	1 
FPS_EC_OF		EQU	FEXCPT_EC_PSOF		;PS overflow   (-3)
FPS_EC_UF		EQU	FEXCPT_EC_PSUF		;PS underflow  (-4)
#endif
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FPS_VARS_START_LIN
			ORG 	FPS_VARS_START, FPS_VARS_START_LIN
#else
			ORG 	FPS_VARS_START
FPS_VARS_START_LIN	EQU	@
#endif
	
PSP			DS	2 	;parameter stack pointer (top of stack)

FPS_VARS_END		EQU	*
FPS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FPS_INIT, 0
			;Initialize parameter stack
			MOVW	#PS_EMPTY,	PSP	
#emac
	
;#Abort action (to be executed in addition of quit action)
#macro	FPS_ABORT, 0
			;Reset parameter stack
			MOVW	#PS_EMPTY,	PSP		
#emac
	
;#Quit action
#macro	FPS_QUIT, 0
#emac
	
;#Suspend action
#macro	FPS_SUSPEND, 0
#emac

;#Parameter stack oerations:
;#--------------------------	
;PS_RESET: reset the parameter stack
; args:   none
; result: none
; SSTACK: none
;        X, Y and D are preserved 
#macro	PS_RESET, 0
			MOVW	#PS_EMPTY,	PSP	
#emac

;PS_CHECK_UF: check for a minimum number of stack entries (PSP -> Y)
; args:   1: required stack content (cells)
; result: Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X and D are preserved 
#macro	PS_CHECK_UF, 1
			LDY	PSP 			;=> 3 cycles
#ifndef	FPS_NO_CHECK
			CPY	#(PS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	FPS_THROW_PSUF		;=> 3 cycles/ 4 cycles
							;  -------------------
							;   8 cycles/ 9 cycles
#endif
#emac
	
;PS_CHECK_Y_UF: check for a minimum number of stack entries (PSP -> Y)
; args:   1: required stack content (cells)
;         Y: PSP
; result: none
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         Y, X and D are preserved 
#macro	PS_CHECK_Y_UF, 1
#ifndef	FPS_NO_CHECK
			CPY	#(PS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	FPS_THROW_PSUF		;=> 3 cycles/ 4 cycles
							;  -------------------
							;   8 cycles/ 9 cycles
#endif
#emac
	
;PS_CHECK_OF: check if there is room for a number of stack entries (PSP-new cells -> Y)
; args:   1: required stack space (cells)
; result: Y: PSP-new cells
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;        X and D are preserved 
#macro	PS_CHECK_OF, 1
			LDY	PSP 			;=> 3 cycles
			LEAY	-(2*\1),Y		;=> 2 cycles
#ifndef	FPS_NO_CHECK
			CPY	PAD			;=> 3 cycles
			BLO	FPS_THROW_PSOF		;=> 3 cycle / 4 cycles
							;  -------------------
							;  11 cycles/ 12 cycles
#endif
#emac

;PS_CHECK_OF_D: check if there is room for a number of stack entries (PSP-new cells -> Y)
; args:   D: required stack space (cells)
; result: Y: PSP-new cells
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;         X and D are preserved 
#macro	PS_CHECK_OF_D, 0
			LDY	PSP 			;=> 3 cycles
			COMA				;=> 1 cycle
			COMB				;=> 1 cycle
			LEAY	D,Y			;=> 2 cycles
			LEAY	D,Y			;=> 2 cycles
			LEAY	2,Y			;=> 2 cycles
			COMA				;=> 1 cycle
			COMB				;=> 1 cycle
#ifndef	FPS_NO_CHECK
			CPY	PAD			;=> 3 cycles
			BLO	FPS_THROW_PSOF		;=> 3 cycles/  4 cycles
							;  --------------------
							;  19 cycles/ 20 cycles
#endif
#emac

;PS_CHECK_UFOF: check for over and underflow (PSP-new cells -> Y)
; args:   1: required stack content (cells)
;	  2: required stack space (cells)
; result: Y: PSP-new cells
; SSTACK: none
; throws: FEXCPT_EC_PSOF,
;         FEXCPT_EC_PSUF
;         X and D are preserved 
#macro	PS_CHECK_UFOF, 2  
			LDY	PSP 			;=> 3 cycles
#ifndef	FPS_NO_CHECK
			CPY	#(PS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	FPS_THROW_PSUF		;=> 3 cycles/  4 cycles
#endif
			LEAY	-(2*\2),Y		;=> 2 cycles
#ifndef	FPS_NO_CHECK
			CPY	PAD			;=> 3 cycles
			BLO	FPS_THROW_PSOF		;=> 3 cycles/  4 cycles
#endif
							;  --------------------
							;  16 cycles/ 18 cycles
#emac

;PS_REQUIRE: check if there is room for a number of stack entries (PSP-new cells -> Y)
; args:   1: required stack space (cells)
;         2: branch address is requirement is not fulfilled
; result: Y: PSP-new cells
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;        X and D are preserved 
#macro	PS_REQUIRE, 2
			LDY	PSP 			;=> 3 cycles
			LEAY	-(2*\1),Y		;=> 2 cycles
			CPY	PAD			;=> 3 cycles
			BLO	\2			;=> 3 cycle / 4 cycles
							;  -------------------
							;  11 cycles/ 12 cycles
#emac
	
;PS_PULL_X: Pull one entry from the parameter stack into index X (PSP -> Y)
; args:   none
; result: X: pulled PS content
;	  Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         D is preserved 
#macro	PS_PULL_X, 0
			PS_CHECK_UF	1		;check for underflow	=> 8 cycles
			LDX		2,Y+		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         14 cycles
#emac	
	
;PS_COPY_X: Copy one entry from the parameter stack into index X (PSP -> Y)
; args:   none
; result: D:      copied PS content
;	  Y:      PSP
;	  N-flag: set if cell is negative
;	  Z-flag: set if cell is zero
;	  V-flag: cleared
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X is preserved 
#macro	PS_COPY_X, 0
			PS_CHECK_UF	1		;check for underflow	=> 8 cycles
			LDX		0,Y		;PS -> Y		=> 3 cycles 
							;                         ---------
							;                         11 cycles
#emac	

;PS_PULL_D: Pull one entry from the parameter stack into accu D (PSP -> Y)
; args:   none
; result: D: pulled PS content
;	  Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X is preserved 
#macro	PS_PULL_D, 0
			PS_CHECK_UF	1		;check for underflow	=> 8 cycles
			LDD		2,Y+		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         14 cycles
#emac	
	
;PS_COPY_D: Copy one entry from the parameter stack into accu D (PSP -> Y)
; args:   none
; result: D:      copied PS content
;	  Y:      PSP
;	  N-flag: set if cell is negative
;	  Z-flag: set if cell is zero
;	  V-flag: cleared
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X is preserved 
#macro	PS_COPY_D, 0
			PS_CHECK_UF	1		;check for underflow	=> 8 cycles
			LDD		0,Y		;PS -> Y		=> 3 cycles 
							;                         ---------
							;                         11 cycles
#emac	

;PS_PUSH: 
; args:   1: value to push onto the PS
; result: Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;         X and D are preserved 
#macro	PS_PUSH, 1
			PS_CHECK_OF	1		;check for overflow	=> 9 cycles
			MOVW		\1, 0,Y		;PS -> Y		=> 4/5 cycles 
			STY		PSP		;			=> 3   cycles
							;                         ---------
							;                         16/17 cycles
#emac	
	
;PS_PUSH_X: Push one entry from index X onto the return stack (PSP -> Y)
; args:   X: value to push onto the PS
; result: Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;         X and D are preserved 
#macro	PS_PUSH_X, 0
			PS_CHECK_OF	1		;check for overflow	=> 9 cycles
			STX		0,Y		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         15 cycles
#emac	

;PS_PUSH_D: Push one entry from accu D onto the return stack (PSP -> Y)
; args:   D: value to push onto the PS
; result: Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;         X and D are preserved 
#macro	PS_PUSH_D, 0
			PS_CHECK_OF	1		;check for overflow	=>11 cycles
			STD		0,Y		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         17 cycles
#emac	

;PS_PUSH_DX: Push one entry from accu D onto the return stack (PSP -> Y)
; args:   D:X: value to push onto the PS
; result: Y:   PSP
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;         X and D are preserved 
#macro	PS_PUSH_DX, 0
			PS_CHECK_OF	2		;check for overflow	=>11 cycles
			STD		0,Y		;PS -> Y		=> 3 cycles 
			STX		2,Y		;   			=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         20 cycles
#emac	

;PS_PUSH_D_NOCHK: Push one entry from accu D onto the return stack (PSP -> Y)
; args:   D: value to push onto the PS
; result: Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSOF
;         X and D are preserved 
#macro	PS_PUSH_D_NOCHK, 0
			LDY		PSP		;PS -> Y		=> 3 cycles
			STD		2,-Y		;			=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                          9 cycles
#emac	


;PS_DUP: Duplicate last parameter stack entry (PSP -> Y)
; args:   none
; result: 1: number of cells to remove
;	  Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X and D are preserved 
#macro	PS_DUP, 0
			PS_CHECK_OF	1		;check for overflow	=>11 cycles
			MOVW		2,Y, 0,Y	;duplicate last entry	=> 3 cycles
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         19 cycles
#emac	
	
;PS_DROP: Remove entries from the parameter stack (PSP -> Y)
; args:   none
; result: 1: number of cells to remove
;	  Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X and D are preserved 
#macro	PS_DROP, 1
			PS_CHECK_UF	\1		;check for underflow	=> 8 cycles
			LEAY		(2*\1),Y	;PS -> Y		=> 2 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         14 cycles
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

;Code fields:
;============
;2CONSTANT run-time semantics ( -- d )
;Push the contents of the first cell after the CFA onto the parameter stack
;
;S12CForth implementation details:
;Throws:	FEXCPT_EC_PSOF
CF_TWO_CONSTANT_RT	PS_CHECK_OF	2			;overflow check	=> 9 cycles
			MOVW		4,X, 2,Y		;[CFA+6] -> PS	=> 5 cycles
			JOB		CF_TWO_CONSTANT_RT_1
CF_TWO_CONSTANT_RT_1	EQU		CF_CONSTANT_RT_1

;CONSTANT run-time semantics ( -- x )
;Push the contents of the first cell after the CFA onto the parameter stack
;
;S12CForth implementation details:
;Throws:	FEXCPT_EC_PSOF
CF_CONSTANT_RT		PS_CHECK_OF	1			;overflow check	=> 9 cycles
CF_CONSTANT_RT_1	MOVW		2,X, 0,Y		;[CFA+2] -> PS	=> 5 cycles
CF_CONSTANT_RT_2	STY		PSP			;		=> 3 cycles
			NEXT					;NEXT		=>15 cycles
								; 		  ---------
								;		  32 cycles

;DUP ( x -- x x )
;Duplicate x.
;
;S12CForth implementation details:
;Throws:	FEXCPT_EC_PSOF
;        	FEXCPT_EC_PSUF
CF_DUP			PS_CHECK_UFOF	1, 1			;check for overflow	=>11 cycles
			MOVW		2,Y, 0,Y		;duplicate last entry	=> 3 cycles
			JOB		CF_DUP_1
CF_DUP_1		EQU		CF_CONSTANT_RT_2

;DROP ( x -- )
;Remove x from the stack.
;
;S12CForth implementation details:
;Doesn't throw any exception, resets the parameter stack on underflow 
;Throws:	FEXCPT_EC_PSUF
CF_DROP			PS_CHECK_UF	1			;check for underflow	=> 8 cycles
			LEAY		2,Y			;PS -> Y		=> 2 cycles 
			JOB		CF_DROP_1
CF_DROP_1		EQU		CF_CONSTANT_RT_2

;OVER ( x1 x2 -- x1 x2 x1 )
;Place a copy of x1 on top of the stack.
;
;S12CForth implementation details:
;Throws:        FEXCPT_EC_PSUF
;         	FEXCPT_EC_PSOF
CF_OVER			PS_CHECK_UFOF	2, 1			;check for under and overflow (PSP-2 -> Y)
			MOVW	4,Y, 0,Y
			JOB		CF_OVER_1
CF_OVER_1		EQU		CF_CONSTANT_RT_2

;2DUP ( x1 x2 -- x1 x2 x1 x2 )
;Duplicate cell pair x1 x2.
;
;S12CForth implementation details:
;Throws:        FEXCPT_EC_PSUF
;         	FEXCPT_EC_PSOF
CF_TWO_DUP		PS_CHECK_UFOF	2, 2			;check for under and overflow
			MOVW		6,Y, 2,Y		;duplicate stack entry
			MOVW		4,Y, 0,Y		;duplicate stack entry
			JOB		CF_TWO_DUP_1
CF_TWO_DUP_1		EQU		CF_CONSTANT_RT_2

;2DROP ( x1 x2 -- )
;Drop cell pair x1 x2 from the stack.
;
;S12CForth implementation details:
;Throws:        FEXCPT_EC_PSUF
CF_TWO_DROP		PS_CHECK_UF	2			;check for underflow	=> 8 cycles
			LEAY		4,Y			;PS -> Y		=> 2 cycles 
			JOB		CF_TWO_DROP_1
CF_TWO_DROP_1		EQU		CF_CONSTANT_RT_2
	
;2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;Copy cell pair x1 x2 to the top of the stack.
;
;S12CForth implementation details:
;Throws:	FEXCPT_EC_PSUF
;         	FEXCPT_EC_PSOF
CF_TWO_OVER		PS_CHECK_UFOF	4, 2			;check for under and overflow
			MOVW		8,Y, 0,Y		;duplicate stack entry
			MOVW		10,Y, 2,Y		;duplicate stack entry
			JOB		CF_TWO_OVER_1
CF_TWO_OVER_1		EQU		CF_CONSTANT_RT_2

;SWAP ( x1 x2 -- x2 x1 )
;Exchange the top two stack items.
;
;S12CForth implementation details:
;Throws:         FEXCPT_EC_PSUF
CF_SWAP			PS_CHECK_UF	2			;check for underflow (PSP -> Y)
			;Swap
			LDD		2,Y
			MOVW		0,Y, 2,Y
CF_SWAP_1		STD		0,Y
			;Done
			NEXT

;2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;Exchange the top two cell pairs.
;
;S12CForth implementation details:
;Throws:         FEXCPT_EC_PSUF
CF_TWO_SWAP		PS_CHECK_UF	4			;(PSP -> Y)
			LDD		6,Y
			MOVW		2,Y 6,Y
			STD		2,Y
			LDD		4,Y
			MOVW		0,Y 4,Y
			JOB		CF_TWO_SWAP_1
CF_TWO_SWAP_1		EQU		CF_SWAP_1
	
;ROT ( x1 x2 x3 -- x2 x3 x1 )
;Rotate the top three stack entries.
;
;S12CForth implementation details:
;Throws:         FEXCPT_EC_PSUF
CF_ROT			PS_CHECK_UF	2			;check for underflow
			;Rotate
			LDD		4,Y
			MOVW		2,Y, 4,Y
			MOVW		0,Y, 2,Y
			JOB		CF_ROT_1
CF_ROT_1		EQU		CF_SWAP_1

;2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;top of the stack.
;
;S12CForth implementation details:
;Throws:         FEXCPT_EC_PSUF
CF_TWO_ROT		PS_CHECK_UF 	6		;check for underflow (PSP -> Y)
			;Swap PS entries (PSP in Y)
			LDD	10,Y 			;save  x1
			MOVW	 6,Y, 10,Y		;x3 -> x1
			MOVW	 2,Y,  6,Y		;x5 -> x3
			STD	 2,Y			;x1 -> x5
			LDD	 8,Y 			;save  x2
			MOVW	 4,Y,  8,Y		;x4 -> x2
			MOVW	 0,Y,  4,Y		;x6 -> x4
			JOB	CF_TWO_ROT_1
CF_TWO_ROT_1		EQU	CF_SWAP_1

;.S ( -- ) Copy and display the values currently on the data stack.
; args:   none
; result: none
; SSTACK: 18 bytes
; PS:      4 cells
; RS:      1 cell
; throws: FEXCPT_EC_PSOF
;CF_DOT_S		EQU	*
;			;Print header
;			PS_PUSH	#FPS_DOT_S_HEADER
;			EXEC_CF	CF_STRING_DOT
;			;Reserve and populate local stack space
;			FPS_CHECK_OF	4 			;reserve 3 cells
;			MOVW	PSP, 6,Y			;initialize index
;			STY	PSP				;update PSP
;			;Print first column (PSP in Y)
;			MOVW	BASE, 4,Y			;save BASE
;			LDD	#PS_EMPTY			;calculate line count
;			SUBD	6,Y
;			LSRD
;			STD	2,Y
;			LDD	#(PS_EMPTY+6)			;calculate number of PS entries
;			SUBD	PSP
;			LSRD
;			TFR	D, X 				;determine digit count
;			LDD	#10 				;set BASE to decimal
;			STD	BASE
;			LDY	#$0000
;			NUM_REVERSE 				
;			TAB					;print line number
;			CLRA
;			STD	[PSP]
;			EXEC_CF	CF_DOT_R
;			;Print separator
;			PS_PUSH	#FPS_DOT_S_HEADER
;			EXEC_CF	CF_STRING_DOT
			
	
;Exceptions:
;===========
;Standard exceptions
#ifndef FPS_NO_CHECK
#ifdef FPS_DEBUG
FPS_THROW_PSOF		BGND					;parameter stack overflow
FPS_THROW_PSUF		BGND					;parameter stack underflow
#else
FPS_THROW_PSOF		FEXCPT_THROW	FEXCPT_EC_PSOF		;parameter stack overflow
FPS_THROW_PSUF		FEXCPT_THROW	FEXCPT_EC_PSUF		;parameter stack underflow
#endif
#endif
	
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

;FPS_DOT_S_HEADER	STRING_NL_NONTERM
;			FCC	"Parameter stack:"
;			STRING_NL_TERM
;FPS_DOT_S_SEPARATOR	FCS	": "
	
FPS_TABS_END		EQU	*
FPS_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FPS_WORDS_START_LIN
			ORG 	FPS_WORDS_START, FPS_WORDS_START_LIN
#else
			ORG 	FPS_WORDS_START
FPS_WORDS_START_LIN	EQU	@
#endif	

;#ANSForth Words:
;================
;Word: DUP ( x -- x x )
;Duplicate x.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
CFA_DUP			DW	CF_DUP

;Word: DROP ( x -- )
;Remove x from the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
CFA_DROP		DW	CF_DROP

;Word: ROT ( x1 x2 x3 -- x2 x3 x1 )
;Rotate the top three stack entries.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
CFA_ROT			DW	CF_ROT

;Word: OVER ( x1 x2 -- x1 x2 x1 )
;Place a copy of x1 on top of the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
CFA_OVER		DW	CF_OVER

;Word: SWAP ( x1 x2 -- x2 x1 )
;Exchange the top two stack items.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
CFA_SWAP		DW	CF_SWAP

;Word: 2DUP ( x1 x2 -- x1 x2 x1 x2 )
;Duplicate cell pair x1 x2.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
CFA_TWO_DUP		DW	CF_TWO_DUP

;Word: 2DROP ( x1 x2 -- )
;Drop cell pair x1 x2 from the stack.
;
;S12CForth implementation details:
; - Doesn't throw any exception, resets the parameter stack on underflow 
CFA_TWO_DROP		DW	CF_TWO_DROP

;Word: 2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the
;top of the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
CFA_TWO_ROT		DW	CF_TWO_ROT	

;Word: 2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
;Copy cell pair x1 x2 to the top of the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
CFA_TWO_OVER		DW	CF_TWO_OVER

;Word: 2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
;Exchange the top two cell pairs.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
CFA_TWO_SWAP		DW	CF_TWO_SWAP
	
FPS_WORDS_END		EQU	*
FPS_WORDS_END_LIN	EQU	@

