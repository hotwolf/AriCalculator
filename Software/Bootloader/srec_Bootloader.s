#ifndef SREC_COMPILED
#define	SREC_COMPILED	
;###############################################################################
;# AriCalculator - Bootloader - S-Record Parser                                #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU family.   #
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
;#    This part of the AriCalculator's bootloader contains the S-Record        #
;#    parser.                                                                  #
;#                                                                             #
;# S-Record format:                                                            #
;#                                                                             #
;#  +--+--+--+--+--+-//-+--+--+-//-+--+--+--+                                  #
;#  |Type |Size | Address  |   Data   |Csum |				       #
;#  +--+--+--+--+--+-//-+--+--+-//-+--+--+--+                                  #
;#                                                                             #
;#  Type:    S0 -> Header                                                      #
;#           S1 -> Data (16-bit address)                                       #
;#           S2 -> Data (24-bit address)                                       #
;#           S3 -> Data (32-bit address)                                       #
;#           S5 -> Count of previous S1/S2/S3-records in 16-bit Address field  #
;#           S6 -> Count of previous S1/S2/S3-records in 24-bit Address field  #
;#           S7 -> Termination (32-bit address)                                #
;#           S8 -> Termination (24-bit address)                                #
;#           S9 -> Termination (16-bit address)                                #
;#  Size:    Combined byte count of Address, Data, and Csum field.             #
;#  Address: Address field (2, 3, or 4 byte wide)                              #
;#  Data:    Data field                                                        #
;#  Csum:    Checksum over Count, Address, and Data field (255 - (sum%256))    #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    July 10, 2017                                                            #
;#      - Initial release                                                      #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;#NVM phrase size
#ifndef SREC_PHRASE_SIZE	
SREC_PHRASE_SIZE	EQU	8 		;default is 8 bytes
#endif	

;#Address width
#ifndef SREC_ADDR_WIDTH	
SREC_ADDR_WIDTH		EQU	18 		;default is 10 bit
#endif	
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Error codes
SREC_ERR_RX		EQU	$80 		;communication error
SREC_ERR_FORMAT		EQU	$40 		;format error
SREC_ERR_CHECKSUM	EQU	$20 		;CRC error
SREC_ERR_COUNT		EQU	$10 		;count error

;#C0 characters
SREC_C0_LF		EQU	$0A 		;line feed

;#Upper address limit
SREC_MAX_ADDR		EQU	$40_0000	;highest address
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef SREC_VARS_START_LIN
			ORG 	SREC_VARS_START, SREC_VARS_START_LIN
#else
			ORG 	SREC_VARS_START
SREC_VARS_START_LIN	EQU	@			
#endif	
			ALIGN	1

SREC_COUNT		DS	4 		;S-record count (S0=0, S1/S2/S3=+1) 
SREC_ADDR		DS	4		;address field
SREC_TYPE		DS	1 		;current type 
SREC_BYTECOUNT		DS	1		;byte count
SREC_CHECKSUM		DS	1		;checksum
		
SREC_VARS_END		EQU	*
SREC_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SREC_INIT, 0
#emac

;#Parse S-Records - blocking
; args:   none
; result: A:      error code
; SSTACK: 21 bytes
;         B, X and Y are preserved
#macro	SREC_PARSE_SREC, 0
			SSTACK_JOBSR	SREC_PARSE_SREC, 21
#emac

;#Parse data field - blocking
; args:   none
; result: A:      error code
;         B:      data
;         C-flag: set if data is valid
; SSTACK: 14 bytes
;         X and Y are preserved
#macro	SREC_PARSE_DATA, 0
			SSTACK_JOBSR	SREC_PARSE_DATA, 14
#emac
	
;#Parse header - blocking
; args:   none
; result: A: error code
;         B: type
; SSTACK: 16 bytes
;         X and Y are preserved
#macro	SREC_PARSE_HEADER, 0
			SSTACK_JOBSR	SREC_PARSE_HEADER, 16
#emac

;#Skip to next type field - blocking
; args:   none
; result: A: error code
;         B: type
; SSTACK: 9 bytes
;         X and Y are preserved
#macro	SREC_SKIP_TYPE, 0
			SSTACK_JOBSR	SREC_SKIP_TYPE, 12
#emac

;#Skip to the next line - blocking
; args:   none
; result: A: error code
; SSTACK: 10 bytes
;         B, X, and Y are preserved
;#macro	SREC_SKIP_NL, 0	
;			SSTACK_JOBSR	SREC_SKIP_NL,10
;#emac

