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
;#    This modules    provides two functions to the main program:              #
;#    SCI_TX_NB     - This function sends a byte over the serial interface. In #
;#                    case of a transmit buffer overflow, it will return       #
;#                    immediately with an error status.                        #
;#    SCI_TX_BL     - This function sends a byte over the serial interface. It #
;#                    will block the program flow until the data can be handed #
;#                    over to the transmit queue.                              #
;#    SCI_TX_PEEK   - This function returns the number of bytes left in the    #
;#                    transmit queue.                                          #
;#    SCI_RX_NB     - This function reads a byte (and associated error flags)  #
;#                    It will return an error status if no read data is        #
;#                    available.                                               #
;#    SCI_RX_BL     - This function reads a byte (and associated error flags)  #
;#                    from the serial interface. It will block the             #
;#                    program flow until data is available.                    #
;#    SCI_RX_PEEK   - This function reads the oldest buffer entry and the      #
;#                    number receive buffer entries, without modifying the     #
;#                    buffer.                                                  #
;#    SCI_RX_DROP   - This function removes the oldest buffer entry.           #
;#    SCI_RX_HOLD   - This function stops the incomming data stream.           #
;#    SCI_RX_RESUME - This function enables the incomming data stream.         #
;#    SCI_RXTX_BUSY - This function checks for queued and onging.              #
;#                    transmissions.                                           #
;#    SCI_RXTX_WAIT - This function blocks the program flow until all queued.  #
;#                    ongoing transmissions are complete.                      #
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
;#      - changed selection of detectable baud rates                           #
;#      - stop baud rate detection when receiving a corret character           #
;#      - stop baud rate detection when manually setting the baud rate         #
;#    January 2, 2012                                                          #
;#      - Mini-BDM-Pod uses XN/XOFF flow control instead of RTS/CTS            #
;#                                                                             #
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
#ifndef	SCI_RTS_CTS
#ifndef	SCI_XON_XOFF
SCI_RTS_CTS		EQU	1 		;default is SCI_RTS_CTS
#endif
#endif

;XON/XOFF timer channel
#ifdef	SCI_XON_XOFF	
#ifndef	SCI_TIM_OCTO
SCI_TIM_OCFC		EQU	$08		;default is OC3			
SCI_TIM_TCFC		EQU	$TC3		;default is TC3
#endif
#endif
	
;RTS/CTS pins
#ifdef	SCI_RTS_CTS
#ifndef	SCI_RTS_PORT
SCI_RTS_PORT		EQU	PTM 		;default is PTM
SCI_RTS_PIN		EQU	PM0		;default is PM0
#endif
#ifndef	SCI_CTS_PORT
SCI_CTS_PORT		EQU	PTM 		;default is PTM
SCI_CTS_PIN		EQU	PM1		;default is PM1
#endif
#endif
	
;C0 character handling
;--------------------- 
;Detect BREAK character
#ifdef	SCI_HANDLE_BREAK
#ifdef	SCI_IGNORE_BREAK
SCI_IGNORE_BREAK	EQU	1 		;default is to ignore break chars
#endif
#endif
	
;Detect SUSPEND character
#ifdef	SCI_HANDLE_SUSPEND
#ifdef	SCI_IGNORE_SUSPEND
SCI_IGNORE_SUSPEND	EQU	1 		;default is to ignore suspend chars
#endif
#endif

;Interrupt workaround for MC9S12DP256 devices
;-------------------------------------------- 
;Enable interrupt workaround
#ifndef	SCI_IRQWA_ON
#ifndef	SCI_IRQWA_OFF
SCI_IRQWA_OFF		EQU	1 		;default is no workaround
#endif
#endif

#ifdef	SCI_IRQWA_ON
#ifndef	SCI_IRQWA_OC
SCI_IRQWA_OC		EQU	$10		;default is IC4			
SCI_IRQWA_TC		EQU	$TC4		;default is TC4
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
#ifdef	SCI_BD_ON
#ifndef	SCI_BD_TIM
#ifndef	SCI_BD_ECT
SCI_BD_TIM		EQU	1 		;default is TIM
#endif
#endif
#endif

;Input capture channels 
#ifdef	SCI_BD_TIM
#ifdef	SCI_BD_TIM_ICPE
SCI_BD_TIM_ICPE		EQU	$01		;default is IC0			
SCI_BD_TIM_TCPE		EQU	$TC0		;default is TC0
SCI_BD_TIM_ICNE		EQU	$02		;default is IC1			
SCI_BD_TIM_TCNE		EQU	$TC1		;default is TC1		
SCI_BD_ECT_TCTL		EQU	$TCTL4		;default is TCTL4		
SCI_BD_ECT_TCTL_SET	EQU	$EDG0B|EDG0A	;default is EDG0B|EDG0A		
SCI_BD_ECT_TCTL_CLR	EQU	$EDG0B|EDG0A	;default is EDG0B|EDG0A
#endif
#endif
#ifdef	SCI_BD_ECT
#ifdef	SCI_BD_ECT_IC
SCI_BD_ECT_IC		EQU	$01		;default is IC0		
SCI_BD_ECT_TC		EQU	$TC0		;default is TC0		
SCI_BD_ECT_TCH		EQU	$TC0H		;default is TC0H		
SCI_BD_ECT_TCTL		EQU	$TCTL4		;default is TCTL4		
SCI_BD_ECT_TCTL_SET	EQU	$EDG0B|EDG0A	;default is EDG0B|EDG0A		
SCI_BD_ECT_TCTL_CLR	EQU	$EDG0B|EDG0A	;default is EDG0B|EDG0A		
#endif
#endif

;Output compare channels 
#ifndef	SCI_BD_TIM_OCTO
#ifdef	SCI_BD_TIM
SCI_BD_OCTO		EQU	$04		;default is OC2			
SCI_BD_TCTO		EQU	$TC2		;default is TC2
#endif
#ifdef	SCI_BD_ECT
SCI_BD_OCTO		EQU	$02		;default is OC1			
SCI_BD_TCTO		EQU	$TC1		;default is TC1
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
SCI_TXBUF_SIZE		EQU	  8		;size of the transmit buffer
SCI_RXBUF_MASK		EQU	$1F		;mask for rolling over the RX buffer
SCI_TXBUF_MASK		EQU	$07		;mask for rolling over the TX buffer

