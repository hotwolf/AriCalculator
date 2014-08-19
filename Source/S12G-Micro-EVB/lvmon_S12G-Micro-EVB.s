#ifndef	LVMON
#define	LVMON
;###############################################################################
;# S12CBase - LVMON - Low Vdd Monitor (S12G-Micro-EVB)                         #
;###############################################################################
;#    Copyright 2010-2014 Dirk Heisswolf                                       #
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
;#    This module monitors the supply voltage of the S12G-Mini-EVB.            #
;###############################################################################
;# Version History:                                                            #
;#    August 19, 2014                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Voltage thresholds
;------------------
#ifndef LVMON_UPPER_THRESHOLD
LVMON_UPPER_THRESHOLD	EQU	(24*$FFFF)/33 ;default 2.4V
#endif	

#ifndef LVMON_LOWER_THRESHOLD
LVMON_LOWER_THRESHOLD	EQU	 (20*$FFFF)/33 ;default 2.0V
#endif	

;LV/HV condition handling
;------------------------ 
;Act on low voltage detection (use LVMON_LV_ACTION macro)
#ifndef	LVMON_HANDLE_LV
#ifndef	LVMON_IGNORE_LV
LVMON_IGNORE_LV		EQU	1 		;default is to ignore LV conditions
#endif
#endif
	
;Act on low voltage detection (use LVMON_HV_ACTION macro)
#ifndef	LVMON_HANDLE_HV
#ifndef	LVMON_IGNORE_HV
LVMON_IGNORE_HV		EQU	1 		;default is to ignore HV conditions
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;ADC configuration
;-----------------
;LVMON_ATDCTL0_CONFIG	EQU	%00001111 ;reset value
			;             ^  ^
			;    WRAP-----+--+ 
	
LVMON_ATDCTL1_CONFIG	EQU	 %01000000
			;         ^^^^^  ^
			;ETRIGSEL-+||||  | 
			;    SRES--++||  | 
			; SMP_DIS----+|  | 
			; ETRIGCH-----+--+ 

LVMON_ATDCTL2_CONFIG	EQU	 %01000001
			;          ^^^^^^^
			;    AFFC--+|||||| 
			; ICLKSTP---+||||| 
			; ETRIGLE----+|||| 
			;  ETRIGP-----+||| 
			;  ETRIGE------+|| 
			;   ASCIE-------+| 
			;  ACMPIE--------+ 

LVMON_ATDCTL3_CONFIG	EQU	 %00010011
			;         ^^^^^^^^
			;     DJM-+||||||| 
			;     S8C--+|||||| 
			;     S4C---+||||| 
			;     S2C----+|||| 
			;     S1C-----+||| 
			;    FIFO------+|| 
			;     FRZ-------++ 

LVMON_ATDCTL4_CONFIG	EQU	 %11111111
			;         ^ ^^   ^
			;     SMP-+-+|   | 
			;     PRS----+---+ 

LVMON_ATDCTL5_CONFIG	EQU	 %00100000
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
#ifdef LVMON_VARS_START_LIN
			ORG 	LVMON_VARS_START, LVMON_VARS_START_LIN
#else
			ORG 	LVMON_VARS_START
LVMON_VARS_START_LIN	EQU	@			
#endif	

LVMON_VARS_END		EQU	*
LVMON_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	LVMON_INIT, 0
			;Configure ADC
			MOVB	#LVMON_ATDCTL1_CONFIG, ATDCTL1
			MOVW	#((LVMON_ATDCTL2_CONFIG<<8)|LVMON_ATDCTL3_CONFIG), ATDCTL2
			MOVB	#LVMON_ATDCTL4_CONFIG, ATDCTL4
			MOVB	#$01, ATDCMPEL
			MOVB	#$01, ATDCMPHTL
			MOVW	#LVMON_UPPER_THRESHOLD, ATDDR0

			;Start ATD conversions
			MOVB	#LVMON_ATDCTL5_CONFIG, ATDCTL5
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef LVMON_CODE_START_LIN
			ORG 	LVMON_CODE_START, LVMON_CODE_START_LIN
#else
			ORG 	LVMON_CODE_START
LVMON_CODE_START_LIN	EQU	@			
#endif	

LVMON_ISR		EQU	*
			BRSET	ATDCMPHTH+$1, #$01, LVMON_ISR_1 ;target Vdd detected

			;Low Vdd
			BSET	ATDCMPHTL, #$01			;target Vdd must be higher than threshold			
			MOVW	#LVMON_UPPER_THRESHOLD, ATDDR0	;set upper threshold value
#ifdef	LVMON_HANDLE_LV
			LVMON_LV_ACTION				;LV action
#endif
			JOB	LVMON_ISR_2			;restart ADC conversion
			
			;High Vdd
LVMON_ISR_1		BCLR	ATDCMPHTL, #$01			;target Vdd must be lower than threshold			
			MOVW	#LVMON_LOWER_THRESHOLD, ATDDR0	;set lower threshold value
#ifdef	LVMON_HANDLE_HV
			LVMON_HV_ACTION				;HV action
#endif
	
			;Restart ATD conversions
LVMON_ISR_2		MOVB	#LVMON_ATDCTL5_CONFIG, ATDCTL5
	
			;Done 
			ISTACK_RTI	

LVMON_CODE_END		EQU	*	
LVMON_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef LVMON_TABS_START_LIN
			ORG 	LVMON_TABS_START, LVMON_TABS_START_LIN
#else
			ORG 	LVMON_TABS_START
LVMON_TABS_START_LIN	EQU	@			
#endif	

LVMON_TABS_END		EQU	*	
LVMON_TABS_END_LIN	EQU	@	
#endif