;#Receive one data word - blocking
; args:   none
; result: A: error code
;         X: word
; SSTACK: 15 bytes
;         X and Y are preserved
;#macro	SREC_RX_WORD, 0			
;			SSTACK_JOBSR	SREC_RX_WORD, 15		
;#emac

;#Receive one data byte - blocking
; args:   none
; result: A: error code
;         B: byte
; SSTACK: 12 bytes
;         X and Y are preserved
#macro	SREC_RX_BYTE, 0			
			SSTACK_JOBSR	SREC_RX_BYTE, 12		
#emac

;#Receive one data nibble - blocking
; args:   none
; result: A: error code
;         B: hexadecimal digit
; SSTACK: 9 bytes
;         X and Y are preserved
#macro	SREC_RX_NIBBLE, 0
			SSTACK_JOBSR	SREC_RX_NIBBLE, 9
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef SREC_CODE_START_LIN
			ORG 	SREC_CODE_START, SREC_CODE_START_LIN
#else
			ORG 	SREC_CODE_START
SREC_CODE_START_LIN	EQU	@	
#endif
	
;#Parse S-Records - blocking
; args:   none
; result: A:      error code
; SSTACK: 21 bytes
;         B, X and Y are preserved
SREC_PARSE_SREC		EQU	*
			;Save registers 
			PSHX						;save X
			PSHB						;save B
			;Parse header 
SREC_PARSE_SREC_1	SREC_PARSE_HEADER 				;(SSTACK: 16 bytes)
			TBNE	A, SREC_PARSE_SREC_4 			;error (fail)
			;Determine srecord handler (type in D)
			LSLB						;jump table offset -> D
			JMP [D,PC] 					;table lookup
			DW	SREC_PARSE_SREC_5 			;S0 - print header
			DW	SREC_PARSE_SREC_8 			;S1 - flash data
			DW	SREC_PARSE_SREC_8 			;S2 - flash data
			DW	SREC_PARSE_SREC_8 			;S3 - flash data
			DW	SREC_PARSE_SREC_2 			;format error
			DW	SREC_PARSE_SREC_12 			;S5 - check count
			DW	SREC_PARSE_SREC_12 			;S6 - check count
			DW	SREC_PARSE_SREC_14 			;S7 - last S-record
			DW	SREC_PARSE_SREC_14 			;S8 - last S-record
			DW	SREC_PARSE_SREC_14 			;S9 - last S-record 
			;Format error
SREC_PARSE_SREC_2	LDAA	#SREC_ERR_FORMAT 			;return format error
			JOB	SREC_PARSE_SREC_4 			;done
			;Checksum error
SREC_PARSE_SREC_3	LDAA	#SREC_ERR_CHECKSUM 			;return checksum error			
SREC_PARSE_SREC_4	SSTACK_PREPULL	5 				;check SSTACK
			PULB						;restore B
			PULX						;restore X
			RTS						;done			
			;S0 Record
			;--------- 
SREC_PARSE_SREC_5	MOVW	#0000, SREC_COUNT 			;reset srecord count
			MOVW	#0000, SREC_COUNT+2 			;
			LDX	#SREC_MSG_S0_HEADER 			;message header -> X
			STRING_PRINT_BL					;print message header
SREC_PARSE_SREC_6	SREC_PARSE_DATA					;data byte -> B (SSTACK: 14 bytes)
			TBNE	A, SREC_PARSE_SREC_4 			;error (fail)
			BCC	SREC_PARSE_SREC_7 			;end of S-record reached
			STRING_PRINTABLE 				;make sure character is printable
			SCI_TX_BL 					;print character
			JOB	SREC_PARSE_SREC_6 			;get next byte
SREC_PARSE_SREC_7	LDX	#STRING_STR_NL 				;line break -> X
			STRING_PRINT_BL					;print line break
			JOB	SREC_PARSE_SREC_1 			;parse next header
			;S1/S2/S3 Record 
			;--------------- 
SREC_PARSE_SREC_8	LDY	SREC_ADDR 				;upper address word -> Y
			;CPY	#(SREC_MAX_ADDR>>16) 			;check address range
			;BHS	SREC_PARSE_SREC_2 			;address range exeeded
			LDX	SREC_ADDR+2 				;lower address word -> X
			NVM_SET_ADDR_BL 					;set new NVM address
