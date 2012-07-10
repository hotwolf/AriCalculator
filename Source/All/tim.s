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
;#      IC0:     SCI (capture posedges on RX pin)                              #
;#      IC1:     SCI (capture negedges on RX pin)                              #
;#      OC2:     unused                                                        #
;#      OC3:     unused                                                        #
;#      OC4:     unused                                                        #
;#      IC5:     BDM (capture posedges on BKGD pin)                            #
;#      IC6/OC5: BDM (capture negedges on BKGD pin/toggle BKGD pin)            #
;#      OC7:     BDM (toggle BKGD pin/timeouts)                                #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    February 22, 2012                                                        #
;#      - Back-ported LFBDMPGMR updates                                        #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
TIM_SCI			EQU	$01 	;indicates that the timer is currently
					; by the SCI 
TIM_BDM			EQU	$02 	;indicates that the timer is currently
					; by the BDM
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	TIM_VARS_START
TIM_BUSY		DS	1 	;flags to indicate who is using the timer
TIM_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	TIM_INIT, 0		 ;7 6 5 4 3 2 1 0
			MOVB	#%1_0_0_1_1_1_0_0, TIOS 	;select input capture (0)
				 ;B B B       S S 		; or output compare (1) feature
				 ;D D D       C C
				 ;M M M       I I
				 ;T N P       N P
				 ;O E E       E E

				;CFORC
				;OC7M 

				;7 6 5 4 3 2 1 0
			;MOVB	#%0_1_0_0_0_0_0_0, TOC7D	;OC7 output compares drive
				 ;B B B       S S 		; posedges on TC6 	
				 ;D D D       C C
				 ;M M M       I I
				 ;T N P       N P
				 ;O E E       E E

				;TCNT 
				;TSCR1 
				;TTOV 
	
				 ;7 6 5 4 3 2 1 0
			;MOVW	#%0000000000000000, TCTL1 	;OC6 output compares drive
				 ;B B B       S S		; negedges (=10) on TC6
				 ;D D D       C C
				 ;M M M       I I
				 ;T N P       N P
				 ;O E E       E E

			 	 ;7 6 5 4 3 2 1 0
			;MOVW	#%0000010000001000, TCTL3 	;set capture edges
				 ;B B B       S S	
				 ;D D D       C C
				 ;M M M       I I
				 ;T N P       N P
				 ;O E E       E E

			;MOVB	#(VEC_TC2&$FE), HPRIO ;TC2 gets highest interrupt priority

				;TIE
				;TSCR2
				;TFLG1
				;TFLG2
				;TC0 ... TC7
				;PACTL
				;PAFLG
				;PACN0 ... PACN3
#emac

;#Enable timer
; args: 1. module (TIM_SCI or TIM_BDM)
#macro	TIM_ENABLE, 1
	BSET	TIM_BUSY, #\1
	MOVB	#(TEN|TSFRZ), TSCR1	
#emac

;#Disable timer
; args: 1. module (TIM_SCI or TIM_BDM)
#macro	TIM_DISABLE, 1
	BCLR	TIM_BUSY, #\1
	BNE	DONE
	CLR	TSCR1
DONE	EQU	*
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	TIM_CODE_START
TIM_CODE_END		EQU	*

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	TIM_TABS_START
TIM_TABS_END		EQU	*


