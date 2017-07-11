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
;###############################################################################
;# Version History:                                                            #
;#    July 10, 2017                                                            #
;#      - Initial release                                                      #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef SREC_VARS_START_LIN
			ORG 	SREC_VARS_START, SREC_VARS_START_LIN
#else
			ORG 	SREC_VARS_START
SREC_VARS_START_LIN	EQU	@			
#endif	

SREC_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1

SREC_TYPE		DS	1 		;S-record type 
SREC_COUNT		DS	1		;S-record count
	
SREC_ADDR		EQU	*		;address field
SREC_DATA		DS 	254		;address and data fields
SREC_MAX_BYTE_COUNT	EQU	1+*-SREC_ADDR	;max. byte count

SREC_COUNT		DS	3 		;S-Record count
	
SREC_VARS_END		EQU	*
SREC_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SREC_INIT, 0
#emac

;#Receive receive one complete S-record - blocking
; args:   none
; result: C-flag: set on success	
; SSTACK: 23 bytes
;         X, Y and D are preserved
#macro	SREC_RX, 0
			SSTACK_JOBSR	SREC_RX, 23
#emac

;#Receive receive one data byte - blocking
; args:   none
; result: B:      data byte
;         C-flag: set on success	
; SSTACK: 14 bytes
;         A, X and Y are preserved
#macro	SREC_RX_BYTE, 0
			SSTACK_JOBSR	SREC_RX, 14
#emac

;#Receive receive one data nibble - blocking
; args:   none
; result: B:      hexadecimal digit
;         C-flag: set on success	
; SSTACK: 11 bytes
;         A, X and Y are preserved
#macro	SREC_RX_NIBBLE, 0
			SSTACK_JOBSR	SREC_RX, 11
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



;#Parse S-record string - blocking
; args:   none
; result: C-flag: set on success	
; SSTACK: 32 bytes
;         X, Y and D are preserved
SREC_PARSE		EQU	*
			;Save registers
			PSHD						;save D
			PSHY						;save Y
			PSHX						;save X
			SEC						;default result: success
			PSHC						;save CCR (incl. default result)	
			;Reset S-record count 
			MOVW	#$0000, SREC_COUNT 			;clear S-record counter
			MOVW	#$0000, SREC_COUNT+2 			;
			;Receive S-record 
SREC_PARSE_1		SREC_RX		  				;load s-recoed (SSTACK: 23 bytes)
			BCC	SREC_PARSE_	 			;format error (fail)
			LDD	#$0001 					;increment S-record counter
			ADDD	SREC_COUNT+1 				;
			STD	SREC_COUNT+1 				;
			LDAB	SREC_COUNT 				;
			ADCB						;
			STAB	SREC_COUNT   				;
			;Turn on green BUSY LED 
			LED_ON	A 					;light up green LED
			;Check  S-record type
			LDAB	SREC_TYPE 				;type -> B
			CMPB	#9 					;check type range
			BHI	SREC_PARSE_	 			;illegal type (fail)
			LSLB						;adjust to word offset
			JMP [B,PC] 					;
			DW	SREC_PARSE_1				;S0: ignore
			DW	SREC_PARSE_				;S1: program to flash
			DW	SREC_PARSE_				;S2: program to flash
			DW	SREC_PARSE_				;S3: program to flash
			DW	SREC_PARSE_				;S4: error
			DW	SREC_PARSE_				;S5: check 16-bit srec count
			DW	SREC_PARSE_				;S6: check 24-bit srec count
			DW	SREC_PARSE_				;S7: done
			DW	SREC_PARSE_				;S8: done
			DW	SREC_PARSE_				;S9: done
			



	;; ==============> Hier weiter!!!

	
;#Receive receive one complete S-record - blocking
; args:   none
; result: C-flag: set on success	
; SSTACK: 23 bytes
;         X, Y and D are preserved
SREC_RX			EQU	*
			;Save registers
			PSHD						;save D
			PSHY						;save Y
			PSHX						;save X
			SEC						;default result: success
			PSHC						;save CCR (incl. default result)	
			;Skip line breaks and whitespace 
SREC_RX_1		SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
			ANDA	#(SCI_FLG_SWOR|OR|NF|FE|PF) 		;check for communication error
			BNE	SREC_RX_5	 			;communication error (fail)			
			CMPB	#$20 					;check for space
			BEQ	SREC_RX_1 				;get next char
			CMPB	#$0D 					;check for CR
			BEQ	SREC_RX_1 				;get next char
			CMPB	#$0A 					;check for LF
			BEQ	SREC_RX_1 				;get next char
			CMPB	#$09 					;check for TAB
			BEQ	SREC_RX_1 				;get next char
			;Check for the start of the S-record (char in B)
			CMPB	#"S" 					;check for upper case "S"
			BEQ	SREC_RX_2	 			;check type
			CMPB	#"s" 					;check for lower case "s"
			BNE	SREC_RX_5	 			;format error (fail)			
			LDX	#SREC_TYPE 				;srec pointer -> X
			;Get type
