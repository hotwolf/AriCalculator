#ifndef	DISP_SPLASH
#define	DISP_SPLASH
;###############################################################################
;# AriCalculator - Image: Splash.raw (single frame)                            #
;###############################################################################
;#    Copyright 2012 - 2014 Dirk Heisswolf                                     #
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
;#       DISP_SPLASH_TAB:                                                      #
;#           This macro allocates a table of raw image data.                   #
;#                                                                             #
;#       DISP_SPLASH_STREAM:                                                   #
;#           This macro allocates a compressed stream of image data and        #
;#           control commands, which can be directly driven to the display     #
;#           driver.                                                           #
;###############################################################################
;# Generated on Wed, Aug 13 2014                                               #
;###############################################################################

#macro DISP_SPLASH_TAB, 0

;#Frame 0:
;#----------------------------------------------------------------------
;#Page 0:
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $80  $60  $18  $00
		DB  $40  $20  $78  $00  $30  $48  $30  $00
		DB  $40  $F8  $40  $00  $78  $48  $30  $00
		DB  $F8  $00  $70  $08  $70  $00  $48  $48
		DB  $30  $00  $F8  $00  $78  $48  $30  $00
		DB  $90  $08  $08  $F0  $00  $78  $00  $40
		DB  $20  $78  $00  $78  $A0  $20  $A0  $78
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $E0  $E0  $18  $18  $60  $60  $80  $80
		DB  $F8  $F8  $98  $98  $80  $80  $E0  $E0
		DB  $18  $18  $80  $80  $98  $98  $80  $80
		DB  $F8  $F8  $60  $60  $78  $78  $60  $60
		DB  $F8  $F8  $E0  $E0  $18  $18  $98  $98
		DB  $00  $00  $F8  $F8  $18  $18  $98  $98
		DB  $98  $98  $98  $98  $18  $18  $F8  $F8
;#Page 1:
		DB  $00  $00  $C0  $30  $00  $60  $90  $60
		DB  $00  $F0  $00  $10  $01  $60  $90  $F0
		DB  $00  $E0  $10  $E0  $00  $70  $80  $F0
		DB  $00  $80  $F0  $80  $00  $F0  $00  $78
		DB  $95  $64  $00  $10  $00  $80  $80  $F0
		DB  $00  $F0  $01  $60  $90  $60  $00  $E0
		DB  $10  $61  $11  $E0  $00  $81  $F0  $80
		DB  $00  $60  $90  $60  $00  $71  $80  $F0
		DB  $00  $00  $00  $00  $00  $00  $66  $66
		DB  $67  $67  $9E  $9E  $E0  $E0  $F9  $F9
		DB  $1F  $1F  $99  $99  $19  $19  $F9  $F9
		DB  $E6  $E6  $87  $87  $01  $01  $67  $67
		DB  $E1  $E1  $66  $66  $00  $00  $66  $66
		DB  $01  $01  $9F  $9F  $78  $78  $7F  $7F
		DB  $00  $00  $FF  $FF  $80  $80  $9F  $9F
		DB  $9F  $9F  $9F  $9F  $80  $80  $FF  $FF
;#Page 2:
		DB  $00  $03  $00  $00  $00  $00  $00  $00
		DB  $00  $02  $00  $00  $00  $00  $00  $03
		DB  $00  $00  $00  $00  $00  $00  $00  $03
		DB  $00  $00  $01  $00  $00  $02  $00  $00
		DB  $00  $00  $00  $00  $00  $02  $02  $01
		DB  $80  $63  $00  $00  $80  $60  $00  $20
		DB  $00  $C0  $20  $F8  $00  $00  $E1  $00
		DB  $00  $00  $E0  $00  $00  $E0  $00  $E3
		DB  $00  $00  $00  $00  $00  $00  $1E  $1E
		DB  $7E  $7E  $9F  $9F  $87  $87  $FF  $FF
		DB  $78  $78  $F9  $F9  $78  $78  $7F  $7F
		DB  $07  $07  $E7  $E7  $9E  $9E  $86  $86
		DB  $99  $99  $98  $98  $E0  $E0  $E6  $E6
		DB  $1E  $1E  $07  $07  $78  $78  $66  $66
		DB  $78  $78  $99  $99  $79  $79  $F9  $F9
		DB  $01  $01  $61  $61  $01  $01  $F9  $F9
