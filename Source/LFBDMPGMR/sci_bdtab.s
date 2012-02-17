;###############################################################################
;# S12CBase - SCI Baud Detection Search Trees                                  #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
;#    This file is part of the OpenBDM BDM pod firmware.                       #
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
;#    This file contains the two search trees which are required for the SCI   #
;#    modules baud rate detection.                                             #
;#    One is used to determine the set of baud rates that are valid for a      #
;#    certain high pulse.                                                      #
;#    The other one is used to determine the set of baud rates that are valid  #
;#    for a certain low pulse.                                                 #
;#                                                                             #
;#    Each table assigs a set of valid baud rates to a range of pulse lengths. #
;#    lower boundary <= pulse length < upper boundary -> set of baud rates     #
;#                                                                             #
;#    The format of a node entry is the following:                             #
;#                                                                             #
;#                      +--------+--------+                                    #
;#    start of entry -> | lower boundary  | value of lower boundary            #
;#                      +--------+--------+                                    #
;#                      |  BRs   |  BRs   | set of boud rates - twice          #
;#                      +--------+--------+                                    #
;#                      |  node pointer   | pointer to node with longer        #
;#                      +--------+--------+ boundary value                     #
;#    node node with -> | lower boundary  |                                    #
;#    even lower        +--------+--------+                                    #
;#    boundary value    |  BRs   |  BRs   |                                    #
;#                      +--------+--------+                                    #
;#                      |  node pointer   |                                    #
;#                      +--------+--------+                                    #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    14 May, 2009                                                             #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Low pulses                                                                  #
;###############################################################################
;#
;#                                                    53211   
;#                                                    78894974
;#                                                    64824628
;#                                                    00000000
;# Range                                              00000000
;# -----------------------------------------------------------
;#    415 <= pulse <    454 [   19F,   1C6]           X.......
;#    454 <= pulse <    623 [   1C6,   26F]           ........
;#    623 <= pulse <    680 [   26F,   2A8]           .X......
;#    680 <= pulse <    831 [   2A8,   33F]           ........
;#    831 <= pulse <    907 [   33F,   38B]           X.X.....
;#    907 <= pulse <   1247 [   38B,   4DF]           ........
;#   1247 <= pulse <   1360 [   4DF,   550]           XX.X....
;#   1360 <= pulse <   1663 [   550,   67F]           ........
;#   1663 <= pulse <   1670 [   67F,   686]           X.X.....
;#   1670 <= pulse <   1813 [   686,   715]           X.X.X...
;#   1813 <= pulse <   1821 [   715,   71D]           ....X...
;#   1821 <= pulse <   1871 [   71D,   74F]           ........
;#   1871 <= pulse <   2039 [   74F,   7F7]           .X......
;#   2039 <= pulse <   2079 [   7F7,   81F]           ........
;#   2079 <= pulse <   2266 [   81F,   8DA]           X.......
;#   2266 <= pulse <   2494 [   8DA,   9BE]           ........
;#   2494 <= pulse <   2502 [   9BE,   9C6]           XXXX....
;#   2502 <= pulse <   2719 [   9C6,   A9F]           XXXX.X..
;#   2719 <= pulse <   2727 [   A9F,   AA7]           .....X..
;#   2727 <= pulse <   2910 [   AA7,   B5E]           ........
;#   2910 <= pulse <   3118 [   B5E,   C2E]           X.......
;#   3118 <= pulse <   3172 [   C2E,   C64]           XX......
;#   3172 <= pulse <   3326 [   C64,   CFE]           .X......
;#   3326 <= pulse <   3341 [   CFE,   D0D]           XXX.....
;#   3341 <= pulse <   3398 [   D0D,   D46]           XXX.X.X.
;#   3398 <= pulse <   3625 [   D46,   E29]           X.X.X.X.
;#   3625 <= pulse <   3641 [   E29,   E39]           ....X.X.
;#   3641 <= pulse <   3742 [   E39,   E9E]           ........
;#   3742 <= pulse <   4078 [   E9E,   FEE]           XX.X....
;#   4078 <= pulse <   4158 [   FEE,  103E]           ........
;#   4158 <= pulse <   4365 [  103E,  110D]           ..X.....
;#   4365 <= pulse <   4531 [  110D,  11B3]           .XX.....
;#   4531 <= pulse <   4757 [  11B3,  1295]           .X......
;#   4757 <= pulse <   4989 [  1295,  137D]           ........
;#   4989 <= pulse <   5005 [  137D,  138D]           .XXX....
;#   5005 <= pulse <   5012 [  138D,  1394]           .XXX.X..
;#   5012 <= pulse <   5437 [  1394,  153D]           .XXXXX.X
;#   5437 <= pulse <   5453 [  153D,  154D]           ....XX.X
;#   5453 <= pulse <   5462 [  154D,  1556]           ....X..X
;#   5462 <= pulse <   5613 [  1556,  15ED]           ........
;#   5613 <= pulse <   5821 [  15ED,  16BD]           .X......
;#   5821 <= pulse <   6116 [  16BD,  17E4]           .XX.....
;#   6116 <= pulse <   6237 [  17E4,  185D]           ..X.....
;#   6237 <= pulse <   6343 [  185D,  18C7]           ..XX....
;#   6343 <= pulse <   6652 [  18C7,  19FC]           ...X....
;#   6652 <= pulse <   6683 [  19FC,  1A1B]           ..XX....
;#   6683 <= pulse <   6796 [  1A1B,  1A8C]           ..XXX.X.
;#   6796 <= pulse <   7249 [  1A8C,  1C51]           ..X.X.X.
;#   7249 <= pulse <   7282 [  1C51,  1C72]           ....X.X.
;#   7282 <= pulse <   7484 [  1C72,  1D3C]           ........
;#   7484 <= pulse <   7507 [  1D3C,  1D53]           ..XX....
;#   7507 <= pulse <   8155 [  1D53,  1FDB]           ..XX.X..
;#   8155 <= pulse <   8180 [  1FDB,  1FF4]           .....X..
;#   8180 <= pulse <   8354 [  1FF4,  20A2]           ........
;#   8354 <= pulse <   8731 [  20A2,  221B]           ....X...
;#   8731 <= pulse <   9102 [  221B,  238E]           ...XX...
;#   9102 <= pulse <   9514 [  238E,  252A]           ...X....
;#   9514 <= pulse <   9979 [  252A,  26FB]           ........
;#   9979 <= pulse <  10010 [  26FB,  271A]           ...X....
;#  10010 <= pulse <  10025 [  271A,  2729]           ...X.X..
;#  10025 <= pulse <  10873 [  2729,  2A79]           ...XXXXX
;#  10873 <= pulse <  10906 [  2A79,  2A9A]           ....XXXX
;#  10906 <= pulse <  10923 [  2A9A,  2AAB]           ....X.XX
;#  10923 <= pulse <  11226 [  2AAB,  2BDA]           ........
;#  11226 <= pulse <  11696 [  2BDA,  2DB0]           ...X....
;#  11696 <= pulse <  12232 [  2DB0,  2FC8]           ...XX...
;#  12232 <= pulse <  12512 [  2FC8,  30E0]           ....X...
;#  12512 <= pulse <  12743 [  30E0,  31C7]           ....XX..
;#  12743 <= pulse <  13367 [  31C7,  3437]           .....X..
;#  13367 <= pulse <  13632 [  3437,  3540]           ....XXX.
;#  13632 <= pulse <  14564 [  3540,  38E4]           ....X.X.
;#  14564 <= pulse <  15015 [  38E4,  3AA7]           ........
;#  15015 <= pulse <  15038 [  3AA7,  3ABE]           .....X..
;#  15038 <= pulse <  16359 [  3ABE,  3FE7]           ....XX.X
;#  16359 <= pulse <  16384 [  3FE7,  4000]           ....X..X
;#  16384 <= pulse <  16709 [  4000,  4145]           ........
;#  16709 <= pulse <  17517 [  4145,  446D]           ......X.
;#  17517 <= pulse <  18204 [  446D,  471C]           .....XX.
;#  18204 <= pulse <  19085 [  471C,  4A8D]           .....X..
;#  19085 <= pulse <  20020 [  4A8D,  4E34]           ........
;#  20020 <= pulse <  20050 [  4E34,  4E52]           .....X..
;#  20050 <= pulse <  21812 [  4E52,  5534]           .....XXX
;#  21812 <= pulse <  21845 [  5534,  5555]           ......XX
;#  21845 <= pulse <  22522 [  5555,  57FA]           ........
;#  22522 <= pulse <  23392 [  57FA,  5B60]           .....X..
;#  23392 <= pulse <  24538 [  5B60,  5FDA]           .....XX.
;#  24538 <= pulse <  25063 [  5FDA,  61E7]           ......X.
;#  25063 <= pulse <  25486 [  61E7,  638E]           ......XX
;#  25486 <= pulse <  26734 [  638E,  686E]           .......X
;#  26734 <= pulse <  27306 [  686E,  6AAA]           ......XX
;#  27306 <= pulse <  29127 [  6AAA,  71C7]           ......X.
;#  29127 <= pulse <  30076 [  71C7,  757C]           ........
;#  30076 <= pulse <  32768 [  757C,  8000]           ......XX
;#  32768 <= pulse <  35088 [  8000,  8910]           ........
;#  35088 <= pulse <  38229 [  8910,  9555]           .......X
;#  38229 <= pulse <  40101 [  9555,  9CA5]           ........
;#  40101 <= pulse <  43690 [  9CA5,  AAAA]           .......X
;#  43690 <= pulse <  45114 [  AAAA,  B03A]           ........
;#  45114 <= pulse <  49151 [  B03A,  BFFF]           .......X
;#  49151 <= pulse          [  BFFF,   ...]           ........


