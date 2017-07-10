#ifndef SREC_COMPILED
#define	SREC_COMPILED	
;###############################################################################
;# AriCalculator - Bootloader - S-Record Parser                                #
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
;#    This part of the AriCalculator's bootloader contains the S-Record        #
;#    parser.                                                                  #
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
#ifdef SREC_VARS_START_LIN
			ORG 	SREC_VARS_START, SREC_VARS_START_LIN
#else
			ORG 	SREC_VARS_START
SREC_VARS_START_LIN	EQU	@			
#endif	

SREC_VARS_END		EQU	*
SREC_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SREC_INIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef SREC_CODE_START_LIN
			ORG 	SREC_CODE_START, SREC_CODE_START_LIN
#else
			ORG 	SREC_CODE_START
SREC_CODE_START_LIN	EQU	@	
#endif
	
	
SREC_CODE_END		EQU	*	
SREC_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef SREC_TABS_START_LIN
			ORG 	SREC_TABS_START, SREC_TABS_START_LIN
#else
			ORG 	SREC_TABS_START
SREC_TABS_START_LIN	EQU	@	
#endif	

	
SREC_TABS_END		EQU	*
SREC_TABS_END_LIN	EQU	@
#endif
