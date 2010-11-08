;###############################################################################
;# BDM_TEST - BDM Driver Test                                                  #
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
BASE_VARS_END		EQU	ERROR_VARS_END

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	BASE_INIT, 0
	GPIO_INIT		
	;MMAP_INIT	;must be done at reset entry
	ISTACK_INIT 	
	CLOCK_INIT	
	COP_INIT		
	RTI_INIT		
	SSTACK_INIT	
	LED_INIT		
	TIM_INIT
	PRINT_INIT	
	;BDM_INIT		
	CLOCK_WAIT_FOR_PLL
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
			ORG	ERROR_CODE_END

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
			JOB	BASE_APP_START

	
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
			ORG	ERROR_TABS_END

#ifndef	MAIN_NAME_STRING
MAIN_NAME_STRING	FCS	"BDM Test"
#endif

#ifndef	MAIN_VERSION_STRING
MAIN_VERSION_STRING	FCS	"V00.00"
#endif
	
BASE_TABS_END		EQU	*

;###############################################################################
;# Default mapping                                                             #
;###############################################################################
BASE_VARS_START		EQU	RAM_START

BASE_CODE_START		EQU	FLASH_START

BASE_TABS_START		EQU	FLASH_START+$2000

;###############################################################################
;# BDM mapping                                                                 #
;###############################################################################
BDM_VARS_START		EQU	BASE_VARS_END

BDM_CODE_START		EQU	BDM_VARS_END

BDM_TABS_START		EQU	BDM_CODE_END

;###############################################################################
;# Test code                                                                   #
;###############################################################################
			ORG	$3C00
BASE_APP_START		EQU	*
			;Initialize driver
			BDM_INIT

			;Test
			LDD	#128
			BDM_SET_SPEED

			LBRA	*

			ORG	$3FF0
BDM_TEST_ISR_TGTRST	JMP	BDM_ISR_TGTRST
BDM_TEST_ISR_TC7	JMP	BDM_ISR_TC7
BDM_TEST_ISR_TC6	JMP	BDM_ISR_TC6
BDM_TEST_ISR_TC5	JMP	BDM_ISR_TC5
	
;###############################################################################
;# Vector map                                                                  #
;###############################################################################
		ORG	$FF80
VEC_RESERVED80	DW	ERROR_ISR
VEC_RESERVED82	DW	ERROR_ISR
VEC_RESERVED84	DW	ERROR_ISR
VEC_RESERVED86	DW	ERROR_ISR
VEC_RESERVED88	DW	ERROR_ISR
VEC_LVI		DW	ERROR_ISR
VEC_PWM		DW	ERROR_ISR
VEC_PORTP	DW	BDM_TEST_ISR_TGTRST
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
VEC_TC7		DW	BDM_TEST_ISR_TC7
VEC_TC6		DW	BDM_TEST_ISR_TC6
VEC_TC5		DW	BDM_TEST_ISR_TC5
VEC_TC4		DW	ERROR_ISR
VEC_TC3		DW	ERROR_ISR
VEC_TC2		DW	SCI_ISR_TC2
VEC_TC1		DW	SCI_ISR_TC1
VEC_TC0		DW	SCI_ISR_TC0
VEC_RTI		DW	LED_ISR
VEC_IRQ		DW	ERROR_ISR
VEC_XIRQ	DW	ERROR_ISR
VEC_SWI		DW	ERROR_ISR
VEC_TRAP	DW	ERROR_ISR
VEC_RESET_COP	DW	BASE_ENTRY_COP
VEC_RESET_CM	DW	BASE_ENTRY_CM
VEC_RESET_EXT	DW	BASE_ENTRY_EXT

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Source/regdef.s	;register definitions
#include ../Source/gpio.s	;general purpose I/O driver
#include ../Source/mmap.s	;memory map
#include ../Source/istack.s	;interrupt stack
#include ../Source/clock.s	;clock driver
#include ../Source/cop.s	;watchdog driver
#include ../Source/rti.s	;RTI handler
#include ../Source/sstack.s	;subroutine stack
#include ../Source/led.s	;LED driver
#include ../Source/tim.s        ;timer driver
#include ../Source/sci.s	;UART friver
#include ../Source/print.s	;string output handler
#include ../Source/error.s	;error handler
#include ../Source/bdm.s	;BDM driver


