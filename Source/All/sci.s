#ifndef	SCI_COMPILED
#define SCI_COMPILED
;###############################################################################
;# S12CBase - SCI - Serial Communication Interface Driver                      #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
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
;#    SCI_PAUSE_NB    - This function initiates a pause of the SCI             #
;#                      communication and returns status information on the    #
;#                      shut down sequence.                                    #
;#    SCI_PAUSE_BL    - This function pauses of the SCI communication. It will #
;#                      block the program flow until the communication is shut #
;#                      down.                                                  #
;#    SCI_RESUME      - This function resumes paused SCI communication.        #
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
;#   Pause/Resume:                                                             #
;#     Implement a safety period of about 2 SCI frame lengths. A pause request #
;#     is indicated by the SCI_FLG_PAUSE flag. The pause request is completed  #
;#     when the SCI_OC_CNT register is cleared.                                #
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
SCI_RXTX_ACTLO		EQU	1 		;default is active low RXD/TXD
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
;TIM instance for baud rate detection, shutdown, and flow control
#ifndef	SCI_OC_TIM
SCI_OC_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Output compare channel for baud rate detection, shutdown, and flow control
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
;Detect BREAK character -> define macro SCI_BREAK_ACTION
;#mac SCI_BREAK_ACTION, 0
;	...code to be executed on BREAK condition (inside ISR)
;#emac
;Detect SUSPEND character -> define macro SCI_SUSPEND_ACTION
;#mac SCI_SUSPEND_ACTION, 0
;	...code to be executed on SUSPEND condition (inside ISR)
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
SCI_C0_BREAK		EQU	$03 		;ctrl-c (terminate program execution)
SCI_C0_DLE		EQU	$10		;data link escape (treat next byte as data)
SCI_C0_XON		EQU	$11 		;unblock transmission
SCI_C0_XOFF		EQU	$13		;block transmission
SCI_C0_SUSPEND		EQU	$1A 		;ctrl-z (suspend program execution)
SCI_C0_US		EQU	$1A 		;last C0 character (unit separator)
SCI_C0_DEL		EQU	$7F 		;DELETE
	
;#Buffer masks		
SCI_RXBUF_MASK		EQU	SCI_TXBUF_SIZE-1;mask for rolling over the RX buffer
SCI_TXBUF_MASK		EQU	SCI_TXBUF_SIZE-1;mask for rolling over the TX buffer

;#Flow control thresholds
SCI_RX_FULL_LEVEL	EQU	 8*2		;RX buffer threshold to block transmissions
SCI_RX_EMPTY_LEVEL	EQU	 2*2		;RX buffer threshold to unblock transmissions
	
;#Flag definitions
SCI_FLG_PAUSE		EQU	$80		;pause SCI traffic (to disable interrupts)
SCI_FLG_TC_VALID	EQU	$40		;timestamp is valid
SCI_FLG_CTRL		EQU	$20		;control character
SCI_FLG_SWOR		EQU	$10		;software buffer overrun (RX buffer)
SCI_FLG_TX_XONXOFF	EQU	$08		;send XON/XOFF symbol asap
SCI_FLG_POLL_RTS	EQU	$08		;poll RTS input
SCI_FLG_RX_XOFF		EQU	$04		;don't transmit (XOFF received)
SCI_FLG_RX_ESC		EQU	$02		;character is to be escaped
SCI_FLG_TX_ESC		EQU	$01		;character is to be escaped

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
SCI_BD_DLY		EQU	$04		;idle time before ending the baud rate detection
SCI_PAUSE_DLY		EQU	$04		;pause time before disableing the SCI
SCI_XONXOFF_DLY		EQU	$FF		;XON/XOFF reminder intervall
	
;#C0 character handling
#ifdef	SCI_XONXOFF
SCI_HANDLE_C0		EQU	1		;detect XON/XOFF symbols
#endif
#ifmac	SCI_BREAK_ACTION
SCI_HANDLE_C0		EQU	1		;detect BREAK symbol
SCI_HANDLE_BREAK	EQU	1		;detect BREAK symbol
#endif
#ifmac	SCI_SUSPEND_ACTION
SCI_HANDLE_C0		EQU	1		;detect SUSPEND symbol
SCI_HANDLE_SUSPEND	EQU	1		;detect SUSPEND symbol
#endif	
	
