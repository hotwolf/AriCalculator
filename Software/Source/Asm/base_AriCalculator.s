#ifndef	BASE
#define	BASE
;###############################################################################
;# S12CBase - Base Bundle (AriCalculator)                                      #
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
;#    This module bundles all standard S12CBase modules into one.              #
;###############################################################################
;# Version History:                                                            #
;#    January 7, 2015                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# TIM channel allocation                                                      #
;#      IC0:     SCI baud rate detection (capture posedges on RX pin)          #
;#      IC1:     SCI baud rate detection (capture negedges on RX pin)          #
;#      OC2:     SCI baud rate detection (timeout)                             #
;#      OC3:     SCI (timeout)                                                 #
;#      OC4:     KEYS (debounce delay)                                         #
;#      OC5:     LCD backlight PWM                                             #
;#      OC6:     LED (error signal)                                            #
;#      OC7:     unasigned                                                     #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# CLOCK
CLOCK_CPMU		EQU	1		;CPMU
CLOCK_IRC		EQU	1		;use IRC
CLOCK_OSC_FREQ		EQU	 1000000	; 1 MHz IRC frequency
CLOCK_BUS_FREQ		EQU	25000000	; 25 MHz bus frequency
CLOCK_REF_FREQ		EQU	 1000000	; 1 MHz reference clock frequency
CLOCK_VCOFRQ		EQU	$1		; 10 MHz VCO frequency
CLOCK_REFFRQ		EQU	$0		;  1 MHz reference clock frequency

;# ISTACK
ISTACK_LEVELS		EQU	4 		;max. interrupt nesting levels

;# TIM
TIM_OCPD_CHECK_ON	EQU	1 		;enable OCPD checks
	
;# SCI
SCI_RXTX_ACTHI		EQU	1 		;RXD/TXD are inverted (active high)
SCI_FC_RTSCTS		EQU	1 		;RTS/CTS flow control
SCI_RTS_PORT		EQU	PTM 		;PTM
SCI_RTS_PIN		EQU	PM0		;PM0
SCI_CTS_PORT		EQU	PTM 		;PTM
SCI_CTS_DDR		EQU	DDRM 		;DDRM
SCI_CTS_PPS		EQU	PPSM 		;PPSM
SCI_CTS_PIN		EQU	PM1		;PM1
SCI_CTS_WEAK_DRIVE	EQU	1		;weak CTS drive
SCI_DLY_OC		EQU	3		;delay timer OC3
SCI_BD_ON		EQU	1 		;use baud rate detection
SCI_BD_TIM		EQU	1 		;TIM
SCI_BD_ICPE		EQU	0		;RX posedge capture IC0
SCI_BD_ICNE		EQU	1		;RX negedge capture IC1	
SCI_BD_OC		EQU	2		;BD delay timer OC2	
SCI_BLOCKING_ON		EQU	1		;enable blocking subroutines

;# NUM
NUM_MAX_BASE_16		EQU	1 		;BASE<=16

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef BASE_VARS_START_LIN
			ORG 	BASE_VARS_START, BASE_VARS_START_LIN
#else
			ORG 	BASE_VARS_START
#endif	

MMAP_VARS_START		EQU	*	 
MMAP_VARS_START_LIN	EQU	@
			ORG	MMAP_VARS_END, MMAP_VARS_END_LIN
	
VECTAB_VARS_START	EQU	*
VECTAB_VARS_START_LIN	EQU	@
			ORG	VECTAB_VARS_END, VECTAB_VARS_END_LIN

GPIO_VARS_START		EQU	*
GPIO_VARS_START_LIN	EQU	@
			ORG	GPIO_VARS_END, GPIO_VARS_END_LIN

SSTACK_VARS_START	EQU	*
SSTACK_VARS_START_LIN	EQU	@
			ORG	SSTACK_VARS_END, SSTACK_VARS_END_LIN

ISTACK_VARS_START	EQU	*
ISTACK_VARS_START_LIN	EQU	@
			ORG	ISTACK_VARS_END, ISTACK_VARS_END_LIN

CLOCK_VARS_START	EQU	*
CLOCK_VARS_START_LIN	EQU	@
			ORG	CLOCK_VARS_END, CLOCK_VARS_END_LIN

COP_VARS_START		EQU	*
COP_VARS_START_LIN	EQU	@
			ORG	COP_VARS_END, COP_VARS_END_LIN

TIM_VARS_START		EQU	*
TIM_VARS_START_LIN	EQU	@
			ORG	TIM_VARS_END, TIM_VARS_END_LIN

