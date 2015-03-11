#ifndef	GPIO_COMPILED
#define GPIO_COMPILED
;###############################################################################
;# S12CBase - GPIO - GPIO Handler (Mini-BDM-Pod)                               #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#     PAD00 - unused                     (analog       no pull  )             #
;#     PAD01 - unused                     (analog       no pull  )             #
;#     PAD02 - NC                         (input        pull-up  )             #
;#     PAD03 - NC                         (input        pull-up  )             #
;#     PAD04 - NC                         (input        pull-up  )             #
;#     PAD05 - NC                         (input        pull-up  )             #
;#     PAD06 - NC                         (input        pull-up  )             #
;#     PAD07 - NC                         (input        pull-up  )             #
;#     PAD08 - unused                     (analog       no pull  )             #
;#     PAD09 - unused                     (analog       no pull  )             #
;#     PAD10 - unused                     (analog       no pull  )             #
;#     PAD11 - Target VDD                 (analog       no pull  )             #
;#     PAD12 - NC                         (input        pull-up  )             #
;#     PAD13 - NC                         (input        pull-up  )             #
;#     PAD14 - NC                         (input        pull-up  )             #
;#     PAD15 - NC                         (input        pull-up  )             #
;#     PAD16 - NC                         (input        pull-up  )             #
;#     PAD17 - NC                         (input        pull-up  )             #
;#     PAD18 - NC                         (input        pull-up  )             #
;#     PAD19 - NC                         (input        pull-up  )             #
;#     PAD20 - NC                         (input        pull-up  )             #
;#     PAD21 - NC                         (input        pull-up  )             #
;#     PAD22 - NC                         (input        pull-up  )             #
;#     PAD23 - NC                         (input        pull-up  )             #
;#     PAD24 - NC                         (input        pull-up  )             #
;#     PAD25 - NC                         (input        pull-up  )             #
;#     PAD26 - NC                         (input        pull-up  )             #
;#     PAD27 - NC                         (input        pull-up  )             #
;#     PAD28 - NC                         (input        pull-up  )             #
;#     PAD29 - NC                         (input        pull-up  )             #
;#     PAD30 - NC                         (input        pull-up  )             #
;#     PAD30 - NC                         (input        pull-up  )             #
;#    Port A:                                                                  #
;#     PA0 - unused                       (output       low      )             #
;#     PA1 - unused                       (output       low      )             #
;#     PA2 - unused                       (output       low      )             #
;#     PA3 - unused                       (output       low      )             #
;#     PA4 - unused                       (output       low      )             #
;#     PA5 - unused                       (output       low      )             #
;#     PA6 - unused                       (output       low      )             #
;#     PA7 - unused                       (output       low      )             #
;#    Port B:                                                                  #
;#     PB0 - unused                       (output       low      )             #
;#     PB1 - unused                       (output       low      )             #
;#     PB2 - unused                       (output       low      )             #
;#     PB3 - unused                       (output       low      )             #
;#     PB4 - unused                       (output       low      )             #
;#     PB5 - unused                       (output       low      )             #
;#     PB6 - unused                       (output       low      )             #
;#     PB7 - unused                       (output       low      )             #
;#    Port C:                                                                  #
;#     PC0 - NC                           (input        pull-up  )             #
;#     PC1 - NC                           (input        pull-up  )             #
;#     PC2 - NC                           (input        pull-up  )             #
;#     PC3 - NC                           (input        pull-up  )             #
;#     PC4 - NC                           (input        pull-up  )             #
;#     PC5 - NC                           (input        pull-up  )             #
;#     PC6 - NC                           (input        pull-up  )             #
;#     PC7 - NC                           (input        pull-up  )             #
;#    Port D:                                                                  #
;#     PD0 - NC                           (input        pull-up  )             #
;#     PD1 - NC                           (input        pull-up  )             #
;#     PD2 - NC                           (input        pull-up  )             #
;#     PD3 - NC                           (input        pull-up  )             #
;#     PD4 - NC                           (input        pull-up  )             #
;#     PD5 - NC                           (input        pull-up  )             #
;#     PD6 - NC                           (input        pull-up  )             #
;#     PD7 - NC                           (input        pull-up  )             #
;#    Port E:                                                                  #
;#     PE0 - unused                       (input        no pull  )             #
;#     PE1 - unused                       (input        no pull  )             #
;#     PE2 - unused                       (output       low      )             #
;#     PE3 - NC                           (input        pull-up  )             #
;#     PE4 - NC                           (input        pull-up  )             #
;#     PE5 - MODA                         (input        pull-down)             #
;#     PE6 - MODB                         (input        pull-down)             #
;#     PE7 - unused                       (input        no pull  )             #
;#    Port F:                                                                  #
;#     PF0 - NC                           (input        pull-up  )             #
;#     PF1 - NC                           (input        pull-up  )             #
;#     PF2 - NC                           (input        pull-up  )             #
;#     PF3 - NC                           (input        pull-up  )             #
;#     PF4 - NC                           (input        pull-up  )             #
;#     PF5 - NC                           (input        pull-up  )             #
;#     PF6 - NC                           (input        pull-up  )             #
;#     PF7 - NC                           (input        pull-up  )             #
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
;#     PJ0 - NC                           (input        pull-up  )             #
;#     PJ1 - NC                           (input        pull-up  )             #
;#     PJ2 - NC                           (input        pull-up  )             #
;#     PJ3 - NC                           (input        pull-up  )             #
;#     PJ4 - NC                           (input        pull-up  )             #
;#     PJ5 - NC                           (input        pull-up  )             #
;#     PJ6 - unused                       (input        no pull  )             #
;#     PJ7 - unused                       (input        no pull  )             #
;#    Port K:                                                                  #
;#     PK0 - unused                       (output       high     )             #
;#     PK1 - unused                       (output       high     )             #
;#     PK2 - unused                       (output       high     )             #
;#     PK3 - NC                           (input        pull-up  )             #
;#     PK4 - NC                           (input        pull-up  )             #
;#     PK5 - NC                           (input        pull-up  )             #
;#     PK6 - NC                           (input        pull-up  )             #
;#     PK7 - NC                           (input        pull-up  )             #
;#    Port M:                                                                  #
;#     PM0 - unused                       (output       low      )             #
;#     PM1 - unused                       (output       low      )             #
;#     PM2 - unused                       (output       low      )             #
;#     PM3 - unused                       (output       low      )             #
;#     PM4 - unused                       (output       low      )             #
;#     PM5 - unused                       (output       low      )             #
;#     PM6 - Switch                       (input        no pull  )             #
;#     PM7 - Target interface enable      (open-drain   no-pull  )             #
;#    Port L:                                                                  #
;#     PL0 - NC                           (input        pull-up  )             #
;#     PL1 - NC                           (input        pull-up  )             #
;#     PL2 - NC                           (input        pull-up  )             #
;#     PL3 - NC                           (input        pull-up  )             #
;#     PL4 - NC                           (input        pull-up  )             #
;#     PL5 - NC                           (input        pull-up  )             #
;#     PL6 - NC                           (input        pull-up  )             #
;#     PL7 - NC                           (input        pull-up  )             #
;#    Port P:                                                                  #
;#     PP0 - unused                       (output       low      )             #
;#     PP1 - unused                       (output       low      )             #
;#     PP2 - LED switch                   (output       high     )             #
;#     PP3 - LED switch                   (output       high     )             #
;#     PP4 - LED 4 green                  (output       high     )             #
;#     PP5 - LED 3 green                  (output       high     )             #
;#     PP6 - LED 2 green                  (output       high     )             #
;#     PP7 - LED 1 red                    (output       high     )             #
;#    Port R:                                                                  #
;#     PR0 - NC                           (input        pull-up  )             #
;#     PR1 - NC                           (input        pull-up  )             #
;#     PR2 - NC                           (input        pull-up  )             #
;#     PR3 - NC                           (input        pull-up  )             #
;#     PR4 - NC                           (input        pull-up  )             #
;#     PR5 - NC                           (input        pull-up  )             #
;#     PR6 - NC                           (input        pull-up  )             #
;#     PR7 - NC                           (input        pull-up  )             #
;#    Port S:                                                                  #
;#     PS0 - SCI RX                       (input        no pull  )             #
;#     PS1 - SCI TX                       (output       high     )             #
;#     PS2 - NC                           (input        pull-up  )             #
;#     PS3 - NC                           (input        pull-up  )             #
;#     PS4 - NC                           (input        pull-up  )             #
;#     PS5 - unused                       (output       low      )             #
;#     PS6 - unused                       (output       low      )             #
;#     PS7 - unused                       (output       high     )             #
;#    Port T:                                                                  #
;#     PT0 - SCI RX                       (input        no pull  )             #
;#     PT1 - NC                           (input        pull-up  )             #
;#     PT2 - NC                           (input        pull-up  )             #
;#     PT3 - NC                           (input        pull-up  )             #
;#     PT4 - NC                           (input        pull-up  )             #
;#     PT5 - NC                           (input        pull-up  )             #
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
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    July 31, 2012                                                            #
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
		;#General
		LDAA	#MODC		;lock MODE register into NSC mode
		STAA	MODE		
		STAA	MODE
		;#Port AD
		MOVW	#%1111_1111_1111_1111, ATD1DIENH 	;switch unused pins to digital
		MOVW	#%1111_0000_1111_1100, ATD0DIENH

		MOVW	#%1111_1111_1111_1111, PER0AD1 		;enable pull-up on all unused pins
		MOVW	#%1111_0000_1111_1100, PER0AD0
		;#Port A & B
		MOVW	#(((PUPKE|BKPUE|PUPEE|PUPDE|PUPCE)<<8)|RDPK|RDPE|RDPD|RDPC|PUPBE|PUPAE), PUCR ;enable pull-ups and reduced drive	
		;MOVW	#$0000, PORTA
		MOVW	#$FFFF, DDRA
		;#Port C & D
		;MOVW	#$0000, PORTC
		;MOVW	#$0000, DDRC
		;#Port E
		;MOVB	#$00, PORTE
		MOVB	#$04, DDRE
		CLR	IRQCR		;disable IRQ
		;#Port F
		;CLR	DDRF
		;MOVB	#$FF, PERF
		;#Port H
		;CLR	DDRH
		;MOVB	#$FF, PERH
		;#Port J
		;CLR	DDRJ
		MOVB	#$FC, PERJ
		;#Port K
		MOVW	#$0707, PORTK
		;#Port M
		;CLR	PTM
		MOVW	#$BFFF, DDRM
		;CLR	PERM
		MOVB	#$80, WOMM
		;#Port L
		;CLR	DDRL
		;MOVW	$#FF00, PERL
		;#Port P
		MOVB	#$F3, PTP
		MOVB	#$FF, DDRP
		;CLR	RDRP
		;#Port R
		;CLR	DDRR
		MOVB	#$FF, PERR
		;CLR	PPSR	
		;#Port S
		MOVB	#$82, PTS
		MOVB	#$70, DDRS
		MOVB	#$1C, PERS
		;CLR	PPSS	
		;#Port T
		;CLR	DDRT
		;CLR	RDRT
		MOVB	#$FE, PERT
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
