;###############################################################################
;# S12CForth - FBDM - Forth wrapper for the S12CBase BDM driver                #
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
;#    This module implements Forth words for the S12CBase BDM driver           # 
;#                                                                             #
;#    Relationship between BDM_SPEED (target speed) and BDM frequency:         #
;#                                                                             #
;#                               128 * CLOCK_BUS_FREQ                          #
;#              BDM frequency = ----------------------                         #
;#                                     BDM_SPEED                               #
;#                                                                             #
;#                               128 * CLOCK_BUS_FREQ                          #
;#                  BDM_SPEED = ----------------------                         #
;#                                   BDM frequency                             #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FCORE  - Forth core words                                                #
;#    FMEM   - Forth memories                                                  #
;#    FEXCPT - Forth exceptions                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
FBDM_DIVISOR		EQU	CLOCK_BUS_FREQ*128		;constant divisor

;Non-standard error codes 
FBDM_EC_TGTRST		EQU	(FEXCPT_MSGTAB_FBDM-FEXCPT_MSGTAB_END)/2;Unexpected target reset
FBDM_EC_NORSP 		EQU	2+FBDM_EC_TGTRST			;Target is not responding
FBDM_EC_NOSPD 		EQU	4+FBDM_EC_TGTRST			;BDM frequency not set   
FBDM_EC_COMERR 		EQU	6+FBDM_EC_TGTRST			;BDM communication error

;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FBDM_VARS_START
FBDM_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FBDM_INIT, 0
#emac

;#Error message lookup table
#macro	FBDM_MSGTAB, 0
			DW	FBDM_MSG_TGTRST	;Unexpected target reset
			DW	FBDM_MSG_NORSP 	;Target is not responding
			DW	FBDM_MSG_NOSPD 	;BDM frequency not set   
			DW	FBDM_MSG_COMERR ;Communication error   
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FBDM_CODE_START
;Common subroutines:
;=================== 	
;#Divide CLOCK_BUS_FREQ*128 by a double number
; args:   D:X: Dividend
; result: D:X: Result
; SSTACK: 16 bytes
;         Y is preserved
FBDM_CONVERT	EQU	*
			;Save registers
			SSTACK_PSHYXD				;save index X and accu D

			;Check if dividend is only 16-bit wide (dividend in D:X) 
			TBEQ	D, FBDM_CONVERT_8 		;16-bit dividend

			;32-bit dividend (dividend in D:X)
			;Allocate temporary memory (dividend in D:X)
			SSTACK_ALLOC	8 			;allocate 4 additional words
			LDY	SSTACK_SP
;  	                +--------------+--------------+
;           SSTACK_SP-> |        divisor (MSW)        | +$00
;  	                +--------------+--------------+
;                       |        divisor (LSW)        | +$02
;  	                +--------------+--------------+
;                       |        dividend (MSW)       | +$04
;  	                +--------------+--------------+          
;                       |        dividend (LSW)       | +$06         
;  	                +--------------+--------------+	     
;                       |         D (shifter)         | +$08         
;  	                +--------------+--------------+	     
;                       |         X (result)          | +$0A         
;  	                +--------------+--------------+	     
;                       |              Y              | +$0C         
;  	                +--------------+--------------+          
FBDM_CONVERT_DIVISOR_LSW	EQU	$00
FBDM_CONVERT_DIVISOR_MSW	EQU	$02
FBDM_CONVERT_DIVIDEND_LSW	EQU	$04
FBDM_CONVERT_DIVIDEND_MSW	EQU	$06
FBDM_CONVERT_SHIFTER		EQU	$08
FBDM_CONVERT_RESULT		EQU	$0A
			;Initialize temporary registers (SP in Y, dividend in D:X)
			MOVW	#$0000, FBDM_CONVERT_SHIFTER,Y
			MOVW	#$0000, FBDM_CONVERT_RESULT,Y
			MOVW	#(FBDM_DIVISOR>>16), FBDM_CONVERT_DIVISOR_MSW,Y
			MOVW	#FBDM_DIVISOR,       FBDM_CONVERT_DIVISOR_LSW,Y
			MOVW	#$0000, FBDM_CONVERT_DIVIDEND_MSW,Y
			MOVW	#$0000, FBDM_CONVERT_DIVIDEND_LSW,Y
			;Check if shifted dividend is greater than the divisor (SP in Y, shifted dividend in D:X)
