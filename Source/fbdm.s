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

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FBDM_CODE_START
;Common subroutines:
;=================== 	
;#Divide CLOCK_BUS_FREQ*128 by a double number
; args:   D:X: Dividend
; result: D:X: Result
; SSTACK: 18 bytes
;         Y is preserved
FBDM_CONVERT	EQU	*
			;Save registers
			SSTACK_PSHYXD				;save index X and accu D

			;Check if dividend is only 16-bit wide (dividend in D:X) 
			TBEQ	D, FBDM_CONVERT_8 		;16-bit dividend

			;32-bit dividend (dividend in D:X)
FBDM_CONVERT_1	SSTACK_ALLOC	10 			;allocate temporary variables
			LDY	SSTACK_SP
;  	                +--------------+--------------+
;           SSTACK_SP-> |         temp variable       | +$00
;  	                +--------------+--------------+
;                       |           shifter           | +$02
;  	                +--------------+--------------+
;                       |        divisor (MSW)        | +$04
;  	                +--------------+--------------+          
;                       |        divisor (LSW)        | +$06         
;  	                +--------------+--------------+	     
;                       |        dividend (MSW)       | +$04
;  	                +--------------+--------------+          
;                       |        dividend (LSW)       | +$06         
;  	                +--------------+--------------+	     
;                       |           result            | +$08         
;  	                +--------------+--------------+	     
;                       |              Y              | +$0A         
;  	                +--------------+--------------+          
FBDM_CONVERT_TMP		EQU	$00
FBDM_CONVERT_SHIFTER	EQU	$02
FBDM_CONVERT_DIVISOR_LSW	EQU	$06
FBDM_CONVERT_DIVISOR_MSW	EQU	$08
FBDM_CONVERT_DIVIDEND_LSW	EQU	$06
FBDM_CONVERT_DIVIDEND_MSW	EQU	$08
FBDM_CONVERT_RESULT	EQU	$0A

			;Initialize result (SP in Y, dividend in D:X))
			MOVW	#$0000, FBDM_CONVERT_RESULT,Y

			;Initialize divisor (SP in Y, dividend in D:X))
			MOVW	#(FBDM_DIVISOR>>16),  FBDM_CONVERT_DIVISOR_MSW,Y
			MOVW	#(FBDM_DIVISOR>>$FF), FBDM_CONVERT_DIVISOR_LSW,Y

			;Initialize dividend (SP in Y, dividend in D:X))
			STD	FBDM_CONVERT_DIVIDEND_MSW,Y
			STX	FBDM_CONVERT_DIVIDEND_LSW,Y
			
			;Terminate if divisor <= dividend (SP in Y, dividend in D:X)
FBDM_CONVERT_2	CPD	FBDM_CONVERT_DIVISOR_MSW,Y
			BHI	FBDM_CONVERT_7 			;terminate
			BLO	FBDM_CONVERT_3 			;continue division
			;Divisor MSW == dividend MSW (SP in Y, dividend in D:X)
			CPX	FBDM_CONVERT_DIVISOR_LSW,Y
			BHI	FBDM_CONVERT_7 			;terminate

			;Initialize shifter  (SP in Y, dividend in D:X))
FBDM_CONVERT_3		MOVW	#$0001, FBDM_CONVERT_SHIFTER,Y

			;Shift dividend  (SP in Y, dividend in D:X)			
FBDM_CONVERT_4		EXG	D, X
			LSLD
			EXG	D, X
			ROLB
			ROLA

			;Check if shifted divisor < shifted dividend (SP in Y, shifted dividend in C:D:X)
			BCS	FBDM_CONVERT_5 			;terminate iteration and consider carry bit
			CPD	FBDM_CONVERT_DIVISOR_MSW,Y
			BHI	FBDM_CONVERT_6 			;terminate iteration
			;Divisor MSW == dividend MSW (SP in Y, shifted dividend in D:X)
			CPX	FBDM_CONVERT_DIVISOR_LSW,Y
			BHI	FBDM_CONVERT_6 			;terminate iteration

			;Shift shifter (SP in Y, shifted dividend in D:X)
			STD	FBDM_CONVERT_TMP,Y
			LDD	FBDM_CONVERT_SHIFTER,Y
			LSLD
			STD	FBDM_CONVERT_SHIFTER,Y
			LDD	FBDM_CONVERT_TMP,Y
			
			;Next iteration 
			JOB	FBDM_CONVERT_ 			
	
			;Terminate iteration and consider carry bit (SP in Y, shifted dividend in C:D:X)
FBDM_CONVERT_5		RORA	
			RORB
			JOB	FBDM_CONVERT_6			;terminate iteration
	
			;Terminate iteration (SP in Y, shifted dividend in D:X)