SCI_VARS_START		EQU	*
SCI_VARS_START_LIN	EQU	@
			ORG	SCI_VARS_END, SCI_VARS_END_LIN

STRING_VARS_START	EQU	*
STRING_VARS_START_LIN	EQU	@
			ORG	STRING_VARS_END, STRING_VARS_END_LIN

NUM_VARS_START		EQU	*
NUM_VARS_START_LIN	EQU	@
			ORG	NUM_VARS_END, NUM_VARS_END_LIN
	
RESET_VARS_START	EQU	*
RESET_VARS_START_LIN	EQU	@
			ORG	RESET_VARS_END, RESET_VARS_END_LIN

LED_VARS_START		EQU	*
LED_VARS_START_LIN	EQU	@
			ORG	LED_VARS_END, LED_VARS_END_LIN

VMON_VARS_START	EQU	*
VMON_VARS_START_LIN	EQU	@
			ORG	VMON_VARS_END, VMON_VARS_END_LIN

NVM_VARS_START		EQU	*
NVM_VARS_START_LIN	EQU	@
			ORG	NVM_VARS_END, NVM_VARS_END_LIN
	
DISP_VARS_START		EQU	*
DISP_VARS_START_LIN	EQU	@
			ORG	DISP_VARS_END, DISP_VARS_END_LIN
	
KEYS_VARS_START		EQU	*
KEYS_VARS_START_LIN	EQU	@
			ORG	KEYS_VARS_END, KEYS_VARS_END_LIN
	
BASE_VARS_END		EQU	*	
BASE_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;--------------- 
#macro	BASE_INIT, 0
			;Urgent initialization
			GPIO_INIT	;urgent!
			COP_INIT	;urgent!
			CLOCK_INIT	;urgent!	
			;Initialization w/o PLL lock
			RESET_INIT
			MMAP_INIT
			VECTAB_INIT
			SSTACK_INIT
			ISTACK_INIT
			VMON_INIT	
			TIM_INIT
			LED_INIT
			KEYS_INIT
			SCI_INIT
			STRING_INIT
			NUM_INIT
			DISP_INIT
			;Show welcome/error screen on DISP
			RESET_BR_ERR	BASE_DISP_ERROR    
			BASE_DISP_WELCOME
			JOB	BASE_DISP_DONE
BASE_DISP_ERROR		BASE_DISP_ERROR  			
BASE_DISP_DONE		EQU	*
			;Wait for PLL lock
            		CLOCK_WAIT_FOR_PLL
			;Wait for voltage monitor
			VMON_WAIT_FOR_1ST_RESULTS
			;Send welcome/error message through 
			SCI_BR_DISABLED	BASE_SCI_DONE
			RESET_BR_ERR	BASE_SCI_ERROR 
			BASE_SCI_WELCOME
			JOB	BASE_SCI_DONE	
BASE_SCI_ERROR		BASE_SCI_ERROR				
BASE_SCI_DONE		EQU	*
#emac

;#Enable SCI error signaling
;--------------------------- 
#ifnmac SCI_ERRSIG_START
#macro	SCI_ERRSIG_START, 0
	;Signal error over LED
	LED_COMERR_ON	LED_NOP, LED_NOP
#emac
#endif	
#ifnmac SCI_ERRSIG_END
#macro	SCI_ERRSIG_END, 0
	;Stop signaling over LED
	LED_COMERR_OFF
#emac
#endif	
	
;#Enable SCI whenever USB is connected, disable otherwise
;-------------------------------------------------------- 
#ifnmac VMON_VUSB_LVACTION
#macro	VMON_VUSB_LVACTION, 0
	SCI_DISABLE
#emac
#endif	
#ifnmac VMON_VUSB_HVACTION
#macro	VMON_VUSB_HVACTION, 0
	SCI_ENABLE
#emac
#endif	

;#Welcome messages
;----------------- 
;#SCI
#macro	BASE_SCI_WELCOME, 0
			LDX	#BASE_SCI_WELCOME_MSG	;print welcome message
			STRING_PRINT_BL
#emac

;#DISP
#macro	BASE_DISP_WELCOME, 0
			LDX	#BASE_DISP_WELCOME_SCR
			LDY	#BASE_DISP_WELCOME_SIZE
			DISP_STREAM_BL
#emac
	
;#Error messages
;--------------- 
; args:   Y: error message 
;#SCI
#macro	BASE_SCI_ERROR, 0
			LDX	#BASE_SCI_ERROR_HEADER	;print error header
			STRING_PRINT_BL
			TFR	Y, X			;print error message
			STRING_PRINT_BL
			LDX	#BASE_SCI_ERROR_TRAILER	;print error TRAILER
			STRING_PRINT_BL
