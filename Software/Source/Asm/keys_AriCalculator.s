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
;#Column port
#ifndef KEYS_COLUMN_PORT	
KEYS_COLUMN_PORT	EQU	PTP		;default is port P		
#endif

;#Row port
#ifndef KEYS_ROW_PORT	
KEYS_ROW_PORT		EQU	PTAD		;default is port AD		
#endif

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
			ORG 	KEYS_START
			ALIGN	1
;#Command buffer  
KEYS_BUF		DS	2*KEYS_BUF_SIZE
KEYS_BUF_IN		DS	1
KEYS_BUF_OUT		DS	1
	
KEYS_VARS_END	EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	KEYS_INIT, 0
			;Initialize Variables 
			MOVW	#$0000, DISPLAY_BUF_IN
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	KEYS_CODE_START

;#Check if buffer contains data
; args:   none
; result: C: 1=buffer not empty, 0=buffer empty
; SSTACK: 4 bytes
;         X, Y and D are preserved 
KEYS_CHECK_BUF	EQU	*
			;Save registers (buffer entry in D)
			SSTACK_PSHD						;push accu D onto the SSTACK

			;Check if the buffer is empty
			LDD	KEYS_BUF_IN
			CBA
			BEQ	<KEYS_CHECK_BUF_1				;buffer is empty

			;Return positive status 
			SSTACK_PULD						;pull accu D from the SSTACK
			SEC
			SSTACK_RTS

			;Return negative status 
KEYS_CHECK_BUF_1	SSTACK_PULD						;pull accu D from the SSTACK
			CLC
			SSTACK_RTS
	
;#Read the next keycode (non-blocking)
; args:   none
; result: B: key code
;         C: 1 = successful
; SSTACK: 5 bytes
;         X, Y and A are preserved 
KEYS_GET_NB		EQU	*
			;Save registers
			SSTACK_PSHYA						;push  registers onto the SSTACK

			;Check if the buffer is empty 
			LDD	KEYS_BUF_IN
			CBA
			BEQ	<KEYS_GET_NB_1					;buffer is empty

			;Pull keycode from buffer (in-index in A, out-index in B)
			LDY	#KEYS_BUF
			LDAA	B,Y
			INCB
			ANDB	#KEYS_BUF_MASK
			STAB	KEYS_BUF_OUT

			;Return positive status 
			SSTACK_PULAY						;pull  registers from the SSTACK
			SEC
			SSTACK_RTS

			;Return negative status 
KEYS_GET_NB_1		SSTACK_PULAY						;pull registers from the SSTACK
			CLC
			SSTACK_RTS

;#Read the next keycode (blocking)
; args:   none
; result: B: key code
; SSTACK: 5 bytes
;         X, Y and A are preserved 
KEYS_GET_BL		EQU	*

KEYS_GET_BL_1		SEI
			JOBSR	KEYS_GET_NB
			BCS	DISPLAY_TX_BL_2 				;done
			ISTACK_WAIT
			JOB	DISPLAY_TX_BL_1

			;Done 
KEYS_KET_BL_2		CLI
			SSTACK_RTS
	
;#Key wake-up interrupt
KEYS_ISR_WUP		EQU	*





			;Service SPIF if necessary 
DISPLAY_ISR_1		BRCLR	SPISR, #SPIF, DISPLAY_ISR_2 			;SPIF not set
			TST	SPIDRL
			DEC	DISPLAY_TXCNT
			BMI	<DISPLAY_ISR_8					;this should never happen			
			BRSET	SPISR, #SPIF, DISPLAY_ISR_1 			;SPIF still set
	
			;Check if SPIDRL is empty
DISPLAY_ISR_2		BRCLR	SPISR, #SPTEF, DISPLAY_ISR_5 			;done

			;Check if there is data to be transmitted 
			LDD	DISPLAY_BUF_IN
			CBA
			BEQ	<DISPLAY_ISR_8					;disable SPI transmit interrupt

			;Check if A0 must be switched (out-index in B) 
			LDX	#DISPLAY_BUF
			BRCLR	B,X, #DISPLAY_BUF_A0, DISPLAY_ISR_3 		;A0 is to be cleared
			BRSET	DISPLAY_A0_PORT, #DISPLAY_A0_PIN, DISPLAY_ISR_4 ;check transmit count
			TST	DISPLAY_TXCNT
			BNE	<DISPLAY_ISR_5					;done
			BSET	DISPLAY_A0_PORT, #DISPLAY_A0_PIN 		;set A0
			JOB	DISPLAY_ISR_4 					;check transmit count
DISPLAY_ISR_3		BRCLR	DISPLAY_A0_PORT, #DISPLAY_A0_PIN, DISPLAY_ISR_4 ;check transmit countr
			TST	DISPLAY_TXCNT
			BNE	<DISPLAY_ISR_5					;done
			BCLR	DISPLAY_A0_PORT, #DISPLAY_A0_PIN 		;clear A0

			;Check transmit count (out-index in B, buffer pointer in X) 
DISPLAY_ISR_4		LDAA	DISPLAY_TXCNT
			CMPA	#$03
			BHS	<DISPLAY_ISR					;this should never happen			
			INCA	
			STAA	DISPLAY_TXCNT
	
			;Transmit data (out-index in B, buffer pointer in X)
			LDD	B,X 						;get current buffer entry
			STAB	SPIDRL 						;transmit data
			BITA	#DISPLAY_BUF_REPEAT 				;check repeat count
			BNE	<DISPLAY_ISR_7					;decrement repeat count
			LDD	DISPLAY_BUF_IN					;remove data from buffer
			ADDB	#DISPLAY_BUF_IDX_INC
			ANDB	#DISPLAY_BUF_IDX_MASK 
			STAB	DISPLAY_BUF_OUT					;check if queue is empty now
			CBA	
			BEQ	<DISPLAY_ISR_8					;disable SPI transmit interrupt
		
			;Done
DISPLAY_ISR_5		ISTACK_RTI

			;Reset transmission count and wait 
DISPLAY_ISR_6		CLR	DISPLAY_TXCNT
			JOB	DISPLAY_ISR_5 					;done
	
			;Decrement repeat count (buffer entry in D, buffer pointer in X)
DISPLAY_ISR_7		SUBA	#DISPLAY_BUF_REPEAT_DEC				;decrement repeat count
			LDAB	DISPLAY_BUF_OUT					;store repeat count
			STAA	B,X
			JOB	DISPLAY_ISR_5 					;done

			;Disable SPI transmit interrupt
DISPLAY_ISR_8		BCLR	SPICR1, #SPTIE	 				;clear SPTIE bit
			JOB	DISPLAY_ISR_5 					;done
	
DISPLAY_CODE_END	EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	DISPLAY_TABS_START
DISPLAY_TABS_END	EQU	*

#endif
