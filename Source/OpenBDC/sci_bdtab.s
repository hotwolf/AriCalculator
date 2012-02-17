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
;# High pulses                                                                 #
;###############################################################################
;#
;#                                                    53211   
;#                                                    78894974
;#                                                    64824628
;#                                                    00000000
;# Range                                              00000000
;# -----------------------------------------------------------
;#    415 <= pulse <    616 [   19F,   268]           X.......
;#    616 <= pulse <    816 [   268,   330]           XX......
;#    816 <= pulse <   1232 [   330,   4D0]           XXX.....
;#   1232 <= pulse <   1647 [   4D0,   66F]           XXXX....
;#   1647 <= pulse <   2464 [   66F,   9A0]           XXXXX...
;#   2464 <= pulse <   3280 [   9A0,   CD0]           XXXXXX..
;#   3280 <= pulse <   4928 [   CD0,  1340]           XXXXXXX.
;#   4928 <= pulse          [  1340,   ...]           XXXXXXXX


SCI_HT_CNT	EQU	$01


SCI_HT0		EQU	*
SCI_HT0_04	DW	$066F %11111000_11111000 SCI_HT0_06	;pulse >=  1647 cycs
SCI_HT0_02	DW	$0330 %11100000_11100000 SCI_HT0_03	;pulse >=   816 cycs
SCI_HT0_01	DW	$0268 %11000000_11000000 $0000		;pulse >=   616 cycs
SCI_HT0_00	DW	$019F %10000000_10000000 $0000		;pulse >=   415 cycs
		DW	$0000
SCI_HT0_03	DW	$04D0 %11110000_11110000 $0000		;pulse >=  1232 cycs
		DW	$0000
SCI_HT0_06	DW	$0CD0 %11111110_11111110 SCI_HT0_07	;pulse >=  3280 cycs
SCI_HT0_05	DW	$09A0 %11111100_11111100 $0000		;pulse >=  2464 cycs
		DW	$0000
