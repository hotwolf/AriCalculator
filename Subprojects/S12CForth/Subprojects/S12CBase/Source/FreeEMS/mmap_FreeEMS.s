#ifndef MMAP_COMPILED
#define	MMAP_COMPILED
;###############################################################################
;# S12CBase - MMAP - Memory Map (FreeEMS)                                      #
;###############################################################################
;#    Copyright 2010-2014 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
;#    families.                                                                #
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
;#    This module performs all the necessary steps to initialize the device    #
;#    after each reset.                                                        #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;###############################################################################
;# Version History:                                                            #
;#    July  8, 2014                                                            #
;#      - Initial release                                                      #
;###############################################################################
;  Flash Memory Map:
;  -----------------  
;                      S12X                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  	         +-------------+ $0800
;                |/////////////|	     
;   	  RAM->+ +-------------+ $1000
;  	       | |  Variables  |
;  	Flash->+ +-------------+ $4000
;              | |/////////////|	     
;  	       | +-------------+ $C000
;  	       | |    Code     |
;  	       | +-------------+ 
;  	       | |   Tables    |
;  	       | +-------------+ $FF10
;  	       | |   Vectors   |
;  	       + +-------------+ 
; 
;  RAM Memory Map:
;  ---------------  
;                      S12X                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  	         +-------------+ $0800
;                |/////////////|	     
;  	  RAM->+ +-------------+ $1000
;  	       | |  Variables  |
;  	       | +-------------+
;  	       | |    Code     |
;  	       | +-------------+
;  	       | |   Tables    |
;  	       | +-------------+
;              | |/////////////|	     
;  	       | +-------------+ $3F10
;  	       | |   Vectors   |
;  	       + +-------------+ $4000
;                |/////////////|	     
;  		 +-------------+ 
; 
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;RAM or flash
#ifndef	MMAP_RAM
#ifndef	MMAP_FLASH
MMAP_FLASH		EQU	1 		;default is flash
#endif
#endif
	
;###############################################################################
;# Security and Protection                                                     #
;###############################################################################
#ifdef	MMAP_FLASH
			ORG	$FF0D	;unprotect
			DB	$FF
			ORG	$FF0F	;unsecure
			DB	$FE
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;# Memory Locations
;Register space
MMAP_REG_START		EQU	$0000
MMAP_REG_START_LIN	EQU	$00_0000
MMAP_REG_END		EQU	$0800
MMAP_REG_END_LIN	EQU	$0_0800

;EEPROM
MMAP_EE_START		EQU	$0800
MMAP_EE_START_LIN	EQU	$13_F800
MMAP_EE_END		EQU	$1000
MMAP_EE_END_LIN		EQU	$14_0000
MMAP_EE_WIN_START	EQU	MMAP_EE_START
MMAP_EE_WIN_END  	EQU	$0C00
MMAP_EE_FF_START	EQU	MMAP_EE_WIN_END
MMAP_EE_FF_START_LIN	EQU	$13_FC00
MMAP_EE_FF_END		EQU	MMAP_EE_END
MMAP_EE_FF_END_LIN	EQU	MMAP_EE_END_LIN

;RAM
MMAP_RAM_START		EQU	$1000
MMAP_RAM_START_LIN	EQU	$0F_D000
MMAP_RAM_END		EQU	$4000
MMAP_RAM_END_LIN	EQU	$10_0000
MMAP_RAM_WIN_START	EQU	MMAP_RAM_START
MMAP_RAM_WIN_END  	EQU	$2000
MMAP_RAM_FEFF_START	EQU	MMAP_RAM_WIN_END
MMAP_RAM_FEFF_START_LIN	EQU	$0F_E000
MMAP_RAM_FEFF_END	EQU	MMAP_RAM_END
MMAP_RAM_FEFF_END_LIN	EQU	MMAP_RAM_END_LIN

;Flash
MMAP_FLASH_START	EQU	$4000
MMAP_FLASH_START_LIN	EQU	$7F_4000
MMAP_FLASH_END		EQU	$10000
MMAP_FLASH_END_LIN	EQU	$80_0000
MMAP_FLASH_WIN_START	EQU	$8000
MMAP_FLASH_WIN_END  	EQU	$C000
MMAP_FLASH_FD_START	EQU	$4000
MMAP_FLASH_FD_START_LIN	EQU	$7F_4000
MMAP_FLASH_FD_END	EQU	$8000
MMAP_FLASH_FD_END_LIN	EQU	$7F_8000
MMAP_FLASH_FE_START	EQU	$8000
MMAP_FLASH_FE_START_LIN	EQU	$7F_8000
MMAP_FLASH_FE_END	EQU	$C000
MMAP_FLASH_FE_END_LIN	EQU	$7F_C000
MMAP_FLASH_FF_START	EQU	$C000
MMAP_FLASH_FF_START_LIN	EQU	$7F_C000
MMAP_FLASH_FF_END	EQU	MMAP_FLASH_END
MMAP_FLASH_FF_END_LIN	EQU	MMAP_FLASH_END_LIN
	
;# Vector table
#ifndef VECTAB_START
#ifdef	MMAP_RAM
VECTAB_START		EQU	$3F10    
VECTAB_START_LIN	EQU	$0F_FF10    
#endif
#ifdef	MMAP_FLASH
VECTAB_START		EQU	$FF10    
VECTAB_START_LIN	EQU	$7F_FF10    
#endif
#endif
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef MMAP_VARS_START_LIN
			ORG 	MMAP_VARS_START, MMAP_VARS_START_LIN
#else
			ORG 	MMAP_VARS_START
MMAP_VARS_START_LIN	EQU	@			
#endif	

MMAP_VARS_END		EQU	*
MMAP_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	MMAP_INIT, 0
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef MMAP_CODE_START_LIN
			ORG 	MMAP_CODE_START, MMAP_CODE_START_LIN
#else
			ORG 	MMAP_CODE_START
MMAP_CODE_START_LIN	EQU	@			
#endif

MMAP_CODE_END		EQU	*	
MMAP_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef MMAP_TABS_START_LIN
			ORG 	MMAP_TABS_START, MMAP_TABS_START_LIN
#else
			ORG 	MMAP_TABS_START
MMAP_TABS_START_LIN	EQU	@			
#endif	

MMAP_TABS_END		EQU	*	
MMAP_TABS_END_LIN	EQU	@	
#endif	

