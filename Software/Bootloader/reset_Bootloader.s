#ifndef RESET_COMPILED
#define	RESET_COMPILED	
;###############################################################################
;# AriCalculator - Bootloader - Reset Handler                                  #
;###############################################################################
;#    Copyright 2010-2018 Dirk Heisswolf                                       #
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
;#    This part of the AriCalculator's bootloader is active after reset. It    #
;#    invokes the bootloader codei if the keys ENTER and DEL are pushed,       #
;#    coming out of power-on reset. Otherwise the regular firmware will be     #
;#    started.                                                                 #
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
#ifdef RESET_VARS_START_LIN
			ORG 	RESET_VARS_START, RESET_VARS_START_LIN
#else
			ORG 	RESET_VARS_START
RESET_VARS_START_LIN	EQU	@			
#endif	

RESET_VARS_END		EQU	*
RESET_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	RESET_INIT, 0	
#ifdef	FLASH_COMPILE
			;Check for POR
			BRSET	CPMUFLG, #PORF, CHECK_KEYPAD		;check for POR
	
			;Start firmware
START_FIRMWARE		CLR	ATDDIENL 				;restore reset state
			CLR	PER1AD 					;restore reset state
			CLR	DDRP 					;restore reset state
			CLR	PTP				    	;restore reset state
			MOVB	#(($FF00-BOOTLOADER_SIZE)>>8), IVBR 	;set vector base
			JMP	[$FFFE-BOOTLOADER_SIZE]			;jump to firmware
#else	
START_FIRMWARE		EQU	START_OF_CODE 				;loop until key combination is pushed
#endif	
			;Setup keypad 
CHECK_KEYPAD		MOVB	#$FF, ATDDIENL 				;enable PAD's input buffers
			MOVB	#$FF, PER1AD				;enable PAD's pull-ups
			MOVB	#$3F,   DDRP 				;drive keyboard columns low
			
			;Check key pad
			;          P  P  P  P  P  P
			;          P  P  P  P  P  P
			;          0  1  2  3  4  5
			;          |  |  |  |  |  |
			; PAD6 ---29-28-27-26-25-24 |G
			;          |  |  |  |  |  | |
			; PAD5 ---23-22-21-20-1F-1E |F
			;          |  |  |  |  |  | |
			; PAD4 ---1D-1C-1B-1A-19-18 |E
			;             |  |  |  |  | |
			; PAD3 ------16-15-14-13-12 |D
			;             |  |  |  |  | |
			; PAD2 ------10--F--E--D--C |C
			;             |  |  |  |  | |
			; PAD1 -------A--9--8--7--6 |B
			;             |  |  |  |  | |
			; PAD0 -------4--3--2--1--0 |A
			;          ________________
			;          5  4  3  2  1  0
			MOVB	#$FD, PTP 				;check row 4
			NOP		       				;wait
			LDAA	PT1AD 					;row pattern -> A 
			MOVB	#$EF, PTP 				;check row 1
			CMPA	#$FB 					;check for ENTER key
			BNE	START_FIRMWARE				;start regular firmware

			LDAA	PT1AD 					;row pattern -> A 
			MOVB	#$DF, PTP 				;check row 0
			CMPA	#$FE 					;check for DEL key
			BNE	START_FIRMWARE	 			;start regular firmware

			LDAA	PT1AD 					;row pattern -> A 
			MOVB	#$F7, PTP 				;check row 2
			COMA						;check for no key
			BNE	START_FIRMWARE	 			;start regular firmware

			LDAA	PT1AD 					;row pattern -> A 
			MOVB	#$FB, PTP 				;check row 3
			COMA						;check for no key
			BNE	START_FIRMWARE	 			;start regular firmware

			LDAA	PT1AD 					;row pattern -> A 
			MOVB	#$FE, PTP 				;check row 5
			COMA						;check for no key
			BNE	START_FIRMWARE	 			;start regular firmware

			LDAA	PT1AD 					;row pattern -> A 
			MOVB	#$FF, PTP				;unselect keypad columns	
			COMA						;check for no key
			BNE	START_FIRMWARE	 			;start regular firmware
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef RESET_CODE_START_LIN
			ORG 	RESET_CODE_START, RESET_CODE_START_LIN
#else
			ORG 	RESET_CODE_START
RESET_CODE_START_LIN	EQU	@	
#endif
	
;# Entry point for COP reset
;#========================== 
RESET_COP_ENTRY		EQU	*
			//Run firmware's COP reset handler
			MOVB	#(($FF00-BOOTLOADER_SIZE)>>8), IVBR 
			JMP	[$FFFA-BOOTLOADER_SIZE]
	
;# Entry point for CM reset
;#========================= 
RESET_CM_ENTRY		EQU	*
			//Run firmware's COP reset handler
			MOVB	#(($FF00-BOOTLOADER_SIZE)>>8), IVBR 
			JMP	[$FFFC-BOOTLOADER_SIZE]

;# Entry point for common resets
;#============================== 
RESET_EXT_ENTRY		EQU	START_OF_CODE

RESET_CODE_END		EQU	*	
RESET_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef RESET_TABS_START_LIN
			ORG 	RESET_TABS_START, RESET_TABS_START_LIN
#else
			ORG 	RESET_TABS_START
RESET_TABS_START_LIN	EQU	@	
#endif	

	
RESET_TABS_END		EQU	*
RESET_TABS_END_LIN	EQU	@
#endif