SREC_RX_2		SREC_RX_NIBBLE	 				;digit -> B (SSTACK: 11 bytes)
			BCC	SREC_RX_5	 			;format error (fail)
			STAB	1,X+ 					;store srec type
			;Get byte count 			
			SREC_RX_BYTE	 				;byte count  -> B (SSTACK: 14 bytes)
			BCC	SREC_RX_5	 			;format error (fail)
			;CMPB	#SREC_MAX_BYTE_COUNT			;check srec size
			;BHI	SREC_RX_5	 			;too big (fail)
			STAB	1,X+ 					;store byte count
			TBA						;start checksum
			TFR	B, Y 					;byte count -> Y
			DBEQ	Y, SREC_RX_4 				;empty srecord
			;Get address and data fields 
SREC_RX_3		SREC_RX_BYTE	 				;data  -> B (SSTACK: 14 bytes)
			BCC	SREC_RX_5	 			;format error (fail)
			STAB	1,X+ 					;store data
			ABA						;adjust checksum
			DBNE	Y, SREC_RX_3 				;loop
			;Verify checksum (checksum in A)
SREC_RX_4		SREC_RX_BYTE	 				;expected checksum  -> B (SSTACK: 14 bytes)
			BCC	SREC_RX_5	 			;format error (fail)
			CMPB	#SREC_DATA_SIZE				;check srec size
			COMA						;invert checksum
			CBA						;compare checksum
			BNE	SREC_RX_5	 			;checksum error (fail)
			;Return result
			BSET	0,SP, #$01				;signal success
SREC_RX_5		SSTACK_PREPULL	9 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULX						;restore X
			PULY						;restore Y
			PULD						;restore D
			;Done
			RTS
	
;#Receive receive one data byte - blocking
; args:   none
; result: B:      data byte
;         C-flag: set on success	
; SSTACK: 14 bytes
;         A, X and Y are preserved
SREC_RX_BYTE		EQU	*
			;Save registers
			PSHA						;save A
			CLC						;signal failure by default
			PSHC						;save CCR			
			;Receive first nibble 
			SREC_RX_NIBBLE 					;receive first nibble
			BCC	SREC_RX_BYTE_1 				;fail
			TBA						;nibble -> A
			;Receive second nibble (first nibble in A)
			SREC_RX_NIBBLE 					;receive first nibble (SSTACK: 11 bytes)
			BCC	SREC_RX_BYTE_1 				;fail
			;Combine nibbles (first nibble in A, second nibble in B)
			LSLA						;shift first nibble
			LSLA						;
			LSLA						;
			LSLA						;
			ABA						;byte -> A
			TAB						;byte -> B
			;Return result (digit in B)
			BSET	0,SP, #$01				;signal success
SREC_RX_BYTE1		SSTACK_PREPULL	4 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULA						;restore A
			;Done
			RTS			
	
;#Receive receive one data nibble - blocking
; args:   none
; result: B:      hexadecimal digit
;         C-flag: set on success	
; SSTACK: 11 bytes
;         A, X and Y are preserved
SREC_RX_NIBBLE		EQU	*
			;Save registers
			PSHA						;save A
			CLC						;signal failure by default
			PSHC						;save CCR			
			;Receive one byte
			SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
			ANDA	#(SCI_FLG_SWOR|OR|NF|FE|PF) 		;check for communication error
			BNE	SREC_RX_NIBBLE_2 			;communication error (fail)			
			;Check for decimal digit (data in B)
			TBA						;data -> A
			ANDA	#$F0 					;mask data
			EORA	#$30	       				;check for decimal digit
			BNE	SREC_RX_NIBBLE_3 			;check for upper case digit
			ANDB	#$0F 					;mask digit
			CMPB	#9					;check range
			BHI	SREC_RX_NIBBLE_2			;out of range (fail)		
			;Return result (digit in B)
SREC_RX_NIBBLE_1	BSET	0,SP, #$01				;signal success
SREC_RX_NIBBLE_2	SSTACK_PREPULL	4 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULA						;restore A
			;Done
			RTS			
			;Check for upper case digit (data in B)
SREC_RX_NIBBLE_3	TBA						;data -> A
			ANDA	#$F8 					;mask data
			EORA	#$40	       				;check for upper case digit
			BNE	SREC_RX_NIBBLE_5 			;check for lower case digit
SREC_RX_NIBBLE_4	ANDB	#$07 					;mask digit
			BEQ	SREC_RX_NIBBLE_2			;out of range (fail)
			CMPB	#6					;check range
			BHI	SREC_RX_NIBBLE_2			;out of range (fail)
			ADDB	#9 					;add offset
			JOB	SREC_RX_NIBBLE_1			;return result (success)
			;Check for lower case digit (data in B)
SREC_RX_NIBBLE_5	TBA						;data -> A
			ANDA	#$F8 					;mask data
			EORA	#$60	       				;check for lower case digit
			BEQ	SREC_RX_NIBBLE_4			;mask digit
			JOB	SREC_RX_NIBBLE_2 			;invalid character (fail)
	
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

	
SREC_TABS_END		EQU	*
SREC_TABS_END_LIN	EQU	@
#endif
