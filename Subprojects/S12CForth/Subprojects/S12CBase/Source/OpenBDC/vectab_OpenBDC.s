#ifndef	VECTAB
#define	VECTAB
;###############################################################################
;# S12CBase - VECTAB - Vector Table (OpenBDC)                                  #
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
;#    RESET  - Reset handler                                                   #
;#    CLOCK  - Clock handler                                                   #
;#    SCI    - UART driver                                                     #
;#    LED    - LED driver                                                      #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    July 9, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added dummy vectors                                                  #
;#    July 31, 2012                                                            #
;#      - Moved vector table to table section                                  #
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
#ifdef	SCI_ISR_BD_PE
			;Give SCI_ISR_BD_PE high priority 
			MOVB	#(VEC_TIM_TC0&$FF), HPRIO	
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
VECTAB_VARS_START_LIN	EQU	@			
#endif	

;#Interrupt service routines
;#--------------------------
#ifdef VECTAB_DEBUG
ISR_RES80   		BGND				;vector base + $80
ISR_RES82   		BGND				;vector base + $82
ISR_RES84   		BGND				;vector base + $84
ISR_RES86   		BGND				;vector base + $86
ISR_RES88   		BGND				;vector base + $88
ISR_LVI     		BGND      			;vector base + $8A
ISR_PWM     		BGND      			;vector base + $8C
ISR_PORTP   		BGND				;vector base + $8E
ISR_RES90   		BGND				;vector base + $90
ISR_RES92   		BGND				;vector base + $92
ISR_RES94   		BGND				;vector base + $94
ISR_RES96   		BGND				;vector base + $96
ISR_RES98   		BGND				;vector base + $98
ISR_RES9A   		BGND				;vector base + $9A
ISR_RES9C   		BGND				;vector base + $9C
ISR_RES9E   		BGND				;vector base + $9E
ISR_RESA0   		BGND				;vector base + $A0
ISR_RESA2   		BGND				;vector base + $A2
ISR_RESA4   		BGND				;vector base + $A4
ISR_RESA6   		BGND				;vector base + $A6
ISR_RESA8   		BGND				;vector base + $A8
ISR_RESAA   		BGND				;vector base + $AA
ISR_RESAC   		BGND				;vector base + $AC
ISR_RESAE   		BGND				;vector base + $AE
ISR_CANTX   		BGND				;vector base + $A0
ISR_CANRX   		BGND				;vector base + $B2
ISR_CANERR  		BGND				;vector base + $B4
ISR_CANWUP  		BGND				;vector base + $B6
ISR_FLASH   		BGND				;vector base + $B8
ISR_RESBA   		BGND				;vector base + $BA
ISR_RESBC   		BGND				;vector base + $BC
ISR_RESBE   		BGND				;vector base + $BE
ISR_RESC0   		BGND				;vector base + $C0
ISR_RESC2   		BGND				;vector base + $C2
ISR_SCM     		BGND      			;vector base + $C4
#ifdef	CLOCK_ISR					;vector base + $C6
ISR_PLLLOCK		EQU	CLOCK_ISR
#else
ISR_PLLLOCK		BGND
#endif
ISR_RESC8  		BGND				;vector base + $C8
ISR_RESCA  		BGND				;vector base + $CA
ISR_RESCC  		BGND				;vector base + $CC
ISR_PORTJ  		BGND				;vector base + $CC
ISR_RESD0  		BGND				;vector base + $D0
ISR_ATD    		BGND				;vector base + $D2
ISR_RESD4  		BGND				;vector base + $D4
#ifdef	SCI_ISR_RXTX					;vector base + $D6
ISR_SCI			EQU	SCI_ISR_RXTX
#else
ISR_SCI			BGND
#endif
ISR_SPI    		BGND				;vector base + $D8
ISR_TIM_PAIE   		BGND				;vector base + $DA
ISR_TIM_PAOV   		BGND				;vector base + $DC
ISR_TIM_TOV    		BGND				;vector base + $DE
ISR_TIM_TC7    		BGND				;vector base + $E0
ISR_TIM_TC6    		BGND				;vector base + $E2
ISR_TIM_TC5    		BGND				;vector base + $E4
ISR_TIM_TC4    		BGND				;vector base + $E6
#ifdef	SCI_ISR_DELAY					;vector base + $E8
ISR_TIM_TC3		EQU	SCI_ISR_DELAY
#else
ISR_TIM_TC3		BGND
#endif
ISR_TIM_TC2    		BGND				;vector base + $EA
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
#ifdef	LED_ISR						;vector base + $F0
ISR_RTI			EQU	LED_ISR
#else
ISR_RTI			BGND
#endif
ISR_IRQ    		BGND				;vector base + $F2
ISR_XIRQ   		BGND				;vector base + $F4
ISR_SWI    		BGND				;vector base + $F6
ISR_TRAP   		BGND				;vector base + $F8
#else
ISR_RES80   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $80
ISR_RES82   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $82
ISR_RES84   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $84
ISR_RES86   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $86
ISR_RES88   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $88
ISR_LVI     		EQU	VECTAB_ISR_ILLIRQ      	;vector base + $8A
ISR_PWM     		EQU	VECTAB_ISR_ILLIRQ      	;vector base + $8C
ISR_PORTP   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $8E
ISR_RES90   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $90
ISR_RES92   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $92
ISR_RES94   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $94
ISR_RES96   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $96
ISR_RES98   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $98
ISR_RES9A   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9A
ISR_RES9C   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9C
ISR_RES9E   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $9E
ISR_RESA0   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A0
ISR_RESA2   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A2
ISR_RESA4   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A4
ISR_RESA6   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A6
ISR_RESA8   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A8
ISR_RESAA   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AA
ISR_RESAC   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AC
ISR_RESAE   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $AE
ISR_CANTX   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $A0
ISR_CANRX   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B2
ISR_CANERR  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B4
ISR_CANWUP  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B6
ISR_FLASH   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $B8
ISR_RESBA   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BA
ISR_RESBC   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BC
ISR_RESBE   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $BE
ISR_RESC0   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C0
ISR_RESC2   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C2
ISR_SCM     		EQU	VECTAB_ISR_ILLIRQ      	;vector base + $C4
#ifdef	CLOCK_ISR					;vector base + $C6
ISR_PLLLOCK		EQU	CLOCK_ISR
#else
ISR_PLLLOCK		BGND
#endif
ISR_RESC8  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $C8
ISR_RESCA  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CA
ISR_RESCC  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CC
ISR_PORTJ  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $CC
ISR_RESD0  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D0
ISR_ATD    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D2
ISR_RESD4  		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D4
#ifdef	SCI_ISR_RXTX					;vector base + $D6
ISR_SCI			EQU	SCI_ISR_RXTX
#else
ISR_SCI			EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_SPI    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $D8
ISR_TIM_PAIE   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DA
ISR_TIM_PAOV   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DC
ISR_TIM_TOV    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $DE
ISR_TIM_TC7    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E0
ISR_TIM_TC6    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E2
ISR_TIM_TC5    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E4
ISR_TIM_TC4    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $E6
#ifdef	SCI_ISR_DELAY					;vector base + $E8
ISR_TIM_TC3		EQU	SCI_ISR_DELAY
#else
ISR_TIM_TC3		EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_TIM_TC2    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $EA
#ifdef	SCI_ISR_BD_NE					;vector base + $EC
ISR_TIM_TC1		EQU	SCI_ISR_BD_NE
#else
ISR_TIM_TC1		EQU	VECTAB_ISR_ILLIRQ
#endif
#ifdef	SCI_ISR_BD_PE					;vector base + $EE
ISR_TIM_TC0		EQU	SCI_ISR_BD_PE
#else
ISR_TIM_TC0		EQU	VECTAB_ISR_ILLIRQ
#endif
#ifdef	LED_ISR						;vector base + $F0
ISR_RTI			EQU	LED_ISR
#else
ISR_RTI			EQU	VECTAB_ISR_ILLIRQ
#endif
ISR_IRQ    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $F2
ISR_XIRQ   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $F4
ISR_SWI    		EQU	VECTAB_ISR_ILLIRQ	;vector base + $F6
ISR_TRAP   		EQU	VECTAB_ISR_ILLIRQ	;vector base + $F8

