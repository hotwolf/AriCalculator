#ifndef	BASE_COMPILED
#define	BASE_COMPILED
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
;#    May 17, 2017                                                             #
;#      - Clean up                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;#Core
				CPU	S12

;#CLOCK
CLOCK_CPMU			EQU	1		;CPMU
CLOCK_IRC			EQU	1		;use IRC
CLOCK_OSC_FREQ			EQU	 1000000	; 1 MHz IRC frequency
CLOCK_BUS_FREQ			EQU	25000000	;25 MHz bus frequency
CLOCK_REF_FREQ			EQU	 1000000	; 1 MHz reference clock frequency
CLOCK_VCOFRQ			EQU	$1		;10 MHz VCO frequency
CLOCK_REFFRQ			EQU	$0		; 1 MHz reference clock frequency
	
;#TIM				
; IC0 - SCI (baud rate detection)			;SCI driver
; OC1 - SCI (general purpose)				;SCI driver
; OC2 - DELAY						;delay driver
; OC3 - LED						;red/green LED driver 
; OC4 - KEYS						;keypad driver
; OC5 - BACKLIGHT 					;LCD backlight driver
; OC6 - free
; OC7 - free
BASE_TIOS_INIT			EQU	SCI_OC_TIOS_INIT|DELAY_TIOS_INIT|LED_TIOS_INIT|KEYS_TIOS_INIT|BACKLIGHT_TIOS_INIT
BASE_TTOV_INIT			EQU	BACKLIGHT_TTOV_INIT	
BASE_TCTL12_INIT		EQU	BACKLIGHT_TCTL12_INIT	
BASE_TCTL34_INIT		EQU	SCI_IC_TCTL34_INIT
#ifndef	TIM_TIOS_INIT
TIM_TIOS_INIT			EQU	BASE_TIOS_INIT	
#endif
#ifndef	TIM_TTOV_INIT
TIM_TTOV_INIT			EQU	BASE_TTOV_INIT	
#endif
#ifndef	TIM_TCTL12_INIT
TIM_TCTL12_INIT			EQU	BASE_TCTL12_INIT	
#endif
#ifndef	TIM_TCTL34_INIT
TIM_TCTL34_INIT			EQU	BASE_TCTL34_INIT	
#endif
TIM_OCPD_CHECK_ON		EQU	1 		;enable OCPD checks (required for PWM outputs)

;#LED
; LED A: PE0 blinking     -> busy  (green)
; LED B: PE1 blinking     -> error (red)
; Timer usage 
LED_TIM				EQU	TIM 		;TIM
LED_OC				EQU	3 		;OC3
; LED A							
LED_A_BLINK_ON			EQU	1 		;no blink patterns
LED_A_PORT			EQU	PORTE 		;port E
LED_A_PIN			EQU	PE0 		;PE0
; LED B							
LED_B_BLINK_ON			EQU	1 		;no blink patterns
LED_B_PORT			EQU	PORTE 		;port E
LED_B_PIN			EQU	PE1 		;PE1

;#BACKLIGHT

;#DELAY
DELAY_TIM			EQU	TIM 		;TIM
DELAY_OC			EQU	2		;OC2

;#KEYS
	
;#SCI							
SCI_V5				EQU	1   		;V5
SCI_BAUD_9600			EQU	1 		;fixed baud rate
SCI_BAUD_DETECT_ON		EQU	1		;enable baud rate detection
SCI_IC_TIM			EQU	TIM 		;ECT
SCI_IC				EQU	0 		;IC0
SCI_OC_TIM			EQU	TIM 		;ECT
SCI_OC				EQU	1 		;OC1
SCI_RTSCTS			EQU	1		;RTS/CTS flow control
SCI_RTS_PORT			EQU	PTM 		;PTM
SCI_RTS_PIN			EQU	PM0		;PM0
SCI_CTS_PORT			EQU	PTM 		;PTM
SCI_CTS_DDR			EQU	DDRM 		;DDRM
SCI_CTS_PPS			EQU	PPSM 		;PPSM
SCI_CTS_PIN			EQU	PM1		;PM1
#ifndef	SCI_CTS_WEAK_DRIVE				
#ifndef	SCI_CTS_STRONG_DRIVE				
SCI_CTS_STRONG_DRIVE		EQU	1		;weak drive
#endif
#endif
#macro SCI_BDSIG_START, 0
#emac
#macro SCI_BDSIG_STOP, 0
				LED_CLR	B, LED_SEQ_L0NG_PULSE	;stop single gap on red LED