;#RX error detection
#ifdef	SCI_HANDLE_C0
SCI_CHECK_RX_ERR	EQU	1		;check for RX errors to ignore faulty C0 charakters
#endif
#ifmac	SCI_ERRSIG_START
;Check for RX errors to start the error signal
SCI_CHECK_RX_ERR	EQU	1		;check for RX errors
#endif	
#ifmac	SCI_ERRSIG_STOP
;Check for RX errors to stop the error signal
SCI_CHECK_RX_ERR	EQU	1		;check for RX errors
#endif	

;#Dummy macros
;BREAK action
#ifnmac SCI_BREAK_ACTION	
#macro SCI_BREAK_ACTION, 0
#emac
#endif
;SUSPEND action
#ifnmac SCI_SUSPEND_ACTION	
#macro SCI_SUSPEND_ACTION, 0
#emac
#endif
;Start BD signal 
#ifnmac SCI_BDSIG_START
#macro SCI_BDSIG_START, 0
#emac
#endif
;Stop BD signal 
#ifnmac SCI_BDSIG_STOP
#macro SCI_BDSIG_STOP, 0
#emac
#endif
;Start error signal 
#ifnmac SCI_ERRSIG_START
#macro SCI_ERRSIG_START, 0
#emac
#endif
;Stop error signal 
#ifnmac SCI_ERRSIG_STOP
#macro SCI_ERRSIG_STOP, 0
#emac
#endif
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef	SCI_VARS_START_LIN
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

;#Flags
SCI_FLGS		DS	1		;status flags

;#OC event down counter
SCI_OC_CNT		DS	1		;down counter for OC events
	
#ifdef	SCI_BAUD_DETECT_ON
;#Baud rate detection (only active before the RX buffer is used)	
SCI_BD_LAST_TC		EQU	SCI_RXBUF+0 	;timer counter (share RX buffer)
SCI_BD_PULSE		EQU	SCI_RXBUF+2 	;shortest pulse (share RX buffer)
#endif

#ifdef	SCI_BAUD_DETECT_ON
;#Baud rate -> checksum (~(SCI_SAVED_BDIV[15:8]+SCI_SAVED_BDIV[7:0])
#ifdef	SCI_V6
SCI_SAVED_BDIV		DS	2		;value of the SCIBD register
#else
SCI_SAVED_BDIV		DS	1		;value of the SCIBDL register
#endif
SCI_AUTO_LOC2		DS	((~SCI_AUTO_LOC1)&1);2nd auto-place location
SCI_SAVED_BDIV_CS	EQU	((SCI_AUTO_LOC1&1)*SCI_AUTO_LOC1)+(((~SCI_AUTO_LOC1)&1)*SCI_AUTO_LOC2)
#endif

SCI_VARS_END		EQU	*
SCI_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	SCI_INIT, 0
			;Setup SCI communication
			MOVB	#SCI_FORMAT, SCICR1		;set frame format
#ifdef	SCI_FORMAT_8N2						
			MOVB	#T8, SCIDRH			;prepare 9-bit frame
#endif								
#ifdef	SCI_RXTX_ACTHI						
			MOVB	#(TXPOL|RXPOL), SCISR2		;invert RXD/TXD polarity
#endif                                                         
			;Initialize buffers			
			MOVW	#$0000,SCI_TXBUF_IN 		;set TX buffer indexes
			MOVW	#$0000,SCI_RXBUF_IN 		;set RX buffer indexes
			;Set baud rate divider 
#ifdef	SCI_BAUD_DETECT_ON
#ifdef	CLOCK_FLGS
			LDAB	CLOCK_FLGS 			;check if RAM content can be trusted
			BITA	#(PORF|LVRF)			;check for POR or LVR
			BNE	SCI_INIT_1			;set default baud rate
#endif
#ifdef	SCI_V6
			LDD	SCI_SAVED_BDIV 			;read last baud rate divider
			TFR	D, X				;save last baud rate divider
			ABA					;calculate checksum
			EORA	SCI_SAVED_BDIV_CS		;compare checksum
			IBNE	A, SCI_INIT_1			;set default baud rate
			STX	SCIBDH				;restore last baud rate
			JOB	SCI_INIT_2			;activate SCI
#else
			LDAB	SCI_SAVED_BDIV 			;read last baud rate divider
			LDAA	SCI_SAVED_BDIV_CS		;read checksum
			ABA					;compare checksum
			BCS	SCI_INIT_1			;set default baud rate
			IBNE	A, SCI_INIT_1			;set default baud rate
			CLRA					;restore last baud rate
			STX	SCIBDH				;restore last baud rate
			JOB	SCI_INIT_2			;activate SCI
#endif
#endif
SCI_INIT_1		MOVW	#SCI_BDIV, SCIBDH 		;set fixed baud rate				
			;Activate SCI 
