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
;#    This modules  provides two functions to the main program:                #
;#    SCI_TX      - This function sends a byte over the serial interface. This #
;#                  function will block the program flow until the data can be #
;#                  handed over to the transmit queue.                         #
;#    SCI_TX_PEEK - This function returns the number of bytes left in the      #
;#                  transmit queue.                                            #
;#    SCI_TX_WAIT - This function waits until all characters in the TX buffer  #
;#                  have been transmitted.                                     #
;#    SCI_RX      - This function reads a byte (and associated error flags)    #
;#                  from the serial interface. This function will block the    #
;#                  program flow until data is available.                      #
;#    SCI_RX_PEEK - This function reads the oldest buffer entry and the number #
;#                  RX buffer entries, without modifying the buffer.           #
;#                  program flow until data is available.                      #
;#    SCI_RX_DROP - This function removes the oldest buffer entry.             #
;#    SCI_RX_BLK  - This function stops the incomming data stream.             #
;#    SCI_RX_UBLK - This function enables the incomming data stream.           #
;#    SCI_BAUD    - This function allows the application to set the SCI's baud #
;#                  rate manually.                                             #
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
;#    February 22, 2012                                                        #
;#      - Back-ported LFBDMPGMR updates                                        #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Baud rate devider settings
; SCIBD = 24.576MHz / (16*baud rate)

SCI_1200        	EQU	1280
SCI_2400        	EQU	 640
SCI_4800        	EQU	 320
SCI_7200        	EQU	 213
SCI_9600        	EQU	 160
SCI_14400       	EQU	 107
SCI_19200       	EQU	  80
SCI_28800       	EQU	  53
SCI_38400       	EQU	  40
SCI_57600       	EQU	  27
SCI_76800       	EQU	  20
SCI_115200		EQU	  13
SCI_153600		EQU	  10
SCI_BDEF		EQU	SCI_9600 	;default baud rate
SCI_BMUL		EQU	 $CB	 	;Multiplicator for storing the baud rate
	
;#Transmission format
SCI_FORMAT		EQU	ILT		;8N1

;#Buffer sizes
SCI_RXBUF_SIZE		EQU	 16*2		;size of the receive buffer (8 error:data entries)
SCI_TXBUF_SIZE		EQU	  8		;size of the transmit buffer
SCI_RXBUF_MASK		EQU	$1F		;mask for rolling over the RX buffer
SCI_TXBUF_MASK		EQU	$07		;mask for rolling over the TX buffer

;#Hardware handshake borders
SCI_CTS_FULL		EQU	11*2		;Boundary to clear CTS
SCI_CTS_FREE		EQU	 8*2		;Boundary to set CTS
	
;#Flag definitions
SCI_FLG_SWOR		EQU	$10		;software buffer overrun (RX buffer)
;SCI_FLG_FCRX		EQU	$08		;don't receive (state of the serial interface)
SCI_FLG_FCRX_FC		EQU	$04		;request to stop incomming data (forced flow control)
SCI_FLG_FCRX_BF		EQU	$02		;request to stop incomming data (buffer overflow)
;SCI_FLG_FCTX		EQU	$01		;don't transmit (XOFF received)

;#CTS state
SCI_CTS_SET		EQU	$00		;CTS (PM1) is set     -> incomming data allowed
SCI_CTS_CLEARED		EQU	$02		;CTS (PM1) is cleared -> incomming data forbidden
			
;#Timer channels	
SCI_TIMCH		EQU	$03		;timer channels assigned to the SCI:
                                        	; IC0: SCI (capture posedges on RX pin)
                                        	; IC1: SCI (capture negedges on RX pin)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	SCI_VARS_START
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
;#Flags			
SCI_FLGS		DS	1
;#Baud rate detection registers
SCI_BDLST		DS	1		;list of potential baud rates
			
