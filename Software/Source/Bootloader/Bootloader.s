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
#ifndef LRE_COMPILE
FLASH_COMPILE		EQU	1 		;default target is NVM
#endif	
#endif

;# Size of the bootloader code
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
;                        FLASH_COMPILE:                                     LRE_COMPILE:
;                        ==============                                     ============
;      MMAP_REG_START -> +----------+----------+        MMAP_REG_START -> +----------+----------+                              
;             ($0000)    |   Register Space    |               ($0000)    |   Register Space    |                             
;        MMAP_REG_END -> +----------+----------+          MMAP_REG_END -> +----------+----------+                             
;             ($0400)    :       unused        :               ($0400)    :       unused        :                             
;     MMAP_RAM_START, -> +----------+----------+       MMAP_RAM_START, -> +----------+----------+                             
;    VECTAB_START_LRE    |    Vector Table     |      VECTAB_START_LRE    |    Vector Table     |                                  
;      TABS_START_LRE -> +----------+----------+        TABS_START_LRE -> +----------+----------+                             
;                        |       Tables        |                          |       Tables        |                             
;      CODE_START_LRE -> +----------+----------+        CODE_START_LRE -> +----------+----------+                             
;                        |    Program Space    |                          |    Program Space    |                             
;                        |                     |                          |                     |                             
;          VARS_START -> +----------+----------+            VARS_START -> +----------+----------+                             
;                        |  Global Variables   |                          |  Global Variables   |
;                        +----------+----------+  VECTAB_START_LRE_LIN -> +----------+----------+
;                        |                     |                          |Vector Table (source)|            
;                        |                     |    TABS_START_LRE_LIN -> +----------+----------+            
;                        |                     |                          |   Tables (source)   |            
;                        |                     |    CODE_START_LRE_LIN -> +----------+----------+            
;                        |                     |                          |    Program Space    |             
;                        |                     |                          |      (Source)       |            
;                        |       unused        |                          +----------+----------+            
;                        |                     |                          |        Tables       |             
;  	                 |                     |                          +----------+----------+                  
;                        |                     |                          |    Program Space    |        
;                        |                     |                          +----------+----------+            
;                        |                     |                          |        unused       |            
;        MMAP_RAM_END -> +----------+----------+          MMAP_RAM_END -> +----------+----------+ 
;                        :       unused        |                    
; MMAP_FLASH_F_START, -> +----------+----------+  
; VECTAB_START_LRE_LIN   |Vector Table (source)|               
;  TABS_START_LRE_LIN -> +----------+----------+                    
;                        |   Tables (source)   |               
;  CODE_START_LRE_LIN -> +----------+----------+                    
;                        |    Program Space    |          
;                        |      (Source)       |                    
;                        +----------+----------+          
;                        |        Tables       |               
;  	                 +----------+----------+                    
;                        |    Program Space    |          
;                        +----------+----------+          
;                        |    Vector Table     |                    
;                        +----------+----------+          

#ifdef	LRE_COMPILE
			;LRE_COMPILE
			;===========
			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN

VECTAB_START		EQU	*	
VECTAB_START_LIN	EQU	@
			ORG	VECTAB_END, VECTAB_END_LIN

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
			DS	MMAP_RAM_END-(*+TIB_RS_SIZE)
DS_PS_END		EQU	*
DS_PS_END_LIN		EQU	@

TIB_RS_START		EQU	*
TIB_RS_START_LIN	EQU	@
			DS	MMAP_RAM_END-*
TIB_RS_END		EQU	*			
TIB_RS_END_LIN		EQU	@
#else
			;FLASH_COMPILE
			;=============
			ORG	MMAP_RAM_START, MMAP_RAM_START_LIN

VARS_START		EQU	*	
VARS_START_LIN		EQU	@
			ORG	VARS_END, VARS_END_LIN
	
DS_PS_START		EQU	*			
DS_PS_START_LIN		EQU	@
			DS	MMAP_RAM_END-(*+TIB_RS_SIZE)
DS_PS_END		EQU	*
DS_PS_END_LIN		EQU	@

TIB_RS_START		EQU	*
TIB_RS_START_LIN	EQU	@
			DS	MMAP_RAM_END-*
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

			ORG	MMAP_FLASH_F_END, MMAP_FLASH_F_END_LIN
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
;#CLOCK

;#COP

;#RESET

;#GPIO

;#MMAP: 
#ifdef LRE_COMPILE
MMAP_UNSEC_OFF		EQU	1 	;don't set the security byte for LRE compiles
#endif
#ifdef BOOTLOADER
MMAP_UNSEC_OFF		EQU	1 	;don't set the security byte if a bootloader is used
#endif

;#COP

;#RESET

;#GPIO

;#MMAP

;#VECTAB
	