FBDM_CONVERT_1		CPD	FBDM_CONVERT_DIVISOR_MSW,Y	
			BHI	FBDM_CONVERT_4 			;shifted dividend > divisor
			BLO	FBDM_CONVERT_2			;shifted dividend < divisor
			CPX	FBDM_CONVERT_DIVISOR_LSW,Y
			BHI	FBDM_CONVERT_4 			;dividend > divisor
			;Shifted dividend < divisor (SP in Y, shifted dividend in D:X)
FBDM_CONVERT_2		STD	FBDM_CONVERT_DIVIDEND_MSW,Y 	;store shifted dividend
			STX	FBDM_CONVERT_DIVIDEND_LSW,Y
			LDD	FBDM_CONVERT_SHIFTER,Y 		;update shifter
			LSLD
			BNE	FBDM_CONVERT_3
			LDD	#$0001
FBDM_CONVERT_3		STD	FBDM_CONVERT_SHIFTER,Y
			TFR	X,D 				;left-shift dividend
			LSLD
			TFR	D,X
			LDD	FBDM_CONVERT_DIVIDEND_MSW,Y
			ROLB
			ROLA
			BCC	FBDM_CONVERT_1
			;Shifted dividend > divisor (SP in Y)
FBDM_CONVERT_4		LDD	FBDM_CONVERT_RESULT,Y 		;add shifter to result
			ADDD	FBDM_CONVERT_SHIFTER,Y
			STD	FBDM_CONVERT_RESULT,Y
			LDD	FBDM_CONVERT_DIVISOR_LSW,Y 	;subtract dividend from divisor
			SUBD	FBDM_CONVERT_DIVIDEND_LSW,Y
			LDD	FBDM_CONVERT_DIVISOR_MSW,Y
			SBCB	FBDM_CONVERT_DIVIDEND_MSW+1,Y
			SBCA	FBDM_CONVERT_DIVIDEND_MSW,Y
			STD	FBDM_CONVERT_DIVISOR_MSW,Y
			LDD	FBDM_CONVERT_DIVIDEND_MSW,Y 	;dividend -> D:X
			LDX	FBDM_CONVERT_DIVIDEND_LSW,Y
			;Right-shift dividend (SP in Y, dividend in D:X) 
FBDM_CONVERT_5		LSRD					;shift MSW
			STD	FBDM_CONVERT_DIVIDEND_MSW,Y	;store MSW
			TFR	X,D				;shift LSW
			RORA
			RORB
			TFR	D,X
			STX	FBDM_CONVERT_DIVIDEND_LSW,Y	;store LSW
			LDD	FBDM_CONVERT_SHIFTER,Y		;update shifter
			LSRD
			STD	FBDM_CONVERT_SHIFTER,Y
			LDD	FBDM_CONVERT_DIVIDEND_MSW,Y
			;Terminate if shifted dividend is zero (SP in Y, dividend in D:X)
			TBNE	D, FBDM_CONVERT_6		;dividend is not zero
			TBEQ	X, FBDM_CONVERT_7		;dividend is zero
			;Check if dividend < divisor (SP in Y, dividend in D:X)
FBDM_CONVERT_6		CPD	FBDM_CONVERT_DIVISOR_MSW,Y
			BLO	FBDM_CONVERT_4 			;shifted dividend < divisor
			BHI	FBDM_CONVERT_5			;shifted dividend > divisor
			CPX	FBDM_CONVERT_DIVISOR_MSW,Y
			BHI	FBDM_CONVERT_5			;shifted dividend > divisor
			JOB	FBDM_CONVERT_4 			;shifted dividend <= divisor
			;Prepare result (SP in Y)
FBDM_CONVERT_7		;MOVW	#$0000, FBDM_CONVERT_SHIFTER,Y	
			SSTACK_DEALLOC	8 				;free temporary variables
			JOB	FBDM_CONVERT_9	
				
			;16-bit dividend (dividend in X)
;  	                +--------------+--------------+          
;            SSTACK_SP->|     D (dividend/result MSW) | +$00       
;  	                +--------------+--------------+	     
;                       |     X (dividend/result LSW) | +$02         
;  	                +--------------+--------------+	     
;                       |              Y              | +$04         
;  	                +--------------+--------------+
FBDM_CONVERT_D		EQU	$00
FBDM_CONVERT_X		EQU	$02
FBDM_CONVERT_Y		EQU	$04
			;Check if divident ia zero (dividend in X)
