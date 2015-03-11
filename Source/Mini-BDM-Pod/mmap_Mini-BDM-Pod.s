#ifndef	MMAP_COMPILED
#define	MMAP_COMPILED
;###############################################################################
;# S12CBase - MMAP - Memory Map (Mini-BDM-Pod)                                 #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#    This module performs all the necessary steps to initialize the device    #
;#    after each reset.                                                        #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    December 14, 2011                                                        #
;#      - Initial release                                                      #
;#    July 31, 2012                                                            #
;#      - Added support for linear PC                                          #
;#      - Updated memory mapping                                               #
;###############################################################################
;  Flash Memory Map:
;  -----------------  
;                     S12XE                
;        	 +-------------+ $0000
;  		 |  Registers  |
;   	  RAM->+ +-------------+ $0800
;  	       | |  Variables  |
;  	       | +-------------+
;              | |/////////////|	     
;  	Flash->+ +-------------+ $4000
;  	       | |    Code     |
;  	       | +-------------+ 
;  	       | |   Tables    |
;  	       | +-------------+
;              | |/////////////|	     
;  	       | +-------------+ $DF10
;  	       | |   Vectors   |
;  	       | +-------------+ $E000
;  	       | | BootLoader  |
;  	       + +-------------+ 
; 
;  RAM Memory Map:
;  ---------------  
;                     S12XE                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  	  RAM->+ +-------------+ $1000
;  	       | |  Variables  |
;  	       | +-------------+
;  	       | |    Code     |
;  	       | +-------------+
;  	       | |   Tables    |
;  	       | +-------------+
;              | |/////////////|	     
;  	       | +-------------+ $7F10
;  	       | |   Vectors   |
;  	       + +-------------+ $8000
;                |/////////////|	     
;  		 +-------------+ $E000
;  		 | BootLoader  |
;  		 +-------------+ 
; 
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;RAM or flash
#ifndef	MMAP_RAM
#ifndef	MMAP_FLASH
MMAP_FLASH		EQU	1 		;default is flash
#endif
#endif

;S12XEP100 or S12XEQ512
#ifndef	MMAP_S12XEP100
#ifndef	MMAP_S12XEQ512
MMAP_S12XEP100		EQU	1 		;default is S12XEP100
#endif
#endif
	
;###############################################################################
;# Security and Protection                                                     #
;###############################################################################
			;Set within bootloader code 
			;ORG	$FF0D	;unprotect
			;DB	$FF
			;ORG	$FF0F	;unsecure
			;DB	$FE

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;# Memory Locations
;Register space
MMAP_REG_GLOBAL_START	EQU	$00_0000
MMAP_REG_GLOBAL_END	EQU	$0_0800
MMAP_REG_START		EQU	$0000
MMAP_REG_START_LIN	EQU	MMAP_REG_GLOBAL_START
MMAP_REG_END		EQU	$0800
MMAP_REG_END_LIN	EQU	MMAP_REG_GLOBAL_START

;EEE RAM
MMAP_EERAM_GLOBAL_START	EQU	$13_F000
MMAP_EERAM_GLOBAL_END	EQU	$14_0000
MMAP_EERAM_START	EQU	$0800
MMAP_EERAM_START_LIN	EQU	$13_F800
MMAP_EERAM_WIN_START	EQU	$0C00
MMAP_EERAM_END		EQU	$1000
MMAP_EERAM_END_LIN	EQU	MMAP_EERAM_GLOBAL_END

;RAM
#ifdef	MMAP_S12XEQ512
MMAP_RAM_GLOBAL_START	EQU	$0F_C000 	;16K
#else
MMAP_RAM_GLOBAL_START	EQU	$0F_8000 	;32K
#endif
MMAP_RAM_GLOBAL_END	EQU	$10_0000
MMAP_RAM_START		EQU	$1000
#ifdef	MMAP_RAM
MMAP_RAM_START_LIN	EQU	$0F_9000
#else
MMAP_RAM_START_LIN	EQU	$0F_D000
#endif
MMAP_RAM_WIN_START	EQU	$2000
#ifdef	MMAP_RAM
MMAP_RAM_END		EQU	$8000
#else
MMAP_RAM_END		EQU	$4000
#endif
MMAP_RAM_END_LIN	EQU	MMAP_RAM_GLOBAL_END

;Flash
#ifdef	MMAP_S12XEQ512
MMAP_FLASH_GLOBAL_START	EQU	$70_0000 	;1024K
#else
MMAP_FLASH_GLOBAL_START	EQU	$78_8000 	;512K
#endif
MMAP_FLASH_GLOBAL_END	EQU	$80_0000
MMAP_FLASH_FD_START	EQU	$4000
MMAP_FLASH_FD_START_LIN	EQU	$7F_4000
MMAP_FLASH_WIN_START	EQU	$8000
MMAP_FLASH_FE_START	EQU	$C000
MMAP_FLASH_FE_START_LIN	EQU	$7F_C000
MMAP_FLASH_END		EQU	$10000
MMAP_FLASH_END_LIN	EQU	MMAP_FLASH_GLOBAL_END