SCI_HT0_07	DW	$1340 %11111111_11111111 $0000		;pulse >=  4928 cycs
		DW	$0000

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
;#    454 <= pulse <    616 [   1C6,   268]           ........
;#    616 <= pulse <    672 [   268,   2A0]           .X......
;#    672 <= pulse <    816 [   2A0,   330]           ........
;#    816 <= pulse <    831 [   330,   33F]           ..X.....
;#    831 <= pulse <    890 [   33F,   37A]           X.X.....
;#    890 <= pulse <    907 [   37A,   38B]           X.......
;#    907 <= pulse <   1232 [   38B,   4D0]           ........
;#   1232 <= pulse <   1247 [   4D0,   4DF]           .X.X....
;#   1247 <= pulse <   1343 [   4DF,   53F]           XX.X....
;#   1343 <= pulse <   1360 [   53F,   550]           X.......
;#   1360 <= pulse <   1632 [   550,   660]           ........
;#   1632 <= pulse <   1647 [   660,   66F]           ..X.....
;#   1647 <= pulse <   1663 [   66F,   67F]           ..X.X...
;#   1663 <= pulse <   1779 [   67F,   6F3]           X.X.X...
;#   1779 <= pulse <   1796 [   6F3,   704]           X...X...
;#   1796 <= pulse <   1813 [   704,   715]           X.......
;#   1813 <= pulse <   1848 [   715,   738]           ........
;#   1848 <= pulse <   2014 [   738,   7DE]           .X......
;#   2014 <= pulse <   2079 [   7DE,   81F]           ........
;#   2079 <= pulse <   2266 [   81F,   8DA]           X.......
;#   2266 <= pulse <   2448 [   8DA,   990]           ........
;#   2448 <= pulse <   2464 [   990,   9A0]           ..X.....
;#   2464 <= pulse <   2494 [   9A0,   9BE]           .XXX.X..
;#   2494 <= pulse <   2668 [   9BE,   A6C]           XXXX.X..
;#   2668 <= pulse <   2685 [   A6C,   A7D]           XX.X.X..
;#   2685 <= pulse <   2719 [   A7D,   A9F]           X.......
;#   2719 <= pulse <   2910 [   A9F,   B5E]           ........
;#   2910 <= pulse <   3080 [   B5E,   C08]           X.......
;#   3080 <= pulse <   3172 [   C08,   C64]           XX......
;#   3172 <= pulse <   3264 [   C64,   CC0]           .X......
;#   3264 <= pulse <   3280 [   CC0,   CD0]           .XX.....
;#   3280 <= pulse <   3295 [   CD0,   CDF]           .XX...X.
;#   3295 <= pulse <   3326 [   CDF,   CFE]           .XX.X.X.
;#   3326 <= pulse <   3356 [   CFE,   D1C]           XXX.X.X.
;#   3356 <= pulse <   3557 [   D1C,   DE5]           X.X.X.X.
;#   3557 <= pulse <   3574 [   DE5,   DF6]           X...X.X.
;#   3574 <= pulse <   3591 [   DF6,   E07]           X...X...
;#   3591 <= pulse <   3625 [   E07,   E29]           X.......
;#   3625 <= pulse <   3696 [   E29,   E70]           ........
;#   3696 <= pulse <   3742 [   E70,   E9E]           .X.X....
;#   3742 <= pulse <   4027 [   E9E,   FBB]           XX.X....
;#   4027 <= pulse <   4078 [   FBB,   FEE]           X.......
;#   4078 <= pulse <   4081 [   FEE,   FF1]           ........
;#   4081 <= pulse <   4312 [   FF1,  10D8]           ..X.....
;#   4312 <= pulse <   4447 [  10D8,  115F]           .XX.....
;#   4447 <= pulse <   4698 [  115F,  125A]           .X......
;#   4698 <= pulse <   4897 [  125A,  1321]           ........
;#   4897 <= pulse <   4928 [  1321,  1340]           ..X.....
;#   4928 <= pulse <   4943 [  1340,  134F]           .XXX.X.X
;#   4943 <= pulse <   5336 [  134F,  14D8]           .XXXXX.X
;#   5336 <= pulse <   5369 [  14D8,  14F9]           .X.XXX.X
;#   5369 <= pulse <   5386 [  14F9,  150A]           ....X...
;#   5386 <= pulse <   5544 [  150A,  15A8]           ........
;#   5544 <= pulse <   5713 [  15A8,  1651]           .X......
;#   5713 <= pulse <   6041 [  1651,  1799]           .XX.....
;#   6041 <= pulse <   6160 [  1799,  1810]           ..X.....
;#   6160 <= pulse <   6225 [  1810,  1851]           ..XX....
;#   6225 <= pulse <   6529 [  1851,  1981]           ...X....
;#   6529 <= pulse <   6560 [  1981,  19A0]           ..XX....
;#   6560 <= pulse <   6591 [  19A0,  19BF]           ..XX..X.
;#   6591 <= pulse <   6712 [  19BF,  1A38]           ..XXX.X.
;#   6712 <= pulse <   7114 [  1A38,  1BCA]           ..X.X.X.
;#   7114 <= pulse <   7148 [  1BCA,  1BEC]           ....X.X.
;#   7148 <= pulse <   7181 [  1BEC,  1C0D]           ....X...
;#   7181 <= pulse <   7345 [  1C0D,  1CB1]           ........
;#   7345 <= pulse <   7392 [  1CB1,  1CE0]           ..X.....
;#   7392 <= pulse <   8004 [  1CE0,  1F44]           ..XX.X..
;#   8004 <= pulse <   8054 [  1F44,  1F76]           ...X.X..
;#   8054 <= pulse <   8239 [  1F76,  202F]           ........
;#   8239 <= pulse <   8624 [  202F,  21B0]           ....X...
;#   8624 <= pulse <   8977 [  21B0,  2311]           ...XX...
;#   8977 <= pulse <   9396 [  2311,  24B4]           ...X....
;#   9396 <= pulse <   9840 [  24B4,  2670]           ........
;#   9840 <= pulse <   9856 [  2670,  2680]           ......X.
;#   9856 <= pulse <   9886 [  2680,  269E]           ...X.XXX
;#   9886 <= pulse <  10722 [  269E,  29E2]           ...XXXXX
;#  10722 <= pulse <  10738 [  29E2,  29F2]           ...XXX.X
;#  10738 <= pulse <  10772 [  29F2,  2A14]           ....X...
;#  10772 <= pulse <  11088 [  2A14,  2B50]           ........
;#  11088 <= pulse <  11534 [  2B50,  2D0E]           ...X....
;#  11534 <= pulse <  12081 [  2D0E,  2F31]           ...XX...
;#  12081 <= pulse <  12320 [  2F31,  3020]           ....X...
;#  12320 <= pulse <  12567 [  3020,  3117]           ....XX..
;#  12567 <= pulse <  13120 [  3117,  3340]           .....X..
;#  13120 <= pulse <  13182 [  3340,  337E]           .....XX.
;#  13182 <= pulse <  13423 [  337E,  346F]           ....XXX.
;#  13423 <= pulse <  14295 [  346F,  37D7]           ....X.X.
;#  14295 <= pulse <  14362 [  37D7,  381A]           ....X...
;#  14362 <= pulse <  14784 [  381A,  39C0]           ........
;#  14784 <= pulse <  14830 [  39C0,  39EE]           .....X.X
;#  14830 <= pulse <  16107 [  39EE,  3EEB]           ....XX.X
;#  16107 <= pulse <  16158 [  3EEB,  3F1E]           ....X...
;#  16158 <= pulse <  16401 [  3F1E,  4011]           ........
;#  16401 <= pulse <  17248 [  4011,  4360]           ......X.
;#  17248 <= pulse <  17869 [  4360,  45CD]           .....XX.
;#  17869 <= pulse <  18792 [  45CD,  4968]           .....X..
;#  18792 <= pulse <  19681 [  4968,  4CE1]           ........
;#  19681 <= pulse <  19712 [  4CE1,  4D00]           ......X.
;#  19712 <= pulse <  21443 [  4D00,  53C3]           .....XXX
;#  21443 <= pulse <  21476 [  53C3,  53E4]           .....X.X
;#  21476 <= pulse <  22176 [  53E4,  56A0]           ........
;#  22176 <= pulse <  22961 [  56A0,  59B1]           .....X..
;#  22961 <= pulse <  24161 [  59B1,  5E61]           .....XX.
;#  24161 <= pulse <  24640 [  5E61,  6040]           ......X.
;#  24640 <= pulse <  25016 [  6040,  61B8]           ......XX
;#  25016 <= pulse <  26241 [  61B8,  6681]           .......X
;#  26241 <= pulse <  26845 [  6681,  68DD]           ......XX
;#  26845 <= pulse <  28590 [  68DD,  6FAE]           ......X.
;#  28590 <= pulse <  29521 [  6FAE,  7351]           ........
;#  29521 <= pulse <  29568 [  7351,  7380]           ......X.
;#  29568 <= pulse <  32164 [  7380,  7DA4]           ......XX
;#  32164 <= pulse <  32214 [  7DA4,  7DD6]           .......X
;#  32214 <= pulse <  34496 [  7DD6,  86C0]           ........
;#  34496 <= pulse <  37583 [  86C0,  92CF]           .......X
;#  37583 <= pulse <  39424 [  92CF,  9A00]           ........
;#  39424 <= pulse <  42952 [  9A00,  A7C8]           .......X
;#  42952 <= pulse <  44352 [  A7C8,  AD40]           ........
;#  44352 <= pulse <  48321 [  AD40,  BCC1]           .......X
;#  48321 <= pulse          [  BCC1,   ...]           ........


