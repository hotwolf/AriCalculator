;###############################################################################
;# AriCalculsator - Main file                                                  #
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
;###############################################################################
;# Description:                                                                #
;#    This is the top level file if the AriCalculator firmware. This file      #
;#    supports compilation to flash memory and to RAM ("load ram and execute"  #
;#    -> LRE). To execute the firmware from RAM, set the program counter to    #
;#    the label "START_OF_CODE".                                               #
;#                                                                             #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    May 15, 2017                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# Compile target (LRE or NVM)
#ifndef FLASH_COMPILE
#ifndef LRE_COMPILE
FLASH_COMPILE		EQU	1 		;default target is NVM
#endif	
#endif

;###############################################################################
;# Memory map                                                                  #
;###############################################################################
;                        FLASH_COMPILE:                                            LRE_COMPILE:
;                        ==============                                            ============
;      MMAP_REG_START -> +----------+----------+                 MMAP_REG_START -> +----------+----------+                              
;             ($0000)    |   Register Space    |                        ($0000)    |   Register Space    |                      
;   MMAP_EEPROM_START -> +----------+----------+                   MMAP_REG_END -> +----------+----------+                      
;             ($0400)    |   EEPROM (not used) |                        ($0400)    |       unused        |                      
;  MMAP_FLASH_C_START -> +----------+----------+                MMAP_RAM_START, -> +----------+----------+                      
;                        |   Part of PPAGE C   |                   VECTAB_START    |    Vector Table     |                                  
;                        |      (unused)       |                     CODE_START -> +----------+----------+                      
;      MMAP_RAM_START -> +----------+----------+                                   |                     |                      
;                        |  Global Variables   |                                   |    Program Space    |                             
;         DS_PS_START -> +----------+----------+                                   |                     |                      
;                        |    User Variables   |                     TABS_START -> +----------+----------+                      
;                        |          |          |                                   |       Tables        |                      
;                        |          v          |                     VARS_START -> +----------+----------+                      
;                        | --- --- --- --- --- | <- [DP]                           |  Global Variables   |                      
;                        |                     |                    DS_PS_START -> +----------+----------+                      
;                        | --- --- --- --- --- | <- [CFSP]                         |    User Variables   |                             
;                        |          ^          |                                   |          |          |                      
;                        |          |          |                                   |          v          |                      
;                        | Control-flow stack  |                                   | --- --- --- --- --- | <- [DP]              
;                        +----------+----------+ <- [CFSP]                         |                     |                             
;                        | Compile Variables   |                                   | --- --- --- --- --- | <- [CFSP]                    
;                        | (CP, CFSP, ...)     |                                   |          ^          |                      
;                        +----------+----------+                                   |          |          |                      
;                        |  User Dictionary    |                                   | Control-flow stack  |                      
;                        |          |          |                                   +----------+----------+ <- [CFSP]                    
;                        |          v          |                                   | Compile Variables   |                             
;                        | --- --- --- --- --- | <- [CP]                           | (CP, CFSP, ...)     |                             
;                        |                     |                                   +----------+----------+                      
;                        | --- --- --- --- --- | <- [HLD]                          |  User Dictionary    |                      
;                        |          ^          |                                   |          |          |                      
;                        |         PAD         |                                   |          v          |                      
;                        | --- --- --- --- --- | <- [PAD]                          | --- --- --- --- --- | <- [CP]              
;                        |                     |                                   |                     |                             
;                        | --- --- --- --- --- | <- [PSP=Y]                        | --- --- --- --- --- | <- [HLD]                     
;                        |          ^          |                                   |          ^          |                      
;                        |          |          |                                   |         PAD         |                      
;                        |   Parameter stack   |                                   | --- --- --- --- --- | <- [PAD]                     
;                        +----------+----------+                                   |                     |                      
;                        |   Canary (4 bytes)  |                                   | --- --- --- --- --- | <- [PSP=Y]                     
;        TIB_RS_START -> +----------+----------+                                   |          ^          |                      
;                        |  Text Input Buffer  | | [NUMBER_TIB]                    |          |          |                      
;                        |          |          | |                                 |   Parameter stack   |                      
;                        |          v          | |                                 +----------+----------+                      
;                        | --- --- --- --- --- | <                                 |   Canary (4 bytes)  |                             
;                        |                     |                   TIB_RS_START -> +----------+----------+                              
;                        | --- --- --- --- --- | <- [RSP=SP]                       |  Text Input Buffer  | | [NUMBER_TIB]               
;                        |          ^          |                                   |          |          | |                            
;                        |          |          |                                   |          v          | |                            
;                        |    Return Stack     |                                   | --- --- --- --- --- | <                            
;  MMAP_FLASH_D_START -> +----------+----------+                                   |                     |                      
;             ($4000)    |                     |                                   | --- --- --- --- --- | <- [RSP=SP]                  
;                        |    Program Space    |                                   |          ^          |                      
;                        |                     |                                   |          |          |                      
; MMAP_FLASHWIN_START -> +----------+----------+                                   |    Return Stack     |                      
;             ($8000)    |    Non-Volatile     |                   MMAP_RAM_END -> +----------+----------+                      
;                        |  User Dictionary    |                        ($4000)                                                        
;                        |          |          |             
;                        |          v          |             
;                        | --- --- --- --- --- |
;                        |                     |                  
;  MMAP_FLASH_D_START -> +----------+----------+
;             ($C000)    |                     |             
;                        |    Program Space    |                  
;                        |                     |             
;          TABS_START -> +----------+----------+        
;                        |        Tables       |                  
;        VECTAB_START -> +----------+----------+        
;             ($DF00)    |    Vector Table     |                  
;    BOOTLOADER_START -> +----------+----------+        
;             ($E000)    |     Bootloader      |             
;                        +----------+----------+

