#ifndef FNVDICT_COMPILED
#define FNVDICT_COMPILED
;###############################################################################
;# S12CForth - FNVDICT - Non-Volatile Dictionary and User Variables            #
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
;#    This module implements the non-volatile user dictionary and user         #
;#    variables.                                                               # 
;#                                                                             #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    S12CForth system variables:                                              #
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
;#    October 6, 2016                                                          #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
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
;Non-volatile dictionary 
#ifndef	NVDICT_ON
#ifndef	NVDICT_OFF
NVDICT_ON		EQU	1 		;NVDICT enabled by default
#endif
#endif

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
#elseFNVDICT_PHRASE_SIZE	EQU	8	
#endif	

;;NVC variable 
;NVC_VOLATILE		EQU	FALSE
;NVC_NON_VOLATILE	EQU	TRUE
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FNVDICT_VARS_START_LIN
			ORG 	FNVDICT_VARS_START, FNVDICT_VARS_START_LIN
#else
			ORG 	FNVDICT_VARS_START
FNVDICT_VARS_START_LIN	EQU	@
#endif	
#ifdef NVDICT_ON	
	
DP			DS	2 	;compile pointer (next free space in the data space) 
DP_SAVE			DS	2 	;compile pointer to revert to in case of an error

NVDICT_LAST_NFA		DS	2 	;pointer to the most recent NFA of the NVDICT
	
#endif	
FNVDICT_VARS_END	EQU	*
FNVDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FNVDICT_INIT, 0
			LDD	#UDICT_PS_START 	;allocate data space 
			STD	CP_SAVE
			STD	CP
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FNVDICT_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FNVDICT_QUIT, 0
			MOVW	DP_SAVE, DP 		;restore cp
#emac

;#System integrity monitor
;=========================
#macro	FNVDICT_MON, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FNVDICT_CODE_START_LIN
			ORG 	FNVDICT_CODE_START, FNVDICT_CODE_START_LIN
#else
			ORG 	FNVDICT_CODE_START
FNVDICT_CODE_START_LIN	EQU	@
#endif

;#########
;# Words #
;#########

;Word: LU-NVDICT ( c-addr u -- xt | c-addr u false )
;Look up a name in the NVDICT dictionary. The name is referenced by the start
;address c-addr and the character count u. If successful the resulting execution
;token xt is returned. Otherwise the name reference remains on the parameter
;stack along with a false flag.
IF_LU_NVDICT		REGULAR
CF_LU_NVDICT		EQU	*
			MOVW	#$0000, 2,-Y
			RTS

;Word: WORDS-NVDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
;When the NVDICT dictionary is used as a buffer for compilation to non-volatile
;memory, no word list is printed 
IF_WORDS_NVDICT		REGULAR
CF_WORDS_NVDICT		EQU	*
			RTS
	
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
#endif
