#ifndef SCI
#define SCI
;###############################################################################
;# S12CBase - SCI - Serial Communication Interface Driver                      #
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
;#    This is the low level driver for the SCI module.                         #
;#                                                                             #
;#    This module provides the following functions to the main program:        #
;#    SCI_TX_NB     - This function sends a byte over the serial interface. In #
;#                    case of a transmit buffer overflow, it will return       #
;#                    immediately with an error status.                        #
;#    SCI_TX_BL     - This function sends a byte over the serial interface. It #
;#                    will block the program flow until the data can be handed #
;#                    over to the transmit queue.                              #
;#    SCI_TX_CHECK  - Checks if a transmission is ongoing.                     #
;#    SCI_TX_WAIT   - This function blocksthe program execution until all      #
;#                    pending data is sent.                                    #
;#    SCI_RX_NB     - This function reads a byte (and associated error flags)  #
;#                    It will return an error status if no read data is        #
;#                    available.                                               #
;#    SCI_RX_BL     - This function reads a byte (and associated error flags)  #
;#                    from the serial interface. It will block the             #
;#                    program flow until data is available.                    #
;#    SCI_RX_PEEK   - This function reads the oldest buffer entry and the      #
;#                    number receive buffer entries, without modifying the     #
;#                    buffer.                                                  #
;#    SCI_BAUD      - This function allows the application to set the SCI's    #
;#                    baud rate manually.                                      #
;#                                                                             #
;#    For convinience, all of these functions may also be called as macro.     #
;#                                                                             #
;#    Five error condition can occur when receiving data from the serial       #
;#    interface:                                                               #
;#    SWOR - Software Overrun (in RX Queue)                                    #
;#         The main program has failed to free up the RX queeue in time.       #
;#         The received data is considerd to be valid.                         #
;#         Baud rate detection will not be triggered.                          #
;#         This condition will be reported to the application.                 #       
;#                                                                             #
;#    OR - Overrun (in SCI hardware)                                           #
;#         The software has failed to transfer RX data to the RX queue in      #
;#         time.                                                               #
;#         The received data is considerd to be valid.                         #
;#         Baud rate detection will not be triggered.                          #
;#         This condition will be reported to the application.                 #       
;#                                                                             #
;#    NF - Noise (Flag)                                                        #
;#         Noise has been detected on the RX line.                             #
;#         The received data is still considerd to be valid.                   #
;#         Baud rate detection will be triggered.                              #
;#         This condition will not be reported to the application.             #       
;#                                                                             #
;#    FE - Framing Error                                                       #
;#         An invalid data frame (stop bit) has been received                  #
;#         The received data is considerd to be invalid.                       #
;#         If a sequence of invalid data is received, only one entry will be   #
;#         stored in the RX queue.                                             #
;#         Baud rate detection will be triggered.                              #
;#         This condition will be reported to the application.                 #       
;#                                                                             #
;#    PE - Parity Error (only occurs if parity is enabled)                     #
;#         An invalid parity bit has been received                             #
;#         The received data is considerd to be invalid.                       #
;#         If a sequence of invalid data is received, only one entry will be   #
;#         stored in the RX queue.                                             #
;#         Baud rate detection will be triggered.                              #
;#         This condition will be reported to the application.                 #       
;#                                                                             #
;#    The SCI module is capable of detecting the baud rate of received data.   #
;#    Whenever a framing error, a parity error or noise is detected, the baud  #
;#    rate detection is activated and the module begins measuring all high and #
;#    low pulses on the RX line. Assuming that the sender uses one of the      #
;#    following baud rates:     4800	                                       #
;#                              7200	                                       #
;#                              9600	                                       #
;#                             14400	                                       #
;#                             19200	                                       #
;#                             28800	                                       #
;#                             38400	                                       #
;#                             57600	                                       #
;#    ...it finds the senders baud rate by elimination. When the baud rate has #
;#    been detected (all but one of the valid baud rates eliminated) and 15    #
;#    consecutive low or high ulses match this baud rate, then the SCI will be #
;#    set to the new baud rate.	                                               #
;#    While the baud rate detection is active, a communication error will be   #
;#    signaled over the LED.                                                   #
;#                                                                             #
;#    The SCI driver supports hardware flow control (RTS/CTS) to allow 8-bit   #
;#    data transmissions. The flow control signals are implemented to using    #
;#    the following GPIO pins:  RTS input:  PM0                                #
;#                              CTS output: PM1                                #
;#    The remaining PM pins are unused.                                        #
;###############################################################################
;# Flow Control:                                                               #
;# RTS/CTS:                                                                    #
;#          Only transmit if RTS is set                                        #
;#          Forbid incoming data -> clear CTS                                  #
;#          Allow incoming data -> set CTS                                     #
;# XON/XOFF:                                                                   #
;#          Remember the last received XON/XOFF                                #
;#          Only transmit if XON was received last                             #
;#          Forbid incoming data                                               #
;#                                                                             #
;###############################################################################
;# Required Modules:                                                           #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    GPIO   - GPIO driver                                                     #
;#    TIM    - Timer driver                                                    #
;#    LED    - LED driver                                                      #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - The bus clock must be set to 24.576MHz                                 #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    April 22, 2010                                                           #
;#      - added functions SCI_TBE and SCI_BAUD                                 #
;#    June 6, 2010                                                             #
;#      - Changed selection of detectable baud rates                           #
;#      - Stop baud rate detection when receiving a corret character           #
;#      - Stop baud rate detection when manually setting the baud rate         #
;#    January 2, 2012                                                          #
;#      - Mini-BDM-Pod uses XON/XOFF flow control instead of RTS/CTS           #
;#    November 14, 2012                                                        #
;#      - Total redo                                                           #
;#    September 25, 2013                                                       #
;#      - Fixed reception of C0 characters                                     #
;#    February 5, 2014                                                         #
;#      - Made SCI_TXBUF_SIZE configurable                                     #
;###############################################################################

;###############################################################################
;# Baud rate detection                                                         #
;###############################################################################
;typ. bus speed:     25 MHz
;max. baud rate:  153600 baud   ==>  162 bus cycles per bit
;min. baud rate:    4800 baud   ==> 5208 bus cycles per bit (46875 per frame)

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;Bus frequency
#ifndef	CLOCK_BUS_FREQ
CLOCK_BUS_FREQ		EQU	25000000 	;default is 25MHz
#endif
	
;Invert RXD/TXD 
#ifndef	SCI_RXTX_ACTLO
#ifndef	SCI_RXTX_ACTHI
SCI_RXTX_ACTLO		EQU	1 		;default is active low RXD/TXD
#endif
#endif
	
;Flow control
;------------ 
;RTS/CTS or XON/XOFF
#ifndef	SCI_FC_RTSCTS
#ifndef	SCI_FC_XONXOFF
#ifndef SCI_FC_NONE	
SCI_FC_RTSCTS		EQU	1 		;default is SCI_RTSCTS
#endif
#endif
#endif

;XON/XOFF reminder intervall
#ifndef	SCI_XONXOFF_REMCNT
SCI_XONXOFF_REMINDER	EQU	(10*CLOCK_BUS_FREQ)/65536
#endif
	
;RTS/CTS pins
#ifdef	SCI_FC_RTSCTS
#ifndef	SCI_RTS_PORT
SCI_RTS_PORT		EQU	PTM 		;default is PTM
SCI_RTS_PIN		EQU	PM0		;default is PM0
#endif
#ifndef	SCI_CTS_PORT
SCI_CTS_PORT		EQU	PTM 		;default is PTM
SCI_CTS_PIN		EQU	PM1		;default is PM1
#endif
#endif

;Delay counter
;------------- 
#ifndef	SCI_DLY_TC
SCI_DLY_OC		EQU	$3		;default is OC3
#endif
	
;C0 character handling
;--------------------- 
;Detect BREAK character (use SCI_BREAK_ACTION macro)
#ifdef	SCI_HANDLE_BREAK
#ifdef	SCI_IGNORE_BREAK
SCI_IGNORE_BREAK	EQU	1 		;default is to ignore break chars
#endif
#endif
	