SREC_PARSE_SREC_9	SREC_PARSE_DATA					;data byte -> B (SSTACK: 14 bytes)
			TBNE	A, SREC_PARSE_SREC_4 			;error (fail)
			BCC	SREC_PARSE_SREC_10 			;end of S-record reached
			NVM_PGM_BYTE_BL					;queue data byte for programming
			JOB	SREC_PARSE_SREC_9 			;get next byte
SREC_PARSE_SREC_10	LDAB	#"*" 					;progress char -> B
			SCI_TX_BL 					;print progress char
			LDD 	SREC_COUNT+2 				;S-Record count (lower word) -> D
			ADDD	#1 					;increment S-Record count (lower word)
			STD	SREC_COUNT+2 				;update	S-Record count (lower word)
			LDD	SREC_COUNT				;S-Record count (upper word) -> D
			ADCA	#$00 					;increment S-Record count (upper word)
			ADCB	#$00	   				;
			STD	SREC_COUNT				;S-Record count (upper word) -> D
			LDAB	SREC_COUNT+3 				;S-Record count (lowest byte) -> B
			BITB	#$3F 					;;check for multiples of 64
			BNE	SREC_PARSE_SREC_11 			;
			LDX	#STRING_STR_NL 				;line break -> X
			STRING_PRINT_BL					;print line break
SREC_PARSE_SREC_11	;LDY	SREC_ADDR				;debug: address -> Y:X
			;LDX	SREC_ADDR+2				;debug: 
			;LDD	#$0610					;debug: alignment:base -> D
			;NUM_PRINT_ZUD_BL				;debug: print address
			;LDX	#STRING_STR_NL 				;debug: line break -> X
			;STRING_PRINT_BL				;debug: print line break
			JOB	SREC_PARSE_SREC_1 			;parse next header
			;S5/S6 Record 
			;------------ 
SREC_PARSE_SREC_12	SREC_PARSE_DATA					;data byte -> B (SSTACK: 14 bytes)
			TBNE	A, SREC_PARSE_SREC_4 			;error (fail)
			BCS	SREC_PARSE_SREC_2 			;error (fail)
			LDX	SREC_ADDR+2 				;S-Record count (lower word) -> X
			CPX	SREC_COUNT+2 				;check S-Record count (low word)
			BNE	SREC_PARSE_SREC_13 			;mismatch
			LDX	SREC_ADDR 				;S-Record count (upper word) -> X
			CPX	SREC_COUNT 				;check S-Record count (low word)
			BEQ	SREC_PARSE_SREC_1 			;parse next header
SREC_PARSE_SREC_13	LDAA	#SREC_ERR_COUNT 			;return count error
			JOB	SREC_PARSE_SREC_4 			;done
			;S7/S8/S9 Record 
			;--------------- 
SREC_PARSE_SREC_14	SREC_PARSE_DATA					;data byte -> B (SSTACK: 14 bytes)
			TBNE	A, SREC_PARSE_srec_4 			;error (fail)
			BCS	SREC_PARSE_SREC_2 			;format error (fail)
			NVM_FLUSH_BL 					;program remaining data
			CLRA						;signal no errors
			JOB	SREC_PARSE_SREC_4 			;done

;#Parse data field - blocking
; args:   none
; result: A:      error code
;         B:      data
;         C-flag: set if data is valid
; SSTACK: 14 bytes
;         X and Y are preserved
SREC_PARSE_DATA		EQU	*
			;Get data byte 
			SREC_RX_BYTE 					;count -> B, error code in A (SSTACK: 12 bytes)
			TBNE	A, SREC_PARSE_DATA_2 			;error (fail)
			;Update checksum (data in B)
			LDAA	SREC_CHECKSUM 				;old checksum -> A
			ABA						;new checksum -> A
			;Update count (data in B)
			DEC	SREC_BYTECOUNT 				;decrement byte count
			BEQ	SREC_PARSE_DATA_1 			;checksum field reached
			;Return data (data in B, checksum in A) 
			STAA	SREC_CHECKSUM 				;update checksum
			CLRA						;no errors
			SSTACK_PREPULL	2 				;check SSTACK
			SEC						;data is valid
			RTS						;done			
			;Verify checksum (data in B, checksum in A) 
SREC_PARSE_DATA_1	IBNE	A, SREC_PARSE_DATA_3 			;checksum error
			CLRA						;no error
SREC_PARSE_DATA_2	SSTACK_PREPULL	2 				;check SSTACK
			CLC						;no valid data to return
			RTS						;done			
			;Checksum error
