;###############################################################################
;# S12CBase - BASE - S12CBase Framework Bundle (SIMHC12 Version)               #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    This module bundles the S12CBase framework into a single include file.   #
;#    This version of BASE contains modifications to run on the SIM68HC12      #
;#    simulator.                                                               #
;###############################################################################
;# Required Modules:                                                           #
;#     REGDEF - Register Definitions                                           #
;#     VECTAB - Vector Table                                                   #
;#     GPIO   - GPIO Handler                                                   #
;#     MMAP   - Memory Map                                                     #
;#     ISTACK - Interrupt Stack Handler                                        #
;#     CLOCK  - Clock Driver                                                   #
;#     COP    - Watchdog Handler                                               #
;#     RTI    - Real-Time Interrupt Handler                                    #
;#     SSTACK - Subroutine Stack Handler                                       #
;#     LED    - LED Driver                                                     #
;#     TIM    - Timer Driver                                                   #
;#     SCI    - Serial Communication Interface Driver                          #
;#     PRINT  - Print Routines                                                 #
;#     ERROR  - Error Handler                                                  #
;#     BDM    - BDM Driver                                                     #
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
;#    DEBUG - Turns off functionality tha hinders debugging.                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
GPIO_VARS_START		EQU	BASE_VARS_START
MMAP_VARS_START		EQU	GPIO_VARS_END
ISTACK_VARS_START	EQU	MMAP_VARS_END
CLOCK_VARS_START	EQU	ISTACK_VARS_END
COP_VARS_START		EQU	CLOCK_VARS_END
RTI_VARS_START		EQU	COP_VARS_END
SSTACK_VARS_START	EQU	RTI_VARS_END
LED_VARS_START		EQU	SSTACK_VARS_END
TIM_VARS_START		EQU	LED_VARS_END
SCI_VARS_START		EQU	TIM_VARS_END
PRINT_VARS_START	EQU	SCI_VARS_END
ERROR_VARS_START	EQU	PRINT_VARS_END
BDM_VARS_START		EQU	ERROR_VARS_END
BASE_VARS_END		EQU	BDM_VARS_END

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	BASE_INIT, 0
	CLR	$0016		;disable cop
	;GPIO_INIT		
	;MMAP_INIT	;must be done at reset entry
	ISTACK_INIT 	
	;CLOCK_INIT	
	;COP_INIT		
	;RTI_INIT		
	SSTACK_INIT	
	;LED_INIT		
	;TIM_INIT
	PRINT_INIT	
	;BDM_INIT		
	;CLOCK_WAIT_FOR_PLL
	SCI_INIT		
	ERROR_INIT	
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
GPIO_CODE_START		EQU	BASE_CODE_START
MMAP_CODE_START		EQU	GPIO_CODE_END
ISTACK_CODE_START	EQU	MMAP_CODE_END
CLOCK_CODE_START	EQU	ISTACK_CODE_END
COP_CODE_START		EQU	CLOCK_CODE_END
RTI_CODE_START		EQU	COP_CODE_END
SSTACK_CODE_START	EQU	RTI_CODE_END
LED_CODE_START		EQU	SSTACK_CODE_END
TIM_CODE_START		EQU	LED_CODE_END
SCI_CODE_START		EQU	TIM_CODE_END
PRINT_CODE_START	EQU	SCI_CODE_END
ERROR_CODE_START	EQU	PRINT_CODE_END
BDM_CODE_START		EQU	ERROR_CODE_END
			ORG	BDM_CODE_END

			;COP reset entry
BASE_ENTRY_COP		MMAP_INIT
			ERROR_ENTRY_COP
			JOB	BASE_INIT
	
			;CM reset entry
BASE_ENTRY_CM		MMAP_INIT
			ERROR_ENTRY_CM
			JOB	BASE_INIT
	
			;External reset entry
BASE_ENTRY_EXT		MMAP_INIT
			ERROR_ENTRY_EXT
	
			;Initialize system			
BASE_INIT		BASE_INIT

			;Jump to application code 
#ifdef BASE_APP_START
			JOB	BASE_APP_START
BASE_CODE_END		EQU	*
#else
BASE_APP_START		EQU	*
BASE_CODE_END		EQU	BASE_APP_END
#endif
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
GPIO_TABS_START		EQU	BASE_TABS_START
MMAP_TABS_START		EQU	GPIO_TABS_END
ISTACK_TABS_START	EQU	MMAP_TABS_END
CLOCK_TABS_START	EQU	ISTACK_TABS_END
COP_TABS_START		EQU	CLOCK_TABS_END
RTI_TABS_START		EQU	COP_TABS_END
SSTACK_TABS_START	EQU	RTI_TABS_END
LED_TABS_START		EQU	SSTACK_TABS_END
TIM_TABS_START		EQU	LED_TABS_END
SCI_TABS_START		EQU	TIM_TABS_END
PRINT_TABS_START	EQU	SCI_TABS_END
ERROR_TABS_START	EQU	PRINT_TABS_END
BDM_TABS_START		EQU	ERROR_TABS_END
			ORG	BDM_TABS_END
#ifndef	MAIN_NAME_STRING
MAIN_NAME_STRING	FCS	"S12CBase"
#endif

#ifndef	MAIN_VERSION_STRING
MAIN_VERSION_STRING	FCS	"V00.05 (SIMHC12)"
#endif
	
BASE_TABS_END		EQU	*
	
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include regdef_simhc12.s	;register definitions
#include vectab_simhc12.s	;vector table
#include gpio.s			;general purpose I/O driver
#include mmap.s			;memory map
#include istack.s		;interrupt stack
#include clock.s		;clock driver
#include cop.s			;watchdog driver
#include rti.s			;RTI handler
#include sstack.s		;subroutine stack
#include led.s			;LED driver
#include tim.s          	;timer driver
#include sci.s			;UART friver
#include print_simhc12.s	;string output handler
#include error.s		;error handler
#include bdm.s			;BDM driver

;###############################################################################
;# Default mapping                                                             #
;###############################################################################
#ifndef	BASE_VARS_START
BASE_VARS_START		EQU	RAM_START
#endif

#ifndef	BASE_CODE_START
BASE_CODE_START		EQU	FLASH_START
#endif

#ifndef	BASE_TABS_START
BASE_TABS_START		EQU	FLASH_START+$2000
#endif
