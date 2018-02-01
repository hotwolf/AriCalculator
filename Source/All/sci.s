#ifndef	SCI_COMPILED
#define SCI_COMPILED
;###############################################################################
;# S12CBase - SCI - Serial Communication Interface Driver                      #
;###############################################################################
;#    Copyright 2010-2018 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU           #
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
;#    SCI_TX_NB       - This function sends a byte over the serial interface   #
;#                      without blocking the program flow. It will return a    #
;#                      status on the success of the operation.                #
;#    SCI_TX_BL       - This function sends a byte over the serial interface.  #
;#                      It will block the program flow until the data can be   #
;#                      handed over to the transmit queue.                     #
;#    SCI_TX_READY_NB - This function checks the status of the transmit queue  #
;#                      without blocking the program flow.                     #
;#    SCI_TX_READY_BL - This function will block the program flow until the    #
;#                      transmission queue is ready to accept further data.    #
;#    SCI_RX_NB       - This function receives a byte from the serial          #
;#                      interface without blocking the program flow. It will   #
;#                      return astatus on the success of the operation.        #
;#    SCI_RX_BL       - This function receives a byte from the serial          #
;#                      interface. It will block the program flow until data   #
;#                      available.                                             #
;#    SCI_RX_READY_NB - This function checks the status of the receive queue   #
;#                      without blocking the program flow.                     #
;#    SCI_RX_READY_BL - This function will block the program flow until data   #
;#                      is available in the receive queue.                     #
;#                                                                             #
;#    For convinience, all of these functions may also be called as macro.     #
;#                                                                             #
;#    Six conditions are flagged can when receiving data from the serial       #
;#    interface:                                                               #
;#    CTRL - C0 character received [status byte -> bit 5]                      #
;#         The main program has failed to free up the RX queeue in time.       #
;#         The received data is considerd to be valid.                         #
;#         Baud rate detection will not be triggered.                          #
;#         This condition will be reported to the application.                 #
;#                                                                             #
;#    SWOR - Software Overrun (in RX Queue) [status byte -> bit 4]             #
;#         The main program has failed to free up the RX queeue in time.       #
;#         The received data is considerd to be valid.                         #
;#         Baud rate detection will not be triggered.                          #
;#         This condition will be reported to the application.                 #
;#                                                                             #
;#    OR - Overrun (in SCI hardware) [status byte -> bit 3]                    #
;#         The software has failed to transfer RX data to the RX queue in      #
;#         time.                                                               #
;#         The received data is considerd to be valid.                         #
;#         Baud rate detection will not be triggered.                          #
;#         This condition will be reported to the application.                 #
;#                                                                             #
;#    NF - Noise (Flag) [status byte -> bit 2]                                 #
;#         Noise has been detected on the RX line.                             #
;#         The received data is still considerd to be valid.                   #
;#         Baud rate detection will be triggered.                              #
;#         This condition will not be reported to the application.             #
;#                                                                             #
;#    FE - Framing Error [status byte -> bit 1]                                #
;#         An invalid data frame (stop bit) has been received                  #
;#         The received data is considerd to be invalid.                       #
;#         If a sequence of invalid data is received, only one entry will be   #
;#         stored in the RX queue.                                             #
;#         Baud rate detection will be triggered.                              #
;#         This condition will be reported to the application.                 #
;#                                                                             #
;#    PE - Parity Error (only occurs if parity is enabled)[status b. -> bit 0] #
;#         An invalid parity bit has been received                             #
;#         The received data is considerd to be invalid.                       #
;#         If a sequence of invalid data is received, only one entry will be   #
;#         stored in the RX queue.                                             #
;#         Baud rate detection will be triggered.                              #
;#         This condition will be reported to the application.                 #
;#                                                                             #
;#    The SCI module is capable of detecting the baud rate of the serial       #
;#    communication. After each power-up, the RX pin is probed, expecting to   #
;#    receive a CR character. The boud rate is then determined based on the    #
;#    observed pusle widths.                                                   #
;#                                                                             #
;#    The SCI driver supports hardware flow control (RTS/CTS) to allow 8-bit   #
;#    data transmissions. The flow control signals are implemented to using    #
;#    the following GPIO pins by default:  RTS input:  PM0                     #
;#                                         CTS output: PM1                     #
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
;###############################################################################
;# Timer usage:                                                                #
;#   Baud rate detection:                                                      #
;#     Set IC to capture any transition of the RX pin. Keep track of the       #
;#     shortest valid RX pulse. Everytime a pulse is captured set the OC 16    #
;#     times the length of the shortest pulse. When the OC times out, the      #
;#     shortest pulse and the associated baud rate has been detected. The      #
;#     SCI can be enabled immediately.                                         #
;#     The baud rate detection is should always detect the character           #
;#     combination CR LF ($0D_0A -> %00001101_00001010).                       #
;#     Active baud rate detection is indicated by the enabled IC channel.      #
;#                                                                             #
;#   RTS/CTS flow control:                                                     #
;#     Enable RTS polling if RTS is low while atempting to transmit data.      #
;#     Disable RTS polling if data has been transmitted successfully. While    #
;#     RTS polling is enabled, set (and reset) OC to reatempt to transmit      #
;#     approx. every 2 SCI frame lengths.                                      #
;#                                                                             #
;#   XON/XOFF flow control:                                                    #
;#     Set (and reset) OC periodically. Keep a count of OC events to send out  #
;#     a XON/XOFF reminder every couple of seconds.                            #
;#                                                                             #
;#   MC9S12DP256 SCI IRQ workaround:                                           #
;#     Set (and reset) OC to check all IFs approx. every 2 SCI frame lengths.  #
;#                                                                             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register definitions                                            #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    CLOCK  - Clock driver                                                    #
;#    GPIO   - GPIO driver                                                     #
;#    TIM    - Timer driver                                                    #
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
;#    October 1, 2014                                                          #
;#      - Added dynamic enable/disable feature                                 #
;#    January 14, 2015                                                         #
;#      - Changed configuration options                                        #
;#      - Changed control character handling                                   #
;#    October 28, 2015                                                         #
;#      - Added feature to halt SCI communication                              #
;#    April 23, 2016                                                           #
;#      - Moved from countinuous to initial baud rate detection                #
;#    January 30, 2017                                                         #
;#      - Moved from initial to manually invoked baud rate detection           #
;#    January 11, 2018                                                         #
;#      - Removed feature to halt SCI communication                            #
;#    January 30, 2018                                                         #
;#      - Split initialization between SCI_INIT and SCI_ACTIVATE               #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;SCI version
#ifndef	SCI_V6
#ifndef	SCI_V5
#ifndef	SCI_V4
#ifndef	SCI_V3
#ifndef	SCI_V2
SCI_V5			EQU	1	 	;default is V5
#endif
#endif
#endif
#endif
#endif
	
;Bus frequency
#ifndef	CLOCK_BUS_FREQ
CLOCK_BUS_FREQ		EQU	25000000 	;default is 25MHz
#endif
	
;Invert RXD/TXD
#ifndef	SCI_RXTX_ACTLO
#ifndef	SCI_RXTX_ACTHI
SCI_RXTX_ACTHI		EQU	1 		;default is active high RXD/TXD
#endif
#endif
	
;TIM configuration
;TIM instance for baud rate detection
#ifndef	SCI_IC_TIM
SCI_IC_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Input capture channel for baud rate detection
#ifndef	SCI_IC
SCI_IC			EQU	1 		;default is IC1
#endif
;TIM instance for baud rate detection and flow control
#ifndef	SCI_OC_TIM
SCI_OC_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Output compare channel for baud rate detection and flow control
;Past baud rate detection, the OC will always measure time periods of roughly 2 SCI frames
#ifndef	SCI_OC
SCI_OC			EQU	0 		;default is OC0
#endif
;TIM instance for the MUCts00510 workaround
#ifndef	SCI_IRQBUG_TIM
SCI_IRQBUG_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Output compare channel for the MUCts00510 workaround
;Past baud rate detection, the OC will always measure time periods of roughly 2 SCI frames
#ifndef	SCI_IRQBUG_OC
SCI_IRQBUG_OC		EQU	2 		;default is OC02
#endif
	
;Default baud rate
;-----------------
#ifndef	SCI_BAUD_9600 	
#ifndef	SCI_BAUD_14400	
#ifndef	SCI_BAUD_19200	
#ifndef	SCI_BAUD_28800	
#ifndef	SCI_BAUD_38400	
#ifndef	SCI_BAUD_57600	
#ifndef	SCI_BAUD_76800       	
#ifndef	SCI_BAUD_115200		
#ifndef	SCI_BAUD_153600
SCI_BAUD_9600		EQU	1 		;default is 9600 baud
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif

;Baud rate detection
;-------------------
#ifndef	SCI_BAUD_DETECT_ON
#ifndef	SCI_BAUD_DETECT_OFF
SCI_BAUD_DETECT_OFF	EQU	1 		;baud rate detection disabled by default
#endif
#endif
	
;Frame format
;------------
#ifndef	SCI_FORMAT_8N1
#ifndef	SCI_FORMAT_8E1
#ifndef	SCI_FORMAT_8O1
#ifndef	SCI_FORMAT_8N2
SCI_FORMAT_8N1		
#endif
#endif
#endif
#endif
	
