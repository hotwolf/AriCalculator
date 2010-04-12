;###############################################################################
;# S12CBase - COP - Watchdog Handler                                           #
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
;#    The module handles the COP watchdog timer.                               #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#    CLOCK  - Clock driver                                                    #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Prevents COP resets.                                             #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	COP_VARS_START
COP_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	COP_INIT, 0
#ifdef	DEBUG
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
#ifdef	DEBUG
			MOVB	#$55, ARMCOP
			MOVB	#$AA, ARMCOP
#else
			MOVB	#$55, ARMCOP
			MOVB	#$AA, ARMCOP
#endif
#emac

;#COP reset
#macro	COP_RESET, 0
#ifdef	DEBUG
			JOB	BASE_ENTRY_COP
#else
			MOVB	#$FF, ARMCOP
#endif
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	COP_CODE_START
COP_CODE_END		EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	COP_TABS_START
COP_TABS_END		EQU	*