SREC_PARSE_DATA_3	LDAA	#SREC_ERR_CHECKSUM	  		;return checksum erreor
			JOB	SREC_PARSE_DATA_2 			;done
	
;#Parse header - blocking
; args:   none
; result: A: error code
;         B: type
; SSTACK: 16 bytes
;         X and Y are preserved
SREC_PARSE_HEADER	EQU	*
			;Save registers 
			PSHX						;save X
			;Clear S-record information 
			CLRA						;zero -> D
			CLRB						;
			STD	SREC_ADDR 				;clear address
			STD	SREC_ADDR+2 				;
			STD	SREC_TYPE 				;clear type and byte count
			;Skip to the beginning of the next S-record 
			SREC_SKIP_TYPE 					;type -> B, error code -> A (SSTACK: 12 bytes)	
			TBNE	A, SREC_PARSE_HEADER_9 			;communication error (fail)
			TFR	B, X  					;type -> X
			;Get byte count (type in X)
			SREC_RX_BYTE 					;count -> B, error code in A (SSTACK: 12 bytes)
			TBNE	A, SREC_PARSE_HEADER_8 			;error (fail)
			STAB	SREC_CHECKSUM 				;set initial checksum
			EXG	B, X	  				;byte count -> X, type -> B
			;Get address (byte count in X, type in D)
			LSLB						;jump table offset -> D
			JMP	[D,PC] 					;jump table
			DW	SREC_PARSE_HEADER_6 			;S0 -> 16bit address
			DW	SREC_PARSE_HEADER_5 			;S1 -> 16bit address
			DW	SREC_PARSE_HEADER_3 			;S2 -> 24bit address
			DW	SREC_PARSE_HEADER_2 			;S3 -> 32bit address
			DW	SREC_PARSE_HEADER_1 			;S4 -> format error
			DW	SREC_PARSE_HEADER_6 			;S5 -> 16bit address
			DW	SREC_PARSE_HEADER_3 			;S6 -> 24bit address
			DW	SREC_PARSE_HEADER_2 			;S7 -> 32bit address
			DW	SREC_PARSE_HEADER_3 			;S8 -> 24bit address
			DW	SREC_PARSE_HEADER_6 			;S9 -> 16bit address
			;Format error
SREC_PARSE_HEADER_1	LDAA	#SREC_ERR_FORMAT
			JOB	SREC_PARSE_HEADER_8
			;32bit address (byte count in X)
SREC_PARSE_HEADER_2	LEAX	-4,X 					;subtract address width
			TFR	X, B 					;byte count -> B
			STAB	SREC_BYTECOUNT 				;store byte count	
			SREC_RX_BYTE 					;address byte -> B, error code in A (SSTACK: 12 bytes)
			TBNE	A, SREC_PARSE_HEADER_8 			;error (fail)
			TBA						;address byte -> A
			ADDA	SREC_CHECKSUM				;new checksum -> A
			STAA	SREC_CHECKSUM				;update checksum
			STAB	SREC_ADDR 				;store address byte
			JOB	SREC_PARSE_HEADER_4 			;get remaining address bytes
			;24bit address (byte count in X)
SREC_PARSE_HEADER_3	LEAX	-3,X 					;subtract address width
			TFR	X, B 					;byte count -> B
			STAB	SREC_BYTECOUNT 				;store byte count				
SREC_PARSE_HEADER_4	SREC_RX_BYTE 					;address byte -> B, error code in A (SSTACK: 12 bytes)
			TBNE	A, SREC_PARSE_HEADER_8 			;error (fail)
			TBA						;address byte -> A
			ADDA	SREC_CHECKSUM				;new checksum -> A
			STAA	SREC_CHECKSUM				;update checksum
			STAB	SREC_ADDR+1 				;store address byte
			JOB	SREC_PARSE_HEADER_7 			;get remaining address bytes
			;16bit address (byte count in X)
SREC_PARSE_HEADER_5	MOVB	#$3F, SREC_ADDR+1 			;default offset
SREC_PARSE_HEADER_6	LEAX	-2,X 					;subtract address width
			TFR	X, B 					;byte count -> B
			STAB	SREC_BYTECOUNT 				;store byte count	