#emac
#macro SCI_ERRSIG_START, 0
				LED_SET	B, LED_SEQ_FAST_BLINK	;start fast blink on red LED
#emac
#macro SCI_ERRSIG_STOP, 0
				LED_CLR	B, LED_SEQ_FAST_BLINK	;stop fast blink on red LED
#emac
	
;DISP							

;VMON							


	
	

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef BASE_VARS_START_LIN
				ORG 	BASE_VARS_START, BASE_VARS_START_LIN
#else				
				ORG 	BASE_VARS_START
#endif				
				
GPIO_VARS_START			EQU	*
GPIO_VARS_START_LIN		EQU	@
				ORG	GPIO_VARS_END, GPIO_VARS_END_LIN

MMAP_VARS_START			EQU	*	 
MMAP_VARS_START_LIN		EQU	@
				ORG	MMAP_VARS_END, MMAP_VARS_END_LIN
				
SSTACK_VARS_START		EQU	*
SSTACK_VARS_START_LIN		EQU	@
				ORG	SSTACK_VARS_END, SSTACK_VARS_END_LIN
				
ISTACK_VARS_START		EQU	*
ISTACK_VARS_START_LIN		EQU	@
				ORG	ISTACK_VARS_END, ISTACK_VARS_END_LIN
				
CLOCK_VARS_START		EQU	*
CLOCK_VARS_START_LIN		EQU	@
				ORG	CLOCK_VARS_END, CLOCK_VARS_END_LIN
				
COP_VARS_START			EQU	*
COP_VARS_START_LIN		EQU	@
				ORG	COP_VARS_END, COP_VARS_END_LIN
				
TIM_VARS_START			EQU	*
TIM_VARS_START_LIN		EQU	@
				ORG	TIM_VARS_END, TIM_VARS_END_LIN
				
SCI_VARS_START			EQU	*
SCI_VARS_START_LIN		EQU	@
				ORG	SCI_VARS_END, SCI_VARS_END_LIN
				
STRING_VARS_START		EQU	*
STRING_VARS_START_LIN		EQU	@
				ORG	STRING_VARS_END, STRING_VARS_END_LIN
				
NUM_VARS_START			EQU	*
NUM_VARS_START_LIN		EQU	@
				ORG	NUM_VARS_END, NUM_VARS_END_LIN
				
RESET_VARS_START		EQU	*
RESET_VARS_START_LIN		EQU	@
				ORG	RESET_VARS_END, RESET_VARS_END_LIN
				
LED_VARS_START			EQU	*
LED_VARS_START_LIN		EQU	@
				ORG	LED_VARS_END, LED_VARS_END_LIN
				
VMON_VARS_START			EQU	*
VMON_VARS_START_LIN		EQU	@
				ORG	VMON_VARS_END, VMON_VARS_END_LIN
				
NVM_VARS_START			EQU	*
NVM_VARS_START_LIN		EQU	@
				ORG	NVM_VARS_END, NVM_VARS_END_LIN
				
RANDOM_VARS_START		EQU	*
RANDOM_VARS_START_LIN		EQU	@
				ORG	RANDOM_VARS_END, RANDOM_VARS_END_LIN
				
DELAY_VARS_START		EQU	*
DELAY_VARS_START_LIN		EQU	@
				ORG	DELAY_VARS_END, DELAY_VARS_END_LIN

