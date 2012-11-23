;###############################################################################
;# S12CBase - NUM - Number printing routines                                   #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
;#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
;#    family.                                                                  #
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
;#    This module implements various print routines for the SCI driver:        #
;#    NUM_REVERSE    - calculate a number of reverse digit order               #
;#    NUM_RPRINT_NB  - print a reverse number (non-blocking)                   #
;#                                                                             #
;#    Each of these functions has a coresponding macro definition              #
;###############################################################################
;# Required Modules:                                                           #
;#    SCI    - SCI driver                                                      #
;#    SSTACK - Subroutine Stack Handler                                        #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    Apr  4, 2010                                                             #
;#      - Initial release                                                      #
;#    Apr 29, 2010                                                             #
;#      - Added macros "PRINT_UPPER_B" and "PRINT_LOWER_B"                     #
;#    Jul 29, 2010                                                             #
;#      - fixed PRINT_SINTCNT                                                  #
;#    July 2, 2012                                                             #
;#      - Added support for linear PC                                          #
;#      - Added non-blocking functions                                         #
;#    November 21, 2012                                                        #
;#      - Total rewrite (now called NUM)                                       #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Valid number base
NUM_BASE_MIN		EQU	2				;binary
NUM_BASE_MAX		EQU	NUM_SYMTAB_END-NUM_SYMTAB	;max base value determined by symbol table
NUM_BASE_DEF		EQU	10				;default base (decimal)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef NUM_VARS_START_LIN
			ORG 	NUM_VARS_START, NUM_VARS_START_LIN
#else
			ORG 	NUM_VARS_START
#endif	

NUM_VARS_END		EQU	*
NUM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	NUM_INIT, 0
#emac	

;#Reverse unsigned double word
; args:   Y:X: unsigned double value
; 	  B:   base   (2<=base<=16)
; result: A:   number of digits
;         SP+0: MSB   
;         SP+1:  |    
;         SP+2:  |reverse  
;         SP+3:  |number  
;         SP+4:  |    
;         SP+5: LSB   
; SSTACK: 18 bytes
;         X, Y and B are preserved
#macro	NUM_REVERSE, 0
			SSTACK_PREPUSH	18
			JOBSR	NUM_REVERSE
#emac

;#Print a reserse number digit - non-blocking
; args:   Y:      pointer to reverse number
; 	  B:      base   (2<=base<=16)
; result: Y:      pointer to the updated reverse number
;         C-flag: set if successful
; SSTACK: 19 bytes
;         X, Y and D are preserved 
#macro	NUM_RPRINT_NB, 0
			SSTACK_PREPUSH	19
			JOBSR	NUM_RPRINT_NB
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef NUM_CODE_START_LIN
			ORG 	NUM_CODE_START, NUM_CODE_START_LIN
#else
			ORG 	NUM_CODE_START
#endif

;#Reverse unsigned double word
; args:   Y:X: unsigned double value
; 	  B:   base   (2<=base<=16)
; result: A:   number of digits
;         SP+0: MSB   
;         SP+1:  |    
;         SP+2:  |reverse  
;         SP+3:  |number  
;         SP+4:  |    
;         SP+5: LSB   
; SSTACK: 18 bytes
;         X, Y and B are preserved
NUM_REVERSE		EQU	*
;Stack layout:
NUM_REVERSE_FHW		EQU	$00 ;SP+ 0: MSB          
				    ;SP+ 1:  |forward
NUM_REVERSE_FLW		EQU	$02 ;SP+ 2:  |number
				    ;SP+ 3: LSB
NUM_REVERSE_COUNT	EQU	$04 ;SP+ 4: count -> A
NUM_REVERSE_BASE	EQU	$05 ;SP+ 5: base  -> B
NUM_REVERSE_Y		EQU	$06 ;SP+ 6: +Y             
				    ;SP+ 7: +
NUM_REVERSE_X		EQU	$08 ;SP+ 8: +X
				    ;SP+ 9: +
NUM_REVERSE_RTN		EQU	$0A ;SP+10: +return address
				    ;SP+11: +
NUM_REVERSE_RHW		EQU	$0C ;SP+12: MSB   
				    ;SP+13:  |    
NUM_REVERSE_RMW         EQU	$0E ;SP+14:  |reverse
				    ;SP+15:  |number
