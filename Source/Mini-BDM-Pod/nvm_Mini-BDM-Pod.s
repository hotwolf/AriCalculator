#ifndef	NVM_COMPILED
#define	NVM_COMPILED
;###############################################################################
;# S12CBase - NVM - NVM Driver (Mini-BDM_Pod)                                  #
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
NVM_FDIV_VAL		EQU	(CLOCK_BUS_FREQ/1000000)-1 ;FTMRG clock divider
#endif

;NVM pages
;--------- 
#ifndef NVM_FIRST_PAGE
NVM_FIRST_PAGE		EQU	($100-(MMAP_FLASH_SIZE/$4000))	;first NVM page
#endif
#ifndef NVM_LAST_PAGE
NVM_LAST_PAGE		EQU	$FE				;last NVM page
#endif
#ifndef NVM_PROT_FD_ON
#ifndef NVM_PROT_FD_OFF
NVM_PROT_FD_ON		EQU	1 				;protect page $F
#endif
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
NVM_PHRASE_SIZE		EQU	8 	;bytes
NVM_SECTOR_SIZE		EQU	1024	;bytes

;Validation byte (must be !=$FF on a valid page)
;-----------------------------------------------
NVM_VAL_BYTE		EQU	$BFFF 		;address of the validation byte
NVM_VAL_PHRASE		EQU	$BFF8		;phrase containing the validation byte

;Valid page window
;-----------------
NVM_PAGE_WIN_START	EQU	$8000		;address of the validation byte
NVM_PAGE_WIN_END	EQU	$BFF8		;phrase containing the validation byte

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
			MOVB	#DFDIE,FERCNFG		;detect ECC double faults
			;Select valid ppage 
			NVM_SET_PPAGE 			;find last PPAGE
#emac	

;#User interface
;---------------      
;#Erase NVM data
; args:   none
; result: C-flag: set if successful
; SSTACK: 27 bytes
;         All registers are preserved
#macro	NVM_ERASE, 0
			SSTACK_JOBSR	NVM_ERASE, 27
#emac	

;#Copy data to NVM
; args:   X: source address in RAM
;	  Y: destination address in page window
;	  D: number of bytes to copy
; result: C-flag: set if successful
; SSTACK: 29 bytes
;         All registers are preserved
#macro	 NVM_PROGRAM, 0
			SSTACK_JOBSR	NVM_PROGRAM, 29
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
			BRSET	PPAGE, $0E, \1 ;last PPAGE already reached
#emac
	
;#Switch to next PPAGE
; args:   PPAGE: current page
; result: PPAGE: next page
; SSTACK: none
;         All registers are preserved
#macro	 NVM_NEXT_PPAGE, 0
INC_PPAGE		INC	PPAGE
#ifdef NVM_PROT_FD_ON
			BRSET	PPAGE, $0D, INC_PPAGE
#endif	
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
#ifdef	NVM_PROT_FD_ON
			BRSET	PPAGE, #$FD, \1			;page FD or page FF
#else
			BRSET	PPAGE, #$FF, \1			;page FF
#endif
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
			LDD #(NVM_PHRASE_SIZE|$FF00)	
LOOP			ANDA	B,\1
			DBEQ	B, LOOP
			DBNE	B, \2
#emac

;#Program a 4-byte phrase
; args:   X:     target pointer (phrase aligned)
;	  Y:     source pointer 
;	  PPAGE: current page
; result: X:     target pointer incremented by 8
;	  Y:     source pointer incremented by 8
;	  C-flag: set if successful
; SSTACK: 21 bytes
;         D is preserved
#macro	NVM_PROGRAM_PHRASE, 0
			SSTACK_JOBSR	NVM_PROGRAM_PHRASE, 21
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
; SSTACK: 27 bytes
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
			NVM_PROGRAM_PHRASE 			;(SSTACK: 21 bytes)
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
; SSTACK: 29 bytes
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
NVM_PROGRAM_1		NVM_PROGRAM_PHRASE			;program phrase (SSTACK: 21 bytes)
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
;#Program a 4-byte phrase
; args:   X:      target pointer (phrase aligned)
;	  Y:      source pointer 
;	  PPAGE:  current page
; result: X:      target pointer incremented by 8
;	  Y:      source pointer incremented by 8
;	  C-flag: set if successful
; SSTACK: 21 bytes
;         D is preserved
NVM_PROGRAM_PHRASE	EQU	*
			;Save registers (target address in X, source address in Y)
			PSHX 					;save X
			PSHD 					;save D
			;Perform safety checks (target address in X, source address in Y)
			NVM_CHECK_PAGE_PROT	    NVM_PROGRAM_PHRASE_3
			NVM_CHECK_PHRASE_RANGE   X, NVM_PROGRAM_PHRASE_3
			NVM_CHECK_PHRASE_ALIGNED X, NVM_PROGRAM_PHRASE_3
			NVM_CHECK_PHRASE_ERASED  X, NVM_PROGRAM_PHRASE_3
			;Set CCOB  (target address in X, source address in Y)
			;1st CCOB word 
			CLR	FCCOBIX	    			;CCOBIX=$00	
			MOVW	#$06, FCCOBHI 			;program P-flash
			LDAA	PPAGE				;PPAGE    -> A
			CLRB					;PPAGE:00 -> D
			LSRD 					;align address
			LSRD 					;align address
			STAA	FCCOBLO				;store global address[17:16]
			;2nd CCOB word 
			INC	FCCOBIX	    			;CCOBIX=$001
			TBA					;B -> A
			CLRB					;store global address[15:16]
			EXG	D, X				;target addr -> D
			ANDA	#$3F				;clear bits 15 and 14
			LEAX	D,X				;assemble global address
			STX	FCCOBHI				;store global address[15:0]
			;3rd to 6th CCOB word 
			LDAA	#4				;copy 4 words
			INC	FCCOBIX	    			;CCOBIX=$002