DISP_VARS_START			EQU	*
DISP_VARS_START_LIN		EQU	@
				ORG	DISP_VARS_END, DISP_VARS_END_LIN
				
KEYS_VARS_START			EQU	*
KEYS_VARS_START_LIN		EQU	@
				ORG	KEYS_VARS_END, KEYS_VARS_END_LIN
				
BACKLIGHT_VARS_START		EQU	*
BACKLIGHT_VARS_START_LIN	EQU	@
				ORG	BACKLIGHT_VARS_END, BACKLIGHT_VARS_END_LIN
				
VECTAB_VARS_START		EQU	*
VECTAB_VARS_START_LIN		EQU	@
				ORG	VECTAB_VARS_END, VECTAB_VARS_END_LIN

BASE_VARS_END			EQU	*	
BASE_VARS_END_LIN		EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Error message
;-------------- 
#ifnmac	ERROR_MESSAGE
#macro	ERROR_MESSAGE, 0
				;VMON_VUSB_BRLV	DONE 		;no terminal connected
				RESET_BR_NOERR	DONE		;no error detected 
				SCI_CHECK_BAUD_BL		;determine baud rate first
				LDX	#ERROR_HEADER		;print error header
				STRING_PRINT_BL
				TFR	Y, X			;print error message
				STRING_PRINT_BL
				LDX	#ERROR_TRAILER		;print error TRAILER
				STRING_PRINT_BL
DONE				EQU	*
#emac
#endif

;#Error message
;-------------- 
#ifnmac	SPLASH_SCREEN
#macro	SPLASH_SCREEN, 0
				;Show welcome or error screen on DISP
				RESET_BR_ERR	SPLASH_SCREEN_ERROR    
				BASE_DISP_WELCOME
				JOB	DONE
SPLASH_SCREEN_ERROR		BASE_DISP_ERROR  			
SPLASH_SCREEN_DONE		EQU	*
				;Wait for PLL lock
DONE				EQU	*
#emac
#endif
	
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
				BACKLIGHT_INIT
				SCI_INIT
				STRING_INIT
				NUM_INIT
				DISP_INIT
				SPLASH_SCREEN
        			CLOCK_WAIT_FOR_PLL
				VMON_WAIT_FOR_1ST_RESULTS
				VMON_VUSB_BRLV	DONE
				SCI_INIT
				ERROR_MESSAGE
DONE				EQU	*	
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
				
GPIO_CODE_START			EQU	*
GPIO_CODE_START_LIN		EQU	@
				ORG	GPIO_CODE_END, GPIO_CODE_END_LIN

MMAP_CODE_START			EQU	*	 
MMAP_CODE_START_LIN		EQU	@
				ORG	MMAP_CODE_END, MMAP_CODE_END_LIN
				
SSTACK_CODE_START		EQU	*
SSTACK_CODE_START_LIN		EQU	@
				ORG	SSTACK_CODE_END, SSTACK_CODE_END_LIN
				
ISTACK_CODE_START		EQU	*
ISTACK_CODE_START_LIN		EQU	@
				ORG	ISTACK_CODE_END, ISTACK_CODE_END_LIN
				
CLOCK_CODE_START		EQU	*
CLOCK_CODE_START_LIN		EQU	@
				ORG	CLOCK_CODE_END, CLOCK_CODE_END_LIN
				
COP_CODE_START			EQU	*
COP_CODE_START_LIN		EQU	@
				ORG	COP_CODE_END, COP_CODE_END_LIN
				
TIM_CODE_START			EQU	*
TIM_CODE_START_LIN		EQU	@
				ORG	TIM_CODE_END, TIM_CODE_END_LIN
				
SCI_CODE_START			EQU	*
SCI_CODE_START_LIN		EQU	@
				ORG	SCI_CODE_END, SCI_CODE_END_LIN
				
STRING_CODE_START		EQU	*
STRING_CODE_START_LIN		EQU	@
				ORG	STRING_CODE_END, STRING_CODE_END_LIN
				
