#ifndef	IMG
#define	IMG
;###############################################################################
;# AriCalculator - Bootloader - Images for the LCD Display                     #
;###############################################################################
;#    Copyright 2010-2017 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12 MCU family.    #
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
;#    This module defines the static vector table of the AriCalculator         #
;#    bootloader.                                                              #
;###############################################################################
;# Version History:                                                            #
;#    August 18, 2017                                                          #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef IMG_VARS_START_LIN
			ORG 	IMG_VARS_START, IMG_VARS_START_LIN
#else
IMG_VARS_START_LIN	EQU	@			
#endif

IMG_VARS_END		EQU	*
IMG_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	IMG_INIT, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef IMG_CODE_START_LIN
			ORG 	IMG_CODE_START, IMG_CODE_START_LIN
#else
			ORG 	IMG_CODE_START
IMG_CODE_START_LIN	EQU	@			
#endif

IMG_CODE_END		EQU	*	
IMG_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef IMG_TABS_START_LIN
			ORG 	IMG_TABS_START, IMG_TABS_START_LIN
#else
			ORG 	IMG_TABS_START
IMG_TABS_START_LIN	EQU	@			
#endif	

;#Display configurationtion
;#=========================
IMG_SEQ_INIT_START	EQU	*
			DISP_SEQ_CONFIG 		;configure display
	