;#Memory sizes
MMAP_REG_SIZE		EQU	MMAP_REG_END-MMAP_REG_START
MMAP_EERAM_SIZE		EQU	MMAP_EERAM_GLOBAL_END-MMAP_EERAM_GLOBAL_START	
MMAP_RAM_SIZE		EQU	MMAP_RAM_GLOBAL_END-MMAP_RAM_GLOBAL_START	
MMAP_FLASH_SIZE		EQU	MMAP_FLASH_GLOBAL_END-MMAP_FLASH_GLOBAL_START	

;#MPU desccriptors	
MMAP_D_REG_LOADDR	EQU	MMAP_REG_GLOBAL_START 	;register space
MMAP_D_REG_HIADDR	EQU	MMAP_REG_GLOBAL_END-1
MMAP_D_REG_PROTECT	EQU	NEX 			;read and write
MMAP_D_REG_BYTE0	EQU   	       (MSTR0|MSTR1|(MMAP_D_REG_LOADDR>>19))&$FF
MMAP_D_REG_BYTE1	EQU	                   ((MMAP_D_REG_LOADDR>>11))&$FF
MMAP_D_REG_BYTE2	EQU                   	   ((MMAP_D_REG_LOADDR>>03))&$FF
MMAP_D_REG_BYTE3	EQU	(MMAP_D_REG_PROTECT|(MMAP_D_REG_HIADDR>>19))&$FF
MMAP_D_REG_BYTE4	EQU	                   ((MMAP_D_REG_HIADDR>>11))&$FF
MMAP_D_REG_BYTE5	EQU 	                   ((MMAP_D_REG_HIADDR>>03))&$FF

MMAP_D_URAM_LOADDR	EQU	MMAP_REG_GLOBAL_END 	;unimplemented RAM space
MMAP_D_URAM_HIADDR	EQU	MMAP_RAM_GLOBAL_START-1
MMAP_D_URAM_PROTECT	EQU	WP|NEX 			;read omly
MMAP_D_URAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_URAM_LOADDR>>19))&$FF
MMAP_D_URAM_BYTE1	EQU	                    ((MMAP_D_URAM_LOADDR>>11))&$FF
MMAP_D_URAM_BYTE2	EQU	                    ((MMAP_D_URAM_LOADDR>>03))&$FF
MMAP_D_URAM_BYTE3	EQU     (MMAP_D_URAM_PROTECT|(MMAP_D_URAM_HIADDR>>19))&$FF
MMAP_D_URAM_BYTE4	EQU	                    ((MMAP_D_URAM_HIADDR>>11))&$FF
MMAP_D_URAM_BYTE5	EQU	                    ((MMAP_D_URAM_HIADDR>>03))&$FF

MMAP_D_RAM_LOADDR	EQU	MMAP_RAM_GLOBAL_START	;RAM
MMAP_D_RAM_HIADDR	EQU	MMAP_RAM_GLOBAL_END-1
MMAP_D_RAM_PROTECT	EQU	0 			;read, write, and execute
MMAP_D_RAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_RAM_LOADDR>>19))&$FF
MMAP_D_RAM_BYTE1	EQU	                    ((MMAP_D_RAM_LOADDR>>11))&$FF
MMAP_D_RAM_BYTE2	EQU	                    ((MMAP_D_RAM_LOADDR>>03))&$FF
MMAP_D_RAM_BYTE3	EQU      (MMAP_D_RAM_PROTECT|(MMAP_D_RAM_HIADDR>>19))&$FF
MMAP_D_RAM_BYTE4	EQU	                    ((MMAP_D_RAM_HIADDR>>11))&$FF
MMAP_D_RAM_BYTE5	EQU	                    ((MMAP_D_RAM_HIADDR>>03))&$FF

MMAP_D_UEERAM_LOADDR	EQU	MMAP_RAM_GLOBAL_END	;unimplemented EERAM space 
MMAP_D_UEERAM_HIADDR	EQU	MMAP_EERAM_GLOBAL_START-1
MMAP_D_UEERAM_PROTECT	EQU	WP|NEX 			;read only
MMAP_D_UEERAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_UEERAM_LOADDR>>19))&$FF
MMAP_D_UEERAM_BYTE1	EQU	                    ((MMAP_D_UEERAM_LOADDR>>11))&$FF
MMAP_D_UEERAM_BYTE2	EQU	                    ((MMAP_D_UEERAM_LOADDR>>03))&$FF
MMAP_D_UEERAM_BYTE3	EQU   (MMAP_D_UEERAM_PROTECT|(MMAP_D_UEERAM_HIADDR>>19))&$FF
MMAP_D_UEERAM_BYTE4	EQU	                    ((MMAP_D_UEERAM_HIADDR>>11))&$FF
MMAP_D_UEERAM_BYTE5	EQU	                    ((MMAP_D_UEERAM_HIADDR>>03))&$FF

