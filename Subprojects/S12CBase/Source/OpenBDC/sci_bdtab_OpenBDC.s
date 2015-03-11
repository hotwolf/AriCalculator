#ifndef	SCI_BD_COMPILED
#define	SCI_BD_COMPILED
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
;# Generated on Thu, Jul 26 2012                                               #
;###############################################################################
;# Bus clock:              24.58 MHz                                           #
;# Frame format:           8N1                                                 #
;# Supported baud rates:                                                       #
;#                        4800 ( 140)                                          #
;#                        7200 (  D5)                                          #
;#                        9600 (  A0)                                          #
;#                       14400 (  6B)                                          #
;#                       19200 (  50)                                          #
;#                       28800 (  35)                                          #
;#                       38400 (  28)                                          #
;#                       57600 (  1B)                                          #
;###############################################################################

;###############################################################################
;# Low pulse search tree                                                       #
;###############################################################################
#macro SCI_BD_LOW_PULSE_TREE, 0
;#                    5 3 2 1 1       
;#                    7 8 8 9 4 9 7 4 
;#                    6 4 8 2 4 6 2 8 
;#                    0 0 0 0 0 0 0 0 
;# pulse length >=    0 0 0 0 0 0 0 0       weight  depth  parse time
;# ------------------------------------------------------------------
;#    276 ( 114)      1 . . . . . . . (80)   2001      2       27
;#    400 ( 190)      1 1 . . . . . . (C0)   1843      1       35
;#    533 ( 215)      1 1 1 . . . . . (E0)   1184      3       44
;#    637 ( 27D)      . 1 1 . . . . . (60)    402      2       62
;#    719 ( 2CF)      2 1 1 . . . . . (E0)    352      5       71
;#    800 ( 320)      2 1 1 1 . . . . (F0)    274      4       69
;#    921 ( 399)      2 . 1 1 . . . . (B0)     91      5       78
;#   1040 ( 410)      2 2 1 1 . . . . (F0)     55      3       89
;#   1076 ( 434)      2 2 1 1 1 . . . (F8)     55      7       98
;#   1080 ( 438)      . 2 1 1 1 . . . (78)     43      6      106
;#   1162 ( 48A)      3 2 1 1 1 . . . (F8)     32      8      115
;#   1227 ( 4CB)      3 2 . 1 1 . . . (D8)     17      7      123
;#   1386 ( 56A)      3 2 2 1 1 . . . (F8)     10      9      132
;#   1522 ( 5F2)      . 2 2 1 1 . . . (78)      5      8      140
;#   1561 ( 619)      . . 2 1 1 . . . (38)      3     10      149
;#   1600 ( 640)      . . 2 1 1 1 . . (3C)      4      9      147
;#   1604 ( 644)      4 . 2 1 1 1 . . (BC)      5     10      156
;#   1680 ( 690)      4 3 2 1 1 1 . . (FC)      6      5      126
;#   1841 ( 731)      4 3 2 . 1 1 . . (EC)      5     10      135
;#   1965 ( 7AD)      . 3 2 . 1 1 . . (6C)      4      9      133
;#   2047 ( 7FF)      5 3 2 . 1 1 . . (EC)      5     10      142
;#   2080 ( 820)      5 3 2 2 1 1 . . (FC)      6      8      133
;#   2081 ( 821)      5 3 . 2 1 1 . . (DC)      5     10      142
;#   2133 ( 855)      5 3 . 2 1 1 1 . (DE)      6      9      140
;#   2201 ( 899)      5 . . 2 1 1 1 . (9E)      5     10      149
;#   2240 ( 8C0)      5 . 3 2 1 1 1 . (BE)      6      7      133
;#   2320 ( 910)      5 4 3 2 1 1 1 . (FE)      7     10      142
;#   2408 ( 968)      . 4 3 2 1 1 1 . (7E)      6      9      140
;#   2477 ( 9AD)      . 4 3 2 . 1 1 . (76)      5     10      149
;#   2490 ( 9BA)      6 4 3 2 . 1 1 . (F6)      6      8      140
;#   2799 ( AEF)      6 4 3 2 2 1 1 . (FE)      7     10      149
;#   2841 ( B19)      6 . 3 2 2 1 1 . (BE)      6      9      147
;#   2850 ( B22)      . . 3 2 2 1 1 . (3E)      5     10      156
;#   2932 ( B74)      7 . 3 2 2 1 1 . (BE)      6      6      133
;#   2934 ( B76)      7 . . 2 2 1 1 . (9E)      5     10      142
;#   2960 ( B90)      7 5 . 2 2 1 1 . (DE)      6      9      140
;#   3093 ( C15)      7 5 4 2 2 1 1 . (FE)      7     10      149
;#   3121 ( C31)      7 5 4 . 2 1 1 . (EE)      6      8      130
;#   3200 ( C80)      7 5 4 . 2 1 1 1 (EF)      7      9      147
;#   3293 ( CDD)      . 5 4 . 2 1 1 1 (6F)      6     10      156
;#   3360 ( D20)      . 5 4 3 2 1 1 1 (7F)      7      7      130
;#   3375 ( D2F)      8 5 4 3 2 1 1 1 (FF)      8      9      147
;#   3481 ( D99)      8 . 4 3 2 1 1 1 (BF)      7     10      156
;#   3600 ( E10)      8 6 4 3 2 1 1 1 (FF)      8      8      147
;#   3681 ( E61)      8 6 4 3 2 . 1 1 (FB)      7     10      156
;#   3736 ( E98)      . 6 4 3 2 . 1 1 (7B)      6      9      154
;#   3787 ( ECB)      . 6 . 3 2 . 1 1 (5B)      5     10      163
;#   3818 ( EEA)      9 6 . 3 2 . 1 1 (DB)      6      4      126
;#   3946 ( F6A)      9 6 5 3 2 . 1 1 (FB)      7     10      135
;#   4121 (1019)      9 . 5 3 2 . 1 1 (BB)      6      9      133
;#   4160 (1040)      9 . 5 3 2 2 1 1 (BF)      7     10      142
;#   4178 (1052)      . . 5 3 2 2 1 1 (3F)      6      8      133
;#   4200 (1068)      . . 5 3 . 2 1 1 (37)      5     10      142
;#   4240 (1090)      . 7 5 3 . 2 1 1 (77)      6      9      140
;#   4401 (1131)      . 7 5 . . 2 1 1 (67)      5     10      149
;#   4522 (11AA)      . 7 5 . 3 2 1 1 (6F)      6      7      133
;#   4640 (1220)      . 7 5 4 3 2 1 1 (7F)      7     10      142
;#   4641 (1221)      . 7 . 4 3 2 1 1 (5F)      6      9      140
;#   4761 (1299)      . . . 4 3 2 1 1 (1F)      5     10      149
;#   4800 (12C0)      . . 6 4 3 2 1 1 (3F)      6      8      130
;#   4880 (1310)      . 8 6 4 3 2 1 1 (7F)      7      9      147
;#   4907 (132B)      . 8 6 4 3 2 . 1 (7D)      6     10      156
;#   5401 (1519)      . . 6 4 3 2 . 1 (3D)      5      6      133
;#   5494 (1576)      . . . 4 3 2 . 1 (1D)      4     10      142
;#   5520 (1590)      . 9 . 4 3 2 . 1 (5D)      5      9      140
;#   5546 (15AA)      . 9 . 4 3 2 2 1 (5F)      6     10      149
;#   5653 (1615)      . 9 7 4 3 2 2 1 (7F)      7      8      140
;#   5681 (1631)      . 9 7 . 3 2 2 1 (6F)      6     10      149
;#   5920 (1720)      . 9 7 5 3 2 2 1 (7F)      7      9      147
;#   5922 (1722)      . 9 7 5 . 2 2 1 (77)      6     10      156
;#   6041 (1799)      . . 7 5 . 2 2 1 (37)      5      7      140
;#   6241 (1861)      . . 7 5 . . 2 1 (33)      4     10      149
;#   6244 (1864)      . . 7 5 4 . 2 1 (3B)      5      9      157
;#   6347 (18CB)      . . . 5 4 . 2 1 (1B)      4     11      166
;#   6506 (196A)      . . 8 5 4 . 2 1 (3B)      5     10      156
;#   6720 (1A40)      . . 8 5 4 3 2 1 (3F)      6      8      147
;#   6961 (1B31)      . . 8 . 4 3 2 1 (2F)      5     10      156
;#   7200 (1C20)      . . 8 6 4 3 2 1 (3F)      6      9      154
;#   7201 (1C21)      . . . 6 4 3 2 1 (1F)      5     10      163
;#   7360 (1CC0)      . . 9 6 4 3 2 1 (3F)      6      5      133
;#   7361 (1CC1)      . . 9 6 4 3 2 . (3E)      5     10      142
;#   7645 (1DDD)      . . 9 6 . 3 2 . (36)      4      9      140
;#   7967 (1F1F)      . . 9 6 5 3 2 . (3E)      5     10      157
;#   8054 (1F76)      . . . 6 5 3 2 . (1E)      4     11      166
;#   8241 (2031)      . . . . 5 3 2 . ( E)      3      8      140
;#   8320 (2080)      . . . . 5 3 2 2 ( F)      4     10      157
;#   8321 (2081)      . . . . 5 3 . 2 ( D)      3     11      166
;#   8480 (2120)      . . . 7 5 3 . 2 (1D)      4      9      157
;#   8801 (2261)      . . . 7 5 . . 2 (19)      3     11      166
;#   8960 (2300)      . . . 7 5 . 3 2 (1B)      4     10      156
;#   9280 (2440)      . . . 7 5 4 3 2 (1F)      5      7      140
;#   9368 (2498)      . . . 7 . 4 3 2 (17)      4     10      157
;#   9521 (2531)      . . . . . 4 3 2 ( 7)      3     11      166
;#   9690 (25DA)      . . . . 6 4 3 2 ( F)      4      9      147
;#   9760 (2620)      . . . 8 6 4 3 2 (1F)      5     10      164
;#  10801 (2A31)      . . . . 6 4 3 2 ( F)      4     11      173
;#  11040 (2B20)      . . . 9 6 4 3 2 (1F)      5      8      147
;#  11090 (2B52)      . . . 9 . 4 3 2 (17)      4     10      164
;#  11361 (2C61)      . . . 9 . . 3 2 (13)      3     11      173
;#  11412 (2C94)      . . . 9 7 . 3 2 (1B)      4      9      164
;#  11734 (2DD6)      . . . 9 7 . . 2 (19)      3     11      173
;#  11840 (2E40)      . . . 9 7 5 . 2 (1D)      4     10      163
;#  12081 (2F31)      . . . . 7 5 . 2 ( D)      3      6      150
;#  12373 (3055)      . . . . 7 5 4 2 ( F)      4     11      159
;#  12481 (30C1)      . . . . 7 5 4 . ( E)      3     10      157
;#  12813 (320D)      . . . . . 5 4 . ( 6)      2     11      166
;#  13135 (334F)      . . . . 8 5 4 . ( E)      3      9      147
;#  13440 (3480)      . . . . 8 5 4 3 ( F)      4     10      164
;#  13921 (3661)      . . . . 8 . 4 3 ( B)      3     11      173
;#  14400 (3840)      . . . . 8 6 4 3 ( F)      4      8      157
;#  14536 (38C8)      . . . . . 6 4 3 ( 7)      3     11      166
;#  14858 (3A0A)      . . . . 9 6 4 3 ( F)      4     10      156
;#  15147 (3B2B)      . . . . 9 6 . 3 ( D)      3      9      164
;#  15786 (3DAA)      . . . . 9 6 5 3 ( F)      4     11      173
;#  16258 (3F82)      . . . . . 6 5 3 ( 7)      3     10      171
;#  16481 (4061)      . . . . . . 5 3 ( 3)      2     11      180
;#  16960 (4240)      . . . . . 7 5 3 ( 7)      3      7      157
;#  17601 (44C1)      . . . . . 7 5 . ( 6)      2     11      166
;#  18560 (4880)      . . . . . 7 5 4 ( 7)      3     10      164
;#  18561 (4881)      . . . . . 7 . 4 ( 5)      2     11      181
;#  19041 (4A61)      . . . . . . . 4 ( 1)      1     12      190
;#  19200 (4B00)      . . . . . . 6 4 ( 3)      2      9      164
;#  19520 (4C40)      . . . . . 8 6 4 ( 7)      3     11      173
;#  21601 (5461)      . . . . . . 6 4 ( 3)      2     10      181
;#  21974 (55D6)      . . . . . . . 4 ( 1)      1     12      190
;#  22080 (5640)      . . . . . 9 . 4 ( 5)      2     11      180
;#  22613 (5855)      . . . . . 9 7 4 ( 7)      3      8      164
;#  22721 (58C1)      . . . . . 9 7 . ( 6)      2     11      173
;#  23680 (5C80)      . . . . . 9 7 5 ( 7)      3     10      171
;#  24161 (5E61)      . . . . . . 7 5 ( 3)      2     11      188
;#  25387 (632B)      . . . . . . . 5 ( 1)      1     12      197
;#  26026 (65AA)      . . . . . . 8 5 ( 3)      2      9      181
;#  27841 (6CC1)      . . . . . . 8 . ( 2)      1     12      190
;#  28800 (7080)      . . . . . . 8 6 ( 3)      2     11      188
;#  28801 (7081)      . . . . . . . 6 ( 1)      1     12      197
;#  29440 (7300)      . . . . . . 9 6 ( 3)      2     10      188
;#  32214 (7DD6)      . . . . . . . 6 ( 1)      1     12      205
;#  32961 (80C1)      . . . . . . . . ( 0)      0     13      214
;#  33920 (8480)      . . . . . . . 7 ( 1)      1     11      205
;#  38081 (94C1)      . . . . . . . . ( 0)      0     13      214
;#  39040 (9880)      . . . . . . . 8 ( 1)      1     12      222
;#  43201 (A8C1)      . . . . . . . . ( 0)      0     14      231
;#  44160 (AC80)      . . . . . . . 9 ( 1)      1     13      229
;#  48321 (BCC1)      . . . . . . . . ( 0)      0     14      238
;#
;#       |
;#       |
;#       1
;#       9
;#+------0------+
;#|             |
;#|             |
;#1             2
;#1             7
;#4 +-----------D-----------+
;#  |                       |
;#  |                       |
;#  2                       4
;#  1                       1
;#  5  +--------------------0---------------------+
;#     |                                          |
;#     |                                          |
;#     3                                          E
;#     2                                          E
;#    +0+             +---------------------------A---------------------------+
;#    | |             |                                                       |
;#    | |             |                                                       1
;#    2 3             6                                                       C
;#    C 9             9                                                       C
;#    F 9  +----------0-----------+                          +----------------0----------------+
;#         |                      |                          |                                 |
;#         |                      |                          1                                 2
;#         4                      B                          5                                 F
;#         3                      7                          1                                 3
;#        +8-+             +------4------+            +------9-------+               +---------1----------+
;#        |  |             |             |            |              |               |                    |
;#        |  |             |             |            1              1               2                    4
;#        4  4             8             D            1              7               4                    2
;#        3  C             C             2            A              9               4                    4
;#        4 +B-+       +---0---+      +--0-+       +--A---+      +---9---+       +---0---+         +------0------+
;#          |  |       |       |      |    |       |      |      |       |       |       |         |             |
;#          |  |       |       |      |    |       1      1      1       1       2       2         3             5
;#          4  5       8       9      C    E       0      2      6       A       0       B         8             8
;#          8  F       2       B      3    1       5      C      1       4       3       2         4             5
;#          A +2-+   +-0-+   +-A-+   +1-+ +0-+   +-2-+   +0-+  +-5-+   +-0-+   +-1-+   +-0-+    +--0-+       +---5----+
;#            |  |   |   |   |   |   |  | |  |   |   |   |  |  |   |   |   |   |   |   |   |    |    |       |        |
;#            |  |   |   |   |   |   |  | |  |   1   1   1  1  1   1   1   1   1   2   2   2    3    3       4        6
;#            5  6   7   8   9   B   B  C D  E   0   0   2  3  5   7   8   C   D   1   5   C    3    B       B        5
;#            6  4   A   5   6   1   9  8 2  9   1   9   2  1  9   2   6   2   D   2   D   9    4    2       0        A
;#            A +0+ +D+ +5+ +8+ +9+ +0+ 0 F +8+ +9+ +0+ +1+ 0 +0+ +0+ +4+ +0+ +D+ +0+ +A+ +4+  +F-+ +B-+   +-0-+   +--A--+
;#              | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  |  | |  |   |   |   |     |
;#              | | | | | | | | | | | | | | | | | 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2  3  3 3  3   4   5   5     7
;#              6 6 7 7 8 8 9 9 A B B C C D E E F 0 0 1 2 2 3 5 5 6 7 8 9 B C C F 0 3 4 6 B E  0  4 A  F   8   4   C     3
;#              1 4 3 F 2 9 1 A E 2 7 1 D 9 6 C 6 4 6 3 2 9 2 7 A 3 2 6 6 3 2 C 1 8 0 9 2 5 4  C  8 0  8   8   6   8     0
;#              9 4 1 F 1 9 0 D F 2 6 5 D 9 1 B A 0 8 1 0 9 B 6 A 1 2 1 A 1 1 1 F 0 0 8 0 2 0 +1+ 0 A +2+ +0+ +1+ +0+  +-0-+
;#                                                                      |       | | | | | | | | | | | | | | | | | | |  |   |
;#                                                                      1       1 2 2 2 2 2 2 3 3 3 3 3 4 4 4 4 5 5 5  7   8
;#                                                                      8       F 0 2 5 A C D 0 2 6 8 D 0 4 8 C 6 8 E  0   4
;#                                                                      C       7 8 6 3 3 6 D 5 0 6 C A 6 C 8 4 4 C 6  8   8
;#                                                                      B       6 1 1 1 1 1 6 5 D 1 8 A 1 1 1 0 0 1 1 +0+ +0-+
;#                                                                                                          |   |   | | | |  |
;#                                                                                                          4   5   6 6 7 7  9
;#                                                                                                          A   5   3 C 0 D  8
;#                                                                                                          6   D   2 C 8 D  8
;#                                                                                                          1   6   B 1 1 6 +0-+
;#                                                                                                                        | |  |
;#                                                                                                                        8 9  A
;#                                                                                                                        0 4  C
;#                                                                                                                        C C  8
;#                                                                                                                        1 1 +0+
;#                                                                                                                            | |
;#                                                                                                                            A B
;#                                                                                                                            8 C
;#                                                                                                                            C C
;#                                                                                                                            1 1
;#
N__190		DW	$0190	$C0C0	N__27D		;if pulse >= 400 then check N__27D else check N__114
N__114		DW	$0114	$8080	$0000		;if pulse >= 276 then the result is 80 else the result is 00 
		DW	$0000
