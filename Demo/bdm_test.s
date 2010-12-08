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
DEBUG     		EQU	1

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;# Memory Sizes:
REG_SIZE		EQU	$0400
;S12C128
RAM_SIZE		EQU	$1000
FLASH_SIZE		EQU	$20000
;S12C32	
;RAM_SIZE		EQU	$800
;FLASH_SIZE		EQU	$8000

;# Memory Locations
REG_START		EQU	$0000
REG_END			EQU	REG_START+REG_SIZE

RAM_START		EQU	$F000
RAM_END			EQU	$10000

FLASH_START		EQU	$C000
FLASH_END		EQU	$10000
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
GPIO_VARS_START		EQU	BASE_VARS_START
ISTACK_VARS_START	EQU	GPIO_VARS_END
CLOCK_VARS_START	EQU	ISTACK_VARS_END
COP_VARS_START		EQU	CLOCK_VARS_END
RTI_VARS_START		EQU	COP_VARS_END
SSTACK_VARS_START	EQU	RTI_VARS_END
TIM_VARS_START		EQU	SSTACK_VARS_END
BDM_VARS_START		EQU	TIM_VARS_END
BASE_VARS_END		EQU	BDM_VARS_END

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	BASE_INIT, 0
	GPIO_INIT		
	ISTACK_INIT 	
	CLOCK_INIT	
	COP_INIT		
	RTI_INIT		
	SSTACK_INIT	
	TIM_INIT
	BDM_INIT		
	CLOCK_WAIT_FOR_PLL	
#emac

#macro	ERROR_PRINT, 0
	NOP
#emac

#macro	ERROR_MSG, 2
	NOP
#emac

#macro	ERROR_RESTART, 1
	NOP
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
GPIO_CODE_START		EQU	BASE_CODE_START
ISTACK_CODE_START	EQU	GPIO_CODE_END
CLOCK_CODE_START	EQU	ISTACK_CODE_END
COP_CODE_START		EQU	CLOCK_CODE_END
RTI_CODE_START		EQU	COP_CODE_END
SSTACK_CODE_START	EQU	RTI_CODE_END
TIM_CODE_START		EQU	SSTACK_CODE_END
BDM_CODE_START		EQU	TIM_CODE_END
			ORG	BDM_CODE_END
			;COP reset entry
BASE_ENTRY_COP
BASE_ENTRY_CM
BASE_ENTRY_EXT		MOVW	#((RAM_START&$FE00)|(REG_START>>8)), INITRM
			;JOB	BASE_INIT
	
			;Initialize system			
BASE_INIT		BASE_INIT
			;JOB	BASE_APP_START

BASE_APP_START		EQU	*
			;Initialize driver
			BDM_INIT
			LDD	#128
			BDM_SET_SPEED

                        BGND

			;Test
TEST                    BDM_SYNC

			LBRA	TEST1

BASE_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
GPIO_TABS_START		EQU	BASE_TABS_START
ISTACK_TABS_START	EQU	GPIO_TABS_END
CLOCK_TABS_START	EQU	ISTACK_TABS_END
COP_TABS_START		EQU	CLOCK_TABS_END
RTI_TABS_START		EQU	COP_TABS_END
SSTACK_TABS_START	EQU	RTI_TABS_END
TIM_TABS_START		EQU	SSTACK_TABS_END
BDM_TABS_START		EQU	TIM_TABS_END
			ORG	BDM_TABS_END

#ifndef	MAIN_NAME_STRING
MAIN_NAME_STRING	EQU	0
#endif

#ifndef	MAIN_VERSION_STRING
MAIN_VERSION_STRING	EQU	0
#endif
	
BASE_TABS_END		EQU	*

;###############################################################################
;# Default mapping                                                             #
;###############################################################################
BASE_VARS_START		EQU	RAM_START

BASE_CODE_START		EQU	BASE_VARS_END

BASE_TABS_START		EQU	BASE_CODE_END
	
;###############################################################################
;# Vector map                                                                  #
;###############################################################################

		ORG	$F000
