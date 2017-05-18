#ifndef	SCI_BD_COMPILED
#define	SCI_BD_COMPILED
;###############################################################################
;# S12CBase - SCI Baud Detection Search Trees                                  #
;###############################################################################
;#    Copyright 2009-2012 Dirk Heisswolf                                       #
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
;# Generated on Thu, Nov 15 2012                                               #
;###############################################################################
;# Bus clock:              50.00 MHz divided by  2                             #
;# Frame format:           8N1                                                 #
;# Supported baud rates:                                                       #
;#                        4800 ( 28B)                                          #
;#                        7200 ( 1B2)                                          #
;#                        9600 ( 146)                                          #
;#                       14400 (  D9)                                          #
;#                       19200 (  A3)                                          #
;#                       28800 (  6D)                                          #
;#                       38400 (  51)                                          #
;#                       57600 (  36)                                          #
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
;#    271 ( 10F)      1 . . . . . . . (80)   2001      2       27
;#    416 ( 1A0)      1 1 . . . . . . (C0)   1621      1       35
;#    542 ( 21E)      1 1 1 . . . . . (E0)   1091      3       44
;#    624 ( 270)      . 1 1 . . . . . (60)    428      2       52
;#    705 ( 2C1)      2 1 1 . . . . . (E0)    379      4       69
;#    813 ( 32D)      2 1 1 1 . . . . (F0)    248      5       86
;#    959 ( 3BF)      2 . 1 1 . . . . (B0)     70      6       95
;#   1058 ( 422)      . . 1 1 . . . . (30)     24      3       99
;#   1083 ( 43B)      . 2 1 1 . . . . (70)     31      8      108
;#   1095 ( 447)      . 2 1 1 1 . . . (78)     38      7       98
;#   1139 ( 473)      3 2 1 1 1 . . . (F8)     36      6      106
;#   1248 ( 4E0)      3 2 . 1 1 . . . (D8)     15      8      123
;#   1410 ( 582)      3 2 2 1 1 . . . (F8)      9      9      140
;#   1492 ( 5D4)      . 2 2 1 1 . . . (78)      5     10      149
;#   1573 ( 625)      4 2 2 1 1 . . . (F8)      6      7      133
;#   1626 ( 65A)      4 . 2 1 1 . . . (B8)      4     10      142
;#   1637 ( 665)      4 . 2 1 1 1 . . (BC)      5      9      132
;#   1750 ( 6D6)      4 3 2 1 1 1 . . (FC)      6      8      130
;#   1872 ( 750)      4 3 2 . 1 1 . . (EC)      5      9      147
;#   1926 ( 786)      . 3 2 . 1 1 . . (6C)      4     10      156
;#   2007 ( 7D7)      5 3 2 . 1 1 . . (EC)      5      5      126
;#   2115 ( 843)      5 3 2 2 1 1 . . (FC)      6     10      135
;#   2116 ( 844)      5 3 . 2 1 1 . . (DC)      5      9      133
;#   2170 ( 87A)      5 3 . 2 1 1 1 . (DE)      6     10      142
;#   2278 ( 8E6)      5 3 3 2 1 1 1 . (FE)      7      8      133
;#   2293 ( 8F5)      5 . 3 2 1 1 1 . (BE)      6     10      142
;#   2361 ( 939)      . . 3 2 1 1 1 . (3E)      5      9      140
;#   2418 ( 972)      . 4 3 2 1 1 1 . (7E)      6     10      149
;#   2441 ( 989)      6 4 3 2 1 1 1 . (FE)      7      7      133
;#   2519 ( 9D7)      6 4 3 2 . 1 1 . (F6)      6     10      142
;#   2795 ( AEB)      . 4 3 2 . 1 1 . (76)      5      9      140
;#   2847 ( B1F)      . 4 3 2 2 1 1 . (7E)      6     10      149
;#   2875 ( B3B)      7 4 3 2 2 1 1 . (FE)      7      8      130
;#   2960 ( B90)      7 . 3 2 2 1 1 . (BE)      6      9      147
;#   2984 ( BA8)      7 . . 2 2 1 1 . (9E)      5     10      156
;#   3085 ( C0D)      7 5 . 2 2 1 1 . (DE)      6      6      133
;#   3146 ( C4A)      7 5 4 2 2 1 1 . (FE)      7     10      142
;#   3174 ( C66)      7 5 4 . 2 1 1 . (EE)      6      9      140
;#   3229 ( C9D)      . 5 4 . 2 1 1 . (6E)      5     10      149
;#   3265 ( CC1)      . 5 4 . 2 1 1 1 (6F)      6      8      140
;#   3309 ( CED)      8 5 4 . 2 1 1 1 (EF)      7     10      149
;#   3417 ( D59)      8 5 4 3 2 1 1 1 (FF)      8      9      139
;#   3628 ( E2C)      8 . 4 3 2 1 1 1 (BF)      7      7      140
;#   3663 ( E4F)      . . 4 3 2 1 1 1 (3F)      6     10      149
;#   3743 ( E9F)      9 . 4 3 2 1 1 1 (BF)      7      9      139
;#   3752 ( EA8)      9 6 4 3 2 1 1 1 (FF)      8      8      137
;#   3767 ( EB7)      9 6 4 3 2 . 1 1 (FB)      7      9      154
;#   3852 ( F0C)      9 6 . 3 2 . 1 1 (DB)      6     10      163
;#   4014 ( FAE)      9 6 5 3 2 . 1 1 (FB)      7      4      126
;#   4097 (1001)      . 6 5 3 2 . 1 1 (7B)      6     10      135
;#   4257 (10A1)      . 6 5 3 2 2 1 1 (7F)      7      9      133
;#   4271 (10AF)      . 6 5 3 . 2 1 1 (77)      6     10      142
;#   4295 (10C7)      . . 5 3 . 2 1 1 (37)      5      8      133
;#   4419 (1143)      . 7 5 3 . 2 1 1 (77)      6     10      142
;#   4476 (117C)      . 7 5 . . 2 1 1 (67)      5      9      140
;#   4599 (11F7)      . 7 5 . 3 2 1 1 (6F)      6     10      149
;#   4720 (1270)      . 7 5 4 3 2 1 1 (7F)      7      7      133
;#   4721 (1271)      . 7 . 4 3 2 1 1 (5F)      6     10      142
;#   4882 (1312)      . 7 6 4 3 2 1 1 (7F)      7      9      132
;#   4962 (1362)      . . 6 4 3 2 1 1 (3F)      6      8      140
;#   4992 (1380)      . . 6 4 3 2 . 1 (3D)      5     10      149
;#   5086 (13DE)      . 8 6 4 3 2 . 1 (7D)      6      9      147
;#   5589 (15D5)      . 8 . 4 3 2 . 1 (5D)      5     10      156
;#   5629 (15FD)      . . . 4 3 2 . 1 (1D)      4      6      133
;#   5642 (160A)      . . . 4 3 2 2 1 (1F)      5     10      142
;#   5750 (1676)      . . 7 4 3 2 2 1 (3F)      6      9      140
;#   5753 (1679)      . 9 7 4 3 2 2 1 (7F)      7     10      149
;#   5778 (1692)      . 9 7 . 3 2 2 1 (6F)      6      8      130
;#   6022 (1786)      . 9 7 5 3 2 2 1 (7F)      7      9      147
;#   6023 (1787)      . 9 7 5 . 2 2 1 (77)      6     10      156
;#   6296 (1898)      . . 7 5 . 2 2 1 (37)      5      7      140
;#   6351 (18CF)      . . 7 5 4 2 2 1 (3F)      6     10      149
;#   6387 (18F3)      . . 7 5 4 . 2 1 (3B)      5      9      157
;#   6457 (1939)      . . . 5 4 . 2 1 (1B)      4     11      166
;#   6618 (19DA)      . . 8 5 4 . 2 1 (3B)      5     10      156
;#   6877 (1ADD)      . . 8 5 4 3 2 1 (3F)      6      8      147
;#   7081 (1BA9)      . . 8 . 4 3 2 1 (2F)      5     10      156
;#   7324 (1C9C)      . . 8 6 4 3 2 1 (3F)      6      9      154
;#   7325 (1C9D)      . . . 6 4 3 2 1 (1F)      5     10      163
;#   7486 (1D3E)      . . 9 6 4 3 2 1 (3F)      6      5      133
;#   7510 (1D56)      . . 9 6 4 3 2 . (3E)      5     10      142
;#   7775 (1E5F)      . . 9 6 . 3 2 . (36)      4      9      140
;#   8103 (1FA7)      . . 9 6 5 3 2 . (3E)      5     10      157
;#   8193 (2001)      . . . 6 5 3 2 . (1E)      4     11      166
;#   8383 (20BF)      . . . . 5 3 2 . ( E)      3      8      150
;#   8464 (2110)      . . . . 5 3 . . ( C)      2     11      159
;#   8489 (2129)      . . . . 5 3 . 2 ( D)      3     10      149
;#   8626 (21B2)      . . . 7 5 3 . 2 (1D)      4      9      157
;#   9007 (232F)      . . . 7 5 . . 2 (19)      3     11      166
;#   9114 (239A)      . . . 7 5 . 3 2 (1B)      4     10      156
;#   9498 (251A)      . . . 7 5 4 3 2 (1F)      5      7      140
;#   9528 (2538)      . . . 7 . 4 3 2 (17)      4     10      157
;#   9685 (25D5)      . . . . . 4 3 2 ( 7)      3     11      166
;#   9855 (267F)      . . . . 6 4 3 2 ( F)      4      9      147
;#   9928 (26C8)      . . . 8 6 4 3 2 (1F)      5     10      164
;#  10987 (2AEB)      . . . . 6 4 3 2 ( F)      4     11      173
;#  11230 (2BDE)      . . . 9 6 4 3 2 (1F)      5      8      147
;#  11280 (2C10)      . . . 9 . 4 3 2 (17)      4     10      156
;#  11607 (2D57)      . . . 9 7 4 3 2 (1F)      5      9      154
;#  11627 (2D6B)      . . . 9 7 . 3 2 (1B)      4     10      171
;#  11936 (2EA0)      . . . 9 7 . . 2 (19)      3     11      180
;#  12118 (2F56)      . . . 9 7 5 . 2 (1D)      4      6      150
;#  12289 (3001)      . . . . 7 5 . 2 ( D)      3     11      159
;#  12586 (312A)      . . . . 7 5 4 2 ( F)      4     10      149
;#  12735 (31BF)      . . . . 7 5 4 . ( E)      3      9      157
;#  13032 (32E8)      . . . . . 5 4 . ( 6)      2     11      166
;#  13359 (342F)      . . . . 8 5 4 . ( E)      3     10      164
;#  13713 (3591)      . . . . 8 5 4 3 ( F)      4     11      173
;#  14248 (37A8)      . . . . 8 . 4 3 ( B)      3      8      147
;#  14738 (3992)      . . . . 8 6 4 3 ( F)      4     10      164
;#  14784 (39C0)      . . . . . 6 4 3 ( 7)      3     11      173
;#  15111 (3B07)      . . . . 9 6 4 3 ( F)      4      9      164
;#  15408 (3C30)      . . . . 9 6 . 3 ( D)      3     11      173
;#  16059 (3EBB)      . . . . 9 6 5 3 ( F)      4     10      163
;#  16536 (4098)      . . . . . 6 5 3 ( 7)      3      7      157
;#  16868 (41E4)      . . . . . . 5 3 ( 3)      2     11      166
;#  17358 (43CE)      . . . . . 7 5 3 ( 7)      3     10      164
;#  17959 (4627)      . . . . . 7 5 . ( 6)      2     11      181
;#  18881 (49C1)      . . . . . 7 . . ( 4)      1     12      190
;#  18938 (49FA)      . . . . . 7 . 4 ( 5)      2      9      174
;#  19488 (4C20)      . . . . . . . 4 ( 1)      1     12      183
;#  19531 (4C4B)      . . . . . . 6 4 ( 3)      2     11      173
;#  19978 (4E0A)      . . . . . 8 6 4 ( 7)      3     10      171
;#  22108 (565C)      . . . . . . 6 4 ( 3)      2     11      188
;#  22353 (5751)      . . . . . . . 4 ( 1)      1     12      197
;#  22598 (5846)      . . . . . 9 . 4 ( 5)      2      8      164
;#  23003 (59DB)      . . . . . 9 7 4 ( 7)      3     11      173
;#  23183 (5A8F)      . . . . . 9 7 . ( 6)      2     10      171
;#  24162 (5E62)      . . . . . 9 7 5 ( 7)      3     11      188
;#  24728 (6098)      . . . . . . 7 5 ( 3)      2     12      197
;#  25825 (64E1)      . . . . . . . 5 ( 1)      1      9      171
;#  26475 (676B)      . . . . . . 8 5 ( 3)      2     11      188
;#  28408 (6EF8)      . . . . . . 8 . ( 2)      1     12      215
;#  29297 (7271)      . . . . . . . . ( 0)      0     14      224
;#  29386 (72CA)      . . . . . . . 6 ( 1)      1     13      214
;#  29947 (74FB)      . . . . . . 9 6 ( 3)      2     10      188
;#  32770 (8002)      . . . . . . . 6 ( 1)      1     12      205
;#  33632 (8360)      . . . . . . . . ( 0)      0     13      214
;#  34611 (8733)      . . . . . . . 7 ( 1)      1     11      205
;#  38856 (97C8)      . . . . . . . . ( 0)      0     13      214
;#  39835 (9B9B)      . . . . . . . 8 ( 1)      1     12      222
;#  44081 (AC31)      . . . . . . . . ( 0)      0     14      231
;#  45059 (B003)      . . . . . . . 9 ( 1)      1     13      229
;#  49305 (C099)      . . . . . . . . ( 0)      0     14      238
;#
;#      |
;#      |
;#      1
;#      A
;#+-----0-----+
;#|           |
;#|           |
;#1           2
;#0           7
;#F +---------0----------+
;#  |                    |
;#  |                    |
;#  2                    4
;#  1                    2
;#  E +------------------2------------------+
;#    |                                     |
;#    |                                     |
;#    2                                     F
;#    C                                     A
;#    1            +------------------------E-----------------------+
;#    |            |                                                |
;#    |            |                                                1
;#    3            7                                                D
;#    2            D                                                3
;#    D  +---------7--------+                        +--------------E---------------+
;#    |  |                  |                        |                              |
;#    |  |                  |                        1                              2
;#    3  4                  C                        5                              F
;#    B  7                  0                        F                              5
;#    F +3-+          +-----D-----+           +------D-----+               +--------6---------+
;#      |  |          |           |           |            |               |                  |
;#      |  |          |           |           1            1               2                  4
;#      4  6          9           E           2            8               5                  0
;#      4  2          8           2           7            9               1                  9
;#      7 +5-+     +--9---+     +-C--+     +--0--+      +--8---+       +---A---+        +-----8------+
;#      | |  |     |      |     |    |     |     |      |      |       |       |        |            |
;#      | |  |     |      |     |    |     1     1      1      1       2       2        3            5
;#      4 4  6     8      B     C    E     0     3      6      A       0       B        7            8
;#      3 E  D     E      3     C    A     C     6      9      D       B       D        A            4
;#      B 0 +6+  +-6-+   +B-+  +1-+ +8+  +-7-+  +2-+   +2-+  +-D-+   +-F-+   +-E-+   +--8--+     +---6---+
;#        | | |  |   |   |  |  |  | | |  |   |  |  |   |  |  |   |   |   |   |   |   |     |     |       |
;#        | | |  |   |   |  |  |  | | |  1   1  1  1   1  1  1   1   1   2   2   2   3     3     4       6
;#        5 6 7  8   9   A  B  C  D E E  0   1  3  3   6  7  8   C   E   1   6   D   1     B     9       4
;#        8 6 5  4   3   E  9  6  5 9 B  A   7  1  D   7  8  F   9   5   B   7   5   B     0     F       E
;#        2 5 0 +4+ +9+ +B+ 0 +6+ 9 F 7 +1+ +C+ 2 +E+ +6+ 6 +3+ +C+ +F+ +2+ +F+ +7+ +F-+  +7+  +-A-+   +-1-+
;#        | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  |  | |  |   |   |   |
;#        | | | | | | | | | | | | | | | 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 3  3  3 3  4   4   5   7
;#        5 6 7 8 8 8 9 9 B B C C C E F 0 0 1 1 2 3 5 6 6 7 8 9 B C D F 1 3 5 6 C D 1  4  9 E  3   E   A   4
;#        D 5 8 4 7 F 7 D 1 A 4 9 E 4 0 0 A 4 F 7 8 D 0 7 8 C D A 9 5 A 2 9 3 C 1 6 2  2  9 B  C   0   8   F
;#        4 A 6 3 A 5 2 7 F 8 A D D F C 1 F 3 7 1 0 5 A 9 7 F A 9 D 6 7 9 A 8 8 0 B A +F+ 2 B +E+ +A+ +F+ +B-+
;#                                                            |       | | | | |   | | | | | | | | | | | | |  |
;#                                                            1       2 2 2 2 2   2 3 3 3 3 3 4 4 4 5 5 5 6  8
;#                                                            9       0 1 3 5 A   E 0 2 5 9 C 1 6 C 6 9 E 7  7
;#                                                            3       0 1 2 D E   A 0 E 9 C 3 E 2 4 5 D 6 6  3
;#                                                            9       1 0 F 5 B   0 1 8 1 0 0 4 7 B C B 2 B +3-+
;#                                                                                              | | |   | | |  |
;#                                                                                              4 4 5   6 6 8  9
;#                                                                                              9 C 7   0 E 0  B
;#                                                                                              C 2 5   9 F 0  9
;#                                                                                              1 0 1   8 8 2 +B-+
;#                                                                                                        | | |  |
;#                                                                                                        7 8 9  B
;#                                                                                                        2 3 7  0
;#                                                                                                        C 6 C  0
;#                                                                                                        A 0 8 +3+
;#                                                                                                        |     | |
;#                                                                                                        7     A C
;#                                                                                                        2     C 0
;#                                                                                                        7     3 9
;#                                                                                                        1     1 9
;#
N__1A0		DW	$01A0	$C0C0	N__270		;if pulse >= 416 then check N__270 else check N__10F
N__10F		DW	$010F	$8080	$0000		;if pulse >= 271 then the result is 80 else the result is 00 
		DW	$0000
