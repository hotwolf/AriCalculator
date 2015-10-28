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
;#    October 27, 2015							       #
;#	- Cleanup							       #
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
;  	Flash->+ +-------------+ $8000
;              | | Page Window |	     
;              + +-------------+ $C000
;  	       | |    Code     |
;  	      P| +-------------+ 
;  	      a| |   Tables    |
;  	      g| +-------------+
;             e| |/////////////|	     
;  	       | +-------------+ $DF10
;  	      F| |   Vectors   |
;  	      F| +-------------+ $E000
;  	       | | BootLoader  |
;  	       + +-------------+ 
; 
;  RAM Memory Map:
;  ---------------  
;                     S12XE                
;        	 +-------------+ $0000
;  		 |  Registers  |
;  	  RAM->+ +-------------+ $0800
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
;# Memory Sizes:
#ifdef	MMAP_S12XEP100
MMAP_REG_SIZE		EQU	 $0800	;    2k
MMAP_EERAM_SIZE		EQU	 $1000	;    4k
MMAP_RAM_SIZE		EQU	 $10000	;   64k
MMAP_FLASH_SIZE		EQU	 $8000	; 1024k
#endif
#ifdef	MMAP_S12XEQ512
MMAP_REG_SIZE		EQU	 $0800	;    2k
MMAP_EERAM_SIZE		EQU	 $1000	;    4k
MMAP_RAM_SIZE		EQU	 $8000	;   32k
MMAP_FLASH_SIZE		EQU	$10000	;  512k
#endif
	
;# Memory Locations
;Register space
MMAP_REG_START		EQU	$0000
MMAP_REG_END		EQU	$0800
MMAP_REG_START_LIN	EQU	MMAP_REG_START
MMAP_REG_END_LIN	EQU	MMAP_REG_END

;EEE RAM
MMAP_EERAM_WIN_START	EQU	$0800
MMAP_EERAM_WIN_END	EQU	$0C00
MMAP_EERAM_FF_START	EQU	$0C00
MMAP_EERAM_FF_END	EQU	$1000
MMAP_EERAM_FF_START_LIN	EQU	$13_FC00
MMAP_EERAM_FF_END_LIN	EQU	$14_0000

;RAM
MMAP_RAM_WIN_START	EQU	$1000
MMAP_RAM_WIN_END	EQU	$2000

MMAP_RAM_FA_START	EQU	$2C00
MMAP_RAM_FA_END		EQU	$3000
MMAP_RAM_FA_START_LIN	EQU	$0F_AC00
MMAP_RAM_FA_END_LIN	EQU	$0F_B000

MMAP_RAM_FB_START	EQU	$3000
MMAP_RAM_FB_END		EQU	$4000
MMAP_RAM_FB_START_LIN	EQU	$0F_B000
MMAP_RAM_FB_END_LIN	EQU	$0F_C000

MMAP_RAM_FC_START	EQU	$4000
MMAP_RAM_FC_END		EQU	$5000
MMAP_RAM_FC_START_LIN	EQU	$0F_C000
MMAP_RAM_FC_END_LIN	EQU	$0F_D000

MMAP_RAM_FD_START	EQU	$5000
MMAP_RAM_FD_END		EQU	$6000
MMAP_RAM_FD_START_LIN	EQU	$0F_D000
MMAP_RAM_FD_END_LIN	EQU	$0F_E000

MMAP_RAM_FE_START	EQU	$6C00
MMAP_RAM_FE_END		EQU	$7000
MMAP_RAM_FE_START_LIN	EQU	$0F_EC00
MMAP_RAM_FE_END_LIN	EQU	$0F_F000

MMAP_RAM_FF_START	EQU	$7000
MMAP_RAM_FF_END		EQU	$8000
MMAP_RAM_FF_START_LIN	EQU	$0F_F000
MMAP_RAM_FF_END_LIN	EQU	$10_0000

;Combined RAM
MMAP_RAM_START		EQU	MMAP_EERAM_WIN_START
MMAP_RAM_END		EQU	MMAP_RAM_FF_END

