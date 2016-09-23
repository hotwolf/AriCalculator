#ifndef	VECTAB
#define	VECTAB
;###############################################################################
;# S12CBase - VECTAB - Vector Table (MagniCube)                                #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12(X) MCU         #
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
;#    This module defines the static vector table of the OpenBDC firmware.     #
;#    Unexpected inerrupts are cought and trigger a fatal error in the reset   #
;#    handler.                                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    RESET   - Reset handler                                                  #
;#    SCI     - UART driver                                                    #
;###############################################################################
;# Version History:                                                            #
;#    August 12, 2014                                                          #
;#      - Initial release                                                      #
;#  	  (based on the S12CBase vector table for the S12G-Mini-EVB)           #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Point all unused ISRs to separate BGND instructions
;VECTAB_DEBUG		EQU	1 

;###############################################################################
;# Constants                                                                   #
;###############################################################################

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
#ifdef	MMAP_RAM
			;Set vector base address
			MOVB	#(VECTAB_START>>8), IVBR
#endif
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

#ifndef VECTAB_DEBUG
;Illegal interrupt catcher
VECTAB_ISR_ILLIRQ	RESET_FATAL	VECTAB_MSG_ILLIRQ
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
#ifdef VECTAB_DEBUG
ISR_SPURIOUS		BGND				;vector base + $80
ISR_PAD			BGND				;vector base + $82
ISR_ADCCOMP		BGND				;vector base + $84
ISR_HTI			BGND				;vector base + $86
ISR_API			BGND				;vector base + $88
ISR_LVI			BGND				;vector base + $8A
ISR_PPOC		BGND				;vector base + $8C
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
ISR_ISENSE		BGND				;vector base + $A2
ISR_RESA4		BGND				;vector base + $A4
ISR_LS2OC		BGND				;vector base + $A6
ISR_BATS		BGND				;vector base + $A8
ISR_LPOC		BGND				;vector base + $AA
ISR_LSOC		BGND				;vector base + $AC
ISR_HSOC		BGND				;vector base + $AE
ISR_RESB0		BGND				;vector base + $B0
ISR_RESB2		BGND				;vector base + $B2
ISR_RESB4		BGND				;vector base + $B4
ISR_RESB6		BGND				;vector base + $B6
ISR_FLASH		BGND				;vector base + $B8
ISR_FLASHFLT  		EQU	NVM_ISR_ECCERR		;vector base + $BA
ISR_RESBC		BGND				;vector base + $BC
ISR_RESBE		BGND				;vector base + $BE
ISR_RESC0		BGND				;vector base + $C0
ISR_RESC2		BGND				;vector base + $C2
ISR_RESC4		BGND				;vector base + $C4
ISR_PLLLOCK		BGND				;vector base + $C6
ISR_OSCSTAT		BGND				;vector base + $C8
ISR_RESCA		BGND				;vector base + $CA
ISR_RESCC		BGND				;vector base + $CC
ISR_PORTL		BGND				;vector base + $CC
ISR_RESD0		BGND				;vector base + $D0
ISR_ATD			BGND				;vector base + $D2
ISR_SCI1		BGND				;vector base + $D4
ISR_SCI0		EQU	SCI_ISR_RXTX		;vector base + $D6
ISR_SPI			BGND				;vector base + $D8
ISR_RESDA		BGND				;vector base + $DA
ISR_TIM1_TOV		BGND				;vector base + $DC
ISR_TIM0_TOV		BGND				;vector base + $DE
ISR_RESE0		BGND				;vector base + $E0
ISR_RESE2		BGND				;vector base + $E2
ISR_RESE4		BGND				;vector base + $E4
ISR_RESE6		BGND				;vector base + $E6
#ifdef S12VR64
ISR_TIM0_TC3		BGND				;vector base + $E8
ISR_TIM0_TC2		BGND				;vector base + $EA
ISR_TIM0_TC1		BGND				;vector base + $EC
ISR_TIM0_TC0		EQU	SCI_ISR_OC		;vector base + $EE
#else
ISR_TIM1_TC1		EQU	SCI_ISR_IC		;vector base + $E8
ISR_TIM1_TC0		EQU	SCI_ISR_OC		;vector base + $EA
ISR_TIM0_TC1		BGND				;vector base + $EC
ISR_TIM0_TC0		BGND				;vector base + $EE
#endif	
ISR_RTI			BGND				;vector base + $F0
ISR_IRQ			BGND				;vector base + $F2
ISR_XIRQ		BGND				;vector base + $F4
ISR_SWI			BGND				;vector base + $F6
ISR_TRAP		BGND				;vector base + $F8
#else								
ISR_SPURIOUS		EQU	VECTAB_ISR_ILLIRQ	;vector base + $80
ISR_PAD			EQU	VECTAB_ISR_ILLIRQ	;vector base + $82
ISR_ADCCOMP		EQU	VECTAB_ISR_ILLIRQ	;vector base + $84
ISR_HTI			EQU	VECTAB_ISR_ILLIRQ	;vector base + $86
ISR_API			EQU	VECTAB_ISR_ILLIRQ	;vector base + $88
ISR_LVI			EQU	VECTAB_ISR_ILLIRQ	;vector base + $8A
ISR_PPOC		EQU	VECTAB_ISR_ILLIRQ	;vector base + $8C
ISR_PORTP		EQU	VECTAB_ISR_ILLIRQ	;vector base + $8E
ISR_RES90		EQU	VECTAB_ISR_ILLIRQ	;vector base + $90
ISR_RES92		EQU	VECTAB_ISR_ILLIRQ	;vector base + $92
ISR_RES94		EQU	VECTAB_ISR_ILLIRQ	;vector base + $94
ISR_RES96		EQU	VECTAB_ISR_ILLIRQ	;vector base + $96
ISR_RES98		EQU	VECTAB_ISR_ILLIRQ	;vector base + $98
ISR_RES9A		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9A
ISR_RES9C		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9C
ISR_RES9E		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9E
ISR_RESA0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A0
ISR_ISENSE		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A2
ISR_RESA4		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A4
ISR_LS2OC		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A6
ISR_BATS		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A8
ISR_LPOC		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AA
ISR_LSOC		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AC
ISR_HSOC		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AE
ISR_RESB0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B0
ISR_RESB2		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B2
ISR_RESB4		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B4
ISR_RESB6		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B6
ISR_FLASH		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B8
ISR_FLASHFLT  		EQU	NVM_ISR_ECCERR		;vector base + $BA
ISR_RESBC		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BC
ISR_RESBE		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BE
ISR_RESC0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C0
ISR_RESC2		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C2
ISR_RESC4		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C4
ISR_PLLLOCK		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C6
ISR_OSCSTAT		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C8
ISR_RESCA		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CA
ISR_RESCC		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CC
ISR_PORTL		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CC
ISR_RESD0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D0
ISR_ATD			EQU	VECTAB_ISR_ILLIRQ	;vector base + $D2
ISR_SCI1		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D4
ISR_SCI0		EQU	SCI_ISR_RXTX		;vector base + $D6
ISR_SPI			EQU	VECTAB_ISR_ILLIRQ	;vector base + $D8
ISR_RESDA		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DA
ISR_TIM1_TOV		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DC
ISR_TIM0_TOV		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DE
ISR_RESE0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E0
ISR_RESE2		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E2
ISR_RESE4		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E4
ISR_RESE6		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E6
#ifdef S12VR64
ISR_TIM0_TC3		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E8
ISR_TIM0_TC2		EQU	VECTAB_ISR_ILLIRQ	;vector base + $EA
ISR_TIM0_TC1		EQU	VECTAB_ISR_ILLIRQ	;vector base + $EC
ISR_TIM0_TC0		EQU	SCI_ISR_OC		;vector base + $EE
#else
ISR_TIM1_TC1		EQU	SCI_ISR_IC		;vector base + $E8
ISR_TIM1_TC0		EQU	SCI_ISR_OC		;vector base + $EA
ISR_TIM0_TC1		EQU	VECTAB_ISR_ILLIRQ	;vector base + $EC
ISR_TIM0_TC0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $EE
#endif	
ISR_RTI			EQU	VECTAB_ISR_ILLIRQ	;vector base + $F0
ISR_IRQ			EQU	VECTAB_ISR_ILLIRQ	;vector base + $F2
ISR_XIRQ		EQU	VECTAB_ISR_ILLIRQ	;vector base + $F4
ISR_SWI			EQU	VECTAB_ISR_ILLIRQ	;vector base + $F6
#endif