NUM_CODE_START			EQU	*
NUM_CODE_START_LIN		EQU	@
				ORG	NUM_CODE_END, NUM_CODE_END_LIN
				
RESET_CODE_START		EQU	*
RESET_CODE_START_LIN		EQU	@
				ORG	RESET_CODE_END, RESET_CODE_END_LIN
				
LED_CODE_START			EQU	*
LED_CODE_START_LIN		EQU	@
				ORG	LED_CODE_END, LED_CODE_END_LIN
				
VMON_CODE_START			EQU	*
VMON_CODE_START_LIN		EQU	@
				ORG	VMON_CODE_END, VMON_CODE_END_LIN
				
NVM_CODE_START			EQU	*
NVM_CODE_START_LIN		EQU	@
				ORG	NVM_CODE_END, NVM_CODE_END_LIN
				
RANDOM_CODE_START		EQU	*
RANDOM_CODE_START_LIN		EQU	@
				ORG	RANDOM_CODE_END, RANDOM_CODE_END_LIN
				
DELAY_CODE_START		EQU	*
DELAY_CODE_START_LIN		EQU	@
				ORG	DELAY_CODE_END, DELAY_CODE_END_LIN
	
DISP_CODE_START			EQU	*
DISP_CODE_START_LIN		EQU	@
				ORG	DISP_CODE_END, DISP_CODE_END_LIN
				
KEYS_CODE_START			EQU	*
KEYS_CODE_START_LIN		EQU	@
				ORG	KEYS_CODE_END, KEYS_CODE_END_LIN
				
BACKLIGHT_CODE_START		EQU	*
BACKLIGHT_CODE_START_LIN	EQU	@
				ORG	BACKLIGHT_CODE_END, BACKLIGHT_CODE_END_LIN
				
VECTAB_CODE_START		EQU	*
VECTAB_CODE_START_LIN		EQU	@
				ORG	VECTAB_CODE_END, VECTAB_CODE_END_LIN

BASE_CODE_END			EQU	*	
BASE_CODE_END_LIN		EQU	@

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
BASE_DISP_WELCOME_SCR		DISP_WELCOME_STREAM 			;display splash screen
BASE_DISP_WELCOME_SIZE		EQU	*-BASE_DISP_WELCOME_SCR
				
;Error Screen			
BASE_DISP_ERROR_SCR		DISP_ERROR_STREAM 			;display splash screen
BASE_DISP_ERROR_SIZE		EQU	*-BASE_DISP_ERROR_SCR
				
;#SCI messages			
;-------------			
;#Error message format
#ifndef	ERROR_HEADER
ERROR_HEADER			FCS	"FATAL ERROR! "
#endif
#ifndef	ERROR_TRAILER
ERROR_TRAILER			FCC	"!"
				STRING_NL_TERM
#endif
	
GPIO_TABS_START			EQU	*
GPIO_TABS_START_LIN		EQU	@
				ORG	GPIO_TABS_END, GPIO_TABS_END_LIN

				
MMAP_TABS_START			EQU	*	 
MMAP_TABS_START_LIN		EQU	@
				ORG	MMAP_TABS_END, MMAP_TABS_END_LIN
				
SSTACK_TABS_START		EQU	*
SSTACK_TABS_START_LIN		EQU	@
				ORG	SSTACK_TABS_END, SSTACK_TABS_END_LIN
				
ISTACK_TABS_START		EQU	*
ISTACK_TABS_START_LIN		EQU	@
				ORG	ISTACK_TABS_END, ISTACK_TABS_END_LIN
				
CLOCK_TABS_START		EQU	*
CLOCK_TABS_START_LIN		EQU	@
				ORG	CLOCK_TABS_END, CLOCK_TABS_END_LIN
				
COP_TABS_START			EQU	*
COP_TABS_START_LIN		EQU	@
				ORG	COP_TABS_END, COP_TABS_END_LIN
				
