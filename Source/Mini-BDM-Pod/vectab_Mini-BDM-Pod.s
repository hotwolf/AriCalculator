#ifndef	VECTAB_COMPILED
#define	VECTAB_COMPILED
;###############################################################################
;# S12CBase - VECTAB - Vector Table (Mini-BDM-Pod)                             #
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
;#    This module defines the static vector table of the OpenBDC firmware.     #
;#    Unexpected inerrupts are cought and trigger a fatal error in the reset   #
;#    handler.                                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    CLOCK  - Clock handler                                                   #
;#    SCI    - UART driver                                                     #
;#    LED    - LED driver                                                      #
;#    DELAY  - Delay driver                                                    #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    December 14, 2011                                                        #
;#      - Initial release                                                      #
;#    July 31, 2012                                                            #
;#      - Added support for linear PC                                          #
;#      - Added dummy vectors                                                  #
;#    November 16, 2012                                                        #
;#      - Restructured table                                                   #
;#    June 12, 2013                                                            #
;#      - Added ECC error interrupt                                            #
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
#ifdef	MMAP_RAM
			;Set vector base address
			MOVB	#(VECTAB_START>>8), IVBR
#endif
			;Disable XGATE interrupts
			CLR	XGPRIO
#ifdef	SCI_ISR_IC
			;Give TC0 high priority
			MOVB	#(VEC_ECT_TC0&$F0), CFADDR
			MOVB	#$07, (CFDATA0+((VEC_ECT_TC0&$000E)>>1))
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
ISR_SPURIOUS  		BGND				;vector base + $10
ISR_SYS			BGND				;vector base + $12
ISR_MPU			BGND				;vector base + $14
ISR_XGSWE     		BGND				;vector base + $16
ISR_RES18		BGND				;vector base + $18
ISR_RES1A		BGND				;vector base + $1A
ISR_RES1C		BGND				;vector base + $1C
ISR_RES1E		BGND				;vector base + $1E
ISR_RES20		BGND				;vector base + $20
ISR_RES22		BGND				;vector base + $22
ISR_RES24		BGND				;vector base + $24
ISR_RES26		BGND				;vector base + $26
ISR_RES28		BGND				;vector base + $28
ISR_RES2A		BGND				;vector base + $2A
ISR_RES2C		BGND				;vector base + $2C
ISR_RES2E		BGND				;vector base + $2E
ISR_RES30		BGND				;vector base + $30
ISR_RES32		BGND				;vector base + $32
ISR_RES34		BGND				;vector base + $34
ISR_RES36		BGND				;vector base + $36
ISR_RES38		BGND				;vector base + $38
ISR_RES3A		BGND				;vector base + $3A
ISR_ATD1COMP  		BGND				;vector base + $3C
#ifdef	TVMON_ISR					;vector base + $3E
ISR_ATD0COMP		EQU	TVMON_ISR
#else
ISR_ATD0COMP		BGND
#endif
ISR_TIM_PAIE  		BGND				;vector base + $40
ISR_TIM_PAOV  		BGND				;vector base + $42
ISR_TIM_TOV   		BGND				;vector base + $44
ISR_TIM_TC7   		BGND				;vector base + $46
ISR_TIM_TC6   		BGND				;vector base + $48
ISR_TIM_TC5   		BGND				;vector base + $4A
ISR_TIM_TC4   		BGND				;vector base + $4C
ISR_TIM_TC3   		BGND				;vector base + $4E
ISR_TIM_TC2   		BGND				;vector base + $50
ISR_TIM_TC1   		BGND				;vector base + $52
ISR_TIM_TC0   		BGND				;vector base + $54
ISR_SCI7      		BGND				;vector base + $56
ISR_PITCH7    		BGND				;vector base + $58
ISR_PITCH6    		BGND				;vector base + $5A
ISR_PITCH5    		BGND				;vector base + $5C
ISR_PITCH4    		BGND				;vector base + $5E
ISR_RES60		BGND				;vector base + $60
ISR_RES62		BGND				;vector base + $62
ISR_XGSWT7 		BGND				;vector base + $64
ISR_XGSWT6 		BGND				;vector base + $66
ISR_XGSWT5 		BGND				;vector base + $68
ISR_XGSWT4 		BGND				;vector base + $6A
ISR_XGSWT3 		BGND				;vector base + $6C
ISR_XGSWT2 		BGND				;vector base + $6E
ISR_XGSWT1 		BGND				;vector base + $70
ISR_XGSWT0 		BGND				;vector base + $72
ISR_PITCH3 		BGND				;vector base + $74
ISR_PITCH2 		BGND				;vector base + $76
ISR_PITCH1 		BGND				;vector base + $78
ISR_PITCH0 		BGND				;vector base + $7A
ISR_HT	   		BGND				;vector base + $7C
ISR_API			BGND				;vector base + $7E
ISR_LVI			BGND				;vector base + $80
ISR_IIC1   		BGND				;vector base + $82
ISR_SCI5   		BGND				;vector base + $84
ISR_SCI4   		BGND				;vector base + $86
ISR_SCI3   		BGND				;vector base + $88
ISR_SCI2   		BGND				;vector base + $8A
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
#ifdef	NVM_ISR_ECCERR					;vector base + $BA
ISR_FLASHFLT  		EQU	NVM_ISR_ECCERR
#else
ISR_FLASHFLT  		BGND
#endif
ISR_SPI2      		BGND				;vector base + $BC
ISR_SPI1      		BGND				;vector base + $BE
ISR_IIC0      		BGND				;vector base + $C0
ISR_SCI6      		BGND				;vector base + $C2
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
#ifdef	LED_ISR						;vector base + $E8
ISR_ECT_TC3		EQU	LED_ISR
#else
ISR_ECT_TC3		BGND
#endif
#ifdef	DELAY_ISR					;vector base + $EA
ISR_ECT_TC2		EQU	DELAY_ISR
#else
ISR_ECT_TC2		BGND
#endif
#ifdef	SCI_ISR_OC					;vector base + $EC
ISR_ECT_TC1		EQU	SCI_ISR_OC
#else
ISR_ECT_TC1		BGND
#endif
#ifdef	SCI_ISR_IC					;vector base + $EE
ISR_ECT_TC0		EQU	SCI_ISR_IC
#else
ISR_ECT_TC0		BGND
#endif
ISR_RTI			BGND				;vector base + $F0
ISR_IRQ			BGND				;vector base + $F2
ISR_XIRQ		BGND				;vector base + $F4
ISR_SWI			BGND				;vector base + $F6
ISR_TRAP		BGND				;vector base + $F8
#else							
ISR_SPURIOUS  		EQU	RESET_ISR_FATAL		;vector base + $10
ISR_SYS			EQU	RESET_ISR_FATAL		;vector base + $12
ISR_MPU			EQU	MMAP_IRQ_MPU		;vector base + $14
ISR_XGSWE     		EQU	RESET_ISR_FATAL		;vector base + $16
ISR_RES18		EQU	RESET_ISR_FATAL		;vector base + $18
ISR_RES1A		EQU	RESET_ISR_FATAL		;vector base + $1A
ISR_RES1C		EQU	RESET_ISR_FATAL		;vector base + $1C
ISR_RES1E		EQU	RESET_ISR_FATAL		;vector base + $1E
ISR_RES20		EQU	RESET_ISR_FATAL		;vector base + $20
ISR_RES22		EQU	RESET_ISR_FATAL		;vector base + $22
ISR_RES24		EQU	RESET_ISR_FATAL		;vector base + $24
ISR_RES26		EQU	RESET_ISR_FATAL		;vector base + $26
ISR_RES28		EQU	RESET_ISR_FATAL		;vector base + $28
ISR_RES2A		EQU	RESET_ISR_FATAL		;vector base + $2A
ISR_RES2C		EQU	RESET_ISR_FATAL		;vector base + $2C
ISR_RES2E		EQU	RESET_ISR_FATAL		;vector base + $2E
ISR_RES30		EQU	RESET_ISR_FATAL		;vector base + $30
ISR_RES32		EQU	RESET_ISR_FATAL		;vector base + $32
ISR_RES34		EQU	RESET_ISR_FATAL		;vector base + $34
ISR_RES36		EQU	RESET_ISR_FATAL		;vector base + $36
ISR_RES38		EQU	RESET_ISR_FATAL		;vector base + $38
ISR_RES3A		EQU	RESET_ISR_FATAL		;vector base + $3A
ISR_ATD1COMP  		EQU	RESET_ISR_FATAL		;vector base + $3C
#ifdef	TVMON_ISR					;vector base + $3E
ISR_ATD0COMP		EQU	TVMON_ISR
#else
ISR_ATD0COMP		EQU	RESET_ISR_FATAL
#endif
ISR_TIM_PAIE  		EQU	RESET_ISR_FATAL		;vector base + $40
ISR_TIM_PAOV  		EQU	RESET_ISR_FATAL		;vector base + $42
ISR_TIM_TOV   		EQU	RESET_ISR_FATAL		;vector base + $44
ISR_TIM_TC7   		EQU	RESET_ISR_FATAL		;vector base + $46
ISR_TIM_TC6   		EQU	RESET_ISR_FATAL		;vector base + $48
ISR_TIM_TC5   		EQU	RESET_ISR_FATAL		;vector base + $4A
ISR_TIM_TC4   		EQU	RESET_ISR_FATAL		;vector base + $4C
ISR_TIM_TC3   		EQU	RESET_ISR_FATAL		;vector base + $4E
ISR_TIM_TC2   		EQU	RESET_ISR_FATAL		;vector base + $50
ISR_TIM_TC1   		EQU	RESET_ISR_FATAL		;vector base + $52
ISR_TIM_TC0   		EQU	RESET_ISR_FATAL		;vector base + $54
ISR_SCI7      		EQU	RESET_ISR_FATAL		;vector base + $56
ISR_PITCH7    		EQU	RESET_ISR_FATAL		;vector base + $58
ISR_PITCH6    		EQU	RESET_ISR_FATAL		;vector base + $5A
ISR_PITCH5    		EQU	RESET_ISR_FATAL		;vector base + $5C
ISR_PITCH4    		EQU	RESET_ISR_FATAL		;vector base + $5E
ISR_RES60		EQU	RESET_ISR_FATAL		;vector base + $60
ISR_RES62		EQU	RESET_ISR_FATAL		;vector base + $62
ISR_XGSWT7 		EQU	RESET_ISR_FATAL		;vector base + $64
ISR_XGSWT6 		EQU	RESET_ISR_FATAL		;vector base + $66
ISR_XGSWT5 		EQU	RESET_ISR_FATAL		;vector base + $68
ISR_XGSWT4 		EQU	RESET_ISR_FATAL		;vector base + $6A
ISR_XGSWT3 		EQU	RESET_ISR_FATAL		;vector base + $6C
ISR_XGSWT2 		EQU	RESET_ISR_FATAL		;vector base + $6E
ISR_XGSWT1 		EQU	RESET_ISR_FATAL		;vector base + $70
ISR_XGSWT0 		EQU	RESET_ISR_FATAL		;vector base + $72
ISR_PITCH3 		EQU	RESET_ISR_FATAL		;vector base + $74
ISR_PITCH2 		EQU	RESET_ISR_FATAL		;vector base + $76
ISR_PITCH1 		EQU	RESET_ISR_FATAL		;vector base + $78
ISR_PITCH0 		EQU	RESET_ISR_FATAL		;vector base + $7A
ISR_HT	   		EQU	RESET_ISR_FATAL		;vector base + $7C
ISR_API			EQU	RESET_ISR_FATAL		;vector base + $7E
ISR_LVI			EQU	RESET_ISR_FATAL		;vector base + $80
ISR_IIC1   		EQU	RESET_ISR_FATAL		;vector base + $82
ISR_SCI5   		EQU	RESET_ISR_FATAL		;vector base + $84
ISR_SCI4   		EQU	RESET_ISR_FATAL		;vector base + $86
ISR_SCI3   		EQU	RESET_ISR_FATAL		;vector base + $88
ISR_SCI2   		EQU	RESET_ISR_FATAL		;vector base + $8A
ISR_PWMSDN 		EQU	RESET_ISR_FATAL		;vector base + $8C
ISR_PORTP  		EQU	RESET_ISR_FATAL		;vector base + $8E
ISR_CAN4TX 		EQU	RESET_ISR_FATAL		;vector base + $90
ISR_CAN4RX 		EQU	RESET_ISR_FATAL		;vector base + $92
ISR_CAN4ERR		EQU	RESET_ISR_FATAL		;vector base + $94
ISR_CAN4WUP		EQU	RESET_ISR_FATAL		;vector base + $96
ISR_CAN3TX 		EQU	RESET_ISR_FATAL		;vector base + $98
ISR_CAN3RX 		EQU	RESET_ISR_FATAL		;vector base + $9A
ISR_CAN3ERR		EQU	RESET_ISR_FATAL		;vector base + $9C
ISR_CAN3WUP		EQU	RESET_ISR_FATAL		;vector base + $9E
ISR_CAN2TX 		EQU	RESET_ISR_FATAL		;vector base + $A0
ISR_CAN2RX 		EQU	RESET_ISR_FATAL		;vector base + $A2
ISR_CAN2ERR		EQU	RESET_ISR_FATAL		;vector base + $A4
ISR_CAN2WUP		EQU	RESET_ISR_FATAL		;vector base + $A6
ISR_CAN1TX    		EQU	RESET_ISR_FATAL		;vector base + $A8
ISR_CAN1RX    		EQU	RESET_ISR_FATAL		;vector base + $AA
ISR_CAN1ERR   		EQU	RESET_ISR_FATAL		;vector base + $AC
ISR_CAN1WUP   		EQU	RESET_ISR_FATAL		;vector base + $AE
ISR_CAN0TX    		EQU	RESET_ISR_FATAL		;vector base + $A0
ISR_CAN0RX    		EQU	RESET_ISR_FATAL		;vector base + $B2
ISR_CAN0ERR   		EQU	RESET_ISR_FATAL		;vector base + $B4
ISR_CAN0WUP   		EQU	RESET_ISR_FATAL		;vector base + $B6
ISR_FLASH     		EQU	RESET_ISR_FATAL		;vector base + $B8
#ifdef	NVM_ISR_ECCERR					;vector base + $BA
ISR_FLASHFLT  		EQU	NVM_ISR_ECCERR
#else
ISR_FLASHFLT  		EQU	RESET_ISR_FATAL
#endif
ISR_SPI2      		EQU	RESET_ISR_FATAL		;vector base + $BC
ISR_SPI1      		EQU	RESET_ISR_FATAL		;vector base + $BE
ISR_IIC0      		EQU	RESET_ISR_FATAL		;vector base + $C0
ISR_SCI6      		EQU	RESET_ISR_FATAL		;vector base + $C2
ISR_SCM			EQU	RESET_ISR_FATAL		;vector base + $C4
#ifdef	CLOCK_ISR					;vector base + $C6
ISR_PLLLOCK		EQU	CLOCK_ISR
#else
ISR_PLLLOCK		EQU	RESET_ISR_FATAL
#endif
ISR_ECT_PBOV  		EQU	RESET_ISR_FATAL		;vector base + $C8
ISR_ECT_MODCNT		EQU	RESET_ISR_FATAL		;vector base + $CA
ISR_PORTH		EQU	RESET_ISR_FATAL		;vector base + $CC
ISR_PORTJ		EQU	RESET_ISR_FATAL		;vector base + $CE
ISR_ATD1		EQU	RESET_ISR_FATAL		;vector base + $D0
ISR_ATD0		EQU	RESET_ISR_FATAL		;vector base + $D2
ISR_SCI1		EQU	RESET_ISR_FATAL		;vector base + $D4
#ifdef	SCI_ISR_RXTX					;vector base + $D6
ISR_SCI0		EQU	SCI_ISR_RXTX
#else
ISR_SCI0		EQU	RESET_ISR_FATAL
#endif
ISR_SPI0		EQU	RESET_ISR_FATAL		;vector base + $D8
ISR_ECT_PAIE		EQU	RESET_ISR_FATAL		;vector base + $DA
ISR_ECT_PAOV		EQU	RESET_ISR_FATAL		;vector base + $DC
ISR_ECT_TOV		EQU	RESET_ISR_FATAL		;vector base + $DE
ISR_ECT_TC7		EQU	RESET_ISR_FATAL		;vector base + $E0
ISR_ECT_TC6		EQU	RESET_ISR_FATAL		;vector base + $E2
ISR_ECT_TC5		EQU	RESET_ISR_FATAL		;vector base + $E4
ISR_ECT_TC4		EQU	RESET_ISR_FATAL		;vector base + $E6
#ifdef	LED_ISR						;vector base + $E8
ISR_ECT_TC3		EQU	LED_ISR
#else
ISR_ECT_TC3		EQU	RESET_ISR_FATAL
#endif
#ifdef	DELAY_ISR					;vector base + $EA
ISR_ECT_TC2		EQU	DELAY_ISR
#else
ISR_ECT_TC2		EQU	RESET_ISR_FATAL
#endif
#ifdef	SCI_ISR_OC					;vector base + $EC
ISR_ECT_TC1		EQU	SCI_ISR_OC
#else
ISR_ECT_TC1		EQU	RESET_ISR_FATAL
#endif
#ifdef	SCI_ISR_IC					;vector base + $EE
ISR_ECT_TC0		EQU	SCI_ISR_IC
#else
ISR_ECT_TC0		EQU	RESET_ISR_FATAL
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
RES_COP			EQU	RESET_COP_EXT
#else
RES_COP			EQU	RES_EXT
#endif
#ifdef	ERROR_RESET_CM					;vector base + $FC
RES_CM			EQU	RESET_CM_EXT
#else
RES_CM			EQU	RES_EXT
#endif
#ifdef	ERROR_RESET_EXT					;vector base + $FE
RES_EXT			EQU	RESET_COP_EXT
#else
RES_EXT			EQU	START_OF_CODE
#endif
	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	
	
