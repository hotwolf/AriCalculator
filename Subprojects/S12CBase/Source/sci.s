;###############################################################################
;# S12CBase - SCI - Serial Communication Interface Driver                      #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    This modules provides two functions to the main program:                 #
;#    SCI_TX   - This function sends a byte over the serial interface. This    #
;#               function will block the program flow until the data can be    #
;#               handed over to the transmit queue.                            #
;#    SCI_TBE  - This function waits until all characters in the TX buffer     #
;#               have been transmitted.                                        #
;#    SCI_RX   - This function reads a byte (and associated error flags) from  #
;#               the serial interface. This function will block the program    #
;#               flow until data is available.                                 #
;#    SCI_BAUD - This function allows the application to set the SCI's baud    #
;#               rate manually.                                                #
;#                                                                             #
;#    For convinience, these functions may also be called via the macros:      #
;#    SCI_TX     - Calls SCI_TX.                                               #
;#    SCI_TBE    - Calls SCI_TBE.                                              #
;#    SCI_RX     - Calls SCI_RX.                                               #
;#    SCI_BAUD   - Calls SCI_BAUD.                                             #
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
;#                                                                             #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Baud rate devider settings
; SCIBD = 24.576MHz / (16*baud rate)

SCI_1200        EQU	1280
SCI_2400        EQU	 640
SCI_4800        EQU	 320
SCI_7200        EQU	 213
SCI_9600        EQU	 160
SCI_14400       EQU	 107
SCI_19200       EQU	  80
SCI_28800       EQU	  53
SCI_38400       EQU	  40
SCI_57600       EQU	  27
SCI_76800       EQU	  20
SCI_115200	EQU	  13
SCI_153600	EQU	  10
SCI_BDEF	EQU	SCI_9600 	;default baud rate
SCI_BMUL	EQU	 $CB	 	;Multiplicator for storing the baud rate
	
;#Transmission format
SCI_FORMAT	EQU	ILT		;8N1

;#Buffer sizes
SCI_RXBUF_SIZE	EQU	 16*2		;size of the receive buffer (8 error:data entries)
SCI_TXBUF_SIZE	EQU	  8		;size of the transmit buffer
SCI_RXBUF_MASK	EQU	$1F		;mask for rolling over the RX buffer
SCI_TXBUF_MASK	EQU	$07		;mask for rolling over the TX buffer

;#Hardware handshake borders
SCI_CTS_FULL	EQU	14*2		;Boundary to clear CTS
SCI_CTS_FREE	EQU	 8*2		;Boundary to set CTS
	
;#Flag definitions
SCI_FLG_BDCNT	EQU	$70		;down counter for baud rate detection runs (0=BD disabled)
SCI_FLG_BDIGN	EQU	$10		;Ignore next capture value
SCI_FLG_SWOR	EQU	$08		;software buffer overrun (RX buffer)
SCI_FLG_WAITRX	EQU	$04		;waiting for receive data
SCI_FLG_WAITTX	EQU	$02		;waiting until data can be placed into 
SCI_FLG_WAITTBE	EQU	$01		;waiting until data can be placed intTX buffer is empty 
	
;#Timer channels
SCI_TIMCH	EQU	$07		;timer channels assigned to the SCI:
                                        ; IC0: SCI (capture posedges on RX pin)
                                        ; IC1: SCI (capture negedges on RX pin)
                                        ; OC2: SCI (timeout)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
		ORG 	SCI_VARS_START
;#Receive buffer
SCI_RXBUF	DS	SCI_RXBUF_SIZE
SCI_RXBUF_IN	DS	1
SCI_RXBUF_OUT	DS	1
;#Transmit buffer
SCI_TXBUF	DS	SCI_TXBUF_SIZE
SCI_TXBUF_IN	DS	1			;points to the next free space
SCI_TXBUF_OUT	DS	1			;points to the oldest entry
;#Baud rate (reset proof) 
SCI_BVAL	DS	2			;value of the SCIBD register *SCI_BMUL
;#Flags
SCI_FLGS	DS	1
;#Baud rate detection registers
SCI_BDLST	DS	1			;list of potential baud rates

