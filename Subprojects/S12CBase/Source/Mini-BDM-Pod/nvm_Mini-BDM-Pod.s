#ifndef	NVM_COMPILED
#define	NVM_COMPILED
;###############################################################################
;# S12CBase - NVM - NVM Driver (Mini-BDM-Pod)                                  #
;###############################################################################
;#    Copyright 2010-2013 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
;#    families.                                                                #
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
;#    This module contains NVM write and erase functions.                      #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    May 27, 2013                                                             #
;#      - Initial release                                                      #
;#    February 5, 2014                                                         #
;#      - Fixed NVM_PHRASE_SIZE                                                #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Prescaler value
#ifndef NVM_FDIV_VAL
NVM_FDIV_VAL		EQU	(CLOCK_OSC_FREQ/1000000)-1
#endif

;Fixed page protection
;--------------------- 
#ifndef	NVM_FIXED_PAGE_PROT_ON
#ifndef	NVM_FIXED_PAGE_PROT_OFF
NVM_FIXED_PAGE_PROT_ON	EQU	1	;default is NVM_FIXED_PAGE_PROT_ON	
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Program/erase sizes
;-------------------- 
NVM_PHRASE_SIZE		EQU	8
NVM_SECTOR_SIZE		EQU	1024

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef NVM_VARS_START_LIN
			ORG 	NVM_VARS_START, NVM_VARS_START_LIN
#else
			ORG 	NVM_VARS_START
NVM_VARS_START_LIN	EQU	@			
#endif	

NVM_VARS_END		EQU	*
NVM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	NVM_INIT, 0
			MOVB	#NVM_FDIV_VAL, FCLKDIV
			MOVB	#DFDIE,FERCNFG 
#emac	
	
;#Program phrase
; args:   X:      target address within paging window
;	  PPAGE:  current page
;	  Y:      data pointer 
; result: C-flag: set if successful
; SSTACK: 18 bytes
;         X, Y, and D are preserved
#macro	NVM_PROGRAM_PHRASE, 0
			SSTACK_JOBSR	NVM_PROGRAM_PHRASE, 18
#emac

;#Erase sector
; args:   X:      sector address
;	  PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 18 bytes
;         X, Y, and D are preserved
#macro	NVM_ERASE_SECTOR, 0
			SSTACK_JOBSR	NVM_ERASE_SECTOR, 18
#emac

;#Erase page
; args:   PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 22 bytes
;         X, Y, and D are preserved
#macro	NVM_ERASE_PAGE, 0
			SSTACK_JOBSR	NVM_ERASE_PAGE, 22
#emac

;#Check fixed page protection 
; args:   1:      escape address (in case of violation)
;	  PPAGE:  current page
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	NVM_CHECK_FIXED_PAGE_PROT, 1
#ifndef	NVM_FIXED_PAGE_PROT_ON
	BRSET	PPAGE, #$FD, \1
#endif
#emac

;#Set command and address 
; args:   X:      target address within paging window
;	  PPAGE:  current page
;	  A:      command 
; result: CCOBIX: $01
;         C-flag: set if successful
; SSTACK: 4 bytes
;         X, Y, and D are preserved
#macro	NVM_SET_CMD, 0
			SSTACK_JOBSR	NVM_SET_CMD, 4
#emac

;#Execute NVM command from RAM
; args:   none
; result: none
; SSTACK: 15 bytes
;         X, Y, and D are preserved
#macro	NVM_EXEC_CMD, 0
			SSTACK_JOBSR	NVM_EXEC_CMD, 15
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
	
;#Program phrase
; args:   X:      target address within paging window
;	  PPAGE:  current page
;	  Y:      data pointer 
; result: C-flag: set if successful
; SSTACK: 18 bytes
;         X, Y, and D are preserved
NVM_PROGRAM_PHRASE	EQU	*
			;Protect fixed pages
			NVM_CHECK_FIXED_PAGE_PROT  NVM_PROGRAM_PHRASE_1
			;Save registers (paged address in X, data pointer in Y)
			PSHA 					;push A onto the SSTACK
			;Set CCOB  (paged address in X, data pointer in Y)
			LDAA	#$06 				;program P-flash
			NVM_SET_CMD
			INC	FCCOBIX	    			;CCOBIX=$002
			MOVW	0,Y, FCCOBHI
			INC	FCCOBIX	    			;CCOBIX=$003
			MOVW	2,Y, FCCOBHI
			INC	FCCOBIX	    			;CCOBIX=$004
			MOVW	4,Y, FCCOBHI
			INC	FCCOBIX	    			;CCOBIX=$005
			MOVW	6,Y, FCCOBHI
			;Execute command 
			NVM_EXEC_CMD
			;Restore registers
			SSTACK_PREPULL	3
			PULA					;pull A from the SSTACK
			;Check result
			SEC
			BRCLR	FSTAT, #(ACCERR|FPVIOL|MGSTAT1|MGSTAT0), NVM_PROGRAM_PHRASE_2
