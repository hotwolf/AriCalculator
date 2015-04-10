#ifndef	GPIO_COMPILED
#define	GPIO_COMPILED
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
;#     PAD00 - IAT     (air charge temperature)          (analog  no pull  )   #
;#     PAD01 - Coolant (engine coolant temperature)      (analog  no pull  )   #
;#     PAD02 - TPS     (throttle position)               (analog  no pull  )   #
;#     PAD03 - O2      (exhaust gas oxigen sensor)       (analog  no pull  )   #
;#     PAD04 - MAP     (manifold absolute pressure)      (analog  no pull  )   #
;#     PAD05 - AAP     (barometric pressure)             (analog  no pull  )   #
;#     PAD06 - BRV     (battery voltage)                 (analog  no pull  )   #
;#     PAD07 - SPR     (fuel/ignition trim)              (analog  no pull  )   #
;#     PAD08 - NC                                        (analog  no pull  )   #
;#     PAD09 - NC                                        (analog  no pull  )   #
;#     PAD10 - MAF     (mass air flow)                   (analog  no pull  )   #
;#     PAD11 - NC                                        (analog  no pull  )   #
;#     PAD12 - NC                                        (analog  no pull  )   #
;#     PAD13 - NC                                        (analog  no pull  )   #
;#     PAD14 - NC                                        (analog  no pull  )   #
;#     PAD15 - NC                                        (analog  no pull  )   #
;#     PAD16 - NC                                        (analog  no pull  )   #
;#     PAD17 - NC                                        (analog  no pull  )   #
;#     PAD18 - NC                                        (analog  no pull  )   #
;#     PAD19 - NC                                        (analog  no pull  )   #
;#     PAD20 - NC                                        (analog  no pull  )   #
;#     PAD21 - NC                                        (analog  no pull  )   #
;#     PAD22 - NC                                        (analog  no pull  )   #
;#     PAD23 - NC                                        (analog  no pull  )   #
;#    Port A:                                                                  #
;#     PA0 - NC                                          (input   pull-up  )   #
;#     PA1 - NC                                          (input   pull-up  )   #
;#     PA2 - NC                                          (input   pull-up  )   #
;#     PA3 - NC                                          (input   pull-up  )   #
;#     PA4 - NC                                          (input   pull-up  )   #
;#     PA5 - NC                                          (input   pull-up  )   #
;#     PA6 - check engine light/load run switch          (input   pull-up  )   #
;#     PA7 - fuel pump drive                             (output  high     )   #
;#    Port B:                                                                  #
;#     PB0 - injector1                                   (output  high     )   #
;#     PB1 - injector2                                   (output  high     )   #
;#     PB2 - injector3                                   (output  high     )   #
;#     PB3 - injector4                                   (output  high     )   #
;#     PB4 - injector5                                   (output  high     )   #
;#     PB5 - injector6                                   (output  high     )   #
;#     PB6 - injector7                                   (output  high     )   #
;#     PB7 - injector8                                   (output  high     )   #
;#    Port C:                                                                  #
;#     PC0 - NC                                          (input   pull-up  )   #
;#     PC1 - NC                                          (input   pull-up  )   #
;#     PC2 - NC                                          (input   pull-up  )   #
;#     PC3 - NC                                          (input   pull-up  )   #
;#     PC4 - NC                                          (input   pull-up  )   #
;#     PC5 - NC                                          (input   pull-up  )   #
;#     PC6 - NC                                          (input   pull-up  )   #
;#     PC7 - NC                                          (input   pull-up  )   #
;#    Port D:                                                                  #
;#     PD0 - NC                                          (input   pull-up  )   #
;#     PD1 - NC                                          (input   pull-up  )   #
;#     PD2 - NC                                          (input   pull-up  )   #
;#     PD3 - NC                                          (input   pull-up  )   #
;#     PD4 - NC                                          (input   pull-up  )   #
;#     PD5 - NC                                          (input   pull-up  )   #
;#     PD6 - NC                                          (input   pull-up  )   #
;#     PD7 - NC                                          (input   pull-up  )   #
;#    Port E:                                                                  #
;#     PE0 - NC (/XIRQ)                                  (input   pull-up  )   #
;#     PE1 - NC (/IRQ)                                   (input   pull-up  )   #
;#     PE2 - NC                                          (input   pull-up  )   #
;#     PE3 - NC                                          (input   pull-up  )   #
;#     PE4 - NC                                          (input   pull-up  )   #
;#     PE5 - MODA                                        (input   pull-up  )   #
;#     PE6 - MODB                                        (input   pull-up  )   #
;#     PE7 - /XCLKS                                      (input   pull-up  )   #
;#    Port H:                                                                  #
;#     PH0 - NC                                          (input   pull-down)   #
;#     PH1 - NC                                          (input   pull-down)   #
;#     PH2 - NC                                          (input   pull-down)   #
;#     PH3 - NC                                          (input   pull-down)   #
;#     PH4 - NC                                          (input   pull-down)   #
;#     PH5 - NC                                          (input   pull-down)   #
;#     PH6 - NC                                          (input   pull-down)   #
;#     PH7 - NC                                          (input   pull-down)   #
;#    Port J:                                                                  #
;#     PJ0 - NC                                          (input   pull-down)   #
;#     PJ1 - NC                                          (input   pull-down)   #
;#     PJ2 - NC                                          (input   pull-down)   #
;#     PJ4 - NC                                          (input   pull-down)   #
;#     PJ5 - NC                                          (input   pull-down)   #
;#     PJ6 - NC                                          (input   pull-down)   #
;#     PJ7 - NC                                          (input   pull-down)   #
;#    Port K:                                                                  #
;#     PK0 - NC                                          (input   pull-up  )   #
;#     PK1 - NC                                          (input   pull-up  )   #
;#     PK2 - NC                                          (input   pull-up  )   #
;#     PK3 - NC                                          (input   pull-up  )   #
;#     PK4 - fan                                         (output  high     )   #
;#     PK5 - P62                                         (input   pull-up  )   #
;#     PK6 - NC                                          (input   pull-up  )   #
;#     PK7 - NC                                          (input   pull-up  )   #
;#    Port M:                                                                  #
;#     PM0 - RXCAN0 (P64)                                (input   pull-up  )   #
;#     PM1 - TXCAN0 (P64)                                (output  high     )   #
;#     PM2 - NC                                          (input   pull-down)   #
;#     PM3 - NC                                          (input   pull-down)   #
;#     PM4 - NC                                          (input   pull-down)   #
;#     PM5 - NC                                          (input   pull-down)   #
;#     PM6 - NC                                          (input   pull-down)   #
;#     PM7 - NC                                          (input   pull-down)   #
;#    Port P:                                                                  #
;#     PP0 - PP1                                         (input   pull-down)   #
;#     PP1 - PP1                                         (input   pull-down)   #
;#     PP2 - PP1                                         (input   pull-down)   #
;#     PP3 - PP1                                         (input   pull-down)   #
;#     PP4 - PP2                                         (input   pull-down)   #
;#     PP5 - PP2                                         (input   pull-down)   #
;#     PP6 - PP2                                         (input   pull-down)   #
;#     PP7 - PP2                                         (input   pull-down)   #
;#    Port S:                                                                  #
;#     PS0 - SCI0 RX (FT232RL)                           (input   no pull  )   #
;#     PS1 - SCI0 TX (FT232RL)                           (output  high     )   #
;#     PS2 - P58                                         (input   pull-down)   #
;#     PS3 - P57                                         (input   pull-down)   #
;#     PS4 - NC                                          (input   pull-down)   #
;#     PS5 - NC                                          (input   pull-down)   #
;#     PS6 - NC                                          (input   pull-down)   #
;#     PS7 - NC                                          (input   pull-down)   #
;#    Port T:                                                                  #
;#     PT0 - RPM0                                        (input   no pull  )   #
;#     PT1 - RPM1                                        (input   no pull  )   #
;#     PT2 - DIS advance                                 (output  low      )   #
;#     PT3 - DIS bypass                                  (output  low      )   #
;#     PT4 - injector 1                                  (output  high     )   #
;#     PT5 - injector 2                                  (output  high     )   #
;#     PT6 - injector 3                                  (output  high     )   #
;#     PT7 - injector 4                                  (output  high     )   #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;###############################################################################
;# Version History:                                                            #
;#    July  8, 2014                                                            #
;#      - Initial release                                                      #
;#    July  9, 2014                                                            #
;#      - Updated I/O list based on the FreeEMS Jaguar board                   #
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
		MOVB	#(PUPKE|BKPUE|PUPEE|PUPDE|PUPCE|PUPAE), PUCR	;enable pull-ups	
		MOVW	#%10000000_11111111, PORTA			;PORTA:PORTB
		MOVW	PORTA, DDRA		     			;PORTA:PORTB -> DDRA:DDRB
		
		;#Port C & D

		;#Port E
		CLR	IRQCR						;disable IRQ

		;#Port H
		MOVW	#%11111111_11111111, PERH 			;PERH:PPSH

		;#Port J
		MOVB	#%11110111, PPSJ 				;pulls enabled out of reset
		
		;#Port K
		MOVW	#%00001000_00001000, PORTK 			;PORTK:DDRK
			
		;#Port M
		MOVB	#%00000010, PTM					;drive recessive level on CAN TX (PM1)
		MOVB	PTM, DDRM 					;PTM -> DDRM
		MOVW	#%11111101_11111100, PERM 			;PERM:PPSM

		;#Port P
		MOVW	#%11111111_11111111, PERP 			;PERP:PPSP

		;#Port S
		MOVB	#%00000010, PTS					;drive idle level on SCI TX (PS1)
		MOVB	PTM, DDRM 					;PTS -> DDRS
		MOVB	#%11111100, PPSS 				;pulls enabled out of reset

		;#Port T
		MOVB	#11110000, PTT	
		MOVB	#11111100, DDRT	
		MOVW	#%11110000_11110000, PERT 			;PERT:PPST
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
