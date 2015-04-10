#ifndef	VECTAB_COMPILED
#define VECTAB_COMPILED
;###############################################################################
;# S12CBase - VECTAB - Vector Table (S12DP256-Mini-EVB)                        #
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
;#    This module defines the static vector table of the OpenBDC firmware.     #
;#    Unexpected inerrupts are cought and trigger a fatal error in the reset   #
;#    handler.                                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    ERROR  - Error handler                                                   #
;#    CLOCK  - Clock handler                                                   #
;#    SCI    - UART driver                                                     #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    November 15, 2012                                                        #
;#      - Initial release                                                      #
;#    November 16, 2012                                                        #
;#      - Restructured table                                                   #
;#    January 29, 2015                                                         #
;#      - Updated during S12CBASE overhaul                                     #
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
#ifdef	SCI_ISR_BD_NEPE
			;Give SCI_ISR_BD_NEPE high priority 
			MOVB	#(VEC_ECT_TC0&$FF), HPRIO
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
	
;Illegal interrupt catcher
#ifndef VECTAB_DEBUG
VECTAB_ISR_ILLIRQ	RESET_FATAL	VECTAB_MSG_ILLIRQ
#else
VECTAB_ISR_ILLIRQ	BGND	
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
ISR_RES80		BGND				;vector base + $80
ISR_RES82   		BGND				;vector base + $82
ISR_RES84   		BGND				;vector base + $84
ISR_RES86   		BGND				;vector base + $86
ISR_RES88   		BGND				;vector base + $88
ISR_RES8A   		BGND				;vector base + $8A
ISR_PWMSDN 		BGND				;vector base + $8C
ISR_PORTP  		BGND				;vector base + $8E
ISR_CAN4TX 		BGND				;vector base + $90
ISR_CAN4RX 		BGND				;vector base + $92
ISR_CAN4ERR		BGND				;vector base + $94
ISR_CAN4WUP		BGND				;vector base + $96
ISR_CAN3TX 		BGND				;vector base + $98
ISR_CAN3RX 		BGND				;vector base + $9A
ISR_CAN3ERR		BGND				;vector base + $9C
ISR_CAN3WUP		BGND				;vector base + $9E
ISR_CAN2TX 		BGND				;vector base + $A0
ISR_CAN2RX 		BGND				;vector base + $A2
ISR_CAN2ERR		BGND				;vector base + $A4
ISR_CAN2WUP		BGND				;vector base + $A6
ISR_CAN1TX    		BGND				;vector base + $A8
ISR_CAN1RX    		BGND				;vector base + $AA
ISR_CAN1ERR   		BGND				;vector base + $AC
ISR_CAN1WUP   		BGND				;vector base + $AE
ISR_CAN0TX    		BGND				;vector base + $A0
ISR_CAN0RX    		BGND				;vector base + $B2
ISR_CAN0ERR   		BGND				;vector base + $B4
ISR_CAN0WUP   		BGND				;vector base + $B6
ISR_FLASH     		BGND				;vector base + $B8
ISR_EEPROM  		BGND				;vector base + $BA
ISR_SPI2      		BGND				;vector base + $BC
ISR_SPI1      		BGND				;vector base + $BE
ISR_IIC0      		BGND				;vector base + $C0
ISR_BDLC      		BGND				;vector base + $C2
ISR_SCM			BGND				;vector base + $C4
#ifdef	CLOCK_ISR					;vector base + $C6
ISR_PLLLOCK		EQU	CLOCK_ISR
#else
ISR_PLLLOCK		BGND
#endif
ISR_ECT_PBOV  		BGND				;vector base + $C8
ISR_ECT_MODCNT		BGND				;vector base + $CA
ISR_PORTH		BGND				;vector base + $CC
ISR_PORTJ		BGND				;vector base + $CC
ISR_ATD1		BGND				;vector base + $D0
ISR_ATD0		BGND				;vector base + $D2
ISR_SCI1		BGND				;vector base + $D4
#ifdef	SCI_ISR_RXTX					;vector base + $D6
ISR_SCI0		EQU	SCI_ISR_RXTX
#else
ISR_SCI0		BGND
#endif
ISR_SPI0		BGND				;vector base + $D8
ISR_ECT_PAIE		BGND				;vector base + $DA
ISR_ECT_PAOV		BGND				;vector base + $DC
ISR_ECT_TOV		BGND				;vector base + $DE
ISR_ECT_TC7		BGND				;vector base + $E0
ISR_ECT_TC6		BGND				;vector base + $E2
ISR_ECT_TC5		BGND				;vector base + $E4
ISR_ECT_TC4		BGND				;vector base + $E6
#ifdef	SCI_ISR_DELAY					;vector base + $E8
ISR_ECT_TC3		EQU	SCI_ISR_DELAY
#else
ISR_ECT_TC3		BGND
#endif
ISR_ECT_TC2		BGND				;vector base + $EA
ISR_ECT_TC1		BGND				;vector base + $EC
#ifdef	SCI_ISR_BD_NEPE					;vector base + $EE
ISR_ECT_TC0		EQU	SCI_ISR_BD_NEPE
#else
ISR_ECT_TC0		BGND
#endif
ISR_RTI			BGND				;vector base + $F0
ISR_IRQ			BGND				;vector base + $F2
ISR_XIRQ		BGND				;vector base + $F4
#ifdef	SCI_ISR_RXTX					;vector base + $F6
ISR_SWI			EQU	SCI_ISR_RXTX
#else
ISR_SWI			BGND
#endif
ISR_TRAP		BGND				;vector base + $F8
#else
ISR_RES80		EQU	VECTAB_ISR_ILLIRQ	;vector base + $80
ISR_RES82		EQU	VECTAB_ISR_ILLIRQ	;vector base + $82
ISR_RES84		EQU	VECTAB_ISR_ILLIRQ	;vector base + $84
ISR_RES86		EQU	VECTAB_ISR_ILLIRQ	;vector base + $86
ISR_RES88		EQU	VECTAB_ISR_ILLIRQ	;vector base + $88
ISR_RES8A		EQU	VECTAB_ISR_ILLIRQ	;vector base + $8A
ISR_PWMSDN 		EQU	VECTAB_ISR_ILLIRQ	;vector base + $8C
ISR_PORTP  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $8E
ISR_CAN4TX 		EQU	VECTAB_ISR_ILLIRQ	;vector base + $90
ISR_CAN4RX 		EQU	VECTAB_ISR_ILLIRQ	;vector base + $92
ISR_CAN4ERR		EQU	VECTAB_ISR_ILLIRQ	;vector base + $94
ISR_CAN4WUP		EQU	VECTAB_ISR_ILLIRQ	;vector base + $96
ISR_CAN3TX 		EQU	VECTAB_ISR_ILLIRQ	;vector base + $98
ISR_CAN3RX 		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9A
ISR_CAN3ERR		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9C
ISR_CAN3WUP		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9E
ISR_CAN2TX 		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A0
ISR_CAN2RX 		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A2
ISR_CAN2ERR		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A4
ISR_CAN2WUP		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A6
ISR_CAN1TX    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A8
ISR_CAN1RX    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AA
ISR_CAN1ERR   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AC
ISR_CAN1WUP   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AE
ISR_CAN0TX    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A0
ISR_CAN0RX    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B2
ISR_CAN0ERR   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B4
ISR_CAN0WUP   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B6
ISR_FLASH     		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B8
ISR_EEPROM  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BA
ISR_SPI2      		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BC
ISR_SPI1      		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BE
ISR_IIC0      		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C0
ISR_BDLC     		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C2
ISR_SCM			EQU	VECTAB_ISR_ILLIRQ	;vector base + $C4
#ifdef	CLOCK_ISR					;vector base + $C6
ISR_PLLLOCK		EQU	CLOCK_ISR
#else
ISR_PLLLOCK		EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_ECT_PBOV  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C8
ISR_ECT_MODCNT		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CA
ISR_PORTH		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CC
ISR_PORTJ		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CE
ISR_ATD1		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D0
ISR_ATD0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D2
ISR_SCI1		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D4
#ifdef	SCI_ISR_RXTX					;vector base + $D6
ISR_SCI0		EQU	SCI_ISR_RXTX
#else
ISR_SCI0		EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_SPI0		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D8
ISR_ECT_PAIE		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DA
ISR_ECT_PAOV		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DC
ISR_ECT_TOV		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DE
ISR_ECT_TC7		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E0
ISR_ECT_TC6		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E2
ISR_ECT_TC5		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E4
ISR_ECT_TC4		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E6
#ifdef	SCI_ISR_DELAY					;vector base + $E8
ISR_ECT_TC3		EQU	SCI_ISR_DELAY
#else
ISR_ECT_TC3		EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_ECT_TC2		EQU	VECTAB_ISR_ILLIRQ	;vector base + $EA
ISR_ECT_TC1		EQU	VECTAB_ISR_ILLIRQ	;vector base + $EC
#ifdef	SCI_ISR_BD_NEPE					;vector base + $EE
ISR_ECT_TC0		EQU	SCI_ISR_BD_NEPE
#else
ISR_ECT_TC0		EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_RTI			EQU	VECTAB_ISR_ILLIRQ	;vector base + $F0
ISR_IRQ			EQU	VECTAB_ISR_ILLIRQ	;vector base + $F2
ISR_XIRQ		EQU	VECTAB_ISR_ILLIRQ	;vector base + $F4
#ifdef	SCI_ISR_RXTX					;vector base + $F6
ISR_SWI			EQU	SCI_ISR_RXTX
#else
ISR_SWI			EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_TRAP		EQU	VECTAB_ISR_ILLIRQ	;vector base + $F8
#endif

