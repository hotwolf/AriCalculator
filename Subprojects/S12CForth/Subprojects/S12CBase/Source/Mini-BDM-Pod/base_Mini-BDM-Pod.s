;###############################################################################
;# S12CBase - Base Bundle (Mini-BDM-Pod)                                  #
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
;#    This module bundles all standard S12CBase modules into one.              #
;###############################################################################
;# Version History:                                                            #
;#    November 20, 2012                                                        #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# Clocks
CLOCK_CRG		EQU	1		;old CRG
#ifndef CLOCK_OSC_FREQ	
CLOCK_OSC_FREQ		EQU	10000000	;10 MHz
#endif
#ifndef CLOCK_BUS_FREQ
CLOCK_BUS_FREQ		EQU	50000000	;50 MHz
#endif
#ifndef CLOCK_REF_FREQ
CLOCK_REF_FREQ		EQU	CLOCK_OSC_FREQ	;4,000 MHz
#endif
#ifndef CLOCK_VCOFRQ
CLOCK_VCOFRQ		EQU	3		;VCO=100MHz
#endif
#ifndef CLOCK_REFFRQ
CLOCK_REFFRQ		EQU	2		;Ref=10Mhz
#endif

;# RESET
RESET_COP_OFF		EQU	1
RESET_CLKFAIL_OFF	EQU	1
	
;# SCI
#ifndef	SCI_FC_RTS_CTS
#ifndef	SCI_FC_XON_XOFF
#ifndef SCI_FC_NONE	
SCI_FC_XON_XOFF		EQU	1 		;XON/XOFF flow control
#endif
#endif
#endif

#ifndef	SCI_BD_ON
#ifndef	SCI_BD_OFF
SCI_BD_ON		EQU	1 		;use baud rate detection
SCI_BD_TIM		EQU	1 		;TIM
SCI_BD_ICNEPE		EQU	0		;IC0
SCI_BD_OC		EQU	2		;OC2			
SCI_DLY_OC		EQU	3		;OC3
#endif
#endif

#ifndef	SCI_ERRSIG_ON
#ifndef	SCI_ERRSIG_OFF
SCI_ERRSIG_ON		EQU	1 		;signal errors
#endif
#endif
	
;# TIM
TIM_DIV2_ON		EQU	1 		;run TIM at half bus frequency

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef BASE_VARS_START_LIN
			ORG 	BASE_VARS_START, BASE_VARS_START_LIN
#else
			ORG 	BASE_VARS_START
#endif	

GPIO_VARS_START		EQU	*
GPIO_VARS_START_LIN	EQU	@

MMAP_VARS_START		EQU	GPIO_VARS_END	 
MMAP_VARS_START_LIN	EQU	GPIO_VARS_END_LIN

SSTACK_VARS_START	EQU	MMAP_VARS_END
SSTACK_VARS_START_LIN	EQU	MMAP_VARS_END_LIN

ISTACK_VARS_START	EQU	SSTACK_VARS_END
ISTACK_VARS_START_LIN	EQU	SSTACK_VARS_END_LIN

CLOCK_VARS_START	EQU	ISTACK_VARS_END
CLOCK_VARS_START_LIN	EQU	ISTACK_VARS_END_LIN

COP_VARS_START		EQU	CLOCK_VARS_END
COP_VARS_START_LIN	EQU	CLOCK_VARS_END_LIN

TIM_VARS_START		EQU	COP_VARS_END
TIM_VARS_START_LIN	EQU	COP_VARS_END_LIN

LED_VARS_START		EQU	TIM_VARS_END
LED_VARS_START_LIN	EQU	TIM_VARS_END_LIN

TVMON_VARS_START	EQU	LED_VARS_END
TVMON_VARS_START_LIN	EQU	LED_VARS_END_LIN

SCI_VARS_START		EQU	TVMON_VARS_END
SCI_VARS_START_LIN	EQU	TVMON_VARS_END_LIN

STRING_VARS_START	EQU	SCI_VARS_END
STRING_VARS_START_LIN	EQU	SCI_VARS_END_LIN

RESET_VARS_START	EQU	STRING_VARS_END
RESET_VARS_START_LIN	EQU	STRING_VARS_END_LIN

NUM_VARS_START		EQU	RESET_VARS_END
NUM_VARS_START_LIN	EQU	RESET_VARS_END_LIN
	
NVM_VARS_START		EQU	NUM_VARS_END
NVM_VARS_START_LIN	EQU	NUM_VARS_END_LIN
	
VECTAB_VARS_START	EQU	NVM_VARS_END
VECTAB_VARS_START_LIN	EQU	NVM_VARS_END_LIN

BASE_VARS_END		EQU	VECTAB_VARS_START	
BASE_VARS_END_LIN	EQU	VECTAB_VARS_START_LIN

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	BASE_INIT, 0
			GPIO_INIT
			CLOCK_INIT
			COP_INIT
			MMAP_INIT
			VECTAB_INIT
			ISTACK_INIT
			TIM_INIT
			STRING_INIT
			NUM_INIT
			NVM_INIT
			LED_INIT
			TVMON_INIT
			CLOCK_WAIT_FOR_PLL
			SCI_INIT	
			RESET_INIT
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef BASE_CODE_START_LIN
			ORG 	BASE_CODE_START, BASE_CODE_START_LIN
#else
			ORG 	BASE_CODE_START
#endif	

GPIO_CODE_START		EQU	*
GPIO_CODE_START_LIN	EQU	@

MMAP_CODE_START		EQU	GPIO_CODE_END	 
MMAP_CODE_START_LIN	EQU	GPIO_CODE_END_LIN