SCI_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SCI_INIT, 0
			;Initialize queues and state flags	
			LDD	#$0000
			STD	SCI_TXBUF_IN 				;reset in and out pointer of the TX buffer
			STD	SCI_RXBUF_IN 				;reset in and out pointer of the RX buffer
			STAA	SCI_FLGS 				;reset status flags
			STAA	SCI_BDLST				;reset baud rate detection
			
			;Check for POR 
			LDAB	CLOCK_FLGS
			BITA	#(PORF|LVRF)
			BNE	SCI_INIT_2
	
			;Check if stored baud rate is still valid
			LDD	SCI_BVAL 	;SCI_BMUL*baud rate -> D
			BEQ	SCI_INIT_2	;use default value if zero
			LDX	#SCI_BMUL	;SCI_BMUL -> X
			IDIV			;D/X -> X, D%X -> D
			CPD	#$0000		;check if the remainder is 0
			BNE	SCI_INIT_2	;stored baud rate is invalid
			LDY	#SCI_BTAB	;start of baud table -> Y
SCI_INIT_1		CPX     2,Y+		;compare table entry with X	
			BEQ	SCI_INIT_3	;match
			CPY	#SCI_BTAB_END	;check if the end of the table has been reached
			BNE	SCI_INIT_1	;loop
			;No match use default
SCI_INIT_2		LDX	#SCI_BDEF	 ;default baud rate
			MOVW	#(SCI_BDEF*SCI_BMUL), SCI_BVAL
			;Match 
SCI_INIT_3		STX	SCIBDH		;set baud rate
			
			;Set format and enable RX interrupts 
			MOVW	#((SCI_FORMAT<<8)|RIE|TE|RE), SCICR1
			
			;Set CTS signal
			SCI_SET_CTS
#emac

;#Transmit one byte (convinience macro to call the SCI_TX subroutine)
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX, 0
			SSTACK_JOBSR	SCI_TX
#emac

;#Peek into the TX queue and check how much space is left
; args:   none
; result: A: number of entries left in TX queue
; SSTACK: 3 bytes
;         X, Y, and B are preserved 
#macro	SCI_TX_PEEK, 0
			SSTACK_JOBSR	SCI_TX_PEEK
#emac
	
;#Wait until the TX buffer is empty (convinience macro to call the SCI_TBE subroutine)
; args:   none
; result: none
; SSTACK: 4 bytes
;         X, Y, and D are preserved 
#macro	SCI_TX_WAIT, 0
			SSTACK_JOBSR	SCI_TX_WAIT
#emac
	
;#Receive one byte (convinience macro to call the SCI_RX subroutine)
; args:   none
; result: A: error flags 
;         B: received data 
; SSTACK: 6 bytes
;         X and Y are preserved 
#macro	SCI_RX, 0
			SSTACK_JOBSR	SCI_RX
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
	
;#Set baud rate (convinience macro to call the SCI_BAUD subroutine)
; args:   D: new SCIBD value
; result: none
; SSTACK: 14 bytes
;         X, Y, and D are preserved 
#macro	SCI_SET_BAUD, 0
			SSTACK_JOBSR	SCI_SET_BAUD
#emac

;#Block interrupts and avoid RX overflows (convinience macro to call the SCI_BAUD subroutine)
#macro	SCI_SEI, 0
			SCI_CLR_CTS
			SEI
#emac

;#Enable interrupts (convinience macro to call the SCI_BAUD subroutine)
; args:   none
; result: none
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_CLI, 0
			CLI
			SCI_CLR_CTS
#emac
	
;Set CTS signal -> allow incomming data ("Clear To Send")
#macro	SCI_SET_CTS, 0
			BCLR	SCI_FLGS, SCI_FLG_FCRX_FC
			BRSET	SCI_FLGS, SCI_FLG_FCRX_BF, DONE
			MOVB	#SCI_CTS_CLEARED, PTM
DONE			EQU	*
#emac

;Clear CTS signal -> forbid incomming data ("Clear To Send")
#macro	SCI_CLR_CTS, 0
			BSET	SCI_FLGS, SCI_FLG_FCRX_FC
			MOVB	#SCI_CTS_CLEARED, PTM
#emac

;Branch if RTS is cleared ("Ready To Send")
#macro	SCI_BRNORTS, 1
			BRSET	PTIM, #$01, \1
#emac
	
;Stop baud rate detection
#macro	SCI_STOP_BD, 0
			BRCLR	SCI_BDLST, #$FF, DONE			;baud rate detection already inactive
			BCLR	TIE, #(C1I|C0I)				;disable interrupts
			TIM_DISABLE TIM_SCI				;disable timer
			CLR	SCI_BDLST				;reset status flags
			LED_COMERR_OFF					;stop signaling communication errors
