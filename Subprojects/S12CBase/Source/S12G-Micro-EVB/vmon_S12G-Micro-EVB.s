#ifndef	VMON_COMPILED
#define	VMON_COMPILED
;###############################################################################
;# S12CBase - VMON - Voltage Monitor (S12G-Micro-EVB)                          #
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
;#    VECTAB  - Vector table                                                   #
;#    ISTACK  - Interrupt stack handler                                        #
;###############################################################################
;# Hardware setup:  VBAT -> AN0                                                #
;#                  VUSB -> AN7                                                #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Battery voltage monitor (PAD0)
;------------------------------
;VBAT high voltage action
#ifmac VMON_VUSB_HVACTION
VMON_VBAT			EQU	1 		;monitor VBAT
VMON_ANY			EQU	1 		;VMON enabled
#endif
;VBAT low voltage action
#ifmac VMON_VBAT_LVACTION
VMON_VBAT			EQU	1 		;monitor VBAT
VMON_ANY			EQU	1 		;VMON enabled
#endif
;Upper threshold
#ifdef VMON_VBAT
#ifndef VMON_VBAT_UPPER_THRESHOLD
VMON_VBAT_UPPER_THRESHOLD	EQU	(24*$FFFF)/33 	;default 2.4V
#endif	
;Lower threshold
#ifndef VMON_VBAT_LOWER_THRESHOLD
VMON_VBAT_LOWER_THRESHOLD	EQU	(20*$FFFF)/33 	;default 2.0V
#endif	
#endif	
	
;USB voltage monitor (PAD7)
;--------------------------
;VUSB high voltage action
#ifmac VMON_VUSB_HVACTION
VMON_VUSB			EQU	1 		;monitor VUSB
VMON_ANY			EQU	1 		;VMON enabled
#endif
;VUSB low voltage action
#ifmac VMON_VUSB_LVACTION
VMON_VUSB			EQU	1 		;monitor VUSB
VMON_ANY			EQU	1 		;VMON enabled
#endif
#ifdef VMON_VUSB
;Upper threshold
#ifndef VMON_VUSB_UPPER_THRESHOLD
VMON_VUSB_UPPER_THRESHOLD	EQU	(24*$FFFF)/33 	;default 2.4V
#endif	
;Lower threshold
#ifndef VMON_VUSB_LOWER_THRESHOLD
VMON_VUSB_LOWER_THRESHOLD	EQU     (20*$FFFF)/33 	;default 2.0V
#endif	
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Basic settings
;--------------
				;Common configuration 
VMON_ATDCTL0_CONFIG		EQU      %00000111 ;only relevant when monitoring both voltages
				;             ^  ^ ;conversion sequence wrap around at AN7
				;    WRAP-----+--+ 
				
VMON_ATDCTL1_CONFIG		EQU	 %01000000 ;8-bit resolution
				;         ^^^^^  ^
				;ETRIGSEL-+||||  | 
				;    SRES--++||  | 
				; SMP_DIS----+|  | 
				; ETRIGCH-----+--+ 
				
VMON_ATDCTL2_CONFIG		EQU	 %01000001 ;fast flag clearing
				;          ^^^^^^^ ;enable compare interrupt
				;    AFFC--+|||||| 
				; ICLKSTP---+||||| 
				; ETRIGLE----+|||| 
				;  ETRIGP-----+||| 
				;  ETRIGE------+|| 
				;   ASCIE-------+| 
				;  ACMPIE--------+ 
				
VMON_ATDCTL3_CONFIG		EQU	 %00010010 ;only relevant when monitoring both voltages
				;         ^^^^^^^^ ;two conversion sequence
				;     DJM-+||||||| ;only freeze inbetween cinversions
				;     S8C--+|||||| 
				;     S4C---+||||| 
				;     S2C----+|||| 
				;     S1C-----+||| 
				;    FIFO------+|| 
				;     FRZ-------++ 

VMON_ATDCTL4_CONFIG		EQU	 %11100111 ;long sample time
		   		;         ^ ^^   ^ ;fATDC between 0,25MHZ (VCO 8MHZ) and  
		   		;     SMP-+-+|   | ;              1,56MHZ (PLL 50MHz)
		   		;     PRS----+---+ 

;Configuration specific settings
;-------------------------------
#ifdef	VMON_VBAT
#ifdef	VMON_VUSB
				;Monitor VBAT and VUSB
