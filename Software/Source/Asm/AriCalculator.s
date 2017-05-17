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

;# Bootloader
#ifndef BOOTLOADER_ON
#ifndef BOOTLOADER_OFF
BOOTLOADER_OFF		EQU	1 		;default is no bootloader supplort
#endif	
#endif	
#ifndef BOOTLOADER_SIZE
BOOTLOADER_SIZE		EQU	$1000 		;default is 4K
#endif	

;# Size of the shared space for return stack and text input buffer
#ifndef TIB_RS_SIZE
TIB_RS_SIZE		EQU	(((MMAP_RAM_END-DS_PS_START)/3)&-2)
#endif	

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
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
;                        |      (unused)       |                     TABS_START -> +----------+----------+                      
;      MMAP_RAM_START -> +----------+----------+                                   |       Tables        |                      
;                        |  Global Variables   |                     CODE_START -> +----------+----------+                             
;         DS_PS_START -> +----------+----------+                                   |                     |                      
;                        |    User Variables   |                                   |    Program Space    |                      
;                        |          |          |                                   |                     |                      
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
;                        |      (PPAGE D)      |                                   |          |          |                      
; MMAP_FLASHWIN_START -> +----------+----------+                                   |    Return Stack     |                      
;             ($8000)    |    Non-Volatile     |                   MMAP_RAM_END -> +----------+----------+                      
;                        |  User Dictionary    |                        ($4000)                                                        
;                        |          |          |             
;                        |          v          |             
;                        | --- --- --- --- --- |
;                        |                     |                  
;  MMAP_FLASH_F_START -> +----------+----------+
;             ($C000)    |        Tables       |             
;  	 CODE_F_START -> +----------+----------+                  
;                        |                     |             
;                        |    Program Space    |        
;                        |      (PPAGE F)      |                  
;        VECTAB_START -> +----------+----------+        
;             ($DF00)    |    Vector Table     |                  
;    BOOTLOADER_START -> +----------+----------+        
;             ($E000)    |     Bootloader      |             
;                        +----------+----------+

#ifdef	LRE_COMPILE
			;LRE_COMPILE
			;===========
			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN

VECTAB_START		EQU	*	
VECTAB_START_LIN	EQU	@
			ORG	VECCTAB_END, VECTAB_END_LIN

TABS_START		EQU	*	
TABS_START_LIN		EQU	@
			ORG	TABS_END, TABS_END_LIN

CODE_START		EQU	*	
CODE_START_LIN		EQU	@
			ORG	CODE_END, CODE_END_LIN

VARS_START		EQU	*	
VARS_START_LIN		EQU	@
			ORG	VARS_END, VARS_END_LIN

DS_PS_START		EQU	*			
DS_PS_START_LIN		EQU	@
DS_PS_END		EQU	MMAP_RAM_END-TIB-TIB_RS_SIZE
DS_PS_END_LIN		EQU	MMAP_RAM_END_LIN-TIB-TIB_RS_SIZE
TIB_RS_START		EQU	MMAP_RAM_END-TIB-TIB_RS_SIZE
TIB_RS_START_LIN	EQU	MMAP_RAM_END_LIN-TIB-TIB_RS_SIZE
TIB_RS_END		EQU	MMAP_RAM_END			
TIB_RS_END_LIN		EQU	MMAP_RAM_END_LIN
#else
			;FLASH_COMPILE
			;=============
			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN

VARS_START		EQU	*	
VARS_START_LIN		EQU	@
			ORG	VARS_END, VARS_END_LIN

DS_PS_START		EQU	*			
DS_PS_START_LIN		EQU	@
			ORG	MMAP_RAM_END, MMAP_RAM_END_LIN
DS_PS_END		EQU	*-TIB-TIB_RS_SIZE
DS_PS_END_LIN		EQU	@-TIB-TIB_RS_SIZE
TIB_RS_START		EQU	*-TIB-TIB_RS_SIZE
TIB_RS_START_LIN	EQU	@-TIB-TIB_RS_SIZE
TIB_RS_END		EQU	*			
TIB_RS_END_LIN		EQU	@

			ORG	MMAP_FLASH_D_START, MMAP_FLASH_D_START_LIN
	
CODE_D_START		EQU	*	
CODE_D_START_LIN	EQU	@
			;ORG	CODE_D_END, CODE_D_END_LIN

			ORG	MMAP_FLASH_F_START, MMAP_FLASH_F_START_LIN

