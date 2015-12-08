#ifndef	NUM_COMPILED
#define	NUM_COMPILED
;###############################################################################
;# S12CBase - NUM - Number printing routines                                   #
;###############################################################################
;#    Copyright 2010- Dirk Heisswolf                                           #
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
;#    NUM_REVERSE     - calculate a number of reverse digit order              #
;#    NUM_REVPRINT_NB - print a reverse number (non-blocking)                  #
;#    NUM_REVPRINT_BL - print a reverse number (blocking)                      #
;#                                                                             #
;#    Each of these functions has a coresponding macro definition              #
;###############################################################################
;# Required Modules:                                                           #
;#    STRING    - String printing routines                                     #
;#    SCI    - SCI driver                                                      #
;#    SSTACK - Subroutine Stack Handler                                        #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    Apr  4, 2010                                                             #
;#      - Initial release                                                      #
;#    November 21, 2012                                                        #
;#      - Total rewrite (now called NUM)                                       #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Maximum number conversion radix
;------------------------------- 
;Enable blocking subroutines
#ifndef	NUM_MAX_BASE_16
#ifndef	NUM_MAX_BASE_36
NUM_MAX_BASE_16		EQU	1 				;default is 16
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Valid number base
NUM_BASE_MIN		EQU	2				;binary
NUM_BASE_MAX		EQU	NUM_SYMTAB_END-NUM_SYMTAB	;max base value determined by symbol table
NUM_BASE_DEFAULT	EQU	10				;default base (decimal)
	
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

;#Negate double word
; args:   Y:X: signed double value
; result: Y:X: negated double value
; SSTACK: 0 bytes
;         D is preserved
#macro	NUM_NEGATE, 0
			EXG	Y, D 						;Y <-> D
			COMA							;invert D (upper word)
			COMB							;
			EXG	X, D 						;X <-> D	
			COMA							;invert D (lower word)
			COMB							;
			ADDD	#1   						;increment D (lower word)
			EXG	X, D 						;X <-> D	
			ADCB	#0 						;propagate carry (upper word)
			ADCA	#0   						;
			EXG	Y, D 						;Y <-> D
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
			SSTACK_JOBSR	NUM_REVERSE, 18
#emac

;#Clean-up stack space for reverse unsigned double word
; args:   SP+0: MSB   
;         SP+1:  |    
;         SP+2:  |reverse  
;         SP+3:  |number  
;         SP+4:  |    
;         SP+5: LSB   
; result: none
; SSTACK: 0 bytes  (+6 arg bytes)
;         X, Y and D are preserved
#macro	NUM_CLEAN_REVERSE, 0
			SSTACK_PREPULL	6
			LEAS	6,SP
#emac

;#Print a reverse number digit - non-blocking
; args:   B:    base (2<=base<=16)
;         SP+0: MSB   
;         SP+1:  |    
;         SP+2:  |reverse  
;         SP+3:  |number  
;         SP+4:  |    
;         SP+5: LSB   
; result: SP+0: MSB   
;         SP+1:  |remaining    
;         SP+2:  | digits of
;         SP+3:  |reverse 
;         SP+4:  |number      
;         SP+5: LSB   
;         C-flag: set if successful
; SSTACK: 8 bytes (+6 arg bytes) 
;         X, Y and D are preserved 
#macro	NUM_REVPRINT_NB, 0
			SSTACK_JOBSR	NUM_REVPRINT_NB, 8
#emac
	
;#Print a reverse number digit - blocking
; args:   B:    base (2<=base<=16)
;         SP+0: MSB   
;         SP+1:  |    
;         SP+2:  |reverse  
;         SP+3:  |number  
;         SP+4:  |    
;         SP+5: LSB   
; result: SP+0: MSB   
;         SP+1:  |remaining    
;         SP+2:  | digits of
;         SP+3:  |reverse 
;         SP+4:  |number      
;         SP+5: LSB   
;         C-flag: set if successful
; SSTACK: 8 bytes  (+6 arg bytes)
;         X, Y and D are preserved 
#macro	NUM_REVPRINT_BL, 0
			NUM_CALL_BL	NUM_REVPRINT_NB, 8
#emac

