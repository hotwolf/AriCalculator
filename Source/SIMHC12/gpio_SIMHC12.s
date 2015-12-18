#ifndef GPIO_COMPILED
#define GPIO_COMPILED
;###############################################################################
;# S12CBase - GPIO - GPIO Handler (SIMHC12)                                    #
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
;#    This module initializes all unused GPIO ports. The OpenBDM firmware      #
;#    assumes the following I/O pin configuration of the S12C128 MCU:          #
;#    Port A:                                                                  #
;#     PA0 - NC                           (input        pull-up)               #
;#     PA1 - NC                           (input        pull-up)               #
;#     PA2 - NC                           (input        pull-up)               #
;#     PA3 - NC                           (input        pull-up)               #
;#     PA4 - NC                           (input        pull-up)               #
;#     PA5 - NC                           (input        pull-up)               #
;#     PA6 - NC                           (input        pull-up)               #
;#     PA7 - NC                           (input        pull-up)               #
;#    Port B:                                                                  #
;#     PB0 - NC                           (input        pull-up)               #
;#     PB1 - NC                           (input        pull-up)               #
;#     PB2 - NC                           (input        pull-up)               #
;#     PB3 - NC                           (input        pull-up)               #
;#     PB4 - NC                           (input        pull-up)               #
;#     PB5 - NC                           (input        pull-up)               #
;#     PB6 - NC                           (input        pull-up)               #
;#     PB7 - NC                           (input        pull-up)               #
;#    Port C:                                                                  #
;#     PC0 - NC                           (input        pull-up)               #
;#     PC1 - NC                           (input        pull-up)               #
;#     PC2 - NC                           (input        pull-up)               #
;#     PC3 - NC                           (input        pull-up)               #
;#     PC4 - NC                           (input        pull-up)               #
;#     PC5 - NC                           (input        pull-up)               #
;#     PC6 - NC                           (input        pull-up)               #
;#     PC7 - NC                           (input        pull-up)               #
;#    Port D:                                                                  #
;#     PD0 - NC                           (input        pull-up)               #
;#     PD1 - NC                           (input        pull-up)               #
;#     PD2 - NC                           (input        pull-up)               #
;#     PD3 - NC                           (input        pull-up)               #
;#     PD4 - NC                           (input        pull-up)               #
;#     PD5 - NC                           (input        pull-up)               #
;#     PD6 - NC                           (input        pull-up)               #
;#     PD7 - NC                           (input        pull-up)               #
;#    Port E:                                                                  #
;#     PE0 - /IRQ                         (input        pull-up)               #
;#     PE1 - /XIRQ                        (input        no pull)               #
;#     PE2 - NC                           (input        pull-up)               #
;#     PE3 - NC                           (input        pull-up)               #
;#     PE4 - NC                           (input        no pull)               #
;#     PE5 - NC                           (input        no pull)               #
;#     PE6 - NC                           (input        no pull)               #
;#     PE7 - NC                           (input        no pull)               #
;#    Port F:                                                                  #
;#     PF0 - NC                           (input        pull-up)               #
;#     PF1 - NC                           (input        pull-up)               #
;#     PF2 - NC                           (input        pull-up)               #
;#     PF3 - NC                           (input        pull-up)               #
;#     PF4 - NC                           (input        pull-up)               #
;#     PF5 - NC                           (input        pull-up)               #
;#     PF6 - NC                           (input        pull-up)               #
;#    Port G:                                                                  #
;#     PG0 - NC                           (input        pull-up)               #
;#     PG1 - NC                           (input        pull-up)               #
;#     PG2 - NC                           (input        pull-up)               #
;#     PG3 - NC                           (input        pull-up)               #
;#     PG4 - NC                           (input        pull-up)               #
;#     PG5 - NC                           (input        pull-up)               #
;#    Port H:                                                                  #
;#     PH0 - NC                           (input        pull-up)               #
;#     PH1 - NC                           (input        pull-up)               #
;#     PH2 - NC                           (input        pull-up)               #
;#     PH3 - NC                           (input        pull-up)               #
;#     PH4 - NC                           (input        pull-up)               #
;#     PH5 - NC                           (input        pull-up)               #
;#     PH6 - NC                           (input        pull-up)               #
;#     PH7 - NC                           (input        pull-up)               #
;#    Port J:                                                                  #
;#     PJ0 - NC                           (input        no pull)               #
;#     PJ1 - NC                           (input        no pull)               #
;#     PJ2 - NC                           (input        no pull)               #
;#     PJ3 - NC                           (input        no pull)               #
;#     PJ4 - NC                           (input        no pull)               #
;#     PJ5 - NC                           (input        no pull)               #
;#     PJ6 - NC                           (input        no pull)               #
;#     PJ7 - NC                           (input        no pull)               #
;#    Port S:                                                                  #
;#     PS0 - SCI RX input                 (input        no pull)               #
;#     PS1 - SCI TX output                (output       no pull)               #
;#     PS2 - NC                           (input        no pull)               #
;#     PS3 - NC                           (input        no pull)               #
;#     PS4 - NC                           (input        no pull)               #
;#     PS5 - NC                           (input        no pull)               #
;#     PS6 - NC                           (input        no pull)               #
;#     PS7 - NC                           (input        no pull)               #
;#    Port T:                                                                  #
;#     PT0 - NC                           (input        no pull)               #
;#     PT1 - NC                           (input        no pull)               #
;#     PT2 - NC                           (input        no pull)               #
;#     PT3 - NC                           (input        no pull)               #
;#     PT4 - NC                           (input        no pull)               #
;#     PT5 - NC                           (input        no pull)               #
;#     PT6 - NC                           (input        no pull)               #
;#     PT7 - NC                           (input        no pull)               #
;#    Port AD:                                                                 #
;#     PAD0 - NC                          (input        no pull)               #
;#     PAD1 - NC                          (input        no pull)               #
;#     PAD2 - NC                          (input        no pull)               #
;#     PAD3 - NC                          (input        no pull)               #
;#     PAD4 - NC                          (input        no pull)               #
;#     PAD5 - NC                          (input        no pull)               #
;#     PAD6 - NC                          (input        no pull)               #
;#     PAD7 - NC                          (input        no pull)               #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    July 10, 2012                                                             #
;#      - Added support for linear PC                                          #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef GPIO_VARS_START_LIN
			ORG 	GPIO_VARS_START, GPIO_VARS_START_LIN
#else
			ORG 	GPIO_VARS_START
GPIO_VARS_START_LIN	EQU	@			
#endif	

GPIO_VARS_END		EQU	*
GPIO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	GPIO_INIT, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef GPIO_CODE_START_LIN
			ORG 	GPIO_CODE_START, GPIO_CODE_START_LIN
#else
			ORG 	GPIO_CODE_START
GPIO_CODE_START_LIN	EQU	@			
#endif	

GPIO_CODE_END		EQU	*	
GPIO_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef GPIO_TABS_START_LIN
			ORG 	GPIO_TABS_START, GPIO_TABS_START_LIN
#else
			ORG 	GPIO_TABS_START
GPIO_TABS_START_LIN	EQU	@			
#endif	

GPIO_TABS_END		EQU	*	
GPIO_TABS_END_LIN	EQU	@	
#endif	