SCI_LT_CNT	EQU	$01


SCI_LT0		EQU	*
SCI_LT0_3C	DW	$19A0 %00110010_00110010 SCI_LT0_5A	;pulse >=  6560 cycs
SCI_LT0_1E	DW	$0C64 %01000000_01000000 SCI_LT0_2D	;pulse >=  3172 cycs
SCI_LT0_0F	DW	$06F3 %10001000_10001000 SCI_LT0_17	;pulse >=  1779 cycs
SCI_LT0_07	DW	$038B %00000000_00000000 SCI_LT0_0B	;pulse >=   907 cycs
SCI_LT0_03	DW	$02A0 %00000000_00000000 SCI_LT0_05	;pulse >=   672 cycs
SCI_LT0_01	DW	$01C6 %00000000_00000000 SCI_LT0_02	;pulse >=   454 cycs
SCI_LT0_00	DW	$019F %10000000_10000000 $0000		;pulse >=   415 cycs
		DW	$0000
SCI_LT0_02	DW	$0268 %01000000_01000000 $0000		;pulse >=   616 cycs
		DW	$0000
SCI_LT0_05	DW	$033F %10100000_10100000 SCI_LT0_06	;pulse >=   831 cycs
SCI_LT0_04	DW	$0330 %00100000_00100000 $0000		;pulse >=   816 cycs
		DW	$0000
