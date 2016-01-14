;###############################################################################
;# S12CForth - FSCI - Customized SCI Driver                                    #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
;#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
;#    family.                                                                  #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#    This module implements Forth words for the S12CBase SCI driver           #
;#    Relationship between SCIBR and the baud rate:                            #
;#                                                                             #
;#                               CLOCK_BUS_FREQ                                #
;#                  baud rate = ----------------                               #
;#                                 16 * SCIBR                                  #
;#                                                                             #
;#                               CLOCK_BUS_FREQ                                #
;#                     SCI_BR = ----------------                               #
;#                               16 * baud rate                                #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FCORE - Forth core words                                                 #
;#    FMEM - Forth memories                                                    #
;#    FEXCPT - Forth exceptions                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;CPU
#ifndef	CPU_S12
#ifndef	CPU_S12X
CPU_S12		EQU	1 			;default is S12
#endif
#endif

;Bus frequency
#ifndef	CLOCK_BUS_FREQ
CLOCK_BUS_FREQ		EQU	25000000 	;default is 25MHz
#endif
	
;Invert RXD/TXD 
#ifndef	FSCI_RXTX_ACTLO
#ifndef	FSCI_RXTX_ACTHI
FSCI_RXTX_ACTLO		EQU	1 		;default is active low RXD/TXD
#endif
#endif

;TIM configuration
;The FSCI driver requires one timer channel to time delays and to measure
;the pulse lengths at the RX pin
#ifndef	FSCI_TC
FSCI_TC			EQU	0 		;default is TC0
#endif
	
;Baud rate
;---------
#ifndef FSCI_BAUD_AUTO
#ifndef FSCI_BAUD_4800 	
#ifndef FSCI_BAUD_7200 	
#ifndef FSCI_BAUD_9600 	
#ifndef FSCI_BAUD_14400	
#ifndef FSCI_BAUD_19200	
#ifndef FSCI_BAUD_28800	
#ifndef FSCI_BAUD_38400	
#ifndef FSCI_BAUD_57600	
FSCI_BAUD_AUTO		EQU	1 		;default is auto detection
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
	
;Flow control
;------------ 
;RTS/CTS or XON/XOFF
#ifndef	FSCI_FC_RTSCTS
#ifndef	FSCI_FC_XONXOFF
FSCI_FC_RTSCTS		EQU	1 		;default is FSCI_RTSCTS
#endif
#endif

;RTS/CTS coniguration
#ifdef FSCI_FC_RTSCTS
;RTS pin
#ifndef	FSCI_RTS_PORT
FSCI_RTS_PORT		EQU	PTM 		;default is PTM
#endif
#ifndef	FSCI_RTS_PIN	
FSCI_RTS_PIN		EQU	PM0		;default is PM0
#endif
;CTS pin
#ifndef	FSCI_CTS_PORT
FSCI_CTS_PORT		EQU	PTM 		;default is PTM
#endif
#ifndef	FSCI_CTS_DDR
FSCI_CTS_DDR		EQU	DDRM 		;default is DDRM
#endif
#ifndef	FSCI_CTS_PPS
FSCI_CTS_PPS		EQU	PPSM 		;default is PPSM
#endif
#ifndef	FSCI_CTS_PIN
FSCI_CTS_PIN		EQU	PM1		;default is PM1
#endif
;CTS drive strength
#ifndef	FSCI_CTS_WEAK_DRIVE
#ifndef	FSCI_CTS_STRONG_DRIVE
FSCI_CTS_STRONG_DRIVE	EQU	1		;default is strong drive
#endif
#endif
#endif
	
;MC9S12DP256 FSCI IRQ workaround (MUCts00510)
;------------------------------------------- 
;###############################################################################
;# The will SCI only request interrupts if an odd number of interrupt flags is #
;# This will cause disabled and spourious interrupts.                          #
;# -> The RX/TX ISR must be periodically triggered by a timer interrupt.       #
;#    The timer period should be about as long as two SCI frames:              #
;#    RT cycle = SCIBD * bus cycles                                            #
;#    bit time = 16 * RT cycles = 16 * SCIBD * bus cycles                      #
;#    frame time = 10 * bit times = 160 RT cycles = 160 * SCIBD * bus cycles   #
;#    2 * frame times = 320 * SCIBD * bus cycles = 0x140 * SCIBD * bus cycles  #
;#    Simplification:                                                          #
;#    TIM period = 0x100 * SCIBD * bus cycles                                  #
;###############################################################################
;Enable IRQ workaround
#ifndef	FSCI_IRQ_WORKAROUND_ON
#ifndef	FSCI_IRQ_WORKAROUND_OFF
FSCI_IRQ_WORKAROUND_OFF	EQU	1 		;IRQ workaround disabled by default
#endif
#endif

