;###############################################################################
;# AriCalculator - Bootloader                                                  #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the AriCalculator firmware.                         #
;#                                                                             #
;#    AriCalculator is free software: you can redistribute it and/or modify    #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    AriCalculator is distributed in the hope that it will be useful,         #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with AriCalculator.  If not, see <http://www.gnu.org/licenses/>.   #
;###############################################################################
;# Description:                                                                #
;#    This is the bootloader for the AriCalculator firmware. It allows         #
;#    firmware updates without additional hardware.                            #
;#                                                                             #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    July 7, 2017                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# Compile target (LRE or NVM)
#ifndef FLASH_COMPILE
#ifndef RAM_COMPILE
FLASH_COMPILE		EQU	1 		;default target is NVM
#endif	
#endif

;# Size of the bootloader code
#ifndef BOOTLOADER_SIZE
BOOTLOADER_SIZE		EQU	$1000 		;default is 4K
#endif	

;MCU (S12G32, S12G64, S12G128, or S12G240)
;MMAP_S12G240		EQU	1		;default is S12G240

;###############################################################################
;# Timer channel allocation                                                    #
;###############################################################################
; OC0 - SCI                     	;SCI driver
; OC1 - LED				;LED driver
; OC2 - free
; OC3 - free 
; OC4 - free
; OC5 - free
; OC6 - free
; OC7 - free

;###############################################################################
;# Module configuration                                                        #
;###############################################################################
;#CLOCK
CLOCK_CPMU		EQU	1		;CPMU
CLOCK_IRC		EQU	1		;use IRC
CLOCK_OSC_FREQ		EQU	 1000000	; 1 MHz IRC frequency
CLOCK_BUS_FREQ		EQU	25000000	;25 MHz bus frequency
CLOCK_REF_FREQ		EQU	 1000000	; 1 MHz reference clock frequency
CLOCK_VCOFRQ		EQU	$1		;10 MHz VCO frequency
CLOCK_REFFRQ		EQU	$0		; 1 MHz reference clock frequency

;#MMAP: 
#ifdef RAM_COMPILE
MMAP_UNSEC_OFF		EQU	1 	;don't set the security byte for LRE compiles
#endif

;#SSTACK:
SSTACK_TOP		EQU	STACKS_START
SSTACK_TOP_LIN		EQU	STACKS_START
SSTACK_BOTTOM		EQU	STACKS_END

;#ISTACK 
#ifdef RAM_COMPILE
ISTACK_NO_WAI		EQU	1 	;don't enter wait mode when debugging
#endif
	
;#SCI							
SCI_V5			EQU	1   		;V5
SCI_BAUD_9600		EQU	1 		;fixed baud rate
SCI_BAUD_DETECT_OFF	EQU	1		;no baud rate detection
SCI_OC_TIM		EQU	TIM 		;ECT
SCI_OC			EQU	0 		;OC0
SCI_RTSCTS		EQU	1		;RTS/CTS flow control
SCI_RTS_PORT		EQU	PTM 		;PTM
SCI_RTS_PIN		EQU	PM0		;PM0
SCI_CTS_PORT		EQU	PTM 		;PTM
SCI_CTS_DDR		EQU	DDRM 		;DDRM
SCI_CTS_PPS		EQU	PPSM 		;PPSM
SCI_CTS_PIN		EQU	PM1		;PM1
SCI_CTS_STRONG_DRIVE	EQU	1		;strong drive

;#LED							
; LED A: PE0 blinking     -> busy  (green)
; LED B: PE1 blinking     -> error (red)
; Timer usage 
LED_TIM			EQU	TIM 		;TIM
LED_OC			EQU	1 		;OC1
; LED A						
LED_A_BLINK_OFF		EQU	1 		;no blink patterns
LED_A_PORT		EQU	PORTE 		;port E
LED_A_PIN		EQU	PE0 		;PE0
; LED B						
LED_B_BLINK_OFF		EQU	1 		;no blink patterns
LED_B_PORT		EQU	PORTE 		;port E
LED_B_PIN		EQU	PE1 		;PE1
	
;#TIM
TIM_TIOS_INIT		EQU	SCI_OC_TIOS_INIT|LED_TIOS_INIT 

