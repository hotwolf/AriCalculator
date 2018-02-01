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
#ifndef NVM_QUEUE_DEPTH
NVM_QUEUE_DEPTH		EQU	128			;default is 128 entries
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
NVM_ADDR_SIZE		EQU	2			;address size [bytes]

;Size of a buffer entry
NVM_QUEUE_ENTRY_SIZE	EQU	NVM_PHRASE_SIZE+2 	;buffer entry size [bytes]
	
;Firmware size
NVM_FIRMWARE_SIZE	EQU	NVM_FIRMWARE_END_LIN-NVM_FIRMWARE_START_LIN
			
;Offset of the sector status field (sector address corresponding to NVM_TAGS
NVM_TAGS_OFFS	EQU	NVM_FIRMWARE_START_LIN/(8*NVM_SECTOR_SIZE)

;NVM commands 
NVM_CMD_PROG		EQU	$06			;program P-flash command
NVM_CMD_ERASE		EQU	$0A			;erase P-flash sector command
NVM_CMD_VERIFY		EQU	$03			;erase verify P-flash section command
	
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
	
NVM_TAGS		DS	NVM_FIRMWARE_SIZE/(8*NVM_SECTOR_SIZE)
NVM_TAGS_END		EQU	*

NVM_ADDR_QUEUE		DS	NVM_QUEUE_DEPTH*NVM_ADDR_SIZE
NVM_ADDR_QUEUE_END	EQU	*

NVM_DATA_QUEUE		DS	NVM_QUEUE_DEPTH*NVM_PHRASE_SIZE
NVM_DATA_QUEUE_END	EQU	*

NVM_QUEUE_IN		DS	1		;points to the next free space
NVM_QUEUE_OUT		DS	1		;points to the oldest entry
	
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

;#Program P-flash phrase (non-blocking)
; args:   Y:      phrase address (byte address/8)
;         X: d    ata pointer
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
