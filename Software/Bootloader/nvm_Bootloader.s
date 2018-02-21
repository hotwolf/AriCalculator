#ifndef NVM_COMPILED
#define	NVM_COMPILED	
;###############################################################################
;# AriCalculator - Bootloader - NVM Driver                                     #
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
;#    This part of the AriCalculator's bootloader handles non-volatile memory  #
;#    operations.                                                              #
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
;Prescaler value
;--------------- 
#ifndef NVM_FDIV_VAL
NVM_FDIV_VAL		EQU	(CLOCK_BUS_FREQ/1000000)-1 ;FTMRG clock divider
#endif

;Program buffer
;-------------- 
#ifndef NVM_BUF_DEPTH
NVM_BUF_DEPTH		EQU	16			;max. 32 entries
#endif	

;Firmware range
;-------------- 
#ifndef NVM_FIRMWARE_START_LIN
NVM_FIRMWARE_START_LIN	EQU	MMAP_FLASH_F_END_LIN-MMAP_FLASH_SIZE
#endif	
#ifndef NVM_FIRMWARE_END_LIN
NVM_FIRMWARE_END_LIN	EQU	MMAP_FLASH_F_END_LIN-BOOTLOADER_SIZE
#endif	
	
;Error handler
;-------------
#ifnmac	NVM_ERROR_HANDLER
#macro NVM_ERROR_HANDLER, 0
			;Signal error (error code in A) 
			JOB	BOOTLOADER_DONE 	;end bootloader
#emac
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Sector size
NVM_SECTOR_SIZE		EQU	512			;sector size  [bytes]
NVM_PHRASE_SIZE		EQU	8			;phrase size  [bytes]
NVM_ADDR_SIZE		EQU	4			;address size [bytes]

;#Firmware size
NVM_FIRMWARE_SIZE	EQU	NVM_FIRMWARE_END_LIN-NVM_FIRMWARE_START_LIN
			
;#NVM commands 
NVM_CMD_PROG		EQU	$06			;program P-flash command
NVM_CMD_ERASE		EQU	$0A			;erase P-flash sector command
NVM_CMD_VERIFY		EQU	$03			;erase verify P-flash section command

;#NVM fill pattern 
NVM_FILL_PATTERN	EQU	$FF 			;fill gaps with $FF

;#Error codes
NVM_ERR_ADDR		EQU	$08 			;address error
NVM_ERR_HW		EQU	$04 			;HW error
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef NVM_VARS_START_LIN
			ORG 	NVM_VARS_START, NVM_VARS_START_LIN
#else
			ORG 	NVM_VARS_START
NVM_VARS_START_LIN	EQU	@			
#endif	
			ALIGN 	1

NVM_DATA_BUF		DS	NVM_BUF_DEPTH*NVM_PHRASE_SIZE
NVM_DATA_BUF_END	EQU	*

NVM_ADDR_BUF		DS	NVM_BUF_DEPTH*NVM_ADDR_SIZE
NVM_ADDR_BUF_END	EQU	*

NVM_BUF_IN		DS	1			;points to the next free space
NVM_BUF_OUT		DS	1			;points to the oldest entry
	
NVM_TAGS		DS	NVM_FIRMWARE_SIZE/(8*NVM_SECTOR_SIZE)
NVM_TAGS_END		EQU	*
	
NVM_VARS_END		EQU	*
NVM_VARS_END_LIN	EQU	@
		
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	NVM_INIT, 0
			;Initialize the NVM wrapper
			MOVB	#(FDIVLCK|NVM_FDIV_VAL), FCLKDIV;set clock divider
			MOVB	#DFDIE,FERCNFG			;detect ECC double faults
			;Initialize the sector status 
			LDX	#NVM_TAGS
			LDY	#(NVM_TAGS_END-NVM_TAGS)/4
			CLRA
			CLRB