FBDM_CONVERT_8		TBEQ	X, FBDM_CONVERT_10 		;division by zero (return zero)	
			;1st division: divisor(MSB)/dividend => result(MSB) 
			LDD	#(FBDM_DIVISOR>>16)
			IDIV					;D/X=>X; remainder=D
			LDY	SSTACK_SP
			STX	FBDM_CONVERT_D,Y
			;2nd division: remainder:divisor(LSB)/dividend => result(LSB) 
			LDX	FBDM_CONVERT_X,Y	
			TFR	D,Y
			LDD	#FBDM_DIVISOR
			EDIV					;Y:D/X=>Y; remainder=>D
			LDX	SSTACK_SP
			STY	FBDM_CONVERT_X,X
			;Restore registers 
FBDM_CONVERT_9		SSTACK_PULDXY
			SSTACK_RTS
			;Division by zero
FBDM_CONVERT_10		LDY	SSTACK_SP
			MOVW	#$FFFF, FBDM_CONVERT_D,Y
			MOVW	#$FFFF, FBDM_CONVERT_X,Y
			JOB	FBDM_CONVERT_9
	
;Exceptions:
;===========
;Standard exceptions
FBDM_THROW_PSOF	EQU	FMEM_THROW_PSOF				;stack overflow
FBDM_THROW_PSUF	EQU	FMEM_THROW_PSUF				;stack underflow
FBDM_THROW_INVALNUM	FEXCPT_THROW	FEXCPT_EC_INVALNUM	;invalid numeric argument
FBDM_THROW_TGTRST	FEXCPT_THROW	FBDM_EC_TGTRST		;Unexpected target reset 
FBDM_THROW_NORSP	FEXCPT_THROW	FBDM_EC_NORSP		;Target is not responding
FBDM_THROW_NOSPD	FEXCPT_THROW	FBDM_EC_NOSPD		;BDM frequency not set   
FBDM_THROW_COMERR	FEXCPT_THROW	FBDM_EC_COMERR		;Communication error
	
FBDM_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FBDM_TABS_START

;Non-standard error messages 
FBDM_MSG_TGTRST		ERROR_MSG	ERROR_LEVEL_ERROR, "Unexpected target reset" 
FBDM_MSG_NORSP		ERROR_MSG	ERROR_LEVEL_ERROR, "Target is not responding"
FBDM_MSG_NOSPD		ERROR_MSG	ERROR_LEVEL_ERROR, "BDM frequency not set"   
FBDM_MSG_COMERR		ERROR_MSG	ERROR_LEVEL_ERROR, "Communication error"

FBDM_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FBDM_WORDS_START
	
;BDMTXB ( char u_ackto -- u_ack ) S12CForth extension CHECK!
;Send a byte over the BDM interface and wait for an ACK pulse
;char:    transmit data
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;u_bits:  number of bits to receive 
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Invalid numeric value"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMTXB		FHEADER, "BDMTXB", FBDM_PREV_NFA, COMPILE
CFA_BDMTXB		DW	CF_BDMTXB
CF_BDMTXB		PS_CHECK_UF	2, CF_BDMTXB_PSUF ;check for underflow  (PSP -> Y)
			;BDM write access (PSP in Y)
			LDX	#8
			LDD	2,Y+ 	;ACK timeout [BC]
			BDM_TX
			JMP	[CF_BDMTXW_TAB,X]
	
CF_BDMTXB_PSUF		JOB	FBDM_THROW_PSUF	
	
;BDMTXW ( u u_ackto -- u_ack ) S12CForth extension CHECK!
;Send a double word over the BDM interface and wait for an ACK pulse
;u:      transmit data
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;u_bits:  number of bits to receive 
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Invalid numeric value"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMTXW		FHEADER, "BDMTXW", NFA_BDMTXB, COMPILE
CFA_BDMTXW		DW	CF_BDMTXW
CF_BDMTXW		PS_CHECK_UF	2, CF_BDMTXW_PSUF ;check for underflow  (PSP -> Y)
			;BDM write access (PSP in Y)
			LDX	#16
			LDD	2,Y+ 	;ACK timeout [BC]
			BDM_TX
			JMP	[CF_BDMTXW_TAB,X]
	
CF_BDMTXW_PSUF		JOB	FBDM_THROW_PSUF	

CF_BDMTXW_TAB		DW	CF_BDMTXW_1
			DW	FBDM_THROW_TGTRST
			DW	FBDM_THROW_NOSPD
			DW	FBDM_THROW_COMERR

			;No problems (PSP+2 in Y)
