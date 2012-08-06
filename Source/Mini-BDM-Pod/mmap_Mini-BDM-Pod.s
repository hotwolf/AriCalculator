;###############################################################################
;# S12CBase - MMAP - Memory Map (Mini-BDM-Pod)                                 #
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
;#    July 31, 2012                                                            #
;#      - Added support for linear PC                                          #
;#      - Updated memory mapping                                               #
;###############################################################################
;  Flash Memory Map:
;  -----------------  
;                     S12XE                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  		 +-------------+ $0800
;                |/////////////|	     
;   	  RAM->+ +-------------+ $1000
;  	       | |  Variables  |
;  	       + +-------------+
;                |/////////////|	     
;  	Flash->+ +-------------+ $4000
;  	       | |    Code     |
;  	       | +-------------+ 
;  	       | |   Tables    |
;  	       | +-------------+
;              | |/////////////|	     
;  	       | +-------------+ $DF10
;  	       | |   Vectors   |
;  	       | +-------------+ $E000
;  	       | | BootLoader  |
;  	       + +-------------+ 
; 
;  RAM Memory Map:
;  ---------------  
;                     S12XE                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  		 +-------------+ $0800
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
;  		 +-------------+ $E000
;  		 | BootLoader  |
;  		 +-------------+ 

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
			;Set within bootloader code 
			;ORG	$FF0D	;unprotect
			;DB	$FF
			;ORG	$FF0F	;unsecure
			;DB	$FE

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;# Memory Sizes:
REG_SIZE		EQU	$0800
;S12C128
RAM_SIZE		EQU	$3000
FLASH_SIZE		EQU	$20000

;# Memory Locations
REG_START		EQU	$0000
REG_END			EQU	$0800

RAM_START		EQU	$1000
RAM_END			EQU	$4000

FLASH_START		EQU	$C000
FLASH_END		EQU	$E000

;# Init code
;INIT_CODE		EQU	$E002
	
;# Vector table
#ifndef VECTAB_START
#ifdef	MMAP_RAM
VECTAB_START		EQU	$3F10    
VECTAB_START_LIN	EQU	$0FFF10    
#endif
#ifdef	MMAP_FLASH
VECTAB_START		EQU	$EF10    
VECTAB_START_LIN	EQU	$7FEF10    
#endif
#endif
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	MMAP_VARS_START
MMAP_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	MMAP_INIT, 0
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	MMAP_CODE_START
MMAP_CODE_END		EQU	*	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	MMAP_TABS_START
MMAP_TABS_END		EQU	*