;#Error message
VECTAB_MSG_ILLIRQ	FCS	"Unexpected interrupt"
			FLET16	VECTAB_MSG_ILLIRQ *-1
#endif
	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	
	
;###############################################################################
;# S12DP256 Vector Table                                                       #
;###############################################################################
			ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_RES80		DW	ISR_RES80	   	;vector base + $80
VEC_RES82		DW	ISR_RES82		;vector base + $82
VEC_RES84		DW	ISR_RES84		;vector base + $84
VEC_RES86		DW	ISR_RES86		;vector base + $86
VEC_RES88		DW	ISR_RES88		;vector base + $88
VEC_RES8A		DW	ISR_RES8A		;vector base + $8A
VEC_PWMSDN 		DW	ISR_PWMSDN 		;vector base + $8C
VEC_PORTP  		DW	ISR_PORTP  		;vector base + $8E
VEC_CAN4TX 		DW	ISR_CAN4TX 		;vector base + $90
VEC_CAN4RX 		DW	ISR_CAN4RX 		;vector base + $92
VEC_CAN4ERR		DW	ISR_CAN4ERR		;vector base + $94
VEC_CAN4WUP		DW	ISR_CAN4WUP		;vector base + $96
VEC_CAN3TX 		DW	ISR_CAN3TX 		;vector base + $98
VEC_CAN3RX 		DW	ISR_CAN3RX 		;vector base + $9A
VEC_CAN3ERR		DW	ISR_CAN3ERR		;vector base + $9C
VEC_CAN3WUP		DW	ISR_CAN3WUP		;vector base + $9E
VEC_CAN2TX 		DW	ISR_CAN2TX 		;vector base + $A0
VEC_CAN2RX 		DW	ISR_CAN2RX 		;vector base + $A2
VEC_CAN2ERR		DW	ISR_CAN2ERR		;vector base + $A4
VEC_CAN2WUP		DW	ISR_CAN2WUP		;vector base + $A6
VEC_CAN1TX    		DW	ISR_CAN1TX    		;vector base + $A8
VEC_CAN1RX    		DW	ISR_CAN1RX    		;vector base + $AA
VEC_CAN1ERR   		DW	ISR_CAN1ERR   		;vector base + $AC
VEC_CAN1WUP   		DW	ISR_CAN1WUP   		;vector base + $AE
VEC_CAN0TX    		DW	ISR_CAN0TX    		;vector base + $A0
VEC_CAN0RX    		DW	ISR_CAN0RX    		;vector base + $B2
VEC_CAN0ERR   		DW	ISR_CAN0ERR   		;vector base + $B4
VEC_CAN0WUP   		DW	ISR_CAN0WUP   		;vector base + $B6
VEC_FLASH     		DW	ISR_FLASH     		;vector base + $B8
VEC_EEPROM  		DW	ISR_EEPROM  		;vector base + $BA
VEC_SPI2      		DW	ISR_SPI2      		;vector base + $BC
VEC_SPI1      		DW	ISR_SPI1      		;vector base + $BE
VEC_IIC0      		DW	ISR_IIC0      		;vector base + $C0
VEC_BDLC     		DW	ISR_BDLC     		;vector base + $C2
VEC_SCM	      		DW	ISR_SCM	      	      	;vector base + $C4
VEC_PLLLOCK   		DW	ISR_PLLLOCK   		;vector base + $C6
VEC_ECT_PBOV  		DW	ISR_ECT_PBOV  		;vector base + $C8
VEC_ECT_MODCNT		DW	ISR_ECT_MODCNT		;vector base + $CA
VEC_PORTH		DW	ISR_PORTH		;vector base + $CC
VEC_PORTJ		DW	ISR_PORTJ		;vector base + $CE
VEC_ATD1		DW	ISR_ATD1		;vector base + $D0
VEC_ATD0		DW	ISR_ATD0		;vector base + $D2
VEC_SCI1		DW	ISR_SCI1		;vector base + $D4
VEC_SCI0		DW	ISR_SCI0		;vector base + $D6
VEC_SPI0		DW	ISR_SPI0		;vector base + $D8
VEC_ECT_PAIE		DW	ISR_ECT_PAIE		;vector base + $DA
VEC_ECT_PAOV		DW	ISR_ECT_PAOV		;vector base + $DC
VEC_ECT_TOV		DW	ISR_ECT_TOV		;vector base + $DE
VEC_ECT_TC7		DW	ISR_ECT_TC7		;vector base + $E0
VEC_ECT_TC6		DW	ISR_ECT_TC6		;vector base + $E2
VEC_ECT_TC5		DW	ISR_ECT_TC5		;vector base + $E4
VEC_ECT_TC4		DW	ISR_ECT_TC4		;vector base + $E6
VEC_ECT_TC3		DW	ISR_ECT_TC3		;vector base + $E8
VEC_ECT_TC2		DW	ISR_ECT_TC2		;vector base + $EA
VEC_ECT_TC1		DW	ISR_ECT_TC1		;vector base + $EC
VEC_ECT_TC0		DW	ISR_ECT_TC0		;vector base + $EE
VEC_RTI			DW	ISR_RTI			;vector base + $F0
VEC_IRQ			DW	ISR_IRQ			;vector base + $F2
VEC_XIRQ		DW	ISR_XIRQ		;vector base + $F4
VEC_SWI			DW	ISR_SWI			;vector base + $F6
VEC_TRAP		DW	ISR_TRAP		;vector base + $F8
VEC_RESET_COP		DW	RESET_COP_ENTRY		;vector base + $FA
VEC_RESET_CM		DW	RESET_CM_ENTRY 		;vector base + $FC
VEC_RESET_EXT		DW	RESET_EXT_ENTRY		;vector base + $FE
#endif
