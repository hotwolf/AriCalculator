;###############################################################################
;# S12CBase - VECTAB - Vector Table (OpenBDC)                                  #
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
;#    BASE   - S12CBase Framework bundle                                       #
;#    ERROR  - Error handler                                                   #
;#    BDM    - BDM driver                                                      #
;#    CLOCK  - Clock handler                                                   #
;#    SCI    - UART driver                                                     #
;#    LED    - LED driver                                                      #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    July 9, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added dummy vectors                                                  #
;#    July 31, 2012                                                            #
;#      - Moved vector table to table section                                  #
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
VECTAB_START_LIN	EQU	$FFF80

;###############################################################################
;# Undefined ISRs                                                              #
;###############################################################################
;#BDM
#ifndef	BDM_ISR_TGTRST
BDM_ISR_TGTRST		EQU	VECTAB_DUMMY_PORTP
#endif
#ifndef	BDM_ISR_TC5
BDM_ISR_TC5		EQU	VECTAB_DUMMY_TC5
#endif
#ifndef	BDM_ISR_TC6
BDM_ISR_TC6		EQU	VECTAB_DUMMY_TC6
#endif
#ifndef	BDM_ISR_TC7
BDM_ISR_TC7		EQU	VECTAB_DUMMY_TC7
#endif
	
;#CLOCK
#ifndef	CLOCK_ISR
CLOCK_ISR		EQU	VECTAB_DUMMY_PLLLOCK
#endif

;#SCI
#ifndef	SCI_ISR_RXTX
SCI_ISR_RXTX		EQU	VECTAB_DUMMY_SCI
#endif
#ifndef	SCI_ISR_TC0
SCI_ISR_TC0		EQU	VECTAB_DUMMY_TC0
#endif
#ifndef	SCI_ISR_TC1
SCI_ISR_TC1		EQU	VECTAB_DUMMY_TC1
#endif
#ifndef	SCI_ISR_TC2
SCI_ISR_TC2		EQU	VECTAB_DUMMY_TC2
#endif

;#LED
#ifndef	LED_ISR
LED_ISR			EQU	VECTAB_DUMMY_RTI
#endif

