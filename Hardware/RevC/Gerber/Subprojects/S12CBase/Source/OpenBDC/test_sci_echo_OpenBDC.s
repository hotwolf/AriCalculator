;###############################################################################
;# S12CBase - SCI Test (OpenBDC Pod)                                           #
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
;#    This demo application transmits each byte it receives via the SCI.       #
;#                                                                             #
;# Usage:                                                                      #
;#    1. Place the RAM onto the vector space                                   #
;#       $FF -> INITRM                                                         #
;#    2. Upload S-Record                                                       #
;#    3. Execute code at address "START_OF_CODE"                               #
;###############################################################################
;# Version History:                                                            #
;#    July 3, 2012                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# Clocks
CLOCK_CRG		EQU	1		;old CRG
CLOCK_OSC_FREQ		EQU	4096000		;4,096 MHz
CLOCK_BUS_FREQ		EQU	25000000	;25 MHz
CLOCK_REF_FREQ		EQU	4096000		;4,096 MHz

;# Memory map
MMAP_RAM		EQU	1 		;use RAM memory map
MMAP_S12C128		EQU	1		;complie for S12S128
;MMAP_S12C32		EQU	1		;complile for S12C32

;# Interrupt stack
ISTACK_LEVELS		EQU	1	 	;no interrupt nesting
ISTACK_DEBUG		EQU	1 		;don't enter wait mode

;# Subroutine stack
SSTACK_DEPTH		EQU	24	 	;no interrupt nesting
SSTACK_DEBUG		EQU	1 		;debug behavior

;# COP
COP_DEBUG		EQU	1 		;disable COP

;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs

;# SCI
SCI_FC_RTS_CTS		EQU	1 		;RTS/CTS flow control
SCI_RTS_PORT		EQU	PTM 		;PTM
SCI_RTS_PIN		EQU	PM0		;PM0
SCI_CTS_PORT		EQU	PTM 		;PTM
SCI_CTS_PIN		EQU	PM1		;PM1
SCI_HANDLE_BREAK	EQU	1		;react to BREAK symbol
SCI_HANDLE_SUSPEND	EQU	1		;react to SUSPEND symbol
SCI_BD_ON		EQU	1 		;use baud rate detection
SCI_BD_TIM		EQU	1 		;TIM
SCI_BD_ICPE		EQU	0		;IC0
SCI_BD_ICNE		EQU	1		;IC1			
SCI_BD_OC		EQU	2		;OC2			
SCI_DLY_OC		EQU	3		;OC3
SCI_ERRSIG_ON		EQU	1 		;signal errors

;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START
;Code
START_OF_CODE		EQU	*	
TEST_CODE_START		EQU	*
TEST_CODE_START_LIN	EQU	@

GPIO_CODE_START		EQU	TEST_CODE_END
GPIO_CODE_START_LIN	EQU	TEST_CODE_END_LIN

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

RTI_CODE_START		EQU	COP_CODE_END
RTI_CODE_START_LIN	EQU	COP_CODE_END_LIN

LED_CODE_START		EQU	RTI_CODE_END
LED_CODE_START_LIN	EQU	RTI_CODE_END_LIN

TIM_CODE_START		EQU	LED_CODE_END
TIM_CODE_START_LIN	EQU	LED_CODE_END_LIN

SCI_CODE_START		EQU	TIM_CODE_END
SCI_CODE_START_LIN	EQU	TIM_CODE_END_LIN

VECTAB_CODE_START	EQU	SCI_CODE_END
VECTAB_CODE_START_LIN	EQU	SCI_CODE_END_LIN

;Variables
TEST_VARS_START		EQU	VECTAB_CODE_END
TEST_VARS_START_LIN	EQU	VECTAB_CODE_END_LIN
	
GPIO_VARS_START		EQU	TEST_VARS_END
GPIO_VARS_START_LIN	EQU	TEST_VARS_END_LIN

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

RTI_VARS_START		EQU	COP_VARS_END
RTI_VARS_START_LIN	EQU	COP_VARS_END_LIN

LED_VARS_START		EQU	RTI_VARS_END
LED_VARS_START_LIN	EQU	RTI_VARS_END_LIN

TIM_VARS_START		EQU	LED_VARS_END
TIM_VARS_START_LIN	EQU	LED_VARS_END_LIN

SCI_VARS_START		EQU	TIM_VARS_END
SCI_VARS_START_LIN	EQU	TIM_VARS_END_LIN

VECTAB_VARS_START	EQU	SCI_VARS_END
VECTAB_VARS_START_LIN	EQU	SCI_VARS_END_LIN

;Tables
TEST_TABS_START		EQU	VECTAB_VARS_END
TEST_TABS_START_LIN	EQU	VECTAB_VARS_END_LIN
	
GPIO_TABS_START		EQU	TEST_TABS_END
GPIO_TABS_START_LIN	EQU	TEST_TABS_END_LIN

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

RTI_TABS_START		EQU	COP_TABS_END
RTI_TABS_START_LIN	EQU	COP_TABS_END_LIN

LED_TABS_START		EQU	RTI_TABS_END
LED_TABS_START_LIN	EQU	RTI_TABS_END_LIN

TIM_TABS_START		EQU	LED_TABS_END
TIM_TABS_START_LIN	EQU	LED_TABS_END_LIN

SCI_TABS_START		EQU	TIM_TABS_END
SCI_TABS_START_LIN	EQU	TIM_TABS_END_LIN

VECTAB_TABS_START	EQU	SCI_TABS_END
VECTAB_TABS_START_LIN	EQU	SCI_TABS_END_LIN

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./regdef_OpenBDC.s		;S12C128 register map
#include ./gpio_OpenBDC.s		;I/O setup
#include ./mmap_OpenBDC.s		;RAM memory map
#include ../All/sstack.s		;Subroutine stack
#include ../All/istack.s		;Interrupt stack
#include ../All/clock.s			;CRG setup
#include ../All/cop.s			;COP handler
#include ./rti_OpenBDC.s		;RTI setup
#include ./led_OpenBDC.s		;LED driver
#include ../All/tim.s			;TIM driver
#include ./sci_bdtab_OpenBDC.s		;Search tree for SCI baud rate detection
#include ../All/sci.s			;SCI driver
#include ./vectab_OpenBDC.s		;S12C128 vector table
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	TEST_VARS_START, TEST_VARS_START_LIN

TEST_VARS_END		EQU	*
TEST_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
#macro DELAY, 0
			LDX	#$0010
OUTER_LOOP		LDY	#$0000
INNER_LOOP		DBNE	Y, INNER_LOOP
			DBNE	X, OUTER_LOOP
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG 	TEST_CODE_START, TEST_CODE_START_LIN

;Initialization
			GPIO_INIT
			CLOCK_INIT
			COP_INIT
			MMAP_INIT
			VECTAB_INIT
			ISTACK_INIT
			RTI_INIT
			TIM_INIT
			CLOCK_WAIT_FOR_PLL
			SCI_INIT	

	
;Application code
TEST_LOOP		SCI_RX_BL
			DELAY
			SCI_TX_BL
			JOB	TEST_LOOP
;Break handler
#macro	SCI_BREAK_ACTION, 0
			LED_BUSY_ON
#emac
	
;Suspend handler
#macro	SCI_SUSPEND_ACTION, 0
			LED_BUSY_OFF
#emac

	
TEST_CODE_END		EQU	*	
TEST_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	TEST_TABS_START, TEST_TABS_START_LIN

TEST_TABS_END		EQU	*	
TEST_TABS_END_LIN	EQU	@	