N__270		DW	$0270	$6060	N__422		;if pulse >= 624 then check N__422 else check N__21E
N__21E		DW	$021E	$E0E0	$0000		;if pulse >= 542 then the result is E0 else the result is C0 
		DW	$0000
N__422		DW	$0422	$3030	N__FAE		;if pulse >= 1058 then check N__FAE else check N__2C1
N__2C1		DW	$02C1	$E0E0	N__32D		;if pulse >= 705 then check N__32D else the result is 60
		DW	$0000
N__32D		DW	$032D	$F0F0	N__3BF		;if pulse >= 813 then check N__3BF else the result is E0
		DW	$0000
N__3BF		DW	$03BF	$B0B0	$0000		;if pulse >= 959 then the result is B0 else the result is F0 
		DW	$0000
N__FAE		DW	$0FAE	$FBFB	N_1D3E		;if pulse >= 4014 then check N_1D3E else check N__7D7
N__7D7		DW	$07D7	$ECEC	N__C0D		;if pulse >= 2007 then check N__C0D else check N__473
N__473		DW	$0473	$F8F8	N__625		;if pulse >= 1139 then check N__625 else check N__447
N__447		DW	$0447	$7878	$0000		;if pulse >= 1095 then the result is 78 else check N__43B
N__43B		DW	$043B	$7070	$0000		;if pulse >= 1083 then the result is 70 else the result is 30 
		DW	$0000
