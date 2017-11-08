#ifndef	VECTAB
#define	VECTAB
;###############################################################################
;# AriCalculator - Bootloader - Vector Table                                   #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12 MCU family.    #
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
;#    This module defines the static vector table of the AriCalculator         #
;#    bootloader.                                                              #
;###############################################################################
;# Required Modules:                                                           #
;#    SCI     - UART driver                                                    #
;#    DISP    - ST7565R display driver                                         #
;###############################################################################
;# Version History:                                                            #
;#    July 8, 2017                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Point all unused ISRs to separate BGND instructions
#ifndef	VECTAB_DEBUG_ON
#ifndef	VECTAB_DEBUG_OFF
VECTAB_DEBUG_OFF	EQU	1 		;default is off
#endif
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Size of the vector table
VECTAB_SIZE		EQU	$80
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef VECTAB_VARS_START_LIN
			ORG 	VECTAB_VARS_START, VECTAB_VARS_START_LIN
#else
			ORG 	VECTAB_VARS_START
VECTAB_VARS_START_LIN	EQU	@			
#endif	

VECTAB_VARS_END		EQU	*
VECTAB_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	VECTAB_INIT, 0
			;Set vector base address
			MOVB	#(VECTAB_START>>8), IVBR
#emac	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef VECTAB_CODE_START_LIN
			ORG 	VECTAB_CODE_START, VECTAB_CODE_START_LIN
#else
			ORG 	VECTAB_CODE_START
VECTAB_CODE_START_LIN	EQU	@			
#endif

VECTAB_CODE_END		EQU	*	
VECTAB_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef VECTAB_TABS_START_LIN
			ORG 	VECTAB_TABS_START, VECTAB_TABS_START_LIN
#else
			ORG 	VECTAB_TABS_START
VECTAB_TABS_START_LIN	EQU	@			
#endif	