;Detect SUSPEND character (use SCI_SUSPEND_ACTION macro)
#ifdef	SCI_HANDLE_SUSPEND
#ifdef	SCI_IGNORE_SUSPEND
SCI_IGNORE_SUSPEND	EQU	1 		;default is to ignore suspend chars
#endif
#endif

;Baud rate detection 
;------------------- 
;Enable (SCI_BD_ON or SCI_BD_OFF)
#ifndef	SCI_BD_ON
#ifndef	SCI_BD_OFF
SCI_BD_ON		EQU	1 		;default is SCI_BD_ON
#endif
#endif

;ECT or TIM (SCI_BD_ECT or SCI_BD_TIM)
#ifndef	SCI_BD_TIM
#ifndef	SCI_BD_ECT
SCI_BD_TIM		EQU	1 		;default is TIM
#endif
#endif

;Input capture channels 
#ifndef	SCI_BD_TCPE
SCI_BD_ICPE		EQU	$0		;default is IC0
#endif
#ifndef	SCI_BD_TCNE
SCI_BD_ICNE		EQU	$1		;default is IC1			
#endif

#ifndef SCI_BD_TC
SCI_BD_IC		EQU	$0		;default is IC0		
#endif

;Output compare channels 
#ifndef	SCI_BD_OC
SCI_BD_OC		EQU	$2		;default is OC2			
#endif

;Log captured BD pulse length 
#ifndef	SCI_BD_LOG_ON
#ifndef	SCI_BD_LOG_OFF
SCI_BD_LOG_OFF		EQU	1 		;default is SCI_BD_LOG_OFF
#endif
#endif

;Communication error signaling
;----------------------------- 
;Enable error signaling (if enabled, macros SCI_ERRSIG_ON and SCI_ERRSIG_OFF must be defined)
#ifndef	SCI_ERRSIG_ON
#ifndef	SCI_ERRSIG_OFF
SCI_ERRSIG_OFF		EQU	1 		;default is no error signaling
#endif
#endif

;Blocking subroutines
;-------------------- 
;Enable blocking subroutines
#ifndef	SCI_BLOCKING_ON
#ifndef	SCI_BLOCKING_OFF
SCI_BLOCKING_OFF	EQU	1 		;blocking functions disabled by default
#endif
#endif

;TX buffer size (minimize to 1 for debugging) 
;-------------------------------------------- 
;SCI_TXBUF_SIZE		EQU	  1 		;minimum size of the transmit buffer

;.MC9S12DP25625 SCI IRQ workaround (MUCts00510)
;---------------------------------------------- 
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
#ifndef	SCI_IRQ_WORKAROUND_ON
#ifndef	SCI_IRQ_WORKAROUND_OFF
SCI_IRQ_WORKAROUND_OFF	EQU	1 		;IRQ workaround disabled by default
#endif
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Baud rate devider settings
; SCIBD = 25MHz / (16*baud rate)
SCI_1200        	EQU	(CLOCK_BUS_FREQ/(16*  1200))+(((2*CLOCK_BUS_FREQ)/(16*  1200))&1)	
SCI_2400        	EQU	(CLOCK_BUS_FREQ/(16*  2400))+(((2*CLOCK_BUS_FREQ)/(16*  2400))&1)	
SCI_4800        	EQU	(CLOCK_BUS_FREQ/(16*  4800))+(((2*CLOCK_BUS_FREQ)/(16*  4800))&1)	
SCI_7200        	EQU	(CLOCK_BUS_FREQ/(16*  7200))+(((2*CLOCK_BUS_FREQ)/(16*  7200))&1)	
SCI_9600        	EQU	(CLOCK_BUS_FREQ/(16*  9600))+(((2*CLOCK_BUS_FREQ)/(16*  9600))&1)	
SCI_14400       	EQU	(CLOCK_BUS_FREQ/(16* 14400))+(((2*CLOCK_BUS_FREQ)/(16* 14400))&1)	
SCI_19200       	EQU	(CLOCK_BUS_FREQ/(16* 19200))+(((2*CLOCK_BUS_FREQ)/(16* 19200))&1)	
SCI_28800       	EQU	(CLOCK_BUS_FREQ/(16* 28800))+(((2*CLOCK_BUS_FREQ)/(16* 28800))&1)	
SCI_38400       	EQU	(CLOCK_BUS_FREQ/(16* 38400))+(((2*CLOCK_BUS_FREQ)/(16* 38400))&1)	
SCI_57600       	EQU	(CLOCK_BUS_FREQ/(16* 57600))+(((2*CLOCK_BUS_FREQ)/(16* 57600))&1)	
SCI_76800       	EQU	(CLOCK_BUS_FREQ/(16* 76800))+(((2*CLOCK_BUS_FREQ)/(16* 76800))&1)	
SCI_115200		EQU	(CLOCK_BUS_FREQ/(16*115200))+(((2*CLOCK_BUS_FREQ)/(16*115200))&1)	
SCI_153600		EQU	(CLOCK_BUS_FREQ/(16*153600))+(((2*CLOCK_BUS_FREQ)/(16*153600))&1)
SCI_BDEF		EQU	SCI_9600 			;default baud rate
SCI_BMUL		EQU	$FFFF/SCI_153600	 	;Multiplicator for storing the baud rate
		
;#Frame format
SCI_8N1			EQU	  ILT		;8N1
SCI_8E1			EQU	  ILT|PE	;8E1
SCI_8O1			EQU	  ILT|PE|PT	;8O1
SCI_8N2		 	EQU	M|ILT		;8N2 TX8=1
	
;#C0 characters
SCI_C0_MASK		EQU	$E0 		;mask for C0 character range
SCI_BREAK		EQU	$03 		;ctrl-c (terminate program execution)
SCI_DLE			EQU	$10		;data link escape (treat next byte as data)
SCI_XON			EQU	$11 		;unblock transmission 
SCI_XOFF		EQU	$13		;block transmission
SCI_SUSPEND		EQU	$1A 		;ctrl-z (suspend program execution)

;#Buffer sizes		
SCI_RXBUF_SIZE		EQU	 16*2		;size of the receive buffer (8 error:data entries)
#ifndef	SCI_TXBUF_SIZE	
SCI_TXBUF_SIZE		EQU	  8		;size of the transmit buffer
#endif
SCI_RXBUF_MASK		EQU	$1F		;mask for rolling over the RX buffer
;SCI_TXBUF_MASK		EQU	$07		;mask for rolling over the TX buffer
SCI_TXBUF_MASK		EQU	$01		;mask for rolling over the TX buffer

;#Hardware handshake borders
SCI_RX_FULL_LEVEL	EQU	 8*2		;RX buffer threshold to block transmissions 
SCI_RX_EMPTY_LEVEL	EQU	 2*2		;RX buffer threshold to unblock transmissions
	
;#Flag definitions
SCI_FLG_SEND_XONXOFF	EQU	$80		;send XON/XOFF symbol asap
SCI_FLG_POLL_RTS	EQU	$40		;poll RTS input
SCI_FLG_SWOR		EQU	$10		;software buffer overrun (RX buffer)
SCI_FLG_TX_BLOCKED	EQU	$08		;don't transmit (XOFF received)
SCI_FLG_RX_ESC		EQU	$04		;character is to be escaped
SCI_FLG_TX_ESC		EQU	$02		;character is to be escaped

