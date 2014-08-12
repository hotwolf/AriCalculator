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
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Program/erase sizes
;-------------------- 
NVM_PHRASE_SIZE		EQU	64
NVM_SECTOR_SIZE		EQU	1024

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
#emac	
	
;#Program phrase
; args:   X:      target address within paging window
;	  PPAGE:  current page
;	  Y:      data pointer 
; result: C-flag: set if successful
; SSTACK: 2 bytes
;         X, Y, and D are preserved
#macro	NVM_PROGRAM_PHRASE, 0
			SSTACK_JOBSR	NVM_PROGRAM_PHRASE, 18
#emac

;#Erase sector
; args:   X:      sector address
;	  PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         X, Y, and D are preserved
#macro	NVM_ERASE_SECTOR, 0
			SSTACK_JOBSR	NVM_ERASE_SECTOR, 18
#emac

;#Erase page
; args:   PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 10 bytes
;         X, Y, and D are preserved
#macro	NVM_ERASE_PAGE, 0
			SSTACK_JOBSR	NVM_ERASE_PAGE, 22
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
	
;#Program phrase
; args:   X:      target address within paging window
;	  PPAGE:  current page (ignored)
;	  Y:      data pointer 
; result: C-flag: set if successful
; SSTACK: 2 bytes
;         X, Y, and D are preserved
NVM_PROGRAM_PHRASE	EQU	*
			MOVW	0,X, 0,Y	
			MOVW	2,X, 2,Y	
			MOVW	4,X, 4,Y	
			MOVW	6,X, 6,Y	
			;Done
			SSTACK_PREPULL	2
			SEC
			RTS
						
;#Erase sector
; args:   X:      sector address
;	  PPAGE:  current page (ignored)
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         X, Y, and D are preserved
NVM_ERASE_SECTOR	EQU	*
			;Save registers (paged address in X)
			PSHD 					;push D onto the SSTACK
			PSHX 					;push X onto the SSTACK
			;Erase memory (paged address in X)
			LDD	#(NVM_SECTOR_SIZE/2)
NVM_ERASE_SECTOR_1	MOVW	#$FFFF, 2,X+
			DBNE	D, NVM_ERASE_SECTOR_1 
			;Done
			SSTACK_PREPULL	6
			SEC
			RTS
	
;#Erase page
; args:   PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 10 bytes
;         X, Y, and D are preserved
NVM_ERASE_PAGE		EQU	*
			;Save registers (paged address in X, data pointer in Y)
			PSHX 					;push X onto the SSTACK
			;Erase all 16 sdectors sector 
			LDX	#$8000		
NVM_ERASE_PAGE_1	NVM_ERASE_SECTOR
			BCC	NVM_ERASE_PAGE_2			;error occured
			LEAX	NVM_SECTOR_SIZE,X
			CPX	$C000
			BLO	NVM_ERASE_PAGE_1
			;Restore registers (page erased)
			SSTACK_PREPULL	4
			PULX					;pull X from the SSTACK
			;Done
			SEC
			RTS
			;Restore registers (error condition)
NVM_ERASE_PAGE_2	SSTACK_PREPULL	4
			PULX					;pull X from the SSTACK
			;Done
			CLC
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

