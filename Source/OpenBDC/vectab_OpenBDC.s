;###############################################################################
;# S12CBase - VECTAB - Vector Table (OpenBDC)                                  #
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
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    July 9, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added dummy vectors                                                  #
;#    July 31, 2012                                                            #
;#      - Moved vedctor table to table section                                 #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Make each unused interrupt point to a separate BGND instruction
;VECTAB_DEBUG		EQU	1 

;###############################################################################
;# Constants                                                                   #
;###############################################################################
VECTAB_START		EQU	$FF80
VECTAB_START_LIN	EQU	$FFF80

;###############################################################################
;# Undefined ISRs                                                              #
;###############################################################################
;#BDM
#ifndef	BDM_ISR_TGTRST
BDM_ISR_TGTRST		EQU	VECTAB_DUMMY_PORTP
#endif
#ifndef	BDM_ISR_TC5
BDM_ISR_TC5		EQU	VECTAB_DUMMY_TC5
#endif
#ifndef	BDM_ISR_TC6
BDM_ISR_TC6		EQU	VECTAB_DUMMY_TC6
#endif
#ifndef	BDM_ISR_TC7
BDM_ISR_TC7		EQU	VECTAB_DUMMY_TC7
#endif
	
;#CLOCK
#ifndef	CLOCK_ISR
CLOCK_ISR		EQU	VECTAB_DUMMY_PLLLOCK
#endif

;#SCI
#ifndef	SCI_ISR_RXTX
SCI_ISR_RXTX		EQU	VECTAB_DUMMY_SCI
#endif
#ifndef	SCI_ISR_TC0
SCI_ISR_TC0		EQU	VECTAB_DUMMY_TC0
#endif
#ifndef	SCI_ISR_TC1
SCI_ISR_TC1		EQU	VECTAB_DUMMY_TC1
#endif
#ifndef	SCI_ISR_TC2
SCI_ISR_TC2		EQU	VECTAB_DUMMY_TC2
#endif