;#Timer setup
#ifdef SCI_BD_ON	
#ifdef	SCI_BD_TIM
SCI_SET_TIOS		EQU	1
SCI_BD_TIOS_VAL		EQU	(1<<SCI_BD_OC)
SCI_SET_TCTL3		EQU	1
SCI_BD_TCTL3_VAL	EQU 	(1<<(2*SCI_BD_ICPE))|(2<<(2*SCI_BD_ICNE))
#else
#ifdef	SCI_BD_ECT
SCI_SET_TIOS		EQU	1
SCI_BD_TIOS_VAL		EQU	(1<<SCI_BD_OC)
SCI_SET_TCTL3		EQU	1
SCI_BD_TCTL3_VAL	EQU 	(3<<(2*SCI_BD_IC))
SCI_SET_ICSYS		EQU	1
#else
SCI_BD_TIOS_VAL		EQU	0
#endif	
#endif
#else
SCI_BD_TIOS_VAL		EQU	0
#endif	
#ifdef	SCI_FC_RTSCTS
SCI_SET_TIOS		EQU	1
SCI_DLY_TIOS_VAL	EQU	(1<<SCI_DLY_OC)
#else
#ifdef	SCI_FC_XONXOFF
SCI_SET_TIOS		EQU	1
SCI_DLY_TIOS_VAL	EQU	(1<<SCI_DLY_OC)
#else
#ifdef	SCI_IRQ_WORKAROUND_ON
SCI_SET_TIOS		EQU	1
SCI_DLY_TIOS_VAL	EQU	(1<<SCI_DLY_OC)
#else
SCI_DLY_TIOS_VAL	EQU	0
#endif
#endif
#endif	

;#Baud rate detection
SCI_BD_RECOVCNT_INIT	EQU	8
SCI_BD_LIST_INIT	EQU	$FF
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef SCI_VARS_START_LIN
			ORG 	SCI_VARS_START, SCI_VARS_START_LIN
#else
			ORG 	SCI_VARS_START
SCI_VARS_START_LIN	EQU	@			
#endif	

SCI_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1
;#Receive buffer	
SCI_RXBUF		DS	SCI_RXBUF_SIZE
SCI_RXBUF_IN		DS	1		;points to the next free space
SCI_RXBUF_OUT		DS	1		;points to the oldest entry
;#Transmit buffer
SCI_TXBUF		DS	SCI_TXBUF_SIZE
SCI_TXBUF_IN		DS	1		;points to the next free space
SCI_TXBUF_OUT		DS	1		;points to the oldest entry
;#Baud rate (reset proof) 
SCI_BVAL		DS	2		;value of the SCIBD register *SCI_BMUL

;#XON/XOFF reminder count
#ifdef	SCI_FC_XONXOFF
SCI_XONXOFF_REMCNT	DS	2		;counter for XON/XOFF reminder
#endif

;#BD log buffer
#ifdef SCI_BD_ON	
#ifdef SCI_BD_LOG_ON	
SCI_BD_LOG_IDX		DS	2
SCI_BD_LOG_BUF		DS	4*32
SCI_BD_LOG_BUF_END	EQU	*
#endif
#endif
	
SCI_AUTO_LOC2		EQU	*		;2nd auto-place location

;#Flags
SCI_FLGS		EQU	((SCI_AUTO_LOC1&1)*SCI_AUTO_LOC1)+(((~SCI_AUTO_LOC1)&1)*SCI_AUTO_LOC2)
			UNALIGN	((~SCI_AUTO_LOC1)&1)
	
;#Baud rate detection registers
#ifdef SCI_BD_ON
;SCI_BD_RECOVCNT	DS	1		;recover counter
SCI_BD_LIST		DS	1		;list of potential baud rates
#endif

	
SCI_VARS_END		EQU	*
SCI_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SCI_INIT, 0
			;Initialize queues and state flags	
			LDD	#$0000
			STD	SCI_TXBUF_IN 				;reset in and out pointer of the TX buffer
			STD	SCI_RXBUF_IN 				;reset in and out pointer of the RX buffer
#ifdef SCI_FC_XONXOFF
			MOVB	#SCI_FLG_SEND_XONXOFF,	SCI_FLGS 	;request transmission of XON/XOFF
#else
			STAA	SCI_FLGS
#endif
			;Initialize baud rate detection
#ifdef SCI_BD_ON	
;			STD	SCI_BD_RECOVCNT 			;reset baud rate check list and recovery count
			STAA	SCI_BD_LIST	 			;reset baud rate check list
#endif	

			;Initialize timer
#ifdef	SCI_SET_TIOS
			BSET	TIOS, #(SCI_DLY_TIOS_VAL|SCI_BD_TIOS_VAL)
#endif	
#ifdef	SCI_SET_ICSYS
			MOVB	#BUFEN, ICSYS
#endif	
	
			;Invert RXD/TXD polarity
#ifdef	SCI_RXTX_ACTHI
			MOVB	#(TXPOL|RXPOL), SCISR2
#endif
	
			;Set baud rate
			;Check for POR
#ifdef	CLOCK_FLGS
			LDAB	CLOCK_FLGS
			BITA	#(PORF|LVRF)
			BNE	<SCI_INIT_2
#endif
			;Check if stored baud rate is still valid
			LDD	SCI_BVAL 				;SCI_BMUL*baud rate -> D
			BEQ	<SCI_INIT_2				;use default value if zero
			LDX	#SCI_BMUL				;SCI_BMUL -> X
			IDIV						;D/X -> X, D%X -> D
			CPD	#$0000					;check if the remainder is 0
			BNE	<SCI_INIT_2				;stored baud rate is invalid
			;Check if baud rate is listed 
			LDY	#SCI_BTAB				;start of baud table -> Y
SCI_INIT_1		CPX     2,Y+					;compare table entry with X	
			BEQ	<SCI_INIT_3				;match
			CPY	#SCI_BTAB_END				;check if the end of the table has been reached
			BNE	<SCI_INIT_1				;loop
			;No match use default
SCI_INIT_2		LDX	#SCI_BDEF	 			;default baud rate
			MOVW	#(SCI_BDEF*SCI_BMUL), SCI_BVAL
			;Match 
SCI_INIT_3		STX	SCIBDH					;set baud rate

			;Set frame format and enable transmission
#ifdef	SCI_FC_XONXOFF	
			MOVW	#((SCI_8N1<<8)|TXIE|RIE|TE|RE), SCICR1 	;8N1 (transmit XON)
#else
			MOVW	#((SCI_8N1<<8)|RIE|TE|RE), SCICR1 	;8N1 (keep TX IRQs disabled)
#endif	
			;Initialize CTS 
			SCI_ASSERT_CTS

			;Initialize baud rate detection
#ifdef	SCI_BD_ON
			;BSET	TCTL3, #(SCI_BD_TCTL3_VAL>>8)
			BSET	TCTL4, #(SCI_BD_TCTL3_VAL&$00FF)
#endif	
	
#ifdef	SCI_IRQ_WORKAROUND_ON
			;Trigger periodic interrupt
			SCI_ISR_DELAY_RETRIGGER 
#endif
#emac
	
;#Functions	
;#Transmit one byte - non-blocking
; args:   B:      data to be send
; result: C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX_NB, 0
			SSTACK_JOBSR	SCI_TX_NB, 5
#emac
	
;#Transmit one byte - blocking
; args:   B: data to be send
; SSTACK: 7 bytes
;         X, Y, and D are preserved 
#ifdef	SCI_BLOCKING_ON
#macro	SCI_TX_BL, 0
			SSTACK_JOBSR	SCI_TX_BL, 7
#emac
#else
#macro	SCI_TX_BL, 0
			SCI_CALL_BL	SCI_TX_NB, 5
#emac
#endif
	
;#Check if a transmission is ongoing
; args:   none
; result:  C-flag: set if all transmissionsare complete
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX_DONE_NB, 0
			SSTACK_JOBSR	SCI_TX_DONE_NB, 4
#emac
	
;#Wait until all pending data is sent
; args:   none
; result: A: number of entries left in TX queue
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
#ifdef	SCI_BLOCKING_ON
#macro	SCI_TX_DONE_BL, 0
			SSTACK_JOBSR	SCI_TX_DONE_BL, 6
#emac
#else
#macro	SCI_TX_DONE_BL, 0
			SCI_CALL_BL 	SCI_TX_DONE_NB, 4
#emac
#endif
		
;#Check if TX queue can hold further data
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX_READY_NB, 0
			SSTACK_JOBSR	SCI_TX_READY_NB, 4
#emac

;#Wait until TX queue can hold further data
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
#ifdef	SCI_BLOCKING_ON
#macro	SCI_TX_READY_BL, 0
			SSTACK_JOBSR	SCI_TX_READY_BL, 6