#emac

;#DISP
#macro	BASE_DISP_ERROR, 0
			LDX	#BASE_DISP_ERROR_SCR
			LDY	#BASE_DISP_ERROR_SIZE
			DISP_STREAM_BL
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef BASE_CODE_START_LIN
			ORG 	BASE_CODE_START, BASE_CODE_START_LIN
#else
			ORG 	BASE_CODE_START
#endif	

MMAP_CODE_START		EQU	*	 
MMAP_CODE_START_LIN	EQU	@
			ORG	MMAP_CODE_END, MMAP_CODE_END_LIN
	
VECTAB_CODE_START	EQU	*
VECTAB_CODE_START_LIN	EQU	@
			ORG	VECTAB_CODE_END, VECTAB_CODE_END_LIN
	
GPIO_CODE_START		EQU	*
GPIO_CODE_START_LIN	EQU	@
			ORG	GPIO_CODE_END, GPIO_CODE_END_LIN

SSTACK_CODE_START	EQU	*
SSTACK_CODE_START_LIN	EQU	@
			ORG	SSTACK_CODE_END, SSTACK_CODE_END_LIN

ISTACK_CODE_START	EQU	*
ISTACK_CODE_START_LIN	EQU	@
			ORG	ISTACK_CODE_END, ISTACK_CODE_END_LIN

CLOCK_CODE_START	EQU	*
CLOCK_CODE_START_LIN	EQU	@
			ORG	CLOCK_CODE_END, CLOCK_CODE_END_LIN

COP_CODE_START		EQU	*
COP_CODE_START_LIN	EQU	@
			ORG	COP_CODE_END, COP_CODE_END_LIN

TIM_CODE_START		EQU	*
TIM_CODE_START_LIN	EQU	@
			ORG	TIM_CODE_END, TIM_CODE_END_LIN

SCI_CODE_START		EQU	*
SCI_CODE_START_LIN	EQU	@
			ORG	SCI_CODE_END, SCI_CODE_END_LIN

STRING_CODE_START	EQU	*
STRING_CODE_START_LIN	EQU	@
			ORG	STRING_CODE_END, STRING_CODE_END_LIN

NUM_CODE_START		EQU	*
NUM_CODE_START_LIN	EQU	@
			ORG	NUM_CODE_END, NUM_CODE_END_LIN

RESET_CODE_START	EQU	*
RESET_CODE_START_LIN	EQU	@
			ORG	RESET_CODE_END, RESET_CODE_END_LIN
	
LED_CODE_START		EQU	*
LED_CODE_START_LIN	EQU	@
			ORG	LED_CODE_END, LED_CODE_END_LIN

VMON_CODE_START	EQU	*
VMON_CODE_START_LIN	EQU	@
			ORG	VMON_CODE_END, VMON_CODE_END_LIN
	
NVM_CODE_START		EQU	*
NVM_CODE_START_LIN	EQU	@
			ORG	NVM_CODE_END, NVM_CODE_END_LIN
	
DISP_CODE_START		EQU	*
DISP_CODE_START_LIN	EQU	@
			ORG	DISP_CODE_END, DISP_CODE_END_LIN
	
KEYS_CODE_START		EQU	*
KEYS_CODE_START_LIN	EQU	@
			ORG	KEYS_CODE_END, KEYS_CODE_END_LIN
	
BASE_CODE_END		EQU	*	
BASE_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef BASE_TABS_START_LIN
			ORG 	BASE_TABS_START, BASE_TABS_START_LIN
#else
			ORG 	BASE_TABS_START
#endif	

;#DISP screens
;-------------
;Welcome screen
BASE_DISP_WELCOME_SCR	DISP_WELCOME_STREAM 			;display splash screen
BASE_DISP_WELCOME_SIZE	EQU	*-BASE_DISP_WELCOME_SCR

;Error Screen
BASE_DISP_ERROR_SCR	DISP_ERROR_STREAM 			;display splash screen
BASE_DISP_ERROR_SIZE	EQU	*-BASE_DISP_ERROR_SCR

;#SCI messages	
;-------------
;Welcome message
BASE_SCI_WELCOME_MSG	FCC	"Hello, I'm  AriCalculator!"
			STRING_NL_TERM
;Error message format
BASE_SCI_ERROR_HEADER	FCS	"FATAL ERROR! "
BASE_SCI_ERROR_TRAILER	FCC	"!"
			STRING_NL_TERM

