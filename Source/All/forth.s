;###############################################################################
;# S12CForth - S12CForth Bundle                                                #
;###############################################################################
;#    Copyright 2010-2013 Dirk Heisswolf                                       #
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
;#    This module bundles all standard S12CForth modules into one.             #
;###############################################################################
;# Version History:                                                            #
;#    January 29, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FORTH_VARS_START_LIN
			ORG 	FORTH_VARS_START, FORTH_VARS_START_LIN
#else
			ORG 	FORTH_VARS_START
#endif	

GPIO_VARS_START		EQU	*
GPIO_VARS_START_LIN	EQU	@


FORTH_VARS_END		EQU	VECTAB_VARS_START	
FORTH_VARS_END_LIN	EQU	VECTAB_VARS_START_LIN

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FORTH_INIT, 0
			FINNER_INIT
			FRAM_INIT

	
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FORTH_CODE_START_LIN
			ORG 	FORTH_CODE_START, FORTH_CODE_START_LIN
#else
			ORG 	FORTH_CODE_START
#endif	

GPIO_CODE_START		EQU	*
GPIO_CODE_START_LIN	EQU	@

FORTH_CODE_END		EQU	VECTAB_CODE_START	
FORTH_CODE_END_LIN	EQU	VECTAB_CODE_START_LIN

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FORTH_TABS_START_LIN
			ORG 	FORTH_TABS_START, FORTH_TABS_START_LIN
#else
			ORG 	FORTH_TABS_START
#endif	

GPIO_TABS_START		EQU	*
GPIO_TABS_START_LIN	EQU	@


FORTH_TABS_END		EQU	VECTAB_TABS_START	
FORTH_TABS_END_LIN	EQU	VECTAB_TABS_START_LIN

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FORTH_WORDS_START_LIN
			ORG 	FORTH_WORDS_START, FORTH_WORDS_START_LIN
#else
			ORG 	FORTH_WORDS_START
#endif	

FORTH_WORDS_END		EQU	VECTAB_WORDS_START	
FORTH_WORDS_END_LIN	EQU	VECTAB_WORDS_START_LIN

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./finner.s  			;Inner interpreter
#include ./fram.s			;Stacks and buffers

