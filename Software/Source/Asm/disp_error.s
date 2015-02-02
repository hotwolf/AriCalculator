#ifndef	DISP_ERROR
#define	DISP_ERROR
;###############################################################################
;# AriCalculator - Image: Error.raw (single frame)                             #
;###############################################################################
;#    Copyright 2012 - 2015 Dirk Heisswolf                                     #
;#    This file is part of the AriCalculator framework for Freescale's S12(X)  #
;#    MCU families.                                                            #
;#                                                                             #
;#    AriCalculator is free software: you can redistribute it and/or modify    #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    AriCalculator is distributed in the hope that it will be useful,         #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with AriCalculator.  If not, see <http://www.gnu.org/licenses/>.   #
;###############################################################################
;# Description:                                                                #
;#    This file contains the two macros:                                       #
;#       DISP_ERROR_TAB:                                                       #
;#           This macro allocates a table of raw image data.                   #
;#                                                                             #
;#       DISP_ERROR_STREAM:                                                    #
;#           This macro allocates a compressed stream of image data and        #
;#           control commands, which can be directly driven to the display     #
;#           driver.                                                           #
;###############################################################################
;# Generated on Mon, Feb 02 2015                                               #
;###############################################################################

#macro DISP_ERROR_TAB, 0

;#Frame 0:
;#----------------------------------------------------------------------
;#Page 0:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $7F  $1F  $1F  $0F  $0F  $07  $07
		DB  $07  $07  $07  $07  $0F  $1F  $3F  $FF
;#Page 1:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $F0  $E0  $C0  $C0  $80  $80  $80
		DB  $80  $80  $C0  $C0  $E0  $F0  $F8  $FF
;#Page 2:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $3F  $0F  $0F
		DB  $07  $07  $07  $7F  $FF  $FF  $FF  $FF
;#Page 3:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $00  $00  $00
		DB  $00  $00  $00  $00  $FF  $FF  $FF  $FF
;#Page 4:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $01  $00  $00  $00
		DB  $00  $00  $00  $00  $03  $FF  $FF  $FF
;#Page 5:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $3F  $3F  $3F  $FF  $FF  $FF
		DB  $7F  $3F  $3F  $3F  $3F  $7F  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $3F  $3F  $3F  $FF
		DB  $FF  $FF  $FF  $3F  $3F  $3F  $FF  $3F
		DB  $3F  $3F  $3F  $3F  $3F  $3F  $3F  $3F
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $3F  $3F  $3F  $FF  $FF  $3F  $3F  $3F
		DB  $7F  $3F  $3F  $3F  $3F  $7F  $FF  $3F
		DB  $3F  $3F  $3F  $7F  $FF  $FF  $FF  $3F
		DB  $3F  $3F  $7F  $3F  $3F  $3F  $3F  $7F
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $3F
		DB  $3F  $3F  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $1F  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $1F  $FF  $FF
;#Page 6:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $1F  $1F
		DB  $8F  $01  $00  $00  $FC  $FF  $C1  $80
		DB  $00  $3E  $3F  $1F  $80  $80  $E0  $FF
		DB  $1F  $1F  $8F  $01  $00  $00  $FC  $1F
		DB  $1F  $8F  $01  $00  $00  $FC  $FF  $C6
		DB  $C6  $C6  $C6  $46  $00  $00  $80  $FE
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $7F  $01
		DB  $00  $80  $FE  $FF  $83  $80  $00  $30
		DB  $33  $33  $11  $98  $D8  $3C  $3F  $3F
		DB  $07  $00  $00  $30  $3F  $FF  $83  $80
		DB  $00  $30  $33  $33  $11  $98  $D8  $FC
		DB  $FF  $C7  $C7  $C7  $C7  $47  $01  $00
		DB  $80  $FE  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $FF  $FF
;#Page 7:
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $F8  $F8  $F8
		DB  $F8  $F8  $F8  $F8  $F8  $F8  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $F8  $F8
		DB  $F8  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $F8
		DB  $F8  $F8  $FE  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $F8
		DB  $F8  $F8  $F8  $F8  $F8  $F8  $F8  $F8
		DB  $FF  $FF  $FF  $FF  $FF  $FF  $FF  $FF
		DB  $FF  $FF  $E0  $C0  $C0  $C0  $E0  $E0
		DB  $F0  $F0  $F8  $F8  $FC  $FC  $FE  $FF

#emac
;Size = 1024 bytes

#macro DISP_ERROR_STREAM, 0

