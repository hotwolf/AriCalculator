;###############################################################################
;# S12CBase - SCI Test (LFBDMPGMR port)                                        #
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
;#   This module bundles the S12CBase framework into a single include file.    #
;###############################################################################
;# Required Modules:                                                           #
;#     REGDEF - Register Definitions                                           #
;#     VECTAB - Vector Table                                                   #
;#     GPIO   - GPIO Handler                                                   #
;#     MMAP   - Memory Map                                                     #
;#     ISTACK - Interrupt Stack Handler                                        #
;#     CLOCK  - Clock Driver                                                   #
;#     COP    - Watchdog Handler                                               #
;#     SSTACK - Subroutine Stack Handler                                       #
;#     LED    - LED Driver                                                     #
;#     TIM    - Timer Driver                                                   #
;#     SCI    - Serial Communication Interface Driver                          #
;#     PRINT  - Print Routines                                                 #
;#     ERROR  - Error Handler                                                  #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    May 31, 2010                                                             #
;#      - Call MMAP_INIT right at the reset entry point                        #
;#      - Changed definittion of BASE_CODE_END                                 #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Turns off functionality that hinders debugging.                  #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;  Memory Map:
;  -----------  
;        	 +-------------+ $0000
;  		 |  Registers  |
;  		 +-------------+ $0800
;  		 |/////////////|
;  		 +-------------+ $2000
;  		 |    Code     |
;  		 +-------------+ 
;  		 |   Tables    |
;  		 +-------------+ 
;  		 |  Variables  |
;  		 +-------------+ 
;  		 |             |
;  		 +-------------+ $3F10
;  		 |   Vectors   |
;  		 +-------------+ $4000

TEST_CODE_START		EQU	$2000
TEST_TABS_START		EQU	TEST_CODE_END
TEST_VARS_START		EQU	TEST_TABS_END
VECTAB			EQU	$3F10

ERROR_ISR		EQU	TEST_DUMMY_ISR
TVMON_ISR		EQU	TEST_DUMMY_ISR
BDM_ISR_TC7		EQU	TEST_DUMMY_ISR
BDM_ISR_TC6		EQU	TEST_DUMMY_ISR
	
BASE_ENTRY_COP		EQU	TEST_DUMMY_LOOP
BASE_ENTRY_CM		EQU	TEST_DUMMY_LOOP
BASE_ENTRY_EXT		EQU	TEST_DUMMY_LOOP

;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	TEST_VARS_START
	
MMAP_VARS_START		EQU	*
VECTAB_VARS_START	EQU	MMAP_VARS_END
GPIO_VARS_START		EQU	VECTAB_VARS_END
ISTACK_VARS_START	EQU	GPIO_VARS_END
CLOCK_VARS_START	EQU	ISTACK_VARS_END
COP_VARS_START		EQU	CLOCK_VARS_END
SSTACK_VARS_START	EQU	COP_VARS_END
LED_VARS_START		EQU	SSTACK_VARS_END
TIM_VARS_START		EQU	LED_VARS_END
SCI_VARS_START		EQU	TIM_VARS_END
	
TEST_VARS_END		EQU	SCI_VARS_END

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	TEST_INIT, 0
	MMAP_INIT	;must be done at reset entry
	VECTAB_INIT
	GPIO_INIT		
	ISTACK_INIT 	
	CLOCK_INIT	
	COP_INIT		
	SSTACK_INIT	
	LED_INIT		
	TIM_INIT

	CLOCK_WAIT_FOR_PLL

	SCI_INIT		
#emac

#macro	ERROR_MSG, 2
#emac
	
#macro	ERROR_RESTART, 1
	BRA	*
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	TEST_CODE_START

			TEST_INIT

TEST_LOOP		SCI_RX

			SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;SCI_TX
			;LDAB	#$0D
			;SCI_TX
			;LDAB	#$0A
			;SCI_TX
	
			COP_SERVICE
			JOB	TEST_LOOP
				
TEST_DUMMY_LOOP		BRA	*
TEST_DUMMY_ISR		RTI	

			ALIGN	$F
	
MMAP_CODE_START		EQU	*
VECTAB_CODE_START	EQU	MMAP_CODE_END
GPIO_CODE_START		EQU	VECTAB_CODE_END
ISTACK_CODE_START	EQU	GPIO_CODE_END
CLOCK_CODE_START	EQU	ISTACK_CODE_END
COP_CODE_START		EQU	CLOCK_CODE_END
SSTACK_CODE_START	EQU	COP_CODE_END
LED_CODE_START		EQU	SSTACK_CODE_END
TIM_CODE_START		EQU	LED_CODE_END
SCI_CODE_START		EQU	TIM_CODE_END

TEST_CODE_END		EQU	SCI_CODE_END	

;PRINT_CODE_START	EQU	SCI_CODE_END
;ERROR_CODE_START	EQU	PRINT_CODE_END
;BDM_CODE_START		EQU	ERROR_CODE_END
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	TEST_TABS_START

MMAP_TABS_START		EQU	*
VECTAB_TABS_START	EQU	MMAP_TABS_END
GPIO_TABS_START		EQU	VECTAB_TABS_END
ISTACK_TABS_START	EQU	GPIO_TABS_END
CLOCK_TABS_START	EQU	ISTACK_TABS_END
COP_TABS_START		EQU	CLOCK_TABS_END
SSTACK_TABS_START	EQU	COP_TABS_END
LED_TABS_START		EQU	SSTACK_TABS_END
TIM_TABS_START		EQU	LED_TABS_END
SCI_TABS_START		EQU	TIM_TABS_END

TEST_TABS_END		EQU	SCI_TABS_END

;PRINT_TABS_START	EQU	SCI_TABS_END
;ERROR_TABS_START	EQU	PRINT_TABS_END
;BDM_TABS_START		EQU	ERROR_TABS_END
;			ORG	BDM_TABS_END
;#ifndef	MAIN_NAME_STRING
;MAIN_NAME_STRING	FCS	"S12CBase for LFBDMPGMR"
;#endif
;
;#ifndef	MAIN_VERSION_STRING
;MAIN_VERSION_STRING	FCS	"V00.11"
;#endif
;	
;BASE_TABS_END		EQU	*
	
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include regdef.s	;register definitions
#include mmap.s		;memory map
#include vectab.s	;vector table
#include gpio.s		;general purpose I/O driver
#include istack.s	;interrupt stack
#include clock.s	;clock driver
#include cop.s		;watchdog driver
#include sstack.s	;subroutine stack
#include led.s		;LED driver
#include tim.s          ;timer driver
#include sci.s		;UART driver