SREC_PARSE_HEADER_7	SREC_RX_BYTE 					;count -> B, error code in A (SSTACK: 12 bytes)
			TBNE	A, SREC_PARSE_HEADER_8 			;error (fail)
			TBA						;address byte -> A
			ADDA	SREC_CHECKSUM				;new checksum -> A
			STAA	SREC_CHECKSUM				;update checksum
			STAB	SREC_ADDR+2 				;store address byte
			SREC_RX_BYTE 					;count -> B, error code in A (SSTACK: 12 bytes)
			TBNE	A, SREC_PARSE_HEADER_8 			;error (fail)
			TBA						;address byte -> A
			ADDA	SREC_CHECKSUM				;new checksum -> A
			STAA	SREC_CHECKSUM				;update checksum
			STAB	SREC_ADDR+3 				;store address byte
			;Return results 		
			CLRA						;return no errors
SREC_PARSE_HEADER_8	LDAB	SREC_TYPE 				;return type
SREC_PARSE_HEADER_9	SSTACK_PREPULL	4 				;check SSTACK
			PULX						;restore B
			RTS						;done			
	
;#Skip to next type field - blocking
; args:   none
; result: A: error code
;         B: type
; SSTACK: 9 bytes
;         X and Y are preserved
SREC_SKIP_TYPE		EQU	*	
			;Receive first byte
SREC_SKIP_TYPE_1	SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
			ANDA	#(SWOR|OR|NF|FE|PF) 			;check for communication error
			BNE	SREC_SKIP_TYPE_4	 		;communication error (fail)			
			;Check for "S" character (data in B, zero in A)
			CMPB	#"s" 					;check for lower case "s"
			BEQ	SREC_SKIP_TYPE_2	 		;receive second byte
			CMPB	#"S" 					;check for upper case "S"
			BNE	SREC_SKIP_TYPE_6	 		;check for line xbreak
			;Receive second byte
SREC_SKIP_TYPE_2	SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
			ANDA	#(SWOR|OR|NF|FE|PF) 			;check for communication error
			BNE	SREC_SKIP_TYPE_4	 		;communication error (fail)			
			;Check for valid type (data in B, zero in A)
			CMPB	#"0" 					;check lower boundary
			BLO	SREC_SKIP_TYPE_5	 		;skip to next line
			CMPB	#"9" 					;check upper boundary
			BHI	SREC_SKIP_TYPE_5	 		;skip to next line
			CMPB	#"4" 					;check upper boundary
			BEQ	SREC_SKIP_TYPE_5 			;skip to next line
			ANDB	#$0F 					;mask range
			STAB	SREC_TYPE 				;update current type 
			;Return result (type in B, error code in A)
SREC_SKIP_TYPE_3	SSTACK_PREPULL	2 				;check SSTACK
			RTS						;done			
			;Communication error
SREC_SKIP_TYPE_4	LDD	#(SREC_ERR_RX<<8) 			;set error code
			JOB	SREC_SKIP_TYPE_3	 		;done
			;Skip to next line 
SREC_SKIP_TYPE_5	SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
			ANDA	#(SWOR|OR|NF|FE|PF) 			;check for communication error
			BNE	SREC_SKIP_TYPE_4	 		;communication error (fail)			
			;Check for line break (data in B, zero in A)
SREC_SKIP_TYPE_6	CMPB	#SREC_C0_LF 				;check for line feed
			BNE	SREC_SKIP_TYPE_5 			;skip
			JOB	SREC_SKIP_TYPE_1			;Parse type field
	
;#Skip to the next line - blocking
; args:   none
; result: A: error code
; SSTACK: 10 bytes
;         B, X, and Y are preserved
;SREC_SKIP_NL		EQU	*	
;			;Save registers
;			PSHB						;save B
;			;Receive byte
;SREC_SKIP_NL_1		SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
;			ANDA	#(SWOR|OR|NF|FE|PF) 			;check for communication error
;			BNE	SREC_SKIP_NL_3				;communication error (fail)			
;			;Check for LF (data in B, zero in A)
;			CMPB	#SREC_C0_LF 				;check for line feed
;			BNE	SREC_SKIP_NL_1 				;skip
;			;Return result (byte in B, error code in A)
;SREC_SKIP_NL_2		SSTACK_PREPULL	3 				;check SSTACK
;			PULB						;restore B
;			RTS						;done
;			;Communication error
;SREC_SKIP_NL_3		LDAB	#SREC_ERR_RX 				;return error
;			JOB	SREC_SKIP_NL_2 				;return result