SCI_VARS_END	EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SCI_INIT, 0
		;Initialize queues and state flags	
		LDD	#$0000
		STD	SCI_TXBUF_IN 		;reset in and out pointer of the TX buffer
		STD	SCI_RXBUF_IN 		;reset in and out pointer of the RX buffer
		STAA	SCI_FLGS 		;reset status flags
	
		;Check if stored baud rate is still valid
		LDD	SCI_BVAL 		;SCI_BMUL*baud rate -> D
		BEQ	SCI_INIT_2		;use default value if zero
		LDX	#SCI_BMUL		;SCI_BMUL -> X
		IDIV				;D/X -> X, D%X -> D
		CPD	#$0000			;check if the remainder is 0
		BNE	SCI_INIT_2		;stored baud rate is invalid
		LDY	#SCI_BTAB		;start of baud table -> Y
SCI_INIT_1	CPX     2,Y+			;compare table entry with X	
		BEQ	SCI_INIT_3		;match
		CPY	#SCI_BTAB_END		;check if the end of the table has been reached
		BNE	SCI_INIT_1		;loop
		;No match use default
SCI_INIT_2	LDX	#SCI_BDEF	 	;default baud rate
		MOVW	#(SCI_BDEF*SCI_BMUL), SCI_BVAL
		;Match 
SCI_INIT_3	STX	SCIBDH			;set baud rate

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

;#Wait until the TX buffer is empty (convinience macro to call the SCI_TBE subroutine)
; args:    none
; SSTACK:  bytes
;         X, Y, and D are preserved 
#macro	SCI_TBE, 0
		SSTACK_JOBSR	SCI_TBE
#emac
	
;#Receive one byte (convinience macro to call the SCI_RX subroutine)
; result: A: error flags 
;         B: received data 
; SSTACK: 6 bytes
;         X and Y are preserved 
#macro	SCI_RX, 0
		SSTACK_JOBSR	SCI_RX
#emac

;#Set baud rate (convinience macro to call the SCI_BAUD subroutine)
; result: D: new SCIBD value
; SSTACK: bytes
;         X, Y, and D are preserved 
#macro	SCI_BAUD, 0
		SSTACK_JOBSR	SCI_BAUD
#emac
		
;Set CTS signal ("Clear To Send")
#macro	SCI_SET_CTS, 0
		CLR	PTM
#emac

;Clear CTS signal ("Clear To Send")
#macro	SCI_CLR_CTS, 0
		MOVB	#$02, PTM
#emac

;Branch if RTS is cleared ("Ready To Send")
#macro	SCI_BRNORTS, 1
		BRSET	PTIM, #$01, \1
#emac
	
;Stop baud rate detection
#macro	SCI_STOP_BD, 0
		BRCLR	SCI_FLGS, #SCI_FLG_BDCNT, DONE	;baud rate detection already inactive
		BCLR	TIE, #SCI_TIMCH			;disable interrupts
		TIM_DISABLE TIM_SCI			;disable timer
		BCLR	SCI_FLGS, #(SCI_FLG_BDCNT|SCI_FLG_BDIGN);reset status flags
		LED_COMERR_OFF				;stop signaling communication errors
DONE		EQU	*
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
		ORG	SCI_CODE_START
;#Transmit one byte (this function will block until it is able to queue one byte of data)
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
SCI_TX		EQU	*
		SSTACK_PSHYXD			;push all registers onto the SSTACK
SCI_TX_1	SEI				;block interrupts

		;Check RTS signal 
		SCI_BRNORTS	SCI_TX_3	;not ready for transmission
	
		;Check if TX register is empty
		LDAA	SCISR1			;load status flags into accu A
						;SCI Flag order:				 
						; 7:TDRE (Transmit Data Register Empty Flag)
						; 6:TC   (TransmitCompleteFlag)
						; 5:RDRF (Receive Data Register Full Flag)
						; 4:IDLE (Idle Line Flag)
						; 3:OR   (Overrun Flag)
						; 2:NF   (Noise Flag)
						; 1:FE   (Framing Error Flag)
						; 0:PE	 (Parity Error Flag)
		BPL	SCI_TX_3		;TX is ongoing

		;TX register is empty -> TX data
		STAB	SCIDRL			;TX data

		;End subroutine
SCI_TX_2	CLI				;unblock interrupts
		COP_SERVICE			;service COP
		SSTACK_PULDXY			;restore all registers
		SSTACK_RTS			;return

		;Write TX data into the buffer
