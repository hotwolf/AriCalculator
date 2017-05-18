#ifndef	NVM_COMPILED
#define	NVM_COMPILED
;###############################################################################
;# S12CBase - NVM - NVM Driver (OpenBDC)                                       #
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
;#    October 27, 2015                                                         #
;#      - New user interface                                                   #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Prescaler value
;--------------- 
#ifndef NVM_FDIV_VAL
NVM_FDIV_VAL		EQU	(CLOCK_OSC_FREQ/175000)-1
#endif

;NVM pages
;--------- 
#ifndef NVM_FIRST_PAGE
NVM_FIRST_PAGE		EQU	($40-(MMAP_FLASH_SIZE/$4000))	;first NVM page
#endif
#ifndef NVM_LAST_PAGE
NVM_LAST_PAGE		EQU	$3D				;last NVM page
#endif
		
;Halt external communication while NVM is not accesible
;------------------------------------------------------
#ifnmac NVM_HALT_COM
#macro NVM_HALT_COM, 0
			SCI_HALT_COM 		;halt SCI communication (SSTACK: 2 bytes)
#emac
#endif	
#ifnmac NVM_RESUME_COM
#macro NVM_RESUME_COM, 0
			SCI_RESUME_COM 		;resume SCI communication (SSTACK: 4)
#emac
#endif	

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Program/erase sizes
;-------------------- 
NVM_PHRASE_SIZE		EQU	2 	;bytes
NVM_SECTOR_SIZE		EQU	1024	;bytes

;Validation byte (must be !=$FF on a valid page)
;-----------------------------------------------
NVM_VAL_BYTE		EQU	$BFFF 		;address of the validation byte
NVM_VAL_PHRASE		EQU	$BFFE		;phrase containing the validation byte

;Valid page window
;-----------------
NVM_PAGE_WIN_START	EQU	$8000		;address of the validation byte
NVM_PAGE_WIN_END	EQU	$BFFE		;phrase containing the validation byte

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
;---------------      
#macro	NVM_INIT, 0
			;Initialize NVM wrapper 
			MOVB	#NVM_FDIV_VAL, FCLKDIV	;set clock divider
			;Select valid ppage 
			NVM_SET_PPAGE 			;find last PPAGE
#emac	

;#User interface
;---------------      
;#Erase NVM data
; args:   none
; result: C-flag: set if successful
; SSTACK: 30 bytes
;         All registers are preserved
#macro	NVM_ERASE, 0
			SSTACK_JOBSR	NVM_ERASE, 30
#emac	

;#Copy data to NVM
; args:   X: source address in RAM
;	  Y: destination address in page window
;	  D: number of bytes to copy
; result: C-flag: set if successful
; SSTACK: 8 bytes
;         All registers are preserved
#macro	 NVM_PROGRAM, 0
			SSTACK_JOBSR	NVM_PROGRAM, 8
#emac	

;#Memory map operations
;----------------------      
;#Check if last PPAGE is selected
; args:   1:     branch if no more pages are available
;         PPAGE: current page
; result: none
; SSTACK: none
;         All registers are preserved
#macro	 NVM_CHECK_LAST_PPAGE, 1
			BRSET	PPAGE, $3D, \1 ;last PPAGE already reached
#emac
	
;#Switch to next PPAGE
; args:   PPAGE: current page
; result: PPAGE: next page
; SSTACK: none
;         All registers are preserved
#macro	 NVM_NEXT_PPAGE, 0
INC_PPAGE		INC	PPAGE
#emac
	
;#Set PPAGE to the most recent page
; args:   none
; result: PPAGE: most recent page
; SSTACK: none
;         All registers are preserved
#macro	 NVM_SET_PPAGE, 0
			MOVB	NVM_FIRST_PAGE, PPAGE 		;set first PPAGE
CHECK_PAGE		BRSET	NVM_VAL_BYTE, #$FF, DONE	;done
			NVM_CHECK_LAST_PPAGE	DONE		;done
			NVM_NEXT_PPAGE				;switch to next page
			JOB	CHECK_PAGE			;loop
DONE			EQU	*
#emac	

;#NVM opperations
;----------------      
;#Check for page protection 
; args:   1:      branch address if PPAGE is set to protected page
;	  PPAGE:  current page
; result: none
; SSTACK: none
;         All registers are preserved
#macro	NVM_CHECK_PAGE_PROT, 1
			BRSET	PPAGE, #$3E, \1			;page 3E
#emac

;#Check if a phrase is within the page window
; args:   1:     X or Y (pointing to the beginning of the phrase)
;	  2: 	 branch address if phrase is not erased
; result: none
; SSTACK: none
;         X and Y registers are preserved
#macro	NVM_CHECK_PHRASE_RANGE, 2
			CP\1	#NVM_PAGE_WIN_START 		;check upper boundary
			BLO	\2				;range exceeded
			CP\1	#NVM_PAGE_WIN_END 		;check lower boundary
			BHI	\2				;range exceeded
#emac

