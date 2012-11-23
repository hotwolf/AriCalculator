;###############################################################################
;# S12CBase - DISP - LCD Driver (ST7565R)                                      #
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
;#    DISP_CHECK_BUF - This function checks if the command buffer is able   #
;#                        to accept more data.                                 #
;#    DISP_TX_NB -     This function send one command to the display        #
;#                        without blocking the program flow.                   #
;#    DISP_TX_BL -     This function send one command to the display and    #
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
;#Bus frequency
#ifndef CLOCK_BUS_FREQ	
CLOCK_BUS_FREQ		EQU	25000000	;default is 25 MHz
#endif

;#Baud rate
#ifndef DISP_BAUD
DISP_BAUD		EQU	12000000	;default is 12 Mbit/s
#endif

;#A0 output
#ifndef DISP_A0_PORT
DISP_A0_PORT		EQU	PTS 		;default is port S	
#endif
#ifndef DISP_A0_PIN
DISP_A0_PIN		EQU	PS4		;default is PS4	
#endif

;#Splash screen
#ifndef DISP_SPLASH
#macro	SPLASH_STREAM, 0
#emac
#endif

;#Buffer size
#ifndef DISP_BUF_SIZE
DISP_BUF_SIZE	EQU	8 		;depth of the command buffer
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Buffer
; Entry format: 
;  F  E  D  C  B  A  9  8  7  6  5  4  3  2  1  0
; +-------------------+--+-----------------------+
; |   repeat count    |A0|    command/data       |
; +-------------------+--+-----------------------+
DISP_BUF_REPEAT	EQU	$FE 		;repeat count     (within the high byte)
DISP_BUF_REPEAT_DEC	EQU	$02 		;repeat increment (within the high byte)
DISP_BUF_A0		EQU	$01 		;A0               (within the high byte)
DISP_BUF_IDX_MASK	EQU	(DISP_BUF_SIZE-1)<<1 ;index mask
DISP_BUF_IDX_INC	EQU	$02 		;index increment

;#Baud rate divider
DISP_SPPR		EQU	((CLOCK_BUS_FREQ/(2*DISP_BAUD))-1)&7
DISP_SPR		EQU	0	
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	DISP_VARS_START
DISP_AUTO_LOC1	EQU	* 		;1st auto-place location
			ALIGN	1
	
;#Command buffer  
DISP_BUF		DS	2*DISP_BUF_SIZE
DISP_BUF_IN		DS	1
DISP_BUF_OUT		DS	1

DISP_AUTO_LOC2	DS	1		;2nd auto-place location
DISP_AUTO_LOC3	EQU	*		;3nd auto-place location

;#Transmission counter (auto-place)
DISP_TXCNT		EQU	((DISP_AUTO_LOC1&1)*DISP_AUTO_LOC1)+((~DISP_AUTO_LOC1&1)*DISP_AUTO_LOC2)
DISP_VARS_END	EQU	((DISP_AUTO_LOC1&1)*DISP_AUTO_LOC2)+((~DISP_AUTO_LOC1&1)*DISP_AUTO_LOC3)
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	DISP_INIT, 0
			;Initialize Variables 
			MOVW	#$0000, DISP_BUF_IN
			CLR	DISP_TXCNT
	
			;Initialize SPI	
			MOVW	#%11011110_00011001, SPICR1
				 ;SSSMCCSL  X MB SS
				 ;PPPSPPSS  F OI PP
				 ;IETTOHOB  R DD IC
				 ;E IRLAEF  W FI S0
				 ;  E    E    ER W
				 ;            NO A
				 ;             E I
			MOVB	#((DISP_SPPR<<4|(DISP_SPR))), SPIBR
			;MOVB	#$FF, SPISR

			;Initialize display	
			CLRA				
			LDX	#SETUP_START		
			LDY	#(SETUP_END-SETUP_START)	
INIT_LOOP		LDAB	1,X+
			JOBSR	DISP_TX_BL
			DBNE	Y, INIT_LOOP

			;Show splash screen	