;#DISP
DISP_SEQ_INIT_START	EQU	IMG_SEQ_INIT_START;start of initialization stream
DISP_SEQ_INIT_END	EQU	DISP_SEQ_INIT_END ;end of initialization stream
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Memory map                                                                  #
;###############################################################################
;                        FLASH_COMPILE:                                     RAM_COMPILE:
;                        ==============                                     ============
;      MMAP_REG_START -> +----------+----------+        MMAP_REG_START -> +----------+----------+
;             ($0000)    |   Register Space    |               ($0000)    |   Register Space    |
;        MMAP_REG_END -> +----------+----------+          MMAP_REG_END -> +----------+----------+
;             ($0400)    :       unused        :               ($0400)    :       unused        :
;      MMAP_RAM_START,-> +----------+----------+        MMAP_RAM_START,-> +----------+----------+
;    RAM_VECTAB_START    |    Vector Table     |      RAM_VECTAB_START    |    Vector Table     |
;      RAM_TABS_START -> +----------+----------+        RAM_TABS_START -> +----------+----------+
;                        |       Tables        |                          |       Tables        |
;      RAM_CODE_START -> +----------+----------+        RAM_CODE_START -> +----------+----------+
;                        |                     |                          |                     |
;                        |    Program Space    |                          |    Program Space    |
;                        |                     |                          |                     |
;          VARS_START -> +----------+----------+            VARS_START -> +----------+----------+
;                        |                     |                          |                     |
;                        |  Global Variables   |                          |  Global Variables   |
;                        |                     |                          |                     |
;          SSTACK_TOP -> +----------+----------+            SSTACK_TOP -> +----------+----------+
;                        |                     |                          |                     |
;                        |                     |                          |       SSTACK        |
;                        |                     |                          |       ISTACK        |
;                        |                     |                          |                     |
;                        |                     |    RAM_TABS_START_LIN -> +----------+----------+--- B
;                        |                     |                          |   Tables (source)   | ^  O
;                        |                     |    RAM_CODE_START_LIN -> +----------+----------+ |  O
;                        |                     |                          |                     | |  T
;                        |        SSTACK       |                          |    Program Space    | |  L
;                        |        ISTACK       |                          |      (Source)       | |  O
;                        |                     |            CODE_START -> +----------+----------+ |  A
;                        |                     |                          |    Program Space    | |  D
;                        |                     |            TABS_START -> +----------+----------+ |  E
;                        |                     |                          |        Tables       | |  R
;                        |                     |                          +----------+----------+ |  _
;                        |                     |                          :                    :  |  S
;  	                 |                     |  RAM_VECTAB_START_LIN,-> +----------+----------+ |  I
;                        |                     |         VECTAB_START     |    Vector Table     | v  Z
;        MMAP_RAM_END -> +----------+----------+          MMAP_RAM_END -> +----------+----------+--- E 
;                        :       unused        :                    
;  RAM_TABS_START_LIN -> +----------+----------+--- B
;                        |   Tables (source)   | ^  O
;  RAM_CODE_START_LIN -> +----------+----------+ |  O
;                        |                     | |  T
;                        |    Program Space    | |  L
;                        |      (Source)       | |  O
;          CODE_START -> +----------+----------+ |  A
;                        |    Program Space    | |  D
;          TABS_START -> +----------+----------+ |  E
;                        |        Tables       | |  R
;                        +----------+----------+ |  _
;                        :                     : |  S
;RAM_VECTAB_START_LIN,-> +----------+----------+ |  I
;       VECTAB_START     |    Vector Table     | v  Z
;                        +----------+----------+--- E

			;RAM vector table
RAM_VECTAB_START	EQU	MMAP_RAM_START 				;LRE destination
RAM_VECTAB_START_LIN	EQU	VECTAB_START_LIN   			;LRE source
			ORG	RAM_VECTAB_START, RAM_VECTAB_START_LIN
			DS	VECTAB_SIZE
RAM_VECTAB_END		EQU	*					;LRE destination
RAM_VECTAB_END_LIN	EQU	@					;LRE source

			;RAM tables
RAM_TABS_START		EQU	RAM_VECTAB_END 				;LRE destination
#ifdef FLASH_COMPILE		
RAM_TABS_START_LIN	EQU	MMAP_FLASH_F_END_LIN-BOOTLOADER_SIZE 	;LRE source
#else
RAM_TABS_START_LIN	EQU	MMAP_RAM_END-BOOTLOADER_SIZE 		;LRE source
#endif
			ORG	RAM_TABS_START, RAM_TABS_START_LIN
			DS	RAM_TABS_END-RAM_TABS_START

			;RAM code
			ORG	RAM_TABS_END, RAM_TABS_END_LIN
RAM_CODE_START		EQU	*					;LRE destination
RAM_CODE_START_LIN	EQU	@					;LRE source
			DS	RAM_CODE_END-RAM_CODE_START

			;Variables 
			ORG	RAM_CODE_END, RAM_CODE_END
