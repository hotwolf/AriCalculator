;###############################################################################
;# S12CForth - Demo of the S12CForth Framework                                 #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
;#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
;#    family.                                                                  #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#   This demo application receives ASCII characters via the RS232 interface   #
;#   and returs various numeric representaions of the received character       #
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
;			ORG	FORTH_APP_START
			ORG	RAM_START
FORTH_APP_START		EQU	*


FORTH_VARS_START	EQU	*

	
	
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
#include ../Source/forth.s         ;framework bundle