CF_BDMTXW_1		STD	2,+Y
			STY	PSP
			;Done	
FBDM_NEXT		NEXT
	
;BDMTXD ( ud u_ackto -- u_ack ) S12CForth extension CHECK!
;Send a double word over the BDM interface and wait for an ACK pulse
;ud:      transmit data
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;u_bits:  number of bits to receive 
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Invalid numeric value"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMTXD		FHEADER, "BDMTXD", NFA_BDMTXW, COMPILE
CFA_BDMTXD		DW	CF_BDMTXD
CF_BDMTXD		PS_CHECK_UF	3, CF_BDMTXD_PSUF ;check for underflow  (PSP -> Y)
			;BDM write access (PSP in Y)
			LDX	#32
			LDD	2,Y+ 	;ACK timeout [BC]
			BDM_TX
			JMP	[CF_BDMTXD_TAB,X]
	
CF_BDMTXD_PSUF		JOB	FBDM_THROW_PSUF	

CF_BDMTXD_TAB		DW	CF_BDMTXD_1
			DW	FBDM_THROW_TGTRST
			DW	FBDM_THROW_NOSPD
			DW	FBDM_THROW_COMERR

			;No problems (PSP+2 in Y)
CF_BDMTXD_1		STD	4,+Y
			STY	PSP
			;Done	
			NEXT

;BDMTX ( u_1...u_n u_ackto u_bits -- u_ack ) S12CForth extension CHECK!
;Send a number of bits over the BDM interface and wait for an ACK pulse
;u_1:     LSW of the transmit data
;u_n:	  MSW of the transmit data (n = (u_bits+15)/16)
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;u_bits:  number of bits to receive 
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Invalid numeric value"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMTX		FHEADER, "BDMTX", NFA_BDMTXD, COMPILE
CFA_BDMTX		DW	CF_BDMTX
CF_BDMTX		PS_CHECK_UF	2, CF_BDMTX_PSUF ;check for underflow  (PSP -> Y)
			;Check for stack underflow (PSP in Y)			
			LDD	0,Y			 
			LSRD
			ADCB	#$27
			ADCA	#$00
			LSRD
			LSRD
			ANDB	#$FE 			;min. stack size -> D
			ADDD	PSP
			BCS	CF_BDMTX_PSUF
			CPD	#PS_EMPTY
			BLO	CF_BDMTX_PSUF
			;BDM write access (PSP in Y)
			LDD	2,Y 	;ACK timeout [BC]
			LDX	4,Y+ 	;data width [bits]
			BDM_TX
			JMP	[CF_BDMTX_TAB,X]

CF_BDMTX_PSUF		JOB	FBDM_THROW_PSUF	

CF_BDMTX_TAB		DW	CF_BDMTX_1
			DW	FBDM_THROW_TGTRST
			DW	FBDM_THROW_NOSPD
			DW	FBDM_THROW_COMERR

			;No problems (PSP+4 in Y)
CF_BDMTX_1		TFR	D,X
			LDD	4,-Y
			LSRD
			ADCB	#$17
			ADCA	#$00
			LSRD
			LSRD
			ANDB	#$FE 			;min. stack size -> D
			LEAY	D,Y
			STY	PSP
			;Done	
			NEXT

;BDMRXB ( u_ackto --  char u_ack ) S12CForth extension CHECK!
;Read a byte from the BDM interface.
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;u:       received byte
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Parameter stack underflow"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMRXB		FHEADER, "BDMRXB", NFA_BDMTX, COMPILE
CFA_BDMRXB		DW	CF_BDMRXB
CF_BDMRXB		PS_CHECK_UFOF	1, CF_BDMRXB_PSUF, 1, CF_BDMRXB_PSOF	;check for over and underflow (PSP-2 -> Y)
			;BDM read access (PSP-2 in Y)
			LDD	2,+Y	;ACK timeout [BC]
			LDX	#8	;data width [bits]
			BDM_RX
			JMP	[CF_BDMRX_TAB,X]
	
CF_BDMRXB_PSUF		JOB	FBDM_THROW_PSUF	
CF_BDMRXB_PSOF		JOB	FBDM_THROW_PSOF	
	
