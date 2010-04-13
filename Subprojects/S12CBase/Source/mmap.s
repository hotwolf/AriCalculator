;###############################################################################
;# S12CBase - MMAP - Memory Map                                                #
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
;###############################################################################
;  Memory Map:
;  -----------  
;        	 +-------------+ $0000
;  		 |  Registers  |
;  		 +-------------+ $0400
;  		 |/////////////|
;  		 +-------------+ $3000
;  		 |  Variables  |
;  		 +-------------+ $4000
;  		 |/////////////|
;  		 +-------------+ $C000
;  		 |             |
;  		 |    Code     |
;  		 |             |
;  		 +-------------+ $E000 
;  		 |   Tables    |
;  		 +-------------+ $FF80
;  		 |  Vectors    |
;  		 +-------------+ 

;###############################################################################
;# Security and Protection                                                     #
;###############################################################################
			ORG	$FF0D	;unprotect
			DB	$FF
			ORG	$FF0F	;unsecure
			DB	$FE

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;# Memory Sizes:
REG_SIZE		EQU	$0400
;S12C128
RAM_SIZE		EQU	$1000
FLASH_SIZE		EQU	$20000
;S12C32	
;RAM_SIZE		EQU	$800
;FLASH_SIZE		EQU	$8000

;# Memory Locations
REG_START		EQU	$0000
REG_END			EQU	REG_START+REG_SIZE

RAM_START		EQU	RAM_END-RAM_SIZE
RAM_END			EQU	$4000

FLASH_START		EQU	$C000
FLASH_END		EQU	$10000
		
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
			;Setup RAM and register space
			MOVW	#((RAM_START&$FE00)|(REG_START>>8)), INITRM

			;Setup Flash
			;MOVB	#(ROMHM|ROMON), MISC
			;MOVB	#$FE, PPAGE
#EMAC	

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


