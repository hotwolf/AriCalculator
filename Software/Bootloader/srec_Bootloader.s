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
;#           S5 -> Count of previous S1/S2/S3-recpords in 16-bit Address field #
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
SREC_ADDR		DS	4		;address field
SREC_RCNT		DS	3		;record count
SREC_TYPE		DS	1 		;type 
SREC_BCNT		DS	1		;byte count
SREC_CSUM		DS	1		;checksum
		
SREC_VARS_END		EQU	*
SREC_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SREC_INIT, 0
#emac









;#Receive receive one data nibble - blocking
; args:   none
; result: B:      hexadecimal digit
;         C-flag: set on success	
; SSTACK: 11 bytes
;         A, X and Y are preserved
#macro	SREC_NIBBLE, 0
			SSTACK_JOBSR	SREC_NIBBLE, 11
#emac
	
;#Receive receive one data byte - blocking
; args:   none
; result: B:      data byte
;         C-flag: set on success	
; SSTACK: 15 bytes
;         A, X and Y are preserved
#macro	SREC_HBYTE, 0
			SSTACK_JOBSR	SREC_HBYTE, 15
#emac

;#Receive receive one data word - blocking
; args:   none
; result: D:      data word
;         C-flag: set on success	
; SSTACK: 18 bytes
;         X and Y are preserved
#macro	SREC_RX_WORD, 0
			SSTACK_JOBSR	SREC_RX_WORD, 18
#emac

;#Receive the S-record type - blocking
; args:   none
; result: B:      type (0..9)
;         C-flag: set on success	
; SSTACK: 11 bytes
;         A, X and Y are preserved
#macro	SREC_RX_TYPE, 0
			SSTACK_JOBSR	SREC_RX_TYPE, 11
#emac

;#Receive the S-record type - blocking
; args:   none
; result: X:      size
;         C-flag: set on success	
; SSTACK: 20 bytes
;         D and Y are preserved
#macro	SREC_RX_SIZE, 0
			SSTACK_JOBSR	SREC_RX_SIZE, 20
#emac

;#Receive and verify the checksum - blocking
; args:   A: accumulated sum od data bytes
; result: C-flag: set on success	
; SSTACK: 19 bytes
;         D, X and Y are preserved
#macro	SREC_RX_CSUM, 0
			SSTACK_JOBSR	SREC_RX_CSUM, 19
#emac
	
;#Ignore the content of the S-Record - blocking
; args:   none
; result: C-flag: set on success	
; SSTACK: 27 bytes
;         D, X and Y are preserved
#macro	SREC_IGNORE, 0
			SSTACK_JOBSR	SREC_IGNORE, 27
#emac















	
;#Parse S-record string - blocking
; args:   1: error handler 
;         2: exit handler	
; result: none	
; SSTACK: ?? bytes
;         X, Y and D are preserved
#macro	SREC_PARSE, 2

			;Get S-record type
			SREC_RX_TYPE 			;get S-record type (SREC_RX_TYPE, 11)
			BCC	\1			;invalid type
			CLRA				;prepare jump table offset
			LSLB				;adjust jump table offset
			JMP	[D, PC]			;handle S-record type
			;Jump table 
			DW	SREC_PARSE_ignore 	;S0
			DW	SREC_PARSE_s1	  	;S1
			DW	SREC_PARSE_s2	  	;S2
			DW	SREC_PARSE_s3	  	;S3
			DW	\1		  	;invalid
			DW	SREC_PARSE_check  	;S5
			DW	\1		  	;invalid
			DW	SREC_PARSE_term	  	;S7
			DW	SREC_PARSE_term	  	;S8
			DW	SREC_PARSE_term	  	;S9




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

