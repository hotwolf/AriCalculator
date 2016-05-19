#ifndef	GPIO
#define	GPIO
;###############################################################################
;# S12CBase - GPIO - GPIO Handler (MagniCube)                                  #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
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
;#    This module initializes all GPIO ports of the MagniCube hardware.        #
;#    It assumes the following I/O pin configuration of the S12VR MCU:         #
;#    Port AD:                                                                 #
;#     PAD0 - LED column  0               (output       low      )             #
;#     PAD1 - LED column  1               (output       low      )             #
;#     PAD2 - LED column  2               (output       low      )             #
;#     PAD3 - LED column  3               (output       low      )             #
;#     PAD4 - LED column  4               (output       low      )             #
;#     PAD5 - LED column  5               (output       low      )             #
;#    Port E:                                                                  #
;#     PE0  - LED column  6               (output       low      )             #
;#     PE1  - LED column  7               (output       low      )             #
;#    Port P:                                                                  #
;#     PP0  - LED column  8               (output       low      )             #
;#     PP1  - LED column  9               (output       low      )             #
;#     PP2  - LED column 10               (output       low      )             #
;#     PP3  - LED column 11               (output       low      )             #
;#     PP4  - LED column 12               (output       low      )             #
;#     PP5  - LED column 13               (output       low      )             #
;#    Port S:                                                                  #
;#     PS0  - SCI RX                      (input        pull-up  )             #
;#     PS1  - SCI TX                      (output       high     )             #
;#     PS3  - LED column 14               (output       low      )             #
;#     PS3  - LED column 15               (output       low      )             #
;#     PS4  - NC                          (input        pull-up  )             #
;#     PS5  - NC                          (input        pull-up  )             #
;#    Port T:                                                                  #
;#     PT0 - LED level 0                  (output       low      )             #
;#     PT1 - LED level 1                  (output       low      )             #
;#     PT2 - LED level 2                  (output       low      )             #
;#     PT3 - LED level 3                  (output       low      )             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    May 19, 2016                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	GPIO_VARS_START, GPIO_VARS_START_LIN

GPIO_VARS_END		EQU	*
GPIO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	GPIO_INIT, 0
		;#Urgent initializations
	
		;#Port E
		;MOVB	#$00, PORTE
		MOVW	#$03, DDRE 				;switch pins to output
		MOVB	#$40, PUCR				;BKPUE|~PDPEE
		;MOVB	#$80, ECLKCTL
		;MOVB	#$00, PIMMISC
		;MOVB	#$00, PPOCPE		      
		;MOVB	#$00, IRQCR
		;#Port T
		;MOVB	#$00, PTT 			
		MOVB	#$0F, DDRT 				;switch pins to output
		;MOVB	#$00  PERT
		;MOVB	#$00, PPST 
		;MOVB	#$00, MODRR0
		;MOVB	#$00, MODRR1
		;#Port S
		MOVB	#$02, PTS 				;drive TX oin high
		MOVB	#$07, DDRS				;configure outputs
		MOVB	#$31, PERS 				;configure outputs
		;MOVB	#$00, PPSS 				
		;MOVB	#$00, WOMS
#ifdef	S12VR64	
		MOVB	#$04, MODRR2 				;map SCI0 to PS[1:0]
#else		
		MOVB	#$84, MODRR2 				;map SCI0 to PS[1:0], connect TIM1IC1 to RXD
#endif		
		;#Port P
		;MOVB	#$00,   PTP 			
		MOVB	#$3F,   DDRP 				;switch pins to output
		;MOVB	#$00,   RDRP
		;MOVB	#$FF	PERP				
		;MOVB	#$00,   PPSP 			
		;MOVB	#$00,	PIEP 			
		;#Port L		
		;MOVB	#$00, PTAENL
		;MOVB	#$00, PTADIRL
		;MOVB	#$00, PTABYPL
		;MOVB	#$00, PTPSL
		;MOVB	#$00, DIENL
		;MOVB	#$00, PTTEL

----->hier weiter	

		;#Port AD
		MOVW	#%1111_1100_1111_1111, ATDDIEN   	;switch unused pins to digital
		;MOVW	#$0000, PT0AD
		;MOVW	#$0000, DDR0AD
		MOVW	#%1111_1100_1111_1111, PER0AD
		;MOVW	#$0000, PPS0AD
		;MOVW	#$0000, PIE0AD
		;#Port J
		;MOVB	#$00,   PTJ 			
		;MOVB	#$00,   DDRJ 			
		;MOVB	#$FF	PERJ
		MOVB	#$0F,   PPSJ 			
		;MOVB	#$00FF,	PIEJ				;PIEJ/PIFJ 			
		;#Port M
		;MOVB	#$00,   PTM 			
		MOVB	#$02,   DDRM 			
		MOVW	#$0D01	PERM 				;PERM/PPSM
		;MOVB	#$02,	WOMM
		;#Port P
		;MOVB	#$00,   PTP 			
		MOVB	#$3F,   DDRP 				;drive keyboard columns low
		MOVB	#$FF	PERP
		;MOVB	#$00,   PPSP 			
		;MOVB	#$00FF,	PIEP				;PIEP/PIFP 			

		;General setup
		LDAA	#MODC					;lock MODE register into NSC mode
		STAA	MODE		
		STAA	MODE
		MOVB	PKGCR, PKGCR 				;lock PKGCR
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG 	GPIO_CODE_START, GPIO_CODE_START_LIN

GPIO_CODE_END		EQU	*	
GPIO_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	GPIO_TABS_START, GPIO_TABS_START_LIN

GPIO_TABS_END		EQU	*	
GPIO_TABS_END_LIN	EQU	@	
#endif
