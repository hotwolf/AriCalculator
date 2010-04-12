;###############################################################################
;# S12CBase - SSTACK - Subroutine Stack Handler                                #
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
;#    The S12CBase framework uses two stacks in its assembly code:             #
;#      1. An interrupt stack, which is implemented in the ISTACK module       #
;#      2. An subroutine stack, which is implemented in this module            #
;#                                                                             #
;#   The subroutine stack is implemented in software. It provides assembler    #
;#   macros which are intended to be used as a replacement for the CPUs native #
;#   stacking instructions.                                                    #
;#                                                                             #
;#   Stack under- and overflows are checked with every stack operation. Upon   #
;#   detection, a fatal error will be triggered to the reset handler.          #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    ERROR - Error Handler                                                    #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;                       +--------------+--------------+  
;   SSTACK_VAR_START,-> |                             | 
;         SSTACK_TOP    |                             |
;                       |         Stack Space         |
;                       |                             | 
;                       |                             |
;                       |                             |
;      SSTACK_BOTTOM,   +--------------+--------------+
;          SSTACK_SP -> |       Stack Pointer         |
;                       +--------------+--------------+
;        SSTACK_TMPX -> |   Temporary Storage Space   |
;                       +--------------+--------------+
;      SSTACK_TMPRET -> |   Temporary Storage Space   |
;                       +--------------+--------------+
;     SSTACK_VAR_END ->                 

;###############################################################################
;# Constants                                                                   #
;###############################################################################
SSTACK_DEPTH		EQU	24
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	SSTACK_VARS_START
SSTACK_TOP		DS	2*SSTACK_DEPTH
SSTACK_BOTTOM
SSTACK_SP		DS	2
SSTACK_TMPX		DS	2 ;temporary storage forv index X
SSTACK_TMPRET		DS	2	
SSTACK_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SSTACK_INIT, 0
			MOVW	#SSTACK_BOTTOM, SSTACK_SP	;Set stack pointer
#emac

;#Load Stack Pointer
#macro	SSTACK_LDS, 1
			MOVW		#\1, SSTACK_SP
#emac

;#Allocate local memory
#macro	SSTACK_ALLOC, 1
			SSTACK_PREPARE
			LEAX	-\1,X
			SSTACK_POSTPUSH
#emac

;#Push accu A onto stack
#macro	SSTACK_PSHA, 0
			SSTACK_PREPARE
			STAA	1,-X
			SSTACK_POSTPUSH
#emac

;#Push accu B onto stack
#macro	SSTACK_PSHB, 0
			SSTACK_PREPARE
			STAB	1,-X
			SSTACK_POSTPUSH
#emac

;#Push accu D onto stack
#macro	SSTACK_PSHD, 0
			SSTACK_PREPARE
			STD	2,-X
			SSTACK_POSTPUSH
#emac

;#Push index X onto stack
#macro	SSTACK_PSHX, 0
			SSTACK_PREPARE
			MOVW	SSTACK_TMPX, 2,-X
			SSTACK_POSTPUSH
#emac

;#Push index X and accu B onto stack
#macro	SSTACK_PSHXB, 0
			SSTACK_PREPARE
			MOVW	SSTACK_TMPX, 2,-X
			STAB	1,-X
			SSTACK_POSTPUSH
#emac

;#Push index X and accu D onto stack
#macro	SSTACK_PSHXD, 0
			SSTACK_PREPARE
			MOVW	SSTACK_TMPX, 2,-X
			STD	2,-X
			SSTACK_POSTPUSH
#emac

;#Push index Y onto stack
#macro	SSTACK_PSHY, 0
			SSTACK_PREPARE
			STY	2,-X
			SSTACK_POSTPUSH
#emac

;#Push index Y and accu B onto the stack
#macro	SSTACK_PSHYB, 0
			SSTACK_PREPARE
			STY	2,-X
			STAB	1,-X
			SSTACK_POSTPUSH
#emac

;#Push index Y and accu D onto the stack
#macro	SSTACK_PSHYD, 0
			SSTACK_PREPARE
			STY	2,-X
			STD	2,-X
			SSTACK_POSTPUSH
#emac

;#Push index X and Y onto the stack
#macro	SSTACK_PSHYX, 0
			SSTACK_PREPARE
			STY	2,-X
			MOVW	SSTACK_TMPX, 2,-X
			SSTACK_POSTPUSH
#emac

;#Push index X, Y and accu A onto the stack
#macro	SSTACK_PSHYXA, 0
			SSTACK_PREPARE
			STY	2,-X
			MOVW	SSTACK_TMPX, 2,-X
			STAA	1,-X
			SSTACK_POSTPUSH
#emac

;#Push index X, Y and accu B onto the stack
#macro	SSTACK_PSHYXB, 0
			SSTACK_PREPARE
			STY	2,-X
			MOVW	SSTACK_TMPX, 2,-X
			STAB	1,-X
			SSTACK_POSTPUSH
#emac

;#Push index X, Y and accu D onto the stack
#macro	SSTACK_PSHYXD, 0
			SSTACK_PREPARE
			STY	2,-X
			MOVW	SSTACK_TMPX, 2,-X
			STD	2,-X
			SSTACK_POSTPUSH
#emac

;#Deallocate local memory
#macro	SSTACK_DEALLOC, 1
			SSTACK_PREPARE
			LEAX	\1,X
			SSTACK_POSTPULL
#emac
	
;#Pull accu A from stack
#macro	SSTACK_PULA, 0
			SSTACK_PREPARE
			LDAA	1,X+
			SSTACK_POSTPULL