;#Parse S-record header
; args:   X:Y: old S-Record count   
; result: X:Y: new S-Record count	
; result: C-flag: set on success	
; SSTACK: ?? bytes
;         X, Y and D are preserved
SREC_PARSE_HEADER	EQU	*
;			;Save registers
;			PSHD						;save D
;			CLC						;signal failure by default
;			PSHC						;save CCR			
;			;Wait for the beginning of the next S-Record
;			JOBSR	SREC_WAIT_FOR_S 			;(SSTACK: 12 bytes)
;			BCS	SREC_PARSE_HEADER_7 			;error
;			;Read type 
;			JOBSR	SREC_NIBBLE				;type -> B (SSTACK: 11 bytes)
;			BCS	SREC_PARSE_HEADER_7 			;error
;			STAB	SREC_TYPE 				;store type	
;			;Read byte count 
;			JOBSR	SREC_HBYTE				;count -> B (SSTACK: 15 bytes)
;			BCS	SREC_PARSE_HEADER_7 			;error
;			STAB	SREC_COUNT 				;store byte count	
;			STAB	SREC_CSUM 				;store check sum	
;			;Jump to address parser
;			LDAB	SREC_TYPE
;			JMP	B,PC 					;
;			DW	SREC_PARSE_HEADER_4			;S0 (16-bit)
;			DW	SREC_PARSE_HEADER_4			;S1 (16-bit)
;			DW	SREC_PARSE_HEADER_2			;S2 (24-bit)
;			DW	SREC_PARSE_HEADER_1			;S3 (32-bit)
;			DW	SREC_PARSE_HEADER_7			;error
;			DW	SREC_PARSE_HEADER_4			;S5 (16-bit)
;			DW	SREC_PARSE_HEADER_2			;S6 (24-bit)
;			DW	SREC_PARSE_HEADER_1			;S7 (32-bit)
;			DW	SREC_PARSE_HEADER_2			;S8 (24-bit)
;			DW	SREC_PARSE_HEADER_4			;S9 (16-bit)
;			DW	SREC_PARSE_HEADER_7			;error
;			DW	SREC_PARSE_HEADER_7			;error
;			DW	SREC_PARSE_HEADER_7			;error
;			DW	SREC_PARSE_HEADER_7			;error
;			DW	SREC_PARSE_HEADER_7			;error
;			DW	SREC_PARSE_HEADER_7			;error
;			DW	SREC_PARSE_HEADER_7			;error
;			;Read 32-bit address
;SREC_PARSE_HEADER_1	JOBSR	SREC_BBYTE				;count -> B (SSTACK: ?? bytes)
;			BCS	SREC_PARSE_HEADER_7 			;error
;			STAB	SREC_ADDR 				;store address byte
;			JOB	SREC_PARSE_HEADER_3 			;read remaining 24-bit address
;			;Read 24-bit address
;SREC_PARSE_HEADER_2     CLR	SREC_ADDR 				;clear first address byte
;SREC_PARSE_HEADER_3	JOBSR	SREC_BBYTE				;count -> B (SSTACK: ?? bytes)
;			BCS	SREC_PARSE_HEADER_7 			;error
;			STAB	SREC_ADDR+1 				;store address byte
;			JOB	SREC_PARSE_HEADER_5 			;read remaining 16-bit address
;			;Read 16-bit address
;SREC_PARSE_HEADER_4	MOVW	#$003F, SREC_ADDR 			;add address offset
;SREC_PARSE_HEADER_5	JOBSR	SREC_BBYTE				;count -> B (SSTACK: ?? bytes)
;			BCS	SREC_PARSE_HEADER_7 			;error
;			STAB	SREC_ADDR+2 				;store address byte
;			JOBSR	SREC_BBYTE				;count -> B (SSTACK: ?? bytes)
;			BCS	SREC_PARSE_HEADER_7 			;error
;			STAB	SREC_ADDR+3 				;store address byte
;			;Parsing sucessful 
;SREC_PARSE_HEADER_6	BSET	0,SP, #$01				;signal success
;SREC_PARSE_HEADER_7	SSTACK_PREPULL	x	 			;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULD						;restore D
;			;Done
;			RTS			
	
;#Wait for an "S" character
; args:   none
; result: none
;         C-flag: set on success	
; SSTACK: 12 bytes
;         All registers are preserved
SREC_WAIT_FOR_S		EQU	*
;			;Save registers
;			PSHD						;save D
;			CLC						;signal failure by default
;			PSHC						;save CCR			
;			;RX loop
;SREC_WAIT_FOR_S_1	SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
;			BITA	#(SWOR|OR|NF|FE|PF) 			;check for communication error	
;			BNE	SREC_WAIT_FOR_S_3			;communication error (fail)			
;			CMPB	#"S" 					;check for upper case "S"
;			BEQ	SREC_WAIT_FOR_S_2 			;upper case "S" found
;			CMPB	#"b" 					;check for lower case "s"
;			BNE	SREC_WAIT_FOR_S_1 			;check next character			
;			;"S" character found
;SREC_WAIT_FOR_S_3	BSET	0,SP, #$01				;signal success
;SREC_WAIT_FOR_S_3	SSTACK_PREPULL	5	 			;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULD						;restore D
;			;Done
;			RTS			