MMAP_TABS_START		EQU	*	 
MMAP_TABS_START_LIN	EQU	@
			ORG	MMAP_TABS_END, MMAP_TABS_END_LIN
	
VECTAB_TABS_START	EQU	*
VECTAB_TABS_START_LIN	EQU	@
			ORG	VECTAB_TABS_END, VECTAB_TABS_END_LIN
	
GPIO_TABS_START		EQU	*
GPIO_TABS_START_LIN	EQU	@
			ORG	GPIO_TABS_END, GPIO_TABS_END_LIN
	
SSTACK_TABS_START	EQU	*
SSTACK_TABS_START_LIN	EQU	@
			ORG	SSTACK_TABS_END, SSTACK_TABS_END_LIN

ISTACK_TABS_START	EQU	*
ISTACK_TABS_START_LIN	EQU	@
			ORG	ISTACK_TABS_END, ISTACK_TABS_END_LIN

CLOCK_TABS_START	EQU	*
CLOCK_TABS_START_LIN	EQU	@
			ORG	CLOCK_TABS_END, CLOCK_TABS_END_LIN

COP_TABS_START		EQU	*
COP_TABS_START_LIN	EQU	@
			ORG	COP_TABS_END, COP_TABS_END_LIN

TIM_TABS_START		EQU	*
TIM_TABS_START_LIN	EQU	@
			ORG	TIM_TABS_END, TIM_TABS_END_LIN

SCI_TABS_START		EQU	*
SCI_TABS_START_LIN	EQU	@
			ORG	SCI_TABS_END, SCI_TABS_END_LIN

STRING_TABS_START	EQU	*
STRING_TABS_START_LIN	EQU	@
			ORG	STRING_TABS_END, STRING_TABS_END_LIN

NUM_TABS_START		EQU	*
NUM_TABS_START_LIN	EQU	@
			ORG	NUM_TABS_END, NUM_TABS_END_LIN
	
RESET_TABS_START	EQU	*
RESET_TABS_START_LIN	EQU	@
			ORG	RESET_TABS_END, RESET_TABS_END_LIN
	
LED_TABS_START		EQU	*
LED_TABS_START_LIN	EQU	@
			ORG	LED_TABS_END, LED_TABS_END_LIN

VMON_TABS_START		EQU	*
VMON_TABS_START_LIN	EQU	@
			ORG	VMON_TABS_END, VMON_TABS_END_LIN

NVM_TABS_START		EQU	*
NVM_TABS_START_LIN	EQU	@
			ORG	NVM_TABS_END, NVM_TABS_END_LIN
	
DISP_TABS_START		EQU	*
DISP_TABS_START_LIN	EQU	@
			ORG	DISP_TABS_END, DISP_TABS_END_LIN
	
KEYS_TABS_START		EQU	*
KEYS_TABS_START_LIN	EQU	@
			ORG	KEYS_TABS_END, KEYS_TABS_END_LIN
	
BASE_TABS_END		EQU	*	
BASE_TABS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./sci_bdtab_AriCalculator.s							;Search tree for SCI baud rate detection
#include ./disp_welcome.s								;Welcome screen
#include ./disp_error.s									;Error screen
#include ./regdef_AriCalculator.s							;S12G register map
#include ./mmap_AriCalculator.s								;Memory map
#include ./vectab_AriCalculator.s							;S12G vector table
#include ./gpio_AriCalculator.s								;I/O setup
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sstack.s	;Subroutine stack
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/istack.s	;Interrupt stack
;#include ../../../../S12CBase/Source/All/clock.s					;!!!!!!!!!!!!!!!latest CPMU setup
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/clock.s		;CPMU setup
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/cop.s		;COP handler
#include ../../../../S12CBase/Source/All/tim.s						;!!!!!!!!!!!!!!!latest TIM setup
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/tim.s		;TIM driver
;#include ../../../../S12CBase/Source/All/sci.s						;!!!!!!!!!!!!!!!latest SCI setup
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sci.s		;SCI driver
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/string.s	;String printing routines
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/num.s	   	;Number printing routines
#include ../../../../S12CBase/Source/All/reset.s					;!!!!!!!!!!!!!!!latest RESET setup
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/reset.s		;Reset driver
#include ./led_AriCalculator.s								;LED driver
#include ./vmon_AriCalculator.s								;Voltage monitor
#include ./nvm_AriCalculator.s								;NVM driver
#include ./disp_AriCalculator.s								;NVM driver
#include ./keys_AriCalculator.s								;NVM driver
#endif