NVM_PROGRAM_PHRASE_1	CLC
			;Done
NVM_PROGRAM_PHRASE_2	RTS
						
;#Erase sector
; args:   X:      sector address
;	  PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 18 bytes
;         X, Y, and D are preserved
NVM_ERASE_SECTOR	EQU	*
			;Protect fixed pages
			NVM_CHECK_FIXED_PAGE_PROT  NVM_ERASE_SECTOR_1
			;Save registers (paged address in X)
			PSHA 					;push A onto the SSTACK
			;Set CCOB  (paged address in X)
			LDAA	#$0A 				;erase P-flash sector
			NVM_SET_CMD
			;Execute command 
			NVM_EXEC_CMD
			;Restore registers
			SSTACK_PREPULL	3
			PULA					;pull A from the SSTACK
			;Check result
			SEC
			BRCLR	FSTAT, #(ACCERR|FPVIOL|MGSTAT1|MGSTAT0), NVM_ERASE_SECTOR_2
NVM_ERASE_SECTOR_1	CLC
			;Done
NVM_ERASE_SECTOR_2	RTS
	
;#Erase page
; args:   PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 22 bytes
;         X, Y, and D are preserved
NVM_ERASE_PAGE		EQU	*
			;Save registers (paged address in X, data pointer in Y)
			PSHX 					;push X onto the SSTACK
			;Erase all 16 sdectors sector 
			LDX	#$8000		
NVM_ERASE_PAGE_1	NVM_ERASE_SECTOR
			BCC	NVM_ERASE_PAGE_2			;error occured
			LEAX	NVM_SECTOR_SIZE,X
			CPX	$C000
			BLO	NVM_ERASE_PAGE_1
			;Restore registers (page erased)
			SSTACK_PREPULL	4
			PULX					;pull X from the SSTACK
			;Done
			SEC
			RTS
			;Restore registers (error condition)
NVM_ERASE_PAGE_2	SSTACK_PREPULL	4
			PULX					;pull X from the SSTACK
			;Done
			CLC
			RTS

	
;#Set command and address 
; args:   X:      target address within paging window
;	  PPAGE:  current page
;	  A:      command 
; result: CCOBIX: $01
; SSTACK: 4 bytes
;         X, Y, and D are preserved
NVM_SET_CMD		EQU	*
			;Save registers (paged address in X, data pointer in Y)
			PSHD 					;push D onto the SSTACK
			;Set command  (paged address in X, command in A)
			CLR	FCCOBIX	    			;CCOBIX=$00	
			STAA	FCCOBHI				;set command
			;Set ADDR[23:16]  (paged address in X)
			LDAA	PPAGE
			CLRB
			LSRA 					
			LSRA 					
			ORAA	#$40
			STAA	FCCOBLO
			;Set ADDR[15:0]  (paged address in X, ADDR[15:14] in B)
			MOVB	#$01, FCCOBIX
			STX	FCCOBHI				;set ADDR[13:0]
			LDAA	FCCOBHI				;set ADDR[15:14]
			ANDA	#$3F
			ABA
			STAA	FCCOBHI
			;Done
			SSTACK_PREPULL	4
			RTS

;#Execute NVM command from RAM
; args:   none
; result: none
; SSTACK: 15 bytes
;         X, Y, and D are preserved
NVM_EXEC_CMD		EQU	*
			;Push RAM code onto the stack
			;18 0B FF 01 07	  MOVB  #$FF, FSTAT     ;clear CCIF
			;1F 01 07 80 FB	  BRCLR FSTAT, #CCIF, * ;wait until CCIF is set
			;06 xx xx      	  JMP     $xxxx
			MOVW	#NVM_EXEC_CMD_1, 2,-SP
			MOVW	#$FB06, 	 2,-SP
			MOVW	#$0708, 	 2,-SP
			MOVW	#$1F01, 	 2,-SP
			MOVW	#$0107, 	 2,-SP
			MOVW	#$0BFF, 	 2,-SP
			MOVB	#$18, 		 1,-SP
			;Invoke command
			SEI
			JMP	0,SP
NVM_EXEC_CMD_1		CLI
			;Done
			SSTACK_PREPULL	15
			LEAS	-13,SP
			RTS
	
;#ECC double fault
NVM_ISR_ECCERR		EQU	*
			RESET_FATAL	NVM_STR_ECCERR	
	
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

NVM_STR_ECCERR		FCS	"ECC error"

NVM_TABS_END		EQU	*	
NVM_TABS_END_LIN	EQU	@	
#endif	