;BDMRXW ( u_ackto -- u u_ack ) S12CForth extension CHECK!
;Read a word from the BDM interface.
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;u:       received word
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Parameter stack underflow"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMRXW		FHEADER, "BDMRXW", NFA_BDMRXB, COMPILE
CFA_BDMRXW		DW	CF_BDMRXW
CF_BDMRXW		PS_CHECK_UFOF	1, CF_BDMRXW_PSUF, 1, CF_BDMRXW_PSOF	;check for over and underflow (PSP-2 -> Y)
			;BDM read access (PSP-2 in Y)
			LDD	2,+Y	;ACK timeout [BC]
			LDX	#16	;data width [bits]
			BDM_RX
			JMP	[CF_BDMRX_TAB,X]
	
CF_BDMRXW_PSUF		JOB	FBDM_THROW_PSUF	
CF_BDMRXW_PSOF		JOB	FBDM_THROW_PSOF	

;BDMRXD ( u_ackto -- ud u_ack ) S12CForth extension CHECK!
;Read a double word from the BDM interface.
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;ud:      received double word
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Parameter stack underflow"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMRXD		FHEADER, "BDMRXD", NFA_BDMRXW, COMPILE
CFA_BDMRXD		DW	CF_BDMRXD
CF_BDMRXD		PS_CHECK_UFOF	1, CF_BDMRXD_PSUF, 2, CF_BDMRXD_PSOF	;check for over and underflow (PSP-4 -> Y)
			;BDM read access (PSP-4 in Y)
			LDD	4,Y	;ACK timeout [BC]
			LEAY	2,Y	;data pointer [word pointer]
			LDX	#32	;data width [bits]
			BDM_RX
			JMP	[CF_BDMRX_TAB,X]
	
CF_BDMRXD_PSUF		JOB	FBDM_THROW_PSUF	
CF_BDMRXD_PSOF		JOB	FBDM_THROW_PSOF	

;BDMRX ( u_ackto u_bits -- u_1...u_n u_ack ) S12CForth extension CHECK!
;Read a number of bits from the BDM interface and wait for an ACK pulse
;u_ackto: timeout of the ACK pulse (0 if no ACK pulse is expected)
;u_bits:  number of bits to receive 
;u_1:     LSW of the received data
;u_n:	  MSW of the received data (n = (u_bits+15)/16)
;u_ack:   width of the ACK pulse (0 if no ACK pulse was received)
;Throws:
;"Parameter stack underflow"
;"Parameter stack underflow"
;"Invalid numeric value"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMRX		FHEADER, "BDMRX", NFA_BDMRXD, COMPILE
CFA_BDMRX		DW	CF_BDMRX
			;Check for stack overflow
CF_BDMRX		PS_CHECK_UF	1, CF_BDMRX_PSUF ;check for underflow  (PSP -> Y)
			;Check for stack overflow (PSP in Y)
			TFR	Y,X
			LDD	0,Y
			LSRD
			ADCB	#7
			ADCA	#0
			LSRD
			LSRD
			LSRD
			SUBD	#1
			PS_CHECK_OF_D	CF_BDMRX_PSOF ;check for underflow  (final PSP -> Y)
			;BDM read access (current PSP in X, final PSP in Y)
			LEAY	2,Y	;data pointer [word pointer]
			LDD	2,X	;ACK timeout [BC]
			LDX	0,X	;data width [bits]
			BDM_RX
			JMP	[CF_BDMRX_TAB,X]

CF_BDMRX_PSUF		JOB	FBDM_THROW_PSUF	
CF_BDMRX_PSOF		JOB	FBDM_THROW_PSOF	
CF_BDMRX_INVALNUM	JOB	FBDM_THROW_INVALNUM	

CF_BDMRX_TAB		DW	CF_BDMRX_1
			DW	FBDM_THROW_TGTRST
			DW	FBDM_THROW_NOSPD
			DW	FBDM_THROW_COMERR

			;No problems 
CF_BDMRX_1		STD	2,-Y
			STY	PSP
			;Done	
			NEXT

;BDMDLY ( u -- ) S12CForth extension CHECK!
;Delay transmission by at least u BDM cycles
;Throws:
;"Parameter stack underflow"
;"Unexpected target reset"
;"BDM frequency not set"
;
			ALIGN	1
NFA_BDMDLY		FHEADER, "BDMDLY", NFA_BDMRXD, COMPILE
CFA_BDMDLY		DW	CF_BDMDLY
CF_BDMDLY		PS_CHECK_UF	1, CF_BDMDLY_PSUF ;check for underflow  (PSP -> Y)
			;Execute delay
			LDX	2,Y+
			STY	PSP
			BDM_DELAY
			;Check error code
			JMP	[CF_BDMDLY_TAB,X]
	
