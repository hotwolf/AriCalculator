;###############################################################################
;# S12CBase - Base Bundle (SIMHC12)                                            #
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
#ifndef	CLOCK_BUS_FREQ	
CLOCK_BUS_FREQ		EQU	8000000		;8 MHz
#endif

;# COP
COP_DEBUG		EQU	1 		;disable COP

;# RESET
RESET_COP_OFF		EQU	1 		;no COP reset
	
#ifndef	SCI_FC_RTS_CTS
#ifndef	SCI_FC_XON_XOFF
#ifndef SCI_FC_NONE	
SCI_FC_NONE		EQU	1 		;no flow control
#endif
#endif
#endif

#ifndef	SCI_BD_ON
#ifndef	SCI_BD_OFF
SCI_BD_OFF		EQU	1 		;no baud rate detection
#endif
#endif

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

TIM_VARS_START		EQU	ISTACK_VARS_END
TIM_VARS_START_LIN	EQU	ISTACK_VARS_END_LIN

SCI_VARS_START		EQU	TIM_VARS_END
SCI_VARS_START_LIN	EQU	TIM_VARS_END_LIN

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

BASE_VARS_END		EQU	VECTAB_VARS_END	
BASE_VARS_END_LIN	EQU	VECTAB_VARS_END_LIN

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	BASE_INIT, 0
			CLR	COPCTL ;disable COP
			GPIO_INIT
			MMAP_INIT
			VECTAB_INIT
			ISTACK_INIT
			SSTACK_INIT
			TIM_INIT
			STRING_INIT
			NUM_INIT
			NVM_INIT
			SCI_INIT
			RESET_INIT
#emac

;# COP replacement macros
#macro COP_SERVICE, 0
#emac
	
#macro COP_RESET, 0
			JOB	RESET_COP_ENTRY
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

TIM_CODE_START		EQU	ISTACK_CODE_END
TIM_CODE_START_LIN	EQU	ISTACK_CODE_END_LIN

SCI_CODE_START		EQU	TIM_CODE_END
SCI_CODE_START_LIN	EQU	TIM_CODE_END_LIN

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

BASE_CODE_END		EQU	VECTAB_CODE_END	
BASE_CODE_END_LIN	EQU	VECTAB_CODE_END_LIN

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

TIM_TABS_START		EQU	ISTACK_TABS_END
TIM_TABS_START_LIN	EQU	ISTACK_TABS_END_LIN

SCI_TABS_START		EQU	TIM_TABS_END
SCI_TABS_START_LIN	EQU	TIM_TABS_END_LIN

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

BASE_TABS_END		EQU	VECTAB_TABS_END	
BASE_TABS_END_LIN	EQU	VECTAB_TABS_END_LIN

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./regdef_SIMHC12.s		;HC12A4 register map
#include ./gpio_SIMHC12.s		;I/O setup
#include ./mmap_SIMHC12.s		;RAM memory map
#include ../All/sstack.s		;Subroutine stack
#include ../All/istack.s		;Interrupt stack
#include ../All/tim.s			;TIM driver
#include ../All/sci.s			;SCI driver
#include ../All/string.s		;String printing routines
#include ../All/reset.s			;Reset driver
#include ../All/num.s	   		;Number printing routines
#include ./nvm_SIMHC12.s		;NVM driver
#include ./vectab_SIMHC12.s		;HC12A4 vector table
	