;#SSTACK: 
SSTACK_TOP		EQU	TIB_RS_START ;stack range
SSTACK_BOTTOM		EQU	TIB_RS_END   ;stack range

;#ISTACK 
#ifdef LRE_COMPILE
ISTACK_NO_WAI		EQU	1 	;don't enter wait mode when debugging
#endif

;#NVM
	
;#TIM:
;TIM_TIOS_INIT		EQU	BASE_TIOS_INIT|FORTH_TIOS_INIT
TIM_TIOS_INIT		EQU	BASE_TIOS_INIT
TIM_TTOV_INIT		EQU	BASE_TTOV_INIT
TIM_TCTL12_INIT		EQU	BASE_TCTL12_INIT
TIM_TCTL34_INIT		EQU	BASE_TCTL34_INIT

;#LED

;#BACKLIGHT

;#KEYS

;#DELAY

;#SCI							

;#DISP							

;#VMON							

;#RANDOM							

;#STRING							

;#NUM							
	
;# S12CForth
	
;# AriCalculator
	
;###############################################################################
;# Initialization                                                              #
;###############################################################################
#macro	INIT, 0



	
#emac
	
;###############################################################################
;# Global variable space                                                       #
;###############################################################################
				ORG	BOOTLOADER_VARS_START, BPPTLOADER_VARS_START_LIN

CLOCK_VARS_START		EQU	*
CLOCK_VARS_START_LIN		EQU	@
				ORG	CLOCK_VARS_END, CLOCK_VARS_END_LIN
				
COP_VARS_START			EQU	*
COP_VARS_START_LIN		EQU	@
				ORG	COP_VARS_END, COP_VARS_END_LIN
				
RESET_VARS_START		EQU	*
RESET_VARS_START_LIN		EQU	@
				ORG	RESET_VARS_END, RESET_VARS_END_LIN
					
GPIO_VARS_START			EQU	*
GPIO_VARS_START_LIN		EQU	@
				ORG	GPIO_VARS_END, GPIO_VARS_END_LIN

MMAP_VARS_START			EQU	*	 
MMAP_VARS_START_LIN		EQU	@
				ORG	MMAP_VARS_END, MMAP_VARS_END_LIN
				
VECTAB_VARS_START		EQU	*
VECTAB_VARS_START_LIN		EQU	@
				ORG	VECTAB_VARS_END, VECTAB_VARS_END_LIN

SSTACK_VARS_START		EQU	*
SSTACK_VARS_START_LIN		EQU	@
				ORG	SSTACK_VARS_END, SSTACK_VARS_END_LIN
				
ISTACK_VARS_START		EQU	*
ISTACK_VARS_START_LIN		EQU	@
				ORG	ISTACK_VARS_END, ISTACK_VARS_END_LIN

NVM_VARS_START			EQU	*
NVM_VARS_START_LIN		EQU	@
				ORG	NVM_VARS_END, NVM_VARS_END_LIN
				
TIM_VARS_START			EQU	*
TIM_VARS_START_LIN		EQU	@
				ORG	TIM_VARS_END, TIM_VARS_END_LIN
	
SCI_VARS_START			EQU	*
SCI_VARS_START_LIN		EQU	@
				ORG	SCI_VARS_END, SCI_VARS_END_LIN
				
DISP_VARS_START			EQU	*
DISP_VARS_START_LIN		EQU	@
				ORG	DISP_VARS_END, DISP_VARS_END_LIN
				
NUM_VARS_START			EQU	*
NUM_VARS_START_LIN		EQU	@
				ORG	NUM_VARS_END, NUM_VARS_END_LIN

BOOTLOADER_VARS_END		EQU	*
BOOTLOADER_VARS_END_LIN		EQU	@
	
;###############################################################################
;# Code space                                                                  #
;###############################################################################
				ORG	BOOTLOADER_CODE_START, BPPTLOADER_CODE_START_LIN

CLOCK_CODE_START		EQU	*
CLOCK_CODE_START_LIN		EQU	@
				ORG	CLOCK_CODE_END, CLOCK_CODE_END_LIN
				
COP_CODE_START			EQU	*
COP_CODE_START_LIN		EQU	@
				ORG	COP_CODE_END, COP_CODE_END_LIN
				
RESET_CODE_START		EQU	*
RESET_CODE_START_LIN		EQU	@
				ORG	RESET_CODE_END, RESET_CODE_END_LIN
					
GPIO_CODE_START			EQU	*
GPIO_CODE_START_LIN		EQU	@
				ORG	GPIO_CODE_END, GPIO_CODE_END_LIN

MMAP_CODE_START			EQU	*	 
MMAP_CODE_START_LIN		EQU	@
				ORG	MMAP_CODE_END, MMAP_CODE_END_LIN
				
