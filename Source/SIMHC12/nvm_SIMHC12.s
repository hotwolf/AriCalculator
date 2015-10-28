#ifndef NVM_COMPILED
#define	NVM_COMPILED
;###############################################################################
;# S12CBase - NVM - NVM Driver (SIMHC12)                                       #
;###############################################################################
;#    Copyright 2010-2013 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
;#    families.                                                                #
;#                                                                             #
;#    S12CBase is free software: you can redistribute it and/or modify         #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CBase is distributed in the hope that it will be useful,              #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #
;###############################################################################
;# Description:                                                                #
;#    This module contains NVM write and erase functions.                      #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    May 27, 2013                                                             #
;#      - Initial release                                                      #
;#    October 27, 2015                                                         #
;#      - New user interface                                                   #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Program/erase sizes
;-------------------- 
NVM_PHRASE_SIZE		EQU	8

;#NVM space
;---------- 
NVM_SPACE_START		EQU	$8000
NVM_SPACE_END		EQU	$C000
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef NVM_VARS_START_LIN
			ORG 	NVM_VARS_START, NVM_VARS_START_LIN
#else
			ORG 	NVM_VARS_START
NVM_VARS_START_LIN	EQU	@			
#endif	

NVM_VARS_END		EQU	*
NVM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	NVM_INIT, 0
			NVM_ERASE 				;erase nvm space
#emac	

;#User interface
;---------------      
;#Erase NVM data
; args:   none
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         All registers are preserved
#macro	NVM_ERASE, 0
			SSTACK_JOBSR	NVM_ERASE, 6
#emac	

;#Copy data to NVM
; args:   X: source address in RAM
;	  Y: destination address 
;	  D: number of bytes to copy
; result: C-flag: set if successful
; SSTACK: 8 bytes
;         All registers are preserved
#macro	 NVM_PROGRAM, 0
			SSTACK_JOBSR	NVM_PROGRAM, 8
#emac	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef NVM_CODE_START_LIN
			ORG 	NVM_CODE_START, NVM_CODE_START_LIN
#else
			ORG 	NVM_CODE_START
NVM_CODE_START_LIN	EQU	@			
#endif	

;#User interface
;---------------      
;#Erase NVM data
; args:   none
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         All registers are preserved
NVM_ERASE       	EQU	*
			;Save registers
			PSHX 					;save X
			PSHD 					;save D
			;Erase memory
			LDD	#$FFFF 				;erase pattern
			LDX	#NVM_SPACE_START			;initialize index
NVM_ERASE_1		STD	2,X+				;erase eight bytes
			STD	2,X+				;
			STD	2,X+				;
			STD	2,X+				;
			CPX	#NVM_SPACE_END			;
			BLO	NVM_ERASE_1			;more to erase
			;Done
			SSTACK_PREPULL	6 			;check stack
			PULD					;restore D
			PULX					;restore X
			SEC					
			RTS

;#Copy data to NVM
; args:   X: source address in RAM
;	  Y: destination address 
;	  D: number of bytes to copy
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         All registers are preserved
NVM_PROGRAM       	EQU	*
			;Save registers (source in X, desination in Y, byte count in D)
			PSHX 					;save X
			PSHY 					;save Y
			PSHD 					;save D
			;Copy data (source in X, desination in Y, byte count in D)
NVM_PROGRAM_1		MOVW	2,X+, 2,Y+ 			;copy 8 bytes
			MOVW	2,X+, 2,Y+			;
			MOVW	2,X+, 2,Y+			;
			MOVW	2,X+, 2,Y+			;
			SUBD	#8				;adjust byte count
			BPL	NVM_PROGRAM_1			;more bytes to copy
			;Done
			SSTACK_PREPULL	6 			;check stack
			PULD					;restore D
			PULY					;restore Y
			PULX					;restore X
			SEC					
			RTS
	
NVM_CODE_END		EQU	*	
NVM_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef NVM_TABS_START_LIN
			ORG 	NVM_TABS_START, NVM_TABS_START_LIN
#else
			ORG 	NVM_TABS_START
NVM_TABS_START_LIN	EQU	@			
#endif	

NVM_TABS_END		EQU	*	
NVM_TABS_END_LIN	EQU	@	
#endif	