#emac
#else
#macro	SCI_TX_READY_BL, 0
			SCI_CALL_BL	SCI_TX_READY_NB, 4
#emac
#endif

;#Receive one byte - non-blocking
; args:   none
; result: A:      error flags 
;         B:      received data 
;         C-flag: set if successful
; SSTACK: 4 bytes
;         X and Y are preserved 
#macro	SCI_RX_NB, 0
			SSTACK_JOBSR	SCI_RX_NB, 4
#emac

;#Receive one byte - blocking
; args:   none
; result: A: error flags 
;         B: received data
; SSTACK: 6 bytes
;         X and Y are preserved 
#ifdef	SCI_BLOCKING_ON
#macro	SCI_RX_BL, 0
			SSTACK_JOBSR	SCI_RX_BL, 6
#emac
#else
#macro	SCI_RX_BL, 0
			SCI_CALL_BL 	SCI_RX_NB, 4
#emac
#endif

;#Check if there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and B are preserved 
#macro	SCI_RX_READY_NB, 0
			SSTACK_JOBSR	SCI_RX_READY_NB, 4
#emac

;#Wait until there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         X, Y and B are preserved 
#ifdef	SCI_BLOCKING_ON
#macro	SCI_RX_READY_BL, 0
			SSTACK_JOBSR	SCI_RX_READY_BL, 6
#emac
#else
#macro	SCI_RX_READY_BL, 0
			SCI_CALL_BL 	SCI_RX_READY_NB, 4
#emac
#endif
	
;#Set baud rate
; args:   D: new SCIBD value
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
#macro	SCI_SET_BAUD, 0
			SSTACK_JOBSR	SCI_SET_BAUD, 6
#emac

;# Macros for internal use

;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function 
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
#macro	SCI_MAKE_BL, 2
			;Disable interrupts
LOOP			SEI
			;Call non-blocking function
			//SSTACK_PREPUSH	\2
			JOBSR	\1
			BCC	WAIT 		;function unsuccessful
			;Enable interrupts
			CLI
			;Done
			SSTACK_PREPULL	2
			RTS
			;Wait for next interrupt 
WAIT			ISTACK_WAIT
			;Try again
			SSTACK_PREPUSH	\2
			JOB	LOOP	
#emac

;#Run a non-blocking subroutine as if it was blocking	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function 
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
#macro	SCI_CALL_BL, 2
			;Disable interrupts
LOOP			SEI
			;Call non-blocking function
			SSTACK_JOBSR	\1, \2
			BCS	DONE 		;function successful
			;Wait for next interrupt 
			ISTACK_WAIT
			;Try again
			JOB	LOOP
			;Enable interrupts
DONE			CLI
#emac
	
;#Assert CTS (allow incoming data)
; args:   none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SCI_ASSERT_CTS, 0
#ifdef	SCI_FC_RTSCTS
			BCLR	SCI_CTS_PORT, #SCI_CTS_PIN 		;clear CTS (allow RX data)
#endif	
#emac	

;#Deassert CTS (stop incoming data)
; args:   none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SCI_DEASSERT_CTS, 0
#ifdef	SCI_FC_RTSCTS
			BSET	SCI_CTS_PORT, #SCI_CTS_PIN 		;set CTS (allow RX data)
#endif	
#emac	

;#Send XON/XOFF symbol
; args:   none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SCI_SEND_XONXOFF, 0
#ifdef SCI_FC_XONXOFF
			BSET	SCI_FLGS, #SCI_FLG_SEND_XONXOFF		;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), SCICR2 		;enable TX interrupts	
#endif	
#emac	

;#Decrement XON/XOFF reminder count
; args:   1: exit point, in case the XON/XOFF reminder is disabled
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_DEC_XONXOFF_REMCNT, 1
			LDD	SCI_XONXOFF_REMCNT
			BEQ	\1 					;XON/XOFF reminder disabled
			DBNE	D, STORE_REMCNT				;don't send XON/XOFF yet
			BSET	SCI_FLGS, #SCI_FLG_SEND_XONXOFF 	;send XON/XOFF asap
STORE_REMCNT		STD	SCI_XONXOFF_REMCNT
#emac

;#Start delay (approx. 2 SCI frames)
; args:   none 
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_START_DELAY, 0
			BRSET	TIE, #(1<<SCI_DLY_OC), DONE 		;skip if delay has already been triggered
			SCI_RESET_DELAY
			TIM_EN		SCI_DLY_OC
DONE			EQU	*
#emac

;#RESET delay (approx. 2 SCI frames)
; args:   none 
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_RESET_DELAY, 0
			TIM_CLRIF   	SCI_DLY_OC
			LDD	SCIBDH 					;retrigger delay
			TBNE	A, MAX_DELAY				;max. delay ($FFFF) exceeded
			TFR	B, A					;determine delay
			CLRB
			TIM_SET_DLY_D	SCI_DLY_OC			;update OC count
MAX_DELAY		EQU	*
#emac

;#Stop delay (approx. 2 SCI frames)
; args:   none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SCI_STOP_DELAY, 0
			TIM_DIS		SCI_DLY_OC
			EQU	*
#emac
	
;#Turn on error signaling
; args:   none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SCI_ERRSIG_ON, 0
#ifdef	SCI_ERRSIG_ON
			LED_COMERR_ON
#endif	
#emac	

;#Turn off error signaling
; args:   none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SCI_ERRSIG_OFF, 0
#ifdef	SCI_ERRSIG_ON
			LED_COMERR_OFF
#endif	
#emac	

;Start baud rate detection (I-bit must be set)
; args:   none 
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_START_BD, 0
#ifdef	SCI_BD_ON
			TST	SCI_BD_LIST
			BNE	DONE 					;baud rate detection is already running
			;Clear BD log 
			SCI_BD_CLEAR_LOG
			;Enable timer
#ifdef	SCI_BD_TIM
			TIM_MULT_EN	((1<<SCI_BD_ICPE)|(1<<SCI_BD_ICNE))
#endif
#ifdef	SCI_BD_ECT
			TIM_MULT_EN	(1<<SCI_BD_IC)
#endif
			;Make sure that the timeout bit is set
			BRSET	TFLG1, #(1<<SCI_BD_OC), SKIP
			;SEI
			TIM_SET_DLY_IMM	SCI_BD_OC, 6
			;CLI
SKIP			EQU	*	
			;Reset baud rate list and recover counter
			MOVB	#SCI_BD_LIST_INIT, SCI_BD_LIST
			;Start edge detection
			SCI_BD_START_EDGE_DETECT
;DONE			MOVB	#SCI_BD_RECOVCNT_INIT, SCI_BD_RECOVCNT
DONE			EQU	*
#endif	
#emac	
	
;Stop baud rate detection
; args:   none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SCI_STOP_BD, 0
#ifdef	SCI_BD_ON
			BRCLR	SCI_BD_LIST, #$FF, DONE			;baud rate detection already inactive
			;Stop edge detection
			SCI_BD_STOP_EDGE_DETECT
			;Disable timer
#ifdef	SCI_BD_TIM
			TIM_MULT_DIS	((1<<SCI_BD_ICPE)|(1<<SCI_BD_ICNE)|(1<<SCI_BD_OC))
#endif
#ifdef	SCI_BD_ECT
			TIM_MULT_DIS	((1<<SCI_BD_ICPE)|(1<<SCI_BD_IC)|(1<<SCI_BD_IC)|(1<<SCI_BD_OC))
#endif
;			MOVW	#$0000,	SCI_BD_RECOVCNT			;clear recovery count and BD list
;									;This must be the last instruction in the macro!!!
;									;See  SCI_ISR_RX_2
			CLR	SCI_BD_LIST 				;clear check list
DONE			EQU	*
#endif
#emac

;Start edge detection
; args:   none 
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_BD_START_EDGE_DETECT, 0
			;BSET	TCTL3, #(SCI_BD_TCTL3_VAL>>8)		;start edge detection
			BSET	TCTL4, #(SCI_BD_TCTL3_VAL&$00FF)