N__625		DW	$0625	$F8F8	N__6D6		;if pulse >= 1573 then check N__6D6 else check N__4E0
N__4E0		DW	$04E0	$D8D8	N__582		;if pulse >= 1248 then check N__582 else the result is F8
		DW	$0000
N__582		DW	$0582	$F8F8	N__5D4		;if pulse >= 1410 then check N__5D4 else the result is D8
		DW	$0000
N__5D4		DW	$05D4	$7878	$0000		;if pulse >= 1492 then the result is 78 else the result is F8 
		DW	$0000
N__6D6		DW	$06D6	$FCFC	N__750		;if pulse >= 1750 then check N__750 else check N__665
N__665		DW	$0665	$BCBC	$0000		;if pulse >= 1637 then the result is BC else check N__65A
N__65A		DW	$065A	$B8B8	$0000		;if pulse >= 1626 then the result is B8 else the result is F8 
		DW	$0000
N__750		DW	$0750	$ECEC	N__786		;if pulse >= 1872 then check N__786 else the result is FC
		DW	$0000
N__786		DW	$0786	$6C6C	$0000		;if pulse >= 1926 then the result is 6C else the result is EC 
		DW	$0000
N__C0D		DW	$0C0D	$DEDE	N__E2C		;if pulse >= 3085 then check N__E2C else check N__989
N__989		DW	$0989	$FEFE	N__B3B		;if pulse >= 2441 then check N__B3B else check N__8E6
N__8E6		DW	$08E6	$FEFE	N__939		;if pulse >= 2278 then check N__939 else check N__844
N__844		DW	$0844	$DCDC	N__87A		;if pulse >= 2116 then check N__87A else check N__843
N__843		DW	$0843	$FCFC	$0000		;if pulse >= 2115 then the result is FC else the result is EC 
		DW	$0000
