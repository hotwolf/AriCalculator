#ifndef RESET_COMPILED
#define	RESET_COMPILED	
;###############################################################################
;# AriCalculator - Bootloader - Reset Handler                                  #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU family.   #
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
;#    This part of the AriCalculator's bootloader is active after reset. It    #
;#    invokes the bootloader codei if the keys ENTER and DEL are pushed,       #
;#    coming out of power-on reset. Otherwise the regular firmware will be     #
;#    started.                                                                 #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    July 10, 2017                                                            #
;#      - Initial release                                                      #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef RESET_VARS_START_LIN
			ORG 	RESET_VARS_START, RESET_VARS_START_LIN
#else
			ORG 	RESET_VARS_START
RESET_VARS_START_LIN	EQU	@			
#endif	

RESET_VARS_END		EQU	*
RESET_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	RESET_INIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef RESET_CODE_START_LIN
			ORG 	RESET_CODE_START, RESET_CODE_START_LIN
#else
			ORG 	RESET_CODE_START
RESET_CODE_START_LIN	EQU	@	
#endif
	
	
RESET_CODE_END		EQU	*	
RESET_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef RESET_TABS_START_LIN
			ORG 	RESET_TABS_START, RESET_TABS_START_LIN
#else
			ORG 	RESET_TABS_START
RESET_TABS_START_LIN	EQU	@	
#endif	

	
RESET_TABS_END		EQU	*
RESET_TABS_END_LIN	EQU	@
#endif