SCI_LT0_06	DW	$037A %10000000_10000000 $0000		;pulse >=   890 cycs
		DW	$0000
SCI_LT0_0B	DW	$0550 %00000000_00000000 SCI_LT0_0D	;pulse >=  1360 cycs
SCI_LT0_09	DW	$04DF %11010000_11010000 SCI_LT0_0A	;pulse >=  1247 cycs
SCI_LT0_08	DW	$04D0 %01010000_01010000 $0000		;pulse >=  1232 cycs
		DW	$0000
SCI_LT0_0A	DW	$053F %10000000_10000000 $0000		;pulse >=  1343 cycs
		DW	$0000
SCI_LT0_0D	DW	$066F %00101000_00101000 SCI_LT0_0E	;pulse >=  1647 cycs
SCI_LT0_0C	DW	$0660 %00100000_00100000 $0000		;pulse >=  1632 cycs
		DW	$0000
SCI_LT0_0E	DW	$067F %10101000_10101000 $0000		;pulse >=  1663 cycs
		DW	$0000
SCI_LT0_17	DW	$09A0 %01110100_01110100 SCI_LT0_1B	;pulse >=  2464 cycs
SCI_LT0_13	DW	$07DE %00000000_00000000 SCI_LT0_15	;pulse >=  2014 cycs
SCI_LT0_11	DW	$0715 %00000000_00000000 SCI_LT0_12	;pulse >=  1813 cycs
SCI_LT0_10	DW	$0704 %10000000_10000000 $0000		;pulse >=  1796 cycs
		DW	$0000
SCI_LT0_12	DW	$0738 %01000000_01000000 $0000		;pulse >=  1848 cycs
		DW	$0000
SCI_LT0_15	DW	$08DA %00000000_00000000 SCI_LT0_16	;pulse >=  2266 cycs
SCI_LT0_14	DW	$081F %10000000_10000000 $0000		;pulse >=  2079 cycs
		DW	$0000
SCI_LT0_16	DW	$0990 %00100000_00100000 $0000		;pulse >=  2448 cycs
		DW	$0000
SCI_LT0_1B	DW	$0A9F %00000000_00000000 SCI_LT0_1D	;pulse >=  2719 cycs
SCI_LT0_19	DW	$0A6C %11010100_11010100 SCI_LT0_1A	;pulse >=  2668 cycs
SCI_LT0_18	DW	$09BE %11110100_11110100 $0000		;pulse >=  2494 cycs
		DW	$0000
SCI_LT0_1A	DW	$0A7D %10000000_10000000 $0000		;pulse >=  2685 cycs
		DW	$0000