;#Hardware handshake borders
SCI_FILL_LEVEL		EQU	 8*2		;RX buffer threshold to block transmissions 
SCI_EMPTY_LEVEL		EQU	 2*2		;RX buffer threshold to unblock transmissions
	
;#Flag definitions
SCI_FLG_FCRX_UPDATE	EQU	$80		;transmit XON/XOFF
SCI_FLG_FCRX_FORCE	EQU	$40		;request to stop incomming data (forced flow control)
SCI_FLG_FCRX_BUF	EQU	$20		;request to stop incomming data (buffer overflow)
SCI_FLG_SWOR		EQU	$10		;software buffer overrun (RX buffer)
SCI_FLG_FCTX		EQU	$08		;don't transmit (XOFF received)
SCI_FLG_ESC		EQU	$04		;character is to be escaped

SCI_FLG_RXERR		EQU	$02		;RX error
SCI_FLG_BDNPREV		EQU	$01		;No previous edge captured
	
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
SCI_RXBUF_IN		DS	1
SCI_RXBUF_OUT		DS	1
;#Transmit buffer
SCI_TXBUF		DS	SCI_TXBUF_SIZE
SCI_TXBUF_IN		DS	1		;points to the next free space
SCI_TXBUF_OUT		DS	1		;points to the oldest entry
;#Baud rate (reset proof) 
SCI_BVAL		DS	2		;value of the SCIBD register *SCI_BMUL

SCI_AUTO_LOC2		DS	1		;2nd auto-place location
			UNALIGN	1
;#Flags
SCI_FLGS		EQU	((SCI_VARS_START&1)*SCI_AUTO_LOC1)+((~SCI_VARS_START&1)*SCI_AUTO_LOC2)
			UNALIGN	(~SCI_VARS_START_LOC1&1)






	
;#Baud rate detection registers
#ifdef SCI_BD_ON	
#ifdef SCI_BD_TIM
SCI_BDPREV		DS	2		;timestamp of previous edge
#endif
SCI_BDLST		DS	1		;list of potential baud rates
#endif


SCI_IRQWA_CNT


	
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
#ifdef SCI_XON_XOFF
			MOVB	#SCI_FLG_FCRX_UPDATE, SCI_FLGS 		;send initial XON
#else
			STAA	SCI_FLGS 				;all cleared
#endif
			;Initialize baud rate detection
#ifdef SCI_BD_ON	
#ifdef SCI_BD_TIM
			STD	SCI_BDPREV				;no  previous timestamp of previous edge
#else
			STD	SCI_BDLST				;baud rate detection disabled
#endif
	
			;Check for POR 
			LDAB	CLOCK_FLGS
			BITA	#(PORF|LVRF)
			BNE	SCI_INIT_2
	
			;Check if stored baud rate is still valid
			LDD	SCI_BVAL 				;SCI_BMUL*baud rate -> D
			BEQ	SCI_INIT_2				;use default value if zero
			LDX	#SCI_BMUL				;SCI_BMUL -> X
			IDIV						;D/X -> X, D%X -> D
			CPD	#$0000					;check if the remainder is 0
			BNE	SCI_INIT_2				;stored baud rate is invalid
			LDY	#SCI_BTAB				;start of baud table -> Y
SCI_INIT_1		CPX     2,Y+					;compare table entry with X	
			BEQ	SCI_INIT_3				;match
			CPY	#SCI_BTAB_END				;check if the end of the table has been reached
			BNE	SCI_INIT_1				;loop
			;No match use default
SCI_INIT_2		LDX	#SCI_BDEF	 			;default baud rate
			MOVW	#(SCI_BDEF*SCI_BMUL), SCI_BVAL
			;Match 
SCI_INIT_3		STX	SCIBDH					;set baud rate

			;Invert RXD/TXD polarity
#ifdef	SCI_RXTX_ACTHI
			MOVB	#(TXPOL|RXPOL), SCISR
#endif	
			;Set frame format and enable transmission
			MOVW	#((SCI_8N1<<8)|TXIE|RIE|TE|RE), SCICR1 	;8N1
			;MOVB	#T8, SCIDRH				;8N2
			;MOVW	#((SCI_8N2<<8)|TXIE|RIE|TE|RE), SCICR1	;8N2

			;Set CTS (allow incomming traffic)
#ifdef	SCI_RTS_CTS
			BSET	SCI_CTS_PORT, SCI_CTS_PIN
#endif	

			;Start XON/XOFF repeater and SMC9S12DP256 workaroundtart XON/XOFF repeater 
#ifdef SCI_XON_XOFF
#ifdef	SCI_WORKAROUND_ON
			LDD	TCNT
			STD	SCI_TIM_TCFC
			ADD	
	
#else


#endif
#else
#ifdef	SCI_WORKAROUND_ON


#endif
#endif


	
			;Start MC9S12DP256 workaround 
			;Start XON/XOFF repeater 
			


	


	


#macro	TIM_ENABLE, 1
			BSET	TIM_BUSY, #\1
			MOVB	#(TEN|TSFRZ), TSCR1	
#emac







#emac

;#Common tasks
;#Allow incomming traffic	
#macro	SCI_RX_ENABLE, 0
			BCLR	 SCI_FLGS, #SCI_FLG_FCRX_FORCE
#ifdef SCI_XON_XOFF
			BSET	 SCI_FLGS, #SCI_FLG_FCRX_UPDATE
#endif
#ifdef	SCI_RTS_CTS
			BRSET	 SCI_FLGS, #SCI_FLG_FCRX_BUF, DONE
			BSET	SCI_CTS_PORT, SCI_CTS_PIN
#endif	
DONE			EQU	*

	
#emac


;#Allow incomming traffic	
#macro	SCI_RX_DISABLE, 0
#ifdef SCI_XON_XOFF
			BSET	 SCI_FLGS, #(SCI_FLG_FCRX_UPDATE|SCI_FLG_FCRX_FORCE)