TABS_START		EQU	*	
TABS_START_LIN		EQU	@
			ORG	TABS_END, TABS_END_LIN
	
CODE_F_START		EQU	*	
CODE_F_START_LIN	EQU	@
			;ORG	CODE_F_END, CODE_F_END_LIN

			ORG	FLASH_F_END, FLASH_F_END_LIN
#ifdef	BOOTLOADER_ON
			ORG	(*-BOOTLOADER_SIZE), (@-BOOTLOADER_SIZE)
BOOTLOADER_START	EQU	*	
BOOTLOADER_START_LIN	EQU	@
#endif

VECTAB_START		EQU	*-VECTAB_SIZE	
VECTAB_START_LIN	EQU	@-VECTAB_SIZE
#endif

;###############################################################################
;# Timer channel allocation                                                    #
;###############################################################################
; IC0 - SCI (baud rate detection)	;SCI driver
; OC1 - SCI (general purpose)		;SCI driver
; OC2 - DELAY				;delay driver
; OC3 - LED				;red/green LED driver 
; OC4 - KEYS				;keypad driver
; OC5 - BACKLIGHT 			;LCD backlight driver
; OC6 - FMON				;Forth sanity monitor
; OC7 - free
	
;###############################################################################
;# Module configuration                                                        #
;###############################################################################
;# S12CBase
;MMAP: 
#ifdef LRE_COMPILE
MMAP_UNSEC_OFF		EQU	1 	;don't set the security byte for LRE compiles
#endif
#ifdef BOOTLOADER
MMAP_UNSEC_OFF		EQU	1 	;don't set the security byte if a bootloader is used
#endif

;TIM:
TIM_TIOS_INIT		EQU	BASE_TIOS_INIT|FORTH_TIOS_INIT
TIM_TCTL12_INIT		EQU	BASE_TCTL12_INIT
TIM_TCTL34_INIT		EQU	BASE_TCTL34_INIT


	
;# S12CForth
	
;# AriCalculator

;###############################################################################
;# Includes                                                                    #
;###############################################################################
;# S12CBase
#include ../../../../S12CBase/Source/AriCalculator/base_AriCalculator.s
;#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/base_AriCalculator.s
	
;# S12CForth
	
;# AriCalculator
	
;###############################################################################
;# Initialization                                                              #
;###############################################################################
#macro	INIT, 0
;# S12CBase
			BASE_INIT
;# S12CForth
	
;# AriCalculator

#emac
	
;###############################################################################
;# Global variable space                                                       #
;###############################################################################
			ORG	VARS_START, VARS_START_LIN
;# S12CBase
BASE_VARS_START		EQU	*
BASE_VARS_START_LIN	EQU	@
			ORG	BASE_VARS_END, BASE_VARS_END_LIN
;# S12CForth
	
;# AriCalculator

VARS_END		EQU	*
VARS_END_LIN		EQU	@
	
;###############################################################################
;# Code space                                                                  #
;###############################################################################
#ifdef	LRE_COMPILE
			ORG	CODE_START, CODE_START_LIN
#else
			ORG	CODE_F_START, CODE_F_START_LIN
#endif	

;# S12CBase
BASE_CODE_START		EQU	*
BASE_CODE_START_LIN	EQU	@
			ORG	BASE_CODE_END, BASE_CODE_END_LIN	
;# S12CForth
	
;# AriCalculator

;# Entry code point for application code
START_OF_CODE					;start label
			INIT			;initialization routines
			BRA	*

#ifndef	LRE_COMPILE
			ALIGN	$7, $FF		;align to NVM phrase size
CODE_F_END		EQU	*
CODE_F_END_LIN		EQU	@
			ORG	CODE_D_START, CODE_D_START_LIN
#endif	

;# S12CBase
	
;# S12CForth
	
;# AriCalculator


			ALIGN	$7, $FF		;align to NVM phrase size
#ifdef	LRE_COMPILE
CODE_END		EQU	*
CODE_END_LIN		EQU	@
#else
CODE_D_END		EQU	*
CODE_D_END_LIN		EQU	@
#endif	
	
;###############################################################################
;# Table space                                                                 #
;###############################################################################
			ORG	TABS_START, TABS_START_LIN
;# S12CBase
BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@
			ORG	BASE_TABS_END, BASE_TABS_END_LIN
;# S12CForth
	
;# AriCalculator

TABS_END		EQU	*
TABS_END_LIN		EQU	@