N__27D		DW	$027D	$6060	N__410		;if pulse >= 637 then check N__410 else check N__215
N__215		DW	$0215	$E0E0	$0000		;if pulse >= 533 then the result is E0 else the result is C0 
		DW	$0000
N__410		DW	$0410	$F0F0	N__EEA		;if pulse >= 1040 then check N__EEA else check N__320
N__320		DW	$0320	$F0F0	N__399		;if pulse >= 800 then check N__399 else check N__2CF
N__2CF		DW	$02CF	$E0E0	$0000		;if pulse >= 719 then the result is E0 else the result is 60 
		DW	$0000
N__399		DW	$0399	$B0B0	$0000		;if pulse >= 921 then the result is B0 else the result is F0 
		DW	$0000
N__EEA		DW	$0EEA	$DBDB	N_1CC0		;if pulse >= 3818 then check N_1CC0 else check N__690
N__690		DW	$0690	$FCFC	N__B74		;if pulse >= 1680 then check N__B74 else check N__438
N__438		DW	$0438	$7878	N__4CB		;if pulse >= 1080 then check N__4CB else check N__434
N__434		DW	$0434	$F8F8	$0000		;if pulse >= 1076 then the result is F8 else the result is F0 
		DW	$0000
N__4CB		DW	$04CB	$D8D8	N__5F2		;if pulse >= 1227 then check N__5F2 else check N__48A
N__48A		DW	$048A	$F8F8	$0000		;if pulse >= 1162 then the result is F8 else the result is 78 
		DW	$0000