;###############################################################################
;# S12XEP100 Vector Table                                                      #
;###############################################################################
			ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_SPURIOUS  		DW	ISR_SPURIOUS  		;vector base + $10
VEC_SYS	      		DW	ISR_SYS	      	      	;vector base + $12
VEC_MPU	      		DW	ISR_MPU	      	      	;vector base + $14
VEC_XGSWE     		DW	ISR_XGSWE     		;vector base + $16
VEC_RES18		DW	ISR_RES18		;vector base + $18
VEC_RES1A		DW	ISR_RES1A		;vector base + $1A
VEC_RES1C		DW	ISR_RES1C		;vector base + $1C
VEC_RES1E		DW	ISR_RES1E		;vector base + $1E
VEC_RES20		DW	ISR_RES20		;vector base + $20
VEC_RES22		DW	ISR_RES22		;vector base + $22
VEC_RES24		DW	ISR_RES24		;vector base + $24
VEC_RES26		DW	ISR_RES26		;vector base + $26
VEC_RES28		DW	ISR_RES28		;vector base + $28
VEC_RES2A		DW	ISR_RES2A		;vector base + $2A
VEC_RES2C		DW	ISR_RES2C		;vector base + $2C
VEC_RES2E		DW	ISR_RES2E		;vector base + $2E
VEC_RES30		DW	ISR_RES30		;vector base + $30
VEC_RES32		DW	ISR_RES32		;vector base + $32
VEC_RES34		DW	ISR_RES34		;vector base + $34
VEC_RES36		DW	ISR_RES36		;vector base + $36
VEC_RES38		DW	ISR_RES38		;vector base + $38
VEC_RES3A		DW	ISR_RES3A		;vector base + $3A
VEC_ATD1COMP  		DW	ISR_ATD1COMP  		;vector base + $3C
VEC_ATD0COMP  		DW	ISR_ATD0COMP  		;vector base + $3E
VEC_TIM_PAIE  		DW	ISR_TIM_PAIE  		;vector base + $40
VEC_TIM_PAOV  		DW	ISR_TIM_PAOV  		;vector base + $42
VEC_TIM_TOV   		DW	ISR_TIM_TOV   		;vector base + $44
VEC_TIM_TC7   		DW	ISR_TIM_TC7   		;vector base + $46
VEC_TIM_TC6   		DW	ISR_TIM_TC6   		;vector base + $48
VEC_TIM_TC5   		DW	ISR_TIM_TC5   		;vector base + $4A
VEC_TIM_TC4   		DW	ISR_TIM_TC4   		;vector base + $4C
VEC_TIM_TC3   		DW	ISR_TIM_TC3   		;vector base + $4E
VEC_TIM_TC2   		DW	ISR_TIM_TC2   		;vector base + $50
VEC_TIM_TC1   		DW	ISR_TIM_TC1   		;vector base + $52
VEC_TIM_TC0   		DW	ISR_TIM_TC0   		;vector base + $54
VEC_SCI7      		DW	ISR_SCI7      		;vector base + $56
VEC_PITCH7    		DW	ISR_PITCH7    		;vector base + $58
VEC_PITCH6    		DW	ISR_PITCH6    		;vector base + $5A
VEC_PITCH5    		DW	ISR_PITCH5    		;vector base + $5C
VEC_PITCH4    		DW	ISR_PITCH4    		;vector base + $5E
VEC_RES60		DW	ISR_RES60		;vector base + $60
VEC_RES62		DW	ISR_RES62		;vector base + $62
VEC_XGSWT7 		DW	ISR_XGSWT7 		;vector base + $64
VEC_XGSWT6 		DW	ISR_XGSWT6 		;vector base + $66
VEC_XGSWT5 		DW	ISR_XGSWT5 		;vector base + $68
VEC_XGSWT4 		DW	ISR_XGSWT4 		;vector base + $6A
VEC_XGSWT3 		DW	ISR_XGSWT3 		;vector base + $6C
VEC_XGSWT2 		DW	ISR_XGSWT2 		;vector base + $6E
VEC_XGSWT1 		DW	ISR_XGSWT1 		;vector base + $70
VEC_XGSWT0 		DW	ISR_XGSWT0 		;vector base + $72
VEC_PITCH3 		DW	ISR_PITCH3 		;vector base + $74
VEC_PITCH2 		DW	ISR_PITCH2 		;vector base + $76
VEC_PITCH1 		DW	ISR_PITCH1 		;vector base + $78
VEC_PITCH0 		DW	ISR_PITCH0 		;vector base + $7A
VEC_HT	   		DW	ISR_HT	   		;vector base + $7C
VEC_API	   		DW	ISR_API	   	   	;vector base + $7E
VEC_LVI	   		DW	ISR_LVI	   	   	;vector base + $80
VEC_IIC1   		DW	ISR_IIC1   		;vector base + $82
VEC_SCI5   		DW	ISR_SCI5   		;vector base + $84
VEC_SCI4   		DW	ISR_SCI4   		;vector base + $86
VEC_SCI3   		DW	ISR_SCI3   		;vector base + $88
VEC_SCI2   		DW	ISR_SCI2   		;vector base + $8A
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
VEC_FLASHFLT  		DW	ISR_FLASHFLT  		;vector base + $BA
VEC_SPI2      		DW	ISR_SPI2      		;vector base + $BC
VEC_SPI1      		DW	ISR_SPI1      		;vector base + $BE
VEC_IIC0      		DW	ISR_IIC0      		;vector base + $C0
VEC_SCI6      		DW	ISR_SCI6      		;vector base + $C2
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
VEC_RESET_COP		DW	RES_COP			;vector base + $FA
VEC_RESET_CM		DW	RES_CM			;vector base + $FC
VEC_RESET_EXT		DW	RES_EXT			;vector base + $FE
#endif