N__87A		DW	$087A	$DEDE	$0000		;if pulse >= 2170 then the result is DE else the result is DC 
		DW	$0000
N__939		DW	$0939	$3E3E	N__972		;if pulse >= 2361 then check N__972 else check N__8F5
N__8F5		DW	$08F5	$BEBE	$0000		;if pulse >= 2293 then the result is BE else the result is FE 
		DW	$0000
N__972		DW	$0972	$7E7E	$0000		;if pulse >= 2418 then the result is 7E else the result is 3E 
		DW	$0000
N__B3B		DW	$0B3B	$FEFE	N__B90		;if pulse >= 2875 then check N__B90 else check N__AEB
N__AEB		DW	$0AEB	$7676	N__B1F		;if pulse >= 2795 then check N__B1F else check N__9D7
N__9D7		DW	$09D7	$F6F6	$0000		;if pulse >= 2519 then the result is F6 else the result is FE 
		DW	$0000
N__B1F		DW	$0B1F	$7E7E	$0000		;if pulse >= 2847 then the result is 7E else the result is 76 
		DW	$0000
N__B90		DW	$0B90	$BEBE	N__BA8		;if pulse >= 2960 then check N__BA8 else the result is FE
		DW	$0000
N__BA8		DW	$0BA8	$9E9E	$0000		;if pulse >= 2984 then the result is 9E else the result is BE 
		DW	$0000