;#Static content - pages 0 to 5
;#=============================
;#Page 0:
			DB  $B0 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $04 $00          ;repeat 5 times
			DB  $FF $FF
			DB  DISP_ESC_START $03 $33          ;repeat 4 times
			DB  $03 $00 $00 $FB $FB $00 $00 $F8
			DB  $F8 $30 $18 $18 $00 $F8 $F8 $10
			DB  $18 $F8 $F0 $10 $18 $F8 $F0 $00
			DB  $18 $F8 $E0 $80 $F0 $78 $F0 $80
			DB  $E0 $F8 $18 $00 $10 $98 $D8 $58
			DB  $F8 $F0 $00 $00 $F8 $F8 $30 $18
			DB  $18 $00 $E0 $F0 $D8 $D8 $D8 $F0
			DB  $E0
			DB  DISP_ESC_START $05 $00          ;repeat 6 times
			DB  $FF $FF
			DB  DISP_ESC_START $04 $00          ;repeat 5 times
			DB  $FF $FF $00 $00 $F8 $F8 $30 $18
			DB  $38 $F0 $E0 $00 $00 $E0 $F0 $38
			DB  $18 $30 $FF $FF $00 $00 $10 $98
			DB  $D8 $58 $F8 $F0 $00 $18 $FC $FE
			DB  $18 $18 $00 $E0 $F0 $D8 $D8 $D8
			DB  $F0 $E0
			DB  DISP_ESC_START $04 $00          ;repeat 5 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 1:		
			DB  $B1 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  $30 $37 $37
			DB  DISP_ESC_START $06 $30          ;repeat 7 times
			DB  $37 $37 $30 $30 $37 $37
			DB  DISP_ESC_START $03 $30          ;repeat 4 times
			DB  $37 $37 $30 $30 $37 $37 $30 $30
			DB  $37 $37 $30 $30 $30 $37 $37 $33
			DB  $30 $33 $37 $37 $30 $30 $30 $33
			DB  $37 $36 $36 $33 $37 $34 $30 $37
			DB  $37
			DB  DISP_ESC_START $03 $30          ;repeat 4 times
			DB  $31 $33
			DB  DISP_ESC_START $03 $36          ;repeat 4 times
			DB  $32
			DB  DISP_ESC_START $05 $30          ;repeat 6 times
			DB  $31 $33 $37 $36 $36 $36 $37 $33
			DB  $31 $30 $00 $3F $3F $03 $36 $37
			DB  $33 $31 $30 $30 $31 $33 $37 $36
			DB  $33 $37 $37 $30 $30 $33 $37 $36
			DB  $36 $33 $37 $34 $30 $33 $37 $36
			DB  $36 $30 $31 $33
			DB  DISP_ESC_START $03 $36          ;repeat 4 times
			DB  $32 $30
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 2:		
			DB  $B2 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $13 $00          ;repeat 20 times
			DB  $10 $10 $F0 $10 $10 $00 $80 $40
			DB  $40 $80 $00 $00 $C0 $40 $00 $C0
			DB  $40 $40 $80 $40 $40 $80 $00 $00
			DB  $D0 $00 $00 $C0 $40 $40 $80 $00
			DB  $00 $00 $40 $40 $80 $00 $00 $F0
			DB  DISP_ESC_START $04 $00          ;repeat 5 times
			DB  $60 $90 $90 $90 $20 $00 $00 $80
			DB  $40 $40 $80 $00 $40 $F0 $40 $40
			DB  $F0 $40 $00 $D0 $00 $00 $C0 $40
			DB  $40 $80 $00 $00 $80 $40 $40 $C0
			DB  $00 $80 $40 $40 $40 $00 $40
			DB  DISP_ESC_START $17 $00          ;repeat 24 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 3:		
			DB  $B3 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $06 $00          ;repeat 7 times
			DB  $80 $40 $40 $80 $00 $80 $40 $40
			DB  $80 $00 $80 $40 $40 $80 $00 $87
			DB  $40 $40 $80 $03 $05 $05 $05 $C0
			DB  $00 $07 $00 $00 $07 $00 $00 $07
			DB  $00 $00 $07 $00 $00 $07 $00 $00
			DB  $07 $00 $00 $07 $C0 $00 $06 $05
			DB  $05 $07 $00 $00 $87 $40 $40 $80
			DB  $00 $00 $C2 $84 $04 $04 $C3 $00
			DB  $00 $83 $C5 $05 $05 $00 $00 $03
			DB  $04 $00 $03 $04 $C0 $47 $40 $40
			DB  $87 $00 $40 $47 $C0 $40 $4B $14
			DB  $94 $4F $40 $84 $05 $05 $02 $C0
			DB  $04 $80 $40 $40 $40 $80 $00 $40
			DB  $40 $C0 $40 $40 $00 $80 $40 $40
			DB  $80
			DB  DISP_ESC_START $07 $00          ;repeat 8 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 4:		
			DB  $B4 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $06 $00          ;repeat 7 times
			DB  $09 $12 $12 $0F $00 $0F $12 $12
			DB  $0C $00 $0F $10 $10 $0F $00 $0F
			DB  $10 $10 $0F
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  $1F $11 $11 $11 $0E $00 $09 $15
			DB  $15 $1E $00 $0F $10 $10 $10 $1F
			DB  $00 $0E $11 $11 $11 $1F $00 $00
			DB  $30
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  $0D $12 $12 $0D $00 $00 $1F $01
			DB  $02 $0C $1F $00 $01 $00 $1F $00
			DB  $00 $00 $30
			DB  DISP_ESC_START $04 $00          ;repeat 5 times
			DB  $1F $02 $06 $0A $11 $00 $00 $00
			DB  $1F $00 $00 $00 $09 $12 $12 $0C
			DB  $00 $18 $07 $00 $00 $0F $10 $10
			DB  $10 $08 $00 $00 $00 $1F $00 $00
			DB  $00 $09 $12 $12 $0C
			DB  DISP_ESC_START $07 $00          ;repeat 8 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 5:		
			DB  $B5 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $7F $00          ;repeat 128 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
	
;#"READY" banner - pages 6 to 7
;#=============================
;#Page 6:
			DB  $B6 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $29 $00          ;repeat 42 times
			DB  $F8 $FF $67 $63
			DB  DISP_ESC_START $01 $E3          ;repeat 2 times
			DB  $33 $3F $1E $00 $E0 $F0 $78 $58
			DB  $58 $78 $70 $00 $80 $90 $D8 $58
			DB  $D8 $F8 $70 $00 $E0 $F0 $38 $18
			DB  $18 $B0 $F8 $FF $07 $18 $F8 $E0
			DB  $00 $C0 $F0 $38 $08 $00 $F8 $3F
			DB  $07
			DB  DISP_ESC_START $26 $00          ;repeat 39 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 7:		
			DB  $B7 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $28 $00          ;repeat 41 times
			DB  $07 $07
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  $03 $07 $04 $00 $00 $01 $03 $06
			DB  $06 $06 $03 $01 $00 $03 $07 $06
			DB  $02 $07 $07 $00 $00 $03 $07 $06
			DB  $06 $02 $07 $07 $00 $30 $30 $39
			DB  $1F $0F $03 $00 $00 $00 $06 $06
			DB  DISP_ESC_START $28 $00          ;repeat 41 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