SCI_LT_CNT	EQU	$01


SCI_LT0		EQU	*
SCI_LT0_32	DW	$1D3C %00110000_00110000 SCI_LT0_4B	;pulse >=  7484 cycs
SCI_LT0_19	DW	$0D46 %10101010_10101010 SCI_LT0_26	;pulse >=  3398 cycs
SCI_LT0_0C	DW	$074F %01000000_01000000 SCI_LT0_13	;pulse >=  1871 cycs
SCI_LT0_06	DW	$04DF %11010000_11010000 SCI_LT0_09	;pulse >=  1247 cycs
SCI_LT0_03	DW	$02A8 %00000000_00000000 SCI_LT0_05	;pulse >=   680 cycs
SCI_LT0_01	DW	$01C6 %00000000_00000000 SCI_LT0_02	;pulse >=   454 cycs
SCI_LT0_00	DW	$019F %10000000_10000000 $0000		;pulse >=   415 cycs
		DW	$0000
SCI_LT0_02	DW	$026F %01000000_01000000 $0000		;pulse >=   623 cycs
		DW	$0000
SCI_LT0_05	DW	$038B %00000000_00000000 $0000		;pulse >=   907 cycs
SCI_LT0_04	DW	$033F %10100000_10100000 $0000		;pulse >=   831 cycs
		DW	$0000
