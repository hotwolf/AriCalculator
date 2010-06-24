;###############################################################################
;# S12CForth- FMEM - Memory management for the Forth VM                        #
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
;#    This module implements the parameter and the return stack, as well as    #
;#    the TIB and the dictionary space.                                        # 
;#                                                                             #
;#    Forth virtual machine registers are defined as follows:                  #
;#       W   = Working register. 					       #
;#             The W register points to the data field of the current word,    #
;#             but it may be overwritten.				       #
;#             Used for indexed addressing and arithmetics.		       #
;#	       Index Register X is used to implement W.                        #
;#       IP  = Instruction pointer.					       #
;#             Points to the next execution token.			       #
;#       PSP = Parameter Stack Pointer.					       #
;#	       Points to the top of the parameter stack                        #
;#       RSP = Return stack pointer.					       #
;#	       Points to the top of the return stack.                          #
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
;        FMEM_VARS_START -> |             CP              |
;      	                    +--------------+--------------+
;                           |           LAST_CP           |
;      	                    +--------------+--------------+
;                           |             PSP             |
;      	                    +--------------+--------------+
;                           |             RSP             |
;      	                    +--------------+--------------+          
;                           |             PAD             |          
;      	                    +--------------+--------------+	     
;                           |             HLD             |          
;      	                    +--------------+--------------+	     
;                           |         NUMBER_TIB          |          
;      	                    +--------------+--------------+          
;                           |            TO_IN            |	     
;      	                    +--------------+--------------+	     
;    	      DICT_START -> |              |              | 	     
;                           |       User Dictionary       |	     
;                           |              |              |	     
;                           |              v              |	     
;                           | --- --- --- --- --- --- --- |	     
;                           |                             | <- [CP]  
;                           | --- --- --- --- --- --- --- |          
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
;              PS_EMPTY,    +--------------+--------------+        
;              TIB_START -> |              |              | |          
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
;               RS_EMPTY,   +--------------+--------------+
;          FMEM_VARS_END ->                                 

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Stack and buffer sizes 
;RS_SIZE		EQU	2*128
;PAD_SIZE		EQU	68
;TIB_SIZE		EQU	80
RS_SIZE			EQU	2*16
PAD_SIZE		EQU	8
TIB_SIZE		EQU	16

;Standard error codes
FMEM_EC_DICTOF		EQU	FEXCPT_EC_DICTOF	;dictionary overflow
FMEM_EC_PSOF		EQU	FEXCPT_EC_PSOF		;stack overflow
FMEM_EC_PSUF		EQU	FEXCPT_EC_PSUF		;stack underflow
FMEM_EC_RSOF		EQU	FEXCPT_EC_RSOF		;return stack overflow
FMEM_EC_RSUF		EQU	FEXCPT_EC_RSUF		;return stack underflow
FMEM_EC_TIBOF		EQU	FEXCPT_EC_TIBOF		;parsed string overflow
FMEM_EC_PADOF		EQU	FEXCPT_EC_PADOF		;pictured numeric output string overflow
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FMEM_VARS_START
CP			DS	2 	;compile pointer (next free space after the dictionary) 
SAVED_CP		DS	2 	;last compile pointer (before the current compilation)  
PSP			DS	2 	;parameter stack pointer (top of stack)
RSP			DS	2 	;return stack pointer (top of stack)
PAD                     DS	2	;end of the PAD buffer
HLD			DS	2	;pointer for pictured numeric output
NUMBER_TIB  		DS	2	;number of chars in the TIB
TO_IN  			DS	2	;in pointer of the TIB (TIB_START+TO_IN points to the next character)
DICT_START		EQU	*
PS_EMPTY		EQU	FMEM_VARS_END-(TIB_SIZE+RS_SIZE+PAD_SIZE)
PAD_START		EQU	FMEM_VARS_END-(TIB_SIZE+RS_SIZE+PAD_SIZE)
PAD_END			EQU	FMEM_VARS_END-(TIB_SIZE+RS_SIZE)
TIB_START		EQU	FMEM_VARS_END-(TIB_SIZE+RS_SIZE)
RS_EMPTY		EQU	FMEM_VARS_END

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FMEM_INIT, 0
			;Initialize memory pointers
			LDD	#DICT_START
			STD	CP
			STD	SAVED_CP	
			PS_RESET
			RS_RESET
			MOVW	#(DICT_START+PAD_SIZE), PAD
			MOVW	#(DICT_START+PAD_SIZE+1), HLD
			MOVW	#$0000,   	NUMBER_TIB
			MOVW	#(TIB_START-1),   TO_IN
