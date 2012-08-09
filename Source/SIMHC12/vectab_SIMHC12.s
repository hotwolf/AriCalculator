;###############################################################################
;# S12CBase - VECTAB - Vector Table (SIMHC12)                                  #
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
;#    This module defines the static vector table of the OpenBDC firmware.     #
;#    Unexpected inerrupts are cought and trigger a fatal error in the reset   #
;#    handler.                                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    SCI    - UART driver                                                     #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    August 9, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added dummy vectors                                                  #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Make each unused interrupt point to a separate BGND instruction
;VECTAB_DEBUG		EQU	1 

;###############################################################################
;# Constants                                                                   #
;###############################################################################
VECTAB_START		EQU	$FF80
VECTAB_START_LIN	EQU	$FFFF80

;###############################################################################
;# Undefined ISRs                                                              #
;###############################################################################
;#SCI
#ifndef	SCI_ISR_RXTX
SCI_ISR_RXTX		EQU	VECTAB_DUMMY_SCI
#endif

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef VECTAB_VARS_START_LIN
			ORG 	VECTAB_VARS_START, VECTAB_VARS_START_LIN
#else
			ORG 	VECTAB_VARS_START
VECTAB_VARS_START_LIN	EQU	@			
#endif	

VECTAB_VARS_END		EQU	*
VECTAB_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	VECTAB_INIT, 0
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef VECTAB_CODE_START_LIN
			ORG 	VECTAB_CODE_START, VECTAB_CODE_START_LIN
#else
			ORG 	VECTAB_CODE_START
VECTAB_VARS_START_LIN	EQU	@			
#endif	
	
VECTAB_CODE_END		EQU	*	
VECTAB_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef VECTAB_TABS_START_LIN
			ORG 	VECTAB_TABS_START, VECTAB_TABS_START_LIN
#else
			ORG 	VECTAB_TABS_START
VECTAB_VARS_START_LIN	EQU	@			
#endif	

