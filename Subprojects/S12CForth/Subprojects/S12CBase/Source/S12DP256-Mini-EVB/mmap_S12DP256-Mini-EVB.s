#ifndef MMAP
#define	MMAP
;###############################################################################
;# S12CBase - MMAP - Memory Map (S12DP256-Mini-EVB)                            #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    July 9, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Updated memory mapping                                               #
;###############################################################################
;  Flash Memory Map:
;  -----------------  
;                   S12DP256              
;                +-------------+ $0000            
;                |  Registers  |           
;                +-------------+ $0400           
;                |/////////////|	   
;         RAM->+ +-------------+ $1000           
;              | |  Variables  |           
;       FLASH->+ +-------------+ $4000           
;              | |    Code     |           
;              | +-------------+           
;              | |  Tables     |           
;              | +-------------+           
;              | |/////////////|	   
;              | +-------------+ $EF80           
;              | |  Vectors    |           
;  	       | +-------------+ $F000
;  	       | | BootLoader  |
;  	       + +-------------+ 
; 
;  RAM Memory Map:
;  ---------------  
;                   S12DP256               
;                +-------------+ $0000          
;                |  Registers  |               
;                +-------------+ $0400         
;                |/////////////|               
;         RAM->+ +-------------+ $D000               
;              | |  Variables  |               
;              | +-------------+               
;              | |    Code     |               
;              | +-------------+               
;              | |   Tables    |               
;              | +-------------+           
;              | |/////////////|	   
;              | +-------------+ $FF80         
;              | |  Vectors    |               
;              + +-------------+                

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
;# Constants                                                                   #
;###############################################################################
;# Memory sizes
MMAP_REG_SIZE		EQU	$0400 		;  1K
MMAP_RAM_SIZE		EQU	$3000 		; 12K
MMAP_FLASH_SIZE		EQU	$40000 		;256K
	
;# Memory Locations
MMAP_REG_START		EQU	$0000
MMAP_REG_END		EQU	MMAP_REG_START+MMAP_REG_SIZE
MMAP_INITRG_VAL		EQU	MMAP_REG_START>>8

	
#ifdef	MMAP_RAM
MMAP_RAM_END		EQU	$10000
MMAP_RAM_START		EQU	MMAP_RAM_END-MMAP_RAM_SIZE
MMAP_INITRM_VAL		EQU	((MMAP_RAM_START>>8)&$C0)|RAMHAL
#else
MMAP_RAM_START		EQU	$1000
MMAP_RAM_END		EQU	MMAP_RAM_START+MMAP_RAM_SIZE
MMAP_INITRM_VAL		EQU	(MMAP_RAM_START>>8)&$C0
#endif

#ifdef	MMAP_FLASH
MMAP_FLASHWIN_START	EQU	$8000	
MMAP_FLASHWIN_END	EQU	$C000

MMAP_FLASH3E_START	EQU	$4000	
MMAP_FLASH3E_END	EQU	$8000
MMAP_FLASH3E_START_LIN	EQU	$F8000	
MMAP_FLASH3E_END_LIN	EQU	$FC000

MMAP_FLASH3F_START	EQU	$C000	
MMAP_FLASH3F_END	EQU	$10000
MMAP_FLASH3F_START_LIN	EQU	$FC000	
MMAP_FLASH3F_END_LIN	EQU	$100000
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
			;Setup and lock RAM and register space
			MOVW	#((MMAP_INITRM_VAL<<8)|MMAP_INITRG_VAL), INITRM

#ifdef	MMAP_FLASH
			;Setup and lock flash space
			MOVB	#(ROMHM|ROMON), MISC
#ifdef	MMAP_S12C32	
			MOVB	#$FE, PPAGE
#else
			MOVB	#$FC, PPAGE
#endif
#endif
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