DONE			EQU	*
#emac

;Clear wait flags
#macro	SCI_CLR_WAIT_FLGS, 0
			BCLR	SCI_FLGS, #(SCI_FLG_WAITRX|SCI_FLG_WAITTX|SCI_FLG_WAITTBE)
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	SCI_CODE_START
;#Transmit one byte (this function will block until it is able to queue one byte of data)
; args:   B: data to be send
; result: none
; SSTACK: 16 bytes
;         X, Y, and D are preserved 
SCI_TX			EQU	*
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
			BEQ	SCI_TX_2 				;buffer is full (wait loop implementation)
			;Update buffer
SCI_TX_1		STAA	SCI_TXBUF_IN
			;Enable interrupts 
			;BSET	SCICR2, #TXIE
			MOVB	#(TXIE|RIE|TE|RE), SCICR2
			CLI
			;Restore registers
			SSTACK_PULAY					;pull A and Y from the SSTACK
			;Done
			RTS
			;Wait loop (data in B, new in-index in A)
SCI_TX_2		SEI
			CMPA	SCI_TXBUF_OUT
			BNE	SCI_TX_1				;leave wait loop
			ISTACK_WAIT					;wait until any interrupt occurs
			JOB	SCI_TX_2				;try again
	
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
			LDD	SCI_RXBUF_IN
			CBA		 		
			BEQ	SCI_RX_3 				;RX buffer is empty
			;Pull entry from the RX queue (in-index in A, out-index in B)
SCI_RX_1		CLI						;unblock interrupts
			LDY	#SCI_RXBUF
			LDX	B,Y
			ADDB	#$02					;increment out pointer
			ANDB	#SCI_RXBUF_MASK
			STAB	SCI_RXBUF_OUT
			;CTS handshake  (in-index in A, new out-index in B, RX data in X)
			SBA
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_CTS_FREE
			BHS	SCI_RX_2 				;buffer still to full
			BCLR	SCI_FLGS, #SCI_FLG_FCRX_BF		;unlock CTS
			BRSER	SCI_FLGS, #SCI_FLG_FCRX_FC, SCI_RX_2
			CLR	PTM
			;Return result (RX data in X)
SCI_RX_2		TFR X, D					;set return value
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
			CMPA	#SCI_CTS_FREE
			BHS	SCI_RX_DROP_1 				;buffer still to full
			;CLR	SCI_CTS_STATE				;signal "Clear To Send"
			CLR	PTM
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
	
;#Transmit handler (status flags in A)
SCI_ISR_TX		EQU	*
			;Check if SCI is ready to transmit data (status flags in A)
			BITA	#TDRE					;check if SCI is ready for new TX data
			BEQ	<SCI_ISR_TX_2				;done for now

			;Check TX flow control
			SCI_BRNORTS SCI_ISR_TX_2 			;done if RTS is not set
				
			;Check TX buffer
			LDD	SCI_TXBUF_IN
			CBA
			BEQ	<SCI_ISR_TX_1 				;disable transmission
			;Transmit data (in-index in A, out-index in B)
			LDY	#SCI_TXBUF
			MOVB	B,Y ,SCIDRL
			;Increment index
			INCB
			ANDB	#SCI_TXBUF_MASK
			STAB	SCI_TXBUF_OUT
			CBA
			BNE	<SCI_ISR_TX_2 				;done

			;Disable transmission
SCI_ISR_TX_1		MOVB	#(RIE|TE|RE), SCICR2			;disable transmission complete interrupt
	
			;Done
SCI_ISR_TX_2		ISTACK_RTI

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
			BITA	#(RDRF|OR) 				;go to receive handler if receive buffer
			BEQ	SCI_ISR_TX				; is full or if an overrun has occured

;#Receive handler (status flags in A)
SCI_ISR_RX		LDAB	SCIDRL					;load receive data into accu B (clears flags)
			;Check for RX errors (status flags in A, RX data in B)
			BITA	#(NF|FE|PF) 				;check for: noise, frame errors, parity errors
			BNE	<SCI_ISR_RX_4				;check if baud rate detection is running

			;Transfer SWOR flag to current error flags (status flags in A, RX data in B)
