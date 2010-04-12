;###############################################################################
;# S12CBase - SCI -SCI Baud Detection Search Trees                             #
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
;# High pulses                                                                 #
;###############################################################################
;#
;#                                                    11      
;#                                                    517531  
;#                                                    35678994
;#                                                    62864268
;#                                                    00000000
;# Range                                              00000000
;# -----------------------------------------------------------
;#    154 <= pulse <    200 [    9A,    C8]           X.......
;#    200 <= pulse <    308 [    C8,   134]           XX......
;#    308 <= pulse <    415 [   134,   19F]           XXX.....
;#    415 <= pulse <    616 [   19F,   268]           XXXX....
;#    616 <= pulse <   1232 [   268,   4D0]           XXXXX...
;#   1232 <= pulse <   2464 [   4D0,   9A0]           XXXXXX..
;#   2464 <= pulse <   4928 [   9A0,  1340]           XXXXXXX.
;#   4928 <= pulse          [  1340,   ...]           XXXXXXXX


SCI_HT_CNT	EQU	$01


SCI_HT0		EQU	*
SCI_HT0_04	DW	$0268 %11111000_11111000 SCI_HT0_06	;pulse >=   616 cycs
SCI_HT0_02	DW	$0134 %11100000_11100000 SCI_HT0_03	;pulse >=   308 cycs
SCI_HT0_01	DW	$00C8 %11000000_11000000 $0000		;pulse >=   200 cycs
SCI_HT0_00	DW	$009A %10000000_10000000 $0000		;pulse >=   154 cycs
		DW	$0000
SCI_HT0_03	DW	$019F %11110000_11110000 $0000		;pulse >=   415 cycs
		DW	$0000
SCI_HT0_06	DW	$09A0 %11111110_11111110 SCI_HT0_07	;pulse >=  2464 cycs
SCI_HT0_05	DW	$04D0 %11111100_11111100 $0000		;pulse >=  1232 cycs
		DW	$0000
SCI_HT0_07	DW	$1340 %11111111_11111111 $0000		;pulse >=  4928 cycs
		DW	$0000

