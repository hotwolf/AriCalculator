;###############################################################################
;# S12CBase - MMAP - Memory Map (S12G-Micro-EVB)                               #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#    This module module performs all the necessary steps to initialize the    #
;#    device after each reset.                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    December 14, 2011                                                        #
;#      - Initial release                                                      #
;#    August 10, 2012                                                          #
;#      - Added support for linear PC                                          #
;#      - Updated memory mapping                                               #
;###############################################################################
;  Flash Memory Map:
;  -----------------  
;                      S12G                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  		 +-------------+ $0400
;  		 |    EEPROM   |
;  		 +-------------+ $0400+EEPROM_SIZE
;  		 |/////////////|
;  		 +-------------+ $4000-RAM_SIZE
;  		 |     RAM     |
;  		 +-------------+ $4000
;  		 |             |
;  		 |    Flash    |
;  		 |   Page D    |
;  		 |             |
;  		 +-------------+ $8000 
;  		 |             |
;  		 |    Flash    |
;  		 |   Page E/   |
;  		 |   window    |
;  		 +-------------+ $C000 
;  		 |             |
;  		 |    Code     |
;  		 |   Page F    |
;  	
	 |             |
;  		 +-------------+ $10000 
; 
;  RAM Memory Map:
;  ---------------  
;                      S12G                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  		 +-------------+ $0400
;                |/////////////|	     
;  	  RAM->+ +-------------+ $4000-RAM_SIZE
;  	       | |  Variables  |
;  	       | +-------------+
;  	       | |    Code     |
;  	       | +-------------+ 
;  	       | |   Tables    |
;  	       | +-------------+
;              | |/////////////|	     
;  	       | +-------------+ $3F80
;  	       | |   Vectors   |
;  	       + +-------------+ $4000

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;MCU (S12G32, S12G64, S12G128, or S12G240)
#ifndef	MMAP_S12G32
#ifndef	MMAP_S12G64
#ifndef	MMAP_S12G128
#ifndef	MMAP_S12G240
MMAP_S12G128		EQU	1 	;default is S12G128
#endif
#endif
#endif
#endif

;RAM or flash
#ifndef	MMAP_RAM
#ifndef	MMAP_FLASH
MMAP_FLASH		EQU	1 	;default is flash
#endif
#endif
	
;###############################################################################
;# Security and Protection                                                     #
;###############################################################################
			;Set within bootloader code 
#ifdef	MMAP_FLASH
			ORG	$FF0D	;unprotect
			DB	$FF
			ORG	$FF0F	;unsecure
			DB	$FE
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;# Memory Sizes:
#ifdef	MMAP_S12G32
MMAP_REG_SIZE		EQU	 $0400 	;  1k
MMAP_EEPROM_SIZE	EQU	 $0400 	;  1k
MMAP_MMAP_RAM_SIZE	EQU	 $0800 	;  2k
FLASH_SIZE		EQU	 $8000 	; 32k
#endif				 	  
#ifdef	MMAP_S12G64			 	  
MMAP_REG_SIZE		EQU	 $0400 	;  1k
MMAP_EEPROM_SIZE	EQU	 $0800 	;  2k
MMAP_RAM_SIZE		EQU	 $1000 	;  4k
MMAP_FLASH_SIZE		EQU	$10000 	; 64k
#endif					  
#ifdef	MMAP_S12G128			 	  
MMAP_REG_SIZE		EQU	 $0400 	;  1k
MMAP_EEPROM_SIZE	EQU	 $1000 	;  4k
MMAP_RAM_SIZE		EQU	 $2000 	;  8k
MMAP_FLASH_SIZE		EQU	$20000 	;128k
#endif
#ifdef	MMAP_S12G240			 	  
MMAP_REG_SIZE		EQU	 $0400 	;  1k
MMAP_EEPROM_SIZE	EQU	 $1000 	;  4k
MMAP_RAM_SIZE		EQU	 $2C00 	; 11k
MMAP_FLASH_SIZE		EQU	$3C000 	;240k
#endif

;# Memory Locations
MMAP_REG_START		EQU	$0000
MMAP_REG_END		EQU	$0400

MMAP_EEPROM_START	EQU	$0400
MMAP_EEPROM_END		EQU	$0400+MMAP_EEPROM_SIZE

MMAP_RAM_START		EQU	$4000-MMAP_RAM_SIZE
MMAP_RAM_END		EQU	$4000

#ifdef	MMAP_S12G32
MMAP_FLASH_START	EQU	$8000
#else
MMAP_FLASH_START	EQU	$4000
#endif
MMAP_FLASH_END		EQU	$10000
	
;# Vector table
#ifndef VECTAB_START
#ifdef	MMAP_RAM
VECTAB_START		EQU	$3F80    
VECTAB_START_LIN	EQU	$003F80   
#endif
#ifdef	MMAP_FLASH
VECTAB_START		EQU	$FF80    
VECTAB_START_LIN	EQU	$3FFF80   
#endif
#endif
	
;###############################################################################
;# Security and Protection                                                     #
;###############################################################################
#ifdef	MMAP_FLASH
			;Set within bootloader code 
			ORG	$FF0D	;unprotect
			DB	$FF
			ORG	$FF0F	;unsecure
			DB	$FE
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