VMON_VBAT_CONVERSION		EQU	$02
VMON_VUSB_CONVERSION		EQU	$01
VMON_VBAT_ATDDR			EQU	ATDDR1
VMON_VUSB_ATDDR			EQU	ATDDR0
VMON_ATDCTL5_CONFIG		EQU	 %00110111 ;setup to monitor both voltages
				;          ^^^^^^^ ;continuous conversion	  
				;      SC--+|||||| ;sample multiple channels	   
				;    SCAN---+||||| ;start sequence withy channel 7 
				;    MULT----+|||| ;sample multiple channels       
				;      CD-----+||| 
				;      CC------+|| 
				;      CB-------+| 
				;      CA--------+
#else				
				;Monitor VBAT only
VMON_VBAT_CONVERSION		EQU	$01
VMON_VUSB_CONVERSION		EQU	$00
VMON_VBAT_ATDDR			EQU	ATDDR0
VMON_ATDCTL5_CONFIG		EQU	 %00100000 ;setup to monitor VBAT only 
				;          ^^^^^^^ ;continuous conversion      
				;      SC--+|||||| ;only sample channel 0       
				;    SCAN---+||||| 
				;    MULT----+|||| 
				;      CD-----+||| 
				;      CC------+|| 
				;      CB-------+| 
				;      CA--------+
#endif
#else
#ifdef	VMON_VUSB
				;Monitor VUSB only
VMON_VBAT_CONVERSION		EQU	$00
VMON_VUSB_CONVERSION		EQU	$01
VMON_VUSB_ATDDR			EQU	ATDDR0
VMON_ATDCTL5_CONFIG		EQU	 %00100111 ;setup to monitor VUSB only 
				;          ^^^^^^^ ;continuous conversion      
				;      SC--+|||||| ;only sample channel 7       
				;    SCAN---+||||| 
				;    MULT----+|||| 
				;      CD-----+||| 
				;      CC------+|| 
				;      CB-------+| 
				;      CA--------+
#endif				
#endif				
				
;Monitor status			
;--------------			
VMON_STATUS			EQU	 ATDCMPHTL ;1=LV condition, 0=HV condition
VMON_STATUS_VBAT		EQU	 VMON_VBAT_CONVERSION
VMON_STATUS_VUSB		EQU	 VMON_VUSB_CONVERSION
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef VMON_VARS_START_LIN
				ORG 	VMON_VARS_START, VMON_VARS_START_LIN
#else				
				ORG 	VMON_VARS_START
VMON_VARS_START_LIN		EQU	@			
#endif				
				
VMON_VARS_END			EQU	*
VMON_VARS_END_LIN		EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	VMON_INIT, 0
#ifdef	VMON_VBAT
#ifdef	VMON_VUSB
				;Monitor VBAT and VUSB
				MOVW	#((VMON_ATDCTL0_CONFIG<<8)|VMON_ATDCTL1_CONFIG), ATDCTL1
				MOVW	#((VMON_ATDCTL2_CONFIG<<8)|VMON_ATDCTL3_CONFIG), ATDCTL2
				MOVB	#VMON_ATDCTL4_CONFIG, ATDCTL4
				MOVB	#(VMON_VBAT_CONVERSION|VMON_VUSB_CONVERSION), ATDCMPEL
				MOVB	#(VMON_VBAT_CONVERSION|VMON_VUSB_CONVERSION), ATDCMPHTL
				MOVW	#VMON_VUSB_UPPER_THRESHOLD, ATDDR0
				MOVW	#VMON_VBAT_UPPER_THRESHOLD, ATDDR1
				;Start ATD conversions
				MOVB	#VMON_ATDCTL5_CONFIG, ATDCTL5
#else				
				;Monitor VBAT only
				MOVB	#VMON_ATDCTL1_CONFIG, ATDCTL1
				MOVW	#((VMON_ATDCTL2_CONFIG<<8)|VMON_ATDCTL3_CONFIG), ATDCTL2
				MOVB	#VMON_ATDCTL4_CONFIG, ATDCTL4
				MOVB	#VMON_VBAT_CONVERSION, ATDCMPEL
				MOVB	#VMON_VBAT_CONVERSION, ATDCMPHTL
				MOVW	#VMON_VBAT_UPPER_THRESHOLD, ATDDR0
				;Start ATD conversions
				MOVB	#VMON_ATDCTL5_CONFIG, ATDCTL5