;#LED
#ifndef	LED_ISR
LED_ISR			EQU	VECTAB_DUMMY_RTI
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
VECTAB_DUMMY_RES80   	BGND
VECTAB_DUMMY_RES82   	BGND
VECTAB_DUMMY_RES84   	BGND
VECTAB_DUMMY_RES86   	BGND
VECTAB_DUMMY_RES88   	BGND
VECTAB_DUMMY_LVI     	BGND      
VECTAB_DUMMY_PWM     	BGND      
VECTAB_DUMMY_PORTP   	BGND
VECTAB_DUMMY_RES90   	BGND
VECTAB_DUMMY_RES92   	BGND
VECTAB_DUMMY_RES94   	BGND
VECTAB_DUMMY_RES96   	BGND
VECTAB_DUMMY_RES98   	BGND
VECTAB_DUMMY_RES9A   	BGND
VECTAB_DUMMY_RES9C   	BGND
VECTAB_DUMMY_RES9E   	BGND
VECTAB_DUMMY_RESA0   	BGND
VECTAB_DUMMY_RESA2   	BGND
VECTAB_DUMMY_RESA4   	BGND
VECTAB_DUMMY_RESA6   	BGND
VECTAB_DUMMY_RESA8   	BGND
VECTAB_DUMMY_RESAA   	BGND
VECTAB_DUMMY_RESAC   	BGND
VECTAB_DUMMY_RESAE   	BGND
VECTAB_DUMMY_CANTX   	BGND
VECTAB_DUMMY_CANRX   	BGND
VECTAB_DUMMY_CANERR  	BGND
VECTAB_DUMMY_CANWUP  	BGND
VECTAB_DUMMY_FLASH   	BGND
VECTAB_DUMMY_RESBA   	BGND
VECTAB_DUMMY_RESBC   	BGND
VECTAB_DUMMY_RESBE   	BGND
VECTAB_DUMMY_RESC0   	BGND
VECTAB_DUMMY_RESC2   	BGND
VECTAB_DUMMY_SCM     	BGND      
VECTAB_DUMMY_PLLLOCK 	BGND
VECTAB_DUMMY_RESC8  	BGND
VECTAB_DUMMY_RESCA  	BGND
VECTAB_DUMMY_RESCC  	BGND
VECTAB_DUMMY_PORTJ  	BGND
VECTAB_DUMMY_RESD0  	BGND
VECTAB_DUMMY_ATD    	BGND
VECTAB_DUMMY_RESD4  	BGND
VECTAB_DUMMY_SCI    	BGND
VECTAB_DUMMY_SPI    	BGND
VECTAB_DUMMY_PAIE   	BGND
VECTAB_DUMMY_PAOV   	BGND
VECTAB_DUMMY_TOV    	BGND
VECTAB_DUMMY_TC7    	BGND
VECTAB_DUMMY_TC6    	BGND
VECTAB_DUMMY_TC5    	BGND
VECTAB_DUMMY_TC4    	BGND
VECTAB_DUMMY_TC3    	BGND
VECTAB_DUMMY_TC2    	BGND
VECTAB_DUMMY_TC1    	BGND
VECTAB_DUMMY_TC0    	BGND
VECTAB_DUMMY_RTI    	BGND
VECTAB_DUMMY_IRQ    	BGND
VECTAB_DUMMY_XIRQ   	BGND
VECTAB_DUMMY_SWI    	BGND
VECTAB_DUMMY_TRAP   	BGND
#else
VECTAB_DUMMY_RES80   	EQU	ERROR_ISR
VECTAB_DUMMY_RES82   	EQU	ERROR_ISR
VECTAB_DUMMY_RES84   	EQU	ERROR_ISR
VECTAB_DUMMY_RES86   	EQU	ERROR_ISR
VECTAB_DUMMY_RES88   	EQU	ERROR_ISR
VECTAB_DUMMY_LVI     	EQU	ERROR_ISR      
VECTAB_DUMMY_PWM     	EQU	ERROR_ISR      
VECTAB_DUMMY_PORTP   	EQU	ERROR_ISR
VECTAB_DUMMY_RES90   	EQU	ERROR_ISR
VECTAB_DUMMY_RES92   	EQU	ERROR_ISR
VECTAB_DUMMY_RES94   	EQU	ERROR_ISR
VECTAB_DUMMY_RES96   	EQU	ERROR_ISR
VECTAB_DUMMY_RES98   	EQU	ERROR_ISR
VECTAB_DUMMY_RES9A   	EQU	ERROR_ISR
VECTAB_DUMMY_RES9C   	EQU	ERROR_ISR
VECTAB_DUMMY_RES9E   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA0   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA2   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA4   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA6   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA8   	EQU	ERROR_ISR
VECTAB_DUMMY_RESAA   	EQU	ERROR_ISR
VECTAB_DUMMY_RESAC   	EQU	ERROR_ISR
VECTAB_DUMMY_RESAE   	EQU	ERROR_ISR
VECTAB_DUMMY_CANTX   	EQU	ERROR_ISR
VECTAB_DUMMY_CANRX   	EQU	ERROR_ISR
VECTAB_DUMMY_CANERR  	EQU	ERROR_ISR
VECTAB_DUMMY_CANWUP  	EQU	ERROR_ISR
VECTAB_DUMMY_FLASH   	EQU	ERROR_ISR
VECTAB_DUMMY_RESBA   	EQU	ERROR_ISR
VECTAB_DUMMY_RESBC   	EQU	ERROR_ISR
VECTAB_DUMMY_RESBE   	EQU	ERROR_ISR
VECTAB_DUMMY_RESC0   	EQU	ERROR_ISR
VECTAB_DUMMY_RESC2   	EQU	ERROR_ISR
VECTAB_DUMMY_SCM     	EQU	ERROR_ISR      
VECTAB_DUMMY_PLLLOCK 	EQU	ERROR_ISR
VECTAB_DUMMY_RESC8  	EQU	ERROR_ISR
VECTAB_DUMMY_RESCA  	EQU	ERROR_ISR
VECTAB_DUMMY_RESCC  	EQU	ERROR_ISR
VECTAB_DUMMY_PORTJ  	EQU	ERROR_ISR
VECTAB_DUMMY_RESD0  	EQU	ERROR_ISR
VECTAB_DUMMY_ATD    	EQU	ERROR_ISR
VECTAB_DUMMY_RESD4  	EQU	ERROR_ISR
VECTAB_DUMMY_SCI    	EQU	ERROR_ISR
VECTAB_DUMMY_SPI    	EQU	ERROR_ISR
VECTAB_DUMMY_PAIE   	EQU	ERROR_ISR
VECTAB_DUMMY_PAOV   	EQU	ERROR_ISR
VECTAB_DUMMY_TOV    	EQU	ERROR_ISR
VECTAB_DUMMY_TC7    	EQU	ERROR_ISR
VECTAB_DUMMY_TC6    	EQU	ERROR_ISR
VECTAB_DUMMY_TC5    	EQU	ERROR_ISR
VECTAB_DUMMY_TC4    	EQU	ERROR_ISR
VECTAB_DUMMY_TC3    	EQU	ERROR_ISR
VECTAB_DUMMY_TC2    	EQU	ERROR_ISR
VECTAB_DUMMY_TC1    	EQU	ERROR_ISR
VECTAB_DUMMY_TC0    	EQU	ERROR_ISR
VECTAB_DUMMY_RTI    	EQU	ERROR_ISR
VECTAB_DUMMY_IRQ    	EQU	ERROR_ISR
VECTAB_DUMMY_XIRQ   	EQU	ERROR_ISR
VECTAB_DUMMY_SWI    	EQU	ERROR_ISR
VECTAB_DUMMY_TRAP   	EQU	ERROR_ISR
#endif
	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	

