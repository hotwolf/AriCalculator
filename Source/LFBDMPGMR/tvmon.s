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
TVMON_UPPER_THRESHOLD	EQU	(30*$FFFF)/100 ;3V
TVMON_LOWER_THRESHOLD	EQU	( 5*$FFFF)/100 ;0.5V

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
			MOVB	#%00000000, ATDCTL0
			;             ^  ^
			;    WRAP-----+--+ 
	
			MOVB	#%01000000, ATDCTL1
			;         ^^^^^  ^
			;ETRIGSEL-+||||  | 
			;    SRES--++||  | 
			; SMP_DIS----+|  | 
			; ETRIGCH-----+--+ 

			MOVB	#%01000001, ATDCTL2
			;          ^^^^^^^
			;    AFFC--+|||||| 
			; ICLKSTP---+||||| 
			; ETRIGLE----+|||| 
			;  ETRIGP-----+||| 
			;  ETRIGE------+|| 
			;   ASCIE-------+| 
			;  ACMPIE--------+ 

			MOVB	#%00010011, ATDCTL3
			;         ^^^^^^^^
			;     DJM-+||||||| 
			;     S8C--+|||||| 
			;     S4C---+||||| 
			;     S2C----+|||| 
			;     S1C-----+||| 
			;    FIFO------+|| 
			;     FRZ-------++ 

			MOVB	#%11111111, ATDCTL4
			;         ^ ^^   ^
			;     SMP-+-+|   | 
			;     PRS----+---+ 

			;ATDSTAT0

			MOVB	#$01, ATDCMPEL

			;ATDSTAT2
			;ATDIEN

			MOVB	#$01, ATDCMPHTL

			MOVW	#TVMON_UPPER_THRESHOLD, ATDDR0
			
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

			;Start ATD conversions
			MOVB	#%00101011, ATDCTL5
			;          ^^^^^^^
			;      SC--+|||||| 
			;    SCAN---+||||| 
			;    MULT----+|||| 
			;      CD-----+||| 
			;      CC------+|| 
			;      CB-------+| 
			;      CA--------+

#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	TVMON_CODE_START

TVMON_ISR		EQU	*
			BRSET	ATDCMPHTH+$1, #$01, TVMON_ISR_1 ;target Vdd detected

			;Target Vdd missing
			LED_BICOLOR_RED				;flag missing target Vdd
			BSET	ATDCMPHTL, #$01			;target Vdd must be higher than threshold			
			MOVW	#TVMON_UPPER_THRESHOLD, ATDDR0	;set upper threshold value
			CLR	PTM				;disable target interface
			JOB	TVMON_ISR_2			;restart ADC conversion
			
			;Target Vdd detected
TVMON_ISR_1		LED_BICOLOR_GREEN			;flag detected target Vdd
			BCLR	ATDCMPHTL, #$01			;target Vdd must be lower than threshold			
			MOVW	#TVMON_LOWER_THRESHOLD, ATDDR0	;set lower threshold value
			MOVB	#PM7, PTM			;enable target interface

			;Restart ATD conversions
TVMON_ISR_2		MOVB	#%00101011, ATDCTL5
			;          ^^^^^^^
			;      SC--+|||||| 
			;    SCAN---+||||| 
			;    MULT----+|||| 
			;      CD-----+||| 
			;      CC------+|| 
			;      CB-------+| 
			;      CA--------+
	
			;Done 
			ISTACK_RTI	

TVMON_CODE_END		EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	TVMON_TABS_START
TVMON_TABS_END		EQU	*