#emac

;#Pull accu A, index X and Y from the stack
#macro	SSTACK_PULAXY, 0
			;SSTACK_PREPARE
			LDX	SSTACK_SP
			LDAA	1,X+
			MOVW	2,X+, SSTACK_TMPX
			LDY	2,X+
			SSTACK_POSTPULL
#emac

;#Pull accu B from stack
#macro	SSTACK_PULB, 0
			SSTACK_PREPARE
			LDAB	1,X+
			SSTACK_POSTPULL
#emac

;#Pull accu B and index X from stack
#macro	SSTACK_PULBX, 0
			;SSTACK_PREPARE
			LDX	SSTACK_SP
			LDAB	1,X+
			MOVW	2,X+, SSTACK_TMPX
			SSTACK_POSTPULL
#emac

;#Pull accu B, index X and Y from the stack
#macro	SSTACK_PULBXY, 0
			;SSTACK_PREPARE
			LDX	SSTACK_SP
			LDAB	1,X+
			MOVW	2,X+, SSTACK_TMPX
			LDY	2,X+
			SSTACK_POSTPULL
#emac

;#Pull index Y and accu B from the stack
#macro	SSTACK_PULBY, 0
			SSTACK_PREPARE
			LDAB	1,X+
			LDY	2,X+
			SSTACK_POSTPULL
#emac

;#Pull accu D from stack
#macro	SSTACK_PULD, 0
			SSTACK_PREPARE
			LDD	2,X+
			SSTACK_POSTPULL
#emac

;#Pull accu D and index X from the stack
#macro	SSTACK_PULDX, 0
			;SSTACK_PREPARE
			LDX	SSTACK_SP
			LDD	2,X+
			MOVW	2,X+, SSTACK_TMPX
			SSTACK_POSTPULL
#emac

;#Pull accu D, index X and Y from the stack
#macro	SSTACK_PULDXY, 0
			;SSTACK_PREPARE
			LDX	SSTACK_SP
			LDD	2,X+
			MOVW	2,X+, SSTACK_TMPX
			LDY	2,X+
			SSTACK_POSTPULL
#emac

;#Pull index Y and accu D from the stack
#macro	SSTACK_PULDY, 0
			SSTACK_PREPARE
			LDD	2,X+
			LDY	2,X+
			SSTACK_POSTPULL
#emac

;#Pull index X from stack
#macro	SSTACK_PULX, 0
			;SSTACK_PREPARE
			LDX	SSTACK_SP
			MOVW	2,X+, SSTACK_TMPX
			SSTACK_POSTPULL
#emac

;#Pull index X and Y from the stack
#macro	SSTACK_PULXY, 0
			;SSTACK_PREPARE
			LDX	SSTACK_SP
			MOVW	2,X+, SSTACK_TMPX
			LDY	2,X+
			SSTACK_POSTPULL
#emac

;#Pull index Y from stack
#macro	SSTACK_PULY, 0
			SSTACK_PREPARE
			LDY	2,X+
			SSTACK_POSTPULL
#emac

;#Call subroutine	
#macro	SSTACK_JOBSR, 1
			SSTACK_PREPARE
			MOVW	#RETURN_ADDR, 2,-X
			SSTACK_POSTPUSH
			JOB	\1
RETURN_ADDR		EQU	*
#emac

;#Return from subroutine	
#macro	SSTACK_RTS, 0
			SSTACK_PREPARE
			MOVW	2,X+, SSTACK_TMPRET
			SSTACK_POSTPULL
			JMP	[SSTACK_TMPRET]		
#emac

;#Return from subroutine and flag no error (carry cleared)	
#macro	SSTACK_RTS_NOERR, 0
			SSTACK_PREPARE
			MOVW	2,X+, SSTACK_TMPRET
			SSTACK_POSTPULL
			CLC
			JMP	[SSTACK_TMPRET]		
#emac

;#Return from subroutine and flag an error (carry set)	
#macro	SSTACK_RTS_ERR, 0
			SSTACK_PREPARE
			MOVW	2,X+, SSTACK_TMPRET
			SSTACK_POSTPULL
			SEC
			JMP	[SSTACK_TMPRET]		
#emac

;#Prepare stack operation	
#macro	SSTACK_PREPARE, 0
			STX	SSTACK_TMPX
			LDX	SSTACK_SP
#emac

;#Conclude push operation	
#macro	SSTACK_POSTPUSH, 0
			STX	SSTACK_SP
			CPX	#SSTACK_TOP
			BLO	SSTACK_OF
			LDX	SSTACK_TMPX			
#emac

;#Conclude pull operation	
#macro	SSTACK_POSTPULL, 0
			STX	SSTACK_SP
			CPX	#SSTACK_BOTTOM
			BHI	SSTACK_UF
			LDX	SSTACK_TMPX			
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	SSTACK_CODE_START

;#Stack overflow detected	
SSTACK_OF		EQU	*
			ERROR_RESTART	SSTACK_MSG_OF

;#Stack underflow detected	
SSTACK_UF		EQU	*
			ERROR_RESTART	SSTACK_MSG_UF
	
SSTACK_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	SSTACK_TABS_START
;#Error Messages
SSTACK_MSG_OF		ERROR_MSG	ERROR_LEVEL_FATAL, "Subroutine stack overflow"
SSTACK_MSG_UF		ERROR_MSG	ERROR_LEVEL_FATAL, "Subroutine stack underflow"

SSTACK_TABS_END		EQU	*