;#Interrupt service routines
;#--------------------------
#ifdef VECTAB_DEBUG_ON
ISR_SPURIOUS		BGND				;vector base + $80
ISR_PAD			BGND				;vector base + $82
ISR_ADCCOMP		BGND				;vector base + $84
ISR_RES86		BGND				;vector base + $86
ISR_API			BGND				;vector base + $88
ISR_LVI			BGND				;vector base + $8A
ISR_RES8C		BGND				;vector base + $8C
ISR_PORTP		BGND	           		;vector base + $8E
ISR_RES90		BGND				;vector base + $90
ISR_RES92		BGND				;vector base + $92
ISR_RES94		BGND				;vector base + $94
ISR_RES96		BGND				;vector base + $96
ISR_RES98		BGND				;vector base + $98
ISR_RES9A		BGND				;vector base + $9A
ISR_RES9C		BGND				;vector base + $9C
ISR_RES9E		BGND				;vector base + $9E
ISR_RESA0		BGND				;vector base + $A0
ISR_RESA2		BGND				;vector base + $A2
ISR_RESA4		BGND				;vector base + $A4
ISR_RESA6		BGND				;vector base + $A6
ISR_RESA8		BGND				;vector base + $A8
ISR_RESAA		BGND				;vector base + $AA
ISR_RESAC		BGND				;vector base + $AC
ISR_RESAE		BGND				;vector base + $AE
ISR_CANTX		BGND				;vector base + $B0
ISR_CANRX		BGND				;vector base + $B2
ISR_CANERR		BGND				;vector base + $B4
ISR_CANWUP		BGND				;vector base + $B6
#ifdef NVM_ISR_CC					;vector base + $B8
ISR_FLASH  		EQU	NVM_ISR_CC
#else
ISR_FLASH		BGND
#endif
ISR_FLASHFLT  		BGND				;vector base + $BA
ISR_SPI2		BGND				;vector base + $BC
ISR_SPI1		BGND				;vector base + $BE
ISR_RESC0		BGND				;vector base + $C0
ISR_SCI2		BGND				;vector base + $C2
ISR_RESC4		BGND				;vector base + $C4
ISR_PLLLOCK		BGND				;vector base + $C6
ISR_OSCSTAT		BGND				;vector base + $C8
ISR_RESCA		BGND				;vector base + $CA
ISR_ACMP		BGND				;vector base + $CC
ISR_PORTJ		BGND				;vector base + $CC
ISR_RESD0		BGND				;vector base + $D0
ISR_ATD0		BGND				;vector base + $D2
ISR_SCI1		BGND				;vector base + $D4
#ifdef SCI_ISR_RXTX					;vector base + $D6
ISR_SCI0		EQU	SCI_ISR_RXTX
#else
ISR_SCI0		BGND
#endif
#ifdef DISP_ISR						;vector base + $D8
ISR_SPI0		EQU	DISP_ISR
#else
ISR_SPI0		BGND
#endif
ISR_TIM_PAIE		BGND				;vector base + $DA
ISR_TIM_PAOV		BGND				;vector base + $DC
ISR_TIM_TOV		BGND				;vector base + $DE
ISR_TIM_TC7		BGND				;vector base + $E0
ISR_TIM_TC6		BGND				;vector base + $E2
ISR_TIM_TC5		BGND				;vector base + $E4
ISR_TIM_TC4		BGND				;vector base + $E6
ISR_TIM_TC3		BGND				;vector base + $E8
ISR_TIM_TC2		BGND				;vector base + $EA
#ifdef SCI_ISR_OC					;vector base + $EC
ISR_TIM_TC1		EQU	SCI_ISR_OC
#else
ISR_TIM_TC1		BGND
#endif
#ifdef SCI_ISR_OC					;vector base + $EE
ISR_TIM_TC0		EQU	SCI_ISR_OC
#else
ISR_TIM_TC0		BGND
#endif
ISR_RTI			BGND				;vector base + $F0
ISR_IRQ			BGND				;vector base + $F2
ISR_XIRQ		BGND				;vector base + $F4
ISR_SWI			BGND				;vector base + $F6
ISR_TRAP		BGND				;vector base + $F8
#else								
ISR_SPURIOUS		EQU	BOOTLOADER_ISR_ERROR	;vector base + $80
ISR_PAD			EQU	BOOTLOADER_ISR_ERROR	;vector base + $82	
ISR_ADCCOMP		EQU	BOOTLOADER_ISR_ERROR	;vector base + $84	
ISR_RES86		EQU	BOOTLOADER_ISR_ERROR	;vector base + $86
ISR_API			EQU	BOOTLOADER_ISR_ERROR	;vector base + $88
ISR_LVI			EQU	BOOTLOADER_ISR_ERROR	;vector base + $8A
ISR_RES8C		EQU	BOOTLOADER_ISR_ERROR	;vector base + $8C
ISR_PORTP		EQU	BOOTLOADER_ISR_ERROR    ;vector base + $8E
ISR_RES90		EQU	BOOTLOADER_ISR_ERROR	;vector base + $90
ISR_RES92		EQU	BOOTLOADER_ISR_ERROR	;vector base + $92
ISR_RES94		EQU	BOOTLOADER_ISR_ERROR	;vector base + $94
ISR_RES96		EQU	BOOTLOADER_ISR_ERROR	;vector base + $96
ISR_RES98		EQU	BOOTLOADER_ISR_ERROR	;vector base + $98
ISR_RES9A		EQU	BOOTLOADER_ISR_ERROR	;vector base + $9A
ISR_RES9C		EQU	BOOTLOADER_ISR_ERROR	;vector base + $9C
ISR_RES9E		EQU	BOOTLOADER_ISR_ERROR	;vector base + $9E
ISR_RESA0		EQU	BOOTLOADER_ISR_ERROR	;vector base + $A0
ISR_RESA2		EQU	BOOTLOADER_ISR_ERROR	;vector base + $A2
ISR_RESA4		EQU	BOOTLOADER_ISR_ERROR	;vector base + $A4
ISR_RESA6		EQU	BOOTLOADER_ISR_ERROR	;vector base + $A6
ISR_RESA8		EQU	BOOTLOADER_ISR_ERROR	;vector base + $A8
ISR_RESAA		EQU	BOOTLOADER_ISR_ERROR	;vector base + $AA
ISR_RESAC		EQU	BOOTLOADER_ISR_ERROR	;vector base + $AC
ISR_RESAE		EQU	BOOTLOADER_ISR_ERROR	;vector base + $AE
ISR_CANTX		EQU	BOOTLOADER_ISR_ERROR	;vector base + $B0
ISR_CANRX		EQU	BOOTLOADER_ISR_ERROR	;vector base + $B2
ISR_CANERR		EQU	BOOTLOADER_ISR_ERROR	;vector base + $B4
ISR_CANWUP		EQU	BOOTLOADER_ISR_ERROR	;vector base + $B6
#ifdef NVM_ISR_CC					;vector base + $B8
ISR_FLASH  		EQU	NVM_ISR_CC
#else
ISR_FLASH  		EQU	BOOTLOADER_ISR_ERROR
#endif
ISR_FLASHFLT  		EQU	BOOTLOADER_ISR_ERROR	;vector base + $BA
ISR_SPI2		EQU	BOOTLOADER_ISR_ERROR	;vector base + $BC
ISR_SPI1		EQU	BOOTLOADER_ISR_ERROR	;vector base + $BE
ISR_RESC0		EQU	BOOTLOADER_ISR_ERROR	;vector base + $C0
ISR_SCI2		EQU	BOOTLOADER_ISR_ERROR	;vector base + $C2
ISR_RESC4		EQU	BOOTLOADER_ISR_ERROR	;vector base + $C4
ISR_PLLLOCK		EQU	BOOTLOADER_ISR_ERROR	;vector base + $C6
ISR_OSCSTAT		EQU	BOOTLOADER_ISR_ERROR	;vector base + $C8
ISR_RESCA		EQU	BOOTLOADER_ISR_ERROR	;vector base + $CA
ISR_ACMP		EQU	BOOTLOADER_ISR_ERROR	;vector base + $CC
ISR_PORTJ		EQU	BOOTLOADER_ISR_ERROR	;vector base + $CC
ISR_RESD0		EQU	BOOTLOADER_ISR_ERROR	;vector base + $D0
ISR_ATD0		EQU	BOOTLOADER_ISR_ERROR	;vector base + $D2
ISR_SCI1		EQU	BOOTLOADER_ISR_ERROR	;vector base + $D4
#ifdef SCI_ISR_RXTX					;vector base + $D6
ISR_SCI0		EQU	SCI_ISR_RXTX
#else
ISR_SCI0		EQU	BOOTLOADER_ISR_ERROR
#endif
#ifdef DISP_ISR						;vector base + $D8
ISR_SPI0		EQU	DISP_ISR		;vector base + $D8
#else
ISR_SPI0		EQU	BOOTLOADER_ISR_ERROR
#endif
ISR_TIM_PAIE		EQU	BOOTLOADER_ISR_ERROR		;vector base + $DA
ISR_TIM_PAOV		EQU	BOOTLOADER_ISR_ERROR		;vector base + $DC
ISR_TIM_TOV		EQU	BOOTLOADER_ISR_ERROR		;vector base + $DE
ISR_TIM_TC7		EQU	BOOTLOADER_ISR_ERROR		;vector base + $E0
ISR_TIM_TC6		EQU	BOOTLOADER_ISR_ERROR		;vector base + $E2
ISR_TIM_TC5		EQU	BOOTLOADER_ISR_ERROR		;vector base + $E4
ISR_TIM_TC4		EQU	BOOTLOADER_ISR_ERROR		;vector base + $E6
ISR_TIM_TC3		EQU	BOOTLOADER_ISR_ERROR		;vector base + $E8
ISR_TIM_TC2		EQU	BOOTLOADER_ISR_ERROR		;vector base + $EA
ISR_TIM_TC1		EQU	BOOTLOADER_ISR_ERROR		;vector base + $EC
#ifdef SCI_ISR_OC					;vector base + $EE
ISR_TIM_TC0		EQU	SCI_ISR_OC
#else
ISR_TIM_TC0		EQU	BOOTLOADER_ISR_ERROR
#endif
ISR_RTI			EQU	BOOTLOADER_ISR_ERROR	;vector base + $F0
ISR_IRQ			EQU	BOOTLOADER_ISR_ERROR	;vector base + $F2
ISR_XIRQ		EQU	BOOTLOADER_ISR_ERROR	;vector base + $F4
ISR_SWI			EQU	BOOTLOADER_ISR_ERROR	;vector base + $F6
ISR_TRAP		EQU	BOOTLOADER_ISR_ERROR	;vector base + $F8
#endif
	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	
	