TIM_TABS_START			EQU	*
TIM_TABS_START_LIN		EQU	@
				ORG	TIM_TABS_END, TIM_TABS_END_LIN
				
SCI_TABS_START			EQU	*
SCI_TABS_START_LIN		EQU	@
				ORG	SCI_TABS_END, SCI_TABS_END_LIN
				
STRING_TABS_START		EQU	*
STRING_TABS_START_LIN		EQU	@
				ORG	STRING_TABS_END, STRING_TABS_END_LIN
				
NUM_TABS_START			EQU	*
NUM_TABS_START_LIN		EQU	@
				ORG	NUM_TABS_END, NUM_TABS_END_LIN
				
RESET_TABS_START		EQU	*
RESET_TABS_START_LIN		EQU	@
				ORG	RESET_TABS_END, RESET_TABS_END_LIN
				
LED_TABS_START			EQU	*
LED_TABS_START_LIN		EQU	@
				ORG	LED_TABS_END, LED_TABS_END_LIN
				
VMON_TABS_START			EQU	*
VMON_TABS_START_LIN		EQU	@
				ORG	VMON_TABS_END, VMON_TABS_END_LIN
				
NVM_TABS_START			EQU	*
NVM_TABS_START_LIN		EQU	@
				ORG	NVM_TABS_END, NVM_TABS_END_LIN
				
RANDOM_TABS_START		EQU	*
RANDOM_TABS_START_LIN		EQU	@
				ORG	RANDOM_TABS_END, RANDOM_TABS_END_LIN
				
DELAY_TABS_START		EQU	*
DELAY_TABS_START_LIN		EQU	@
				ORG	DELAY_TABS_END, DELAY_TABS_END_LIN
	
DISP_TABS_START			EQU	*
DISP_TABS_START_LIN		EQU	@
				ORG	DISP_TABS_END, DISP_TABS_END_LIN
				
KEYS_TABS_START			EQU	*
KEYS_TABS_START_LIN		EQU	@
				ORG	KEYS_TABS_END, KEYS_TABS_END_LIN
	
BACKLIGHT_TABS_START		EQU	*
BACKLIGHT_TABS_START_LIN	EQU	@
				ORG	BACKLIGHT_TABS_END, BACKLIGHT_TABS_END_LIN
	
VECTAB_TABS_START		EQU	*
VECTAB_TABS_START_LIN		EQU	@
				ORG	VECTAB_TABS_END, VECTAB_TABS_END_LIN
	
BASE_TABS_END			EQU	*	
BASE_TABS_END_LIN		EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./regdef_AriCalculator.s		;S12G register map
#include ./gpio_AriCalculator.s			;I/O setup
#include ./mmap_AriCalculator.s			;Memory map
#include ../All/clock.s				;CRG setup
#include ../All/sstack.s			;Subroutine stack
#include ../All/istack.s			;Interrupt stack
#include ../All/cop.s				;COP handler
#include ../All/tim.s				;TIM driver
#include ../All/led.s				;LED driver
#include ./backlight_AriCalculator.s		;Backlight driver
#include ../All/delay.s	  	 		;Delay driver
#include ./keys_AriCalculator.s			;Keypad driver
#include ../All/sci.s				;SCI driver
#include ./disp_AriCalculator.s			;Display driver
#include ./vmon_AriCalculator.s			;Voltage monitor











	

#include ./vectab_AriCalculator.s		;S12G vector table



#include ../All/random.s	   		;Pseudo-random number generator
#include ../All/string.s			;String printing routines	
#include ../All/reset.s				;Reset driver
#include ../All/num.s	   			;Number printing routines
;#include ./nvm_AriCalculator.s			;NVM driver
#include ../S12G-Micro-EVB/nvm_S12G-Micro-EVB.s	;NVM driver
#include ./disp_welcome.s			;Welcome screen
#include ./disp_error.s				;Error screen
#endif