;#Receive a body data byte
; args:   none
; result: B:      data byte
;         C-flag: set on success	
; SSTACK: 19 bytes
;         A, X and Y are preserved
SREC_BBYTE		EQU	*
;			;Save registers
;			PSHA						;save A
;			CLC						;signal failure by default
;			PSHC						;save CCR			
;			;Receive one data cyte 
;			JOBSR SREC_HBYTE 				;receive  (SSTACK: 15 bytes)
;			BCC	SREC_HBYTE_1 				;fail
;			TBA						;nibble -> A
;			;Receive second nibble (first nibble in A)
;			SREC_NIBBLE 					;receive second nibble (SSTACK: 11 bytes)
;			BCC	SREC_HBYTE_1 				;fail
;			;Combine nibbles (first nibble in A, second nibble in B)
;			LSLA						;shift first nibble
;			LSLA						;
;			LSLA						;
;			LSLA						;
;			ABA						;byte -> A
;			TAB						;byte -> B
;			;Return result (digit in B)
;			BSET	0,SP, #$01				;signal success
;SREC_HBYTE_1		SSTACK_PREPULL	4 				;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULA						;restore A
;			;Done
;			RTS			
;
;#Receive a header data byte
; args:   none
; result: B:      data byte
;         C-flag: set on success	
; SSTACK: 15 bytes
;         A, X and Y are preserved
SREC_HBYTE		EQU	*
;			;Save registers
;			PSHA						;save A
;			CLC						;signal failure by default
;			PSHC						;save CCR			
;			;Receive first nibble 
;			JOBSR	SREC_NIBBLE 				;receive first nibble (SSTACK: 11 bytes)
;			BCC	SREC_HBYTE_1 				;fail
;			TBA						;nibble -> A
;			;Receive second nibble (first nibble in A)
;			JOBSR	SREC_NIBBLE 				;receive second nibble (SSTACK: 11 bytes)
;			BCC	SREC_HBYTE_1 				;fail
;			;Combine nibbles (first nibble in A, second nibble in B)
;			LSLA						;shift first nibble
;			LSLA						;
;			LSLA						;
;			LSLA						;
;			ABA						;byte -> A
;			TAB						;byte -> B
;			;Return result (digit in B)
;			BSET	0,SP, #$01				;signal success
;SREC_HBYTE_1		SSTACK_PREPULL	4 				;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULA						;restore A
;			;Done
;			RTS			
	
;#Receive one data nibble - blocking
; args:   none
; result: B:      hexadecimal digit
;         C-flag: set on success	
; SSTACK: 11 bytes
;         A, X and Y are preserved
SREC_NIBBLE		EQU	*
;			;Save registers
;			PSHA						;save A
;			CLC						;signal failure by default
;			PSHC						;save CCR			
;			;Receive one byte
;			SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
;			ANDA	#(SWOR|OR|NF|FE|PF) 			;check for communication error
;			BNE	SREC_NIBBLE_2 			;communication error (fail)			
;			;Check for decimal digit (data in B)
;			TBA						;data -> A
;			ANDA	#$F0 					;mask data
;			EORA	#$30	       				;check for decimal digit
;			BNE	SREC_NIBBLE_3 			;check for upper case digit
;			ANDB	#$0F 					;mask digit
;			CMPB	#9					;check range
;			BHI	SREC_NIBBLE_2			;out of range (fail)		
;			;Return result (digit in B)
;SREC_NIBBLE_1	BSET	0,SP, #$01				;signal success
;SREC_NIBBLE_2	SSTACK_PREPULL	4 				;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULA						;restore A
;			;Done
;			RTS			
;			;Check for upper case digit (data in B)
;SREC_NIBBLE_3	TBA						;data -> A
;			ANDA	#$F8 					;mask data
;			EORA	#$40	       				;check for upper case digit
;			BNE	SREC_NIBBLE_5 			;check for lower case digit
;SREC_NIBBLE_4	ANDB	#$07 					;mask digit
;			BEQ	SREC_NIBBLE_2			;out of range (fail)
;			CMPB	#6					;check range
;			BHI	SREC_NIBBLE_2			;out of range (fail)
;			ADDB	#9 					;add offset
;			JOB	SREC_NIBBLE_1			;return result (success)
;			;Check for lower case digit (data in B)
;SREC_NIBBLE_5	TBA						;data -> A
;			ANDA	#$F8 					;mask data
;			EORA	#$60	       				;check for lower case digit
;			BEQ	SREC_NIBBLE_4			;mask digit
;			JOB	SREC_NIBBLE_2 			;invalid character (fail)
	




	









	
;#Receive and verify the checksum - blocking
; args:   A: accumulated sum of data bytes
; result: C-flag: set on success	
; SSTACK: 19 bytes
;         D, X and Y are preserved
SREC_RX_CSUM		EQU	*
			;Save registers (accumulated sum in A)
			PSHD						;save D
			CLC						;signal failure by default
			PSHC						;save CCR			
	 		;Receive checksum byte (accumulated sum in A)
			SREC_HBYTE 					;receive byte (SSTACK: 15 bytes)
			BCC	SREC_RX_CSUM_1 				;communication error (fail)
			;Validate checksum (accumulated sum in A, CSUM in B)
			ABA						;accumulated sum + CSUM -> A
			COMA		       				;check if result is $FF
			BNE	SREC_RX_CSUM_1 				;checksum error (fail)
			;Return result
			BSET	0,SP, #$01				;signal success