;#Error message
VECTAB_MSG_ILLIRQ	FCS	"Unexpected interrupt"
			FLET16	VECTAB_MSG_ILLIRQ *-1
#endif					
					
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	

;###############################################################################
;# S12G128 Vector Table                                                        #
;###############################################################################
			ORG	VECTAB_START, VECTAB_START_LIN		 	
VEC_RES80    		DW	ISR_RES80    		;vector base + $80
VEC_RES82    		DW	ISR_RES82    		;vector base + $82
VEC_RES84    		DW	ISR_RES84    		;vector base + $84
VEC_RES86    		DW	ISR_RES86    		;vector base + $86
VEC_RES88    		DW	ISR_RES88    		;vector base + $88
VEC_LVI	      		DW	ISR_LVI	           	;vector base + $8A
VEC_PWM	      		DW	ISR_PWM	           	;vector base + $8C
VEC_PORTP    		DW	ISR_PORTP    		;vector base + $8E
VEC_RES90    		DW	ISR_RES90    		;vector base + $90
VEC_RES92    		DW	ISR_RES92    		;vector base + $92
VEC_RES94    		DW	ISR_RES94    		;vector base + $94
VEC_RES96    		DW	ISR_RES96    		;vector base + $96
VEC_RES98    		DW	ISR_RES98    		;vector base + $98
VEC_RES9A    		DW	ISR_RES9A    		;vector base + $9A
VEC_RES9C    		DW	ISR_RES9C    		;vector base + $9C
VEC_RES9E    		DW	ISR_RES9E    		;vector base + $9E
VEC_RESA0    		DW	ISR_RESA0    		;vector base + $A0
VEC_RESA2    		DW	ISR_RESA2    		;vector base + $A2
VEC_RESA4    		DW	ISR_RESA4    		;vector base + $A4
VEC_RESA6    		DW	ISR_RESA6    		;vector base + $A6
VEC_RESA8    		DW	ISR_RESA8    		;vector base + $A8
VEC_RESAA    		DW	ISR_RESAA    		;vector base + $AA
VEC_RESAC    		DW	ISR_RESAC    		;vector base + $AC
VEC_RESAE    		DW	ISR_RESAE    		;vector base + $AE
VEC_CANTX     		DW	ISR_CANTX        	;vector base + $A0
VEC_CANRX     		DW	ISR_CANRX        	;vector base + $B2
VEC_CANERR    		DW	ISR_CANERR       	;vector base + $B4
VEC_CANWUP    		DW	ISR_CANWUP       	;vector base + $B6
VEC_FLASH     		DW	ISR_FLASH        	;vector base + $B8
VEC_RESBA    		DW	ISR_RESBA    		;vector base + $BA
VEC_RESBC    		DW	ISR_RESBC    		;vector base + $BC
VEC_RESBE    		DW	ISR_RESBE    		;vector base + $BE
VEC_RESC0    		DW	ISR_RESC0    		;vector base + $C0
VEC_RESC2    		DW	ISR_RESC2    		;vector base + $C2
VEC_SCM	      		DW	ISR_SCM	           	;vector base + $C4
VEC_PLLLOCK  		DW	ISR_PLLLOCK  		;vector base + $C6
VEC_RESC8    		DW	ISR_RESC8    		;vector base + $C8
VEC_RESCA    		DW	ISR_RESCA    		;vector base + $CA
VEC_RESCC    		DW	ISR_RESCC    		;vector base + $CC
VEC_PORTJ     		DW	ISR_PORTJ        	;vector base + $CC
VEC_RESD0    		DW	ISR_RESD0    		;vector base + $D0
VEC_ATD	      		DW	ISR_ATD	           	;vector base + $D2
VEC_RESD4     		DW	ISR_RESD4     		;vector base + $D4
VEC_SCI	     		DW	ISR_SCI	     		;vector base + $D6
VEC_SPI	     		DW	ISR_SPI	     		;vector base + $D8
VEC_TIM_PAIE     	DW	ISR_TIM_PAIE     	;vector base + $DA
VEC_TIM_PAOV     	DW	ISR_TIM_PAOV     	;vector base + $DC
VEC_TIM_TOV	     	DW	ISR_TIM_TOV	     	;vector base + $DE
VEC_TIM_TC7	     	DW	ISR_TIM_TC7	     	;vector base + $E0
VEC_TIM_TC6	     	DW	ISR_TIM_TC6	     	;vector base + $E2
VEC_TIM_TC5	     	DW	ISR_TIM_TC5	     	;vector base + $E4
VEC_TIM_TC4	     	DW	ISR_TIM_TC4	     	;vector base + $E6
VEC_TIM_TC3	     	DW	ISR_TIM_TC3	     	;vector base + $E8
VEC_TIM_TC2	     	DW	ISR_TIM_TC2	     	;vector base + $EA
VEC_TIM_TC1	     	DW	ISR_TIM_TC1	     	;vector base + $EC
VEC_TIM_TC0	     	DW	ISR_TIM_TC0	     	;vector base + $EE
VEC_RTI	     		DW	ISR_RTI	     		;vector base + $F0
VEC_IRQ	     		DW	ISR_IRQ	     		;vector base + $F2
VEC_XIRQ     		DW	ISR_XIRQ     		;vector base + $F4
VEC_SWI	     		DW	ISR_SWI	     		;vector base + $F6
VEC_TRAP     		DW	ISR_TRAP     		;vector base + $F8
VEC_RESET_COP		DW	RESET_COP_ENTRY		;vector base + $FA
VEC_RESET_CM		DW	RESET_CM_ENTRY 		;vector base + $FC
VEC_RESET_EXT		DW	RESET_EXT_ENTRY		;vector base + $FE
#endif
