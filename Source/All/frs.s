;###############################################################################
;# S12CForth- FRS - Return Stack for the Forth VM                              #
;###############################################################################
;#    Copyright 2010 - 2013 Dirk Heisswolf                                     #
;#    This file is part of the S12CForth frsework for Freescale's S12C MCU     #
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
;#    This module implements the return stack.                                 #
;#                                                                             #
;#    The return stack uses these registers:                                   #
;#            RSP = Return stack pointer.				       #
;#	            Points to the top of the return stack.                     #
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
;                           +--------------+--------------+        
;    	       TIB_START -> |              |              | |          
;                           |       Text Input Buffer     | | [TIB_CNT]
;                           |              |              | |	       
;                           |              v              | <	       
;                           | --- --- --- --- --- --- --- | 	       
;                           .                             . <- [TIB_START+TIB_CNT] 
;                           .                             .            
;                           | --- --- --- --- --- --- --- |            
;                           |              ^              | <- [RSP]
;                           |              |              |
;                           |        Return Stack         |
;                           |              |              |
;                           +--------------+--------------+
;       FRS_TIB_RS_END, ->                                 
;              RS_EMPTY



;#Common word format:
; ===================
;	
;        +-----------------------------+
;  NFA-> |         Previous NFA        |	
;        +--------------+--------------+
;        |PRE|CFA offset| 
;        +--------------+   
;        |              | 
;        |              | 
;        |     Name     | 
;        |              | 
;        |              | 
;        +-----------------------------+
;  CFA-> |       Code Field Address    |	
;        +--------------+--------------+
;        |              | 
;        |              | 
;        |     Data     | 
;        |              | 
;        |              | 
;        +--------------+   
;                              
; args: 1. name of the word
;       2. previous word entry
;       3. precedence bit (1:immediate, 0:compile)
IMMEDIATE	EQU	1
COMPILE		EQU	0
#macro	FHEADER, 3
PREV		DW	\2
NAME_CNT	DB	((NAME_END-NAME_START)&$7F)|(\3<<7)
NAME_START	FCS	\1
		ALIGN	1
NAME_END	
#emac	



	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Memory boundaries
;FRS_DICT_PS_START	EQU	0	;start of shared DICT/PAD/PS space
;FRS_DICT_PS_END	EQU	0	;end of shared DICT/PAD/PS space
;FRS_TIB_RS_START	EQU	0	;start of shared TIB/RS space
;FRS_TIB_RS_END	EQU	0	;end of shared TIB/RS space

;Safety distance between TIB and RS
#ifndef FRS_TIB_RS_DIST
FRS_TIB_RS_DIST	EQU	4 	;default is 4 bytes
#endif

;PAD SIZE
#ifndef FRS_PAD_SIZE
FRS_PAD_SIZE		EQU	84 	;default is 84 bytes
#endif
#ifndef FRS_PAD_MINSIZE
FRS_PAD_MINSIZE	EQU	4 	;default is 4 bytes
#endif
	
;Safety distance between TIB and PS
#ifndef FRS_TIB_PS_DIST
FRS_PAD_PS_DIST	EQU	16 	;default is 16 bytes
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Memory boundaries
DICT_START		EQU	FRS_DICT_PS_START ;start of the dictionary
PS_EMPTY		EQU	FRS_DICT_PS_END   ;PSP on empty PS
TIB_START		EQU	FRS_TIB_RS_START  ;start of the TIB
RS_EMPTY		EQU	FRS_TIB_RS_END	   ;RSP on empty RS

;Error codes
FRS_EC_DICTOF		EQU	FEXCPT_EC_DICTOF	;DICT overflow (-8)
FRS_EC_PADOF		EQU	FEXCPT_EC_PADOF		;PAD overflow  (-17)
FRS_EC_PSOF		EQU	FEXCPT_EC_PSOF		;PS overflow   (-3)
FRS_EC_PSUF		EQU	FEXCPT_EC_PSUF		;PS underflow  (-4)
FRS_EC_RSOF		EQU	FEXCPT_EC_RSOF		;RS overflow   (-5)
FRS_EC_RSUF		EQU	FEXCPT_EC_RSUF		;RS underflow  (-6)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FRS_VARS_START_LIN
			ORG 	FRS_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FRS_VARS_START
FRS_VARS_START_LIN	EQU	@

