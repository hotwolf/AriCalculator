#ifndef	DISP_WELCOME
#define	DISP_WELCOME
;###############################################################################
;# AriCalculator - Image: Splash.data (single frame)                           #
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
;#       DISP_WELCOME_TAB:                                                     #
;#           This macro allocates a table of raw image data.                   #
;#                                                                             #
;#       DISP_WELCOME_STREAM:                                                  #
;#           This macro allocates a compressed stream of image data and        #
;#           control commands, which can be directly driven to the display     #
;#           driver.                                                           #
;###############################################################################
;# Generated on Tue, Jun 02 2015                                               #
;###############################################################################

#macro DISP_WELCOME_TAB, 0

;#Frame 0:
;#----------------------------------------------------------------------
;#Page 0:
		DB  $F8  $F8  $18  $18  $98  $98  $98  $98
		DB  $98  $98  $18  $18  $F8  $F8  $00  $00
		DB  $80  $80  $00  $00  $00  $00  $00  $00
		DB  $60  $60  $78  $78  $E0  $E0  $E0  $E0
		DB  $98  $98  $18  $18  $78  $78  $98  $98
		DB  $98  $98  $00  $00  $F8  $F8  $18  $18
		DB  $98  $98  $98  $98  $98  $98  $18  $18
		DB  $F8  $F8  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
;#Page 1:
		DB  $FF  $FF  $80  $80  $9F  $9F  $9F  $9F
		DB  $9F  $9F  $80  $80  $FF  $FF  $00  $00
		DB  $FF  $FF  $18  $18  $80  $80  $66  $66
		DB  $80  $80  $66  $66  $9F  $9F  $67  $67
		DB  $FF  $FF  $7E  $7E  $98  $98  $1F  $1F
		DB  $81  $81  $00  $00  $FF  $FF  $80  $80
		DB  $9F  $9F  $9F  $9F  $9F  $9F  $80  $80
		DB  $FF  $FF  $00  $00  $00  $00  $00  $00
		DB  $00  $80  $80  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $80
		DB  $80  $80  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
;#Page 2:
		DB  $F9  $F9  $01  $01  $79  $79  $F9  $F9
		DB  $99  $99  $F9  $F9  $99  $99  $00  $00
		DB  $67  $67  $F8  $F8  $81  $81  $FE  $FE
		DB  $E1  $E1  $E0  $E0  $81  $81  $9E  $9E
		DB  $61  $61  $F8  $F8  $79  $79  $66  $66
		DB  $E1  $E1  $60  $60  $F9  $F9  $F9  $F9
		DB  $79  $79  $19  $19  $19  $19  $01  $01
		DB  $61  $61  $00  $00  $00  $00  $00  $FC
		DB  $FF  $13  $13  $FF  $FC  $00  $F8  $F0
		DB  $18  $08  $00  $FA  $FA  $00  $7F  $FF
		DB  $80  $E3  $63  $00  $70  $F8  $88  $F8
		DB  $F8  $00  $FF  $FF  $00  $70  $F8  $88
		DB  $88  $00  $78  $F8  $80  $F8  $78  $00
		DB  $FF  $FF  $00  $70  $F8  $88  $F8  $F8
		DB  $00  $08  $FE  $FE  $08  $00  $70  $F8
		DB  $88  $F8  $70  $00  $F8  $F0  $18  $08
;#Page 3:
		DB  $79  $79  $1E  $1E  $9E  $9E  $99  $99
		DB  $07  $07  $E7  $E7  $99  $99  $FE  $FE
		DB  $60  $60  $81  $81  $19  $19  $87  $87
		DB  $81  $81  $07  $07  $19  $19  $87  $87
		DB  $E6  $E6  $01  $01  $E0  $E0  $60  $60
		DB  $7F  $7F  $66  $66  $61  $61  $E7  $E7
		DB  $60  $60  $18  $18  $F8  $F8  $06  $06
		DB  $60  $60  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
