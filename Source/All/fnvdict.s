#ifndef FNVDICT_COMPILED
#define FNVDICT_COMPILED
;###############################################################################
;# S12CForth - FNVDICT - Non-Volatile Dictionary and User Variables            #
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
;#    This module implements the non-volatile user dictionary and user         #
;#    variables.                                                               # 
;#                                                                             #
;#    The following registers are implemented:                                 #
;#             DP = Data pointer                                               #
;#                  Points to the next free location in the user variable      #
;#                  space                                                      #
;#            NVC = 0 -> Volatile compilation (UDICT)  		               #
;#                 -1 -> Non-volatile compilation (UNVICT)                     #
;#                                                                             #
;#    Compile strategy:                                                        #
;#    The non-volatile dictionary space is allocated after scanning the flash  #
;#    memory. When the NVDICT is selected as compile target, the UDICT is      #
;#    cleared and used as a buffer for compilation. During this buffered       #
;#    compilation, the data pointer is tracked in the variable DP. The compile #
;#    pointer is tracked in the variable CP. Dictionary entries in the compile #
;#    in interpretation state. Look-ups in compile state will return address   #
;#    translated CFAs pointing to the intended location within the flash       #
;#    space. Then the compilation of a code sequence is finished, the compile  #
;#    buffer is copied into the flash as a string.                             #
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
;                           NVM usage:
;      	                    +--------------+--------------+	     
;                           |                             |		  
;                           |           NVDICT            | NVDICT_FIRST_PAGE
;    	                    |                             |		  
;      	                    +--------------+--------------+	     
;                           .                             .          
;                           .                             .          
;      	                    +--------------+--------------+	     
;    	                    |                             |		  
;                           | NVDICT_FD_EN: NVDICT        | $FD			  
;                           |         else: Code Space    |	  
;      	                    +--------------+--------------+	     
;                           |                             |		  
;                           | NVDICT_FE_EN: NVDICT        | $FE			  
;                           |         else: Code Space    |	  
;      	                    +--------------+--------------+	     
;                           |                             |		  
;                           |        Code Space           | $FF		  
;    	                    |                             |		  
;                           +--------------+--------------+        
;        
;                           NVDICT mapping:
;      	                    +--------------+--------------+	     
;          NVDIDCT_START -> |              |              |
;                = $8000    |           NVDICT            |	     
;                           |              |              |	     
;                           |              v              |	     
;                        -+-| --- --- --- --- --- --- --- |
;                  padding| |                             |
;                        -+-| --- --- --- --- --- --- --- |
;                         | |          NVDICT_DP          |
;               info field| | --- --- --- --- --- --- --- |
;                         | |       NVDICT_LAST_NFA       | <- [NVDICT_INFO]
;                        -+-| --- --- --- --- --- --- --- |
;                         | |                             |	  
;     n*NVDICT_PHRASE_SIZE| |     Unprogrammed Flash      |
;                         | |                             |
;                        -+-+--------------+--------------+   
;            NVDIDCT_END ->
;                = $C000       
;   		  	    
;                           Word format:
;                           +-----------------------------+
;                     NFA-> |  IMMEDIATE / Previous NFA   |	
;                           +--------------+--------------+
;                           |                             | 
;                           |            Name             | 
;                           |                             | 
;                           |              +--------------+ 
;                           |              |    Padding   | 
;                           +--------------+--------------+
;                     CFA-> |       Code Field Address    |	
;                           +--------------+--------------+
;                           |                             | 
;                           |            Data             | 
;                           |                             | 
;                           +--------------+--------------+   
;        
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Flash pages reserved for the NVDICT 
#ifdef	NVDICT_FIRST_PAGE
NVDICT_FIRST_PAGE	EQU	$E0 		;default first page in 512k flash
#endif	
#ifdef	NVDICT_LAST_PAGE
FNVDICT_LAST_PAGE	EQU	$FE		;default page $FE
#endif	
#ifndef	NVDICT_SKIP_PAGE_FD
#ifndef	NVDICT_USE_PAGE_FD
NVDICT_SKIP_PAGE_FD	EQU	1 		;default skip page $FD
#endif
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Memory boundaries
FNVDICT_START		EQU	$8000		;start of the dictionary
FNVDICT_END		EQU	$C000		;end of the dictionary