SCI_LT0_09	DW	$0686 %10101000_10101000 SCI_LT0_0B	;pulse >=  1670 cycs
SCI_LT0_08	DW	$067F %10100000_10100000 $0000		;pulse >=  1663 cycs
SCI_LT0_07	DW	$0550 %00000000_00000000 $0000		;pulse >=  1360 cycs
		DW	$0000
SCI_LT0_0B	DW	$071D %00000000_00000000 $0000		;pulse >=  1821 cycs
SCI_LT0_0A	DW	$0715 %00001000_00001000 $0000		;pulse >=  1813 cycs
		DW	$0000
SCI_LT0_13	DW	$0AA7 %00000000_00000000 SCI_LT0_16	;pulse >=  2727 cycs
SCI_LT0_10	DW	$09BE %11110000_11110000 SCI_LT0_12	;pulse >=  2494 cycs
SCI_LT0_0E	DW	$081F %10000000_10000000 SCI_LT0_0F	;pulse >=  2079 cycs
SCI_LT0_0D	DW	$07F7 %00000000_00000000 $0000		;pulse >=  2039 cycs
		DW	$0000
SCI_LT0_0F	DW	$08DA %00000000_00000000 $0000		;pulse >=  2266 cycs
		DW	$0000
SCI_LT0_12	DW	$0A9F %00000100_00000100 $0000		;pulse >=  2719 cycs
SCI_LT0_11	DW	$09C6 %11110100_11110100 $0000		;pulse >=  2502 cycs
		DW	$0000
SCI_LT0_16	DW	$0C64 %01000000_01000000 SCI_LT0_18	;pulse >=  3172 cycs
SCI_LT0_15	DW	$0C2E %11000000_11000000 $0000		;pulse >=  3118 cycs
SCI_LT0_14	DW	$0B5E %10000000_10000000 $0000		;pulse >=  2910 cycs
		DW	$0000
SCI_LT0_18	DW	$0D0D %11101010_11101010 $0000		;pulse >=  3341 cycs
SCI_LT0_17	DW	$0CFE %11100000_11100000 $0000		;pulse >=  3326 cycs
		DW	$0000