N__E2C		DW	$0E2C	$BFBF	N__EA8		;if pulse >= 3628 then check N__EA8 else check N__CC1
N__CC1		DW	$0CC1	$6F6F	N__D59		;if pulse >= 3265 then check N__D59 else check N__C66
N__C66		DW	$0C66	$EEEE	N__C9D		;if pulse >= 3174 then check N__C9D else check N__C4A
N__C4A		DW	$0C4A	$FEFE	$0000		;if pulse >= 3146 then the result is FE else the result is DE 
		DW	$0000
N__C9D		DW	$0C9D	$6E6E	$0000		;if pulse >= 3229 then the result is 6E else the result is EE 
		DW	$0000
N__D59		DW	$0D59	$FFFF	$0000		;if pulse >= 3417 then the result is FF else check N__CED
N__CED		DW	$0CED	$EFEF	$0000		;if pulse >= 3309 then the result is EF else the result is 6F 
		DW	$0000
N__EA8		DW	$0EA8	$FFFF	N__EB7		;if pulse >= 3752 then check N__EB7 else check N__E9F
N__E9F		DW	$0E9F	$BFBF	$0000		;if pulse >= 3743 then the result is BF else check N__E4F
N__E4F		DW	$0E4F	$3F3F	$0000		;if pulse >= 3663 then the result is 3F else the result is BF 
		DW	$0000
N__EB7		DW	$0EB7	$FBFB	N__F0C		;if pulse >= 3767 then check N__F0C else the result is FF
		DW	$0000