FBDM_CONVERT_6		LSRD
			EXG	D,X
			RORA
			RORB

			;Subtract dividend from divisor (SP in Y, shifted dividend in X:D)
			STD	FBDM_CONVERT_TMP,Y
			LDD	FBDM_CONVERT_DIVISOR_LSW,Y
			SUBD	FBDM_CONVERT_TMP,Y
			STD	FBDM_CONVERT_DIVISOR_LSW,Y
			STX	FBDM_CONVERT_TMP,Y
			LDD	FBDM_CONVERT_DIVISOR_MSW,Y
			SBCB	FBDM_CONVERT_TMP+1,Y
			SBCA	FBDM_CONVERT_TMP,Y
			STD	FBDM_CONVERT_DIVISOR_MSW,Y
			
			;Add shifter to result (SP in Y)
			LDD	FBDM_CONVERT_SHIFTER,Y	
			ADDD	FBDM_CONVERT_RESULT,Y
			STD	FBDM_CONVERT_RESULT,Y

			;Load original dividend (SP in Y)
			LDD	FBDM_CONVERT_DIVIDEND_MSW,Y
			LDX	FBDM_CONVERT_DIVIDEND_LSW,Y
		
			;Rerun outer loop with new divisor (SP in Y, dividend in D:X)
			JOB	FBDM_CONVERT_2	

			;Terminate (SP in Y)
FBDM_CONVERT_7		MOVW	#$0000, FBDM_CONVERT_DIVIDEND_LSW,Y	;clean up result
			SSTACK_DEALLOC	10 				;free temporary variables
			JOB	FBDM_CONVERT_9	
				
			;16-bit dividend (dividend in X)
;  	                +--------------+--------------+          
;            SSTACK_SP->|     D (dividend/result MSW) | +$00       
;  	                +--------------+--------------+	     
;                       |     X (dividend/result LSW) | +$02         
;  	                +--------------+--------------+	     
;                       |              Y              | +$04         
;  	                +--------------+--------------+	
			;1st division: divisor(MSB)/dividend => result(MSB) 
FBDM_CONVERT_8		LDD	#(FBDM_DIVISOR>>16)
			IDIV					;D/X=>X; remainder=D
			LDY	SSTACK_SP
			STX	0,Y
			;2nd division: remainder:divisor(LSB)/dividend => result(LSB) 
			LDX	2,Y	
			TFR	D,Y
			LDD	#(FBDM_DIVISOR>>$FF)
			EDIV					;Y:D/X=>Y; remainder=>D
			LDX	SSTACK_SP
			STY	0,X

			;Restore registers 
FBDM_CONVERT_9	SSTACK_PULDXY
			SSTACK_RTS

;Exceptions:
;===========
;Standard exceptions
FBDM_THROW_PSOF	EQU	FMEM_THROW_PSOF			;stack overflow
FBDM_THROW_PSUF	EQU	FMEM_THROW_PSUF			;stack underflow
FBDM_THROW_INVALNUM	THROW	FEXCPT_EC_INVALNUM	;invalid numeric argument

FBDM_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FBDM_TABS_START
FBDM_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FBDM_WORDS_START

;BDMTX ( u1 u2 -- ) S12CForth extension
;Transmit the lower u2 bits of u1.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMTX		FHEADER, "BDMTX", FBDM_PREV_NFA, COMPILE
CFA_BDMTX		DW	CF_BDMTX
CF_BDMTX		PS_CHECK_UF	2, CF_BDMTX_PSUF ;check for underflow  (PSP -> Y)

			NEXT

CF_BDMTX_PSUF		JOB	FBDM_THROW_PSUF	
	
;BDMTXB ( c -- ) S12CForth extension
;Transmit c.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMTXB		FHEADER, "BDMTXB", NFA_BDMTX, COMPILE
CFA_BDMTXB		DW	CF_BDMTXB
CF_BDMTXB		PS_CHECK_UF	1, CF_BDMTXB_PSUF ;check for underflow  (PSP -> Y)

			NEXT

CF_BDMTXB_PSUF		JOB	FBDM_THROW_PSUF	
	
;BDMTXW ( u -- ) S12CForth extension
;Transmit u.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMTXW		FHEADER, "BDMTXW", NFA_BDMTXB, COMPILE
CFA_BDMTXW		DW	CF_BDMTXW
CF_BDMTXW		PS_CHECK_UF	1, CF_BDMTXW_PSUF ;check for underflow  (PSP -> Y)

			NEXT

CF_BDMTXW_PSUF		JOB	FBDM_THROW_PSUF	
	