;Flow control
;------------
;RTS/CTS or XON/XOFF
#ifndef	SCI_RTSCTS
#ifndef	SCI_XONXOFF
#ifndef	SCI_NOFC	
SCI_XONXOFF		EQU	1 		;default is SCI_XONXOFF
#endif
#endif
#endif

;RTS/CTS coniguration
#ifdef	SCI_RTSCTS
;RTS pin
#ifndef	SCI_RTS_PORT
SCI_RTS_PORT		EQU	PTM 		;default is PTM
#endif
#ifndef	SCI_RTS_PIN	
SCI_RTS_PIN		EQU	PM0		;default is PM0
#endif
;CTS pin
#ifndef	SCI_CTS_PORT
SCI_CTS_PORT		EQU	PTM 		;default is PTM
#endif
#ifndef	SCI_CTS_DDR
SCI_CTS_DDR		EQU	DDRM 		;default is DDRM
#endif
#ifndef	SCI_CTS_PPS
SCI_CTS_PPS		EQU	PPSM 		;default is PPSM
#endif
#ifndef	SCI_CTS_PIN
SCI_CTS_PIN		EQU	PM1		;default is PM1
#endif
;CTS drive strength
#ifndef	SCI_CTS_WEAK_DRIVE
#ifndef	SCI_CTS_STRONG_DRIVE
SCI_CTS_STRONG_DRIVE	EQU	1		;default is strong drive
#endif
#endif
#endif

;SCI V02.00 IRQ workaround (MUCts00510)
;--------------------------------------
;###############################################################################
;# Relevant for the folowing parts:                                            #
;#    MC9S12DP256 mask sets 0K79X, 1K79X, 2K79X, 0L58F                         #
;#    MC9S12H256  mask sets 0K78X, 1K78X, 2K78X                                #
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
;Enable workaround for MUCts00510
#ifndef	SCI_IRQBUG_ON
#ifndef	SCI_IRQBUG_OFF
#ifdef V2
SCI_IRQBUG_ON		EQU	1 		;IRQ workaround enabled for SCI V2
#else
SCI_IRQBUG_OFF		EQU	1 		;IRQ workaround disabled on newer SCIs
#endif
#endif
#endif
	
;#Buffer sizes		
#ifndef	SCI_RXBUF_SIZE	
SCI_RXBUF_SIZE		EQU	 16*2		;size of the receive buffer (8 error:data entries)
#endif
#ifndef	SCI_TXBUF_SIZE	
SCI_TXBUF_SIZE		EQU	  8		;size of the transmit buffer
#endif
	