#ifdef VECTAB_DEBUG
VECTAB_DUMMY_RES80   	BGND
VECTAB_DUMMY_RES82   	BGND
VECTAB_DUMMY_RES84   	BGND
VECTAB_DUMMY_RES86   	BGND
VECTAB_DUMMY_RES88   	BGND
VECTAB_DUMMY_LVI     	BGND      
VECTAB_DUMMY_PWM     	BGND      
VECTAB_DUMMY_PORTP   	BGND
VECTAB_DUMMY_RES90   	BGND
VECTAB_DUMMY_RES92   	BGND
VECTAB_DUMMY_RES94   	BGND
VECTAB_DUMMY_RES96   	BGND
VECTAB_DUMMY_RES98   	BGND
VECTAB_DUMMY_RES9A   	BGND
VECTAB_DUMMY_RES9C   	BGND
VECTAB_DUMMY_RES9E   	BGND
VECTAB_DUMMY_RESA0   	BGND
VECTAB_DUMMY_RESA2   	BGND
VECTAB_DUMMY_RESA4   	BGND
VECTAB_DUMMY_RESA6   	BGND
VECTAB_DUMMY_RESA8   	BGND
VECTAB_DUMMY_RESAA   	BGND
VECTAB_DUMMY_RESAC   	BGND
VECTAB_DUMMY_RESAE   	BGND
VECTAB_DUMMY_CANTX   	BGND
VECTAB_DUMMY_CANRX   	BGND
VECTAB_DUMMY_CANERR  	BGND
VECTAB_DUMMY_CANWUP  	BGND
VECTAB_DUMMY_FLASH   	BGND
VECTAB_DUMMY_RESBA   	BGND
VECTAB_DUMMY_RESBC   	BGND
VECTAB_DUMMY_RESBE   	BGND
VECTAB_DUMMY_RESC0   	BGND
VECTAB_DUMMY_RESC2   	BGND
VECTAB_DUMMY_SCM     	BGND      
VECTAB_DUMMY_PLLLOCK 	BGND
VECTAB_DUMMY_RESC8  	BGND
VECTAB_DUMMY_RESCA  	BGND
VECTAB_DUMMY_RESCC  	BGND
VECTAB_DUMMY_PORTJ  	BGND
VECTAB_DUMMY_RESD0  	BGND
VECTAB_DUMMY_ATD    	BGND
VECTAB_DUMMY_RESD4  	BGND
VECTAB_DUMMY_SCI    	BGND
VECTAB_DUMMY_SPI    	BGND
VECTAB_DUMMY_PAIE   	BGND
VECTAB_DUMMY_PAOV   	BGND
VECTAB_DUMMY_TOV    	BGND
VECTAB_DUMMY_TC7    	BGND
VECTAB_DUMMY_TC6    	BGND
VECTAB_DUMMY_TC5    	BGND
VECTAB_DUMMY_TC4    	BGND
VECTAB_DUMMY_TC3    	BGND
VECTAB_DUMMY_TC2    	BGND
VECTAB_DUMMY_TC1    	BGND
VECTAB_DUMMY_TC0    	BGND
VECTAB_DUMMY_RTI    	BGND
VECTAB_DUMMY_IRQ    	BGND
VECTAB_DUMMY_XIRQ   	BGND
VECTAB_DUMMY_SWI    	BGND
VECTAB_DUMMY_TRAP   	BGND
#else
VECTAB_DUMMY_RES80   	EQU	ERROR_ISR
VECTAB_DUMMY_RES82   	EQU	ERROR_ISR
VECTAB_DUMMY_RES84   	EQU	ERROR_ISR
VECTAB_DUMMY_RES86   	EQU	ERROR_ISR
VECTAB_DUMMY_RES88   	EQU	ERROR_ISR
VECTAB_DUMMY_LVI     	EQU	ERROR_ISR      
VECTAB_DUMMY_PWM     	EQU	ERROR_ISR      
VECTAB_DUMMY_PORTP   	EQU	ERROR_ISR
VECTAB_DUMMY_RES90   	EQU	ERROR_ISR
VECTAB_DUMMY_RES92   	EQU	ERROR_ISR
VECTAB_DUMMY_RES94   	EQU	ERROR_ISR
VECTAB_DUMMY_RES96   	EQU	ERROR_ISR
VECTAB_DUMMY_RES98   	EQU	ERROR_ISR
VECTAB_DUMMY_RES9A   	EQU	ERROR_ISR
VECTAB_DUMMY_RES9C   	EQU	ERROR_ISR
VECTAB_DUMMY_RES9E   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA0   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA2   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA4   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA6   	EQU	ERROR_ISR
VECTAB_DUMMY_RESA8   	EQU	ERROR_ISR
VECTAB_DUMMY_RESAA   	EQU	ERROR_ISR
VECTAB_DUMMY_RESAC   	EQU	ERROR_ISR
VECTAB_DUMMY_RESAE   	EQU	ERROR_ISR
VECTAB_DUMMY_CANTX   	EQU	ERROR_ISR
VECTAB_DUMMY_CANRX   	EQU	ERROR_ISR
VECTAB_DUMMY_CANERR  	EQU	ERROR_ISR
VECTAB_DUMMY_CANWUP  	EQU	ERROR_ISR
VECTAB_DUMMY_FLASH   	EQU	ERROR_ISR
VECTAB_DUMMY_RESBA   	EQU	ERROR_ISR
VECTAB_DUMMY_RESBC   	EQU	ERROR_ISR
VECTAB_DUMMY_RESBE   	EQU	ERROR_ISR
VECTAB_DUMMY_RESC0   	EQU	ERROR_ISR
VECTAB_DUMMY_RESC2   	EQU	ERROR_ISR
VECTAB_DUMMY_SCM     	EQU	ERROR_ISR      
VECTAB_DUMMY_PLLLOCK 	EQU	ERROR_ISR
VECTAB_DUMMY_RESC8  	EQU	ERROR_ISR
VECTAB_DUMMY_RESCA  	EQU	ERROR_ISR
VECTAB_DUMMY_RESCC  	EQU	ERROR_ISR
VECTAB_DUMMY_PORTJ  	EQU	ERROR_ISR
VECTAB_DUMMY_RESD0  	EQU	ERROR_ISR
VECTAB_DUMMY_ATD    	EQU	ERROR_ISR
VECTAB_DUMMY_RESD4  	EQU	ERROR_ISR
VECTAB_DUMMY_SCI    	EQU	ERROR_ISR
VECTAB_DUMMY_SPI    	EQU	ERROR_ISR
VECTAB_DUMMY_PAIE   	EQU	ERROR_ISR
VECTAB_DUMMY_PAOV   	EQU	ERROR_ISR
VECTAB_DUMMY_TOV    	EQU	ERROR_ISR
VECTAB_DUMMY_TC7    	EQU	ERROR_ISR
VECTAB_DUMMY_TC6    	EQU	ERROR_ISR
VECTAB_DUMMY_TC5    	EQU	ERROR_ISR
VECTAB_DUMMY_TC4    	EQU	ERROR_ISR
VECTAB_DUMMY_TC3    	EQU	ERROR_ISR
VECTAB_DUMMY_TC2    	EQU	ERROR_ISR
VECTAB_DUMMY_TC1    	EQU	ERROR_ISR
VECTAB_DUMMY_TC0    	EQU	ERROR_ISR
VECTAB_DUMMY_RTI    	EQU	ERROR_ISR
VECTAB_DUMMY_IRQ    	EQU	ERROR_ISR
VECTAB_DUMMY_XIRQ   	EQU	ERROR_ISR
VECTAB_DUMMY_SWI    	EQU	ERROR_ISR
VECTAB_DUMMY_TRAP   	EQU	ERROR_ISR
#endif
	
