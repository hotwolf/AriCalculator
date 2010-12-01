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


#macro	FSCI_LSLDX, 0


#emac
	
#macro	FSCI_LSLRX, 0


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
FSCI_CONVERT_DIVISOR_LSW	EQU	$00
FSCI_CONVERT_DIVISOR_MSW	EQU	$02
FSCI_CONVERT_DIVIDEND_LSW	EQU	$04
FSCI_CONVERT_DIVIDEND_MSW	EQU	$06
FSCI_CONVERT_SHIFTER		EQU	$08
FSCI_CONVERT_RESULT		EQU	$0A
			;Initialize temporary registers (SP in Y, dividend in D:X)
			MOVW	#$0000, FSCI_CONVERT_SHIFTER,Y
			MOVW	#$0000, FSCI_CONVERT_RESULT,Y
			MOVW	#(FSCI_DIVISOR>>16), FSCI_CONVERT_DIVISOR_MSW,Y
			MOVW	#FSCI_DIVISOR,       FSCI_CONVERT_DIVISOR_LSW,Y
			MOVW	#$0000, FSCI_CONVERT_DIVIDEND_MSW,Y
			MOVW	#$0000, FSCI_CONVERT_DIVIDEND_LSW,Y
			;Check if shifted dividend is greater than the divisor (SP in Y, shifted dividend in D:X)
FSCI_CONVERT_1		CPD	FSCI_CONVERT_DIVISOR_MSW,Y	
			BHI	FSCI_CONVERT_4 			;shifted dividend > divisor
			BLO	FSCI_CONVERT_2			;shifted dividend < divisor
			CPX	FSCI_CONVERT_DIVISOR_LSW,Y
			BHI	FSCI_CONVERT_4 			;dividend > divisor
			;Shifted dividend < divisor (SP in Y, shifted dividend in D:X)
FSCI_CONVERT_2		STD	FSCI_CONVERT_DIVIDEND_MSW,Y 	;store shifted dividend
			STX	FSCI_CONVERT_DIVIDEND_LSW,Y
			LDD	FSCI_CONVERT_SHIFTER,Y 		;update shifter
			LSLD
			BNE	FSCI_CONVERT_3
			LDD	#$0001
FSCI_CONVERT_3		STD	FSCI_CONVERT_SHIFTER,Y
			TFR	X,D 				;left-shift dividend
			LSLD
			TFR	D,X
			LDD	FSCI_CONVERT_DIVIDEND_MSW,Y
			ROLB
			ROLA
			JOB	FSCI_CONVERT_1
			;Shifted dividend > divisor (SP in Y)
FSCI_CONVERT_4		LDD	FSCI_CONVERT_RESULT,Y 		;add shifter to result
			ADDD	FSCI_CONVERT_SHIFTER,Y
			STD	FSCI_CONVERT_RESULT,Y
			LDD	FSCI_CONVERT_DIVISOR_LSW,Y 	;subtract dividend from divisor
			SUBD	FSCI_CONVERT_DIVIDEND_LSW,Y
			LDD	FSCI_CONVERT_DIVISOR_MSW,Y
			SBCB	FSCI_CONVERT_DIVIDEND_MSW+1,Y
			SBCA	FSCI_CONVERT_DIVIDEND_MSW,Y
			STD	FSCI_CONVERT_DIVISOR_MSW,Y
			LDD	FSCI_CONVERT_DIVIDEND_MSW,Y 	;dividend -> D:X
			LDX	FSCI_CONVERT_DIVIDEND_LSW,Y
			;Right-shift dividend (SP in Y, dividend in D:X) 
FSCI_CONVERT_5		LSRD					;shift MSW
			STD	FSCI_CONVERT_DIVIDEND_MSW,Y	;store MSW
			TFR	X,D				;shift LSW
			RORA
			RORB
			TFR	D,X
			STX	FSCI_CONVERT_DIVIDEND_LSW,Y	;store LSW
			LDD	FSCI_CONVERT_SHIFTER,Y		;update shifter
			LSRD
			STD	FSCI_CONVERT_SHIFTER,Y
			LDD	FSCI_CONVERT_DIVIDEND_MSW,Y
			;Terminate if shifted dividend is zero (SP in Y, dividend in D:X)
			TBNE	D, FSCI_CONVERT_6		;dividend is not zero
			TBEQ	X, FSCI_CONVERT_7		;dividend is zero
			;Check if dividend < divisor (SP in Y, dividend in D:X)
FSCI_CONVERT_6		CPD	FSCI_CONVERT_DIVISOR_MSW,Y
			BLO	FSCI_CONVERT_4 			;shifted dividend < divisor
			BHI	FSCI_CONVERT_5			;shifted dividend > divisor
			CPX	FSCI_CONVERT_DIVISOR_MSW,Y
			BHI	FSCI_CONVERT_5			;shifted dividend > divisor
			JOB	FSCI_CONVERT_4 			;shifted dividend <= divisor
			;Prepare result (SP in Y)
FSCI_CONVERT_7		;MOVW	#$0000, FSCI_CONVERT_SHIFTER,Y	
			SSTACK_DEALLOC	8 				;free temporary variables
			JOB	FSCI_CONVERT_9	
				
			;16-bit dividend (dividend in X)
;  	                +--------------+--------------+          
;            SSTACK_SP->|     D (dividend/result MSW) | +$00       
;  	                +--------------+--------------+	     
;                       |     X (dividend/result LSW) | +$02         
;  	                +--------------+--------------+	     
;                       |              Y              | +$04         
;  	                +--------------+--------------+
FSCI_CONVERT_D		EQU	$00
FSCI_CONVERT_X		EQU	$02
FSCI_CONVERT_Y		EQU	$04
			;Check if divident ia zero (dividend in X)
FSCI_CONVERT_8		TBEQ	X, FSCI_CONVERT_10 		;division by zero (return zero)	
			;1st division: divisor(MSB)/dividend => result(MSB) 
			LDD	#(FSCI_DIVISOR>>16)
			IDIV					;D/X=>X; remainder=D
			LDY	SSTACK_SP
			STX	FSCI_CONVERT_D,Y
			;2nd division: remainder:divisor(LSB)/dividend => result(LSB) 
			LDX	FSCI_CONVERT_X,Y	
			TFR	D,Y
			LDD	#FSCI_DIVISOR
			EDIV					;Y:D/X=>Y; remainder=>D
			LDX	SSTACK_SP
			STY	FSCI_CONVERT_X,X
			;Restore registers 
FSCI_CONVERT_9		SSTACK_PULDXY
			SSTACK_RTS
			;Division by zero
FSCI_CONVERT_10		LDY	SSTACK_SP
			MOVW	#$FFFF, FSCI_CONVERT_D,Y
			MOVW	#$FFFF, FSCI_CONVERT_X,Y
			JOB	FSCI_CONVERT_9

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
	
;BAUD! ( ud " " -- ) S12CForth extension CHECK!
;Sets the baud RATE to ud. As soon as the word is executed, it expects to
;receive a space character a new baud rate.
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