VARS_START		EQU	*
VARS_START_LIN		EQU	@

			;Stacks
			ORG	VARS_END, VARS_END
STACKS_START		EQU	*
#ifdef FLASH_COMPILE		
STACKS_END		EQU	MMAP_RAM_END
#else
STACKS_END		EQU	RAM_TABS_START_LIN
#endif	
			DS	STACKS_END-STACKS_START

			;Code
CODE_START		EQU	RAM_CODE_END_LIN&$FFFF
CODE_START_LIN		EQU	RAM_CODE_END_LIN

			;Tables
			ORG	CODE_END, CODE_END_LIN
TABS_START		EQU	*	
TABS_START_LIN		EQU	@

			;Vector table
#ifdef FLASH_COMPILE		
VECTAB_START		EQU	MMAP_FLASH_F_END-VECTAB_SIZE
VECTAB_START_LIN	EQU	MMAP_FLASH_F_END_LIN-VECTAB_SIZE
#else
VECTAB_START		EQU	MMAP_RAM_END-VECTAB_SIZE
VECTAB_START_LIN	EQU	MMAP_RAM_END-VECTAB_SIZE
#endif
		
;###############################################################################
;# Initialization                                                              #
;###############################################################################
#macro	INIT, 0
			MMAP_INIT 		;configure memory map
			GPIO_INIT		;configure I/Os
			RESET_INIT		;start bootloder or application
			VECTAB_INIT		;configure cector table
			SSTACK_INIT		;configure subroutine stack
			ISTACK_INIT		;configure interrupt stack
			CLOCK_INIT		;configure clocks
			TIM_INIT		;configure timers			
			LED_INIT		;configure LEDs
			LRE_INIT		;copy LRE code
			CLOCK_WAIT_FOR_PLL	;wait for PLL to lock
			SCI_INIT		;configure SCI
			NVM_INIT		;configure NVM
			IMG_INIT		;configure display content
			DISP_INIT		;configure display
			SREC_INIT		;initialize S-record parser
#emac
	
;###############################################################################
;# Global variable space                                                       #
;###############################################################################
			ORG	VARS_START, VARS_START_LIN

MMAP_VARS_START		EQU	*	 
MMAP_VARS_START_LIN	EQU	@
			ORG	MMAP_VARS_END, MMAP_VARS_END_LIN
			
GPIO_VARS_START		EQU	*
GPIO_VARS_START_LIN	EQU	@
			ORG	GPIO_VARS_END, GPIO_VARS_END_LIN

RESET_VARS_START	EQU	*
RESET_VARS_START_LIN	EQU	@
			ORG	RESET_VARS_END, RESET_VARS_END_LIN

CLOCK_VARS_START	EQU	*
CLOCK_VARS_START_LIN	EQU	@
			ORG	CLOCK_VARS_END, CLOCK_VARS_END_LIN

LRE_VARS_START		EQU	*
LRE_VARS_START_LIN	EQU	@
			ORG	LRE_VARS_END, LRE_VARS_END_LIN
	
TIM_VARS_START		EQU	*
TIM_VARS_START_LIN	EQU	@
			ORG	TIM_VARS_END, TIM_VARS_END_LIN
	
VECTAB_VARS_START	EQU	*
VECTAB_VARS_START_LIN	EQU	@
			ORG	VECTAB_VARS_END, VECTAB_VARS_END_LIN
				
SSTACK_VARS_START	EQU	*
SSTACK_VARS_START_LIN	EQU	@
			ORG	SSTACK_VARS_END, SSTACK_VARS_END_LIN
			
ISTACK_VARS_START	EQU	*
ISTACK_VARS_START_LIN	EQU	@
			ORG	ISTACK_VARS_END, ISTACK_VARS_END_LIN

SCI_VARS_START		EQU	*
SCI_VARS_START_LIN	EQU	@
			ORG	SCI_VARS_END, SCI_VARS_END_LIN
			
DISP_VARS_START		EQU	*
DISP_VARS_START_LIN	EQU	@
			ORG	DISP_VARS_END, DISP_VARS_END_LIN
			
LED_VARS_START		EQU	*
LED_VARS_START_LIN	EQU	@
			ORG	LED_VARS_END, LED_VARS_END_LIN
			
NVM_VARS_START		EQU	*
NVM_VARS_START_LIN	EQU	@
			ORG	NVM_VARS_END, NVM_VARS_END_LIN
			
SREC_VARS_START		EQU	*
SREC_VARS_START_LIN	EQU	@
			ORG	SREC_VARS_END, SREC_VARS_END_LIN

