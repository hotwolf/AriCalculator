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
;#    Early versions of S12CBase framework used to have separate stacks        #
;#    interrupt handling and subroutine calls. These two stacks have noe been  #
;#    combined to one. However the API of the separate stacks has been kept:   #
;#    => The ISTACK module implements all functions required for interrupt     #
;#       handling.                                                             #
;#    => The SSTACK module implements all functions for subroutine calls and   #
;#       temporary RAM storage.                                                #
;#                                                                             #
;#    All of the stacking functions check the upper and lower boundaries of    #
;#    the stack. Fatel errors are thrown if the stacking space is exceeded.    #
;#                                                                             #
;#    The ISTACK module no longer implements an idle loop. Instead it offers   #
;#    the macro ISTACK_WAIT to build local idle loops for drivers which        #
;#    implement blocking I/O.                                                  #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    January 8, 2011                                                          #
;#      - Combined ISTACK and SSTACK                                           #
;###############################################################################
;# Required Modules:                                                           #
;#    ISTACK - Interrupt Stack Handler                                         #
;#    ERROR  - Error Handler                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;###############################################################################
;# Stack Layout                                                                #
;###############################################################################
; ISTACK_VARS_START,   +-------------------+
;        ISTACK_TOP -> |                   |
;                      | ISTACK_FRAME_SIZE |
;                      |                   |
;                      +-------------------+
;        SSTACK_TOP -> |                   |
;                      |                   |
;                      |                   |
;                      |                   |
;                      |    SSTACK_DEPTH   |
;                      |                   |
;                      |                   |
;                      |                   |
;     SSTACK_BOTTOM,   |                   |
;     ISTACK_BOTTOM,   +-------------------+
;   ISTACK_VARS_END ->

;###############################################################################
;# Constants                                                                   #
;###############################################################################
SSTACK_DEPTH		EQU	24
SSTACK_TOP		EQU	ISTACK_TOP+ISTACK_FRAME_SIZE
SSTACK_BOTTOM		EQU	ISTACK_BOTTOM
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	SSTACK_VARS_START
SSTACK_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	SSTACK_INIT, 0
#emac

;#Allocate local memory
#macro	SSTACK_ALLOC, 1
			LEAS	-\1,X
			SSTACK_POSTPUSH
#emac

;#Push accu A onto stack
#macro	SSTACK_PSHA, 0
			PSHA
			SSTACK_POSTPUSH
#emac

;#Push accu B onto stack
#macro	SSTACK_PSHB, 0
			PSHB
			SSTACK_POSTPUSH
#emac

;#Push accu D onto stack
#macro	SSTACK_PSHD, 0
			PSHD
			SSTACK_POSTPUSH
#emac

;#Push index X onto stack
#macro	SSTACK_PSHX, 0
			PSHX
			SSTACK_POSTPUSH
#emac

;#Push index X and accu B onto stack
#macro	SSTACK_PSHXB, 0
			PSHX
			PSHB
			SSTACK_POSTPUSH
#emac

;#Push index X and accu D onto stack
#macro	SSTACK_PSHXD, 0
			PSHX
			PSHD
			SSTACK_POSTPUSH
#emac

;#Push index Y onto stack
#macro	SSTACK_PSHY, 0
			PSHY
			SSTACK_POSTPUSH
#emac

;#Push index Y and accu A onto the stack
#macro	SSTACK_PSHYA, 0
			PSHY
			PSHA
			SSTACK_POSTPUSH
#emac

;#Push index Y and accu B onto the stack
#macro	SSTACK_PSHYB, 0
			PSHY
			PSHB
			SSTACK_POSTPUSH
#emac

;#Push index Y and accu D onto the stack
#macro	SSTACK_PSHYD, 0
			PSHY
			PSHD
			SSTACK_POSTPUSH
#emac

;#Push index X and Y onto the stack
#macro	SSTACK_PSHYX, 0
			PSHY
			PSHX
			SSTACK_POSTPUSH
#emac

;#Push index X, Y and accu A onto the stack
#macro	SSTACK_PSHYXA, 0
			PSHY
			PSHX
			PSHA
			SSTACK_POSTPUSH
#emac

