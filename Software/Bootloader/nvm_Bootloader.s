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
NVM_BUF_DEPTH		EQU	32			;default is 32 entries (maximum)
#endif	

;Firmware range
;-------------- 
#ifndef NVM_FIRMWARE_START_LIN
NVM_FIRMWARE_START_LIN	EQU	MMAP_FLASH_F_END_LIN-MMAP_FLASH_SIZE
#endif	
#ifndef NVM_FIRMWARE_END_LIN
NVM_FIRMWARE_END_LIN	EQU	MMAP_FLASH_F_END_LIN
;NVM_FIRMWARE_END_LIN	EQU	MMAP_FLASH_F_END_LIN-BOOTLOADER_SIZE
#endif	
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Sector size
NVM_SECTOR_SIZE		EQU	512			;sector size  [bytes]
NVM_PHRASE_SIZE		EQU	8			;phrase size  [bytes]
NVM_ADDR_SIZE		EQU	4			;address size [bytes]

;Size of a buffer entry
NVM_QUEUE_ENTRY_SIZE	EQU	NVM_PHRASE_SIZE+2 	;buffer entry size [bytes]
	
;Firmware size
NVM_FIRMWARE_SIZE	EQU	NVM_FIRMWARE_END_LIN-NVM_FIRMWARE_START_LIN
			
