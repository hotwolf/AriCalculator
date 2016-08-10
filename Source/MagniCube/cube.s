#ifndef CUBE_COMPILED
#define CUBE_COMPILED
;###############################################################################
;# S12CBase - CUBE - LED Cube Driver                                           #
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
;#                                                                             #
;#   Y                              Anode connections:                         #
;#  /         C3---C7---C11--C15    C0: PAD0     C8:  PP0                      #
;#  --X       /    /    /    / |    C1: PAD1     C9:  PP1                      #
;# |        C2---C6---C10--C14 @    C2: PAD2     C10: PP2                      #
;# Z        /    /    /    / |/|    C3: PAD3     C11: PP3                      #
;#        C1---C5---C9---C13 @ @    C4: PAD4     C12: PP4                      #
;#        /    /    /    / |/|/|    C5: PAD5     C13: PP5                      #
;#  L0  C0---C4---C8---C12 @ @ @    C6: PE0      C14: PS2                      #
;#       |    |    |    | /|/|/     C7: PE1      C15: PS3                      #
;#  L1  C0---C4---C8---C12 @ @                                                 #
;#       |    |    |    | /|/       Cathode connections:                       #
;#  L2  C0---C4---C8---C12 @        L0: PT0                                    #
;#       |    |    |    | /         L1: PT1                                    #
;#  L3  C0---C4---C8---C12          L2: PT2                                    #
;#                                  L3: PT3                                    #
;#                                                                             #
;# LED state format (unsigned 64-bit integer):                                 #
;#                                                                             #
;#                  C15         C14         C13         C12                    #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              63       60 59       56 55       52 51       48                #
;#                  C11         C10         C9          C8                     #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              47       44 43       40 39       36 35       32                #
;#                  C7          C6          C5          C4                     #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              31       28 27       24 23       20 19       16                #
;#                  C3          C2          C1          C0                     #
;#             +-----------+-----------+-----------+-----------+               #
;#             |L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|L3 L2 L1 L0|               #
;#             +-----------+-----------+-----------+-----------+               #
;#              15       12 11        8  7        4  3        0                #
;#                                                                             #
;#    This is the low level driver for the CUBE module.                        #
;#                                                                             #
;#    This module provides the following functions to the main program:        #
;#    CUBE_QUEUE_FRAME  - This function puts a frame pattern into the display  #
;#                        queue.                                               #
;#    CUBE_QUEUE_FRAMES - This function puts a frame pattern multiple times    #
;#      	          into the display queue.                              #	
;#                        queue.                                               #
;#                                                                             #
;#    The display queue is emptied at FRAMERATE frames/sec. When the display   #
;#    runs empty, the last submitted frame is repeated until new content is    #
;#    provided. Each frame is rebeated SUBFRAMES times.                        #
;###############################################################################
;# Timer usage:                                                                #
;#   Baud rate detection:                                                      #
;#     Set IC to capture any transition of the RX pin. Keep track of the       #
;#     shortest valid RX pulse. Everytime a pulse is captured set the OC 16    #
;#     times the length of the shortest pulse. When the OC times out, the      #
;#     shortest pulse and the associated baud rate has been detected. The      #
;#     CUBE can be enabled immediately.                                         #
;#     The baud rate detection is should always detect the character           #
;#     combination CR LF ($0D_0A -> %00001101_00001010).                       #
;#     Active baud rate detection is indicated by the enabled IC channel.      #
;#                                                                             #
;###############################################################################
;# Modes:                                                                      #
;#   Baud rate detection:                                                      #
;#     LED:      signal BD mode                                                #
;#     RX:       disable                                                       #
;#     TX:       drop any request                                              #
;#     RTS/CTS:  deassert CTS                                                  #
;#     XON/XOFF: --                                                            #
;#                                                                             #
;#   Active:                                                                   #
;#                                                                             #
;#                                                                             #
;#   Active/RX error (Active)                                                  #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#   Deactivation:                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#   Inactive:                                                                 #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#  12 fps * 4 subframes * 16 columns -> 768 Hz                                #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
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
;#      - added functions CUBE_TBE and CUBE_BAUD                                 #
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
;#      - Made CUBE_TXBUF_SIZE configurable                                     #
;#    October 1, 2014                                                          #
;#      - Added dynamic enable/disable feature                                 #
;#    January 14, 2015                                                         #
;#      - Changed configuration options                                        #
;#      - Changed control character handling                                   #
;#    October 28, 2015                                                         #
;#      - Added feature to halt CUBE communication                              #
;#    April 23, 2009                                                           #
;#      - Moved from countinuous to initial baud rate detection                #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;CUBE version
#ifndef	CUBE_V6
#ifndef	CUBE_V5
#ifndef	CUBE_V4
#ifndef	CUBE_V3
CUBE_V5			EQU	1	 	;default is V5
#endif
#endif
#endif
#endif
	
;Bus frequency
#ifndef	CLOCK_BUS_FREQ
CLOCK_BUS_FREQ		EQU	25000000 	;default is 25MHz
#endif
	
;Invert RXD/TXD
#ifndef	CUBE_RXTX_ACTLO
#ifndef	CUBE_RXTX_ACTHI
CUBE_RXTX_ACTLO		EQU	1 		;default is active low RXD/TXD
#endif
#endif
	
;TIM configuration
;TIM instance for baud rate detection
#ifndef	CUBE_IC_TINST
CUBE_IC_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Input capture channel for baud rate detection
#ifndef	CUBE_IC
CUBE_IC			EQU	0 		;default is IC0
#endif
;TIM instance for baud rate detection, shutdown, flow control, and MC9S12DP256 IRQ workaround
#ifndef	CUBE_IC_TINST
CUBE_IC_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
;Output compare channel for baud rate detection, shutdown, flow control, and MC9S12DP256 IRQ workaround
;Past baud rate detection, the OC will always measure time periods of roughly 2 CUBE frames
#ifndef	CUBE_OC
CUBE_OC			EQU	0 		;default is OC0
#endif
	
;Baud rate
;---------
#ifndef CUBE_BAUD_AUTO
#ifndef CUBE_BAUD_9600 	
#ifndef CUBE_BAUD_14400	
#ifndef CUBE_BAUD_19200	
#ifndef CUBE_BAUD_28800	
#ifndef CUBE_BAUD_38400	
#ifndef CUBE_BAUD_57600	
#ifndef CUBE_BAUD_76800       	
#ifndef CUBE_BAUD_115200		
#ifndef CUBE_BAUD_153600
CUBE_BAUD_AUTO		EQU	1 		;default is auto detection
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
	
;Frame format
;------------
#ifndef CUBE_FORMAT_8N1
#ifndef CUBE_FORMAT_8E1
#ifndef CUBE_FORMAT_8O1
#ifndef CUBE_FORMAT_8N2
CUBE_FORMAT_8N1		
#endif
#endif
#endif
#endif
	
;Flow control
;------------
;RTS/CTS or XON/XOFF
#ifndef	CUBE_FC_RTSCTS
#ifndef	CUBE_FC_XONXOFF
#ifndef CUBE_FC_NONE	
CUBE_FC_RTSCTS		EQU	1 		;default is CUBE_RTSCTS
#endif
#endif
#endif

;XON/XOFF coniguration
#ifdef	CUBE_FC_XONXOFF
;XON/XOFF reminder intervall
#ifndef	CUBE_XONXOFF_REMINDER
CUBE_XONXOFF_REMINDER	EQU	(10*TIM_FREQ)/65536
#endif
#endif

;RTS/CTS coniguration
#ifdef CUBE_FC_RTSCTS
;RTS pin
#ifndef	CUBE_RTS_PORT
CUBE_RTS_PORT		EQU	PTM 		;default is PTM
#endif
#ifndef	CUBE_RTS_PIN	
CUBE_RTS_PIN		EQU	PM0		;default is PM0
#endif
;CTS pin
#ifndef	CUBE_CTS_PORT
CUBE_CTS_PORT		EQU	PTM 		;default is PTM
#endif
#ifndef	CUBE_CTS_DDR
CUBE_CTS_DDR		EQU	DDRM 		;default is DDRM
#endif
#ifndef	CUBE_CTS_PPS
CUBE_CTS_PPS		EQU	PPSM 		;default is PPSM
#endif
#ifndef	CUBE_CTS_PIN
CUBE_CTS_PIN		EQU	PM1		;default is PM1
#endif
;CTS drive strength
#ifndef	CUBE_CTS_WEAK_DRIVE
#ifndef	CUBE_CTS_STRONG_DRIVE
CUBE_CTS_STRONG_DRIVE	EQU	1		;default is strong drive
#endif
#endif
#endif

;MC9S12DP256 CUBE IRQ workaround (MUCts00510)
;-------------------------------------------
;###############################################################################
;# The will CUBE only request interrupts if an odd number of interrupt flags is #
;# This will cause disabled and spourious interrupts.                          #
;# -> The RX/TX ISR must be periodically triggered by a timer interrupt.       #
;#    The timer period should be about as long as two CUBE frames:              #
;#    RT cycle = CUBEBD * bus cycles                                            #
;#    bit time = 16 * RT cycles = 16 * CUBEBD * bus cycles                      #
;#    frame time = 10 * bit times = 160 RT cycles = 160 * CUBEBD * bus cycles   #
;#    2 * frame times = 320 * CUBEBD * bus cycles = 0x140 * CUBEBD * bus cycles  #
;#    Simplification:                                                          #
;#    TIM period = 0x100 * CUBEBD * bus cycles                                  #
;###############################################################################
;Enable workaround for MUCts00510
#ifndef	CUBE_IRQBUG_ON
#ifndef	CUBE_IRQBUG_OFF
CUBE_IRQ_IRQBUG_OFF	EQU	1 		;IRQ workaround disabled by default
#endif
#endif

