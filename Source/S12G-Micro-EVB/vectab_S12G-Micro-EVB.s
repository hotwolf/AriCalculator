;###############################################################################
;# S12CBase - VECTAB - Vector Table (S12G-Micro-EVB)                           #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#    This module defines the static vector table of the OpenBDC firmware.     #
;#    Unexpected inerrupts are cought and trigger a fatal error in the reset   #
;#    handler.                                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    KEYS    - Keypad controller                                              #
;#    BATMON  - Battery monitor                                                #
;#    SCI     - UART driver                                                    #
;#    DISP    - ST7565R display driver                                         #
;#    ERROR   - Error handler                                                  #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 14, 2012                                                           #
;#      - Initial release                                                      #
;#    August 10, 2012                                                          #
;#      - Added support for linear PC                                          #
;#      - Added dummy vectors                                                  #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Make each unused interrupt point to a separate BGND instruction
;VECTAB_DEBUG		EQU	1 

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Undefined ISRs                                                              #
;###############################################################################
;#KEYS (keypad controller)
#ifndef	KEYS_ROW_ISR
KEYS_ROW_ISR		EQU	VECTAB_DUMMY__PAD	;vector base + $82
#endif
#ifndef	KEYS_COL_ISR
KEYS_COL_ISR		EQU	VECTAB_DUMMY__PORTP	;vector base + $8E
#endif

;#BATMON (battery monitor)
#ifndef	BATMON_ISR
BATMON_ISR		EQU	VECTAB_DUMMY_ADCCOMP	;vector base + $84
#endif

;#SCI (UART driver)
#ifndef	SCI_ISR_RXTX
SCI_ISR_RXTX		EQU	VECTAB_DUMMY_SCI0	;vector base + $D6
#endif
#ifndef	SCI_ISR_BD_PE
SCI_ISR_BD_PE          	EQU   	VECTAB_DUMMY_TIM_TC0	;vector base + $EE
#endif
#ifndef	SCI_ISR_BD_NE
SCI_ISR_BD_NE          	EQU   	VECTAB_DUMMY_TIM_TC1	;vector base + $EC
#endif
#ifndef	SCI_ISR_BD_TO
SCI_ISR_BD_TO		EQU	VECTAB_DUMMY_TIM_TC2	;vector base + $EA
#endif

;#DISP (ST7565R display driver)
#ifndef	DISP_ISR
DISP_ISR		DW	VECTAB_DUMMY_SPI0	;vector base + $D8
#endif

;#ERROR
#ifndef	ERROR_RESET_COP
ERROR_RESET_COP		EQU	START_OF_CODE
#endif
#ifndef	ERROR_RESET_CM
ERROR_RESET_CM		EQU	ERROR_RESET_COP	
#endif
#ifndef	ERROR_RESET_EXT
ERROR_RESET_EXT		EQU	ERROR_RESET_COP	
#endif

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
			MOVB	#(VECTAB>>8), IVBR
#endif
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef VECTAB_CODE_START_LIN
			ORG 	VECTAB_CODE_START, VECTAB_CODE_START_LIN
#else
			ORG 	VECTAB_CODE_START
VECTAB_VARS_START_LIN	EQU	@			
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
VECTAB_VARS_START_LIN	EQU	@			
#endif	

