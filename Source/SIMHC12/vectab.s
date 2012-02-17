;###############################################################################
;# S12CBase - VECTAB - Vector Table (SIMHC12 Version)                          #
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
;#    This module defines the static vector table of the OpenBDC firmware.     #
;#    Unexpected inerrupts are cought and trigger a fatal error in the reset   #
;#    handler.                                                                 #
;#    This version of VECTAB contains modifications to run on the SIM68HC12    #
;#    simulator.                                                               #
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
;###############################################################################

;###############################################################################
;# S12G128 Vector Table                                                        #
;###############################################################################
		ORG	$FF80
VEC_RESERVED80	DW	ERROR_ISR
VEC_RESERVED82	DW	ERROR_ISR
VEC_RESERVED84	DW	ERROR_ISR
VEC_RESERVED86	DW	ERROR_ISR
VEC_RESERVED88	DW	ERROR_ISR
VEC_LVI		DW	ERROR_ISR
VEC_PWM		DW	ERROR_ISR
VEC_PORTP	DW	ERROR_ISR
VEC_RESERVED90	DW	ERROR_ISR
VEC_RESERVED92	DW	ERROR_ISR
VEC_RESERVED94	DW	ERROR_ISR
VEC_RESERVED96	DW	ERROR_ISR
VEC_RESERVED98	DW	ERROR_ISR
VEC_RESERVED9A	DW	ERROR_ISR
VEC_RESERVED9C	DW	ERROR_ISR
VEC_RESERVED9E	DW	ERROR_ISR
VEC_RESERVEDA0	DW	ERROR_ISR
VEC_RESERVEDA2	DW	ERROR_ISR
VEC_RESERVEDA4	DW	ERROR_ISR
VEC_RESERVEDA6	DW	ERROR_ISR
VEC_RESERVEDA8	DW	ERROR_ISR
VEC_RESERVEDAA	DW	ERROR_ISR
VEC_RESERVEDAC	DW	ERROR_ISR
VEC_RESERVEDAE	DW	ERROR_ISR
VEC_CANTX	DW	ERROR_ISR
VEC_CANRX	DW	ERROR_ISR
VEC_CANERR	DW	ERROR_ISR
VEC_CANWUP	DW	ERROR_ISR
VEC_FLASH	DW	ERROR_ISR
VEC_RESERVEDBA	DW	ERROR_ISR
VEC_RESERVEDBC	DW	ERROR_ISR
VEC_RESERVEDBE	DW	ERROR_ISR
VEC_RESERVEDC0	DW	ERROR_ISR
VEC_RESERVEDC2	DW	ERROR_ISR
VEC_SCM		DW	ERROR_ISR
VEC_PLLLOCK	DW	ERROR_ISR
VEC_RESERVEDC8	DW	ERROR_ISR
VEC_RESERVEDCA	DW	ERROR_ISR
VEC_RESERVEDCC	DW	ERROR_ISR
VEC_PORTJ	DW	ERROR_ISR
VEC_RESERVEDD0	DW	ERROR_ISR
VEC_ATD		DW	ERROR_ISR
VEC_RESERVEDD4	DW	ERROR_ISR
VEC_SCI		DW	SCI_ISR_RXTX
VEC_SPI		DW	ERROR_ISR
VEC_PAIE	DW	ERROR_ISR
VEC_PAOV	DW	ERROR_ISR
VEC_TOV		DW	ERROR_ISR
VEC_TC7		DW	ERROR_ISR
VEC_TC6		DW	ERROR_ISR
VEC_TC5		DW	ERROR_ISR
VEC_TC4		DW	ERROR_ISR
VEC_TC3		DW	ERROR_ISR
VEC_TC2		DW	ERROR_ISR
VEC_TC1		DW	ERROR_ISR
VEC_TC0		DW	ERROR_ISR
VEC_RTI		DW	ERROR_ISR
VEC_IRQ		DW	ERROR_ISR
VEC_XIRQ	DW	ERROR_ISR
VEC_SWI		DW	ERROR_ISR
VEC_TRAP	DW	ERROR_ISR
VEC_RESET_COP	DW	BASE_ENTRY_COP
VEC_RESET_CM	DW	BASE_ENTRY_CM
VEC_RESET_EXT	DW	BASE_ENTRY_EXT