SREC_RX_CSUM_1		SSTACK_PREPULL	54 				;check SSTACK
			PULC						;restore CCR (incl. result)
			PULD						;restore D
			;Done
			RTS			
	
;#Ignore the content of the S-Record - blocking
; args:   none
; result: C-flag: set on success	
; SSTACK: 27 bytes
;         D, X and Y are preserved
SREC_IGNORE		EQU	*
;			;Save registers
;			PSHD						;save D
;			PSHX						;save X
;			CLC						;signal failure by default
;			PSHC						;save CCR			
;			;Receive data count 
;			SREC_RX_SIZE 					;receive size field (SSTACK: 20 bytes)
;			BCC	SREC_IGNORE_3 				;communication error (fail)
;			TBEQ	X, SREC_IGNORE_3 			;zero Srecord size (fail)
;			;Receive data count (0 in A, size in X)
;SREC_IGNORE_1		DBEQ	X, SREC_IGNORE_2			;receive and validate checksum
;			SREC_HBYTE 					;receive first byte (SSTACK: 15 bytes)
;			ABA						;accumulate ckecksum
;			JOB	SREC_IGNORE_1	
;			;Receive and validate checksum (accumulated checksun in A)
;SREC_IGNORE_2		SREC_RX_CSUM					;receive and validate checksum (SSTACK: 19 bytes)
;			BCC	SREC_IGNORE_3 				;communication error (fail)
;			;Return result
;			BSET	0,SP, #$01				;signal success
;SREC_IGNORE_3		SSTACK_PREPULL	7 				;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULX						;restore X
;			PULD						;restore D
;			;Done
;			RTS			