CP			DS	2 	;compile pointer (next free space after the dictionary) 
CP_SAVED		DS	2 	;last compile pointer (before the current compilation)  
HLD			DS	2	;pointer for pictured numeric output
PAD                     DS	2	;end of the PAD buffer
PSP			DS	2 	;parameter stack pointer (top of stack)
NUMBER_TIB  		DS	2	;number of chars in the TIB
TO_IN  			DS	2	;in pointer of the TIB (TIB_START+TO_IN points to the next character)
RSP			DS	2 	;return stack pointer (top of stack)

FRS_VARS_END		EQU	*
FRS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FRS_INIT, 0
			;Initialize dictionary
			LDD	#DICT_START
			STD	CP
			STD	CP_SAVED
	
			;Initialize PAD (DICT_START in D)
			STD	PAD 		;Pad is allocated on demand
			STD	HLD

			;Initialize parameter stack
			MOVW	#PS_EMPTY,	PSP	
	
			;Initialize TIB
			MOVW	#(TIB_START-1),   TO_IN
			MOVW	#$0000,   	NUMBER_TIB

			;Initialize return stack
			MOVW	#PS_EMPTY,	PSP	
#emac

;#Quit action
#macro	FRS_QUIT, 0
			;Initialize TIB
			MOVW	#(TIB_START-1),   TO_IN
			MOVW	#$0000,   	NUMBER_TIB

			;Initialize return stack
			MOVW	#PS_EMPTY,	PSP	
#emac

;#Abort action (in case of break or error)
#macro	FRS_ABORT, 0
			;Quit action 
			FRS_QUIT

			;Initialize parameter stack
			MOVW	#PS_EMPTY,	PSP	
#emac
	
;#User dictionary (DICT)
;----------------------- 
;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   1: required space (bytes)
; result: X: CP-new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	DICT_CHECK_OF, 1
			LDX	CP 			;=> 3 cycles
			LEAX	\1,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FRS_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  -------------------
							;   17 cycles/12 cycles
#emac			

;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   A: required space (bytes)
; result: X: CP-new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	DICT_CHECK_OF_A, 0
			LDX	CP 			;=> 3 cycles
			LEAX	A,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FRS_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  --------------------
							;   17 cycles/12 cycles
#emac			
	
;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   D: required space (bytes)
; result: X: CP-new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	DICT_CHECK_OF_D, 0
			LDX	CP 			;=> 3 cycles
			LEAX	D,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FRS_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  --------------------
							;   17 cycles/12 cycles
#emac			
	
;#Pictured numeric output buffer (PAD)
;-------------------------------------
;PAD_CHECK_OF: check if there is room for one more character on the PAD (HLD -> X)
; args:   none
; result: X: HLD
; SSTACK: none
; throws: FEXCPT_EC_PADOF
;        Y and D are preserved 
#macro	PAD_CHECK_OF, 0
			LDX	HLD 			;=> 3 cycles
			CPX	CP			;=> 3 cycles
			BLS	FRS_PADOF_HANDLER	;=> 3 cycles/ 4 cycles
							;  -------------------
							;   9 cycles/10 cycles
#emac			
	
;PAD_ALLOC: allocate the PAD buffer (PAD_SIZE bytes if possible) (PAD -> D)
; args:   none
; result: D: PAD (= HLD)
; SSTACK: 2 bytes
; throws: FEXCPT_EC_PADOF
;        X and Y are preserved 
#macro	PAD_ALLOC, 0 
			SSTACK_JOBSR	FRS_PAD_ALLOC, 2
			TBEQ	D, FRS_PADOF_HANDLER 	;no space available at all
#emac			

;PAD_DEALLOC: deallocate the PAD buffer  (PAD -> D)
; args:   none
; result: D: CP (= HLD = PAD)
; SSTACK: none
;        X and Y are preserved 
#macro	PAD_DEALLOC, 0 
			LDD	CP
			STD	PAD
			STD	HLD
#emac			
	
;#Parameter stack
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
			CPY	#(PS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	FRS_PSUF_HANDLER	;=> 3 cycles/ 4 cycles
							;  -------------------
							;   8 cycles/ 9 cycles
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
			CPY	PAD			;=> 3 cycles
			BLO	FRS_PSOF_HANDLER	;=> 3 cycle / 4 cycles
							;  -------------------
							;  11 cycles/ 12 cycles
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
			CPY	PAD			;=> 3 cycles
			BLO	FRS_PSOF_HANDLER	;=> 3 cycles/  4 cycles
							;  --------------------
							;  19 cycles/ 20 cycles
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
			CPY	#(PS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	FRS_PSUF_HANDLER	;=> 3 cycles/  4 cycles
			LEAY	-(2*\2),Y		;=> 2 cycles
			CPY	PAD			;=> 3 cycles
			BLO	FRS_PSOF_HANDLER	;=> 3 cycles/  4 cycles
							;  --------------------
							;  16 cycles/ 18 cycles