;NVM phrase size 
#ifdef	FNVM_PHRASE_SIZE
FNVDICT_PHRASE_SIZE	EQU	NVM_PHRASE_SIZE
#else
FNVDICT_PHRASE_SIZE	EQU	8	
#endif	

;NVC variable 
NVC_VOLATILE		EQU	FALSE
NVC_NON_VOLATILE	EQU	TRUE
	
;Max. line length
FUDICT_LINE_WIDTH	EQU	DEFAULT_LINE_WIDTH
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FNVDICT_VARS_START_LIN
			ORG 	FNVDICT_VARS_START, FNVDICT_VARS_START_LIN
#else
			ORG 	FNVDICT_VARS_START
FNVDICT_VARS_START_LIN	EQU	@
#endif	

DP			DS	2 		;data pointer (next free space in the data space) 
NVC			DS	2 		;non-volatile compile flag 

FNVDICT_VARS_END	EQU	*
FNVDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FNVDICT_INIT, 0
			MOVW	#$0000, DP
			MOVW	#$0000, NVC
#emac

;#Abort action (to be executed in addition of quit action)
#macro	FNVDICT_ABORT, 0
#emac
	
;#Quit action
#macro	FNVDICT_QUIT, 0
#emac
	
;#Suspend action
#macro	FNVDICT_SUSPEND, 0
#emac

;Dictionary operations:
;======================	
;#Look-up word in user dictionary 
; args:   X: string pointer (terminated string)
;	  Y: start of dictionary (last NFA)
; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
; SSTACK: 8 bytes
;         X and Y are preserved
#macro	FNVDICT_FIND, 0
			LDD	#$0000
#emac

;#Reverse lookup a CFA and print the corresponding word
; args:   D: CFA
; result: C-flag: set if successful
;	  Y: start of dictionary (last NFA)
; SSTACK: 18 bytes
;         X and D are preserved
;#macro	FNVDICT_REVPRINT_BL, 0
;			CLC
;#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FNVDICT_CODE_START_LIN
			ORG 	FNVDICT_CODE_START, FNVDICT_CODE_START_LIN
#else
			ORG 	FNVDICT_CODE_START
FNVDICT_CODE_START_LIN	EQU	@
#endif
	
FNVDICT_CODE_END		EQU	*
FNVDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FNVDICT_TABS_START_LIN
			ORG 	FNVDICT_TABS_START, FNVDICT_TABS_START_LIN
#else
			ORG 	FNVDICT_TABS_START
FNVDICT_TABS_START_LIN	EQU	@
#endif	

FNVDICT_TABS_END		EQU	*
FNVDICT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FNVDICT_WORDS_START_LIN
			ORG 	FNVDICT_WORDS_START, FNVDICT_WORDS_START_LIN
#else
			ORG 	FNVDICT_WORDS_START
FNVDICT_WORDS_START_LIN	EQU	@
#endif	

;#ANSForth Words:
;================

;S12CForth Words:
;================
;Word: NVC ( -- a-addr ) 
;a-addr is the address of a cell containing the non-volatile compile flag. NVC
;is true when non-volatile compilation is selected, false otherwise. The true 
;value in STATE is non-zero. Only the following standard words alter the value
;in NVC:
; NV{ and }NV:
;  Note:  A program shall not directly alter the contents of NV. 
;
;Throws:
;"Parameter stack overflow"
CFA_NVC			DW	CF_CONSTANT_RT
			DW	NVC


FNVDICT_WORDS_END	EQU	*
FNVDICT_WORDS_END_LIN	EQU	@
#endif
