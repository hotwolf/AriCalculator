#ifndef	TIM_COMPILED 
#define	TIM_COMPILED
;###############################################################################
;# S12CBase - TIM - Timer Driver                                               #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
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
;#    The module controls the shared timer module.                             #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    February 22, 2012                                                        #
;#      - Back-ported LFBDMPGMR updates                                        #
;#    November 14, 2012                                                        #
;#      - Total redo                                                           #
;#    January 15, 2016                                                         #
;#      - Implemented configurable initialization                              #
;#    June 23, 2016                                                            #
;#      - Added support for multiple TIM instances                             #
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
#ifndef	TIM_DIV_OFF
#ifndef	TIM_DIV_2
#ifndef	TIM_DIV_4
#ifndef	TIM_DIV_8
#ifndef	TIM_DIV_16
#ifndef	TIM_DIV_32
#ifndef	TIM_DIV_64
#ifndef	TIM_DIV_128
TIM_DIV_OFF		EQU	1 	;default no clock divider
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif

;OCPD checks (only disable timer if all OCPD bits are set)
;---------------------------------------------------------
#ifndef	TIM_OCPD_CHECK_ON
#ifndef	TIM_OCPD_CHECK_OFF
TIM_OCPD_CHECK_OFF	EQU	1 		;disable OCPD checks
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Timer frequency
;---------------
#ifdef	TIM_DIV_OFF
TIM_FREQ		EQU	CLOCK_BUS_FREQ 		;frequency in Hz
#endif
#ifdef	TIM_DIV_2
TIM_FREQ		EQU	CLOCK_BUS_FREQ/2 	;frequency in Hz
#endif
#ifdef	TIM_DIV_4
TIM_FREQ		EQU	CLOCK_BUS_FREQ/4 	;frequency in Hz
#endif
#ifdef	TIM_DIV_8
TIM_FREQ		EQU	CLOCK_BUS_FREQ/8 	;frequency in Hz
#endif
#ifdef	TIM_DIV_16
TIM_FREQ		EQU	CLOCK_BUS_FREQ/16 	;frequency in Hz
#endif
#ifdef	TIM_DIV_32
TIM_FREQ		EQU	CLOCK_BUS_FREQ/32 	;frequency in Hz
#endif
#ifdef	TIM_DIV_64
TIM_FREQ		EQU	CLOCK_BUS_FREQ/64 	;frequency in Hz
#endif
#ifdef	TIM_DIV_128
TIM_FREQ		EQU	CLOCK_BUS_FREQ/128 	;frequency in Hz
#endif

;Register offsets
;-----------------
TIOS_OFFSET		EQU	$0000
;TCFORC_OFFSET		EQU	$0001
;TOC7M_OFFSET		EQU	$0002
;TOC7D_OFFSET		EQU	$0003
TCNT_OFFSET		EQU	$0004
TSCR1_OFFSET		EQU	$0006
;TTOV_OFFSET		EQU	$0007
TCTL1_OFFSET		EQU	$0008
TCTL2_OFFSET		EQU	$0009
TCTL3_OFFSET		EQU	$000A
TCTL4_OFFSET		EQU	$000B
TIE_OFFSET		EQU	$000C
TSCR2_OFFSET		EQU	$000D
TFLG1_OFFSET		EQU	$000E
TFLG2_OFFSET		EQU	$000F
TC0_OFFSET		EQU	$0010
;TC1_OFFSET		EQU	$0012
;TC2_OFFSET		EQU	$0014
;TC3_OFFSET		EQU	$0016
;TC4_OFFSET		EQU	$0018
;TC5_OFFSET		EQU	$001A
;TC6_OFFSET		EQU	$001C
;TC7_OFFSET		EQU	$001E
;PACTL_OFFSET		EQU	$0020
;PAFLG_OFFSET		EQU	$0021
;PACNT_OFFSET		EQU	$0022
OCPD_OFFSET		EQU	$002C
	
###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef	TIM_VARS_START_LIN
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
;#Default initialization macro
#macro	TIM_INIT, 0
#ifdef	TIM_TIOS_INIT
			;TIOS 
			MOVB	#TIM_TIOS_INIT, TIOS

#endif
#ifdef	TIM_TOCMD_INIT
			;TOC7M/TOC7D
			MOVW	#TIM_TOCMD_INIT, TOCM
#endif
#ifdef 	TIM_TTOV_INIT
			;TTOV 
			MOVB	#TIM_TTOV_INIT, TTOV
#endif
#ifdef	TIM_TCTL12_INIT
			;TCTL1/TCTL2
			MOVW	#TIM_TCTL12_INIT, TCTL1
#endif
#ifdef	TIM_TCTL34_INIT
			;TCTL3/TCTL4
			MOVW	#TIM_TCTL34_INIT, TCTL3