ISR_VEC_RESERVED80	BRA	*
ISR_VEC_RESERVED82	BRA	*
ISR_VEC_RESERVED84	BRA	*
ISR_VEC_RESERVED86	BRA	*
ISR_VEC_RESERVED88	BRA	*
ISR_VEC_LVI		BRA	*
ISR_VEC_PWM		BRA	*
ISR_VEC_PORTP   	BRA	*
ISR_VEC_RESERVED90	BRA	*
ISR_VEC_RESERVED92	BRA	*
ISR_VEC_RESERVED94	BRA	*
ISR_VEC_RESERVED96	BRA	*
ISR_VEC_RESERVED98	BRA	*
ISR_VEC_RESERVED9A	BRA	*
ISR_VEC_RESERVED9C	BRA	*
ISR_VEC_RESERVED9E	BRA	*
ISR_VEC_RESERVEDA0	BRA	*
ISR_VEC_RESERVEDA2	BRA	*
ISR_VEC_RESERVEDA4	BRA	*
ISR_VEC_RESERVEDA6	BRA	*
ISR_VEC_RESERVEDA8	BRA	*
ISR_VEC_RESERVEDAA	BRA	*
ISR_VEC_RESERVEDAC	BRA	*
ISR_VEC_RESERVEDAE	BRA	*
ISR_VEC_CANTX   	BRA	*
ISR_VEC_CANRX   	BRA	*
ISR_VEC_CANERR   	BRA	*
ISR_VEC_CANWUP   	BRA	*
ISR_VEC_FLASH   	BRA	*
ISR_VEC_RESERVEDBA	BRA	*
ISR_VEC_RESERVEDBC	BRA	*
ISR_VEC_RESERVEDBE	BRA	*
ISR_VEC_RESERVEDC0	BRA	*
ISR_VEC_RESERVEDC2	BRA	*
ISR_VEC_SCM		BRA	*
ISR_VEC_PLLLOCK  	BRA	*
ISR_VEC_RESERVEDC8	BRA	*
ISR_VEC_RESERVEDCA	BRA	*
ISR_VEC_RESERVEDCC	BRA	*
ISR_VEC_PORTJ    	BRA	*
ISR_VEC_RESERVEDD0	BRA	*
ISR_VEC_ATD		BRA	*
ISR_VEC_RESERVEDD4	BRA	*
ISR_VEC_SCI		BRA	*
ISR_VEC_SPI		BRA	*
ISR_VEC_PAIE     	BRA	*
ISR_VEC_PAOV     	BRA	*
ISR_VEC_TOV		BRA	*
ISR_VEC_TC7		BRA	*
ISR_VEC_TC6		BRA	*
ISR_VEC_TC5		BRA	*
ISR_VEC_TC4		BRA	*
ISR_VEC_TC3		BRA	*
ISR_VEC_TC2		BRA	*
ISR_VEC_TC1		BRA	*
ISR_VEC_TC0		BRA	*
ISR_VEC_RTI		BRA	*
ISR_VEC_IRQ		BRA	*
ISR_VEC_XIRQ	        BRA	*
ISR_VEC_SWI		BRA	*
ISR_VEC_TRAP     	BRA	*
ISR_VEC_RESET_COP	BRA	*
ISR_VEC_RESET_CM	BRA	*
ISR_VEC_RESET_EXT	BRA	*

		ORG	$FF80