SCI_LT0_1D	DW	$0C08 %11000000_11000000 $0000		;pulse >=  3080 cycs
SCI_LT0_1C	DW	$0B5E %10000000_10000000 $0000		;pulse >=  2910 cycs
		DW	$0000
SCI_LT0_2D	DW	$10D8 %01100000_01100000 SCI_LT0_35	;pulse >=  4312 cycs
SCI_LT0_26	DW	$0E07 %10000000_10000000 SCI_LT0_2A	;pulse >=  3591 cycs
SCI_LT0_22	DW	$0CFE %11101010_11101010 SCI_LT0_24	;pulse >=  3326 cycs
SCI_LT0_20	DW	$0CD0 %01100010_01100010 SCI_LT0_21	;pulse >=  3280 cycs
SCI_LT0_1F	DW	$0CC0 %01100000_01100000 $0000		;pulse >=  3264 cycs
		DW	$0000
SCI_LT0_21	DW	$0CDF %01101010_01101010 $0000		;pulse >=  3295 cycs
		DW	$0000
SCI_LT0_24	DW	$0DE5 %10001010_10001010 SCI_LT0_25	;pulse >=  3557 cycs
SCI_LT0_23	DW	$0D1C %10101010_10101010 $0000		;pulse >=  3356 cycs
		DW	$0000
SCI_LT0_25	DW	$0DF6 %10001000_10001000 $0000		;pulse >=  3574 cycs
		DW	$0000
SCI_LT0_2A	DW	$0FBB %10000000_10000000 SCI_LT0_2C	;pulse >=  4027 cycs
SCI_LT0_28	DW	$0E70 %01010000_01010000 SCI_LT0_29	;pulse >=  3696 cycs
SCI_LT0_27	DW	$0E29 %00000000_00000000 $0000		;pulse >=  3625 cycs
		DW	$0000
SCI_LT0_29	DW	$0E9E %11010000_11010000 $0000		;pulse >=  3742 cycs
		DW	$0000
SCI_LT0_2C	DW	$0FF1 %00100000_00100000 $0000		;pulse >=  4081 cycs
SCI_LT0_2B	DW	$0FEE %00000000_00000000 $0000		;pulse >=  4078 cycs
		DW	$0000
SCI_LT0_35	DW	$150A %00000000_00000000 SCI_LT0_39	;pulse >=  5386 cycs
SCI_LT0_31	DW	$1340 %01110101_01110101 SCI_LT0_33	;pulse >=  4928 cycs
SCI_LT0_2F	DW	$125A %00000000_00000000 SCI_LT0_30	;pulse >=  4698 cycs
SCI_LT0_2E	DW	$115F %01000000_01000000 $0000		;pulse >=  4447 cycs
		DW	$0000
SCI_LT0_30	DW	$1321 %00100000_00100000 $0000		;pulse >=  4897 cycs
		DW	$0000
SCI_LT0_33	DW	$14D8 %01011101_01011101 SCI_LT0_34	;pulse >=  5336 cycs
SCI_LT0_32	DW	$134F %01111101_01111101 $0000		;pulse >=  4943 cycs
		DW	$0000
SCI_LT0_34	DW	$14F9 %00001000_00001000 $0000		;pulse >=  5369 cycs
		DW	$0000
SCI_LT0_39	DW	$1810 %00110000_00110000 SCI_LT0_3B	;pulse >=  6160 cycs
SCI_LT0_37	DW	$1651 %01100000_01100000 SCI_LT0_38	;pulse >=  5713 cycs
SCI_LT0_36	DW	$15A8 %01000000_01000000 $0000		;pulse >=  5544 cycs
		DW	$0000
SCI_LT0_38	DW	$1799 %00100000_00100000 $0000		;pulse >=  6041 cycs
		DW	$0000