SCI_ISR_RX_1		ANDA	#(OR|NF|FE|PF)				;only maintain relevant error flags
			BRCLR	SCI_FLGS, #SCI_FLG_SWOR, SCI_ISR_RX_2	;SWOR bit not set
			ORAA	#SCI_FLG_SWOR				;set SWOR bit in accu A
			BCLR	SCI_FLGS, #SCI_FLG_SWOR 		;clear SWOR bit in variable	

			;Place data into RX queue (status flags in A, RX data in B) 
SCI_ISR_RX_2		TFR	D, Y					;flags:data -> Y
			LDX	#SCI_RXBUF
			LDD	SCI_RXBUF_IN				;in:out -> A:B
			STY	A,X
			ADDA	#2
			ANDA	#SCI_RXBUF_MASK		
			CBA
                	BEQ	<SCI_ISR_RX_5				;buffer is full
			STAA	SCI_RXBUF_IN				;update IN pointer
			;Check for CTS threshold (in:out in D, flags:data in Y) 
			SBA
			ANDA	#SCI_RXBUF_MASK
			CMPA	#SCI_CTS_FULL
			BHS	<SCI_ISR_RX_6 				;don't signal CTS

			;Done
SCI_ISR_RX_3		ISTACK_RTI			

			;Run baud rate detection (status flags in A, RX data in B)
SCI_ISR_RX_4		TST	SCI_BDLST 				;check if baud rate detection is running
			BNE	<SCI_ISR_RX_1 				;transfer SWOR flag
			;Initiate baud rate detection
			LED_COMERR_ON				        ;signal communication error
			MOVB	#$FF, SCI_BDLST				;reset BD result registers
			TIM_ENABLE TIM_SCI		     		;enable timer
			MOVW	#(((C1F|C0F)<<8)|TOF), TFLG1		;clear interrupt flags
			BSET	TCTL4, #$09 				;enable edge detection (IC1: negedge, IC0: posedge)
			;BSET	TIE, #(C1I|C0I)				;enable IC0 und IC1 IRQ
			BSET	TIE, #C0I				;enable IC0 IRQ (expect low pulse first) 
			JOB	SCI_ISR_RX_1 				;transfer SWOR flag

			;Buffer is full (flags:data in Y)
SCI_ISR_RX_5		BSET	SCI_FLGS, #SCI_FLG_SWOR

			;Clear CTS (flags:data in Y)
SCI_ISR_RX_6		BSET	SCI_FLGS, #
			SCI_CLR_CTS	
			JOB	SCI_ISR_RX_3 				;done
				
;#Edge on RX pin captured 
SCI_ISR_TC0		EQU	*
SCI_ISR_TC1		EQU	*
			;Check if both edges have been captured
			BCLR	TIE, #(C1I|C0I)				;clear interrupt enables
			LDAA	TFLG1
			BITA	#C0F
			<BEQ	SCI_ISR_TC0_6 				;posedge not captured
			BITA	#C1F
			<BEQ	SCI_ISR_TC0_7 				;posedge captured, but not negedge
			
			;Determine tne pulse polarity
			BCLR	TCTL4, #$0F 				;disable edge detection
			BRSET	TFLG2, #TOF, SCI_ISR_TC0_9		;ignore pulse if timer overflow occured	
			LDD	TC0					;capture posedge time
			CPD	TC1 					;check if the posedge came before the negedge 
			BLO	<SCI_ISR_TC0_10 			;high pulse detected
			BEQ	<SCI_ISR_TC0_9				;ignore zero length pulses
	
			;Low pulse detected (posedge time in D)
			SUBD	TC1	 				;calculate pulse length
			LDY	#SCI_LT0				;select look-up table
			MOVW	#((C1F<<8)|TOF), TFLG1			;invalidate negedge
			BSET	TIE, #C1I 				;enable negedge interrupt			
	
			;Enable edge detection (pulse length in D, search tree pointer in Y)			
SCI_ISR_TC0_1		BSET	TCTL4, #$09 				;enable edge detection (IC1: negedge, IC0: posedge)

			;Check if baud rate detection is still enabled (pulse length in D, search tree pointer in Y)
			BRCLR	SCI_BDLST, #$FF, SCI_ISR_TC0_13 	;baud rate detection disabled	
	
			;Parse a search tree (pulse length in D, search tree pointer in Y) 
			LDX	#$0000					;use index X to store valid baud rates
