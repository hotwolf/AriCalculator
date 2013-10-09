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
;        UDICT_RS_START, -> |              |              | 	     
;           UDICT_START     |       User Dictionary       |	     
;                           |       User Variables        |	     
;                           |              |              |	     
;                           |              v              |	     
;                       -+- | --- --- --- --- --- --- --- |
;             UDICT_PADDING |                             | <- [CP]	     
;                       -+- | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [HLD]	     
;                           |             PAD             |	     
;                       -+- | --- --- --- --- --- --- --- |          
;             RS_PADDING |  |                             | <- [PAD]          
;                       -+- .                             .          
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
;UDICT_RS_START		EQU	0
;UDICT_RS_END		EQU	0

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
			ORG 	FPS_VARS_START, FRS_VARS_START_LIN
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
	
;#Abort action (to be executed in addition of quit and suspend action)
#macro	FPS_ABORT, 0
			;Reset parameter stack
			MOVW	#PS_EMPTY,	PSP		
#emac
	
;#Quit action (to be executed in addition of suspend action)
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
; result: D: copied PS content
;	  Y: PSP
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
; result: D: copied PS content
;	  Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X is preserved 
#macro	PS_COPY_D, 0
			PS_CHECK_UF	1		;check for underflow	=> 8 cycles
			LDD		0,Y		;PS -> Y		=> 3 cycles 
							;                         ---------
							;                         11 cycles
#emac	

;PS_PUSH: Push one entry from index X onto the return stack (PSP -> Y)
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

;PS_DROP: Remove entries from the parameter stack (PSP -> Y)
; args:   none
; result: 1: number of cells to remove
;	  Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSUF
;         X is preserved 
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

FPS_WORDS_END		EQU	*
FPS_WORDS_END_LIN	EQU	@