;###############################################################################
;# Low pulses                                                                  #
;###############################################################################
;#
;#                                                    11      
;#                                                    517531  
;#                                                    35678994
;#                                                    62864268
;#                                                    00000000
;# Range                                              00000000
;# -----------------------------------------------------------
;#    154 <= pulse <    168 [    9A,    A8]           X.......
;#    168 <= pulse <    200 [    A8,    C8]           ........
;#    200 <= pulse <    219 [    C8,    DB]           .X......
;#    219 <= pulse <    308 [    DB,   134]           ........
;#    308 <= pulse <    336 [   134,   150]           X.X.....
;#    336 <= pulse <    400 [   150,   190]           ........
;#    400 <= pulse <    415 [   190,   19F]           .X......
;#    415 <= pulse <    437 [   19F,   1B5]           .X.X....
;#    437 <= pulse <    454 [   1B5,   1C6]           ...X....
;#    454 <= pulse <    462 [   1C6,   1CE]           ........
;#    462 <= pulse <    504 [   1CE,   1F8]           X.......
;#    504 <= pulse <    600 [   1F8,   258]           ........
;#    600 <= pulse <    616 [   258,   268]           .X......
;#    616 <= pulse <    655 [   268,   28F]           XXX.X...
;#    655 <= pulse <    672 [   28F,   2A0]           X.X.X...
;#    672 <= pulse <    770 [   2A0,   302]           ........
;#    770 <= pulse <    800 [   302,   320]           X.......
;#    800 <= pulse <    831 [   320,   33F]           XX......
;#    831 <= pulse <    839 [   33F,   347]           XX.X....
;#    839 <= pulse <    873 [   347,   369]           .X.X....
;#    873 <= pulse <    907 [   369,   38B]           ...X....
;#    907 <= pulse <    924 [   38B,   39C]           ........
;#    924 <= pulse <   1001 [   39C,   3E9]           X.X.....
;#   1001 <= pulse <   1007 [   3E9,   3EF]           XXX.....
;#   1007 <= pulse <   1078 [   3EF,   436]           .X......
;#   1078 <= pulse <   1091 [   436,   443]           XX......
;#   1091 <= pulse <   1175 [   443,   497]           X.......
;#   1175 <= pulse <   1201 [   497,   4B1]           ........
;#   1201 <= pulse <   1232 [   4B1,   4D0]           .X......
;#   1232 <= pulse <   1247 [   4D0,   4DF]           XXX.XX..
;#   1247 <= pulse <   1309 [   4DF,   51D]           XXXXXX..
;#   1309 <= pulse <   1343 [   51D,   53F]           X.XXXX..
;#   1343 <= pulse <   1360 [   53F,   550]           ...X....
;#   1360 <= pulse <   1386 [   550,   56A]           ........
;#   1386 <= pulse <   1401 [   56A,   579]           X.......
;#   1401 <= pulse <   1511 [   579,   5E7]           XX......
;#   1511 <= pulse <   1527 [   5E7,   5F7]           .X......
;#   1527 <= pulse <   1540 [   5F7,   604]           ........
;#   1540 <= pulse <   1601 [   604,   641]           ..X.....
;#   1601 <= pulse <   1663 [   641,   67F]           .XX.....
;#   1663 <= pulse <   1678 [   67F,   68E]           .XXX....
;#   1678 <= pulse <   1745 [   68E,   6D1]           .X.X....
;#   1745 <= pulse <   1801 [   6D1,   709]           ...X....
;#   1801 <= pulse <   1813 [   709,   715]           .X.X....
;#   1813 <= pulse <   1848 [   715,   738]           .X......
;#   1848 <= pulse <   1964 [   738,   7AC]           .XX.X...
;#   1964 <= pulse <   2014 [   7AC,   7DE]           ..X.X...
;#   2014 <= pulse <   2079 [   7DE,   81F]           ........
;#   2079 <= pulse <   2156 [   81F,   86C]           ...X....
;#   2156 <= pulse <   2266 [   86C,   8DA]           ..XX....
;#   2266 <= pulse <   2349 [   8DA,   92D]           ..X.....
;#   2349 <= pulse <   2464 [   92D,   9A0]           ........
;#   2464 <= pulse <   2494 [   9A0,   9BE]           ..X.XXX.
;#   2494 <= pulse <   2685 [   9BE,   A7D]           ..XXXXX.
;#   2685 <= pulse <   2719 [   A7D,   A9F]           ...X....
;#   2719 <= pulse <   2772 [   A9F,   AD4]           ........
;#   2772 <= pulse <   2910 [   AD4,   B5E]           ..X.....
;#   2910 <= pulse <   3021 [   B5E,   BCD]           ..XX....
;#   3021 <= pulse <   3080 [   BCD,   C08]           ...X....
;#   3080 <= pulse <   3172 [   C08,   C64]           ...XX...
;#   3172 <= pulse <   3326 [   C64,   CFE]           ....X...
;#   3326 <= pulse <   3356 [   CFE,   D1C]           ...XX...
;#   3356 <= pulse <   3625 [   D1C,   E29]           ...X....
;#   3625 <= pulse <   3696 [   E29,   E70]           ........
;#   3696 <= pulse <   3742 [   E70,   E9E]           ....XX..
;#   3742 <= pulse <   4027 [   E9E,   FBB]           ...XXX..
;#   4027 <= pulse <   4078 [   FBB,   FEE]           ...X....
;#   4078 <= pulse <   4312 [   FEE,  10D8]           ........
;#   4312 <= pulse <   4698 [  10D8,  125A]           ....X...
;#   4698 <= pulse <   4928 [  125A,  1340]           ........
;#   4928 <= pulse <   5369 [  1340,  14F9]           ....XXXX
;#   5369 <= pulse <   5544 [  14F9,  15A8]           ........
;#   5544 <= pulse <   6041 [  15A8,  1799]           ....X...
;#   6041 <= pulse <   6160 [  1799,  1810]           ........
;#   6160 <= pulse <   6712 [  1810,  1A38]           .....X..
;#   6712 <= pulse <   7392 [  1A38,  1CE0]           ........
;#   7392 <= pulse <   8054 [  1CE0,  1F76]           .....XX.
;#   8054 <= pulse <   8624 [  1F76,  21B0]           ........
;#   8624 <= pulse <   9396 [  21B0,  24B4]           .....X..
;#   9396 <= pulse <   9856 [  24B4,  2680]           ........
;#   9856 <= pulse <  10738 [  2680,  29F2]           .....XXX
;#  10738 <= pulse <  11088 [  29F2,  2B50]           ........
;#  11088 <= pulse <  12081 [  2B50,  2F31]           .....X..
;#  12081 <= pulse <  12320 [  2F31,  3020]           ........
;#  12320 <= pulse <  13423 [  3020,  346F]           ......X.
;#  13423 <= pulse <  14784 [  346F,  39C0]           ........
;#  14784 <= pulse <  16107 [  39C0,  3EEB]           ......XX
;#  16107 <= pulse <  17248 [  3EEB,  4360]           ........
;#  17248 <= pulse <  18792 [  4360,  4968]           ......X.
;#  18792 <= pulse <  19712 [  4968,  4D00]           ........
;#  19712 <= pulse <  21476 [  4D00,  53E4]           ......XX
;#  21476 <= pulse <  22176 [  53E4,  56A0]           ........
;#  22176 <= pulse <  24161 [  56A0,  5E61]           ......X.
;#  24161 <= pulse <  24640 [  5E61,  6040]           ........
;#  24640 <= pulse <  26845 [  6040,  68DD]           .......X
;#  26845 <= pulse <  29568 [  68DD,  7380]           ........
;#  29568 <= pulse <  32214 [  7380,  7DD6]           .......X
;#  32214 <= pulse <  34496 [  7DD6,  86C0]           ........
;#  34496 <= pulse <  37583 [  86C0,  92CF]           .......X
;#  37583 <= pulse <  39424 [  92CF,  9A00]           ........
;#  39424 <= pulse <  42952 [  9A00,  A7C8]           .......X
;#  42952 <= pulse <  44352 [  A7C8,  AD40]           ........
;#  44352 <= pulse <  48321 [  AD40,  BCC1]           .......X
;#  48321 <= pulse          [  BCC1,   ...]           ........


