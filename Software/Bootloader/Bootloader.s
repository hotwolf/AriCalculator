;###############################################################################
;# AriCalculator - Bootloader                                                  #
;###############################################################################
;#    Copyright 2010-2018 Dirk Heisswolf                                       #
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
; OC1 - free
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
	
;#VECTAB 
VECTAB_DEBUG_OFF	EQU	1 		;debug IRQs
	
;#SSTACK:
SSTACK_TOP		EQU	STACKS_START
SSTACK_TOP_LIN		EQU	STACKS_START
SSTACK_BOTTOM		EQU	STACKS_END

;#ISTACK 
#ifdef RAM_COMPILE
ISTACK_NO_WAI		EQU	1 		;don't enter wait mode when debugging
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
SCI_RXTX_ACTHI		EQU	1		;RXD/TXD are active hi
SCI_RXBUF_SIZE		EQU	32*2		;easier to debug
SCI_TXBUF_SIZE		EQU	8		;easier to debug
;SCI_TXBUF_SIZE		EQU	4		;easier to debug
	
;#STRING							
;STRING_ENABLE_ERASE_NB	EQU	1		;enable STRING_ERASE_NB 
;STRING_ENABLE_ERASE_BL	EQU	1		;enable STRING_ERASE_BL 
;STRING_ENABLE_FILL_NB	EQU	1		;enable STRING_FILL_NB 
;STRING_ENABLE_FILL_BL	EQU	1		;enable STRING_FILL_BL 
STRING_ENABLE_PRINTABLE	EQU	1		;enable STRING_PRINTABLE
	
;#NUM							
;NUM_MAX_BASE_16	EQU	1 		;default is 16
	
;#LED							
; LED A: PE0 -> busy  (green)
; LED B: PE1 -> error (red)
; Timer usage 
;LED_TIM		EQU	TIM 		;TIM
;LED_OC			EQU	1 		;OC1
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
;#Error codes
BOOTLOADER_ERR_UNKNOWN	EQU	$01 		;unknown error
	
;###############################################################################
;# Security and memory protection                                              #
;###############################################################################
#ifdef FLASH_COMPILE
			ORG	$FF0C, $3_FF0C
			DB	$CF 		;FPROT:  protect $3_F000-$3_FFFF 
			DB	$FF		;EEPROT: unprotect
			DB	$FF 		;FOPT:   don't enable the COP
			DB	$FE		;FSEC:   unsecure 
#endif

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
;      RAM_TABS_START    |       Tables        |        RAM_TABS_START    |       Tables        |
;      RAM_CODE_START -> +----------+----------+        RAM_CODE_START -> +----------+----------+
;                        |         LRE         |                          |         LRE         |
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
;  	 VECTAB_START -> +----------+----------+          VECTAB_START -> +----------+----------+
;                        |    Vector Table     |                          |    Vector Table     |
;                        |                     |    RAM_TABS_START_LIN -> +----------+----------+--- B
;                        |                     |                          |   Tables (source)   | ^  O
;                        |                     |    RAM_CODE_START_LIN -> +----------+----------+ |  O
;                        |                     |                          |         LRE         | |  T
;                        |        SSTACK       |                          |    Program Space    | |  L
;                        |        ISTACK       |                          |      (Source)       | |  O
;                        |                     |            CODE_START -> +----------+----------+ |  A
;                        |                     |                          |    Program Space    | |  D
;                        |                     |            TABS_START -> +----------+----------+ |  E
;                        |                     |                          |        Tables       | |  R
;                        |                     |                          +----------+----------+ |  _
;                        |                     |                          :                     : |  S
;  	 VECTAB_START -> +----------+----------+      VECTAB_START_LIN -> +----------+----------+ |  I
;                        |    Vector Table     |                          |    Vector Table     | v  Z
;        MMAP_RAM_END -> +----------+----------+          MMAP_RAM_END -> +----------+----------+--- E 
;                        :       unused        :                    
;  RAM_TABS_START_LIN -> +----------+----------+--- B
;                        |   Tables (source)   | ^  O
;  RAM_CODE_START_LIN -> +----------+----------+ |  O
;                        |         LRE         | |  T
;                        |    Program Space    | |  L
;                        |      (Source)       | |  O
;          CODE_START -> +----------+----------+ |  A
;                        |    Program Space    | |  D
;          TABS_START -> +----------+----------+ |  E
;                        |        Tables       | |  R
;                        +----------+----------+ |  _
;                        :                     : |  S
;    VECTAB_START_LIN -> +----------+----------+ |  I
;                        |    Vector Table     | v  Z
;                        +----------+----------+--- E

			;Vector table