;BDMTXD ( ud -- ) S12CForth extension
;Transmit ud.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMTXD		FHEADER, "BDMTXD", NFA_BDMTXW, COMPILE
CFA_BDMTXD		DW	CF_BDMTXD
CF_BDMTXD		PS_CHECK_UF	2, CF_BDMTXD_PSUF ;check for underflow  (PSP -> Y)

			NEXT

CF_BDMTXD_PSUF		JOB	FBDM_THROW_PSUF	
	
;BDMRX ( u1 -- u2 ) S12CForth extension
;Read u1 bits from the BDM interface. The resulting data is returened as u2.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMRX		FHEADER, "BDMRX", NFA_BDMTXD, COMPILE
CFA_BDMRX		DW	CF_BDMRX
CF_BDMRX		PS_CHECK_UF	1, CF_BDMRX_PSUF ;check for underflow  (PSP -> Y)

			NEXT

CF_BDMRX_PSUF		JOB	FBDM_THROW_PSUF	
	
;BDMRXB ( -- c ) S12CForth extension
;Read one byte from the BDM interface.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMRXB		FHEADER, "BDMRXB", NFA_BDMRX, COMPILE
CFA_BDMRXB		DW	CF_BDMRXB
CF_BDMRXB		PS_CHECK_OF	1, CF_BDMRXB_PSOF ;check for underflow  (PSP+2 -> Y)

			NEXT

CF_BDMRXB_PSOF		JOB	FBDM_THROW_PSOF	
	
;BDMRXW ( -- u ) S12CForth extension
;Read one word from the BDM interface.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMRXW		FHEADER, "BDMRXW", NFA_BDMRXB, COMPILE
CFA_BDMRXW		DW	CF_BDMRXW
CF_BDMRXW		PS_CHECK_OF	1, CF_BDMRXW_PSOF ;check for underflow  (PSP+2 -> Y)

			NEXT

CF_BDMRXW_PSOF		JOB	FBDM_THROW_PSOF	
	
;BDMRXD ( -- ud ) S12CForth extension
;Read one word from the BDM interface.
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMRXD		FHEADER, "BDMRXD", NFA_BDMRXW, COMPILE
CFA_BDMRXD		DW	CF_BDMRXD
CF_BDMRXD		PS_CHECK_OF	2, CF_BDMRXD_PSOF ;check for underflow  (PSP+4 -> Y)

			NEXT

CF_BDMRXD_PSOF		JOB	FBDM_THROW_PSOF	
	
;BDMDLY ( u -- ) S12CForth extension
;Delay transmission by at least u BDM cycles
;Throws:
;"Parameter stack underflow"
;
			ALIGN	1
NFA_BDMDLY		FHEADER, "BDMDLY", NFA_BDMRXD, COMPILE
CFA_BDMDLY		DW	CF_BDMDLY
CF_BDMDLY		PS_CHECK_UF	1, CF_BDMDLY_PSUF ;check for underflow  (PSP -> Y)

			NEXT

CF_BDMDLY_PSUF		JOB	FBDM_THROW_PSUF	
	
;BDMACK ( u1 -- u2) S12CForth extension
;Wait for an ACK pulse from the target. If u1>0 then the ACK pulase must be seen
;within u1 target cycles. Otherwise a timeout error will be thrown. u2 is the 	
;length of the ACK pulse in BDM cycles.
;Throws:
;"Parameter stack underflow"
;"BDM target does not respond"
;
			ALIGN	1
NFA_BDMACK		FHEADER, "BDMACK", NFA_BDMDLY, COMPILE
CFA_BDMACK		DW	CF_BDMACK
CF_BDMACK		PS_CHECK_UF	1, CF_BDMACK_PSUF ;check for underflow  (PSP -> Y)

			NEXT

CF_BDMACK_PSUF		JOB	FBDM_THROW_PSUF	
		
;BDMSYNC ( -- ) S12CForth extension CHECK!
;Sends a SYNC pulse and detects the BDM frequency
;Throws:
;"BDM target does not respond"
;
			ALIGN	1
NFA_BDMSYNC		FHEADER, "BDMSYNC", NFA_BDMACK, COMPILE
CFA_BDMSYNC		DW	CF_BDMSYNC
CF_BDMSYNC		;Sync target
			BDM_SYNC
			;Check error code
			JMP	BDMSYNC_TAB,X
	
BDMSYNC_TAB		DW	FBDM_NEXT
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
NFA_BDMFREQ_STORE	FHEADER, "BDMFREQ!", NFA_BDMSWRST, COMPILE
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
			CPX	#BDM_SPEED_MIN
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
FBDM_LAST_NFA		EQU	NFA_BDMFREQ
