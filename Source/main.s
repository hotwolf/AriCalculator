;###############################################################################
;# FBDM - BDM Pod Firmware:    MAIN - Main Program                             #
;###############################################################################
;#    Copyright 2009 Dirk Heisswolf                                            #
;#    This file is part of the FBDM BDM pod firmware.                          #
;#                                                                             #
;#    FBDM is free software: you can redistribute it and/or modify             #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    FBDM is distributed in the hope that it will be useful,                  #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with FBDM.  If not, see <http://www.gnu.org/licenses/>.            #
;###############################################################################
;# Description:                                                                #
;#    This is the top level module of the FBDM BDM Pod firmware.               #
;###############################################################################
;# Required Modules:                                                           #
;#    INIT   - MCU Initialization Routine                                      #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    COP    - Watchdog Handler                                                #
;#    SCI    - UART Driver                                                     #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 22, 2009                                                           #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Global Parameters                                                           #
;###############################################################################
;DEBUG			EQU	1 ;enable debug code
;S12C32			EQU	1 ;build firmware for the S12C32, default is
	                          ;the S12C128 
;###############################################################################
;# Modules                                                                     #
;###############################################################################
#include regdef.s	;register definitions
#include mmap.s		;memory map

#include istack.s	;interrupt stack
#include sstack.s	;subroutine stack
#include gpio.s		;general purpose I/O driver
#include clock.s	;clock driver
#include cop.s		;watchdog driver
#include rti.s		;RTI handler


#include tim.s          ;timer driver
#include led.s		;LED driver
#include sci.s		;UART friver
#include bdm.s		;BDM friver
#include fmodel.s	;Forth VM model


#include print.s	;string output handler
#include welcome.s	;welcome message handler
#include init.s		;device initialization
#include vectab.s	;vector table

;###############################################################################
;# Variables                                                                   #
;###############################################################################
MAIN_VAR_END		EQU	MAIN_VAR_START

;###############################################################################
;# Code                                                                        #
;###############################################################################
MAIN_CODE_END		ORG	MAIN_CODE_START
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	MAIN_TAB_START
;#Version string
MAIN_VERSION		FCS	"V00.00"

MAIN_TAB_END		EQU	*