N__F0C		DW	$0F0C	$DBDB	$0000		;if pulse >= 3852 then the result is DB else the result is FB 
		DW	$0000
N_1D3E		DW	$1D3E	$3F3F	N_2F56		;if pulse >= 7486 then check N_2F56 else check N_15FD
N_15FD		DW	$15FD	$1D1D	N_1898		;if pulse >= 5629 then check N_1898 else check N_1270
N_1270		DW	$1270	$7F7F	N_1362		;if pulse >= 4720 then check N_1362 else check N_10C7
N_10C7		DW	$10C7	$3737	N_117C		;if pulse >= 4295 then check N_117C else check N_10A1
N_10A1		DW	$10A1	$7F7F	N_10AF		;if pulse >= 4257 then check N_10AF else check N_1001
N_1001		DW	$1001	$7B7B	$0000		;if pulse >= 4097 then the result is 7B else the result is FB 
		DW	$0000
N_10AF		DW	$10AF	$7777	$0000		;if pulse >= 4271 then the result is 77 else the result is 7F 
		DW	$0000
N_117C		DW	$117C	$6767	N_11F7		;if pulse >= 4476 then check N_11F7 else check N_1143
N_1143		DW	$1143	$7777	$0000		;if pulse >= 4419 then the result is 77 else the result is 37 
		DW	$0000
N_11F7		DW	$11F7	$6F6F	$0000		;if pulse >= 4599 then the result is 6F else the result is 67 
		DW	$0000
N_1362		DW	$1362	$3F3F	N_13DE		;if pulse >= 4962 then check N_13DE else check N_1312
N_1312		DW	$1312	$7F7F	$0000		;if pulse >= 4882 then the result is 7F else check N_1271
N_1271		DW	$1271	$5F5F	$0000		;if pulse >= 4721 then the result is 5F else the result is 7F 
		DW	$0000
N_13DE		DW	$13DE	$7D7D	N_15D5		;if pulse >= 5086 then check N_15D5 else check N_1380
N_1380		DW	$1380	$3D3D	$0000		;if pulse >= 4992 then the result is 3D else the result is 3F 
		DW	$0000
N_15D5		DW	$15D5	$5D5D	$0000		;if pulse >= 5589 then the result is 5D else the result is 7D 
		DW	$0000
N_1898		DW	$1898	$3737	N_1ADD		;if pulse >= 6296 then check N_1ADD else check N_1692
N_1692		DW	$1692	$6F6F	N_1786		;if pulse >= 5778 then check N_1786 else check N_1676
N_1676		DW	$1676	$3F3F	N_1679		;if pulse >= 5750 then check N_1679 else check N_160A
N_160A		DW	$160A	$1F1F	$0000		;if pulse >= 5642 then the result is 1F else the result is 1D 
		DW	$0000
N_1679		DW	$1679	$7F7F	$0000		;if pulse >= 5753 then the result is 7F else the result is 3F 
		DW	$0000
N_1786		DW	$1786	$7F7F	N_1787		;if pulse >= 6022 then check N_1787 else the result is 6F
		DW	$0000
N_1787		DW	$1787	$7777	$0000		;if pulse >= 6023 then the result is 77 else the result is 7F 
		DW	$0000
N_1ADD		DW	$1ADD	$3F3F	N_1C9C		;if pulse >= 6877 then check N_1C9C else check N_18F3
N_18F3		DW	$18F3	$3B3B	N_19DA		;if pulse >= 6387 then check N_19DA else check N_18CF
N_18CF		DW	$18CF	$3F3F	$0000		;if pulse >= 6351 then the result is 3F else the result is 37 
		DW	$0000
N_19DA		DW	$19DA	$3B3B	$0000		;if pulse >= 6618 then the result is 3B else check N_1939
N_1939		DW	$1939	$1B1B	$0000		;if pulse >= 6457 then the result is 1B else the result is 3B 
		DW	$0000
N_1C9C		DW	$1C9C	$3F3F	N_1C9D		;if pulse >= 7324 then check N_1C9D else check N_1BA9
N_1BA9		DW	$1BA9	$2F2F	$0000		;if pulse >= 7081 then the result is 2F else the result is 3F 
		DW	$0000
N_1C9D		DW	$1C9D	$1F1F	$0000		;if pulse >= 7325 then the result is 1F else the result is 3F 
		DW	$0000
N_2F56		DW	$2F56	$1D1D	N_4098		;if pulse >= 12118 then check N_4098 else check N_251A
N_251A		DW	$251A	$1F1F	N_2BDE		;if pulse >= 9498 then check N_2BDE else check N_20BF
N_20BF		DW	$20BF	$0E0E	N_21B2		;if pulse >= 8383 then check N_21B2 else check N_1E5F
N_1E5F		DW	$1E5F	$3636	N_1FA7		;if pulse >= 7775 then check N_1FA7 else check N_1D56
N_1D56		DW	$1D56	$3E3E	$0000		;if pulse >= 7510 then the result is 3E else the result is 3F 
		DW	$0000