#emac

;Stop edge detection
; args:   none 
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_BD_STOP_EDGE_DETECT, 0
			;BCLR	TCTL3, #(SCI_BD_TCTL3_VAL>>8)		;stop edge detection
			BCLR	TCTL4, #(SCI_BD_TCTL3_VAL&$00FF)
#emac

;Clear BD pulse log
; args:   none 
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_BD_CLEAR_LOG, 0
#ifdef	SCI_BD_LOG_ON
			TFR	Y,D
			LDY	#SCI_BD_LOG_BUF
			STY	SCI_BD_LOG_IDX
LOOP			MOVW	#$0000, 2,Y+
			CPY	#SCI_BD_LOG_BUF_END
			BLO	LOOP
			TFR	D,Y
#endif
#emac

;Log BD pulse length
; args: X: pulse length
;       Y: search tree pointer 
; SSTACK: none
;         X, and Y are preserved 
#macro	SCI_BD_LOG, 0
#ifdef	SCI_BD_LOG_ON
		TFR	Y,D
		LDY	SCI_BD_LOG_IDX
		CPY	#SCI_BD_LOG_BUF_END
		BHS	DONE
		STD	2,Y+
		STX	2,Y+
		STY	SCI_BD_LOG_IDX
DONE		TFR	D,Y
#endif
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef SCI_CODE_START_LIN
			ORG 	SCI_CODE_START, SCI_CODE_START_LIN
#else
			ORG 	SCI_CODE_START
#endif
	
;#Transmit one byte - non-blocking
; args:   B: data to be send
; result: C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and D are preserved 
SCI_TX_NB		EQU	*
			;Save registers (data in B)
			PSHY
			PSHA
			;Write data into the TX buffer (data in B)
			LDY	#SCI_TXBUF
			LDAA	SCI_TXBUF_IN
			STAB	A,Y
			;Check if there is room for this entry (data in B, in-index in A, TX buffer pointer in Y)
			INCA						;increment index
			ANDA	#SCI_TXBUF_MASK
			CMPA	SCI_TXBUF_OUT
			BEQ	SCI_TX_NB_1 				;buffer is full
			;Update buffer
			STAA	SCI_TXBUF_IN
			;Enable interrupts 
			MOVB	#(TXIE|RIE|TE|RE), SCICR2				;enable TX interrupt
			;Restore registers
			SSTACK_PREPULL	5
			PULA
			PULY
			;Signal success
			SEC
			;Done
			RTS
			;Buffer is full 
			;Restore registers
SCI_TX_NB_1		SSTACK_PREPULL	5
			PULA
			PULY
			;Signal failure
			CLC
			;Done
			RTS
			
;#Transmit one byte - blocking
; args:   B: data to be send
; result: none
; SSTACK: 7 bytes
;         X, Y, and D are preserved 
#ifdef	SCI_BLOCKING_ON
SCI_TX_BL		EQU	*
			SCI_MAKE_BL	SCI_TX_NB, 5
#endif
	
;#Check if a transmission is ongoing
; args:   none
; result:  C-flag: set if all transmissionsare complete
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
SCI_TX_DONE_NB		EQU	*
			;Save registers
			PSHD
			;Check TX queue
			LDD	SCI_TXBUF_IN
			CBA
			BNE	SCI_TX_DONE_NB_1 ;transmissions queued
			;Check SCI status
			BRSET	SCISR1, #(TDRE|TC), SCI_TX_DONE_NB_2 ;all transmissionscomplete
			;Transmissions ongoing
			;Restore registers	
SCI_TX_DONE_NB_1	SSTACK_PREPULL	4
			PULD
			;Signal failure
			CLC
			;Done
			RTS
			;All transmissions complete
			;Restore registers	
SCI_TX_DONE_NB_2	SSTACK_PREPULL	4
			PULD
			;Signal failure
			SEC
			;Done
			RTS
		
;#Wait until all pending data is sent
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
#ifdef	SCI_BLOCKING_ON
SCI_TX_DONE_BL		EQU	*
			SCI_MAKE_BL	SCI_TX_DONE_NB, 4	
#endif

;#Check if TX queue can hold further data
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
SCI_TX_READY_NB		EQU	*
			;Save registers
			PSHD
			;Check if there is room for this entry
			LDD	SCI_TXBUF_IN 		;in-index in A, out-index in B
			INCA
			ANDA	#SCI_TXBUF_MASK
			CMPA	SCI_TXBUF_OUT
			BEQ	SCI_TX_READY_NB_1 				;buffer is full			
			;Restore registers
			SSTACK_PREPULL	4
			PULD
			;Done
			SEC
			RTS
			;TX buffer is full
SCI_TX_READY_NB_1	SSTACK_PREPULL	4
			PULD
			;Done
			CLC
			RTS

;#Wait until TX queue can hold further data
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
#ifdef	SCI_BLOCKING_ON
SCI_TX_READY_BL		EQU	*
			SCI_MAKE_BL	SCI_TX_READY_NB, 4	
#endif

;#Receive one byte - non-blocking ;OK!
; args:   none
; result: A:      error flags 
;         B:      received data
;	  C-flag: set if successful
; SSTACK: 4 bytes
;         X and Y are preserved 
SCI_RX_NB		EQU	*
			;Save registers
			PSHX
			;Check if there is data in the RX queue
			LDD	SCI_RXBUF_IN 				;A:B=in:out
			SBA		   				;A=in-out
			BEQ	SCI_RX_NB_2 				;RX buffer is empty
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_RX_EMPTY_LEVEL
			BEQ	SCI_RX_NB_3 				;unblock flow control
			;Pull entry from the RX queue (out-index in B)
SCI_RX_NB_1		LDX	#SCI_RXBUF
			LDX	B,X
			ADDB	#$02					;increment out pointer
			ANDB	#SCI_RXBUF_MASK
			STAB	SCI_RXBUF_OUT
			;MOVB	#(TXIE|RIE|TE|RE), SCICR2		;trigger RXTX ISR
			TFR	X, D 
			;Restore registers
			SSTACK_PREPULL	4
			PULX
			;Done
			SEC
			RTS
			;RX buffer is empty (CCR in X)
SCI_RX_NB_2		SSTACK_PREPULL	4
			PULX
			;Done
			CLC
			RTS
			;Unblock flow control (out-index in B, CCR in X)			
SCI_RX_NB_3		EQU	*
			SCI_ASSERT_CTS
			SCI_SEND_XONXOFF
			JOB	SCI_RX_NB_1	
	
;#Receive one byte - blocking
; args:   none
; result: A:      error flags 
;         B:      received data
;	  C-flag: set if successful
; SSTACK: 6 bytes
;         X and Y are preserved 
#ifdef	SCI_BLOCKING_ON
SCI_RX_BL		EQU	*
			SCI_MAKE_BL	SCI_RX_NB, 4
#endif

;#Check if there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and D are preserved 
SCI_RX_READY_NB		EQU	*
			;Save registers
			PSHD
			;Check if there is data in the RX queue
			LDD	SCI_RXBUF_IN 		;A:B=in:out
			CBA
			BEQ	SCI_RX_READY_NB_1
			;RX buffer holds data
			SSTACK_PREPULL	4
			PULD
			;Done
			SEC
			RTS
			;RX buffer is empty
SCI_RX_READY_NB_1	SSTACK_PREPULL	4
			PULD
			;Done
			CLC
			RTS

;#Wait until there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and D are preserved 
#ifdef	SCI_BLOCKING_ON
SCI_RX_READY_BL		EQU	*
			SCI_MAKE_BL	SCI_RX_READY_BL, 4
#endif
	