;#Page 4:
		DB  $F8  $F8  $06  $06  $61  $61  $07  $07
		DB  $E0  $E0  $19  $19  $99  $99  $61  $61
		DB  $78  $78  $61  $61  $7E  $7E  $19  $19
		DB  $F9  $F9  $E0  $E0  $E6  $E6  $9F  $9F
		DB  $FF  $FF  $98  $98  $81  $81  $78  $78
		DB  $60  $60  $7E  $7E  $E6  $E6  $7F  $7F
		DB  $E6  $E6  $E0  $E0  $F9  $F9  $06  $06
		DB  $60  $60  $00  $00  $00  $00  $00  $00
		DB  $E0  $80  $00  $00  $80  $C0  $80  $00
		DB  $80  $C0  $80  $00  $00  $80  $00  $00
		DB  $80  $00  $00  $80  $60  $00  $00  $80
		DB  $60  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
;#Page 5:
		DB  $9F  $9F  $80  $80  $86  $86  $80  $80
		DB  $9F  $9F  $9E  $9E  $99  $99  $1E  $1E
		DB  $66  $66  $1E  $1E  $E0  $E0  $78  $78
		DB  $67  $67  $07  $07  $19  $19  $99  $99
		DB  $61  $61  $79  $79  $E7  $E7  $E0  $E0
		DB  $FE  $FE  $1E  $1E  $9F  $9F  $1E  $1E
		DB  $FF  $FF  $E1  $E1  $F9  $F9  $7E  $7E
		DB  $78  $78  $00  $00  $00  $00  $00  $00
		DB  $C7  $00  $07  $00  $00  $07  $00  $00
		DB  $00  $87  $00  $00  $1F  $04  $03  $00
		DB  $04  $00  $06  $01  $00  $00  $C6  $01
		DB  $80  $40  $40  $00  $00  $00  $00  $00
		DB  $00  $00  $40  $00  $00  $80  $00  $00
		DB  $C0  $00  $00  $00  $00  $00  $00  $00
		DB  $C0  $00  $00  $00  $00  $00  $40  $00
		DB  $00  $00  $00  $00  $00  $00  $C0  $00
;#Page 6:
		DB  $FF  $FF  $01  $01  $F9  $F9  $F9  $F9
		DB  $F9  $F9  $01  $01  $FF  $FF  $00  $00
		DB  $FE  $FE  $1E  $1E  $F9  $F9  $80  $80
		DB  $66  $66  $00  $00  $66  $66  $87  $87
		DB  $E6  $E6  $80  $80  $E1  $E1  $67  $67
		DB  $9F  $9F  $98  $98  $99  $99  $F8  $F8
		DB  $9F  $9F  $07  $07  $79  $79  $E6  $E6
		DB  $66  $66  $00  $00  $00  $00  $00  $00
		DB  $0F  $01  $8E  $00  $06  $09  $06  $00
		DB  $01  $0F  $81  $00  $07  $88  $86  $08
		DB  $07  $00  $06  $09  $06  $80  $0F  $00
		DB  $0F  $01  $01  $00  $08  $00  $26  $A9
		DB  $1E  $00  $0F  $00  $01  $0F  $01  $00
		DB  $0F  $01  $0E  $00  $07  $08  $07  $00
		DB  $0F  $09  $06  $80  $08  $00  $0F  $00
		DB  $06  $09  $06  $00  $0C  $03  $00  $00
;#Page 7:
		DB  $1F  $1F  $18  $18  $19  $19  $19  $19
		DB  $19  $19  $18  $18  $1F  $1F  $00  $00
		DB  $19  $19  $18  $18  $07  $07  $1F  $1F
		DB  $06  $06  $1E  $1E  $06  $06  $1F  $1F
		DB  $01  $01  $19  $19  $01  $01  $18  $18
		DB  $07  $07  $01  $01  $19  $19  $1F  $1F
		DB  $01  $01  $06  $06  $18  $18  $07  $07
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $1E  $05  $04  $05  $1E  $00  $1E  $04
		DB  $02  $00  $1E  $00  $0F  $10  $10  $09
		DB  $00  $0C  $12  $1E  $00  $1F  $00  $0C
		DB  $12  $12  $00  $0E  $10  $0E  $00  $1F
		DB  $00  $0C  $12  $1E  $00  $02  $1F  $02
		DB  $00  $0C  $12  $0C  $00  $1E  $04  $02
		DB  $00  $18  $06  $01  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00

#emac
;Size = 1024 bytes

#macro DISP_WELCOME_STREAM, 0

