;###############################################################################
;# S12CBase - Demo of the S12CBase Framework (SIMHC12 Version)                 #
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
;#    This demo application receives ASCII characters via the RS232 interface  #
;#    and returs various numeric representaions of the received character      #
;#    This version of the demo contains modifications to run on the SIM68HC12  #
;#    simulator.                                                               #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Turns off functionality tha hinders debugging.                   #
;###############################################################################

;###############################################################################
;# Global Parameters                                                           #
;###############################################################################
DEBUG                  EQU     1 ;enable debug code
	
;###############################################################################
;# Memory Map                                                                  #
;###############################################################################
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
			PRINT_BITS
	
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
