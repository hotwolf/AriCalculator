;###############################################################################
;# S12CBase - NVM - NVM Driver (Mini-BDM-Pod)                                  #
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
;#Clock divider
#ifndef NVM_FDIV_VAL
NVM_FDIV_VAL		EQU	(CLOCK_OSC_FREQ/1000000)-1
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
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
			MOVB	#NVM_FDIV_VAL, FDIV
#emac	

;#Push RAM code
; args:   none
; result: none
; SSTACK: 8 bytes
;         X, Y, and D are preserved
; RAM code: 
;	6A 40          STAA    0,Y
;	0F 40 80 FC    BRCLR   0,Y, #CCIF, *
;	05 00          JMP     0,X
#macro	NVM_PUSH_RAM_CODE, 0
			MOVW	#$0500, 2,-PS ;JMP     0,X
			MOVW	#$00FC, 2,-PS ;BRCLR   0,Y, #CCIF, *
			MOVW	#$0F40, 2,-PS ;
			MOVW	#$0A40, 2,-PS ;STAA	0,X
#emac

;#Pull RAM code
; args:   none
; result: none
; SSTACK: -8 bytes
;         X, Y, and D are preserved
#macro	NVM_PULL_RAM_CODE, 0
			LEAS	8,SP
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

;#Erase current PPAGE
; args:   PPAGE:   4K flash page to be erased
; result:  C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and D are preserved 
NVM_ERASE_PAGE		EQU	*
			;Save registers


	

			;Make sure that phrase 








	


;#Erase current PPAGE
; args:   PPAGE:   4K flash page to be erased
; result:  C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and D are preserved 
NVM_FLUSH		EQU	*
			;Save registers




	;



	


	
;#Execute command and wait
; args:   none
; result: none
; SSTACK: 5 bytes
;         X, Y, and D are preserved 
NVM_EXEC		EQU	*
			
			MOVW	#$xx, 2,-SP


			STAA	0,Y
			BRCLR	0,Y, #CCIF, *
			JMP	0,X
	


	
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

NVM_STR_MPU		FCS	"MPU error"

NVM_TABS_END		EQU	*	
NVM_TABS_END_LIN	EQU	@	