;Flash
MMAP_FLASHWIN_START	EQU	$8000
MMAP_FLASHWIN_END	EQU	$C000

MMAP_FLASH_FF_START	EQU	$C000
MMAP_FLASH_FF_END	EQU	$10000
MMAP_FLASH_FF_START_LIN	EQU	$7F_C000
MMAP_FLASH_FF_END_LIN	EQU	$80_0000

;#MPU desccriptors	
MMAP_D_REG_LOADDR	EQU	MMAP_REG_START_LIN 	;register space
MMAP_D_REG_HIADDR	EQU	MMAP_REG_END_LIN-1
MMAP_D_REG_PROTECT	EQU	NEX 			;read and write
MMAP_D_REG_BYTE0	EQU   	       (MSTR0|MSTR1|(MMAP_D_REG_LOADDR>>19))&$FF
MMAP_D_REG_BYTE1	EQU	                   ((MMAP_D_REG_LOADDR>>11))&$FF
MMAP_D_REG_BYTE2	EQU                   	   ((MMAP_D_REG_LOADDR>>03))&$FF
MMAP_D_REG_BYTE3	EQU	(MMAP_D_REG_PROTECT|(MMAP_D_REG_HIADDR>>19))&$FF
MMAP_D_REG_BYTE4	EQU	                   ((MMAP_D_REG_HIADDR>>11))&$FF
MMAP_D_REG_BYTE5	EQU 	                   ((MMAP_D_REG_HIADDR>>03))&$FF

MMAP_D_URAM_LOADDR	EQU	MMAP_REG_END_LIN 	;unimplemented RAM space
MMAP_D_URAM_HIADDR	EQU	(MMAP_RAM_FF_END_LIN-MMAP_RAM_SIZE)-1
MMAP_D_URAM_PROTECT	EQU	WP|NEX 			;read only
MMAP_D_URAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_URAM_LOADDR>>19))&$FF
MMAP_D_URAM_BYTE1	EQU	                    ((MMAP_D_URAM_LOADDR>>11))&$FF
MMAP_D_URAM_BYTE2	EQU	                    ((MMAP_D_URAM_LOADDR>>03))&$FF
MMAP_D_URAM_BYTE3	EQU     (MMAP_D_URAM_PROTECT|(MMAP_D_URAM_HIADDR>>19))&$FF
MMAP_D_URAM_BYTE4	EQU	                    ((MMAP_D_URAM_HIADDR>>11))&$FF
MMAP_D_URAM_BYTE5	EQU	                    ((MMAP_D_URAM_HIADDR>>03))&$FF

MMAP_D_RAM_LOADDR	EQU	MMAP_RAM_FF_END_LIN-MMAP_RAM_SIZE;RAM
MMAP_D_RAM_HIADDR	EQU	MMAP_RAM_FF_END_LIN-1
MMAP_D_RAM_PROTECT	EQU	0 			;read, write, and execute
MMAP_D_RAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_RAM_LOADDR>>19))&$FF
MMAP_D_RAM_BYTE1	EQU	                    ((MMAP_D_RAM_LOADDR>>11))&$FF
MMAP_D_RAM_BYTE2	EQU	                    ((MMAP_D_RAM_LOADDR>>03))&$FF
MMAP_D_RAM_BYTE3	EQU      (MMAP_D_RAM_PROTECT|(MMAP_D_RAM_HIADDR>>19))&$FF
MMAP_D_RAM_BYTE4	EQU	                    ((MMAP_D_RAM_HIADDR>>11))&$FF
MMAP_D_RAM_BYTE5	EQU	                    ((MMAP_D_RAM_HIADDR>>03))&$FF