;#Page 3:
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $06
		DB  $01  $00  $00  $06  $01  $00  $00  $01
		DB  $00  $00  $01  $00  $00  $01  $03  $01
		DB  $00  $01  $03  $01  $00  $00  $01  $07
		DB  $00  $00  $00  $00  $00  $00  $06  $06
		DB  $60  $60  $9F  $9F  $07  $07  $67  $67
		DB  $FE  $FE  $67  $67  $7E  $7E  $06  $06
		DB  $1E  $1E  $81  $81  $19  $19  $FF  $FF
		DB  $F9  $F9  $67  $67  $07  $07  $9F  $9F
		DB  $98  $98  $7E  $7E  $86  $86  $1E  $1E
		DB  $86  $86  $99  $99  $98  $98  $07  $07
		DB  $E0  $E0  $86  $86  $60  $60  $1F  $1F
;#Page 4:
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $06  $06
		DB  $60  $60  $1F  $1F  $18  $18  $06  $06
		DB  $E7  $E7  $86  $86  $66  $66  $FE  $FE
		DB  $06  $06  $07  $07  $80  $80  $67  $67
		DB  $E1  $E1  $98  $98  $E0  $E0  $81  $81
		DB  $E1  $E1  $98  $98  $81  $81  $06  $06
		DB  $7F  $7F  $99  $99  $E7  $E7  $E0  $E0
		DB  $99  $99  $79  $79  $78  $78  $9E  $9E
;#Page 5:
		DB  $10  $18  $0F  $1F  $00  $0E  $1F  $11
		DB  $1F  $0E  $00  $10  $7F  $7F  $10  $00
		DB  $1F  $1F  $11  $1F  $0E  $00  $FF  $FF
		DB  $00  $1E  $1F  $01  $1F  $1E  $00  $11
		DB  $11  $1F  $0E  $00  $FF  $FF  $00  $1F
		DB  $1F  $11  $1F  $0E  $00  $C6  $C7  $01
		DB  $FF  $FE  $00  $5F  $5F  $00  $10  $18
		DB  $0F  $1F  $00  $3F  $FF  $C8  $C8  $FF
		DB  $3F  $00  $00  $00  $00  $00  $86  $86
		DB  $80  $80  $98  $98  $98  $98  $9E  $9E
		DB  $9F  $9F  $9F  $9F  $06  $06  $87  $87
		DB  $66  $66  $9E  $9E  $1F  $1F  $86  $86
		DB  $79  $79  $81  $81  $07  $07  $87  $87
		DB  $7F  $7F  $81  $81  $1F  $1F  $E6  $E6
		DB  $00  $00  $99  $99  $9F  $9F  $99  $99
		DB  $9F  $9F  $9E  $9E  $80  $80  $9F  $9F
;#Page 6:
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $01  $01
		DB  $01  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $01  $01  $00
		DB  $00  $00  $00  $00  $00  $00  $FF  $FF
		DB  $01  $01  $F9  $F9  $F9  $F9  $F9  $F9
		DB  $01  $01  $FF  $FF  $00  $00  $81  $81
		DB  $F8  $F8  $19  $19  $7E  $7E  $FF  $FF
		DB  $E6  $E6  $F9  $F9  $66  $66  $01  $01
		DB  $66  $66  $01  $01  $18  $18  $FF  $FF
		DB  $00  $00  $FF  $FF  $01  $01  $F9  $F9
		DB  $F9  $F9  $F9  $F9  $01  $01  $FF  $FF
;#Page 7:
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $00  $00
		DB  $00  $00  $00  $00  $00  $00  $1F  $1F
		DB  $18  $18  $19  $19  $19  $19  $19  $19
		DB  $18  $18  $1F  $1F  $00  $00  $19  $19
		DB  $19  $19  $1E  $1E  $18  $18  $19  $19
		DB  $07  $07  $07  $07  $1E  $1E  $06  $06
		DB  $00  $00  $00  $00  $00  $00  $01  $01
		DB  $00  $00  $1F  $1F  $18  $18  $19  $19
		DB  $19  $19  $19  $19  $18  $18  $1F  $1F

#emac
;Size = 1024 bytes

#macro DISP_SPLASH_STREAM, 0

