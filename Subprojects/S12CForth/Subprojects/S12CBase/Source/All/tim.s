#ifndef	TIM_COMPILED 
#define	TIM_COMPILED
;###############################################################################
;# S12CBase - TIM - Timer Driver                                               #
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
;#    The module controls the timer. The eight timer channes are used as       #
;#    follows:                                                                 #
;#      IC0:     SCI baud rate detection (capture posedges on RX pin)          #
;#      IC1:     SCI baud rate detection (capture negedges on RX pin)          #
;#      OC2:     SCI baud rate detection (timeout)                             #
;#      OC3:     SCI (timeout)                                                 #
;#      OC4:     delay driver                                                  #
;#      OC5:     unasigned                                                     #
;#      OC6:     unasigned                                                     #
;#      OC7:     unasigned                                                     #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    February 22, 2012                                                        #
;#      - Back-ported LFBDMPGMR updates                                        #
;#    November 14, 2012                                                        #
;#      - Total redo                                                           #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Clock divider
;-------------
#ifndef	TIM_DIV2_ON
#ifndef	TIM_DIV2_OFF
TIM_DIV2_OFF		EQU	1 	;default no clock divider
#endif
#endif

; OCPD checks (only disable timer if all OCPD bits are set)
;-------------
#ifndef	TIM_OCPD_CHECK_ON
#ifndef	TIM_OCPD_CHECK_OFF
TIM_OCPD_CHECK_OFF	EQU	1 		;disable OCPD checks
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#SCI channels defaults
TIM_SCI			EQU	$0F	;all channels		 
TIM_SCIBDPE		EQU	$01	;posedge/toggle detection
TIM_SCIBDNE		EQU	$02	;negedge detection 
TIM_SCIBDTO		EQU	$04	;Baud rate detection
TIM_SCITO		EQU	$08	;XON/XOFF reminders

;#BDM channel defaults	
TIM_BDM			EQU	$E0	;all channels		  
TIM_BDMPE		EQU	$20	;posedge/toggle detection 
TIM_BDMNE		EQU	$40	;negedge detection  
TIM_BDMTO		EQU	$80	;SCI bug workaround 
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef TIM_VARS_START_LIN
			ORG 	TIM_VARS_START, TIM_VARS_START_LIN
#else
			ORG 	TIM_VARS_START
TIM_VARS_START_LIN	EQU	@			
#endif	

TIM_VARS_END		EQU	*
TIM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	TIM_INIT, 0		 ;7 6 5 4 3 2 1 0
			;MOVB	#%1_1_1_1_1_1_0_0, TIOS 	;default setup
			;MOVB	#%0_0_0_0_0_0_0_0, TIOS 	;keep at zero, for configuration with BSET
				 ;      D S S S S		;  0=input capture
				 ;      E C C C C		;  1=output compare
				 ;      L I I I	I
				 ;      A B B B	B
				 ;      Y D D D	D
				 ;        T N P	P
				 ;        O E E	E
						
			;CFORC			
			;OC7M 			
						
			 	 ;7 6 5 4 3 2 1 0
			;MOVB	#%0_0_0_0_0_0_0_0, TOC7D	;default setup
			;MOVB	#%0_0_0_0_0_0_0_0, TOC7D	;keep at zero, for configuration with BSET
				 ;      D S S S S
				 ;      E C C C C
				 ;      L I I I I
				 ;      A T B B B
				 ;      Y O D D D
				 ;          T N P
				 ;          O E E

			;TCNT 

#ifdef	TIM_DIV2_ON
			MOVB	#$01, TSCR2 			;run on half bus frequency