SCI_INIT_2		CLR	SCI_OC_CNT 			;reset OC delay
#ifdef	SCI_XONXOFF
			MOVB 	#SCI_FLG_TX_XONXOFF, SCI_FLGS	;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), SCICR2 	;start SCI	
#else
			CLR     SCI_FLGS			;clear flags
			MOVB	#(RIE|TE|RE), SCICR2 		;start SCI	
#endif
#ifdef	SCI_IRQBUG_ON
			;Start MUCts00510 workaround		
			SCI_LDD_FRAME_DELAY	1		;determine delay
			ADDD	SCI_IRQBUG_TCNT			;add to current time
			STD	SCI_IRQBUG_TC 			;set OC
			TIM_EN	SCI_IRQBUG_TIM, SCI_IRQBUG_OC 	;enable timer
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
	
;#Pause SCI communication (non-blocking)
; args:   none
; result: C-flag: set if pause entry is complete
; SSTACK: 3 bytes
;         X, Y, and D are preserved
#macro	SCI_PAUSE_NB, 0
			SSTACK_JOBSR	SCI_PAUSE_NB, 3
#emac

;#Pause SCI communication (blocking)
; args:   none
; result: none
; SSTACK: 5 bytes
;         X, Y, and D are preserved
#macro	SCI_PAUSE_BL, 0
			SSTACK_JOBSR	SCI_PAUSE_BL, 5
#emac

;#Resume SCI communication
; args:   none
; result: none
; SSTACK: 2(4) bytes
;         X, Y, and D are preserved
#macro	SCI_RESUME, 0
			SSTACK_JOBSR	SCI_RESUME, 2
#emac
	
;#Perform baud rate detection (non-blocking)
; args:   none
; result: C-flag: set if baud rate detection is already complete
; SSTACK: 2 bytes
;         X, Y, and D are preserved
#macro	SCI_BAUD_DETECT_NB, 0
#ifdef	SCI_BAUD_DETECT_ON
			SSTACK_JOBSR	SCI_BAUD_DETECT_NB, 2
#endif
#emac

;#Perform baud rate detection (blocking)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved
#macro	SCI_BAUD_DETECT_BL, 0
#ifdef	SCI_BAUD_DETECT_ON
			SSTACK_JOBSR	SCI_BAUD_DETECT_BL, 4
#endif
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
			;Store BDIV value (BDIV in D) 
			STD	SCIBDH 				;set baud rate divider
			STD	SCI_SAVED_BDIV			;save baud rate
			;Store checksum (BDIV in D) 
			ABA					;calculate checksum 
			COMA					;
			STAA	SCI_SAVED_BDIV_CS		;store checksum		
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
			;Store BDIV value (BDIV in D) 
			STAB	SCIBDL 				;set baud rate divider
			STAB	SCI_SAVED_BDIV			;save baud rate
			;Store checksum (BDIV in D) 
			COMB					;
			STAB	SCI_SAVED_BDIV_CS		;store checksum		
#endif
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
	
;#Send XON/XOFF symbol
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	SCI_TX_XONXOFF, 0
			BSET	SCI_FLGS, #SCI_FLG_TX_XONXOFF		;request transmission of XON/XOFF
			;BSET	SCICR2,#TXIE	 			;enable TX interrupts
			MOVB	#(TXIE|RIE|TE|RE), SCICR2		;enable TX interrupts
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
			;BSET	SCICR2,#TXIE	 			;enable TX interrupts
			MOVB	#(TXIE|RIE|TE|RE), SCICR2		;enable TX interrupts
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
			PSHA						;sace A
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
			BEQ	SCI_RX_NB_2 				;RX buffer is empty (failure)
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
			CMPA	#(SCI_RX_EMPTY_LEVEL+1) 		;check flow control threshold
			BNE	SCI_RX_NB_2 				;don't apply flow control
#endif	
SCI_RX_NB_1		EQU	*
#ifdef	SCI_XONXOFF
			;Apply flow control (flags:data in X)
			BRSET	SCI_FLGS,SCI_FLG_PAUSE,SCI_RX_NB_2 	;pause request ongoing
			SCI_TX_XONXOFF 					;transmit XON
#endif	
#ifdef	SCI_RTSCTS
			;Apply flow control (flags:data in X)
			BRSET	SCI_FLGS,SCI_FLG_PAUSE,SCI_RX_NB_2 	;pause request ongoing
			SCI_ASSERT_CTS 					;assert CTS
#endif	
			;Return result (flags:data in X) 