#endif
#ifdef	TIM_DIV_2
			;TSCR2
			MOVB	#$01, TSCR2 		;timer clock = bus clock/2
#endif
#ifdef	TIM_DIV_4
			;TSCR2
			MOVB	#$02, TSCR2 		;timer clock = bus clock/4
#endif
#ifdef	TIM_DIV_8
			;TSCR2
			MOVB	#$03, TSCR2 		;timer clock = bus clock/8
#endif
#ifdef	TIM_DIV_16
			;TSCR2
			MOVB	#$04, TSCR2 		;timer clock = bus clock/16
#endif
#ifdef	TIM_DIV_32
			;TSCR2
			MOVB	#$05, TSCR2 		;timer clock = bus clock/32
#endif
#ifdef	TIM_DIV_64
			;TSCR2
			MOVB	#$06, TSCR2 		;timer clock = bus clock/64
#endif
#ifdef	TIM_DIV_128
			;TSCR2
			MOVB	#$07, TSCR2 		;timer clock = bus clock/128
#endif
#ifdef	OCPD_CHECK_ON
			;OCPD
			MOVW	#$FF, OCPD 		;disconnect all IO
#endif	
#emac
	
;#Instance "TIM0"
#macro	TIM_INIT_TIM0, 0
#ifdef	TIM_TIM0_TIOS_INIT
			;TIOS 
			MOVB	#TIM_TIM0_TIOS_INIT, TIM0_TIOS

#endif
#ifdef	TIM_TIM0_TOCMD_INIT
			;TOC7M/TOC7D
			MOVW	#TIM_TIM0_TOCMD_INIT, TIM0_TOCM
#endif
#ifdef	TIM_TIM0_TTOV_INIT
			;TTOV 
			MOVB	#TIM_TIM0_TTOV_INIT, TIM0_TTOV
#endif
#ifdef	TIM_TIM0_TCTL12_INIT
			;TCTL1/TCTL2
			MOVW	#TIM_TIM0_TCTL12_INIT, TIM0_TCTL1
#endif
#ifdef	TIM_TIM0_TCTL34_INIT
			;TCTL3/TCTL4
			MOVW	#TIM_TIM0_TCTL34_INIT, TIM0_TCTL3
#endif
#ifdef	TIM_DIV_2
			;TSCR2
			MOVB	#$01, TIM0_TSCR2 	;timer clock = bus clock/2
#endif
#ifdef	TIM_DIV_4
			;TSCR2
			MOVB	#$02, TIM0_TSCR2 	;timer clock = bus clock/4
#endif
#ifdef	TIM_DIV_8
			;TSCR2
			MOVB	#$03, TIM0_TSCR2 	;timer clock = bus clock/8
#endif
#ifdef	TIM_DIV_16
			;TSCR2
			MOVB	#$04, TIM0_TSCR2 	;timer clock = bus clock/16
#endif
#ifdef	TIM_DIV_32
			;TSCR2
			MOVB	#$05, TIM0_TSCR2 	;timer clock = bus clock/32
#endif
#ifdef	TIM_DIV_64
			;TSCR2
			MOVB	#$06, TIM0_TSCR2 	;timer clock = bus clock/64
#endif
#ifdef	TIM_DIV_128
			;TSCR2
			MOVB	#$07, TIM0_TSCR2 	;timer clock = bus clock/128
#endif
#ifdef	TIM_OCPD_CHECK_ON
			;OCPD
			MOVW	#$FF, TIM0_OCPD 	;disconnect all IO
#endif	
#emac
	
;#Instance "TIM1"
#macro	TIM_INIT_TIM1, 0
#ifdef	TIM_TIM1_TIOS_INIT
			;TIOS 
			MOVB	#TIM_TIM1_TIOS_INIT, TIM1_TIOS

#endif
#ifdef	TIM_TIM1_TOCMD_INIT
			;TOC7M/TOC7D
			MOVW	#TIM_TIM1_TOCMD_INIT, TIM1_TOCM
#endif
#ifdef	TIM_TIM1_TTOV_INIT
			;TTOV 
			MOVB	#TIM_TIM1_TTOV_INIT, TIM1_TTOV
#endif
#ifdef	TIM_TIM1_TCTL12_INIT
			;TCTL1/TCTL2
			MOVW	#TIM_TIM1_TCTL12_INIT, TIM1_TCTL1
#endif
#ifdef	TIM_TIM1_TCTL34_INIT
			;TCTL3/TCTL4
			MOVW	#TIM_TIM1_TCTL34_INIT, TIM1_TCTL3
#endif
#ifdef	TIM_DIV_2
			;TSCR2
			MOVB	#$01, TIM1_TSCR2 	;timer clock = bus clock/2
