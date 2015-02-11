#ifndef	VMON
#define	VMON
;###############################################################################
;# AriCalculator - VMON - Voltage Monitor (AriCalculator)                      #
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
;#    This module monitors battery and USB voltages.                           #
;###############################################################################
;# Version History:                                                            #
;#    August 19, 2014                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#    VECMAP - Vector Map                                                      #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    GPIO   - GPIO driver                                                     #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Battery voltage monitor (PAD8)
;------------------------------
;Upper threshold
#ifndef VMON_VBAT_UPPER_THRESHOLD
VMON_VBAT_UPPER_THRESHOLD	EQU	(24*$FFFF)/33 	;default 2.4V
#endif	
;Lower threshold
#ifndef VMON_VBAT_LOWER_THRESHOLD
VMON_VBAT_LOWER_THRESHOLD	EQU	 (20*$FFFF)/33 	;default 2.0V
#endif	
	
;USB voltage monitor (PAD9)
;--------------------------
;Upper threshold
#ifndef VMON_VUSB_UPPER_THRESHOLD
VMON_VUSB_UPPER_THRESHOLD	EQU	(24*$FFFF)/33 	;default 2.4V
#endif	
;Lower threshold
#ifndef VMON_VUSB_LOWER_THRESHOLD
VMON_VUSB_LOWER_THRESHOLD	EQU	 (20*$FFFF)/33 	;default 2.0V
#endif	
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Basic settings
;--------------
			;Common configuration 
VMON_ATDCTL0_CONFIG	EQU      %00001001 ;-> wrap at AN9
			;             ^  ^ ;(only relevant when monitoring both voltages)
			;    WRAP-----+--+ 

VMON_ATDCTL1_CONFIG	EQU	 %00010000 ;-> 8-bit resolution
			;         ^^^^^  ^ ;-> discharge sample cap before conversion
			;ETRIGSEL-+||||  | 
			;    SRES--++||  | 
			; SMP_DIS----+|  | 
			; ETRIGCH-----+--+ 

VMON_ATDCTL2_CONFIG	EQU	 %00000001 ;-> fast flag clearing
			;          ^^^^^^^ ;-> enable compare interrupt
			;    AFFC--+|||||| 
			; ICLKSTP---+||||| 
			; ETRIGLE----+|||| 
			;  ETRIGP-----+||| 
			;  ETRIGE------+|| 
			;   ASCIE-------+| 
			;  ACMPIE--------+ 

VMON_ATDCTL3_CONFIG	EQU	 %00010000 ;-> 2 conversions per sequence
			;         ^^^^^^^^ ;-> complete current conversion in BDM active mode
			;     DJM-+||||||| ;(only relevant when monitoring both voltages)  
			;     S8C--+|||||| 
			;     S4C---+|||||
			;     S2C----+|||| 
			;     S1C-----+||| 
			;    FIFO------+|| 
			;     FRZ-------++ 

VMON_ATDCTL4_CONFIG	EQU	 %11111111 ;-> sample for 30.72us 
			;         ^ ^^   ^
			;     SMP-+-+|   | 
			;     PRS----+---+ 

VMON_ATDCTL5_CONFIG	EQU	 %00111000 ;-> continuous conversion over multiple channels
			;          ^^^^^^^ ;-> start conversion sequence with AN8 
			;      SC--+|||||| 
			;    SCAN---+||||| 
			;    MULT----+|||| 
			;      CD-----+||| 
			;      CC------+|| 
			;      CB-------+| 
			;      CA--------+

VMON_VBAT_CONVERSION	EQU	$00
VMON_VUSB_CONVERSION	EQU	$01
VMON_VBAT_ATDDR		EQU	(ATDDR0+(2*VMON_VBAT_CONVERSION))
VMON_VUSB_ATDDR		EQU	(ATDDR0+(2*VMON_VUSB_CONVERSION))

				;Monitor status
;--------------
VMON_STATUS		EQU	 ATDCMPHTL ;1=LV condition, 0=HV condition
VMON_STATUS_VBAT	EQU	 (1<<VMON_VBAT_CONVERSION)
VMON_STATUS_VUSB	EQU	 (1<<VMON_VUSB_CONVERSION)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef VMON_VARS_START_LIN
			ORG 	VMON_VARS_START, VMON_VARS_START_LIN
#else
			ORG 	VMON_VARS_START
VMON_VARS_START_LIN	EQU	@			
#endif	

VMON_VARS_END		EQU	*
VMON_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	VMON_INIT, 0
			;Monitor VBAT and VUSB
			MOVW	#((VMON_ATDCTL0_CONFIG<<8)|VMON_ATDCTL1_CONFIG), ATDCTL0
			MOVW	#((VMON_ATDCTL2_CONFIG<<8)|VMON_ATDCTL3_CONFIG), ATDCTL2
			MOVB	#VMON_ATDCTL4_CONFIG, ATDCTL4
			MOVB	#((1<<VMON_VBAT_CONVERSION)|(1<<VMON_VUSB_CONVERSION)), ATDCMPEL
			MOVB	#((1<<VMON_VBAT_CONVERSION)|(1<<VMON_VUSB_CONVERSION)), ATDCMPHTL
			MOVW	#VMON_VBAT_UPPER_THRESHOLD, VMON_VBAT_ATDDR
			MOVW	#VMON_VUSB_UPPER_THRESHOLD, VMON_VUSB_ATDDR
				;Start ATD conversions
			MOVW	#$FFFF, ATDSTAT2H
			MOVB	#$FF, ATDSTAT0
			MOVB	#VMON_ATDCTL5_CONFIG, ATDCTL5