#ifndef	LRE_COMPILE
			;FLASH_COMPILE
			;=============
			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN

VARS_START		EQU	*	
VARS_START_LIN		EQU	@
			ORG	MMAP_RAM_END, MMAP_RAM_END_LIN

DS_PS_START		EQU	*			
DS_PS_START_LIN		EQU	@
			ORG	DS_PS_END, DS_PS_END_LIN 

TIB_RS_START		EQU	*			
TIB_RS_START_LIN	EQU	@
			ORG	TIB_RS_END, TIB_RS_END_LIN 


	
	
	
#else




#endif

	
;###############################################################################
;# Module configuration                                                                            #
;###############################################################################
		
;;# Clocks
;CLOCK_CPMU		EQU	1		;CPMU
;CLOCK_IRC		EQU	1		;use IRC
;CLOCK_OSC_FREQ		EQU	 1000000	; 1 MHz IRC frequency
;CLOCK_BUS_FREQ		EQU	25000000	; 25 MHz bus frequency
;CLOCK_REF_FREQ		EQU	 1000000	; 1 MHz reference clock frequency
;CLOCK_VCOFRQ		EQU	$1		; 10 MHz VCO frequency
;CLOCK_REFFRQ		EQU	$0		;  1 MHz reference clock frequency
;
;;# Memory map:
;MMAP_S12G128		EQU	1 		;S12G128
;MMAP_RAM		EQU	1 		;use RAM memory map
;
;;# Interrupt stack
;ISTACK_LEVELS		EQU	1	 	;interrupt nesting not guaranteed
;ISTACK_DEBUG		EQU	1 		;don't enter wait mode
;
;;# Subroutine stack
;SSTACK_DEPTH		EQU	27	 	;no interrupt nesting
;SSTACK_DEBUG		EQU	1 		;debug behavior
;
;;# COP
;COP_DEBUG		EQU	1 		;disable COP
;
;;# RESET
;RESET_WELCOME		EQU	DEMO_WELCOME 	;welcome message
;	
;;# Vector table
;VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs
;	
;;# SCI
;SCI_FC_RTSCTS		EQU	1 		;RTS/CTS flow control
;SCI_RTS_PORT		EQU	PTM 		;PTM
;SCI_RTS_PIN		EQU	PM0		;PM0
;SCI_CTS_PORT		EQU	PTM 		;PTM
;SCI_CTS_PIN		EQU	PM1		;PM1
;SCI_HANDLE_BREAK	EQU	1		;react to BREAK symbol
;SCI_HANDLE_SUSPEND	EQU	1		;react to SUSPEND symbol
;SCI_BD_ON		EQU	1 		;use baud rate detection
;SCI_BD_TIM		EQU	1 		;TIM
;SCI_BD_ICPE		EQU	0		;IC0
;SCI_BD_ICNE		EQU	1		;IC1			
;SCI_BD_OC		EQU	2		;OC2			
;SCI_BD_LOG_ON		EQU	1		;log captured BD pulses			
;SCI_DLY_OC		EQU	3		;OC3
;SCI_ERRSIG_ON		EQU	1 		;signal errors
;SCI_BLOCKING_ON		EQU	1		;enable blocking subroutines
	