#endif
#ifdef	TIM_DIV_4
			;TSCR2
			MOVB	#$02, TIM1_TSCR2 	;timer clock = bus clock/4
#endif
#ifdef	TIM_DIV_8
			;TSCR2
			MOVB	#$03, TIM1_TSCR2 	;timer clock = bus clock/8
#endif
#ifdef	TIM_DIV_16
			;TSCR2
			MOVB	#$04, TIM1_TSCR2 	;timer clock = bus clock/16
#endif
#ifdef	TIM_DIV_32
			;TSCR2
			MOVB	#$05, TIM1_TSCR2 	;timer clock = bus clock/32
#endif
#ifdef	TIM_DIV_64
			;TSCR2
			MOVB	#$06, TIM1_TSCR2 	;timer clock = bus clock/64
#endif
#ifdef	TIM_DIV_128
			;TSCR2
			MOVB	#$07, TIM1_TSCR2 	;timer clock = bus clock/128
#endif
#ifdef	TIM_OCPD_CHECK_ON
			;OCPD
			MOVW	#$FF, TIM1_OCPD 	;disconnect all IO
#endif	
#emac

;#Instance "TIM"
#macro	TIM_INIT_TIM, 0
#ifdef	TIM_TIM_TIOS_INIT
			;TIOS 
			MOVB	#TIM_TIM_TIOS_INIT, TIM_TIOS

#endif
#ifdef	TIM_TIM_TOCMD_INIT
			;TOC7M/TOC7D
			MOVW	#TIM_TIM_TOCMD_INIT, TIM_TOCM
#endif
#ifdef	TIM_TIM_TTOV_INIT
			;TTOV 
			MOVB	#TIM_TIM_TTOV_INIT, TIM_TTOV
#endif
#ifdef	TIM_TIM_TCTL12_INIT
			;TCTL1/TCTL2
			MOVW	#TIM_TIM_TCTL12_INIT, TIM_TCTL1
#endif
#ifdef	TIM_TIM_TCTL34_INIT
			;TCTL3/TCTL4
			MOVW	#TIM_TIM_TCTL34_INIT, TIM_TCTL3
#endif
#ifdef	TIM_DIV_2
			;TSCR2
			MOVB	#$01, TIM_TSCR2 	;timer clock = bus clock/2
#endif
#ifdef	TIM_DIV_4
			;TSCR2
			MOVB	#$02, TIM_TSCR2 	;timer clock = bus clock/4
#endif
#ifdef	TIM_DIV_8
			;TSCR2
			MOVB	#$03, TIM_TSCR2 	;timer clock = bus clock/8
#endif
#ifdef	TIM_DIV_16
			;TSCR2
			MOVB	#$04, TIM_TSCR2 	;timer clock = bus clock/16
#endif
#ifdef	TIM_DIV_32
			;TSCR2
			MOVB	#$05, TIM_TSCR2 	;timer clock = bus clock/32
#endif
#ifdef	TIM_DIV_64
			;TSCR2
			MOVB	#$06, TIM_TSCR2 	;timer clock = bus clock/64
#endif
#ifdef	TIM_DIV_128
			;TSCR2
			MOVB	#$07, TIM_TSCR2 	;timer clock = bus clock/128
#endif
#ifdef	TIM_OCPD_CHECK_ON
			;OCPD
			MOVW	#$FF, TIM_OCPD 		;disconnect all IO
#endif	
#emac
	
;#Instance "ECT"
#macro	TIM_INIT_ECT, 0
#ifdef	TIM_ECT_TIOS_INIT
			;TIOS 
			MOVB	#TIM_ECT_TIOS_INIT, ECT_TIOS

#endif
#ifdef	TIM_ECT_TOCMD_INIT
			;TOC7M/TOC7D
			MOVW	#TIM_ECT_TOCMD_INIT, ECT_TOCM
#endif
#ifdef	TIM_ECT_TTOV_INIT
			;TTOV 
			MOVB	#TIM_ECT_TTOV_INIT, ECT_TTOV
#endif
#ifdef	TIM_ECT_TCTL12_INIT
			;TCTL1/TCTL2
			MOVW	#TIM_ECT_TCTL12_INIT, ECT_TCTL1
#endif
#ifdef	TIM_ECT_TCTL34_INIT
			;TCTL3/TCTL4
			MOVW	#TIM_ECT_TCTL34_INIT, ECT_TCTL3
#endif
#ifdef	TIM_DIV_2
			;TSCR2
			MOVB	#$01, ECT_TSCR2 	;timer clock = bus clock/2
#endif
#ifdef	TIM_DIV_4
			;TSCR2
			MOVB	#$02, ECT_TSCR2 	;timer clock = bus clock/4
#endif
#ifdef	TIM_DIV_8
			;TSCR2
			MOVB	#$03, ECT_TSCR2 	;timer clock = bus clock/8