SCI_RX_NB_2		TFR	X, D					;flags:data -> D
			;Restore registers (flags:data in D)
			SSTACK_PREPULL	5 				;check SSTACK
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
			SCI_MAKE_BL	SCI_RX_READY_BL, 5

;#Pause SCI communication (non-blocking)
; args:   none
; result: C-flag: set if successful
; SSTACK: 3 bytes
;         X, Y, and D are preserved
SCI_PAUSE_NB 		EQU	*
			;Save registers
			SEC						;default result: success
			PSHC						;save CCR (incl. default result)	
			;Check for pending pause request
			BRSET	SCI_FLGS,SCI_FLG_PAUSE,SCI_PAUSE_NB_1 	;pause already initiated
			;Set pause request
			BSET	SCI_FLGS,SCI_FLG_PAUSE 			;flag pause request
#ifdef	SCI_XONXOFF
			;Apply flow control
			SCI_TX_XONXOFF 					;transmit XOFF
#endif	
#ifdef	SCI_RTSCTS
			;Apply flow control
			SCI_DEASSERT_CTS 				;deassert CTS
#endif	
			;Set pause timeout			
			MOVB	#SCI_PAUSE_DLY, SCI_OC_CNT 		;reset down counter
			MOVW	SCI_OC_TCNT, SCI_OC_TC 			;reset OC register
			TIM_EN	SCI_OC_TIM, SCI_OC 			;enable timer	
			;Check if pause sequence is complete (=RIE cleared)			
SCI_PAUSE_NB_1		BRCLR	SCI_OC_CNT,#$FF,SCI_PAUSE_NB_2 		;pause sequence complete	
			;Signal failure
			BCLR	0,SP, #1				;clear C-flag
			;Restore registers
SCI_PAUSE_NB_2		SSTACK_PREPULL	3 				;check SSTACK
			PULC						;restore CCR (incl. result)
			RTS						;done

;#Pause SCI communication (blocking)
; args:   none
; result: none
; SSTACK: 5 bytes
;         X, Y, and D are preserved
SCI_PAUSE_BL		EQU	*
			SCI_MAKE_BL	SCI_PAUSE_NB, 3
	
;#Resume SCI communication
; args:   none
; result: none
; SSTACK: 2(4) bytes
;         X, Y, and D are preserved
SCI_RESUME		EQU	*			
			;Clear pause request
			BCLR	SCI_FLGS,SCI_FLG_PAUSE 			;unflag pause request
#ifndef	SCI_NOFC
			;Reenable RX traffic 
			LDD	SCI_RXBUF_IN 				;A:B=in:out
			SBA		   				;A=in-out
			ANDA	#SCI_RXBUF_MASK				;adjust RX data count
			CMPA	#SCI_RX_EMPTY_LEVEL+1 			;check flow control threshold
			BHS	SCI_RESUME_1				;keep RX traffic blocked
#ifdef	SCI_XONXOFF
			SCI_TX_XONXOFF 					;transmit XON/XOFF
#endif	
#ifdef	SCI_RTSCTS
			SCI_ASSERT_CTS 					;assert CTS
#endif	
#endif	
			;Done
SCI_RESUME_1		SSTACK_PREPULL	2 				;check SSTACK
			RTS

#ifdef	SCI_BAUD_DETECT_ON
;#Perform baud rate detection (non-blocking)
; args:   none
; result: none
; SSTACK: 2 bytes
;         X, Y, and D are preserved
SCI_BAUD_DETECT_NB  	EQU	*
			;Check for ongoing baud rate detection
			TIM_BREN SCI_IC_TIM,SCI_IC,SCI_BAUD_DETECT_NB_1	;baud rate detection already running
			;Start baud rate detection 
			MOVW	#$FFFF, SCI_BD_PULSE			;start with max. pulse length
			BCLR	SCI_FLGS,#SCI_FLG_TC_VALID		;no valid IC edge, yet
			SCI_BDSIG_START					;signal baud rate detection
			TIM_DIS	SCI_OC_TIM, SCI_OC 			;stop OC interrupts
			BCLR	SCICR2,#RE 				;disable SCI receiver
			TIM_EN	SCI_IC_TIM, SCI_IC 			;start baud rate detection	
			;Done
SCI_BAUD_DETECT_NB_1	SSTACK_PREPULL	2 				;check SSTACK
			RTS
#endif	

#ifdef	SCI_BAUD_DETECT_ON
;#Perform baud rate detection (blocking)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved
SCI_BAUD_DETECT_BL  	EQU	*
			;Initiate baud rate detection 
			SCI_BAUD_DETECT_NB 				;start baud rate detection
			;Wait until the baud rate detection is complete