;#Error message
VECTAB_MSG_ILLIRQ	FCS	"Unexpected interrupt"
VECTAB_MSG_ILLIRQ_CHECK	DW	$00		
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
#endif	
VEC_SPURIOUS		DW	ISR_SPURIOUS		;vector base + $80
VEC_PAD			DW	ISR_PAD			;vector base + $82
VEC_ADCCOMP		DW	ISR_ADCCOMP		;vector base + $84
VEC_HTI			DW	ISR_HTI			;vector base + $86
VEC_API			DW	ISR_API			;vector base + $88
VEC_LVI			DW	ISR_LVI			;vector base + $8A
VEC_PPOC		DW	ISR_PPOC		;vector base + $8C
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
VEC_ISENSE		DW	ISR_ISENSE		;vector base + $A2
VEC_RESA4		DW	ISR_RESA4		;vector base + $A4
VEC_LS2OC		DW	ISR_LS2OC		;vector base + $A6
VEC_BATS		DW	ISR_BATS		;vector base + $A8
VEC_LPOC		DW	ISR_LPOC		;vector base + $AA
VEC_LSOC		DW	ISR_LSOC		;vector base + $AC
VEC_HSOC		DW	ISR_HSOC		;vector base + $AE
VEC_RESB0		DW	ISR_RESB0		;vector base + $B0
VEC_RESB2		DW	ISR_RESB2		;vector base + $B2
VEC_RESB4		DW	ISR_RESB4		;vector base + $B4
VEC_RESB6		DW	ISR_RESB6		;vector base + $B6
VEC_FLASH		DW	ISR_FLASH		;vector base + $B8
VEC_FLASHFLT  		DW	ISR_FLASHFLT  		;vector base + $BA
VEC_RESBC		DW	ISR_RESBC		;vector base + $BC
VEC_RESBE		DW	ISR_RESBE		;vector base + $BE
VEC_RESC0		DW	ISR_RESC0		;vector base + $C0
VEC_RESC2		DW	ISR_RESC2		;vector base + $C2
VEC_RESC4		DW	ISR_RESC4		;vector base + $C4
VEC_PLLLOCK		DW	ISR_PLLLOCK		;vector base + $C6
VEC_OSCSTAT		DW	ISR_OSCSTAT		;vector base + $C8
VEC_RESCA		DW	ISR_RESCA		;vector base + $CA
VEC_RESCC		DW	ISR_RESCC		;vector base + $CC
VEC_PORTL		DW	ISR_PORTL		;vector base + $CC
VEC_RESD0		DW	ISR_RESD0		;vector base + $D0
VEC_ATD			DW	ISR_ATD			;vector base + $D2
VEC_SCI1		DW	ISR_SCI1		;vector base + $D4
VEC_SCI0		DW	ISR_SCI0		;vector base + $D6
VEC_SPI			DW	ISR_SPI			;vector base + $D8
VEC_RESDA		DW	ISR_RESDA		;vector base + $DA
VEC_TIM1_TOV		DW	ISR_TIM1_TOV		;vector base + $DC
VEC_TIM0_TOV		DW	ISR_TIM0_TOV		;vector base + $DE
VEC_RESE0		DW	ISR_RESE0		;vector base + $E0
VEC_RESE2		DW	ISR_RESE2		;vector base + $E2
VEC_RESE4		DW	ISR_RESE4		;vector base + $E4
VEC_RESE6		DW	ISR_RESE6		;vector base + $E6
#ifdef S12VR64	
VEC_TIM0_TC3		DW	ISR_TIM0_TC3		;vector base + $E8
VEC_TIM0_TC2		DW	ISR_TIM0_TC2		;vector base + $EA
VEC_TIM0_TC1		DW	ISR_TIM0_TC1		;vector base + $EC
VEC_TIM0_TC0		DW	ISR_TIM0_TC0		;vector base + $EE
#else		
VEC_TIM1_TC1		DW	ISR_TIM1_TC1		;vector base + $E8
VEC_TIM1_TC0		DW	ISR_TIM1_TC0		;vector base + $EA
VEC_TIM0_TC1		DW	ISR_TIM0_TC1		;vector base + $EC
VEC_TIM0_TC0		DW	ISR_TIM0_TC0		;vector base + $EE
#endif		
VEC_RTI			DW	ISR_RTI			;vector base + $F0
VEC_IRQ			DW	ISR_IRQ			;vector base + $F2
VEC_XIRQ		DW	ISR_XIRQ		;vector base + $F4
VEC_SWI			DW	ISR_SWI			;vector base + $F6
VEC_TRAP		DW	ISR_TRAP		;vector base + $F8
#endif
