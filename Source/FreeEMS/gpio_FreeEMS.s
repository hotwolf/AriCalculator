;###############################################################################
;# S12CBase - GPIO - GPIO Handler (FreeEMS)                                    #
;###############################################################################
;#    Copyright 2010-2014 Dirk Heisswolf                                       #
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
;#     PAD00 - air charge temperature     (analog       no pull  )             #
;#     PAD01 - engine coolant temperature (analog       no pull  )             #
;#     PAD02 - throttle position          (analog       no pull  )             #
;#     PAD03 - exhaust gas O2 sensor      (analog       no pull  )             #
;#     PAD04 - manifold absolute pressure (analog       no pull  )             #
;#     PAD05 - barometric pressure        (analog       no pull  )             #
;#     PAD06 - battery voltage            (analog       no pull  )             #
;#     PAD07 - fuel/ignition trim         (analog       no pull  )             #
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
;#    Port A:                                                                  #
;#     PA0 - fuel pump                    (output       low      )             #
;#     PA1 - unused                       (input        pull-up  )             #
;#     PA2 - unused                       (input        pull-up  )             #
;#     PA3 - unused                       (input        pull-up  )             #
;#     PA4 - unused                       (input        pull-up  )             #
;#     PA5 - CEL ???                      (input        pull-up  )             #
;#     PA6 - unused                       (input        pull-up  )             #
;#     PA7 - unused                       (input        pull-up  )             #
;#    Port B:                                                                  #
;#     PB0 - F/I Trm Sel ???              (input        pull-up  )             #
;#     PB1 - DFC en ???                   (input        pull-up  )             #
;#     PB2 - unused                       (input        pull-up  )             #
;#     PB3 - unused                       (input        pull-up  )             #
;#     PB4 - unused                       (input        pull-up  )             #
;#     PB5 - unused                       (input        pull-up  )             #
;#     PB6 - unused                       (input        pull-up  )             #
;#     PB7 - unused                       (input        pull-up  )             #
;#    Port C:                                                                  #
;#     PC0 - unused                       (input        pull-up  )             #
;#     PC1 - unused                       (input        pull-up  )             #
;#     PC2 - unused                       (input        pull-up  )             #
;#     PC3 - unused                       (input        pull-up  )             #
;#     PC4 - unused                       (input        pull-up  )             #
;#     PC5 - unused                       (input        pull-up  )             #
;#     PC6 - unused                       (input        pull-up  )             #
;#     PC7 - unused                       (input        pull-up  )             #
;#    Port D:                                                                  #
;#     PD0 - unused                       (input        pull-up  )             #
;#     PD1 - unused                       (input        pull-up  )             #
;#     PD2 - unused                       (input        pull-up  )             #
;#     PD3 - unused                       (input        pull-up  )             #
;#     PD4 - unused                       (input        pull-up  )             #
;#     PD5 - unused                       (input        pull-up  )             #
;#     PD6 - unused                       (input        pull-up  )             #
;#     PD7 - unused                       (input        pull-up  )             #
;#    Port E:                                                                  #
;#     PE0 - /XIRQ                        (input        pull-up  )             #
;#     PE1 - /IRQ                         (input        pull-up  )             #
;#     PE2 - unused                       (input        pull-up  )             #
;#     PE3 - unused                       (input        pull-up  )             #
;#     PE4 - unused                       (input        pull-up  )             #
;#     PE5 - MODA                         (input        pull-up)             #
;#     PE5 -  DE (RS-485), MODA           (output       high     )             #
;#     PE6 - /RE (RS-485), MODB           (output       low      )             #
;#     PE7 - /XCLKS                       (input        pull-up  )             #
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
;#     PJ0 - SCI2 RX (RS-485)             (input        no pull  )             #
;#     PJ1 - SCI2 TX (RS-485)             (output       high     )             #
;#     PJ2 - unused                       (input        pull-up  )             #
;#     PJ3 - unused                       (input        pull-up  )             #
;#     PJ4 - unused                       (input        pull-up  )             #
;#     PJ5 - unused                       (input        pull-up  )             #
;#     PJ6 - unused                       (input        pull-up  )             #
;#     PJ7 - unused                       (input        pull-up  )             #
;#    Port K:                                                                  #
;#     PK0 - unused                       (input        pull-up  )             #
;#     PK1 - unused                       (input        pull-up  )             #
;#     PK2 - unused                       (input        pull-up  )             #
;#     PK3 - unused                       (input        pull-up  )             #
;#     PK4 - LSD1 In ???                  (input        pull-up  )             #
;#     PK5 - unused                       (input        pull-up  )             #
;#     PK6 - unused                       (input        pull-up  )             #
;#     PK7 - unused                       (input        pull-up  )             #
;#    Port M:                                                                  #
;#     PM0 - RXCAN0                       (input        no pull  )             #
;#     PM1 - TXCAN0                       (output       high     )             #
;#     PM2 - RXCAN1                       (input        no pull  )             #
;#     PM3 - TXCAN1                       (output       high     )             #
;#     PM4 - unused                       (input        pull_up  )             #
;#     PM5 - unused                       (input        pull_up  )             #
;#     PM6 - unused                       (input        pull_up  )             #
;#     PM7 - unused                       (input        pull_up  )             #
;#    Port P:                                                                  #
;#     PP0 - unused                       (input        pull_up  )             #
;#     PP1 - unused                       (input        pull_up  )             #
;#     PP2 - unused                       (input        pull_up  )             #
;#     PP3 - unused                       (input        pull_up  )             #
;#     PP4 - unused                       (input        pull_up  )             #
;#     PP5 - unused                       (input        pull_up  )             #
;#     PP6 - unused                       (input        pull_up  )             #
;#     PP7 - User LED                     (output       low      )             #
;#    Port S:                                                                  #
;#     PS0 - SCI0 RX (RS-232)             (input        no pull  )             #
;#     PS1 - SCI0 TX (RS-232)             (output       high     )             #
;#     PS2 - SCI1 RX (5V)                 (input        no pull  )             #
;#     PS3 - SCI1 TX (5V)                 (output       high     )             #
;#     PS4 - unused                       (input        pull-up  )             #
;#     PS5 - unused                       (input        pull-up  )             #
;#     PS6 - unused                       (input        pull-up  )             #
;#     PS7 - unused                       (input        pull-up  )             #
;#    Port T:                                                                  #
;#     PT0 - RPM0                         (input        no pull  )             #
;#     PT1 - RPM1                         (input        no pull  )             #
;#     PT2 - ignitor 1                    (output       low      )             #
;#     PT3 - unused                       (input        pull-up  )             #
;#     PT4 - injector 1                   (output       low      )             #
;#     PT5 - injector 2                   (output       low      )             #
;#     PT6 - unused                       (input        pull-up  )             #
;#     PT7 - unused                       (input        pull-up  )             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;###############################################################################
;# Version History:                                                            #
;#    July  8, 2014                                                            #
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
		;#Port AD

		;#Port A & B
		MOVB	#(PUPKE|BKPUE|PUPEE|PUPDE|PUPCE|PUPBE|PUPAE), PUCR ;enable pull-ups	
		MOVW	#(PA0<<8), DDRA

		;#Port C & D

		;#Port E
		MOVB	#(PE6|PE5), DDRE
		CLR	IRQCR		;disable IRQ

		;#Port H
		MOVB	#$FF, PERH
	
		;#Port J
		MOVB	#PJ1, PTJ
		MOVB	#PJ1, DDRJ
		MOVB	#~PJ0, PERJ
		
		;#Port K

		;#Port M
		MOVB	#(PM3|PM1), PTM
		MOVB	#(PM3|PM1), DDRM
		MOVB	#~(PM2|PM0), PERM

		;#Port P
		MOVB	#PP7, DDRP
		MOVB	#~PP7, PERP

		;#Port S
		MOVB	#(PS3|PS1), PTS
		MOVB	#(PS3|PS1), DDRS
		MOVB	#~(PS2|PS0), PERS

		;#Port T
		MOVB	#(PT5|PT4|PT2), DDRT	
		MOVB	#~(PT1|PT0), PERT
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
