#ifndef	GPIO_COMPILED
#define GPIO_COMPILED
;###############################################################################
;# S12CBase - GPIO - GPIO Handler (S12DP256-Mini-EVB)                          #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
;#    families.                                                                #
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
;#    Port AD:                                                                 #
;#     PAD00 - DBUG1                      (input        no pull  )             #
;#     PAD01 - DBUG2                      (input        no pull  )             #
;#     PAD02 - unused                     (analog       no pull  )             #
;#     PAD03 - unused                     (analog       no pull  )             #
;#     PAD04 - unused                     (analog       no pull  )             #
;#     PAD05 - unused                     (analog       no pull  )             #
;#     PAD06 - unused                     (analog       no pull  )             #
;#     PAD07 - unused                     (analog       no pull  )             #
;#     PAD08 - unused                     (analog       no pull  )             #
;#     PAD09 - unused                     (analog       no pull  )             #
;#     PAD10 - unused                     (analog       no pull  )             #
;#     PAD11 - unused                     (analog       no pull  )             #
;#     PAD12 - unused                     (analog       no pull  )             #
;#     PAD13 - unused                     (analog       no pull  )             #
;#     PAD14 - unused                     (analog       no pull  )             #
;#     PAD15 - unused                     (analog       no pull  )             #
;#     PAD16 - unused                     (analog       no pull  )             #
;#     PAD17 - unused                     (analog       no pull  )             #
;#     PAD18 - unused                     (analog       no pull  )             #
;#     PAD19 - unused                     (analog       no pull  )             #
;#     PAD20 - unused                     (analog       no pull  )             #
;#     PAD21 - unused                     (analog       no pull  )             #
;#     PAD22 - unused                     (analog       no pull  )             #
;#     PAD23 - unused                     (analog       no pull  )             #
;#     PAD24 - unused                     (analog       no pull  )             #
;#     PAD25 - unused                     (analog       no pull  )             #
;#     PAD26 - unused                     (analog       no pull  )             #
;#     PAD27 - unused                     (analog       no pull  )             #
;#     PAD28 - unused                     (analog       no pull  )             #
;#     PAD29 - unused                     (analog       no pull  )             #
;#     PAD30 - unused                     (analog       no pull  )             #
;#     PAD30 - unused                     (analog       no pull  )             #
;#    Port A:                                                                  #
;#     PA0 - unused                       (input        pull-up  )             #
;#     PA1 - unused                       (input        pull-up  )             #
;#     PA2 - unused                       (input        pull-up  )             #
;#     PA3 - unused                       (input        pull-up  )             #
;#     PA4 - unused                       (input        pull-up  )             #
;#     PA5 - unused                       (input        pull-up  )             #
;#     PA6 - unused                       (input        pull-up  )             #
;#     PA7 - unused                       (input        pull-up  )             #
;#    Port B:                                                                  #
;#     PB0 - unused                       (input        pull-up  )             #
;#     PB1 - unused                       (input        pull-up  )             #
;#     PB2 - unused                       (input        pull-up  )             #
;#     PB3 - unused                       (input        pull-up  )             #
;#     PB4 - unused                       (input        pull-up  )             #
;#     PB5 - unused                       (input        pull-up  )             #
;#     PB6 - unused                       (input        pull-up  )             #
;#     PB7 - unused                       (input        pull-up  )             #
;#    Port E:                                                                  #
;#     PE0 - /XIRQ                        (input        pull-up  )             #
;#     PE1 - /IRQ                         (input        pull-up  )             #
;#     PE2 - unused                       (input        pull-up  )             #
;#     PE3 - unused                       (input        pull-up  )             #
;#     PE4 - unused                       (input        pull-up  )             #
;#     PE5 - MODA                         (input        pull-up  )             #
;#     PE6 - MODB                         (input        pull-up  )             #
;#     PE7 - XCLKS                        (input        pull-up  )             #
;#    Port H:                                                                  #
;#     PH0 - unused                       (input        pull-up  )             #
;#     PH1 - unused                       (input        pull-up  )             #
;#     PH2 - unused                       (input        pull-up  )             #
;#     PH3 - unused                       (input        pull-up  )             #
;#     PH4 - unused                       (input        pull-up  )             #
;#     PH5 - unused                       (input        pull-up  )             #
;#     PH6 - unused                       (input        pull-up  )             #
;#     PH7 - unused                       (input        pull-up  )             #
;#    Port J:                                                                  #
;#     PJ0 - unused                       (input        pull-up  )             #
;#     PJ1 - unused                       (input        pull-up  )             #
;#     PJ6 - unused                       (input        pull-up  )             #
;#     PJ7 - unused                       (input        pull-up  )             #
;#    Port K:                                                                  #
;#     PK0 - unused                       (input        pull-up  )             #
;#     PK1 - unused                       (input        pull-up  )             #
;#     PK2 - unused                       (input        pull-up  )             #
;#     PK3 - unused                       (input        pull-up  )             #
;#     PK4 - unused                       (input        pull-up  )             #
;#     PK5 - unused                       (input        pull-up  )             #
;#     PK7 - unused                       (input        pull-up  )             #
;#    Port M:                                                                  #
;#     PM0 - unused                       (input        pull-up  )             #
;#     PM1 - unused                       (input        pull-up  )             #
;#     PM2 - unused                       (input        pull-up  )             #
;#     PM3 - unused                       (input        pull-up  )             #
;#     PM4 - unused                       (input        pull-up  )             #
;#     PM5 - unused                       (input        pull-up  )             #
;#     PM6 - unused                       (input        pull-up  )             #
;#     PM7 - unused                       (input        pull-up  )             #
;#    Port P:                                                                  #
;#     PP0 - unused                       (output       pull-up  )             #
;#     PP1 - unused                       (output       pull-up  )             #
;#     PP2 - unused                       (output       pull-up  )             #
;#     PP3 - unused                       (output       pull-up  )             #
;#     PP4 - unused                       (output       pull-up  )             #
;#     PP5 - unused                       (output       pull-up  )             #
;#     PP6 - unused                       (output       pull-up  )             #
;#     PP7 - unused                       (output       pull-up  )             #
;#    Port S:                                                                  #
;#     PS0 - SCI0 RX                      (input        no pull  )             #
;#     PS1 - SCI0 TX                      (output       high     )             #
;#     PS2 - SCI1 RX                      (input        no pull  )             #
;#     PS3 - SCI1 TX                      (output       high     )             #
;#     PS4 - unused                       (input        pull-up  )             #
;#     PS5 - unused                       (input        pull-up  )             #
;#     PS6 - unused                       (input        pull-up  )             #
;#     PS7 - unused                       (input        pull-up  )             #
;#    Port T:                                                                  #
;#     PT0 - unused                       (input        pull-up  )             #
;#     PT1 - unused                       (input        pull-up  )             #
;#     PT2 - unused                       (input        pull-up  )             #
;#     PT3 - unused                       (input        pull-up  )             #
;#     PT4 - unused                       (input        pull-up  )             #
;#     PT5 - unused                       (input        pull-up  )             #
;#     PT6 - Target BKGD                  (input/output pull-up  )             #
;#     PT7 - Target RESET                 (input/output pull-up  )             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    November 15, 2012                                                        #
;#      - Initial release                                                      #
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
		;#General
		LDAA	#MODC		;lock MODE register into NSC mode
		STAA	MODE		
		STAA	MODE
		;#Port AD
		MOVB	#$C0, ATD1DIEN 	;switch unused pins to analog
		MOVB	#$00, ATD0DIEN
		;#Port A & B
		MOVW	#(((PUPKE|PUPEE|PUPBE|PUPAE)<<8)|RDPK|RDPE|RDPB|RDPA), PUCR ;enable pull-ups and reduced drive	
		;MOVW	#$0000, PORTA
		;MOVW	#$0000, DDRA
		;#Port E
		;MOVB	#$00, PORTE
		;MOVB	#$00, DDRE
		CLR	INTCR		;disable IRQ
		;#Port H
		;CLR	DDRH
		MOVB	#$FF, PERH
		;CLR	PPSH
		;#Port J
		;CLR	DDRJ
		;MOVB	#$FC, PERJ
		;CLR	PPSJ
		;#Port K
		;CLR	DDRK
		;#Port M
		;CLR	DDRM
		MOVB	#$FF, PERM
		;CLR	PPSM
		;#Port P
		;CLR	DDRP
		MOVB	#$FF, PERP
		;CLR	PPSP
		;#Port S
		MOVB	#$0A, PTS
		MOVB	#$0A, DDRS
		MOVW	#$F0, PERS
		;CLR	PPSS
		;#Port T
		;CLR	DDRT
		;CLR	RDRT
		MOVB	#$FF, PERT
		;CLR	PPST
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
