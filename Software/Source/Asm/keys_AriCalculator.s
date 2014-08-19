#ifndef	KEYS
#define	KEYS
;###############################################################################
;# S12CBase - KEYS - Keyboard Driver                                           #
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
;#    This is the low level driver for LCD using a ST7565R controller. This    #
;#    driver assumes, that the ST7565R is connected via the 4-wire SPI         #
;#    interface.                                                               #
;#                                                                             #
;#    This modules  provides three functions to the main program:              #
;#    DISPLAY_CHECK_BUF - This function checks if the command buffer is able   #
;#                        to accept more data.                                 #
;#    DISPLAY_TX_NB -     This function send one command to the display        #
;#                        without blocking the program flow.                   #
;#    DISPLAY_TX_BL -     This function send one command to the display and    #
;#                        blocks the program flow until it has been            #
;#                        successful.                                          #
;#                                                                             #
;#    For convinience, all of these functions may also be called as macro.     #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#    VECMAP - Vector Map                                                      #
;#    CLOCK  - Clock driver                                                    #
;#    GPIO   - GPIO driver                                                     #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    GPIO   - GPIO driver                                                     #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 24, 2012                                                           #
;#      - Initial release                                                      #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;#Column port
#ifndef KEYS_COLUMN_PORT	
KEYS_COLUMN_PORT	EQU	PTP		;default is port P		
#endif

;#Row port
#ifndef KEYS_ROW_PORT	
KEYS_ROW_PORT		EQU	PTAD		;default is port AD		
#endif

;Debounce delay
;--------------
;Output compare channel  
#ifndef	KEYS_OC
KEYS_OC			EQU	$4		;default is OC4			
#endif

;Debounce delay (TIM cycles)
#ifndef	SCI_BD_OC
KEYS_DELAY		EQU	1000000/40	;default is 1ms			
#endif


	
;Buffer
;------
;#Buffer size
#ifndef KEYS_BUF_SIZE
KEYS_BUF_SIZE		EQU	8 		;depth of the command buffer
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Buffer
KEYS_BUF_IDX_MASK	EQU	KEYS_BUF_SIZE-1 ;index mask
KEYS_BUF_IDX_INC	EQU	$01 		;index increment



	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef KEYS_VARS_START_LIN
			ORG 	KEYS_VARS_START, KEYS_VARS_START_LIN
#else
			ORG 	KEYS_VARS_START
KEYS_VARS_START_LIN	EQU	@			
#endif	

KEYS_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1

;#Command buffer  
KEYS_BUF		DS	2*KEYS_BUF_SIZE
KEYS_BUF_IN		DS	1
KEYS_BUF_OUT		DS	1
	
KEYS_AUTO_LOC2		EQU	*		;2nd auto-place location

;#State
KEYS_STATE		EQU	((KEYS_AUTO_LOC1&1)*KEYS_AUTO_LOC1)+(((~KEYS_AUTO_LOC1)&1)*KEYS_AUTO_LOC2)
			UNALIGN	((~KEYS_AUTO_LOC1)&1)
KEYS_VARS_END		EQU	*
KEYS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	KEYS_INIT, 0
			;Initialize Variables 
			MOVW	#$0000, KEYS_BUF_IN ;clear input buffer
			;Clear and enable row interrupts
			MOVB	#$7E, PIF0AD
			MOVB	#$7E, PIE0AD
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef KEYS_CODE_START_LIN
			ORG 	KEYS_CODE_START, KEYS_CODE_START_LIN
#else
			ORG 	KEYS_CODE_START
#endif















	

;#Timer debounce delay
; period: approx. 2 SCI frames
; RTS/CTS:    if RTS polling is requested (SCI_FLG_POLL_RTS) -> enable TX IRQ
; XON/XOFF:   if reminder count == 1 -> request XON/XOFF reminder, enable TX IRQ
;	      if reminder count > 1  -> decrement reminder count, retrigger delay
; workaround: retrigger delay, jump to SCI_ISR_RXTX



;#Timer delay
; period: approx. 2 SCI frames
; RTS/CTS:    if RTS polling is requested (SCI_FLG_POLL_RTS) -> enable TX IRQ
; XON/XOFF:   if reminder count == 1 -> request XON/XOFF reminder, enable TX IRQ
;	      if reminder count > 1  -> decrement reminder count, retrigger delay
; workaround: retrigger delay, jump to SCI_ISR_RXTX







	
KEYS_CODE_END		EQU	*
KEYS_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef KEYS_TABS_START_LIN
			ORG 	KEYS_TABS_START, KEYS_TABS_START_LIN
#else
			ORG 	KEYS_TABS_START
#endif	

KEYS_TABS_END		EQU	*
KEYS_TABS_END_LIN	EQU	@
#endif