SCI_TX_3	LDY	#SCI_TXBUF	 	;copy data into TX buffer
		LDAA	SCI_TXBUF_IN
		STAB	A,Y

		;Check if there is still room for one entry
		INCA				;increment index
		ANDA	#SCI_TXBUF_MASK
		CMPA	SCI_TXBUF_OUT
		BEQ	SCI_TX_4 		;buffer is full

		;Update index
		STAA	SCI_TXBUF_IN

		;Setup interrupts 
		;BSET	SCICR2, #TXIE
		MOVB	#(TXIE|RIE|TE|RE), SCICR2
	
		;End subroutine 
		JOB	SCI_TX_2

		;Wait until TX data can be buffered
SCI_TX_4	BSET	SCI_FLGS, #SCI_FLG_WAITTX ;remember that the main program is waiting
		ISTACK_RTI			  ;drop down one run level
	
;#Wait until the TX buffer is empty (this function will block until the current transmission is complete)
; args:    none
; SSTACK:  8 bytes
;         X, Y, and D are preserved 
SCI_TBE		EQU	*
		SSTACK_PSHYXD			;push all registers onto the SSTACK
		SEI				;block interrupts
	
		;Check if TX buffer is empty
		LDD	SCI_TXBUF_IN		;compare in and out pointer
		CBA
		BNE	SCI_TBE_1		;buffer is not empty

		;TX buffer is empty
		SSTACK_PULDXY			;restore all registers
		SSTACK_RTS			;return

		;Wait until TX data can be buffered
SCI_TBE_1	BSET	SCI_FLGS, #SCI_FLG_WAITTBE;remember that the main program is waiting
		ISTACK_RTI			  ;drop down one run level
		
;#Receive one byte (this function will block until it is able to obtain one byte of data)
; result: A: error flags 
;         B: received data 
; SSTACK: 6 bytes
;         X and Y are preserved 
SCI_RX		EQU	*
		SSTACK_PSHYX			;push index registers onto the SSTACK
		SEI				;block interrupts
			
		;Check if RX data is available 
		LDD	SCI_RXBUF_IN
		CBA
		BEQ	SCI_RX_2 		;buffer is empty

		;Read one RX data entry
		LDY	#SCI_RXBUF
		LDX	B,Y

		;Increment out pointer
		ADDB	#$02
		ANDB	#SCI_RXBUF_MASK
		STAB	SCI_RXBUF_OUT
	
		;CTS handshake
		SBA
		ANDA	#SCI_RXBUF_MASK
		LDAB	#SCI_CTS_FREE
		CBA
		BHS	SCI_RX_1 		;buffer still to full
		SCI_SET_CTS			;signal "Clear To Send"

		;End subroutine
SCI_RX_1	CLI				;unblock interrupts
		COP_SERVICE			;service COP
		TFR X, D			;set return value
		SSTACK_PULXY			;pull index registers from the SSTACK
		SSTACK_RTS

		;RX buffer is empty
SCI_RX_2	BSET	SCI_FLGS, #SCI_FLG_WAITRX
		ISTACK_RTI

;#Set baud rate (this function will block until the current transmission is complete)
; result: D: new SCIBD value
; SSTACK: 14 bytes
;         X, Y, and D are preserved 
SCI_BAUD	EQU	*
		SSTACK_PSHYD			;push all registers onto the SSTACK

		;Finish current transmission
		SCI_TBE				;(SSTACK: 8 bytes) 

		;Disable baud rate detection
		SCI_STOP_BD			;stop baud rate detection
	
		;Set baud rate 
		STD	SCIBDH			;set baud rate
		LDY	#SCI_BMUL		;save baud rate for next warmstart
		EMUL				;D*Y -> Y:D
		STD	SCI_BVAL

		;End subroutine
		SSTACK_PULDY			;restore all registers
		SSTACK_RTS			;return
	
