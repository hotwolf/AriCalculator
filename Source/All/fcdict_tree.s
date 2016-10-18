#ifndef FCDICT_TREE_COMPILED
#define FCDICT_TREE_COMPILED
;###############################################################################
;# S12CForth - Search Tree for the Core Dictionary                             #
;###############################################################################
;#    Copyright 2009-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12(X) MCU        #
;#    families.                                                                #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#    This file contains a search tree for S12CForth CORE dictionary.          #
;#                                                                             #
;###############################################################################
;# Generated on Tue, Oct 18 2016                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> ! -----------------------> CF_STORE
;    $, ----------------------> CF_STRING_COMMA
;    ( -----------------------> CF_PAREN
;    + --> -------------------> CF_PLUS
;    |     ! -----------------> CF_PLUS_STORE
;    |     
;    - -----------------------> CF_MINUS
;    . --> $ -----------------> CF_DOT_STRING
;    |     RTERR -------------> CF_DOT_RTERR
;    |     S -----> ----------> CF_DOT_S
;    |              YNERR ----> CF_DOT_SYNERR
;    |     

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;Global constants
#ifndef      NULL
NULL                    EQU     
#endif

;Tree depth
FCDICT_TREE_DEPTH       EQU     12

;First CF
FCDICT_FIRST_CF         EQU     CF_STORE

;Character count of the first word
FCDICT_FIRST_CC         EQU     1                               ;"!"

;###############################################################################
;# Macros                                                                      #
;###############################################################################

;Dictionary tree
#macro       FCDICT_TREE, 0
;Local constants
EMPTY_STRING            EQU     $00
BRANCH                  EQU     $00
END_OF_BRANCH           EQU     $00
;Root
FCDICT_TREE             FCS     "!"
                        DW      CF_STORE                        ;-> !
                        FCS     "$,"
                        DW      CF_STRING_COMMA                 ;-> $,
                        FCS     "("
                        DW      CF_PAREN                        ;-> (
                        FCS     "+"
                        DB      BRANCH
                        DW      FCDICT_TREE_3                   ;+...
                        FCS     "-"
                        DW      CF_MINUS                        ;-> -
                        FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_5                   ;....
                        FCS     "0"
                        DB      BRANCH
                        DW      FCDICT_TREE_6                   ;0...
                        FCS     "1"
                        DB      BRANCH
                        DW      FCDICT_TREE_7                   ;1...
                        FCS     "2"
                        DB      BRANCH
                        DW      FCDICT_TREE_8                   ;2...
                        FCS     "<"
                        DB      BRANCH
                        DW      FCDICT_TREE_9                   ;<...
                        FCS     "="
                        DB      BRANCH
                        DW      FCDICT_TREE_10                  ;=...
                        FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_11                  ;>...
                        FCS     "?"
                        DB      BRANCH
                        DW      FCDICT_TREE_12                  ;?...
                        FCS     "@"
                        DB      BRANCH
                        DW      FCDICT_TREE_13                  ;@...
                        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_14                  ;A...
                        FCS     "B"
                        DB      BRANCH
                        DW      FCDICT_TREE_15                  ;B...
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_16                  ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_17                  ;D...
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_18                  ;E...
                        FCS     "F"
                        DB      BRANCH
                        DW      FCDICT_TREE_19                  ;F...
                        FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_20                  ;H...
                        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_21                  ;I...
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_22                  ;L...
                        FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_23                  ;M...
                        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_24                  ;N...
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_25                  ;O...
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_26                  ;P...
                        FCS     "Q"
                        DB      BRANCH
                        DW      FCDICT_TREE_27                  ;Q...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_28                  ;R...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_29                  ;S...
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_30                  ;T...
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_31                  ;U...
                        FCS     "W"
                        DB      BRANCH
                        DW      FCDICT_TREE_32                  ;W...
                        FCS     "X"
                        DB      BRANCH
                        DW      FCDICT_TREE_33                  ;X...
                        ;DB     END_OF_BRANCH
;Subtree 3 =>           "+"     -> FCDICT_TREE+85
FCDICT_TREE_3           DB      EMPTY_STRING
                        DW      CF_PLUS                         ;-> +
                        FCS     "!"
                        DW      CF_PLUS_STORE                   ;-> +!
                        DB      END_OF_BRANCH
;Subtree 5 =>           "."     -> FCDICT_TREE+8C
FCDICT_TREE_5           FCS     "$"
                        DW      CF_DOT_STRING                   ;-> .$
                        FCS     "RTERR"
                        DW      CF_DOT_RTERR                    ;-> .RTERR
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_5_2                 ;.S...
                        ;DB     END_OF_BRANCH
;Subtree 5->2 =>        ".S"    -> FCDICT_TREE+9A
FCDICT_TREE_5_2         DB      EMPTY_STRING
                        DW      CF_DOT_S                        ;-> .S
                        FCS     "YNERR"
                        DW      CF_DOT_SYNERR                   ;-> .SYNERR
                        DB      END_OF_BRANCH
;Subtree 6 =>           "0"     -> FCDICT_TREE+A5
FCDICT_TREE_6           FCS     "<"
                        DB      BRANCH
                        DW      FCDICT_TREE_6_0                 ;0<...
                        FCS     "="
                        DB      BRANCH
                        DW      FCDICT_TREE_6_1                 ;0=...
                        ;DB     END_OF_BRANCH
;Subtree 6->0 =>        "0<"    -> FCDICT_TREE+AD
FCDICT_TREE_6_0         DB      EMPTY_STRING
                        DW      CF_ZERO_LESS                    ;-> 0<
                        DB      END_OF_BRANCH
;Subtree 6->1 =>        "0="    -> FCDICT_TREE+B1
FCDICT_TREE_6_1         DB      EMPTY_STRING
                        DW      CF_ZERO_EQUALS                  ;-> 0=
                        DB      END_OF_BRANCH
;Subtree 7 =>           "1"     -> FCDICT_TREE+B5
FCDICT_TREE_7           FCS     "+"
                        DB      BRANCH
                        DW      FCDICT_TREE_7_0                 ;1+...
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_7_1                 ;1-...
                        ;DB     END_OF_BRANCH
;Subtree 7->0 =>        "1+"    -> FCDICT_TREE+BD
FCDICT_TREE_7_0         DB      EMPTY_STRING
                        DW      CF_ONE_PLUS                     ;-> 1+
                        DB      END_OF_BRANCH
;Subtree 7->1 =>        "1-"    -> FCDICT_TREE+C1
FCDICT_TREE_7_1         DB      EMPTY_STRING
                        DW      CF_ONE_MINUS                    ;-> 1-
                        DB      END_OF_BRANCH
;Subtree 8 =>           "2"     -> FCDICT_TREE+C5
FCDICT_TREE_8           FCS     "!"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_0                 ;2!...
                        FCS     "*"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_1                 ;2*...
                        FCS     "/"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_2                 ;2/...
                        FCS     "@"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_3                 ;2@...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_4                 ;2D...
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_5                 ;2O...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_6                 ;2R...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_7                 ;2S...
                        ;DB     END_OF_BRANCH
;Subtree 8->0 =>        "2!"    -> FCDICT_TREE+E5
FCDICT_TREE_8_0         DB      EMPTY_STRING
                        DW      CF_TWO_STORE                    ;-> 2!
                        DB      END_OF_BRANCH
;Subtree 8->1 =>        "2*"    -> FCDICT_TREE+E9
FCDICT_TREE_8_1         DB      EMPTY_STRING
                        DW      CF_TWO_STAR                     ;-> 2*
                        DB      END_OF_BRANCH
;Subtree 8->2 =>        "2/"    -> FCDICT_TREE+ED
FCDICT_TREE_8_2         DB      EMPTY_STRING
                        DW      CF_TWO_SLASH                    ;-> 2/
                        DB      END_OF_BRANCH
;Subtree 8->3 =>        "2@"    -> FCDICT_TREE+F1
FCDICT_TREE_8_3         DB      EMPTY_STRING
                        DW      CF_TWO_FETCH                    ;-> 2@
                        DB      END_OF_BRANCH
;Subtree 8->4 =>        "2D"    -> FCDICT_TREE+F5
FCDICT_TREE_8_4         FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_4_0               ;2DR...
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_4_1               ;2DU...
                        DB      END_OF_BRANCH
;Subtree 8->4->0 =>     "2DR"   -> FCDICT_TREE+FE
FCDICT_TREE_8_4_0       FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_4_0_0             ;2DRO...
                        DB      END_OF_BRANCH
;Subtree 8->4->0->0 =>  "2DRO"  -> FCDICT_TREE+103
FCDICT_TREE_8_4_0_0     FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_4_0_0_0           ;2DROP...
                        ;DB     END_OF_BRANCH
;Subtree 8->4->0->0->0 =>"2DROP" -> FCDICT_TREE+107
FCDICT_TREE_8_4_0_0_0   DB      EMPTY_STRING
                        DW      CF_TWO_DROP                     ;-> 2DROP
                        DB      END_OF_BRANCH
;Subtree 8->4->1 =>     "2DU"   -> FCDICT_TREE+10B
FCDICT_TREE_8_4_1       FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_4_1_0             ;2DUP...
                        ;DB     END_OF_BRANCH
;Subtree 8->4->1->0 =>  "2DUP"  -> FCDICT_TREE+10F
FCDICT_TREE_8_4_1_0     DB      EMPTY_STRING
                        DW      CF_TWO_DUP                      ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 8->5 =>        "2O"    -> FCDICT_TREE+113
FCDICT_TREE_8_5         FCS     "V"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_5_0               ;2OV...
                        DB      END_OF_BRANCH
;Subtree 8->5->0 =>     "2OV"   -> FCDICT_TREE+118
FCDICT_TREE_8_5_0       FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_5_0_0             ;2OVE...
                        DB      END_OF_BRANCH
;Subtree 8->5->0->0 =>  "2OVE"  -> FCDICT_TREE+11D
FCDICT_TREE_8_5_0_0     FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_5_0_0_0           ;2OVER...
                        ;DB     END_OF_BRANCH
;Subtree 8->5->0->0->0 =>"2OVER" -> FCDICT_TREE+121
FCDICT_TREE_8_5_0_0_0   DB      EMPTY_STRING
                        DW      CF_TWO_OVER                     ;-> 2OVER
                        DB      END_OF_BRANCH
;Subtree 8->6 =>        "2R"    -> FCDICT_TREE+125
FCDICT_TREE_8_6         FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_6_0               ;2RO...
                        DB      END_OF_BRANCH
;Subtree 8->6->0 =>     "2RO"   -> FCDICT_TREE+12A
FCDICT_TREE_8_6_0       FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_6_0_0             ;2ROT...
                        ;DB     END_OF_BRANCH
;Subtree 8->6->0->0 =>  "2ROT"  -> FCDICT_TREE+12E
FCDICT_TREE_8_6_0_0     DB      EMPTY_STRING
                        DW      CF_2ROT                         ;-> 2ROT
                        DB      END_OF_BRANCH
;Subtree 8->7 =>        "2S"    -> FCDICT_TREE+132
FCDICT_TREE_8_7         FCS     "W"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_7_0               ;2SW...
                        DB      END_OF_BRANCH
;Subtree 8->7->0 =>     "2SW"   -> FCDICT_TREE+137
FCDICT_TREE_8_7_0       FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_7_0_0             ;2SWA...
                        DB      END_OF_BRANCH
;Subtree 8->7->0->0 =>  "2SWA"  -> FCDICT_TREE+13C
FCDICT_TREE_8_7_0_0     FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_7_0_0_0           ;2SWAP...
                        ;DB     END_OF_BRANCH
;Subtree 8->7->0->0->0 =>"2SWAP" -> FCDICT_TREE+140
FCDICT_TREE_8_7_0_0_0   DB      EMPTY_STRING
                        DW      CF_TWO_SWAP                     ;-> 2SWAP
                        DB      END_OF_BRANCH
;Subtree 9 =>           "<"     -> FCDICT_TREE+144
FCDICT_TREE_9           DB      EMPTY_STRING
                        DW      CF_LESS_THAN                    ;-> <
                        DB      END_OF_BRANCH
;Subtree 10 =>          "="     -> FCDICT_TREE+148
FCDICT_TREE_10          DB      EMPTY_STRING
                        DW      CF_EQUALS                       ;-> =
                        DB      END_OF_BRANCH
;Subtree 11 =>          ">"     -> FCDICT_TREE+14C
FCDICT_TREE_11          DB      EMPTY_STRING
                        DW      CF_GREATER_THAN                 ;-> >
                        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_11_1                ;>I...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_11_2                ;>R...
                        ;DB     END_OF_BRANCH
;Subtree 11->2 =>       ">R"    -> FCDICT_TREE+157
FCDICT_TREE_11_2        DB      EMPTY_STRING
                        DW      CF_TO_R                         ;-> >R
                        DB      END_OF_BRANCH
;Subtree 11->1 =>       ">I"    -> FCDICT_TREE+15B
FCDICT_TREE_11_1        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_11_1_0              ;>IN...
                        ;DB     END_OF_BRANCH
;Subtree 11->1->0 =>    ">IN"   -> FCDICT_TREE+15F
FCDICT_TREE_11_1_0      DB      EMPTY_STRING
                        DW      CF_TO_IN                        ;-> >IN
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_11_1_0_1            ;>INT...
                        ;DB     END_OF_BRANCH
;Subtree 11->1->0->1 => ">INT"  -> FCDICT_TREE+166
FCDICT_TREE_11_1_0_1    DB      EMPTY_STRING
                        DW      CF_TO_INT                       ;-> >INT
                        DB      END_OF_BRANCH
;Subtree 12 =>          "?"     -> FCDICT_TREE+16A
FCDICT_TREE_12          FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_12_0                ;?D...
                        DB      END_OF_BRANCH
;Subtree 12->0 =>       "?D"    -> FCDICT_TREE+16F
FCDICT_TREE_12_0        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_12_0_0              ;?DU...
                        DB      END_OF_BRANCH
;Subtree 12->0->0 =>    "?DU"   -> FCDICT_TREE+174
FCDICT_TREE_12_0_0      FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_12_0_0_0            ;?DUP...
                        ;DB     END_OF_BRANCH
;Subtree 12->0->0->0 => "?DUP"  -> FCDICT_TREE+178
FCDICT_TREE_12_0_0_0    DB      EMPTY_STRING
                        DW      CF_QUESTION_DUP                 ;-> ?DUP
                        DB      END_OF_BRANCH
;Subtree 13 =>          "@"     -> FCDICT_TREE+17C
FCDICT_TREE_13          DB      EMPTY_STRING
                        DW      CF_FETCH                        ;-> @
                        DB      END_OF_BRANCH
;Subtree 14 =>          "A"     -> FCDICT_TREE+180
FCDICT_TREE_14          FCS     "B"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_0                ;AB...
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_1                ;AL...
                        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_2                ;AN...
                        DB      END_OF_BRANCH
;Subtree 14->0 =>       "AB"    -> FCDICT_TREE+18D
FCDICT_TREE_14_0        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_0_0              ;ABO...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_0_1              ;ABS...
                        ;DB     END_OF_BRANCH
;Subtree 14->0->1 =>    "ABS"   -> FCDICT_TREE+195
FCDICT_TREE_14_0_1      DB      EMPTY_STRING
                        DW      CF_ABS                          ;-> ABS
                        DB      END_OF_BRANCH
;Subtree 14->0->0 =>    "ABO"   -> FCDICT_TREE+199
FCDICT_TREE_14_0_0      FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_0_0_0            ;ABOR...
                        DB      END_OF_BRANCH
;Subtree 14->0->0->0 => "ABOR"  -> FCDICT_TREE+19E
FCDICT_TREE_14_0_0_0    FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_0_0_0_0          ;ABORT...
                        ;DB     END_OF_BRANCH
;Subtree 14->0->0->0->0 =>"ABORT" -> FCDICT_TREE+1A2
FCDICT_TREE_14_0_0_0_0  DB      EMPTY_STRING
                        DW      CF_ABORT                        ;-> ABORT
                        FCS     '"'
                        DB      BRANCH
                        DW      FCDICT_TREE_14_0_0_0_0_1        ;ABORT"...
                        ;DB     END_OF_BRANCH
;Subtree 14->0->0->0->0->1 =>"ABORT""-> FCDICT_TREE+1A9
FCDICT_TREE_14_0_0_0_0_1 DB      EMPTY_STRING
                        DW      CF_ABORT_QUOTE                  ;-> ABORT"
                        DB      END_OF_BRANCH
;Subtree 14->1 =>       "AL"    -> FCDICT_TREE+1AD
FCDICT_TREE_14_1        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_1_0              ;ALI...
                        DB      END_OF_BRANCH
;Subtree 14->1->0 =>    "ALI"   -> FCDICT_TREE+1B2
FCDICT_TREE_14_1_0      FCS     "G"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_1_0_0            ;ALIG...
                        DB      END_OF_BRANCH
;Subtree 14->1->0->0 => "ALIG"  -> FCDICT_TREE+1B7
FCDICT_TREE_14_1_0_0    FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_1_0_0_0          ;ALIGN...
                        DB      END_OF_BRANCH
;Subtree 14->1->0->0->0 =>"ALIGN" -> FCDICT_TREE+1BC
FCDICT_TREE_14_1_0_0_0  FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_1_0_0_0_0        ;ALIGNE...
                        DB      END_OF_BRANCH
;Subtree 14->1->0->0->0->0 =>"ALIGNE"-> FCDICT_TREE+1C1
FCDICT_TREE_14_1_0_0_0_0 FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_1_0_0_0_0_0      ;ALIGNED...
                        ;DB     END_OF_BRANCH
;Subtree 14->1->0->0->0->0->0 =>"ALIGNED"-> FCDICT_TREE+1C5
FCDICT_TREE_14_1_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_ALIGNED                      ;-> ALIGNED
                        DB      END_OF_BRANCH
;Subtree 14->2 =>       "AN"    -> FCDICT_TREE+1C9
FCDICT_TREE_14_2        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_14_2_0              ;AND...
                        ;DB     END_OF_BRANCH
;Subtree 14->2->0 =>    "AND"   -> FCDICT_TREE+1CD
FCDICT_TREE_14_2_0      DB      EMPTY_STRING
                        DW      CF_AND                          ;-> AND
                        DB      END_OF_BRANCH
;Subtree 15 =>          "B"     -> FCDICT_TREE+1D1
FCDICT_TREE_15          FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_15_0                ;BA...
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_15_1                ;BL...
                        ;DB     END_OF_BRANCH
;Subtree 15->1 =>       "BL"    -> FCDICT_TREE+1D9
FCDICT_TREE_15_1        DB      EMPTY_STRING
                        DW      CF_BL                           ;-> BL
                        DB      END_OF_BRANCH
;Subtree 15->0 =>       "BA"    -> FCDICT_TREE+1DD
FCDICT_TREE_15_0        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_15_0_0              ;BAS...
                        DB      END_OF_BRANCH
;Subtree 15->0->0 =>    "BAS"   -> FCDICT_TREE+1E2
FCDICT_TREE_15_0_0      FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_15_0_0_0            ;BASE...
                        ;DB     END_OF_BRANCH
;Subtree 15->0->0->0 => "BASE"  -> FCDICT_TREE+1E6
FCDICT_TREE_15_0_0_0    DB      EMPTY_STRING
                        DW      CF_BASE                         ;-> BASE
                        DB      END_OF_BRANCH
;Subtree 16 =>          "C"     -> FCDICT_TREE+1EA
FCDICT_TREE_16          FCS     "!"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_0                ;C!...
                        FCS     "@"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_1                ;C@...
                        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_2                ;CA...
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_3                ;CE...
                        FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_4                ;CH...
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_5                ;CL...
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6                ;CO...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_7                ;CR...
                        ;DB     END_OF_BRANCH
;Subtree 16->0 =>       "C!"    -> FCDICT_TREE+20A
FCDICT_TREE_16_0        DB      EMPTY_STRING
                        DW      CF_C_STORE                      ;-> C!
                        DB      END_OF_BRANCH
;Subtree 16->1 =>       "C@"    -> FCDICT_TREE+20E
FCDICT_TREE_16_1        DB      EMPTY_STRING
                        DW      CF_C_FETCH                      ;-> C@
                        DB      END_OF_BRANCH
;Subtree 16->2 =>       "CA"    -> FCDICT_TREE+212
FCDICT_TREE_16_2        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_2_0              ;CAT...
                        DB      END_OF_BRANCH
;Subtree 16->2->0 =>    "CAT"   -> FCDICT_TREE+217
FCDICT_TREE_16_2_0      FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_2_0_0            ;CATC...
                        DB      END_OF_BRANCH
;Subtree 16->2->0->0 => "CATC"  -> FCDICT_TREE+21C
FCDICT_TREE_16_2_0_0    FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_2_0_0_0          ;CATCH...
                        ;DB     END_OF_BRANCH
;Subtree 16->2->0->0->0 =>"CATCH" -> FCDICT_TREE+220
FCDICT_TREE_16_2_0_0_0  DB      EMPTY_STRING
                        DW      CF_CATCH                        ;-> CATCH
                        DB      END_OF_BRANCH
;Subtree 16->3 =>       "CE"    -> FCDICT_TREE+224
FCDICT_TREE_16_3        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_3_0              ;CEL...
                        DB      END_OF_BRANCH
;Subtree 16->3->0 =>    "CEL"   -> FCDICT_TREE+229
FCDICT_TREE_16_3_0      FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_3_0_0            ;CELL...
                        DB      END_OF_BRANCH
;Subtree 16->3->0->0 => "CELL"  -> FCDICT_TREE+22E
FCDICT_TREE_16_3_0_0    FCS     "+"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_3_0_0_0          ;CELL+...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_3_0_0_1          ;CELLS...
                        ;DB     END_OF_BRANCH
;Subtree 16->3->0->0->0 =>"CELL+" -> FCDICT_TREE+236
FCDICT_TREE_16_3_0_0_0  DB      EMPTY_STRING
                        DW      CF_CELL_PLUS                    ;-> CELL+
                        DB      END_OF_BRANCH
;Subtree 16->3->0->0->1 =>"CELLS" -> FCDICT_TREE+23A
FCDICT_TREE_16_3_0_0_1  DB      EMPTY_STRING
                        DW      CF_CELLS                        ;-> CELLS
                        DB      END_OF_BRANCH
;Subtree 16->4 =>       "CH"    -> FCDICT_TREE+23E
FCDICT_TREE_16_4        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_4_0              ;CHA...
                        DB      END_OF_BRANCH
;Subtree 16->4->0 =>    "CHA"   -> FCDICT_TREE+243
FCDICT_TREE_16_4_0      FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_4_0_0            ;CHAR...
                        DB      END_OF_BRANCH
;Subtree 16->4->0->0 => "CHAR"  -> FCDICT_TREE+248
FCDICT_TREE_16_4_0_0    FCS     "+"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_4_0_0_0          ;CHAR+...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_4_0_0_1          ;CHARS...
                        ;DB     END_OF_BRANCH
;Subtree 16->4->0->0->0 =>"CHAR+" -> FCDICT_TREE+250
FCDICT_TREE_16_4_0_0_0  DB      EMPTY_STRING
                        DW      CF_CHAR_PLUS                    ;-> CHAR+
                        DB      END_OF_BRANCH
;Subtree 16->4->0->0->1 =>"CHARS" -> FCDICT_TREE+254
FCDICT_TREE_16_4_0_0_1  DB      EMPTY_STRING
                        DW      CF_CHARS                        ;-> CHARS
                        DB      END_OF_BRANCH
;Subtree 16->5 =>       "CL"    -> FCDICT_TREE+258
FCDICT_TREE_16_5        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_5_0              ;CLS...
                        ;DB     END_OF_BRANCH
;Subtree 16->5->0 =>    "CLS"   -> FCDICT_TREE+25C
FCDICT_TREE_16_5_0      DB      EMPTY_STRING
                        DW      CF_CLS                          ;-> CLS
                        DB      END_OF_BRANCH
;Subtree 16->6 =>       "CO"    -> FCDICT_TREE+260
FCDICT_TREE_16_6        FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_0              ;COM...
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_1              ;COU...
                        DB      END_OF_BRANCH
;Subtree 16->6->0 =>    "COM"   -> FCDICT_TREE+269
FCDICT_TREE_16_6_0      FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_0_0            ;COMP...
                        DB      END_OF_BRANCH
;Subtree 16->6->0->0 => "COMP"  -> FCDICT_TREE+26E
FCDICT_TREE_16_6_0_0    FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_0_0_0          ;COMPI...
                        DB      END_OF_BRANCH
;Subtree 16->6->0->0->0 =>"COMPI" -> FCDICT_TREE+273
FCDICT_TREE_16_6_0_0_0  FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_0_0_0_0        ;COMPIL...
                        DB      END_OF_BRANCH
;Subtree 16->6->0->0->0->0 =>"COMPIL"-> FCDICT_TREE+278
FCDICT_TREE_16_6_0_0_0_0 FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_0_0_0_0_0      ;COMPILE...
                        DB      END_OF_BRANCH
;Subtree 16->6->0->0->0->0->0 =>"COMPILE"-> FCDICT_TREE+27D
FCDICT_TREE_16_6_0_0_0_0_0 FCS     ","
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_0_0_0_0_0_0    ;COMPILE,...
                        ;DB     END_OF_BRANCH
;Subtree 16->6->0->0->0->0->0->0 =>"COMPILE,"-> FCDICT_TREE+281
FCDICT_TREE_16_6_0_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_COMPILE_COMMA                ;-> COMPILE,
                        DB      END_OF_BRANCH
;Subtree 16->6->1 =>    "COU"   -> FCDICT_TREE+285
FCDICT_TREE_16_6_1      FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_1_0            ;COUN...
                        DB      END_OF_BRANCH
;Subtree 16->6->1->0 => "COUN"  -> FCDICT_TREE+28A
FCDICT_TREE_16_6_1_0    FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_6_1_0_0          ;COUNT...
                        ;DB     END_OF_BRANCH
;Subtree 16->6->1->0->0 =>"COUNT" -> FCDICT_TREE+28E
FCDICT_TREE_16_6_1_0_0  DB      EMPTY_STRING
                        DW      CF_COUNT                        ;-> COUNT
                        DB      END_OF_BRANCH
;Subtree 16->7 =>       "CR"    -> FCDICT_TREE+292
FCDICT_TREE_16_7        DB      EMPTY_STRING
                        DW      CF_CR                           ;-> CR
                        DB      END_OF_BRANCH
;Subtree 17 =>          "D"     -> FCDICT_TREE+296
FCDICT_TREE_17          FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0                ;DE...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_1                ;DR...
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_2                ;DU...
                        DB      END_OF_BRANCH
;Subtree 17->0 =>       "DE"    -> FCDICT_TREE+2A3
FCDICT_TREE_17_0        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_0              ;DEC...
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_1              ;DEP...
                        DB      END_OF_BRANCH
;Subtree 17->0->0 =>    "DEC"   -> FCDICT_TREE+2AC
FCDICT_TREE_17_0_0      FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_0_0            ;DECI...
                        DB      END_OF_BRANCH
;Subtree 17->0->0->0 => "DECI"  -> FCDICT_TREE+2B1
FCDICT_TREE_17_0_0_0    FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_0_0_0          ;DECIM...
                        DB      END_OF_BRANCH
;Subtree 17->0->0->0->0 =>"DECIM" -> FCDICT_TREE+2B6
FCDICT_TREE_17_0_0_0_0  FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_0_0_0_0        ;DECIMA...
                        DB      END_OF_BRANCH
;Subtree 17->0->0->0->0->0 =>"DECIMA"-> FCDICT_TREE+2BB
FCDICT_TREE_17_0_0_0_0_0 FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_0_0_0_0_0      ;DECIMAL...
                        ;DB     END_OF_BRANCH
;Subtree 17->0->0->0->0->0->0 =>"DECIMAL"-> FCDICT_TREE+2BF
FCDICT_TREE_17_0_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_DECIMAL                      ;-> DECIMAL
                        DB      END_OF_BRANCH
;Subtree 17->0->1 =>    "DEP"   -> FCDICT_TREE+2C3
FCDICT_TREE_17_0_1      FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_1_0            ;DEPT...
                        DB      END_OF_BRANCH
;Subtree 17->0->1->0 => "DEPT"  -> FCDICT_TREE+2C8
FCDICT_TREE_17_0_1_0    FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_0_1_0_0          ;DEPTH...
                        ;DB     END_OF_BRANCH
;Subtree 17->0->1->0->0 =>"DEPTH" -> FCDICT_TREE+2CC
FCDICT_TREE_17_0_1_0_0  DB      EMPTY_STRING
                        DW      CF_DEPTH                        ;-> DEPTH
                        DB      END_OF_BRANCH
;Subtree 17->1 =>       "DR"    -> FCDICT_TREE+2D0
FCDICT_TREE_17_1        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_1_0              ;DRO...
                        DB      END_OF_BRANCH
;Subtree 17->1->0 =>    "DRO"   -> FCDICT_TREE+2D5
FCDICT_TREE_17_1_0      FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_1_0_0            ;DROP...
                        ;DB     END_OF_BRANCH
;Subtree 17->1->0->0 => "DROP"  -> FCDICT_TREE+2D9
FCDICT_TREE_17_1_0_0    DB      EMPTY_STRING
                        DW      CF_DROP                         ;-> DROP
                        DB      END_OF_BRANCH
;Subtree 17->2 =>       "DU"    -> FCDICT_TREE+2DD
FCDICT_TREE_17_2        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_2_0              ;DUP...
                        ;DB     END_OF_BRANCH
;Subtree 17->2->0 =>    "DUP"   -> FCDICT_TREE+2E1
FCDICT_TREE_17_2_0      DB      EMPTY_STRING
                        DW      CF_DUP                          ;-> DUP
                        DB      END_OF_BRANCH
;Subtree 18 =>          "E"     -> FCDICT_TREE+2E5
FCDICT_TREE_18          FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_0                ;EM...
                        FCS     "X"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_1                ;EX...
                        DB      END_OF_BRANCH
;Subtree 18->0 =>       "EM"    -> FCDICT_TREE+2EE
FCDICT_TREE_18_0        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_0_0              ;EMI...
                        DB      END_OF_BRANCH
;Subtree 18->0->0 =>    "EMI"   -> FCDICT_TREE+2F3
FCDICT_TREE_18_0_0      FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_0_0_0            ;EMIT...
                        ;DB     END_OF_BRANCH
;Subtree 18->0->0->0 => "EMIT"  -> FCDICT_TREE+2F7
FCDICT_TREE_18_0_0_0    DB      EMPTY_STRING
                        DW      CF_EMIT                         ;-> EMIT
                        DB      END_OF_BRANCH
;Subtree 18->1 =>       "EX"    -> FCDICT_TREE+2FB
FCDICT_TREE_18_1        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_1_0              ;EXE...
                        DB      END_OF_BRANCH
;Subtree 18->1->0 =>    "EXE"   -> FCDICT_TREE+300
FCDICT_TREE_18_1_0      FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_1_0_0            ;EXEC...
                        DB      END_OF_BRANCH
;Subtree 18->1->0->0 => "EXEC"  -> FCDICT_TREE+305
FCDICT_TREE_18_1_0_0    FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_1_0_0_0          ;EXECU...
                        DB      END_OF_BRANCH
;Subtree 18->1->0->0->0 =>"EXECU" -> FCDICT_TREE+30A
FCDICT_TREE_18_1_0_0_0  FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_1_0_0_0_0        ;EXECUT...
                        DB      END_OF_BRANCH
;Subtree 18->1->0->0->0->0 =>"EXECUT"-> FCDICT_TREE+30F
FCDICT_TREE_18_1_0_0_0_0 FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_1_0_0_0_0_0      ;EXECUTE...
                        ;DB     END_OF_BRANCH
;Subtree 18->1->0->0->0->0->0 =>"EXECUTE"-> FCDICT_TREE+313
FCDICT_TREE_18_1_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_EXECUTE                      ;-> EXECUTE
                        DB      END_OF_BRANCH
;Subtree 19 =>          "F"     -> FCDICT_TREE+317
FCDICT_TREE_19          FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_19_0                ;FA...
                        DB      END_OF_BRANCH
;Subtree 19->0 =>       "FA"    -> FCDICT_TREE+31C
FCDICT_TREE_19_0        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_19_0_0              ;FAL...
                        DB      END_OF_BRANCH
;Subtree 19->0->0 =>    "FAL"   -> FCDICT_TREE+321
FCDICT_TREE_19_0_0      FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_19_0_0_0            ;FALS...
                        DB      END_OF_BRANCH
;Subtree 19->0->0->0 => "FALS"  -> FCDICT_TREE+326
FCDICT_TREE_19_0_0_0    FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_19_0_0_0_0          ;FALSE...
                        ;DB     END_OF_BRANCH
;Subtree 19->0->0->0->0 =>"FALSE" -> FCDICT_TREE+32A
FCDICT_TREE_19_0_0_0_0  DB      EMPTY_STRING
                        DW      CF_FALSE                        ;-> FALSE
                        DB      END_OF_BRANCH
;Subtree 20 =>          "H"     -> FCDICT_TREE+32E
FCDICT_TREE_20          FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_20_0                ;HE...
                        DB      END_OF_BRANCH
;Subtree 20->0 =>       "HE"    -> FCDICT_TREE+333
FCDICT_TREE_20_0        FCS     "X"
                        DB      BRANCH
                        DW      FCDICT_TREE_20_0_0              ;HEX...
                        ;DB     END_OF_BRANCH
;Subtree 20->0->0 =>    "HEX"   -> FCDICT_TREE+337
FCDICT_TREE_20_0_0      DB      EMPTY_STRING
                        DW      CF_HEX                          ;-> HEX
                        DB      END_OF_BRANCH
;Subtree 21 =>          "I"     -> FCDICT_TREE+33B
FCDICT_TREE_21          FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_21_0                ;IN...
                        DB      END_OF_BRANCH
;Subtree 21->0 =>       "IN"    -> FCDICT_TREE+340
FCDICT_TREE_21_0        FCS     "V"
                        DB      BRANCH
                        DW      FCDICT_TREE_21_0_0              ;INV...
                        DB      END_OF_BRANCH
;Subtree 21->0->0 =>    "INV"   -> FCDICT_TREE+345
FCDICT_TREE_21_0_0      FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_21_0_0_0            ;INVE...
                        DB      END_OF_BRANCH
;Subtree 21->0->0->0 => "INVE"  -> FCDICT_TREE+34A
FCDICT_TREE_21_0_0_0    FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_21_0_0_0_0          ;INVER...
                        DB      END_OF_BRANCH
;Subtree 21->0->0->0->0 =>"INVER" -> FCDICT_TREE+34F
FCDICT_TREE_21_0_0_0_0  FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_21_0_0_0_0_0        ;INVERT...
                        ;DB     END_OF_BRANCH
;Subtree 21->0->0->0->0->0 =>"INVERT"-> FCDICT_TREE+353
FCDICT_TREE_21_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_INVERT                       ;-> INVERT
                        DB      END_OF_BRANCH
;Subtree 22 =>          "L"     -> FCDICT_TREE+357
FCDICT_TREE_22          FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_0                ;LI...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_1                ;LS...
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_2                ;LU...
                        ;DB     END_OF_BRANCH
;Subtree 22->2 =>       "LU"    -> FCDICT_TREE+363
FCDICT_TREE_22_2        DB      EMPTY_STRING
                        DW      CF_LU                           ;-> LU
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_2_1              ;LU-...
                        DB      END_OF_BRANCH
;Subtree 22->2->1 =>    "LU-"   -> FCDICT_TREE+36B
FCDICT_TREE_22_2_1      FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_2_1_0            ;LU-C...
                        DB      END_OF_BRANCH
;Subtree 22->2->1->0 => "LU-C"  -> FCDICT_TREE+370
FCDICT_TREE_22_2_1_0    FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_2_1_0_0          ;LU-CD...
                        DB      END_OF_BRANCH
;Subtree 22->2->1->0->0 =>"LU-CD" -> FCDICT_TREE+375
FCDICT_TREE_22_2_1_0_0  FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_2_1_0_0_0        ;LU-CDI...
                        DB      END_OF_BRANCH
;Subtree 22->2->1->0->0->0 =>"LU-CDI"-> FCDICT_TREE+37A
FCDICT_TREE_22_2_1_0_0_0 FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_2_1_0_0_0_0      ;LU-CDIC...
                        DB      END_OF_BRANCH
;Subtree 22->2->1->0->0->0->0 =>"LU-CDIC"-> FCDICT_TREE+37F
FCDICT_TREE_22_2_1_0_0_0_0 FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_2_1_0_0_0_0_0    ;LU-CDICT...
                        ;DB     END_OF_BRANCH
;Subtree 22->2->1->0->0->0->0->0 =>"LU-CDICT"-> FCDICT_TREE+383
FCDICT_TREE_22_2_1_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_LU_CDICT                     ;-> LU-CDICT
                        DB      END_OF_BRANCH
;Subtree 22->0 =>       "LI"    -> FCDICT_TREE+387
FCDICT_TREE_22_0        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_0_0              ;LIT...
                        DB      END_OF_BRANCH
;Subtree 22->0->0 =>    "LIT"   -> FCDICT_TREE+38C
FCDICT_TREE_22_0_0      FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_0_0_0            ;LITE...
                        DB      END_OF_BRANCH
;Subtree 22->0->0->0 => "LITE"  -> FCDICT_TREE+391
FCDICT_TREE_22_0_0_0    FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_0_0_0_0          ;LITER...
                        DB      END_OF_BRANCH
;Subtree 22->0->0->0->0 =>"LITER" -> FCDICT_TREE+396
FCDICT_TREE_22_0_0_0_0  FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_0_0_0_0_0        ;LITERA...
                        DB      END_OF_BRANCH
;Subtree 22->0->0->0->0->0 =>"LITERA"-> FCDICT_TREE+39B
FCDICT_TREE_22_0_0_0_0_0 FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_0_0_0_0_0_0      ;LITERAL...
                        ;DB     END_OF_BRANCH
;Subtree 22->0->0->0->0->0->0 =>"LITERAL"-> FCDICT_TREE+39F
FCDICT_TREE_22_0_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_LITERAL                      ;-> LITERAL
                        DB      END_OF_BRANCH
;Subtree 22->1 =>       "LS"    -> FCDICT_TREE+3A3
FCDICT_TREE_22_1        FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_1_0              ;LSH...
                        DB      END_OF_BRANCH
;Subtree 22->1->0 =>    "LSH"   -> FCDICT_TREE+3A8
FCDICT_TREE_22_1_0      FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_1_0_0            ;LSHI...
                        DB      END_OF_BRANCH
;Subtree 22->1->0->0 => "LSHI"  -> FCDICT_TREE+3AD
FCDICT_TREE_22_1_0_0    FCS     "F"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_1_0_0_0          ;LSHIF...
                        DB      END_OF_BRANCH
;Subtree 22->1->0->0->0 =>"LSHIF" -> FCDICT_TREE+3B2
FCDICT_TREE_22_1_0_0_0  FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_1_0_0_0_0        ;LSHIFT...
                        ;DB     END_OF_BRANCH
;Subtree 22->1->0->0->0->0 =>"LSHIFT"-> FCDICT_TREE+3B6
FCDICT_TREE_22_1_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_L_SHIFT                      ;-> LSHIFT
                        DB      END_OF_BRANCH
;Subtree 23 =>          "M"     -> FCDICT_TREE+3BA
FCDICT_TREE_23          FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_23_0                ;MA...
                        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_23_1                ;MI...
                        DB      END_OF_BRANCH
;Subtree 23->0 =>       "MA"    -> FCDICT_TREE+3C3
FCDICT_TREE_23_0        FCS     "X"
                        DB      BRANCH
                        DW      FCDICT_TREE_23_0_0              ;MAX...
                        ;DB     END_OF_BRANCH
;Subtree 23->0->0 =>    "MAX"   -> FCDICT_TREE+3C7
FCDICT_TREE_23_0_0      DB      EMPTY_STRING
                        DW      CF_MAX                          ;-> MAX
                        DB      END_OF_BRANCH
;Subtree 23->1 =>       "MI"    -> FCDICT_TREE+3CB
FCDICT_TREE_23_1        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_23_1_0              ;MIN...
                        ;DB     END_OF_BRANCH
;Subtree 23->1->0 =>    "MIN"   -> FCDICT_TREE+3CF
FCDICT_TREE_23_1_0      DB      EMPTY_STRING
                        DW      CF_MIN                          ;-> MIN
                        DB      END_OF_BRANCH
;Subtree 24 =>          "N"     -> FCDICT_TREE+3D3
FCDICT_TREE_24          FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_0                ;NE...
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_1                ;NO...
                        DB      END_OF_BRANCH
;Subtree 24->0 =>       "NE"    -> FCDICT_TREE+3DC
FCDICT_TREE_24_0        FCS     "G"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_0_0              ;NEG...
                        DB      END_OF_BRANCH
;Subtree 24->0->0 =>    "NEG"   -> FCDICT_TREE+3E1
FCDICT_TREE_24_0_0      FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_0_0_0            ;NEGA...
                        DB      END_OF_BRANCH
;Subtree 24->0->0->0 => "NEGA"  -> FCDICT_TREE+3E6
FCDICT_TREE_24_0_0_0    FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_0_0_0_0          ;NEGAT...
                        DB      END_OF_BRANCH
;Subtree 24->0->0->0->0 =>"NEGAT" -> FCDICT_TREE+3EB
FCDICT_TREE_24_0_0_0_0  FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_0_0_0_0_0        ;NEGATE...
                        ;DB     END_OF_BRANCH
;Subtree 24->0->0->0->0->0 =>"NEGATE"-> FCDICT_TREE+3EF
FCDICT_TREE_24_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_NEGATE                       ;-> NEGATE
                        DB      END_OF_BRANCH
;Subtree 24->1 =>       "NO"    -> FCDICT_TREE+3F3
FCDICT_TREE_24_1        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_1_0              ;NOP...
                        ;DB     END_OF_BRANCH
;Subtree 24->1->0 =>    "NOP"   -> FCDICT_TREE+3F7
FCDICT_TREE_24_1_0      DB      EMPTY_STRING
                        DW      CF_NOP                          ;-> NOP
                        DB      END_OF_BRANCH
;Subtree 25 =>          "O"     -> FCDICT_TREE+3FB
FCDICT_TREE_25          FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_25_0                ;OR...
                        FCS     "V"
                        DB      BRANCH
                        DW      FCDICT_TREE_25_1                ;OV...
                        ;DB     END_OF_BRANCH
;Subtree 25->0 =>       "OR"    -> FCDICT_TREE+403
FCDICT_TREE_25_0        DB      EMPTY_STRING
                        DW      CF_OR                           ;-> OR
                        DB      END_OF_BRANCH
;Subtree 25->1 =>       "OV"    -> FCDICT_TREE+407
FCDICT_TREE_25_1        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_25_1_0              ;OVE...
                        DB      END_OF_BRANCH
;Subtree 25->1->0 =>    "OVE"   -> FCDICT_TREE+40C
FCDICT_TREE_25_1_0      FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_25_1_0_0            ;OVER...
                        ;DB     END_OF_BRANCH
;Subtree 25->1->0->0 => "OVER"  -> FCDICT_TREE+410
FCDICT_TREE_25_1_0_0    DB      EMPTY_STRING
                        DW      CF_OVER                         ;-> OVER
                        DB      END_OF_BRANCH
;Subtree 26 =>          "P"     -> FCDICT_TREE+414
FCDICT_TREE_26          FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_0                ;PA...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_1                ;PR...
                        DB      END_OF_BRANCH
;Subtree 26->0 =>       "PA"    -> FCDICT_TREE+41D
FCDICT_TREE_26_0        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_0_0              ;PAR...
                        DB      END_OF_BRANCH
;Subtree 26->0->0 =>    "PAR"   -> FCDICT_TREE+422
FCDICT_TREE_26_0_0      FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_0_0_0            ;PARS...
                        DB      END_OF_BRANCH
;Subtree 26->0->0->0 => "PARS"  -> FCDICT_TREE+427
FCDICT_TREE_26_0_0_0    FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_0_0_0_0          ;PARSE...
                        ;DB     END_OF_BRANCH
;Subtree 26->0->0->0->0 =>"PARSE" -> FCDICT_TREE+42B
FCDICT_TREE_26_0_0_0_0  DB      EMPTY_STRING
                        DW      CF_PARSE                        ;-> PARSE
                        DB      END_OF_BRANCH
;Subtree 26->1 =>       "PR"    -> FCDICT_TREE+42F
FCDICT_TREE_26_1        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_1_0              ;PRO...
                        DB      END_OF_BRANCH
;Subtree 26->1->0 =>    "PRO"   -> FCDICT_TREE+434
FCDICT_TREE_26_1_0      FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_1_0_0            ;PROM...
                        DB      END_OF_BRANCH
;Subtree 26->1->0->0 => "PROM"  -> FCDICT_TREE+439
FCDICT_TREE_26_1_0_0    FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_1_0_0_0          ;PROMP...
                        DB      END_OF_BRANCH
;Subtree 26->1->0->0->0 =>"PROMP" -> FCDICT_TREE+43E
FCDICT_TREE_26_1_0_0_0  FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_26_1_0_0_0_0        ;PROMPT...
                        ;DB     END_OF_BRANCH
;Subtree 26->1->0->0->0->0 =>"PROMPT"-> FCDICT_TREE+442
FCDICT_TREE_26_1_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_PROMPT                       ;-> PROMPT
                        DB      END_OF_BRANCH
;Subtree 27 =>          "Q"     -> FCDICT_TREE+446
FCDICT_TREE_27          FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_27_0                ;QU...
                        DB      END_OF_BRANCH
;Subtree 27->0 =>       "QU"    -> FCDICT_TREE+44B
FCDICT_TREE_27_0        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_27_0_0              ;QUE...
                        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_27_0_1              ;QUI...
                        DB      END_OF_BRANCH
;Subtree 27->0->0 =>    "QUE"   -> FCDICT_TREE+454
FCDICT_TREE_27_0_0      FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_27_0_0_0            ;QUER...
                        DB      END_OF_BRANCH
;Subtree 27->0->0->0 => "QUER"  -> FCDICT_TREE+459
FCDICT_TREE_27_0_0_0    FCS     "Y"
                        DB      BRANCH
                        DW      FCDICT_TREE_27_0_0_0_0          ;QUERY...
                        ;DB     END_OF_BRANCH
;Subtree 27->0->0->0->0 =>"QUERY" -> FCDICT_TREE+45D
FCDICT_TREE_27_0_0_0_0  DB      EMPTY_STRING
                        DW      CF_QUERY                        ;-> QUERY
                        DB      END_OF_BRANCH
;Subtree 27->0->1 =>    "QUI"   -> FCDICT_TREE+461
FCDICT_TREE_27_0_1      FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_27_0_1_0            ;QUIT...
                        ;DB     END_OF_BRANCH
;Subtree 27->0->1->0 => "QUIT"  -> FCDICT_TREE+465
FCDICT_TREE_27_0_1_0    DB      EMPTY_STRING
                        DW      CF_QUIT                         ;-> QUIT
                        DB      END_OF_BRANCH
;Subtree 28 =>          "R"     -> FCDICT_TREE+469
FCDICT_TREE_28          FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_28_0                ;RO...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_28_1                ;RS...
                        DB      END_OF_BRANCH
;Subtree 28->0 =>       "RO"    -> FCDICT_TREE+472
FCDICT_TREE_28_0        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_28_0_0              ;ROT...
                        ;DB     END_OF_BRANCH
;Subtree 28->0->0 =>    "ROT"   -> FCDICT_TREE+476
FCDICT_TREE_28_0_0      DB      EMPTY_STRING
                        DW      CF_ROT                          ;-> ROT
                        DB      END_OF_BRANCH
;Subtree 28->1 =>       "RS"    -> FCDICT_TREE+47A
FCDICT_TREE_28_1        FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_28_1_0              ;RSH...
                        DB      END_OF_BRANCH
;Subtree 28->1->0 =>    "RSH"   -> FCDICT_TREE+47F
FCDICT_TREE_28_1_0      FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_28_1_0_0            ;RSHI...
                        DB      END_OF_BRANCH
;Subtree 28->1->0->0 => "RSHI"  -> FCDICT_TREE+484
FCDICT_TREE_28_1_0_0    FCS     "F"
                        DB      BRANCH
                        DW      FCDICT_TREE_28_1_0_0_0          ;RSHIF...
                        DB      END_OF_BRANCH
;Subtree 28->1->0->0->0 =>"RSHIF" -> FCDICT_TREE+489
FCDICT_TREE_28_1_0_0_0  FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_28_1_0_0_0_0        ;RSHIFT...
                        ;DB     END_OF_BRANCH
;Subtree 28->1->0->0->0->0 =>"RSHIFT"-> FCDICT_TREE+48D
FCDICT_TREE_28_1_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_R_SHIFT                      ;-> RSHIFT
                        DB      END_OF_BRANCH
;Subtree 29 =>          "S"     -> FCDICT_TREE+491
FCDICT_TREE_29          FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_0                ;S>...
                        FCS     "K"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1                ;SK...
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_2                ;SP...
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_3                ;ST...
                        FCS     "W"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_4                ;SW...
                        DB      END_OF_BRANCH
;Subtree 29->0 =>       "S>"    -> FCDICT_TREE+4A6
FCDICT_TREE_29_0        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_0_0              ;S>D...
                        ;DB     END_OF_BRANCH
;Subtree 29->0->0 =>    "S>D"   -> FCDICT_TREE+4AA
FCDICT_TREE_29_0_0      DB      EMPTY_STRING
                        DW      CF_S_TO_D                       ;-> S>D
                        DB      END_OF_BRANCH
;Subtree 29->1 =>       "SK"    -> FCDICT_TREE+4AE
FCDICT_TREE_29_1        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0              ;SKI...
                        DB      END_OF_BRANCH
;Subtree 29->1->0 =>    "SKI"   -> FCDICT_TREE+4B3
FCDICT_TREE_29_1_0      FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0_0            ;SKIP...
                        DB      END_OF_BRANCH
;Subtree 29->1->0->0 => "SKIP"  -> FCDICT_TREE+4B8
FCDICT_TREE_29_1_0_0    FCS     "&"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0_0_0          ;SKIP&...
                        DB      END_OF_BRANCH
;Subtree 29->1->0->0->0 =>"SKIP&" -> FCDICT_TREE+4BD
FCDICT_TREE_29_1_0_0_0  FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0_0_0_0        ;SKIP&P...
                        DB      END_OF_BRANCH
;Subtree 29->1->0->0->0->0 =>"SKIP&P"-> FCDICT_TREE+4C2
FCDICT_TREE_29_1_0_0_0_0 FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0_0_0_0_0      ;SKIP&PA...
                        DB      END_OF_BRANCH
;Subtree 29->1->0->0->0->0->0 =>"SKIP&PA"-> FCDICT_TREE+4C7
FCDICT_TREE_29_1_0_0_0_0_0 FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0_0_0_0_0_0    ;SKIP&PAR...
                        DB      END_OF_BRANCH
;Subtree 29->1->0->0->0->0->0->0 =>"SKIP&PAR"-> FCDICT_TREE+4CC
FCDICT_TREE_29_1_0_0_0_0_0_0 FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0_0_0_0_0_0_0  ;SKIP&PARS...
                        DB      END_OF_BRANCH
;Subtree 29->1->0->0->0->0->0->0->0 =>"SKIP&PARS"-> FCDICT_TREE+4D1
FCDICT_TREE_29_1_0_0_0_0_0_0_0 FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_1_0_0_0_0_0_0_0_0 ;SKIP&PARSE...
                        ;DB     END_OF_BRANCH
;Subtree 29->1->0->0->0->0->0->0->0->0 =>"SKIP&PARSE"-> FCDICT_TREE+4D5
FCDICT_TREE_29_1_0_0_0_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_SKIP_AND_PARSE               ;-> SKIP&PARSE
                        DB      END_OF_BRANCH
;Subtree 29->2 =>       "SP"    -> FCDICT_TREE+4D9
FCDICT_TREE_29_2        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_2_0              ;SPA...
                        DB      END_OF_BRANCH
;Subtree 29->2->0 =>    "SPA"   -> FCDICT_TREE+4DE
FCDICT_TREE_29_2_0      FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_2_0_0            ;SPAC...
                        DB      END_OF_BRANCH
;Subtree 29->2->0->0 => "SPAC"  -> FCDICT_TREE+4E3
FCDICT_TREE_29_2_0_0    FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_2_0_0_0          ;SPACE...
                        ;DB     END_OF_BRANCH
;Subtree 29->2->0->0->0 =>"SPACE" -> FCDICT_TREE+4E7
FCDICT_TREE_29_2_0_0_0  DB      EMPTY_STRING
                        DW      CF_SPACE                        ;-> SPACE
                        DB      END_OF_BRANCH
;Subtree 29->3 =>       "ST"    -> FCDICT_TREE+4EB
FCDICT_TREE_29_3        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_3_0              ;STA...
                        DB      END_OF_BRANCH
;Subtree 29->3->0 =>    "STA"   -> FCDICT_TREE+4F0
FCDICT_TREE_29_3_0      FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_3_0_0            ;STAT...
                        DB      END_OF_BRANCH
;Subtree 29->3->0->0 => "STAT"  -> FCDICT_TREE+4F5
FCDICT_TREE_29_3_0_0    FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_3_0_0_0          ;STATE...
                        ;DB     END_OF_BRANCH
;Subtree 29->3->0->0->0 =>"STATE" -> FCDICT_TREE+4F9
FCDICT_TREE_29_3_0_0_0  DB      EMPTY_STRING
                        DW      CF_STATE                        ;-> STATE
                        DB      END_OF_BRANCH
;Subtree 29->4 =>       "SW"    -> FCDICT_TREE+4FD
FCDICT_TREE_29_4        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_4_0              ;SWA...
                        DB      END_OF_BRANCH
;Subtree 29->4->0 =>    "SWA"   -> FCDICT_TREE+502
FCDICT_TREE_29_4_0      FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_4_0_0            ;SWAP...
                        ;DB     END_OF_BRANCH
;Subtree 29->4->0->0 => "SWAP"  -> FCDICT_TREE+506
FCDICT_TREE_29_4_0_0    DB      EMPTY_STRING
                        DW      CF_SWAP                         ;-> SWAP
                        DB      END_OF_BRANCH
;Subtree 30 =>          "T"     -> FCDICT_TREE+50A
FCDICT_TREE_30          FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_0                ;TH...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_1                ;TR...
                        DB      END_OF_BRANCH
;Subtree 30->0 =>       "TH"    -> FCDICT_TREE+513
FCDICT_TREE_30_0        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_0_0              ;THR...
                        DB      END_OF_BRANCH
;Subtree 30->0->0 =>    "THR"   -> FCDICT_TREE+518
FCDICT_TREE_30_0_0      FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_0_0_0            ;THRO...
                        DB      END_OF_BRANCH
;Subtree 30->0->0->0 => "THRO"  -> FCDICT_TREE+51D
FCDICT_TREE_30_0_0_0    FCS     "W"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_0_0_0_0          ;THROW...
                        ;DB     END_OF_BRANCH
;Subtree 30->0->0->0->0 =>"THROW" -> FCDICT_TREE+521
FCDICT_TREE_30_0_0_0_0  DB      EMPTY_STRING
                        DW      CF_THROW                        ;-> THROW
                        DB      END_OF_BRANCH
;Subtree 30->1 =>       "TR"    -> FCDICT_TREE+525
FCDICT_TREE_30_1        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_1_0              ;TRU...
                        DB      END_OF_BRANCH
;Subtree 30->1->0 =>    "TRU"   -> FCDICT_TREE+52A
FCDICT_TREE_30_1_0      FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_1_0_0            ;TRUE...
                        ;DB     END_OF_BRANCH
;Subtree 30->1->0->0 => "TRUE"  -> FCDICT_TREE+52E
FCDICT_TREE_30_1_0_0    DB      EMPTY_STRING
                        DW      CF_TRUE                         ;-> TRUE
                        DB      END_OF_BRANCH
;Subtree 31 =>          "U"     -> FCDICT_TREE+532
FCDICT_TREE_31          FCS     "<"
                        DB      BRANCH
                        DW      FCDICT_TREE_31_0                ;U<...
                        FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_31_1                ;U>...
                        ;DB     END_OF_BRANCH
;Subtree 31->0 =>       "U<"    -> FCDICT_TREE+53A
FCDICT_TREE_31_0        DB      EMPTY_STRING
                        DW      CF_U_LESS_THAN                  ;-> U<
                        DB      END_OF_BRANCH
;Subtree 31->1 =>       "U>"    -> FCDICT_TREE+53E
FCDICT_TREE_31_1        DB      EMPTY_STRING
                        DW      CF_U_GREATER_THAN               ;-> U>
                        DB      END_OF_BRANCH
;Subtree 32 =>          "W"     -> FCDICT_TREE+542
FCDICT_TREE_32          FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0                ;WO...
                        DB      END_OF_BRANCH
;Subtree 32->0 =>       "WO"    -> FCDICT_TREE+547
FCDICT_TREE_32_0        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0              ;WOR...
                        DB      END_OF_BRANCH
;Subtree 32->0->0 =>    "WOR"   -> FCDICT_TREE+54C
FCDICT_TREE_32_0_0      FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0            ;WORD...
                        DB      END_OF_BRANCH
;Subtree 32->0->0->0 => "WORD"  -> FCDICT_TREE+551
FCDICT_TREE_32_0_0_0    FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0_0          ;WORDS...
                        ;DB     END_OF_BRANCH
;Subtree 32->0->0->0->0 =>"WORDS" -> FCDICT_TREE+555
FCDICT_TREE_32_0_0_0_0  DB      EMPTY_STRING
                        DW      CF_WORDS                        ;-> WORDS
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0_0_1        ;WORDS-...
                        DB      END_OF_BRANCH
;Subtree 32->0->0->0->0->1 =>"WORDS-"-> FCDICT_TREE+55D
FCDICT_TREE_32_0_0_0_0_1 FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0_0_1_0      ;WORDS-C...
                        DB      END_OF_BRANCH
;Subtree 32->0->0->0->0->1->0 =>"WORDS-C"-> FCDICT_TREE+562
FCDICT_TREE_32_0_0_0_0_1_0 FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0_0_1_0_0    ;WORDS-CD...
                        DB      END_OF_BRANCH
;Subtree 32->0->0->0->0->1->0->0 =>"WORDS-CD"-> FCDICT_TREE+567
FCDICT_TREE_32_0_0_0_0_1_0_0 FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0_0_1_0_0_0  ;WORDS-CDI...
                        DB      END_OF_BRANCH
;Subtree 32->0->0->0->0->1->0->0->0 =>"WORDS-CDI"-> FCDICT_TREE+56C
FCDICT_TREE_32_0_0_0_0_1_0_0_0 FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0_0_1_0_0_0_0 ;WORDS-CDIC...
                        DB      END_OF_BRANCH
;Subtree 32->0->0->0->0->1->0->0->0->0 =>"WORDS-CDIC"-> FCDICT_TREE+571
FCDICT_TREE_32_0_0_0_0_1_0_0_0_0 FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0_0_0_0_1_0_0_0_0_0 ;WORDS-CDICT...
                        ;DB     END_OF_BRANCH
;Subtree 32->0->0->0->0->1->0->0->0->0->0 =>"WORDS-CDICT"-> FCDICT_TREE+575
FCDICT_TREE_32_0_0_0_0_1_0_0_0_0_0 DB      EMPTY_STRING
                        DW      CF_WORDS_CDICT                  ;-> WORDS-CDICT
                        DB      END_OF_BRANCH
;Subtree 33 =>          "X"     -> FCDICT_TREE+579
FCDICT_TREE_33          FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_33_0                ;XO...
                        DB      END_OF_BRANCH
;Subtree 33->0 =>       "XO"    -> FCDICT_TREE+57E
FCDICT_TREE_33_0        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_33_0_0              ;XOR...
                        ;DB     END_OF_BRANCH
;Subtree 33->0->0 =>    "XOR"   -> FCDICT_TREE+582
FCDICT_TREE_33_0_0      DB      EMPTY_STRING
                        DW      CF_XOR                          ;-> XOR
                        DB      END_OF_BRANCH
#emac

;#Set pointer structure to first CDICT entry
; args:   1: address of CDICT root
;         2: index register to address tree entry structure
;         3: offset of tree entry structure
; result: none
; SSTACK: none
;         All registers are preserved
#macro FCDICT_INIT_ITERATOR, 3
                        MOVW #(\1+$00), (\3+$16),\2   ;FCDICT_TREE         ("!")
                        MOVW #NULL,     (\3+$14),\2   ;unused
                        MOVW #NULL,     (\3+$12),\2   ;unused
                        MOVW #NULL,     (\3+$10),\2   ;unused
                        MOVW #NULL,     (\3+$0E),\2   ;unused
                        MOVW #NULL,     (\3+$0C),\2   ;unused
                        MOVW #NULL,     (\3+$0A),\2   ;unused
                        MOVW #NULL,     (\3+$08),\2   ;unused
                        MOVW #NULL,     (\3+$06),\2   ;unused
                        MOVW #NULL,     (\3+$04),\2   ;unused
                        MOVW #NULL,     (\3+$02),\2   ;unused
                        MOVW #NULL,     (\3+$00),\2   ;unused
#emac

#endif
