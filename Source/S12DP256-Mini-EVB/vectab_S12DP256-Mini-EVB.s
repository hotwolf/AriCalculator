;###############################################################################
;# S12CBase - VECTAB - Vector Table (S12DP256-Mini-EVB)                        #
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
;#CLOCK
#ifndef	CLOCK_ISR
CLOCK_ISR		EQU	VECTAB_DUMMY_PLLLOCK
#endif

;#SCI
#ifndef	SCI_ISR_RXTX
SCI_ISR_RXTX		EQU	VECTAB_DUMMY_SCI0
#endif
#ifndef	SCI_ISR_BD_TOG
SCI_ISR_BD_TOG          EQU   	VECTAB_DUMMY_ECT_TC0
#endif
#ifndef	SCI_ISR_BD_TO
SCI_ISR_BD_TO		EQU	VECTAB_DUMMY_ECT_TC1
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
			MOVB	#(VECTAB_START>>8), IVBR
#endif
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
VECTAB_DUMMY_RES80	BGND					;vector base + $80
VECTAB_DUMMY_RES82   	BGND					;vector base + $82
VECTAB_DUMMY_RES84   	BGND					;vector base + $84
VECTAB_DUMMY_RES86   	BGND					;vector base + $86
VECTAB_DUMMY_RES88   	BGND					;vector base + $88
VECTAB_DUMMY_RES8A   	BGND					;vector base + $8A
VECTAB_DUMMY_PWMSDN 	BGND					;vector base + $8C
VECTAB_DUMMY_PORTP  	BGND					;vector base + $8E
VECTAB_DUMMY_CAN4TX 	BGND					;vector base + $90
VECTAB_DUMMY_CAN4RX 	BGND					;vector base + $92
VECTAB_DUMMY_CAN4ERR	BGND					;vector base + $94
VECTAB_DUMMY_CAN4WUP	BGND					;vector base + $96
VECTAB_DUMMY_CAN3TX 	BGND					;vector base + $98
VECTAB_DUMMY_CAN3RX 	BGND					;vector base + $9A
VECTAB_DUMMY_CAN3ERR	BGND					;vector base + $9C
VECTAB_DUMMY_CAN3WUP	BGND					;vector base + $9E
VECTAB_DUMMY_CAN2TX 	BGND					;vector base + $A0
VECTAB_DUMMY_CAN2RX 	BGND					;vector base + $A2
VECTAB_DUMMY_CAN2ERR	BGND					;vector base + $A4
VECTAB_DUMMY_CAN2WUP	BGND					;vector base + $A6
VECTAB_DUMMY_CAN1TX    	BGND					;vector base + $A8
VECTAB_DUMMY_CAN1RX    	BGND					;vector base + $AA
VECTAB_DUMMY_CAN1ERR   	BGND					;vector base + $AC
VECTAB_DUMMY_CAN1WUP   	BGND					;vector base + $AE
VECTAB_DUMMY_CAN0TX    	BGND					;vector base + $A0
VECTAB_DUMMY_CAN0RX    	BGND					;vector base + $B2
VECTAB_DUMMY_CAN0ERR   	BGND					;vector base + $B4
VECTAB_DUMMY_CAN0WUP   	BGND					;vector base + $B6
VECTAB_DUMMY_FLASH     	BGND					;vector base + $B8
VECTAB_DUMMY_EEPROM  	BGND					;vector base + $BA
VECTAB_DUMMY_SPI2      	BGND					;vector base + $BC
VECTAB_DUMMY_SPI1      	BGND					;vector base + $BE
VECTAB_DUMMY_IIC0      	BGND					;vector base + $C0
VECTAB_DUMMY_BDLC      	BGND					;vector base + $C2
VECTAB_DUMMY_SCM	BGND					;vector base + $C4
VECTAB_DUMMY_PLLLOCK	BGND					;vector base + $C6
VECTAB_DUMMY_ECT_PBOV  	BGND					;vector base + $C8
VECTAB_DUMMY_ECT_MODCNT	BGND					;vector base + $CA
VECTAB_DUMMY_PORTH	BGND					;vector base + $CC
VECTAB_DUMMY_PORTJ	BGND					;vector base + $CC
VECTAB_DUMMY_ATD1	BGND					;vector base + $D0
VECTAB_DUMMY_ATD0	BGND					;vector base + $D2
VECTAB_DUMMY_SCI1	BGND					;vector base + $D4
VECTAB_DUMMY_SCI0	BGND					;vector base + $D6
VECTAB_DUMMY_SPI0	BGND					;vector base + $D8
VECTAB_DUMMY_ECT_PAIE	BGND					;vector base + $DA
VECTAB_DUMMY_ECT_PAOV	BGND					;vector base + $DC
VECTAB_DUMMY_ECT_TOV	BGND					;vector base + $DE
VECTAB_DUMMY_ECT_TC7	BGND					;vector base + $E0
VECTAB_DUMMY_ECT_TC6	BGND					;vector base + $E2
VECTAB_DUMMY_ECT_TC5	BGND					;vector base + $E4
VECTAB_DUMMY_ECT_TC4	BGND					;vector base + $E6
VECTAB_DUMMY_ECT_TC3	BGND					;vector base + $E8
VECTAB_DUMMY_ECT_TC2	BGND					;vector base + $EA
VECTAB_DUMMY_ECT_TC1	BGND					;vector base + $EC
VECTAB_DUMMY_ECT_TC0	BGND					;vector base + $EE
VECTAB_DUMMY_RTI	BGND					;vector base + $F0
VECTAB_DUMMY_IRQ	BGND					;vector base + $F2
VECTAB_DUMMY_XIRQ	BGND					;vector base + $F4
VECTAB_DUMMY_SWI	BGND					;vector base + $F6
VECTAB_DUMMY_TRAP	BGND					;vector base + $F8
#else								
VECTAB_DUMMY_RES80	EQU	ERROR_ISR			;vector base + $80
VECTAB_DUMMY_RES82	EQU	ERROR_ISR			;vector base + $82
VECTAB_DUMMY_RES84	EQU	ERROR_ISR			;vector base + $84
VECTAB_DUMMY_RES86	EQU	ERROR_ISR			;vector base + $86
VECTAB_DUMMY_RES88	EQU	ERROR_ISR			;vector base + $88
VECTAB_DUMMY_RES8A	EQU	ERROR_ISR			;vector base + $8A
VECTAB_DUMMY_PWMSDN 	EQU	ERROR_ISR			;vector base + $8C
VECTAB_DUMMY_PORTP  	EQU	ERROR_ISR			;vector base + $8E
VECTAB_DUMMY_CAN4TX 	EQU	ERROR_ISR			;vector base + $90
VECTAB_DUMMY_CAN4RX 	EQU	ERROR_ISR			;vector base + $92
VECTAB_DUMMY_CAN4ERR	EQU	ERROR_ISR			;vector base + $94
VECTAB_DUMMY_CAN4WUP	EQU	ERROR_ISR			;vector base + $96
VECTAB_DUMMY_CAN3TX 	EQU	ERROR_ISR			;vector base + $98
VECTAB_DUMMY_CAN3RX 	EQU	ERROR_ISR			;vector base + $9A
VECTAB_DUMMY_CAN3ERR	EQU	ERROR_ISR			;vector base + $9C
VECTAB_DUMMY_CAN3WUP	EQU	ERROR_ISR			;vector base + $9E
VECTAB_DUMMY_CAN2TX 	EQU	ERROR_ISR			;vector base + $A0
VECTAB_DUMMY_CAN2RX 	EQU	ERROR_ISR			;vector base + $A2
VECTAB_DUMMY_CAN2ERR	EQU	ERROR_ISR			;vector base + $A4
VECTAB_DUMMY_CAN2WUP	EQU	ERROR_ISR			;vector base + $A6
VECTAB_DUMMY_CAN1TX    	EQU	ERROR_ISR			;vector base + $A8
VECTAB_DUMMY_CAN1RX    	EQU	ERROR_ISR			;vector base + $AA
VECTAB_DUMMY_CAN1ERR   	EQU	ERROR_ISR			;vector base + $AC
VECTAB_DUMMY_CAN1WUP   	EQU	ERROR_ISR			;vector base + $AE
VECTAB_DUMMY_CAN0TX    	EQU	ERROR_ISR			;vector base + $A0
VECTAB_DUMMY_CAN0RX    	EQU	ERROR_ISR			;vector base + $B2
VECTAB_DUMMY_CAN0ERR   	EQU	ERROR_ISR			;vector base + $B4
VECTAB_DUMMY_CAN0WUP   	EQU	ERROR_ISR			;vector base + $B6
VECTAB_DUMMY_FLASH     	EQU	ERROR_ISR			;vector base + $B8
VECTAB_DUMMY_EEPROM  	EQU	ERROR_ISR			;vector base + $BA
VECTAB_DUMMY_SPI2      	EQU	ERROR_ISR			;vector base + $BC
VECTAB_DUMMY_SPI1      	EQU	ERROR_ISR			;vector base + $BE
VECTAB_DUMMY_IIC0      	EQU	ERROR_ISR			;vector base + $C0
VECTAB_DUMMY_SBDLC     	EQU	ERROR_ISR			;vector base + $C2
VECTAB_DUMMY_SCM	EQU	ERROR_ISR			;vector base + $C4
VECTAB_DUMMY_PLLLOCK	EQU	ERROR_ISR			;vector base + $C6
VECTAB_DUMMY_ECT_PBOV  	EQU	ERROR_ISR			;vector base + $C8
VECTAB_DUMMY_ECT_MODCNT	EQU	ERROR_ISR			;vector base + $CA
VECTAB_DUMMY_PORTH	EQU	ERROR_ISR			;vector base + $CC
VECTAB_DUMMY_PORTJ	EQU	ERROR_ISR			;vector base + $CE
VECTAB_DUMMY_ATD1	EQU	ERROR_ISR			;vector base + $D0
VECTAB_DUMMY_ATD0	EQU	ERROR_ISR			;vector base + $D2
VECTAB_DUMMY_SCI1	EQU	ERROR_ISR			;vector base + $D4
VECTAB_DUMMY_SCI0	EQU	ERROR_ISR			;vector base + $D6
VECTAB_DUMMY_SPI0	EQU	ERROR_ISR			;vector base + $D8
VECTAB_DUMMY_ECT_PAIE	EQU	ERROR_ISR			;vector base + $DA
VECTAB_DUMMY_ECT_PAOV	EQU	ERROR_ISR			;vector base + $DC
VECTAB_DUMMY_ECT_TOV	EQU	ERROR_ISR			;vector base + $DE
VECTAB_DUMMY_ECT_TC7	EQU	ERROR_ISR			;vector base + $E0
VECTAB_DUMMY_ECT_TC6	EQU	ERROR_ISR			;vector base + $E2
VECTAB_DUMMY_ECT_TC5	EQU	ERROR_ISR			;vector base + $E4
VECTAB_DUMMY_ECT_TC4	EQU	ERROR_ISR			;vector base + $E6
VECTAB_DUMMY_ECT_TC3	EQU	ERROR_ISR			;vector base + $E8
VECTAB_DUMMY_ECT_TC2	EQU	ERROR_ISR			;vector base + $EA
VECTAB_DUMMY_ECT_TC1	EQU	ERROR_ISR			;vector base + $EC
VECTAB_DUMMY_ECT_TC0	EQU	ERROR_ISR			;vector base + $EE
VECTAB_DUMMY_RTI	EQU	ERROR_ISR			;vector base + $F0
VECTAB_DUMMY_IRQ	EQU	ERROR_ISR			;vector base + $F2
VECTAB_DUMMY_XIRQ	EQU	ERROR_ISR			;vector base + $F4
VECTAB_DUMMY_SWI	EQU	ERROR_ISR			;vector base + $F6
VECTAB_DUMMY_TRAP	EQU	ERROR_ISR			;vector base + $F8
#endif
	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	
	