;#Transmit handler (status flags in accu A)
SCI_ISR_TX	EQU	*
		BITA	#TDRE			;check if SCI is ready for new TX data
		BEQ	SCI_ISR_TX_1		;nothing to do

		;Check TX buffer
		LDD	SCI_TXBUF_IN
		CBA
		BEQ	SCI_ISR_TX_2 		;TX buffer is empty

		;Check RTS signal
		SCI_BRNORTS SCI_ISR_TX_1 	;receiver is not ready

		;Transmit data
		LDY	#SCI_TXBUF
		MOVB	B,Y ,SCIDRL
	
		;Increment index
		INCB
		ANDB	#SCI_TXBUF_MASK
		STAB	SCI_TXBUF_OUT
		CBA
		BEQ	SCI_ISR_TX_2 		;TX Buffer is empty

		;Check if TX callback is ready
		BRSET	SCI_FLGS, #SCI_FLG_WAITTX, SCI_ISR_TX_3

		;Done
SCI_ISR_TX_1	ISTACK_RTI

		;TX buffer is empty
SCI_ISR_TX_2	;BCLR	SCICR2, #TXIE	;disable TX interrupts
		MOVB	#(RIE|TE|RE), SCICR2

		;Check if main program is waiting for TBE
		BRSET	SCI_FLGS, #SCI_FLG_WAITTBE, SCI_ISR_TX_4
		ISTACK_RTI

		;Run TX callback
SCI_ISR_TX_3	BCLR	SCI_FLGS, #(SCI_FLG_WAITRX|SCI_FLG_WAITTX)
		CLI
		;SSTACK_PULDXY			;restore all registers
	        ;JOB	SCI_TX			;rerun TX subroutine
		LDX	SSTACK_SP		;restore accu B
		LDAB	1,X
	        JOB	SCI_TX_1		;rerun TX subroutine
					
		;Resume program execution after the SCI_TBE call		
SCI_ISR_TX_4	BCLR	SCI_FLGS, #SCI_FLG_WAITTBE ;clear wait flag
		CLI				;Enable interrupts
		SSTACK_PULDXY			;restore all registers
		SSTACK_RTS			;return

;#Transmit/Receive ISR (Common ISR entry point for the SCI)
SCI_ISR_RXTX	EQU	*
		;Common entry point for all SCI interrupts
		;Load flags
		LDAA	SCISR1			;load status flags into accu A
						;SCI Flag order:				 
						; 7:TDRE (Transmit Data Register Empty Flag)
						; 6:TC   (TransmitCompleteFlag)
						; 5:RDRF (Receive Data Register Full Flag)
						; 4:IDLE (Idle Line Flag)
						; 3:OR   (Overrun Flag)
						; 2:NF   (Noise Flag)
						; 1:FE   (Framing Error Flag)
						; 0:PE	 (Parity Error Flag)
	
		;Check for RX data
		BITA	#(RDRF|OR) 		;go to receive handler if receive buffer
		BEQ	SCI_ISR_TX		; is full or if an overrun has occured

;#Receive handler (status flags in accu A)
SCI_ISR_RX	LDAB	SCIDRL			;load receive data into accu B (clears flags)
	
		;Initiate baud rate detection in case of an RX error
		BITA	#(NF|FE|PE) 		;check for: noise, frame errors, parity errors
		BNE	SCI_ISR_RX_7		;start baud rate detection
		SCI_STOP_BD			;stop baud rate detection
	
		;Transfer SWOR flag to current error flags
SCI_ISR_RX_1	BRSET	SCI_FLGS, #SCI_FLG_SWOR, SCI_ISR_RX_8 ;move SWOR bit

		;Only maintain relevant error flags
SCI_ISR_RX_2	ANDA	#(SCI_FLG_SWOR|OR|NF|FE|PE)
	
		;Check if the main program is waiting for read data
		BRSET	SCI_FLGS, #SCI_FLG_WAITRX, SCI_ISR_RX_9 ;Retrun data

		;Check if invalid data must be stored (first entry in buffer or previous entry was valid)
		BITA	#(NF|FE|PE) 		;check for invalid data: frame errors, parity errors
		BNE	SCI_ISR_RX_6		;queue invalid data
		
		;Queue RX data (status flags in accu A, data in accu B)
SCI_ISR_RX_3	TFR	D, X	     		;store accu A and B into the field indicated by
		LDD	SCI_RXBUF_IN		; the IN pointer				
