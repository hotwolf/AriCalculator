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
;###############################################################################

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
BDM_ISR_TGTRST		EQU	ERROR_ISR
#endif
#ifndef	BDM_ISR_TC5
BDM_ISR_TC5		EQU	ERROR_ISR
#endif
#ifndef	BDM_ISR_TC6
BDM_ISR_TC6		EQU	ERROR_ISR
#endif
#ifndef	BDM_ISR_TC7
BDM_ISR_TC7		EQU	ERROR_ISR
#endif
	
;#CLOCK
#ifndef	CLOCK_ISR
CLOCK_ISR		EQU	ERROR_ISR
#endif

;#SCI
#ifndef	SCI_ISR_RXTX
SCI_ISR_RXTX		EQU	ERROR_ISR
#endif
#ifndef	SCI_ISR_TC0
SCI_ISR_TC0		EQU	ERROR_ISR
#endif
#ifndef	SCI_ISR_TC1
SCI_ISR_TC1		EQU	ERROR_ISR
#endif
#ifndef	SCI_ISR_TC2
SCI_ISR_TC2		EQU	ERROR_ISR
#endif

;#LED
#ifndef	LED_ISR
LED_ISR			EQU	ERROR_ISR
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

;#Dummy ISR
#ifndef	ERROR_ISR
ERROR_ISR		BGND
			JOB	ERROR_ISR
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

VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	

;###############################################################################
;# S12G128 Vector Table                                                        #
;###############################################################################
		ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_RESERVED80	DW	ERROR_ISR
VEC_RESERVED82	DW	ERROR_ISR
VEC_RESERVED84	DW	ERROR_ISR
VEC_RESERVED86	DW	ERROR_ISR
VEC_RESERVED88	DW	ERROR_ISR
VEC_LVI		DW	ERROR_ISR
VEC_PWM		DW	ERROR_ISR
VEC_PORTP	DW	BDM_ISR_TGTRST
VEC_RESERVED90	DW	ERROR_ISR
VEC_RESERVED92	DW	ERROR_ISR
VEC_RESERVED94	DW	ERROR_ISR
VEC_RESERVED96	DW	ERROR_ISR
VEC_RESERVED98	DW	ERROR_ISR
VEC_RESERVED9A	DW	ERROR_ISR
VEC_RESERVED9C	DW	ERROR_ISR
VEC_RESERVED9E	DW	ERROR_ISR
VEC_RESERVEDA0	DW	ERROR_ISR
VEC_RESERVEDA2	DW	ERROR_ISR
VEC_RESERVEDA4	DW	ERROR_ISR
VEC_RESERVEDA6	DW	ERROR_ISR
VEC_RESERVEDA8	DW	ERROR_ISR
VEC_RESERVEDAA	DW	ERROR_ISR
VEC_RESERVEDAC	DW	ERROR_ISR
VEC_RESERVEDAE	DW	ERROR_ISR
VEC_CANTX	DW	ERROR_ISR
VEC_CANRX	DW	ERROR_ISR
VEC_CANERR	DW	ERROR_ISR
VEC_CANWUP	DW	ERROR_ISR
VEC_FLASH	DW	ERROR_ISR
VEC_RESERVEDBA	DW	ERROR_ISR
VEC_RESERVEDBC	DW	ERROR_ISR
VEC_RESERVEDBE	DW	ERROR_ISR
VEC_RESERVEDC0	DW	ERROR_ISR
VEC_RESERVEDC2	DW	ERROR_ISR
VEC_SCM		DW	ERROR_ISR
VEC_PLLLOCK	DW	CLOCK_ISR
VEC_RESERVEDC8	DW	ERROR_ISR
VEC_RESERVEDCA	DW	ERROR_ISR
VEC_RESERVEDCC	DW	ERROR_ISR
VEC_PORTJ	DW	ERROR_ISR
VEC_RESERVEDD0	DW	ERROR_ISR
VEC_ATD		DW	ERROR_ISR
VEC_RESERVEDD4	DW	ERROR_ISR
VEC_SCI		DW	SCI_ISR_RXTX
VEC_SPI		DW	ERROR_ISR
VEC_PAIE	DW	ERROR_ISR
VEC_PAOV	DW	ERROR_ISR
VEC_TOV		DW	ERROR_ISR
VEC_TC7		DW	BDM_ISR_TC7
VEC_TC6		DW	BDM_ISR_TC6
VEC_TC5		DW	BDM_ISR_TC5
VEC_TC4		DW	ERROR_ISR
VEC_TC3		DW	ERROR_ISR
VEC_TC2		DW	ERROR_ISR
VEC_TC1		DW	SCI_ISR_TC1
VEC_TC0		DW	SCI_ISR_TC0
VEC_RTI		DW	LED_ISR
VEC_IRQ		DW	ERROR_ISR
VEC_XIRQ	DW	ERROR_ISR
VEC_SWI		DW	ERROR_ISR
VEC_TRAP	DW	ERROR_ISR
VEC_RESET_COP	DW	ERROR_RESET_COP
VEC_RESET_CM	DW	ERROR_RESET_CM
VEC_RESET_EXT	DW	ERROR_RESET_EXT