SSTACK_CODE_START	EQU	MMAP_CODE_END
SSTACK_CODE_START_LIN	EQU	MMAP_CODE_END_LIN

ISTACK_CODE_START	EQU	SSTACK_CODE_END
ISTACK_CODE_START_LIN	EQU	SSTACK_CODE_END_LIN

CLOCK_CODE_START	EQU	ISTACK_CODE_END
CLOCK_CODE_START_LIN	EQU	ISTACK_CODE_END_LIN

COP_CODE_START		EQU	CLOCK_CODE_END
COP_CODE_START_LIN	EQU	CLOCK_CODE_END_LIN

TIM_CODE_START		EQU	COP_CODE_END
TIM_CODE_START_LIN	EQU	COP_CODE_END_LIN

LED_CODE_START		EQU	TIM_CODE_END
LED_CODE_START_LIN	EQU	TIM_CODE_END_LIN

TVMON_CODE_START	EQU	LED_CODE_END
TVMON_CODE_START_LIN	EQU	LED_CODE_END_LIN

SCI_CODE_START		EQU	TVMON_CODE_END
SCI_CODE_START_LIN	EQU	TVMON_CODE_END_LIN

STRING_CODE_START	EQU	SCI_CODE_END
STRING_CODE_START_LIN	EQU	SCI_CODE_END_LIN

RESET_CODE_START	EQU	STRING_CODE_END
RESET_CODE_START_LIN	EQU	STRING_CODE_END_LIN

NUM_CODE_START		EQU	RESET_CODE_END
NUM_CODE_START_LIN	EQU	RESET_CODE_END_LIN
	
NVM_CODE_START		EQU	NUM_CODE_END
NVM_CODE_START_LIN	EQU	NUM_CODE_END_LIN
	
VECTAB_CODE_START	EQU	NVM_CODE_END
VECTAB_CODE_START_LIN	EQU	NVM_CODE_END_LIN

BASE_CODE_END		EQU	VECTAB_CODE_START	
BASE_CODE_END_LIN	EQU	VECTAB_CODE_START_LIN

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef BASE_TABS_START_LIN
			ORG 	BASE_TABS_START, BASE_TABS_START_LIN
#else
			ORG 	BASE_TABS_START
#endif	

GPIO_TABS_START		EQU	*
GPIO_TABS_START_LIN	EQU	@

MMAP_TABS_START		EQU	GPIO_TABS_END	 
MMAP_TABS_START_LIN	EQU	GPIO_TABS_END_LIN

SSTACK_TABS_START	EQU	MMAP_TABS_END
SSTACK_TABS_START_LIN	EQU	MMAP_TABS_END_LIN

ISTACK_TABS_START	EQU	SSTACK_TABS_END
ISTACK_TABS_START_LIN	EQU	SSTACK_TABS_END_LIN

CLOCK_TABS_START	EQU	ISTACK_TABS_END
CLOCK_TABS_START_LIN	EQU	ISTACK_TABS_END_LIN

COP_TABS_START		EQU	CLOCK_TABS_END
COP_TABS_START_LIN	EQU	CLOCK_TABS_END_LIN

TIM_TABS_START		EQU	COP_TABS_END
TIM_TABS_START_LIN	EQU	COP_TABS_END_LIN

LED_TABS_START		EQU	TIM_TABS_END
LED_TABS_START_LIN	EQU	TIM_TABS_END_LIN

TVMON_TABS_START	EQU	LED_TABS_END
TVMON_TABS_START_LIN	EQU	LED_TABS_END_LIN

SCI_TABS_START		EQU	TVMON_TABS_END
SCI_TABS_START_LIN	EQU	TVMON_TABS_END_LIN

STRING_TABS_START	EQU	SCI_TABS_END
STRING_TABS_START_LIN	EQU	SCI_TABS_END_LIN

RESET_TABS_START	EQU	STRING_TABS_END
RESET_TABS_START_LIN	EQU	STRING_TABS_END_LIN

NUM_TABS_START		EQU	RESET_TABS_END
NUM_TABS_START_LIN	EQU	RESET_TABS_END_LIN
	
NVM_TABS_START		EQU	NUM_TABS_END
NVM_TABS_START_LIN	EQU	NUM_TABS_END_LIN
	
VECTAB_TABS_START	EQU	NVM_TABS_END
VECTAB_TABS_START_LIN	EQU	NVM_TABS_END_LIN

BASE_TABS_END		EQU	VECTAB_TABS_START	
BASE_TABS_END_LIN	EQU	VECTAB_TABS_START_LIN

;###############################################################################
;# Includes                                                                    #
;###############################################################################
			CPU	S12X
#include ./regdef_Mini-BDM-Pod.s	;S12XEP100 register map
#include ./gpio_Mini-BDM-Pod.s		;I/O setup
#include ./mmap_Mini-BDM-Pod.s		;RAM memory map
#include ../All/sstack.s		;Subroutine stack
#include ../All/istack.s		;Interrupt stack
#include ../All/clock.s			;CRG setup
#include ../All/cop.s			;COP handler
#include ../All/tim.s			;TIM driver
#include ./led_Mini-BDM-Pod.s		;LED driver
#include ./tvmon_Mini-BDM-Pod.s		;Target Vdd monitor
#include ./sci_bdtab_Mini-BDM-Pod.s	;Search tree for SCI baud rate detection
#include ../All/sci.s			;SCI driver
#include ../All/string.s		;String printing routines
#include ../All/reset.s			;Reset driver
#include ../All/num.s	   		;Number printing routines
#include ./nvm_Mini-BDM-Pod.s		;NVM driver
#include ./vectab_Mini-BDM-Pod.s	;S12XEP100 vector table