;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function (min. 4)
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
;#macro	NUM_MAKE_BL, 2
;			;Call non-blocking subroutine as if it was blocking
;			NUM_CALL_BL	\1, \2
;			;Done
;			SSTACK_PREPULL	2
;			RTS
;#emac

;#Run a non-blocking subroutine as if it was blocking	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function (min. 4)
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved 
#macro	NUM_CALL_BL, 2
LOOP			;Wait until TX buffer accepts new data
			SCI_TX_READY_BL
			;Call non-blocking function
			SSTACK_JOBSR	\1, \2
			BCC	LOOP 		;function unsuccessful
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
			MOVW	0,SP, 6,-SP 		;move return address to SP+10
			STD	6,SP			;initialize reverse number
			MOVW	#$0000, 4,SP    	;reverse number = base
			MOVW	#$0000, 2,SP		
			PSHX				;store X at SP+8
			PSHY				;store Y at SP+6			
			PSHD				;store count:base at SP+4
			PSHX				;store double value at SP+0
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
			LDD	NUM_REVERSE_FLW,SP
			BNE	<NUM_REVERSE_3 		;reverse value incomplete
			LDD	NUM_REVERSE_FHW,SP
			BEQ	<NUM_REVERSE_4		;reverse value has been generated

			;Multiply RLW by base
NUM_REVERSE_3		LDY	NUM_REVERSE_RLW,SP
			CLRA
			LDAB	NUM_REVERSE_BASE,SP
			EMUL				;Y * D => Y:D
			STD	NUM_REVERSE_RLW,SP
			
			;Multiply RMW by base (carry-over in Y)
			LDD	NUM_REVERSE_RMW,SP
			EXG	D, Y
			STD	NUM_REVERSE_RMW,SP
			CLRA
			LDAB	NUM_REVERSE_BASE,SP
			EMUL				;Y * D => Y:D
			ADDD	NUM_REVERSE_RMW,SP
			STD	NUM_REVERSE_RMW,SP
			TFR	Y, D
 			ADCB	#$00	
			ADCA	#$00
 			
			;Multiply RHW by base (carry-over in D)
			LDY	NUM_REVERSE_RHW,SP
			STD	NUM_REVERSE_RHW,SP
			CLRA
			LDAB	NUM_REVERSE_BASE,SP
			EMUL				;Y * D => Y:D
			ADDD	NUM_REVERSE_RHW,SP
			STD	NUM_REVERSE_RHW,SP

			;Start new iteration
			JOB	NUM_REVERSE_1

			;Clean up
NUM_REVERSE_4		SSTACK_PREPULL	18
			LEAS	4,SP 			;release temporary space for forward number
			PULD				;
			PULY
			PULX
			;Done
			RTS

;#Print a reserse number digit - non-blocking
; args:   B:    base (2<=base<=16)
;         SP+0: MSB   
;         SP+1:  |    
;         SP+2:  |reverse  
;         SP+3:  |number  
;         SP+4:  |    
;         SP+5: LSB   
; result: SP+0: MSB   
;         SP+1:  |remaining    
;         SP+2:  | digits of
;         SP+3:  |reverse 
;         SP+4:  |number      
;         SP+5: LSB   
;         C-flag: set if successful
; SSTACK: 8 bytes  (+6 arg bytes)
;         X, Y and D are preserved 
NUM_REVPRINT_NB		EQU	*
	
;Stack layout:
NUM_REVPRINT_NB_COUNT	EQU	$00 ;SP+ 0: A
NUM_REVPRINT_NB_BASE	EQU	$01 ;SP+ 1: base -> B
NUM_REVPRINT_NB_Y	EQU	$02 ;SP+ 2: +Y           
				    ;SP+ 3: +
NUM_REVPRINT_NB_X	EQU	$04 ;SP+ 4: +X
				    ;SP+ 5: +
NUM_REVPRINT_NB_RTN	EQU	$06 ;SP+ 6: +return address
				    ;SP+ 7: +
NUM_REVPRINT_NB_RHW	EQU	$08 ;SP+ 8: MSB   
				    ;SP+ 9:  |copy    