;#Parse S-record string - blocking
; args:   none
; result: C-flag: set on success	
; SSTACK: ?? bytes
;         X, Y and D are preserved
SREC_PARSE		EQU	*
;			;Save registers
;			PSHD						;save D
;			PSHY						;save Y
;			PSHX						;save X
;			SEC						;default result: success
;			PSHC						;save CCR (incl. default result)	
;			;setup local variables
;			MOVW	#$0000, 2,-SP 				;S-record counter
;			LEAS	-(SREC_PHRASE_SIZE+2),SP 		;allocate space for phrase and address
;			;Stack:
;			;+--------+--------+ 
;			;|                 | SP+0
;			;+                 + 
;			;|                 | SP+2
;			;+      data       + 
;			;|                 | SP+4
;			;+                 + 
;			;|                 | SP+6
;			;+--------+--------+ 
;			;|  cond. address  | SP+SREC_PHRASE_SIZE
;			;+--------+--------+ 
;			;|  S-rec. counter | SP+SREC_PHRASE_SIZE+2
;			;+--------+--------+ 
;
;
;
;
;
;
;
;
;	
;
;			;Get S-record type
;SREC_PARSE_1		SREC_RX_TYPE 					;get S-record type (SREC_RX_TYPE, 11)
;			BCC	\1					;invalid type
;			CLRA						;prepare jump table offset
;			LSLB						;adjust jump table offset
;			JMP	[D, PC]					;handle S-record type
;			;Jump table 					
;			DW	SREC_PARSE_s0 				;S0
;			DW	SREC_PARSE_s1	  			;S1
;			DW	SREC_PARSE_s2	  			;S2
;			DW	SREC_PARSE_s3	  			;S3
;			DW	SREC_PARSE_fail		  		;invalid type
;			DW	SREC_PARSE_s5	  			;S5
;			DW	SREC_PARSE_fail		  		;invalid type
;			DW	SREC_PARSE_term	  			;S7
;			DW	SREC_PARSE_term	  			;S8
;			DW	SREC_PARSE_term	  			;S9
;									
;									
;			;Handle S0-record				
;SREC_PARSE_s0		SREC_IGNORE 					;ignore content (SSTACK: 26 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			MOVW	#$0000, ?,SP 				;clear S-record counter
;			JOB	SREC_PARSE_1 				;parse next S-record
;
;			
;			;Handle S1-record
;			;Receive and check size 
;SREC_PARSE_s1		SREC_RX_SIZE 					;receive data count (SSTACK: 20 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			CPX	#3 					;expect at least 3 bytes
;			BLO	SREC_PARSE_fail  			;S-record too short (fail)
;			;Determine the high byte of the address field (size in X)
;			LEAX	-2,X 					;subtract address field
;			LDAB	#((1<<(SREC_ADDR_WIDTH-16))-1)	 	;store high byte of the address 
;			JOB	SREC_PARSE_common 			;common part of the S-record handler
;
;			;Handle S3-record
;			;Receive and check size 
;SREC_PARSE_s3		SREC_RX_SIZE 					;receive data count (SSTACK: 20 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			CPX	#5 					;expect at least 5 bytes
;			BLO	SREC_PARSE_fail  			;S-record too short (fail)
;			LEAX	-4,X 					;sbtract address field
;			;Receive the high word of the address field (size in X)
;			SREC_RX_WORD 					;receive first address word (SSTACK: 18 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			TBEQ	A, SREC_PARSE_common			;store high byte of the address
;			JOB	 SREC_PARSE_fail			;address error (fail)
;
;			;Handle S2-record
;			;Receive and check size 
;SREC_PARSE_s2		SREC_RX_SIZE 					;receive data count (SSTACK: 20 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			CPX	#4 					;expect at least 4 bytes
;			BLO	SREC_PARSE_fail  			;S-record too short (fail)
;			;Receive the high byte of the address field (size in X)
;			LEAX	-3,X 					;sbtract address field
;			SREC_HBYTE 					;receive first byte (SSTACK: 15 bytes)
;			BCC	SREC_PARSE_fail  			;fail
;			;Common S-record handler (size in X, high address in B)
;			;Determine condensed address (size in X, high address in B)
;SREC_PARSE_common	LDAA	#(256/SREC_PHRASE_SIZE)			;shift multiplicator -> A
;			MUL						;shift
;			TBA						;shift more
;			CLRB						;clear lower byte
;			TFR	D, Y 					;high address -> Y
;			SREC_RX_WORD 					;receive lower address word (SSTACK: 18 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			PSHX						;save size
;			LDX	#SREC_PHRASE_SIZE			;shift divisor -> X
;			IDIV						;shifted address -> X, remainder -> D
;			EXG	X, D					;shifted address -> D, remainder -> X
;			LEAY	D,Y 					;condensed address -> Y
;			TFR	X, A 					;remainder -> A
;			PULX						;restore size
;			PSHY						;store address
;			LEAS	-SREC_PHRASE_SIZE,SP			;allocate data space
;			;Pad data space (data pointer in A, size in X)
;			TAB						;reminder -> B
;			TBEQ 	B, SREC_PARSE_
;			MOVB	#$FF, B,SP 				;pad data space
;			DBNE	B, SREC_PARSE_
;			;Read data (data pointer in A, size in X)
;			DBEQ	X, SREC_PARSE_ 				;no more data in S-Record
;			CMPA	#SREC_PHRASE_SIZE 			;check if phrase is full
;			BHS	SREC_PARSE_ 				;phrase is full
;			
;
;	
;	
;	
;			MOVW	#$FFFF, 2,-SP 				;allocate data space
;			MOVW	#$FFFF, 2,-SP 				;allocate data space
;			MOVW	#$FFFF, 2,-SP 				;allocate data space
;			MOVW	#$FFFF, 2,-SP 				;allocate data space
;		
;
;
;
;
;
;
;
;	
;			CMPB	#(1<<(SREC_ADDR_WIDTH-16)) 		;check address range
;			BHS	SREC_PARSE_fail  			;address error too high (fail)
;			LEAX	-11, SP					;reserve space for parameters
;			STAB	0,SP 					;store high byte of the address	
;			;Receive the low word of the address field (size in X)
;			SREC_RX_WORD 					;receive first address word (SSTACK: 18 bytes)
;			BCC	SREC_PARSE_failcleanup  		;parse error (fail)
;			STD	1,SP
;			LEAY	3,SP
;			
;
;
;	
;
;			CPD	#(1<<(SREC_ADDR_WIDTH-16)) 		;check address range
;			BHS	SREC_PARSE_fail  			;address too high (fail)
;			LEAS	-11,SP 					;allocate space foe data and address
;			STAA	0,SP 					;store address high byte
;			SREC_RX_WORD 					;receive second address word (SSTACK: 18 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			STD	1,SP					;store address high byte 
;
;			
;
;	
;
;	
;			;Handle S5-record
;			;Receive and check data length 
;SREC_PARSE_s5		SREC_HBYTE 					;receive data count (SSTACK: 15 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			CMPA	#3 					;expect length of three
;			BNE	SREC_PARSE_fail  			;wrong length (fail)
;			;Receive and check data length 
;			SREC_RX_WORD 					;receive S-record count (SSTACK: 18 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			CPD	?,SP				
;			BNE	SREC_PARSE_fail  			;wrong S-record count (fail)
;			ABA						;accumulate checksum
;			;Receive and check data length (accumulated sum in A)
;			SREC_IGNORE_2		SREC_RX_CSUM		;receive and validate checksum (SSTACK: 19 bytes)
;			BCC	SREC_RX_IGNORE_3 			;communication error (fail)
;			JOB	SREC_PARSE_1 				;parse next S-record
;	
;
;			;Handle S7/S8/S9-record				
;SREC_PARSE_term		SREC_IGNORE 					;ignore content (SSTACK: 26 bytes)
;			BCC	SREC_PARSE_fail  			;parse error (fail)
;			;Return result
;			BSET	?,SP, #$01				;signal success
;SREC_PARSE_fail		SSTACK_PREPULL	4 				;check SSTACK
;			LEAS	?,SP 					;clean uplocal variables
;			PULC						;restore CCR (incl. result)
;			PULX						;restore X
;			PULY						;restore Y
;			PULD						;restore D
;			;Done
;			RTS			
;
;
;
;
;	
;
;
;			;Reset S-record count 
;			MOVW	#$0000, SREC_COUNTER 			;clear S-record counter
;			MOVW	#$0000, SREC_COUNTER+2 			;
;			;Receive S-record 
;SREC_PARSE_1		SREC_RX		  				;load S-record (SSTACK: 23 bytes)
;			BCC	SREC_PARSE_3	 			;format error (fail)
;			LDD	SREC_COUNTER+2				;S-record counter (lo) -> D
;			ADDD	#1 					;increment S-record counter (lo), carry -> C-flag
;			STD	SREC_COUNTER+2 				;update S-record counter -> X, carry in C-flag			
;			LDD	SREC_COUNTER				;S-record counter (hi) -> D
;			ADCB	#0 					;add carry to S-record counter (hi)
;			ADCA	#0 					;
;			SBCA	#0	   				;saturate high byte
;			LDD	SREC_COUNTER				;update S-record counter (hi)
;			;Check  S-record type
;			LDAB	SREC_TYPE 				;type -> B
;			CMPB	#9 					;check type range
;			BHI	SREC_PARSE_3	 			;illegal type (fail)
;			LSLB						;adjust to word offset
;			LDAA	SREC_BYTE_COUNT 			;byte count -> A
;			LDY	#SREC_ADDR   				;data pointer -> Y
;;TBD			JMP 	[B,PC]	    
;			DW	SREC_PARSE_1				;S0: ignore
;			DW	SREC_PARSE_4				;S1: program S-record to flash (16-bit address space)
;			DW	SREC_PARSE_6				;S2: program S-record to flash (24-bit address space)
;			DW	SREC_PARSE_7				;S3: program S-record to flash (32-bit address space)
;			DW	SREC_PARSE_3				;S4: error
;			DW	SREC_PARSE_8				;S5: check 16-bit srec count
;			DW	SREC_PARSE_10				;S6: check 24-bit srec count
;			DW	SREC_PARSE_2				;S7: done
;			DW	SREC_PARSE_2				;S8: done
;			DW	SREC_PARSE_2				;S9: done			
;			;Return result
;SREC_PARSE_2		BSET	0,SP, #$01				;signal success
;SREC_PARSE_3		SSTACK_PREPULL	9 				;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULX						;restore X
;			PULY						;restore Y
;			PULD						;restore D
;			;Done
;			RTS			
;			;S1-record: Program S-record to flash -> 16-bit addresses (byte count in A, data pointer in Y)
;SREC_PARSE_4		SUBA	#3	    				;string length  -> A
;			LDAB	#$03 					;address[23:16] -> B
;SREC_PARSE_5		LDX	2,Y+ 					;address[15:0] -> -> X
;;TBD			NVM_PROG_STRING	    				;program NVM (SSTACK: ?? bytes)
;			JOB	SREC_PARSE_1 				;load next S-record
;			;S2-record: Program S-record to flash -> 24-bit addresses (byte count in A, data pointer in Y)
;			SUBA	#4	    				;string length  -> A
;SREC_PARSE_6		LDAB	1,Y+ 					;address[23:16] -> B
;			JOB	SREC_PARSE_5				;address[15:0] -> -> X
;			;S3-record: Program S-record to flash -> 24-bit addresses (byte count in A, data pointer in Y)
;SREC_PARSE_7		SUBA	#5	    				;string length  -> A
;			TST	1,Y+	     				;check address[31:24]
;			BEQ	SREC_PARSE_6				;address[23:16] -> B
;			JOB	SREC_PARSE_3 				;address out of range (fail)
;			;S5-record: Check 16-bit count (byte count in A, data pointer in Y)
;SREC_PARSE_8		CMPA	 #3					;check S-record length
;			BNE	SREC_PARSE_3 				;wrong format (fail)
;			LDX	SREC_COUNTER				;check counter[31:16]
;SREC_PARSE_9		BNE	SREC_PARSE_3 				;counter overflow (fail)
;			LDX	2,Y+ 					;counter[15:0] -> X
;			CPX	SREC_COUNTER+2 				;check counter
;			BNE	SREC_PARSE_3 				;counter mismatch (fail)
;			JOB	SREC_PARSE_1 				;load next S-record
;			;S6-record: Check 24-bit count (byte count in A, data pointer in Y)
;SREC_PARSE_10		CMPA	#4					;check S-record length
;			BNE	SREC_PARSE_3 				;wrong format (fail)
;			TST	SREC_COUNTER				;check counter[31:24]
;			BNE	SREC_PARSE_3 				;counter overflow (fail)
;			LDAB	1,Y+ 					;counter[23:16] -> B
;			CMPB	SREC_COUNTER+1 				;check counter[23:16]
;			JOB	SREC_PARSE_9 				;check for mismatch
;	
;;#Receive receive one complete S-record - blocking
;; args:   none
;; result: C-flag: set on success	
;; SSTACK: 23 bytes
;;         X, Y and D are preserved
;SREC_RX			EQU	*
;			;Save registers
;			PSHD						;save D
;			PSHY						;save Y
;			PSHX						;save X
;			SEC						;default result: success
;			PSHC						;save CCR (incl. default result)	
;			;Skip line breaks and whitespace 
;SREC_RX_1		SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
;			ANDA	#(SCI_STAT_SWOR|OR|NF|FE|PF) 		;check for communication error
;			BNE	SREC_RX_5	 			;communication error (fail)			
;			CMPB	#$20 					;check for space
;			BEQ	SREC_RX_1 				;get next char
;			CMPB	#$0D 					;check for CR
;			BEQ	SREC_RX_1 				;get next char
;			CMPB	#$0A 					;check for LF
;			BEQ	SREC_RX_1 				;get next char
;			CMPB	#$09 					;check for TAB
;			BEQ	SREC_RX_1 				;get next char
;			;Check for the start of the S-record (char in B)
;			CMPB	#"S" 					;check for upper case "S"
;			BEQ	SREC_RX_2	 			;check type
;			CMPB	#"s" 					;check for lower case "s"
;			BNE	SREC_RX_5	 			;format error (fail)			
;			LDX	#SREC_TYPE 				;srec pointer -> X
;			;Get type
;SREC_RX_2		SREC_NIBBLE	 				;digit -> B (SSTACK: 11 bytes)
;			BCC	SREC_RX_5	 			;format error (fail)
;			STAB	1,X+ 					;store srec type
;			;Get byte count 			
;			SREC_HBYTE	 				;byte count  -> B (SSTACK: 14 bytes)
;			BCC	SREC_RX_5	 			;format error (fail)
;			;CMPB	#SREC_MAX_BYTE_COUNT			;check srec size
;			;BHI	SREC_RX_5	 			;too big (fail)
;			STAB	1,X+ 					;store byte count
;			TBA						;start checksum
;			TFR	B, Y 					;byte count -> Y
;			DBEQ	Y, SREC_RX_4 				;empty srecord
;			;Get address and data fields 
;SREC_RX_3		SREC_HBYTE	 				;data  -> B (SSTACK: 14 bytes)
;			BCC	SREC_RX_5	 			;format error (fail)
;			STAB	1,X+ 					;store data
;			ABA						;adjust checksum
;			DBNE	Y, SREC_RX_3 				;loop
;			;Verify checksum (checksum in A)
;SREC_RX_4		SREC_HBYTE	 				;expected checksum  -> B (SSTACK: 14 bytes)
;			BCC	SREC_RX_5	 			;format error (fail)
;			CMPB	#SREC_BYTE_COUNT 	;TBD		;check srec size
;			COMA						;invert checksum
;			CBA						;compare checksum
;			BNE	SREC_RX_5	 			;checksum error (fail)
;			;Return result
;			BSET	0,SP, #$01				;signal success
;SREC_RX_5		SSTACK_PREPULL	9 				;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULX						;restore X
;			PULY						;restore Y
;			PULD						;restore D
;			;Done
;			RTS
;	
;;#Receive receive one data nibble - blocking
;; args:   none
;; result: B:      hexadecimal digit
;;         C-flag: set on success	
;; SSTACK: 11 bytes
;;         A, X and Y are preserved
;SREC_NIBBLE		EQU	*
;			;Save registers
;			PSHA						;save A
;			CLC						;signal failure by default
;			PSHC						;save CCR			
;			;Receive one byte
;			SCI_RX_BL 					;flags -> A, data -> B (SSTACK: 7 bytes)
;			ANDA	#(SCI_STAT_SWOR|OR|NF|FE|PF) 		;check for communication error
;			BNE	SREC_NIBBLE_2 			;communication error (fail)			
;			;Check for decimal digit (data in B)
;			TBA						;data -> A
;			ANDA	#$F0 					;mask data
;			EORA	#$30	       				;check for decimal digit
;			BNE	SREC_NIBBLE_3 			;check for upper case digit
;			ANDB	#$0F 					;mask digit
;			CMPB	#9					;check range
;			BHI	SREC_NIBBLE_2			;out of range (fail)		
;			;Return result (digit in B)
;SREC_NIBBLE_1	BSET	0,SP, #$01				;signal success
;SREC_NIBBLE_2	SSTACK_PREPULL	4 				;check SSTACK
;			PULC						;restore CCR (incl. result)
;			PULA						;restore A
;			;Done
;			RTS			
;			;Check for upper case digit (data in B)
;SREC_NIBBLE_3	TBA						;data -> A
;			ANDA	#$F8 					;mask data
;			EORA	#$40	       				;check for upper case digit
;			BNE	SREC_NIBBLE_5 			;check for lower case digit
;SREC_NIBBLE_4	ANDB	#$07 					;mask digit
;			BEQ	SREC_NIBBLE_2			;out of range (fail)
;			CMPB	#6					;check range
;			BHI	SREC_NIBBLE_2			;out of range (fail)
;			ADDB	#9 					;add offset
;			JOB	SREC_NIBBLE_1			;return result (success)
;			;Check for lower case digit (data in B)
;SREC_NIBBLE_5	TBA						;data -> A
;			ANDA	#$F8 					;mask data
;			EORA	#$60	       				;check for lower case digit
;			BEQ	SREC_NIBBLE_4			;mask digit
;			JOB	SREC_NIBBLE_2 			;invalid character (fail)
	
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
