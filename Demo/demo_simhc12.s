;###############################################################################
;# S12CForth - Demo of the S12CForth Framework (SIMHC12 Version)               #
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
;  		 |    Code     |
;  		 +-------------+ 
;  		 |   Tables    |
;  		 +-------------+
;  		 |   Words     |
;  		 +-------------+ $FF80
;  		 |  Vectors    |
;  		 +-------------+ 

DEMO_VARS_START			EQU	$3000
FORTH_VARS_START		EQU	DEMO_VARS_END
FORTH_VARS_END			EQU	$4000
FORTH_CODE_START		EQU	$C000
DEMO_TABS_START			EQU	DEMO_CODE_END
FORTH_TABS_START		EQU	DEMO_TABS_END
FORTH_WORDS_START		EQU	FORTH_TABS_END
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
				ORG	DEMO_VARS_START
DEMO_VARS_END			EQU	*
	
;###############################################################################
;# Code                                                                        #
;###############################################################################	
				ORG	FORTH_APP_START
DEMO_CODE_START			EQU	*
				MOVW	#16, BASE

DEMO_ERROR			JOB	CF_QUIT

DEMO_CODE_END			EQU	*
FORTH_APP_END			EQU	*


	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
				ORG	DEMO_TABS_START
DEMO_TABS_END			EQU	*
	
;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ../Source/forth_simhc12.s	;S12CForth framework bundle
