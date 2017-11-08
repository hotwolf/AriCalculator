#ifndef LRE_COMPILED
#define	LRE_COMPILED	
;###############################################################################
;# AriCalculator - Bootloader - LRE Handler                                    #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU family.   #
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
;#    This part of the AriCalculator's bootloader copies the program code into #
;#    the system RAM.                                                          #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    July 10, 2017                                                            #
;#      - Initial release                                                      #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef LRE_VARS_START_LIN
			ORG 	LRE_VARS_START, LRE_VARS_START_LIN
#else
			ORG 	LRE_VARS_START
LRE_VARS_START_LIN	EQU	@			
#endif	

LRE_VARS_END		EQU	*
LRE_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	LRE_INIT, 0
			;Copy tables and code
			LRE_COPY	RAM_TABS_START_LIN, RAM_TABS_START, (RAM_CODE_END-RAM_TABS_START)
			;Copy vector table
			LRE_COPY	VECTAB_START_LIN, VECTAB_START, VECTAB_SIZE
			;Set vector base address
			MOVB	#(VECTAB_START>>8), IVBR
#emac

;Copy loop
; args:   1: source address
;         2: destination address
;         3: min. number of bytes to copy
; result: none
; SSTACK: none
;         no registers are preserved
#macro	LRE_COPY, 3
			;Setup
			LDX	#(\1&$FFFF)	;source address
			LDY	#(\2&$FFFF)	;destination address
			LDD	#((\3>>3)+(((\3>>2)&1)|((\3>>1)&1)|(\3&1)))
			;Loop 
LOOP			MOVW	2,X+, 2,Y+	
			MOVW	2,X+, 2,Y+	
			MOVW	2,X+, 2,Y+	
			MOVW	2,X+, 2,Y+	
			DBNE	D, LOOP
#emac

	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef LRE_CODE_START_LIN
			ORG 	LRE_CODE_START, LRE_CODE_START_LIN
#else
			ORG 	LRE_CODE_START
LRE_CODE_START_LIN	EQU	@	
#endif
	
	
LRE_CODE_END		EQU	*	
LRE_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef LRE_TABS_START_LIN
			ORG 	LRE_TABS_START, LRE_TABS_START_LIN
#else
			ORG 	LRE_TABS_START
LRE_TABS_START_LIN	EQU	@	
#endif	

	
LRE_TABS_END		EQU	*
LRE_TABS_END_LIN	EQU	@
#endif