;#Set baud rate
; args:   D: new SCIBD value
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
SCI_SET_BAUD		EQU	*
			;Save registers (new SCIBD value in D)
			PSHY 					;push Y onto the SSTACK
			PSHD					;push D onto the SSTACK
			;Set baud rate (new SCIBD value in D)
			STD	SCIBDH				;set baud rate
			LDY	#SCI_BMUL			;save baud rate for next warmstart
			EMUL					;D*Y -> Y:D
			STD	SCI_BVAL
			;Clear input buffer
			MOVW	#$0000, SCI_RXBUF_IN		;reset in and out pointer of the RX buffer
			;Restore registers
			SSTACK_PREPULL	6
			PULD					;pull D from the SSTACK
			PULY					;pull Y from the SSTACK
			;Done
			RTS

;#Timer delay
; period: approx. 2 SCI frames
; RTS/CTS:    if RTS polling is requested (SCI_FLG_POLL_RTS) -> enable TX IRQ
; XON/XOFF:   if reminder count == 1 -> request XON/XOFF reminder, enable TX IRQ
;	      if reminder count > 1  -> decrement reminder count, retrigger delay
; workaround: retrigger delay, jump to SCI_ISR_RXTX
SCI_ISR_DELAY		EQU	*
#ifndef	SCI_IRQ_WORKAROUND_ON
			CLC								;don't retrigger
#endif
#ifdef	SCI_FC_RTSCTS
			;Poll RTS (retrigger request in C-flag)
        		BRCLR	SCI_FLGS, #SCI_FLG_POLL_RTS, SCI_ISR_DELAY_2 		;no polling required	
			;BRSET	SCI_RTS_PORT, #SCI_RTS_PIN, SCI_ISR_DELAY_1 		;RTS is now set
			BRCLR	SCI_RTS_PORT, #SCI_RTS_PIN, SCI_ISR_DELAY_1 		;RTS is now set
#ifndef	SCI_IRQ_WORKAROUND_ON
			SEC								;retrigger
#endif
			JOB	SCI_ISR_DELAY_2
SCI_ISR_DELAY_1		MOVB	#(TXIE|RIE|TE|RE), SCICR2				;invoke RXTX ISR
SCI_ISR_DELAY_2		EQU	*
#endif
#ifdef	SCI_FC_XONXOFF
			;Check XON/XOFF reminder count (retrigger request in C-flag)
			LDD	SCI_XONXOFF_REMCNT
			BEQ	SCI_ISR_DELAY_5	 					;XON/XOFF reminder disabled
			DBNE	D, SCI_ISR_DELAY_3					;don't send XON/XOFF yet
			BSET	SCI_FLGS, #SCI_FLG_SEND_XONXOFF 			;request XON/XOFF reminder
			MOVB	#(TXIE|RIE|TE|RE), SCICR2				;invoke RXTX ISR
			JOB	SCI_ISR_DELAY_4
SCI_ISR_DELAY_3		EQU	*
#ifndef	SCI_IRQ_WORKAROUND_ON
			SEC								;retrigger
#endif
SCI_ISR_DELAY_4		STD	SCI_XONXOFF_REMCNT
SCI_ISR_DELAY_5		EQU	*
#endif
#ifdef	SCI_IRQ_WORKAROUND_ON
			;Retrigger and jump to SCI_ISR_RXTX (retrigger request in C-flag)
			SCI_RESET_DELAY
			JOB	SCI_ISR_RXTX						;jump to RXTX ISR
#else
			;Retrigger if required (retrigger request in C-flag)
			BCC	SCI_ISR_DELAY_7
			SCI_RESET_DELAY
SCI_ISR_DELAY_6		ISTACK_RTI			
SCI_ISR_DELAY_7		SCI_STOP_DELAY
			JOB	SCI_ISR_DELAY_6	
#endif

			;#Transmit ISR (status flags in A)
SCI_ISR_TX		EQU	*
			BITA	#TDRE					;check if SCI is ready for new TX data
			BEQ	<SCI_ISR_TX_4				;done for now
#ifdef	SCI_FC_XONXOFF
			;Don't escape any XON/XOFF symbol
			BRSET	SCI_FLGS, #SCI_FLG_TX_ESC, SCI_ISR_TX_1 ;Don't escape any XON/XOFF symbols
			;Transmit XON/XOFF symbols
			BRCLR	SCI_FLGS, #SCI_FLG_SEND_XONXOFF, SCI_ISR_TX_1 ;XON/XOFF not requested
			;Clear XON/XOFF request
			BCLR	SCI_FLGS, #SCI_FLG_SEND_XONXOFF
			;Check RX queue
			LDD	SCI_RXBUF_IN
			SBA			
			ANDA	#SCI_RXBUF_MASK
			;Check XOFF theshold
			CMPA	#SCI_RX_FULL_LEVEL
			BHS	<SCI_ISR_TX_6	 			;transmit XOFF
			;Check XON theshold
			CMPA	#SCI_RX_EMPTY_LEVEL
			BLS	<SCI_ISR_TX_5	 			;transmit XON
			;Check XOFF status
			BRSET	SCI_FLGS, #SCI_FLG_TX_BLOCKED, SCI_ISR_TX_3 ;stop transmitting
#endif
#ifdef	SCI_FC_RTSCTS
			;Check RTS status
			;BRSET	SCI_RTS_PORT, #SCI_RTS_PIN, SCI_ISR_TX_1;check TX buffer
			BRCLR	SCI_RTS_PORT, #SCI_RTS_PIN, SCI_ISR_TX_1;check TX buffer
        		BSET	SCI_FLGS, #SCI_FLG_POLL_RTS		;request RTS polling	
			SCI_START_DELAY					;start delay
			JOB	SCI_ISR_TX_3				;stop transmitting
#endif
			;Check TX buffer
SCI_ISR_TX_1		LDD	SCI_TXBUF_IN
			CBA
			BEQ	<SCI_ISR_TX_3 				;stop transmitting
			;Transmit data (in-index in A, out-index in B)
			LDY	#SCI_TXBUF
#ifdef	SCI_FC_XONXOFF
			;Check for DLE
			BCLR	SCI_FLGS, #SCI_FLG_TX_ESC
			TFR	D, X
			LDAB	B,Y
			CMPB	#SCI_DLE
			BNE	SCI_ISR_TX_2
			BSET	SCI_FLGS, #SCI_FLG_TX_ESC
SCI_ISR_TX_2		STAB	SCIDRL	
			TFR	X, D
#else	
			MOVB	B,Y ,SCIDRL
#endif
			;Increment index
			INCB
			ANDB	#SCI_TXBUF_MASK
			STAB	SCI_TXBUF_OUT
			CBA
			BNE	<SCI_ISR_TX_4 				;done	
			;Stop transmitting
SCI_ISR_TX_3		EQU	*
#ifdef SCI_FC_XONXOFF
			BRSET	SCI_FLGS, #SCI_FLG_TX_ESC, SCI_ISR_TX_4 ;consider pending XON/XOFF symbols
#endif	
			MOVB	#(RIE|TE|RE), SCICR2 			;disable TX interrupts	
			;Done
SCI_ISR_TX_4		ISTACK_RTI
#ifdef SCI_FC_XONXOFF
			;Transmit XON
SCI_ISR_TX_5		MOVB	#SCI_XON, SCIDRL
			JOB	SCI_ISR_TX_7				;schedule reminder	
			;Transmit XOFF
SCI_ISR_TX_6		MOVB	#SCI_XOFF, SCIDRL
			;Schedule reminder
SCI_ISR_TX_7		MOVW	#SCI_XONXOFF_REMINDER, SCI_XONXOFF_REMCNT
			SCI_START_DELAY					;start delay
			JOB	SCI_ISR_TX_4 				;done	
#endif	

;#Receive/Transmit ISR (Common ISR entry point for the SCI)
SCI_ISR_RXTX		EQU	*
			;Common entry point for all SCI interrupts
			;Load flags
			LDAA	SCISR1					;load status flags into accu A
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
#ifdef 	RDRFF								;RDRF is also the Reduced Drive Register for port F
			BITA	#(RDRFF|OR) 				;go to receive handler if receive buffer
#else	
			BITA	#(RDRF|OR) 				;go to receive handler if receive buffer
#endif
			BEQ	SCI_ISR_TX				; is full or if an overrun has occured
			