;#Push index X, Y and accu B onto the stack
#macro	SSTACK_PSHYXB, 0
			PSHY
			PSHX
			PSHB
			SSTACK_POSTPUSH
#emac

;#Push index X, Y and accu D onto the stack
#macro	SSTACK_PSHYXD, 0
			PSHY
			PSHX
			PSHD
			SSTACK_POSTPUSH
#emac

;#Deallocate local memory
#macro	SSTACK_DEALLOC, 1
			LEAS	\1,X
			SSTACK_POSTPULL
#emac
	
;#Pull accu A from stack
#macro	SSTACK_PULA, 0
			PULA
			SSTACK_POSTPULL
#emac

;#Pull accu A, index X and Y from the stack
#macro	SSTACK_PULAXY, 0
			PULA
			PULX
			PULY
			SSTACK_POSTPULL
#emac

;#Pull accu A and index Y from the stack
#macro	SSTACK_PULAY, 0
			PULA
			PULY
			SSTACK_POSTPULL
#emac

;#Pull accu B from stack
#macro	SSTACK_PULB, 0
			PULB
			SSTACK_POSTPULL
#emac

;#Pull accu B and index X from stack
#macro	SSTACK_PULBX, 0
			PULB
			PULX
			SSTACK_POSTPULL
#emac

;#Pull accu B, index X and Y from the stack
#macro	SSTACK_PULBXY, 0
			PULB
			PULX
			PULY
			SSTACK_POSTPULL
#emac

;#Pull index Y and accu B from the stack
#macro	SSTACK_PULBY, 0
			PULB
			PULY
			SSTACK_POSTPULL
#emac

;#Pull accu D from stack
#macro	SSTACK_PULD, 0
			PULD
			SSTACK_POSTPULL
#emac

;#Pull accu D and index X from the stack
#macro	SSTACK_PULDX, 0
			PULD
			PULX
			SSTACK_POSTPULL
#emac

;#Pull accu D, index X and Y from the stack
#macro	SSTACK_PULDXY, 0
			PULD
			PULX
			PULY
			SSTACK_POSTPULL
#emac

;#Pull index Y and accu D from the stack
#macro	SSTACK_PULDY, 0
			PULD
			PULY
			SSTACK_POSTPULL
#emac

;#Pull index X from stack
#macro	SSTACK_PULX, 0
			PULX
			SSTACK_POSTPULL
#emac

;#Pull index X and Y from the stack
#macro	SSTACK_PULXY, 0
			PULX
			PULY
			SSTACK_POSTPULL
#emac

;#Pull index Y from stack
#macro	SSTACK_PULY, 0
			PULY
			SSTACK_POSTPULL
#emac

;#Call subroutine	
#macro	SSTACK_JOBSR, 1
			CPS	#SSTACK_TOP+2
			BLO	SSTACK_OF
			JOBSR	\1
#emac

;#Return from subroutine	
#macro	SSTACK_RTS, 0
			CPS	#SSTACK_BOTTOM-2
			BHI	SSTACK_UF
			RTS
#emac

;#Return from subroutine and flag no error (carry cleared)	
#macro	SSTACK_RTS_NOERR, 0
			CPS	#SSTACK_BOTTOM-2
			BHI	SSTACK_UF
			CLC
			RTS
#emac

;#Return from subroutine and flag an error (carry set)	
#macro	SSTACK_RTS_ERR, 0
			CPS	#SSTACK_BOTTOM-2
			BHI	SSTACK_UF
			SEC
			RTS
#emac

;#Conclude push operation	
#macro	SSTACK_POSTPUSH, 0
			CPS	#SSTACK_TOP
			BLO	SSTACK_OF
#emac

;#Conclude pull operation	
#macro	SSTACK_POSTPULL, 0
			CPS	#SSTACK_BOTTOM
			BHI	SSTACK_UF
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	SSTACK_CODE_START

;#Stack overflow detected	
SSTACK_OF		EQU	ISTACK_OF

;#Stack underflow detected	
SSTACK_UF		EQU	ISTACK_UF
	
SSTACK_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	SSTACK_TABS_START
;#Error Messages
SSTACK_MSG_OF		EQU	ISTACK_MSG_OF
SSTACK_MSG_UF		EQU	ISTACK_MSG_UF

SSTACK_TABS_END		EQU	*