SCI_BAUD_DETECT_BL_1 	SEI						;disable interrupts
			TIM_BRDIS SCI_IC_TIM,SCI_IC,SCI_BAUD_DETECT_BL_2;baud rate detected
			ISTACK_WAIT 					;wait for any event
			JOB	SCI_BAUD_DETECT_BL_1 			;check again
			;Done
SCI_BAUD_DETECT_BL_2	SSTACK_PREPULL	2 				;check SSTACK
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
			TFR	D, X 				;save current TC
			BRCLR	SCI_FLGS,#SCI_FLG_TC_VALID,SCI_ISR_IC_1;previous TC is invalid	
			SUBD	SCI_BD_LAST_TC			;pulse width -> D
			LDY	#SCI_BD_PULSE			;shortest pulse storage -> Y 
			EMINM	0,Y				;keep shortest 	
SCI_ISR_IC_1		STX	SCI_BD_LAST_TC			;update previous TC
			BSET	SCI_FLGS,#SCI_FLG_TC_VALID	;flag TC valid	
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
;  Pause:  	
;    Disable SCI when delay is over	
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
			;########################################
			;# Baud Rate Detection                  #
			;# ===================                  #
			;# -check shortest pulse                #
			;# -set baud rate or restart detection  #
			;# -start sci if bau rate is valid      #
			;########################################
			;Check if baud rate detection is active
SCI_ISR_OC_BD		TIM_BRDIS SCI_IC_TIM, SCI_IC,SCI_ISR_OC_BD_3;baud rate detection not active
			;Check captured pulse is too short
			LDD	SCI_BD_PULSE 			;pulse width -> D
			CPD	#SCI_BD_MIN_PULSE		;check if pulse is too short
			BHS	SCI_ISR_OC_BD_2			;pulse is long enough	
			;Restart baud sate detection
			MOVW	#$FFFF, SCI_BD_PULSE
SCI_ISR_OC_BD_1		TIM_DIS	SCI_OC_TIM, SCI_OC		;disable SCI_OC
			BCLR	SCI_FLGS,#SCI_FLG_TC_VALID	;flag TC invalid
			TIM_CLRIF SCI_IC_TIM, SCI_IC		;start with next edge
			ISTACK_RTI				;done
			;Check captured pulse is too long (pulse length in D)
SCI_ISR_OC_BD_2		CPD	#SCI_BD_MAX_PULSE		;check if pulse is too long
			BHI	SCI_ISR_OC_BD_1			;pulse is still too long	
			;Calculate baud rate divider (pulse length in D)
			SCI_SET_BDIV	       			;determine baud rate divider
			SCI_BDSIG_STOP				;stop signaling baud rate detection	
			TIM_DIS	SCI_IC_TIM, SCI_IC		;stop IC
			BSET	SCICR2,#RE 			;enable SCI receiver
			JOB	SCI_ISR_OC_RX			;continue
			;Next
SCI_ISR_OC_BD_3		EQU	*	
#endif
			;########################################
			;# Pause                                #
			;# =====                                #
			;# -disable SCI and timer when timeout	#
			;#  has been reached  	                #
			;########################################
			;Check if pause is requested
SCI_ISR_OC_PAUSE	BRCLR SCI_FLGS,SCI_FLG_PAUSE,SCI_ISR_OC_PAUSE_2;no pause requested
			;Check if pause length
			TST	SCI_OC_CNT			;check is pause timeout is over
			BEQ	SCI_ISR_OC_RX			;pause timeout is over
			DEC	SCI_OC_CNT			;decrement SCI_OC_CNT
#ifdef SCI_XONXOFF
			;Transmit frequent XOFFs during pause 
			SCI_TX_XONXOFF				;request XON/XOFF reminder
#endif		
SCI_ISR_OC_PAUSE_1	ISTACK_RTI				;done
			;Next
SCI_ISR_OC_PAUSE_2	EQU	*		
#ifdef	SCI_RTSCTS
			;########################################
			;# RTS polling                          #
			;# ===========                          #
			;# -enable TXIE        		        #
			;# -clear RTS poll flag                 #
			;########################################
			;Check if RTS polling is enabled
SCI_ISR_OC_RTS		BRCLR	SCI_FLGS,#SCI_FLG_POLL_RTS,SCI_ISR_OC_RTS_1;RTS polling not requested
			;Enable TX interrupt
			MOVB	#(TXIE|RIE|TE|RE), SCICR2	;enable TXIE
			;Check if RTS polling is enabled
			BCLR	SCI_FLGS,#SCI_FLG_POLL_RTS	;clear RTS poll flag
			;Next