;#Receive ISR (status flags in A)
SCI_ISR_RX		LDAB	SCIDRL					;load receive data into accu B (clears flags)
			;Transfer SWOR flag to current error flags (status flags in A, RX data in B)
			ANDA	#(OR|NF|FE|PF)				;only maintain relevant error flags
			BRCLR	SCI_FLGS, #SCI_FLG_SWOR, SCI_ISR_RX_1	;SWOR bit not set
			ORAA	#SCI_FLG_SWOR				;set SWOR bit in accu A
			BCLR	SCI_FLGS, #SCI_FLG_SWOR 		;clear SWOR bit in variable	
SCI_ISR_RX_1		EQU	*
			;Check for RX errors (status flags in A, RX data in B)
			BITA	#(NF|FE|PF) 				;check for: noise, frame errors, parity errors
			BNE	<SCI_ISR_RX_8				;RX error detected (skip special caracter detection)
			;No RX error detected (status flags in A, RX data in B)
#ifndef SCI_BD_ON
			SCI_ERRSIG_OFF					;clear error signal immediately if there is no baud rate detection
#endif	
;			DEC	SCI_BD_RECOVCNT				;decrement recovery count if >$00
;			BCS	<SCI_ISR_RX_2 				;keep recovery count at $00
;			BNE	<SCI_ISR_RX_3				;baud rate detection is ongoing
;			;Auto-recover from baud rate detection (status flags in A, RX data in B)
;			SCI_ERRSIG_OFF					;clear error signal 
;			SCI_STOP_BD					;disable baud rate detection
;SCI_ISR_RX_2		EQU	*-6	
			;Check for control characters (status flags in A, RX data in B)
SCI_ISR_RX_3		EQU	*	
#ifdef	SCI_HANDLE_SUSPEND
			BRSET	SCI_FLGS, #SCI_FLG_RX_ESC, SCI_ISR_RX_4	;charakter is escaped (skip detection)
			CMPB	#SCI_SUSPEND
			;BLE	<SCI_ISR_RX_11				;determine control signal
			BLE	SCI_ISR_RX_11				;determine control signal
SCI_ISR_RX_4		BCLR	SCI_FLGS, #SCI_FLG_RX_ESC 		;clear escape marker
#else
#ifdef	SCI_FC_XONXOFF
			BRSET	SCI_FLGS, #SCI_FLG_RX_ESC, SCI_ISR_RX_4 ;charakter is escaped (skip detection)
			CMPB	#SCI_XOFF
			BLE	<SCI_ISR_RX_11				;determine control signal
SCI_ISR_RX_4		BCLR	SCI_FLGS, #SCI_FLG_RX_ESC 		;clear escape marker
#else
#ifdef	SCI_HANDLE_BREAK
			BRSET	SCI_FLGS, #SCI_FLG_RX_ESC, SCI_ISR_RX_4 ;charakter is escaped (skip detection)
			CMPB	#SCI_DLE
			BLE	<SCI_ISR_RX_11				;determine control signal
SCI_ISR_RX_4		BCLR	SCI_FLGS, #SCI_FLG_RX_ESC 		;clear escape marker
#else
SCI_ISR_RX_4		EQU	*	
#endif
#endif
#endif
			;Place data into RX queue (status flags in A, RX data in B) 
SCI_ISR_RX_5		TFR	D, Y					;flags:data -> Y
			LDX	#SCI_RXBUF
			LDD	SCI_RXBUF_IN				;in:out -> A:B
			STY	A,X
			ADDA	#2
			ANDA	#SCI_RXBUF_MASK		
			CBA
                	BEQ	<SCI_ISR_RX_9				;buffer overflow
			STAA	SCI_RXBUF_IN				;update IN pointer
			;Check flow control threshold (in:out in D) 
			SBA
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_RX_FULL_LEVEL
			BHS	<SCI_ISR_RX_10 				;buffer is getting full			
SCI_ISR_RX_6		EQU	*
#ifdef SCI_FC_XONXOFF
			;Delay reminder in case it is running
			LDD	SCI_XONXOFF_REMCNT
			BEQ	SCI_ISR_RX_7 				;done
			MOVW	#SCI_XONXOFF_REMINDER, SCI_XONXOFF_REMCNT
#endif
SCI_ISR_RX_7		EQU	*
#ifdef	SCI_IRQ_WORKAROUND_ON
			;Continue with TX 
			JOB	SCI_ISR_RXTX
#else
			;Done
			ISTACK_RTI
#endif
			;RX error detected (status flags in A, RX data in B)
SCI_ISR_RX_8		SCI_ERRSIG_ON
			SCI_START_BD
#ifdef	SCI_ERRSIG_ON	
			JOB	SCI_ISR_RX_4 				;queue RX data
#else
#ifdef	SCI_BD_ON
			JOB	SCI_ISR_RX_4 				;queue RX data
#endif
#endif	
			;Buffer overflow
SCI_ISR_RX_9		BSET	SCI_FLGS, #SCI_FLG_SWOR 		;set overflow flag
			JOB	SCI_ISR_RX_6 				;done
			;RX buffer is getting full
SCI_ISR_RX_10		SCI_DEASSERT_CTS
			SCI_SEND_XONXOFF
			JOB	SCI_ISR_RX_6 				;done
			;Determine control signal (status flags in A, RX data in B)
SCI_ISR_RX_11		EQU	*
#ifdef	SCI_FC_XONXOFF
			;Check for XON/XOFF (status flags in A, RX data in B)
			CMPB	#SCI_XOFF
			BNE	<SCI_ISR_RX_12				;determine control signal
			BSET	SCI_FLGS, #SCI_FLG_TX_BLOCKED
			JOB	SCI_ISR_RX_6 				;done
SCI_ISR_RX_12		CMPB	#SCI_XON
			BNE	<SCI_ISR_RX_13				;determine control signal
			BCLR	SCI_FLGS, #SCI_FLG_TX_BLOCKED		;clear TX block
			MOVB	#(TXIE|RIE|TE|RE), SCICR2 		;enable TX interrupt
			JOB	SCI_ISR_RX_6 				;done
SCI_ISR_RX_13		EQU	*
#endif
#ifdef	SCI_HANDLE_SUSPEND
			;Check for SUSPEND (status flags in A, RX data in B)
			CMPB	#SCI_SUSPEND
			BNE	<SCI_ISR_RX_14				;determine control signal
			SCI_SUSPEND_ACTION
			JOB	SCI_ISR_RX_6 				;done
SCI_ISR_RX_14		EQU	*
#endif
#ifdef	SCI_HANDLE_BREAK
			;Check for BREAK (status flags in A, RX data in B)
			CMPB	#SCI_BREAK
			BNE	<SCI_ISR_RX_15				;determine control signal
			SCI_BREAK_ACTION
SCI_ISR_RX_15		CMPB	#SCI_DLE
			BNE	<SCI_ISR_RX_16				;done
			BSET	SCI_FLGS, #SCI_FLG_RX_ESC 		;set escape marker	
			JOB	SCI_ISR_RX_6 				;done
#else
#ifdef	SCI_FC_XONXOFF
			CMPB	#SCI_DLE
			BNE	<SCI_ISR_RX_16				;done
			BSET	SCI_FLGS, #SCI_FLG_RX_ESC 			;set escape marker	
			JOB	SCI_ISR_RX_6 				;done
#else
#ifdef	SCI_FC_SUSPEND
			CMPB	#SCI_DLE
			BNE	<SCI_ISR_RX_16				;done
			BSET	SCI_FLGS, #SCI_FLG_RX_ESC 			;set escape marker	
			JOB	SCI_ISR_RX_6 				;done
#endif
#endif
#endif
SCI_ISR_RX_16		JOB	SCI_ISR_RX_5 				;queue RX data