VECTAB_CODE_START		EQU	*
VECTAB_CODE_START_LIN		EQU	@
				ORG	VECTAB_CODE_END, VECTAB_CODE_END_LIN

SSTACK_CODE_START		EQU	*
SSTACK_CODE_START_LIN		EQU	@
				ORG	SSTACK_CODE_END, SSTACK_CODE_END_LIN
				
ISTACK_CODE_START		EQU	*
ISTACK_CODE_START_LIN		EQU	@
				ORG	ISTACK_CODE_END, ISTACK_CODE_END_LIN

NVM_CODE_START			EQU	*
NVM_CODE_START_LIN		EQU	@
				ORG	NVM_CODE_END, NVM_CODE_END_LIN
				
TIM_CODE_START			EQU	*
TIM_CODE_START_LIN		EQU	@
				ORG	TIM_CODE_END, TIM_CODE_END_LIN
	
SCI_CODE_START			EQU	*
SCI_CODE_START_LIN		EQU	@
				ORG	SCI_CODE_END, SCI_CODE_END_LIN
				
DISP_CODE_START			EQU	*
DISP_CODE_START_LIN		EQU	@
				ORG	DISP_CODE_END, DISP_CODE_END_LIN
				
NUM_CODE_START			EQU	*
NUM_CODE_START_LIN		EQU	@
				ORG	NUM_CODE_END, NUM_CODE_END_LIN

BOOTLOADER_CODE_END		EQU	*
BOOTLOADER_CODE_END_LIN		EQU	@
	
;###############################################################################
;# Table space                                                                 #
;###############################################################################
				ORG	BOOTLOADER_TABS_START, BPPTLOADER_TABS_START_LIN

CLOCK_TABS_START		EQU	*
CLOCK_TABS_START_LIN		EQU	@
				ORG	CLOCK_TABS_END, CLOCK_TABS_END_LIN
				
COP_TABS_START			EQU	*
COP_TABS_START_LIN		EQU	@
				ORG	COP_TABS_END, COP_TABS_END_LIN
				
RESET_TABS_START		EQU	*
RESET_TABS_START_LIN		EQU	@
				ORG	RESET_TABS_END, RESET_TABS_END_LIN
					
GPIO_TABS_START			EQU	*
GPIO_TABS_START_LIN		EQU	@
				ORG	GPIO_TABS_END, GPIO_TABS_END_LIN

MMAP_TABS_START			EQU	*	 
MMAP_TABS_START_LIN		EQU	@
				ORG	MMAP_TABS_END, MMAP_TABS_END_LIN
				
VECTAB_TABS_START		EQU	*
VECTAB_TABS_START_LIN		EQU	@
				ORG	VECTAB_TABS_END, VECTAB_TABS_END_LIN

SSTACK_TABS_START		EQU	*
SSTACK_TABS_START_LIN		EQU	@
				ORG	SSTACK_TABS_END, SSTACK_TABS_END_LIN
				
ISTACK_TABS_START		EQU	*
ISTACK_TABS_START_LIN		EQU	@
				ORG	ISTACK_TABS_END, ISTACK_TABS_END_LIN

NVM_TABS_START			EQU	*
NVM_TABS_START_LIN		EQU	@
				ORG	NVM_TABS_END, NVM_TABS_END_LIN
				
TIM_TABS_START			EQU	*
TIM_TABS_START_LIN		EQU	@
				ORG	TIM_TABS_END, TIM_TABS_END_LIN
	
SCI_TABS_START			EQU	*
SCI_TABS_START_LIN		EQU	@
				ORG	SCI_TABS_END, SCI_TABS_END_LIN
				
DISP_TABS_START			EQU	*
DISP_TABS_START_LIN		EQU	@
				ORG	DISP_TABS_END, DISP_TABS_END_LIN
				
NUM_TABS_START			EQU	*
NUM_TABS_START_LIN		EQU	@
				ORG	NUM_TABS_END, NUM_TABS_END_LIN

BOOTLOADER_TABS_END		EQU	*
BOOTLOADER_TABS_END_LIN		EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
;# S12CBase
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/regdef_AriCalculator.s ;Register definitions
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/gpio_AriCalculator.s   ;I/O setup
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/AriCalculator/memmap_AriCalculator.s ;Memory map
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sstack.s		  	 ;Subroutine stack
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/istack.s	  		 ;Interrupt stack
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/tim.s				 ;TIM driver
#include ../../../Subprojects/S12CForth/Subprojects/S12CBase/Source/All/sci.s				 ;SCI driver
#include ./vectab_Bootloader.s	                                                                         ;S12G vector table
#include ./reset_Bootloader.s                                                                            ;Reset driver
#include ./nvm_Bootloader.s	                                                                         ;NVM driver
#include ./srec_Bootloader.s                                                                             ;S-Record handler