N__5F2		DW	$05F2	$7878	N__640		;if pulse >= 1522 then check N__640 else check N__56A
N__56A		DW	$056A	$F8F8	$0000		;if pulse >= 1386 then the result is F8 else the result is D8 
		DW	$0000
N__640		DW	$0640	$3C3C	N__644		;if pulse >= 1600 then check N__644 else check N__619
N__619		DW	$0619	$3838	$0000		;if pulse >= 1561 then the result is 38 else the result is 78 
		DW	$0000
N__644		DW	$0644	$BCBC	$0000		;if pulse >= 1604 then the result is BC else the result is 3C 
		DW	$0000
N__B74		DW	$0B74	$BEBE	N__D20		;if pulse >= 2932 then check N__D20 else check N__8C0
N__8C0		DW	$08C0	$BEBE	N__9BA		;if pulse >= 2240 then check N__9BA else check N__820
N__820		DW	$0820	$FCFC	N__855		;if pulse >= 2080 then check N__855 else check N__7AD
N__7AD		DW	$07AD	$6C6C	N__7FF		;if pulse >= 1965 then check N__7FF else check N__731
N__731		DW	$0731	$ECEC	$0000		;if pulse >= 1841 then the result is EC else the result is FC 
		DW	$0000
N__7FF		DW	$07FF	$ECEC	$0000		;if pulse >= 2047 then the result is EC else the result is 6C 
		DW	$0000