#ifdef SCI_BD_ON
#ifdef SCI_BD_TIM	
;#BD negedge ISR (default IC1)
SCI_ISR_BD_NE		EQU	*
			;Clear ICNE interrupt
			TIM_CLRIF	SCI_BD_ICNE	
			;Capture pulse length and flags
			LDX	(TC0+(2*SCI_BD_ICNE))			;capture current edge (posedge)
			LDY	(TC0+(2*SCI_BD_ICPE))			;capture previous edge (posedge)
			LDAB	TFLG1 					;capture interrupt flags
			;Reset timeout  flags (current edge in X, previous edge in Y, interrupt flags in B)
			STX	(TC0+(2*SCI_BD_OC))		
			TIM_CLRIF	SCI_BD_OC
			;Allow nested interrupts (current edge in X, previous edge in Y, interrupt flags in B)
			ISTACK_CHECK_AND_CLI 				;allow interrupts if there is enough room on the stack
			;Make sure no time-out has and no early edge has occured (current edge in X, previous edge in Y, interrupt flags in B)
			BITB	#((1<<SCI_BD_ICPE)|(1<<SCI_BD_ICNE)|(1<<SCI_BD_OC)) 
			BNE	SCI_ISR_BD_NEPE_4 			;done
			;Calculate pulse length (current edge in X, previous edge in Y, polarity flags in B)
			LDD	#-1
			EMULS						;-1 * Y => Y:D
			LEAX	D,X 					;subtract timestamps
			;Select search tree tree (pulse length in X)
			LDY	#SCI_BD_HIGH_PULSE_TREE
			TBNE	X, SCI_ISR_BD_NEPE_2 			;parse search tree if pulse length is > 0
			JOB	SCI_ISR_BD_NEPE_4 			;discard zero-length pulses (for whatever reasson they may occur)

;#BD posedge ISR (default IC0)
SCI_ISR_BD_PE		EQU	*
			;Clear ICNE interrupt
			TIM_CLRIF	SCI_BD_ICPE	
			;Capture pulse length and flags
			LDX	(TC0+(2*SCI_BD_ICPE))			;capture current edge (posedge)
			LDY	(TC0+(2*SCI_BD_ICNE))			;capture previous edge (posedge)
			LDAB	TFLG1 					;capture interrupt flags
			;Reset timeout  flags (current edge in X, previous edge in Y, interrupt flags in B)
			STX	(TC0+(2*SCI_BD_OC))		
			TIM_CLRIF	SCI_BD_OC
			;Allow nested interrupts (current edge in X, previous edge in Y, interrupt flags in B)
			ISTACK_CHECK_AND_CLI 				;allow interrupts if there is enough room on the stack
			;Make sure no time-out has and no early edge has occured (current edge in X, previous edge in Y, interrupt flags in B)
			BITB	#((1<<SCI_BD_ICPE)|(1<<SCI_BD_ICNE)|(1<<SCI_BD_OC)) 
			BNE	SCI_ISR_BD_NEPE_4 			;done
			;Calculate pulse length (current edge in X, previous edge in Y, polarity flags in B)
			LDD	#-1
			EMULS						;-1 * Y => Y:D
			LEAX	D,X 					;subtract timestamps
			TBEQ	X, SCI_ISR_BD_NEPE_4 			;discard zero-length pulses (for whatever reasson they may occur)
			;Select search tree tree (pulse length in X)
			LDY	#SCI_BD_LOW_PULSE_TREE
			JOB	SCI_ISR_BD_NEPE_2 			;parse search tree
#endif	
#ifdef SCI_BD_ECT	
;#Edge on RX pin captured (default IC0)
SCI_ISR_BD_NEPE		EQU	*
			;Clear IC interrupt
			TIM_CLRIF	SCI_BD_IC	
			;Capture pulse length and flags
			LDX	(TC0+(2*SCI_BD_IC))			;capture current edge (posedge)
			LDY	(TC0H+(2*SCI_BD_IC))			;capture previous edge (posedge)
			LDAB	MCFLG					;capture polarity flags
			;Make sure no time-out has and no early edge has occured
			BRCLR	TFLG1, ((1<<SCI_BD_IC)|(1<<SCI_BD_OC)), SCI_ISR_BD_NEPE_1
			;Reset time-out and discard captured values 
			STX	(TC0+(2*SCI_BD_OC))		
			TIM_CLRIF	SCI_BD_OC
			JOB	SCI_ISR_BD_NEPE_4 			;done
			;Reset timeout  flags (current edge in X, previous edge in Y, polarity flags in B)
SCI_ISR_BD_NEPE_1	STX	(TC0+(2*SCI_BD_OC))		
			TIM_CLRIF	SCI_BD_OC
			;Allow nested interrupts (current edge in X, previous edge in Y, polarity flags in B)
			ISTACK_CHECK_AND_CLI 				;allow interrupts if there is enough room on the stack
			;Calculate pulse length (current edge in X, previous edge in Y, polarity flags in B)
			EXG	D,Y 					;precious edge -> D
			COMA						;calculate 2's comlplement
			COMB
			ADDD	#1
			LEAX	D,X 					;subtract timestamps
			TBEQ	X, SCI_ISR_BD_NEPE_4 			;discard zero-length pulses (for whatever reasson they may occur)
			TFR	Y,D
			;Select search tree tree (pulse length in X, polarity flags in B)
			LDY	#SCI_BD_HIGH_PULSE_TREE
			BITB	#(1<<SCI_BD_IC)
			BNE	SCI_ISR_BD_NEPE_2
			;BEQ	SCI_ISR_BD_NEPE_2	;!!!
			LDY	#SCI_BD_LOW_PULSE_TREE
#endif	
			;Log pluse length for debuging (pulse length in X, search tree in Y)
SCI_ISR_BD_NEPE_2	SCI_BD_LOG
			;Parse tree  (pulse length in X, search tree in Y)
			SCI_BD_PARSE			
			;Update list of potential batd rates (matching baud rates in D)
			SEI
			ANDB	SCI_BD_LIST 				;remove mismatching baud rates from the list
			BEQ	SCI_ISR_BD_NEPE_5	 		;no valid baud rate found
			STAB	SCI_BD_LIST 
			;Check if baud rate has been determined (potential baud rates in B (not zero))
			CLRA
SCI_ISR_BD_NEPE_3	INCA
			LSRB
			BCC	SCI_ISR_BD_NEPE_3
			BEQ	SCI_ISR_BD_NEPE_6 			;new baud rate found (index in A)
			;Done
SCI_ISR_BD_NEPE_4	ISTACK_RTI
			;No valid baud rate found
SCI_ISR_BD_NEPE_5	BRCLR	SCI_BD_LIST, #$FF, SCI_ISR_BD_NEPE_4	;done
			;Restart baud rate detection 
			MOVB	#$FF, SCI_BD_LIST
			JOB	SCI_ISR_BD_NEPE_4 			;done
			;New baud rate found (index+1 in A, $00 in B)
SCI_ISR_BD_NEPE_6	SCI_STOP_BD
			;Set baud rate (index+1 in A, $00 in B)
			LSLA						;index -> addess offset
			LDX	#SCI_BTAB-2 				;look up prescaler value
			LDD	A,X					;look up divider value
			SCI_SET_BAUD
			;Clear error signal
			SCI_ERRSIG_OFF
			JOB	SCI_ISR_BD_NEPE_4 			;done
#endif	

SCI_CODE_END		EQU	*
SCI_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef SCI_TABS_START_LIN
			ORG 	SCI_TABS_START, SCI_TABS_START_LIN
#else
			ORG 	SCI_TABS_START
#endif	

			ALIGN	1

			;List of prescaler values
SCI_BTAB		EQU	*
			DW	SCI_4800 	
			DW	SCI_7200 	
			DW	SCI_9600 	
			DW	SCI_14400	
			DW	SCI_19200	
			DW	SCI_28800	
			DW	SCI_38400	
			DW	SCI_57600	
SCI_BTAB_END		EQU	*

#ifdef	SCI_BD_ON
			;Search tree for low pulses
SCI_BD_LOW_PULSE_TREE	SCI_BD_LOW_PULSE_TREE

			;Search tree for high pulses
SCI_BD_HIGH_PULSE_TREE	SCI_BD_HIGH_PULSE_TREE		
#endif	

SCI_TABS_END		EQU	*
SCI_TABS_END_LIN	EQU	@
#endif