VEC_RESERVED80	DW	ISR_VEC_RESERVED80	
VEC_RESERVED82	DW	ISR_VEC_RESERVED82	
VEC_RESERVED84	DW	ISR_VEC_RESERVED84	
VEC_RESERVED86	DW	ISR_VEC_RESERVED86	
VEC_RESERVED88	DW	ISR_VEC_RESERVED88	
VEC_LVI		DW	ISR_VEC_LVI		
VEC_PWM		DW	ISR_VEC_PWM		
VEC_PORTP	DW	BDM_ISR_TGTRST
VEC_RESERVED90	DW	ISR_VEC_RESERVED90	
VEC_RESERVED92	DW	ISR_VEC_RESERVED92	
VEC_RESERVED94	DW	ISR_VEC_RESERVED94	
VEC_RESERVED96	DW	ISR_VEC_RESERVED96	
VEC_RESERVED98	DW	ISR_VEC_RESERVED98	
VEC_RESERVED9A	DW	ISR_VEC_RESERVED9A	
VEC_RESERVED9C	DW	ISR_VEC_RESERVED9C	
VEC_RESERVED9E	DW	ISR_VEC_RESERVED9E	
VEC_RESERVEDA0	DW	ISR_VEC_RESERVEDA0	
VEC_RESERVEDA2	DW	ISR_VEC_RESERVEDA2	
VEC_RESERVEDA4	DW	ISR_VEC_RESERVEDA4	
VEC_RESERVEDA6	DW	ISR_VEC_RESERVEDA6	
VEC_RESERVEDA8	DW	ISR_VEC_RESERVEDA8	
VEC_RESERVEDAA	DW	ISR_VEC_RESERVEDAA	
VEC_RESERVEDAC	DW	ISR_VEC_RESERVEDAC	
VEC_RESERVEDAE	DW	ISR_VEC_RESERVEDAE	
VEC_CANTX	DW	ISR_VEC_CANTX
VEC_CANRX	DW	ISR_VEC_CANRX
VEC_CANERR	DW	ISR_VEC_CANERR
VEC_CANWUP	DW	ISR_VEC_CANWUP
VEC_FLASH	DW	ISR_VEC_FLASH
VEC_RESERVEDBA	DW	ISR_VEC_RESERVEDBA
VEC_RESERVEDBC	DW	ISR_VEC_RESERVEDBC
VEC_RESERVEDBE	DW	ISR_VEC_RESERVEDBE
VEC_RESERVEDC0	DW	ISR_VEC_RESERVEDC0
VEC_RESERVEDC2	DW	ISR_VEC_RESERVEDC2
VEC_SCM		DW	ISR_VEC_SCM	  
VEC_PLLLOCK	DW	CLOCK_ISR
VEC_RESERVEDC8	DW	ISR_VEC_RESERVEDC8
VEC_RESERVEDCA	DW	ISR_VEC_RESERVEDCA
VEC_RESERVEDCC	DW	ISR_VEC_RESERVEDCC
VEC_PORTJ	DW	ISR_VEC_PORTJ     
VEC_RESERVEDD0	DW	ISR_VEC_RESERVEDD0
VEC_ATD		DW	ISR_VEC_ATD	      
VEC_RESERVEDD4	DW	ISR_VEC_RESERVEDD4
VEC_SCI		DW	ISR_VEC_SCI
VEC_SPI		DW	ISR_VEC_SPI 
VEC_PAIE	DW	ISR_VEC_PAIE
VEC_PAOV	DW	ISR_VEC_PAOV
VEC_TOV		DW	ISR_VEC_TOV 
VEC_TC7		DW	BDM_ISR_TC7
VEC_TC6		DW	BDM_ISR_TC6
VEC_TC5		DW	BDM_ISR_TC5
VEC_TC4		DW	ISR_VEC_TC4
VEC_TC3		DW	ISR_VEC_TC3
VEC_TC2		DW	ISR_VEC_TC2
VEC_TC1		DW	ISR_VEC_TC1
VEC_TC0		DW	ISR_VEC_TC0
VEC_RTI		DW	ISR_VEC_RTI
VEC_IRQ		DW	ISR_VEC_IRQ 
VEC_XIRQ	DW	ISR_VEC_XIRQ
VEC_SWI		DW	ISR_VEC_SWI 
VEC_TRAP	DW	ISR_VEC_TRAP
VEC_RESET_COP	DW	BASE_ENTRY_COP
VEC_RESET_CM	DW	BASE_ENTRY_CM
VEC_RESET_EXT	DW	BASE_ENTRY_EXT

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Source/regdef.s	;register definitions
#include ../Source/gpio.s	;general purpose I/O driver
;#include ../Source/mmap.s	;memory map
#include ../Source/istack.s	;interrupt stack
#include ../Source/clock.s	;clock driver
#include ../Source/cop.s	;watchdog driver
#include ../Source/rti.s	;RTI handler
#include ../Source/sstack.s	;subroutine stack
;#include ../Source/led.s	;LED driver
#include ../Source/tim.s        ;timer driver
;#include ../Source/sci.s	;UART friver
;#include ../Source/print.s	;string output handler
;#include ../Source/error.s	;error handler
#include ../Source/bdm.s	;BDM driver


