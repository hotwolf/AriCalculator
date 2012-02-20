;###############################################################################
;# S12CBase - TVMON - Target Vdd Monitor (LFBDMPGMR only)                      #
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
;#    This module monitors the target voltage on the LFMPGMR pod.              #
;###############################################################################
;# Version History:                                                            #
;#    February 13, 2012                                                        #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	TVMON_VARS_START
TVMON_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	TVMON_INIT, 0
			;MOVB	#%00000000, ADCCTL0
			;             ^  ^
			;    WRAP-----+--+ 
	
			;MOVB	#%00000000, ADCCTL1
			;         ^^^^^  ^
			;ETRIGSEL-+||||  | 
			;    SRES--++||  | 
			; SMP_DIS----+|  | 
			; ETRIGCH-----+--+ 

			MOVB	#%01000001, ADCCTL2
			;          ^^^^^^^
			;    AFFC--+|||||| 
			; ICLKSTP---+||||| 
			; ETRIGLE----+|||| 
			;  ETRIGP-----+||| 
			;  ETRIGE------+|| 
			;   ASCIE-------+| 
			;  ACMPIE--------+ 

			MOVB	#%00001011, ADCCTL3
			;         ^^^^^^^^
			;     DJM-+||||||| 
			;     S8C--+|||||| 
			;     S4C---+||||| 
			;     S2C----+|||| 
			;     S1C-----+||| 
			;    FIFO------+|| 
			;     FRZ-------++ 

			MOVB	#%11111111, ADCCTL4
			;         ^ ^^   ^
			;     SMP-+-+|   | 
			;     PRS----+---+ 

			MOVB	#%00011011, ADCCTL5
			;          ^^^^^^^
			;      SC--+|||||| 
			;    SCAN---+||||| 
			;    MULT----+|||| 
			;      CD-----+||| 
			;      CC------+|| 
			;      CB-------+| 
			;      CA--------+

			;ATDSTAT0

			MOVB	#$01, ATDCMPE+$1

			;ATDSTAT2
			;ATDIEN

			MOVB	#$01, ATDCMPHT+$1

			MOVB	#(30*$FF)/50, ATDDR0
			
			;ATDDR1
			;ATDDR2
			;ATDDR3
			;ATDDR4
			;ATDDR5
			;ATDDR5
			;ATDDR6
			;ATDDR7
			;ATDDR8
			;ATDDR9
			;ATDDR10
			;ATDDR11
			;ATDDR12
			;ATDDR13
			;ATDDR14
			;ATDDR15

			;Initially flag missing target
			LED_BICOLOR_RED
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	TVMON_CODE_START

TVMON_ISR		EQU	*
			BRSET	ATDCMPHT+$1, #$01, TVMON_ISR_1 	;target Vdd detected

			;Target Vdd missing
			LED_BICOLOR_RED				;flag missing target Vdd
			MOVB	#(30*$FF)/50, ATDDR0		;set threshold value (3V)
			MOVB	#$01, ATDCMPHT+$1		;target Vdd must be higher than threshold
			MOVB	#PM7, PTM			;disable target interface
			JOB	TVMON_ISR_2			;done
			
			;Target Vdd detected
TVMON_ISR_1		LED_BICOLOR_GREEN			;flag detected target Vdd
			MOVB	#(25*$FF)/50, ATDDR0		;set threshold value (2,5V)
			CLR	ATDCMPHT+$1			;target Vdd must be lower or same as threshold
			CLR	PTM				;enable target interface
			;Done 
TVMON_ISR_2		ISTACK_RTS	

TVMON_CODE_END		EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	TVMON_TABS_START
TVMON_TABS_END		EQU	*