#endif
#ifdef	TIM_DIV_16
			;TSCR2
			MOVB	#$04, ECT_TSCR2 	;timer clock = bus clock/16
#endif
#ifdef	TIM_DIV_32
			;TSCR2
			MOVB	#$05, ECT_TSCR2 	;timer clock = bus clock/32
#endif
#ifdef	TIM_DIV_64
			;TSCR2
			MOVB	#$06, ECT_TSCR2 	;timer clock = bus clock/64
#endif
#ifdef	TIM_DIV_128
			;TSCR2
			MOVB	#$07, ECT_TSCR2 	;timer clock = bus clock/128
#endif
#ifdef	TIM_OCPD_CHECK_ON
			;OCPD
			MOVW	#$FF, ECT_OCPD 		;disconnect all IO
#endif	
#emac

;#Enable multiple timer channels
; args: 1: start address of register space
;       2: channels  mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_EN, 2
			MOVB	#\2, \1+TFLG1_OFFSET 		;clear interrupt flags
			BSET	\1+TIE_OFFSET, #\2		;enable interrupts
			MOVB	#(TEN|TSFRZ), \1+TSCR1_OFFSET	;enable timer
#emac

;#Enable one timer channel
; args: 1: start address of register space
;       2: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_EN, 2
			TIM_MULT_EN	\1, (1<<\2)
#emac

;#Enable the timer counter only
; args: 1: start address of register space
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CNT_EN, 1
			MOVB	#(TEN|TSFRZ), \1+TSCR1_OFFSET	;enable timer
#emac
	
;#Disable the timer counter
; args: 1: start address of register space
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CNT_DIS, 1
			TST	\1+TIE_OFFSET
			BNE	DONE
#ifdef	TIM_OCPD_CHECK_ON
			BRSET	\1+OCPD_OFFSET, #$FF, DISABLE
			JOB	DONE
#endif
DISABLE			CLR	\1+TSCR1_OFFSET
DONE			EQU	*
#emac
	
;#Disable multiple timer channels
; args: 1: start address of register space
;       2: channel mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_DIS, 2
			BCLR	\1+TIE_OFFSET, #\2
			BNE	DONE
#ifdef	TIM_OCPD_CHECK_ON
			BRSET	\1+OCPD_OFFSET, #$FF, DISABLE
			JOB	DONE
#endif
DISABLE			CLR	\1+TSCR1_OFFSET
DONE			EQU	*
#emac

;#Disable one timer channel
; args: 1: start address of register space
;       2: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_DIS, 2
			TIM_MULT_DIS	\1, (1<<\2)
#emac

;#Branch if channel is enabled
; args: 1: start address of register space
;       2: channel number
;       3: branch address
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_BREN, 3
			BRSET	\1+TIE_OFFSET, #(1<<\2), \3
#emac

;#Branch if channel is disnabled
; args: 1: start address of register space
;       2: channel number
;       3: branch address
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_BRDIS, 3
			BRCLR	\1+TIE_OFFSET, #(1<<\2), \3
#emac

;#Clear multiple interrupt flags
; args: 1: start address of register space
;       2: channel mask
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_MULT_CLRIF, 2
			MOVB	#\2, \1+TFLG1_OFFSET
#emac

;#Clear one interrupt flag
; args: 1: start address of register space
;       2: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_CLRIF, 2
			TIM_MULT_CLRIF	\1, (1<<\2)
#emac
	
;#Setup timer delay
; args: 1: start address of register space
;       2: channel number
;       3: delay (in timer counts)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY, 3
			LDD	#\3		
			ADDD	\1+TCNT_OFFSET			;RPO
			STD	(\1+TC0+OFFSET+(2*\2))		;PWO
#emac

;#Setup timer delay
; args: 1: start address of register space
;       2: channel number
;       D: delay (in bus cycles)
; SSTACK: none
;         X, and Y are preserved 
#macro	TIM_SET_DLY_D, 2
			ADDD	\1+TCNT_OFFSET 			;RPO
			STD	(\1+TC0_OFFSET+(2*\2))		;PWO
#emac
	
;#Do nothing
; args: 1: start address of register space
;       2: channel number
; SSTACK: none
;         X, Y, and D are preserved 
#macro	TIM_NOP, 2
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef	TIM_CODE_START_LIN
			ORG 	TIM_CODE_START, TIM_CODE_START_LIN
#else
			ORG 	TIM_CODE_START
#endif

TIM_CODE_END		EQU	*
TIM_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef	TIM_TABS_START_LIN
			ORG 	TIM_TABS_START, TIM_TABS_START_LIN
#else
			ORG 	TIM_TABS_START
#endif	

TIM_TABS_END		EQU	*
TIM_TABS_END_LIN	EQU	@
#endif