#else
			BSET	 SCI_FLGS, #SCI_FLG_FCRX_FORCE
#endif	
#ifdef	SCI_RTS_CTS
			BCLR	SCI_CTS_PORT, SCI_CTS_PIN
#endif	
#emac

;#Functions
	
;#Transmit one byte - non-blocking
; args:   B: data to be send
; result: C-flag: set if successful
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX_NB, 0
			SSTACK_JOBSR	SCI_TX_NB
#emac
	
;#Transmit one byte - blocking
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX_BL, 0
			SSTACK_JOBSR	SCI_TX_BL
#emac

;#Peek into the TX queue and check how much space is left
; args:   none
; result: A: number of entries left in TX queue
; SSTACK: 3 bytes
;         X, Y, and B are preserved 
#macro	SCI_TX_PEEK, 0
			SSTACK_JOBSR	SCI_TX_PEEK
#emac
		
;#Wait until the TX queue is empty
; args:   none
; result: A: number of entries left in TX queue
; SSTACK: 3 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX_WAIT, 0
			SSTACK_JOBSR	SCI_TX_WAIT
#emac
		
;#Receive one byte - blocking
; args:   none
; result: A: error flags 
;         B: received data 
;    C-flag: set if successful
; SSTACK: 6 bytes
;         X and Y are preserved 
#macro	SCI_RX_NB, 0
			SSTACK_JOBSR	SCI_RX_NB
#emac
;#Receive one byte - blocking
;#Receive one byte - blocking
; args:   none
; result: none
; SSTACK: 6 bytes
;         X and Y are preserved 
#macro	SCI_RX_BL, 0
			SSTACK_JOBSR	SCI_RX_BL
#emac

;#Peek into the RX queue and check how bytes have been received
; args:   none
; result: X: number of entries in RX queue
;         D: oldest queue entry (random value if X is zero)
; SSTACK: 2 bytes
;         Y is preserved 
#macro	SCI_RX_PEEK, 0
			SSTACK_JOBSR	SCI_RX_PEEK
#emac
	
;#Remove the oldest entry from the RX queue (convinience macro to call the SCI_RX subroutine)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y and D are preserved 
#macro	SCI_RX_DROP, 0
			SSTACK_JOBSR	SCI_RX_DROP
#emac
	
;#Block incoming data
; args:   none
; result: none
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_RX_BLK, 0
			SSTACK_JOBSR	SCI_RX_BLK
#emac

;#Unblock incoming data
; args:   none
; result: none
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_RX_UBLK, 0
			SSTACK_JOBSR	SCI_RX_UBLK
#emac

;#Set baud rate (convinience macro to call the SCI_BAUD subroutine)
; args:   D: new SCIBD value
; result: none
; SSTACK: 14 bytes
;         X, Y, and D are preserved 
#macro	SCI_SET_BAUD, 0
			SSTACK_JOBSR	SCI_SET_BAUD
#emac

;# Macros for internal use

	


;#Enable interrupts (convinience macro to call the SCI_BAUD subroutine)
; args:   none
; result: none
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_CLI, 0
			CLI
			BCLR	SCI_FLGS, #SCI_FLG_FCRX_FC			;request transmission of XON
			MOVB	#(TXIE|RIE|TE|RE), SCICR2		   	;enable TX IRQ
#emac
	
;Set CTS signal -> allow incomming data ("Clear To Send")
; args:   none
; result: none
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_SET_CTS, 0
			BCLR	SCI_FLGS, #SCI_FLG_FCRX_FC			;request transmission of XON
			MOVB	#(TXIE|RIE|TE|RE), SCICR2		   	;enable TX IRQ
#emac

;Clear CTS signal -> forbid incomming data ("Clear To Send")
; args:   none
; result: none
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_CLR_CTS, 0
			BSET	SCI_FLGS, #SCI_FLG_FCRX_FC			;request transmission of XOFF
			MOVB	#(TXIE|RIE|TE|RE), SCICR2		   	;enable TX IRQ
#emac

;Branch if RTS is cleared ("Ready To Send")
; args:   none
; result: none
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_BRNORTS, 1
			BRCLR	SCI_FLGS, #SCI_FLG_FCTX, %1	
#emac
	
;Stop baud rate detection
#macro	SCI_STOP_BD, 0
			BRCLR	SCI_BDLST, #$FF, DONE			;baud rate detection already inactive
			BCLR	TIE, #C0I				;disable interrupts
			TIM_DISABLE TIM_SCI				;disable timer
			CLR	SCI_BDLST				;clear baud rate result register
			LED_COMERR_OFF					;stop signaling communication errors
DONE			EQU	*
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
#macro	SCI_TX_NB, 0
			;Save registers (data in B)
			SSTACK_PSHYA					;push Y and A onto the SSTACK
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
			;BSET	SCICR2, #TXIE
			MOVB	#(TXIE|RIE|TE|RE), SCICR2
			;Restore registers
			SSTACK_PULAY					;pull A and Y from the SSTACK
			;Signal success
			SEC
			;Done
			RTS
			;Buffer is full 
			;Restore registers
SCI_TX_NB_1		SSTACK_PULAY					;pull A and Y from the SSTACK
			;Signal failure
			CLC
			;Done
			RTS
			
;#Transmit one byte - blocking
; args:   B: data to be send
; SSTACK: 7 bytes
;         X, Y, and D are preserved 
SCI_TX_BL		EQU	*
			;Disable interrupts (data in B)
			SEI
			;Try to transmit data (data in B)
			SSTACK_JOBSR	SCI_TX_NB
			BCS	SCI_TX_BL_ 				;transmission successful
			;Wait fu 
	

		 ;Save registers (data in B)
			SSTACK_PSHYA					;push Y and A onto the SSTACK







	SSTACK_JOBSR	SCI_TX_NB
#emac




	
;#Peek into the TX queue and check how much space is left
; args:   none
; result: A: number of entries left in queue
; SSTACK: 3 bytes
;         X, Y, and B are preserved 
SCI_TX_PEEK		EQU	*
			;Save registers
			SSTACK_PSHB					;push accu B onto the SSTACK
			;Calculate the number of entries left in the buffer 
			LDD	SCI_TXBUF_IN
			INCB
			EXG	A,B
			SBA
			ANDA	#SCI_TXBUF_MASK
			;Restore registers
			SSTACK_PULB					;pull all accu B from the SSTACK
			;Done
			RTS