;Communication error signaling
;----------------------------- 
;Signal RX errors -> define macros SCI_ERRSIG_START and SCI_ERRSIG_STOP
;#mac SCI_ERRSIG_START, 0
;	...code to start error signaling (inside ISR)
;#emac
;#mac SCI_ERRSIG_STOP, 0			;X, Y, and D are preserved 
;	...code to stop error signaling (inside ISR)
;#emac
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Baud rate devider settings
; SCIBD = 25MHz / (16*baud rate)
FSCI_1200        	EQU	(CLOCK_BUS_FREQ/(16*  1200))+(((2*CLOCK_BUS_FREQ)/(16*  1200))&1)	
FSCI_2400        	EQU	(CLOCK_BUS_FREQ/(16*  2400))+(((2*CLOCK_BUS_FREQ)/(16*  2400))&1)	
FSCI_4800        	EQU	(CLOCK_BUS_FREQ/(16*  4800))+(((2*CLOCK_BUS_FREQ)/(16*  4800))&1)	
FSCI_7200        	EQU	(CLOCK_BUS_FREQ/(16*  7200))+(((2*CLOCK_BUS_FREQ)/(16*  7200))&1)	
FSCI_9600        	EQU	(CLOCK_BUS_FREQ/(16*  9600))+(((2*CLOCK_BUS_FREQ)/(16*  9600))&1)	
FSCI_14400       	EQU	(CLOCK_BUS_FREQ/(16* 14400))+(((2*CLOCK_BUS_FREQ)/(16* 14400))&1)	
FSCI_19200       	EQU	(CLOCK_BUS_FREQ/(16* 19200))+(((2*CLOCK_BUS_FREQ)/(16* 19200))&1)	
FSCI_28800       	EQU	(CLOCK_BUS_FREQ/(16* 28800))+(((2*CLOCK_BUS_FREQ)/(16* 28800))&1)	
FSCI_38400       	EQU	(CLOCK_BUS_FREQ/(16* 38400))+(((2*CLOCK_BUS_FREQ)/(16* 38400))&1)	
FSCI_57600       	EQU	(CLOCK_BUS_FREQ/(16* 57600))+(((2*CLOCK_BUS_FREQ)/(16* 57600))&1)	
FSCI_76800       	EQU	(CLOCK_BUS_FREQ/(16* 76800))+(((2*CLOCK_BUS_FREQ)/(16* 76800))&1)	
FSCI_115200		EQU	(CLOCK_BUS_FREQ/(16*115200))+(((2*CLOCK_BUS_FREQ)/(16*115200))&1)	
FSCI_153600		EQU	(CLOCK_BUS_FREQ/(16*153600))+(((2*CLOCK_BUS_FREQ)/(16*153600))&1)
FSCI_BMUL		EQU	$FFFF/SCI_153600	 	;Multiplicator for storing the baud rate
		
;#Frame format
FSCI_8N1			EQU	  ILT		;8N1
FSCI_8E1			EQU	  ILT|PE	;8E1
FSCI_8O1			EQU	  ILT|PE|PT	;8O1
FSCI_8N2		 	EQU	M|ILT		;8N2 TX8=1
	
;#C0 characters
FSCI_C0_MASK		EQU	$E0 		;mask for C0 character range
FSCI_BREAK		EQU	$03 		;ctrl-c (terminate program execution)
FSCI_DLE			EQU	$10		;data link escape (treat next byte as data)
FSCI_XON			EQU	$11 		;unblock transmission 
FSCI_XOFF		EQU	$13		;block transmission
FSCI_SUSPEND		EQU	$1A 		;ctrl-z (suspend program execution)

;#Buffer sizes		
FSCI_RXBUF_SIZE		EQU	 16*2		;size of the receive buffer (8 error:data entries)
#ifndef	SCI_TXBUF_SIZE	
FSCI_TXBUF_SIZE		EQU	  8		;size of the transmit buffer
#endif
FSCI_RXBUF_MASK		EQU	$1F		;mask for rolling over the RX buffer
;SCI_TXBUF_MASK		EQU	$07		;mask for rolling over the TX buffer
FSCI_TXBUF_MASK		EQU	$01		;mask for rolling over the TX buffer