SCI_LT0_3B	DW	$1981 %00110000_00110000 $0000		;pulse >=  6529 cycs
SCI_LT0_3A	DW	$1851 %00010000_00010000 $0000		;pulse >=  6225 cycs
		DW	$0000
SCI_LT0_5A	DW	$39C0 %00000101_00000101 SCI_LT0_69	;pulse >= 14784 cycs
SCI_LT0_4B	DW	$2680 %00010111_00010111 SCI_LT0_53	;pulse >=  9856 cycs
SCI_LT0_44	DW	$1F44 %00010100_00010100 SCI_LT0_48	;pulse >=  8004 cycs
SCI_LT0_40	DW	$1BEC %00001000_00001000 SCI_LT0_42	;pulse >=  7148 cycs
SCI_LT0_3E	DW	$1A38 %00101010_00101010 SCI_LT0_3F	;pulse >=  6712 cycs
SCI_LT0_3D	DW	$19BF %00111010_00111010 $0000		;pulse >=  6591 cycs
		DW	$0000
SCI_LT0_3F	DW	$1BCA %00001010_00001010 $0000		;pulse >=  7114 cycs
		DW	$0000
SCI_LT0_42	DW	$1CB1 %00100000_00100000 SCI_LT0_43	;pulse >=  7345 cycs
SCI_LT0_41	DW	$1C0D %00000000_00000000 $0000		;pulse >=  7181 cycs
		DW	$0000
SCI_LT0_43	DW	$1CE0 %00110100_00110100 $0000		;pulse >=  7392 cycs
		DW	$0000
SCI_LT0_48	DW	$2311 %00010000_00010000 SCI_LT0_4A	;pulse >=  8977 cycs
SCI_LT0_46	DW	$202F %00001000_00001000 SCI_LT0_47	;pulse >=  8239 cycs
SCI_LT0_45	DW	$1F76 %00000000_00000000 $0000		;pulse >=  8054 cycs
		DW	$0000
SCI_LT0_47	DW	$21B0 %00011000_00011000 $0000		;pulse >=  8624 cycs
		DW	$0000
SCI_LT0_4A	DW	$2670 %00000010_00000010 $0000		;pulse >=  9840 cycs
SCI_LT0_49	DW	$24B4 %00000000_00000000 $0000		;pulse >=  9396 cycs
		DW	$0000
SCI_LT0_53	DW	$3020 %00001100_00001100 SCI_LT0_57	;pulse >= 12320 cycs
SCI_LT0_4F	DW	$2A14 %00000000_00000000 SCI_LT0_51	;pulse >= 10772 cycs
SCI_LT0_4D	DW	$29E2 %00011101_00011101 SCI_LT0_4E	;pulse >= 10722 cycs
SCI_LT0_4C	DW	$269E %00011111_00011111 $0000		;pulse >=  9886 cycs
		DW	$0000
SCI_LT0_4E	DW	$29F2 %00001000_00001000 $0000		;pulse >= 10738 cycs
		DW	$0000
SCI_LT0_51	DW	$2D0E %00011000_00011000 SCI_LT0_52	;pulse >= 11534 cycs
SCI_LT0_50	DW	$2B50 %00010000_00010000 $0000		;pulse >= 11088 cycs
		DW	$0000
SCI_LT0_52	DW	$2F31 %00001000_00001000 $0000		;pulse >= 12081 cycs
		DW	$0000
SCI_LT0_57	DW	$346F %00001010_00001010 SCI_LT0_59	;pulse >= 13423 cycs
SCI_LT0_55	DW	$3340 %00000110_00000110 SCI_LT0_56	;pulse >= 13120 cycs
SCI_LT0_54	DW	$3117 %00000100_00000100 $0000		;pulse >= 12567 cycs
		DW	$0000
SCI_LT0_56	DW	$337E %00001110_00001110 $0000		;pulse >= 13182 cycs
		DW	$0000