;#Frame 0:
;#----------------------------------------------------------------------
;#Page 0:
		DB  $B0 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $0C $00          ;repeat 12 times
		DB  $80 $60 $18 $00 $40 $20 $78 $00
		DB  $30 $48 $30 $00 $40 $F8 $40 $00
		DB  $78 $48 $30 $00 $F8 $00 $70 $08
		DB  $70 $00 $48 $48 $30 $00 $F8 $00
		DB  $78 $48 $30 $00 $90 $08 $08 $F0
		DB  $00 $78 $00 $40 $20 $78 $00 $78
		DB  $A0 $20 $A0 $78
		DB  DISP_ESC_START $08 $00          ;repeat 8 times
		DB  $E0 $E0 $18 $18 $60 $60 $80 $80
		DB  $F8 $F8 $98 $98 $80 $80 $E0 $E0
		DB  $18 $18 $80 $80 $98 $98 $80 $80
		DB  $F8 $F8 $60 $60 $78 $78 $60 $60
		DB  $F8 $F8 $E0 $E0 $18 $18 $98 $98
		DB  $00 $00 $F8 $F8 $18 $18
		DB  DISP_ESC_START $06 $98          ;repeat 6 times
		DB  $18 $18 $F8 $F8
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 1:
		DB  $B1 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $00 $00 $C0 $30 $00 $60 $90 $60
		DB  $00 $F0 $00 $10 $01 $60 $90 $F0
		DB  $00 $E0 $10 $E0 $00 $70 $80 $F0
		DB  $00 $80 $F0 $80 $00 $F0 $00 $78
		DB  $95 $64 $00 $10 $00 $80 $80 $F0
		DB  $00 $F0 $01 $60 $90 $60 $00 $E0
		DB  $10 $61 $11 $E0 $00 $81 $F0 $80
		DB  $00 $60 $90 $60 $00 $71 $80 $F0
		DB  DISP_ESC_START $06 $00          ;repeat 6 times
		DB  $66 $66 $67 $67 $9E $9E $E0 $E0
		DB  $F9 $F9 $1F $1F $99 $99 $19 $19
		DB  $F9 $F9 $E6 $E6 $87 $87 $01 $01
		DB  $67 $67 $E1 $E1 $66 $66 $00 $00
		DB  $66 $66 $01 $01 $9F $9F $78 $78
		DB  $7F $7F $00 $00 $FF $FF $80 $80
		DB  DISP_ESC_START $06 $9F          ;repeat 6 times
		DB  $80 $80 $FF $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 2:
		DB  $B2 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $00 $03
		DB  DISP_ESC_START $07 $00          ;repeat 7 times
		DB  $02
		DB  DISP_ESC_START $05 $00          ;repeat 5 times
		DB  $03
		DB  DISP_ESC_START $07 $00          ;repeat 7 times
		DB  $03 $00 $00 $01 $00 $00 $02
		DB  DISP_ESC_START $07 $00          ;repeat 7 times
		DB  $02 $02 $01 $80 $63 $00 $00 $80
		DB  $60 $00 $20 $00 $C0 $20 $F8 $00
		DB  $00 $E1 $00 $00 $00 $E0 $00 $00
		DB  $E0 $00
		DB  DISP_ESC_START DISP_ESC_ESC     ;escape $E3
		DB  DISP_ESC_START $06 $00          ;repeat 6 times
		DB  $1E $1E $7E $7E $9F $9F $87 $87
		DB  $FF $FF $78 $78 $F9 $F9 $78 $78
		DB  $7F $7F $07 $07 $E7 $E7 $9E $9E
		DB  $86 $86 $99 $99 $98 $98 $E0 $E0
		DB  $E6 $E6 $1E $1E $07 $07 $78 $78
		DB  $66 $66 $78 $78 $99 $99 $79 $79
		DB  $F9 $F9 $01 $01 $61 $61 $01 $01
		DB  $F9 $F9
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 3:
		DB  $B3 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $27 $00          ;repeat 39 times
		DB  $06 $01 $00 $00 $06 $01 $00 $00
		DB  $01 $00 $00 $01 $00 $00 $01 $03
		DB  $01 $00 $01 $03 $01 $00 $00 $01
		DB  $07
		DB  DISP_ESC_START $06 $00          ;repeat 6 times
		DB  $06 $06 $60 $60 $9F $9F $07 $07
		DB  $67 $67 $FE $FE $67 $67 $7E $7E
		DB  $06 $06 $1E $1E $81 $81 $19 $19
		DB  $FF $FF $F9 $F9 $67 $67 $07 $07
		DB  $9F $9F $98 $98 $7E $7E $86 $86
		DB  $1E $1E $86 $86 $99 $99 $98 $98
		DB  $07 $07 $E0 $E0 $86 $86 $60 $60
		DB  $1F $1F
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 4:
		DB  $B4 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $46 $00          ;repeat 70 times
		DB  $06 $06 $60 $60 $1F $1F $18 $18
		DB  $06 $06 $E7 $E7 $86 $86 $66 $66
		DB  $FE $FE $06 $06 $07 $07 $80 $80
		DB  $67 $67 $E1 $E1 $98 $98 $E0 $E0
		DB  $81 $81 $E1 $E1 $98 $98 $81 $81
		DB  $06 $06 $7F $7F $99 $99 $E7 $E7
		DB  $E0 $E0 $99 $99 $79 $79 $78 $78
		DB  $9E $9E
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 5:
		DB  $B5 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  $10 $18 $0F $1F $00 $0E $1F $11
		DB  $1F $0E $00 $10 $7F $7F $10 $00
		DB  $1F $1F $11 $1F $0E $00 $FF $FF
		DB  $00 $1E $1F $01 $1F $1E $00 $11
		DB  $11 $1F $0E $00 $FF $FF $00 $1F
		DB  $1F $11 $1F $0E $00 $C6 $C7 $01
		DB  $FF $FE $00 $5F $5F $00 $10 $18
		DB  $0F $1F $00 $3F $FF $C8 $C8 $FF
		DB  $3F
		DB  DISP_ESC_START $05 $00          ;repeat 5 times
		DB  $86 $86 $80 $80
		DB  DISP_ESC_START $04 $98          ;repeat 4 times
		DB  $9E $9E
		DB  DISP_ESC_START $04 $9F          ;repeat 4 times
		DB  $06 $06 $87 $87 $66 $66 $9E $9E
		DB  $1F $1F $86 $86 $79 $79 $81 $81
		DB  $07 $07 $87 $87 $7F $7F $81 $81
		DB  $1F $1F $E6 $E6 $00 $00 $99 $99
		DB  $9F $9F $99 $99 $9F $9F $9E $9E
		DB  $80 $80 $9F $9F
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 6:
		DB  $B6 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $2E $00          ;repeat 46 times
		DB  $01 $01 $01
		DB  DISP_ESC_START $0C $00          ;repeat 12 times
		DB  $01 $01
		DB  DISP_ESC_START $07 $00          ;repeat 7 times
		DB  $FF $FF $01 $01
		DB  DISP_ESC_START $06 $F9          ;repeat 6 times
		DB  $01 $01 $FF $FF $00 $00 $81 $81
		DB  $F8 $F8 $19 $19 $7E $7E $FF $FF
		DB  $E6 $E6 $F9 $F9 $66 $66 $01 $01
		DB  $66 $66 $01 $01 $18 $18 $FF $FF
		DB  $00 $00 $FF $FF $01 $01
		DB  DISP_ESC_START $06 $F9          ;repeat 6 times
		DB  $01 $01 $FF $FF
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
;#Page 7:
		DB  $B7 $10 $04                     ;set page and column address
		DB  DISP_ESC_START DISP_ESC_DATA    ;switch to data input
		DB  DISP_ESC_START $46 $00          ;repeat 70 times
		DB  $1F $1F $18 $18
		DB  DISP_ESC_START $06 $19          ;repeat 6 times
		DB  $18 $18 $1F $1F $00 $00
		DB  DISP_ESC_START $04 $19          ;repeat 4 times
		DB  $1E $1E $18 $18 $19 $19
		DB  DISP_ESC_START $04 $07          ;repeat 4 times
		DB  $1E $1E $06 $06
		DB  DISP_ESC_START $06 $00          ;repeat 6 times
		DB  $01 $01 $00 $00 $1F $1F $18 $18
		DB  DISP_ESC_START $06 $19          ;repeat 6 times
		DB  $18 $18 $1F $1F
		DB  DISP_ESC_START DISP_ESC_CMD     ;switch to command input
#emac
;Size = 799 bytes
#endif