N__855		DW	$0855	$DEDE	N__899		;if pulse >= 2133 then check N__899 else check N__821
N__821		DW	$0821	$DCDC	$0000		;if pulse >= 2081 then the result is DC else the result is FC 
		DW	$0000
N__899		DW	$0899	$9E9E	$0000		;if pulse >= 2201 then the result is 9E else the result is DE 
		DW	$0000
N__9BA		DW	$09BA	$F6F6	N__B19		;if pulse >= 2490 then check N__B19 else check N__968
N__968		DW	$0968	$7E7E	N__9AD		;if pulse >= 2408 then check N__9AD else check N__910
N__910		DW	$0910	$FEFE	$0000		;if pulse >= 2320 then the result is FE else the result is BE 
		DW	$0000
N__9AD		DW	$09AD	$7676	$0000		;if pulse >= 2477 then the result is 76 else the result is 7E 
		DW	$0000
N__B19		DW	$0B19	$BEBE	N__B22		;if pulse >= 2841 then check N__B22 else check N__AEF
N__AEF		DW	$0AEF	$FEFE	$0000		;if pulse >= 2799 then the result is FE else the result is F6 
		DW	$0000
N__B22		DW	$0B22	$3E3E	$0000		;if pulse >= 2850 then the result is 3E else the result is BE 
		DW	$0000