#emac

;#Wait for first connversion results
;#----------------------------------
#macro	VMON_WAIT_FOR_1ST_RESULTS, 0
LOOP		SEI	
		BRSET	ATDSTAT0, #SCF, DONE 			;Conversion sequence complete
		ISTACK_WAIT
		JOB	LOOP
DONE		CLI	
#emac

;#Conditional branches
;#--------------------
;#Branch on VBAT HV condition
; args:   1: branch address
; SSTACK: none
;         All registers are preserved 
#macro VMON_VBAT_BRHV, 1
	BRCLR	VMON_STATUS, #VMON_STATUS_VBAT, \1
#emac

;#Branch on VBAT LV condition
; args:   1: branch address
; SSTACK: none
;         All registers are preserved 
#macro VMON_VBAT_BRLV, 1
	BRSET	VMON_STATUS, #VMON_STATUS_VBAT, \1
#emac

;#Branch on VUSB HV condition
; args:   1: branch address
; SSTACK: none
;         All registers are preserved 
#macro VMON_VUSB_BRHV, 1
	BRCLR	VMON_STATUS, #VMON_STATUS_VUSB, \1
#emac

;#Branch on VUSB LV condition
; args:   1: branch address
; SSTACK: none
;         All registers are preserved 
#macro VMON_VUSB_BRLV, 1
	BRSET	VMON_STATUS, #VMON_STATUS_VUSB, \1
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef VMON_CODE_START_LIN
			ORG 	VMON_CODE_START, VMON_CODE_START_LIN
#else
			ORG 	VMON_CODE_START
VMON_CODE_START_LIN	EQU	@			
#endif	

;#ADC Compare ISR
;#---------------
VMON_ISR		EQU	*
			;Check VUSB
			BRCLR	ATDSTAT2L,  #(1<<VMON_VUSB_CONVERSION), VMON_ISR_2 	;skip if state hasn't changed
			BRSET	ATDCMPHTL, #(1<<VMON_VUSB_CONVERSION), VMON_ISR_1 	;HV condition detected
			;LV condition detected
			MOVW	#VMON_VUSB_UPPER_THRESHOLD, VMON_VUSB_ATDDR		;set upper threshold value
			BSET	ATDCMPHTL, #(1<<VMON_VUSB_CONVERSION)   		;VUSB must be higher than threshold
			MOVB	#(1<<VMON_VUSB_CONVERSION), ATDSTAT2L 			;clear interrupt flag
#ifmac	VMON_VUSB_LVACTION
			VMON_VUSB_LVACTION
#endif
			JOB	VMON_ISR_2						;VUSB check done
			;HV condition detected
VMON_ISR_1		MOVW	#(1<<VMON_VUSB_LOWER_THRESHOLD), VMON_VUSB_ATDDR	;set upper threshold value
			BCLR	ATDCMPHTL, #(1<<VMON_VUSB_CONVERSION)   		;VUSB must be lower (or same) than threshold
			MOVB	#(1<<VMON_VUSB_CONVERSION), ATDSTAT2L 			;clear interrupt flag
#ifmac	VMON_VUSB_HVACTION
			VMON_VUSB_HVACTION
#endif
			;Check VBAT
VMON_ISR_2		BRCLR	ATDSTAT2L,  #(1<<VMON_VBAT_CONVERSION), VMON_ISR_5 	;skip if state hasn't changed
			BRSET	ATDCMPHTL, #(1<<VMON_VBAT_CONVERSION), VMON_ISR_3 	;HV condition detected
			;LV condition detected
			MOVW	#VMON_VBAT_UPPER_THRESHOLD, VMON_VBAT_ATDDR		;set upper threshold value
			BSET	ATDCMPHTL, #(1<<VMON_VBAT_CONVERSION)   		;VBAT must be higher than threshold
			MOVB	#(1<<VMON_VBAT_CONVERSION), ATDSTAT2L 			;clear interrupt flag
#ifmac	VMON_VBAT_LVACTION
			VMON_VBAT_LVACTION
#endif
			JOB	VMON_ISR_4						;VBAT check done
			;HV condition detected
VMON_ISR_3		MOVW	#VMON_VBAT_LOWER_THRESHOLD, VMON_VBAT_ATDDR		;set upper threshold value
			BCLR	ATDCMPHTL, #(1<<VMON_VBAT_CONVERSION)   		;VBAT must be lower (or same) than threshold
			MOVB	#(1<<VMON_VBAT_CONVERSION), ATDSTAT2L 			;clear interrupt flag
#ifmac	VMON_VBAT_LHACTION
			VMON_VBAT_HVACTION
#endif
			;Restart conversion sequence 
VMON_ISR_4		MOVB	#VMON_ATDCTL5_CONFIG, ATDCTL5

			;VBAT check done
VMON_ISR_5		ISTACK_RTI

VMON_CODE_END		EQU	*	
VMON_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef VMON_TABS_START_LIN
			ORG 	VMON_TABS_START, VMON_TABS_START_LIN
#else
			ORG 	VMON_TABS_START
VMON_TABS_START_LIN	EQU	@			
#endif	

VMON_TABS_END		EQU	*	
VMON_TABS_END_LIN	EQU	@	
#endif