;#Hardware handshake borders
FSCI_RX_FULL_LEVEL	EQU	8*2		;RX buffer threshold to block transmissions 
FSCI_RX_EMPTY_LEVEL	EQU	2*2		;RX buffer threshold to unblock transmissions
	
;#Flag definitions
FSCI_FLG_SEND_XONXOFF	EQU	$80		;send XON/XOFF symbol asap
FSCI_FLG_POLL_RTS	EQU	$40		;poll RTS input
FSCI_FLG_DELAY_PENDING	EQU	$20		;bit to detect the execution of the delay ISR
FSCI_FLG_SWOR		EQU	$10		;software buffer overrun (RX buffer)
FSCI_FLG_RX_BLOCKED	EQU	$08		;don't allow incommint traffic (send XOFF, clear CTS) 
FSCI_FLG_TX_BLOCKED	EQU	$04		;don't transmit (XOFF received)
FSCI_FLG_RX_ESC		EQU	$02		;character is to be escaped
FSCI_FLG_TX_ESC		EQU	$01		;character is to be escaped

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FSCI_VARS_START_LIN
			ORG 	FSCI_VARS_START, FSCI_VARS_START_LIN
#else
			ORG 	FSCI_VARS_START
FSCI_VARS_START_LIN	EQU	@			

#endif	
FSCI_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1	
;#Receive buffer	
FSCI_RXBUF		DS	FSCI_RXBUF_SIZE
FSCI_RXBUF_IN		DS	1		;points to the next free space
FSCI_RXBUF_OUT		DS	1		;points to the oldest entry
;#Transmit buffer
FSCI_TXBUF		DS	FSCI_TXBUF_SIZE
FSCI_TXBUF_IN		DS	1		;points to the next free space
FSCI_TXBUF_OUT		DS	1		;points to the oldest entry
;#Baud rate (reset proof) 
FSCI_BVAL		DS	2		;value of the SCIBD register
FSCI_BVAL_INV		DS	2		;inverted value of the SCIBD register




FSCI_VARS_END		EQU	*
FSCI_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FSCI_INIT, 0
#emac
	
;#Abort action (to be executed in addition of quit action)
#macro	FSCI_ABORT, 0
#emac
	
;#Quit action
#macro	FSCI_QUIT, 0
#emac
	
;#Suspend action (to be executed in addition of QUIT action)
#macro	FSCI_SUSPEND, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FSCI_CODE_START_LIN
			ORG 	FSCI_CODE_START, FSCI_CODE_START_LIN
#else
			ORG 	FSCI_CODE_START
#endif

;Interrupt service routines:
;===========================
; No nesting of ISRs allowed (I-bit must remain set) 
 
;#Transmit ISR (status flags in A)
;--------------------------------- 
FSCI_ISR_TX		EQU	*
			;Handle false alerts
			BITA	#TDRE						;check if SCI is ready for new TX data
			BEQ	<FSCI_ISR_TX_4					;done for now
#ifdef	FSCI_FC_XONXOFF
			;Check if XON/XOFF transmission is required
			BRSET	FSCI_FLGS, #FSCI_FLG_TX_ESC, FSCI_ISR_TX_1 	;Don't escape any XON/XOFF symbols
			;Transmit XON/XOFF symbols
			BRCLR	FSCI_FLGS, #FSCI_FLG_SEND_XONXOFF, FSCI_ISR_TX_1;XON/XOFF not requested
			;Clear XON/XOFF request
			BCLR	FSCI_FLGS, #FSCI_FLG_SEND_XONXOFF
			;Check for forced XOFF
			BRSET	FSCI_FLGS, #FSCI_FLG_RX_BLOCKED, FSCI_ISR_TX_6 ;transmit XOFF
			;Check RX queue
			LDD	FSCI_RXBUF_IN
			SBA			
			ANDA	#FSCI_RXBUF_MASK
			;Check XOFF theshold
			CMPA	#FSCI_RX_FULL_LEVEL
			BHS	<FSCI_ISR_TX_6	 				;transmit XOFF
			;Check XON theshold
			CMPA	#FSCI_RX_EMPTY_LEVEL
			BLS	<FSCI_ISR_TX_5	 				;transmit XON
			;Check XOFF status
			BRSET	FSCI_FLGS, #FSCI_FLG_TX_BLOCKED, FSCI_ISR_TX_3 ;stop transmitting
