;###############################################################################
;# S12CBase - BDM - Bit Level BDM Protocol Driver                              #
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
;#    This module provides routines for low bevel BDM communication.           #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	BDM_VARS_START
BDM_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	BDM_INIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	BDM_CODE_START
BDM_CODE_END		EQU	*

BDM_ISR_TGTRES		EQU	ERROR_ISR	
BDM_ISR_TC7		EQU	ERROR_ISR
BDM_ISR_TC6		EQU	ERROR_ISR
BDM_ISR_TC5		EQU	ERROR_ISR

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	BDM_TABS_START
BDM_TABS_END		EQU	*