MMAP_D_EERAM_LOADDR	EQU	MMAP_EERAM_GLOBAL_START	;EERAM
MMAP_D_EERAM_HIADDR	EQU	MMAP_EERAM_END-1
MMAP_D_EERAM_PROTECT	EQU	0 			;read, write and execute
MMAP_D_EERAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_EERAM_LOADDR>>19))&$FF
MMAP_D_EERAM_BYTE1	EQU	                    ((MMAP_D_EERAM_LOADDR>>11))&$FF
MMAP_D_EERAM_BYTE2	EQU	                    ((MMAP_D_EERAM_LOADDR>>03))&$FF
MMAP_D_EERAM_BYTE3	EQU    (MMAP_D_EERAM_PROTECT|(MMAP_D_EERAM_HIADDR>>19))&$FF
MMAP_D_EERAM_BYTE4	EQU	                    ((MMAP_D_EERAM_HIADDR>>11))&$FF
MMAP_D_EERAM_BYTE5	EQU	                    ((MMAP_D_EERAM_HIADDR>>03))&$FF

MMAP_D_UFLASH_LOADDR	EQU	MMAP_EERAM_GLOBAL_END	;unimplemented flash space
MMAP_D_UFLASH_HIADDR	EQU	MMAP_FLASH_GLOBAL_START-1
MMAP_D_UFLASH_PROTECT	EQU	WP|NEX 			;read only
MMAP_D_UFLASH_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_UFLASH_LOADDR>>19))&$FF
MMAP_D_UFLASH_BYTE1	EQU	                    ((MMAP_D_UFLASH_LOADDR>>11))&$FF
MMAP_D_UFLASH_BYTE2	EQU	                    ((MMAP_D_UFLASH_LOADDR>>03))&$FF
MMAP_D_UFLASH_BYTE3	EQU   (MMAP_D_UFLASH_PROTECT|(MMAP_D_UFLASH_HIADDR>>19))&$FF
MMAP_D_UFLASH_BYTE4	EQU	                    ((MMAP_D_UFLASH_HIADDR>>11))&$FF
MMAP_D_UFLASH_BYTE5	EQU	                    ((MMAP_D_UFLASH_HIADDR>>03))&$FF

MMAP_D_FLASH_LOADDR	EQU	MMAP_FLASH_GLOBAL_START ;Flash
MMAP_D_FLASH_HIADDR	EQU	MMAP_FLASH_GLOBAL_END-1
MMAP_D_FLASH_PROTECT	EQU	WP 			;read and execute
MMAP_D_FLASH_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_FLASH_LOADDR>>19))&$FF
MMAP_D_FLASH_BYTE1	EQU	                    ((MMAP_D_FLASH_LOADDR>>11))&$FF
MMAP_D_FLASH_BYTE2	EQU	                    ((MMAP_D_FLASH_LOADDR>>03))&$FF
MMAP_D_FLASH_BYTE3	EQU    (MMAP_D_FLASH_PROTECT|(MMAP_D_FLASH_HIADDR>>19))&$FF
MMAP_D_FLASH_BYTE4	EQU	                    ((MMAP_D_FLASH_HIADDR>>11))&$FF
MMAP_D_FLASH_BYTE5	EQU	                    ((MMAP_D_FLASH_HIADDR>>03))&$FF
	
;# Vector table
#ifndef VECTAB_START
#ifdef	MMAP_RAM
VECTAB_START		EQU	$7F10    
VECTAB_START_LIN	EQU	$0FFF10    
#endif
#ifdef	MMAP_FLASH
VECTAB_START		EQU	$EF10    
VECTAB_START_LIN	EQU	$7FEF10    
#endif
#endif
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef MMAP_VARS_START_LIN
			ORG 	MMAP_VARS_START, MMAP_VARS_START_LIN
#else
			ORG 	MMAP_VARS_START
MMAP_VARS_START_LIN	EQU	@			
#endif	

