;###############################################################################
;# S12CBase - VECTAB - Vector Table (Mini-BDM-Pod)                             #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#    This module defines the static vector table of the OpenBDC firmware.     #
;#    Unexpected inerrupts are cought and trigger a fatal error in the reset   #
;#    handler.                                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase Framework bundle                                       #
;#    ERROR  - Error handler                                                   #
;#    BDM    - BDM driver                                                      #
;#    CLOCK  - Clock handler                                                   #
;#    SCI    - UART driver                                                     #
;#    LED    - LED driver                                                      #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    December 14, 2011                                                        #
;#      - Initial release                                                      #
;#    July 31, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added dummy vectors                                                  #
;###############################################################################


;###############################################################################
;# Configuration                                                               #
;###############################################################################
;RAM or flash
#ifndef	VECTAB_RAM
#ifndef	VECTAB_FLASH
#ifdef	MMAP_RAM
VECTAB_RAM		EQU	1 		;reuse MMAP configuration
#else
VECTAB_FLASH		EQU	1 		;default is flash
#endif
#endif
#endif

;Make each unused interrupt point to a separate BGND instruction
;VECTAB_DEBUG		EQU	1 

;###############################################################################
;# Constants                                                                   #
;###############################################################################
VECTAB_START		EQU	$EF10
VECTAB_START_LIN	EQU	$FEF10


;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	VECTAB_VARS_START
VECTAB_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	VECTAB_INIT, 0
			;Set vector base address
			MOVB	#(VECTAB_START>>8), IVBR
			;Disable XGATE interrupts
			CLR	XGPRIO	
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



	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	

	
;###############################################################################
;# S12XEP100 Vector Table                                                      #
;###############################################################################
		ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_SPURIOUS	DW	ERROR_ISR		;vector base + $10