;#Frame 0:
;#----------------------------------------------------------------------
;#Page 0:
		DB  $B0 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $70 $FF          ;repeat 113 times
		DB  $7F $1F $1F $0F $0F
		DB  DISP_ESC_START $05 $07          ;repeat 6 times
		DB  $0F $1F $3F $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 1:
		DB  $B1 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $70 $FF          ;repeat 113 times
		DB  $F0 $E0 $C0 $C0
		DB  DISP_ESC_START $04 $80          ;repeat 5 times
		DB  $C0 $C0 $E0 $F0 $F8 $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 2:
		DB  $B2 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $74 $FF          ;repeat 117 times
		DB  $3F $0F $0F $07 $07 $07 $7F $FF
		DB  $FF $FF $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 3:
		DB  $B3 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $74 $FF          ;repeat 117 times
		DB  DISP_ESC_START $06 $00          ;repeat 7 times
		DB  $FF $FF $FF $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 4:
		DB  $B4 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $73 $FF          ;repeat 116 times
		DB  $01
		DB  DISP_ESC_START $06 $00          ;repeat 7 times
		DB  $03 $FF $FF $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 5:
		DB  $B5 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $11 $FF          ;repeat 18 times
		DB  $3F $3F $3F $FF $FF $FF $7F
		DB  DISP_ESC_START $03 $3F          ;repeat 4 times
		DB  $7F
		DB  DISP_ESC_START $05 $FF          ;repeat 6 times
		DB  $3F $3F $3F
		DB  DISP_ESC_START $03 $FF          ;repeat 4 times
		DB  $3F $3F $3F $FF
		DB  DISP_ESC_START $08 $3F          ;repeat 9 times
		DB  DISP_ESC_START $07 $FF          ;repeat 8 times
		DB  $3F $3F $3F $FF $FF $3F $3F $3F
		DB  $7F
		DB  DISP_ESC_START $03 $3F          ;repeat 4 times
		DB  $7F $FF
		DB  DISP_ESC_START $03 $3F          ;repeat 4 times
		DB  $7F $FF $FF $FF $3F $3F $3F $7F
		DB  DISP_ESC_START $03 $3F          ;repeat 4 times
		DB  $7F
		DB  DISP_ESC_START $06 $FF          ;repeat 7 times
		DB  $3F $3F $3F
		DB  DISP_ESC_START $08 $FF          ;repeat 9 times
		DB  $1F
		DB  DISP_ESC_START $08 $00          ;repeat 9 times
		DB  $1F $FF $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 6:
		DB  $B6 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $0D $FF          ;repeat 14 times
		DB  $1F $1F $8F $01 $00 $00 $FC $FF
		DB  $C1 $80 $00 $3E $3F $1F $80 $80
		DB  $E0 $FF $1F $1F $8F $01 $00 $00
		DB  $FC $1F $1F $8F $01 $00 $00 $FC
		DB  $FF
		DB  DISP_ESC_START $03 $C6          ;repeat 4 times
		DB  $46 $00 $00 $80 $FE
		DB  DISP_ESC_START $05 $FF          ;repeat 6 times
		DB  $7F $01 $00 $80 $FE $FF $83 $80
		DB  $00 $30 $33 $33 $11 $98 $D8 $3C
		DB  $3F $3F $07 $00 $00 $30 $3F $FF
		DB  $83 $80 $00 $30 $33 $33 $11 $98
		DB  $D8 $FC $FF
		DB  DISP_ESC_START $03 $C7          ;repeat 4 times
		DB  $47 $01 $00 $80 $FE
		DB  DISP_ESC_START $08 $FF          ;repeat 9 times
		DB  DISP_ESC_START $0A $00          ;repeat 11 times
		DB  $FF $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 7:
		DB  $B7 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $2C $FF          ;repeat 45 times
		DB  DISP_ESC_START $08 $F8          ;repeat 9 times
		DB  DISP_ESC_START $07 $FF          ;repeat 8 times
		DB  $F8 $F8 $F8
		DB  DISP_ESC_START $0D $FF          ;repeat 14 times
		DB  $F8 $F8 $F8 $FE
		DB  DISP_ESC_START $0B $FF          ;repeat 12 times
		DB  DISP_ESC_START $08 $F8          ;repeat 9 times
		DB  DISP_ESC_START $09 $FF          ;repeat 10 times
		DB  $E0 $C0 $C0 $C0 $E0 $E0 $F0 $F0
		DB  $F8 $F8 $FC $FC $FE $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
#emac
;Size = 348 bytes
#endif