N_1FA7		DW	$1FA7	$3E3E	N_2001		;if pulse >= 8103 then check N_2001 else the result is 36
		DW	$0000
N_2001		DW	$2001	$1E1E	$0000		;if pulse >= 8193 then the result is 1E else the result is 3E 
		DW	$0000
N_21B2		DW	$21B2	$1D1D	N_239A		;if pulse >= 8626 then check N_239A else check N_2129
N_2129		DW	$2129	$0D0D	$0000		;if pulse >= 8489 then the result is 0D else check N_2110
N_2110		DW	$2110	$0C0C	$0000		;if pulse >= 8464 then the result is 0C else the result is 0E 
		DW	$0000
N_239A		DW	$239A	$1B1B	$0000		;if pulse >= 9114 then the result is 1B else check N_232F
N_232F		DW	$232F	$1919	$0000		;if pulse >= 9007 then the result is 19 else the result is 1D 
		DW	$0000
N_2BDE		DW	$2BDE	$1F1F	N_2D57		;if pulse >= 11230 then check N_2D57 else check N_267F
N_267F		DW	$267F	$0F0F	N_26C8		;if pulse >= 9855 then check N_26C8 else check N_2538
N_2538		DW	$2538	$1717	N_25D5		;if pulse >= 9528 then check N_25D5 else the result is 1F
		DW	$0000
N_25D5		DW	$25D5	$0707	$0000		;if pulse >= 9685 then the result is 07 else the result is 17 
		DW	$0000
N_26C8		DW	$26C8	$1F1F	N_2AEB		;if pulse >= 9928 then check N_2AEB else the result is 0F
		DW	$0000
N_2AEB		DW	$2AEB	$0F0F	$0000		;if pulse >= 10987 then the result is 0F else the result is 1F 
		DW	$0000
N_2D57		DW	$2D57	$1F1F	N_2D6B		;if pulse >= 11607 then check N_2D6B else check N_2C10
N_2C10		DW	$2C10	$1717	$0000		;if pulse >= 11280 then the result is 17 else the result is 1F 
		DW	$0000
N_2D6B		DW	$2D6B	$1B1B	N_2EA0		;if pulse >= 11627 then check N_2EA0 else the result is 1F
		DW	$0000
N_2EA0		DW	$2EA0	$1919	$0000		;if pulse >= 11936 then the result is 19 else the result is 1B 
		DW	$0000
N_4098		DW	$4098	$0707	N_5846		;if pulse >= 16536 then check N_5846 else check N_37A8
N_37A8		DW	$37A8	$0B0B	N_3B07		;if pulse >= 14248 then check N_3B07 else check N_31BF
N_31BF		DW	$31BF	$0E0E	N_342F		;if pulse >= 12735 then check N_342F else check N_312A
N_312A		DW	$312A	$0F0F	$0000		;if pulse >= 12586 then the result is 0F else check N_3001
N_3001		DW	$3001	$0D0D	$0000		;if pulse >= 12289 then the result is 0D else the result is 1D 
		DW	$0000
N_342F		DW	$342F	$0E0E	N_3591		;if pulse >= 13359 then check N_3591 else check N_32E8
N_32E8		DW	$32E8	$0606	$0000		;if pulse >= 13032 then the result is 06 else the result is 0E 
		DW	$0000
N_3591		DW	$3591	$0F0F	$0000		;if pulse >= 13713 then the result is 0F else the result is 0E 
		DW	$0000
N_3B07		DW	$3B07	$0F0F	N_3EBB		;if pulse >= 15111 then check N_3EBB else check N_3992
N_3992		DW	$3992	$0F0F	N_39C0		;if pulse >= 14738 then check N_39C0 else the result is 0B
		DW	$0000
N_39C0		DW	$39C0	$0707	$0000		;if pulse >= 14784 then the result is 07 else the result is 0F 
		DW	$0000
N_3EBB		DW	$3EBB	$0F0F	$0000		;if pulse >= 16059 then the result is 0F else check N_3C30
N_3C30		DW	$3C30	$0D0D	$0000		;if pulse >= 15408 then the result is 0D else the result is 0F 
		DW	$0000
N_5846		DW	$5846	$0505	N_64E1		;if pulse >= 22598 then check N_64E1 else check N_49FA
N_49FA		DW	$49FA	$0505	N_4E0A		;if pulse >= 18938 then check N_4E0A else check N_43CE
N_43CE		DW	$43CE	$0707	N_4627		;if pulse >= 17358 then check N_4627 else check N_41E4
N_41E4		DW	$41E4	$0303	$0000		;if pulse >= 16868 then the result is 03 else the result is 07 
		DW	$0000
N_4627		DW	$4627	$0606	N_49C1		;if pulse >= 17959 then check N_49C1 else the result is 07
		DW	$0000
N_49C1		DW	$49C1	$0404	$0000		;if pulse >= 18881 then the result is 04 else the result is 06 
		DW	$0000
