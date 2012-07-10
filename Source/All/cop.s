;###############################################################################
;# S12CBase - COP - Watchdog Handler                                           #
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
;#    The module handles the COP watchdog timer.                               #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    July 2, 2012                                                             #
;#      - Added support for linear PC                                          #
;###############################################################################
;# Required Modules:                                                           #
;#    ERROR  - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Debug option to disable the COP timeout
;COP_DEBUG		EQU	1 

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef COP_VARS_START_LIN
			ORG 	COP_VARS_START, COP_VARS_START_LIN
#else
			ORG 	COP_VARS_START
COP_VARS_START_LIN	EQU	@
#endif
	
COP_VARS_END		EQU	*
COP_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	COP_INIT, 0
#ifdef	COP_DEBUG
			MOVB	#RSBCK, COPCTL		 	;COP configuration:
								; no window mode			(~WCOP)
								; COP and RTI stop when BDM is active	(RSBCK)
								; COP is disabled	(~CR2|~CR1|~CR0)
#else
			MOVB	#(RSBCK|CR2|CR1|CR0), COPCTL 	;COP configuration:
								; no window mode			(~WCOP)
								; COP and RTI stop when BDM is active	(RSBCK)
								; 10^24 oscillator cyles timeout =2.44s	(CR2|CR1|CR0)
#endif
#emac

;#Service COP
#macro	COP_SERVICE, 0
#ifndef	COP_DEBUG
			MOVB	#$55, ARMCOP
			MOVB	#$AA, ARMCOP
#endif
#emac

;#COP reset
#macro	COP_RESET, 0
#ifdef	DEBUG
			JOB	ERROR_COP_RESET_ENTRY
#else
			MOVB	#$FF, ARMCOP
#endif
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef COP_CODE_START_LIN
			ORG 	COP_CODE_START, COP_CODE_START_LIN
#else
			ORG 	COP_CODE_START
COP_CODE_START_LIN	EQU	@
#endif

COP_CODE_END		EQU	*
COP_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef COP_TABS_START_LIN
			ORG 	COP_TABS_START, COP_TABS_START_LIN
#else
			ORG 	COP_TABS_START
COP_TABS_START_LIN	EQU	@
#endif

COP_TABS_END		EQU	*
COP_TABS_END_LIN	EQU	@