LOOP			STD	2,X+
			STD	2,X+
			DBNE	Y, LOOP
			;Initialize the program buffer (0 in D) 
			STD	NVM_BUF_IN 			;reset IN:OUT
			STD	NVM_ADDR_BUF 			;set initial address
			STD	NVM_ADDR_BUF+2 			;reset IN:OUT
#emac

;#Set the start address of the following input stream (non-blocking)
; args:   Y:X: address
; result: none
; SSTACK: 21 bytes
;         All registers are preserved
#macro	NVM_SET_ADDR_NB, 0
			SSTACK_JOBSR	NVM_SET_ADDR_NB, 21
#emac

;#Set the start address of the following input stream (blocking)
; args:   Y:X: address
; result: none
; SSTACK: 323bytes
;         All registers are preserved
#macro	NVM_SET_ADDR_BL, 0
			SSTACK_JOBSR	NVM_SET_ADDR_BL, 23
#emac
 
;#Submit current phrase for programming (non-blocking)
; args:   none
; result: C-flag: set if successful
; SSTACK: 19 bytes
;         All registers are preserved
#macro	NVM_FLUSH_NB, 0
			SSTACK_JOBSR	NVM_FLUSH_NB, 12
#emac

;#Submit current phrase for programming (blocking)
; args:   none
; result: none
; SSTACK: 21 bytes
;         All registers are preserved
#macro	NVM_FLUSH_BL, 0
			SSTACK_JOBSR	NVM_FLUSH_BL, 14
#emac

;#Program one byte (non-blocking)
; args:   B: data
; result: C-flag: set if successful
; SSTACK: 9  bytes
;         All registers are preserved
#macro	NVM_PGM_BYTE_NB, 0
			SSTACK_JOBSR	NVM_PGM_BYTE_NB, 9
#emac

;#Program one byte (blocking)
; args:   B: data
; result: none
; SSTACK: 11 bytes
;         All registers are preserved
#macro	NVM_PGM_BYTE_BL, 0
			SSTACK_JOBSR	NVM_PGM_BYTE_BL, 11
#emac
	
;#Wait until the FTMRG wrapper is idle
; args:   none
; result: none
; SSTACK:  0 bytes
;         All registers are preserved
#macro	NVM_WAIT_IDLE, 0
			BRCLR	FSTAT,#CCIF,*
#emac

;#Stop NVM activity
; args:   none
; result: none
; SSTACK:  0 bytes
;         All registers are preserved
#macro	NVM_STOP, 0
			BCLR	FSTAT,#CCIF
			MOVB	NVM_BUF_OUT, NVM_BUF_IN
#emac

;#Helper functions
;#----------------
;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved
#macro	NVM_MAKE_BL, 2
			SCI_MAKE_BL \1 \2
#emac

;#Debug output:
;#-------------

;#Display S-record address	
; args:   Y:X: address
; SSTACK: 28 bytes
;         All registers are preserved
#macro	NVM_SHOW_ADDR, 0
			;Save Registers (address in Y:X)
			PSHD						;save D
			;Print header (address in Y:X)
			TFR	X, D	       				;save X
			LDX	#HEADER_STRING 				;string pointer -> X
			STRING_PRINT_BL 				;print string
			TFR	D, X 					;restore X
			;Print address (address in Y:X)
			LDD	#$0610 					;set alignment and base
			NUM_PRINT_ZUD_BL 				;print address
			;Print line break (address in Y:X)
			TFR	X, D	       				;save X
			LDX	#NL_STRING 				;string pointer -> X
			STRING_PRINT_BL 				;print string
			TFR	D, X 					;restore X
			JOB	DONE	  				;done
			;Strings 		
HEADER_STRING		STRING_NL_NONTERM 				;header
			FCS	"Address: "
NL_STRING		STRING_NL_TERM	
DONE			PULD						;restore D
#emac