VECTAB_TABS_END		EQU	*	
VECTAB_TABS_END_LIN	EQU	@	

;###############################################################################
;# S12G128 Vector Table                                                        #
;###############################################################################
		ORG	VECTAB_START, VECTAB_START_LIN 	
VEC_RESERVED80	DW	VECTAB_DUMMY_RES80			;$FF80
VEC_RESERVED82	DW	VECTAB_DUMMY_RES82			;$FF82
VEC_RESERVED84	DW	VECTAB_DUMMY_RES84			;$FF84
VEC_RESERVED86	DW	VECTAB_DUMMY_RES86			;$FF86
VEC_RESERVED88	DW	VECTAB_DUMMY_RES88			;$FF88
VEC_RESERVED8A  DW	VECTAB_DUMMY_RES8A	      		;$FF8A
VEC_RESERVED8C  DW	VECTAB_DUMMY_RES8C	      		;$FF8C
VEC_RESERVED8E	DW	VECTAB_DUMMY_RES8E			;$FF8E
VEC_RESERVED90	DW	VECTAB_DUMMY_RES90			;$FF90
VEC_RESERVED92	DW	VECTAB_DUMMY_RES92			;$FF92
VEC_RESERVED94	DW	VECTAB_DUMMY_RES94			;$FF94
VEC_RESERVED96	DW	VECTAB_DUMMY_RES96			;$FF96
VEC_RESERVED98	DW	VECTAB_DUMMY_RES98			;$FF98
VEC_RESERVED9A	DW	VECTAB_DUMMY_RES9A			;$FF9A
VEC_RESERVED9C	DW	VECTAB_DUMMY_RES9C			;$FF9C
VEC_RESERVED9E	DW	VECTAB_DUMMY_RES9E			;$FF9E
VEC_RESERVEDA0	DW	VECTAB_DUMMY_RESA0			;$FFA0
VEC_RESERVEDA2	DW	VECTAB_DUMMY_RESA2			;$FFA2
VEC_RESERVEDA4	DW	VECTAB_DUMMY_RESA4			;$FFA4
VEC_RESERVEDA6	DW	VECTAB_DUMMY_RESA6			;$FFA6
VEC_RESERVEDA8	DW	VECTAB_DUMMY_RESA8			;$FFA8
VEC_RESERVEDAA	DW	VECTAB_DUMMY_RESAA			;$FFAA
VEC_RESERVEDAC	DW	VECTAB_DUMMY_RESAC			;$FFAC
VEC_RESERVEDAE	DW	VECTAB_DUMMY_RESAE			;$FFAE
VEC_RESERVEDB0  DW	VECTAB_DUMMY_RESB0    			;$FFA0
VEC_RESERVEDB2  DW	VECTAB_DUMMY_RESB2    			;$FFB2
VEC_RESERVEDB4  DW	VECTAB_DUMMY_RESB4    			;$FFB4
VEC_RESERVEDB6  DW	VECTAB_DUMMY_RESB6    			;$FFB6
VEC_RESERVEDB8  DW	VECTAB_DUMMY_RESB8    			;$FFB8
VEC_RESERVEDBA	DW	VECTAB_DUMMY_RESBA			;$FFBA
VEC_RESERVEDBC	DW	VECTAB_DUMMY_RESBC			;$FFBC
VEC_RESERVEDBE	DW	VECTAB_DUMMY_RESBE			;$FFBE
VEC_RESERVEDC0	DW	VECTAB_DUMMY_RESC0			;$FFC0
VEC_RESERVEDC2	DW	VECTAB_DUMMY_RESC2			;$FFC2
VEC_RESERVEDC4  DW	VECTAB_DUMMY_RESC4	      		;$FFC4
VEC_RESERVEDC6	DW	VECTAB_DUMMY_RESC5			;$FFC6
VEC_RESERVEDC8	DW	VECTAB_DUMMY_RESC8			;$FFC8
VEC_RESERVEDCA	DW	VECTAB_DUMMY_RESCA			;$FFCA
VEC_RESERVEDCC	DW	VECTAB_DUMMY_RESCC			;$FFCC
VEC_PORTH     	DW	VECTAB_DUMMY_PORTH     			;$FFCC
VEC_PORTJ	DW	VECTAB_DUMMY_PORTJ			;$FFD0
VEC_ATD	      	DW	VECTAB_DUMMY_ATD	      		;$FFD2
VEC_SCI1	DW	VECTAB_DUMMY_SCI1			;$FFD4
VEC_SCI0	DW	SCI_ISR_RXTX				;$FFD6
VEC_SPI		DW	VECTAB_DUMMY_SPI			;$FFD8
VEC_PAIE	DW	VECTAB_DUMMY_PAIE			;$FFDA
VEC_PAOV	DW	VECTAB_DUMMY_PAOV			;$FFDC
VEC_TOV		DW	VECTAB_DUMMY_TOV			;$FFDE
VEC_TC7		DW	VECTAB_DUMMY_TC7			;$FFE0
VEC_TC6		DW	VECTAB_DUMMY_TC6			;$FFE2
VEC_TC5		DW	VECTAB_DUMMY_TC5			;$FFE4
VEC_TC4		DW	VECTAB_DUMMY_TC4			;$FFE6
VEC_TC3		DW	VECTAB_DUMMY_TC3			;$FFE8
VEC_TC2		DW	VECTAB_DUMMY_TC2			;$FFEA
VEC_TC1		DW	VECTAB_DUMMY_TC0			;$FFEC
VEC_TC0		DW	VECTAB_DUMMY_TC1			;$FFEE
VEC_RTI		DW	VECTAB_DUMMY_RTI			;$FFF0
VEC_IRQ		DW	VECTAB_DUMMY_IRQ			;$FFF2
VEC_XIRQ	DW	VECTAB_DUMMY_XIRQ			;$FFF4
VEC_SWI		DW	VECTAB_DUMMY_SWI			;$FFF6
VEC_TRAP	DW	VECTAB_DUMMY_TRAP			;$FFF8
VEC_RESET_COP	DW	ERROR_RESET_COP				;$FFFA
VEC_RESET_CM	DW	ERROR_RESET_CM				;$FFFC
VEC_RESET_EXT	DW	ERROR_RESET_EXT				;$FFFE
