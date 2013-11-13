;###############################################################################
;# S12CForth- FUDUCT - User Ductionary and User Variables                      #
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
;#    This module implements the user dictionary, user variables, and the PAD. #
;#                                                                             #
;#    The following registers are implemented:                                 #
;#             CP = Compile pointer                                            #
;#                  Points to the next free space after the dictionary         #
;#            PAD = Beginning of the PAD buffer 			       #
;#                  Points to the next byte after the PAD		       #
;#            HLD = Pointer for pictured numeric output			       #
;#                  Points to the first character on the PAD                   #
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
;          UDUCT_PS_END
	
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
;Boundaries
;UDICT_PS_START		EQU	0
;UDICT_PS_END		EQU	0

;Safety distance between the user dictionary and the PAD
#ifndef UDICT_PADDING
UDICT_PADDING		EQU	4 	;default is 4 bytes
#endif

;PAD SIZE
#ifndef PAD_SIZE
PAD_SIZE		EQU	84 	;default is 84 bytes
#endif
#ifndef PAD_MINSIZE
PAD_MINSIZE		EQU	4 	;default is 4 bytes
#endif
	
;Safety distance between the PAD and the parameter stack
#ifndef PS_PADDING
PS_PADDING		EQU	16 	;default is 16 bytes
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;User Dictionary start address
UDICT_START		EQU	UDICT_PS_START	

;Error codes
;FUDICT_EC_DICTOF	EQU	FEXCPT_EC_DICTOF	;DICT overflow (-8)
;FUDICT_EC_PADOF		EQU	FEXCPT_EC_PADOF		;PAD overflow  (-17)
;FUDICT_EC_PSOF		EQU	FEXCPT_EC_PSOF		;PS overflow   (-3)
;FUDICT_EC_PSUF		EQU	FEXCPT_EC_PSUF		;PS underflow  (-4)
;FUDICT_EC_RSOF		EQU	FEXCPT_EC_RSOF		;RS overflow   (-5)
;FUDICT_EC_RSUF		EQU	FEXCPT_EC_RSUF		;RS underflow  (-6)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FUDICT_VARS_START_LIN
			ORG 	FUDICT_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FUDICT_VARS_START
FUDICT_VARS_START_LIN	EQU	@
#endif

CP			DS	2 	;compile pointer (next free space after the dictionary) 
CP_SAVED		DS	2 	;last compile pointer (before the current compilation)  
HLD			DS	2	;pointer for pictured numeric output
PAD                     DS	2	;end of the PAD buffer

FUDICT_VARS_END		EQU	*
FUDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FUDICT_INIT, 0
			;Initialize dictionary
			LDD	#UDICT_START
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

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FUDICT_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FUDICT_QUIT, 0
#emac
	
;#Suspend action
#macro	FUDICT_SUSPEND, 0
#emac
	
;#User dictionary (UDICT)
;----------------------- 
;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   1: required space (bytes)
; result: X: CP-new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	UDICT_CHECK_OF, 1
			LDX	CP 			;=> 3 cycles
			LEAX	\1,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FUDICT_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
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
#macro	UDICT_CHECK_OF_A, 0
			LDX	CP 			;=> 3 cycles
			LEAX	A,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FUDICT_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
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
			BHI	FUDICT_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
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
			BLS	FUDICT_PADOF_HANDLER	;=> 3 cycles/ 4 cycles
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
			SSTACK_JOBSR	FUDICT_PAD_ALLOC, 2
			TBEQ	D, FUDICT_PADOF_HANDLER 	;no space available at all
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

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FUDICT_CODE_START_LIN
			ORG 	FUDICT_CODE_START, FUDICT_CODE_START_LIN
#else
			ORG 	FUDICT_CODE_START
FUDICT_CODE_START_LIN	EQU	@
#endif

;PAD_ALLOC: allocate the PAD buffer (PAD_SIZE bytes if possible) (PAD -> D)
; args:   none
; result: D: PAD (= HLD), $0000 if no space is available
; SSTACK: 2
;        X and Y are preserved 
FUDICT_PAD_ALLOC	EQU	*
			;Calculate available space
			LDD	PSP
			SUBD	CP
			;BLS	FUDICT_PAD_ALLOC_4 	;no space available at all
			;Check if requested space is available
			CPD	#(PAD_SIZE+PS_PADDING)
			BLO	FUDICT_PAD_ALLOC_3	;reduce size
			LDD	CP
			ADDD	#PAD_SIZE
			;Allocate PAD
FUDICT_PAD_ALLOC_1	STD	PAD
			STD	HLD
			;Done 
FUDICT_PAD_ALLOC_2	SSTACK_PREPULL	2
			RTS
			;Reduce PAD size 
FUDICT_PAD_ALLOC_3	CPD	#(PAD_MINSIZE+PS_PADDING)
			BLO	FUDICT_PAD_ALLOC_4		;not enough space available
			LDD	PSP
			SUBD	#PS_PADDING
			JOB	FUDICT_PAD_ALLOC_1 	;allocate PAD
			;Not enough space available
FUDICT_PAD_ALLOC_4	LDD 	$0000 			;signal failure
			JOB	FUDICT_PAD_ALLOC_2	;done

;#Dictionary overflow handler
FUDICT_DICTOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_DICTOF

;#PAD overflow handler
FUDICT_PADOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_PADOF

;#PS overflow handler
FUDICT_PSOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_PSOF

;#PS underflow handler
FUDICT_PSUF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_PSUF

;#RS overflow handler
RAM_RSOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_RSOF
	
;#RS underflow handler
FUDICT_RSUF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_RSUF
			BGND
	
FUDICT_CODE_END		EQU	*
FUDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FUDICT_TABS_START_LIN
			ORG 	FUDICT_TABS_START, FUDICT_TABS_START_LIN
#else
			ORG 	FUDICT_TABS_START
FUDICT_TABS_START_LIN	EQU	@
#endif	

FUDICT_TABS_END		EQU	*
FUDICT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FUDICT_WORDS_START_LIN
			ORG 	FUDICT_WORDS_START, FUDICT_WORDS_START_LIN
#else
			ORG 	FUDICT_WORDS_START
FUDICT_WORDS_START_LIN	EQU	@
#endif	

FUDICT_WORDS_END		EQU	*
FUDICT_WORDS_END_LIN	EQU	@