#ifdef FLASH_COMPILE		
VECTAB_START		EQU	MMAP_RAM_END-VECTAB_SIZE 		;LRE destination
VECTAB_START_LIN	EQU	MMAP_FLASH_F_END_LIN-VECTAB_SIZE   	;LRE source
#else
VECTAB_START		EQU	RAM_TABS_START_LIN-VECTAB_SIZE 		;LRE destination
VECTAB_START_LIN	EQU	MMAP_RAM_END-VECTAB_SIZE   		;LRE source
#endif

			;RAM tables
RAM_TABS_START		EQU	MMAP_RAM_START 				;LRE destination
#ifdef FLASH_COMPILE		
RAM_TABS_START_LIN	EQU	MMAP_FLASH_F_END_LIN-BOOTLOADER_SIZE 	;LRE source
#else
RAM_TABS_START_LIN	EQU	MMAP_RAM_END-BOOTLOADER_SIZE 		;LRE source
#endif

			;RAM code
			ORG	RAM_TABS_END, RAM_TABS_END_LIN
RAM_CODE_START		EQU	*					;LRE destination
RAM_CODE_START_LIN	EQU	@					;LRE source

			;Variables 
			ORG	RAM_CODE_END, RAM_CODE_END
VARS_START		EQU	*
VARS_START_LIN		EQU	@

			;Stacks
			ORG	VARS_END, VARS_END
STACKS_START		EQU	*
STACKS_END		EQU	VECTAB_START
			DS	STACKS_END-STACKS_START

			;Code
CODE_START		EQU	RAM_CODE_END_LIN&$FFFF
CODE_START_LIN		EQU	RAM_CODE_END_LIN

			;Tables
			ORG	CODE_END, CODE_END_LIN
TABS_START		EQU	*	
TABS_START_LIN		EQU	@
		
;###############################################################################
;# Initialization                                                              #
;###############################################################################
#macro	INIT, 0
			RESET_INIT		;start bootloder or application
			MMAP_INIT 		;configure memory map
			GPIO_INIT		;configure I/Os
			CLOCK_INIT		;configure clocks
			VECTAB_INIT		;configure cector table
			SSTACK_INIT		;configure subroutine stack
			ISTACK_INIT		;configure interrupt stack
			TIM_INIT		;configure timers			
			LED_INIT		;configure LEDs
			NVM_INIT		;configure NVM
			SCI_INIT		;configure SCI
			STRING_INIT		;configure STRING
			;NUM_INIT		;configure NUM
			SREC_INIT		;initialize S-record parser
			LRE_INIT		;copy LRE code
			CLOCK_WAIT_FOR_PLL	;wait for PLL to lock
			SCI_ACTIVATE		;activate SCI
			IMG_INIT		;configure display content
			DISP_INIT		;configure display
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
			
STRING_VARS_START	EQU	*
STRING_VARS_START_LIN	EQU	@
			ORG	STRING_VARS_END, STRING_VARS_END_LIN
			
;NUM_VARS_START		EQU	*
;NUM_VARS_START_LIN	EQU	@
;			ORG	NUM_VARS_END, NUM_VARS_END_LIN
			
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

BOOTLOADER_COUNT	DS	1
	
VARS_END		EQU	*
VARS_END_LIN		EQU	@
	