N__D20		DW	$0D20	$7F7F	N__E10		;if pulse >= 3360 then check N__E10 else check N__C31
N__C31		DW	$0C31	$EEEE	N__C80		;if pulse >= 3121 then check N__C80 else check N__B90
N__B90		DW	$0B90	$DEDE	N__C15		;if pulse >= 2960 then check N__C15 else check N__B76
N__B76		DW	$0B76	$9E9E	$0000		;if pulse >= 2934 then the result is 9E else the result is BE 
		DW	$0000
N__C15		DW	$0C15	$FEFE	$0000		;if pulse >= 3093 then the result is FE else the result is DE 
		DW	$0000
N__C80		DW	$0C80	$EFEF	N__CDD		;if pulse >= 3200 then check N__CDD else the result is EE
		DW	$0000
N__CDD		DW	$0CDD	$6F6F	$0000		;if pulse >= 3293 then the result is 6F else the result is EF 
		DW	$0000
N__E10		DW	$0E10	$FFFF	N__E98		;if pulse >= 3600 then check N__E98 else check N__D2F
N__D2F		DW	$0D2F	$FFFF	N__D99		;if pulse >= 3375 then check N__D99 else the result is 7F
		DW	$0000
N__D99		DW	$0D99	$BFBF	$0000		;if pulse >= 3481 then the result is BF else the result is FF 
		DW	$0000
N__E98		DW	$0E98	$7B7B	N__ECB		;if pulse >= 3736 then check N__ECB else check N__E61
N__E61		DW	$0E61	$FBFB	$0000		;if pulse >= 3681 then the result is FB else the result is FF 
		DW	$0000
N__ECB		DW	$0ECB	$5B5B	$0000		;if pulse >= 3787 then the result is 5B else the result is 7B 
		DW	$0000
N_1CC0		DW	$1CC0	$3F3F	N_2F31		;if pulse >= 7360 then check N_2F31 else check N_1519
N_1519		DW	$1519	$3D3D	N_1799		;if pulse >= 5401 then check N_1799 else check N_11AA
N_11AA		DW	$11AA	$6F6F	N_12C0		;if pulse >= 4522 then check N_12C0 else check N_1052
N_1052		DW	$1052	$3F3F	N_1090		;if pulse >= 4178 then check N_1090 else check N_1019
N_1019		DW	$1019	$BBBB	N_1040		;if pulse >= 4121 then check N_1040 else check N__F6A
N__F6A		DW	$0F6A	$FBFB	$0000		;if pulse >= 3946 then the result is FB else the result is DB 
		DW	$0000