NUM_REVPRINT_NB_RMW     EQU	$0A ;SP+10:  |of
				    ;SP+11:  |reverse
NUM_REVPRINT_NB_RLW	EQU	$0C ;SP+12:  |number   
				    ;SP+13: LSB

			;Setup stack (base in B)
			PSHX					;store X at SP+8
			PSHY					;store Y at SP+6			
			PSHD					;store count:base at SP+4

			;Check if TX queue is full already (base in B)
NUM_REVPRINT_NB_1	SCI_TX_READY_NB
			BCC	>NUM_REVPRINT_NB_4 	;TX queue is full

			;Divide RHW by base
			LDY	NUM_REVPRINT_NB_RHW,SP	;RHW => Y
			BEQ	NUM_REVPRINT_NB_2		;skip division step
			TFR	Y, X
			CLRA				;base => D
			LDAB	NUM_REVPRINT_NB_BASE,SP
			EXG	X, D
			IDIV				;D / X => X,  D % X => D 
			STX	NUM_REVPRINT_NB_RHW,SP	;result => RHW

			;Divide RMW by base (prev remainder in D)
			TFR	D, Y			;remainder => Y
NUM_REVPRINT_NB_2	CLRA				;base => D
			LDAB	NUM_REVPRINT_NB_BASE,SP
			LDX	NUM_REVPRINT_NB_RMW,SP	;RMW => Y
			EXG	D, X
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			STY	NUM_REVPRINT_NB_RMW,SP	;result => RMW

			;Divide RLW by base (prev remainder in D, base in X)
			TFR	D, Y 			;remainder => Y
			LDD	NUM_REVPRINT_NB_RLW,SP 	;RLW => D
			EDIV				;Y:D / X => Y,  Y:D % X => D 
			STY	NUM_REVPRINT_NB_RLW,SP	;result => RLW

			;Print remainder (prev, remainder in D, RLW in Y)
			LdX	#NUM_SYMTAB
			LDAB	B,X
			JOBSR	SCI_TX_NB		;print character (SSTACK: 5 bytes)
			;BCC	>NUM_REVPRINT_NB_4	;TX unsuccessful -> has already been checked
			
			;Repeat until the reverse value is $1 (RLW in Y)
			DBNE	Y, NUM_REVPRINT_NB_1 	;RLW is not 1
			LDD	NUM_REVPRINT_NB_RMW,SP
			BNE	NUM_REVPRINT_NB_1 	;RMW is not 0
			LDD	NUM_REVPRINT_NB_RHW,SP
			BNE	NUM_REVPRINT_NB_1 	;RMW is not 0
	
			;Printing complete 
			SSTACK_PREPULL	14
			SEC
NUM_REVPRINT_NB_3	PULD
			PULY
			PULX
			;Done
			RTS

			;Printing incomplete 
NUM_REVPRINT_NB_4	SSTACK_PREPULL	14
			CLC
			JOB	NUM_REVPRINT_NB_3
	
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

NUM_SYMTAB		DB	"0"	; 0
			DB	"1"	; 1
			DB	"2"	; 2
			DB	"3"	; 3
			DB	"4"	; 4
			DB	"5"	; 5
			DB	"6"	; 6
			DB	"7"	; 7
			DB	"8"	; 8
			DB	"9"	; 9
			DB	"A"	;10
			DB	"B"	;11
			DB	"C"	;12
			DB	"D"	;13
			DB	"E"	;14
			DB	"F"	;15
#ifdef	NUM_MAX_BASE_32	
			DB	"G"	;16
			DB	"H"	;17
			DB	"I"	;18
			DB	"J"	;19
			DB	"K"	;20
			DB	"L"	;21
			DB	"M"	;22
			DB	"N"	;23
			DB	"O"	;24
			DB	"P"	;25
			DB	"Q"	;26
			DB	"R"	;27
			DB	"S"	;28
			DB	"T"	;29
			DB	"U"	;30
			DB	"V"	;31
			DB	"W"	;32
			DB	"X"	;33
			DB	"Y"	;34
			DB	"Z"	;35
#endif	
NUM_SYMTAB_END	DB	*
	
NUM_TABS_END		EQU	*
NUM_TABS_END_LIN	EQU	@
#endif