;#Display data byte	
; args:   B: data
; SSTACK: 34 bytes
;         All registers are preserved
#macro	NVM_SHOW_BYTE, 0
			;Save Registers (data in B)
			PSHX						;save X
			PSHD						;save D
			;Print address (data in B)
			CLRA
			TFR	D, X
			LDD	#$0210 					;set alignment and base
			NUM_PRINT_ZUW_BL 				;print address
			;Restore Registers 
DONE			PULD						;restore D
			PULX						;restore X
#emac

;#Show data buffer	
; args:   none
; SSTACK: 34 bytes
;         All registers are preserved
#macro	NVM_SHOW_BUF, 0
			;Save Registers
			PSHY						;save Y
			PSHX						;save X
			PSHD						;save D
			MOVW	NVM_BUF_IN, 2,-SP			;IN:OUT
			;Print header
			LDX	#HEADER_STRING 				;string pointer -> X
			STRING_PRINT_BL 				;print string (SSTACK: 10 bytes)
			;Check for buffer entries		
LOOP			LDD	0,SP 					;IN:OUT -> D
			CBA						;check for more entries
			BEQ	DONE 					;done
			;Print index (IN:OUT -> D)
			CLRA						;OUT -> D
			TFR	D, X 					;OUT -> X
			LDD	#$0210 					;set format
			NUM_PRINT_ZUW_BL				;print index (SSTACK: 28 bytes)
			LDD	#$0220 					;set format
			STRING_FILL_BL 					;print space (SSTACK: 7 bytes)
			;Print address 			
			LDX	#NVM_ADDR_BUF 				;address buffer -> X
			LDAB	1,SP					;OUT -> B
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;align address
			LSRB						;phrase offset -> B
			LEAX	B,X 					;address pointer -> X
			LDY	0,X 					;upper address word -> Y
			LDX	2,X 					;lower address word -> X
			LDD	#$0810 					;set format
			NUM_PRINT_ZUD_BL				;print index (SSTACK: 24 bytes)
			LDD	#$0220 					;set format
			STRING_FILL_BL 					;print space (SSTACK: 7 bytes)
			;Print data
			LDX	#NVM_DATA_BUF 				;data buffer -> X
			LDAA	1,SP 					;OUT -> A
			LDAB	A,X 					;data -> B
			INCA						;advance OUT
			ANDA	#((NVM_BUF_DEPTH*NVM_PHRASE_SIZE)-1) 	;wrap OUT
			STAA	1,SP 					;update OUT
			CLRA	     					;data -> D
			TFR	D, X		     			;data -> X
			LDD	#$0210 					;set format
			NUM_PRINT_ZUW_BL				;print data (SSTACK: 28 bytes)
			LDX	#NL_STRING 				;string pointer -> X
			STRING_PRINT_BL 				;print string (SSTACK: 10 bytes)
			JOB	LOOP 					;LOOP
			;Strings 
HEADER_STRING		STRING_NL_NONTERM 				;header
			STRING_NL_NONTERM
			FCC	"Data buffer: "
NL_STRING		STRING_NL_TERM
			;Restore Registers 
DONE			PULD						;free stack
			PULD						;restore D
			PULX						;restore X
			PULY						;restore Y
#emac
	
;#Display CCOB content for debug purposes	
; args:   none
; SSTACK: 35 bytes
;         All registers are preserved
#macro	NVM_SHOW_CCOB, 0
			;Save Registers 
			PSHX						;save X
			PSHD						;save D
			MOVB	FCCOBIX, 1,-SP 				;save CC
			;Print header
			LDX	#HEADER_STRING 				;string pointer -> X
			STRING_PRINT_BL 				;print string
			LDAA	FCCOBIX 				;CCOBIX -> A
			TFR	A, X 					;CCOBIX -> X				
			LDD	#$0210 					;set alignment and base (SSTACK: 28 bytes)
			NUM_PRINT_ZUW_BL				;print CCOBIX
			;Print CCOB
			CLR	FCCOBIX 				;reset CCOBIX