;###############################################################################
;# Code space                                                                  #
;###############################################################################
			ORG	CODE_START, CODE_START_LIN

START_OF_CODE		EQU	*

			;Initialization
			INIT					;initialize bootloader
			;Indicate readyness  
BOOTLOADER_SHOW_READY	EQU	*
			;Set LEDs 
			;LED_OFF A 				;not busy anymore
			;LED_OFF B 				;no error
			;Print ready message  
			LDX	#BOOTLOADER_MSG_READY 		;message pointer -> X
			STRING_PRINT_BL				;print message
			;Update display 
			;DISP_STREAM_FROM_TO_BL	IMG_SEQ_READY_START, IMG_SEQ_READY_END

			;Wait for transmission 
			SCI_RX_READY_BL

			;Indicate ongoing firmware transmission
BOOTLOADER_SHOW_BUSY	EQU	*
			;Set LEDs 
			;LED_OFF A 				;not busy anymore
			;LED_OFF B 				;no error
			;Update display 
			DISP_STREAM_FROM_TO_BL	IMG_SEQ_BUSY_START, IMG_SEQ_BUSY_END

			;Execute from RAM
			JMP	START_OF_RAM_CODE		;run LRE code

			;Check for errors (error code in A)
BOOTLOADER_DONE		LDY	#(BOOTLOADER_ERR_TAB-2)		;initialize table pointer
BOOTLOADER_DONE_1	LEAY	2,Y				;advance table pointer
			LSLA					;check next errr bit
			BCS	BOOTLOADER_DONE_3 		;cause found
			BNE	BOOTLOADER_DONE_1		;check next bit

			;Indicate successful firmware update  
			;Set LEDs 
			LED_OFF	A 				;not busy anymore
			;LED_OFF B 				;no error
			;Print message  
			LDX	#BOOTLOADER_MSG_DONE 		;message pointer -> X
			STRING_PRINT_BL				;print message
			;Update display 
			DISP_STREAM_FROM_TO_BL	IMG_SEQ_DONE_START, IMG_SEQ_DONE_END
			;Read loop
BOOTLOADER_DONE_2	SCI_RX_BL 				;ignore incoming data
			JOB	BOOTLOADER_DONE_2	

			;Indicate failed firmware update (error message in Y)
BOOTLOADER_DONE_3	NVM_STOP		      		;stop the NVM
			LDX	#BOOTLOADER_MSG_ERROR 		;message pointer -> X
			STRING_PRINT_BL				;print message
			LDX	0,Y	 			;message pointer -> X	
			STRING_PRINT_BL				;print message
			;Set LEDs 
			LED_OFF	A 				;not busy anymore
			LED_ON	B 				;flag error
			;Update display 
			DISP_STREAM_FROM_TO_BL	IMG_SEQ_ERROR_START, IMG_SEQ_ERROR_END
			JOB	BOOTLOADER_DONE_2	

			;Unexpected interrupt request  
BOOTLOADER_ISR_ERROR	LDAA	#BOOTLOADER_ERR_UNKNOWN 		;unknown error -> A
			LEAS	9,SP 					;free stack space
			CLI						;enable interrupts
			JOB	BOOTLOADER_DONE				;handle errors
	
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
;# RAM code space                                                              #
;###############################################################################
			ORG	RAM_CODE_START, RAM_CODE_START_LIN

START_OF_RAM_CODE	EQU	*
	
			;Parse incoming S-records
			SREC_PARSE_SREC

			;Wait for NVM (error code in A)
			NVM_WAIT_IDLE				;wait for FTMRG to become idle
			JOB	BOOTLOADER_DONE			;show result
				
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
			
STRING_CODE_START	EQU	*
STRING_CODE_START_LIN	EQU	@
			ORG	STRING_CODE_END, STRING_CODE_END_LIN
			
;NUM_CODE_START		EQU	*
;NUM_CODE_START_LIN	EQU	@
;			ORG	NUM_CODE_END, NUM_CODE_END_LIN
			
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