;#Receive one data word - blocking
; args:   none
; result: A: error code
;         X: word
; SSTACK: 15 bytes
;         X and Y are preserved
;SREC_RX_WORD		EQU	*			
;			;Save registers  
;			PSHB						;save B
;			;Receive first byte
;			SREC_RX_BYTE 					;data -> B, error code -> A (SSTACK: 12 bytes)
;SREC_RX_WORD_1		STX	#$0000		 			;clear X
;			TBNE	A, SREC_RX_WORD_2 			;communication error (fail)
;			TFR	B, X 					;high byte -> X	
;			;Receive second byte (high byte in X)
;			SREC_RX_BYTE 					;data -> B, error code -> A (SSTACK: 12 bytes)
;			TBNE	A, SREC_RX_WORD_1 			;communication error (fail)
;			EXG	X, A 					;word -> D, zero -> X
;			EXG	X, D					;word -> X, zero -> D
;			;Return result (word in X, error code in A)
;SREC_RX_WORD_2		SSTACK_PREPULL	3 				;check SSTACK
;			PULB						;restore B
;			RTS						;done			

;#Receive one data byte - blocking
; args:   none
; result: A: error code
;         B: byte
; SSTACK: 12 bytes
;         X and Y are preserved
SREC_RX_BYTE		EQU	*			
			;Reserve temporary stack space
			LEAS	-1,SP 					;allocate stack
			;Receive first nibble
			SREC_RX_NIBBLE 					;data -> B, error code -> A (SSTACK: 9 bytes)
			TBNE	A, SREC_RX_BYTE_1 			;error (fail)
			;Shift nibble (nibble in B, zero in A)
			LSLB						;shift to upper nibble
			LSLB						;
			LSLB						;
			LSLB						;
			STAB	0,SP					;store nibble
			;Receive second nibble
			SREC_RX_NIBBLE 					;data -> B, error code -> A (SSTACK: 9 bytes)
			TBNE	A, SREC_RX_BYTE_1 			;error (fail)
			ORAB	0,SP 					;assemble data byte
			;Return result (byte in B, error code in A)
SREC_RX_BYTE_1		SSTACK_PREPULL	3 				;check SSTACK
			LEAS	1,SP 					;free stack
			RTS						;done

;#Receive one data nibble - blocking
; args:   none
; result: A: error code
;         B: hexadecimal digit
; SSTACK: 9 bytes
;         X and Y are preserved
SREC_RX_NIBBLE		EQU	*
			;Receive byte
			SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
			ANDA	#(SWOR|OR|NF|FE|PF) 			;check for communication error
			BNE	SREC_RX_NIBBLE_4 			;communication error (fail)			
			;Check decimal range (data in B, zero in A)
			CMPB	#"0" 					;check lower boundary
			BLO	SREC_RX_NIBBLE_5 			;format error
			CMPB	#"9" 					;check upper boundary
			BLS	SREC_RX_NIBBLE_2 			;digit found
			;Check upper case range (data in B, zero in A)			
			CMPB	#"A" 					;check lower boundary
			BLO	SREC_RX_NIBBLE_5 			;format error
			CMPB	#"F" 					;check upper boundary
			BLS	SREC_RX_NIBBLE_1 			;digit found
			;Check lower case range (data in B, zero in A)			
			CMPB	#"a" 					;check lower boundary
			BLO	SREC_RX_NIBBLE_5 			;format error
			CMPB	#"f" 					;check upper boundary
			BHI	SREC_RX_NIBBLE_5 			;format error
SREC_RX_NIBBLE_1	ADDB	#9 					;addd offset
SREC_RX_NIBBLE_2	ANDB	#$0F 					;mask range
			;Return result (digit in B, error code in A)
SREC_RX_NIBBLE_3	SSTACK_PREPULL	2 				;check SSTACK
			RTS						;done
			;Communication error
SREC_RX_NIBBLE_4	LDD	#(SREC_ERR_RX<<8) 			;set error code
			JOB	SREC_RX_NIBBLE_3 			;done
			;Format error
SREC_RX_NIBBLE_5	LDD	#(SREC_ERR_FORMAT<<8) 			;set error code
			JOB	SREC_RX_NIBBLE_3 			;done
	
SREC_CODE_END		EQU	*	
SREC_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef SREC_TABS_START_LIN
			ORG 	SREC_TABS_START, SREC_TABS_START_LIN
#else
			ORG 	SREC_TABS_START
SREC_TABS_START_LIN	EQU	@	
#endif	

SREC_MSG_S0_HEADER	STRING_NL_NONTERM
			FCS	"Uploading: "

SREC_TABS_END		EQU	*
SREC_TABS_END_LIN	EQU	@
#endif