NUM_REVERSE_RLW		EQU	$10 ;SP+16:  |      +return address at  
				    ;SP+17: LSB     +subroutine entry

			;Setup stack (double value in Y:X, base in B)
			CLRA
			MOVW	0,SP, 6,SP 	;move return address to SP+10
			LDD	2,SP-		;initialize reverse number
			MOVW	#$0000, 2,SP-   ;  reverse number = base
			MOVW	#$0000, 2,SP-
			PSHX			;store X at SP+8
			PSHY			;store Y at SP+6			
			PSHD			;store count:base at SP+4
			PSHX			;store double value at SP+0
			PSHY

			;Divide FHW by base
NUM_REVERSE_1		LDX	NUM_REVERSE_FHW,SP	;FHW => X
			BEQ	NUM_REVERSE_2		;skip division step
			CLRA				;base => D
			LDAB	NUM_REVERSE_BASE,SP
			EXG	X, D
			IDIV				;D / X => X,  D % X => D 
			STX	NUM_REVERSE_FHW,SP	;result => FHW

			;Divide FLW by base (prev. remainder in D)
			TFR	D, X			;remainder => X
NUM_REVERSE_2		CLRA				;base => D
			LDAB	NUM_REVERSE_BASE,SP
			LDY	NUM_REVERSE_FLW,SP	;FLW => Y
			EXG	X, Y
			EXG	X, D
			EDIV				;Y:D / X => Y,  Y:D % X => D
			STY	NUM_REVERSE_FLW,SP	;result => FLW
	
			;Add remainder to the reverse value (prev. remainder in D)
			ADDD	NUM_REVERSE_RLW,SP 	;RLW
			STD	NUM_REVERSE_RLW,SP
			LDD	NUM_REVERSE_RMW,SP 	;RMW
			ADCB	#$00	
			ADCA	#$00
			STD	NUM_REVERSE_RMW,SP
			LDD	NUM_REVERSE_RHW,SP 	;RHW
			ADCB	#$00	
			ADCA	#$00
			STD	NUM_REVERSE_RHW,SP

			;Increment digit count
			INC	NUM_REVERSE_COUNT,SP
	
			;Check if the calculation is finished
			LDD	NUM_REVERSE_LHW,SP
			BNE	<NUM_REVERSE_3 		;reverse value has been generated
			LDD	NUM_REVERSE_FHW,SP
			BEQ	<NUM_REVERSE_3		;reverse value has been generated

			;Multiply RLW by base
			LDY	NUM_REVERSE_RLW,SP
			CLRA
			LDAB	NUM_REVERSE_BASE,SP
			EMUL				;Y * D => Y:D
			STD	NUM_REVERSE_RTMP1,SP
			
			;Multiply RMW by base (carry-over in Y)
			LDD	NUM_REVERSE_RMW,SP
			EXG	D, Y
			STD	NUM_REVERSE_RMW,SP
			CLRA
			LDAB	NUM_REVERSE_BASE,SP
			EMUL				;Y * D => Y:D
			ADDD	NUM_REVERSE_RMW,SP
			STD	NUM_REVERSE_RMW,SP

			;Multiply RHW by base (carry-over in Y)
			LDD	NUM_REVERSE_RHW,SP
			EXG	D, Y
			STD	NUM_REVERSE_RHW,SP
			CLRA
			LDAB	NUM_REVERSE_BASE,SP
			EMUL				;Y * D => Y:D
			ADDD	NUM_REVERSE_RHW,SP
			STD	NUM_REVERSE_RHW,SP

			;Start new iteration
			JOB	NUM_REVERSE_1

			;Clean up
NUM_REVERSE_3		SSTACK_PREPULL	18
			LEAS	4,SP 			;release temporary space for forward number
			PULD				;
			PULY
			PULX
			;Done
			RTS
	
;#Print a reserse number digit - non-blocking
; args:   Y:      pointer to reverse number
; 	  B:      base   (2<=base<=16)
; result: Y:      pointer to the updated reverse number
;         C-flag: set if successful
; SSTACK: 19 bytes
;         X, Y and D are preserved 
NUM_RPRINT_NB	EQU	*
	
;Stack layout:
NUM_RPRINT_NB_RHW	EQU	$0C ;SP+ 0: MSB   
				    ;SP+ 1:  |copy    
NUM_RPRINT_NB_RMW       EQU	$0E ;SP+ 2:  |of
				    ;SP+ 3:  |reverse
NUM_RPRINT_NB_RLW	EQU	$10 ;SP+ 4:  |number   
				    ;SP+ 5: LSB