SCI_ISR_OC_RTS_1	EQU	*
#endif
			;########################################
			;# Regular RX operation                 #
			;# ======                               #
			;# - send XON/XOFF reminder             #
			;#   or                                 #
			;# - disable timer                      #
			;########################################
SCI_ISR_OC_RX		EQU	*
#SCI_XONXOFF
			DEC	SCI_OC_CNT 			;decrement counter
			BNE	SCI_ISR_OC_RX_1			;reminder not yet required
			SCI_TX_XONXOFF				;request XON/XOFF reminder
SCI_ISR_OC_RX_1		EQU	*				;done	
#else
#ifndef	SCI_IRQBUG_ON
			TIM_DIS	SCI_OC_TIM, SCI_OC		;disable OC
#endif
#endif

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
			;Execute SCI_ISR_RXTX 
			JOB	SCI_ISR_RXTX
#else
			ISTACK_RTI				;done	
#endif
	
;#SCI TX ISR (status flags in A)
;-------------------------------
SCI_ISR_TX		BITA	#TDRE					;check if SCI is ready for new TX data
			BEQ	<SCI_ISR_TX_5				;done for now			
#ifdef	SCI_XONXOFF	
			;Check if an escape sequence is ongoing
			BRSET	SCI_FLGS, #SCI_FLG_TX_ESC, SCI_ISR_TX_1 ;Don't escape any XON/XOFF symbols
			;Check if XON/XOFF transmission is required
			BRCLR	SCI_FLGS, #SCI_FLG_TX_XONXOFF, SCI_ISR_TX_1;XON/XOFF not requested
			;Clear XON/XOFF request
			BCLR	SCI_FLGS, #SCI_FLG_TX_XONXOFF
			;Check for forced XOFF
			BRSET	SCI_FLGS, #SCI_FLG_PAUSE, SCI_ISR_TX_7	;transmit XOFF
			;Trigger next XON/XOFF reminder
			MOVB	#SCI_XONXOFF_DLY, SCI_OC_CNT 		;set OC event counter
			MOVW	SCI_OC_TCNT, SCI_OC_TC 			;set OC register
			TIM_EN	SCI_OC_TIM, SCI_OC 			;enable timer
			;Check RX queue
			LDD	SCI_RXBUF_IN 				;in:out -> D
			SBA						;in-out -> A
			ANDA	#SCI_RXBUF_MASK				;adjust entry count
			;Check XOFF theshold
			CMPA	#SCI_RX_FULL_LEVEL 			;check threshold
			BHS	<SCI_ISR_TX_7	 			;transmit XOFF
			;Check XON theshold
			CMPA	#SCI_RX_EMPTY_LEVEL			;check threshold
			BLS	<SCI_ISR_TX_6	 			;transmit XON
			;Check XOFF status
			BRSET	SCI_FLGS, #SCI_FLG_RX_XOFF, SCI_ISR_TX_3 ;stop transmitting
#endif
#ifdef	SCI_RTSCTS
			;Check RTS status
			BRCLR	SCI_RTS_PORT, #SCI_RTS_PIN, SCI_ISR_TX_1;check TX buffer
			;Poll  
       			BSET	SCI_FLGS, #SCI_FLG_POLL_RTS		;request RTS polling	
			BRSET	SCI_FLGS,SCI_FLG_PAUSE,SCI_ISR_TX_3	;no request ongoing
			SCI_LDD_FRAME_DELAY	1 			;poll delay -> D
			ADDD	SCI_OC_TCNT 				;new OC timestamp -> D
			STD	SCI_OC_TC	   			;setup OC
			TIM_EN	SCI_OC_TIM, SCI_OC			;enable timer
			JOB	SCI_ISR_TX_3				;stop transmitting
#endif
			;Check TX buffer
SCI_ISR_TX_1		LDD	SCI_TXBUF_IN
			CBA
			BEQ	<SCI_ISR_TX_3 				;stop transmitting
			;Transmit data (in-index in A, out-index in B)
			LDY	#SCI_TXBUF
#ifdef	SCI_XONXOFF
			;Check for DLE (in-index in A, out-index in B, buffer pointer in Y)
			BCLR	SCI_FLGS, #SCI_FLG_TX_ESC
			TFR	D, X
			LDAB	B,Y
			CMPB	#SCI_C0_DLE
			BNE	<SCI_ISR_TX_2
			BSET	SCI_FLGS, #SCI_FLG_TX_ESC
SCI_ISR_TX_2		STAB	SCIDRL	
			TFR	X, D