SCI_LT_CNT	EQU	$01


SCI_LT0		EQU	*
SCI_LT0_34	DW	$09A0 %00101110_00101110 SCI_LT0_4E	;pulse >=  2464 cycs
SCI_LT0_1A	DW	$0443 %10000000_10000000 SCI_LT0_27	;pulse >=  1091 cycs
SCI_LT0_0D	DW	$0268 %11101000_11101000 SCI_LT0_14	;pulse >=   616 cycs
SCI_LT0_06	DW	$0190 %01000000_01000000 SCI_LT0_0A	;pulse >=   400 cycs
SCI_LT0_03	DW	$00DB %00000000_00000000 SCI_LT0_05	;pulse >=   219 cycs
SCI_LT0_01	DW	$00A8 %00000000_00000000 SCI_LT0_02	;pulse >=   168 cycs
SCI_LT0_00	DW	$009A %10000000_10000000 $0000		;pulse >=   154 cycs
		DW	$0000
SCI_LT0_02	DW	$00C8 %01000000_01000000 $0000		;pulse >=   200 cycs
		DW	$0000
SCI_LT0_05	DW	$0150 %00000000_00000000 $0000		;pulse >=   336 cycs
SCI_LT0_04	DW	$0134 %10100000_10100000 $0000		;pulse >=   308 cycs
		DW	$0000