LOOP			LDAA	FCCOBIX 				;CCOBIX -> A
			CMPA	#6 					;check if iterations are complete
			BHS	DONE 					;done
			LDX	#CCOB_1_STRING 				;1st CCOBIX string -> X
			STRING_PRINT_BL 				;print string
			LDAA	FCCOBIX 				;CCOBIX -> A
			CMPA	#6 					;check if iterations are complete
			BHS	DONE 					;done
			TFR	A, X 					;CCOBIX -> X
			LDD	#$0210 					;set alignment and base
			NUM_PRINT_ZUW_BL				;print CCOBIX
			LDX	#CCOB_2_STRING 				;1st CCOBIX string -> X
			STRING_PRINT_BL 				;print string
			LDX	FCCOBHI 				;CCOB -> X
			LDD	#$0410 					;set alignment and base
			NUM_PRINT_ZUW_BL				;print CCOB
			INC	FCCOBIX 				;advance CCOBIX
			JOB	LOOP 					;loop
			;Strings 
HEADER_STRING		STRING_NL_NONTERM 				;header
			STRING_NL_NONTERM
			FCC	"New NVM Command: "
			STRING_NL_NONTERM
			FCS	"CCOBIX: "
CCOB_1_STRING		STRING_NL_NONTERM 				;1st CCOB string
			FCS	"CCOB"
CCOB_2_STRING		FCS	": "					;2nd CCOB string
			;Restore Registers 
DONE			MOVB	1,SP+, FCCOBIX 				;restore CCOBIX
			PULD						;restore D
			PULX						;restore X
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef NVM_CODE_START_LIN
			ORG 	NVM_CODE_START, NVM_CODE_START_LIN
#else
			ORG 	NVM_CODE_START
NVM_CODE_START_LIN	EQU	@	
#endif

;#Frontend functions:
;==================== 

;#Set the start address of the following input stream (non-blocking)
; args:   Y:X: address
; result: none
; SSTACK: 21 bytes
;         All registers are preserved
NVM_SET_ADDR_NB 	EQU	*
			;Save registers (address in Y:X)
			PSHY						;save Y	(SP+5)		
			PSHX						;save X	(SP+3)		
			EXG	A, B 					;adjust D for RTI unstacking
			PSHD						;save B:A (SP+1)
			CLC						;signal fail by default
			PSHC						;save C (SP+0)
			;Check if phrase address matches (upper address word in Y)
			LDX	#NVM_ADDR_BUF 				;address buffer -> X
			LDAA	NVM_BUF_IN				;IN -> A
			ANDA	#~(NVM_PHRASE_SIZE-1) 			;phrase offset -> A
			LSRA 						;address buffer offset -> X
			LEAX	A,X 					;address pointer -> X
			CPY	0,X 					;compare upper address word 
			BNE	NVM_SET_ADDR_NB_5			;mismatch
			LDD	3,SP 					;lower address word -> D
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;align address
			CPD	2,X 					;compare lower address word 
			BNE	NVM_SET_ADDR_NB_5			;mismatch
			;Check for gap to fill (upper address word in Y, address pointer in X)
NVM_SET_ADDR_NB_1	LDAA	4,SP 					;lowest address byte -> A
			ANDA	#(NVM_PHRASE_SIZE-1) 			;byte offset -> A
			LDAB	NVM_BUF_IN				;IN -> B
			ANDB	#(NVM_PHRASE_SIZE-1) 			;byte offset -> B
			SBA						;A - B -> A
			BMI	NVM_SET_ADDR_NB_5			;mismatch
			BEQ	NVM_SET_ADDR_NB_3			;done
			LDAB	#NVM_FILL_PATTERN 			;fill pattern -> B
NVM_SET_ADDR_NB_2	NVM_PGM_BYTE_NB 				;program one byte (SSTACK: 9  bytes)
			BCC	NVM_SET_ADDR_NB_4			;signal failure
			DBNE	A, NVM_SET_ADDR_NB_2
			;Signal success