#else	
			MOVB	B,Y ,SCIDRL
#endif
			;Increment index (in-index in A, out-index in B, buffer pointer in Y)
			INCB
			ANDB	#SCI_TXBUF_MASK
			STAB	SCI_TXBUF_OUT
			CBA
			BNE	<SCI_ISR_TX_5 				;done	
			;Stop transmitting
SCI_ISR_TX_3		EQU	*
#ifdef	SCI_XONXOFF
			BRSET	SCI_FLGS, #SCI_FLG_TX_XONXOFF, SCI_ISR_TX_5;consider pending XON/XOFF symbols
#endif	
SCI_ISR_TX_4		MOVB	#(RIE|TE|RE), SCICR2 			;disable TX interrupts	
			;Done
SCI_ISR_TX_5		ISTACK_RTI
#ifdef	SCI_XONXOFF
			;Transmit XON
SCI_ISR_TX_6		MOVB	#SCI_C0_XON, SCIDRL
			JOB	SCI_ISR_TX_5				;done	
			;Transmit XOFF
SCI_ISR_TX_7		MOVB	#SCI_C0_XOFF, SCIDRL
			JOB	SCI_ISR_TX_5 				;done	
#endif	

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
			BEQ	SCI_ISR_TX				; is full or if an overrun has occured
			
;#SCI RX ISR (status flags in A)
;-------------------------------
SCI_ISR_RX		LDAB	SCIDRL					;load receive data into accu B (clears flags)
#ifdef	SCI_BAUD_DETECT_ON
			;Drop data during baud rate detection (status flags in A, RX data in B)
			;TIM_BREN SCI_IC_TIM, SCI_IC, SCI_ISR_RX_7	;drop data
			TIM_BREN SCI_IC_TIM, SCI_IC, SCI_ISR_TX_5	;drop data
#endif
			;Transfer SWOR flag to current error flags (status flags in A, RX data in B)
			ANDA	#(OR|NF|FE|PF)				;only maintain relevant error flags
			BRCLR	SCI_FLGS, #SCI_FLG_SWOR, SCI_ISR_RX_1	;SWOR bit not set
			ORAA	#SCI_FLG_SWOR				;set SWOR bit in accu A
			BCLR	SCI_FLGS, #SCI_FLG_SWOR 		;clear SWOR bit in variable	
SCI_ISR_RX_1		EQU	*
#ifdef	SCI_CHECK_RX_ERR
			;Check for RX errors (status flags in A, RX data in B)
			BITA	#(SCI_FLG_SWOR|OR|NF|FE|PF) 		;don't handle control characters with errors
			BNE	<SCI_ISR_RX_3  				;queue data
			SCI_ERRSIG_STOP 				;release error signal
#endif
#ifdef	SCI_HANDLE_C0
			;Check character is escaped (status flags in A, RX data in B)
			BRSET	SCI_FLGS,#SCI_FLG_RX_ESC,SCI_ISR_RX_3	;charakter is escaped (skip detection)			
			;Check for DEL charakter (status flags in A, RX data in B)
			CMPB	#SCI_C0_DEL	 			;check for DEL charakter
			BEQ	<SCI_ISR_RX_2				;flag control character
			;Check for C0 charakters (status flags in A, RX data in B)
			CMPB	#SCI_C0_US	 			;check for C0 charakters
			BHI	<SCI_ISR_RX_3				;C1 character found
#ifdef	SCI_XONXOFF
			;Process XOFF (status flags in A, RX data in B)
			CMPB	#SCI_C0_XOFF 				;check for XOFF
			BEQ	<SCI_ISR_RX_8				;handle XOFF
			;Process XOFF (status flags in A, RX data in B)
			CMPB	#SCI_C0_XOFF 				;check for XON
			BEQ	<SCI_ISR_RX_9				;handle XON
#endif
			;Process DLE (status flags in A, RX data in B)
			CMPB	#SCI_C0_DLE 				;check for DLE
			BEQ	<SCI_ISR_RX_10				;handle DLE

#ifdef	SCI_HANDLE_BREAK
			;Process BREAK (status flags in A, RX data in B)
			CMPB	#SCI_C0_BREAK 				;check for BREAK
			BEQ	<SCI_ISR_RX_11 				;handle BREAK
#endif
#ifdef	SCI_HANDLE_SUSPEND
			;Process SUSPEND (status flags in A, RX data in B)
			CMPB	#SCI_C0_SUSPEND 			;check for SUSPEND
			BEQ	SCI_ISR_RX_12 				;handle SUSPEND
#endif
			;Handle other C0 characters (status flags in A, RX data in B)