BOOTLOADER_ERR_TAB	DW	BOOTLOADER_MSG_RX
			DW	BOOTLOADER_MSG_FORMAT
			DW	BOOTLOADER_MSG_CHECKSUM
			DW	BOOTLOADER_MSG_COUNT
			DW	BOOTLOADER_MSG_ADDR
			DW	BOOTLOADER_MSG_HW
			DW	BOOTLOADER_MSG_UNKNOWN
			DW	BOOTLOADER_MSG_UNKNOWN
						
BOOTLOADER_MSG_RX	FCS	"Broken data transfer!"
BOOTLOADER_MSG_FORMAT	FCS	"Wrong S-record format!"
BOOTLOADER_MSG_CHECKSUM	FCS	"Incorrect checksum!"
BOOTLOADER_MSG_COUNT	FCS	"Wrong S-record count!"
BOOTLOADER_MSG_ADDR	FCS	"Wrong address!"
BOOTLOADER_MSG_HW	FCS	"Hardware failur!"
BOOTLOADER_MSG_UNKNOWN	FCS	"Unknown cause!"

BOOTLOADER_MSG_READY	STRING_NL_NONTERM
			FCS	"Ready to receive S-record!"	
BOOTLOADER_MSG_DONE	STRING_NL_NONTERM
			FCS	"Done!"
BOOTLOADER_MSG_ERROR	STRING_NL_NONTERM
			FCS	"Error! "	
	
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
;# RAM table space                                                             #
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
			
STRING_TABS_START	EQU	*
STRING_TABS_START_LIN	EQU	@
			ORG	STRING_TABS_END, STRING_TABS_END_LIN
			
;NUM_TABS_START		EQU	*
;NUM_TABS_START_LIN	EQU	@
;			ORG	NUM_TABS_END, NUM_TABS_END_LIN
			
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
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/regdef_AriCalculator.s	;Register definitions
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/mmap_AriCalculator.s	;Memory map
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/gpio_AriCalculator.s	;I/O setup
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/disp_AriCalculator.s	;Display driver
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/clock.s			  	;TIM driver
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/tim.s				;TIM driver
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sstack.s		  	  	;Subroutine stack
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/istack.s	  		  	;Interrupt stack
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sci.s  				;SCI driver
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/led.s				;LED driver
#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/string.s			  	;String printing routines
;#include ../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/num.s				;Number printing routines

;#include ../../../S12CBase/Source/AriCalculator/regdef_AriCalculator.s 				;Register definitions
;#include ../../../S12CBase/Source/AriCalculator/mmap_AriCalculator.s 				        ;Memory map
;#include ../../../S12CBase/Source/AriCalculator/gpio_AriCalculator.s   				;I/O setup
;#include ../../../S12CBase/Source/AriCalculator/disp_AriCalculator.s   				;Display driver
;#include ../../../S12CBase/Source/All/clock.s				 			        ;Clock driver
;#include ../../../S12CBase/Source/All/tim.s				 				;TIM driver
;#include ../../../S12CBase/Source/All/sstack.s		  	 				        ;Subroutine stack
;#include ../../../S12CBase/Source/All/istack.s	  		 				        ;Interrupt stack
;#include ../../../S12CBase/Source/All/sci.s				 				;SCI driver
;#include ../../../S12CBase/Source/All/led.s				 				;LED driver
;#include ../../../S12CBase/Source/All/string.s								;String printing routines
;#include ../../../S12CBase/Source/All/num.s			  	  				;Number printing routines
													
#include ./reset_Bootloader.s                                                                           ;Reset driver
#include ./lre_Bootloader.s	                                                                        ;LRE code
#include ./nvm_Bootloader.s	                                                                        ;NVM driver
#include ./srec_Bootloader.s                                                                            ;S-Record handler
#include ./img_Bootloader.s                                                                             ;Bitmaps to display
#include ./vectab_Bootloader.s	                                                                        ;S12G vector table