;Offset of the sector status field (sector address corresponding to NVM_TAGS
NVM_TAGS_OFFS		EQU	NVM_FIRMWARE_START_LIN/(8*NVM_SECTOR_SIZE)

;NVM commands 
NVM_CMD_PROG		EQU	$06			;program P-flash command
NVM_CMD_ERASE		EQU	$0A			;erase P-flash sector command
NVM_CMD_VERIFY		EQU	$03			;erase verify P-flash section command

;NVM commands 
NVM_FILL_PATTERN	EQU	$FF 			;fill gaps with $FF
	
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
			STD	NVM_QUEUE_IN	
#emac

;#Set the start address of the following input stream (non-blocking)
; args:   X:Y: address
; result: none
; SSTACK: 28 bytes
;         All registers are preserved
#macro	NVM_SET_ADDR_NB, 0
			SSTACK_JOBSR	NVM_SET_ADDR_NB, 28
#emac

;#Set the start address of the following input stream (blocking)
; args:   X:Y: address
; result: none
; SSTACK: 30 bytes
;         All registers are preserved
#macro	NVM_SET_ADDR_BL, 0
			SSTACK_JOBSR	NVM_SET_ADDR_BL, 30
#emac
 
;#Submit current phrase for programming (non-blocking)
; args:   none
; result: C-flag: set if successful
; SSTACK: 19 bytes
;         All registers are preserved
#macro	NVM_FLUSH_NB, 0
			SSTACK_JOBSR	NVM_FLUSH_NB, 19
#emac

;#Submit current phrase for programming (blocking)
; args:   none
; result: none
; SSTACK: 21 bytes
;         All registers are preserved
#macro	NVM_FLUSH_BL, 0
			SSTACK_JOBSR	NVM_FLUSH_BL, 21
#emac

;#Submit current phrase for programming (non-blocking)
; args:   A:      fill size (bytes)
; result: C-flag: set if successful
; SSTACK: 15 bytes
;         All registers are preserved
#macro	NVM_FILL_NB, 0
			SSTACK_JOBSR	NVM_FILL_NB, 15
#emac

;#Submit current phrase for programming (blocking)
; args:   none
; result: none
; SSTACK: 17 bytes
;         All registers are preserved
#macro	NVM_FILL_BL, 0
			SSTACK_JOBSR	NVM_FILL_BL, 17
#emac

;#Program one byte (non-blocking)
; args:   B: data
; result: none
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





	
;#Program P-flash phrase (non-blocking)
; args:   Y:      phrase address (byte address/8)
;         X:      data pointer
; result: C-flag: set if successful
; SSTACK: 11 bytes
;         All registers are preserved
#macro	NVM_PGM_PHRASE_NB, 0
			SSTACK_JOBSR	NVM_PGM_PHRASE_NB, 11
#emac

;#Program P-flash phrase (blocking)
; args:   Y: phrase address (byte address/8)
;         X: data pointer
; result: none
; SSTACK: 13 bytes
;         All registers are preserved
#macro	NVM_PGM_PHRASE_BL, 0
			SSTACK_JOBSR	NVM_PGM_PHRASE_BL 11
#emac

;#Wait until the FTMRG wrapper is idle
; args:   none
; result: none
; SSTACK:  0 bytes
;         All registers are preserved
#macro	NVM_WAIT_IDLE, 0
			BRCLR	FSTAT,#CCIF,*
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
; args:   X:Y: address
; result: none
; SSTACK: 28 bytes
;         All registers are preserved
NVM_SET_ADDR_NB 	EQU	*
			;Save registers (data in B)
			PSHY						;save X	(SP+5)		
			PSHX						;save Y	(SP+3)		
			PSHD						;save D	(SP+1)
			CLC						;signal fail by default
			PSHC						;save C (SP+0)
			;Get address pointer (upper address word in X)
			LDAA	NVM_BUF_IN 				;IN -> A
			LDY	#NVM_ADDR_BUF 				;address buffer -> Y
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;address pointer -> Y
			LSRB						;
			LEAY	B,Y 					;
			;Check if address in in the same phrase (upper address word in X, address pointer -> Y)
			CPX	0,Y 					;compare upper address word
			BNE	NVM_SET_ADDR_NB_1 			;flush phrase
			LDD	5,SP	 				;lower address word -> D
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;align address
			CPD	2,Y 					;compare lower address word
			BEQ	NVM_SET_ADDR_NB_4 			;new address is within current phrase
			;Flush previous phrase (upper address word in X)
NVM_SET_ADDR_NB_1	NVM_FLUSH_NB 					;(SSTACK: 19 bytes)
			BCC	NVM_SET_ADDR_NB_3 			;fail
			;Set new phrase address (upper address word in X)  
			LDAA	NVM_BUF_IN 				;IN -> A
			LDY	#NVM_ADDR_BUF 				;address buffer -> Y
			ANDB	#~(NVM_PHRASE_SIZE-1) ;redundand	;address pointer -> Y
			LSRB						;
			LEAY	B,Y 					;
			STX	0,Y 					;set upper address word
			LDD	3,SP 					;lower address word -> D
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;align lower address word
			STD	2,Y 					;set lower address word
			;Align data buffer 
			LDAA	3,SP 					;lowest address byte -> A
			ANDA	#(NVM_PHRASE_SIZE-1) 			;phrase offset -> A
NVM_SET_ADDR_NB_2	NVM_FILL_NB 					;(SSTACK: 15 bytes)
			BCC	NVM_SET_ADDR_NB_3 			;fail
			;Signal success
			BSET	0,SP, #$01				;set C-flag
			;Done
NVM_SET_ADDR_NB_3	SSTACK_PREPULL	9 				;check SSTACK
			RTI  						;done
			;New address is within the current phrase
NVM_SET_ADDR_NB_4	LDAA	4,SP 					;lowest address byte -> A
			ANDA	#(NVM_PHRASE_SIZE-1) 			;phrase offset -> A
			LDAB	NVM_BUF_IN 				;IN -> B
			ANDB	#(NVM_PHRASE_SIZE-1) 			;phrase offset -> B
			SBA			  			;fill gap -> A
			BPL	NVM_SET_ADDR_NB_2 			;fill gap
			JOB	NVM_SET_ADDR_NB_1 			;flush phrase

;#Set the start address of the following input stream (blocking)
; args:   X:Y: address
; result: none
; SSTACK: 30 bytes
;         All registers are preserved
NVM_SET_ADDR_BL 	EQU	*
			NVM_MAKE_BL	NVM_SET_ADDR_NB, 28
	
;#Submit current phrase for programming (non-blocking)
; args:   none
; result: C-flag: set if successful
; SSTACK: 19 bytes
;         All registers are preserved
NVM_FLUSH_NB		EQU	*
			;Save registers 
			PSHA						;save A			
			SEC						;signal success by default
			PSHC						;save CCR
			;Calculate number of fill bytes 
			LDAA	NVM_BUF_IN 				;IN -> A
			NEGA						;empty space in phrase -> A
			ANDA	#(NVM_PHRASE_SIZE-1) 			;
			;Program fill bytes (fill size in A) 
			NVM_FILL_NB 					;fill memory (SSTACK: 15 byte)
			BCS	NVM_FLUSH_NB_1 				;signal success
			;Signal failure
			BCLR	0,SP, #$01				;clear C-flag
			;Restore registers
NVM_FLUSH_NB_1		SSTACK_PREPULL	4 				;check SSTACK		
			PULC						;restore CCR (incl. result)
			PULB						;restore B
			;Done
			RTS
		
;#Submit current phrase for programming (blocking)
; args:   none
; result: none
; SSTACK: 21 bytes
;         All registers are preserved
NVM_FLUSH_BL		EQU	*
			NVM_MAKE_BL	NVM_FLUSH_NB, 19

;#Submit current phrase for programming (non-blocking)
; args:   A:      fill size (bytes)
; result: C-flag: set if successful
; SSTACK: 15 bytes
;         All registers are preserved
NVM_FILL_NB		EQU	*
			;Save registers (fill size in A)
			PSHD						;save D			
			CLC						;signal fail by default
			PSHC						;save CCR
			;Check for zero size (fill size in A)
			TBEQ	A, NVM_FILL_NB_2			;success
			;Fill loop (fill size in A)
			LDAB	#NVM_FILL_PATTERN 			;fill pattern -> B
NVM_FILL_NB_1		NVM_PGM_BYTE_NB 				;program one byte (SSTACK: 9  bytes)
			BCC	NVM_FAIL_NB_3 				;fail
			DBNE	A, NVM_FILL_NB_1 			;loop
			;Signal success
NVM_FILL_NB_2		BSET	0,SP, #$01				;set C-flag
			;Restore registers
NVM_FILL_NB_3		SSTACK_PREPULL	5 				;check SSTACK		
			PULC						;restore CCR (incl. result)
			PULD						;restore D
			;Done
			RTS

;#Submit current phrase for programming (blocking)
; args:   none
; result: none
; SSTACK: 17 bytes
;         All registers are preserved
NVM_FILL_BL		EQU	*
			NVM_MAKE_BL	NVM_FLUSH_NB, 15
	
;#Program one byte (non-blocking)
; args:   B: data
; result: none
; SSTACK: 9  bytes
;         All registers are preserved
NVM_PGM_BYTE_NB		EQU	*
			;Save registers (data in B)
			PSHY						;save X	(SP+5)		
			PSHX						;save Y	(SP+3)		
			PSHD						;save D	(SP+1)
			CLC						;signal fail by default
			PSHC						;save C (SP+0)
			;Store data byte (data in B)
			LDY	NVM_DATA_BUF 				;data buffer -> Y
			LDAA	NVM_BUF_IN 				;IN -> A
			STAB	A,Y 					;store data
			TAB		    				;IN -> B
			INCA						;advance IN
			ANDA	#((NVM_BUF_DEPTH*NVM_PHRASE_SIZE)-1) 	;wrap IN
			CMPA	NVM_BUF_OUT 				;check if buffer is full
			BEQ	NVM_PGM_BYTE_NB_2 			;buffer is full
			STAA	NVM_BUF_IN 				;update IN
			;Check if phrase is complete (new IN in A, old IN in B)
			BITA	#(NVM_PHRASE_SIZE-1) 			;check if phrase is complete
			BNE	NVM_PGM_BYTE_NB_1 			;phrase is still incomplete
			;Submit complete phrase to NVM (new IN in A, old IN in B)
			BSET	FCNFG, #CCIE 				;enable interrupt
			;Start new phrase  (new IN in A, old IN in B)
			LDX	NVM_ADDR_BUF 				;address buffer -> X
			TFR	X, Y 					;address buffer -> Y
			LSRA						;new address buffer offset -> A
			LEAY	A,Y 					;new address location -> Y
			ANDB	#~(NVM_PHRASE_SIZE-1) 			;old address buffer offset -> B
			LSRB						;
			LEAX	B,X 					;old address location -> X	
			LDD	2,X 					;old address -> D
			ADDD	#NVM_PHRASE_SIZE 			;advance address
			STD	2,Y 					;store new address
			CLRB						;0 -> B 
			ADCB	1,X					;propagate carry	
			CLRA						;0 -> A
			ADCA	0,X					;propagate carry	
			STD	0,Y 					;store new address
			;Signal success
NVM_PGM_BYTE_NB_1	BSET	0,SP, #$01				;set C-flag
			;Done
NVM_PGM_BYTE_NB_2	SSTACK_PREPULL	9 				;check SSTACK
			RTI

;#Program one byte (blocking)
; args:   B: data
; result: none
; SSTACK: 11 bytes
;         All registers are preserved
NVM_PGM_BYTE_BL		EQU	*

			NVM_MAKE_BL	NVM_PGM_BYTE_NB, 9


;#Backend functions:
;=================== 


	
;#Program P-flash phrase (non-blocking)
; args:   Y:      phrase address (byte address/8)
;         X:      data pointer
; result: C-flag: set if successful
; SSTACK: 11 bytes
;         All registers are preserved
NVM_PGM_PHRASE_NB	EQU	*
			;Save registers
			PSHY						;save Y   (SP+5)
			PSHX						;save X   (SP+3)
			PSHD						;save D   (SP+1)
			CLC						;signal failure by default
			PSHC						;save CCR (SP+0)		
			;Check if queue is full (phrase address in Y)
			LDAA	NVM_QUEUE_IN 				;IN -> A
			TAB						;IN -> B
			INCB 						;increment IN (B)
			ANDB	#(NVM_QUEUE_DEPTH-1) 			;wrap IN (B)
			CMPB	NVM_QUEUE_OUT	   			;check if queue is full
			BEQ	NVM_PGM_PHRASE_NB_1 			;queue is full	
			;Copy address to queue (old IN in A, new IN in B, phrase address in Y) 
			LDX	#NVM_ADDR_QUEUE 			;address queue -> X
			LEAX	A,X 					;add offset (1 byte)
			STY	A,X 					;store address		
			;Copy address to queue (old IN in A, new IN in B) 
			LDY	3,SP 					;data pointer -> Y 
			LDX	#NVM_DATA_QUEUE 			;address queue -> X
			LEAX	A,X					;add offset (1 byte)
			LEAX	A,X					;add offset (2 bytes)
			LEAX	A,X					;add offset (3 bytes)
			LEAX	A,X					;add offset (4 bytes)
			LEAX	A,X					;add offset (5 bytes)
			LEAX	A,X					;add offset (6 bytes)
			LEAX	A,X					;add offset (7 bytes)					;add offset
			LEAX	A,X					;add offset (8 bytes)					;add offset
			MOVW	2,X+, 2,Y+ 				;copy data
			MOVW	2,X+, 2,Y+ 				;copy data
			MOVW	2,X+, 2,Y+ 				;copy data
			MOVW	2,X+, 2,Y+ 				;copy data			
			;Update IN (new IN in B) 
			STAB	NVM_QUEUE_IN 				;update IN
			;Signal success 
			BSET	0,SP, #$01				;signal success
			;Enable CC interrupt 
NVM_PGM_PHRASE_NB_1	MOVB	#CCIE, FCNFG 				;enable interruptr
			;Return result
			SSTACK_PREPULL	9 				;check SSTACK
			;PULC						;restore CCR (incl. result)
			;PULD						;restore D
			;PULX						;restore X
			;PULY						;restore Y
			;RTS						;done
			RTI						;shortcut

;#Program P-flash phrase (blocking)
; args:   Y: phrase address (byte address/8)
;         X: data pointer
; result: none
; SSTACK: 13 bytes
;         All registers are preserved
NVM_PGM_PHRASE_BL	EQU	*
			NVM_MAKE_BL	NVM_PGM_PHRASE_NB, 11


;ISRs
;----
;+-----+-----+-----+--------------------------------- 
;| Tag |FCMD |FSTAT|       Action
;+-----+-----+-----+--------------------------------- 
;|  -  |  06 | 
;+-----+-----+-------------------------------------- 
	
;Programming interrupt 
NVM_ISR			EQU	*
			;Turn of BUSY LED 

	
			;Check for errors 
;			BRCLR	FSTAT,#(ACCERR|FPVIOL|MGSTAT),NVM_ISR_ ;no errrs

			BGND	;TBD


;			;Check if the queue is empty 
;NVM_ISR_		LDD	NVM_QUEUE_IN 				;IN -> A, OUT -> B
;			CBA						;check for empty queue 
;			BEQ						;queue is empty
;			;Check if sector has already been reased (OUT in B)
;			LDX	#NVM_ADDR_QUEUE				;address queue -> X
;			LEAX	B,X 					;
;			LDX	B,X	
	

	
;			;Check for the result of the previous operation
;			CLR	FCCOBIX 			;reset FCCOBIX index
;			LDAB	FCCOB				;last FCMD -> B
;			BEQ	NVM_ISR_1			;no prior NVM operation
;			LDAA	FSTAT				;FSTAT -> A
;			BITA	#(ACCERR|FPVIOL|MGSTAT1|MGSTAT0);check for errors
;			BNE	NVM_ISR_			;error found
;			CMPA	#NVM_CMD_ERASE			;check for erase operation
;			BEQ	NVM_ISR_			;check result of erase operation
;			CMPA	#NVM_CMD_VERIFY			;check for erase verify operation
;			BEQ	NVM_ISR_			;check result of erase verify operation			
;			;Check for queed jobs
;NVM_ISR_1		LDD	NVM_QUEUE_IN 			;IN-> A, OUT -> B
;			CBA					;check if queue is empty
;			BEQ	NVM_ISR_			;nothing to do
;			;Get phrase address (OUT in B) 
;			LDX	#(NVM_QUEUE+NVM_PHRASE_SIZE) 	;first address field -> X 
;			LDX	B,X				;phrase address -> X
;			TFR	X, D				;phrase address -> D
;			LSLD					;shift phrase address
;
;
;
;
;
;			ADCB	#0				;MSB -> LSB
;			LSLD					;shift phrase address				
;			ADCB	#0				;MSB -> LSB
;			LSLD					;shift phrase address
;			ADCB	#0				;MSB -> LSB
;			MOVB	#$01, FCCOBIX			;point to CCOB address[15:0]
;			STD	FCCOB				;store address[15:0] in FCCOB
;			BCLR	FCCOB+1, #$07			;clear address[2:0]
;			




	
;#Check and set sector status
; args:   Y: address[19:4]
; result: C-flag: previous state of the status bit
; SSTACK:  bytes
;         All registers are preserved
NVM_SET_CHK_STAT	EQU	*
			;Save registers (address[19:4] in Y)
			PSHX 					;save X
			PSHY 					;save Y
			;Check address range (address[19:4] in Y)


			;Determine status field address (address[19:4] in Y)
			LEAY	-(NVM_FIRMWARE_START_LIN>>3),Y 	;zero aligned address[19:4]
			TFR	Y, D 				;byte offset -> A, bit position -> B
			LDY	#NVM_TAGS			;status field offset -> Y
			LDY	A,Y				;status field address -> Y
			;Determine status field bit position (status field address[19:4] in Y, bit position in B)
			CLRA					;clear bit mask
			ANDB	#$E0				;align pit poition to sector size
			SEC					;set initial shift value
NVM_SET_CHK_STAT_1	ROLA					;shift mask
			SUBB	#$20				;secrement counter
			BNE	NVM_SET_CHK_STAT_1		;iterate
			;Check and set status flag (status field address[19:4] in Y, bit mask in A)
			
	
	
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