;#ERROR
#ifndef	ERROR_RESET_COP
ERROR_RESET_COP		EQU	START_OF_CODE
#endif
#ifndef	ERROR_RESET_CM
ERROR_RESET_CM		EQU	ERROR_RESET_COP	
#endif
#ifndef	ERROR_RESET_EXT
ERROR_RESET_EXT		EQU	ERROR_RESET_COP	
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
VECTAB_DUMMY_RES80   	BGND					;$FF80
VECTAB_DUMMY_RES82   	BGND					;$FF82
VECTAB_DUMMY_RES84   	BGND					;$FF84
VECTAB_DUMMY_RES86   	BGND					;$FF86
VECTAB_DUMMY_RES88   	BGND					;$FF88
VECTAB_DUMMY_LVI     	BGND      				;$FF8A
VECTAB_DUMMY_PWM     	BGND      				;$FF8C
VECTAB_DUMMY_PORTP   	BGND					;$FF8E
VECTAB_DUMMY_RES90   	BGND					;$FF90
VECTAB_DUMMY_RES92   	BGND					;$FF92
VECTAB_DUMMY_RES94   	BGND					;$FF94
VECTAB_DUMMY_RES96   	BGND					;$FF96
VECTAB_DUMMY_RES98   	BGND					;$FF98
VECTAB_DUMMY_RES9A   	BGND					;$FF9A
VECTAB_DUMMY_RES9C   	BGND					;$FF9C
VECTAB_DUMMY_RES9E   	BGND					;$FF9E
VECTAB_DUMMY_RESA0   	BGND					;$FFA0
VECTAB_DUMMY_RESA2   	BGND					;$FFA2
VECTAB_DUMMY_RESA4   	BGND					;$FFA4
VECTAB_DUMMY_RESA6   	BGND					;$FFA6
VECTAB_DUMMY_RESA8   	BGND					;$FFA8
VECTAB_DUMMY_RESAA   	BGND					;$FFAA
VECTAB_DUMMY_RESAC   	BGND					;$FFAC
VECTAB_DUMMY_RESAE   	BGND					;$FFAE
VECTAB_DUMMY_CANTX   	BGND					;$FFA0
VECTAB_DUMMY_CANRX   	BGND					;$FFB2
VECTAB_DUMMY_CANERR  	BGND					;$FFB4
VECTAB_DUMMY_CANWUP  	BGND					;$FFB6
VECTAB_DUMMY_FLASH   	BGND					;$FFB8
VECTAB_DUMMY_RESBA   	BGND					;$FFBA
VECTAB_DUMMY_RESBC   	BGND					;$FFBC
VECTAB_DUMMY_RESBE   	BGND					;$FFBE
VECTAB_DUMMY_RESC0   	BGND					;$FFC0
VECTAB_DUMMY_RESC2   	BGND					;$FFC2
VECTAB_DUMMY_SCM     	BGND      				;$FFC4
VECTAB_DUMMY_PLLLOCK 	BGND					;$FFC6
VECTAB_DUMMY_RESC8  	BGND					;$FFC8
VECTAB_DUMMY_RESCA  	BGND					;$FFCA
VECTAB_DUMMY_RESCC  	BGND					;$FFCC
VECTAB_DUMMY_PORTJ  	BGND					;$FFCC
VECTAB_DUMMY_RESD0  	BGND					;$FFD0
VECTAB_DUMMY_ATD    	BGND					;$FFD2
VECTAB_DUMMY_RESD4  	BGND					;$FFD4
VECTAB_DUMMY_SCI    	BGND					;$FFD6
VECTAB_DUMMY_SPI    	BGND					;$FFD8
VECTAB_DUMMY_PAIE   	BGND					;$FFDA
VECTAB_DUMMY_PAOV   	BGND					;$FFDC
VECTAB_DUMMY_TOV    	BGND					;$FFDE
VECTAB_DUMMY_TC7    	BGND					;$FFE0
VECTAB_DUMMY_TC6    	BGND					;$FFE2
VECTAB_DUMMY_TC5    	BGND					;$FFE4
VECTAB_DUMMY_TC4    	BGND					;$FFE6
VECTAB_DUMMY_TC3    	BGND					;$FFE8
VECTAB_DUMMY_TC2    	BGND					;$FFEA
VECTAB_DUMMY_TC1    	BGND					;$FFEC
VECTAB_DUMMY_TC0    	BGND					;$FFEE
VECTAB_DUMMY_RTI    	BGND					;$FFF0
VECTAB_DUMMY_IRQ    	BGND					;$FFF2
VECTAB_DUMMY_XIRQ   	BGND					;$FFF4
VECTAB_DUMMY_SWI    	BGND					;$FFF6
VECTAB_DUMMY_TRAP   	BGND					;$FFF8
#else								
VECTAB_DUMMY_RES80   	EQU	ERROR_ISR			;$FF80
VECTAB_DUMMY_RES82   	EQU	ERROR_ISR			;$FF82
VECTAB_DUMMY_RES84   	EQU	ERROR_ISR			;$FF84
VECTAB_DUMMY_RES86   	EQU	ERROR_ISR			;$FF86
VECTAB_DUMMY_RES88   	EQU	ERROR_ISR			;$FF88
VECTAB_DUMMY_LVI     	EQU	ERROR_ISR      			;$FF8A
VECTAB_DUMMY_PWM     	EQU	ERROR_ISR      			;$FF8C
VECTAB_DUMMY_PORTP   	EQU	ERROR_ISR			;$FF8E
VECTAB_DUMMY_RES90   	EQU	ERROR_ISR			;$FF90
VECTAB_DUMMY_RES92   	EQU	ERROR_ISR			;$FF92
VECTAB_DUMMY_RES94   	EQU	ERROR_ISR			;$FF94
VECTAB_DUMMY_RES96   	EQU	ERROR_ISR			;$FF96
VECTAB_DUMMY_RES98   	EQU	ERROR_ISR			;$FF98
VECTAB_DUMMY_RES9A   	EQU	ERROR_ISR			;$FF9A
VECTAB_DUMMY_RES9C   	EQU	ERROR_ISR			;$FF9C
VECTAB_DUMMY_RES9E   	EQU	ERROR_ISR			;$FF9E
VECTAB_DUMMY_RESA0   	EQU	ERROR_ISR			;$FFA0
VECTAB_DUMMY_RESA2   	EQU	ERROR_ISR			;$FFA2
VECTAB_DUMMY_RESA4   	EQU	ERROR_ISR			;$FFA4
VECTAB_DUMMY_RESA6   	EQU	ERROR_ISR			;$FFA6
VECTAB_DUMMY_RESA8   	EQU	ERROR_ISR			;$FFA8
VECTAB_DUMMY_RESAA   	EQU	ERROR_ISR			;$FFAA
VECTAB_DUMMY_RESAC   	EQU	ERROR_ISR			;$FFAC
VECTAB_DUMMY_RESAE   	EQU	ERROR_ISR			;$FFAE
VECTAB_DUMMY_CANTX   	EQU	ERROR_ISR			;$FFA0
VECTAB_DUMMY_CANRX   	EQU	ERROR_ISR			;$FFB2
VECTAB_DUMMY_CANERR  	EQU	ERROR_ISR			;$FFB4
VECTAB_DUMMY_CANWUP  	EQU	ERROR_ISR			;$FFB6
VECTAB_DUMMY_FLASH   	EQU	ERROR_ISR			;$FFB8
VECTAB_DUMMY_RESBA   	EQU	ERROR_ISR			;$FFBA
VECTAB_DUMMY_RESBC   	EQU	ERROR_ISR			;$FFBC
VECTAB_DUMMY_RESBE   	EQU	ERROR_ISR			;$FFBE
VECTAB_DUMMY_RESC0   	EQU	ERROR_ISR			;$FFC0
VECTAB_DUMMY_RESC2   	EQU	ERROR_ISR			;$FFC2
VECTAB_DUMMY_SCM     	EQU	ERROR_ISR      			;$FFC4
VECTAB_DUMMY_PLLLOCK 	EQU	ERROR_ISR			;$FFC6
VECTAB_DUMMY_RESC8  	EQU	ERROR_ISR			;$FFC8
VECTAB_DUMMY_RESCA  	EQU	ERROR_ISR			;$FFCA
VECTAB_DUMMY_RESCC  	EQU	ERROR_ISR			;$FFCC
VECTAB_DUMMY_PORTJ  	EQU	ERROR_ISR			;$FFCC
VECTAB_DUMMY_RESD0  	EQU	ERROR_ISR			;$FFD0
VECTAB_DUMMY_ATD    	EQU	ERROR_ISR			;$FFD2
VECTAB_DUMMY_RESD4  	EQU	ERROR_ISR			;$FFD4
VECTAB_DUMMY_SCI    	EQU	ERROR_ISR			;$FFD6
VECTAB_DUMMY_SPI    	EQU	ERROR_ISR			;$FFD8
VECTAB_DUMMY_PAIE   	EQU	ERROR_ISR			;$FFDA
VECTAB_DUMMY_PAOV   	EQU	ERROR_ISR			;$FFDC
VECTAB_DUMMY_TOV    	EQU	ERROR_ISR			;$FFDE
VECTAB_DUMMY_TC7    	EQU	ERROR_ISR			;$FFE0
VECTAB_DUMMY_TC6    	EQU	ERROR_ISR			;$FFE2
VECTAB_DUMMY_TC5    	EQU	ERROR_ISR			;$FFE4
VECTAB_DUMMY_TC4    	EQU	ERROR_ISR			;$FFE6
VECTAB_DUMMY_TC3    	EQU	ERROR_ISR			;$FFE8
VECTAB_DUMMY_TC2    	EQU	ERROR_ISR			;$FFEA
VECTAB_DUMMY_TC1    	EQU	ERROR_ISR			;$FFEC
VECTAB_DUMMY_TC0    	EQU	ERROR_ISR			;$FFEE
VECTAB_DUMMY_RTI    	EQU	ERROR_ISR			;$FFF0
VECTAB_DUMMY_IRQ    	EQU	ERROR_ISR			;$FFF2
VECTAB_DUMMY_XIRQ   	EQU	ERROR_ISR			;$FFF4
VECTAB_DUMMY_SWI    	EQU	ERROR_ISR			;$FFF6
VECTAB_DUMMY_TRAP   	EQU	ERROR_ISR			;$FFF8
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
VEC_LVI	      	DW	VECTAB_DUMMY_LVI	      		;$FF8A
VEC_PWM	      	DW	VECTAB_DUMMY_PWM	      		;$FF8C
VEC_PORTP	DW	BDM_ISR_TGTRST				;$FF8E
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
VEC_CANTX     	DW	VECTAB_DUMMY_CANTX     			;$FFA0
VEC_CANRX     	DW	VECTAB_DUMMY_CANRX     			;$FFB2
VEC_CANERR    	DW	VECTAB_DUMMY_CANERR    			;$FFB4
VEC_CANWUP    	DW	VECTAB_DUMMY_CANWUP    			;$FFB6
VEC_FLASH     	DW	VECTAB_DUMMY_FLASH     			;$FFB8
VEC_RESERVEDBA	DW	VECTAB_DUMMY_RESBA			;$FFBA
VEC_RESERVEDBC	DW	VECTAB_DUMMY_RESBC			;$FFBC
VEC_RESERVEDBE	DW	VECTAB_DUMMY_RESBE			;$FFBE
VEC_RESERVEDC0	DW	VECTAB_DUMMY_RESC0			;$FFC0
VEC_RESERVEDC2	DW	VECTAB_DUMMY_RESC2			;$FFC2
VEC_SCM	      	DW	VECTAB_DUMMY_SCM	      		;$FFC4
VEC_PLLLOCK	DW	CLOCK_ISR				;$FFC6
VEC_RESERVEDC8	DW	VECTAB_DUMMY_RESC8			;$FFC8
VEC_RESERVEDCA	DW	VECTAB_DUMMY_RESCA			;$FFCA
VEC_RESERVEDCC	DW	VECTAB_DUMMY_RESCC			;$FFCC
VEC_PORTJ     	DW	VECTAB_DUMMY_PORTJ     			;$FFCC
VEC_RESERVEDD0	DW	VECTAB_DUMMY_RESD0			;$FFD0
VEC_ATD	      	DW	VECTAB_DUMMY_ATD	      		;$FFD2
VEC_RESERVEDD4	DW	VECTAB_DUMMY_RESD4			;$FFD4
VEC_SCI		DW	SCI_ISR_RXTX				;$FFD6
VEC_SPI		DW	VECTAB_DUMMY_SPI			;$FFD8
VEC_PAIE	DW	VECTAB_DUMMY_PAIE			;$FFDA
VEC_PAOV	DW	VECTAB_DUMMY_PAOV			;$FFDC
VEC_TOV		DW	VECTAB_DUMMY_TOV			;$FFDE
VEC_TC7		DW	BDM_ISR_TC7				;$FFE0
VEC_TC6		DW	BDM_ISR_TC6				;$FFE2
VEC_TC5		DW	BDM_ISR_TC5				;$FFE4
VEC_TC4		DW	VECTAB_DUMMY_TC4			;$FFE6
VEC_TC3		DW	VECTAB_DUMMY_TC3			;$FFE8
VEC_TC2		DW	VECTAB_DUMMY_TC2			;$FFEA
VEC_TC1		DW	SCI_ISR_TC1				;$FFEC
VEC_TC0		DW	SCI_ISR_TC0				;$FFEE
VEC_RTI		DW	LED_ISR					;$FFF0
VEC_IRQ		DW	VECTAB_DUMMY_IRQ			;$FFF2
VEC_XIRQ	DW	VECTAB_DUMMY_XIRQ			;$FFF4
VEC_SWI		DW	VECTAB_DUMMY_SWI			;$FFF6
VEC_TRAP	DW	VECTAB_DUMMY_TRAP			;$FFF8
VEC_RESET_COP	DW	ERROR_RESET_COP				;$FFFA
VEC_RESET_CM	DW	ERROR_RESET_CM				;$FFFC
VEC_RESET_EXT	DW	ERROR_RESET_EXT				;$FFFE