;C0 character handling
;---------------------
;Detect BREAK character (ctrl-c) -> define macro SCI_BREAK_ACTION
;#mac SCI_BREAK_ACTION, 0
;	...code to be executed on BREAK condition (inside ISR)
;#emac
;Detect CANCEL character (ctrl-x) -> define macro SCI_CANCEL_ACTION
;#mac SCI_CANCEL_ACTION, 0
;	...code to be executed on CANCEL condition (inside ISR)
;#emac
;Detect SUSPEND character (ctrl-z-> define macro SCI_SUSPEND_ACTION
;#mac SCI_SUSPEND_ACTION, 0
;	...code to be executed on SUSPEND condition (inside ISR)
;#emac
;Detect ESCAPE character (ESC) -> define macro SCI_ESCAPE_ACTION
;#mac SCI_ESCAPE_ACTION, 0
;	...code to be executed on ESCAPE condition (inside ISR)
;#emac

;Communication error signaling
;-----------------------------
;Signal active baud rate detection -> define macros SCI_BDSIG_START and SCI_BDSIG_STOP
;#mac SCI_BDSIG_START, 0
;	...code to start BD signaling (inside ISR)
;#emac
;#mac SCI_BDSIG_STOP, 0
;	...code to stop BD signaling (inside ISR)
;#emac
	
;Signal RX errors -> define macros SCI_ERRSIG_START and SCI_ERRSIG_STOP
;#mac SCI_ERRSIG_START, 0
;	...code to start error signal (inside ISR)
;#emac
;#mac SCI_ERRSIG_STOP, 0
;	...code to stop error signal (inside ISR)
;#emac

	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Parameter check
#ifdef TIM_DIV_16
			ERROR	"Parameter TIM_DIV_16 not supported by SCI"
#endif
#ifdef TIM_DIV_32
			ERROR	"Parameter TIM_DIV_32 not supported by SCI"
#endif
#ifdef TIM_DIV_64
			ERROR	"Parameter TIM_DIV_64 not supported by SCI"
#endif
#ifdef TIM_DIV_128
			ERROR	"Parameter TIM_DIV_128 not supported by SCI"
#endif

;#Baud rate
#ifdef	SCI_BAUD_9600        	
SCI_BAUD		EQU	9600
#endif
#ifdef	SCI_BAUD_14400       	
SCI_BAUD		EQU	14400
#endif
#ifdef	SCI_BAUD_19200       	
SCI_BAUD		EQU	19200
#endif
#ifdef	SCI_BAUD_28800       	
SCI_BAUD		EQU	28800
#endif
#ifdef	SCI_BAUD_38400       	
SCI_BAUD		EQU	38400
#endif
#ifdef	SCI_BAUD_57600       	
SCI_BAUD		EQU	57600
#endif
#ifdef	SCI_BAUD_76800       	
SCI_BAUD		EQU	76800
#endif
#ifdef	SCI_BAUD_115200		
SCI_BAUD		EQU	115200
#endif
#ifdef	SCI_BAUD_153600
SCI_BAUD		EQU	153600
#endif
	
;#Baud rate divider (SCIBD)
; SCI V5: SCIBD = bus clock / (16*baud rate)
;         25MHz:   9600 -> $A2
;                 14400 -> $6C
;                 19200 -> $51
;                 28800 -> $36
;                 38400 -> $28
;                 57600 -> $1B
;                 76800 -> $14
;                115200 -> $0D
;                153600 -> $0A
; SCI V6: SCIBD = bus clock / baud rate
;         25MHz:   9600 -> $A2C
;                 14400 -> $6C8
;                 19200 -> $516
;                 28800 -> $364
;                 38400 -> $28B
;                 57600 -> $1B2
;                 76800 -> $145
;                115200 -> $0D9
;                153600 -> $0A2
#ifdef	SCI_V6
SCI_BDIV		EQU	(CLOCK_BUS_FREQ/SCI_BAUD)+(((2*CLOCK_BUS_FREQ)/SCI_BAUD)&1)			
#else
SCI_BDIV		EQU	(CLOCK_BUS_FREQ/(16*SCI_BAUD))+(((2*CLOCK_BUS_FREQ)/(16*SCI_BAUD))&1)
#endif

;#Pulse range for faud rate detection
;max. baud rate:  153600 baud +10% = 168960 baud
;min. baud rate:  TIM_FREQ/$FFFF   ~   381 baud (TIM_FREQ=25MHz)
SCI_BD_MAX_BAUD		EQU	168960 				;highest baud rate
SCI_BD_MIN_BAUD		EQU	TIM_FREQ/$FFFF			;lowest baud rate
SCI_BD_MIN_PULSE	EQU	TIM_FREQ/SCI_BD_MAX_BAUD	;shortest bit pulse
SCI_BD_MAX_PULSE	EQU	$FFFF				;longest bit pulse
	
;#Frame format
SCI_8N1			EQU	  ILT		;8N1
SCI_8E1			EQU	  ILT|PE	;8E1
SCI_8O1			EQU	  ILT|PE|PT	;8O1
SCI_8N2		 	EQU	M|ILT		;8N2 TX8=1

#ifdef	SCI_FORMAT_8N1
SCI_FORMAT		EQU	SCI_8N1
#endif
#ifdef	SCI_FORMAT_8E1
SCI_FORMAT		EQU	SCI_8E1
#endif
#ifdef	SCI_FORMAT_8O1
SCI_FORMAT		EQU	SCI_8O1
#endif
#ifdef	SCI_FORMAT_8N2
SCI_FORMAT		EQU	SCI_8N2
#endif
	
;#C0 characters
SCI_C0_MASK		EQU	$E0 		;mask for C0 character range
SCI_C0_BREAK		EQU	$03 		;ctrl-c (break signal)
SCI_C0_DLE		EQU	$10		;data link escape (treat next byte as data)
SCI_C0_XON		EQU	$11 		;unblock transmission
SCI_C0_XOFF		EQU	$13		;block transmission
SCI_C0_CANCEL		EQU	$18 		;ctrl-x (cancel signal)
SCI_C0_SUSPEND		EQU	$1A 		;ctrl-z (suspend signal)
SCI_C0_ESCAPE		EQU	$1B 		;ESC (escape signal)
SCI_C0_US		EQU	$1A 		;last C0 character (unit separator)
SCI_C0_DEL		EQU	$7F 		;DELETE

;#C1 characters
SCI_C1_MASK		EQU	$10 		;mask for C1 character range
	
;#Buffer masks		
SCI_RXBUF_MASK		EQU	SCI_RXBUF_SIZE-1;mask for rolling over the RX buffer
SCI_TXBUF_MASK		EQU	SCI_TXBUF_SIZE-1;mask for rolling over the TX buffer

;#Flow control thresholds
SCI_RX_FULL_LEVEL	EQU	SCI_RXBUF_SIZE-10;RX buffer threshold to block transmissions
SCI_RX_EMPTY_LEVEL	EQU	2*2		;RX buffer threshold to unblock transmissions

;#Action flags
#ifndef	SCI_NOFC	
SCI_EXCPT_RXFC		EQU	$80		;handle RX flow control
#else
SCI_EXCPT_RXFC		EQU	$00		;no flow control
#endif
#ifmac	SCI_BREAK_ACTION
SCI_EXCPT_BREAK		EQU	$08		;handle BREAK request
#else
SCI_EXCPT_BREAK		EQU	$00		;no BREAK request
#endif
#ifmac	SCI_CANCEL_ACTION
SCI_EXCPT_CANCEL	EQU	$04		;handle CANCEL request
#else
SCI_EXCPT_CANCEL	EQU	$00		;no CANCEL request
#endif
#ifmac	SCI_SUSPEND_ACTION
SCI_EXCPT_SUSPEND	EQU	$02		;handle SUSPEND request
#else
SCI_EXCPT_SUSPEND	EQU	$00		;no SUSPEND request
#endif
#ifmac	SCI_ESCAPE_ACTION
SCI_EXCPT_ESCAPE	EQU	$01		;handle ESCAPE request
#else
SCI_EXCPT_ESCAPE	EQU	$00		;no ESCAPE request
#endif
SCI_EXCPT_ANY		EQU	SCI_EXCPT_RXFC|SCI_EXCPT_BREAK|SCI_EXCPT_CANCEL|SCI_EXCPT_SUSPEND|SCI_EXCPT_ESCAPE

;#Status Flags
SCI_STAT_TCVALID	EQU	$80		;timestamp is valid
SCI_STAT_TXDLE          EQU     $40		;atomic TX sequence
SCI_STAT_RXDLE          EQU     $20		;next RX character is escaped
SCI_STAT_SWOR		EQU	$10		;software buffer overrun (RX buffer)
SCI_STAT_NOTX		EQU	$08		;don't transmit (XOFF received)
SCI_STAT_RXERR		EQU	$04		;RX error state
SCI_STAT_BDIVOK		EQU	$02		;BDIV is valid

;#Meta Data
SCI_META_C1           	EQU     $80		;C1 character
SCI_META_C0             EQU     $40		;C0 Character (incl. DEL)
SCI_META_DLE            EQU     $20		;character is escaped
SCI_META_SWOR           EQU     $10		;software overrun (previous data lost)
SCI_META_HWOR           EQU     $08		;hardware overrun (previous data lost)
SCI_META_NF             EQU     $04		;data received with noise
SCI_META_FE             EQU     $02		;data received with frame error
SCI_META_PF             EQU     $01		;data received with parity error
;#Shortcuts
SWOR			EQU	SCI_META_SWOR 	;shortcut
	
;#Timer usage and configuration
#ifdef	SCI_BAUD_DETECT_ON
SCI_IC_TCTL34_INIT	EQU	3<<SCI_IC	;capture any edge (baud rate detection)
#else
SCI_IC_TCTL34_INIT	EQU	0		;no IC needed
#endif	
SCI_OC_TIOS_INIT	EQU	1<<SCI_OC 	;use OC
SCI_IRQBUG_TIOS_INIT	EQU	1<<SCI_IRQBUG_OC;use OC
	
;#Timer channels
SCI_IC_TC		EQU	SCI_IC_TIM+TC0_OFFSET+(2*SCI_IC)	;IC capture register
SCI_OC_TC		EQU	SCI_OC_TIM+TC0_OFFSET+(2*SCI_OC)	;OC compare register
SCI_OC_TCNT		EQU	SCI_OC_TIM+TCNT_OFFSET			;OC counter register
SCI_IRQBUG_TC		EQU	SCI_IRQBUG_TIM+TC0_OFFSET+(2*SCI_IRQBUG_OC);OC counter register
SCI_IRQBUG_TCNT		EQU	SCI_IRQBUG_TIM+TCNT_OFFSET		;OC counter register

;#OC delays
SCI_XONXOFF_DLY		EQU	10*(TIM_FREQ/65536)			;XON/XOFF reminder intervall (~10sec)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef	SCI_VARS_START_LIN
			ORG 	SCI_VARS_START, SCI_VARS_START_LIN
#else
			ORG 	SCI_VARS_START
SCI_VARS_START_LIN	EQU	@			
#endif	

			ALIGN	1
;#Receive buffer	
SCI_RXBUF		DS	SCI_RXBUF_SIZE
SCI_RXBUF_IN		DS	1		;points to the next free space
SCI_RXBUF_OUT		DS	1		;points to the oldest entry
;#Transmit buffer
SCI_TXBUF		DS	SCI_TXBUF_SIZE
SCI_TXBUF_IN		DS	1		;points to the next free space
SCI_TXBUF_OUT		DS	1		;points to the oldest entry

#ifdef	SCI_BAUD_DETECT_ON
;#Baud rate detection (only active before the RX buffer is used)	
SCI_BD_LAST_TC		EQU	SCI_RXBUF+0 	;timer counter (share RX buffer)
SCI_BD_PULSE		EQU	SCI_RXBUF+2 	;shortest pulse (share RX buffer)
#endif

#ifdef SCI_XONXOFF
;#OC event down counter
SCI_OC_CNT		DS	2		;down counter for XON/XOFF reminders
#endif 

#ifdef	SCI_BAUD_DETECT_ON
;#Baud rate -> checksum (~(SCI_SAVED_BDIV[15:8]+SCI_SAVED_BDIV[7:0])
SCI_SAVED_BDIV		DS	2		;value of the SCIBD register
SCI_SAVED_BDIV_CS	DS	1
#endif
		
;#Event flags
SCI_EXCPT		DS	1		; flags
	
;#Status flags
SCI_STAT		DS	1		;status flags

SCI_VARS_END		EQU	*
SCI_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	SCI_INIT, 0
			;Setup SCI communication
			MOVB	#SCI_FORMAT, SCICR1			;set frame format
#ifdef	SCI_FORMAT_8N2							
			MOVB	#T8, SCIDRH				;prepare 9-bit frame
#endif									
#ifdef	SCI_RXTX_ACTHI							
			MOVB	#(TXPOL|RXPOL), SCISR2			;invert RXD/TXD polarity
#endif                                                         		
			;Initialize buffers				
			MOVW	#$0000,SCI_TXBUF_IN 			;set TX buffer indexes
			MOVW	#$0000,SCI_RXBUF_IN 			;set RX buffer indexes
			;Initialize variables 
			CLR	SCI_EXCPT				;clear all exception requests
			CLR	SCI_STAT				;clear all flags
#ifdef SCI_XONXOFF
			MOVW	#SCI_XONXOFF_DLY, SCI_OC_CNT 		;reset OC delay
#endif 
#ifdef	SCI_BAUD_DETECT_ON						
#ifdef	CLOCK_FLGS							
			;Check if stored baud rate can be trusted 							
			LDAB	CLOCK_FLGS 				;CPMU status -> B
			BITB	#(PORF|LVRF)				;check for POR or LVR
			BNE	SCI_INIT_1				;BDIV is invalid
#endif									
			;Check if stored baud rate is valid							
			LDD	SCI_SAVED_BDIV 				;BDIV -> D
#ifdef	SCI_V5								
			ANDA	#$1F 					;don't touch IR configuration bits
#endif									
			TFR	D, X					;BDIV -> X
			ABA						;calculate checksum
			EORA	SCI_SAVED_BDIV_CS			;compare checksum
			IBNE	A, SCI_INIT_1				;BDIV is invalid
			;Set baud rate divider (BDIV in X)
			STX	 SCIBDH					;set BDIV
			BSET 	SCI_STAT,#SCI_STAT_BDIVOK 		;mark BDIV valid
SCI_INIT_1		EQU	* 					;done
#else
			;Set baud rate divider
			MOVW	#SCI_BDIV, SCIBDH 
#endif
#emac

;#Activate SCI hardware
; args:   none
; result: none
; SSTACK: none
;         No registers are preserved
#macro	SCI_ACTIVATE, 0
#ifdef	SCI_BAUD_DETECT_ON						
			;Check id baud rate divider is valid 
			BRSET 	SCI_STAT,#SCI_STAT_BDIVOK,SCI_ACTIVATE_1;BDIV is valid
			;Start baud rate detection 
#ifmac	SCI_BDSIG_START
			SCI_BDSIG_START					;signal active baud rate detection
#endif
			MOVW	#$FFFF, SCI_BD_PULSE			;start with max. pulse length
			TIM_EN	SCI_IC_TIM, SCI_IC 			;start baud rate detection	
			JOB	SCI_ACTIVATE_1				;done
#endif
			;Activate SCI 			
#ifdef	SCI_XONXOFF							
			MOVB 	#SCI_EXCPT_RXFC, SCI_EXCPT		;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), SCICR2 		;start SCI	
			TIM_EN	SCI_OC_TIM, SCI_OC			;enable SCI_OC			
#else									
			MOVB	#(RIE|TE|RE), SCICR2 			;start SCI	
#endif									
#ifdef	SCI_IRQBUG_ON							
			;Start MUCts00510 workaround			
			SCI_LDD_FRAME_DELAY	1			;determine delay
 			ADDD	SCI_IRQBUG_TCNT				;add to current time
			STD	SCI_IRQBUG_TC 				;set OC
			TIM_EN	SCI_IRQBUG_TIM, SCI_IRQBUG_OC 		;enable timer
#endif
			;Done 					
SCI_ACTIVATE_1		EQU	* 					;done
#emac

;#Deactivate SCI hardware
; args:   none
; result: none
; SSTACK: none
;         No registers are preserved
#macro	SCI_DEACTIVATE, 0
			CLR	SCICR2 					;disable SCI
#ifdef	SCI_XONXOFF							
			TIM_DIS	SCI_IC_TIM, SCI_IC 			;stop IC
#endif
			TIM_DIS	SCI_OC_TIM, SCI_OC 			;stop OC
#ifdef	SCI_IRQBUG_ON							
			TIM_DIS	SCI_IRQBUG_TIM, SCI_IRQBUG_OC 		;stop OC
#endif
#ifmac	SCI_BDSIG_STOP			
			SCI_BDSIG_STOP 					;stop BD indicator
#endif	
#ifmac	SCI_ERRSIG_STOP			
			SCI_ERRSIG_STOP 				;stop error indicator
#endif	
#emac
	
;#User functions
;#--------------
;#Transmit one byte - non-blocking
; args:   B:      data to be send
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         X, Y, and D are preserved
#macro	SCI_TX_NB, 0
			SSTACK_JOBSR	SCI_TX_NB, 6
#emac
	
;#Transmit one byte - blocking
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved
#macro	SCI_TX_BL, 0
			SSTACK_JOBSR	SCI_TX_BL, 8
#emac
	
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
#macro	SCI_TX_READY_BL, 0
			SSTACK_JOBSR	SCI_TX_READY_BL, 6
#emac

;#Check if there is no more data in the TX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and D are preserved
#macro	SCI_TX_DONE_NB, 0
			SSTACK_JOBSR	SCI_TX_DONE_NB, 4
#emac
	
;#Wait until there is no more data in the TX queue
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y and D are preserved
#macro	SCI_TX_DONE_BL, 0
			SSTACK_JOBSR	SCI_TX_DONE_BL, 6
#emac
	
;#Receive one byte - non-blocking
; args:   none
; result: A:      error flags
;         B:      received data
;         C-flag: set if successful
; SSTACK: 5 bytes
;         X and Y are preserved
#macro	SCI_RX_NB, 0
			SSTACK_JOBSR	SCI_RX_NB, 4
#emac

;#Receive one byte - blocking
; args:   none
; result: A: error flags
;         B: received data
; SSTACK: 7 bytes
;         X and Y are preserved
#macro	SCI_RX_BL, 0
			SSTACK_JOBSR	SCI_RX_BL, 6
#emac
	
;#Check if there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y and B are preserved
#macro	SCI_RX_READY_NB, 0
			SSTACK_JOBSR	SCI_RX_READY_NB, 5
#emac
	
;#Wait until there is data in the RX queue
; args:   none
; result: none
; SSTACK: 7 bytes
;         X, Y and B are preserved
#macro	SCI_RX_READY_BL, 0
			SSTACK_JOBSR	SCI_RX_READY_BL, 7
#emac

#ifdef	SCI_BAUD_DETECT_ON
;#Check for valid baud rate (non-blocking)
; args:   none
; result: C-flag: set if baud rate is valid
; SSTACK: 2 bytes
;         X, Y, and D are preserved
#macro	SCI_CHECK_BAUD_NB, 0
			SSTACK_JOBSR	SCI_CHECK_BAUD_NB, 2
#emac

;#Check for valid baud rate (blocking)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved
#macro	SCI_CHECK_BAUD_BL, 0
			SSTACK_JOBSR	SCI_CHECK_BAUD_BL, 2
#emac
#endif	
	
;#Polling Operation
;#------------------
;#Poll RX input (LRE code)
; args:   none
; result: none
; SSTACK: 7 bytes
;         X, Y and B are preserved
;All interrupts are expected to be disabled 
#macro	SCI_POLL_RX, 0		
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
			BEQ	SCI_POLL_RX_17				;no RX data			
			;Pick up RX data (status flags in A)
			LDAB	SCIDRL					;load receive data into accu B (clears flags)
#ifdef	SCI_XONXOFF
			;Send XOFF (status flags in A, RX data in B)
			BRCLR	SCISR1,#TDRE,SCI_POLL_RX_1 		;skip if transmit buffer is full
			MOVB	#SCI_C0_XOFF, SCIDL 			;send XOFF
#endif
#ifdef	SCI_RTSCTS
			;Deassert CTS (flags:data in Y)
			SCI_DEASSERT_CTS 				;clear CTS
#endif
			;Transfer hardware flag to metadata (status flags in A, RX data in B)
SCI_POLL_RX_1		ANDA	#(OR|NF|FE|PF)				;keep  error flags
			;Check for C0 range (metadata in A, RX data in B)
SCI_POLL_RX_2		CMPB	#SCI_C0_US 				;check for lower C0 range 
			BLE	SCI_POLL_RX_3 				;decode C0 character
			CMPB	#SCI_C0_DEL 				;check for DEL
			BNE	SCI_POLL_RX_4 				;no C0 character
SCI_POLL_RX_3		ORAA	#SCI_META_C0 				;mark as C0 character
			;Check for C1 range (metadata in A, RX data in B)
SCI_POLL_RX_4		TSTB						;check for C1 range
			BPL	SCI_POLL_RX_5				;no C1 character					
			ORAA	#SCI_META_C1 				;mark as C1 character
			;Transfer SWOR und DLE flags to metadata (metadata in A, RX data in B)
SCI_POLL_RX_5		TFR	B, X 					;RX data -> X
			LDAB	SCI_STAT 				;get status bits
			ANDB	#(SCI_STAT_RXDLE|SCI_STAT_SWOR) 	;mask DLE and SWOR
			ABA						;transfer status bits to metadata
			TFR	X, B 					;RX data -> X
			;Interpret C0 codes if there is no error (metadata in A, RX data in B)
SCI_POLL_RX_6		CMPA	#SCI_META_C0 				;check for C0 and no errors
			BNE	SCI_POLL_RX_14 				;queue RX data
			;Interpret DLE (RX data in B)
			CMPB	#SCI_C0_DLE 				;check for DLE
			BNE	SCI_POLL_RX_7 				;no DLE character
			BSET	SCT_STAT,#SCI_STAT_RXDLE 		;set DLE status
			BRA	SCI_POLL_RX_16				;enable TX interrupt
SCI_POLL_RX_7		EQU	*					;no DLE character
#ifdef	SCI_XONXOFF
			;Interpret XON/XOFF (RX data in B)
			CMPB	#SCI_C0_XON 				;check for XON
			BNE	SCI_POLL_RX_8 				;no XON character
			BCLR	SCI_STAT,#SCI_STAT_NOTX 		;block transmissions
			BRA	SCI_POLL_RX_16				;enable TX interrupt
SCI_POLL_RX_8		CMPB	#SCI_C0_XOFF 				;check for XOFF
			BNE	SCI_POLL_RX_9 				;no XOFF character
			BSET	SCI_STAT,#SCI_STAT_NOTX 		;clear XOFF status
			BRA	SCI_POLL_RX_16				;enable TX interrupt
SCI_POLL_RX_9		EQU	* 					;no XON/XOFF character
#endif			
#ifmac	SCI_BREAK_ACTION
			;Interpret BREAK (RX data in B)
			CMPB	#SCI_C0_BREAK 				;check for BREAK
			BNE	SCI_POLL_RX_10 				;no BREAK character
			BSET	SCI_EXCPT,#SCI_EXCPT_BREAK 		;request BREAK handletr
			BRA	SCI_POLL_RX_16				;enable TX interrupt
SCI_POLL_RX_10		EQU	* 					;no BREAK character
#endif
#ifmac	SCI_CANCEL_ACTION
			;Interpret CANCEL (RX data in B)
			CMPB	#SCI_C0_CANCEL 				;check for CANCEL
			BNE	SCI_POLL_RX_11 				;no CANCEL character
			BSET	SCI_EXCPT,#SCI_EXCPT_CANCEL 		;request CANCEL handletr
			BRA	SCI_POLL_RX_16				;enable TX interrupt
SCI_POLL_RX_11		EQU	* 					;no CANCEL character
#endif
#ifmac	SCI_SUSPEND_ACTION
			;Interpret SUSPEND (RX data in B)
			CMPB	#SCI_C0_SUSPEND 			;check for SUSPEND
			BNE	SCI_POLL_RX_12 				;no SUSPEND character
			BSET	SCI_EXCPT,#SCI_EXCPT_SUSPEND 		;request SUSPEND handletr
			BRA	SCI_POLL_RX_16				;enable TX interrupt
SCI_POLL_RX_12		EQU	* 					;no SUSPEND character
#endif
#ifmac	SCI_ESCAPE_ACTION
			;Interpret ESCAPE (RX data in B)
			CMPB	#SCI_C0_ESCAPE 				;check for ESCAPE
			BNE	SCI_POLL_RX_13 				;no ESCAPE character
			BSET	SCI_EXCPT,#SCI_EXCPT_ESCAPE 		;request ESCAPE handletr
			BRA	SCI_POLL_RX_16				;enable TX interrupt
SCI_POLL_RX_13		EQU	* 					;no ESCAPE character
#endif
			;Queue RX data (metadata in A, RX data in B)
SCI_POLL_RX_14		BCLR	SCI_STAT, #(SCI_STAT_RXDLE|SCI_STAT_SWOR)	;clear DLE and SWOR status	
			TFR	D, Y					;metadata:RX data -> Y
			LDX	#SCI_RXBUF   				;buffer pointer -> X
			LDD	SCI_RXBUF_IN				;in:out -> A:B
			STY	A,X 					;store metadata:RX data in buffer
			ADDA	#2 					;advance in pointer
			ANDA	#SCI_RXBUF_MASK				;
			CBA		     				;check for buffer overflow
                 	BEQ	SCI_POLL_RX_15				;buffer overflow
			STAA	SCI_RXBUF_IN				;update IN pointer
			BRA	SCI_POLL_RX_16 				;enable TX interrupt
			;Buffer overflow 
SCI_POLL_RX_15		EQU	*
#ifmac SCI_ERRSIG_START
			BSET	SCI_STAT,#(SCI_STAT_SWOR|SCI_STAT_RXERR);set SWOR and RX error status
#else
			BSET	SCI_STAT,#SCI_STAT_SWOR			;set SWOR status
#endif	
SCI_POLL_RX_16		EQU	*
#ifndef	SCI_NOFC
			;Request control flow handler
			BSET	SCI_EXCPT,#SCI_EXCPT_RXFC		;request exception handler
#endif
			;Enable TX interrupt
			BSET	SCICR2, #TXIE				;enable TX interrupt
			;Done			
SCI_POLL_RX_17		EQU	*					;done
#emac
	
;#Helper functions
;#----------------
;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved
#macro	SCI_MAKE_BL, 2
			;Disable interrupts
LOOP			SEI
			;Call non-blocking function
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
; result: none
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

;#Calculate and set baud rate divider
; args:   D: shortest RX pulse
; result: D: BDIF value
; SSTACK: 0 bytes
;         X and Y are preserved
#macro	SCI_SET_BDIV, 0
#ifdef	SCI_V6
			;Calculate BDIV value 
#ifndef TIM_DIV_OFF
			LSLD					;double
#ifndef	TIM_DIV_2
			LSLD					;double					
#ifndef	TIM_DIV_4
			LSLD					;double
#endif
#endif
#endif
#else
			;Calculate BDIV value 
			;LSRD					;half
			;LSRD					;half
			LSRD					;half
#ifndef TIM_DIV_8
			LSRD					;half
#ifndef TIM_DIV_4
			LSRD					;half
#ifndef TIM_DIV_2
			LSRD					;half
#endif
#endif
#endif
#endif
			;Store BDIV value (BDIV in D) 
			STD	SCIBDH 				;set baud rate divider
			STD	SCI_SAVED_BDIV			;save baud rate
			ABA					;calculate checksum 
			COMA					;
			STAA	SCI_SAVED_BDIV_CS		;store checksum
			BSET 	SCI_STAT,#SCI_STAT_BDIVOK 	;mark BDIV valid
#emac

;#Load TCs for the length a given number of SCI frames into accu D
; args:   1: delay in SCI frames
; result: D: TCs roughly equivalent to 2 SCI frames
; SSTACK: 0 bytes
;         X is preserved
; SCI V6: TC = FRAMES *  10 * SCIBD * CLOCK_BUS_FREQ/TIM_FREQ
; SCI V5: TC = FRAMES * 160 * SCIBD * CLOCK_BUS_FREQ/TIM_FREQ
#macro	SCI_LDD_FRAME_DELAY, 1
#ifdef	SCI_V6	
#ifndef	SCI_BAUD_DETECT_ON        	
			;Fixed baud rate
			LDD	#((\1*10*SCI_BAUD)/TIM_FREQ) 	;TC -> D
#else
			LDD	#((\1*160*CLOCK_BUS_FREQ/TIM_FREQ);delay in bit length -> D
			LDY	SCIBDH				;baud rate divider -> Y
			EMUL					;TC -> Y:D
#endif	
#else
#ifndef	SCI_BAUD_DETECT_ON        	
			;Fixed baud rate
			LDD	#((\1*160*$140*SCI_BAUD)/TIM_FREQ);TC -> D
#else
			LDD	#(\1*160*$140*CLOCK_BUS_FREQ/TIM_FREQ);delay in bit length -> D
			LDY	SCIBDH	 			;baud rate divider -> Y
			EMUL					;TC -> Y:D
#endif	
#endif
#emac

;#Assert CTS (Clear To Send - allow incoming data)
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	SCI_ASSERT_CTS, 0
#ifdef	SCI_RTSCTS
#ifdef	SCI_CTS_WEAK_DRIVE
			BRCLR	SCI_CTS_PORT,#SCI_CTS_PIN,DONE 		;CTS already asserted
			BCLR	SCI_CTS_PORT,#SCI_CTS_PIN 		;clear CTS (allow RX data)
			BSET	SCI_CTS_DDR, #SCI_CTS_PIN		;drive speed-up pulse
			BSET	SCI_CTS_PPS, #SCI_CTS_PIN 		;select pull-down device
			BCLR	SCI_CTS_DDR, #SCI_CTS_PIN		;end speed-up pulse
DONE			EQU	* 					;done
#else
			BCLR	SCI_CTS_PORT, #SCI_CTS_PIN 		;clear CTS (allow RX data)
#endif	
#endif	
#emac	

;#Deassert CTS (stop incoming data)
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	SCI_DEASSERT_CTS, 0
#ifdef	SCI_CTS_WEAK_DRIVE
			BRSET	SCI_CTS_PORT,#SCI_CTS_PIN,DONE 		;CTS already deasserted
			BSET	SCI_CTS_PORT, #SCI_CTS_PIN 		;set CTS (prohibit RX data)
			BSET	SCI_CTS_DDR, #SCI_CTS_PIN		;drive speed-up pulse
			BCLR	SCI_CTS_PPS, #SCI_CTS_PIN 		;select pull-up device
			BCLR	SCI_CTS_DDR, #SCI_CTS_PIN		;end speed-up pulse
DONE			EQU	* 					;done
#else
			BSET	SCI_CTS_PORT, #SCI_CTS_PIN 		;set CTS (prohibit RX data)
#endif	
#emac	


	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef	SCI_CODE_START_LIN
			ORG 	SCI_CODE_START, SCI_CODE_START_LIN
#else
			ORG 	SCI_CODE_START
#endif

;#Transmit one byte - non-blocking
; args:   B: data to be send
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         X, Y, and D are preserved
SCI_TX_NB		EQU	*
			;Save registers (data in B)
			PSHX						;save X
			PSHA						;save A
			CLC						;signal failure by default
			PSHC						;save CCR
			;Write data into the TX buffer (data in B)
			LDX	#SCI_TXBUF 				;buffer pointer -> X
			LDAA	SCI_TXBUF_IN 				;in -> A
			STAB	A,X 					;store data in buffer
			;Check if there is room for this entry (data in B, in-index in A, TX buffer pointer in X)
			INCA						;increment index
			ANDA	#SCI_TXBUF_MASK				;wrap index
			CMPA	SCI_TXBUF_OUT 				;check if buffer is full
			BEQ	SCI_TX_NB_1 				;buffer is full
			;Update buffer
			STAA	SCI_TXBUF_IN 				;update in
			;Enable interrupts
			BSET	SCICR2,#TXIE	 			;enable TX interrupt
			;Signal success
			BSET	0,SP, #$01				;set C-flag
			;Restore registers
SCI_TX_NB_1		SSTACK_PREPULL	6 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULA						;restore A
			PULX						;restore X
			;Done
			RTS
			
;#Transmit one byte - blocking
; args:   B: data to be send
; result: none
; SSTACK: 8 bytes
;         X, Y, and D are preserved
SCI_TX_BL		EQU	*
			SCI_MAKE_BL	SCI_TX_NB, 6

;#Check if TX queue can hold further data
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y, and D are preserved
SCI_TX_READY_NB		EQU	*
			;Save registers
			PSHA						;sace A
			CLC						;default result: failure
			PSHC						;save CCR (incl. default result)
			;Check if there is room for this entry
			LDAA	SCI_TXBUF_IN 				;in -> A
			INCA						;increment in
			ANDA	#SCI_TXBUF_MASK 			;wrap in
			CMPA	SCI_TXBUF_OUT 				;check for overflow
			BEQ	SCI_TX_READY_NB_2 			;buffer is full			
			;Signal success
SCI_TX_READY_NB_1	BSET	0,SP, #1				;set C-flag
			;Restore registers
SCI_TX_READY_NB_2	SSTACK_PREPULL	4 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULA						;restore A
			;Done
			RTS			

;#Wait until TX queue can hold further data
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved
SCI_TX_READY_BL		EQU	*
			SCI_MAKE_BL	SCI_TX_READY_NB, 4	

;#Check if there is no more data in the TX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and B are preserved
SCI_TX_DONE_NB		EQU	*		
			;Save registers
			PSHA						;save A
			CLC						;default result: failure
			PSHC						;save CCR (incl. default result)
			;Check if TX queue is empty
			LDAA	SCI_TXBUF_IN 				;in -> A
			CMPA	SCI_TXBUF_OUT 				;check for overflow
			BEQ	SCI_TX_READY_NB_1 			;signal success			
			JOB	SCI_TX_READY_NB_2 			;signal failure			
	
;#Wait until there is no more data in the TX queue
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y and B are preserved
SCI_TX_DONE_BL		EQU	*
			SCI_MAKE_BL	SCI_TX_DONE_NB, 4	
	
;#Receive one byte - non-blocking ;OK!
; args:   none
; result: A:      error flags
;         B:      received data
;	  C-flag: set if successful
; SSTACK: 5 bytes
;         X and Y are preserved
SCI_RX_NB		EQU	*
			;Save registers
			PSHX   						;save X
			CLC						;signal failure by default
			PSHC						;save CCR
			;Check if there is data in the RX queue
			LDD	SCI_RXBUF_IN 				;A:B=in:out
			SBA		   				;A=in-out
			BEQ	SCI_RX_NB_5 				;RX buffer is empty (failure)
			;Signal success
			BSET	0,SP, #$01				;set C-flag
			;Pull entry from the RX queue (in-out in A, out in B)
			LDX	#SCI_RXBUF 				;buffer pointer -> X
			LDX	B,X  					;flags:data -> X
			ADDB	#$02					;increment out
			ANDB	#SCI_RXBUF_MASK				;wrap out
			STAB	SCI_RXBUF_OUT 				;update out
#ifndef	SCI_NOFC
			;Check if more RX buffer is running empty (in-out in A, flags:data in X)
			ANDA	#SCI_RXBUF_MASK				;adjust RX data count
			CMPA	#SCI_RX_EMPTY_LEVEL	 		;check flow control threshold
			BNE	SCI_RX_NB_2 				;don't apply flow control
			BSET	SCI_EXCPT,#SCI_EXCPT_RXFC	 	;request flow control handletr
			BSET	SCICR2, #TXIE				;enable TX interrupt
#endif	
			;Return result (flags:data in X) 
SCI_RX_NB_2		TFR	X, D					;flags:data -> D
#ifmac SCI_ERRSIG_START
			;Handle errors (flags:data in D) 
			BITA	#(SWOR|OR|NF|FE|PF)			;check for errors
			BEQ	 SCI_RX_NB_3				;no errors found			
			;Error found  (flags:data in D)
			BSET	SCI_STAT,#SCI_STAT_RXERR 		;set error state
			SCI_ERRSIG_START 				;signal error
#ifmac SCI_ERRSIG_STOP
			JOB	SCI_RX_NB_4 				;continue
			;No error found  (flags:data in D)
SCI_RX_NB_3		BRCLR	SCI_STAT,#SCI_STAT_RXERR,SCI_RX_NB_4	;no previous error
			BCLR	SCI_STAT,#SCI_STAT_RXERR 		;clear error state
			SCI_ERRSIG_STOP 				;release error signal
SCI_RX_NB_4		EQU	*
#else			
SCI_RX_NB_3		EQU	*
#endif
#endif
			;Restore registers (flags:data in D)
SCI_RX_NB_5		SSTACK_PREPULL	5 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULX						;restore X
			;Done
			RTS			
	
;#Receive one byte - blocking
; args:   none
; result: A:      error flags
;         B:      received data
; SSTACK: 7 bytes
;         X and Y are preserved
SCI_RX_BL		EQU	*
			SCI_MAKE_BL	SCI_RX_NB, 5

;#Check if there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y and D are preserved
SCI_RX_READY_NB		EQU	*
			;Save registers
			PSHD   						;save D
			CLC						;default result: failure
			PSHC						;save CCR (incl. default result)
			;Check if there is data in the RX queue
			LDD	SCI_RXBUF_IN 				;in:out -> A:B
			CBA						;check is RX data is available
			BEQ	SCI_RX_READY_NB_1 			;buffer is empty
			;Signal success
			BSET	0,SP, #1				;set C-flag
			;Restore registers
SCI_RX_READY_NB_1	SSTACK_PREPULL	5 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULD						;restore D
			;Done
			RTS

;#Wait until there is data in the RX queue
; args:   none
; result: none
; SSTACK: 7 bytes
;         X, Y and D are preserved
SCI_RX_READY_BL		EQU	*
			SCI_MAKE_BL	SCI_RX_READY_NB, 5


#ifdef	SCI_BAUD_DETECT_ON
;#Check for valid baud rate (non-blocking)
; args:   none
; result: C-flag: set if baud rate is valid
; SSTACK: 2 bytes
;         X, Y, and D are preserved
SCI_CHECK_BAUD_NB  	EQU	*
			;Set default result 
			SEC						;declare baud rate valid by default
			;Check if baud rate detection is running
			TIM_BRDIS SCI_IC_TIM,SCI_IC,SCI_CHECK_BAUD_NB_1	;baud rate is valid
			CLC						
			;Done
SCI_CHECK_BAUD_NB_1	SSTACK_PREPULL	2 				;check SSTACK
			RTS

;#Check for valid baud rate (blocking)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved
SCI_CHECK_BAUD_BL  	EQU	*
			SCI_MAKE_BL	SCI_CHECK_BAUD_NB, 2
			;Done
			SSTACK_PREPULL	2 				;check SSTACK
			RTS
#endif	

	
;ISRs
;----
#ifdef	SCI_BAUD_DETECT_ON
;#TIM IC ISR
;-----------
;  Baud rate detection: (sole purpose)	
;    SCI_BD_PULSE must be set to $FFFF before enabling baud rate detection ->enabling SCI_IC.	
;    SCI_IC serves as indicator that baud rate detection is active.	
;    SCI_OC will be enabled after the first edge has been captured.	
;    SCI_OC serves as indicator that pulse wiidth may be calculated.
;    A SCI_OC event ends baud rate detection 	
SCI_ISR_IC		EQU	*
			;########################################
			;# Baud Rate Detection                  #
			;########################################
			;Capture timestamp
			LDD	SCI_IC_TC 			;current TC -> D
			;Clear interrupt flag (current TC in D)
			TIM_CLRIF SCI_IC_TIM, SCI_IC		;clear interrupt flag			
			;Calculate pulse length (current TC in D)
			TFR	D, X 				;current TC -> X
			BRCLR	SCI_STAT,#SCI_STAT_TCVALID,SCI_ISR_IC_1;previous TC is invalid	
			SUBD	SCI_BD_LAST_TC			;pulse width -> D
			LDY	#SCI_BD_PULSE			;shortest pulse storage -> Y 
			EMINM	0,Y				;keep shortest 	
SCI_ISR_IC_1		STX	SCI_BD_LAST_TC			;update previous TC
			BSET	SCI_STAT,#SCI_STAT_TCVALID	;flag TC valid	
			;(Re-)trigger SCI_OC (current TC in X)
			STX	SCI_OC_TC 			;set timeout
			TIM_EN	SCI_OC_TIM, SCI_OC		;enable SCI_OC	
			;Done
			ISTACK_RTI
#endif

;#TIM OC ISR 
;-----------
;  Baud rate detection:	
;    Invalidate last IC edge at every OC event	
;    Calcuate and set baud rate when delay is over	
;      Restart baud rate detection if baud rate is invalid	
;  XON/XOFF flow control 	
;    Disable OC	
;    Request XON/XOFF transmission	
;  RTS polling  	
;    Disable OC	
;    Run RX/TX ISR	
SCI_ISR_OC		EQU	*
			//Clear interrupt flag 
			TIM_CLRIF, SCI_OC_TIM, SCI_OC 		;clear IF
	
#ifdef	SCI_BAUD_DETECT_ON
			;Check if baud rate detection is active
SCI_ISR_OC_BDFC		TIM_BRDIS SCI_IC_TIM, SCI_IC,SCI_ISR_OC_FC;do flow control
			;########################################
			;# Baud Rate Detection                  #
			;# ===================                  #
			;# -check shortest pulse                #
			;# -set baud rate or restart detection  #
			;# -start sci if bau rate is valid      #
			;########################################
SCI_ISR_OC_BD		EQU	*
			;Check captured pulse is too short
			LDD	SCI_BD_PULSE 			;pulse width -> D
			CPD	#SCI_BD_MIN_PULSE		;check if pulse is too short
			BHS	SCI_ISR_OC_BD_2			;pulse is long enough	
			;Restart baud rate detection
			MOVW	#$FFFF, SCI_BD_PULSE
SCI_ISR_OC_BD_1		TIM_DIS	SCI_OC_TIM, SCI_OC		;disable SCI_OC
			BCLR	SCI_STAT,#SCI_STAT_TCVALID	;flag TC invalid
			TIM_CLRIF SCI_IC_TIM, SCI_IC		;start with next edge
			JOB	SCI_ISR_OC_BD_2			;done
			;Check captured pulse is too long (pulse length in D)
SCI_ISR_OC_BD_2		CPD	#SCI_BD_MAX_PULSE		;check if pulse is too long
			BHI	SCI_ISR_OC_BD_1			;pulse is still too long	
			;Calculate baud rate divider (pulse length in D)
			SCI_SET_BDIV	       			;determine baud rate divider
			TIM_DIS	SCI_IC_TIM, SCI_IC		;stop IC
#ifmac	SCI_BDSIG_STOP
			SCI_BDSIG_STOP				;stop signaling baud rate detection	
#endif
			;Activate SCI 			
#ifdef	SCI_XONXOFF							
			MOVB 	#SCI_EXCPT_RXFC, SCI_EXCPT		;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), SCICR2 		;start SCI	
#else									
			MOVB	#(RIE|TE|RE), SCICR2 			;start SCI	
			TIM_DIS	SCI_OC_TIM, SCI_OC			;disable SCI_OC			
#endif									
#ifdef	SCI_IRQBUG_ON							
			;Start MUCts00510 workaround			
			SCI_LDD_FRAME_DELAY	1			;determine delay
 			ADDD	SCI_IRQBUG_TCNT				;add to current time
			STD	SCI_IRQBUG_TC 				;set OC
			TIM_EN	SCI_IRQBUG_TIM, SCI_IRQBUG_OC 		;enable timer
#endif
			;Done 					
SCI_ISR_OC_BD_3		ISTACK_RTI				;done	
			;########################################
			;# Flow control                         #
			;# ============                         #
			;# RTS/CTS: RTS poll delay              #
			;# XON/XOFF: XON/XOFF reminders         #
			;########################################
SCI_ISR_OC_FC		EQU	*	
#endif
#ifdef	SCI_RTSCTS
			;########################################
			;# RTS/CTS                              #
			;# =======                              #
			;# - Set TXIE after RTS poll delay      #
			;########################################
			;Enable TX interrupt
			BSET	SCI_EXCPT,#SCI_EXCPT_RXFC		;request exception handler
			BSET	SCICR2, #TXIE				;enable TX interrupt
			TIM_DIS	SCI_OC_TIM, SCI_OC			;disable OC
#endif
#ifdef SCI_XONXOFF
			;########################################
			;# XON/XOFF                             #
			;# ========                             #
			;# - send XON/XOFF reminder             #
			;########################################
			;Handle long delay
			LDD	SCI_OC_CNT 				;delay counter -> D
			DBNE	D, SCI_ISR_OC_FC_1 			;decrement delay counter			
			MOVW	#SCI_XONXOFF_DLY, SCI_OC_CNT 		;reset delay counter
			;Request XON/XOFF reminder 
			BSET	SCI_EXCPT,#SCI_EXCPT_RXFC 		;request RXFC handletr
			BSET	SCICR2, #TXIE				;enable TX interrupt
SCI_ISR_OC_FC_1		STD	SCI_OC_CNT 				;update delay counter	
#endif
			;Done 
			ISTACK_RTI					;done	

#ifdef	SCI_IRQBUG_ON
;#TIM ISR for the MUCts00510 workaround
;--------------------------------------
;  Periodically execute S12_ISR_RXTX every 1 1/2 frame times 
SCI_ISR_IRQBUG		EQU	*				
			;Advance OC
			SCI_LDD_FRAME_DELAY	1			;determine delay
			ADDD	SCI_IRQBUG_TCNT				;add to current time
			STD	SCI_IRQBUG_TC 				;set OC
			;Clear interrupt flag
			TIM_CLRIF SCI_IRQBUG_TIM, SCI_IRQBUG_OC		;clear interrupt flag
			;Execute SCI_ISR_RX 
			JOB	SCI_ISR_RXTX
#endif

;#SCI EXCPT ISR (status flags in A)
;----------------------------------
SCI_ISR_EXCPT		EQU	*
#ifndef	SCI_NOFC	
			;Handle RXFC request (status flags in A)
			;---------------------------------------
#ifdef SCI_XONXOFF			
			;Make sure TDRE is set (status flags in A)
			TSTA						;check TDRE
			BPL	SCI_ISR_EXCPT_3				;handle another exception
			;Make sure the there is no ongoing atomic sequence  
			BRSET	SCI_STAT,#SCI_STAT_TXDLE,SCI_ISR_TX_1	;complete TX sequence
#endif
			;Check if an RXFC request is pending 
			BRCLR	SCI_EXCPT,#SCI_EXCPT_RXFC,SCI_ISR_EXCPT_3;handle another exception
			;Check RX buffer 
			LDD	SCI_RXBUF_IN 				;A:B=in:out
			SBA		   				;A=in-out
			ANDA	#SCI_RXBUF_MASK				;adjust RX data count
			;Check empty level (char count in A)
			CMPA	#SCI_RX_EMPTY_LEVEL 			;check flow control threshold
			BHI	SCI_ISR_EXCPT_1 			;don't apply flow control
			;Allow incoming data 
#ifdef	SCI_XONXOFF
			MOVB	#SCI_C0_XON, SCIDRL 			;transmit XON	
#endif
#ifdef	SCI_RTSCTS
			SCI_ASSERT_CTS 					;set CTS
#endif	
			JOB	SCI_ISR_EXCPT_2 			;done
			;Check full level (char count in A)
SCI_ISR_EXCPT_1		CMPA	#SCI_RX_FULL_LEVEL 			;check flow control threshold
			BLO	SCI_ISR_EXCPT_2 			;don't apply flow control
			;Block incoming data 
#ifdef	SCI_XONXOFF
			MOVB	#SCI_C0_XOFF, SCIDRL 			;transmit XOFF	
#endif
#ifdef	SCI_RTSCTS
			SCI_DEASSERT_CTS 				;clear CTS
#endif	
SCI_ISR_EXCPT_2		;Clear RXFC request
			BCLR	SCI_EXCPT,#SCI_EXCPT_RXFC 		;clear RXFC request
SCI_ISR_EXCPT_3		EQU	*
#endif
#ifmac	SCI_BREAK_ACTION
			;Handle BREAK exceptions
			;-----------------------
			BRCLR	SCI_EXCPT,#SCI_EXCPT_BREAK,SCI_ISR_EXCPT_4;no BREAK request
			SCI_BREAK_ACTION 				;execute BREAK action
			BCLR	SCI_EXCPT,#SCI_EXCPT_BREAK 		;clear BREAK request
			JOB	SCI_ISR_EXCPT_8 			;done
SCI_ISR_EXCPT_4		EQU	*
#endif
#ifmac	SCI_CANCEL_ACTION
			;Handle CANCEL exceptions
			;-----------------------
			BRCLR	SCI_EXCPT,#SCI_EXCPT_CANCEL,SCI_ISR_EXCPT_5;no CANCEL request
			SCI_CANCEL_ACTION 				;execute CANCEL action
			BCLR	SCI_EXCPT,#SCI_EXCPT_CANCEL 		;clear CANCEL request
			JOB	SCI_ISR_EXCPT_8 			;done
SCI_ISR_EXCPT_5		EQU	*
#endif
#ifmac	SCI_SUSPEND_ACTION
			;Handle SUSPEND exceptions
			;-----------------------
			BRCLR	SCI_EXCPT,#SCI_EXCPT_SUSPEND,SCI_ISR_EXCPT_6;no SUSPEND request
			SCI_SUSPEND_ACTION 				;execute SUSPEND action
			BCLR	SCI_EXCPT,#SCI_EXCPT_SUSPEND 		;clear SUSPEND request
			JOB	SCI_ISR_EXCPT_8 			;done
SCI_ISR_EXCPT_6		EQU	*
#endif
#ifmac	SCI_ESCAPE_ACTION
			;Handle ESCAPE exceptions
			;-----------------------
			BRCLR	SCI_EXCPT,#SCI_EXCPT_ESCAPE,SCI_ISR_EXCPT_7;no ESCAPE request
			SCI_ESCAPE_ACTION 				;execute ESCAPE action
			BCLR	SCI_EXCPT,#SCI_EXCPT_ESCAPE 		;clear ESCAPE request
			;JOB	SCI_ISR_EXCPT_8 			;done
SCI_ISR_EXCPT_7		EQU	*
#endif
			;Done			
SCI_ISR_EXCPT_8		ISTACK_RTI 					;done
	
;#SCI TX ISR (status flags in A)
;-------------------------------
SCI_ISR_TX		EQU	*
			;Check action requests (status flags in A)
	                LDAB	SCI_EXCPT				;exceptions -> A
			BITB	#SCI_EXCPT_ANY 				;only check implemented requests
			BNE	SCI_ISR_EXCPT 				;process exception handlers
			;Make sure TDRE is set (status flags in A)
			TSTA						;check TDRE
			BPL	SCI_ISR_TX_4				;done
#ifdef SCI_XONXOFF			
			;Check TX flow control
SCI_ISR_TX_1		BRSET	SCI_STAT,#SCI_STAT_NOTX,SCI_ISR_TX_5	;transmission blocked
#endif
#ifdef	SCI_RTSCTS
			;Check TX flow control
			BRCLR	SCI_RTS_PORT,#SCI_RTS_PIN,SCI_ISR_TX_2	;transmission permitted
			SCI_LDD_FRAME_DELAY	1 			;poll delay -> D
			ADDD	SCI_OC_TCNT 				;new OC timestamp -> D
			STD	SCI_OC_TC	   			;setup OC
			TIM_EN	SCI_OC_TIM, SCI_OC			;enable timer
			BCLR	SCICR2, #TXIE				;disable TX interrupt
			JOB	SCI_ISR_TX_4				;done
#endif
			;Check TX buffer
SCI_ISR_TX_2		LDD	SCI_TXBUF_IN 				;in:out -> A:B
			CBA		    				;check if buffer is empty
			BEQ	SCI_ISR_TX_5 				;buffer is empty
			;Get TX data (in:out in D)
			LDY	#SCI_TXBUF 				;buffer pointer -> Y
			LDAA	B,Y 					;data -> A
			;Handle DLE code (data in A, out in B)
			BCLR	SCI_STAT,#SCI_STAT_TXDLE 		;release sequence lock					
			CMPA	#SCI_C0_DLE 				;check for DLE
			BNE	SCI_ISR_TX_3 				;no DLE code
			BSET	SCI_STAT,#SCI_STAT_TXDLE 		;flag atomic sequence		
			;Transmit data (data in A, out in B)
SCI_ISR_TX_3		STAA	SCIDRL 					;transmit data
			;Increment index (out in B)
			INCB						;advance out index 
			ANDB	#SCI_TXBUF_MASK 			;wrap out index
			STAB	SCI_TXBUF_OUT 				;update out index
			;Done			
SCI_ISR_TX_4		ISTACK_RTI 					;done
			;TX buffer is empty
SCI_ISR_TX_5		TST	SCI_EXCPT 				;RXFC->N, /others->Z, 0->V
			BGT	SCI_ISR_TX_4 				;Z + (N ^ V) = 0
			BCLR	SCICR2, #TXIE				;disable TX interrupt
			JOB	SCI_ISR_TX_4				;done
			
		
;#SCI RX/TX ISR (SCI ISR)
;------------------------
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
			BEQ	SCI_ISR_TX				;process requested actions
			
;#SCI RX ISR (status flags in A)
;-------------------------------
SCI_ISR_RX		LDAB	SCIDRL					;load receive data into accu B (clears flags)
#ifdef	SCI_BAUD_DETECT_ON
			;Drop data during baud rate detection (status flags in A, RX data in B)
			TIM_BREN SCI_IC_TIM, SCI_IC, SCI_ISR_RX_17	;drop data
#endif
			;Transfer hardware flag to metadata (status flags in A, RX data in B)
			ANDA	#(OR|NF|FE|PF)				;keep  error flags
			;Check for C0 range (metadata in A, RX data in B)
SCI_ISR_RX_1		CMPB	#SCI_C0_US 				;check for lower C0 range 
			BLE	SCI_ISR_RX_2 				;decode C0 character
			CMPB	#SCI_C0_DEL 				;check for DEL
			BNE	SCI_ISR_RX_3 				;no C0 character
SCI_ISR_RX_2		ORAA	#SCI_META_C0 				;mark as C0 character
			;Check for C1 range (metadata in A, RX data in B)
SCI_ISR_RX_3		TSTB						;check for C1 range
			BPL	SCI_ISR_RX_4				;no C1 character					
			ORAA	#SCI_META_C1 				;mark as C1 character
			;Transfer SWOR und DLE flags to metadata (metadata in A, RX data in B)
SCI_ISR_RX_4		TFR	B, X 					;RX data -> X
			LDAB	SCI_STAT 				;get status bits
			ANDB	#(SCI_STAT_RXDLE|SCI_STAT_SWOR) 		;mask DLE and SWOR
			ABA						;transfer status bits to metadata
			TFR	X, B 					;RX data -> X
			;Interpret C0 codes if there is no error (metadata in A, RX data in B)
SCI_ISR_RX_5		CMPA	#SCI_META_C0 				;check for C0 and no errors
			BNE	SCI_ISR_RX_13 				;queue RX data
			;Interpret DLE (RX data in B)
			CMPB	#SCI_C0_DLE 				;check for DLE
			BNE	SCI_ISR_RX_6 				;no DLE character
			BSET	SCI_STAT,#SCI_STAT_RXDLE 			;set DLE status
			JOB	SCI_ISR_RX_16				;done
SCI_ISR_RX_6		EQU	*					;no DLE character
#ifdef	SCI_XONXOFF
			;Interpret XON/XOFF (RX data in B)
			CMPB	#SCI_C0_XON 				;check for XON
			BNE	SCI_ISR_RX_7 				;no XON character
			BCLR	SCI_STAT,#SCI_STAT_NOTX 		;allow transmissions
			BSET	SCICR2, #TXIE				;enable TX interrupt
			JOB	SCI_ISR_RX_16				;done
SCI_ISR_RX_7		CMPB	#SCI_C0_XOFF 				;check for XOFF
			BNE	SCI_ISR_RX_8 				;no XOFF character
			BSET	SCI_STAT,#SCI_STAT_NOTX			;block transmissions
			JOB	SCI_ISR_RX_16				;done
SCI_ISR_RX_8		EQU	* 					;no XON/XOFF character
#endif			
#ifmac	SCI_BREAK_ACTION
			;Interpret BREAK (RX data in B)
			CMPB	#SCI_C0_BREAK 				;check for BREAK
			BNE	SCI_ISR_RX_9 				;no BREAK character
			BSET	SCI_EXCPT,#SCI_EXCPT_BREAK 		;request BREAK handletr
			JOB	SCI_ISR_RX_15				;enable TX interrupt
SCI_ISR_RX_9		EQU	* 					;no BREAK character
#endif
#ifmac	SCI_CANCEL_ACTION
			;Interpret CANCEL (RX data in B)
			CMPB	#SCI_C0_CANCEL 				;check for CANCEL
			BNE	SCI_ISR_RX_10 				;no CANCEL character
			BSET	SCI_EXCPT,#SCI_EXCPT_CANCEL 		;request CANCEL handletr
			JOB	SCI_ISR_RX_15				;enable TX interrupt
SCI_ISR_RX_10		EQU	* 					;no CANCEL character
#endif
#ifmac	SCI_SUSPEND_ACTION
			;Interpret SUSPEND (RX data in B)
			CMPB	#SCI_C0_SUSPEND 			;check for SUSPEND
			BNE	SCI_ISR_RX_11 				;no SUSPEND character
			BSET	SCI_EXCPT,#SCI_EXCPT_SUSPEND 		;request SUSPEND handletr
			JOB	SCI_ISR_RX_15				;enable TX interrupt
SCI_ISR_RX_11		EQU	* 					;no SUSPEND character
#endif
#ifmac	SCI_ESCAPE_ACTION
			;Interpret ESCAPE (RX data in B)
			CMPB	#SCI_C0_ESCAPE 				;check for ESCAPE
			BNE	SCI_ISR_RX_12 				;no ESCAPE character
			BSET	SCI_EXCPT,#SCI_EXCPT_ESCAPE 		;request ESCAPE handletr
			JOB	SCI_ISR_RX_15				;enable TX interrupt
SCI_ISR_RX_12		EQU	* 					;no ESCAPE character
#endif
			;Queue RX data (metadata in A, RX data in B)
SCI_ISR_RX_13		BCLR	SCI_STAT, #(SCI_STAT_RXDLE|SCI_STAT_SWOR);clear DLE and SWOR status	
			TFR	D, Y					;metadata:RX data -> Y
			LDX	#SCI_RXBUF   				;buffer pointer -> X
			LDD	SCI_RXBUF_IN				;in:out -> A:B
			STY	A,X 					;store metadata:RX data in buffer
			ADDA	#2 					;advance in pointer
			ANDA	#SCI_RXBUF_MASK				;
			CBA		     				;check for buffer overflow
                 	BEQ	SCI_ISR_RX_14				;buffer overflow
			STAA	SCI_RXBUF_IN				;update IN pointer
#ifdef	SCI_NOFC
			JOB	SCI_ISR_RX_16 				;done
#else
			;Check if flow control must be applied (in:out in D, flags:data in Y)
			SBA						;determine free buffer space
			ANDA	#SCI_RXBUF_MASK 			;
			CMPA	#SCI_RX_FULL_LEVEL 			;check for threshold
			BLO	SCI_ISR_RX_16 				;buffer is getting full
#endif
#ifdef	SCI_XONXOFF
			;Request XOFF
			BSET	SCI_EXCPT,#SCI_EXCPT_RXFC	 	;request flow control handletr
			JOB	SCI_ISR_RX_15				;enable TX interrupt
#endif
#ifdef	SCI_RTSCTS
			;Deassert CTS (flags:data in Y)
			;BSET	SCI_EXCPT,#SCI_EXCPT_RXFC	 	;request flow control handletr
			;JOB	SCI_ISR_RX_15				;enable TX interrupt
			SCI_DEASSERT_CTS 				;clear CTS
			JOB	SCI_ISR_RX_16 				;done
#endif
			;Buffer overflow 
SCI_ISR_RX_14		EQU	*
			BSET	SCI_STAT,#SCI_STAT_SWOR			;set SWOR status
			JOB	SCI_ISR_RX_16
			;Enable TX interrupt
SCI_ISR_RX_15		BSET	SCICR2, #TXIE				;enable TX interrupt
			;Done			
SCI_ISR_RX_16		ISTACK_RTI 					;done
SCI_ISR_RX_17		EQU	SCI_ISR_TX_4 				;done
	
SCI_CODE_END		EQU	*
SCI_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef	SCI_TABS_START_LIN
			ORG 	SCI_TABS_START, SCI_TABS_START_LIN
#else
			ORG 	SCI_TABS_START
#endif	

SCI_TABS_END		EQU	*
SCI_TABS_END_LIN	EQU	@
#endif