SCI_LT0_0A	DW	$01CE %10000000_10000000 SCI_LT0_0C	;pulse >=   462 cycs
SCI_LT0_08	DW	$01B5 %00010000_00010000 SCI_LT0_09	;pulse >=   437 cycs
SCI_LT0_07	DW	$019F %01010000_01010000 $0000		;pulse >=   415 cycs
		DW	$0000
SCI_LT0_09	DW	$01C6 %00000000_00000000 $0000		;pulse >=   454 cycs
		DW	$0000
SCI_LT0_0C	DW	$0258 %01000000_01000000 $0000		;pulse >=   600 cycs
SCI_LT0_0B	DW	$01F8 %00000000_00000000 $0000		;pulse >=   504 cycs
		DW	$0000
SCI_LT0_14	DW	$0369 %00010000_00010000 SCI_LT0_17	;pulse >=   873 cycs
SCI_LT0_11	DW	$0320 %11000000_11000000 SCI_LT0_13	;pulse >=   800 cycs
SCI_LT0_0F	DW	$02A0 %00000000_00000000 SCI_LT0_10	;pulse >=   672 cycs
SCI_LT0_0E	DW	$028F %10101000_10101000 $0000		;pulse >=   655 cycs
		DW	$0000
SCI_LT0_10	DW	$0302 %10000000_10000000 $0000		;pulse >=   770 cycs
		DW	$0000
SCI_LT0_13	DW	$0347 %01010000_01010000 $0000		;pulse >=   839 cycs
SCI_LT0_12	DW	$033F %11010000_11010000 $0000		;pulse >=   831 cycs
		DW	$0000
SCI_LT0_17	DW	$03E9 %11100000_11100000 SCI_LT0_19	;pulse >=  1001 cycs
SCI_LT0_16	DW	$039C %10100000_10100000 $0000		;pulse >=   924 cycs
SCI_LT0_15	DW	$038B %00000000_00000000 $0000		;pulse >=   907 cycs
		DW	$0000
SCI_LT0_19	DW	$0436 %11000000_11000000 $0000		;pulse >=  1078 cycs
SCI_LT0_18	DW	$03EF %01000000_01000000 $0000		;pulse >=  1007 cycs
		DW	$0000
SCI_LT0_27	DW	$0641 %01100000_01100000 SCI_LT0_2E	;pulse >=  1601 cycs
SCI_LT0_21	DW	$0550 %00000000_00000000 SCI_LT0_24	;pulse >=  1360 cycs
SCI_LT0_1E	DW	$04DF %11111100_11111100 SCI_LT0_20	;pulse >=  1247 cycs
SCI_LT0_1C	DW	$04B1 %01000000_01000000 SCI_LT0_1D	;pulse >=  1201 cycs
SCI_LT0_1B	DW	$0497 %00000000_00000000 $0000		;pulse >=  1175 cycs
		DW	$0000
SCI_LT0_1D	DW	$04D0 %11101100_11101100 $0000		;pulse >=  1232 cycs
		DW	$0000
SCI_LT0_20	DW	$053F %00010000_00010000 $0000		;pulse >=  1343 cycs
SCI_LT0_1F	DW	$051D %10111100_10111100 $0000		;pulse >=  1309 cycs
		DW	$0000
SCI_LT0_24	DW	$05E7 %01000000_01000000 SCI_LT0_26	;pulse >=  1511 cycs
SCI_LT0_23	DW	$0579 %11000000_11000000 $0000		;pulse >=  1401 cycs
SCI_LT0_22	DW	$056A %10000000_10000000 $0000		;pulse >=  1386 cycs
		DW	$0000
SCI_LT0_26	DW	$0604 %00100000_00100000 $0000		;pulse >=  1540 cycs
SCI_LT0_25	DW	$05F7 %00000000_00000000 $0000		;pulse >=  1527 cycs
		DW	$0000