SCI_ISR_RX_4	LDY	#SCI_RXBUF
		STX	A,Y

		;Increment IN pointer
		ADDA	#$02
		ANDA	#SCI_RXBUF_MASK

		;Check for buffer overflow
		CBA
		BEQ	SCI_ISR_RX_10		;Handle buffer overflow

		;Update IN pointer
		STAA	SCI_RXBUF_IN

		;Update CTS handshake signal
		SBA
		ANDA	#SCI_RXBUF_MASK
		LDAB	#SCI_CTS_FULL
		CBA
		BHS	SCI_ISR_RX_11		;release CTS

SCI_ISR_RX_5	ISTACK_RTI

		;Check if invalid data must be queued, because queue is empty
SCI_ISR_RX_6	TFR	D, X					;check if queue is empty
		LDD	SCI_RXBUF_IN				; -> invalid entry must be made
		CBA				
		BEQ	SCI_ISR_RX_4 				;queue is empty

		;Check if invalid data must be queued, because previous entry was valid
		LDY	#SCI_RXBUF				;check if previous entry was already invalid
		SUBA	#2					; -> update flags in that entry
		ANDA	#SCI_RXBUF_MASK
		LEAY	A,Y
		ADDA	#2
		ANDA	#SCI_RXBUF_MASK
		BRCLR	0,Y, #(NF|FE|PE), SCI_ISR_RX_4 		;previous entry was valid

		;Update flags of previously invalid entry
		TFR	X, D					;add current error flags to previous entry
		ORAA	0,Y			
		STAA	0,Y
		ISTACK_RTI

		;Check if baud rate detection is already active
SCI_ISR_RX_7	BRCLR	SCI_FLGS, #SCI_FLG_BDCNT, SCI_ISR_RX_12	;start baud rate detection
		JOB	SCI_ISR_RX_1

		;Transfer SWOR flag to current error flags
SCI_ISR_RX_8	BCLR	SCI_FLGS, #SCI_FLG_SWOR 		;clear SWOR bit in variable
		ORAA	#SCI_FLG_SWOR				;set SWOR bit in accu A
		JOB	SCI_ISR_RX_2

		;Return data to main program (status flags in accu A, data in accu B)
SCI_ISR_RX_9	BCLR	SCI_FLGS, #SCI_FLG_WAITRX 		;clear wait flag
		CLI						;Enable interrupts
		SSTACK_PULXY					;pull index registers from the SSTACK
		SSTACK_RTS

		;Handle buffer overflow
SCI_ISR_RX_10	BSET	SCI_FLGS, #SCI_FLG_SWOR			;set SWOR flag
		ISTACK_RTI

		;Release CTS
SCI_ISR_RX_11	SCI_CLR_CTS
		ISTACK_RTI
	
		;Initiate baud rate detection
SCI_ISR_RX_12	LED_COMERR_ON				        ;signal communication error
		BSET	SCI_FLGS, #(SCI_FLG_BDCNT|SCI_FLG_BDIGN);reset BD counter and ignore first pulse
		MOVB	#$FF, SCI_BDLST				;reset BD result registers	
		TIM_ENABLE TIM_SCI		     		;enable timer
		BSET	TIE, #SCI_TIMCH		     		;enable interrupts
		MOVW	TCNT, TC2				;set timeout
		LDX	TC0					;clear IC interrupt flag
		LDX	TC1					;clear IC interrupt flag
		JOB	SCI_ISR_RX_2
		
;#Negedge on RX pin captured 
SCI_ISR_TC1	EQU	*
		;Capture length of high pulse 
		LDD	TC1		;RPf			;negedge timestamp - posedge timestamp
		SUBD	TC0		;RPf
		BEQ	SCI_ISR_TC2				;this somehow occurs, just ignore it for now
		;Reset timeout
		LDX	TCNT		;RPf
		LEAX	(-6&$FFFF),X	;PP (LDD TC1H -> LDX TCNTH = 6 cycles)
		STX	TC2		;PW

		;Check if measured length is valid
		BRSET	SCI_FLGS, #SCI_FLG_BDIGN, SCI_ISR_TC1_1 ;clear ignore bit
	
		;Parse the high pulse search tree (pulse length in ACCU D)
		LDY	#SCI_HT0				;set pointer to the beginning of the search tree
		JOB	SCI_ISR_PST

		;Clear ignore bit
SCI_ISR_TC1_1	BCLR	SCI_FLGS, #SCI_FLG_BDIGN
		ISTACK_RTI