;###############################################################################
;# S12G Vector Table                                                           #
;###############################################################################
#ifdef VECTAB_START_LIN
			ORG 	VECTAB_START, VECTAB_START_LIN
#else
			ORG 	VECTAB_START
VECTAB_START_LIN	EQU	@				
#endif	

VEC_SPURIOUS		DW	ISR_SPURIOUS		;vector base + $80
VEC_PAD			DW	ISR_PAD			;vector base + $82
VEC_ADCCOMP		DW	ISR_ADCCOMP		;vector base + $84
VEC_RES86		DW	ISR_RES86		;vector base + $86
VEC_API	       		DW	ISR_API	       		;vector base + $88
VEC_LVI	       		DW	ISR_LVI	       		;vector base + $8A
VEC_RES8C		DW	ISR_RES8C		;vector base + $8C
VEC_PORTP		DW	ISR_PORTP		;vector base + $8E
VEC_RES90		DW	ISR_RES90		;vector base + $90
VEC_RES92		DW	ISR_RES92		;vector base + $92
VEC_RES94		DW	ISR_RES94		;vector base + $94
VEC_RES96		DW	ISR_RES96		;vector base + $96
VEC_RES98		DW	ISR_RES98		;vector base + $98
VEC_RES9A		DW	ISR_RES9A		;vector base + $9A
VEC_RES9C		DW	ISR_RES9C		;vector base + $9C
VEC_RES9E		DW	ISR_RES9E		;vector base + $9E
VEC_RESA0		DW	ISR_RESA0		;vector base + $A0
VEC_RESA2		DW	ISR_RESA2		;vector base + $A2
VEC_RESA4		DW	ISR_RESA4		;vector base + $A4
VEC_RESA6		DW	ISR_RESA6		;vector base + $A6
VEC_RESA8		DW	ISR_RESA8		;vector base + $A8
VEC_RESAA		DW	ISR_RESAA		;vector base + $AA
VEC_RESAC		DW	ISR_RESAC		;vector base + $AC
VEC_RESAE		DW	ISR_RESAE		;vector base + $AE
VEC_CANTX		DW	ISR_CANTX		;vector base + $A0
VEC_CANRX		DW	ISR_CANRX		;vector base + $B2
VEC_CANERR		DW	ISR_CANERR		;vector base + $B4
VEC_CANWUP		DW	ISR_CANWUP		;vector base + $B6
VEC_FLASH		DW	ISR_FLASH		;vector base + $B8
VEC_FLASHFLT		DW	ISR_FLASHFLT		;vector base + $BA
VEC_SPI2		DW	ISR_SPI2		;vector base + $BC
VEC_SPI1		DW	ISR_SPI1		;vector base + $BE
VEC_RESC0		DW	ISR_RESC0		;vector base + $C0
VEC_SCI2		DW	ISR_SCI2		;vector base + $C2
VEC_RESC4		DW	ISR_RESC4		;vector base + $C4
VEC_PLLLOCK		DW	ISR_PLLLOCK		;vector base + $C6
VEC_OSCSTAT		DW	ISR_OSCSTAT		;vector base + $C8
VEC_RESCA		DW	ISR_RESCA		;vector base + $CA
VEC_ACMP		DW	ISR_ACMP		;vector base + $CC
VEC_PORTJ		DW	ISR_PORTJ		;vector base + $CC
VEC_RESD0		DW	ISR_RESD0		;vector base + $D0
VEC_ATD0		DW	ISR_ATD0		;vector base + $D2
VEC_SCI1		DW	ISR_SCI1		;vector base + $D4
VEC_SCI0		DW	ISR_SCI0		;vector base + $D6
VEC_SPI0		DW	ISR_SPI0		;vector base + $D8
VEC_TIM_PAIE		DW	ISR_TIM_PAIE		;vector base + $DA
VEC_TIM_PAOV		DW	ISR_TIM_PAOV		;vector base + $DC
VEC_TIM_TOV		DW	ISR_TIM_TOV		;vector base + $DE
VEC_TIM_TC7		DW	ISR_TIM_TC7		;vector base + $E0
VEC_TIM_TC6		DW	ISR_TIM_TC6		;vector base + $E2
VEC_TIM_TC5		DW	ISR_TIM_TC5		;vector base + $E4
VEC_TIM_TC4		DW	ISR_TIM_TC4		;vector base + $E6
VEC_TIM_TC3		DW	ISR_TIM_TC3		;vector base + $E8
VEC_TIM_TC2		DW	ISR_TIM_TC2		;vector base + $EA
VEC_TIM_TC1		DW	ISR_TIM_TC1		;vector base + $EC
VEC_TIM_TC0		DW	ISR_TIM_TC0		;vector base + $EE
VEC_RTI			DW	ISR_RTI			;vector base + $F0
VEC_IRQ			DW	ISR_IRQ			;vector base + $F2
VEC_XIRQ		DW	ISR_XIRQ		;vector base + $F4
VEC_SWI			DW	ISR_SWI			;vector base + $F6
VEC_TRAP		DW	ISR_TRAP		;vector base + $F8
VEC_RESET_COP		DW	RESET_COP_ENTRY		;vector base + $FA
VEC_RESET_CM		DW	RESET_CM_ENTRY		;vector base + $FC
VEC_RESET_EXT		DW	RESET_EXT_ENTRY		;vector base + $FE

VECTAB_END		EQU	*	
VECTAB_END_LIN		EQU	@	

#endif
