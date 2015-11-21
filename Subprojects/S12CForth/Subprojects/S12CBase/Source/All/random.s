#ifndef RANDOM_COMPILED
#define RANDOM_COMPILED
;###############################################################################
;# S12CBase - RANDOM - Pseudo-Random Number Generator                          #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
;#    family.                                                                  #
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
;#    The RANDOM module implements a 16-bit linear-feedback shift register to  #
;#    generate pseudo-random numbers.                                          #
;###############################################################################
;# Version History:                                                            #
;#    November 19, 2015                                                        #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#                                                                             #
;###############################################################################
;###############################################################################
;# 16-Bit Linear-Feedback shift register                                       #
;###############################################################################
;
;  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
;  |15 |14 |13 |12 |11 |10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |<-+
;  +-+-+---+-+-+-+-+---+-+-+---+---+---+---+---+---+---+---+---+---+  |
;    |       |   |       |                                            |
;    |       |   |       |10 +--*                                     |
;    |       |   |12     +---+   \                                    |
;    |       |13 +-----------+ EX |___________________________________|
;    |15     +---------------+ OR |
;    +-----------------------+   /
;                            +--*

;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef RANDOM_VARS_START_LIN
			ORG 	RANDOM_VARS_START, RANDOM_VARS_START_LIN
#else
			ORG 	RANDOM_VARS_START
#endif	

RANDOM_LSFR		DS	2

	
RANDOM_VARS_END		EQU	*
RANDOM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (initialization done by ISTACK module)
#macro	RANDOM_INIT, 0
#emac
			RANDOM_SEED 			;set a random seed
#emac
	
;#Set a random seed for the LSFR the LSFR	
; args:   none
; result: none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	RANDOM_SEED, 0
			LDD	LSFR_SEED 		;start RAM content
			ADD	TCNT			;add TIM counter
			EXG	A, B			;swap nibbles
			BNE	DONE			;done
			LDD	#$1234			;non-zero seed
DONE			EQU	*
#emac

;#Generate next pseudo random value
; args:   none
; result: D: new pseudo-random value
; SSTACK: 2 bytes
;         X and Y are preserved
#macro	RANDOM_NEXT, 0
			SSTACK_JOBSR	RANDOM_NEXT, 2
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef RANDOM_CODE_START_LIN
			ORG 	RANDOM_CODE_START, RANDOM_CODE_START_LIN
#else
			ORG 	RANDOM_CODE_START
#endif


;#Generate next pseudo random value
; args:   none
; result: D: new pseudo-random value
; SSTACK: 2 bytes
;         X and Y are preserved
RANDOM_NEXT		EQU	*
			;Accumulate tabs in LSFR high byte
			CLRA						;clear A
			LDAB	RANDOM_LSFR 				;LSFR high byte -> B
			;1st tab - bit 15 ($00 in A, LSFR high byte in B)
			LSLB						;shift high byte
			ADCA	#0 					;store 1st tab
			STAB	RANDOM_LSFR 				;store new high byte
			;2nd tab - bit 13 (XORed tabs in A, LSFR high byte in B)
			LSLB						;shift high byte
			LSLB						;shift high byte
			ADCA	#0 					;accumulate tabs
			;3rd tab - bit 12 (XORed tabs in A, LSFR high byte in B)
			LSLB						;shift high byte
			ADCA	#0 					;accumulate tabs
			;4th tab - bit 10 (XORed tabs in A, LSFR high byte in B)
			LSLB						;shift high byte
			LSLB						;shift high byte
			ADCA	#0 					;accumulate tabs
			;Calculate new LSFR value (XORed tabs in A)
			LSRA						;XORed tabs -> C-flag
			LDD	RANDOM_LSFR 				;LSFR -> D
			ROLB						;shift LSFR
			ROLA						; XORed tabs in LSB
			STD	RANDOM_LSFR 				;update LSFR
			;Done (new LSFR value in D)	
			SSTACK_PREPULL	2 				;check stack
			RTS
	
RANDOM_CODE_END		EQU	*
RANDOM_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef RANDOM_TABS_START_LIN
			ORG 	RANDOM_TABS_START, RANDOM_TABS_START_LIN
#else
			ORG 	RANDOM_TABS_START
#endif	

RANDOM_TABS_END		EQU	*
RANDOM_TABS_END_LIN	EQU	@
#endif