N_1040		DW	$1040	$BFBF	$0000		;if pulse >= 4160 then the result is BF else the result is BB 
		DW	$0000
N_1090		DW	$1090	$7777	N_1131		;if pulse >= 4240 then check N_1131 else check N_1068
N_1068		DW	$1068	$3737	$0000		;if pulse >= 4200 then the result is 37 else the result is 3F 
		DW	$0000
N_1131		DW	$1131	$6767	$0000		;if pulse >= 4401 then the result is 67 else the result is 77 
		DW	$0000
N_12C0		DW	$12C0	$3F3F	N_1310		;if pulse >= 4800 then check N_1310 else check N_1221
N_1221		DW	$1221	$5F5F	N_1299		;if pulse >= 4641 then check N_1299 else check N_1220
N_1220		DW	$1220	$7F7F	$0000		;if pulse >= 4640 then the result is 7F else the result is 6F 
		DW	$0000
N_1299		DW	$1299	$1F1F	$0000		;if pulse >= 4761 then the result is 1F else the result is 5F 
		DW	$0000
N_1310		DW	$1310	$7F7F	N_132B		;if pulse >= 4880 then check N_132B else the result is 3F
		DW	$0000
N_132B		DW	$132B	$7D7D	$0000		;if pulse >= 4907 then the result is 7D else the result is 7F 
		DW	$0000
N_1799		DW	$1799	$3737	N_1A40		;if pulse >= 6041 then check N_1A40 else check N_1615
N_1615		DW	$1615	$7F7F	N_1720		;if pulse >= 5653 then check N_1720 else check N_1590
N_1590		DW	$1590	$5D5D	N_15AA		;if pulse >= 5520 then check N_15AA else check N_1576
N_1576		DW	$1576	$1D1D	$0000		;if pulse >= 5494 then the result is 1D else the result is 3D 
		DW	$0000
N_15AA		DW	$15AA	$5F5F	$0000		;if pulse >= 5546 then the result is 5F else the result is 5D 
		DW	$0000
N_1720		DW	$1720	$7F7F	N_1722		;if pulse >= 5920 then check N_1722 else check N_1631
N_1631		DW	$1631	$6F6F	$0000		;if pulse >= 5681 then the result is 6F else the result is 7F 
		DW	$0000
N_1722		DW	$1722	$7777	$0000		;if pulse >= 5922 then the result is 77 else the result is 7F 
		DW	$0000
N_1A40		DW	$1A40	$3F3F	N_1C20		;if pulse >= 6720 then check N_1C20 else check N_1864
N_1864		DW	$1864	$3B3B	N_196A		;if pulse >= 6244 then check N_196A else check N_1861
N_1861		DW	$1861	$3333	$0000		;if pulse >= 6241 then the result is 33 else the result is 37 
		DW	$0000
N_196A		DW	$196A	$3B3B	$0000		;if pulse >= 6506 then the result is 3B else check N_18CB
N_18CB		DW	$18CB	$1B1B	$0000		;if pulse >= 6347 then the result is 1B else the result is 3B 
		DW	$0000
N_1C20		DW	$1C20	$3F3F	N_1C21		;if pulse >= 7200 then check N_1C21 else check N_1B31
N_1B31		DW	$1B31	$2F2F	$0000		;if pulse >= 6961 then the result is 2F else the result is 3F 
		DW	$0000
N_1C21		DW	$1C21	$1F1F	$0000		;if pulse >= 7201 then the result is 1F else the result is 3F 
		DW	$0000
N_2F31		DW	$2F31	$0D0D	N_4240		;if pulse >= 12081 then check N_4240 else check N_2440
N_2440		DW	$2440	$1F1F	N_2B20		;if pulse >= 9280 then check N_2B20 else check N_2031
N_2031		DW	$2031	$0E0E	N_2120		;if pulse >= 8241 then check N_2120 else check N_1DDD
N_1DDD		DW	$1DDD	$3636	N_1F1F		;if pulse >= 7645 then check N_1F1F else check N_1CC1
N_1CC1		DW	$1CC1	$3E3E	$0000		;if pulse >= 7361 then the result is 3E else the result is 3F 
		DW	$0000
N_1F1F		DW	$1F1F	$3E3E	N_1F76		;if pulse >= 7967 then check N_1F76 else the result is 36
		DW	$0000
N_1F76		DW	$1F76	$1E1E	$0000		;if pulse >= 8054 then the result is 1E else the result is 3E 
		DW	$0000
N_2120		DW	$2120	$1D1D	N_2300		;if pulse >= 8480 then check N_2300 else check N_2080
N_2080		DW	$2080	$0F0F	N_2081		;if pulse >= 8320 then check N_2081 else the result is 0E
		DW	$0000
N_2081		DW	$2081	$0D0D	$0000		;if pulse >= 8321 then the result is 0D else the result is 0F 
		DW	$0000
N_2300		DW	$2300	$1B1B	$0000		;if pulse >= 8960 then the result is 1B else check N_2261
N_2261		DW	$2261	$1919	$0000		;if pulse >= 8801 then the result is 19 else the result is 1D 
		DW	$0000