;#Wait until the TX buffer is empty (convinience macro to call the SCI_TBE subroutine)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
SCI_TX_WAIT		EQU	*
			;Save registers
			SSTACK_PSHD					;push accu D onto the SSTACK
			;Wait until the TX queue is empty
SCI_TX_WAIT_1		SEI						;disable interrupts		
			LDD	SCI_TXBUF_IN				;check if TX queue is empty
			CBA
			BEQ	SCI_TX_WAIT_2 				;wait until current transmission is complete	
			ISTACK_WAIT					;wait for an event
			JOB	SCI_TX_WAIT_1
			;Wait until current transmission is complete (I-bit is set)
SCI_TX_WAIT_2		SEI  						;enable transmission complete interrupt
			MOVB	#(TCIE|RIE|TE|RE), SCICR2
			BRSET	SCISR1, #TC, SCI_TX_WAIT_3 		;transmission is over
			ISTACK_WAIT					;wait for an event
			JOB	SCI_TX_WAIT_2
SCI_TX_WAIT_3		MOVB	#(RIE|TE|RE), SCICR2			;disable transmission complete interrupt
			;Restore registers
			SSTACK_PULD					;pull all accu D from the SSTACK
			;Done
			RTS
		
;#Receive one byte (this function will block until it is able to obtain one byte of data)
; args:   none
; result: A: error flags 
;         B: received data 
 ; SSTACK: 6 bytes
;         X and Y are preserved 
SCI_RX			EQU	*
			;Save registers
			SSTACK_PSHYX					;push index registers onto the SSTACK
			;Check if there is data in the RX queue
			SEI
			LDD	SCI_RXBUF_IN
			CBA		 		
			BEQ	SCI_RX_3 				;RX buffer is empty
			;Pull entry from the RX queue (in-index in A, out-index in B)
SCI_RX_1		LDY	#SCI_RXBUF
			LDX	B,Y
			ADDB	#$02					;increment out pointer
			ANDB	#SCI_RXBUF_MASK
			STAB	SCI_RXBUF_OUT
			;CTS handshake  (in-index in A, new out-index in B, RX data in X)
			SBA
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_XON_LEVEL
			BHS	SCI_RX_2 				;buffer still to full
			BRCLR	SCI_FLGS, #SCI_FLG_FCRX_BF, SCI_RX_2	
			BCLR	SCI_FLGS, #SCI_FLG_FCRX_BF		;send XON
			MOVB	#(TXIE|RIE|TE|RE), SCICR2
			;Return result (RX data in X)
SCI_RX_2		CLI						;unblock interrupts
			TFR X, D					;set return value
			;Restore registers (RX data in D)	
			SSTACK_PULXY					;pull index registers from the SSTACK
			;Done (RX data in X)
			SSTACK_RTS
			;Wait loop (in-index in A, out-index in B)
SCI_RX_3		SEI
			LDAA	SCI_RXBUF_IN
			CBA
			BNE	SCI_RX_1				;leave wait loop
			ISTACK_WAIT					;wait until any interrupt occurs
			JOB	SCI_RX_3