#emac
	
;PS_PULL_X: pull one entry from the parameter stack into index Y (PSP -> Y)
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
	
;PS_PULL_D: pull one entry from the parameter stack into accu D (PSP -> Y)
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




	
;PS_PUSH_X: Push one entry from index X onto the return stack (PSP -> Y)
; args:   X: cell to push onto the PS
; result: Y: PSP
; SSTACK: none
; throws: FEXCPT_EC_PSOF
         X and D are preserved 
#macro	PS_PUSH_X, 0
			PS_CHECK_OF	1		;check for overflow	=> 9 cycles
			STX		0,Y		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         15 cycles
#emac	

;PS_PUSH_D: Push one entry from accu D onto the return stack (PSP -> Y)
; args:   D: cell to push onto the PS
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
; args:   D: cell to push onto the PS
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
	
;#Text input buffer (TIB)
;TIB_CHECK_OF: check if there is room for another character on the TIB (next free TIB location -> X)
; args:   1: required character space
; result: X: next free TIB location
; SSTACK: none
; throws: FEXCPT_EC_TIBOF
;        Y and D are preserved 
#macro	TIB_CHECK_OF, 1
			LDX	NUMBER_TIB		;=> 3 cycles
			LEAX	(TIB_START+\1),X	;=> 2 cycles
			CPX	RSP			;=> 3 cycles
			BHI	FRS_TIBOF_HANDLER	;=> 3 cycle / 4 cycles
							;  -------------------
							;  11 cycles/12 cycles
#emac
	
;#Return stack
;RS_RESET: reset the parameter stack
; args:   none
; result: none
; SSTACK: none
;        X, Y and D are preserved 
#macro	RS_RESET, 0
			MOVW	#RS_EMPTY,	RSP	
#emac

;RS_CHECK_UF: check for a minimum number of stack entries (RSP -> X)
; args:   1: required stack content (cells)
; result: X: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSUF
;        Y and D are preserved 
#macro	RS_CHECK_UF, 1
			LDX	RSP 			;=> 3 cycles
			CPX	#(RS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	FRS_RSUF_HANDLER	;=> 3 cycles/ 4 cycles
							;  -------------------
							;   8 cycles/ 9 cycles
#emac

;RS_CHECK_OF: check if there is room for a number of stack entries (X modified)
; args:   1: required stack space (cells)
; result: none
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        Y and D are preserved 
#macro	RS_CHECK_OF, 1
			LDX	NUMBER_TIB		;=> 3 cycles
			LEAX	(TIB_START+(2*\1)),X	;=> 2 cycles
			CPX	RSP			;=> 3 cycles
			BHI	FRS_RSOF_HANDLER	;=> 3 cycles/ 4 cycles
							;  -------------------
							;  11 cycles/12 cycles
#emac
	
;RS_CHECK_OF_KEEP_X: check if there is room for a number of stack entries (Y modified)
; args:   1: required stack space (cells)
; result: none
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        X and D are preserved 
#macro	RS_CHECK_OF_KEEP_X, 1
			LDY	NUMBER_TIB		;=> 3 cycles
			LEAY	(TIB_START+(2*\1)),Y	;=> 2 cycles
			CPY	RSP			;=> 3 cycles
			BHI	FRS_RSOF_HANDLER	;=> 3 cycles/ 4 cycles
							;  -------------------
							;  11 cycles/12 cycles
#emac
	
;RS_PULL: pull one entry from the return stack  (RSP -> X)
; args:   1: address of variable to pull data into
; result: X: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSUF
;        Y and D are preserved 
#macro	RS_PULL, 1
			RS_CHECK_UF	1		;check for underflow	=> 8 cycles
			MOVW		2,X+, \1	;RS -> X		=> 3 cycles 
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         14 cycles
#emac	
	
;RS_PULL_Y: pull one entry from the return stack into index Y
; args:   none
; result: X: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSUF
;        Y and D are preserved 
#macro	RS_PULL_Y, 0	;1:underflow handler  
			RS_CHECK_UF	1		;check for underflow	=> 8 cycles
			LDY		2,X+		;RS -> X		=> 3 cycles 
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         14 cycles
#emac	
	