NVM_PROGRAM_PHRASE_1	MOVW	2,Y+, FCCOBHI			;store data
			DBNE	A, NVM_PROGRAM_PHRASE_1		;more data to store
			;Execute command (incremented source address in Y)
			NVM_EXEC_CMD 				;(SSTACK: 15 bytes)
			;Check result (incremented source address in Y)
			BRCLR	FSTAT, #(ACCERR|FPVIOL|MGSTAT1|MGSTAT0), NVM_PROGRAM_PHRASE_4
			;Failure (incremented source address in Y)
NVM_PROGRAM_PHRASE_2	SSTACK_PREPULL	6 			;check stack
			CLC					;flag failure
			JOB	NVM_PROGRAM_PHRASE_5		;restore registers
			;Failure (source address in Y)
NVM_PROGRAM_PHRASE_3	LEAY	NVM_PHRASE_SIZE,Y		;increment Y by phrase size
			JOB	NVM_PROGRAM_PHRASE_2		;failure
			;Success (incremented source address in Y)
NVM_PROGRAM_PHRASE_4	SSTACK_PREPULL	6 			;check stack
			SEC					;flag success
NVM_PROGRAM_PHRASE_5	PULD					;restore D
			PULX					;restore X
			LEAX	NVM_PHRASE_SIZE,X		;increment X by phrase size
			RTS
	
;#Execute NVM command from RAM
; args:   none
; result: none
; SSTACK: 15 bytes
;         All registers are preserved
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

;#Erase page
; args:   PPAGE:  current page
; result: C-flag: set if successful
; SSTACK: 19 bytes
;         All registers are preserved
NVM_ERASE_PAGE		EQU	*
			;Save registers
			PSHD 					;save D
			;Perform safety checks
			NVM_CHECK_PAGE_PROT	    NVM_ERASE_PAGE_3
			;Set CCOB  (target address in X, source address in Y)
			;1st CCOB word 
			CLR	FCCOBIX	    			;CCOBIX=$00	
			MOVW	#$0A, FCCOBHI 			;erase P-flash sector
			LDAA	PPAGE				;PPAGE    -> A
			CLRB					;PPAGE:00 -> D
			LSRD 					;align address
			LSRD 					;align address
			STAA	FCCOBLO				;store global address[17:16]
			;2nd CCOB word 
			INC	FCCOBIX	    			;CCOBIX=$001
			STAB	FCCOBHI 			;store global address[15:16]
			CLR	FCCOBLO				;first sector
			;Execute command
NVM_ERASE_PAGE_2	NVM_EXEC_CMD 				;(SSTACK: 15 bytes)
			;Check result (incremented source address in Y)
			BRCLR	FSTAT, #(ACCERR|FPVIOL|MGSTAT1|MGSTAT0), NVM_ERASE_PAGE_5			
			;Failure
NVM_ERASE_PAGE_3	SSTACK_PREPULL	4 			;check stack
			CLC					;flag failure
NVM_ERASE_PAGE_4	PULD					;restore D
			RTS			
			;Switch to next sector
NVM_ERASE_PAGE_5	LDD	FCCOBHI
			ADDD	#NVM_SECTOR_SIZE
			STD	FCCOBHI
			CPD	#$C000
			BLO	NVM_ERASE_PAGE_2
			;Success
			SSTACK_PREPULL	4 			;check stack
			SEC					;flag success
			JOB	NVM_ERASE_PAGE_4
	
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

NVM_VAL_PHRASE_PATTERN	DB	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	
NVM_TABS_END		EQU	*	
NVM_TABS_END_LIN	EQU	@	
#endif