DISP_SEQ_INIT_END	EQU	*

;#"BUSY" banner - pages 6 to 7
;#============================
IMG_SEQ_BUSY_START	EQU	*
;#Page 6:
			DB  $B6 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $2E $00          ;repeat 47 times
			DB  $F8 $FF $37 $33 $33 $33 $F3 $DF
			DB  $0E $00 $80 $F8 $78 $00 $00 $80
			DB  $F8 $78 $00 $00 $70 $F8 $D8 $D8
			DB  $98 $10 $00 $18 $F8 $E0 $00 $C0
			DB  $F0 $38 $08 $00 $F8 $3F $07
			DB  DISP_ESC_START $29 $00          ;repeat 42 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 7:		
			DB  $B7 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $2D $00          ;repeat 46 times
			DB  $07 $07
			DB  DISP_ESC_START $03 $06          ;repeat 4 times
			DB  $07 $03 $01 $00 $00 $03 $07 $06
			DB  $06 $02 $07 $07 $00 $00 $02 $06
			DB  $06 $06 $07 $03 $00 $30 $30 $39
			DB  $1F $0F $03 $00 $00 $00 $06 $06
			DB  DISP_ESC_START $2B $00          ;repeat 44 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
IMG_SEQ_BUSY_END	EQU	*

;#"DONE" banner - pages 6 to 7
;#============================
IMG_SEQ_DONE_START	EQU	*
;#Page 6:
			DB  $B6 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $2E $00          ;repeat 47 times
			DB  $F8 $FF $07 $03 $03 $03 $87 $FE
			DB  $7C $00 $E0 $F0 $38 $18 $18 $18
			DB  $F0 $E0 $00 $00 $F8 $F8 $30 $18
			DB  $18 $F8 $F0 $00 $E0 $F0 $78 $58
			DB  $58 $78 $70 $00 $00 $F8 $3F $07
			DB  DISP_ESC_START $28 $00          ;repeat 41 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 7:		
			DB  $B7 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $2D $00          ;repeat 46 times
			DB  $07 $07
			DB  DISP_ESC_START $03 $06          ;repeat 4 times
			DB  $07 $03 $01 $00 $00 $01 $03 $06
			DB  $06 $06 $07 $03 $01 $00 $07 $07
			DB  $00 $00 $00 $07 $07 $00 $00 $01
			DB  $03 $06 $06 $06 $03 $01 $00 $06
			DB  $06
			DB  DISP_ESC_START $2A $00          ;repeat 43 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
IMG_SEQ_DONE_END	EQU	*

;#"ERROR" banner - pages 6 to 7
;#=============================
IMG_SEQ_ERROR_START	EQU	*
;#Page 6:
			DB  $B6 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $2E $00          ;repeat 47 times
			DB  $F8 $FF $37
			DB  DISP_ESC_START $03 $33          ;repeat 4 times
			DB  $03 $03 $00 $F8 $F8 $30 $18 $18
			DB  $00 $F8 $F8 $30 $18 $18 $E0 $F0
			DB  $38 $18 $18 $18 $F0 $E0 $00 $00
			DB  $F8 $F8 $30 $18 $18 $00 $F8 $3F
			DB  $07
			DB  DISP_ESC_START $28 $00          ;repeat 41 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 7:		
			DB  $B7 $10 $00                     ;set page and column address
			DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
			DB  DISP_ESC_START $2D $00          ;repeat 46 times
			DB  $07 $07
			DB  DISP_ESC_START $05 $06          ;repeat 6 times
			DB  $00 $00 $07 $07
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  $07 $07
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  $01 $03 $06 $06 $06 $07 $03 $01
			DB  $00 $07 $07
			DB  DISP_ESC_START $03 $00          ;repeat 4 times
			DB  $06 $06
			DB  DISP_ESC_START $2A $00          ;repeat 43 times
			DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
IMG_SEQ_ERROR_END	EQU	*
	
IMG_TABS_END		EQU	*	
IMG_TABS_END_LIN	EQU	@	

#endif
