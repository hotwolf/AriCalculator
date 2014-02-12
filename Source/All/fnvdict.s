;###############################################################################
;# S12CForth- FRAM - Stack and buffer management for the Forth VM              #
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
NVDICT_LAST_PAGE	EQU	$FE		;default page $FE
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
NVDICT_START		EQU	$8000		;start of the dictionary
NVDICT_END		EQU	$C000		;end of the dictionary

;NVM phrase size 
#ifdef	NVM_PHRASE_SIZE
NVDICT_PHRASE_SIZE	EQU	NVM_PHRASE_SIZE
#else
NVDICT_PHRASE_SIZE	EQU	8	
#endif	
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef NVDICT_VARS_START_LIN
			ORG 	NVDICT_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	NVDICT_VARS_START
NVDICT_VARS_START_LIN	EQU	@


NVDICT_INFO		DS	2 		;pointer to the NVDICT info field
DP			DS	2 		;data pointer (next free space in the data space) 
NVC			DS	2 		;non-volatile compile flag 

NVDICT_VARS_END		EQU	*
NVDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	NVDICT_INIT, 0
#emac

;#Quit action
#macro	NVDICT_QUIT, 0
#emac

;#Abort action (in case of break or error)
#macro	NVDICT_ABORT, 0
#emac

;#Functions
;NVDICT_SCAN_PAGE: Scan the current PPAGE for a valid dictionary
; args:   PPAGE: flash page to scan
; result: Y:     ponter to last field in pointer field, 0 if page is empty
;         X:     NVDICT root, 0 if page is invalid
; SSTACK: 2 bytes
;         D and PPAGE are preserved 
#macro	NVDICT_SCAN_PAGE, 0
			SSTACK_JOBSR	NVDICT_SCAN_PAGE, 2
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef NVDICT_CODE_START_LIN
			ORG 	NVDICT_CODE_START, NVDICT_CODE_START_LIN
#else
			ORG 	NVDICT_CODE_START
NVDICT_CODE_START_LIN	EQU	@
#endif



;Search word in dictionary (compile state)
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16  bytes
;         X and Y are preserved 
FNVDICT_BUFFER_SEARCH		EQU	*



	
;Search word in dictionary (interpretation state)
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16  bytes
;         X and Y are preserved 
FNVDICT_SEARCH		EQU	*











	

;NVDICT_SCAN_PAGE: Scan the current PPAGE for a valid dictionary
; args:   PPAGE: flash page to scan
; result: Y:     ponter to last field in pointer field, 0 if page is empty
;         X:     NVDICT root, 0 if page is invalid
; SSTACK: 2 bytes
;         D and PPAGE are preserved 
NVDICT_SCAN_PAGE	EQU	*
			;Find pointer field
			LDY	#(NVDICT_END+NVDICT_PHRASE_SIZE-2)	;initialize prase pointer
NVDICT_SCAN_PAGE_1	LDX	NVDICT_PHRASE_SIZE, Y- 			;read last word of phrase
			CPY	#NVDICT_START	   			;check range
			BLS	NVDICT_SCAN_PAGE_3 			;page is empty
			IBEQ	X, NVDICT_SCAN_PAGE_1 			;loop
			;Check if page is invalid (phrase pointer in X, NVDICT_ROOT+1 in X)  
			LEAX	-1,X
			;Done  (phrase pointer in X, NVDICT_ROOT in X)
NVDICT_SCAN_PAGE_2	SSTACK_PREPULL	2
			RTS
			;Page is empty 
NVDICT_SCAN_PAGE_3	LDY	#$0000
			LEAX	-1,Y
			JOB	NVDICT_SCAN_PAGE_2









	
NVDICT_CODE_END		EQU	*
NVDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef NVDICT_TABS_START_LIN
			ORG 	NVDICT_TABS_START, NVDICT_TABS_START_LIN
#else
			ORG 	NVDICT_TABS_START
NVDICT_TABS_START_LIN	EQU	@
#endif	

NVDICT_TABS_END		EQU	*
NVDICT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef NVDICT_WORDS_START_LIN
			ORG 	NVDICT_WORDS_START, NVDICT_WORDS_START_LIN
#else
			ORG 	NVDICT_WORDS_START
NVDICT_WORDS_START_LIN	EQU	@
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


NVDICT_WORDS_END	EQU	*
NVDICT_WORDS_END_LIN	EQU	@