#emac

;#Parameter stack
;PS_RESET: reset the parameter stack
#macro	PS_RESET, 0
			MOVW	#PS_EMPTY,	PSP	
#emac

;PS_CHECK_UF: check for a minimum number of stack entries (PSP -> Y)
#macro	PS_CHECK_UF, 2	;1:expected entries before operation 2:underflow handler  
			LDY	PSP 			;=> 3 cycles
			CPY	#(PS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	>\2			;=> 1 cycle / 3 cycles
							;  -------------------
							;   6 cycles/ 8 cycles
#emac

;PS_CHECK_OF: check if there is room for a number of stack entries (PSP-new cells -> Y)
#macro	PS_CHECK_OF, 2	;1:required cells on the stack 2:overflow handler  
			LDY	PSP 			;=> 3 cycles
			LEAY	-(2*\1),Y		;=> 2 cycles
			CPY	PAD			;=> 3 cycles
			BLO	>\2			;=> 1 cycle / 3 cycles
							;  -------------------
							;   9 cycles/ 11 cycles
#emac

;PS_CHECK_UFOF: check for over and underflow (PSP-new cells -> Y)
#macro	PS_CHECK_UFOF, 4	;1:expected entries before operation 2:underflow handler 3:required cells on the stack 4:overflow handler  
			LDY	PSP 			;=> 3 cycles
			CPY	#(PS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	>\2			;=> 1 cycle / 3 cycles
			LEAY	-(2*\3),Y		;=> 2 cycles
			CPY	PAD			;=> 3 cycles
			BLO	>\4			;=> 1 cycle / 3 cycles
							;  -------------------
							;  12 cycles/16 cycles
#emac
	
;PS_PULL_X: pull one entry from the parameter stack into index Y (PSP -> Y)
#macro	PS_PULL_X, 2	;1:expected entries before operation 2:underflow handler 
			PS_CHECK_UF	\1, \2		;check for underflow	=> 6 cycles
			LDX		2,Y+		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         12 cycles
#emac	
	
;PS_PULL_D: pull one entry from the parameter stack into accu D (PSP -> Y)
#macro	PS_PULL_D, 2	;1:expected entries before operation 2:underflow handler 
			PS_CHECK_UF	\1, \2		;check for underflow	=> 6 cycles
			LDD		2,Y+		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         12 cycles
#emac	

;PS_PUSH_D: Push one entry from accu D onto the return stack into index Y (PSP -> Y)
#macro	PS_PUSH_D, 2	;1:required cells on the stack 2:overflow handler 
			PS_CHECK_OF	\1, \2		;check for overflow	=> 9 cycles
			STD		0,Y		;PS -> Y		=> 3 cycles 
			STY		PSP		;			=> 3 cycles
							;                         ---------
							;                         15 cycles
#emac	

;#Return stack
;RS_RESET: reset the parameter stack
#macro	RS_RESET, 0
			MOVW	#RS_EMPTY,	RSP	
#emac

;RS_CHECK_UF: check for a minimum number of stack entries (RSP -> X)
#macro	RS_CHECK_UF, 2	;1:expected entries before operation 2:underflow handler  
			LDX	RSP 			;=> 3 cycles
			CPX	#(RS_EMPTY-(2*\1))	;=> 2 cycles
			BHI	>\2			;=> 1 cycle / 3 cycles
							;  -------------------
							;   6 cycles/ 8 cycles
#emac

;RS_CHECK_OF: check if there is room for a number of stack entries (X modified)
#macro	RS_CHECK_OF, 2	;1:required cells space 2:overflow handler  
			LDX	NUMBER_TIB		;=> 3 cycles
			LEAX	(TIB_START+(2*\1)),X	;=> 2 cycles
			CPX	RSP			;=> 3 cycles
			BHI	>\2			;=> 1 cycle / 3 cycles
							;  -------------------
							;   9 cycles/ 11 cycles
#emac
	
;RS_PULL: pull one entry from the return stack  (RSP -> X)
#macro	RS_PULL, 2	;1:variable 2:underflow handler  
			RS_CHECK_UF	1, \2		;check for underflow	=> 6 cycles
			MOVW		2,X+, \1	;RS -> X		=> 3 cycles 
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         12 cycles
#emac	
	