;#Buffer sizes		
#ifndef	CUBE_RXBUF_SIZE	
CUBE_RXBUF_SIZE		EQU	 16*2		;size of the receive buffer (8 error:data entries)
#endif
#ifndef	CUBE_TXBUF_SIZE	
CUBE_TXBUF_SIZE		EQU	  8		;size of the transmit buffer
#endif
	
;C0 character handling
;---------------------
;Detect BREAK character -> define macro CUBE_BREAK_ACTION
;#mac CUBE_BREAK_ACTION, 0
;	...code to be executed on BREAK condition (inside ISR)
;#emac
;Detect SUSPEND character -> define macro CUBE_SUSPEND_ACTION
;#mac CUBE_SUSPEND_ACTION, 0
;	...code to be executed on SUSPEND condition (inside ISR)
;#emac

;Communication error signaling
;-----------------------------
;Signal active baud rate detection -> define macros CUBE_BDSIG_START and CUBE_BDSIG_STOP
;#mac CUBE_BDSIG_START, 0
;	...code to start signaling active baud rate detection (inside ISR)
;#emac
;#mac CUBE_BDSIG_STOP, 0
;	...code to stop signaling active baud rate detection (inside ISR)
;#emac
	
;Signal RX errors -> define macros CUBE_ERRSIG_START and CUBE_ERRSIG_STOP
;#mac CUBE_ERRSIG_START, 0
;	...code to start error signaling (inside ISR)
;#emac
;#mac CUBE_ERRSIG_STOP, 0			;X, Y, and D are preserved
;	...code to stop error signaling (inside ISR)
;#emac
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Parameter check
#ifdef TIM_DIV_16
			ERROR	"Parameter TIM_DIV_16 not supported by CUBE"
#endif
#ifdef TIM_DIV_32
			ERROR	"Parameter TIM_DIV_32 not supported by CUBE"
#endif
#ifdef TIM_DIV_64
			ERROR	"Parameter TIM_DIV_64 not supported by CUBE"
#endif
#ifdef TIM_DIV_128
			ERROR	"Parameter TIM_DIV_128 not supported by CUBE"
#endif

;#Baud rate
#ifdef CUBE_BAUD_9600        	
CUBE_BAUD		EQU	9600
#endif
#ifdef CUBE_BAUD_14400       	
CUBE_BAUD		EQU	14400
#endif
#ifdef CUBE_BAUD_19200       	
CUBE_BAUD		EQU	19200
#endif
#ifdef CUBE_BAUD_28800       	
CUBE_BAUD		EQU	28800
#endif
#ifdef CUBE_BAUD_38400       	
CUBE_BAUD		EQU	38400
#endif
#ifdef CUBE_BAUD_57600       	
CUBE_BAUD		EQU	57600
#endif
#ifdef CUBE_BAUD_76800       	
CUBE_BAUD		EQU	76800
#endif
#ifdef CUBE_BAUD_115200		
CUBE_BAUD		EQU	115200
#endif
#ifdef CUBE_BAUD_153600
CUBE_BAUD		EQU	153600
#endif
	
;#Baud rate divider (CUBEBD)
; CUBE V5: CUBEBD = bus clock / (16*baud rate)
; CUBE V6: CUBEBD = bus clock / (baud rate)
#ifndef CUBE_BAUD_AUTO	
#ifdef	CUBE_V6
CUBE_BDIV		EQU	(CLOCK_BUS_FREQ/CUBE_BAUD)+(((2*CLOCK_BUS_FREQ)/CUBE_BAUD)&1)			
#else
CUBE_BDIV		EQU	(CLOCK_BUS_FREQ/(16*CUBE_BAUD))+(((2*CLOCK_BUS_FREQ)/(16*CUBE_BAUD))&1)
#endif
#endif

;#Pulse range for faud rate detection
;max. baud rate:  153600 baud +10% = 168960 baud
;min. baud rate:  TIM_FREQ/$FFFF   ~ 7626 baud (TIM_FREQ=25MHz)
CUBE_BD_MAX_BAUD		EQU	168960 				;highest baud rate
CUBE_BD_MIN_BAUD		EQU	20*TIM_FREQ/$FFFF		;lowest baud rate
CUBE_BD_MIN_PULSE	EQU	TIM_FREQ/CUBE_BD_MAX_BAUD	;shortest bit pulse
CUBE_BD_MAX_PULSE	EQU	TIM_FREQ/CUBE_BD_MIN_BAUD	;longest bit pulse
	
;#Frame format
CUBE_8N1			EQU	  ILT		;8N1
CUBE_8E1			EQU	  ILT|PE	;8E1
CUBE_8O1			EQU	  ILT|PE|PT	;8O1
CUBE_8N2		 	EQU	M|ILT		;8N2 TX8=1

#ifdef CUBE_FORMAT_8N1
CUBE_FORMAT		EQU	CUBE_8N1
#endif
#ifdef CUBE_FORMAT_8E1
CUBE_FORMAT		EQU	CUBE_8E1
#endif
#ifdef CUBE_FORMAT_8O1
CUBE_FORMAT		EQU	CUBE_8O1
#endif
#ifdef CUBE_FORMAT_8N2
CUBE_FORMAT		EQU	CUBE_8N2
#endif
	
;#C0 characters
CUBE_C0_MASK		EQU	$E0 		;mask for C0 character range
CUBE_BREAK		EQU	$03 		;ctrl-c (terminate program execution)
CUBE_DLE			EQU	$10		;data link escape (treat next byte as data)
CUBE_XON			EQU	$11 		;unblock transmission
CUBE_XOFF		EQU	$13		;block transmission
CUBE_SUSPEND		EQU	$1A 		;ctrl-z (suspend program execution)

;#Buffer masks		
CUBE_RXBUF_MASK		EQU	CUBE_TXBUF_SIZE-1;mask for rolling over the RX buffer
CUBE_TXBUF_MASK		EQU	CUBE_TXBUF_SIZE-1;mask for rolling over the TX buffer

;#Flow control thresholds
CUBE_RX_FULL_LEVEL	EQU	 8*2		;RX buffer threshold to block transmissions
CUBE_RX_EMPTY_LEVEL	EQU	 2*2		;RX buffer threshold to unblock transmissions
	
;#Flag definitions
CUBE_FLG_PAUSE		EQU	$80		;pause CUBE traffic (to disable interrupts)

CUBE_FLG_PAUSE_DLY	EQU	$60 		;delay counter
	
CUBE_FLG_SWOR		EQU	$10		;software buffer overrun (RX buffer)
CUBE_FLG_TX_XONXOFF	EQU	$08		;send XON/XOFF symbol asap
CUBE_FLG_RX_XOFF		EQU	$04		;don't transmit (XOFF received)
CUBE_FLG_RX_ESC		EQU	$02		;character is to be escaped
CUBE_FLG_TX_ESC		EQU	$01		;character is to be escaped

;#Flow control
#ifdef	CUBE_FC_RTSCTS
CUBE_FC_ON		EQU	1 		;use flow control
#endif	
#ifdef	CUBE_FC_XONXOFF
CUBE_FC_ON		EQU	1 		;use flow control
#endif	

;#Timer usage and configuration
#ifdef CUBE_BAUD_AUTO
CUBE_OC_ON		EQU	1		;use OC
CUBE_IC_ON		EQU	1 		;use IC
CUBE_TIOS_INIT		EQU	1<<CUBE_OC 	;use OC
CUBE_TCTL34_INIT		EQU	3<<CUBE_IC	;capture any edge (baud rate detection)
#else
#ifdef	CUBE_FC_ON
CUBE_OC_ON		EQU	1		;use OC
CUBE_IC_OFF		EQU	1		;no IC needed
CUBE_TIOS_INIT		EQU	1<<CUBE_OC 	;use OC
CUBE_TCTL34_INIT		EQU	0		;no IC needed
#else
#ifdef	CUBE_IRQBUG_ON
CUBE_OC_ON		EQU	1		;use OC
CUBE_IC_OFF		EQU	1		;no IC needed
CUBE_TIOS_INIT		EQU	1<<CUBE_OC 	;use OC
CUBE_TCTL34_INIT		EQU	0		;no IC needed
#else
CUBE_OC_OFF		EQU	1		;no OC needed
CUBE_IC_OFF		EQU	1		;no IC needed
CUBE_TIOS_INIT		EQU	0 		;use OC
CUBE_TCTL34_INIT		EQU	0		;no IC needed
#endif	
#endif	
#endif	

;#Timer channels
CUBE_ICTC		EQU	TC0+(2*CUBE_IC)	;IC capture register
CUBE_OCTC		EQU	TC0+(2*CUBE_OC)	;OC compare register
	
