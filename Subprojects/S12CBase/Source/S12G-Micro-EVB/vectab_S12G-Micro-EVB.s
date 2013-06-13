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
;#    November 16, 2012                                                        #
;#      - Restructured table                                                   #
;#    June 12, 2013                                                            #
;#      - Added ECC error interrupt                                            #
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

;#Interrupt service routines
;#--------------------------
#ifdef VECTAB_DEBUG
ISR_SPURIOUS		BGND				;vector base + $80
#ifdef	KEYS_ISR_ROW					;vector base + $82
ISR_PAD			EQU	KEYS_ISR_ROW
#else
ISR_PAD			BGND
#endif
#ifdef	BATMON_ISR					;vector base + $84
ISR_ADCCOMP		EQU	BATMON_ISR
#else
ISR_ADCCOMP		BGND
#endif
ISR_RES86		BGND				;vector base + $86
ISR_API			BGND				;vector base + $88
ISR_LVI			BGND				;vector base + $8A
ISR_RES8C		BGND				;vector base + $8C
#ifdef	KEYS_ISR_COL					;vector base + $8E
ISR_PORTP		EQU	KEYS_ISR_COL
#else
ISR_PORTP		BGND
#endif
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
ISR_CANTX		BGND				;vector base + $A0
ISR_CANRX		BGND				;vector base + $B2
ISR_CANERR		BGND				;vector base + $B4
ISR_CANWUP		BGND				;vector base + $B6
ISR_FLASH		BGND				;vector base + $B8
#ifdef	NVM_ISR_ECCERR					;vector base + $BA
ISR_FLASHFLT  		EQU	NVM_ISR_ECCERR
#else
ISR_FLASHFLT  		BGND
#endif
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
#ifdef	SCI_ISR_RXTX					;vector base + $D6
ISR_SCI0		EQU	SCI_ISR_RXTX
#else
ISR_SCI0		BGND
#endif
#ifdef	DISP_ISR					;vector base + $D8
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
#ifdef	SCI_ISR_DELAY					;vector base + $E8
ISR_TIM_TC3		EQU	SCI_ISR_DELAY
#else
ISR_TIM_TC3		BGND
#endif
ISR_TIM_TC2		BGND				;vector base + $EA
#ifdef	SCI_ISR_BD_NE					;vector base + $EC
ISR_TIM_TC1		EQU	SCI_ISR_BD_NE
#else
ISR_TIM_TC1		BGND
#endif
#ifdef	SCI_ISR_BD_PE					;vector base + $EE
ISR_TIM_TC0		EQU	SCI_ISR_BD_PE
#else
ISR_TIM_TC0		BGND
#endif
ISR_RTI			BGND				;vector base + $F0
ISR_IRQ			BGND				;vector base + $F2
ISR_XIRQ		BGND				;vector base + $F4
ISR_SWI			BGND				;vector base + $F6
ISR_TRAP		BGND				;vector base + $F8
#else								
ISR_SPURIOUS		EQU	RESET_ISR_FATAL		;vector base + $80
#ifdef	KEYS_ISR_ROW					;vector base + $82
ISR_PAD			EQU	KEYS_ISR_ROW
#else
ISR_PAD			EQU	RESET_ISR_FATAL
#endif
#ifdef	BATMON_ISR					;vector base + $84
ISR_ADCCOMP		EQU	BATMON_ISR
#else
ISR_ADCCOMP		EQU	RESET_ISR_FATAL
#endif
ISR_RES86		EQU	RESET_ISR_FATAL		;vector base + $86
ISR_API			EQU	RESET_ISR_FATAL		;vector base + $88
ISR_LVI			EQU	RESET_ISR_FATAL		;vector base + $8A
ISR_RES8C		EQU	RESET_ISR_FATAL		;vector base + $8C
#ifdef	KEYS_ISR_COL					;vector base + $8E
ISR_PORTP		EQU	KEYS_ISR_COL
#else
ISR_PORTP		EQU	RESET_ISR_FATAL
#endif
ISR_RES90		EQU	RESET_ISR_FATAL		;vector base + $90
ISR_RES92		EQU	RESET_ISR_FATAL		;vector base + $92
ISR_RES94		EQU	RESET_ISR_FATAL		;vector base + $94
ISR_RES96		EQU	RESET_ISR_FATAL		;vector base + $96
ISR_RES98		EQU	RESET_ISR_FATAL		;vector base + $98
ISR_RES9A		EQU	RESET_ISR_FATAL		;vector base + $9A
ISR_RES9C		EQU	RESET_ISR_FATAL		;vector base + $9C
ISR_RES9E		EQU	RESET_ISR_FATAL		;vector base + $9E
ISR_RESA0		EQU	RESET_ISR_FATAL		;vector base + $A0
ISR_RESA2		EQU	RESET_ISR_FATAL		;vector base + $A2
ISR_RESA4		EQU	RESET_ISR_FATAL		;vector base + $A4
ISR_RESA6		EQU	RESET_ISR_FATAL		;vector base + $A6
ISR_RESA8		EQU	RESET_ISR_FATAL		;vector base + $A8
ISR_RESAA		EQU	RESET_ISR_FATAL		;vector base + $AA
ISR_RESAC		EQU	RESET_ISR_FATAL		;vector base + $AC
ISR_RESAE		EQU	RESET_ISR_FATAL		;vector base + $AE
ISR_CANTX		EQU	RESET_ISR_FATAL		;vector base + $A0
ISR_CANRX		EQU	RESET_ISR_FATAL		;vector base + $B2
ISR_CANERR		EQU	RESET_ISR_FATAL		;vector base + $B4
ISR_CANWUP		EQU	RESET_ISR_FATAL		;vector base + $B6
ISR_FLASH		EQU	RESET_ISR_FATAL		;vector base + $B8
#ifdef	NVM_ISR_ECCERR					;vector base + $BA
ISR_FLASHFLT  		EQU	NVM_ISR_ECCERR
#else
ISR_FLASHFLT  		EQU	RESET_ISR_FATAL
#endif
ISR_SPI2		EQU	RESET_ISR_FATAL		;vector base + $BC
ISR_SPI1		EQU	RESET_ISR_FATAL		;vector base + $BE
ISR_RESC0		EQU	RESET_ISR_FATAL		;vector base + $C0
ISR_SCI2		EQU	RESET_ISR_FATAL		;vector base + $C2
ISR_RESC4		EQU	RESET_ISR_FATAL		;vector base + $C4
ISR_PLLLOCK		EQU	RESET_ISR_FATAL		;vector base + $C6
ISR_OSCSTAT		EQU	RESET_ISR_FATAL		;vector base + $C8
ISR_RESCA		EQU	RESET_ISR_FATAL		;vector base + $CA
ISR_ACMP		EQU	RESET_ISR_FATAL		;vector base + $CC
ISR_PORTJ		EQU	RESET_ISR_FATAL		;vector base + $CC
ISR_RESD0		EQU	RESET_ISR_FATAL		;vector base + $D0
ISR_ATD0		EQU	RESET_ISR_FATAL		;vector base + $D2
ISR_SCI1		EQU	RESET_ISR_FATAL		;vector base + $D4
#ifdef	SCI_ISR_RXTX					;vector base + $D6
ISR_SCI0		EQU	SCI_ISR_RXTX
#else
ISR_SCI0		EQU	RESET_ISR_FATAL
#endif
#ifdef	DISP_ISR					;vector base + $D8
ISR_SPI0		EQU	DISP_ISR
#else
ISR_SPI0		EQU	RESET_ISR_FATAL
#endif
ISR_TIM_PAIE		EQU	RESET_ISR_FATAL		;vector base + $DA
ISR_TIM_PAOV		EQU	RESET_ISR_FATAL		;vector base + $DC
ISR_TIM_TOV		EQU	RESET_ISR_FATAL		;vector base + $DE
ISR_TIM_TC7		EQU	RESET_ISR_FATAL		;vector base + $E0
ISR_TIM_TC6		EQU	RESET_ISR_FATAL		;vector base + $E2
ISR_TIM_TC5		EQU	RESET_ISR_FATAL		;vector base + $E4
ISR_TIM_TC4		EQU	RESET_ISR_FATAL		;vector base + $E6
#ifdef	SCI_ISR_DELAY					;vector base + $E8
ISR_TIM_TC3		EQU	SCI_ISR_DELAY
#else
ISR_TIM_TC3		EQU	RESET_ISR_FATAL
#endif
ISR_TIM_TC2		EQU	RESET_ISR_FATAL		;vector base + $EA
#ifdef	SCI_ISR_BD_NE					;vector base + $EC
ISR_TIM_TC1		EQU	SCI_ISR_BD_NE
#else
ISR_TIM_TC1		EQU	RESET_ISR_FATAL
#endif
#ifdef	SCI_ISR_BD_PE					;vector base + $EE
ISR_TIM_TC0		EQU	SCI_ISR_BD_PE
#else
ISR_TIM_TC0		EQU	RESET_ISR_FATAL
#endif
ISR_RTI			EQU	RESET_ISR_FATAL		;vector base + $F0
ISR_IRQ			EQU	RESET_ISR_FATAL		;vector base + $F2
ISR_XIRQ		EQU	RESET_ISR_FATAL		;vector base + $F4
ISR_SWI			EQU	RESET_ISR_FATAL		;vector base + $F6
ISR_TRAP		EQU	RESET_ISR_FATAL		;vector base + $F8
#endif

;#Code entry points
;#-----------------
#ifdef	ERROR_RESET_COP					;vector base + $FA
RES_COP			EQU	RESET_COP_ENTRY
#else
RES_COP			EQU	RES_EXT
#endif
#ifdef	ERROR_RESET_CM					;vector base + $FC
RES_CM			EQU	RESET_CM_ENTRY
#else
RES_CM			EQU	RES_EXT
#endif
#ifdef	ERROR_RESET_EXT					;vector base + $FE
RES_EXT			EQU	RESET_EXT_ENTRY
#else
RES_EXT			EQU	START_OF_CODE
#endif
	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	
	
;###############################################################################
;# S12G Vector Table                                                           #
;###############################################################################
			ORG	VECTAB_START, VECTAB_START_LIN 	
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
VEC_RESET_COP		DW	RES_COP			;vector base + $FA
VEC_RESET_CM		DW	RES_CM			;vector base + $FC
VEC_RESET_EXT		DW	RES_EXT			;vector base + $FE
V
