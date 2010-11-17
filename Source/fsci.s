;###############################################################################
;# S12CForth - FSCI - Forth wrapper for the S12CBase SCI driver                #
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
;# Constants                                                                   #
;###############################################################################
FSCI_DIVISOR		EQU	CLOCK_BUS_FREQ/16 		;constant divisor
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FSCI_VARS_START
FSCI_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FSCI_INIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FSCI_CODE_START
;Common subroutines:
;=================== 	
;#Divide CLOCK_BUS_FREQ/16 by a double number
; args:   D:X: Dividend
; result: D:X: Result
; SSTACK: 18 bytes
;         Y is preserved
FSCI_CONVERT	EQU	*
			;Save registers
			SSTACK_PSHYXD				;save index X and accu D

			;Check if dividend is only 16-bit wide (dividend in D:X) 
			TBEQ	D, FSCI_CONVERT_8 		;16-bit dividend

			;32-bit dividend (dividend in D:X)
FSCI_CONVERT_1	SSTACK_ALLOC	10 			;allocate temporary variables
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
FSCI_CONVERT_TMP		EQU	$00
FSCI_CONVERT_SHIFTER	EQU	$02
FSCI_CONVERT_DIVISOR_LSW	EQU	$06
FSCI_CONVERT_DIVISOR_MSW	EQU	$08
FSCI_CONVERT_DIVIDEND_LSW	EQU	$06
FSCI_CONVERT_DIVIDEND_MSW	EQU	$08
FSCI_CONVERT_RESULT	EQU	$0A

			;Initialize result (SP in Y, dividend in D:X))
			MOVW	#$0000, FSCI_CONVERT_RESULT,Y

			;Initialize divisor (SP in Y, dividend in D:X))
			MOVW	#(FSCI_DIVISOR>>16),  FSCI_CONVERT_DIVISOR_MSW,Y
			MOVW	#(FSCI_DIVISOR>>$FF), FSCI_CONVERT_DIVISOR_LSW,Y

			;Initialize dividend (SP in Y, dividend in D:X))
			STD	FSCI_CONVERT_DIVIDEND_MSW,Y
			STX	FSCI_CONVERT_DIVIDEND_LSW,Y
			
			;Terminate if divisor <= dividend (SP in Y, dividend in D:X)
FSCI_CONVERT_2		CPD	FSCI_CONVERT_DIVISOR_MSW,Y
			BHI	FSCI_CONVERT_7 			;terminate
			BLO	FSCI_CONVERT_3 			;continue division
			;Divisor MSW == dividend MSW (SP in Y, dividend in D:X)
			CPX	FSCI_CONVERT_DIVISOR_LSW,Y
			BHI	FSCI_CONVERT_7 			;terminate

			;Initialize shifter  (SP in Y, dividend in D:X))
FSCI_CONVERT_3		MOVW	#$0001, FSCI_CONVERT_SHIFTER,Y

			;Shift dividend  (SP in Y, dividend in D:X)			
FSCI_CONVERT_4		EXG	D, X
			LSLD
			EXG	D, X
			ROLB
			ROLA

			;Check if shifted divisor < shifted dividend (SP in Y, shifted dividend in C:D:X)
			BCS	FSCI_CONVERT_5 			;terminate iteration and consider carry bit
			CPD	FSCI_CONVERT_DIVISOR_MSW,Y
			BHI	FSCI_CONVERT_6 			;terminate iteration
			;Divisor MSW == dividend MSW (SP in Y, shifted dividend in D:X)
			CPX	FSCI_CONVERT_DIVISOR_LSW,Y
			BHI	FSCI_CONVERT_6 			;terminate iteration

			;Shift shifter (SP in Y, shifted dividend in D:X)
			STD	FSCI_CONVERT_TMP,Y
			LDD	FSCI_CONVERT_SHIFTER,Y
			LSLD
			STD	FSCI_CONVERT_SHIFTER,Y
			LDD	FSCI_CONVERT_TMP,Y
			
			;Next iteration 
			JOB	FSCI_CONVERT_4 			
	
			;Terminate iteration and consider carry bit (SP in Y, shifted dividend in C:D:X)
FSCI_CONVERT_5		RORA	
			RORB
			JOB	FSCI_CONVERT_6			;terminate iteration
	
			;Terminate iteration (SP in Y, shifted dividend in D:X)
FSCI_CONVERT_6		LSRD
			EXG	D,X
			RORA
			RORB

			;Subtract dividend from divisor (SP in Y, shifted dividend in X:D)
			STD	FSCI_CONVERT_TMP,Y
			LDD	FSCI_CONVERT_DIVISOR_LSW,Y
			SUBD	FSCI_CONVERT_TMP,Y
			STD	FSCI_CONVERT_DIVISOR_LSW,Y
			STX	FSCI_CONVERT_TMP,Y
			LDD	FSCI_CONVERT_DIVISOR_MSW,Y
			SBCB	FSCI_CONVERT_TMP+1,Y
			SBCA	FSCI_CONVERT_TMP,Y
			STD	FSCI_CONVERT_DIVISOR_MSW,Y
			
			;Add shifter to result (SP in Y)
			LDD	FSCI_CONVERT_SHIFTER,Y	
			ADDD	FSCI_CONVERT_RESULT,Y
			STD	FSCI_CONVERT_RESULT,Y

			;Load original dividend (SP in Y)
			LDD	FSCI_CONVERT_DIVIDEND_MSW,Y
			LDX	FSCI_CONVERT_DIVIDEND_LSW,Y
		
			;Rerun outer loop with new divisor (SP in Y, dividend in D:X)
			JOB	FSCI_CONVERT_2	

			;Terminate (SP in Y)