SCI_LT0_26	DW	$154D %00001001_00001001 SCI_LT0_2C	;pulse >=  5453 cycs
SCI_LT0_20	DW	$11B3 %01000000_01000000 SCI_LT0_23	;pulse >=  4531 cycs
SCI_LT0_1D	DW	$0FEE %00000000_00000000 SCI_LT0_1F	;pulse >=  4078 cycs
SCI_LT0_1B	DW	$0E39 %00000000_00000000 SCI_LT0_1C	;pulse >=  3641 cycs
SCI_LT0_1A	DW	$0E29 %00001010_00001010 $0000		;pulse >=  3625 cycs
		DW	$0000
SCI_LT0_1C	DW	$0E9E %11010000_11010000 $0000		;pulse >=  3742 cycs
		DW	$0000
SCI_LT0_1F	DW	$110D %01100000_01100000 $0000		;pulse >=  4365 cycs
SCI_LT0_1E	DW	$103E %00100000_00100000 $0000		;pulse >=  4158 cycs
		DW	$0000
SCI_LT0_23	DW	$138D %01110100_01110100 SCI_LT0_25	;pulse >=  5005 cycs
SCI_LT0_22	DW	$137D %01110000_01110000 $0000		;pulse >=  4989 cycs
SCI_LT0_21	DW	$1295 %00000000_00000000 $0000		;pulse >=  4757 cycs
		DW	$0000
SCI_LT0_25	DW	$153D %00001101_00001101 $0000		;pulse >=  5437 cycs
SCI_LT0_24	DW	$1394 %01111101_01111101 $0000		;pulse >=  5012 cycs
		DW	$0000
SCI_LT0_2C	DW	$18C7 %00010000_00010000 SCI_LT0_2F	;pulse >=  6343 cycs
SCI_LT0_29	DW	$16BD %01100000_01100000 SCI_LT0_2B	;pulse >=  5821 cycs
SCI_LT0_28	DW	$15ED %01000000_01000000 $0000		;pulse >=  5613 cycs
SCI_LT0_27	DW	$1556 %00000000_00000000 $0000		;pulse >=  5462 cycs
		DW	$0000
SCI_LT0_2B	DW	$185D %00110000_00110000 $0000		;pulse >=  6237 cycs
SCI_LT0_2A	DW	$17E4 %00100000_00100000 $0000		;pulse >=  6116 cycs
		DW	$0000
SCI_LT0_2F	DW	$1A8C %00101010_00101010 SCI_LT0_31	;pulse >=  6796 cycs
SCI_LT0_2E	DW	$1A1B %00111010_00111010 $0000		;pulse >=  6683 cycs
SCI_LT0_2D	DW	$19FC %00110000_00110000 $0000		;pulse >=  6652 cycs
		DW	$0000
SCI_LT0_31	DW	$1C72 %00000000_00000000 $0000		;pulse >=  7282 cycs
SCI_LT0_30	DW	$1C51 %00001010_00001010 $0000		;pulse >=  7249 cycs
		DW	$0000
SCI_LT0_4B	DW	$4000 %00000000_00000000 SCI_LT0_58	;pulse >= 16384 cycs
SCI_LT0_3F	DW	$2AAB %00000000_00000000 SCI_LT0_45	;pulse >= 10923 cycs
SCI_LT0_39	DW	$252A %00000000_00000000 SCI_LT0_3C	;pulse >=  9514 cycs
SCI_LT0_36	DW	$20A2 %00001000_00001000 SCI_LT0_38	;pulse >=  8354 cycs
SCI_LT0_34	DW	$1FDB %00000100_00000100 SCI_LT0_35	;pulse >=  8155 cycs
SCI_LT0_33	DW	$1D53 %00110100_00110100 $0000		;pulse >=  7507 cycs
		DW	$0000
SCI_LT0_35	DW	$1FF4 %00000000_00000000 $0000		;pulse >=  8180 cycs
		DW	$0000
SCI_LT0_38	DW	$238E %00010000_00010000 $0000		;pulse >=  9102 cycs
SCI_LT0_37	DW	$221B %00011000_00011000 $0000		;pulse >=  8731 cycs
		DW	$0000
SCI_LT0_3C	DW	$2729 %00011111_00011111 SCI_LT0_3E	;pulse >= 10025 cycs
SCI_LT0_3B	DW	$271A %00010100_00010100 $0000		;pulse >= 10010 cycs
SCI_LT0_3A	DW	$26FB %00010000_00010000 $0000		;pulse >=  9979 cycs
		DW	$0000
SCI_LT0_3E	DW	$2A9A %00001011_00001011 $0000		;pulse >= 10906 cycs
SCI_LT0_3D	DW	$2A79 %00001111_00001111 $0000		;pulse >= 10873 cycs
		DW	$0000
