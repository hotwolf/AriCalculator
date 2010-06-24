;###############################################################################
;# S12CBase - GPIO - GPIO Handler                                              #
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
;#     PB4 - BDM - BKGD output            (input/output pull-up)               #
;#     PB5 - NC                           (input        pull-up)               #
;#     PB6 - NC                           (input        pull-up)               #
;#     PB7 - NC                           (input        pull-up)               #
;#    Port E:                                                                  #
;#     PE0 - NC                           (input        pull-up)               #
;#     PE1 - NC                           (input        pull-up)               #
;#     PE2 - NC                           (input        pull-up)               #
;#     PE3 - NC                           (input        pull-up)               #
;#     PE4 - NC                           (input        pull-up)               #
;#     PE5 - NC                           (input        pull-up)               #
;#     PE6 - NC                           (input        pull-up)               #
;#     PE7 - NC                           (input        pull-up)               #
;#    Port J:                                                                  #
;#     PJ6 - NC                           (input        pull-up)               #
;#     PJ7 - NC                           (input        pull-up)               #
;#    Port M:                                                                  #
;#     PM0 - SCI - RTS input              (input        no pull)               #
;#     PM1 - SCI - CTS output             (output       no pull)               #
;#     PM2 - NC                           (input        pull-up)               #
;#     PM3 - NC                           (input        pull-up)               #
;#     PM4 - NC                           (input        pull-up)               #
;#     PM5 - NC                           (input        pull-up)               #
;#    Port P:                                                                  #
;#     PP0 - NC                           (input        pull-up)               #
;#     PP1 - NC                           (input        pull-up)               #
;#     PP2 - NC                           (input        pull-up)               #
;#     PP3 - NC                           (input        pull-up)               #
;#     PP4 - NC                           (input        pull-up)               #
;#     PP5 - BDM - RESET output           (input/output no pull)               #
;#     PP6 - NC                           (input        pull-up)               #
;#     PP7 - NC                           (input        pull-up)               #
;#    Port S:                                                                  #
;#     PS0 - SCI RX input                 (input        no pull)               #
;#     PS1 - SCI TX output                (output       no pull)               #
;#     PS2 - NC                           (input        pull-up)               #
;#     PS3 - NC                           (input        pull-up)               #
;#    Port T:                                                                  #
;#     PT0 - SCI - RX posedge detection   (input        no pull)               #
;#     PT1 - SCI - RX negedge detection   (input        no pull)               #
;#     PT2 - NC                           (input        pull-up)               #
;#     PT3 - NC                           (input        pull-up)               #
;#     PT4 - NC                           (input        pull-up)               #
;#     PT5 - BDM - BKGD posedge detection (input        no pull)               #
;#     PT6 - BDM - BKGD negedge detection (input        no pull)               #
;#     PT7 - NC                           (input        pull-up)               #
;#    Port AD:                                                                 #
;#     PAD0 - NC                          (input        pull-up)               #
;#     PAD1 - NC                          (input        pull-up)               #
;#     PAD2 - NC                          (input        pull-up)               #
;#     PAD3 - NC                          (input        pull-up)               #
;#     PAD4 - NC                          (input        pull-up)               #
;#     PAD5 - NC                          (input        pull-up)               #
;#     PAD6 - NC                          (input        pull-up)               #
;#     PAD7 - LED - 1=on/0=off            (output       no pull)               #
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
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
		ORG	GPIO_VARS_START
GPIO_VARS_END	EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	GPIO_INIT, 0
		;#Port A
		LDAA	#MODC		;lock MODE register into NSC mode
		STAA	MODE		
		STAA	MODE
		MOVB	#~PUPBE, PUCR 	;enable pull-ups on ports A & E
		;#Port B
		;#Port E
		MOVB	#NECLK, PEAR 	;lock PEAR register
		CLR	INTCR		;disable external interrupts
		;#Port J
		MOVB	#$FF, PERJ 	;enable pull-ups on port J	
		;#Port M
		MOVB	#$02, DDRM 	;switch PM1 to ouput
		MOVB	#$FC, PERM	;enable pull-ups on PM[6:2]	
		;#Port P
		MOVB	#$DF, PERP	;enable pull-ups on PP[7:6] and PP[4:0]	
		;#Port S
		MOVB	#$02, DDRS 	;switch PS1 to ouput
		MOVB	#$02, PTS 	;drive PS1 high
		MOVB	#$FC, PERS	;enable pull-ups on PS[3:2]	
		;#Port T
		MOVB	#$9C, PERT	;enable pull-ups on PT7 & PT[4:2]	
		;#Port AD
		;CLR	ATDDIEN		;enable digital input buffers
		MOVB	#$80, DDRAD	;switch PAD0 to ouput
		CLR	PTAD		;turn off LED
		;MOVB	#$00, PTAD 	;turn off LED
		MOVB	#$7F, PERAD 	;enable pull-ups on PAD[7:1]
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
		ORG	GPIO_CODE_START
GPIO_CODE_END	EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
		ORG	GPIO_TABS_START
GPIO_TABS_END	EQU	*