;#Timeout, invalidate current measurements
SCI_ISR_TC2	EQU	*
		BSET	SCI_FLGS, #SCI_FLG_BDIGN 		;ignore next measurement
		ISTACK_RTI
	
;#Posedge on RX pin captured 
SCI_ISR_TC0	EQU	*
		;Capture length of high pulse 
		LDD	TC0		;RPf			;posedge timestamp - nededge timestamp
		SUBD	TC1		;RPf
		BEQ	SCI_ISR_TC2				;this somehow occurs, just ignore it for now
		;Reset timeout
		LDX	TCNT		;RPf
		LEAX	(-6&$FFFF),X	;PP (LDD TC1H -> LDX TCNTH = 6 cycles)
		STX	TC2		;PW

		;Check if measured length is valid
		BRSET	SCI_FLGS, #SCI_FLG_BDIGN, SCI_ISR_TC0_1 ;clear ignore bit
	
		;Parse the low pulse search tree (pulse length in accu D)
		LDY	#SCI_LT0				;set pointer to the beginning of the search tree
		;JOB	SCI_ISR_PST

		;Clear ignore bit
SCI_ISR_TC0_1	EQU	SCI_ISR_TC1_1
	
;#Parse a search tree (pulse length in accu D, first search tree entry in index Y) 
SCI_ISR_PST	LDX	#$0000					;use index X to store valid baud rates
SCI_ISR_PST_1	TST	0,Y	     				;check if lower boundary exists
		BEQ	SCI_ISR_PST_2				;search done
		CPD	6,Y+					;check if pulse length is shorter than lower boundary
		BLO	SCI_ISR_PST_1				;pulse length is shorter than lower boundary
								; -> try a shorter range
		LDX	-4,Y					;pulse length is longer or same as lower boundary
								; -> store valid baud rate field in index X
		LDY	-2,Y					; -> parse a new branch of the search tree that contains longer ranges
		BNE	SCI_ISR_PST_1				;parse branch if it exists
	
		;Search is done (valid baud rates are stored in index X) 
SCI_ISR_PST_2	EXG	X, D	 				;apply search result to the set of valid baud rates
		ANDA	SCI_BDLST
		BEQ	SCI_ISR_PST_4				;no valid baud rate found, start all over
		STAB	SCI_BDLST 				;save valid Baud rates
			
		;Check if baud rate has been determined (valid baud rates are stored in accu A)
		TAB						;save baude rates in accu B
		LDX	#$FFFE					;use index X as index counter
SCI_ISR_PST_3	LEAX	2,X					;increment index counter
		LSRA						;check if only one bit is set in accu A
		BCC	SCI_ISR_PST_3				;shift until a "1" ends up in the carry bit
		BEQ	SCI_ISR_PST_5				;baud rate has been determined

		;Baud rate has not been determined yet (valid baud rates are stored in accu B)
		//BSET	SCI_FLGS, #SCI_FLG_BDCNT
		ISTACK_RTI					;wait for the next pulse
	
		;No valid baud rate found, start all over
SCI_ISR_PST_4	MOVB	#$FF, SCI_BDLST
		BSET	SCI_FLGS, #SCI_FLG_BDCNT
		ISTACK_RTI

		;Baud rate has been determined (index of baud rate table in index X)
SCI_ISR_PST_5   LDAB	SCI_FLGS				;load flags into accu B
		ADDB	#SCI_FLG_BDCNT				;decrement BD counter
		STAB	SCI_FLGS				;save flags
	        BITB	#SCI_FLG_BDCNT
		BEQ	SCI_ISR_PST_6				;baud rate has been validated often enough
		ISTACK_RTI

		;Baud rate has been validated (index of baud rate table in index X)
SCI_ISR_PST_6	LDD	SCI_BTAB,X				;look up divider value
		STD	SCIBDH					;set baud rate
		LDY	#SCI_BMUL				;save baud rate for next warmstart
		EMUL						;D*Y -> Y:D
		STD	SCI_BVAL
	
		;Disable monitoring of the RX pin 
		BCLR	TIE, #SCI_TIMCH		     		;disable interrupts
		TIM_DISABLE TIM_SCI		     		;disable timer	
		LED_COMERR_OFF					;stop signaling communication errors
		ISTACK_RTI
	
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