;#Peek into the RX queue and check how bytes have been received
; args:   none
; result: X: number of entries in RX queue
;         D: oldest queue entry (random value if X is zero)
; SSTACK: 2 bytes
;         X and Y are preserved 
SCI_RX_PEEK		EQU	*
			;Check if RX queue is empty
			LDD	SCI_RXBUF_IN
			SBA		 		
			BEQ	SCI_RX_PEEK_1 				;RX_QUEUE is empty
			;Read oldest RX data entry (in-index - out-index in A, out-index in B)
			ANDA	#SCI_RXBUF_MASK				;number of RX entries -> A
			LSRA
			LDX	#SCI_RXBUF 				;oldest RX entry -> X
			LDX	B,X 
   			;Return result (number of RX entries in A, oldest queue entry in X
SCI_RX_PEEK_1		EXG	A, D
			EXG	D, X
			;Done
			SSTACK_RTS

;#Remove the oldest entry from the RX queue (convinience macro to call the SCI_RX subroutine)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y and D are preserved 
SCI_RX_DROP		EQU	*
			;Save registers
			SSTACK_PSHD					;push accu D onto the SSTACK	
			;Check if RX queue is empty
			LDD	SCI_RXBUF_IN
			CBA		 		
			BEQ	SCI_RX_DROP_1 				;RX_QUEUE is empty
			;Incremaent out-index (in-index in A, out-index in B) 
			ADDB	#2
			ANDB	#SCI_RXBUF_MASK	
			STAB	SCI_RXBUF_OUT
			;CTS handshake  (in-index in A, new out-index in B)
			SBA
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_XON_LEVEL
			BHS	SCI_RX_DROP_1 				;buffer still to full
			MOVB	#(TXIE|RIE|TE|RE), SCICR2
			;Restore registers	
SCI_RX_DROP_1		SSTACK_PULD					;pull accu D from the SSTACK
			;Done (RX data in X)
			SSTACK_RTS
	
;#Set baud rate (this function will block until the current transmission is complete)
; args:   D: new SCIBD value
; result: none
; SSTACK: 14 bytes
;         X, Y, and D are preserved 
SCI_SET_BAUD		EQU	*
			;Save registers (new SCIBD value in D)
			SSTACK_PSHYD					;push Y and D onto the SSTACK
			;Finish current transmission (new SCIBD value in D)
			SCI_TX_WAIT					;(SSTACK: 8 bytes) 
			;Disable baud rate detection (new SCIBD value in D)
			SCI_STOP_BD					;stop baud rate detection	
			;Set baud rate (new SCIBD value in D)
			STD	SCIBDH					;set baud rate
			LDY	#SCI_BMUL				;save baud rate for next warmstart
			EMUL						;D*Y -> Y:D
			STD	SCI_BVAL
			;Clear input buffer
			MOVW	#$0000, SCI_RXBUF_IN			;reset in and out pointer of the RX buffer
			;Restore registers
			SSTACK_PULDY					;pull D and Y from the SSTACK
			;Done
			RTS
	
;#Transmit handler
SCI_ISR_TX		EQU	*
			;Check if SCI is ready to transmit data (status flags in A)
			BITA	#TDRE					;check if SCI is ready for new TX data
			BEQ	<SCI_ISR_TX_5				;done for now
			
			;Check RX flow control 
			LDAA	SCI_FLGS
			BITA	#(SCI_FLG_FCRX|SCI_FLG_FCRX_BF|SCI_FLG_FCRX_FC)
			BEQ	<SCI_ISR_TX_2 				;check TX flow control
			BMI	<SCI_ISR_TX_1				;check if XON should be send
			
			;Send XOFF (SCI_FLGS in A)
			MOVB	#SCI_XOFF, SCIDRL			;send XOFF
			BSET	SCI_FLGS, #SCI_FLG_FCRX		 	;update flow control status
			JOB	SCI_ISR_TX_5				;done for now
			
			;Check XON should be send (SCI_FLGS in A)
SCI_ISR_TX_1		BITA	#(SCI_FLG_FCRX_BF|SCI_FLG_FCRX_FC)
			BNE	<SCI_ISR_TX_2 				;check TX flow control
			MOVB	#SCI_XON, SCIDRL			;send XOFF
			BCLR	SCI_FLGS, #SCI_FLG_FCRX			;update flow control status
			BEQ	<SCI_ISR_TX_5				;done for now
			
			;Check TX flow control (SCI_FLGS in A)
SCI_ISR_TX_2		BITA	#SCI_FLG_FCTX 				;check if an XOFF had been received
			BNE	<SCI_ISR_TX_4				;disable transmission
			
			;Check TX buffer
SCI_ISR_TX_3		LDD	SCI_TXBUF_IN
			CBA
			BEQ	<SCI_ISR_TX_4 				;disable transmission
			;Transmit data (in-index in A, out-index in B)
			LDY	#SCI_TXBUF
			MOVB	B,Y ,SCIDRL
			;Increment index
			INCB
			ANDB	#SCI_TXBUF_MASK
			STAB	SCI_TXBUF_OUT
			CBA
			BNE	<SCI_ISR_TX_5 				;done

			;Disable transmission
SCI_ISR_TX_4		MOVB	#(RIE|TE|RE), SCICR2			;disable transmission complete interrupt

			;Done
SCI_ISR_TX_5		ISTACK_RTI			

;#Transmit/Receive ISR (Common ISR entry point for the SCI)
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
			;BITA	#(RDRF|OR) 				;go to receive handler if receive buffer
			BITA	#(RDRFF|OR) 				;RDRF is the Reduced Drive Register for port F
			BEQ	<SCI_ISR_TX				; is full or if an overrun has occured
			
;#Receive handler (status flags in A)
SCI_ISR_RX		LDAB	SCIDRL					;load receive data into accu B (clears flags)
			;Check for RX errors (status flags in A, RX data in B)
#ifdef	SCI_BD_ON							;baud rate detection enabled
			BITA	#(NF|FE|PF) 				;check for: noise, frame errors, parity errors
			BNE	<SCI_ISR_RX_				;start baud rate detection
#else
#ifdef	SCI_ERRSIG_ON							;error signaling enabled, but baud rate detection disabled
			BITA	#(NF|FE|PF) 				;check for: noise, frame errors, parity errors
			BNE	<SCI_ISR_RX_				;signal error
			BRSET	SCI_FLGS, #SCI_FLG_RXERR, SCI_ISR_RX_ 	;stop error signal
#endif
#endif

			;Transfer SWOR flag to current error flags (status flags in A, RX data in B)
SCI_ISR_RX_1		ANDA	#(OR|NF|FE|PF)				;only maintain relevant error flags
			BRCLR	SCI_FLGS, #SCI_FLG_SWOR, SCI_ISR_RX_2	;SWOR bit not set
			ORAA	#SCI_FLG_SWOR				;set SWOR bit in accu A
			BCLR	SCI_FLGS, #SCI_FLG_SWOR 		;clear SWOR bit in variable	
SCI_ISR_RX_2		EQU	*

#ifdef	SCI_C0_WATCH	
			;Check for C0 characters (status flags in A, RX data in B)
			BITB	SCI_C0_MASK
			BEQ	SCI_ISR_RX_ 				;C0 character received

			;Reset escape flag (status flags in A, RX data in B)
SCI_ISR_RX_		BCLR	SCI_FLGS, #SCI_FLG_ESC
#endif	
			;Place data into RX queue (status flags in A, RX data in B) 
SCI_ISR_RX_		TFR	D, Y					;flags:data -> Y
			LDX	#SCI_RXBUF
			LDD	SCI_RXBUF_IN				;in:out -> A:B
			STY	A,X
			ADDA	#2
			ANDA	#SCI_RXBUF_MASK		
			CBA
                	BEQ	<SCI_ISR_RX_				;buffer overflow
			STAA	SCI_RXBUF_IN				;update IN pointer

			;Check flow control threshold (in:out in D, flags:data in Y) 
			SBA
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_FULL_LEVEL
			BHS	<SCI_ISR_RX_ 				;block incoming transmissions
			
			;Done
SCI_ISR_RX_		ISTACK_RTI			
	
			;Start baud rate detection if necessary (status flags in A, RX data in B)
#ifdef SCI_BD_ON
SCI_ISR_RX_		TST	SCI_BDLST 				;check if baud rate detection is running
			BNE	<SCI_ISR_RX_ 				;continue (transfer SWOR flag)

			;Initiate baud rate detection
			MOVB	#$FF, SCI_BDLST				;reset BD result registers
#ifdef SCI_ERRSIG_ON
			SCI_ERRSIG_ON				        ;signal communication error
#endif
#ifdef SCI_INTWA_OFF
			TIM_ENABLE TIM_SCI		     		;enable timer
#endif
#ifdef	SCI_BD_TIM
			;Setup TIM 
			MOVB	#(SCI_BD_TIM_ICNE|SCI_BD_TIM_ICPE|SCI_BD_OCTO), TFLG1	;clear interrupt flags
			BSET	TCTL4, #$09 				;enable edge detection (IC1: negedge, IC0: posedge)
			BSET	TIE, #(SCI_BD_TIM_ICNE|SCI_BD_TIM_ICPE)	;enable posedge and negedge IRQ
#endif
#ifdef	SCI_BD_ECT
			;Setup ECT 
			MOVB	#(SCI_BD_ECT_IC|SCI_BD_OCTO), TFLG1	;clear interrupt flags
			LDD	SCI_BD_ECT_TC
			LDD	SCI_BD_ECT_TCH
			BSET	SCI_BD_ECT_TCTL, #SCI_BD_ECT_TCTL_SET 	;enable edge detection (workaround for erratum MUCts04104)
			BSET	TIE, #SCI_BD_ECT_IC			;enable  IRQ
#endif
			JOB	SCI_ISR_RX_1 				;continue (transfer SWOR flag)
#else	
#ifdef	SCI_ERRSIG_ON							;error signaling enabled, but baud rate detection disabled
			;Signal error (status flags in A, RX data in B)
SCI_ISR_RX_		BRSET	SCI_FLGS, #SCI_FLG_RXERR, SCI_ISR_RX_1 	;continue (transfer SWOR flag)
			SCI_ERRSIG_ON
			JOB	SCI_ISR_RX_1 				;continue (transfer SWOR flag)
			;Stop error signal (status flags in A, RX data in B)
			BCLR	SCI_FLGS, #SCI_FLG_RXERR
			JOB	SCI_ISR_RX_1 				;continue (transfer SWOR flag)
#endif
#endif


	
#ifdef	SCI_CHECK_C0_CHARS	
			;C0 character received (status flags in A, RX data in B)
SCI_ISR_RX_		BRSET	SCI_FLGS, #SCI_FLG_ESC, SCI_ISR_RX_ 	;escape C0 character
			
#ifdef	SCI_XON_XOFF		
			;Check for XON or XOFF (status flags in A, RX data in B)
			CMPB	#SCI_XOFF
			BEQ	<SCI_ISR_RX_ 				;disable transmissions
			CMPB	#SCI_XON
			BEQ	<SCI_ISR_RX_ 				;enable transmissions
#endif

#ifndef	SCI_BREAK
			;Check for BREAK (status flags in A, RX data in B)
			CMPB	#SCI_BREAK
			BEQ	<SCI_ISR_RX_ 				;terminate program execution
#endif	

#ifndef	SCI_SUSPEND
			;Check for SUSPEND (status flags in A, RX data in B)
			CMPB	#SCI_SUSPEND
			BEQ	<SCI_ISR_RX_ 				;terminate program execution
#endif	
			;Check for DLE (status flags in A, RX data in B)		
			CMPB	#SCI_DLE
			BNE	<SCI_ISR_RX_ 				;treat character as data
			BSET	SCI_FLGS, #SCI_FLG_ESC 			;escape next character
			JOB	<SCI_ISR_RX_ 				;done
#endif

#ifdef	SCI_XON_XOFF		
			;Disable transmissions
SCI_ISR_RX_		BSET	SCI_FLGS, #SCI_FLG_FCTX
			;MOVB	#(TXIE|RIE|TE|RE), SCICR2 		;enable TX interrupts	
			JOB	SCI_ISR_RX_ 				;done

			;Enable transmissions
SCI_ISR_RX_		BCLR	SCI_FLGS, #SCI_FLG_FCTX
			MOVB	#(TXIE|RIE|TE|RE), SCICR2 		;enable TX interrupts
			JOB	SCI_ISR_RX_ 				;done
#endif
	
			;Buffer overflow (flags:data in Y)
SCI_ISR_RX_		BSET	SCI_FLGS, #SCI_FLG_SWOR

			;Block incoming transmissions (flags:data in Y)
SCI_ISR_RX_		EQU	*
#ifdef	SCI_XON_XOFF		
			BSET	SCI_FLGS, #SCI_FLG_FCRX_BF
			MOVB	#(TXIE|RIE|TE|RE), SCICR2 		;enable interrupts
#endif
#ifdef	SCI_RTS_CTS		
			SCI_RELEASE_

#endif

			JOB	SCI_ISR_RX_ 				;done






#ifdef SCI_BD_TIM	
			;RX negedge ISR  (default IC1)
SCI_ISR_BD_NE		EQU	*
	
			;Capture the pulse length
SCI_ISR_BD_NE_1		LDD	SCI_BD_TIM_TCNE				;capture time of this negedge
			STD	SCI_BD_TCTO				;reset timeout
			SUBD	SCI_BD_TIM_TCPE				;calculate pulse length -> D
			LDX	TFLG1 					;capture flags -> X
			MOVB	#(SCI_BD_TIM_ICPE|SCI_BD_TIM_ICNE|SCI_BD_OCTO), TFLG1 ;clear flags
	
			;Release interrupts (pulse length in D, flags in X)
			ISTACK_CLI 					;allow interrupts if there is enough room on the stack

			;Check for overrun and timeout (pulse length in D, flags in X)
			EXG	X, D
			BITA	#(SCI_BD_TIM_ICNE|SCI_BD_OCTO)
			BNE	SCI_ISR_BD_NE_ 				;overrun or timeout has occured (done)

			;Look up pulse length in search tree (pulse length in X, flags in D)
			LDY	#SCI_BD_HIGH_PULSE_TREE
			JOB	SCI_ISR_BD_NE_

SCI_ISR_BD_NE_		EQU	SCI_ISR_BD_PE_				;done
SCI_ISR_BD_NE_		EQU	SCI_ISR_BD_PE_				;parse high pulse search tree

	
			;RX posedge ISR  (default IC0)
SCI_ISR_BD_PE		EQU	*
	
			;Capture the pulse length
SCI_ISR_BD_PE_1		LDD	SCI_BD_TIM_TCPE				;capture time of this posedge
			STD	SCI_BD_TCTO				;reset timeout
			SUBD	SCI_BD_TIM_TCNE				;calculate pulse length -> D
			LDX	TFLG1 					;capture flags -> X
			MOVB	#(SCI_BD_TIM_ICPE|SCI_BD_TIM_ICNE|SCI_BD_OCTO), TFLG1 ;clear flags
	
			;Release interrupts (pulse length in D, flags in X)
			ISTACK_CLI 					;allow interrupts if there is enough room on the stack

			;Check for overrun and timeout (pulse length in D, flags in X)
			EXG	X, D
			BITA	#(SCI_BD_TIM_ICNE|SCI_BD_OCTO)
			BNE	SCI_ISR_BD_PE_ 				;overrun or timeout has occured (done)

			;Look up pulse length in search tree (pulse length in X, flags in D)
			LDY	 #SCI_BD_LOW_PULSE_TREE
SCI_ISR_BD_PE_		SCI_BD_PARSE 					;determine matching baud rates -> D

			;Update list of potential batd rates (matching baud rates in D)
			SEI						;prevent interrupts
			ANDB	SCI_BDLST 				;remove mismatching baud rates from the list
			BEQ	SCI_ISR_BD_PE_ 				;no valid baud rate found
			STAB	SCI_BDLST 

			;Check if baud rate has been determined (potential baud rates in B (not zero))
			CLRA
SCI_ISR_BD_PE_		INCA
			LSRB
			BCC	SCI_ISR_BD_PE_
			BEQ	SCI_ISR_BD_PE_ 				;new baud rate found (index in A)
			
			;Done (baud rate detection not finished)
SCI_ISR_BD_PE_		ISTACK_RTI

			;Check if baud rate detection is over
SCI_ISR_BD_PE_		BRCLR	SCI_BDLST, #$FF, SCI_ISR_BD_PE_		;done

			;Restart baud rate detection 
			MOVB	$#FF, SCI_BDLST
			JOB	SCI_ISR_BD_PE_ 				;done
	
			;New baud rate found (index in A, $00 in B)
SCI_ISR_BD_PE_		BCLR	TIE, #(SCI_BD_TIM_ICPE|SCI_BD_TIM_ICNE)	;disable timer interrupts
			LSLA						;index -> addess offset
			LDX	SCI_BD_BTAB 				;look up prescaler value
			LDD	SCI_BD_BTAB,X				;look up divider value
			STD	SCIBDH					;set baud rate
			LDY	#SCI_BMUL				;save baud rate for next warmstart
			EMUL						;D*Y -> Y:D
			STD	SCI_BVAL
			TIM_DISABLE	(SCI_BD_TIM_ICPE|SCI_BD_TIM_ICNE|SCI_BD_OCTO)
			JOB	SCI_ISR_BD_PE_ 				`;done
#endif	
			
#ifdef SCI_BD_EXT
			;RX toggle ISR  (default IC0)
SCI_ISR_BD_TOG		EQU	*
			
			;Capture the pulse length
SCI_ISR_DB_TOG_		LDD	TC0					;determine time of most recent edge
			STD	SCI_BD_TCTO				;reset timeout
			SUBD	TC0H					;calculate pulse length -> D

			;Determine tne pulse polarity (pulse length in D)
			LDY	#SCI_BD_LOW_PULSE_TREE			;determine the polarity
			BRCLR	MCFLG, #POLF0, SCI_ISR_DB_TOG_		;check for time out
			LDY	#SCI_BD_HIGH_PULSE_TREE				
			
			;Check timeout (pulse length in D, tree root in Y)
SCI_ISR_DB_TOG_		BRSET	TFLG1, $SCI_BD_OCTO, SCI_ISR_DB_TOG_ 	;time out has occured

			;Clear interrupt flags 
			MOVB	#(SCI_BD_ECT_IC|SCI_BD_OCTO), TFLG1 	;clear flags
	
			;Release interrupts (pulse length in D, tree root in Y)
			ISTACK_CLI 					;allow interrupts if there is enough room on the stack

			;Look up pulse length in search tree (pulse length in D, tree root in Y)
			TFR	D, X
			SCI_BD_PARSE 					;determine matching baud rates -> D

			;Update list of potential batd rates (matching baud rates in D)
			SEI						;prevent interrupts
			ANDB	SCI_BDLST 				;remove mismatching baud rates from the list
			BEQ	SCI_ISR_BD_TOG_ 			;no valid baud rate found
			STAB	SCI_BDLST 

			;Check if baud rate has been determined (potential baud rates in B (not zero))
			CLRA
SCI_ISR_BD_TOG_		INCA
			LSRB
			BCC	SCI_ISR_BD_TOG_
			BEQ	SCI_ISR_BD_TOG_ 			;new baud rate found (index in A)
			
			;Done (baud rate detection not finished)
SCI_ISR_BD_TOG_		ISTACK_RTI

			;Time out occurred 
			MOVB	#(SCI_BD_ECT_IC|SCI_BD_OCTO), TFLG1 	;clear flags
			JOB	SCI_ISR_BD_TOG_				;done
	
			;Check if baud rate detection is over
SCI_ISR_BD_PE_		BRCLR	SCI_BDLST, #$FF, SCI_ISR_BD_PE_		;done

			;Restart baud rate detection 
			MOVB	$#FF, SCI_BDLST
			JOB	SCI_ISR_BD_PE_ 				;done
	
			;New baud rate found (index in A, $00 in B)
SCI_ISR_BD_PE_		BCLR	TIE, #(SCI_BD_TIM_ICPE|SCI_BD_TIM_ICNE)	;disable timer interrupts
			LSLA						;index -> addess offset
			LDX	SCI_BD_BTAB 				;look up prescaler value
			LDD	SCI_BD_BTAB,X				;look up divider value
			STD	SCIBDH					;set baud rate
			LDY	#SCI_BMUL				;save baud rate for next warmstart
			EMUL						;D*Y -> Y:D
			STD	SCI_BVAL
			TIM_DISABLE	(SCI_BD_TIM_ICPE|SCI_BD_TIM_ICNE|SCI_BD_OCTO)
			JOB	SCI_ISR_BD_PE_ 				`;done
#endif	
	
	






;#Edge on RX pin captured
SCI_ISR_TC0		EQU	*
			;Determine tne pulse polarity
			LDY	#SCI_LT0				;determine the polarity
			BRCLR	MCFLG, #POLF0, SCI_ISR_TC0_1		;capture pulse length
			LDY	#SCI_HT0				
			;Ignore pulses if a timer overflow has occured (search tree pointer in Y)
			BRSET	TFLG2  #TOI, SCI_ISR_TC0_9

			;Capture pulse length (search tree pointer in Y)
SCI_ISR_TC0_1		MOVW	#((C0F<<8)|TOF), TFLG1 			;clear interrupt flags
			BCLR	TCTL4, #$03 				;disable edge detection (workaround for erratum MUCts04104)
			LDD	TC0					;determine the pulse length
			SUBD	TC0H
			BSET	TCTL4, #$03 				;enable (workaround for erratum MUCts04104)	

			;Check if baud rate detection is still enabled (pulse length in D, search tree pointer in Y)
			BRCLR	SCI_BDLST, #$FF, SCI_ISR_TC0_8 		;baud rate detection disabled	

			;Ignore zero length pulses - happens when debugging (pulse length in D, search tree pointer in Y)
			TBEQ	D, SCI_ISR_TC0_5

			;Parse a search tree (pulse length in D, search tree pointer in Y) 
			LDX	#$0000					;use index X to store valid baud rates
SCI_ISR_TC0_2		TST	0,Y	     				;check if lower boundary exists
			BEQ	<SCI_ISR_TC0_3				;search done
			CPD	6,Y+					;check if pulse length is shorter than lower boundary
			BLO	<SCI_ISR_TC0_2				;pulse length is shorter than lower boundary
									; -> try a shorter range
			LDX	-4,Y					;pulse length is longer or same as lower boundary
									; -> store valid baud rate field in index X
			LDY	-2,Y					; -> parse a new branch of the search tree that contains longer ranges
			BNE	<SCI_ISR_TC0_2				;parse branch if it exists			

			;Search is done (valid baud rates in X) 
SCI_ISR_TC0_3		EXG	X, D	 				;apply search result to the set of valid baud rates
			ANDA	SCI_BDLST
			BEQ	<SCI_ISR_TC0_6				;no valid baud rate found, start all over
			STAA	SCI_BDLST 				;save valid Baud rates				
			;Check if baud rate has been determined (valid baud rates in A)
			TAB						;save baude rates in accu B
			LDX	#$FFFE					;use index X as index counter
SCI_ISR_TC0_4		LEAX	2,X					;increment index counter
			LSRA						;check if only one bit is set in accu A
			BCC	<SCI_ISR_TC0_4				;shift until a "1" ends up in the carry bit
			BEQ	<SCI_ISR_TC0_7				;baud rate has been determined			

			;Baud rate has not been determined yet (valid baud rates in accu B)
SCI_ISR_TC0_5		ISTACK_RTI					;wait for the next pulse			

			;No valid baud rate found, start all over
SCI_ISR_TC0_6		MOVB	#$FF, SCI_BDLST
			JOB	SCI_ISR_TC0_5				;done			

			;Baud rate has been validated (index of baud rate table in index X)
SCI_ISR_TC0_7		LDD	SCI_BTAB,X				;look up divider value
			STD	SCIBDH					;set baud rate
			LDY	#SCI_BMUL				;save baud rate for next warmstart
			EMUL						;D*Y -> Y:D
			STD	SCI_BVAL	

			;Disable monitoring of the RX pin 
SCI_ISR_TC0_8		BCLR	TIE, #C0I 				;disable interrupts
			TIM_DISABLE TIM_SCI		     		;disable timer	
			BCLR	TCTL4, #$03 				;disable edge detection (workaround for erratum MUCts04104)
			CLR	SCI_BDLST 				;clear baud rate result register
			LED_COMERR_OFF					;stop signaling communication errors
			JOB	SCI_ISR_TC0_5				;done

			;Ignore pulses if timer overflow has occured
SCI_ISR_TC0_9		MOVW	#((C0F<<8)|TOF), TFLG1 			;clear interrupt flags
			BCLR	TCTL4, #$3 				;disable edge detection (workaround for erratum MUCts04104)
			LDD	TC0					;determine the pulse length
			LDD	TC0H
			BSET	TCTL4, #$3 				;enable (workaround for erratum MUCts04104)	
			BRCLR	SCI_BDLST, #$FF, SCI_ISR_TC0_8 		;baud rate detection disabled	
			JOB	SCI_ISR_TC0_5 				;done



#ifdef	SCI_IRQWA_ON
;###############################################################################
;# Workaround for the MC9S12DP256 SCI interrupt bug (MUCts00510)               #
;###############################################################################
;# The will only request interrupts if an odd number of interrupt flags is     #
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
;;#      #
;#      #



;#Interrupt workaround for old .25u devices
SCI_ISR_IRQWA		EQU	*
			;Decrement and  


			EQU	*
			;Setup next timer delay
			LDD	SCIBDH 					;get baud rate (clock cycles per bit)
			LSLD						;multiply by eight (10 bit per frame)
			LSLD
			LSLD
			ADD	SCI_INTWA_TC 				;setup next OC event
			STD	SCI_INTWA_TC 
			;Check for RX data 
			SCI_ISR_RXTX
#else
SCI_INT_INTWA		EQU	ERROR_ISR
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

#ifdef	SCI_BD_ON
			ALIGN	1

			;List of prescaler values
SCI_BD_BTAB		EQU	*
			DW	SCI_4800 	
			DW	SCI_7200 	
			DW	SCI_9600 	
			DW	SCI_14400	
			DW	SCI_19200	
			DW	SCI_28800	
			DW	SCI_38400	
			DW	SCI_57600	

			;Search tree for low pulses
SCI_BD_LOW_PULSE_TREE	SCI_BD_LOW_PULSE_TREE

			;Search tree for high pulses
SCI_BD_HIGH_PULSE_TREE	SCI_BD_HIGH_PULSE_TREE		
#endif	

SCI_TABS_END		EQU	*
SCI_TABS_END_LIN	EQU	@