#endif
#ifdef	FSCI_FC_RTSCTS
			;Check RTS status
			BRCLR	FSCI_RTS_PORT, #FSCI_RTS_PIN, FSCI_ISR_TX_1	;check TX buffer
        		BSET	FSCI_FLGS, #FSCI_FLG_POLL_RTS			;request RTS polling	
			FSCI_START_DELAY					;start delay
			JOB	FSCI_ISR_TX_3					;stop transmitting
#endif
			;Check TX buffer
FSCI_ISR_TX_1		LDD	FSCI_TXBUF_IN
			CBA
			BEQ	<FSCI_ISR_TX_3 					;stop transmitting
			;Transmit data (in-index in A, out-index in B)
			LDY	#FSCI_TXBUF
#ifdef	FSCI_FC_XONXOFF
			;Check for DLE (in-index in A, out-index in B, buffer pointer in Y)
			BCLR	FSCI_FLGS, #FSCI_FLG_TX_ESC
			TFR	D, X
			LDAB	B,Y
			CMPB	#FSCI_DLE
			BNE	FSCI_ISR_TX_2
			BSET	FSCI_FLGS, #FSCI_FLG_TX_ESC
FSCI_ISR_TX_2		STAB	SCIDRL	
			TFR	X, D
#else	
			MOVB	B,Y ,SCIDRL
#endif
			;Increment index (in-index in A, out-index in B, buffer pointer in Y)
			INCB
			ANDB	#FSCI_TXBUF_MASK
			STAB	FSCI_TXBUF_OUT
			CBA
			BNE	<FSCI_ISR_TX_4 					;done	
			;Stop transmitting
FSCI_ISR_TX_3		EQU	*
#ifdef FSCI_FC_XONXOFF
			BRSET	FSCI_FLGS, #FSCI_FLG_SEND_XONXOFF, FSCI_ISR_TX_4 ;consider pending XON/XOFF symbols
#endif	
			MOVB	#(RIE|TE|RE), SCICR2 				;disable TX interrupts	
			;Done
FSCI_ISR_TX_4		RTI
#ifdef FSCI_FC_XONXOFF
			;Transmit XON
FSCI_ISR_TX_5		MOVB	#FSCI_XON, SCIDRL
			JOB	FSCI_ISR_TX_7					;schedule reminder	
			;Transmit XOFF
FSCI_ISR_TX_6		MOVB	#FSCI_XOFF, SCIDRL
			;Schedule reminder
FSCI_ISR_TX_7		MOVW	#FSCI_XONXOFF_REMINDER, FSCI_XONXOFF_REMCNT
			FSCI_START_DELAY					;start delay
			;JOB	FSCI_ISR_TX_4 					;done	
			RTI 							;done	
#endif	

;#Receive/Transmit ISR (Common ISR entry point for the SCI)
;---------------------------------------------------------- 
FSCI_ISR_RXTX		EQU	*
			;Common entry point for all SCI interrupts
			;Load flags
			LDAA	SCISR1						;load status flags into accu A
										;SCI Flag order:				 
										; 7:TDRE (Transmit Data Register Empty Flag)
										; 6:TC   (TransmitCompleteFlag)
										; 5:RDRF (Receive Data Register Full Flag)
										; 4:IDLE (Idle Line Flag)
										; 3:OR   (Overrun Flag)
										; 2:NF   (Noise Flag)
										; 1:FE   (Framing Error Flag)
										; 0:PE	 (Parity Error Flag)	
			;Check for RX data (status flags in A)			
#ifdef 	RDRFF									;RDRF is also the Reduced Drive Register for port F
			BITA	#(RDRFF|OR) 					;go to receive handler if receive buffer
#else										
			BITA	#(RDRF|OR) 					;go to receive handler if receive buffer
#endif										
			BEQ	FSCI_ISR_TX					;is full or if an overrun has occured
			