SCI_LT0_45	DW	$3437 %00001110_00001110 SCI_LT0_48	;pulse >= 13367 cycs
SCI_LT0_42	DW	$2FC8 %00001000_00001000 SCI_LT0_44	;pulse >= 12232 cycs
SCI_LT0_41	DW	$2DB0 %00011000_00011000 $0000		;pulse >= 11696 cycs
SCI_LT0_40	DW	$2BDA %00010000_00010000 $0000		;pulse >= 11226 cycs
		DW	$0000
SCI_LT0_44	DW	$31C7 %00000100_00000100 $0000		;pulse >= 12743 cycs
SCI_LT0_43	DW	$30E0 %00001100_00001100 $0000		;pulse >= 12512 cycs
		DW	$0000
SCI_LT0_48	DW	$3AA7 %00000100_00000100 SCI_LT0_4A	;pulse >= 15015 cycs
SCI_LT0_47	DW	$38E4 %00000000_00000000 $0000		;pulse >= 14564 cycs
SCI_LT0_46	DW	$3540 %00001010_00001010 $0000		;pulse >= 13632 cycs
		DW	$0000
SCI_LT0_4A	DW	$3FE7 %00001001_00001001 $0000		;pulse >= 16359 cycs
SCI_LT0_49	DW	$3ABE %00001101_00001101 $0000		;pulse >= 15038 cycs
		DW	$0000
SCI_LT0_58	DW	$638E %00000001_00000001 SCI_LT0_5E	;pulse >= 25486 cycs
SCI_LT0_52	DW	$5534 %00000011_00000011 SCI_LT0_55	;pulse >= 21812 cycs
SCI_LT0_4F	DW	$4A8D %00000000_00000000 SCI_LT0_51	;pulse >= 19085 cycs
SCI_LT0_4D	DW	$446D %00000110_00000110 SCI_LT0_4E	;pulse >= 17517 cycs
SCI_LT0_4C	DW	$4145 %00000010_00000010 $0000		;pulse >= 16709 cycs
		DW	$0000
SCI_LT0_4E	DW	$471C %00000100_00000100 $0000		;pulse >= 18204 cycs
		DW	$0000
SCI_LT0_51	DW	$4E52 %00000111_00000111 $0000		;pulse >= 20050 cycs
SCI_LT0_50	DW	$4E34 %00000100_00000100 $0000		;pulse >= 20020 cycs
		DW	$0000
SCI_LT0_55	DW	$5B60 %00000110_00000110 SCI_LT0_57	;pulse >= 23392 cycs
SCI_LT0_54	DW	$57FA %00000100_00000100 $0000		;pulse >= 22522 cycs
SCI_LT0_53	DW	$5555 %00000000_00000000 $0000		;pulse >= 21845 cycs
		DW	$0000
SCI_LT0_57	DW	$61E7 %00000011_00000011 $0000		;pulse >= 25063 cycs
SCI_LT0_56	DW	$5FDA %00000010_00000010 $0000		;pulse >= 24538 cycs
		DW	$0000
SCI_LT0_5E	DW	$8910 %00000001_00000001 SCI_LT0_61	;pulse >= 35088 cycs
SCI_LT0_5B	DW	$71C7 %00000000_00000000 SCI_LT0_5D	;pulse >= 29127 cycs
SCI_LT0_5A	DW	$6AAA %00000010_00000010 $0000		;pulse >= 27306 cycs
SCI_LT0_59	DW	$686E %00000011_00000011 $0000		;pulse >= 26734 cycs
		DW	$0000
SCI_LT0_5D	DW	$8000 %00000000_00000000 $0000		;pulse >= 32768 cycs
SCI_LT0_5C	DW	$757C %00000011_00000011 $0000		;pulse >= 30076 cycs
		DW	$0000
SCI_LT0_61	DW	$AAAA %00000000_00000000 SCI_LT0_63	;pulse >= 43690 cycs
SCI_LT0_60	DW	$9CA5 %00000001_00000001 $0000		;pulse >= 40101 cycs
SCI_LT0_5F	DW	$9555 %00000000_00000000 $0000		;pulse >= 38229 cycs
		DW	$0000
SCI_LT0_63	DW	$BFFF %00000000_00000000 $0000		;pulse >= 49151 cycs
SCI_LT0_62	DW	$B03A %00000001_00000001 $0000		;pulse >= 45114 cycs
		DW	$0000

