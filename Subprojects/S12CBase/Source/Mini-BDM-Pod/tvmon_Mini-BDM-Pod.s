#ifndef	TVMON_COMPILED
#define	TVMON_COMPILED
;###############################################################################
;# S12CBase - TVMON - Target Vdd Monitor (Mini-BDM-Pod)                        #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
;#    families                                                                 #
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
;#    August 7, 2012                                                           #
;#      - Added support for linear PC                                          #
;###############################################################################
;# Required Modules:                                                           #
;#    LED - LED driver                                                         #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Voltage thresholds
;------------------
#ifndef TVMON_UPPER_THRESHOLD
TVMON_UPPER_THRESHOLD	EQU	(30*$FFFF)/(2*50) ;default 3.0V
#endif	

#ifndef TVMON_LOWER_THRESHOLD
TVMON_LOWER_THRESHOLD	EQU	 (5*$FFFF)/(2*50) ;default 0.5V
#endif	

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;ADC configuration
;-----------------
;TVMON_ATDCTL0_CONFIG	EQU	 %00001111 ;reset value
			;             ^  ^
			;    WRAP-----+--+ 
	
TVMON_ATDCTL1_CONFIG	EQU	 %01000000
			;         ^^^^^  ^
			;ETRIGSEL-+||||  | 
			;    SRES--++||  | 
			; SMP_DIS----+|  | 
			; ETRIGCH-----+--+ 

TVMON_ATDCTL2_CONFIG	EQU	 %01000001
			;          ^^^^^^^
			;    AFFC--+|||||| 
			; ICLKSTP---+||||| 
			; ETRIGLE----+|||| 
			;  ETRIGP-----+||| 
			;  ETRIGE------+|| 
			;   ASCIE-------+| 
			;  ACMPIE--------+ 

TVMON_ATDCTL3_CONFIG	EQU	 %00010011
			;         ^^^^^^^^
			;     DJM-+||||||| 
			;     S8C--+|||||| 
			;     S4C---+||||| 
			;     S2C----+|||| 
			;     S1C-----+||| 
			;    FIFO------+|| 
			;     FRZ-------++ 

TVMON_ATDCTL4_CONFIG	EQU	%11111111
			;         ^ ^^   ^
			;     SMP-+-+|   | 
			;     PRS----+---+ 

TVMON_ATDCTL5_CONFIG	EQU	 %00101011
			;          ^^^^^^^
			;      SC--+|||||| 
			;    SCAN---+||||| 
			;    MULT----+|||| 
			;      CD-----+||| 
			;      CC------+|| 
			;      CB-------+| 
			;      CA--------+

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef TVMON_VARS_START_LIN
			ORG 	TVMON_VARS_START, TVMON_VARS_START_LIN
#else
			ORG 	TVMON_VARS_START
TVMON_VARS_START_LIN	EQU	@			
#endif	

TVMON_VARS_END		EQU	*
TVMON_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	TVMON_INIT, 0
			;Configure ADC
			MOVB	#TVMON_ATDCTL1_CONFIG, ATDCTL1
			MOVW	#((TVMON_ATDCTL2_CONFIG<<8)|TVMON_ATDCTL3_CONFIG), ATDCTL2
			MOVB	#TVMON_ATDCTL4_CONFIG, ATDCTL4
			MOVB	#$01, ATDCMPEL
			MOVB	#$01, ATDCMPHTL
			MOVW	#TVMON_UPPER_THRESHOLD, ATDDR0

			;Initially flag missing target
			LED_BICOLOR_RED

			;Start ATD conversions
			MOVB	#TVMON_ATDCTL5_CONFIG, ATDCTL5
#emac

;#Functions	
;#---------
;#Branch if no target is detected
#macro	TVMON_BRNOTGT, 1
			BRSET	ATDCMPHTL, #$01, \1	
#emac

;#Branch if no target is detected
#macro	TVMON_BRTGT, 1
			BRCLR	ATDCMPHTL, #$01, \1	
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef TVMON_CODE_START_LIN
			ORG 	TVMON_CODE_START, TVMON_CODE_START_LIN
#else
			ORG 	TVMON_CODE_START
TVMON_CODE_START_LIN	EQU	@			
#endif	

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
TVMON_ISR_2		MOVB	#TVMON_ATDCTL5_CONFIG, ATDCTL5
	
			;Done 
			ISTACK_RTI	

TVMON_CODE_END		EQU	*	
TVMON_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef TVMON_TABS_START_LIN
			ORG 	TVMON_TABS_START, TVMON_TABS_START_LIN
#else
			ORG 	TVMON_TABS_START
TVMON_TABS_START_LIN	EQU	@			
#endif	

TVMON_TABS_END		EQU	*	
TVMON_TABS_END_LIN	EQU	@	
#endif