FSCI_CONVERT_7		MOVW	#$0000, FSCI_CONVERT_DIVIDEND_LSW,Y	;clean up result
			SSTACK_DEALLOC	10 				;free temporary variables
			JOB	FSCI_CONVERT_9	
				
			;16-bit dividend (dividend in X)
;  	                +--------------+--------------+          
;            SSTACK_SP->|     D (dividend/result MSW) | +$00       
;  	                +--------------+--------------+	     
;                       |     X (dividend/result LSW) | +$02         
;  	                +--------------+--------------+	     
;                       |              Y              | +$04         
;  	                +--------------+--------------+	
			;1st division: divisor(MSB)/dividend => result(MSB) 
FSCI_CONVERT_8		LDD	#(FSCI_DIVISOR>>16)
			IDIV					;D/X=>X; remainder=D
			LDY	SSTACK_SP
			STX	0,Y
			;2nd division: remainder:divisor(LSB)/dividend => result(LSB) 
			LDX	2,Y	
			TFR	D,Y
			LDD	#(FSCI_DIVISOR>>$FF)
			EDIV					;Y:D/X=>Y; remainder=>D
			LDX	SSTACK_SP
			STY	0,X

			;Restore registers 
FSCI_CONVERT_9	SSTACK_PULDXY
			SSTACK_RTS

;Exceptions:
;===========
;Standard exceptions
FSCI_THROW_PSOF		EQU	FMEM_THROW_PSOF			;stack overflow
FSCI_THROW_PSUF		EQU	FMEM_THROW_PSUF			;stack underflow
FSCI_THROW_INVALNUM	FEXCPT_THROW	FEXCPT_EC_INVALNUM	;invalid numeric argument
	
FSCI_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FSCI_TABS_START
;Baud rate change message 
FSCI_INSTR_MSG		FCS	"Please adjust the baud rate and hit <SPACE>!"

FSCI_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FSCI_WORDS_START
	
;BAUD! ( ud -- ) S12CForth extension
;Sets the baud RATE to ud.
;Throws:
;"Parameter stack underflow"
;"Invalid numeric argument"
;
			ALIGN	1
NFA_BAUD_STORE		FHEADER, "BAUD!", FSCI_PREV_NFA, COMPILE
CFA_BAUD_STORE		DW	CF_BAUD_STORE
CF_BAUD_STORE		PS_CHECK_UF	2, CF_BAUD_STORE_PSUF ;check for underflow (PSP -> Y)
			;Pull baud rate from PSP
			LDD	2,Y+
			LDX	2,Y+
			STY	PSP
			;Convert baud rate into SCIBD value 
			SSTACK_JOBSR	FSCI_CONVERT		 ;(SSTACK: 18 bytes)
			;Check SCIBD value
			TBNE	D, CF_BAUD_STORE_INVALNUM	;the MSW must be zero
			TBEQ	X, CF_BAUD_STORE_INVALNUM	;the LSW must not
			CPX	#$2000
			BHS	CF_BAUD_STORE_INVALNUM    	;the LSW must only be 13 bit wide
			;Change baud rate (SCIBD value in X)
			TFR	X,D
			SCI_BAUD
			;Wait until a " " (space) has been correctly received
CF_BAUD_STORE_1		SCI_RX				;get one byte
			BITA	#(NF|FE|PE) 		;check for: noise, frame errors, parity errors
			BNE	CF_BAUD_STORE_1		;try another character
			CMPB	#" "			;check if a " " has been received
			BNE	CF_BAUD_STORE_1
			;Done
			NEXT

CF_BAUD_STORE_PSUF	JOB	FSCI_THROW_PSUF
CF_BAUD_STORE_INVALNUM	JOB	FSCI_THROW_INVALNUM

;BAUD@ (  -- ud ) S12CForth extension
;Returns the current baud rate.
;been set.
;Throws:
;"Parameter stack overflow"
;
			ALIGN	1
NFA_BAUD_FETCH		FHEADER, "BAUD@", NFA_BAUD_STORE, COMPILE
CFA_BAUD_FETCH		DW	CF_BAUD_FETCH
CF_BAUD_FETCH		PS_CHECK_OF	2, CF_BAUD_FETCH_PSOF ;check for underflow (PSP-4 -> Y)
			;Get SCIBD value 
			CLRA
			CLRB
			LDX	SCIBDH
			;Convert SCIBD value into baud rate (PSP-4 -> Y)
			SSTACK_JOBSR	FSCI_CONVERT		 ;(SSTACK: 18 bytes)
			;Push baud rate onto PS   
			STD	0,Y
			STX	2,Y
			STY	PSP
			;Done
			NEXT

CF_BAUD_FETCH_PSOF	JOB	FSCI_THROW_PSOF
	
FSCI_WORDS_END		EQU	*
FSCI_LAST_NFA		EQU	NFA_BAUD_FETCH