CF_BDMDLY_TAB		DW	FBDM_NEXT
			DW	FBDM_THROW_TGTRST
			DW	FBDM_THROW_NOSPD

CF_BDMDLY_PSUF		JOB	FBDM_THROW_PSUF
		
;BDMSYNC ( -- ) S12CForth extension CHECK!
;Sends a SYNC pulse and detects the BDM frequency
;Throws:
;"BDM target does not respond"
;
			ALIGN	1
NFA_BDMSYNC		FHEADER, "BDMSYNC", NFA_BDMDLY, COMPILE
CFA_BDMSYNC		DW	CF_BDMSYNC
CF_BDMSYNC		;Sync target
			BDM_SYNC
			;Check error code
			JMP	[CF_BDMSYNC_TAB,X]
	
CF_BDMSYNC_TAB		DW	FBDM_NEXT
			DW	FBDM_THROW_TGTRST
			DW	FBDM_THROW_NORSP

;BDMRST ( -- ) S12CForth extension CHECK!
;Resets the target without touching the BKGD pin.
;
			ALIGN	1
NFA_BDMRST		FHEADER, "BDMRST", NFA_BDMSYNC, COMPILE
CFA_BDMRST		DW	CF_BDMRST
CF_BDMRST		;Reset target
			LDAB	#$FF
			BDM_RESET
			;Done
			NEXT

;BDMSRST ( -- ) S12CForth extension CHECK!
;Resets the target into special mode
;
			ALIGN	1
NFA_BDMSRST		FHEADER, "BDMSRST", NFA_BDMRST, COMPILE
CFA_BDMSRST		DW	CF_BDMSRST
CF_BDMSRST		;Reset target
			CLRB
			BDM_RESET
			;Done
			NEXT
	
;BDMFREQ! ( ud -- ) S12CForth extension CHECK!
;Sets the BDM frequency to ud Hz.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMFREQ_STORE	FHEADER, "BDMFREQ!", NFA_BDMSRST, COMPILE
CFA_BDMFREQ_STORE	DW	CF_BDMFREQ_STORE
CF_BDMFREQ_STORE	PS_CHECK_UF	2, CF_BDMFREQ_STORE_PSUF ;check for underflow (PSP -> Y)
			;Pull baud rate from PSP
			LDD	2,Y+
			LDX	2,Y+
			STY	PSP
			;Convert baud rate into BDM_SPEED value 
			SSTACK_JOBSR	FBDM_CONVERT		 ;(SSTACK: 18 bytes)
			;Check SPEED value
			TBNE	D, CF_BDMFREQ_STORE_INVALNUM	;the MSW must be zero
			CPX	#BDM_SPEED_MAX
			BLO	CF_BDMFREQ_STORE_INVALNUM
			;Set new BDM speed
			TFR	X, D
			BDM_SET_SPEED
			;Done
			NEXT

CF_BDMFREQ_STORE_PSUF		JOB	FBDM_THROW_PSUF
CF_BDMFREQ_STORE_INVALNUM	JOB	FBDM_THROW_INVALNUM

;BDMFREQ@ (  -- ud ) S12CForth extension CHECK!
;Returns the BDM frequency in Hz. Returns zero if the target frequency has
;been set.
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_BDMFREQ_FETCH	FHEADER, "BDMFREQ@", NFA_BDMFREQ_STORE, COMPILE
CFA_BDMFREQ_FETCH	DW	CF_BDMFREQ_FETCH
CF_BDMFREQ_FETCH	PS_CHECK_OF	2, CF_BDMFREQ_FETCH_PSOF ;check for underflow (PSP-4 -> Y)
			;Get BDM_SPEED value 
			CLRA
			CLRB
			LDX	BDM_SPEED
			;Convert SCIBD value into baud rate (PSP-4 -> Y)
			SSTACK_JOBSR	FBDM_CONVERT		 ;(SSTACK: 18 bytes)
			;Push baud rate onto PS   
			STD	0,Y
			STX	2,Y
			STY	PSP
			;Done
			NEXT

CF_BDMFREQ_FETCH_PSOF	JOB	FBDM_THROW_PSOF
	
FBDM_WORDS_END		EQU	*
FBDM_LAST_NFA		EQU	NFA_BDMFREQ_FETCH