SCI_LT0_2E	DW	$07AC %00101000_00101000 SCI_LT0_31	;pulse >=  1964 cycs
SCI_LT0_2B	DW	$0709 %01010000_01010000 SCI_LT0_2D	;pulse >=  1801 cycs
SCI_LT0_29	DW	$068E %01010000_01010000 SCI_LT0_2A	;pulse >=  1678 cycs
SCI_LT0_28	DW	$067F %01110000_01110000 $0000		;pulse >=  1663 cycs
		DW	$0000
SCI_LT0_2A	DW	$06D1 %00010000_00010000 $0000		;pulse >=  1745 cycs
		DW	$0000
SCI_LT0_2D	DW	$0738 %01101000_01101000 $0000		;pulse >=  1848 cycs
SCI_LT0_2C	DW	$0715 %01000000_01000000 $0000		;pulse >=  1813 cycs
		DW	$0000
SCI_LT0_31	DW	$086C %00110000_00110000 SCI_LT0_33	;pulse >=  2156 cycs
SCI_LT0_30	DW	$081F %00010000_00010000 $0000		;pulse >=  2079 cycs
SCI_LT0_2F	DW	$07DE %00000000_00000000 $0000		;pulse >=  2014 cycs
		DW	$0000
SCI_LT0_33	DW	$092D %00000000_00000000 $0000		;pulse >=  2349 cycs
SCI_LT0_32	DW	$08DA %00100000_00100000 $0000		;pulse >=  2266 cycs
		DW	$0000
SCI_LT0_4E	DW	$21B0 %00000100_00000100 SCI_LT0_5B	;pulse >=  8624 cycs
SCI_LT0_41	DW	$0E9E %00011100_00011100 SCI_LT0_48	;pulse >=  3742 cycs
SCI_LT0_3B	DW	$0C08 %00011000_00011000 SCI_LT0_3E	;pulse >=  3080 cycs
SCI_LT0_38	DW	$0AD4 %00100000_00100000 SCI_LT0_3A	;pulse >=  2772 cycs
SCI_LT0_36	DW	$0A7D %00010000_00010000 SCI_LT0_37	;pulse >=  2685 cycs
SCI_LT0_35	DW	$09BE %00111110_00111110 $0000		;pulse >=  2494 cycs
		DW	$0000
SCI_LT0_37	DW	$0A9F %00000000_00000000 $0000		;pulse >=  2719 cycs
		DW	$0000
SCI_LT0_3A	DW	$0BCD %00010000_00010000 $0000		;pulse >=  3021 cycs
SCI_LT0_39	DW	$0B5E %00110000_00110000 $0000		;pulse >=  2910 cycs
		DW	$0000
SCI_LT0_3E	DW	$0D1C %00010000_00010000 SCI_LT0_40	;pulse >=  3356 cycs
SCI_LT0_3D	DW	$0CFE %00011000_00011000 $0000		;pulse >=  3326 cycs
SCI_LT0_3C	DW	$0C64 %00001000_00001000 $0000		;pulse >=  3172 cycs
		DW	$0000
SCI_LT0_40	DW	$0E70 %00001100_00001100 $0000		;pulse >=  3696 cycs
SCI_LT0_3F	DW	$0E29 %00000000_00000000 $0000		;pulse >=  3625 cycs
		DW	$0000
SCI_LT0_48	DW	$15A8 %00001000_00001000 SCI_LT0_4B	;pulse >=  5544 cycs
SCI_LT0_45	DW	$125A %00000000_00000000 SCI_LT0_47	;pulse >=  4698 cycs
SCI_LT0_43	DW	$0FEE %00000000_00000000 SCI_LT0_44	;pulse >=  4078 cycs
SCI_LT0_42	DW	$0FBB %00010000_00010000 $0000		;pulse >=  4027 cycs
		DW	$0000
SCI_LT0_44	DW	$10D8 %00001000_00001000 $0000		;pulse >=  4312 cycs
		DW	$0000