#ifdef	DISP_SPLASH
			LDX	#SPLASH_START
			LDY	#(SPLASH_END-SPLASH_START)	
SPLASH_LOOP		LDD	2,X+
			JOBSR	DISP_TX_BL
			DBNE	Y, SPLASH_LOOP
#endif			
			JOB	DONE

SETUP_START		DB	$40 				;start display at line 0
			DB	$A0				;flip display
			DB	$C8				;COM0 -> 
			;DB	$A1				;flip display
			;DB	$C0				;COM0 -> 
			DB	$A2				;set bias 1/9 (Duty 1/65) ;
			DB	$2F 				;enabable booster, regulator and follower
			DB	$F8				;set booster to 4x
			DB	$00
			DB	$27				;set ref value to 6.5
			DB	$81				;set alpha value to 47
			DB	$10                             ;V0=alpha*(1-(ref/162)*2.1V =[4V..13.5V]
			DB	$AC				;no static indicator
			DB	$00
			DB	$AF 				;enable display
SETUP_END		EQU	*

SPLASH_START		EQU	*
			SPLASH_STREAM
SPLASH_END

DONE			EQU	*
#emac

;#Convenience macros

;#Check if buffer is full
; args:   none
; result: C: 1=buffer not full, 0=buffer full
; SSTACK: 4 bytes
;         X, Y and D are preserved 
#macro	DISP_CHECK_BUF, 0
			JOBSR	DISP_CHECK_BUF
#emac

;#Transmit commands and data (non-blocking)
; args:   D: buffer entry
; result: C: 1=successful, 0=nothing has been done
; SSTACK: 8 bytes
;         X, Y and D are preserved 
#macro	DISP_TX_NB, 0
			JOBSR	DISP_TX_NB
#emac

;#Transmit commands and data (blocking)
; args:   D: buffer entry
; result: none
; SSTACK: 10 bytes
;         X, Y and D are preserved 
#macro	DISP_TX_BL, 0
			JOBSR	DISP_TX_BL
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	DISP_CODE_START

;#Check if buffer is full
; args:   none
; result: C: 1=buffer not full, 0=buffer full
; SSTACK: 4 bytes
;         X, Y and D are preserved 
DISP_CHECK_BUF	EQU	*
			;Save registers (buffer entry in D)
			SSTACK_PSHD						;push accu D onto the SSTACK

			;Check if the buffer is full
			LDD	DISP_BUF_IN
			ADDA    #DISP_BUF_IDX_INC
			CBA
			BEQ	<DISP_CHECK_BUF_1				;buffer is full

			;Return positive status 
			SSTACK_PULD						;pull accu D from the SSTACK
			SEC
			SSTACK_RTS

			;Return negative status 
DISP_CHECK_BUF_1	SSTACK_PULD						;pull accu D from the SSTACK
			CLC
			SSTACK_RTS
	
;#Transmit commands and data (non-blocking)
; args:   D: buffer entry
; result: C: 1 = successful
; SSTACK: 8 bytes
;         X, Y and D are preserved 
DISP_TX_NB		EQU	*
			;Save registers (buffer entry in D)
			SSTACK_PSHYXD						;push all registers onto the SSTACK

			;Store buffer entry (buffer entry in D)
DISP_TX_NB_1		TFR	D, Y
			LDX	#DISP_BUF 					;store buffer
			LDD	DISP_BUF_IN
			STY	A,X						

			;Check if the buffer is full (in-index in A, out-index in B)
			ADDA    #DISP_BUF_IDX_INC
			ANDA	#DISP_BUF_IDX_MASK
			CBA
			BEQ	<DISP_TX_NB_2				;buffer is full
			STAA	DISP_BUF_IN					;Update buffer (new in-index in A)

			;Enable SPI transmit interrupt 
			BSET	SPICR1, #SPTIE
	
			;Return positive status 
			SSTACK_PULDXY						;pull all registers from the SSTACK
			SEC
			SSTACK_RTS

			;Return negative status 
DISP_TX_NB_2		SSTACK_PULDXY						;pull all registers from the SSTACK
			CLC
			SSTACK_RTS

;#Transmit commands and data (blocking)
; args:   D: buffer entry
; result: none
; SSTACK: 10 bytes
;         X, Y and D are preserved 
DISP_TX_BL		EQU	*

DISP_TX_BL_1		SEI
			JOBSR	DISP_TX_NB
			BCS	DISP_TX_BL_2 				;done
			ISTACK_WAIT
			JOB	DISP_TX_BL_1

			;Done 
DISP_TX_BL_2		CLI
			SSTACK_RTS
	
;#SPI ISR for transmitting data to the ST7565R display controller
DISP_ISR		EQU	*
			;Service SPIF if necessary 
DISP_ISR_1		BRCLR	SPISR, #SPIF, DISP_ISR_2 			;SPIF not set
			TST	SPIDRL
			DEC	DISP_TXCNT
			BMI	<DISP_ISR_8					;this should never happen			
			BRSET	SPISR, #SPIF, DISP_ISR_1 			;SPIF still set
	
			;Check if SPIDRL is empty
DISP_ISR_2		BRCLR	SPISR, #SPTEF, DISP_ISR_5 			;done

			;Check if there is data to be transmitted 
			LDD	DISP_BUF_IN
			CBA
			BEQ	<DISP_ISR_8					;disable SPI transmit interrupt

			;Check if A0 must be switched (out-index in B) 
			LDX	#DISP_BUF
			BRCLR	B,X, #DISP_BUF_A0, DISP_ISR_3 		;A0 is to be cleared
			BRSET	DISP_A0_PORT, #DISP_A0_PIN, DISP_ISR_4 ;check transmit count
			TST	DISP_TXCNT
			BNE	<DISP_ISR_5					;done
			BSET	DISP_A0_PORT, #DISP_A0_PIN 		;set A0
			JOB	DISP_ISR_4 					;check transmit count
DISP_ISR_3		BRCLR	DISP_A0_PORT, #DISP_A0_PIN, DISP_ISR_4 ;check transmit countr
			TST	DISP_TXCNT
			BNE	<DISP_ISR_5					;done
			BCLR	DISP_A0_PORT, #DISP_A0_PIN 		;clear A0

			;Check transmit count (out-index in B, buffer pointer in X) 
DISP_ISR_4		LDAA	DISP_TXCNT
			CMPA	#$03
			BHS	<DISP_ISR					;this should never happen			
			INCA	
			STAA	DISP_TXCNT
	
			;Transmit data (out-index in B, buffer pointer in X)
			LDD	B,X 						;get current buffer entry
			STAB	SPIDRL 						;transmit data
			BITA	#DISP_BUF_REPEAT 				;check repeat count
			BNE	<DISP_ISR_7					;decrement repeat count
			LDD	DISP_BUF_IN					;remove data from buffer
			ADDB	#DISP_BUF_IDX_INC
			ANDB	#DISP_BUF_IDX_MASK 
			STAB	DISP_BUF_OUT					;check if queue is empty now
			CBA	
			BEQ	<DISP_ISR_8					;disable SPI transmit interrupt
		
			;Done
DISP_ISR_5		ISTACK_RTI

			;Reset transmission count and wait 
DISP_ISR_6		CLR	DISP_TXCNT
			JOB	DISP_ISR_5 					;done
	
			;Decrement repeat count (buffer entry in D, buffer pointer in X)
DISP_ISR_7		SUBA	#DISP_BUF_REPEAT_DEC				;decrement repeat count
			LDAB	DISP_BUF_OUT					;store repeat count
			STAA	B,X
			JOB	DISP_ISR_5 					;done

			;Disable SPI transmit interrupt
DISP_ISR_8		BCLR	SPICR1, #SPTIE	 				;clear SPTIE bit
			JOB	DISP_ISR_5 					;done
	
DISP_CODE_END	EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	DISP_TABS_START
DISP_TABS_END	EQU	*