;#RX error detection33
#ifdef	CUBE_FC_XONXOFF
CUBE_CHECK_RX_ERR	EQU	1		;check for RX errors to ignore faulty XON/XOFF symbols
#endif
#ifmac	CUBE_BREAK_ACTION
CUBE_CHECK_RX_ERR	EQU	1		;check for RX errors to ignore faulty BREAK symbols
#endif
#ifmac	CUBE_SUSPEND_ACTION
CUBE_CHECK_RX_ERR	EQU	1		;check for RX errors to ignore faulty SUSPEND symbols
#endif	
#ifmac	CUBE_ERRSIG_START160*CLOCK_BUS_FREQ)/TIM_FREQ
;Check for RX errors to start the error signal
CUBE_CHECK_RX_ERR	EQU	1		;check for RX errors
#endif	
#ifmac	CUBE_ERRSIG_STOP
;Check for RX errors to stop the error signal
CUBE_CHECK_RX_ERR	EQU	1		;check for RX errors
#endif	

;#C0 character handling
#ifdef	CUBE_FC_XONXOFF160*CLOCK_BUS_FREQ)/TIM_FREQ
CUBE_DETECT_C0		EQU	1		;detect XON/XOFF symbols
#endif
#ifmac	CUBE_BREAK_ACTION
CUBE_DETECT_C0		EQU	1		;detect BREAK symbol
#endif
#ifmac	CUBE_SUSPEND_ACTION
CUBE_DETECT_C0		EQU	1		;detect SUSPEND symbol
#endif	
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef CUBE_VARS_START_LIN
			ORG 	CUBE_VARS_START, CUBE_VARS_START_LIN
#else
			ORG 	CUBE_VARS_START
CUBE_VARS_START_LIN	EQU	@			
#endif	

CUBE_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1
;#Receive buffer	
CUBE_RXBUF		DS	CUBE_RXBUF_SIZE
CUBE_RXBUF_IN		DS	1		;points to the next free space
CUBE_RXBUF_OUT		DS	1		;points to the oldest entry
;#Transmit buffer
CUBE_TXBUF		DS	CUBE_TXBUF_SIZE
CUBE_TXBUF_IN		DS	1		;points to the next free space
CUBE_TXBUF_OUT		DS	1		;points to the oldest entry

#ifdef CUBE_FC_XONXOFF	
;#OC event down counter
CUBE_XONXOFF_CNT		DS	2		;counter for XONXOFF reminder
#endif
	