#endif				
#else				
#ifdef	VMON_VUSB		
				;Monitor VUSB only
				MOVB	#VMON_ATDCTL1_CONFIG, ATDCTL1
				MOVW	#((VMON_ATDCTL2_CONFIG<<8)|VMON_ATDCTL3_CONFIG), ATDCTL2
				MOVB	#VMON_ATDCTL4_CONFIG, ATDCTL4
				MOVB	#VMON_VUSB_CONVERSION, ATDCMPEL
				MOVB	#VMON_VUSB_CONVERSION, ATDCMPHTL
				MOVW	#VMON_VUSB_UPPER_THRESHOLD, ATDDR0
				;Start ATD conversions
				MOVB	#VMON_ATDCTL5_CONFIG, ATDCTL5
#endif
#endif
#emac

;#Wait for first connversion results
;#----------------------------------
#macro	VMON_WAIT_FOR_1ST_RESULTS, 0
#ifdef VMON_ANY	
LOOP				SEI	
				BRSET	ATDSTAT0, #SCF, DONE 			;Conversion sequence complete
				ISTACK_WAIT
				JOB	LOOP
DONE				CLI
#endif
#emac

;#Conditional branches
;#--------------------
#ifdef	VMON_VBAT
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
#endif

#ifdef	VMON_VUSB
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
#endif
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef VMON_CODE_START_LIN
				ORG 	VMON_CODE_START, VMON_CODE_START_LIN
#else				
				ORG 	VMON_CODE_START
VMON_CODE_START_		EQU	@			
#endif				
				
;#ADC Compare IS		
;#--------------		
#ifdef	VMON_ANY		
VMON_ISR			EQU	*
#ifdef	VMON_VUS		
				;Check VUSB
				;==========
				BRCLR	ATDSTAT2,  #VMON_VUSB_CONVERSION, VMON_ISR_2 	;skip if state hasn't changed
				BRSET	ATDCMPHTL, #VMON_VUSB_CONVERSION, VMON_ISR_1 	;HV condition detected
				;VUSB LV condition detected
				BSET	ATDCMPHTL, #VMON_VUSB_CONVERSION   		;VUSB must be higher than threshold
				MOVW	#VMON_VUSB_UPPER_THRESHOLD, VMON_VUSB_ATDDR	;set upper threshold value
				;VUSB LV action
#ifmac	VMON_VUSB_LVACTION
				VMON_VUSB_LVACTION
#endif				
				JOB	VMON_ISR_2					;VUSB check done
				;HV condition detected
VMON_ISR_1			BCLR	ATDCMPHTL, #VMON_VUSB_CONVERSION   		;VUSB must be lower (or same) than threshold
				MOVW	#VMON_VUSB_LOWER_THRESHOLD, VMON_VUSB_ATDDR	;set upper threshold value
#ifmac	VMON_VUSB_HVACTION			
				VMON_VUSB_HVACTION
#endif				
				;VUSB check done
VMON_ISR_2			EQU	*
#endif				
#ifdef	VMON_VBAT_ON		
				;Check VBAT
				;==========
				BRCLR	ATDSTAT2,  #VMON_VBAT_CONVERSION, VMON_ISR_3 	;skip if state hasn't changed
				BRSET	ATDCMPHTL, #VMON_VBAT_CONVERSION, VMON_ISR_4 	;HV condition detected
				;LV condition detected
				BSET	ATDCMPHTL, #VMON_VBAT_CONVERSION   		;VBAT must be higher than threshold
				MOVW	#VMON_VBAT_UPPER_THRESHOLD, VMON_VBAT_ATDDR	;set upper threshold value
#ifmac	VMON_VBAT_LVACTION			
				VMON_VBAT_LVACTION
#endif				
				JOB	VMON_ISR_4					;VBAT check done
				;HV condition detected
VMON_ISR_3			BCLR	ATDCMPHTL, #VMON_VBAT_CONVERSION   		;VBAT must be lower (or same) than threshold
				MOVW	#VMON_VBAT_LOWER_THRESHOLD, VMON_VBAT_ATDDR	;set upper threshold value
#ifmac	VMON_VBAT_HVACTION			
				VMON_VBAT_HVACTION
#endif				
				;VBAT check done
VMON_ISR_4			EQU	*
#endif				
				ISTACK_RTI
#endif				
				
VMON_CODE_END			EQU	*	
VMON_CODE_END_LIN		EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef VMON_TABS_START_LIN
				ORG 	VMON_TABS_START, VMON_TABS_START_LIN
#else				
				ORG 	VMON_TABS_START
VMON_TABS_START_LIN		EQU	@			
#endif				
				
VMON_TABS_END			EQU	*	
VMON_TABS_END_LIN		EQU	@	
#endif