N_2B20		DW	$2B20	$1F1F	N_2C94		;if pulse >= 11040 then check N_2C94 else check N_25DA
N_25DA		DW	$25DA	$0F0F	N_2620		;if pulse >= 9690 then check N_2620 else check N_2498
N_2498		DW	$2498	$1717	N_2531		;if pulse >= 9368 then check N_2531 else the result is 1F
		DW	$0000
N_2531		DW	$2531	$0707	$0000		;if pulse >= 9521 then the result is 07 else the result is 17 
		DW	$0000
N_2620		DW	$2620	$1F1F	N_2A31		;if pulse >= 9760 then check N_2A31 else the result is 0F
		DW	$0000
N_2A31		DW	$2A31	$0F0F	$0000		;if pulse >= 10801 then the result is 0F else the result is 1F 
		DW	$0000
N_2C94		DW	$2C94	$1B1B	N_2E40		;if pulse >= 11412 then check N_2E40 else check N_2B52
N_2B52		DW	$2B52	$1717	N_2C61		;if pulse >= 11090 then check N_2C61 else the result is 1F
		DW	$0000
N_2C61		DW	$2C61	$1313	$0000		;if pulse >= 11361 then the result is 13 else the result is 17 
		DW	$0000
N_2E40		DW	$2E40	$1D1D	$0000		;if pulse >= 11840 then the result is 1D else check N_2DD6
N_2DD6		DW	$2DD6	$1919	$0000		;if pulse >= 11734 then the result is 19 else the result is 1B 
		DW	$0000
N_4240		DW	$4240	$0707	N_5855		;if pulse >= 16960 then check N_5855 else check N_3840
N_3840		DW	$3840	$0F0F	N_3B2B		;if pulse >= 14400 then check N_3B2B else check N_334F
N_334F		DW	$334F	$0E0E	N_3480		;if pulse >= 13135 then check N_3480 else check N_30C1
N_30C1		DW	$30C1	$0E0E	N_320D		;if pulse >= 12481 then check N_320D else check N_3055
N_3055		DW	$3055	$0F0F	$0000		;if pulse >= 12373 then the result is 0F else the result is 0D 
		DW	$0000
N_320D		DW	$320D	$0606	$0000		;if pulse >= 12813 then the result is 06 else the result is 0E 
		DW	$0000
N_3480		DW	$3480	$0F0F	N_3661		;if pulse >= 13440 then check N_3661 else the result is 0E
		DW	$0000
N_3661		DW	$3661	$0B0B	$0000		;if pulse >= 13921 then the result is 0B else the result is 0F 
		DW	$0000
N_3B2B		DW	$3B2B	$0D0D	N_3F82		;if pulse >= 15147 then check N_3F82 else check N_3A0A
N_3A0A		DW	$3A0A	$0F0F	$0000		;if pulse >= 14858 then the result is 0F else check N_38C8
N_38C8		DW	$38C8	$0707	$0000		;if pulse >= 14536 then the result is 07 else the result is 0F 
		DW	$0000
N_3F82		DW	$3F82	$0707	N_4061		;if pulse >= 16258 then check N_4061 else check N_3DAA
N_3DAA		DW	$3DAA	$0F0F	$0000		;if pulse >= 15786 then the result is 0F else the result is 0D 
		DW	$0000
N_4061		DW	$4061	$0303	$0000		;if pulse >= 16481 then the result is 03 else the result is 07 
		DW	$0000
N_5855		DW	$5855	$0707	N_65AA		;if pulse >= 22613 then check N_65AA else check N_4B00
N_4B00		DW	$4B00	$0303	N_5461		;if pulse >= 19200 then check N_5461 else check N_4880
N_4880		DW	$4880	$0707	N_4881		;if pulse >= 18560 then check N_4881 else check N_44C1
N_44C1		DW	$44C1	$0606	$0000		;if pulse >= 17601 then the result is 06 else the result is 07 
		DW	$0000
N_4881		DW	$4881	$0505	N_4A61		;if pulse >= 18561 then check N_4A61 else the result is 07
		DW	$0000
N_4A61		DW	$4A61	$0101	$0000		;if pulse >= 19041 then the result is 01 else the result is 05 
		DW	$0000
N_5461		DW	$5461	$0303	N_5640		;if pulse >= 21601 then check N_5640 else check N_4C40
N_4C40		DW	$4C40	$0707	$0000		;if pulse >= 19520 then the result is 07 else the result is 03 
		DW	$0000
N_5640		DW	$5640	$0505	$0000		;if pulse >= 22080 then the result is 05 else check N_55D6
N_55D6		DW	$55D6	$0101	$0000		;if pulse >= 21974 then the result is 01 else the result is 03 
		DW	$0000
N_65AA		DW	$65AA	$0303	N_7300		;if pulse >= 26026 then check N_7300 else check N_5C80
N_5C80		DW	$5C80	$0707	N_5E61		;if pulse >= 23680 then check N_5E61 else check N_58C1
N_58C1		DW	$58C1	$0606	$0000		;if pulse >= 22721 then the result is 06 else the result is 07 
		DW	$0000
N_5E61		DW	$5E61	$0303	N_632B		;if pulse >= 24161 then check N_632B else the result is 07
		DW	$0000
N_632B		DW	$632B	$0101	$0000		;if pulse >= 25387 then the result is 01 else the result is 03 
		DW	$0000