SCI_ISR_RX_2		ORAA	#SCI_FLG_CTRL 				;flag control character
#endif
			;Place data into RX queue (status flags in A, RX data in B)
SCI_ISR_RX_3		EQU	*
#ifdef	SCI_HANDLE_C0
			BCLR	SCI_FLGS, #SCI_FLG_RX_ESC		;remove escape flag			
#endif
			TFR	D, Y					;flags:data -> Y
			LDX	#SCI_RXBUF   				;buffer pointer -> X
			LDD	SCI_RXBUF_IN				;in:out -> A:B
			STY	A,X 					;store flags:data in buffer
			ADDA	#2 					;advance in pointer
			ANDA	#SCI_RXBUF_MASK				;
			CBA		     				;check for buffer overflow
                	BEQ	<SCI_ISR_RX_13				;buffer overflow
			STAA	SCI_RXBUF_IN				;update IN pointer
#ifndef	SCI_NOFC
			;Check if flow control must be applied (in:out in D, flags:data in Y)
			SBA
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_RX_FULL_LEVEL
			BHS	<SCI_ISR_RX_14 				;buffer is getting full
#endif
			;Restart pause time-out	(flags:data in Y) 
SCI_ISR_RX_4		BRCLR	SCI_FLGS,#SCI_FLG_PAUSE,SCI_ISR_RX_5	;no pause requested
			MOVB	#SCI_PAUSE_DLY, SCI_OC_CNT 		;reset down counter
			MOVW	SCI_OC_TCNT, SCI_OC_TC 			;reset OC register
#ifdef	SCI_XONXOFF
			JOB	SCI_ISR_RX_6
			;Restart XON/XOFF reminder delay (flags:data in Y)
SCI_ISR_RX_5		MOVB	#SCI_XONXOFF_DLY, SCI_OC_CNT 		;reset down counter
			MOVW	#SCI_OC_TCNT, SCI_OC_TC 		;reset down counter
SCI_ISR_RX_6		EQU	*
#else
SCI_ISR_RX_5		EQU	SCI_ISR_RX_7 				;done
#endif
			MOVW	SCI_OC_TCNT, SCI_OC_TC 			;adjust OC
			TIM_CLRIF SCI_OC_TIM, SCI_OC 			;clear interrupt flag
			;Done
SCI_ISR_RX_7		EQU	* 					;done
#ifmac	RANDOM_SHIFT_TIM
			RANDOM_SHIFT_TIM SCI_OC_TIM 			;randomize on input
#endif
			ISTACK_RTI					;done
#ifdef	SCI_HANDLE_C0
			;Handle C0 characters (status flags in A, RX data in B)	
#ifdef	SCI_XONXOFF
			;XOFF
SCI_ISR_RX_8		BSET	SCI_FLGS,#SCI_FLG_RX_XOFF 		;stop transmissions	
			JOB	SCI_ISR_RX_5				;delay XON/XOFF reminder
			;XON
SCI_ISR_RX_9		BCLR	SCI_FLGS,#SCI_FLG_RX_XOFF 		;resume transmissions	
			JOB	SCI_ISR_RX_5				;delay XON/XOFF reminder
#endif
			;DLE
SCI_ISR_RX_10		BSET	SCI_FLGS,#SCI_FLG_RX_ESC 		;escape next RX char	
			JOB	SCI_ISR_RX_4				;restart pause delay
#ifdef	SCI_HANDLE_BREAK
			;BREAK
SCI_ISR_RX_11		SCI_BREAK_ACTION 				;BREAK action	
			JOB	SCI_ISR_RX_7				;done
			;ISTACK_RTI 					;done
#endif
#ifdef	SCI_HANDLE_SUSPEND
			;SUSPEND
SCI_ISR_RX_12		SCI_SUSPEND_ACTION 				;SUSPEND action
			JOB	SCI_ISR_RX_7				;done
			;ISTACK_RTI 					;done
#endif
#endif
			;Buffer overflow
SCI_ISR_RX_13		BSET	SCI_FLGS, #SCI_FLG_SWOR 		;set SWOR bit (software overrun)	
#ifdef	SCI_XONXOFF
			;Apply flow control (flags:data in Y)
SCI_ISR_RX_14		SCI_TX_XONXOFF 					;signal XOFF
#endif
#ifdef	SCI_RTSCTS
			;Apply flow control (flags:data in Y)
SCI_ISR_RX_14		SCI_DEASSERT_CTS 				;clear CTS
#endif
			JOB	SCI_ISR_RX_4				;restart pause delay
	
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