;###############################################################################
;# Ressource a                                                          #
;###############################################################################
			ORG	MMAP_RAM_START
;Code
START_OF_CODE		EQU	*	
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@

BASE_CODE_START		EQU	DEMO_CODE_END
BASE_CODE_START_LIN	EQU	DEMO_CODE_END_LIN

;Variables
DEMO_VARS_START		EQU	BASE_CODE_END
DEMO_VARS_START_LIN	EQU	BASE_CODE_END_LIN
	
BASE_VARS_START		EQU	DEMO_VARS_END
BASE_VARS_START_LIN	EQU	DEMO_VARS_END_LIN

;Tables
DEMO_TABS_START		EQU	BASE_VARS_END
DEMO_TABS_START_LIN	EQU	BASE_VARS_END_LIN
	
BASE_TABS_START		EQU	DEMO_TABS_END
BASE_TABS_START_LIN	EQU	DEMO_TABS_END_LIN

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./base_S12G-Micro-EVB.s		;S12CBase bundle
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	DEMO_VARS_START, DEMO_VARS_START_LIN

DEMO_VARS_END		EQU	*
	
DEMO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;Break handler
#macro	SCI_BREAK_ACTION, 0
			LED_BUSY_ON
#emac
	
;Suspend handler
#macro	SCI_SUSPEND_ACTION, 0
			LED_BUSY_OFF
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN

;Initialization
			BASE_INIT
	
;Application code
DEMO_LOOP		SCI_RX_BL
			;Ignore RX errors 
			ANDA	#(SCI_FLG_SWOR|OR|NF|FE|PF)
			BNE	DEMO_LOOP
			;TBNE	A, DEMO_LOOP

			;Print ASCII character (char in B)
			TFR	D, X
			LDAA	#4
			LDAB	#" "
			STRING_FILL_BL
			TFR	X, D
			CLRA
			STRING_PRINTABLE
			SCI_TX_BL

			;Print hexadecimal value (char in X)
			LDY	#$0000
			LDAB	#16
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#5
			LDAB	#" "
			STRING_FILL_BL
			LDAB	#16
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print decimal value (char in X)
			LDY	#$0000
			LDAB	#10
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#5
			LDAB	#" "
			STRING_FILL_BL
			LDAB	#10
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print octal value (char in X)
			LDY	#$0000
			LDAB	#8
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#5
			LDAB	#" "
			STRING_FILL_BL
			LDAB	#8
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print binary value (char in X)
			LDAA	#2
			LDAB	#" "
			STRING_FILL_BL
			LDY	#$0000
			LDAB	#2
			NUM_REVERSE
			TFR	SP, Y
			NEGA
			ADDA	#8
			LDAB	#"0"
			STRING_fill_BL
			LDAB	#2
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Print new line
			LDX	#STRING_STR_NL
			STRING_PRINT_BL
			JOB	DEMO_LOOP
	
DEMO_CODE_END		EQU	*	
DEMO_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	DEMO_TABS_START, DEMO_TABS_START_LIN

DEMO_WELCOME		FCC	"This is the S12CBase Demo for the S12G-Micro-EVB"
			STRING_NL_NONTERM
			STRING_NL_NONTERM
			FCC	"ASCII  Hex  Dec  Oct       Bin"
			STRING_NL_NONTERM
			FCC	"------------------------------"
			STRING_NL_TERM

DEMO_TABS_END		EQU	*	
DEMO_TABS_END_LIN	EQU	@	