NUM_RPRINT_NB_COUNT	EQU	$04 ;SP+ 6: A
NUM_RPRINT_NB_BASE	EQU	$05 ;SP+ 7: base -> B
NUM_RPRINT_NB_Y		EQU	$06 ;SP+ 8: +pointer to            
				    ;SP+ 9: +reverse number -> Y  
NUM_RPRINT_NB_X		EQU	$08 ;SP+10: +X
				    ;SP+12: +
NUM_RPRINT_NB_RTN	EQU	$0A ;SP+13: +return address
				    ;SP+14: +

			;Setup stack (pointer in Y:X, base in B)
			PSHX					;store X at SP+8
			PSHY					;store Y at SP+6			
			PSHD					;store count:base at SP+4
			MOVW	NUM_RPRINT_NB_RLW,Y, 2,-SP 	;copy reverse number
			MOVW	NUM_RPRINT_NB_RMW,Y, 2,-SP
			MOVW	NUM_RPRINT_NB_RHW,Y, 2,-SP

			;Divide RHW by base
NUM_RPRINT_NB_1		LDY	NUM_RPRINT_NB_RHW,SP	;RHW => Y
			BEQ	NUM_RPRINT_NB_2		;skip division step
			TFR	Y, X
			CLRA				;base => D
			LDAB	NUM_RPRINT_NB_BASE,SP
			EXG	X, D
			IDIV				;D / X => X,  D % X => D 
			STX	NUM_RPRINT_NB_RHW,SP	;result => RHW

			;Divide RMW by base (prev remainder in D)
			TFR	D, Y			;remainder => Y
NUM_RPRINT_NB_2		CLRA				;base => D
			LDAB	NUM_RPRINT_NB_BASE,SP
			LDX	NUM_RPRINT_NB_RMW,SP	;RMW => Y
			EXG	D, X
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			STY	NUM_RPRINT_NB_RMW,SP	;result => RMW

			;Divide RLW by base (prev remainder in D, base in X)
			TFR	D, Y 			;remainder => Y
			LDD	NUM_RPRINT_NB_RLW,SP 	;RLW => D
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			STY	NUM_RPRINR_NB_RLW,SP	;result => RLW

			;Print remainder (prev, remainder in D)
			LDY	#NUM_SYMTAB
			LDAB	B,Y
			SCI_TX_NB			;print character (SSTACK: 5 bytes)
			BCC	>NUM_RPRINT_NB_	4	;TX unsuccessful

			;Copy updated reverse value
			LDY	NUM_RPRINT_NB_Y,SP
			MOVW	NUM_RPRINT_NB_RLW,SP, NUM_RPRINT_NB_RLW,Y
			MOVW	NUM_RPRINT_NB_RMW,SP, NUM_RPRINT_NB_RMW,Y
			MOVW	NUM_RPRINT_NB_RHW,SP, NUM_RPRINT_NB_RHW,Y
			
			;Repeat until the reverse value is $1
			LDD	NUM_RPRINT_NB_RLW,SP
			DBNE	D, NUM_RPRINT_NB_1 	;RLW is not 1
			LDD	NUM_RPRINT_NB_RMW,SP
			BNE	NUM_RPRINT_NB_1 	;RMW is not 0
			LDD	NUM_RPRINT_NB_RHW,SP
			BNE	NUM_RPRINT_NB_1 	;RMW is not 0
			
			;Printing complete 
			SSTACK_PREPULL	14
			SEC
NUM_RPRINT_NB_3		PULD				;
			PULY
			PULX
			;Done
			RTS

			;Printing incomplete 
NUM_RPRINT_NB_4		SSTACK_PREPULL	14
			CLC
			JOB	NUM_RPRINT_NB_3
		
NUM_CODE_END		EQU	*
NUM_CODE_END_LIN	EQU	@
			
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef NUM_TABS_START_LIN
			ORG 	NUM_TABS_START, NUM_TABS_START_LIN
#else
			ORG 	NUM_TABS_START
#endif	

NUM_SYMTAB		DB	"0"
			DB	"1"
			DB	"2"
			DB	"3"
			DB	"4"
			DB	"5"
			DB	"6"
			DB	"7"
			DB	"8"
			DB	"9"
			DB	"A"
			DB	"B"
			DB	"C"
			DB	"D"
			DB	"E"
			DB	"F"
NUM_SYMTAB_END	DB	*

NUM_TABS_END		EQU	*
NUM_TABS_END_LIN	EQU	@