MMAP_D_UEERAM_LOADDR	EQU	MMAP_RAM_FF_END_LIN	;unimplemented EERAM space 
MMAP_D_UEERAM_HIADDR	EQU	(MMAP_EERAM_FF_END_LIN-MMAP_EERAM_SIZE)-1
MMAP_D_UEERAM_PROTECT	EQU	WP|NEX 			;read only
MMAP_D_UEERAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_UEERAM_LOADDR>>19))&$FF
MMAP_D_UEERAM_BYTE1	EQU	                    ((MMAP_D_UEERAM_LOADDR>>11))&$FF
MMAP_D_UEERAM_BYTE2	EQU	                    ((MMAP_D_UEERAM_LOADDR>>03))&$FF
MMAP_D_UEERAM_BYTE3	EQU   (MMAP_D_UEERAM_PROTECT|(MMAP_D_UEERAM_HIADDR>>19))&$FF
MMAP_D_UEERAM_BYTE4	EQU	                    ((MMAP_D_UEERAM_HIADDR>>11))&$FF
MMAP_D_UEERAM_BYTE5	EQU	                    ((MMAP_D_UEERAM_HIADDR>>03))&$FF

MMAP_D_EERAM_LOADDR	EQU	MMAP_EERAM_FF_END_LIN-MMAP_EERAM_SIZE;EERAM
MMAP_D_EERAM_HIADDR	EQU	MMAP_EERAM_FF_END_LIN-1
MMAP_D_EERAM_PROTECT	EQU	0 			;read, write and execute
MMAP_D_EERAM_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_EERAM_LOADDR>>19))&$FF
MMAP_D_EERAM_BYTE1	EQU	                    ((MMAP_D_EERAM_LOADDR>>11))&$FF
MMAP_D_EERAM_BYTE2	EQU	                    ((MMAP_D_EERAM_LOADDR>>03))&$FF
MMAP_D_EERAM_BYTE3	EQU    (MMAP_D_EERAM_PROTECT|(MMAP_D_EERAM_HIADDR>>19))&$FF
MMAP_D_EERAM_BYTE4	EQU	                    ((MMAP_D_EERAM_HIADDR>>11))&$FF
MMAP_D_EERAM_BYTE5	EQU	                    ((MMAP_D_EERAM_HIADDR>>03))&$FF

MMAP_D_UFLASH_LOADDR	EQU	MMAP_EERAM_FF_END_LIN	;unimplemented flash space
MMAP_D_UFLASH_HIADDR	EQU	(MMAP_FLASH_FF_END_LIN-MMAP_FLASH_SIZE)-1
MMAP_D_UFLASH_PROTECT	EQU	WP|NEX 			;read only
MMAP_D_UFLASH_BYTE0	EQU	        (MSTR0|MSTR1|(MMAP_D_UFLASH_LOADDR>>19))&$FF
MMAP_D_UFLASH_BYTE1	EQU	                    ((MMAP_D_UFLASH_LOADDR>>11))&$FF
MMAP_D_UFLASH_BYTE2	EQU	                    ((MMAP_D_UFLASH_LOADDR>>03))&$FF
MMAP_D_UFLASH_BYTE3	EQU   (MMAP_D_UFLASH_PROTECT|(MMAP_D_UFLASH_HIADDR>>19))&$FF
MMAP_D_UFLASH_BYTE4	EQU	                    ((MMAP_D_UFLASH_HIADDR>>11))&$FF
MMAP_D_UFLASH_BYTE5	EQU	                    ((MMAP_D_UFLASH_HIADDR>>03))&$FF

MMAP_D_FLASH_LOADDR	EQU	MMAP_FLASH_FF_END_LIN-MMAP_FLASH_SIZE;Flash
MMAP_D_FLASH_HIADDR	EQU	MMAP_FLASH_FF_END_LIN-1
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
VECTAB_START_LIN	EQU	$0F_FF10    
#endif
#ifdef	MMAP_FLASH
VECTAB_START		EQU	$EF10    
VECTAB_START_LIN	EQU	$7F_EF10    
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
			;Setup 30K linear RAM space
			CLR	DIRECT 			;lock DIRECT page register
			BSET	MMCCTL1, #(RAMHM|ROMHM)	;MAP RAM 
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