IMG_VARS_START		EQU	*
IMG_VARS_START_LIN	EQU	@
			ORG	IMG_VARS_END, IMG_VARS_END_LIN

VARS_END		EQU	*
VARS_END_LIN		EQU	@
	
;###############################################################################
;# Code space                                                                  #
;###############################################################################
			ORG	CODE_START, CODE_START_LIN

START_OF_CODE		EQU	*

			;Initialization
			INIT				;initialize bootloader
			JOB	START_OF_RAM_CODE	;run LRE code

			;Bootloading successful 
BOOTLOADER_DONE		EQU	*
			LED_OFF	A 			;not busy anymore
			LED_ON	B 			;no error
			DISP_STREAM_FROM_TO_BL	IMG_SEQ_DONE_START, IMG_SEQ_DONE_END
			BRA	*
	
			;Bootloading failed
BOOTLOADER_ISR_ERROR	EQU	*
			CLI
BOOTLOADER_ERROR	EQU	*
			LED_OFF	A 			;not busy anymore
			LED_ON	B 			;flag error
			DISP_STREAM_FROM_TO_BL	IMG_SEQ_ERROR_START, IMG_SEQ_ERROR_END
			BRA	*
	
MMAP_CODE_START		EQU	*	 
MMAP_CODE_START_LIN	EQU	@
			ORG	MMAP_CODE_END, MMAP_CODE_END_LIN

GPIO_CODE_START		EQU	*
GPIO_CODE_START_LIN	EQU	@
			ORG	GPIO_CODE_END, GPIO_CODE_END_LIN

RESET_CODE_START	EQU	*
RESET_CODE_START_LIN	EQU	@
			ORG	RESET_CODE_END, RESET_CODE_END_LIN

CLOCK_CODE_START	EQU	*
CLOCK_CODE_START_LIN	EQU	@
			ORG	CLOCK_CODE_END, CLOCK_CODE_END_LIN
			
LRE_CODE_START		EQU	*
LRE_CODE_START_LIN	EQU	@
			ORG	LRE_CODE_END, LRE_CODE_END_LIN

TIM_CODE_START		EQU	*
TIM_CODE_START_LIN	EQU	@
			ORG	TIM_CODE_END, TIM_CODE_END_LIN
	
DISP_CODE_START		EQU	*
DISP_CODE_START_LIN	EQU	@
			ORG	DISP_CODE_END, DISP_CODE_END_LIN
			
LED_CODE_START		EQU	*
LED_CODE_START_LIN	EQU	@
			ORG	LED_CODE_END, LED_CODE_END_LIN
			
IMG_CODE_START		EQU	*
IMG_CODE_START_LIN	EQU	@
			ORG	IMG_CODE_END, IMG_CODE_END_LIN
			
CODE_END		EQU	*
CODE_END_LIN		EQU	@

;###############################################################################
;# LRE code space                                                              #
;###############################################################################
			ORG	RAM_CODE_START, RAM_CODE_START_LIN

START_OF_RAM_CODE	EQU	*
			;JOB	SREC_PARSE
			BRA	*
	
VECTAB_CODE_START	EQU	*
VECTAB_CODE_START_LIN	EQU	@
			ORG	VECTAB_CODE_END, VECTAB_CODE_END_LIN

SSTACK_CODE_START	EQU	*
SSTACK_CODE_START_LIN	EQU	@
			ORG	SSTACK_CODE_END, SSTACK_CODE_END_LIN
			
ISTACK_CODE_START	EQU	*
ISTACK_CODE_START_LIN	EQU	@
			ORG	ISTACK_CODE_END, ISTACK_CODE_END_LIN

SCI_CODE_START		EQU	*
SCI_CODE_START_LIN	EQU	@
			ORG	SCI_CODE_END, SCI_CODE_END_LIN
			
NVM_CODE_START		EQU	*
NVM_CODE_START_LIN	EQU	@
			ORG	NVM_CODE_END, NVM_CODE_END_LIN
			
SREC_CODE_START		EQU	*
SREC_CODE_START_LIN	EQU	@
			ORG	SREC_CODE_END, SREC_CODE_END_LIN

RAM_CODE_END		EQU	*
RAM_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Table space                                                                 #
;###############################################################################
			ORG	TABS_START, TABS_START_LIN

MMAP_TABS_START		EQU	*	 
MMAP_TABS_START_LIN	EQU	@
			ORG	MMAP_TABS_END, MMAP_TABS_END_LIN
			
GPIO_TABS_START		EQU	*
GPIO_TABS_START_LIN	EQU	@
			ORG	GPIO_TABS_END, GPIO_TABS_END_LIN