#ifdef VECTAB_DEBUG
VECTAB_DUMMY_SPURIOUS	BGND				;vector base + $80
VECTAB_DUMMY_PAD	BGND				;vector base + $82
VECTAB_DUMMY_ADCCOMP	BGND				;vector base + $84
VECTAB_DUMMY_RES_86	BGND				;vector base + $86
VECTAB_DUMMY_API	BGND				;vector base + $88
VECTAB_DUMMY_LVI	BGND				;vector base + $8A
VECTAB_DUMMY_RES_8C	BGND				;vector base + $8C
VECTAB_DUMMY_PORTP	BGND				;vector base + $8E
VECTAB_DUMMY_RES_90	BGND				;vector base + $90
VECTAB_DUMMY_RES_92	BGND				;vector base + $92
VECTAB_DUMMY_RES_94	BGND				;vector base + $94
VECTAB_DUMMY_RES_96	BGND				;vector base + $96
VECTAB_DUMMY_RES_98	BGND				;vector base + $98
VECTAB_DUMMY_RES_9A	BGND				;vector base + $9A
VECTAB_DUMMY_RES_9C	BGND				;vector base + $9C
VECTAB_DUMMY_RES_9E	BGND				;vector base + $9E
VECTAB_DUMMY_RES_A0	BGND				;vector base + $A0
VECTAB_DUMMY_RES_A2	BGND				;vector base + $A2
VECTAB_DUMMY_RES_A4	BGND				;vector base + $A4
VECTAB_DUMMY_RES_A6	BGND				;vector base + $A6
VECTAB_DUMMY_RES_A8	BGND				;vector base + $A8
VECTAB_DUMMY_RES_AA	BGND				;vector base + $AA
VECTAB_DUMMY_RES_AC	BGND				;vector base + $AC
VECTAB_DUMMY_RES_AE	BGND				;vector base + $AE
VECTAB_DUMMY_CANTX	BGND				;vector base + $A0
VECTAB_DUMMY_CANRX	BGND				;vector base + $B2
VECTAB_DUMMY_CANERR	BGND				;vector base + $B4
VECTAB_DUMMY_CANWUP	BGND				;vector base + $B6
VECTAB_DUMMY_FLASH	BGND				;vector base + $B8
VECTAB_DUMMY_FLASHFLT	BGND				;vector base + $BA
VECTAB_DUMMY_SPI2	BGND				;vector base + $BC
VECTAB_DUMMY_SPI1	BGND				;vector base + $BE
VECTAB_DUMMY_RES_C0	BGND				;vector base + $C0
VECTAB_DUMMY_SCI2	BGND				;vector base + $C2
VECTAB_DUMMY_RES_C4	BGND				;vector base + $C4
VECTAB_DUMMY_PLLLOCK	BGND				;vector base + $C6
VECTAB_DUMMY_OSCSTAT	BGND				;vector base + $C8
VECTAB_DUMMY_RES_CA	BGND				;vector base + $CA
VECTAB_DUMMY_ACMP	BGND				;vector base + $CC
VECTAB_DUMMY_PORTJ	BGND				;vector base + $CC
VECTAB_DUMMY_RES_D0	BGND				;vector base + $D0
VECTAB_DUMMY_ATD0	BGND				;vector base + $D2
VECTAB_DUMMY_SCI1	BGND				;vector base + $D4
VECTAB_DUMMY_SCI0	BGND				;vector base + $D6
VECTAB_DUMMY_SPI0	BGND				;vector base + $D8
VECTAB_DUMMY_TIM_PAIE	BGND				;vector base + $DA
VECTAB_DUMMY_TIM_PAOV	BGND				;vector base + $DC
VECTAB_DUMMY_TIM_TOV	BGND				;vector base + $DE
VECTAB_DUMMY_TIM_TC7	BGND				;vector base + $E0
VECTAB_DUMMY_TIM_TC6	BGND				;vector base + $E2
VECTAB_DUMMY_TIM_TC5	BGND				;vector base + $E4
VECTAB_DUMMY_TIM_TC4	BGND				;vector base + $E6
VECTAB_DUMMY_TIM_TC3	BGND				;vector base + $E8
VECTAB_DUMMY_TIM_TC2	BGND				;vector base + $EA
VECTAB_DUMMY_TIM_TC1	BGND				;vector base + $EC
VECTAB_DUMMY_TIM_TC0	BGND				;vector base + $EE
VECTAB_DUMMY_RTI	BGND				;vector base + $F0
VECTAB_DUMMY_IRQ	BGND				;vector base + $F2
VECTAB_DUMMY_XIRQ	BGND				;vector base + $F4
VECTAB_DUMMY_SWI	BGND				;vector base + $F6
VECTAB_DUMMY_TRAP	BGND				;vector base + $F8
#else								
VECTAB_DUMMY_SPURIOUS	EQU	ERROR_ISR		;vector base + $80
VECTAB_DUMMY_PAD	EQU	ERROR_ISR		;vector base + $82
VECTAB_DUMMY_ADCCOMP	EQU	ERROR_ISR		;vector base + $84
VECTAB_DUMMY_RES_86	EQU	ERROR_ISR		;vector base + $86
VECTAB_DUMMY_API	EQU	ERROR_ISR		;vector base + $88
VECTAB_DUMMY_LVI	EQU	ERROR_ISR		;vector base + $8A
VECTAB_DUMMY_RES_8C	EQU	ERROR_ISR		;vector base + $8C
VECTAB_DUMMY_PORTP	EQU	ERROR_ISR		;vector base + $8E
VECTAB_DUMMY_RES_90	EQU	ERROR_ISR		;vector base + $90
VECTAB_DUMMY_RES_92	EQU	ERROR_ISR		;vector base + $92
VECTAB_DUMMY_RES_94	EQU	ERROR_ISR		;vector base + $94
VECTAB_DUMMY_RES_96	EQU	ERROR_ISR		;vector base + $96
VECTAB_DUMMY_RES_98	EQU	ERROR_ISR		;vector base + $98
VECTAB_DUMMY_RES_9A	EQU	ERROR_ISR		;vector base + $9A
VECTAB_DUMMY_RES_9C	EQU	ERROR_ISR		;vector base + $9C
VECTAB_DUMMY_RES_9E	EQU	ERROR_ISR		;vector base + $9E
VECTAB_DUMMY_RES_A0	EQU	ERROR_ISR		;vector base + $A0
VECTAB_DUMMY_RES_A2	EQU	ERROR_ISR		;vector base + $A2
VECTAB_DUMMY_RES_A4	EQU	ERROR_ISR		;vector base + $A4
VECTAB_DUMMY_RES_A6	EQU	ERROR_ISR		;vector base + $A6
VECTAB_DUMMY_RES_A8	EQU	ERROR_ISR		;vector base + $A8
VECTAB_DUMMY_RES_AA	EQU	ERROR_ISR		;vector base + $AA
VECTAB_DUMMY_RES_AC	EQU	ERROR_ISR		;vector base + $AC
VECTAB_DUMMY_RES_AE	EQU	ERROR_ISR		;vector base + $AE
VECTAB_DUMMY_CANTX	EQU	ERROR_ISR		;vector base + $A0
VECTAB_DUMMY_CANRX	EQU	ERROR_ISR		;vector base + $B2
VECTAB_DUMMY_CANERR	EQU	ERROR_ISR		;vector base + $B4
VECTAB_DUMMY_CANWUP	EQU	ERROR_ISR		;vector base + $B6
VECTAB_DUMMY_FLASH	EQU	ERROR_ISR		;vector base + $B8
VECTAB_DUMMY_FLASHFLT	EQU	ERROR_ISR		;vector base + $BA
VECTAB_DUMMY_SPI2	EQU	ERROR_ISR		;vector base + $BC
VECTAB_DUMMY_SPI1	EQU	ERROR_ISR		;vector base + $BE
VECTAB_DUMMY_RES_C0	EQU	ERROR_ISR		;vector base + $C0
VECTAB_DUMMY_SCI2	EQU	ERROR_ISR		;vector base + $C2
VECTAB_DUMMY_RES_C4	EQU	ERROR_ISR		;vector base + $C4
VECTAB_DUMMY_PLLLOCK	EQU	ERROR_ISR		;vector base + $C6
VECTAB_DUMMY_OSCSTAT	EQU	ERROR_ISR		;vector base + $C8
VECTAB_DUMMY_RES_CA	EQU	ERROR_ISR		;vector base + $CA
VECTAB_DUMMY_ACMP	EQU	ERROR_ISR		;vector base + $CC
VECTAB_DUMMY_PORTJ	EQU	ERROR_ISR		;vector base + $CC
VECTAB_DUMMY_RES_D0	EQU	ERROR_ISR		;vector base + $D0
VECTAB_DUMMY_ATD0	EQU	ERROR_ISR		;vector base + $D2
VECTAB_DUMMY_SCI1	EQU	ERROR_ISR		;vector base + $D4
VECTAB_DUMMY_SCI0	EQU	ERROR_ISR		;vector base + $D6
VECTAB_DUMMY_SPI0	EQU	ERROR_ISR		;vector base + $D8
VECTAB_DUMMY_TIM_PAIE	EQU	ERROR_ISR		;vector base + $DA
VECTAB_DUMMY_TIM_PAOV	EQU	ERROR_ISR		;vector base + $DC
VECTAB_DUMMY_TIM_TOV	EQU	ERROR_ISR		;vector base + $DE
VECTAB_DUMMY_TIM_TC7	EQU	ERROR_ISR		;vector base + $E0
VECTAB_DUMMY_TIM_TC6	EQU	ERROR_ISR		;vector base + $E2
VECTAB_DUMMY_TIM_TC5	EQU	ERROR_ISR		;vector base + $E4
VECTAB_DUMMY_TIM_TC4	EQU	ERROR_ISR		;vector base + $E6
VECTAB_DUMMY_TIM_TC3	EQU	ERROR_ISR		;vector base + $E8
VECTAB_DUMMY_TIM_TC2	EQU	ERROR_ISR		;vector base + $EA
VECTAB_DUMMY_TIM_TC1	EQU	ERROR_ISR		;vector base + $EC
VECTAB_DUMMY_TIM_TC0	EQU	ERROR_ISR		;vector base + $EE
VECTAB_DUMMY_RTI	EQU	ERROR_ISR		;vector base + $F0
VECTAB_DUMMY_IRQ	EQU	ERROR_ISR		;vector base + $F2
VECTAB_DUMMY_XIRQ	EQU	ERROR_ISR		;vector base + $F4
VECTAB_DUMMY_SWI	EQU	ERROR_ISR		;vector base + $F6
VECTAB_DUMMY_TRAP	EQU	ERROR_ISR		;vector base + $F8
#endif

VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	
	
;###############################################################################
;# S12G Vector Table                                                           #
;###############################################################################
			ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_SPURIOUS		DW	VECTAB_DUMMY_SPURIOUS	;vector base + $80
VEC_PAD			DW	KEYS_ROW_ISR		;vector base + $82
VEC_ADCCOMP		DW	BATMON_ISR		;vector base + $84
VEC_RESERVED_86		DW	VECTAB_DUMMY_VEC_RES_86	;vector base + $86
VEC_API	       		DW	VECTAB_DUMMY_VEC_API	;vector base + $88
VEC_LVI	       		DW	VECTAB_DUMMY_VEC_LVI	;vector base + $8A
VEC_RESERVED_8C		DW	VECTAB_DUMMY_VEC_RES_8C	;vector base + $8C
VEC_PORTP		DW	KEYS_COL_ISR		;vector base + $8E
VEC_RESERVED_90		DW	VECTAB_DUMMY_RES_90	;vector base + $90
VEC_RESERVED_92		DW	VECTAB_DUMMY_RES_92	;vector base + $92
VEC_RESERVED_94		DW	VECTAB_DUMMY_RES_94	;vector base + $94
VEC_RESERVED_96		DW	VECTAB_DUMMY_RES_96	;vector base + $96
VEC_RESERVED_98		DW	VECTAB_DUMMY_RES_98	;vector base + $98
VEC_RESERVED_9A		DW	VECTAB_DUMMY_RES_9A	;vector base + $9A
VEC_RESERVED_9C		DW	VECTAB_DUMMY_RES_9C	;vector base + $9C
VEC_RESERVED_9E		DW	VECTAB_DUMMY_RES_9E	;vector base + $9E
VEC_RESERVED_A0		DW	VECTAB_DUMMY_RES_A0	;vector base + $A0
VEC_RESERVED_A2		DW	VECTAB_DUMMY_RES_A2	;vector base + $A2
VEC_RESERVED_A4		DW	VECTAB_DUMMY_RES_A4	;vector base + $A4
VEC_RESERVED_A6		DW	VECTAB_DUMMY_RES_A6	;vector base + $A6
VEC_RESERVED_A8		DW	VECTAB_DUMMY_RES_A8	;vector base + $A8
VEC_RESERVED_AA		DW	VECTAB_DUMMY_RES_AA	;vector base + $AA
VEC_RESERVED_AC		DW	VECTAB_DUMMY_RES_AC	;vector base + $AC
VEC_RESERVED_AE		DW	VECTAB_DUMMY_RES_AE	;vector base + $AE
VEC_CANTX		DW	VECTAB_DUMMY_CANTX	;vector base + $A0
VEC_CANRX		DW	VECTAB_DUMMY_CANRX	;vector base + $B2
VEC_CANERR		DW	VECTAB_DUMMY_CANERR	;vector base + $B4
VEC_CANWUP		DW	VECTAB_DUMMY_CANWUP	;vector base + $B6
VEC_FLASH		DW	VECTAB_DUMMY_FLASH	;vector base + $B8
VEC_FLASHFLT		DW	VECTAB_DUMMY_FLASHFLT	;vector base + $BA
VEC_SPI2		DW	VECTAB_DUMMY_SPI2	;vector base + $BC
VEC_SPI1		DW	VECTAB_DUMMY_SPI1	;vector base + $BE
VEC_RESERVED_C0		DW	VECTAB_DUMMY_RES_C0	;vector base + $C0
VEC_SCI2		DW	VECTAB_DUMMY_SCI2	;vector base + $C2
VEC_RESERVED_C4		DW	VECTAB_DUMMY_RES_C4	;vector base + $C4
VEC_PLLLOCK		DW	VECTAB_DUMMY_PLLLOCK	;vector base + $C6
VEC_OSCSTAT		DW	VECTAB_DUMMY_OSCSTAT	;vector base + $C8
VEC_RESERVED_CA		DW	VECTAB_DUMMY_RES_CA	;vector base + $CA
VEC_ACMP		DW	VECTAB_DUMMY_ACMP	;vector base + $CC
VEC_PORTJ		DW	VECTAB_DUMMY_PORTJ	;vector base + $CC
VEC_RESERVED_D0		DW	VECTAB_DUMMY_RES_D0	;vector base + $D0
VEC_ATD0		DW	VECTAB_DUMMY_ATD0	;vector base + $D2
VEC_SCI1		DW	VECTAB_DUMMY_SCI1	;vector base + $D4
VEC_SCI0		DW	SCI_ISR_RXTX		;vector base + $D6
VEC_SPI0		DW	DISP_ISR		;vector base + $D8
VEC_TIM_PAIE		DW	VECTAB_DUMMY_TIM_PAIE	;vector base + $DA
VEC_TIM_PAOV		DW	VECTAB_DUMMY_TIM_PAOV	;vector base + $DC
VEC_TIM_TOV		DW	VECTAB_DUMMY_TIM_TOV	;vector base + $DE
VEC_TIM_TC7		DW	VECTAB_DUMMY_TIM_TC7	;vector base + $E0
VEC_TIM_TC6		DW	VECTAB_DUMMY_TIM_TC6	;vector base + $E2
VEC_TIM_TC5		DW	VECTAB_DUMMY_TIM_TC5	;vector base + $E4
VEC_TIM_TC4		DW	VECTAB_DUMMY_TIM_TC4	;vector base + $E6
VEC_TIM_TC3		DW	VECTAB_DUMMY_TIM_TC3	;vector base + $E8
VEC_TIM_TC2		DW	SCI_ISR_BD_TO		;vector base + $EA
VEC_TIM_TC1		DW	SCI_ISR_BD_NE		;vector base + $EC
VEC_TIM_TC0		DW	SCI_ISR_BD_PE		;vector base + $EE
VEC_RTI			DW	VECTAB_DUMMY_RTI	;vector base + $F0
VEC_IRQ			DW	VECTAB_DUMMY_IRQ	;vector base + $F2
VEC_XIRQ		DW	VECTAB_DUMMY_XIRQ	;vector base + $F4
VEC_SWI			DW	VECTAB_DUMMY_SWI	;vector base + $F6
VEC_TRAP		DW	VECTAB_DUMMY_TRAP	;vector base + $F8
VEC_RESET_COP		DW	ERROR_RESET_COP		;vector base + $FA
VEC_RESET_CM		DW	ERROR_RESET_CM		;vector base + $FC
VEC_RESET_EXT		DW	ERROR_RESET_EXT		;vector base + $FE