;RS_PUSH: push a variable onto the return stack (RSP -> X)
; args:   1: address of variable to push data from
; result: Y: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        Y and D are preserved
#macro	RS_PUSH, 1	;1:variable
			RS_CHECK_OF	1		;check for overflow	=>11 cycles
			LDX		RSP		;var -> RS		=> 3 cycles
			MOVW		\1, 2,-X	;			=> 5 cycles
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         22 cycles
#emac	

;RS_PUSH: push a variable onto the return stack and don't touch index X
; args:   1: variable
; result: Y: RSP
; SSTACK: none
; throws: FEXCPT_EC_RSOF
;        X and D are preserved
#macro	RS_PUSH_KEEP_X, 1	;1:variable
			LDY	NUMBER_TIB		;=> 3 cycles
			LEAY	(TIB_START+2),Y		;=> 2 cycles
			CPY	RSP			;=> 3 cycles
			BHI	FRS_RSOF_HANDLER	;=> 3 cycle / 4 cycles
			LDY	RSP			;=> 3 cycles
			MOVW	\1, 2,-Y		;=> 5 cycles
			STY	RSP			;=> 3 cycles
							;  ---------
							;  22 cycles
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FRS_CODE_START_LIN
			ORG 	FRS_CODE_START, FRS_CODE_START_LIN
#else
			ORG 	FRS_CODE_START
FRS_CODE_START_LIN	EQU	@
#endif




;PAD_ALLOC: allocate the PAD buffer (PAD_SIZE bytes if possible) (PAD -> D)
; args:   none
; result: D: PAD (= HLD), $0000 if no space is available
; SSTACK: 2
;        X and Y are preserved 
FRS_PAD_ALLOC		EQU	*
			;Calculate available space
			LDD	PSP
			SUBD	CP
			;BLS	FRS_PAD_ALLOC_4 	;no space available at all
			;Check if requested space is available
			CPD	#(FRS_PAD_SIZE+FRS_PAD_PS_DIST)
			BLO	FRS_PAD_ALLOC_3	;reduce size
			LDD	CP
			ADDD	#FRS_PAD_SIZE
			;Allocate PAD
FRS_PAD_ALLOC_1	STD	PAD
			STD	HLD
			;Done 
FRS_PAD_ALLOC_2	SSTACK_PREPULL	2
			RTS
			;Reduce PAD size 
FRS_PAD_ALLOC_3	CPD	#(FRS_PAD_MINSIZE+FRS_PAD_PS_DIST)
			BLO	FRS_PAD_ALLOC_		;not enough space available
			LDD	PSP
			SUBD	#FRS_PAD_PS_DIST
			JOB	FRS_PAD_ALLOC_1 	;allocate PAD
			;Not enough space available
FRS_PAD_ALLOC_4	LDD 	$0000 			;signal failure
			JOB	FRS_PAD_ALLOC_2	;done

;#Dictionary overflow handler
FRS_DICTOF_HANDLER	EQU	*
			FEXCPT_THROW	FMEM_EC_DICTOF

;#PAD overflow handler
FRS_PADOF_HANDLER	EQU	*
			FEXCPT_THROW	FMEM_EC_PADOF

;#PS overflow handler
FRS_PSOF_HANDLER	EQU	*
			FEXCPT_THROW	FMEM_EC_PSOF

;#PS underflow handler
FRS_PSUF_HANDLER	EQU	*
			FEXCPT_THROW	FMEM_EC_PSUF

;#RS overflow handler
RAM_RSOF_HANDLER	EQU	*
			FEXCPT_THROW	FMEM_EC_RSOF
	
;#RS underflow handler
FRS_RSUF_HANDLER	EQU	*
			FEXCPT_THROW	FMEM_EC_RSUF
	
FRS_CODE_END		EQU	*
FRS_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FRS_TABS_START_LIN
			ORG 	FRS_TABS_START, FRS_TABS_START_LIN
#else
			ORG 	FRS_TABS_START
FRS_TABS_START_LIN	EQU	@
#endif	

FRS_TABS_END		EQU	*
FRS_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FRS_WORDS_START_LIN
			ORG 	FRS_WORDS_START, FRS_WORDS_START_LIN
#else
			ORG 	FRS_WORDS_START
FRS_WORDS_START_LIN	EQU	@
#endif	

FRS_WORDS_END		EQU	*
FRS_WORDS_END_LIN	EQU	@