RESET_TABS_START	EQU	*
RESET_TABS_START_LIN	EQU	@
			ORG	RESET_TABS_END, RESET_TABS_END_LIN

CLOCK_TABS_START	EQU	*
CLOCK_TABS_START_LIN	EQU	@
			ORG	CLOCK_TABS_END, CLOCK_TABS_END_LIN
			
LRE_TABS_START		EQU	*
LRE_TABS_START_LIN	EQU	@
			ORG	LRE_TABS_END, LRE_TABS_END_LIN
			
TIM_TABS_START		EQU	*
TIM_TABS_START_LIN	EQU	@
			ORG	TIM_TABS_END, TIM_TABS_END_LIN
	
DISP_TABS_START		EQU	*
DISP_TABS_START_LIN	EQU	@
			ORG	DISP_TABS_END, DISP_TABS_END_LIN
			
LED_TABS_START		EQU	*
LED_TABS_START_LIN	EQU	@
			ORG	LED_TABS_END, LED_TABS_END_LIN
			
IMG_TABS_START		EQU	*
IMG_TABS_START_LIN	EQU	@
			ORG	IMG_TABS_END, IMG_TABS_END_LIN
			
TABS_END		EQU	*
TABS_END_LIN		EQU	@


;###############################################################################
;# LRE table space                                                             #
;###############################################################################
			ORG	RAM_TABS_START, RAM_TABS_START_LIN

VECTAB_TABS_START	EQU	*
VECTAB_TABS_START_LIN	EQU	@
			ORG	VECTAB_TABS_END, VECTAB_TABS_END_LIN
			
SSTACK_TABS_START	EQU	*
SSTACK_TABS_START_LIN	EQU	@
			ORG	SSTACK_TABS_END, SSTACK_TABS_END_LIN
			
ISTACK_TABS_START	EQU	*
ISTACK_TABS_START_LIN	EQU	@
			ORG	ISTACK_TABS_END, ISTACK_TABS_END_LIN

SCI_TABS_START		EQU	*
SCI_TABS_START_LIN	EQU	@
			ORG	SCI_TABS_END, SCI_TABS_END_LIN
			
NVM_TABS_START		EQU	*
NVM_TABS_START_LIN	EQU	@
			ORG	NVM_TABS_END, NVM_TABS_END_LIN
			
SREC_TABS_START		EQU	*
SREC_TABS_START_LIN	EQU	@
			ORG	SREC_TABS_END, SREC_TABS_END_LIN

RAM_TABS_END		EQU	*
RAM_TABS_END_LIN	EQU	@
	
;###############################################################################
;# Includes                                                                    #
;###############################################################################
;# S12CBase
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/regdef_AriCalculator.s ;Register definitions
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/memmap_AriCalculator.s ;Memory map
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/gpio_AriCalculator.s   ;I/O setup
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/disp_AriCalculator.s   ;Display driver
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/clocks.s				  ;TIM driver
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/tim.s				  ;TIM driver
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sstack.s		  	  ;Subroutine stack
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/istack.s	  		  ;Interrupt stack
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sci.s				  ;SCI driver
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/led.s				  ;LED driver

#include ../../../../S12CBase/Source/AriCalculator/regdef_AriCalculator.s 				 ;Register definitions
#include ../../../../S12CBase/Source/AriCalculator/mmap_AriCalculator.s 				 ;Memory map
#include ../../../../S12CBase/Source/AriCalculator/gpio_AriCalculator.s   				 ;I/O setup
#include ../../../../S12CBase/Source/AriCalculator/disp_AriCalculator.s   				 ;Display driver
#include ../../../../S12CBase/Source/All/clock.s				 			 ;Clock driver
#include ../../../../S12CBase/Source/All/tim.s				 				 ;TIM driver
#include ../../../../S12CBase/Source/All/sstack.s		  	 				 ;Subroutine stack
#include ../../../../S12CBase/Source/All/istack.s	  		 				 ;Interrupt stack
#include ../../../../S12CBase/Source/All/sci.s				 				 ;SCI driver
#include ../../../../S12CBase/Source/All/led.s				 				 ;LED driver

#include ./vectab_Bootloader.s	                                                                         ;S12G vector table
#include ./reset_Bootloader.s                                                                            ;Reset driver
#include ./lre_Bootloader.s	                                                                         ;LRE code
#include ./nvm_Bootloader.s	                                                                         ;NVM driver
#include ./srec_Bootloader.s                                                                             ;S-Record handler
#include ./img_Bootloader.s                                                                              ;Bitmaps to display