;#Check if a phrase is aligned
; args:   1:     X or Y (pointing to the beginning of the phrase)
;	  2: 	 branch address if phrase is not aligned
; result: none
; SSTACK: none
;         X and Y registers are preserved
#macro	NVM_CHECK_PHRASE_ALIGNED, 2
			TFR	\1, A
			BITA	#(NVM_PHRASE_SIZE-1)
			BNE	\2
#emac

;#Check if a phrase is erased
; args:   1:     X or Y (pointing to the beginning of the phrase)
;	  2: 	 branch address if phrase is not erased
;	  PPAGE: current page
; result: none
; SSTACK: none
;         X and Y registers are preserved
#macro	NVM_CHECK_PHRASE_ERASED, 2
			LDD	0,\1
			IBNE	D, \2
#emac

;#Program a 4-byte phrase
; args:   X:     target pointer (phrase aligned)
;	  Y:     source pointer 
;	  PPAGE: current page
; result: X:     target pointer incremented by 8
;	  Y:     source pointer incremented by 8
;	  C-flag: set if successful
; SSTACK: 24 bytes
;         D is preserved
#macro	NVM_PROGRAM_PHRASE, 0
			SSTACK_JOBSR	NVM_PROGRAM_PHRASE, 24
#emac

;#Execute NVM command from RAM
; args:   none
; result: none
; SSTACK: 15 bytes
;         X, Y, and D are preserved
#macro	NVM_EXEC_CMD, 0
			SSTACK_JOBSR	NVM_EXEC_CMD, 15
#emac

;#Erase page
; args:   PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 19 bytes
;         X, Y, and D are preserved
#macro	NVM_ERASE_PAGE, 0
			SSTACK_JOBSR	NVM_ERASE_PAGE, 19
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
	
;#User interface
;---------------      
;#Erase NVM data
; args:   none
; result: C-flag: set if successful
; SSTACK: 30 bytes
;         All registers are preserved
NVM_ERASE		EQU	*
			;Save registers
			PSHX 					;save X
			PSHY 					;save Y
			;Halt any external communication
			NVM_HALT_COM
			;Check if any empty pages are left 
			NVM_CHECK_LAST_PPAGE NVM_ERASE_4	;erase all pages
			;Invalidate current page 
			LDX	#NVM_VAL_PHRASE 		;target pointer
			LDY	#NVM_VAL_PHRASE_PATTERN		;source pointer
			NVM_PROGRAM_PHRASE 			;( SSTACK: 24 bytes)
			BCC	NVM_ERASE_6			;failure	
			NVM_NEXT_PPAGE				;select next PPAGE
			;Success 
NVM_ERASE_1		NVM_RESUME_COM	  			;resume communication
			SSTACK_PREPULL	6 			;check stack
			SEC					;flag success
NVM_ERASE_2		PULY					;restore Y
			PULX					;restore X
			RTS
			;Select 1st PPAGE 
NVM_ERASE_3		MOVB	NVM_FIRST_PAGE, PPAGE 		;set first PPAGE
			JOB	NVM_ERASE_1			;success	
			;Erase all NVM pages 
NVM_ERASE_4		MOVB	NVM_FIRST_PAGE, PPAGE 		;start with first PPAGE
NVM_ERASE_5		NVM_ERASE_PAGE				;(SSTACK: 19 bytes)
			BCC            NVM_ERASE_6		;failure
			NVM_CHECK_LAST_PPAGE NVM_ERASE_3	;select 1st PPAGE
			NVM_NEXT_PPAGE 				;select next PPAGE
			JOB	NVM_ERASE_5			;erase next pages
			;Failure 
NVM_ERASE_6		NVM_RESUME_COM				;resume communication
			SSTACK_PREPULL	6 			;check stack
			CLC					;flag failure
			JOB	NVM_ERASE_2			;done	

;#Copy data to NVM
; args:   X: destination address in page window (phrase aligned)
;	  Y: source address in RAM
;	  D: number of bytes to copy (multiple of phrase size)
; result: C-flag: set if successful
; SSTACK: 8 bytes
;         All registers are preserved
NVM_PROGRAM		EQU	*
			;Save registers (dst addr in X, src addr in Y, byte count in D)
			PSHX 					;save X
			PSHY 					;save Y
			PSHD 					;save D
			;Halt any external communication (dst addr in X, src addr in Y, byte count in D)
			NVM_HALT_COM
			;Program phrases (dst addr in X, src addr in Y, byte count in D)
			LSRD					;byte count/8 -> phrase count 
			LSRD					;
			LSRD					;
NVM_PROGRAM_1		NVM_PROGRAM_PHRASE			;program phrase
			BCC	NVM_PROGRAM_3			;failure
			DBNE	D, NVM_PROGRAM_1		;program next phrase
			;Success 
			NVM_RESUME_COM	  			;resume communication
			SSTACK_PREPULL	6 			;check stack
			SEC					;flag success
NVM_PROGRAM_2		PULD					;restore D
			PULY					;restore Y
			PULX					;restore X
			RTS
			;Failure 