MMAP_VARS_END		EQU	*
MMAP_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	MMAP_INIT, 0
			;Setup MPU
			;Descriptor 0: Register space                 	-> read and write
			CLR	MPUSEL
			MOVW	#((MMAP_D_REG_BYTE0<<8)|(MMAP_D_REG_BYTE1)), MPUDESC0
			MOVW	#((MMAP_D_REG_BYTE2<<8)|(MMAP_D_REG_BYTE3)), MPUDESC2
			MOVW	#((MMAP_D_REG_BYTE4<<8)|(MMAP_D_REG_BYTE5)), MPUDESC4
			;Descriptor 1: Unimplemented RAM 		-> read only 
			INC	MPUSEL
			MOVW	#((MMAP_D_URAM_BYTE0<<8)|(MMAP_D_URAM_BYTE1)), MPUDESC0
			MOVW	#((MMAP_D_URAM_BYTE2<<8)|(MMAP_D_URAM_BYTE3)), MPUDESC2
			MOVW	#((MMAP_D_URAM_BYTE4<<8)|(MMAP_D_URAM_BYTE5)), MPUDESC4
			;Descriptor 1: RAM 				-> read, write, and execute 
			INC	MPUSEL
			MOVW	#((MMAP_D_RAM_BYTE0<<8)|(MMAP_D_RAM_BYTE1)), MPUDESC0
			MOVW	#((MMAP_D_RAM_BYTE2<<8)|(MMAP_D_RAM_BYTE3)), MPUDESC2
			MOVW	#((MMAP_D_RAM_BYTE4<<8)|(MMAP_D_RAM_BYTE5)), MPUDESC4
			;Descriptor 2:  Unimplemented EERAM 		-> read only
			INC	MPUSEL
			MOVW	#((MMAP_D_UEERAM_BYTE0<<8)|(MMAP_D_UEERAM_BYTE1)), MPUDESC0
			MOVW	#((MMAP_D_UEERAM_BYTE2<<8)|(MMAP_D_UEERAM_BYTE3)), MPUDESC2
			MOVW	#((MMAP_D_UEERAM_BYTE4<<8)|(MMAP_D_UEERAM_BYTE5)), MPUDESC4
			;Descriptor 2:  EERAM		 		-> read, write, and execute
			INC	MPUSEL
			MOVW	#((MMAP_D_EERAM_BYTE0<<8)|(MMAP_D_EERAM_BYTE1)), MPUDESC0
			MOVW	#((MMAP_D_EERAM_BYTE2<<8)|(MMAP_D_EERAM_BYTE3)), MPUDESC2
			MOVW	#((MMAP_D_EERAM_BYTE4<<8)|(MMAP_D_EERAM_BYTE5)), MPUDESC4
			;Descriptor 3:  Unimplemented Flash 		-> read only
			INC	MPUSEL
			MOVW	#((MMAP_D_UFLASH_BYTE0<<8)|(MMAP_D_UFLASH_BYTE1)), MPUDESC0
			MOVW	#((MMAP_D_UFLASH_BYTE2<<8)|(MMAP_D_UFLASH_BYTE3)), MPUDESC2
			MOVW	#((MMAP_D_UFLASH_BYTE4<<8)|(MMAP_D_UFLASH_BYTE5)), MPUDESC4
			;Descriptor 4:  Unimplemented Flash 		-> read and execute
			INC	MPUSEL
			MOVW	#((MMAP_D_FLASH_BYTE0<<8)|(MMAP_D_FLASH_BYTE1)), MPUDESC0
			MOVW	#((MMAP_D_FLASH_BYTE2<<8)|(MMAP_D_FLASH_BYTE3)), MPUDESC2
			MOVW	#((MMAP_D_FLASH_BYTE4<<8)|(MMAP_D_FLASH_BYTE5)), MPUDESC4
			;Enable descriptors in supervisor mode
			MOVB	#SVSEN, MPUSEL
;#ifndef MMAP_RAM			;Don't write to RPAGE while executing code from RAM
;			;Initialize RPAGE
			MOVB	#(MMAP_RAM_START_LIN>>12), RPAGE
;#endif	
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef MMAP_CODE_START_LIN
			ORG 	MMAP_CODE_START, MMAP_CODE_START_LIN
#else
			ORG 	MMAP_CODE_START
MMAP_CODE_START_LIN	EQU	@			
#endif	

;#Trigger a fatal error if a reset accurs
MMAP_ISR_MPU		EQU	*
			RESET_FATAL	MMAP_STR_MPU
	
MMAP_CODE_END		EQU	*	
MMAP_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef MMAP_TABS_START_LIN
			ORG 	MMAP_TABS_START, MMAP_TABS_START_LIN
#else
			ORG 	MMAP_TABS_START
MMAP_TABS_START_LIN	EQU	@			
#endif	

MMAP_STR_MPU		FCS	"MPU error"

MMAP_TABS_END		EQU	*	
MMAP_TABS_END_LIN	EQU	@	
#endif	

