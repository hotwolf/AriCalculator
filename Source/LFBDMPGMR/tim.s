;###############################################################################
;# S12CBase - TIM - Timer Driver (LFBDMPGMR port)                              #
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
;#      IC0:     SCI (capture edges on RX pin)                                 #
;#      OC1:     SCI (timeout)                                                 #
;#      OC2:     unused                                                        #
;#      OC3:     unused                                                        #
;#      OC4:     unused                                                        #
;#      OC5:     BDM (timeout)                                                 #
;#      IC6/OC5: BDM (capture edges on BKGD pin/toggle BKGD pin)               #
;#      IC6/OC7: BDM (capture edges on RESET pin/toggle RESET pin)             #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
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
					; in use by the SCI 
TIM_BDM			EQU	$02 	;indicates that the timer is currently
					; in use by the BDM
	
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
			MOVB	#%0_0_1_1_1_1_1_0, TIOS 	;select input capture (0)
				 ;B B B       S S 		; or output compare (1) feature
				 ;D D D       C C
				 ;M M M       I I
				 ;| | |       | |
				 ;B R T       T R 
				 ;K E O       O X 
				 ;G S            
				 ;D E            
				 ;  T             

				;CFORC
				;OC7M 
				;OC7D 
				;TCNT 
				;TSCR1 
				;TTOV 
	
				 ;7 6 5 4 3 2 1 0
			MOVW	#%0000000000000000, TCTL1 	;disable all OC actions
				 ;B B B       S S 	        ;00 - no compare
				 ;D D D       C C               ;01 - toggle
				 ;M M M       I I		;10 - clear
				 ;| | |       | |		;11 - set
				 ;B R T       T R 
				 ;K E O       O X 
				 ;G S            
				 ;D E            
				 ;  T             

			 	 ;7 6 5 4 3 2 1 0
			MOVW	#%1011000000000011, TCTL3 	;set capture edges
				 ;B B B       S S 		;00 - disable 
				 ;D D D       C C		;01 - posedge
				 ;M M M       I I		;10 - negedge
				 ;| | |       | |		;11 - any edge
				 ;B R T       T R 
				 ;K E O       O X 
				 ;G S            
				 ;D E            
				 ;  T             

				;TIE

				MOVB	#$01, TSCR2 		;set prescaler (divide by 2)

				;TFLG1
				;TFLG2
				;TC0 ... TC7
				;PACTL
				;PAFLG
				;PACN0 ... PACN3
				;MCCTL
				;MCFLG
				;ICPAR
				;DLYCT
	
				 ;7 6 5 4 3 2 1 0
			MOVB	#%1_1_0_0_0_0_0_1, ICOVW 	;set IC to one shot
				 ;B B B       S S 		
				 ;D D D       C C		
				 ;M M M       I I		
				 ;| | |       | |		
				 ;B R T       T R 
				 ;K E O       O X 
				 ;G S            
				 ;D E            
				 ;  T             

			MOVB	#(TFMOD|BUFEN), ICSYS 		;setup queue mode

				 ;7 6 5 4 3 2 1 0
			MOVB	#%1_1_1_0_0_0_1_1, OCPD 	;disconnect output compares from pins
				 ;B B B       S S 		
				 ;D D D       C C		
				 ;M M M       I I		
				 ;| | |       | |		
				 ;B R T       T R 
				 ;K E O       O X 
				 ;G S            
				 ;D E            
				 ;  T             

				;PTPSR
				;PTMCPSR
				;PBCTL
				;PBFLG
				;PA3H ... PA0H
				;MCCNT
				;TC0H ... TC3H 	
#emac

;#Enable timer
; args: 1. module (TIM_SCI or TIM_BDM)
#macro	TIM_ENABLE, 1
	BSET	TIM_BUSY, #\1
	MOVB	#(TEN|TSFRZ|TFFCA), TSCR1	
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