NVM_PROGRAM_3		NVM_RESUME_COM				;resume communication
			SSTACK_PREPULL	8 			;check stack
			CLC					;flag failure
			JOB	NVM_PROGRAM_2			;done	
	
;#NVM opperations
;----------------      
;#Program a 2-byte phrase
; args:   X:      target pointer (phrase aligned)
;	  Y:      source pointer 
;	  PPAGE:  current page
; result: X:      target pointer incremented by 2
;	  Y:      source pointer incremented by 2
;	  C-flag: set if successful
; SSTACK: 24 bytes
;         All registers are preserved
NVM_PROGRAM_PHRASE	EQU	*
			;Perform safety checks (target address in X, source address in Y)
			NVM_CHECK_PAGE_PROT	    NVM_PROGRAM_PHRASE_1
			NVM_CHECK_PHRASE_RANGE   X, NVM_PROGRAM_PHRASE_1
			NVM_CHECK_PHRASE_ALIGNED X, NVM_PROGRAM_PHRASE_1
			NVM_CHECK_PHRASE_ERASED  X, NVM_PROGRAM_PHRASE_1
			;Execute command (target address in X, source address in Y)
			LDAA	#$20 				;program P-flash
			NVM_EXEC_CMD				;execute command (SSTACK: 22 bytes)
			;Check result (new target address in X, new source address in Y)
			BRCLR	FSTAT, #(ACCERR|PVIOL), NVM_PROGRAM_PHRASE_2 ;success
			;Failure (new target address in X, new source address in Y)
			SSTACK_PREPULL	2 			;check stack
NVM_PROGRAM_PHRASE_1	CLC
			RTS
			;Failure (new target address in X, new source address in Y)
NVM_PROGRAM_PHRASE_2	SSTACK_PREPULL	2 			;check stack
			CLC
			RTS

;#Execute NVM command from RAM
; args:	  A:      command
;	  X:      target pointer
;	  Y:      source pointer 
; result: X:      target pointer incremented by 2
;	  Y:      source pointer incremented by 2
; SSTACK: 22 bytes
;         D is preserved
NVM_EXEC_CMD		EQU	*
			;Push RAM code onto the stack
			;18 02 71 31    MOVW   2,Y+, 2,X+      ;write data to flsh space
			;7A 01 06       STAA   FCMD            ;set command
			;18 0B FF 01 05 MOVB   #$FF, FSTAT     ;clear cbeif and ccif
			;1F 01 05 40 FB BRCLR  FSTAT, #CCIF, * ;wait until CCIF is set
			;06 xx xx       JMP    $xxxx
			MOVW	#NVM_EXEC_CMD_1, 2,-SP
			MOVW	#$FB06, 	 2,-SP
			MOVW	#$0540, 	 2,-SP
			MOVW	#$1F01, 	 2,-SP
			MOVW	#$0105, 	 2,-SP
			MOVW	#$0BFF, 	 2,-SP
			MOVW	#$0618, 	 2,-SP
			MOVW	#$7A01, 	 2,-SP
			MOVW	#$7131, 	 2,-SP
			MOVW	#$1802, 	 2,-SP
			;Invoke command 
			SEI
			JMP	0,SP
NVM_EXEC_CMD_1		CLI	
			;Done
			SSTACK_PREPULL	22
			LEAS	-20,SP
	RTS
	
;#Erase page
; args:   PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 30 bytes
;         X, Y, and D are preserved
NVM_ERASE_PAGE		EQU	*
			;Save registers (paged address in X, data pointer in Y)
			PSHX 					;save X
			PSHY 					;save Y
			PSHD 					;save D
			;Perform safety checks
			NVM_CHECK_PAGE_PROT	    NVM_ERASE_PAGE_2
			;Erase all 16 sdectors sector 
			LDX	#NVM_PAGE_WIN_START		
NVM_ERASE_PAGE_1	LDAA	#$40 				;sector erase
			LDY	#FCLKDIV			;any data
			NVM_EXEC_CMD				;execute command (SSTACK: 22 bytes)
			;Check result (incremented target address in X)
			BRCLR	FSTAT, #(ACCERR|PVIOL), NVM_ERASE_PAGE_4 ;success			
			;Failure
NVM_ERASE_PAGE_2	SSTACK_PREPULL	8 			;check stack
			CLC					;flag failure
NVM_ERASE_PAGE_3	PULD					;restore D
			PULY					;restore Y
			PULX					;restore X
			RTS			
			;Switch to next sector (incremented target address in X)
			LEAX	(NVM_SECTOR_SIZE-NVM_PHRASE_SIZE),X ;switch to next sector 
			CPX	#$C000
			BLO	NVM_ERASE_PAGE_1
			;Success
NVM_ERASE_PAGE_4	SSTACK_PREPULL	8 			;check stack
			SEC					;flag success
			JOB	NVM_ERASE_PAGE_3
	
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
	
NVM_VAL_PHRASE_PATTERN	DB	$FF, $00
	
NVM_TABS_END		EQU	*	
NVM_TABS_END_LIN	EQU	@	
#endif