;#Receive ISR (status flags in A)
;-------------------------------- 
FSCI_ISR_RX		EQU	*
			;Pick up data
			LDAB	SCIDRL						;load receive data into accu B (clears flags)
			ANDA	#(OR|NF|FE|PF)					;only maintain relevant error flags
			;Check character is escaped (status flags in A, RX data in B)
			BRSET	FSCI_FLGS, #FSCI_FLG_RX_ESC, FSCI_ISR_RX_5 	;charakter is escaped (skip detection)			
			;Transfer SWOR flag to current error flags (status flags in A, RX data in B)
			BRCLR	FSCI_FLGS, #FSCI_FLG_SWOR, FSCI_ISR_RX_1	;SWOR bit not set
			ORAA	#FSCI_FLG_SWOR					;set SWOR bit in accu A
			BCLR	FSCI_FLGS, #FSCI_FLG_SWOR 			;clear SWOR bit in variable	
			;Check for control characters (status flags in A, RX data in B)
			BITA	#(FSCI_FLG_SWOR|OR|NF|FE|PF) 			;don't handle control characters with errors
			BNE	<FSCI_ISR_RX_1 					;queue data
			CMPB	#FSCI_SUSPEND
			BLE	FSCI_ISR_RX_8					;determine control signal
			;Place data into RX queue (status flags in A, RX data in B) 
FSCI_ISR_RX_1		TFR	D, Y						;flags:data -> Y
			LDX	#FSCI_RXBUF   					;buffer pointer -> X
			LDD	FSCI_RXBUF_IN					;in:out -> A:B
			STY	A,X
			ADDA	#2
			ANDA	#FSCI_RXBUF_MASK		
			CBA
                	BEQ	<FSCI_ISR_RX_9					;buffer overflow
			STAA	FSCI_RXBUF_IN					;update IN pointer
			;Check if flow control must be applied (in:out in D, flags:data in Y)
			SBA
			ANDA	#FSCI_RXBUF_MASK
			CMPA	#FSCI_RX_FULL_LEVEL
			BHS	<FSCI_ISR_RX_10 				;buffer is getting full			
			;Check for RX errors (flags:data in Y)
FSCI_ISR_RX_2		BITA	#(NF|FE|PF) 					;check for noise, frame errors, parity errors
			BNE	<FSCI_ISR_RX_12 				;RX error detected
FSCI_ISR_RX_3		EQU	*
#ifmac	FSCI_ERRSIG_STOP
			FSCI_ERRSIG_STOP 					;stop signaling RX error
#endif

#ifdef	FSCI_DETECT_C0
			;Queue escape character (status flags in A, RX data in B)	
FSCI_ISR_RX_5		TFR	D, Y
			LDX	#FSCI_RXBUF
			LDD	FSCI_RXBUF_IN				;in:out -> A:B
			BRCLR	FSCI_FLGS, #FSCI_FLG_SWOR, FSCI_ISR_RX_6   ;no SWOR occured
			MOVW	#((FSCI_FLG_SWOR<<8)|FSCI_DLE), A,X 	;queue DLE with SWOR flag
			JOB	FSCI_ISR_RX_7
FSCI_ISR_RX_6		MOVW	#FSCI_DLE, A,X 				;queue DLE without SWOR flag
FSCI_ISR_RX_7		BCLR	FSCI_FLGS, #(FSCI_FLG_SWOR|FSCI_FLG_RX_ESC) ;clear SWOR and RX_ESC flags	
			ADDA	#2
			ANDA	#FSCI_RXBUF_MASK		
			CBA
                	BEQ	<FSCI_ISR_RX_9				;buffer overflow
			STAA	FSCI_RXBUF_IN				;update IN pointer
			TFR	Y, D
			JOB	FSCI_ISR_RX_1 				;queue data
			;Determine control signal (status flags in A, RX data in B)
FSCI_ISR_RX_8		EQU	*
			;Check for SUSPEND (status flags in A, RX data in B)
			CMPB	#FSCI_SUSPEND
			BEQ	<SCI_ISR_RX_14				;SUSPEND received
#ifdef	FSCI_FC_XONXOFF
			;Check for XON/XOFF (status flags in A, RX data in B)
			CMPB	#FSCI_XOFF
			BEQ	<FSCI_ISR_RX_15				;XOFF received
			CMPB	#FSCI_XON
			BEQ	<FSCI_ISR_RX_16				;XON received
#endif
			;Check for DLE (status flags in A, RX data in B)
			CMPB	#FSCI_DLE
			BEQ	<FSCI_ISR_RX_17				;DLE received
			;Check for BREAK (status flags in A, RX data in B)
			CMPB	#FSCI_BREAK
			BEQ	<SCI_ISR_RX_18				;BREAK received
			JOB	FSCI_ISR_RX_1 				;queue data
			;Buffer overflow (flags:data in Y)