;RS_PULL_Y: pull one entry from the return stack into index Y (RSP -> X)
#macro	RS_PULL_Y, 1	;1:underflow handler  
			RS_CHECK_UF	1, \1		;check for underflow	=> 6 cycles
			LDY		2,X+		;RS -> X		=> 3 cycles 
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         12 cycles
#emac	
	
;RS_PUSH: push a variable onto the return stack (RSP -> X)
#macro	RS_PUSH, 2	;1:variable 2:overflow handler  
			RS_CHECK_OF	1, \2		;check for overflow	=> 9 cycles
			LDX		RSP		;var -> RS		=> 3 cycles
			MOVW		\1, 2,-X	;			=> 5 cycles
			STX		RSP		;			=> 3 cycles
							;                         ---------
							;                         20 cycles
#emac	

;#User dictionary (DICT) 
;DICT_CHECK_OF: check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
#macro	DICT_CHECK_OF, 2	;1:required space (in bytes) 2:overflow handler  
			LDX	CP 			;=> 3 cycles
			LEAX	\1,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	>\2			;=> 1 cycle / 3 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  -------------------
							;   15 cycles/ 17 cycles
#emac			

;DICT_CHECK_OF_A: check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
#macro	DICT_CHECK_OF_A, 1	;1:overflow handler  
			LDX	CP 			;=> 3 cycles
			LEAX	A,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	>\1			;=> 1 cycle / 3 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  -------------------
							;   15 cycles/ 17 cycles
#emac			
	
;#Pictured numeric output buffer (PAD) 
;PAD_CHECK_OF: check if there is room for one more character on the PAD (HLD -> )X
#macro	PAD_CHECK_OF, 1	;1:overflow handler  
			LDX	HLD 			;=> 3 cycles
			CPX	CP			;=> 3 cycles
			BLS	>\1			;=> 1 cycle / 3 cycles
							;  -------------------
							;   7 cycles/ 9 cycles
#emac			
	
;PAD_ALLOC: allocate the PAD buffer (PAD_SIZE bytes if possible) (PAD -> D)
#macro	PAD_ALLOC, 0 
			LDD	CP
			ADDD	#PAD_SIZE
			CPD	PSP
			BLS	PAD_ALLOC_0
			LDD	PSP
PAD_ALLOC_0		STD	PAD
			STD	HLD
#emac			
	
;PAD_ALLOC: deallocate the PAD buffer  (PAD -> D)
#macro	PAD_DEALLOC, 0 
			LDD	CP
			STD	PAD
			STD	HLD
#emac			
	
#Text input buffer (TIB)
;TIB_CHECK_OF: check if there is room for another character on the TIB (next free TIB location -> X)
#macro	TIB_CHECK_OF, 2	;1:required character space 2:overflow handler  
			LDX	NUMBER_TIB		;=> 3 cycles
			LEAX	(TIB_START+\1-1),X	;=> 2 cycles
			CPX	RSP			;=> 3 cycles
			BHS	>\2			;=> 1 cycle / 3 cycles
							;  -------------------
							;   9 cycles/12 cycles
#emac
		
;#Memory access


;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FMEM_CODE_START

;#Throw an RS overflow exception
; args:   none
FMEM_THROW_RSOF		EQU	*
			FEXCPT_THROW	FMEM_EC_RSOF
	
;#Throw an RS underflow exception
; args:   none
FMEM_THROW_RSUF		EQU	*
			FEXCPT_THROW	FMEM_EC_RSUF

;#Throw an PS overflow exception
; args:   none
FMEM_THROW_PSOF		EQU	*
			FEXCPT_THROW	FMEM_EC_PSOF

;#Throw an PS underflow exception
; args:   none
FMEM_THROW_PSUF		EQU	*
			FEXCPT_THROW	FMEM_EC_PSUF

;#Throw an DICT overflow exception
; args:   none
FMEM_THROW_DICTOF	EQU	*
			FEXCPT_THROW	FMEM_EC_DICTOF

;#Throw an PAD overflow exception
; args:   none
FMEM_THROW_PADOF	EQU	*
			FEXCPT_THROW	FMEM_EC_PADOF

;#Throw a TIB pointer out of range exception exception
; args:   none
FMEM_THROW_TIBOF	EQU	*
			FEXCPT_THROW	FMEM_EC_TIBOF

FMEM_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FMEM_TABS_START
FMEM_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FMEM_WORDS_START
FMEM_WORDS_END		EQU	*
FMEM_LAST_NFA		EQU	FMEM_PREV_NFA