;#Frame 0:
;#----------------------------------------------------------------------
;#Page 0:
		DB  $B0 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $F8 $F8 $18 $18
		DB  DISP_ESC_START $05 $98          ;repeat 6 times
		DB  $18 $18 $F8 $F8 $00 $00 $80 $80
		DB  DISP_ESC_START $05 $00          ;repeat 6 times
		DB  $60 $60 $78 $78
		DB  DISP_ESC_START $03 $E0          ;repeat 4 times
		DB  $98 $98 $18 $18 $78 $78
		DB  DISP_ESC_START $03 $98          ;repeat 4 times
		DB  $00 $00 $F8 $F8 $18 $18
		DB  DISP_ESC_START $05 $98          ;repeat 6 times
		DB  $18 $18 $F8 $F8
		DB  DISP_ESC_START $45 $00          ;repeat 70 times
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 1:
		DB  $B1 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $FF $FF $80 $80
		DB  DISP_ESC_START $05 $9F          ;repeat 6 times
		DB  $80 $80 $FF $FF $00 $00 $FF $FF
		DB  $18 $18 $80 $80 $66 $66 $80 $80
		DB  $66 $66 $9F $9F $67 $67 $FF $FF
		DB  $7E $7E $98 $98 $1F $1F $81 $81
		DB  $00 $00 $FF $FF $80 $80
		DB  DISP_ESC_START $05 $9F          ;repeat 6 times
		DB  $80 $80 $FF $FF
		DB  DISP_ESC_START $06 $00          ;repeat 7 times
		DB  $80 $80
		DB  DISP_ESC_START $0B $00          ;repeat 12 times
		DB  $80 $80 $80
		DB  DISP_ESC_START $2D $00          ;repeat 46 times
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 2:
		DB  $B2 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $F9 $F9 $01 $01 $79 $79 $F9 $F9
		DB  $99 $99 $F9 $F9 $99 $99 $00 $00
		DB  $67 $67 $F8 $F8 $81 $81 $FE $FE
		DB  $E1 $E1 $E0 $E0 $81 $81 $9E $9E
		DB  $61 $61 $F8 $F8 $79 $79 $66 $66
		DB  $E1 $E1 $60 $60
		DB  DISP_ESC_START $03 $F9          ;repeat 4 times
		DB  $79 $79
		DB  DISP_ESC_START $03 $19          ;repeat 4 times
		DB  $01 $01 $61 $61
		DB  DISP_ESC_START $04 $00          ;repeat 5 times
		DB  $FC $FF $13 $13 $FF $FC $00 $F8
		DB  $F0 $18 $08 $00 $FA $FA $00 $7F
		DB  $FF $80
		DB  DISP_ESC_START DISP_ESC_ESC     ;escape $E3
		DB  $63 $00 $70 $F8 $88 $F8 $F8 $00
		DB  $FF $FF $00 $70 $F8 $88 $88 $00
		DB  $78 $F8 $80 $F8 $78 $00 $FF $FF
		DB  $00 $70 $F8 $88 $F8 $F8 $00 $08
		DB  $FE $FE $08 $00 $70 $F8 $88 $F8
		DB  $70 $00 $F8 $F0 $18 $08
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 3:
		DB  $B3 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $79 $79 $1E $1E $9E $9E $99 $99
		DB  $07 $07 $E7 $E7 $99 $99 $FE $FE
		DB  $60 $60 $81 $81 $19 $19 $87 $87
		DB  $81 $81 $07 $07 $19 $19 $87 $87
		DB  $E6 $E6 $01 $01 $E0 $E0 $60 $60
		DB  $7F $7F $66 $66 $61 $61 $E7 $E7
		DB  $60 $60 $18 $18 $F8 $F8 $06 $06
		DB  $60 $60
		DB  DISP_ESC_START $45 $00          ;repeat 70 times
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 4:
		DB  $B4 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $F8 $F8 $06 $06 $61 $61 $07 $07
		DB  $E0 $E0 $19 $19 $99 $99 $61 $61
		DB  $78 $78 $61 $61 $7E $7E $19 $19
		DB  $F9 $F9 $E0 $E0 $E6 $E6 $9F $9F
		DB  $FF $FF $98 $98 $81 $81 $78 $78
		DB  $60 $60 $7E $7E $E6 $E6 $7F $7F
		DB  $E6 $E6 $E0 $E0 $F9 $F9 $06 $06
		DB  $60 $60
		DB  DISP_ESC_START $05 $00          ;repeat 6 times
		DB  $E0 $80 $00 $00 $80 $C0 $80 $00
		DB  $80 $C0 $80 $00 $00 $80 $00 $00
		DB  $80 $00 $00 $80 $60 $00 $00 $80
		DB  $60
		DB  DISP_ESC_START $26 $00          ;repeat 39 times
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 5:
		DB  $B5 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $9F $9F $80 $80 $86 $86 $80 $80
		DB  $9F $9F $9E $9E $99 $99 $1E $1E
		DB  $66 $66 $1E $1E $E0 $E0 $78 $78
		DB  $67 $67 $07 $07 $19 $19 $99 $99
		DB  $61 $61 $79 $79 $E7 $E7 $E0 $E0
		DB  $FE $FE $1E $1E $9F $9F $1E $1E
		DB  $FF $FF $E1 $E1 $F9 $F9 $7E $7E
		DB  $78 $78
		DB  DISP_ESC_START $05 $00          ;repeat 6 times
		DB  $C7 $00 $07 $00 $00 $07 $00 $00
		DB  $00 $87 $00 $00 $1F $04 $03 $00
		DB  $04 $00 $06 $01 $00 $00 $C6 $01
		DB  $80 $40 $40
		DB  DISP_ESC_START $06 $00          ;repeat 7 times
		DB  $40 $00 $00 $80 $00 $00 $C0
		DB  DISP_ESC_START $06 $00          ;repeat 7 times
		DB  $C0
		DB  DISP_ESC_START $04 $00          ;repeat 5 times
		DB  $40
		DB  DISP_ESC_START $06 $00          ;repeat 7 times
		DB  $C0 $00
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 6:
		DB  $B6 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $FF $FF $01 $01
		DB  DISP_ESC_START $05 $F9          ;repeat 6 times
		DB  $01 $01 $FF $FF $00 $00 $FE $FE
		DB  $1E $1E $F9 $F9 $80 $80 $66 $66
		DB  $00 $00 $66 $66 $87 $87 $E6 $E6
		DB  $80 $80 $E1 $E1 $67 $67 $9F $9F
		DB  $98 $98 $99 $99 $F8 $F8 $9F $9F
		DB  $07 $07 $79 $79 $E6 $E6 $66 $66
		DB  DISP_ESC_START $05 $00          ;repeat 6 times
		DB  $0F $01 $8E $00 $06 $09 $06 $00
		DB  $01 $0F $81 $00 $07 $88 $86 $08
		DB  $07 $00 $06 $09 $06 $80 $0F $00
		DB  $0F $01 $01 $00 $08 $00 $26 $A9
		DB  $1E $00 $0F $00 $01 $0F $01 $00
		DB  $0F $01 $0E $00 $07 $08 $07 $00
		DB  $0F $09 $06 $80 $08 $00 $0F $00
		DB  $06 $09 $06 $00 $0C $03 $00 $00
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 7:
		DB  $B7 $10 $00                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $1F $1F $18 $18
		DB  DISP_ESC_START $05 $19          ;repeat 6 times
		DB  $18 $18 $1F $1F $00 $00 $19 $19
		DB  $18 $18 $07 $07 $1F $1F $06 $06
		DB  $1E $1E $06 $06 $1F $1F $01 $01
		DB  $19 $19 $01 $01 $18 $18 $07 $07
		DB  $01 $01 $19 $19 $1F $1F $01 $01
		DB  $06 $06 $18 $18 $07 $07
		DB  DISP_ESC_START $07 $00          ;repeat 8 times
		DB  $1E $05 $04 $05 $1E $00 $1E $04
		DB  $02 $00 $1E $00 $0F $10 $10 $09
		DB  $00 $0C $12 $1E $00 $1F $00 $0C
		DB  $12 $12 $00 $0E $10 $0E $00 $1F
		DB  $00 $0C $12 $1E $00 $02 $1F $02
		DB  $00 $0C $12 $0C $00 $1E $04 $02
		DB  $00 $18 $06 $01
		DB  DISP_ESC_START $0B $00          ;repeat 12 times
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
#emac
;Size = 799 bytes
#endif
