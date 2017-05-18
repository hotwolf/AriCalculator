#ifndef	GPIO_COMPILED
#define GPIO_COMPILED
;###############################################################################
;# S12CBase - GPIO - GPIO Handler (BEPM)                                       #
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
;#    This module initializes all unused GPIO ports                            #
;#    Port AD:                                                                 #
;#     PAD00 - ATD0  0 (K5)               (analog       no pull  )             #
;#     PAD01 - ATD0  1 (K4)               (analog       no pull  )             #
;#     PAD02 - ATD0  2 (K3)               (analog       no pull  )             #
;#     PAD03 - ATD0  3 (K2)               (analog       no pull  )             #
;#     PAD04 - ATD0  4 (K1)               (analog       no pull  )             #
;#     PAD05 - ATD0  5 (RV10)             (analog       no pull  )             #
;#     PAD06 - ATD0  6 (RV9)              (analog       no pull  )             #
;#     PAD07 - ATD0  7 (K6)               (analog       no pull  )             #
;#     PAD08 - ATD0  8 (RV8)              (analog       no pull  )             #
;#     PAD09 - ATD0  9 (RV7)              (analog       no pull  )             #
;#     PAD10 - ATD0 10 (RV6)              (analog       no pull  )             #
;#     PAD11 - ATD0 11 (RV5)              (analog       no pull  )             #
;#     PAD12 - ATD0 12 (RV4)              (analog       no pull  )             #
;#     PAD13 - ATD0 13 (RV3)              (analog       no pull  )             #
;#     PAD14 - ATD0 14 (P3)               (analog       no pull  )             #
;#     PAD15 - ATD0 15 (P2)               (analog       no pull  )             #
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
;#     PA0 - SW7                          (input        pull-up  )             #
;#     PA1 - SW3                          (input        pull-up  )             #
;#     PA2 - SW6                          (input        pull-up  )             #
;#     PA3 - SW2                          (input        pull-up  )             #
;#     PA4 - SW5                          (input        pull-up  )             #
;#     PA5 - SW1                          (input        pull-up  )             #
;#     PA6 - SW2 (run/load)               (input        pull-up  )             #
;#     PA7 - SW4                          (input        pull-up  )             #
;#    Port B:                                                                  #
;#     PB0 - LED red (D9)                 (output       low      )             #
;#     PB1 - LED red (D23)                (output       low      )             #
;#     PB2 - LED red (D4)                 (output       low      )             #
;#     PB3 - LED red (D20)                (output       low      )             #
;#     PB4 - LED red (D10)                (output       low      )             #
;#     PB5 - LED red (D1)                 (output       low      )             #
;#     PB6 - LED red (D10)                (output       low      )             #
;#     PB7 - LED red (D2)                 (output       low      )             #
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
;#     PE0 - XIRQ (gear tooth sensor)     (input        pull-up  )             #
;#     PE1 - IRQ  (gear tooth sensor)     (input        pull-up  )             #
;#     PE2 - SD card detect               (input        pull_up  )             #
;#     PE3 - SW5                          (input        pull-up  )             #
;#     PE4 - SW2                          (input        pull-up  )             #
;#     PE5 - SW4 (MODA)                   (input        pull-up  )             #
;#     PE6 - SW1 (MODB)                   (input        pull-up  )             #
;#     PE7 - SW6                          (input        pull-up  )             #
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
;#     PH0 - SD data out     (MISO1)      (input        pull-down)             #
;#     PH1 - SD CMD          (MOSI1)      (output       low      )             #
;#     PH2 - SD CLK          (SCK1)       (output       low      )             #
;#     PH3 - SD CD           (SS1)        (output       low      )             #
;#     PH4 - Real time clock (MISO2)      (input        pull-down)             #
;#     PH5 - Real time clock (MOSI2)      (output       low      )             #
;#     PH6 - Real time clock (SCK2)       (output       low      )             #
;#     PH7 - Real time clock (SS2)        (output       low      )             #
;#    Port J:                                                                  #
;#     PJ0 - SCI2 RXD                     (input        pull-up  )             #
;#     PJ1 - SCI2 TXD                     (output       high     )             #
;#     PJ2 - NC                           (input        pull-up  )             #
;#     PJ3 - NC                           (input        pull-up  )             #
;#     PJ4 - NC                           (input        pull-up  )             #
;#     PJ5 - NC                           (input        pull-up  )             #
;#     PJ6 - SW4                          (input        pull-up  )             #
;#     PJ7 - SW2                          (input        pull-up  )             #
;#    Port K:                                                                  #
;#     PK0 - LED red (D22)                (output       low      )             #
;#     PK1 - LED red (D6)                 (output       low      )             #
;#     PK2 - LED red (D25)                (output       low      )             #
;#     PK3 - LED red (D2)                 (output       low      )             #
;#     PK4 - LED red (D19)                (output       low      )             #
;#     PK5 - LED red (D3)                 (output       low      )             #
;#     PK6 - NC                           (input        pull-up  )             #
;#     PK7 - LED red (D2)                 (output       low      )             #
;#    Port M:                                                                  #
;#     PM0 - RXCAN0                       (input        pull-up  )             #
;#     PM1 - TXCAN0                       (output       high     )             #
;#     PM2 - RXCAN1                       (input        pull-up  )             #
;#     PM3 - TXCAN1                       (output       high     )             #
;#     PM4 - SW3                          (input        pull-up  )             #
;#     PM5 - SW1                          (input        pull-up  )             #
;#     PM6 - SCI3 RXD                     (input        pull-up  )             #
;#     PM7 - SCI3 TXD                     (output       high     )             #
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
;#     PP0 - TIM1 OC4 (P8)                (output       low      )             #
;#     PP1 - TIM1 OC5 (P4)                (output       low      )             #
;#     PP2 - TIM1 OC6 (P7)                (output       low      )             #
;#     PP3 - TIM1 OC7 (P3)                (output       low      )             #
;#     PP4 - TIM1 OC4 (P3)                (output       low      )             #
;#     PP5 - TIM1 OC5 (P6)                (output       low      )             #
;#     PP6 - TIM1 OC6 (P2)                (output       low      )             #
;#     PP7 - TIM1 OC7 (P7)                (output       low      )             #
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
;#     PS0 - SCI0 RXD                     (input        pull-up  )             #
;#     PS1 - SCI0 TXD                     (output       high     )             #
;#     PS2 - SCI1 RXD                     (input        pull-up  )             #
;#     PS3 - SCI1 TXD                     (output       high     )             #
;#     PS4 - MISO0 (P8)                   (input        pull-down)             #
;#     PS5 - MOSI0 (P8)                   (output       low      )             #
;#     PS6 - SCK0  (P8)                   (output       low      )             #
;#     PS7 - SS0   (P8)                   (output       high     )             #
;#    Port T:                                                                  #
;#     PT0 - LED red (D7)                 (output       low      )             #
;#     PT1 - TIM0 IC1                     (input        pull-down)             #
;#     PT2 - LED red (D8)                 (output       low      )             #
;#     PT3 - TIM0 IC3                     (input        pull-down)             #
;#     PT4 - TIM0 IC4                     (input        pull-down)             #
;#     PT5 - TIM0 IC5                     (input        pull-down)             #
;#     PT6 - TIM0 IC6                     (input        pull-down)             #
;#     PT7 - TIM0 IC7                     (input        pull-down)             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    December 28, 2014                                                        #
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
		MOVW	#$FFFF, ATD1DIENH 	;switch unused pins to digital
		;MOVW	#$0000, ATD0DIENH

		MOVW	#%1111_1111_1111_1111, PER0AD1 		;enable pull-up on all unused pins
		;MOVW	#%0000_0000_0000_0000, PER0AD0
		;#Port A & B
		MOVW	#(((PUPKE|BKPUE|PUPEE|PUPDE|PUPCE|PUPAE)<<8)|RDPK|RDPE|RDPD|RDPC|PUPBE|PUPAE), PUCR ;enable pull-ups and reduced drive	
		;MOVW	#$0000, PORTA
		MOVW	#$00FF, DDRA
		;#Port C & D
		;MOVW	#$0000, PORTC
		;MOVW	#$0000, DDRC
		;#Port E
		;MOVB	#$00, PORTE
		CLR	IRQCR		;disable IRQ
		;#Port F
		;CLR	DDRF
		;MOVB	#$FF, PERF
		;#Port H
		MOVB	#$EE, DDRH
		MOVW	#$1111, PERH
		;#Port J
		MOVB	#$02, PTJ
		MOVB	#$02, DDRJ
		;MOVB	#$FD, PERJ
		;#Port K
		MOVB	#$BF, DDRK
		;#Port M
		MOVB	#$8A, PTM
		MOVB	#$8A, DDRM
		MOVB	#$75, PERM
		;#Port L
		;CLR	DDRL
		;MOVW	$#FF00, PERL
		;#Port P
		MOVB	#$FF, DDRP
		;#Port R
		;CLR	DDRR
		MOVB	#$FF, PERR
		;CLR	PPSR	
		;#Port S
		MOVB	#$8A, PTS
		MOVB	#$EA, DDRS
		MOVB	#$10, PPSS	
		;#Port T
		MOVW	#$0505, DDRT
		MOVW	#$FAFA, PERT
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