N_7300		DW	$7300	$0303	N_8480		;if pulse >= 29440 then check N_8480 else check N_7080
N_7080		DW	$7080	$0303	N_7081		;if pulse >= 28800 then check N_7081 else check N_6CC1
N_6CC1		DW	$6CC1	$0202	$0000		;if pulse >= 27841 then the result is 02 else the result is 03 
		DW	$0000
N_7081		DW	$7081	$0101	$0000		;if pulse >= 28801 then the result is 01 else the result is 03 
		DW	$0000
N_8480		DW	$8480	$0101	N_9880		;if pulse >= 33920 then check N_9880 else check N_7DD6
N_7DD6		DW	$7DD6	$0101	N_80C1		;if pulse >= 32214 then check N_80C1 else the result is 03
		DW	$0000
N_80C1		DW	$80C1	$0000	$0000		;if pulse >= 32961 then the result is 00 else the result is 01 
		DW	$0000
N_9880		DW	$9880	$0101	N_AC80		;if pulse >= 39040 then check N_AC80 else check N_94C1
N_94C1		DW	$94C1	$0000	$0000		;if pulse >= 38081 then the result is 00 else the result is 01 
		DW	$0000
N_AC80		DW	$AC80	$0101	N_BCC1		;if pulse >= 44160 then check N_BCC1 else check N_A8C1
N_A8C1		DW	$A8C1	$0000	$0000		;if pulse >= 43201 then the result is 00 else the result is 01 
		DW	$0000
N_BCC1		DW	$BCC1	$0000	$0000		;if pulse >= 48321 then the result is 00 else the result is 01 
		DW	$0000
#emac

;###############################################################################
;# High pulse search tree                                                      #
;###############################################################################
#macro SCI_BD_HIGH_PULSE_TREE, 0
;#                    5 3 2 1 1       
;#                    7 8 8 9 4 9 7 4 
;#                    6 4 8 2 4 6 2 8 
;#                    0 0 0 0 0 0 0 0 
;# pulse length >=    0 0 0 0 0 0 0 0       weight  depth  parse time
;# ------------------------------------------------------------------
;#    420 ( 1A4)      1 . . . . . . . (80)     11      3       37
;#    608 ( 260)      1 1 . . . . . . (C0)     18      2       35
;#    810 ( 32A)      1 1 1 . . . . . (E0)     23      3       44
;#   1216 ( 4C0)      1 1 1 1 . . . . (F0)     20      1       35
;#   1636 ( 664)      1 1 1 1 1 . . . (F8)     14      3       44
;#   2432 ( 980)      1 1 1 1 1 1 . . (FC)      6      2       52
;#   3242 ( CAA)      1 1 1 1 1 1 1 . (FE)      7      4       61
;#   4864 (1300)      1 1 1 1 1 1 1 1 (FF)      8      3       51
;#
;#   |
;#   |
;#   4
;#   C
;# +-0-+
;# |   |
;# |   |
;# 2   9
;# 6   8
;#+0+ +0+
;#| | | |
;#| | | 1
;#1 3 6 3
;#A 2 6 0
;#4 A 4 0
;#      |
;#      |
;#      C
;#      A
;#      A
;#
N__4C0		DW	$04C0	$F0F0	N__980		;if pulse >= 1216 then check N__980 else check N__260
N__260		DW	$0260	$C0C0	N__32A		;if pulse >= 608 then check N__32A else check N__1A4
N__1A4		DW	$01A4	$8080	$0000		;if pulse >= 420 then the result is 80 else the result is 00 
		DW	$0000
N__32A		DW	$032A	$E0E0	$0000		;if pulse >= 810 then the result is E0 else the result is C0 
		DW	$0000
N__980		DW	$0980	$FCFC	N_1300		;if pulse >= 2432 then check N_1300 else check N__664
N__664		DW	$0664	$F8F8	$0000		;if pulse >= 1636 then the result is F8 else the result is F0 
		DW	$0000
N_1300		DW	$1300	$FFFF	$0000		;if pulse >= 4864 then the result is FF else check N__CAA
N__CAA		DW	$0CAA	$FEFE	$0000		;if pulse >= 3242 then the result is FE else the result is FC 
		DW	$0000
#emac

;###############################################################################
;# Parse routine                                                               #
;###############################################################################
;#Parse search tree for detected pulse length
; args:   Y: root of the search tree
;         X: pulse length
; result: D: list of matching baud rates (mirrored in high and low byte)
; SSTACK: 0 bytes
;         X is preserved
#macro	SCI_BD_PARSE, 0
		LDD	#$0000		;  2 cycs	;initialize X
LOOP		TST	0,Y	     	;  3 cycs	;check if lower boundary exists
		BEQ	DONE		;1/3 cycs	;search done
		CPX	6,Y+		;  3 cycs	;check if pulse length is shorter than lower boundary
		BLO	LOOP		;1/3 cycs	;pulse length is shorter than lower boundary -> try a shorter range
		LDD	-4,Y		;  3 cycs	;new lowest boundary found -> store valid baud rate field in index X
		LDY	-2,Y		;  3 cycs	;switch to the branch with higher compare values
		BNE	LOOP		;1/3 cycs	;parse branch if it exists
DONE		EQU	*				;done, result in X
#emac
#endif