SCI_ISR_TC0_2		TST	0,Y	     				;check if lower boundary exists
			BEQ	SCI_ISR_TC0_3				;search done
			CPD	6,Y+					;check if pulse length is shorter than lower boundary
			BLO	SCI_ISR_TC0_2				;pulse length is shorter than lower boundary
									; -> try a shorter range
			LDX	-4,Y					;pulse length is longer or same as lower boundary
									; -> store valid baud rate field in index X
			LDY	-2,Y					; -> parse a new branch of the search tree that contains longer ranges
			BNE	SCI_ISR_TC0_2				;parse branch if it exists			

			;Search is done (valid baud rates in X) 
SCI_ISR_TC0_3		EXG	X, D	 				;apply search result to the set of valid baud rates
			ANDA	SCI_BDLST
			BEQ	SCI_ISR_TC0_11				;no valid baud rate found, start all over
			STAA	SCI_BDLST 				;save valid Baud rates				
			;Check if baud rate has been determined (valid baud rates in A)
			TAB						;save baude rates in accu B
			LDX	#$FFFE					;use index X as index counter
SCI_ISR_TC0_4		LEAX	2,X					;increment index counter
			LSRA						;check if only one bit is set in accu A
			BCC	SCI_ISR_TC0_4				;shift until a "1" ends up in the carry bit
			BEQ	SCI_ISR_TC0_12				;baud rate has been determined
	
			;Baud rate has not been determined yet (valid baud rates in accu B)
SCI_ISR_TC0_5		ISTACK_RTI					;wait for the next pulse			

			;No posedge captured (TFLG1 in A) 
SCI_ISR_TC0_6		BITA	#C1F
			<BEQ	SCI_ISR_TC0_8 				;no edge captured
			BSET	TIE, #C0F
			JOB	SCI_ISR_TC0_5
			;Posedge captured, but no negedge
SCI_ISR_TC0_7		BSET	TIE, #C1F
			JOB	SCI_ISR_TC0_5
			;No edge captured
SCI_ISR_TC0_8		BSET	TIE, #(C1F|C0F)
			JOB	SCI_ISR_TC0_5

			;Ignore pulse 
SCI_ISR_TC0_9		BSET	TCTL4, #$09 				;enable edge detection (IC1: negedge, IC0: posedge)
			MOVW	#(((C1I|C0I)<<8)|TOF), TFLG1		;invalidate both edges gedge
			BSET	TIE, #(C1F|C0F)
			JOB	SCI_ISR_TC0_5
	
			;High pulse detected
SCI_ISR_TC0_10		LDD	TC1	 				;calculate pulse length
			SUBD	TC0
			LDY	#SCI_HT0				;select look-up table
			MOVW	#((C0F<<8)|TOF), TFLG1			;invalidate posedge
			BSET	TIE, #C0I 				;enable posedge interrupt			
			JOB	SCI_ISR_TC0_1 				;enable edge detection
				
			;No valid baud rate found, start all over
SCI_ISR_TC0_11		MOVB	#$FF, SCI_BDLST
			JOB	SCI_ISR_TC0_5				;done			

			;Baud rate has been validated (index of baud rate table in index X)
SCI_ISR_TC0_12		LDD	SCI_BTAB,X				;look up divider value
			STD	SCIBDH					;set baud rate
			LDY	#SCI_BMUL				;save baud rate for next warmstart
			EMUL						;D*Y -> Y:D
			STD	SCI_BVAL	

			;Disable monitoring of the RX pin 
SCI_ISR_TC0_13		BCLR	TIE, #(C1I|C0I) 			;disable interrupts
			TIM_DISABLE TIM_SCI		     		;disable timer	
			BCLR	TCTL4, #$0F				;disable edge detection (workaround for erratum MUCts04104)
			CLR	SCI_BDLST 				;clear baud rate result register
			LED_COMERR_OFF					;stop signaling communication errors
			JOB	SCI_ISR_TC0_5				;done
	
SCI_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	SCI_TABS_START
;Baud rate table
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

;Baud rate search tree
#include	sci_bdtab.s	

SCI_TABS_END		EQU	*