SCI_LT0_59	DW	$381A %00000000_00000000 $0000		;pulse >= 14362 cycs
SCI_LT0_58	DW	$37D7 %00001000_00001000 $0000		;pulse >= 14295 cycs
		DW	$0000
SCI_LT0_69	DW	$6040 %00000011_00000011 SCI_LT0_71	;pulse >= 24640 cycs
SCI_LT0_62	DW	$4CE1 %00000010_00000010 SCI_LT0_66	;pulse >= 19681 cycs
SCI_LT0_5E	DW	$4011 %00000010_00000010 SCI_LT0_60	;pulse >= 16401 cycs
SCI_LT0_5C	DW	$3EEB %00001000_00001000 SCI_LT0_5D	;pulse >= 16107 cycs
SCI_LT0_5B	DW	$39EE %00001101_00001101 $0000		;pulse >= 14830 cycs
		DW	$0000
SCI_LT0_5D	DW	$3F1E %00000000_00000000 $0000		;pulse >= 16158 cycs
		DW	$0000
SCI_LT0_60	DW	$45CD %00000100_00000100 SCI_LT0_61	;pulse >= 17869 cycs
SCI_LT0_5F	DW	$4360 %00000110_00000110 $0000		;pulse >= 17248 cycs
		DW	$0000
SCI_LT0_61	DW	$4968 %00000000_00000000 $0000		;pulse >= 18792 cycs
		DW	$0000
SCI_LT0_66	DW	$56A0 %00000100_00000100 SCI_LT0_68	;pulse >= 22176 cycs
SCI_LT0_64	DW	$53C3 %00000101_00000101 SCI_LT0_65	;pulse >= 21443 cycs
SCI_LT0_63	DW	$4D00 %00000111_00000111 $0000		;pulse >= 19712 cycs
		DW	$0000
SCI_LT0_65	DW	$53E4 %00000000_00000000 $0000		;pulse >= 21476 cycs
		DW	$0000
SCI_LT0_68	DW	$5E61 %00000010_00000010 $0000		;pulse >= 24161 cycs
SCI_LT0_67	DW	$59B1 %00000110_00000110 $0000		;pulse >= 22961 cycs
		DW	$0000
SCI_LT0_71	DW	$7DD6 %00000000_00000000 SCI_LT0_75	;pulse >= 32214 cycs
SCI_LT0_6D	DW	$6FAE %00000000_00000000 SCI_LT0_6F	;pulse >= 28590 cycs
SCI_LT0_6B	DW	$6681 %00000011_00000011 SCI_LT0_6C	;pulse >= 26241 cycs
SCI_LT0_6A	DW	$61B8 %00000001_00000001 $0000		;pulse >= 25016 cycs
		DW	$0000
SCI_LT0_6C	DW	$68DD %00000010_00000010 $0000		;pulse >= 26845 cycs
		DW	$0000
SCI_LT0_6F	DW	$7380 %00000011_00000011 SCI_LT0_70	;pulse >= 29568 cycs
SCI_LT0_6E	DW	$7351 %00000010_00000010 $0000		;pulse >= 29521 cycs
		DW	$0000
SCI_LT0_70	DW	$7DA4 %00000001_00000001 $0000		;pulse >= 32164 cycs
		DW	$0000
SCI_LT0_75	DW	$A7C8 %00000000_00000000 SCI_LT0_77	;pulse >= 42952 cycs
SCI_LT0_73	DW	$92CF %00000000_00000000 SCI_LT0_74	;pulse >= 37583 cycs
SCI_LT0_72	DW	$86C0 %00000001_00000001 $0000		;pulse >= 34496 cycs
		DW	$0000
SCI_LT0_74	DW	$9A00 %00000001_00000001 $0000		;pulse >= 39424 cycs
		DW	$0000
SCI_LT0_77	DW	$BCC1 %00000000_00000000 $0000		;pulse >= 48321 cycs
SCI_LT0_76	DW	$AD40 %00000001_00000001 $0000		;pulse >= 44352 cycs
		DW	$0000