N_4E0A		DW	$4E0A	$0707	N_565C		;if pulse >= 19978 then check N_565C else check N_4C4B
N_4C4B		DW	$4C4B	$0303	$0000		;if pulse >= 19531 then the result is 03 else check N_4C20
N_4C20		DW	$4C20	$0101	$0000		;if pulse >= 19488 then the result is 01 else the result is 05 
		DW	$0000
N_565C		DW	$565C	$0303	N_5751		;if pulse >= 22108 then check N_5751 else the result is 07
		DW	$0000
N_5751		DW	$5751	$0101	$0000		;if pulse >= 22353 then the result is 01 else the result is 03 
		DW	$0000
N_64E1		DW	$64E1	$0101	N_74FB		;if pulse >= 25825 then check N_74FB else check N_5A8F
N_5A8F		DW	$5A8F	$0606	N_5E62		;if pulse >= 23183 then check N_5E62 else check N_59DB
N_59DB		DW	$59DB	$0707	$0000		;if pulse >= 23003 then the result is 07 else the result is 05 
		DW	$0000
N_5E62		DW	$5E62	$0707	N_6098		;if pulse >= 24162 then check N_6098 else the result is 06
		DW	$0000
N_6098		DW	$6098	$0303	$0000		;if pulse >= 24728 then the result is 03 else the result is 07 
		DW	$0000
N_74FB		DW	$74FB	$0303	N_8733		;if pulse >= 29947 then check N_8733 else check N_676B
N_676B		DW	$676B	$0303	N_6EF8		;if pulse >= 26475 then check N_6EF8 else the result is 01
		DW	$0000
N_6EF8		DW	$6EF8	$0202	N_72CA		;if pulse >= 28408 then check N_72CA else the result is 03
		DW	$0000
N_72CA		DW	$72CA	$0101	$0000		;if pulse >= 29386 then the result is 01 else check N_7271
N_7271		DW	$7271	$0000	$0000		;if pulse >= 29297 then the result is 00 else the result is 02 
		DW	$0000
N_8733		DW	$8733	$0101	N_9B9B		;if pulse >= 34611 then check N_9B9B else check N_8002
N_8002		DW	$8002	$0101	N_8360		;if pulse >= 32770 then check N_8360 else the result is 03
		DW	$0000
N_8360		DW	$8360	$0000	$0000		;if pulse >= 33632 then the result is 00 else the result is 01 
		DW	$0000
N_9B9B		DW	$9B9B	$0101	N_B003		;if pulse >= 39835 then check N_B003 else check N_97C8
N_97C8		DW	$97C8	$0000	$0000		;if pulse >= 38856 then the result is 00 else the result is 01 
		DW	$0000
N_B003		DW	$B003	$0101	N_C099		;if pulse >= 45059 then check N_C099 else check N_AC31
N_AC31		DW	$AC31	$0000	$0000		;if pulse >= 44081 then the result is 00 else the result is 01 
		DW	$0000
N_C099		DW	$C099	$0000	$0000		;if pulse >= 49305 then the result is 00 else the result is 01 
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
;#    412 ( 19C)      1 . . . . . . . (80)     11      3       37
;#    633 ( 279)      1 1 . . . . . . (C0)     18      2       35
;#    824 ( 338)      1 1 1 . . . . . (E0)     22      3       44
;#   1236 ( 4D4)      1 1 1 1 . . . . (F0)     19      1       35
;#   1664 ( 680)      1 1 1 1 1 . . . (F8)     14      3       44
;#   2489 ( 9B9)      1 1 1 1 1 1 . . (FC)      6      2       52
;#   3298 ( CE2)      1 1 1 1 1 1 1 . (FE)      7      4       61
;#   4963 (1363)      1 1 1 1 1 1 1 1 (FF)      8      3       51
;#
;#   |
;#   |
;#   4
;#   D
;# +-4-+
;# |   |
;# |   |
;# 2   9
;# 7   B
;#+9+ +9+
;#| | | |
;#| | | 1
;#1 3 6 3
;#9 3 8 6
;#C 8 0 3
;#      |
;#      |
;#      C
;#      E
;#      2
;#
N__4D4		DW	$04D4	$F0F0	N__9B9		;if pulse >= 1236 then check N__9B9 else check N__279
N__279		DW	$0279	$C0C0	N__338		;if pulse >= 633 then check N__338 else check N__19C
N__19C		DW	$019C	$8080	$0000		;if pulse >= 412 then the result is 80 else the result is 00 
		DW	$0000
N__338		DW	$0338	$E0E0	$0000		;if pulse >= 824 then the result is E0 else the result is C0 
		DW	$0000
N__9B9		DW	$09B9	$FCFC	N_1363		;if pulse >= 2489 then check N_1363 else check N__680
N__680		DW	$0680	$F8F8	$0000		;if pulse >= 1664 then the result is F8 else the result is F0 
		DW	$0000
N_1363		DW	$1363	$FFFF	$0000		;if pulse >= 4963 then the result is FF else check N__CE2
N__CE2		DW	$0CE2	$FEFE	$0000		;if pulse >= 3298 then the result is FE else the result is FC 
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