;###############################################################################
;# S12G128 Vector Table                                                        #
;###############################################################################
		ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_RESERVED80	DW	VECTAB_DUMMY_RES80
VEC_RESERVED82	DW	VECTAB_DUMMY_RES82
VEC_RESERVED84	DW	VECTAB_DUMMY_RES84
VEC_RESERVED86	DW	VECTAB_DUMMY_RES86
VEC_RESERVED88	DW	VECTAB_DUMMY_RES88
VEC_LVI	      	DW	VECTAB_DUMMY_LVI	      
VEC_PWM	      	DW	VECTAB_DUMMY_PWM	      
VEC_PORTP	DW	BDM_ISR_TGTRST
VEC_RESERVED90	DW	VECTAB_DUMMY_RES90
VEC_RESERVED92	DW	VECTAB_DUMMY_RES92
VEC_RESERVED94	DW	VECTAB_DUMMY_RES94
VEC_RESERVED96	DW	VECTAB_DUMMY_RES96
VEC_RESERVED98	DW	VECTAB_DUMMY_RES98
VEC_RESERVED9A	DW	VECTAB_DUMMY_RES9A
VEC_RESERVED9C	DW	VECTAB_DUMMY_RES9C
VEC_RESERVED9E	DW	VECTAB_DUMMY_RES9E
VEC_RESERVEDA0	DW	VECTAB_DUMMY_RESA0
VEC_RESERVEDA2	DW	VECTAB_DUMMY_RESA2
VEC_RESERVEDA4	DW	VECTAB_DUMMY_RESA4
VEC_RESERVEDA6	DW	VECTAB_DUMMY_RESA6
VEC_RESERVEDA8	DW	VECTAB_DUMMY_RESA8
VEC_RESERVEDAA	DW	VECTAB_DUMMY_RESAA
VEC_RESERVEDAC	DW	VECTAB_DUMMY_RESAC
VEC_RESERVEDAE	DW	VECTAB_DUMMY_RESAE
VEC_CANTX     	DW	VECTAB_DUMMY_CANTX     
VEC_CANRX     	DW	VECTAB_DUMMY_CANRX     
VEC_CANERR    	DW	VECTAB_DUMMY_CANERR    
VEC_CANWUP    	DW	VECTAB_DUMMY_CANWUP    
VEC_FLASH     	DW	VECTAB_DUMMY_FLASH     
VEC_RESERVEDBA	DW	VECTAB_DUMMY_RESBA
VEC_RESERVEDBC	DW	VECTAB_DUMMY_RESBC
VEC_RESERVEDBE	DW	VECTAB_DUMMY_RESBE
VEC_RESERVEDC0	DW	VECTAB_DUMMY_RESC0
VEC_RESERVEDC2	DW	VECTAB_DUMMY_RESC2
VEC_SCM	      	DW	VECTAB_DUMMY_SCM	      
VEC_PLLLOCK	DW	CLOCK_ISR
VEC_RESERVEDC8	DW	VECTAB_DUMMY_RESC8
VEC_RESERVEDCA	DW	VECTAB_DUMMY_RESCA
VEC_RESERVEDCC	DW	VECTAB_DUMMY_RESCC
VEC_PORTJ     	DW	VECTAB_DUMMY_PORTJ     
VEC_RESERVEDD0	DW	VECTAB_DUMMY_RESD0
VEC_ATD	      	DW	VECTAB_DUMMY_ATD	      
VEC_RESERVEDD4	DW	VECTAB_DUMMY_RESD4
VEC_SCI		DW	SCI_ISR_RXTX
VEC_SPI		DW	VECTAB_DUMMY_SPI	
VEC_PAIE	DW	VECTAB_DUMMY_PAIE
VEC_PAOV	DW	VECTAB_DUMMY_PAOV
VEC_TOV		DW	VECTAB_DUMMY_TOV	
VEC_TC7		DW	BDM_ISR_TC7
VEC_TC6		DW	BDM_ISR_TC6
VEC_TC5		DW	BDM_ISR_TC5
VEC_TC4		DW	VECTAB_DUMMY_TC4
VEC_TC3		DW	VECTAB_DUMMY_TC3
VEC_TC2		DW	VECTAB_DUMMY_TC2
VEC_TC1		DW	SCI_ISR_TC1
VEC_TC0		DW	SCI_ISR_TC0
VEC_RTI		DW	LED_ISR
VEC_IRQ		DW	VECTAB_DUMMY_IRQ	
VEC_XIRQ	DW	VECTAB_DUMMY_XIRQ
VEC_SWI		DW	VECTAB_DUMMY_SWI	
VEC_TRAP	DW	VECTAB_DUMMY_TRAP
VEC_RESET_COP	DW	ERROR_RESET_COP
VEC_RESET_CM	DW	ERROR_RESET_CM
VEC_RESET_EXT	DW	ERROR_RESET_EXT