#ifndef CUBE_BAUD_AUTO
;#Baud rate detection (only active before the RX buffer is used)	
CUBE_BD_LAST_TC		EQU	CUBE_RXBUF+0 	;timer counter (share RX buffer)
CUBE_BD_PULSE		EQU	CUBE_RXBUF+2 	;shortest pulse (share RX buffer)
;#Baud rate (reset proof)
CUBE_SAVED_BDIV		DS	2		;value of the CUBEBD register
CUBE_SAVED_BDIV_CS	DS	1		;checksum (~(CUBE_SAVED_BDIV[15:8]+CUBE_SAVED_BDIV[7:0])
#endif
	
CUBE_AUTO_LOC2		EQU	*		;2nd auto-place location

;#Flags
CUBE_FLGS		EQU	((CUBE_AUTO_LOC1&1)*CUBE_AUTO_LOC1)+(((~CUBE_AUTO_LOC1)&1)*CUBE_AUTO_LOC2)
			ALIGN	((~CUBE_AUTO_LOC1)&1)
	
CUBE_VARS_END		EQU	*
CUBE_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	CUBE_INIT, 0
			;Setup CUBE communication
			MOVB	#CUBE_FORMAT, CUBECR1		;set frame format
#ifdef	CUBE_FORMAT_8N2						
			MOVB	#T8, CUBEDRH			;prepare 9-bit frame
#endif								
#ifdef	CUBE_RXTX_ACTHI						
			MOVB	#(TXPOL|RXPOL), CUBESR2		;invert RXD/TXD polarity
#endif                                                         
			;Initialize flags                            
			CLR	CUBE_FLGS			;clear flags
			;Initialize buffers			
			MOVW	#$0000,CUBE_TXBUF_IN 		;set TX buffer indexes
			MOVW	#$0000,CUBE_RXBUF_IN 		;set RX buffer indexes

			;Set baud rate divider 
#ifdef	CUBE_BAUD_AUTO
#ifdef	CLOCK_FLGS
			LDAB	CLOCK_FLGS 			;check if RAM content can be trusted
			BITA	#(PORF|LVRF)			;check for POR or LVR
			BNE	START_BD			;start baud rate detection
#endif
			LDD	CUBE_SAVED_BDIV 			;read last baud rate divider
			TFR	D, X				;save last baud rate divider
			ABA					;calculate checksum
			EORA	CUBE_SAVED_BDIV_CS		;compare checksums
			IBNE	A, START_BD			;start baud rate detection
			STX	CUBEBD				;restore last baud rate
			JOB	GO				;activate CUBE	
START_BD		MOVW	#$FFFF, CUBE_BD_PULSE		;start with max. pulse length
#ifmac	CUBE_BDSIG_START
			CUBE_BDSIG_START				;signal baud rate detection
#endif
			TIM_EN	CUBE_IC_TIM, CUBE_IC 		;start baud rate detection
			JOB	DONE
#else
			MOVW	#CUBE_BDIV, CUBEBD 		;set fixed baud rate
	
			;Activate CUBE 
			CUBE_GO					;start CUBE
DONE			EQU	*				;done
#emac

;#Helper functions
;#----------------
;#Activate the CUBE (at initialzation)
; args:   none
; result: none
; SSTACK: 0 bytes
;         X is preserved
; Must not be interrupted by
#macro	CUBE_GO, 0
			;Activate CUBE 
			MOVB	#



;#Deactivate CUBE
; args:   none
; result: none
; SSTACK: 0 bytes
;         X is preserved
; Must not be interrupted by
#macro	CUBE_PAUSE, 0
			;Activate CUBE 


;#Reactivate CUBE
; args:   none
; result: none
; SSTACK: 0 bytes
;         X is preserved
; Must not be interrupted by
#macro	CUBE_RESUME, 0
			;Activate CUBE 






	



;#User functions
;#--------------
;#Activate CUBE
; args:   none
; result: none
; SSTACK: 0 bytes
;         X is preserved
; Must not be interrupted by
#macro	CUBE_GO, 0
			;Activate CUBE 
#ifdef CUBE_FC_RTSCTS
			;Initialize RTS/CTS flow control (allow incoming data)
			








;#Start OC delay
; args:   1: Pointer to 
; result: none
; SSTACK: 0 bytes
;         X is preserved
; Must not be interrupted by
#macro	CUBE_TRIG_OC, 1
			;Activate CUBE 
#ifdef CUBE_FC_RTSCTS
			;Initialize RTS/CTS flow control (allow incoming data)
			

	


#ifdef CUBE_FC_RTSCTS
			;Initialize RTS/CTS flow control (allow incoming data)
			CUBE_ASSERT_CTS 				;signal clear to send

#endif
#ifdef CUBE_FC_XONXOFF
			;Initialize XON/XOFF flow control
			BSET	CUBE_FLGS,#CUBE_FLG_SEND_XONXOFF ;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), CUBECR2 	;enable CUBE and transmit XON
#else
			MOVB	#(RIE|TE|RE), CUBECR2 		;enable CUBE
#endif
#ifdef	CUBE_OC_ON

			;Trigger periodic interrupt
			CUBE_LDD_2FRAME_TC 			;TC -> D
			ADDD	CUBE_OCTC			;set OC intervall
			STD	CUBE_OCTC			;
			TIM_EN	CUBE_OC 				;start OC channel
#endif

			;Flag CUBE as enabled
			BSET	CUBE_FLGS,#CUBE_FLG_EN 		;Allow CUBE communication
#emac















				;#Load TCs for the length of two CUBE frames into accu D
; args:   none
; result: D: TCs roughly equivalent to 2 CUBE frames
; SSTACK: 0 bytes
;         X is preserved
; CUBE V6: TC =  20 * CUBEBD * CLOCK_BUS_FREQ/TIM_FREQ
; CUBE V5: TC = 320 * CUBEBD * CLOCK_BUS_FREQ/TIM_FREQ
#ifdef CUBE_OC_ON
#macro	CUBE_LDD_2FRAME_TC, 0
	
			;Baud rate detection
#ifdef	CUBE_V6	
			LDD	#((20*CLOCK_BUS_FREQ/TIM_FREQ) ;delay in bit length -> D
#else
			LDD	#((320*CLOCK_BUS_FREQ/TIM_FREQ);TC in bit length -> D
#endif
			LDY	CUBE_BDIV 			;baud rate divider -> Y
			EMUL					;TC -> Y:D
#else
			;Fixed baud rate
			LDD	#((20*CUBE_BAUD)/TIM_FREQ) 	;TC -> D
#endif
#emac
	











	
	
;#Enable CUBE
;#----------
#macro	CUBE_ENABLE, 0
#ifdef CUBE_FC_XONXOFF
			;Initialize XON/XOFF flow control
			MOVB	#CUBE_FLG_SEND_XONXOFF,	CUBE_FLGS;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), CUBECR2 	;enable CUBE and transmit XON
#else
			STAA	CUBE_FLGS        		;reset flags
			MOVB	#(RIE|TE|RE), CUBECR2 		;enable CUBE
#endif
#ifdef CUBE_FC_RTSCTS
			;Initialize RTS/CTS flow control (allow incoming data)
			CUBE_ASSERT_CTS
#endif
#ifdef	CUBE_IRQ_WORKAROUND_ON
			;Trigger periodic interrupt
			;CUBE_START_DELAY <-TBD
#endif
#emac

;#Functions	
;#Transmit one byte - non-blocking
; args:   none
; result: D: TCs roughly equivalent to 2 CUBE frames
; SSTACK: 0 bytes
;         X is preserved
; CUBE V6: TC =  10 * CUBEBD * CLOCK_BUS_FREQ/TIM_FREQ
; CUBE V5: TC = 160 * CUBEBD * CLOCK_BUS_FREQ/TIM_FREQ
#macro	CUBE_LDD_2FRAME_TC, 0
#ifdef CUBE_BAUD_AUTO
			

#else
#ifdef	CUBE_V6	
			LDD	#((20*CLOCK_BUS_FREQ*CUBE_BAUD)/TIM_FREQ) ;TC -> D
#else
			LDD	#((320*CLOCK_BUS_FREQ*CUBE_BAUD)/TIM_FREQ);TC -> D
#endif
#endif
	
;#Disable CUBE TBD
;#-----------
#macro	CUBE_DISABLE, 0

			;Disable transmission, disable IRQs
			CLR	CUBECR2
#ifdef	CUBE_FC_RTSCTS		
			;Clear CTS (minimize output current)
			CUBE_ASSERT_CTS
#endif	
			;Stop timer channels
			TIM_MULT_DIS	(CUBE_BD_TCS|CUBE_DLY_TCS)
#ifmac	CUBE_ERRSIG_STOP
			;Stop error signaling
			CUBE_ERRSIG_STOP
#endif	
#emac

;#Check if disabled
;#-----------------
#macro	CUBE_BR_DISABLED, 1
			;Branch if disabled
			BRCLR	CUBECR2, #(TE|RE), \1
#emac
	
;#Functions	
;#Transmit one byte - non-blocking
; args:   B:      data to be send
; result: C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and D are preserved
#macro	CUBE_TX_NB, 0
			SSTACK_JOBSR	CUBE_TX_NB, 5
#emac
	
;#Transmit one byte - blocking
; args:   B: data to be send
; SSTACK: 7 bytes
;         X, Y, and D are preserved
#ifdef	CUBE_BLOCKING_ON
#macro	CUBE_TX_BL, 0
			SSTACK_JOBSR	CUBE_TX_BL, 7
#emac
#else
#macro	CUBE_TX_BL, 0
			CUBE_CALL_BL	CUBE_TX_NB, 5
#emac
#endif
	
;#Check if a transmission is ongoing
; args:   none
; result:  C-flag: set if all transmissionsare complete
; SSTACK: 4 bytes
;         X, Y, and D are preserved
#macro	CUBE_TX_DONE_NB, 0
			SSTACK_JOBSR	CUBE_TX_DONE_NB, 4
#emac
	
;#Wait until all pending data is sent
; args:   none
; result: A: number of entries left in TX queue
; SSTACK: 6 bytes
;         X, Y, and D are preserved
#ifdef	CUBE_BLOCKING_ON
#macro	CUBE_TX_DONE_BL, 0
			SSTACK_JOBSR	CUBE_TX_DONE_BL, 6
#emac
#else
#macro	CUBE_TX_DONE_BL, 0
			CUBE_CALL_BL 	CUBE_TX_DONE_NB, 4
#emac
#endif
		
;#Check if TX queue can hold further data
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y, and D are preserved
#macro	CUBE_TX_READY_NB, 0
			SSTACK_JOBSR	CUBE_TX_READY_NB, 4
#emac

;#Wait until TX queue can hold further data
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved
#ifdef	CUBE_BLOCKING_ON
#macro	CUBE_TX_READY_BL, 0
			SSTACK_JOBSR	CUBE_TX_READY_BL, 6
#emac
#else
#macro	CUBE_TX_READY_BL, 0
			CUBE_CALL_BL	CUBE_TX_READY_NB, 4
#emac
#endif

;#Receive one byte - non-blocking
; args:   none
; result: A:      error flags
;         B:      received data
;         C-flag: set if successful
; SSTACK: 4 bytes
;         X and Y are preserved
#macro	CUBE_RX_NB, 0
			SSTACK_JOBSR	CUBE_RX_NB, 4
#emac

;#Receive one byte - blocking
; args:   none
; result: A: error flags
;         B: received data
; SSTACK: 6 bytes
;         X and Y are preserved
#ifdef	CUBE_BLOCKING_ON
#macro	CUBE_RX_BL, 0
			SSTACK_JOBSR	CUBE_RX_BL, 6
#emac
#else
#macro	CUBE_RX_BL, 0
			CUBE_CALL_BL 	CUBE_RX_NB, 4
#emac
#endif

;#Check if there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and B are preserved
#macro	CUBE_RX_READY_NB, 0
			SSTACK_JOBSR	CUBE_RX_READY_NB, 4
#emac

;#Wait until there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         X, Y and B are preserved
#ifdef	CUBE_BLOCKING_ON
#macro	CUBE_RX_READY_BL, 0
			SSTACK_JOBSR	CUBE_RX_READY_BL, 6
#emac
#else
#macro	CUBE_RX_READY_BL, 0
			CUBE_CALL_BL 	CUBE_RX_READY_NB, 4
#emac
#endif

;#Halt CUBE communication (blocking)
; args:   none
; result: none
; SSTACK: 2 bytes
;         X, Y, and D are preserved
#macro	CUBE_HALT_COM, 0
#ifndef	CUBE_FC_NONE
			SSTACK_JOBSR	CUBE_HALT_COM, 3
#endif
#emac

;#Resume CUBE communication
; args:   none
; result: none
; SSTACK: 2 or 4 bytes
;         X, Y, and D are preserved
#macro	CUBE_RESUME_COM, 0
#ifdef	CUBE_FC_RTSCTS
			SSTACK_JOBSR	CUBE_RESUME_COM, 4
#endif
#ifdef CUBE_FC_XONXOFF
			SSTACK_JOBSR	CUBE_RESUME_COM, 2
#endif
#emac
	
;#Set baud rate
; args:   D: new CUBEBD value
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved
#macro	CUBE_SET_BAUD, 0
			SSTACK_JOBSR	CUBE_SET_BAUD, 6
#emac

;# Macros for internal use

;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved
#macro	CUBE_MAKE_BL, 2
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
#macro	CUBE_CALL_BL, 2
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
	
#ifdef	CUBE_FC_RTSCTS
;#Assert CTS (Clear To Send - allow incoming data)
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	CUBE_ASSERT_CTS, 0
#ifdef	CUBE_CTS_WEAK_DRIVE
			BCLR	CUBE_CTS_PORT,#CUBE_CTS_PIN 		;clear CTS (allow RX data
			BSET	CUBE_CTS_DDR, #CUBE_CTS_PIN		;drive speed-up pulse
			BSET	CUBE_CTS_PPS, #CUBE_CTS_PIN 		;select pull-down device
			BCLR	CUBE_CTS_DDR, #CUBE_CTS_PIN		;end speed-up pulse
#else
			BCLR	CUBE_CTS_PORT, #CUBE_CTS_PIN 		;clear CTS (allow RX data)
#endif	
#emac	
#endif	

#ifdef	CUBE_FC_RTSCTS
;#Deassert CTS (stop incoming data)
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	CUBE_DEASSERT_CTS, 0
#ifdef	CUBE_CTS_WEAK_DRIVE
			BSET	CUBE_CTS_PORT, #CUBE_CTS_PIN 		;set CTS (prohibit RX data)
			BSET	CUBE_CTS_DDR, #CUBE_CTS_PIN		;drive speed-up pulse
			BCLR	CUBE_CTS_PPS, #CUBE_CTS_PIN 		;select pull-up device
			BCLR	CUBE_CTS_DDR, #CUBE_CTS_PIN		;end speed-up pulse
#else
			BSET	CUBE_CTS_PORT, #CUBE_CTS_PIN 		;set CTS (prohibit RX data)
#endif	
#emac	
#endif
	
#ifdef CUBE_FC_XONXOFF
;#Send XON/XOFF symbol
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	CUBE_SEND_XONXOFF, 0
			BSET	CUBE_FLGS, #CUBE_FLG_SEND_XONXOFF		;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), CUBECR2 		;enable TX interrupts	
#emac	
#endif	

#ifdef	CUBE_DLY_EN
;#RESET delay (approx. 2 CUBE frames)
; args:   none
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_RESET_DELAY, 0
			TIM_CLRIF   	CUBE_DLY_OC
			LDD	CUBEBDH 					;retrigger delay
			TBNE	A, MAX_DELAY				;max. delay ($FFFF) exceeded
			TFR	B, A					;determine delay
			CLRB
			TIM_SET_DLY_D	CUBE_DLY_OC			;update OC count
MAX_DELAY		EQU	*
#emac
#endif

#ifdef	CUBE_DLY_EN
;#Start delay (always retrigger) (approx. 2 CUBE frames)
; args:   none
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_INIT_DELAY, 0
			CUBE_RESET_DELAY
			TIM_EN		CUBE_DLY_OC
#emac
#endif
	
#ifdef	CUBE_DLY_EN
;#Start delay (don't retrigger) (approx. 2 CUBE frames)
; args:   none
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_START_DELAY, 0
			BRSET	TIE, #(1<<CUBE_DLY_OC), DONE 		;skip if delay has already been triggered
			CUBE_INIT_DELAY
DONE			EQU	*
#emac
#endif

#ifdef	CUBE_DLY_EN
;#Stop delay (approx. 2 CUBE frames)
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	CUBE_STOP_DELAY, 0
			TIM_DIS		CUBE_DLY_OC
			EQU	*
#emac
#endif	

#ifdef	CUBE_DLY_EN
;#Wait for one delay period (approx. 2 CUBE frames)
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	CUBE_WAIT_DELAY, 0
			SEI						;start atomic sequence
			CUBE_INIT_DELAY					;restart timer delay
			BSET	CUBE_FLGS, #CUBE_FLG_DELAY_PENDING 	;flag pending delay
LOOP			ISTACK_WAIT 					;wait for any event
			BRSET	CUBE_FLGS, #CUBE_FLG_DELAY_PENDING, LOOP  ;wait for next event
#emac
#endif	
	
#ifdef	CUBE_BD_ON
;Start baud rate detection (I-bit must be set)
; args:   none
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_START_BD, 0
			TST	CUBE_BD_LIST
			BNE	DONE 					;baud rate detection is already running
#ifdef CUBE_BD_LOG_ON
			;Clear BD log
			CUBE_BD_CLEAR_LOG
#endif
			;Enable timer
#ifdef	CUBE_BD_TIM
			TIM_MULT_EN	((1<<CUBE_BD_ICPE)|(1<<CUBE_BD_ICNE))
#endif
#ifdef	CUBE_BD_ECT
			TIM_MULT_EN	(1<<CUBE_BD_IC)
#endif
			;Make sure that the timeout bit is set
			BRSET	TFLG1, #(1<<CUBE_BD_OC), SKIP
			;SEI
			TIM_SET_DLY_IMM	CUBE_BD_OC, 6
			;CLI
SKIP			EQU	*	
			;Reset baud rate list and recover counter
			MOVB	#CUBE_BD_LIST_INIT, CUBE_BD_LIST
			;Start edge detection
			CUBE_BD_START_EDGE_DETECT
;DONE			MOVB	#CUBE_BD_RECOVCNT_INIT, CUBE_BD_RECOVCNT
DONE			EQU	*
#emac	
#endif
	
#ifdef	CUBE_BD_ON
;Stop baud rate detection
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	CUBE_STOP_BD, 0
			BRCLR	CUBE_BD_LIST, #$FF, DONE			;baud rate detection already inactive
			;Stop edge detection
			CUBE_BD_STOP_EDGE_DETECT
			;Disable timer
#ifdef	CUBE_BD_TIM
			TIM_MULT_DIS	((1<<CUBE_BD_ICPE)|(1<<CUBE_BD_ICNE)|(1<<CUBE_BD_OC))
#endif
#ifdef	CUBE_BD_ECT
			TIM_MULT_DIS	((1<<CUBE_BD_IC)|(1<<CUBE_BD_OC))
#endif
;									;See  CUBE_ISR_RX_2
			CLR	CUBE_BD_LIST 				;clear check list
DONE			EQU	*
#emac
#endif

#ifdef	CUBE_BD_ON
;Start edge detection
; args:   none
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_BD_START_EDGE_DETECT, 0
			;BSET	TCTL3, #(CUBE_BD_TCTL3_VAL>>8)		;start edge detection
			BSET	TCTL4, #(CUBE_BD_TCTL3_VAL&$00FF)
#emac
#endif

#ifdef	CUBE_BD_ON
;Stop edge detection
; args:   none
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_BD_STOP_EDGE_DETECT, 0
			;BCLR	TCTL3, #(CUBE_BD_TCTL3_VAL>>8)		;stop edge detection
			BCLR	TCTL4, #(CUBE_BD_TCTL3_VAL&$00FF)
#emac
#endif

#ifdef	CUBE_BD_ON
#ifdef	CUBE_BD_LOG_ON
;Clear BD pulse log
; args:   none
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_BD_CLEAR_LOG, 0
			TFR	Y,D
			LDY	#CUBE_BD_LOG_BUF
			STY	CUBE_BD_LOG_IDX
LOOP			MOVW	#$0000, 2,Y+
			CPY	#CUBE_BD_LOG_BUF_END
			BLO	LOOP
			TFR	D,Y
#emac
#endif
#endif

#ifdef	CUBE_BD_ON
#ifdef	CUBE_BD_LOG_ON
;Log BD pulse length
; args: X: pulse length
;       Y: search tree pointer
; SSTACK: none
;         X, and Y are preserved
#macro	CUBE_BD_LOG, 0
		TFR	Y,D
		LDY	CUBE_BD_LOG_IDX
		CPY	#CUBE_BD_LOG_BUF_END
		BHS	DONE
		STD	2,Y+
		STX	2,Y+
		STY	CUBE_BD_LOG_IDX
DONE		TFR	D,Y
#emac
#endif
#endif
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef CUBE_CODE_START_LIN
			ORG 	CUBE_CODE_START, CUBE_CODE_START_LIN
#else
			ORG 	CUBE_CODE_START
#endif

;#Enable CUBE
; args:   none
; result: none
; SSTACK: 2 bytes
;         X and Y are preserved
CUBE_ENABLE		EQU	*
#ifdef CUBE_FC_XONXOFF
			;Initialize XON/XOFF flow control
			BSET	CUBE_FLGS,#CUBE_FLG_SEND_XONXOFF ;request transmission of XON/XOFF
			MOVB	#(TXIE|RIE|TE|RE), CUBECR2 	;enable CUBE and transmit XON
#else
			MOVB	#(RIE|TE|RE), CUBECR2 		;enable CUBE
#endif
#ifdef CUBE_FC_RTSCTS
			;Initialize RTS/CTS flow control (allow incoming data)
			CUBE_ASSERT_CTS 				;signal clear to send
#endif
#ifdef	CUBE_IRQ_WORKAROUND_ON
			;Trigger periodic interrupt
				;CUBE_START_DELAY <-TBD
#endif
			;Flag CUBE as enabled
			BSET	CUBE_FLGS,#CUBE_FLG_SHUTDOWN
			;Done
			SSTACK_PREPULL	2 			;check SSTACK
			RTS					;done

;#Disable CUBE - non-blocking
; args:   none
; result: C-flag: set if successful
; SSTACK: 2 bytes
;         X and Y are preserved
CUBE_DISABLE_NB		EQU	*
			;Flag CUBE as disabled
			BSET	CUBE_FLGS,#CUBE_FLG_SHUTDOWN


	

	
;#Transmit one byte - non-blocking
; args:   B: data to be send
; result: C-flag: set if successful
; SSTACK: 5 bytes
;         X, Y, and D are preserved
CUBE_TX_NB		EQU	*
			;Check if CUBE transmitter is enabled
			BRCLR	CUBECR2, #TE, CUBE_TX_NB_1 		;do nothing and flag success
			;Save registers (data in B)
			PSHY
			PSHA
			;Write data into the TX buffer (data in B)
			LDY	#CUBE_TXBUF
			LDAA	CUBE_TXBUF_IN
			STAB	A,Y
			;Check if there is room for this entry (data in B, in-index in A, TX buffer pointer in Y)
			INCA						;increment index
			ANDA	#CUBE_TXBUF_MASK
			CMPA	CUBE_TXBUF_OUT
			BEQ	CUBE_TX_NB_2 				;buffer is full
			;Update buffer
			STAA	CUBE_TXBUF_IN
			;Enable interrupts
			MOVB	#(TXIE|RIE|TE|RE), CUBECR2				;enable TX interrupt
			;Restore registers
			SSTACK_PREPULL	5
			PULA
			PULY
			;Signal success
CUBE_TX_NB_1		SEC
			;Done
			RTS
			;Buffer is full
			;Restore registers
CUBE_TX_NB_2		SSTACK_PREPULL	5
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
#ifdef	CUBE_BLOCKING_ON
CUBE_TX_BL		EQU	*
			CUBE_MAKE_BL	CUBE_TX_NB, 5
#endif
	
;#Check if a transmission is ongoing
; args:   none
; result:  C-flag: set if all transmissions are complete
; SSTACK: 4 bytes
;         X, Y, and D are preserved
CUBE_TX_DONE_NB		EQU	*
			;Check if CUBE transmitter is enabled
			BRCLR	CUBECR2, #TE, CUBE_TX_DONE_NB_3 		;do nothing and flag success
			;Save registers
			PSHD
			;Check TX queue
			LDD	CUBE_TXBUF_IN
			CBA
			BNE	CUBE_TX_DONE_NB_1 ;transmissions queued
			;Check CUBE status
			BRSET	CUBESR1, #(TDRE|TC), CUBE_TX_DONE_NB_2 	;all transmissions complete
			;Transmissions ongoing
			;Restore registers	
CUBE_TX_DONE_NB_1	SSTACK_PREPULL	4
			PULD
			;Signal failure
			CLC
			;Done
			RTS
			;All transmissions complete
			;Restore registers	
CUBE_TX_DONE_NB_2	SSTACK_PREPULL	4
			PULD
			;Signal success
CUBE_TX_DONE_NB_3	SEC
			;Done
			RTS
		
;#Wait until all pending data is sent
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved
#ifdef	CUBE_BLOCKING_ON
CUBE_TX_DONE_BL		EQU	*
			CUBE_MAKE_BL	CUBE_TX_DONE_NB, 4	
#endif

;#Check if TX queue can hold further data
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y, and D are preserved
CUBE_TX_READY_NB		EQU	*
			;Check if CUBE transmitter is enabled
			BRCLR	CUBECR2, #TE, CUBE_TX_READY_NB_1 		;do nothing and flag success
			;Save registers
			PSHD
			;Check if there is room for this entry
			LDD	CUBE_TXBUF_IN 		;in-index in A, out-index in B
			INCA
			ANDA	#CUBE_TXBUF_MASK
			CMPA	CUBE_TXBUF_OUT
			BEQ	CUBE_TX_READY_NB_2 				;buffer is full			
			;Restore registers
			SSTACK_PREPULL	4
			PULD
			;Done
CUBE_TX_READY_NB_1	SEC
			RTS
			;TX buffer is full
CUBE_TX_READY_NB_2	SSTACK_PREPULL	4
			PULD
			;Done
			CLC
			RTS

;#Wait until TX queue can hold further data
; args:   none
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved
#ifdef	CUBE_BLOCKING_ON
CUBE_TX_READY_BL		EQU	*
			CUBE_MAKE_BL	CUBE_TX_READY_NB, 4	
#endif

;#Receive one byte - non-blocking ;OK!
; args:   none
; result: A:      error flags
;         B:      received data
;	  C-flag: set if successful
; SSTACK: 4 bytes
;         X and Y are preserved
CUBE_RX_NB		EQU	*
			;Check if CUBE receiver is enabled
			BRCLR	CUBECR2, #TE, CUBE_RX_NB_3 		;do nothing and flag failure
			;Save registers
			PSHX
			;Check if there is data in the RX queue
			LDD	CUBE_RXBUF_IN 				;A:B=in:out
			SBA		   				;A=in-out
			BEQ	CUBE_RX_NB_2 				;RX buffer is empty
#ifdef	CUBE_FC_ON
			;Check if more RX data is allowed  (in-out in A)
			ANDA	#CUBE_RXBUF_MASK
			CMPA	#CUBE_RX_EMPTY_LEVEL
			BEQ	CUBE_RX_NB_4 				;allow RX data
#endif	
			;Pull entry from the RX queue (out in B)
CUBE_RX_NB_1		LDX	#CUBE_RXBUF
			LDX	B,X
			ADDB	#$02					;increment out pointer
			ANDB	#CUBE_RXBUF_MASK
			STAB	CUBE_RXBUF_OUT
			;MOVB	#(TXIE|RIE|TE|RE), CUBECR2		;trigger RXTX ISR
			TFR	X, D
			;Restore registers
			SSTACK_PREPULL	4
			PULX
			;Done
			SEC
			RTS
			;RX buffer is empty (CCR in X)
CUBE_RX_NB_2		SSTACK_PREPULL	4
			PULX
			;Done
CUBE_RX_NB_3		CLC
			RTS
#ifdef	CUBE_FC_RTSCTS
			;Assert CTS (out-index in B, CCR in X)
CUBE_RX_NB_4		CUBE_ASSERT_CTS
			JOB	CUBE_RX_NB_1	
#endif	
#ifdef	CUBE_FC_XONXOFF
			;Transmit XON/XOFF (out-index in B, CCR in X)
CUBE_RX_NB_4		CUBE_SEND_XONXOFF
			JOB	CUBE_RX_NB_1	
#endif	
	
;#Receive one byte - blocking
; args:   none
; result: A:      error flags
;         B:      received data
;	  C-flag: set if successful
; SSTACK: 6 bytes
;         X and Y are preserved
#ifdef	CUBE_BLOCKING_ON
CUBE_RX_BL		EQU	*
			CUBE_MAKE_BL	CUBE_RX_NB, 4
#endif

;#Check if there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and D are preserved
CUBE_RX_READY_NB		EQU	*
			;Check if CUBE receiver is enabled
			BRCLR	CUBECR2, #TE, CUBE_RX_READY_NB_2 		;do nothing and flag failure
			;Save registers
			PSHD
			;Check if there is data in the RX queue
			LDD	CUBE_RXBUF_IN 		;A:B=in:out
			CBA
			BEQ	CUBE_RX_READY_NB_1
			;RX buffer holds data
			SSTACK_PREPULL	4
			PULD
			;Done
			SEC
			RTS
			;RX buffer is empty
CUBE_RX_READY_NB_1	SSTACK_PREPULL	4
			PULD
			;Done
CUBE_RX_READY_NB_2	CLC
			RTS

;#Wait until there is data in the RX queue
; args:   none
; result: C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y and D are preserved
#ifdef	CUBE_BLOCKING_ON
CUBE_RX_READY_BL		EQU	*
			CUBE_MAKE_BL	CUBE_RX_READY_BL, 4
#endif
	
;#Set baud rate
; args:   D: new CUBEBD value
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved
CUBE_SET_BAUD		EQU	*
			;Save registers (new CUBEBD value in D)
			PSHY 					;push Y onto the SSTACK
			PSHD					;push D onto the SSTACK
			;Set baud rate (new CUBEBD value in D)
			STD	CUBEBDH				;set baud rate
			LDY	#CUBE_BMUL			;save baud rate for next warmstart
			EMUL					;D*Y -> Y:D
			STD	CUBE_BVAL
			;Clear input buffer
			MOVW	#$0000, CUBE_RXBUF_IN		;reset in and out pointer of the RX buffer
			;Restore registers
			SSTACK_PREPULL	6
			PULD					;pull D from the SSTACK
			PULY					;pull Y from the SSTACK
			;Done
			RTS
	
#ifndef	CUBE_FC_NONE
;#Halt CUBE communication
; args:   none
; result: none
; SSTACK: 2 bytes
;         X, Y, and D are preserved
CUBE_HALT_COM		EQU	*
#ifdef	CUBE_FC_RTSCTS
			;Force flow control
			BSET	CUBE_FLGS, #CUBE_FLG_RX_BLOCKED 	;update flag
			;Deassert CTS (stop incoming data)
			CUBE_DEASSERT_CTS 			;clear CTS
#endif
#ifdef CUBE_FC_XONXOFF
			;Force flow control
			BSET	CUBE_FLGS, #(CUBE_FLG_RX_BLOCKED|CUBE_FLG_SEND_XONXOFF)
			MOVB	#(TXIE|RIE|TE|RE), CUBECR2 	;enable TX interrupts	
			;Wait for remaining incoming data (approx. 2 CUBE frames)
			CUBE_WAIT_DELAY				;~2 CUBE frames
#endif
			;Wait for remaining incoming data (approx. 4 CUBE frames)
			CUBE_WAIT_DELAY				;~2 CUBE frames
			CUBE_WAIT_DELAY				;~2 CUBE frames
			;Done
			SSTACK_PREPULL	6
			RTS
#endif

#ifndef	CUBE_FC_NONE
;#Resume CUBE communication
; args:   none
; result: none
; SSTACK: 2 or 4 bytes
;         X, Y, and D are preserved
CUBE_RESUME_COM		EQU	*	
#ifdef	CUBE_FC_RTSCTS
			;Save registers
			PSHD					;push D onto the SSTACK
			;Release flow control
			BCLR	CUBE_FLGS, #CUBE_FLG_RX_BLOCKED 	;update flag
			;Update CTS
			LDD	CUBE_RXBUF_IN 			;A:B=in:out
			SBA		   			;A=in-out
			ANDA	#CUBE_RXBUF_MASK			;wrap A	
			CMPA	#CUBE_RX_EMPTY_LEVEL		;Check CTS assert level
			BHI	CUBE_RESUME_COM_1		;keep CTS deasserted
			;Assert CTS (allow incoming data)
			CUBE_ASSERT_CTS 				;set CTS
			;Restore registers
CUBE_RESUME_COM_1	SSTACK_PREPULL	4
			PULD					;pull D from the SSTACK
#endif
#ifdef CUBE_FC_XONXOFF
			;Release flow control
			BCLR	CUBE_FLGS, #CUBE_FLG_RX_BLOCKED 	;update flag
			CUBE_SEND_XONXOFF			;update flow control
#endif
			;Done
			RTS
#endif

;ISRs
;----
#ifdef CUBE_BAUD_AUTO
;#TIM IC ISR
;  Baud rate detection: (sole purpose)	
;    CUBE_BD_PULSE must be set to $FFFF before enabling baud rate detection ->enabling CUBE_IC.	
;    CUBE_IC serves as indicator that baud rate detection is active.	
;    CUBE_OC will be enabled after the first edge has been captured.	
;    CUBE_OC serves as indicator that pulse wiidth may be calculated.
;    A CUBE_OC event ends baud rate detection 	
CUBE_ISR_IC		EQU	*
			;Capture timestamp
			LDD	CUBE_ICTC 			;current TC -> D
			TIM_CLRIF CUBE_IC			;clear interrupt flag
			;Calculate pulse length (current TC in D)
			TFR	D, X 				;save current TC
			SUBD	CUBE_BD_LAST_TC			;pulse width -> D
			STX	CUBE_BD_LAST_TC			;update previous TC
			;Check whether pulse width is valid ->CUBE_OC enabled (pulse width in D, current TC in X)
			TIM_BRDIS CUBE_OC CUBE_ISR_IC_1		;first sample
			CPD	#CUBE_BD_MIN_PULSE		;filter short pulses
			BLO	CUBE_ISR_IC_1			;pulse too short
			;CPD	#CUBE_BD_MAX_PULSE		;filter long pulses (to be checked at OC enent)
			;BHI	CUBE_ISR_IC_1			;pulse too long	
			EMINM	CUBE_BD_PULSE			;keep shortest 
			;Retrigger CUBE_OC (current TC in X)
CUBE_ISR_IC_1		STX	CUBE_OCTC 			;set maximum time period
			TIM_EN	CUBE_OC				;enable CUBE_OC			
			;Done
			ISTACK_RTI
#endif

;#TIM OC ISR 
;  Baud rate detection:	
;    	
;  Pause:  	
;    	
;    	
;    	
;    	
;    CUBE_IC indicates that baud rate detection is active	
;    CUBE_IC indicates that baud rate detection is active	
;    CUBE_IC indicates that baud rate detection is active	
CUBE_ISR_OC		EQU	*	
#ifdef CUBE_BAUD_AUTO
			;Baud rate detection
			;------------------- 
			;Check if baud rate detection is enabled
			TIM_BRDIS	CUBE_IC, CUBE_ISR_OC_	;baud rate not active
			;Check captured pulse width
			LDD	CUBE_BD_PULSE 			;pulse width -> D
			CPD	#CUBE_BD_MAX_PULSE		;check if pulse is too long
			BLS	CUBE_ISR_OC_1			;pulse is short enough	
			;Continue baud rate detection 
			TIM_DIS	CUBE_OC 				;discard ongoing pulse
			ISTACK_RTI
			;Calculate baud rate divider (pulse width in D)
CUBE_ISR_OC_1		EQU	*
#ifdef	CUBE_V6
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
			;Set and store baud rate divider (baud rate divider in D)
			STD	CUBEBD 				;set aud rate divider
			STD	CUBE_SAVED_BDIV 			;save baud rate divider
			ABA					;calculate checksum 
			COMA					;store checksum
			STAA	CUBE_SAVED_BDIV_CS
			;End baud rate detection
			TIM_DIS	CUBE_IC 				;stop baud rate detection
#ifmac	CUBE_BDSIG_STOP
			CUBE_BDSIG_STOP 				;stop BD signal	
#endif
			;Enable CUBE
			CUBE_ENABLE 				;enable CUBE
			ISTACK_RTI				;done
#endif
			;Shutdown
			;-------- 
CUBE_ISR_OC_		BRCLR	CUBE_FLGS,#CUBE_FLG_SHUTDOWN,CUBE_ISR_OC_ ;no shutdown ongoing
			LDD	CUBE_OC_CNT 			;OC counter -> D
			BEQ	CUBE_ISR_OC_			;saturate at zero
			SUBD	#1				;decrement
			STD	CUBE_OC_CNT			;update OC counter
			BNE	CUBE_ISR_OC_			;saturate at zero
CUBE_ISR_OC_		CUBE_DISABLE				;disable CUBE
			ISTACK_RTI				;done
	
			;Flow control
			;------------ 
#ifdef CUBE_FC_XONXOFF
			



CUBE_ISR_OC_



			;MUCts00510 workaround
			;--------------------- 
CUBE_ISR_OC_


#ifndef	CUBE_IRQBUG_ON
#ifndef	CUBE_IRQBUG_OFF







	
	#else
#ifdef	TIM_DIV_2
			LSRD					;CUBEBDIV = pulse width/8
			LSRD
			LSRD
#endif
#ifdef	TIM_DIV_4
			LSRD					;CUBEBDIV = pulse width/4
			LSRD
#endif
#ifdef	TIM_DIV_8
			LSLD					;CUBEBDIV = pulse width/2
#endif



#endif



	


	#ifndef TIM_DIV_4
			LSLD


	
	
			;Check if baud rate detection is enabled
			TIM_BRDIS	CUBE_IC, CUBE_ISR_OC_	;baud rate detection disabled
			;Determine baud rate settings
			LDD	CUBE_SHORTEST_PULSE		;shortest pulse -> D
#ifndef TIM_DIV_16
			LSRD					;determine CUBEBD value
#ifndef TIM_DIV_8
			LSRD					;
#ifndef TIM_DIV_4
			LSRD					;
#ifndef TIM_DIV_2
			LSRD					;
#endif
#endif
#endif
#endif
			BEQ	CUBE_ISR_OC_			;redundant sanity check
			BITA	$E0				;check if baud rate divider is too high
			BNE	CUBE_ISR_OC_			;baud rate divider is too high
			;Baud rate determined (CUBEBD value in D)
			

	
			STD	CUBEBDH 				;set new baud rate
			CUBE_ENABLE				;enable CUBE
			CUBE_BD_DISABLE				;disable baud rate
	
	
	
;#Transmit ISR (status flags in A)
;---------------------------------
CUBE_ISR_TX		BITA	#TDRE					;check if CUBE is ready for new TX data
			BEQ	<CUBE_ISR_TX_4				;done for now
#ifdef	CUBE_FC_XONXOFF
			;Check if XON/XOFF transmission is required
			BRSET	CUBE_FLGS, #CUBE_FLG_TX_ESC, CUBE_ISR_TX_1 ;Don't escape any XON/XOFF symbols
			;Transmit XON/XOFF symbols
			BRCLR	CUBE_FLGS, #CUBE_FLG_SEND_XONXOFF, CUBE_ISR_TX_1 ;XON/XOFF not requested
			;Clear XON/XOFF request
			BCLR	CUBE_FLGS, #CUBE_FLG_SEND_XONXOFF
			;Check for forced XOFF
			BRSET	CUBE_FLGS, #CUBE_FLG_RX_BLOCKED, CUBE_ISR_TX_6 ;transmit XOFF
			;Check RX queue
			LDD	CUBE_RXBUF_IN
			SBA			
			ANDA	#CUBE_RXBUF_MASK
			;Check XOFF theshold
			CMPA	#CUBE_RX_FULL_LEVEL
			BHS	<CUBE_ISR_TX_6	 			;transmit XOFF
			;Check XON theshold
			CMPA	#CUBE_RX_EMPTY_LEVEL
			BLS	<CUBE_ISR_TX_5	 			;transmit XON
			;Check XOFF status
			BRSET	CUBE_FLGS, #CUBE_FLG_TX_BLOCKED, CUBE_ISR_TX_3 ;stop transmitting
#endif
#ifdef	CUBE_FC_RTSCTS
			;Check RTS status
			BRCLR	CUBE_RTS_PORT, #CUBE_RTS_PIN, CUBE_ISR_TX_1;check TX buffer
        		BSET	CUBE_FLGS, #CUBE_FLG_POLL_RTS		;request RTS polling	
			CUBE_START_DELAY					;start delay
			JOB	CUBE_ISR_TX_3				;stop transmitting
#endif
			;Check TX buffer
CUBE_ISR_TX_1		LDD	CUBE_TXBUF_IN
			CBA
			BEQ	<CUBE_ISR_TX_3 				;stop transmitting
			;Transmit data (in-index in A, out-index in B)
			LDY	#CUBE_TXBUF
#ifdef	CUBE_FC_XONXOFF
			;Check for DLE (in-index in A, out-index in B, buffer pointer in Y)
			BCLR	CUBE_FLGS, #CUBE_FLG_TX_ESC
			TFR	D, X
			LDAB	B,Y
			CMPB	#CUBE_DLE
			BNE	CUBE_ISR_TX_2
			BSET	CUBE_FLGS, #CUBE_FLG_TX_ESC
CUBE_ISR_TX_2		STAB	CUBEDRL	
			TFR	X, D
#else	
			MOVB	B,Y ,CUBEDRL
#endif
			;Increment index (in-index in A, out-index in B, buffer pointer in Y)
			INCB
			ANDB	#CUBE_TXBUF_MASK
			STAB	CUBE_TXBUF_OUT
			CBA
			BNE	<CUBE_ISR_TX_4 				;done	
			;Stop transmitting
CUBE_ISR_TX_3		EQU	*
#ifdef CUBE_FC_XONXOFF
			BRSET	CUBE_FLGS, #CUBE_FLG_SEND_XONXOFF, CUBE_ISR_TX_4 ;consider pending XON/XOFF symbols
#endif	
			MOVB	#(RIE|TE|RE), CUBECR2 			;disable TX interrupts	
			;Done
CUBE_ISR_TX_4		ISTACK_RTI
#ifdef CUBE_FC_XONXOFF
			;Transmit XON
CUBE_ISR_TX_5		MOVB	#CUBE_XON, CUBEDRL
			JOB	CUBE_ISR_TX_7				;schedule reminder	
			;Transmit XOFF
CUBE_ISR_TX_6		MOVB	#CUBE_XOFF, CUBEDRL
			;Schedule reminder
CUBE_ISR_TX_7		MOVW	#CUBE_XONXOFF_REMINDER, CUBE_XONXOFF_REMCNT
			CUBE_START_DELAY					;start delay
			JOB	CUBE_ISR_TX_4 				;done	
#endif	

;#Receive/Transmit ISR (Common ISR entry point for the CUBE)
;----------------------------------------------------------
CUBE_ISR_RXTX		EQU	*
			;Common entry point for all CUBE interrupts
			;Load flags
			LDAA	CUBESR1					;load status flags into accu A
									;CUBE Flag order:				
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
			BEQ	CUBE_ISR_TX				; is full or if an overrun has occured
			
;#Receive ISR (status flags in A)
;--------------------------------
CUBE_ISR_RX		LDAB	CUBEDRL					;load receive data into accu B (clears flags)
			ANDA	#(OR|NF|FE|PF)				;only maintain relevant error flags
#ifdef	CUBE_DETECT_C0
			;Check character is escaped (status flags in A, RX data in B)
			BRSET	CUBE_FLGS, #CUBE_FLG_RX_ESC, CUBE_ISR_RX_5 ;charakter is escaped (skip detection)			
#endif	
			;Transfer SWOR flag to current error flags (status flags in A, RX data in B)
			BRCLR	CUBE_FLGS, #CUBE_FLG_SWOR, CUBE_ISR_RX_1	;SWOR bit not set
			ORAA	#CUBE_FLG_SWOR				;set SWOR bit in accu A
			BCLR	CUBE_FLGS, #CUBE_FLG_SWOR 		;clear SWOR bit in variable	
#ifdef	CUBE_DETECT_C0
			;Check for control characters (status flags in A, RX data in B)
			BITA	#(CUBE_FLG_SWOR|OR|NF|FE|PF) 		;don't handle control characters with errors
			BNE	<CUBE_ISR_RX_1 				;queue data
#ifmac	CUBE_SUSPEND_ACTION
			CMPB	#CUBE_SUSPEND
#else
#ifdef	CUBE_FC_XONXOFF
			CMPB	#CUBE_XOFF
#else
			CMPB	#CUBE_DLE
#endif
#endif
			BLE	CUBE_ISR_RX_8				;determine control signal
#endif	

			;Place data into RX queue (status flags in A, RX data in B)
CUBE_ISR_RX_1		TFR	D, Y					;flags:data -> Y
			LDX	#CUBE_RXBUF   				;buffer pointer -> X
			LDD	CUBE_RXBUF_IN				;in:out -> A:B
			STY	A,X
			ADDA	#2
			ANDA	#CUBE_RXBUF_MASK		
			CBA
                	BEQ	<CUBE_ISR_RX_9				;buffer overflow
			STAA	CUBE_RXBUF_IN				;update IN pointer
#ifdef	CUBE_FC_ON
			;Check if flow control must be applied (in:out in D, flags:data in Y)
			SBA
			ANDA	#CUBE_RXBUF_MASK
			CMPA	#CUBE_RX_FULL_LEVEL
			BHS	<CUBE_ISR_RX_10 				;buffer is getting full			
#endif
CUBE_ISR_RX_2		EQU	*
#ifdef	CUBE_CHECK_RX_ERR
			;Check for RX errors (flags:data in Y)
			BITA	#(NF|FE|PF) 				;check for noise, frame errors, parity errors
			BNE	<CUBE_ISR_RX_12 				;RX error detected
CUBE_ISR_RX_3		EQU	*
#ifdef	CUBE_BD_ON
			CUBE_STOP_BD 					;stop baud rate detection
#endif
#ifmac	CUBE_ERRSIG_STOP
			CUBE_ERRSIG_STOP 				;stop signaling RX error
#endif
#endif
#ifdef	CUBE_IRQ_WORKAROUND_ON
			;Continue with TX
CUBE_ISR_RX_4		JOB	CUBE_ISR_RXTX
#else
			;Done
CUBE_ISR_RX_4		ISTACK_RTI
#endif

#ifdef	CUBE_DETECT_C0
			;Queue escape character (status flags in A, RX data in B)	
CUBE_ISR_RX_5		TFR	D, Y
			LDX	#CUBE_RXBUF
			LDD	CUBE_RXBUF_IN				;in:out -> A:B
			BRCLR	CUBE_FLGS, #CUBE_FLG_SWOR, CUBE_ISR_RX_6   ;no SWOR occured
			MOVW	#((CUBE_FLG_SWOR<<8)|CUBE_DLE), A,X 	;queue DLE with SWOR flag
			JOB	CUBE_ISR_RX_7
CUBE_ISR_RX_6		MOVW	#CUBE_DLE, A,X 				;queue DLE without SWOR flag
CUBE_ISR_RX_7		BCLR	CUBE_FLGS, #(CUBE_FLG_SWOR|CUBE_FLG_RX_ESC) ;clear SWOR and RX_ESC flags	
			ADDA	#2
			ANDA	#CUBE_RXBUF_MASK		
			CBA
                	BEQ	<CUBE_ISR_RX_9				;buffer overflow
			STAA	CUBE_RXBUF_IN				;update IN pointer
			TFR	Y, D
			JOB	CUBE_ISR_RX_1 				;queue data
			;Determine control signal (status flags in A, RX data in B)
CUBE_ISR_RX_8		EQU	*
#ifmac	CUBE_SUSPEND_ACTION
			;Check for SUSPEND (status flags in A, RX data in B)
			CMPB	#CUBE_SUSPEND
			BEQ	<CUBE_ISR_RX_14				;SUSPEND received
#endif
#ifdef	CUBE_FC_XONXOFF
			;Check for XON/XOFF (status flags in A, RX data in B)
			CMPB	#CUBE_XOFF
			BEQ	<CUBE_ISR_RX_15				;XOFF received
			CMPB	#CUBE_XON
			BEQ	<CUBE_ISR_RX_16				;XON received
#endif
			;Check for DLE (status flags in A, RX data in B)
			CMPB	#CUBE_DLE
			BEQ	<CUBE_ISR_RX_17				;DLE received
#ifmac	CUBE_BREAK_ACTION
			;Check for BREAK (status flags in A, RX data in B)
			CMPB	#CUBE_BREAK
			BEQ	<CUBE_ISR_RX_18				;BREAK received
#endif
			JOB	CUBE_ISR_RX_1 				;queue data
#endif
			;Buffer overflow (flags:data in Y)
CUBE_ISR_RX_9		BSET	CUBE_FLGS, #CUBE_FLG_SWOR 		;set overflow flag
#ifdef	CUBE_FC_ON
			;Signal buffer full (flags:data in Y)
#ifdef	CUBE_FC_RTSCTS
			;Deassert CTS (stop incomming data) (flags:data in Y)
CUBE_ISR_RX_10		CUBE_DEASSERT_CTS
#endif	
#ifdef	CUBE_FC_XONXOFF
			;Transmit XON/XOFF (flags:data in Y)
CUBE_ISR_RX_10		CUBE_SEND_XONXOFF
#endif
#else
CUBE_ISR_RX_10		EQU	*	
#endif	
CUBE_ISR_RX_11		EQU	*	
#ifdef	CUBE_CHECK_RX_ERR
			BITA	#(NF|FE|PF) 				;check for noise, frame errors, parity errors
			BEQ	<CUBE_ISR_RX_3 				;stop error signaling			
			;RX error detected
CUBE_ISR_RX_12		EQU	*
#ifdef	CUBE_BD_ON
			;Launch baud rate detection
			CUBE_START_BD 					;start baud rate detection
#endif	
#ifmac	CUBE_ERRSIG_START
			;Signal error
			CUBE_ERRSIG_START 				;signal RX error
#endif
#endif
CUBE_ISR_RX_13		JOB	CUBE_ISR_RX_4 				;done			
#ifmac	CUBE_SUSPEND_ACTION
			;Handle SUSPEND
CUBE_ISR_RX_14		CUBE_SUSPEND_ACTION
			JOB	CUBE_ISR_RX_13 				;done
#endif
#ifdef	CUBE_FC_XONXOFF
			;Handle XOFF
CUBE_ISR_RX_15		BSET	CUBE_FLGS, #CUBE_FLG_TX_BLOCKED		;stop transmitting
			JOB	CUBE_ISR_RX_13 				;done
			;Handle XON
CUBE_ISR_RX_16		BSET	CUBE_FLGS, #CUBE_FLG_TX_BLOCKED		;allow transmissions
			MOVB	#(TXIE|RIE|TE|RE), CUBECR2		;enable TX interrupt
			JOB	CUBE_ISR_RX_13 				;done
#endif
			;Handle DLE
CUBE_ISR_RX_17		BSET	CUBE_FLGS, #CUBE_FLG_RX_ESC 		;remember start of escape sequence
			LDD	CUBE_RXBUF_IN				;in:out -> A:B
			ANDA	#CUBE_RXBUF_MASK
			CMPA	#(CUBE_RX_FULL_LEVEL-2)
			BHS	<CUBE_ISR_RX_10 				;buffer is getting full			
			JOB	CUBE_ISR_RX_11				;check for RX errors

#ifmac	CUBE_BREAK_ACTION
			;Handle BREAK
CUBE_ISR_RX_18		CUBE_BREAK_ACTION
			JOB	CUBE_ISR_RX_13 				;done
#endif
	
CUBE_CODE_END		EQU	*
CUBE_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef CUBE_TABS_START_LIN
			ORG 	CUBE_TABS_START, CUBE_TABS_START_LIN
#else
			ORG 	CUBE_TABS_START
#endif	

CUBE_TABS_END		EQU	*
CUBE_TABS_END_LIN	EQU	@
#endif