FSCI_ISR_RX_9		BSET	FSCI_FLGS, #FSCI_FLG_SWOR 		;set overflow flag
			;Signal buffer full (flags:data in Y)
#ifdef	FSCI_FC_RTSCTS
			;Deassert CTS (stop incomming data) (flags:data in Y)
FSCI_ISR_RX_10		FSCI_DEASSERT_CTS
#endif	
#ifdef	FSCI_FC_XONXOFF
			;Transmit XON/XOFF (flags:data in Y)
FSCI_ISR_RX_10		FSCI_SEND_XONXOFF
#endif
FSCI_ISR_RX_11		BITA	#(NF|FE|PF) 				;check for noise, frame errors, parity errors
			BEQ	<FSCI_ISR_RX_3 				;stop error signaling			
			;RX error detected
FSCI_ISR_RX_12		EQU	*
#ifmac	FSCI_ERRSIG_START
			;Signal error
			FSCI_ERRSIG_START 				;signal RX error
#endif
#ifdef	FSCI_IRQ_WORKAROUND_ON
FSCI_ISR_RX_13		JOB	FSCI_ISR_RXTX				;Continue with TX 
#else
FSCI_ISR_RX_13		RTI						;Done
#endif
			;Handle SUSPEND 
SCI_ISR_RX_14		EQU	*
#ifdef	CPU_S12									
			MOVB	0,SP, 2,-SP 				;move CCR
			MOVW	3,SP, 1,SP 				;move D
			MOVW	5,SP, 3,SP 				;move X
			MOVW	7,SP, 5,SP 				;move Y
			MOVW	#CF_SUSPEND, 7,SP 			;set return address
#else
			MOVW	0,SP, 2,-SP 				;move CCR
			MOVW	4,SP, 2,SP 				;move D
			MOVW	6,SP, 4,SP 				;move X
			MOVW	8,SP, 6,SP 				;move Y
			MOVW	#CF_SUSPEND, 8,SP 			;set return address
#endif
			RTI						;suspend
#ifdef	FSCI_FC_XONXOFF
			;Handle XOFF 
FSCI_ISR_RX_15		BSET	FSCI_FLGS, #FSCI_FLG_TX_BLOCKED		;stop transmitting
			JOB	FSCI_ISR_RX_13 				;done
			;Handle XON 
FSCI_ISR_RX_16		BSET	FSCI_FLGS, #FSCI_FLG_TX_BLOCKED		;allow transmissions
			MOVB	#(TXIE|RIE|TE|RE), SCICR2		;enable TX interrupt
			JOB	FSCI_ISR_RX_13 				;done
#endif
			;Handle DLE 
FSCI_ISR_RX_17		BSET	FSCI_FLGS, #FSCI_FLG_RX_ESC 		;remember start of escape sequence
			LDD	FSCI_RXBUF_IN				;in:out -> A:B
			ANDA	#FSCI_RXBUF_MASK
			CMPA	#(FSCI_RX_FULL_LEVEL-2)
			BHS	<FSCI_ISR_RX_10 				;buffer is getting full			
			JOB	FSCI_ISR_RX_11				;check for RX errors

#ifmac	FSCI_BREAK_ACTION
			;Handle BREAK 
FSCI_ISR_RX_18		EQU	*
#ifdef	CPU_S12									
			MOVW	#CF_ABORT, 7,SP 			;set return address
#else
			MOVW	#CF_ABORT, 8,SP 			;set return address
#endif
			RTI						;abort



FSCI_ISR_TIM_IC		EQU	*





FSCI_ISR_TIM		EQU	*
			
	

FSCI_ISR_TIM_OC		EQU	*

	

;Code Fields:
;============
;RSP -> SP 
;PSP -> Y 
;If SP or Y are temporarily used for other purposes, interrupts must be disabled. 






	

FSCI_CODE_END		EQU	*
FSCI_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef SCI_TABS_START_LIN
			ORG 	FSCI_TABS_START, FSCI_TABS_START_LIN
#else
			ORG 	FSCI_TABS_START
#endif	



FSCI_TABS_END		EQU	*
FSCI_TABS_END_LIN	EQU	@
#endif