;###############################################################################
;# S12XEP100 Vector Table                                                      #
;###############################################################################
			ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_RESERVED80		DW	VECTAB_DUMMY_RES80	   	;vector base + $80
VEC_RESERVED82		DW	VECTAB_DUMMY_RES82		;vector base + $82
VEC_RESERVED84		DW	VECTAB_DUMMY_RES84		;vector base + $84
VEC_RESERVED86		DW	VECTAB_DUMMY_RES86		;vector base + $86
VEC_RESERVED88		DW	VECTAB_DUMMY_RES88		;vector base + $88
VEC_RESERVED8A		DW	VECTAB_DUMMY_RES8A		;vector base + $8A
VEC_PWMSDN 		DW	VECTAB_DUMMY_PWMSDN 		;vector base + $8C
VEC_PORTP  		DW	VECTAB_DUMMY_PORTP  		;vector base + $8E
VEC_CAN4TX 		DW	VECTAB_DUMMY_CAN4TX 		;vector base + $90
VEC_CAN4RX 		DW	VECTAB_DUMMY_CAN4RX 		;vector base + $92
VEC_CAN4ERR		DW	VECTAB_DUMMY_CAN4ERR		;vector base + $94
VEC_CAN4WUP		DW	VECTAB_DUMMY_CAN4WUP		;vector base + $96
VEC_CAN3TX 		DW	VECTAB_DUMMY_CAN3TX 		;vector base + $98
VEC_CAN3RX 		DW	VECTAB_DUMMY_CAN3RX 		;vector base + $9A
VEC_CAN3ERR		DW	VECTAB_DUMMY_CAN3ERR		;vector base + $9C
VEC_CAN3WUP		DW	VECTAB_DUMMY_CAN3WUP		;vector base + $9E
VEC_CAN2TX 		DW	VECTAB_DUMMY_CAN2TX 		;vector base + $A0
VEC_CAN2RX 		DW	VECTAB_DUMMY_CAN2RX 		;vector base + $A2
VEC_CAN2ERR		DW	VECTAB_DUMMY_CAN2ERR		;vector base + $A4
VEC_CAN2WUP		DW	VECTAB_DUMMY_CAN2WUP		;vector base + $A6
VEC_CAN1TX    		DW	VECTAB_DUMMY_CAN1TX    		;vector base + $A8
VEC_CAN1RX    		DW	VECTAB_DUMMY_CAN1RX    		;vector base + $AA
VEC_CAN1ERR   		DW	VECTAB_DUMMY_CAN1ERR   		;vector base + $AC
VEC_CAN1WUP   		DW	VECTAB_DUMMY_CAN1WUP   		;vector base + $AE
VEC_CAN0TX    		DW	VECTAB_DUMMY_CAN0TX    		;vector base + $A0
VEC_CAN0RX    		DW	VECTAB_DUMMY_CAN0RX    		;vector base + $B2
VEC_CAN0ERR   		DW	VECTAB_DUMMY_CAN0ERR   		;vector base + $B4
VEC_CAN0WUP   		DW	VECTAB_DUMMY_CAN0WUP   		;vector base + $B6
VEC_FLASH     		DW	VECTAB_DUMMY_FLASH     		;vector base + $B8
VEC_EEPROM  		DW	VECTAB_DUMMY_FLASHFLT  		;vector base + $BA
VEC_SPI2      		DW	VECTAB_DUMMY_SPI2      		;vector base + $BC
VEC_SPI1      		DW	VECTAB_DUMMY_SPI1      		;vector base + $BE
VEC_IIC0      		DW	VECTAB_DUMMY_IIC0      		;vector base + $C0
VEC_BDLC     		DW	VECTAB_DUMMY_BDLC      		;vector base + $C2
VEC_SCM	      		DW	VECTAB_DUMMY_SCM	      	;vector base + $C4
VEC_PLLLOCK   		DW	CLOCK_ISR	  		;vector base + $C6
VEC_ECT_PBOV  		DW	VECTAB_DUMMY_ECT_PBOV  		;vector base + $C8
VEC_ECT_MODCNT		DW	VECTAB_DUMMY_ECT_MODCNT		;vector base + $CA
VEC_PORTH		DW	VECTAB_DUMMY_PORTH		;vector base + $CC
VEC_PORTJ		DW	VECTAB_DUMMY_PORTJ		;vector base + $CE
VEC_ATD1		DW	VECTAB_DUMMY_ATD1		;vector base + $D0
VEC_ATD0		DW	VECTAB_DUMMY_ATD0		;vector base + $D2
VEC_SCI1		DW	VECTAB_DUMMY_SCI1		;vector base + $D4
VEC_SCI0		DW	SCI_ISR_RXTX			;vector base + $D6
VEC_SPI0		DW	VECTAB_DUMMY_SPI0		;vector base + $D8
VEC_ECT_PAIE		DW	VECTAB_DUMMY_ECT_PAIE		;vector base + $DA
VEC_ECT_PAOV		DW	VECTAB_DUMMY_ECT_PAOV		;vector base + $DC
VEC_ECT_TOV		DW	VECTAB_DUMMY_ECT_TOV		;vector base + $DE
VEC_ECT_TC7		DW	VECTAB_DUMMY_ECT_TC7		;vector base + $E0
VEC_ECT_TC6		DW	VECTAB_DUMMY_ECT_TC6		;vector base + $E2
VEC_ECT_TC5		DW	VECTAB_DUMMY_ECT_TC5		;vector base + $E4
VEC_ECT_TC4		DW	VECTAB_DUMMY_ECT_TC4		;vector base + $E6
VEC_ECT_TC3		DW	VECTAB_DUMMY_ECT_TC3		;vector base + $E8
VEC_ECT_TC2		DW	VECTAB_DUMMY_ECT_TC2		;vector base + $EA
VEC_ECT_TC1		DW	SCI_ISR_BD_TO			;vector base + $EC
VEC_ECT_TC0		DW	SCI_ISR_BD_TOG			;vector base + $EE
VEC_RTI			DW	VECTAB_DUMMY_RTI		;vector base + $F0
VEC_IRQ			DW	VECTAB_DUMMY_IRQ		;vector base + $F2
VEC_XIRQ		DW	VECTAB_DUMMY_XIRQ		;vector base + $F4
VEC_SWI			DW	VECTAB_DUMMY_SWI		;vector base + $F6
VEC_TRAP		DW	VECTAB_DUMMY_TRAP		;vector base + $F8
VEC_RESET_COP		DW	ERROR_RESET_COP			;vector base + $FA
VEC_RESET_CM		DW	ERROR_RESET_CM			;vector base + $FC
VEC_RESET_EXT		DW	ERROR_RESET_EXT			;vector base + $FE