NVM_SET_ADDR_NB_3	BSET	0,SP, #$01				;set C-flag
			;Done
NVM_SET_ADDR_NB_4	SSTACK_PREPULL	9 				;check SSTACK
			RTI  						;done
			;Flush on address mismatch (upper address word in Y)
NVM_SET_ADDR_NB_5	NVM_FLUSH_NB 					;flush phrase (SSTACK: 12 bytes)
			BCC	NVM_SET_ADDR_NB_4 			;signal failure			
			;Update address pointer (upper address word in Y
			LDX	#NVM_ADDR_BUF 				;address buffer -> X
			LDAA	NVM_BUF_IN				;IN -> A
			ANDA	#~(NVM_PHRASE_SIZE-1) 			;phrase offset -> A
			LSRA 						;address buffer offset -> X
			LEAX	A,X 					;address pointer -> X
			;Set phrase address (upper address word in Y, address pointer in X)
			STY	0,X  					;set upper address word
			LDD	3,SP 					;lower address word -> D
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;align address
			STD	2,X  					;set lower address word
			JOB	NVM_SET_ADDR_NB_1 			;fill gap

;#Set the start address of the following input stream (blocking)
; args:   Y:X: address
; result: none
; SSTACK: 23 bytes
;         All registers are preserved
NVM_SET_ADDR_BL 	EQU	*
			;NVM_SHOW_ADDR 					;debug output
			NVM_MAKE_BL	NVM_SET_ADDR_NB, 21
	
;#Submit current phrase for programming (non-blocking)
; args:   none
; result: C-flag: set if successful
; SSTACK: 12 bytes
;         All registers are preserved
NVM_FLUSH_NB		EQU	*
			;Save registers 
			PSHA						;save A			
			SEC						;signal success by default
			PSHC						;save CCR
			;Complete phrase 
			LDAB	#NVM_FILL_PATTERN 			;fill pattern -> B
NVM_FLUSH_NB_1		BRCLR	NVM_BUF_IN,#(NVM_PHRASE_SIZE-1),NVM_FLUSH_NB_2;phrase is complete
			NVM_PGM_BYTE_NB 				;program one byte (SSTACK: 9  bytes)
			BCS	NVM_FLUSH_NB_1 				;success			
			;Signal failure
			BCLR	0,SP, #$01				;clear C-flag
			;Restore registers
NVM_FLUSH_NB_2		SSTACK_PREPULL	4 				;check SSTACK		
			PULC						;restore CCR (incl. result)
			PULB						;restore B
			;Done
			RTS
		
;#Submit current phrase for programming (blocking)
; args:   none
; result: none
; SSTACK: 14 bytes
;         All registers are preserved
NVM_FLUSH_BL		EQU	*
			NVM_MAKE_BL	NVM_FLUSH_NB, 12

;#Program one byte (non-blocking)
; args:   B: data
; result: C-flag: set if successful
; SSTACK: 9  bytes
;         All registers are preserved
NVM_PGM_BYTE_NB		EQU	*
			;Save registers (data in B)
			PSHY						;save Y	(SP+5)		
			PSHX						;save X	(SP+3)		
			PSHA						;save A (SP+2)
			PSHB						;save B (SP+1)
			CLC						;signal fail by default
			PSHC						;save C (SP+0)
			;Store data byte (data in B)
			LDY	#NVM_DATA_BUF 				;data buffer -> Y
			LDAA	NVM_BUF_IN 				;IN -> A
			STAB	A,Y 					;store data
			TAB		    				;IN -> B
			INCA						;advance IN
			ANDA	#((NVM_BUF_DEPTH*NVM_PHRASE_SIZE)-1) 	;wrap IN
			CMPA	NVM_BUF_OUT 				;check if buffer is full
			BEQ	NVM_PGM_BYTE_NB_2 			;signal failure (buffer is full)
			STAA	NVM_BUF_IN 				;update IN
			;Check if phrase is complete (new IN in A, old IN in B)
			BITA	#(NVM_PHRASE_SIZE-1) 			;check if phrase is complete
			BNE	NVM_PGM_BYTE_NB_1 			;phrase is still incomplete
			;Set new phrase address (new IN in A, old IN in B)
			ANDA	#~(NVM_PHRASE_SIZE-1) 			;new phrase offset -> A
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;old phrase offset -> A
			LSRD						;new address offset -> A, old address offset -> B
			LDX	#NVM_ADDR_BUF 				;address buffer -> X
			LEAY	B,X 					;old address pointer -> Y
			LEAX	A,X 					;new address pointer -> X
			LDD	2,Y 					;old lower address word -> D
			ADDD	#NVM_PHRASE_SIZE 			;advance lower address word
			STD	2,X 					;update lower address word
			LDD	0,Y 					;upper address word -> D
			ADCB	#0 					;advance upper address word
			ADCA	#0 					;
			STD	0,X 					;update upper address word
			;Submit complete phrase to NVM (new IN in A, old IN in B)
			;NVM_SHOW_BUF 					;debug output
			BSET	FCNFG, #CCIE 				;enable interrupt
			;Signal success
NVM_PGM_BYTE_NB_1	;NVM_SHOW_BUF 					;debug output
			BSET	0,SP, #$01				;set C-flag
			;Done
NVM_PGM_BYTE_NB_2	SSTACK_PREPULL	9 				;check SSTACK
			RTI

;#Program one byte (blocking)
; args:   B: data
; result: none
; SSTACK: 11 bytes
;         All registers are preserved
NVM_PGM_BYTE_BL		EQU	*
			;NVM_SHOW_BYTE 					;debug output
			NVM_MAKE_BL	NVM_PGM_BYTE_NB, 9

;ISRs
;----

;#Command complete interrupt
;---------------------------
NVM_ISR_CC		EQU	*			
			;Clear busy signal 
			LED_OFF A 					;not busy anymore			
			;Check for errors of previous operation 
			LDAB	FSTAT 					;FSTAT -> B
			ANDB	#(ACCERR|FPVIOL|MGSTAT1|MGSTAT0)	;mask error flags
			BNE	NVM_ISR_CC_7 				;error detected
			;Check if data is available for programming 
			LDD	NVM_BUF_IN 				;IN:OUT -> A:B
			ANDA	#~(NVM_PHRASE_SIZE-1) 			;align in to phrase boundary
			CBA						;compare pointers
			BEQ	NVM_ISR_CC_10 				;buffer is empty
			;Get phrase address (OUT in B)
			LDY	#NVM_ADDR_BUF 				;address buffer -> Y
			LSRB						;buffer offset -> B
			LEAY	B,Y 					;address pointer -> Y
			;Check phrase address (address pointer in Y) 
			LDX	0,Y 					;upper address word -> X
			BEQ	NVM_ISR_CC_1 				;address < 64K
			CPX	#(NVM_FIRMWARE_START_LIN>>16) 		;check lower boundary
			BHS	NVM_ISR_CC_2 				;address is within range
NVM_ISR_CC_1		LDX	2,Y 					;lower address word -> X
			CPX	#NVM_FIRMWARE_END_LIN	 		;check upper boundary
			BHS	NVM_ISR_CC_8 				;address out of range
			;Set phrase address (address pointer in Y) 
NVM_ISR_CC_2		CLR	FCCOBIX	 				;reset CCOB index
			MOVB	#NVM_CMD_PROG, FCCOBHI 			;set command byte (program P-flash)
			MOVB	1,Y, FCCOBLO 				;set upper address byte
			INC	FCCOBIX 				;advance CCOB index
			MOVW	2,Y, FCCOBHI 				;set lower address word
			;Determine tag address (address pointer in Y)
			LDD	1,Y 					;address/256 -> D
			LSRD						;sector address -> D
			TFR	D, X					;sector address -> X
			LSRD						;sector address/8 -> D
			LSRD						;
			LSRD						;
			EXG	D, X					;sector address/8 -> X, sector address -> D
			LEAX	(NVM_TAGS-(NVM_FIRMWARE_START_LIN>>12)),X;tag address -> X
			;Determine tag bit (tag address in X, sector address/8 in D)
			LDAA	#1		     			;bit 0 -> A
			ANDB	#(NVM_PHRASE_SIZE-1) 			;bit offset -> B
			BEQ	NVM_ISR_CC_4 				;bit offset = 0
NVM_ISR_CC_3 		LSLA						;shift bit index
			DBNE	B, NVM_ISR_CC_3 			;tag bit -> A
			;Check tag (tag address in X, tag bit in A)
NVM_ISR_CC_4 		TAB						;tag bit -> B
			ANDB	0,X 					;tag status -> B
			BEQ	NVM_ISR_CC_11 				;erase sector
			;Set data field
			LDX	#NVM_DATA_BUF 				;data buffer -> X
			LDAA	NVM_BUF_OUT 				;OUT -> A
			LEAX	A,X 					;phrase address -> X
			INC	FCCOBIX 				;advance CCOB index
			MOVW	0,X, FCCOBHI 				;set first data word
			INC	FCCOBIX 				;advance CCOB index
			MOVW	2,X, FCCOBHI 				;set first data word
			INC	FCCOBIX 				;advance CCOB index
			MOVW	4,X, FCCOBHI 				;set first data word
			INC	FCCOBIX 				;advance CCOB index
			MOVW	6,X, FCCOBHI 				;set first data word
			ADDA	#NVM_PHRASE_SIZE     			;advance OUT
			ANDA	#((NVM_BUF_DEPTH*NVM_PHRASE_SIZE)-1) 	;wrap OUT
			STAA	NVM_BUF_OUT 				;update out
			;Launch NVM command
NVM_ISR_CC_5		LED_ON A 					;show activity			
			MOVB	#CCIF, FSTAT 				;launch command
			;BCLR	FCNFG, #CCIE 				;debug output
			;CLI 						;debug output
			;NVM_SHOW_CCOB 					;debug output
			;SEI 						;debug output
			;BSET	FCNFG, #CCIE 				;debug output
			;Done
NVM_ISR_CC_6		ISTACK_RTI 					;done
			;Error found
NVM_ISR_CC_7		LDAA	#NVM_ERR_HW 				;HW error -> A
			BITB	#(MGSTAT1|MGSTAT0)			;check for HW error
			BNE	NVM_ISR_CC_9				;HW error
NVM_ISR_CC_8		LDAA	#NVM_ERR_ADDR 				;address error -> A
NVM_ISR_CC_9		LEAS	9,SP 					;free stack space
			CLI						;enable interrupts
			NVM_ERROR_HANDLER				;handle errors
			;Buffer is empty
NVM_ISR_CC_10		BCLR	FCNFG, #CCIE 				;disable interrupt
			JOB	NVM_ISR_CC_6 				;done
			;Erase sector (tag address in X, tag bit in A)
NVM_ISR_CC_11		ORAA	0,X 					;set tag
			STAA	0,X 					;
			CLR	FCCOBIX	 				;reset CCOB index
			MOVB	#NVM_CMD_ERASE, FCCOBHI 		;set command byte (program P-flash)
			INC	FCCOBIX 				;advance CCOB index
			JOB	NVM_ISR_CC_5 				;launch command
	
NVM_CODE_END		EQU	*	
NVM_CODE_END_LIN	EQU	@	
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef NVM_TABS_START_LIN
			ORG 	NVM_TABS_START, NVM_TABS_START_LIN
#else
			ORG 	NVM_TABS_START
NVM_TABS_START_LIN	EQU	@	
#endif	

	
NVM_TABS_END		EQU	*
NVM_TABS_END_LIN	EQU	@
#endif
