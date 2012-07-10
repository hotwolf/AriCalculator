;###############################################################################
;# S12CBase - SCI Test (OpenBDC Pod)                                           #
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
;#    This demo application echoes ASCII characters it receives over the       #
;#    RS232 interface.                                                         #
;#                                                                             #
;# Usage:                                                                      #
;#    1. Place the RAM onto the vector space                                   #
;#       $FF -> INITRM                                                         #
;#    2. Upload S-Record                                                       #
;#    3. Execute code at address "START_OF_CODE"                               #
;###############################################################################
;# Version History:                                                            #
;#    July 3, 2012                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# Memory map:
MMAP_RAM		EQU	1 		;use RAM memory map
MMAP_RAM_SIZE		EQU	$1000		;4K RAM
;MMAP_RAM_SIZE		EQU	$800		;2K RAM
MMAP_FLASH_SIZE		EQU	$20000 		;128K Flash
;MMAP_FLASH_SIZE	EQU	$8000 		;32K Flash
	

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	BASE_APP_START
;			ORG	BASE_VARS_END
;BASE_APP_START		EQU	*

			SCI_RX
			LED_BUSY_ON		;signal activity

			PRINT_LINE_BREAK
			LDX	#MAIN_STR_CHAR 	;print ASCII value
			PRINT_STR
			PRINT_CHAR

			LDX	#MAIN_STR_DEC 	;print decimal value
			PRINT_STR
			EXG	B,X
			LDAA	#3
			LDAB	#10
			PRINT_RUINT

	                EXG	X,B
			LDX	#MAIN_STR_HEX 	;print hexadecimal value
			PRINT_STR
			EXG	B,X	
			LDAA	#2
			LDAB	#16
			PRINT_RUINT

	                EXG	X,B
			LDX	#MAIN_STR_BIN 	;print binary value
			PRINT_STR
			PRINT_BYTE
	
			JOB	BASE_APP_START

BASE_APP_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			;ORG	BASE_TABS_END

MAIN_STR_CHAR		FCS	"Char:"
MAIN_STR_HEX		FCS	" Hex:"
MAIN_STR_DEC		FCS	" Dec:"
MAIN_STR_BIN		FCS	" Bits:"
		
MAIN_TABS_END		EQU	*
   
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Source/base_simhc12.s         ;framework bundle