#endif

			;TTOV 
	
				 ;7 6 5 4 3 2 1 0
			;MOVW	#%0000000000000000, TCTL1 	;keep at zero, for configuration with BSET
				 ;      D S S S S		;  00=no OC
				 ;      E C C C C		;  01=toggle
				 ;      L I I I I		;  10=clear
				 ;      A T B B B		;  11=set
				 ;      Y O D D D
				 ;          T N P
				 ;          O E E

			 	 ;7 6 5 4 3 2 1 0
			;MOVW	#%0000000000000000, TCTL3 	;keep at zero, for configuration with BSET
				 ;      D S S S S		;  00=no capture	
				 ;      E C C C C		;  01=posedge
				 ;      L I I I I		;  10=negedge
				 ;      A T B B B		;  11=any edge
				 ;      Y O D D D
				 ;          T N P
				 ;          O E E

			;TIE
			;TSCR2
			;TFLG1
			;TFLG2
			;TC0 ... TC7
			;PACTL
			;PAFLG
			;PACN0 ... PACN3

#ifdef	TIM_OCPD_CHECK_ON
			MOVW	#$FF, OCPD 			;disconnect all IO
#endif	
#emac

;#Enable multiple timer channels
; args: 1: channels  mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_EN, 1
			MOVB	#\1, TFLG1 			;clear interrupt flags
			BSET	TIE, #\1			;enable interrupts
			MOVB	#(TEN|TSFRZ), TSCR1		;enable timer
#emac

;#Enable one timer channel
; args: 1: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_EN, 1
			TIM_MULT_EN	($1<<\1)
#emac

;#Enable the timer counter only
; args: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CNT_EN, 0
			MOVB	#(TEN|TSFRZ), TSCR1		;enable timer
#emac
	
;#Disable multiple timer channels
; args: 1: channel mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_DIS, 1
			BCLR	TIE, #\1
			BNE	DONE
#ifdef	TIM_OCPD_CHECK_ON
			BRSET	OCPD, #$FF, DISABLE
#endif			JOB	DONE
DISABLE			CLR	TSCR1
DONE			EQU	*
#emac

;#Disable one timer channel
; args: 1: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_DIS, 1
			TIM_MULT_DIS	(1<<\1)
#emac

;#Disable the timer counter
; args: none
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CNT_DIS, 0
			TST	TIE
			BNE	DONE
#ifdef	TIM_OCPD_CHECK_ON
			BRSET	OCPD, #$FF, DISABLE
#endif			JOB	DONE
DISABLE			CLR	TSCR1
DONE			EQU	*
#emac
	
;#Clear multiple interrupt flags
; args: 1: channel mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_CLRIF, 1
			MOVB	#\1, TFLG1
#emac

;#Clear one interrupt flag
; args: 1: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CLRIF, 1
			TIM_MULT_CLRIF	(1<<\1)
#emac

	
;#Setup timer delay
; args: 1: channel number
;       2: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY_IMM, 2
#ifdef	TIM_DIV2_ON
			LDD	#(\2>>1)
#else
			LDD	#\2		
#endif
			ADDD	TCNT				;RPO
			STD	(TC0+(2*\1))			;PWO
#emac

;#Setup timer delay
; args: 1: channel number
;       D: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY_D, 1
#ifdef	TIM_DIV2_ON
			LSRD
#endif
			ADDD	TCNT
			STD	(TC0+(2*\1))
#emac

;#Setup timer delay if timer channel is inactive
; args: 1: channel number
;       D: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_START_DLY, 1
			BRSET	TIE, #(1<<\1), DONE 		;skip if timer channel is already active
			TIM_SET_DLY	\1			
			BSET	TIE, #(1<<\1)			;enable interrupts
			MOVB	#(TEN|TSFRZ), TSCR1		;enable timer
DONE			EQU		*
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef TIM_CODE_START_LIN
			ORG 	TIM_CODE_START, TIM_CODE_START_LIN
#else
			ORG 	TIM_CODE_START
#endif

TIM_CODE_END		EQU	*
TIM_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef TIM_TABS_START_LIN
			ORG 	TIM_TABS_START, TIM_TABS_START_LIN
#else
			ORG 	TIM_TABS_START
#endif	

TIM_TABS_END		EQU	*
TIM_TABS_END_LIN	EQU	@
#endif