VEC_SYS		DW	ERROR_ISR		;vector base + $12
VEC_MPU		DW	ERROR_ISR		;vector base + $14
VEC_XGSWE	DW	ERROR_ISR		;vector base + $16
VEC_RESERVED18	DW	ERROR_ISR		;vector base + $18
VEC_RESERVED1A	DW	ERROR_ISR		;vector base + $1A
VEC_RESERVED1C	DW	ERROR_ISR		;vector base + $1C
VEC_RESERVED1E	DW	ERROR_ISR		;vector base + $1E
VEC_RESERVED20	DW	ERROR_ISR		;vector base + $20
VEC_RESERVED22	DW	ERROR_ISR		;vector base + $22
VEC_RESERVED24	DW	ERROR_ISR		;vector base + $24
VEC_RESERVED26	DW	ERROR_ISR		;vector base + $26
VEC_RESERVED28	DW	ERROR_ISR		;vector base + $28
VEC_RESERVED2A	DW	ERROR_ISR		;vector base + $2A
VEC_RESERVED2C	DW	ERROR_ISR		;vector base + $2C
VEC_RESERVED2E	DW	ERROR_ISR		;vector base + $2E
VEC_RESERVED30	DW	ERROR_ISR		;vector base + $30
VEC_RESERVED32	DW	ERROR_ISR		;vector base + $32
VEC_RESERVED34	DW	ERROR_ISR		;vector base + $34
VEC_RESERVED36	DW	ERROR_ISR		;vector base + $36
VEC_RESERVED38	DW	ERROR_ISR		;vector base + $38
VEC_RESERVED3A	DW	ERROR_ISR		;vector base + $3A
VEC_ATD1COMP	DW	ERROR_ISR		;vector base + $3C
VEC_ATD0COMP	DW	TVMON_ISR		;vector base + $3E
VEC_TIM_PAIE	DW	ERROR_ISR		;vector base + $40
VEC_TIM_PAOV	DW	ERROR_ISR		;vector base + $42
VEC_TIM_TOV	DW	ERROR_ISR		;vector base + $44
VEC_TIM_TC7	DW	ERROR_ISR		;vector base + $46
VEC_TIM_TC6	DW	ERROR_ISR		;vector base + $48
VEC_TIM_TC5	DW	ERROR_ISR		;vector base + $4A
VEC_TIM_TC4	DW	ERROR_ISR		;vector base + $4C
VEC_TIM_TC3	DW	ERROR_ISR		;vector base + $4E
VEC_TIM_TC2	DW	ERROR_ISR		;vector base + $50
VEC_TIM_TC1	DW	ERROR_ISR		;vector base + $52
VEC_TIM_TC0	DW	ERROR_ISR		;vector base + $54
VEC_SCI7	DW	ERROR_ISR		;vector base + $56
VEC_PITCH7	DW	ERROR_ISR		;vector base + $58
VEC_PITCH6	DW	ERROR_ISR		;vector base + $5A
VEC_PITCH5	DW	ERROR_ISR		;vector base + $5C
VEC_PITCH4	DW	ERROR_ISR		;vector base + $5E
VEC_RESERVED60	DW	ERROR_ISR		;vector base + $60
VEC_RESERVED62	DW	ERROR_ISR		;vector base + $62
VEC_XGSWT7	DW	ERROR_ISR		;vector base + $64
VEC_XGSWT6	DW	ERROR_ISR		;vector base + $66
VEC_XGSWT5	DW	ERROR_ISR		;vector base + $68
VEC_XGSWT4	DW	ERROR_ISR		;vector base + $6A
VEC_XGSWT3	DW	ERROR_ISR		;vector base + $6C
VEC_XGSWT2	DW	ERROR_ISR		;vector base + $6E
VEC_XGSWT1	DW	ERROR_ISR		;vector base + $70
VEC_XGSWT0	DW	ERROR_ISR		;vector base + $72
VEC_PITCH3	DW	ERROR_ISR		;vector base + $74
VEC_PITCH2	DW	ERROR_ISR		;vector base + $76
VEC_PITCH1	DW	ERROR_ISR		;vector base + $78
VEC_PITCH0	DW	ERROR_ISR		;vector base + $7A
VEC_HT		DW	ERROR_ISR		;vector base + $7C
VEC_API		DW	ERROR_ISR		;vector base + $7E
VEC_LVI		DW	ERROR_ISR		;vector base + $80
VEC_IIC1	DW	ERROR_ISR		;vector base + $82
VEC_SCI5	DW	ERROR_ISR		;vector base + $84
VEC_SCI4	DW	ERROR_ISR		;vector base + $86
VEC_SCI3	DW	ERROR_ISR		;vector base + $88
VEC_SCI2	DW	ERROR_ISR		;vector base + $8A
VEC_PWMSDN	DW	ERROR_ISR		;vector base + $8C
VEC_PORTP	DW	ERROR_ISR		;vector base + $8E
VEC_CAN4TX	DW	ERROR_ISR		;vector base + $90
VEC_CAN4RX	DW	ERROR_ISR		;vector base + $92
VEC_CAN4ERR	DW	ERROR_ISR		;vector base + $94
VEC_CAN4WUP	DW	ERROR_ISR		;vector base + $96
VEC_CAN3TX	DW	ERROR_ISR		;vector base + $98
VEC_CAN3RX	DW	ERROR_ISR		;vector base + $9A
VEC_CAN3ERR	DW	ERROR_ISR		;vector base + $9C
VEC_CAN3WUP	DW	ERROR_ISR		;vector base + $9E
VEC_CAN2TX	DW	ERROR_ISR		;vector base + $A0
VEC_CAN2RX	DW	ERROR_ISR		;vector base + $A2
VEC_CAN2ERR	DW	ERROR_ISR		;vector base + $A4
VEC_CAN2WUP	DW	ERROR_ISR		;vector base + $A6
VEC_CAN1TX	DW	ERROR_ISR		;vector base + $A8
VEC_CAN1RX	DW	ERROR_ISR		;vector base + $AA
VEC_CAN1ERR	DW	ERROR_ISR		;vector base + $AC
VEC_CAN1WUP	DW	ERROR_ISR		;vector base + $AE
VEC_CAN0TX	DW	ERROR_ISR		;vector base + $A0
VEC_CAN0RX	DW	ERROR_ISR		;vector base + $B2
VEC_CAN0ERR	DW	ERROR_ISR		;vector base + $B4
VEC_CAN0WUP	DW	ERROR_ISR		;vector base + $B6
VEC_FLASH	DW	ERROR_ISR		;vector base + $B8
VEC_FLASHFLT	DW	ERROR_ISR		;vector base + $BA
VEC_SPI2	DW	ERROR_ISR		;vector base + $BC
VEC_SPI1	DW	ERROR_ISR		;vector base + $BE
VEC_IIC0	DW	ERROR_ISR		;vector base + $C0
VEC_SCI6	DW	ERROR_ISR		;vector base + $C2
VEC_SCM		DW	ERROR_ISR		;vector base + $C4
VEC_PLLLOCK	DW	CLOCK_ISR		;vector base + $C6
VEC_ECT_PBOV	DW	ERROR_ISR		;vector base + $C8
VEC_ECT_MODCNT	DW	ERROR_ISR		;vector base + $CA
VEC_PORTH	DW	ERROR_ISR		;vector base + $CC
VEC_PORTJ	DW	ERROR_ISR		;vector base + $CC
VEC_ATD1	DW	ERROR_ISR		;vector base + $D0
VEC_ATD0	DW	ERROR_ISR		;vector base + $D2
VEC_SCI1	DW	ERROR_ISR		;vector base + $D4
VEC_SCI0	DW	SCI_ISR_RXTX		;vector base + $D6
VEC_SPI0	DW	ERROR_ISR		;vector base + $D8
VEC_ECT_PAIE	DW	ERROR_ISR		;vector base + $DA
VEC_ECT_PAOV	DW	ERROR_ISR		;vector base + $DC
VEC_ECT_TOV	DW	ERROR_ISR		;vector base + $DE
VEC_ECT_TC7	DW	BDM_ISR_TC7		;vector base + $E0
VEC_ECT_TC6	DW	BDM_ISR_TC6		;vector base + $E2
VEC_ECT_TC5	DW	ERROR_ISR		;vector base + $E4
VEC_ECT_TC4	DW	ERROR_ISR		;vector base + $E6
VEC_ECT_TC3	DW	ERROR_ISR		;vector base + $E8
VEC_ECT_TC2	DW	ERROR_ISR		;vector base + $EA
VEC_ECT_TC1	DW	ERROR_ISR		;vector base + $EC
VEC_ECT_TC0	DW	SCI_ISR_TC0		;vector base + $EE
VEC_RTI		DW	ERROR_ISR		;vector base + $F0
VEC_IRQ		DW	ERROR_ISR		;vector base + $F2
VEC_XIRQ	DW	ERROR_ISR		;vector base + $F4
VEC_SWI		DW	ERROR_ISR		;vector base + $F6
VEC_TRAP	DW	ERROR_ISR		;vector base + $F8
VEC_RESET_COP	DW	BASE_ENTRY_COP		;vector base + $FA
VEC_RESET_CM	DW	BASE_ENTRY_CM		;vector base + $FC
VEC_RESET_EXT	DW	BASE_ENTRY_EXT		;vector base + $FE