SCI_LT0_47	DW	$14F9 %00000000_00000000 $0000		;pulse >=  5369 cycs
SCI_LT0_46	DW	$1340 %00001111_00001111 $0000		;pulse >=  4928 cycs
		DW	$0000
SCI_LT0_4B	DW	$1A38 %00000000_00000000 SCI_LT0_4D	;pulse >=  6712 cycs
SCI_LT0_4A	DW	$1810 %00000100_00000100 $0000		;pulse >=  6160 cycs
SCI_LT0_49	DW	$1799 %00000000_00000000 $0000		;pulse >=  6041 cycs
		DW	$0000
SCI_LT0_4D	DW	$1F76 %00000000_00000000 $0000		;pulse >=  8054 cycs
SCI_LT0_4C	DW	$1CE0 %00000110_00000110 $0000		;pulse >=  7392 cycs
		DW	$0000
SCI_LT0_5B	DW	$53E4 %00000000_00000000 SCI_LT0_62	;pulse >= 21476 cycs
SCI_LT0_55	DW	$346F %00000000_00000000 SCI_LT0_58	;pulse >= 13423 cycs
SCI_LT0_52	DW	$2B50 %00000100_00000100 SCI_LT0_54	;pulse >= 11088 cycs
SCI_LT0_50	DW	$2680 %00000111_00000111 SCI_LT0_51	;pulse >=  9856 cycs
SCI_LT0_4F	DW	$24B4 %00000000_00000000 $0000		;pulse >=  9396 cycs
		DW	$0000
SCI_LT0_51	DW	$29F2 %00000000_00000000 $0000		;pulse >= 10738 cycs
		DW	$0000
SCI_LT0_54	DW	$3020 %00000010_00000010 $0000		;pulse >= 12320 cycs
SCI_LT0_53	DW	$2F31 %00000000_00000000 $0000		;pulse >= 12081 cycs
		DW	$0000
SCI_LT0_58	DW	$4360 %00000010_00000010 SCI_LT0_5A	;pulse >= 17248 cycs
SCI_LT0_57	DW	$3EEB %00000000_00000000 $0000		;pulse >= 16107 cycs
SCI_LT0_56	DW	$39C0 %00000011_00000011 $0000		;pulse >= 14784 cycs
		DW	$0000
SCI_LT0_5A	DW	$4D00 %00000011_00000011 $0000		;pulse >= 19712 cycs
SCI_LT0_59	DW	$4968 %00000000_00000000 $0000		;pulse >= 18792 cycs
		DW	$0000
SCI_LT0_62	DW	$86C0 %00000001_00000001 SCI_LT0_65	;pulse >= 34496 cycs
SCI_LT0_5F	DW	$68DD %00000000_00000000 SCI_LT0_61	;pulse >= 26845 cycs
SCI_LT0_5D	DW	$5E61 %00000000_00000000 SCI_LT0_5E	;pulse >= 24161 cycs
SCI_LT0_5C	DW	$56A0 %00000010_00000010 $0000		;pulse >= 22176 cycs
		DW	$0000
SCI_LT0_5E	DW	$6040 %00000001_00000001 $0000		;pulse >= 24640 cycs
		DW	$0000
SCI_LT0_61	DW	$7DD6 %00000000_00000000 $0000		;pulse >= 32214 cycs
SCI_LT0_60	DW	$7380 %00000001_00000001 $0000		;pulse >= 29568 cycs
		DW	$0000
SCI_LT0_65	DW	$A7C8 %00000000_00000000 SCI_LT0_67	;pulse >= 42952 cycs
SCI_LT0_64	DW	$9A00 %00000001_00000001 $0000		;pulse >= 39424 cycs
SCI_LT0_63	DW	$92CF %00000000_00000000 $0000		;pulse >= 37583 cycs
		DW	$0000
SCI_LT0_67	DW	$BCC1 %00000000_00000000 $0000		;pulse >= 48321 cycs
SCI_LT0_66	DW	$AD40 %00000001_00000001 $0000		;pulse >= 44352 cycs
		DW	$0000

