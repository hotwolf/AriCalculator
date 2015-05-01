#ifndef	REGDEF_COMPILED
#define REGDEF_COMPILED
;###############################################################################
;# S12CBase - REGDEF - Register Definitions (Mini-BDM-Pod)                     #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#    This module defines the register map of the S12XEP100.                   #
;###############################################################################
;# Required Modules:                                                           #
;#    - none                                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    December 14, 2011                                                        #
;#      - Initial release                                                      #
;###############################################################################
;##################################
;# S12XEP100 Register Definitions #
;##################################
PORTA           EQU     $0000
PTA7            EQU     $80
PTA6            EQU     $40
PTA5            EQU     $20
PTA4            EQU     $10
PTA3            EQU     $08
PTA2            EQU     $04
PTA1            EQU     $02
PTA0            EQU     $01
PA7             EQU     $80
PA6             EQU     $40
PA5             EQU     $20
PA4             EQU     $10
PA3             EQU     $08
PA2             EQU     $04
PA1             EQU     $02
PA0             EQU     $01

PORTB           EQU     $0001
PTB7            EQU     $80
PTB6            EQU     $40
PTB5            EQU     $20
PTB4            EQU     $10
PTB3            EQU     $08
PTB2            EQU     $04
PTB1            EQU     $02
PTB0            EQU     $01
PB7             EQU     $80
PB6             EQU     $40
PB5             EQU     $20
PB4             EQU     $10
PB3             EQU     $08
PB2             EQU     $04
PB1             EQU     $02
PB0             EQU     $01

DDRA            EQU     $0002
DDRA7           EQU     $80
DDRA6           EQU     $40
DDRA5           EQU     $20
DDRA4           EQU     $10
DDRA3           EQU     $08
DDRA2           EQU     $04
DDRA1           EQU     $02
DDRA0           EQU     $01

DDRB            EQU     $0003
DDRB7           EQU     $80
DDRB6           EQU     $40
DDRB5           EQU     $20
DDRB4           EQU     $10
DDRB3           EQU     $08
DDRB2           EQU     $04
DDRB1           EQU     $02
DDRB0           EQU     $01

PORTC           EQU     $0004
PTC7            EQU     $80
PTC6            EQU     $40
PTC5            EQU     $20
PTC4            EQU     $10
PTC3            EQU     $08
PTC2            EQU     $04
PTC1            EQU     $02
PTC0            EQU     $01
PC7             EQU     $80
PC6             EQU     $40
PC5             EQU     $20
PC4             EQU     $10
PC3             EQU     $08
PC2             EQU     $04
PC1             EQU     $02
PC0             EQU     $01

PORTD           EQU     $0005
PTD7            EQU     $80
PTD6            EQU     $40
PTD5            EQU     $20
PTD4            EQU     $10
PTD3            EQU     $08
PTD2            EQU     $04
PTD1            EQU     $02
PTD0            EQU     $01
PD7             EQU     $80
PD6             EQU     $40
PD5             EQU     $20
PD4             EQU     $10
PD3             EQU     $08
PD2             EQU     $04
PD1             EQU     $02
PD0             EQU     $01

DDRC            EQU     $0006
DDRC7           EQU     $80
DDRC6           EQU     $40
DDRC5           EQU     $20
DDRC4           EQU     $10
DDRC3           EQU     $08
DDRC2           EQU     $04

DDRD            EQU     $0007
DDRD7           EQU     $80
DDRD6           EQU     $40
DDRD5           EQU     $20
DDRD4           EQU     $10
DDRD3           EQU     $08
DDRD2           EQU     $04

PORTE           EQU     $0008
PTE7            EQU     $80
PTE6            EQU     $40
PTE5            EQU     $20
PTE4            EQU     $10
PTE3            EQU     $08
PTE2            EQU     $04
PTE1            EQU     $02
PTE0            EQU     $01
PE7             EQU     $80
PE6             EQU     $40
PE5             EQU     $20
PE4             EQU     $10
PE3             EQU     $08
PE2             EQU     $04
PE1             EQU     $02
PE0             EQU     $01

DDRE            EQU     $0009
DDRE7           EQU     $80
DDRE6           EQU     $40
DDRE5           EQU     $20
DDRE4           EQU     $10
DDRE3           EQU     $08
DDRE2           EQU     $04

MMCCTL0         EQU     $000A
CS3E1           EQU     $80
CS3E0           EQU     $40
CS2E1           EQU     $20
CS2E0           EQU     $10
CS1E1           EQU     $08
CS1E0           EQU     $04
CS0E1           EQU     $02
CS0E0           EQU     $01

MODE            EQU     $000B
MODC            EQU     $80
MODB            EQU     $40
MODA            EQU     $20

PUCR            EQU     $000C
PUPKE           EQU     $80
BKPUE           EQU     $40
PUPEE           EQU     $10
PUPDE           EQU     $08
PUPCE           EQU     $04
PUPBE           EQU     $02
PUPAE           EQU     $01

RDRIV           EQU     $000D
RDPK            EQU     $80
RDPE            EQU     $10
RDPD            EQU     $08
RDPC            EQU     $04
RDPB            EQU     $02
RDPA            EQU     $01

EBICTL0         EQU     $000E
ITHRS           EQU     $80
HDBE            EQU     $40
ASIZ4           EQU     $10
ASIZ3           EQU     $08
ASIZ2           EQU     $04
ASIZ1           EQU     $02
ASIZ0           EQU     $01

EBICTL1         EQU     $000F
EXSTR12         EQU     $40
EXSTR11         EQU     $20
EXSTR10         EQU     $10
EXSTR02         EQU     $04
EXSTR01         EQU     $02
EXSTR00         EQU     $01

GPAGE           EQU     $0010
GP6		EQU     $40
GP5             EQU     $20
GP4             EQU     $10
GP3             EQU     $08
GP2             EQU     $04
GP1             EQU     $02
GP0		EQU     $01

DIRECT          EQU     $0011
DP15            EQU     $80
DP14            EQU     $40
DP13            EQU     $20
DP12            EQU     $10
DP11            EQU     $08
DP10            EQU     $04
DP9             EQU     $02
DP8             EQU     $01

;$0012 reserved

MMCCTL1         EQU     $0013
TGMRAMON        EQU     $80
EEEIFRON        EQU     $20
PGMIFRON        EQU     $10
RAMHM           EQU     $08
EROMON          EQU     $04
ROMHM           EQU     $02
ROMON           EQU     $01

;$0014 reserved

PPAGE           EQU     $0015
PIX7            EQU     $80
PIX6            EQU     $40
PIX5            EQU     $20
PIX4            EQU     $10
PIX3            EQU     $08
PIX2            EQU     $04
PIX1            EQU     $02
PIX0            EQU     $01

RPAGE           EQU     $0016
RP7             EQU     $80
RP6             EQU     $40
RP5             EQU     $20
RP4             EQU     $10
RP3             EQU     $08
RP2             EQU     $04
RP1             EQU     $02
RP0             EQU     $01

EPAGE           EQU     $0017
EP7             EQU     $80
EP6             EQU     $40
EP5             EQU     $20
EP4             EQU     $10
EP3             EQU     $08
EP2             EQU     $04
EP1             EQU     $02
EP0             EQU     $01

;$0018 to $0019 reserved

PARTIDH         EQU     $001A
ID15            EQU     $80
ID14            EQU     $40
ID13            EQU     $20
ID12            EQU     $10
ID11            EQU     $08
ID10            EQU     $04
ID9             EQU     $02
ID8             EQU     $01

PARTIDL         EQU     $001B
ID7             EQU     $80
ID6             EQU     $40
ID5             EQU     $20
ID4             EQU     $10
ID3             EQU     $08
ID2             EQU     $04
ID1             EQU     $02
ID0             EQU     $01

ECLKCTL         EQU     $001C
NECLK           EQU     $80
NCLKX2          EQU     $40
DIV16           EQU     $20
EDIV4           EQU     $10
EDIV3           EQU     $08
EDIV2           EQU     $04
EDIV1           EQU     $02
EDIV0           EQU     $01

;$001D reserved

IRQCR           EQU     $001E
IRQE            EQU     $80
IRQEN           EQU     $40

;$001F reserved

DBGC1           EQU     $0020
ARM             EQU     $80
TRIG            EQU     $40
XGSBPE          EQU     $20
BDM             EQU     $10
DBGBRK          EQU     $04
COMRV           EQU     $01

DBGSR           EQU    	$0021
TBF          	EQU    	$80
EXTF         	EQU    	$40
SSF2         	EQU    	$04
SSF1         	EQU    	$02
SSF0         	EQU    	$01
		       	
DBGTCR          EQU    	$0022
TSOURCE     	EQU    	$C0
TRANGE      	EQU    	$30
TRCMOD      	EQU    	$0C
TALIGN      	EQU    	$03

DBGC2           EQU    	$0023
CDCM          	EQU    	$0C
ABCM          	EQU    	$03

DBGTBH          EQU    	$0024
DBGTB15       	EQU    	$80
DBGTB14       	EQU    	$40
DBGTB13       	EQU    	$20
DBGTB12       	EQU    	$10
DBGTB11       	EQU    	$08
DBGTB10       	EQU    	$04
DBGTB9        	EQU    	$02
DBGTB8        	EQU    	$01

DBGTBL          EQU    	$0025
DBGTB7        	EQU    	$80
DBGTB6        	EQU    	$40
DBGTB5        	EQU    	$20
DBGTB4        	EQU    	$10
DBGTB3        	EQU    	$08
DBGTB2        	EQU    	$04
DBGTB1        	EQU    	$02
DBGTB0        	EQU    	$01

DBGCNT          EQU    	$0026
		       	
DBGSCRX         EQU    	$0027
SC3        	EQU    	$08
SC2        	EQU    	$04
SC1        	EQU    	$02
SC0        	EQU    	$01

DBGMFR          EQU     $0027
MC3        	EQU    	$08
MC2        	EQU    	$04
MC1        	EQU    	$02
MC0        	EQU    	$01

DBGXCTL         EQU    	$0028
SZE        	EQU    	$80
SZ         	EQU    	$40
TAG        	EQU    	$20
BRK        	EQU    	$10
RW         	EQU    	$08
RWE        	EQU    	$04
SRC        	EQU    	$02
COMPE      	EQU    	$01

DBGXAH          EQU    $0029
DBGXA22       	EQU    $40
DBGXA21       	EQU    $20
DBGXA20       	EQU    $10
DBGXA19       	EQU    $08
DBGXA18       	EQU    $04
DBGXA17       	EQU    $02
DBGXA16       	EQU    $01

DBGXAM          EQU    	$002A
DBGXA15       	EQU    	$80
DBGXA14       	EQU    	$40
DBGXA13       	EQU    	$20
DBGXA12       	EQU    	$10
DBGXA11       	EQU    	$08
DBGXA10       	EQU    	$04
DBGXA9        	EQU    	$02
DBGXA8        	EQU    	$01

DBGXAL          EQU    	$002B
DBGXA7        	EQU    	$80
DBGXA6        	EQU    	$40
DBGXA5        	EQU    	$20
DBGXA4        	EQU    	$10
DBGXA3        	EQU    	$08
DBGXA2        	EQU    	$04
DBGXA1        	EQU    	$02
DBGXA0        	EQU    	$01

DBGXDH          EQU    	$002C
DBGXD15       	EQU    	$80
DBGXD14       	EQU    	$40
DBGXD13       	EQU    	$20
DBGXD12       	EQU    	$10
DBGXD11       	EQU    	$08
DBGXD10       	EQU    	$04
DBGXD9        	EQU    	$02
DBGXD8        	EQU    	$01

DBGXDL          EQU    	$002D
DBGXD7        	EQU    	$80
DBGXD6        	EQU    	$40
DBGXD5        	EQU    	$20
DBGXD4        	EQU    	$10
DBGXD3        	EQU    	$08
DBGXD2        	EQU    	$04
DBGXD1        	EQU    	$02
DBGXD0        	EQU    	$01

DBGXDHM         EQU    	$002E
DBGXDM15       	EQU    	$80
DBGXDM14       	EQU    	$40
DBGXDM13       	EQU    	$20
DBGXDM12       	EQU    	$10
DBGXDM11       	EQU    	$08
DBGXDM10       	EQU    	$04
DBGXDM9        	EQU    	$02
DBGXDM8        	EQU    	$01
		       	
DBGXDLM         EQU    	$002F
DBGXDM7        	EQU    	$80
DBGXDM6        	EQU    	$40
DBGXDM5        	EQU    	$20
DBGXDM4        	EQU    	$10
DBGXDM3        	EQU    	$08
DBGXDM2        	EQU    	$04
DBGXDM1        	EQU    	$02
DBGXDM0        	EQU    	$01

;$0030 to $0031 reserved
	
PORTK           EQU     $0032
PTK7            EQU     $80
PTK6            EQU     $40
PTK5            EQU     $20
PTK4            EQU     $10
PTK3            EQU     $08
PTK2            EQU     $04
PTK1            EQU     $02
PKT0            EQU     $01
PK7             EQU     $80
PK6             EQU     $40
PK5             EQU     $20
PK4             EQU     $10
PK3             EQU     $08
PK2             EQU     $04
PK1             EQU     $02
PK0             EQU     $01

DDRK            EQU     $0033
DDRK7           EQU     $80
DDRK6           EQU     $40
DDRK5           EQU     $20
DDRK4           EQU     $10
DDRK3           EQU     $08
DDRK2           EQU     $04
DDRK1           EQU     $02
DDRK0           EQU     $01

SYNR            EQU     $0034
VCOFRQ1        	EQU     $80
VCOFRQ0        	EQU     $40
SYNDIV5         EQU     $20
SYNDIV4         EQU     $10
SYNDIV3         EQU     $08
SYNDIV2         EQU     $04
SYNDIV1         EQU     $02
SYNDIV0         EQU     $01

REFDV           EQU     $0035
REFFRQ1      	EQU    	$80
REFFRQ0      	EQU    	$40
REFDIV3         EQU     $08
REFDIV2         EQU     $04
REFDIV1         EQU     $02
REFDIV0         EQU     $01

POSTDIV         EQU    	$0036
POSTDIV4   	EQU    	$10
POSTDIV3   	EQU    	$08
POSTDIV2   	EQU    	$04
POSTDIV1   	EQU    	$02
POSTDIV0   	EQU    	$01

CRGFLG          EQU     $0037
RTIF            EQU     $80
PORF            EQU     $40
LVRF            EQU     $20
LOCKIF          EQU     $10
LOCK            EQU     $08
ILAF	        EQU     $04
SCMIF           EQU     $02
SCM             EQU     $01

CRGINT          EQU     $0038
RTIE            EQU     $80
LOCKIE          EQU     $10
SCMIE           EQU     $02

CLKSEL          EQU     $0039
PLLSEL          EQU     $80
PSTP            EQU     $40
XCLKS           EQU     $20
PLLWAI          EQU     $08
RTIWAI          EQU     $02
COPWAI          EQU     $01

PLLCTL          EQU     $003A
CME             EQU     $80
PLLON           EQU     $40
FM1            	EQU     $20
FM0             EQU     $10
FSTWKP	   	EQU     $08
PRE             EQU     $04
PCE             EQU     $02
SCME            EQU     $01

RTICTL          EQU     $003B
RTDEC      	EQU     $80
RTR6            EQU     $40
RTR5            EQU     $20
RTR4            EQU     $10
RTR3            EQU     $08
RTR2            EQU     $04
RTR1            EQU     $02
RTR0            EQU     $01

COPCTL          EQU     $003C
WCOP            EQU     $80
RSBCK           EQU     $40
WRTMASK     	EQU    	$20
CR2             EQU     $04
CR1             EQU     $02
CR0             EQU     $01

FORBYP          EQU     $003D

CTCTL           EQU     $003E

ARMCOP          EQU     $003F

TIOS            EQU     $0040
ECT_TIOS        EQU     $0040
IOS7            EQU     $80
IOS6            EQU     $40
IOS5            EQU     $20
IOS4            EQU     $10
IOS3            EQU     $08
IOS2            EQU     $04
IOS1            EQU     $02
IOS0            EQU     $01

TCFORC          EQU     $0041
ECT_TCFORC      EQU     $0041
FOC7            EQU     $80
FOC6            EQU     $40
FOC5            EQU     $20
FOC4            EQU     $10
FOC3            EQU     $08
FOC2            EQU     $04
FOC1            EQU     $02
FOC0            EQU     $01

TOC7M           EQU     $0042
ECT_TOC7M       EQU     $0042
OC7M7           EQU     $80
OC7M6           EQU     $40
OC7M5           EQU     $20
OC7M4           EQU     $10
OC7M3           EQU     $08
OC7M2           EQU     $04
OC7M1           EQU     $02
OC7M0           EQU     $01

TOC7D           EQU     $0043
ECT_TOC7D       EQU     $0043
OC7D7           EQU     $80
OC7D6           EQU     $40
OC7D5           EQU     $20
OC7D4           EQU     $10
OC7D3           EQU     $08
OC7D2           EQU     $04
OC7D1           EQU     $02
OC7D0           EQU     $01

TCNT            EQU     $0044
ECT_TCNT        EQU     $0044

TSCR1           EQU     $0046
ECT_TSCR1       EQU     $0046
TEN             EQU     $80
TSWAI           EQU     $40
TSFRZ           EQU     $20
TFFCA           EQU     $10

TTOV            EQU     $0047
ECT_TTOV        EQU     $0047
TOV7            EQU     $80
TOV6            EQU     $40
TOV5            EQU     $20
TOV4            EQU     $10
TOV3            EQU     $08
TOV2            EQU     $04
TOV1            EQU     $02
TOV0            EQU     $01

TCTL1           EQU     $0048
ECT_TCTL1       EQU     $0048
OM7             EQU     $80
OL7             EQU     $40
OM6             EQU     $20
OL6             EQU     $10
OM5             EQU     $08
OL5             EQU     $04
OM4             EQU     $02
OL4             EQU     $01

TCTL2           EQU     $0049
ECT_TCTL2       EQU     $0049
OM3             EQU     $80
OL3             EQU     $40
OM2             EQU     $20
OL2             EQU     $10
OM1             EQU     $08
OL1             EQU     $04
OM0             EQU     $02
OL0             EQU     $01

TCTL3           EQU     $004A
ECT_TCTL3       EQU     $004A
EDG7B           EQU     $80
EDG7A           EQU     $40
EDG6B           EQU     $20
EDG6A           EQU     $10
EDG5B           EQU     $08
EDG5A           EQU     $04
EDG4B           EQU     $02
EDG4A           EQU     $01

TCTL4           EQU     $004B
ECT_TCTL4       EQU     $004B
EDG3B           EQU     $80
EDG3A           EQU     $40
EDG2B           EQU     $20
EDG2A           EQU     $10
EDG1B           EQU     $08
EDG1A           EQU     $04
EDG0B           EQU     $02
EDG0A           EQU     $01

TIE             EQU     $004C
ECT_TIE         EQU     $004C
C7I             EQU     $80
C6I             EQU     $40
C5I             EQU     $20
C4I             EQU     $10
C3I             EQU     $08
C2I             EQU     $04
C1I             EQU     $02
C0I             EQU     $01

TSCR2           EQU     $004D
ECT_TSCR2       EQU     $004D
TOI             EQU     $80
TCRE            EQU     $08
PR2             EQU     $04
PR1             EQU     $02
PR0             EQU     $01

TFLG1           EQU     $004E
ECT_TFLG1       EQU     $004E
C7F             EQU     $80
C6F             EQU     $40
C5F             EQU     $20
C4F             EQU     $10
C3F             EQU     $08
C2F             EQU     $04
C1F             EQU     $02
C0F             EQU     $01

TFLG2           EQU     $004F
ECT_TFLG2       EQU     $004F
TOF             EQU     $80

TC0             EQU     $0050
ECT_TC0         EQU     $0050
TC1             EQU     $0052
ECT_TC1         EQU     $0052
TC2             EQU     $0054
ECT_TC3         EQU     $0056
TC3             EQU     $0056
ECT_TC4         EQU     $0058
TC4             EQU     $0058
ECT_TC5         EQU     $005A
TC5             EQU     $005A
ECT_TC6         EQU     $005C
TC7             EQU     $005E
ECT_TC7         EQU     $005E

PACTL           EQU     $0060
ECT_PACTL       EQU     $0060
PAEN            EQU     $40
PAMOD           EQU     $20
PEDGE           EQU     $10
CLK1            EQU     $08
CLK0            EQU     $04
PAOVI           EQU     $02
PAI             EQU     $01

PAFLG           EQU     $0061
ECT_PAFLG       EQU     $0061
PAOVF           EQU     $02
PAIF            EQU     $01

PACNT           EQU     $0062
ECT_PACNT       EQU     $0062
PACN3           EQU     $0062
ECT_PACN3       EQU     $0062
PACN2           EQU     $0063
ECT_PACN2       EQU     $0063
PACN1           EQU     $0064
ECT_PACN1       EQU     $0064
PACN0           EQU     $0065
ECT_PACN0       EQU     $0065

MCCTL     	EQU     $0066
ECT_MCCTL     	EQU     $0066
MCZI     	EQU    	$80
MODMC    	EQU    	$40
RDMCL    	EQU    	$20
ICLAT    	EQU    	$10
FLMC     	EQU    	$08
MCEN     	EQU    	$04
MCPR1    	EQU    	$02
MCPR0    	EQU    	$01

MCFLG   	EQU     $0067
ECT_MCFLG   	EQU     $0067
MCZF     	EQU    	$80
POLF3    	EQU    	$08
POLF2    	EQU    	$04
POLF1    	EQU    	$02
POLF0    	EQU    	$01

ICPAR 		EQU     $0068
ECT_ICPAR 	EQU     $0068
PA3EN    	EQU    	$08
PA2EN    	EQU    	$04
PA1EN    	EQU    	$02
PA0EN    	EQU    	$01

DLYCT 		EQU     $0069
ECT_DLYCT 	EQU     $0069
DLY7     	EQU    	$80
DLY6     	EQU    	$40
DLY5     	EQU    	$20
DLY4     	EQU    	$10
DLY3     	EQU    	$08
DLY2     	EQU    	$04
DLY1     	EQU    	$02
DLY0     	EQU    	$01

ICOVW		EQU     $006A
ECT_ICOVW	EQU     $006A
NOVW7    	EQU    	$80
NOVW6    	EQU    	$40
NOVW5    	EQU    	$20
NOVW4    	EQU    	$10
NOVW3    	EQU    	$08
NOVW2    	EQU    	$04
NOVW1    	EQU    	$02
NOVW0    	EQU    	$01

ICSYS		EQU     $006B
ECT_ICSYS	EQU     $006B
SH37     	EQU    	$80
SH26     	EQU    	$40
SH15     	EQU    	$20
SH04     	EQU    	$10
TFMOD    	EQU    	$08
PACMX    	EQU    	$04
BUFEN    	EQU    	$02
LATQ     	EQU    	$01

OCPD		EQU	$006C
ECT_OCPD	EQU	$006C
OCPD7     	EQU    	$80
OCPD6     	EQU    	$40
OCPD5     	EQU    	$20
OCPD4     	EQU    	$10
OCPD3     	EQU    	$08
OCPD2     	EQU    	$04
OCPD1     	EQU    	$02
OCPD0     	EQU    	$01

;$006D reserved

PTPSR		EQU	$006E
ECT_PTPSR	EQU	$006E
PTPS7    	EQU    	$80
PTPS6    	EQU    	$40
PTPS5    	EQU    	$20
PTPS4    	EQU    	$10
PTPS3    	EQU    	$08
PTPS2    	EQU    	$04
PTPS1    	EQU    	$02
PTPS0    	EQU    	$01

PTMCPSR		EQU	$006F
ECT_PTMCPSR		EQU	$006F
PTMPS0  	EQU    	$01
PTMPS1  	EQU    	$02
PTMPS2  	EQU    	$04
PTMPS3  	EQU    	$08
PTMPS4  	EQU    	$10
PTMPS5  	EQU    	$20
PTMPS6  	EQU    	$40
PTMPS7  	EQU    	$80

PBCTL		EQU	$0070
ECT_PBCTL	EQU	$0070
PBEN     	EQU    	$40
PBOVI    	EQU    	$02

PBFLG		EQU	$00071
ECT_PBFLG	EQU	$00071
PBOVF    	EQU    	$02

PA32H		EQU	$0072
ECT_PA32H	EQU	$0072
PA3H		EQU	$0072
PA2H		EQU	$0073

PA10H		EQU	$0074
ECT_PA10H	EQU	$0074
PA1H		EQU	$0074
PA0H		EQU	$0075

MCCNT		EQU	$0076
ECT_MCCNT	EQU	$0076

TC0H            EQU     $0078
ECT_TC0H        EQU     $0078
TC1H            EQU     $007A
ECT_TC1H        EQU     $007A
TC2H            EQU     $007C
ECT_TC2H        EQU     $007C
TC3H            EQU     $007E
ECT_TC3H        EQU     $007E

ATD1CTL0        EQU     $0080
WRAP3    	EQU    	$08
WRAP2    	EQU    	$04
WRAP1    	EQU    	$02
WRAP0    	EQU    	$01

ATD1CTL1        EQU     $0081
ETRIGSEL  	EQU    	$80
SRES1     	EQU    	$40
SRES0     	EQU    	$20
DIS     	EQU  	$10
ETRIGCH3  	EQU    	$08
ETRIGCH2  	EQU    	$04
ETRIGCH1  	EQU    	$02
ETRIGCH0  	EQU    	$01

ATD1CTL2        EQU     $0082
AFFC            EQU     $40
ICLKSTP         EQU     $20
ETRIGLE         EQU     $10
ETRIGP          EQU     $08
ETRIGE          EQU     $04
ASCIE           EQU     $02
ASCIF           EQU     $01

ATD1CTL3        EQU     $0083
DJM             EQU     $80
S8C             EQU     $40
S4C             EQU     $20
S2C             EQU     $10
S1C             EQU     $08
FIFO            EQU     $04
FRZ1            EQU     $02
FRZ0            EQU     $01

ATD1CTL4        EQU     $0084
SMP2	        EQU     $80
SMP1            EQU     $40
SMP0            EQU     $20
PRS4            EQU     $10
PRS3            EQU     $08
PRS2            EQU     $04
PRS1            EQU     $02
PRS0            EQU     $01

ATD1CTL5        EQU     $0085
SC              EQU     $40
SCAN            EQU     $20
MULT            EQU     $10
CD              EQU     $08
CC              EQU     $04
CB              EQU     $02
CA              EQU     $01

ATD1STAT0       EQU     $0086
SCF             EQU     $80
ETORF           EQU     $20
FIFOR           EQU     $10
CC2             EQU     $04
CC1             EQU     $02
CC0             EQU     $01

;$0087 reserved

ATD1CMPEH       EQU    	$0088
CMPE15   	EQU    	$80
CMPE14   	EQU    	$40
CMPE13   	EQU    	$20
CMPE12   	EQU    	$10
CMPE11   	EQU    	$08
CMPE10   	EQU    	$04
CMPE9    	EQU    	$02
CMPE8    	EQU    	$01

ATD1CMPEL       EQU     $0089
CMPE7    	EQU     $80
CMPE6    	EQU     $40
CMPE5    	EQU     $20
CMPE4    	EQU     $10
CMPE3    	EQU     $08
CMPE2    	EQU     $04
CMPE1    	EQU     $02
CMPE0    	EQU     $01

ATD1STAT2H      EQU    	$008A
CCF15   	EQU    	$80
CCF14   	EQU    	$40
CCF13   	EQU    	$20
CCF12   	EQU    	$10
CCF11   	EQU    	$08
CCF10   	EQU    	$04
CCF9    	EQU    	$02
CCF8    	EQU    	$01

ATD1STAT2L      EQU    	$008B
CCF7    	EQU    	$80
CCF6    	EQU    	$40
CCF5    	EQU    	$20
CCF4    	EQU    	$10
CCF3    	EQU    	$08
CCF2    	EQU    	$04
CCF1    	EQU    	$02
CCF0    	EQU    	$01
		       	
ATD1DIENH       EQU    	$008C
IEN15    	EQU    	$80
IEN14    	EQU    	$40
IEN13    	EQU    	$20
IEN12    	EQU    	$10
IEN11    	EQU    	$08
IEN10    	EQU    	$04
IEN9     	EQU    	$02
IEN8     	EQU    	$01

ATD1DIENL       EQU    	$008D
IEN7     	EQU    	$80
IEN6     	EQU    	$40
IEN5     	EQU    	$20
IEN4     	EQU    	$10
IEN3     	EQU    	$08
IEN2     	EQU    	$04
IEN1     	EQU    	$02
IEN0     	EQU    	$01
		       	
ATD1CMPHTH      EQU    	$008E
CMPHT15  	EQU    	$80
CMPHT14  	EQU    	$40
CMPHT13  	EQU    	$20
CMPHT12  	EQU    	$10
CMPHT11  	EQU    	$08
CMPHT10  	EQU    	$04
CMPHT9   	EQU    	$02
CMPHT8   	EQU    	$01
		       	
ATD1CMPHTL      EQU    	$008F
CMPHT0  	EQU    	$01
CMPHT1  	EQU    	$02
CMPHT2  	EQU    	$04
CMPHT3  	EQU    	$08
CMPHT4  	EQU    	$10
CMPHT5  	EQU    	$20
CMPHT6  	EQU    	$40
CMPHT7  	EQU    	$80
		       	
ATD1DR0         EQU    	$0090
ATD1DR0H        EQU    	$0090
ATD1DR0L        EQU    	$0091

ATD1DR1         EQU    	$0092
ATD1DR1H        EQU    	$0092
ATD1DR1L        EQU    	$0093
		       	
ATD1DR2         EQU    	$0094
ATD1DR2H        EQU    	$0094
ATD1DR2L        EQU    	$0095
		       	
ATD1DR3         EQU    	$0096
ATD1DR3H        EQU    	$0096
ATD1DR3L        EQU    	$0097
		       	
ATD1DR4         EQU    	$0098
ATD1DR4H        EQU    	$0098
ATD1DR4L        EQU    	$0099
		       	
ATD1DR5         EQU    	$009A
ATD1DR5H        EQU    	$009A
ATD1DR5L        EQU    	$009B
		       	
ATD1DR6         EQU    	$009C
ATD1DR6H        EQU    	$009C
ATD1DR6L        EQU    	$009D
		       	
ATD1DR7         EQU    	$009E
ATD1DR7H        EQU    	$009E
ATD1DR7L        EQU    	$009F
		       	
ATD1DR8         EQU    	$00A0
ATD1DR8H        EQU    	$00A0
ATD1DR8L        EQU    	$00A1
		       	
ATD1DR9         EQU    	$00A2
ATD1DR9H        EQU    	$00A2
ATD1DR9L        EQU    	$00A3
		       	
ATD1DR10        EQU    	$00A3
ATD1DR10H       EQU    	$00A3
ATD1DR10L       EQU    	$00A5
		       	
ATD1DR11        EQU    	$00A6
ATD1DR11H       EQU    	$00A6
ATD1DR11L       EQU    	$00A7
		       	
ATD1DR12        EQU    	$00A8
ATD1DR12H       EQU    	$00A8
ATD1DR12L       EQU    	$00A9
		       	
ATD1DR13        EQU    	$00AA
ATD1DR13H       EQU    	$00AA
ATD1DR13L       EQU    	$00AB
		       	
ATD1DR14        EQU    	$00AC
ATD1DR14H       EQU    	$00AC
ATD1DR14L       EQU    	$00AD
		       	
ATD1DR15        EQU    	$00AE
ATD1DR15H       EQU    	$00AE
ATD1DR15L       EQU    	$00AF

I1BAD 		EQU	$00B0
ADR7     	EQU    	$80
ADR6     	EQU    	$40
ADR5     	EQU    	$20
ADR4     	EQU    	$10
ADR3     	EQU    	$08
ADR2     	EQU    	$04
ADR1     	EQU    	$02

I1BFD 		EQU	$00B1
IBC7     	EQU    	$80
IBC6     	EQU    	$40
IBC5     	EQU    	$20
IBC4     	EQU    	$10
IBC3     	EQU    	$08
IBC2     	EQU    	$04
IBC1     	EQU    	$02
IBC0     	EQU    	$01

I1BCR           EQU	$00B2
IBEN     	EQU    	$80
IBIE     	EQU    	$40
SL    		EQU    	$20
RX    		EQU    	$10
TXAK     	EQU    	$08
RSTA     	EQU    	$04
IBSWAI   	EQU    	$01

I1BSR 		EQU	$00B3
TCF      	EQU    	$80
IAAS     	EQU    	$40
IBB      	EQU    	$20
RXAK     	EQU    	$01
SRW      	EQU    	$04
IBIF     	EQU    	$02

I1BDR    	EQU	$00B4

I1BCR2		EQU	$00B5
GCEN    	EQU    	$80
ADTYPE  	EQU    	$40
ADR2    	EQU    	$04
ADR1    	EQU    	$02
ADR0    	EQU    	$01

;$00B6 to $00B7 reserved

SCI2BDH         EQU     $00B8
IREN    	EQU     $80
TNP1            EQU     $40
TNP0            EQU     $20
SBR12           EQU     $10
SBR11           EQU     $08
SBR10           EQU     $04
SBR9            EQU     $02
SBR8            EQU     $01

SCI2ASR1        EQU     $00B8
RXEDGIF   	EQU    	$80
BERRV     	EQU    	$04
BERRIF    	EQU    	$02
BKDIF     	EQU    	$01
	
SCI2BDL         EQU     $00B9
SBR7            EQU     $80
SBR6            EQU     $40
SBR5            EQU     $20
SBR4            EQU     $10
SBR3            EQU     $08
SBR2            EQU     $04
SBR1            EQU     $02
SBR0            EQU     $01

SCI2ACR1        EQU     $00B9
RXEDGIE   	EQU    	$80
BERRIE    	EQU    	$02
BKDIE     	EQU    	$01

SCI2CR1         EQU     $00BA
LOOPS           EQU     $80
SCISWAI         EQU     $40
RSRC            EQU     $20
M               EQU     $10
WAKE            EQU     $08
ILT             EQU     $04
PE              EQU     $02
PT              EQU     $01

SCI2ACR2        EQU     $00BA
BERRM1    	EQU     $04
BERRM0    	EQU     $02
BKDFE     	EQU     $01

SCI2CR2         EQU     $00BB
TXIE            EQU     $80
TCIE            EQU     $40
RIE             EQU     $20
ILIE            EQU     $10
TE              EQU     $08
RE              EQU     $04
RWU             EQU     $02
SBK             EQU     $01

SCI2SR1         EQU     $00BC
TDRE            EQU     $80
TC              EQU     $40
RDRFF           EQU     $20
IDLE            EQU     $10
OR              EQU     $08
NF              EQU     $04
FE              EQU     $02
PF              EQU     $01

SCI2SR2         EQU     $00BD
BRK13           EQU     $04
TXDIR           EQU     $02
RAF             EQU     $01

SCI2DRH         EQU     $00BE
R8              EQU     $80
T8              EQU     $40

SCI2DRL         EQU     $00BF

SCI3BDH         EQU     $00C0
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI3ASR1        EQU     $00C0
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCI3BDL         EQU     $00C1
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI3ACR1        EQU     $00C1
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCI3CR1         EQU     $00C2
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI3ACR2        EQU     $00C2
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCI3CR2         EQU     $00C3
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCI3SR1         EQU     $00C4
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF           EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCI3SR2         EQU     $00C5
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCI3DRH         EQU     $00C6
;R8             EQU     $80
;T8             EQU     $40

SCI3DRL         EQU     $00C7

SCIBDH          EQU     $00C8
SCI0BDH         EQU     $00C8
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI0ASR1        EQU     $00C9
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCIBDL          EQU     $00C9
SCI0BDL         EQU     $00C9
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI0ACR1        EQU     $00C9
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCICR1          EQU     $00CA
SCI0CR1         EQU     $00CA
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI0ACR2        EQU     $00CA
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCICR2          EQU     $00CB
SCI0CR2         EQU     $00CB
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCISR1          EQU     $00CC
SCI0SR1         EQU     $00CC
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF          EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCISR2          EQU     $00CD
SCI0SR2         EQU     $00CD
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCIDRH          EQU     $00CE
SCI0DRH         EQU     $00CE
;R8             EQU     $80
;T8             EQU     $40

SCIDRL          EQU     $00CF
SCI0DRL         EQU     $00CF

SCI1BDH         EQU     $00D0
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI1ASR1        EQU     $00D0
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCI1BDL         EQU     $00D1
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI1ACR1        EQU     $00D1
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCI1CR1         EQU     $00D2
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI1ACR2        EQU     $00D2
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCI1CR2         EQU     $00D3
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCI1SR1         EQU     $00D4
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF          EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCI1SR2         EQU     $00D5
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCI1DRH         EQU     $00D6
;R8             EQU     $80
;T8             EQU     $40

SCI1DRL         EQU     $00D7

SPICR1          EQU     $00D8
SPI0CR1         EQU     $00D8
SPIE            EQU     $80
SPE             EQU     $40
SPTIE           EQU     $20
MSTR            EQU     $10
CPOL            EQU     $08
CPHA            EQU     $04
SSOE            EQU     $02
LSBFE           EQU     $01

SPICR2          EQU     $00D9
SPI0CR2         EQU     $00D9
XFRW       	EQU    	$40
MODFEN          EQU     $10
BIDIROE         EQU     $08
SPISWAI         EQU     $02
SPC0            EQU     $01

SPIBR           EQU     $00DA
SPI0BR          EQU     $00DA
SPPR2           EQU     $40
SPPR1           EQU     $20
SPPR0           EQU     $10
SPR2            EQU     $04
SPR1            EQU     $02
SPR0            EQU     $01

SPISR           EQU     $00DB
SPI0SR          EQU     $00DB
SPIF            EQU     $80
SPTEF           EQU     $20
MODF            EQU     $10

SPIDRH          EQU     $00DC
SPI0DRH         EQU     $00DC

SPIDRL          EQU     $00DD
SPI0DRL         EQU     $00DD

;$00DE to $00DF reserved

IBAD 		EQU	$00E0
I0BAD 		EQU	$00E0
;ADR7     	EQU    	$80
;ADR6     	EQU    	$40
;ADR5     	EQU    	$20
;ADR4     	EQU    	$10
;ADR3     	EQU    	$08
;ADR2     	EQU    	$04
;ADR1     	EQU    	$02

IBFD 		EQU	$00E1
I0BFD 		EQU	$00E1
;IBC7     	EQU    	$80
;IBC6     	EQU    	$40
;IBC5     	EQU    	$20
;IBC4     	EQU    	$10
;IBC3     	EQU    	$08
;IBC2     	EQU    	$04
;IBC1     	EQU    	$02
;IBC0     	EQU    	$01

IBCR            EQU	$00E2
I0BCR           EQU	$00E2
;IBEN     	EQU    	$80
;IBIE     	EQU    	$40
;SL    		EQU    	$20
;RX    		EQU    	$10
;TXAK     	EQU    	$08
;RSTA     	EQU    	$04
;IBSWAI   	EQU    	$01

IBSR 		EQU	$00E3
I0BSR 		EQU	$00E3
;TCF      	EQU    	$80
;IAAS     	EQU    	$40
;IBB      	EQU    	$20
;RXAK     	EQU    	$01
;SRW      	EQU    	$04
;IBIF     	EQU    	$02

IBDR    	EQU	$00E4
I0BDR    	EQU	$00E4

IBCR2		EQU	$00E5
I0BCR2		EQU	$00E5
;GCEN    	EQU    	$80
;ADTYPE  	EQU    	$40
;ADR2    	EQU    	$04
;ADR1    	EQU    	$02
;ADR0    	EQU    	$01

;$00E6 to $00EF reserved

SPI1CR1         EQU     $00F0
;SPIE           EQU     $80
;SPE            EQU     $40
;SPTIE          EQU     $20
;MSTR           EQU     $10
;CPOL           EQU     $08
;CPHA           EQU     $04
;SSOE           EQU     $02
;LSBFE          EQU     $01

SPI1CR2         EQU     $00F1
;XFRW       	EQU    	$40
;MODFEN         EQU     $10
;BIDIROE        EQU     $08
;SPISWAI        EQU     $02
;SPC0           EQU     $01

SPI1BR          EQU     $00F2
;SPPR2          EQU     $40
;SPPR1          EQU     $20
;SPPR0          EQU     $10
;SPR2           EQU     $04
;SPR1           EQU     $02
;SPR0           EQU     $01

SPI1SR          EQU     $00F3
;SPIF           EQU     $80
;SPTEF          EQU     $20
;MODF           EQU     $10

SPI1DRH         EQU     $00F4

SPI1DRL         EQU     $00F5

;$00F6 to $00F7 reserved

SPI2CR1         EQU     $00F8
;SPIE           EQU     $80
;SPE            EQU     $40
;SPTIE          EQU     $20
;MSTR           EQU     $10
;CPOL           EQU     $08
;CPHA           EQU     $04
;SSOE           EQU     $02
;LSBFE          EQU     $01

SPI2CR2         EQU     $00F9
;XFRW       	EQU    	$40
;MODFEN         EQU     $10
;BIDIROE        EQU     $08
;SPISWAI        EQU     $02
;SPC0           EQU     $01

SPI2BR          EQU     $00FA
;SPPR2          EQU     $40
;SPPR1          EQU     $20
;SPPR0          EQU     $10
;SPR2           EQU     $04
;SPR1           EQU     $02
;SPR0           EQU     $01

SPI2SR          EQU     $00FB
;SPIF           EQU     $80
;SPTEF          EQU     $20
;MODF           EQU     $10

SPI2DRH         EQU     $00FC

SPI2DRL         EQU     $00FD

;$00FE to $00FF reserved
 
FCLKDIV         EQU     $0100
FDIVLD          EQU     $80
FDIV6           EQU     $40
FDIV5           EQU     $20
FDIV4           EQU     $10
FDIV3           EQU     $08
FDIV2           EQU     $04
FDIV1           EQU     $02
FDIV0           EQU     $01

FSEC            EQU     $0101
KEYEN1          EQU     $80
KEYEN2          EQU     $40
RNV5            EQU     $20
RNV4            EQU     $10
RNV3            EQU     $08
RNV2            EQU     $04
SEC1            EQU     $02
SEC0            EQU     $01

FCCOBIX         EQU    	$0102
CCOBIX2    	EQU    	$04
CCOBIX1    	EQU    	$02
CCOBIX0    	EQU    	$01

FECCRIX         EQU    	$0103
ECCRIX2    	EQU    	$04
ECCRIX1    	EQU    	$02
ECCRIX0    	EQU    	$01

FCNFG           EQU    	$0104
CCIE         	EQU    	$80
IGNSF        	EQU    	$10
FDFD         	EQU    	$02
FSFD         	EQU    	$01

FERCNFG         EQU    	$0105
ERSERIE    	EQU    	$80
PGMERIE    	EQU    	$40
EPVIOLIE   	EQU    	$10
ERSVIE1    	EQU    	$08
ERSVIE0    	EQU    	$04
DFDIE      	EQU    	$02
SFDIE      	EQU    	$01

FSTAT           EQU    	$0106
CCIF         	EQU    	$80
ACCERR       	EQU    	$20
FPVIOL       	EQU    	$10
MGBUSY       	EQU    	$08
MGSTAT1      	EQU    	$02
MGSTAT0      	EQU    	$01

FERSTAT         EQU    	$0107
ERSERIF    	EQU    	$80
PGMERIF    	EQU    	$40
EPVIOLIF   	EQU    	$10
ERSVIF1    	EQU    	$08
ERSVIF0    	EQU    	$04
DFDIF      	EQU    	$02
SFDIF      	EQU    	$01
		       	
FPROT           EQU    	$0108
FPOPEN       	EQU    	$80
RNV6         	EQU    	$40
FPHDIS       	EQU    	$20
FPHS1        	EQU    	$10
FPHS0        	EQU    	$08
FPLDIS       	EQU    	$04
FPLS1        	EQU    	$02
FPLS0        	EQU    	$01

EPROT           EQU     $0109
EPOPEN       	EQU    	$80
RNV6         	EQU    	$40
RNV5         	EQU    	$20
RNV4         	EQU    	$10
EPDIS        	EQU    	$08
EPS2         	EQU    	$04
EPS1         	EQU    	$02
EPS0         	EQU    	$01
	     	       	
FCCOBHI      	EQU    	$010A
CCOB15     	EQU    	$80
CCOB14     	EQU    	$40
CCOB13     	EQU    	$20
CCOB12     	EQU    	$10
CCOB11     	EQU    	$08
CCOB10     	EQU    	$04
CCOB9      	EQU    	$02
CCOB8      	EQU    	$01

FCCOBLO         EQU    	$010B
CCOB7      	EQU    	$80
CCOB6      	EQU    	$40
CCOB5      	EQU    	$20
CCOB4      	EQU    	$10
CCOB3      	EQU    	$08
CCOB2      	EQU    	$04
CCOB1      	EQU    	$02
CCOB0      	EQU    	$01

ETAGHI          EQU    	$010C
ETAGLO          EQU    	$010D
		       	
FECCRHI         EQU    	$010E
FECCRLO         EQU    	$010F

FOPT            EQU    	$0110
NV7           	EQU    	$80
NV6           	EQU    	$40
NV5           	EQU    	$20
NV4           	EQU    	$10
NV3           	EQU    	$08
NV2           	EQU    	$04
NV1           	EQU    	$02
NV0           	EQU    	$01

;$0111 to $0113 reserved

MPUFLG          EQU    	$0114
AEF         	EQU    	$80
WPF         	EQU    	$40
NEXF        	EQU    	$20
SVSF        	EQU    	$01
		       	
MPUASTAT0       EQU    	$0115
ADDR22   	EQU    	$40
ADDR21   	EQU    	$20
ADDR20   	EQU    	$10
ADDR19   	EQU    	$08
ADDR18   	EQU    	$04
ADDR17   	EQU    	$02
ADDR16   	EQU    	$01
	 	       	
MPUASTAT1	EQU    	$0116
ADDR15   	EQU    	$80
ADDR14   	EQU    	$40
ADDR13   	EQU    	$20
ADDR12   	EQU    	$10
ADDR11   	EQU    	$08
ADDR10   	EQU    	$04
ADDR9    	EQU    	$02
ADDR8    	EQU    	$01

MPUASTAT2       EQU    	$0117
ADDR7    	EQU    	$80
ADDR6    	EQU    	$40
ADDR5    	EQU    	$20
ADDR4    	EQU    	$10
ADDR3    	EQU    	$08
ADDR2    	EQU    	$04
ADDR1    	EQU    	$02
ADDR0    	EQU    	$01

;$0118 reserved

MPUSEL          EQU    	$0119
SVSEN      	EQU    	$80
SEL        	EQU    	$07

MPUDESC0        EQU    	$011A
MSTR0     	EQU    	$80
MSTR1     	EQU    	$40
MSTR2     	EQU    	$20
MSTR3     	EQU    	$10
LOW_ADDR22  	EQU    	$08
LOW_ADDR21  	EQU    	$04
LOW_ADDR20  	EQU    	$02
LOW_ADDR19  	EQU    	$01

MPUDESC1        EQU    	$011B
LOW_ADDR18  	EQU    	$80
LOW_ADDR17  	EQU    	$40
LOW_ADDR16  	EQU    	$20
LOW_ADDR15  	EQU    	$10
LOW_ADDR14  	EQU    	$08
LOW_ADDR13  	EQU    	$04
LOW_ADDR12  	EQU    	$02
LOW_ADDR11  	EQU    	$01

MPUDESC2        EQU    	$011C
LOW_ADDR10  	EQU    	$80
LOW_ADDR9  	EQU    	$40
LOW_ADDR8  	EQU    	$20
LOW_ADDR7  	EQU    	$10
LOW_ADDR6  	EQU    	$08
LOW_ADDR5  	EQU    	$04
LOW_ADDR4  	EQU    	$02
LOW_ADDR3  	EQU    	$01

MPUDESC3        EQU     $011D
WP        	EQU    	$80
NEX       	EQU    	$40
HIGH_ADDR22  	EQU    	$08
HIGH_ADDR21  	EQU    	$04
HIGH_ADDR20  	EQU    	$02
HIGH_ADDR19  	EQU    	$01
	     	       	
MPUDESC4     	EQU    	$011E
HIGH_ADDR18  	EQU    	$80
HIGH_ADDR17  	EQU    	$40
HIGH_ADDR16  	EQU    	$20
HIGH_ADDR15  	EQU    	$10
HIGH_ADDR14  	EQU    	$08
HIGH_ADDR13  	EQU    	$04
HIGH_ADDR12  	EQU    	$02
HIGH_ADDR11  	EQU    	$01
	     	       	
MPUDESC5     	EQU    	$011F
HIGH_ADDR10  	EQU    	$80
HIGH_ADDR9  	EQU    	$40
HIGH_ADDR8  	EQU    	$20
HIGH_ADDR7  	EQU    	$10
HIGH_ADDR6  	EQU    	$08
HIGH_ADDR5  	EQU    	$04
HIGH_ADDR4  	EQU    	$02
HIGH_ADDR3  	EQU    	$01

;$0120 reserved

IVBR            EQU    	$0121

;$0122 to $0125reserved

XGPRIO		EQU	$0126
XILVL  		EQU    	$07

CFADDR 		EQU	$0127

CFDATA0		EQU	$0128
CFDATA1		EQU	$0129
CFDATA2		EQU	$012A
CFDATA3		EQU	$012B
CFDATA4		EQU	$012C
CFDATA5		EQU	$012D
CFDATA6		EQU	$012E
CFDATA7		EQU	$012F
RQST   		EQU    	$80
PRIOLVL  	EQU    	$07

SCI4BDH         EQU     $0130
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI4ASR1        EQU     $0130
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCI4BDL         EQU     $0131
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI4ACR1        EQU     $0131
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCI4CR1         EQU     $0132
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI4ACR2        EQU     $0132
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCI4CR2         EQU     $0133
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCI4SR1         EQU     $0134
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF          EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCI4SR2         EQU     $0135
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCI4DRH         EQU     $0136
;R8             EQU     $80
;T8             EQU     $40

SCI4DRL         EQU     $0137

SCI5BDH         EQU     $0138
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI5ASR1        EQU     $0138
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCI5BDL         EQU     $0139
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI5ACR1        EQU     $0139
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCI5CR1         EQU     $013A
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI5ACR2        EQU     $013A
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCI5CR2         EQU     $013B
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCI5SR1         EQU     $013C
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF          EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCI5SR2         EQU     $013D
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCI5DRH         EQU     $013E
;R8             EQU     $80
;T8             EQU     $40

SCI5DRL         EQU     $013F

CANCTL0         EQU     $0140
CAN0CTL0        EQU     $0140
RXFRM           EQU     $80
RXACT           EQU     $40
CSWAI           EQU     $20
SYNCH           EQU     $10
TIMEN           EQU     $08
WUPE            EQU     $04
SLPRQ           EQU     $02
INITRQ          EQU     $01

CANCTL1         EQU     $0141
CAN0CTL1        EQU     $0141
CANE            EQU     $80
CLKSRC          EQU     $40
LOOPB           EQU     $20
LISTEN          EQU     $10
WUPM            EQU     $04
SLPAK           EQU     $02
INITAK          EQU     $01

CANBTR0         EQU     $0142
CAN0BTR0        EQU     $0142
SJW1            EQU     $80
SJW0            EQU     $40
BRP5            EQU     $20
BRP4            EQU     $10
BRP3            EQU     $08
BRP2            EQU     $04
BRP1            EQU     $02
BRP0            EQU     $01

CANBTR1         EQU     $0143
CAN0BTR1        EQU     $0143
SAMP            EQU     $80
TSEG22          EQU     $40
TSEG21          EQU     $20
TSEG20          EQU     $10
TSEG13          EQU     $08
TSEG12          EQU     $04
TSEG11          EQU     $02
TESG10          EQU     $01

CANRFLG         EQU     $0144
CAN0RFLG        EQU     $0144
WUPIF           EQU     $80
CSCIF           EQU     $40
RSTAT1          EQU     $20
RSTAT0          EQU     $10
TSTAT1          EQU     $08
TSTAT0          EQU     $04
OVRIF           EQU     $02
RXF             EQU     $01

CANRIER         EQU     $0145
CAN0RIER        EQU     $0145
WUPIE           EQU     $80
CSCIE           EQU     $40
RSTATE1         EQU     $20
RSTATE0         EQU     $10
TSTATE1         EQU     $08
TSTATE0         EQU     $04
OVRIE           EQU     $02
RXFIE           EQU     $01

CANTFLG         EQU     $0146
CAN0TFLG        EQU     $0146
TXE2            EQU     $04
TXE1            EQU     $02
TXE0            EQU     $01

CANTIER         EQU     $0147
CAN0TIER        EQU     $0147
TXEIE2          EQU     $04
TXEIE1          EQU     $02
TXEIE0          EQU     $01

CANTARQ         EQU     $0148
CAN0TARQ        EQU     $0148
ABTRQ2          EQU     $04
ABTRQ1          EQU     $02
ABTRQ0          EQU     $01

CANTAAK         EQU     $0149
CAN0TAAK        EQU     $0149
ABTAK2          EQU     $04
ABTAK1          EQU     $02
ABTAK0          EQU     $01

CANTBSEL        EQU     $014A
CAN0TBSEL       EQU     $014A
TX2             EQU     $04
TX1             EQU     $02
TX0             EQU     $01

CANIDAC         EQU     $014B
CAN0IDAC        EQU     $014B
IDAM1           EQU     $20
IDAM0           EQU     $10
IDHIT2          EQU     $04
IDHIT1          EQU     $02
IDHIT0          EQU     $01

; $14c  reserved

CANMISC         EQU    	$014D
CAN0MISC        EQU    	$014D
BOHOLD    	EQU    	$01

CANRXERR        EQU     $014E
CAN0RXERR       EQU     $014E
CANTXERR        EQU     $014F
CAN0TXERR       EQU     $014F

CANIDAR0        EQU     $0150
CAN0IDAR0       EQU     $0150
CANIDAR1        EQU     $0151
CAN0IDAR1       EQU     $0151
CANIDAR2        EQU     $0152
CAN0IDAR2       EQU     $0152
CANIDAR3        EQU     $0153
CAN0IDAR3       EQU     $0153
CANIDMR0        EQU     $0154
CAN0IDMR0       EQU     $0154
CANIDMR1        EQU     $0155
CAN0IDMR1       EQU     $0155
CANIDMR2        EQU     $0156
CAN0IDMR2       EQU     $0156
CANIDMR3        EQU     $0157
CAN0IDMR3       EQU     $0157

CANIDAR4        EQU     $0158
CAN0IDAR4       EQU     $0158
CANIDAR5        EQU     $0159
CAN0IDAR5       EQU     $0159
CANIDAR6        EQU     $015A
CAN0IDAR6       EQU     $015A
CANIDAR7        EQU     $015B
CAN0IDAR7       EQU     $015B
CANIDMR4        EQU     $015C
CAN0IDMR4       EQU     $015C
CANIDMR5        EQU     $015D
CAN0IDMR5       EQU     $015D
CANIDMR6        EQU     $015E
CAN0IDMR6       EQU     $015E
CANIDMR7        EQU     $015F
CAN0IDMR7       EQU     $015F

CANRXIDR0       EQU     $0160
CAN0RXIDR0      EQU     $0160
CANRXIDR1       EQU     $0161
CAN0RXIDR1      EQU     $0161
CANRXIDR2       EQU     $0162
CAN0RXIDR2      EQU     $0162
CANRXIDR3       EQU     $0163
CAN0RXIDR3      EQU     $0163
CANRXDSR0       EQU     $0164
CAN0RXDSR0      EQU     $0164
CANRXDSR1       EQU     $0165
CAN0RXDSR1      EQU     $0165
CANRXDSR2       EQU     $0166
CAN0RXDSR2      EQU     $0166
CANRXDSR3       EQU     $0167
CAN0RXDSR3      EQU     $0167
CANRXDSR4       EQU     $0168
CAN0RXDSR4      EQU     $0168
CANRXDSR5       EQU     $0169
CAN0RXDSR5      EQU     $0169
CANRXDSR6       EQU     $016A
CAN0RXDSR6      EQU     $016A
CANRXDSR7       EQU     $016B
CAN0RXDSR7      EQU     $016B
CANRXDLR        EQU     $016C
CAN0RXDLR       EQU     $016C

;$016D reserved

CANRTSRH        EQU     $016E
CAN0RTSRH       EQU     $016E
CANRTSRL        EQU     $016F
CAN0RTSRL       EQU     $016F
CANTXIDR0       EQU     $0170
CAN0TXIDR0      EQU     $0170
CANTXIDR1       EQU     $0171
CAN0TXIDR1      EQU     $0171
CANTXIDR2       EQU     $0172
CAN0TXIDR2      EQU     $0172
CANTXIDR2       EQU     $0172
CAN0TXIDR2      EQU     $0172
CANTXIDR3       EQU     $0173
CAN0TXIDR3      EQU     $0173
CANTXDSR0       EQU     $0174
CAN0TXDSR0      EQU     $0174
CANTXDSR1       EQU     $0175
CAN0TXDSR1      EQU     $0175
CANTXDSR2       EQU     $0176
CAN0TXDSR2      EQU     $0176
CANTXDSR3       EQU     $0177
CAN0TXDSR3      EQU     $0177
CANTXDSR4       EQU     $0178
CAN0TXDSR4      EQU     $0178
CANTXDSR5       EQU     $0179
CAN0TXDSR5      EQU     $0179
CANTXDSR6       EQU     $017A
CAN0TXDSR6      EQU     $017A
CANTXDSR7       EQU     $017B
CAN0TXDSR7      EQU     $017B
CANTXDLR        EQU     $017C
CAN0TXDLR       EQU     $017C
CANTXTBPR       EQU     $017D
CAN0TXTBPR      EQU     $017D
CANTXTSRH       EQU     $017E
CAN0TXTSRH      EQU     $017E
CANTXTSRL       EQU     $017F
CAN0TXTSRL      EQU     $017F

CAN1CTL0        EQU     $0180
;RXFRM          EQU     $80
;RXACT          EQU     $40
;CSWAI          EQU     $20
;SYNCH          EQU     $10
;TIMEN          EQU     $08
;WUPE           EQU     $04
;SLPRQ          EQU     $02
;INITRQ         EQU     $01

CAN1CTL1        EQU     $0181
;CANE           EQU     $80
;CLKSRC         EQU     $40
;LOOPB          EQU     $20
;LISTEN         EQU     $10
;WUPM           EQU     $04
;SLPAK          EQU     $02
;INITAK         EQU     $01

CAN1BTR0        EQU     $0182
;SJW1           EQU     $80
;SJW0           EQU     $40
;BRP5           EQU     $20
;BRP4           EQU     $10
;BRP3           EQU     $08
;BRP2           EQU     $04
;BRP1           EQU     $02
;BRP0           EQU     $01

CAN1BTR1        EQU     $0183
;SAMP           EQU     $80
;TSEG22         EQU     $40
;TSEG21         EQU     $20
;TSEG20         EQU     $10
;TSEG13         EQU     $08
;TSEG12         EQU     $04
;TSEG11         EQU     $02
;TESG10         EQU     $01

CAN1RFLG        EQU     $0184
;WUPIF          EQU     $80
;CSCIF          EQU     $40
;RSTAT1         EQU     $20
;RSTAT0         EQU     $10
;TSTAT1         EQU     $08
;TSTAT0         EQU     $04
;OVRIF          EQU     $02
;RXF            EQU     $01

CAN1RIER        EQU     $0185
;WUPIE          EQU     $80
;CSCIE          EQU     $40
;RSTATE1        EQU     $20
;RSTATE0        EQU     $10
;TSTATE1        EQU     $08
;TSTATE0        EQU     $04
;OVRIE          EQU     $02
;RXFIE          EQU     $01

CAN1TFLG        EQU     $0186
;TXE2           EQU     $04
;TXE1           EQU     $02
;TXE0           EQU     $01

CAN1TIER        EQU     $0187
;TXEIE2         EQU     $04
;TXEIE1         EQU     $02
;TXEIE0         EQU     $01

CAN1TARQ        EQU     $0188
;ABTRQ2         EQU     $04
;ABTRQ1         EQU     $02
;ABTRQ0         EQU     $01

CAN1TAAK        EQU     $0189
;ABTAK2         EQU     $04
;ABTAK1         EQU     $02
;ABTAK0         EQU     $01

CAN1TBSEL       EQU     $018A
;TX2            EQU     $04
;TX1            EQU     $02
;TX0            EQU     $01

CAN1IDAC        EQU     $018B
;IDAM1          EQU     $20
;IDAM0          EQU     $10
;IDHIT2         EQU     $04
;IDHIT1         EQU     $02
;IDHIT0         EQU     $01

;$18C  reserved

CAN1MISC        EQU    	$018D
;BOHOLD    	EQU    	$01

CAN1RXERR       EQU     $018E
CAN1TXERR       EQU     $018F

CAN1IDAR0       EQU     $0190
CAN1IDAR1       EQU     $0191
CAN1IDAR2       EQU     $0192
CAN1IDAR3       EQU     $0193
CAN1IDMR0       EQU     $0194
CAN1IDMR1       EQU     $0195
CAN1IDMR2       EQU     $0196
CAN1IDMR3       EQU     $0197

CAN1IDAR4       EQU     $0198
CAN1IDAR5       EQU     $0199
CAN1IDAR6       EQU     $019A
CAN1IDAR7       EQU     $019B
CAN1IDMR4       EQU     $019C
CAN1IDMR5       EQU     $019D
CAN1IDMR6       EQU     $019E
CAN1IDMR7       EQU     $019F

CAN1RXIDR0      EQU     $01A0
CAN1RXIDR1      EQU     $01A1
CAN1RXIDR2      EQU     $01A2
CAN1RXIDR3      EQU     $01A3
CAN1RXDSR0      EQU     $01A4
CAN1RXDSR1      EQU     $01A5
CAN1RXDSR2      EQU     $01A6
CAN1RXDSR3      EQU     $01A7
CAN1RXDSR4      EQU     $01A8
CAN1RXDSR5      EQU     $01A9
CAN1RXDSR6      EQU     $01AA
CAN1RXDSR7      EQU     $01AB
CAN1RXDLR       EQU     $01AC

;$01AD reserved

CAN1RTSRH       EQU     $01AE
CAN1RTSRL       EQU     $01AF
CAN1TXIDR0      EQU     $01B0
CAN1TXIDR1      EQU     $01B1
CAN1TXIDR2      EQU     $01B2
CAN1TXIDR2      EQU     $01B2
CAN1TXIDR3      EQU     $01B3
CAN1TXDSR0      EQU     $01B4
CAN1TXDSR1      EQU     $01B5
CAN1TXDSR2      EQU     $01B6
CAN1XDSR3       EQU     $01B7
CAN1TXDSR3      EQU     $01B7
CAN1TXDSR4      EQU     $01B8
CAN1TXDSR5      EQU     $01B9
CAN1TXDSR6      EQU     $01BA
CAN1TXDSR7      EQU     $01BB
CAN1TXDLR       EQU     $01BC
CAN1TXTBPR      EQU     $01BD
CAN1TXTSRH      EQU     $01BE
CAN1TXTSRL      EQU     $01BF

CAN2CTL0        EQU     $01C0
;RXFRM          EQU     $80
;RXACT          EQU     $40
;CSWAI          EQU     $20
;SYNCH          EQU     $10
;TIMEN          EQU     $08
;WUPE           EQU     $04
;SLPRQ          EQU     $02
;INITRQ         EQU     $01

CAN2CTL1        EQU     $01C1
;CANE           EQU     $80
;CLKSRC         EQU     $40
;LOOPB          EQU     $20
;LISTEN         EQU     $10
;WUPM           EQU     $04
;SLPAK          EQU     $02
;INITAK         EQU     $01

CAN2BTR0        EQU     $01C2
;SJW1           EQU     $80
;SJW0           EQU     $40
;BRP5           EQU     $20
;BRP4           EQU     $10
;BRP3           EQU     $08
;BRP2           EQU     $04
;BRP1           EQU     $02
;BRP0           EQU     $01

CAN2BTR1        EQU     $01C3
;SAMP           EQU     $80
;TSEG22         EQU     $40
;TSEG21         EQU     $20
;TSEG20         EQU     $10
;TSEG13         EQU     $08
;TSEG12         EQU     $04
;TSEG11         EQU     $02
;TESG10         EQU     $01

CAN2RFLG        EQU     $01C4
;WUPIF          EQU     $80
;CSCIF          EQU     $40
;RSTAT1         EQU     $20
;RSTAT0         EQU     $10
;TSTAT1         EQU     $08
;TSTAT0         EQU     $04
;OVRIF          EQU     $02
;RXF            EQU     $01

CAN2RIER        EQU     $01C5
;WUPIE          EQU     $80
;CSCIE          EQU     $40
;RSTATE1        EQU     $20
;RSTATE0        EQU     $10
;TSTATE1        EQU     $08
;TSTATE0        EQU     $04
;OVRIE          EQU     $02
;RXFIE          EQU     $01

CAN2TFLG        EQU     $01C6
;TXE2           EQU     $04
;TXE1           EQU     $02
;TXE0           EQU     $01

CAN2TIER        EQU     $01C7
;TXEIE2         EQU     $04
;TXEIE1         EQU     $02
;TXEIE0         EQU     $01

CAN2TARQ        EQU     $01C8
;ABTRQ2         EQU     $04
;ABTRQ1         EQU     $02
;ABTRQ0         EQU     $01

CAN2TAAK        EQU     $01C9
;ABTAK2         EQU     $04
;ABTAK1         EQU     $02
;ABTAK0         EQU     $01

CAN2TBSEL       EQU     $01CA
;TX2            EQU     $04
;TX1            EQU     $02
;TX0            EQU     $01

CAN2IDAC        EQU     $01CB
;IDAM1          EQU     $20
;IDAM0          EQU     $10
;IDHIT2         EQU     $04
;IDHIT1         EQU     $02
;IDHIT0         EQU     $01

;$01CC  reserved

CAN2MISC        EQU    	$01CD
;BOHOLD    	EQU    	$01

CAN2RXERR       EQU     $01CE
CAN2TXERR       EQU     $01CF

CAN2IDAR0       EQU     $01D0
CAN2IDAR1       EQU     $01D1
CAN2IDAR2       EQU     $01D2
CAN2IDAR3       EQU     $01D3
CAN2IDMR0       EQU     $01D4
CAN2IDMR1       EQU     $01D5
CAN2IDMR2       EQU     $01D6
CAN2IDMR3       EQU     $01D7

CAN2IDAR4       EQU     $01D8
CAN2IDAR5       EQU     $01D9
CAN2IDAR6       EQU     $01DA
CAN2IDAR7       EQU     $01DB
CAN2IDMR4       EQU     $01DC
CAN2IDMR5       EQU     $01DD
CAN2IDMR6       EQU     $01DE
CAN2IDMR7       EQU     $01DF

CAN2RXIDR0      EQU     $01E0
CAN2RXIDR1      EQU     $01E1
CAN2RXIDR2      EQU     $01E2
CAN2RXIDR3      EQU     $01E3
CAN2RXDSR0      EQU     $01E4
CAN2RXDSR1      EQU     $01E5
CAN2RXDSR2      EQU     $01E6
CAN2RXDSR3      EQU     $01E7
CAN2RXDSR4      EQU     $01E8
CAN2RXDSR5      EQU     $01E9
CAN2RXDSR6      EQU     $01EA
CAN2RXDSR7      EQU     $01EB
CAN2RXDLR       EQU     $01EC

;$01ED reserved

CAN2RTSRH       EQU     $01EE
CAN2RTSRL       EQU     $01EF
CAN2TXIDR0      EQU     $01F0
CAN2TXIDR1      EQU     $01F1
CAN2TXIDR2      EQU     $01F2
CAN2TXIDR2      EQU     $01F2
CAN2TXIDR3      EQU     $01F3
CAN2TXDSR0      EQU     $01F4
CAN2TXDSR1      EQU     $01F5
CAN2TXDSR2      EQU     $01F6
CAN2XDSR3       EQU     $01F7
CAN2TXDSR3      EQU     $01F7
CAN2TXDSR4      EQU     $01F8
CAN2TXDSR5      EQU     $01F9
CAN2TXDSR6      EQU     $01FA
CAN2TXDSR7      EQU     $01FB
CAN2TXDLR       EQU     $01FC
CAN2TXTBPR      EQU     $01FD
CAN2TXTSRH      EQU     $01FE
CAN2TXTSRL      EQU     $01FF

CAN3CTL0        EQU     $0200
;RXFRM          EQU     $80
;RXACT          EQU     $40
;CSWAI          EQU     $20
;SYNCH          EQU     $10
;TIMEN          EQU     $08
;WUPE           EQU     $04
;SLPRQ          EQU     $02
;INITRQ         EQU     $01

CAN3CTL1        EQU     $0201
;CANE           EQU     $80
;CLKSRC         EQU     $40
;LOOPB          EQU     $20
;LISTEN         EQU     $10
;WUPM           EQU     $04
;SLPAK          EQU     $02
;INITAK         EQU     $01

CAN3BTR0        EQU     $0202
;SJW1           EQU     $80
;SJW0           EQU     $40
;BRP5           EQU     $20
;BRP4           EQU     $10
;BRP3           EQU     $08
;BRP2           EQU     $04
;BRP1           EQU     $02
;BRP0           EQU     $01

CAN3BTR1        EQU     $0203
;SAMP           EQU     $80
;TSEG22         EQU     $40
;TSEG21         EQU     $20
;TSEG20         EQU     $10
;TSEG13         EQU     $08
;TSEG12         EQU     $04
;TSEG11         EQU     $02
;TESG10         EQU     $01

CAN3RFLG        EQU     $0204
;WUPIF          EQU     $80
;CSCIF          EQU     $40
;RSTAT1         EQU     $20
;RSTAT0         EQU     $10
;TSTAT1         EQU     $08
;TSTAT0         EQU     $04
;OVRIF          EQU     $02
;RXF            EQU     $01

CAN3RIER        EQU     $0205
;WUPIE          EQU     $80
;CSCIE          EQU     $40
;RSTATE1        EQU     $20
;RSTATE0        EQU     $10
;TSTATE1        EQU     $08
;TSTATE0        EQU     $04
;OVRIE          EQU     $02
;RXFIE          EQU     $01

CAN3TFLG        EQU     $0206
;TXE2           EQU     $04
;TXE1           EQU     $02
;TXE0           EQU     $01

CAN3TIER        EQU     $0207
;TXEIE2         EQU     $04
;TXEIE1         EQU     $02
;TXEIE0         EQU     $01

CAN3TARQ        EQU     $0208
;ABTRQ2         EQU     $04
;ABTRQ1         EQU     $02
;ABTRQ0         EQU     $01

CAN3TAAK        EQU     $0209
;ABTAK2         EQU     $04
;ABTAK1         EQU     $02
;ABTAK0         EQU     $01

CAN3TBSEL       EQU     $020A
;TX2            EQU     $04
;TX1            EQU     $02
;TX0            EQU     $01

CAN3IDAC        EQU     $020B
;IDAM1          EQU     $20
;IDAM0          EQU     $10
;IDHIT2         EQU     $04
;IDHIT1         EQU     $02
;IDHIT0         EQU     $01

;$020C  reserved

CAN3MISC        EQU    	$020D
;BOHOLD    	EQU    	$01

CAN3RXERR       EQU     $020E
CAN3TXERR       EQU     $020F

CAN3IDAR0       EQU     $0210
CAN3IDAR1       EQU     $0211
CAN3IDAR2       EQU     $0212
CAN3IDAR3       EQU     $0213
CAN3IDMR0       EQU     $0214
CAN3IDMR1       EQU     $0215
CAN3IDMR2       EQU     $0216
CAN3IDMR3       EQU     $0217

CAN3IDAR4       EQU     $0218
CAN3IDAR5       EQU     $0219
CAN3IDAR6       EQU     $021A
CAN3IDAR7       EQU     $021B
CAN3IDMR4       EQU     $021C
CAN3IDMR5       EQU     $021D
CAN3IDMR6       EQU     $021E
CAN3IDMR7       EQU     $021F

CAN3RXIDR0      EQU     $0220
CAN3RXIDR1      EQU     $0221
CAN3RXIDR2      EQU     $0222
CAN3RXIDR3      EQU     $0223
CAN3RXDSR0      EQU     $0224
CAN3RXDSR1      EQU     $0225
CAN3RXDSR2      EQU     $0226
CAN3RXDSR3      EQU     $0227
CAN3RXDSR4      EQU     $0228
CAN3RXDSR5      EQU     $0229
CAN3RXDSR6      EQU     $022A
CAN3RXDSR7      EQU     $022B
CAN3RXDLR       EQU     $022C

;$022D reserved

CAN3RTSRH       EQU     $022E
CAN3RTSRL       EQU     $022F
CAN3TXIDR0      EQU     $0230
CAN3TXIDR1      EQU     $0231
CAN3TXIDR2      EQU     $0232
CAN3TXIDR2      EQU     $0232
CAN3TXIDR3      EQU     $0233
CAN3TXDSR0      EQU     $0234
CAN3TXDSR1      EQU     $0235
CAN3TXDSR2      EQU     $0236
CAN3XDSR3       EQU     $0237
CAN3TXDSR3      EQU     $0237
CAN3TXDSR4      EQU     $0238
CAN3TXDSR5      EQU     $0239
CAN3TXDSR6      EQU     $023A
CAN3TXDSR7      EQU     $023B
CAN3TXDLR       EQU     $023C
CAN3TXTBPR      EQU     $023D
CAN3TXTSRH      EQU     $023E
CAN3TXTSRL      EQU     $023F

PTT             EQU     $0240
PTT7            EQU     $80
PTT6            EQU     $40
PTT5            EQU     $20
PTT4            EQU     $10
PTT3            EQU     $08
PTT2            EQU     $04
PTT1            EQU     $02
PTT0            EQU     $01
PT7             EQU     $80
PT6             EQU     $40
PT5             EQU     $20
PT4             EQU     $10
PT3             EQU     $08
PT2             EQU     $04
PT1             EQU     $02
PT0             EQU     $01

PTIT            EQU     $0241
PTIT7           EQU     $80
PTIT6           EQU     $40
PTIT5           EQU     $20
PTIT4           EQU     $10
PTIT3           EQU     $08
PTIT2           EQU     $04
PTIT1           EQU     $02
PTIT0           EQU     $01

DDRT            EQU     $0242
DDRT7           EQU     $80
DDRT6           EQU     $40
DDRT5           EQU     $20
DDRT4           EQU     $10
DDRT3           EQU     $08
DDRT2           EQU     $04
DDRT1           EQU     $02
DDRT0           EQU     $01

RDRT            EQU     $0243
RDRT7           EQU     $80
RDRT6           EQU     $40
RDRT5           EQU     $20
RDRT4           EQU     $10
RDRT3           EQU     $08
RDRT2           EQU     $04
RDRT1           EQU     $02
RDRT0           EQU     $01

PERT            EQU     $0244
PERT7           EQU     $80
PERT6           EQU     $40
PERT5           EQU     $20
PERT4           EQU     $10
PERT3           EQU     $08
PERT2           EQU     $04
PERT1           EQU     $02
PERT0           EQU     $01

PPST            EQU     $0245
PPST7           EQU     $80
PPST6           EQU     $40
PPST5           EQU     $20
PPST4           EQU     $10
PPST3           EQU     $08
PPST2           EQU     $04
PPST1           EQU     $02
PPST0           EQU     $01

;$0246 to $0247 reserved

PTS             EQU     $0248
PTS7            EQU     $80
PTS6            EQU     $40
PTS5            EQU     $20
PTS4            EQU     $10
PTS3            EQU     $08
PTS2            EQU     $04
PTS1            EQU     $02
PTS0            EQU     $01
PS7             EQU     $80
PS6             EQU     $40
PS5             EQU     $20
PS4             EQU     $10
PS3             EQU     $08
PS2             EQU     $04
PS1             EQU     $02
PS0             EQU     $01

PTIS            EQU     $0249
PTIS7           EQU     $80
PTIS6           EQU     $40
PTIS5           EQU     $20
PTIS4           EQU     $10
PTIS3           EQU     $08
PTIS2           EQU     $04
PTIS1           EQU     $02
PTIS0           EQU     $01

DDRS            EQU     $024A
DDRS7           EQU     $80
DDRS6           EQU     $40
DDRS5           EQU     $20
DDRS4           EQU     $10
DDRS3           EQU     $08
DDRS2           EQU     $04
DDRS1           EQU     $02
DDRS0           EQU     $01

RDRS            EQU     $024B
RDRS7           EQU     $80
RDRS6           EQU     $40
RDRS5           EQU     $20
RDRS4           EQU     $10
RDRS3           EQU     $08
RDRS2           EQU     $04
RDRS1           EQU     $02
RDRS0           EQU     $01

PERS            EQU     $024C
PERS7           EQU     $80
PERS6           EQU     $40
PERS5           EQU     $20
PERS4           EQU     $10
PERS3           EQU     $08
PERS2           EQU     $04
PERS1           EQU     $02
PERS0           EQU     $01

PPSS            EQU     $024D
PPSS7           EQU     $80
PPSS6           EQU     $40
PPSS5           EQU     $20
PPSS4           EQU     $10
PPSS3           EQU     $08
PPSS2           EQU     $04
PPSS1           EQU     $02
PPSS0           EQU     $01

WOMS            EQU     $024E
WOMS7           EQU     $80
WOMS6           EQU     $40
WOMS5           EQU     $20
WOMS4           EQU     $10
WOMS3           EQU     $08
WOMS2           EQU     $04
WOMS1           EQU     $02
WOMS0           EQU     $01

;$024F reserved

PTM             EQU     $0250
PTM7            EQU     $80
PTM6            EQU     $40
PTM5            EQU     $20
PTM4            EQU     $10
PTM3            EQU     $08
PTM2            EQU     $04
PTM1            EQU     $02
PTM0            EQU     $01
PM7             EQU     $80
PM6             EQU     $40
PM5             EQU     $20
PM4             EQU     $10
PM3             EQU     $08
PM2             EQU     $04
PM1             EQU     $02
PM0             EQU     $01

PTIM            EQU     $0251
PTIM7           EQU     $80
PTIM6           EQU     $40
PTIM5           EQU     $20
PTIM4           EQU     $10
PTIM3           EQU     $08
PTIM2           EQU     $04
PTIM1           EQU     $02
PTIM0           EQU     $01

DDRM            EQU     $0252
DDRM7           EQU     $80
DDRM6           EQU     $40
DDRM5           EQU     $20
DDRM4           EQU     $10
DDRM3           EQU     $08
DDRM2           EQU     $04
DDRM1           EQU     $02
DDRM0           EQU     $01

RDRM            EQU     $0253
RDRM7           EQU     $80
RDRM6           EQU     $40
RDRM5           EQU     $20
RDRM4           EQU     $10
RDRM3           EQU     $08
RDRM2           EQU     $04
RDRM1           EQU     $02
RDRM0           EQU     $01

PERM            EQU     $0254
PERM7           EQU     $80
PERM6           EQU     $40
PERM5           EQU     $20
PERM4           EQU     $10
PERM3           EQU     $08
PERM2           EQU     $04
PERM1           EQU     $02
PERM0           EQU     $01

PPSM            EQU     $0255
PPSM7           EQU     $80
PPSM6           EQU     $40
PPSM5           EQU     $20
PPSM4           EQU     $10
PPSM3           EQU     $08
PPSM2           EQU     $04
PPSM1           EQU     $02
PPSM0           EQU     $01

WOMM            EQU     $0256
WOMM7           EQU     $80
WOMM6           EQU     $40
WOMM5           EQU     $20
WOMM4           EQU     $10
WOMM3           EQU     $08
WOMM2           EQU     $04
WOMM1           EQU     $02
WOMM0           EQU     $01

MODRR           EQU     $0257
MODRR6          EQU     $40
MODRR5          EQU     $20
MODRR4          EQU     $10
MODRR3          EQU     $08
MODRR2          EQU     $04
MODRR1          EQU     $02
MODRR0          EQU     $01

PTP             EQU     $0258
PTP7            EQU     $80
PTP6            EQU     $40
PTP5            EQU     $20
PTP4            EQU     $10
PTP3            EQU     $08
PTP2            EQU     $04
PTP1            EQU     $02
PTP0            EQU     $01
PP7             EQU     $80
PP6             EQU     $40
PP5             EQU     $20
PP4             EQU     $10
PP3             EQU     $08
PP2             EQU     $04
PP1             EQU     $02
PP0             EQU     $01

PTIP            EQU     $0259
PTIP7           EQU     $80
PTIP6           EQU     $40
PTIP5           EQU     $20
PTIP4           EQU     $10
PTIP3           EQU     $08
PTIP2           EQU     $04
PTIP1           EQU     $02
PTIP0           EQU     $01

DDRP            EQU     $025A
DDRP7           EQU     $80
DDRP6           EQU     $40
DDRP5           EQU     $20
DDRP4           EQU     $10
DDRP3           EQU     $08
DDRP2           EQU     $04
DDRP1           EQU     $02
DDRP0           EQU     $01

RDRP            EQU     $025B
RDRP7           EQU     $80
RDRP6           EQU     $40
RDRP5           EQU     $20
RDRP4           EQU     $10
RDRP3           EQU     $08
RDRP2           EQU     $04
RDRP1           EQU     $02
RDRP0           EQU     $01

PERP            EQU     $025C
PERP7           EQU     $80
PERP6           EQU     $40
PERP5           EQU     $20
PERP4           EQU     $10
PERP3           EQU     $08
PERP2           EQU     $04
PERP1           EQU     $02
PERP0           EQU     $01

PPSP            EQU     $025D
PPSP7           EQU     $80
PPSP6           EQU     $40
PPSP5           EQU     $20
PPSP4           EQU     $10
PPSP3           EQU     $08
PPSP2           EQU     $04
PPSP1           EQU     $02
PPSP0           EQU     $01

PIEP            EQU     $025E
PIEP7           EQU     $80
PIEP6           EQU     $40
PIEP5           EQU     $20
PIEP4           EQU     $10
PIEP3           EQU     $08
PIEP2           EQU     $04
PIEP1           EQU     $02
PIEP0           EQU     $01

PIFP            EQU     $025F
PIFP7           EQU     $80
PIFP6           EQU     $40
PIFP5           EQU     $20
PIFP4           EQU     $10
PIFP3           EQU     $08
PIFP2           EQU     $04
PIFP1           EQU     $02
PIFP0           EQU     $01

PTH             EQU     $0260
PTH7            EQU     $80
PTH6            EQU     $40
PTH5            EQU     $20
PTH4            EQU     $10
PTH3            EQU     $08
PTH2            EQU     $04
PTH1            EQU     $02
PTH0            EQU     $01
PH7             EQU     $80
PH6             EQU     $40
PH5             EQU     $20
PH4             EQU     $10
PH3             EQU     $08
PH2             EQU     $04
PH1             EQU     $02
PH0             EQU     $01

PTIH            EQU     $0261
PTIH7           EQU     $80
PTIH6           EQU     $40
PTIH5           EQU     $20
PTIH4           EQU     $10
PTIH3           EQU     $08
PTIH2           EQU     $04
PTIH1           EQU     $02
PTIH0           EQU     $01

DDRH            EQU     $0262
DDRH7           EQU     $80
DDRH6           EQU     $40
DDRH5           EQU     $20
DDRH4           EQU     $10
DDRH3           EQU     $08
DDRH2           EQU     $04
DDRH1           EQU     $02
DDRH0           EQU     $01

RDRH            EQU     $0263
RDRH7           EQU     $80
RDRH6           EQU     $40
RDRH5           EQU     $20
RDRH4           EQU     $10
RDRH3           EQU     $08
RDRH2           EQU     $04
RDRH1           EQU     $02
RDRH0           EQU     $01

PERH            EQU     $0264
PERH7           EQU     $80
PERH6           EQU     $40
PERH5           EQU     $20
PERH4           EQU     $10
PERH3           EQU     $08
PERH2           EQU     $04
PERH1           EQU     $02
PERH0           EQU     $01

PPSH            EQU     $0265
PPSH7           EQU     $80
PPSH6           EQU     $40
PPSH5           EQU     $20
PPSH4           EQU     $10
PPSH3           EQU     $08
PPSH2           EQU     $04
PPSH1           EQU     $02
PPSH0           EQU     $01

PIEH            EQU     $0266
PIEH7           EQU     $80
PIEH6           EQU     $40
PIEH5           EQU     $20
PIEH4           EQU     $10
PIEH3           EQU     $08
PIEH2           EQU     $04
PIEH1           EQU     $02
PIEH0           EQU     $01

PIFH            EQU     $0267
PIFH7           EQU     $80
PIFH6           EQU     $40
PIFH5           EQU     $20
PIFH4           EQU     $10
PIFH3           EQU     $08
PIFH2           EQU     $04
PIFH1           EQU     $02
PIFH0           EQU     $01

PTJ             EQU     $0268
PTJ7            EQU     $80
PTJ6            EQU     $40
PTJ5            EQU     $20
PTJ4            EQU     $10
PTJ3            EQU     $08
PTJ2            EQU     $04
PTJ1            EQU     $02
PTJ0            EQU     $01
PJ7             EQU     $80
PJ6             EQU     $40
PJ5             EQU     $20
PJ4             EQU     $10
PJ3             EQU     $08
PJ2             EQU     $04
PJ1             EQU     $02
PJ0             EQU     $01

PTIJ            EQU     $0269
PTIJ7           EQU     $80
PTIJ6           EQU     $40
PTIJ5           EQU     $20
PTIJ4           EQU     $10
PTIJ3           EQU     $08
PTIJ2           EQU     $04
PTIJ1           EQU     $02
PTIJ0           EQU     $01

DDRJ            EQU     $026A
DDRJ7           EQU     $80
DDRJ6           EQU     $40
DDRJ5           EQU     $20
DDRJ4           EQU     $10
DDRJ3           EQU     $08
DDRJ2           EQU     $04
DDRJ1           EQU     $02
DDRJ0           EQU     $01

RDRJ            EQU     $026B
RDRJ7           EQU     $80
RDRJ6           EQU     $40
RDRJ5           EQU     $20
RDRJ4           EQU     $10
RDRJ3           EQU     $08
RDRJ2           EQU     $04
RDRJ1           EQU     $02
RDRJ0           EQU     $01

PERJ            EQU     $026C
PERJ7           EQU     $80
PERJ6           EQU     $40
PERJ5           EQU     $20
PERJ4           EQU     $10
PERJ3           EQU     $08
PERJ2           EQU     $04
PERJ1           EQU     $02
PERJ0           EQU     $01

PPSJ            EQU     $026D
PPSJ7           EQU     $80
PPSJ6           EQU     $40
PPSJ5           EQU     $20
PPSJ4           EQU     $10
PPSJ3           EQU     $08
PPSJ2           EQU     $04
PPSJ1           EQU     $02
PPSJ0           EQU     $01

PIEJ            EQU     $026E
PIEJ7           EQU     $80
PIEJ6           EQU     $40
PIEJ5           EQU     $20
PIEJ4           EQU     $10
PIEJ3           EQU     $08
PIEJ2           EQU     $04
PIEJ1           EQU     $02
PIEJ0           EQU     $01

PIFJ            EQU     $026F
PIFJ7           EQU     $80
PIFJ6           EQU     $40
PIFJ5           EQU     $20
PIFJ4           EQU     $10
PIFJ3           EQU     $08
PIFJ2           EQU     $04
PIFJ1           EQU     $02
PIFJ0           EQU     $01

PT0AD0          EQU     $0270
PT0AD07         EQU     $80
PT0AD06         EQU     $40
PT0AD05         EQU     $20
PT0AD04         EQU     $10
PT0AD03         EQU     $08
PT0AD02         EQU     $04
PT0AD01         EQU     $02
PT0AD00         EQU     $01

PT1AD0          EQU     $0271
PT1AD07         EQU     $80
PT1AD06         EQU     $40
PT1AD05         EQU     $20
PT1AD04         EQU     $10
PT1AD03         EQU     $08
PT1AD02         EQU     $04
PT1AD01         EQU     $02
PT1AD00         EQU     $01

DDR0AD0         EQU     $0272
DDR0AD07        EQU     $80
DDR0AD06        EQU     $40
DDR0AD05        EQU     $20
DDR0AD04        EQU     $10
DDR0AD03        EQU     $08
DDR0AD02        EQU     $04
DDR0AD01        EQU     $02
DDR0AD00        EQU     $01

DDR1AD0         EQU     $0273
DDR1AD07        EQU     $80
DDR1AD06        EQU     $40
DDR1AD05        EQU     $20
DDR1AD04        EQU     $10
DDR1AD03        EQU     $08
DDR1AD02        EQU     $04
DDR1AD01        EQU     $02
DDR1AD00        EQU     $01

RDR0AD0         EQU     $0274
RDR0AD07        EQU     $80
RDR0AD06        EQU     $40
RDR0AD05        EQU     $20
RDR0AD04        EQU     $10
RDR0AD03        EQU     $08
RDR0AD02        EQU     $04
RDR0AD01        EQU     $02
RDR0AD00        EQU     $01

RDR1AD0         EQU     $0275
RDR1AD07        EQU     $80
RDR1AD06        EQU     $40
RDR1AD05        EQU     $20
RDR1AD04        EQU     $10
RDR1AD03        EQU     $08
RDR1AD02        EQU     $04
RDR1AD01        EQU     $02
RDR1AD00        EQU     $01

PER0AD0         EQU     $0276
PER0AD07        EQU     $80
PER0AD06        EQU     $40
PER0AD05        EQU     $20
PER0AD04        EQU     $10
PER0AD03        EQU     $08
PER0AD02        EQU     $04
PER0AD01        EQU     $02
PER0AD00        EQU     $01

PER1AD0         EQU     $0277
PER1AD07        EQU     $80
PER1AD06        EQU     $40
PER1AD05        EQU     $20
PER1AD04        EQU     $10
PER1AD03        EQU     $08
PER1AD02        EQU     $04
PER1AD01        EQU     $02
PER1AD00        EQU     $01

PT0AD1          EQU     $0278
PT0AD17         EQU     $80
PT0AD16         EQU     $40
PT0AD15         EQU     $20
PT0AD14         EQU     $10
PT0AD13         EQU     $08
PT0AD12         EQU     $04
PT0AD11         EQU     $02
PT0AD10         EQU     $01

PT1AD1          EQU     $0279
PT1AD17         EQU     $80
PT1AD16         EQU     $40
PT1AD15         EQU     $20
PT1AD14         EQU     $10
PT1AD13         EQU     $08
PT1AD12         EQU     $04
PT1AD11         EQU     $02
PT1AD10         EQU     $01

DDR0AD1         EQU     $027A
DDR0AD17        EQU     $80
DDR0AD16        EQU     $40
DDR0AD15        EQU     $20
DDR0AD14        EQU     $10
DDR0AD13        EQU     $08
DDR0AD12        EQU     $04
DDR0AD11        EQU     $02
DDR0AD10        EQU     $01

DDR1AD1         EQU     $027B
DDR1AD17        EQU     $80
DDR1AD16        EQU     $40
DDR1AD15        EQU     $20
DDR1AD14        EQU     $10
DDR1AD13        EQU     $08
DDR1AD12        EQU     $04
DDR1AD11        EQU     $02
DDR1AD10        EQU     $01

RDR0AD1         EQU     $027C
RDR0AD17        EQU     $80
RDR0AD16        EQU     $40
RDR0AD15        EQU     $20
RDR0AD14        EQU     $10
RDR0AD13        EQU     $08
RDR0AD12        EQU     $04
RDR0AD11        EQU     $02
RDR0AD10        EQU     $01

RDR1AD1         EQU     $027D
RDR1AD17        EQU     $80
RDR1AD16        EQU     $40
RDR1AD15        EQU     $20
RDR1AD14        EQU     $10
RDR1AD13        EQU     $08
RDR1AD12        EQU     $04
RDR1AD11        EQU     $02
RDR1AD10        EQU     $01

PER0AD1         EQU     $027E
PER0AD17        EQU     $80
PER0AD16        EQU     $40
PER0AD15        EQU     $20
PER0AD14        EQU     $10
PER0AD13        EQU     $08
PER0AD12        EQU     $04
PER0AD11        EQU     $02
PER0AD10        EQU     $01

PER1AD1         EQU     $027F
PER1AD17        EQU     $80
PER1AD16        EQU     $40
PER1AD15        EQU     $20
PER1AD14        EQU     $10
PER1AD13        EQU     $08
PER1AD12        EQU     $04
PER1AD11        EQU     $02
PER1AD10        EQU     $01

CAN4CTL0        EQU     $0280
;RXFRM          EQU     $80
;RXACT          EQU     $40
;CSWAI          EQU     $20
;SYNCH          EQU     $10
;TIMEN          EQU     $08
;WUPE           EQU     $04
;SLPRQ          EQU     $02
;INITRQ         EQU     $01

CAN4CTL1        EQU     $0281
;CANE           EQU     $80
;CLKSRC         EQU     $40
;LOOPB          EQU     $20
;LISTEN         EQU     $10
;WUPM           EQU     $04
;SLPAK          EQU     $02
;INITAK         EQU     $01

CAN4BTR0        EQU     $0282
;SJW1           EQU     $80
;SJW0           EQU     $40
;BRP5           EQU     $20
;BRP4           EQU     $10
;BRP3           EQU     $08
;BRP2           EQU     $04
;BRP1           EQU     $02
;BRP0           EQU     $01

CAN4BTR1        EQU     $0283
;SAMP           EQU     $80
;TSEG22         EQU     $40
;TSEG21         EQU     $20
;TSEG20         EQU     $10
;TSEG13         EQU     $08
;TSEG12         EQU     $04
;TSEG11         EQU     $02
;TESG10         EQU     $01

CAN4RFLG        EQU     $0284
;WUPIF          EQU     $80
;CSCIF          EQU     $40
;RSTAT1         EQU     $20
;RSTAT0         EQU     $10
;TSTAT1         EQU     $08
;TSTAT0         EQU     $04
;OVRIF          EQU     $02
;RXF            EQU     $01

CAN4RIER        EQU     $0285
;WUPIE          EQU     $80
;CSCIE          EQU     $40
;RSTATE1        EQU     $20
;RSTATE0        EQU     $10
;TSTATE1        EQU     $08
;TSTATE0        EQU     $04
;OVRIE          EQU     $02
;RXFIE          EQU     $01

CAN4TFLG        EQU     $0286
;TXE2           EQU     $04
;TXE1           EQU     $02
;TXE0           EQU     $01

CAN4TIER        EQU     $0287
;TXEIE2         EQU     $04
;TXEIE1         EQU     $02
;TXEIE0         EQU     $01

CAN4TARQ        EQU     $0288
;ABTRQ2         EQU     $04
;ABTRQ1         EQU     $02
;ABTRQ0         EQU     $01

CAN4TAAK        EQU     $0289
;ABTAK2         EQU     $04
;ABTAK1         EQU     $02
;ABTAK0         EQU     $01

CAN4TBSEL       EQU     $028A
;TX2            EQU     $04
;TX1            EQU     $02
;TX0            EQU     $01

CAN4IDAC        EQU     $028B
;IDAM1          EQU     $20
;IDAM0          EQU     $10
;IDHIT2         EQU     $04
;IDHIT1         EQU     $02
;IDHIT0         EQU     $01

;$028C  reserved

CAN4MISC        EQU    	$028D
;BOHOLD    	EQU    	$01

CAN4RXERR       EQU     $028E
CAN4TXERR       EQU     $028F

CAN4IDAR0       EQU     $0290
CAN4IDAR1       EQU     $0291
CAN4IDAR2       EQU     $0292
CAN4IDAR3       EQU     $0293
CAN4IDMR0       EQU     $0294
CAN4IDMR1       EQU     $0295
CAN4IDMR2       EQU     $0296
CAN4IDMR3       EQU     $0297

CAN4IDAR4       EQU     $0298
CAN4IDAR5       EQU     $0299
CAN4IDAR6       EQU     $029A
CAN4IDAR7       EQU     $029B
CAN4IDMR4       EQU     $029C
CAN4IDMR5       EQU     $029D
CAN4IDMR6       EQU     $029E
CAN4IDMR7       EQU     $029F

CAN4RXIDR0      EQU     $02A0
CAN4RXIDR1      EQU     $02A1
CAN4RXIDR2      EQU     $02A2
CAN4RXIDR3      EQU     $02A3
CAN4RXDSR0      EQU     $02A4
CAN4RXDSR1      EQU     $02A5
CAN4RXDSR2      EQU     $02A6
CAN4RXDSR3      EQU     $02A7
CAN4RXDSR4      EQU     $02A8
CAN4RXDSR5      EQU     $02A9
CAN4RXDSR6      EQU     $02AA
CAN4RXDSR7      EQU     $02AB
CAN4RXDLR       EQU     $02AC

;$02AD reserved

CAN4RTSRH       EQU     $02AE
CAN4RTSRL       EQU     $02AF
CAN4TXIDR0      EQU     $02B0
CAN4TXIDR1      EQU     $02B1
CAN4TXIDR2      EQU     $02B2
CAN4TXIDR2      EQU     $02B2
CAN4TXIDR3      EQU     $02B3
CAN4TXDSR0      EQU     $02B4
CAN4TXDSR1      EQU     $02B5
CAN4TXDSR2      EQU     $02B6
CAN4XDSR3       EQU     $02B7
CAN4TXDSR3      EQU     $02B7
CAN4TXDSR4      EQU     $02B8
CAN4TXDSR5      EQU     $02B9
CAN4TXDSR6      EQU     $02BA
CAN4TXDSR7      EQU     $02BB
CAN4TXDLR       EQU     $02BC
CAN4TXTBPR      EQU     $02BD
CAN4TXTSRH      EQU     $02BE
CAN4TXTSRL      EQU     $02BF

ATD0CTL0        EQU     $02C0
ATDCTL0         EQU     $02C0
;WRAP3    	EQU    	$08
;WRAP2    	EQU    	$04
;WRAP1    	EQU    	$02
;WRAP0    	EQU    	$01

ATD0CTL1        EQU     $02C1
ATDCTL1         EQU     $02C1
;ETRIGSEL  	EQU    	$80
;SRES1     	EQU    	$40
;SRES0     	EQU    	$20
;DIS     	EQU  	$10
;ETRIGCH3  	EQU    	$08
;ETRIGCH2  	EQU    	$04
;ETRIGCH1  	EQU    	$02
;ETRIGCH0  	EQU    	$01

ATD0CTL2        EQU     $02C2
ATDCTL2         EQU     $02C2
;AFFC            EQU     $40
;ICLKSTP         EQU     $20
;ETRIGLE         EQU     $10
;ETRIGP          EQU     $08
;ETRIGE          EQU     $04
;ASCIE           EQU     $02
;ASCIF           EQU     $01

ATD0CTL3        EQU     $02C3
ATDCTL3         EQU     $02C3
;DJM             EQU     $80
;S8C             EQU     $40
;S4C             EQU     $20
;S2C             EQU     $10
;S1C             EQU     $08
;FIFO            EQU     $04
;FRZ1            EQU     $02
;FRZ0            EQU     $01

ATD0CTL4        EQU     $02C4
ATDCTL4         EQU     $02C4
;SMP2	        EQU     $80
;SMP1            EQU     $40
;SMP0            EQU     $20
;PRS4            EQU     $10
;PRS3            EQU     $08
;PRS2            EQU     $04
;PRS1            EQU     $02
;PRS0            EQU     $01

ATD0CTL5        EQU     $02C5
ATDCTL5         EQU     $02C5
;SC              EQU     $40
;SCAN            EQU     $20
;MULT            EQU     $10
;CD              EQU     $08
;CC              EQU     $04
;CB              EQU     $02
;CA              EQU     $01

ATD0STAT0       EQU     $02C6
ATDSTAT0        EQU     $02C6
;SCF             EQU     $80
;ETORF           EQU     $20
;FIFOR           EQU     $10
;CC2             EQU     $04
;CC1             EQU     $02
;CC0             EQU     $01

;$02C7 reserved

ATD0CMPEH       EQU    	$02C8
ATDCMPEH        EQU    	$02C8
;CMPE15   	EQU    	$80
;CMPE14   	EQU    	$40
;CMPE13   	EQU    	$20
;CMPE12   	EQU    	$10
;CMPE11   	EQU    	$08
;CMPE10   	EQU    	$04
;CMPE9    	EQU    	$02
;CMPE8    	EQU    	$01

ATD0CMPEL       EQU     $02C9
ATDCMPEL        EQU     $02C9
;CMPE7    	EQU     $80
;CMPE6    	EQU     $40
;CMPE5    	EQU     $20
;CMPE4    	EQU     $10
;CMPE3    	EQU     $08
;CMPE2    	EQU     $04
;CMPE1    	EQU     $02
;CMPE0    	EQU     $01

ATD0STAT2H      EQU    	$02CA
ATDSTAT2H       EQU    	$02CA
;CCF15   	EQU    	$80
;CCF14   	EQU    	$40
;CCF13   	EQU    	$20
;CCF12   	EQU    	$10
;CCF11   	EQU    	$08
;CCF10   	EQU    	$04
;CCF9    	EQU    	$02
;CCF8    	EQU    	$01

ATD0STAT2L      EQU    	$02CB
ATDSTAT2L       EQU    	$02CB
;CCF7    	EQU    	$80
;CCF6    	EQU    	$40
;CCF5    	EQU    	$20
;CCF4    	EQU    	$10
;CCF3    	EQU    	$08
;CCF2    	EQU    	$04
;CCF1    	EQU    	$02
;CCF0    	EQU    	$01

ATD0DIENH       EQU    	$02CC
ATDDIENH        EQU    	$02CC
;IEN15    	EQU    	$80
;IEN14    	EQU    	$40
;IEN13    	EQU    	$20
;IEN12    	EQU    	$10
;IEN11    	EQU    	$08
;IEN10    	EQU    	$04
;IEN9     	EQU    	$02
;IEN8     	EQU    	$01

ATD0DIENL       EQU    	$02CD
ATDDIENL        EQU    	$02CD
;IEN7     	EQU    	$80
;IEN6     	EQU    	$40
;IEN5     	EQU    	$20
;IEN4     	EQU    	$10
;IEN3     	EQU    	$08
;IEN2     	EQU    	$04
;IEN1     	EQU    	$02
;IEN0     	EQU    	$01

ATD0CMPHTH      EQU    	$02CE
ATDCMPHTH       EQU    	$02CE
;CMPHT15  	EQU    	$80
;CMPHT14  	EQU    	$40
;CMPHT13  	EQU    	$20
;CMPHT12  	EQU    	$10
;CMPHT11  	EQU    	$08
;CMPHT10  	EQU    	$04
;CMPHT9   	EQU    	$02
;CMPHT8   	EQU    	$01
		       	
ATD0CMPHTL      EQU    	$02CF
ATDCMPHTL       EQU    	$02CF
;CMPHT0  	EQU    	$01
;CMPHT1  	EQU    	$02
;CMPHT2  	EQU    	$04
;CMPHT3  	EQU    	$08
;CMPHT4  	EQU    	$10
;CMPHT5  	EQU    	$20
;CMPHT6  	EQU    	$40
;CMPHT7  	EQU    	$80

ATD0DR0         EQU    	$02D0
ATDDR0          EQU    	$02D0
ATD0DR0H        EQU    	$02D0
ATD0DR0L        EQU    	$02D1

ATD0DR1         EQU    	$02D2
ATDDR1          EQU    	$02D2
ATD0DR1H        EQU    	$02D2
ATD0DR1L        EQU    	$02D3
		       	
ATD0DR2         EQU    	$02D4
ATDDR2          EQU    	$02D4
ATD0DR2H        EQU    	$02D4
ATD0DR2L        EQU    	$02D5
		       	
ATD0DR3         EQU    	$02D6
ATDDR3          EQU    	$02D6
ATD0DR3H        EQU    	$02D6
ATD0DR3L        EQU    	$02D7
		       	
ATD0DR4         EQU    	$02D8
ATDDR4          EQU    	$02D8
ATD0DR4H        EQU    	$02D8
ATD0DR4L        EQU    	$02D9
		       	
ATD0DR5         EQU    	$02DA
ATDDR5          EQU    	$02DA
ATD0DR5H        EQU    	$02DA
ATD0DR5L        EQU    	$02DB
		       	
ATD0DR6         EQU    	$02DC
ATDDR6          EQU    	$02DC
ATD0DR6H        EQU    	$02DC
ATD0DR6L        EQU    	$02DD
		       	
ATD0DR7         EQU    	$02DE
ATDDR7          EQU    	$02DE
ATD0DR7H        EQU    	$02DE
ATD0DR7L        EQU    	$02DF
		       	
ATD0DR8         EQU    	$02E0
ATDDR8          EQU    	$02E0
ATD0DR8H        EQU    	$02E0
ATD0DR8L        EQU    	$02E1
		       	
ATD0DR9         EQU    	$02E2
ATDDR9          EQU    	$02E2
ATD0DR9H        EQU    	$02E2
ATD0DR9L        EQU    	$02E3
		       	
ATD0DR10        EQU    	$02E3
ATDDR10         EQU    	$02E3
ATD0DR10H       EQU    	$02E3
ATD0DR10L       EQU    	$02E5
		       	
ATD0DR11        EQU    	$02E6
ATDDR11         EQU    	$02E6
ATD0DR11H       EQU    	$02E6
ATD0DR11L       EQU    	$02E7
		       	
ATD0DR12        EQU    	$02E8
ATDDR12         EQU    	$02E8
ATD0DR12H       EQU    	$02E8
ATD0DR12L       EQU    	$02E9
		       	
ATD0DR13        EQU    	$02EA
ATDDR13         EQU    	$02EA
ATD0DR13H       EQU    	$02EA
ATD0DR13L       EQU    	$02EB
		       	
ATD0DR14        EQU    	$02EC
ATDDR14         EQU    	$02EC
ATD0DR14H       EQU    	$02EC
ATD0DR14L       EQU    	$02ED
		       	
ATD0DR15        EQU    	$02EE
ATDDR15         EQU    	$02EE
ATD0DR15H       EQU    	$02EE
ATD0DR15L       EQU    	$02EF

VREGHTCL        EQU    	$02F0
VSEL      	EQU    	$20
VAE       	EQU    	$10
HTEN      	EQU    	$08
HTDS      	EQU    	$04
HTIE      	EQU    	$02
HTIF      	EQU    	$01
	  	       	
VREGCTRL  	EQU    	$02F1
LVDS      	EQU    	$04
LVIE      	EQU    	$02
LVIF      	EQU    	$01

VREGAPICTL      EQU    	$02F2
APICLK   	EQU    	$80
APIES    	EQU    	$10
APIEA    	EQU    	$08
APIFE    	EQU    	$04
APIE     	EQU    	$02
APIF     	EQU    	$01
		       	
VREGAPITR       EQU    	$02F3
APITR5   	EQU    	$80
APITR4   	EQU    	$40
APITR3   	EQU    	$20
APITR2   	EQU    	$10
APITR1   	EQU    	$08
APITR0   	EQU    	$04

VREGAPIRH       EQU    	$02F4
APIR15   	EQU    	$80
APIR14   	EQU    	$40
APIR13   	EQU    	$20
APIR12   	EQU    	$10
APIR11   	EQU    	$08
APIR10   	EQU    	$04
APIR9    	EQU    	$02
APIR8    	EQU    	$01
		       	
VREGAPIRL       EQU    	$02F5
APIR7         	EQU     $80
APIR6         	EQU     $40
APIR5         	EQU     $20
APIR4         	EQU     $10
APIR3         	EQU     $08
APIR2         	EQU     $04
APIR1         	EQU     $02
APIR0         	EQU     $01

;$02F6 reserved

VREGHTTR        EQU    	$02F7
HTOEN     	EQU    	$80
HTTR      	EQU    	$0F

;$02F8 to $02FF reserved

PWME            EQU     $0300
PWME7           EQU     $80
PWME6           EQU     $40
PWME5           EQU     $20
PWME4           EQU     $10
PWME3           EQU     $08
PWME2           EQU     $04
PWME1           EQU     $02
PWME0           EQU     $01

PWMPOL          EQU     $0301
PPOL7           EQU     $80
PPOL6           EQU     $40
PPOL5           EQU     $20
PPOL4           EQU     $10
PPOL3           EQU     $08
PPOL2           EQU     $04
PPOL1           EQU     $02
PPOL0           EQU     $01

PWMCLK          EQU     $0302
PCLK7           EQU     $80
PCLK6           EQU     $40
PCLK5           EQU     $20
PCLK4           EQU     $10
PCLK3           EQU     $08
PCLK2           EQU     $04
PCLK1           EQU     $02
PCLK0           EQU     $01

PWMPRCLK        EQU     $0303
PCKB2           EQU     $40
PCKB1           EQU     $20
PCKB0           EQU     $10
PCKA2           EQU     $04
PCKA1           EQU     $02
PCKA0           EQU     $01

PWMCAE          EQU     $0304
CAE7            EQU     $80
CAE6            EQU     $40
CAE5            EQU     $20
CAE4            EQU     $10
CAE3            EQU     $08
CAE2            EQU     $04
CAE1            EQU     $02
CAE0            EQU     $01

PWMCTL          EQU     $0305
CON67           EQU     $80
CON45           EQU     $40
CON23           EQU     $20
CON01           EQU     $10
PSWAI           EQU     $08
PFRZ            EQU     $04

PWMTST          EQU     $0306
PWMPRSC         EQU     $0307

PWMSCNTA        EQU     $030A
PWMSCNTB        EQU     $030B

PWMCNT0         EQU     $030C
PWMCNT1         EQU     $030D
PWMCNT2         EQU     $030E
PWMCNT3         EQU     $030F
PWMCNT4         EQU     $0310
PWMCNT5         EQU     $0311
PWMCNT6         EQU     $0312
PWMCNT7         EQU     $0313
	
PWMPER0         EQU     $0314
PWMPER1         EQU     $0315
PWMPER2         EQU     $0316
PWMPER3         EQU     $0317
PWMPER4         EQU     $0318
PWMPER5         EQU     $0319
PWMPER6         EQU     $031A
PWMPER7         EQU     $031B

PWMDTY0         EQU     $031C
PWMDTY1         EQU     $031D
PWMDTY2         EQU     $031E
PWMDTY3         EQU     $031F
PWMDTY4         EQU     $0320
PWMDTY5         EQU     $0321
PWMDTY6         EQU     $0322
PWMDTY7         EQU     $0323

PWMSDN          EQU    	$0324
PWMIF       	EQU    	$80
PWMIE       	EQU    	$40
PWMRSTRT    	EQU    	$20
PWMLVL      	EQU    	$10
PWM7IN      	EQU    	$04
PWM7INL     	EQU    	$02
PWM7ENA     	EQU    	$01

;$0325 to $032F reserved

SCI6BDH         EQU     $0330
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI6ASR1        EQU     $0330
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCI6BDL         EQU     $0331
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI6ACR1        EQU     $0331
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCI6CR1         EQU     $0332
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI6ACR2        EQU     $0332
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCI6CR2         EQU     $0333
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCI6SR1         EQU     $0334
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF          EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCI6SR2         EQU     $0335
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCI6DRH         EQU     $0336
;R8             EQU     $80
;T8             EQU     $40

SCI6DRL         EQU     $0337

SCI7BDH         EQU     $0338
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI7ASR1        EQU     $0338
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCI7BDL         EQU     $0339
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI7ACR1        EQU     $0339
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCI7CR1         EQU     $033A
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI7ACR2        EQU     $033A
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCI7CR2         EQU     $033B
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCI7SR1         EQU     $033C
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF          EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCI7SR2         EQU     $0335D
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCI7DRH         EQU     $033E
;R8             EQU     $80
;T8             EQU     $40

SCI7DRL         EQU     $033F

PITCFLMT        EQU    	$0340
PITE      	EQU    	$80
PITSWAI   	EQU    	$40
PITFRZ    	EQU    	$20
PFLMT1    	EQU    	$02
PFLMT0    	EQU    	$01

PITFLT          EQU    	$0341
PFLT7           EQU     $80
PFLT6           EQU     $40
PFLT5           EQU     $20
PFLT4           EQU     $10
PFLT3           EQU     $08
PFLT2           EQU     $04
PFLT1           EQU     $02
PFLT0           EQU     $01

PITCE           EQU    	$0342
PCE7           	EQU     $80
PCE6           	EQU     $40
PCE5           	EQU     $20
PCE4           	EQU     $10
PCE3           	EQU     $08
PCE2           	EQU     $04
PCE1           	EQU     $02
PCE0           	EQU     $01

PITMUX          EQU    	$0343
PMUX7           EQU     $80
PMUX6           EQU     $40
PMUX5           EQU     $20
PMUX4           EQU     $10
PMUX3           EQU     $08
PMUX2           EQU     $04
PMUX1           EQU     $02
PMUX0           EQU     $01

PITINTE         EQU    	$0344
PINTE7          EQU     $80
PINTE6          EQU     $40
PINTE5          EQU     $20
PINTE4          EQU     $10
PINTE3          EQU     $08
PINTE2          EQU     $04
PINTE1          EQU     $02
PINTE0          EQU     $01

PITTF           EQU    	$0345
PTF7           	EQU     $80
PTF6           	EQU     $40
PTF5           	EQU     $20
PTF4           	EQU     $10
PTF3           	EQU     $08
PTF2           	EQU     $04
PTF1           	EQU     $02
PTF0           	EQU     $01

PITMTLD0        EQU    	$0346
PMTLD7          EQU     $80
PMTLD6          EQU     $40
PMTLD5          EQU     $20
PMTLD4          EQU     $10
PMTLD3          EQU     $08
PMTLD2          EQU     $04
PMTLD1          EQU     $02
PMTLD0          EQU     $01

PITMTLD1        EQU    	$0347
;PMTLD7         EQU     $80
;PMTLD6         EQU     $40
;PMTLD5         EQU     $20
;PMTLD4         EQU     $10
;PMTLD3         EQU     $08
;PMTLD2         EQU     $04
;PMTLD1         EQU     $02
;PMTLD0         EQU     $01

PITLD0          EQU    	$0348
PITCNT0         EQU    	$034A
		       	
PITLD1          EQU    	$034C
PITCNT1         EQU    	$034E
		       	
PITLD2          EQU    	$0350
PITCNT2         EQU    	$0352
		       	
PITLD3          EQU    	$0354
PITCNT3         EQU    	$0356
		       	
PITLD4          EQU    	$0358
PITCNT4         EQU    	$035A
		       	
PITLD5          EQU    	$035C
PITCNT5         EQU    	$035E
		       	
PITLD6          EQU    	$0360
PITCNT6         EQU    	$0362
		       	
PITLD7          EQU    	$0364
PITCNT7         EQU    	$0366
		       	
PTR             EQU    	$0368
PTR7          	EQU     $80
PTR6          	EQU     $40
PTR5          	EQU     $20
PTR4          	EQU     $10
PTR3          	EQU     $08
PTR2          	EQU     $04
PTR1          	EQU     $02
PTR0          	EQU     $01

PTIR            EQU    	$0369
PTIR7          	EQU     $80
PTIR6          	EQU     $40
PTIR5          	EQU     $20
PTIR4          	EQU     $10
PTIR3          	EQU     $08
PTIR2          	EQU     $04
PTIR1          	EQU     $02
PTIR0          	EQU     $01

DDRR            EQU    	$036A
DDRR7          	EQU     $80
DDRR6          	EQU     $40
DDRR5          	EQU     $20
DDRR4          	EQU     $10
DDRR3          	EQU     $08
DDRR2          	EQU     $04
DDRR1          	EQU     $02
DDRR0          	EQU     $01

RDRR            EQU    	$036B
RDRR7          	EQU     $80
RDRR6          	EQU     $40
RDRR5          	EQU     $20
RDRR4          	EQU     $10
RDRR3          	EQU     $08
RDRR2          	EQU     $04
RDRR1          	EQU     $02
RDRR0          	EQU     $01

PERR            EQU    	$036C
PERR7          	EQU     $80
PERR6          	EQU     $40
PERR5          	EQU     $20
PERR4          	EQU     $10
PERR3          	EQU     $08
PERR2          	EQU     $04
PERR1          	EQU     $02
PERR0          	EQU     $01

PPSR            EQU    	$036D
PPSR7          	EQU     $80
PPSR6          	EQU     $40
PPSR5          	EQU     $20
PPSR4          	EQU     $10
PPSR3          	EQU     $08
PPSR2          	EQU     $04
PPSR1          	EQU     $02
PPSR0          	EQU     $01

PTRRR           EQU    	$036F
PTRRR7          EQU     $80
PTRRR6          EQU     $40
PTRRR5          EQU     $20
PTRRR4          EQU     $10
PTRRR3          EQU     $08
PTRRR2          EQU     $04
PTRRR1          EQU     $02
PTRRR0          EQU     $01

PTL             EQU    	$0370
PTL7          	EQU     $80
PTL6          	EQU     $40
PTL5          	EQU     $20
PTL4          	EQU     $10
PTL3          	EQU     $08
PTL2          	EQU     $04
PTL1          	EQU     $02
PTL0          	EQU     $01

PTIL            EQU    	$0371
PTIL7          	EQU     $80
PTIL6          	EQU     $40
PTIL5          	EQU     $20
PTIL4          	EQU     $10
PTIL3          	EQU     $08
PTIL2          	EQU     $04
PTIL1          	EQU     $02
PTIL0          	EQU     $01

DDRL            EQU    	$0372
DDRL7          	EQU     $80
DDRL6          	EQU     $40
DDRL5          	EQU     $20
DDRL4          	EQU     $10
DDRL3          	EQU     $08
DDRL2          	EQU     $04
DDRL1          	EQU     $02
DDRL0          	EQU     $01

RDRL            EQU    	$0373
RDRL7          	EQU     $80
RDRL6          	EQU     $40
RDRL5          	EQU     $20
RDRL4          	EQU     $10
RDRL3          	EQU     $08
RDRL2          	EQU     $04
RDRL1          	EQU     $02
RDRL0          	EQU     $01

PERL            EQU    	$0374
PERL7          	EQU     $80
PERL6          	EQU     $40
PERL5          	EQU     $20
PERL4          	EQU     $10
PERL3          	EQU     $08
PERL2          	EQU     $04
PERL1          	EQU     $02
PERL0          	EQU     $01

PPSL            EQU    	$0375
PPSL7          	EQU     $80
PPSL6          	EQU     $40
PPSL5          	EQU     $20
PPSL4          	EQU     $10
PPSL3          	EQU     $08
PPSL2          	EQU     $04
PPSL1          	EQU     $02
PPSL0          	EQU     $01

WOML            EQU     $0376
WOML7          	EQU     $80
WOML6          	EQU     $40
WOML5          	EQU     $20
WOML4          	EQU     $10
WOML3          	EQU     $08
WOML2          	EQU     $04
WOML1          	EQU     $02
WOML0          	EQU     $01

PTLRR           EQU    	$0377
PTLRR7          EQU     $80
PTLRR6          EQU     $40
PTLRR5          EQU     $20
PTLRR4          EQU     $10

PTF             EQU   	$0378
PTF7          	EQU     $80
PTF6          	EQU     $40
PTF5          	EQU     $20
PTF4          	EQU     $10
PTF3          	EQU     $08
PTF2          	EQU     $04
PTF1          	EQU     $02
PTF0          	EQU     $01

PTIF            EQU    	$0379
PTIF7          	EQU     $80
PTIF6          	EQU     $40
PTIF5          	EQU     $20
PTIF4          	EQU     $10
PTIF3          	EQU     $08
PTIF2          	EQU     $04
PTIF1          	EQU     $02
PTIF0          	EQU     $01

DDRF            EQU    	$037A
DDRF7          	EQU     $80
DDRF6          	EQU     $40
DDRF5          	EQU     $20
DDRF4          	EQU     $10
DDRF3          	EQU     $08
DDRF2          	EQU     $04
DDRF1          	EQU     $02
DDRF0          	EQU     $01

RDRF            EQU    	$037B
RDRF7          	EQU     $80
RDRF6          	EQU     $40
RDRF5          	EQU     $20
RDRF4          	EQU     $10
RDRF3          	EQU     $08
RDRF2          	EQU     $04
RDRF1          	EQU     $02
RDRF0          	EQU     $01

PERF            EQU    	$037C
PERF7          	EQU     $80
PERF6          	EQU     $40
PERF5          	EQU     $20
PERF4          	EQU     $10
PERF3          	EQU     $08
PERF2          	EQU     $04
PERF1          	EQU     $02
PERF0          	EQU     $01

PPSF            EQU    	$037D
PPSF7          	EQU     $80
PPSF6          	EQU     $40
PPSF5          	EQU     $20
PPSF4          	EQU     $10
PPSF3          	EQU     $08
PPSF2          	EQU     $04
PPSF1          	EQU     $02
PPSF0          	EQU     $01

PTFRR           EQU    	$037F
PTFRR5          EQU     $20
PTFRR4          EQU     $10
PTFRR3          EQU     $08
PTFRR2          EQU     $04
PTFRR1          EQU     $02
PTFRR0          EQU     $01

XGMCTL          EQU    	$0380
XGEM        	EQU    	$8000
XGFRZM      	EQU    	$4000
XGDBGM      	EQU    	$2000
XGSSM       	EQU    	$1000
XGFACTM     	EQU    	$0800
XGSWEFM     	EQU    	$0200
XGIEM       	EQU    	$0100
XGE         	EQU    	$0080
XGFRZ       	EQU    	$0040
XGDBG       	EQU    	$0020
XGSS        	EQU    	$0010
XGFACT      	EQU    	$0008
XGSWEF      	EQU    	$0002
XGIE        	EQU    	$0001

XGCHID          EQU    	$0382
XGCHPL          EQU     $0383

XGISPSEL        EQU    	$0385
XGISP31         EQU    	$0386
XGISP74         EQU    	$0386
XGVBR           EQU    	$0386

XGIF_7F_78 	EQU	$0388
XGIF_7F         EQU     $80
XGIF_7E         EQU     $40
XGIF_7D         EQU     $20
XGIF_7C         EQU     $10
XGIF_7B         EQU     $08
XGIF_7A         EQU     $04
XGIF_79         EQU     $02
XGIF_78         EQU     $01

XGIF_77_70 	EQU	$0389
XGIF_77         EQU     $80
XGIF_76         EQU     $40
XGIF_75         EQU     $20
XGIF_74         EQU     $10
XGIF_73         EQU     $08
XGIF_72         EQU     $04
XGIF_71         EQU     $02
XGIF_70         EQU     $01

XGIF_6F_68 	EQU	$038A
XGIF_6F         EQU     $80
XGIF_6E         EQU     $40
XGIF_6D         EQU     $20
XGIF_6C         EQU     $10
XGIF_6B         EQU     $08
XGIF_6A         EQU     $04
XGIF_69         EQU     $02
XGIF_68         EQU     $01

XGIF_67_60 	EQU	$038B
XGIF_67         EQU     $80
XGIF_66         EQU     $40
XGIF_65         EQU     $20
XGIF_64         EQU     $10
XGIF_63         EQU     $08
XGIF_62         EQU     $04
XGIF_61         EQU     $02
XGIF_60         EQU     $01
	
XGIF_5F_58 	EQU	$038C
XGIF_5F         EQU     $80
XGIF_5E         EQU     $40
XGIF_5D         EQU     $20
XGIF_5C         EQU     $10
XGIF_5B         EQU     $08
XGIF_5A         EQU     $04
XGIF_59         EQU     $02
XGIF_58         EQU     $01

XGIF_57_50 	EQU	$038D
XGIF_57         EQU     $80
XGIF_56         EQU     $40
XGIF_55         EQU     $20
XGIF_54         EQU     $10
XGIF_53         EQU     $08
XGIF_52         EQU     $04
XGIF_51         EQU     $02
XGIF_50         EQU     $01

XGIF_4F_48 	EQU	$038E
XGIF_4F         EQU     $80
XGIF_4E         EQU     $40
XGIF_4D         EQU     $20
XGIF_4C         EQU     $10
XGIF_4B         EQU     $08
XGIF_4A         EQU     $04
XGIF_49         EQU     $02
XGIF_48         EQU     $01

XGIF_47_40 	EQU	$038F
XGIF_47         EQU     $80
XGIF_46         EQU     $40
XGIF_45         EQU     $20
XGIF_44         EQU     $10
XGIF_43         EQU     $08
XGIF_42         EQU     $04
XGIF_41         EQU     $02
XGIF_40         EQU     $01

XGIF_3F_38 	EQU	$0390
XGIF_3F         EQU     $80
XGIF_3E         EQU     $40
XGIF_3D         EQU     $20
XGIF_3C         EQU     $10
XGIF_3B         EQU     $08
XGIF_3A         EQU     $04
XGIF_39         EQU     $02
XGIF_38         EQU     $01

XGIF_37_30 	EQU	$0391
XGIF_37         EQU     $80
XGIF_36         EQU     $40
XGIF_35         EQU     $20
XGIF_34         EQU     $10
XGIF_33         EQU     $08
XGIF_32         EQU     $04
XGIF_31         EQU     $02
XGIF_30         EQU     $01

XGIF_2F_28 	EQU	$0392
XGIF_2F         EQU     $80
XGIF_2E         EQU     $40
XGIF_2D         EQU     $20
XGIF_2C         EQU     $10
XGIF_2B         EQU     $08
XGIF_2A         EQU     $04
XGIF_29         EQU     $02
XGIF_28         EQU     $01

XGIF_27_20 	EQU	$0393
XGIF_27         EQU     $80
XGIF_26         EQU     $40
XGIF_25         EQU     $20
XGIF_24         EQU     $10
XGIF_23         EQU     $08
XGIF_22         EQU     $04
XGIF_21         EQU     $02
XGIF_20         EQU     $01

XGIF_1F_18 	EQU	$0394
XGIF_1F         EQU     $80
XGIF_1E         EQU     $40
XGIF_1D         EQU     $20
XGIF_1C         EQU     $10
XGIF_1B         EQU     $08
XGIF_1A         EQU     $04
XGIF_19         EQU     $02
XGIF_18         EQU     $01

XGIF_17_10 	EQU	$0395
XGIF_17         EQU     $80
XGIF_16         EQU     $40
XGIF_15         EQU     $20
XGIF_14         EQU     $10
XGIF_13         EQU     $08
XGIF_12         EQU     $04
XGIF_11         EQU     $02
XGIF_10         EQU     $01

XGIF_0F_08 	EQU	$0396
XGIF_0F         EQU     $80
XGIF_0E         EQU     $40
XGIF_0D         EQU     $20
XGIF_0C         EQU     $10
XGIF_0B         EQU     $08
XGIF_0A         EQU     $04
XGIF_09         EQU     $02
XGIF_08         EQU     $01

XGIF_07_00 	EQU	$0397
XGIF_07         EQU     $80
XGIF_06         EQU     $40
XGIF_05         EQU     $20
XGIF_04         EQU     $10
XGIF_03         EQU     $08
XGIF_02         EQU     $04
XGIF_01         EQU     $02
XGIF_00         EQU     $01

XGSWT           EQU    	$0398

XGSEM           EQU    	$039A

;$039C reserved

XGCCR           EQU    	$039D
XGN          	EQU    	$08
XGZ          	EQU    	$04
XGV          	EQU    	$02
XGC          	EQU    	$01

XGPC            EQU    	$039E

;$03A0 to $03A1 reserved

XGR1            EQU    	$03A2
XGR2            EQU    	$03A4
XGR3            EQU    	$03A6
XGR4            EQU    	$03A8
XGR5            EQU    	$03AA
XGR6            EQU    	$03AC
XGR7            EQU    	$03AE

;$03B0 to $03CF reserved

TIM_TIOS        EQU     $03D0
;IOS7           EQU     $80
;IOS6           EQU     $40
;IOS5           EQU     $20
;IOS4           EQU     $10
;IOS3           EQU     $08
;IOS2           EQU     $04
;IOS1           EQU     $02
;IOS0           EQU     $01

TIM_TCFORC      EQU    	$03D1
;FOC7           EQU     $80
;FOC6           EQU     $40
;FOC5           EQU     $20
;FOC4           EQU     $10
;FOC3           EQU     $08
;FOC2           EQU     $04
;FOC1           EQU     $02
;FOC0           EQU     $01

TIM_TOC7M       EQU     $03D2
;OC7M7          EQU     $80
;OC7M6          EQU     $40
;OC7M5          EQU     $20
;OC7M4          EQU     $10
;OC7M3          EQU     $08
;OC7M2          EQU     $04
;OC7M1          EQU     $02
;OC7M0          EQU     $01

TIM_TOC7D       EQU     $03D3
;OC7D7          EQU     $80
;OC7D6          EQU     $40
;OC7D5          EQU     $20
;OC7D4          EQU     $10
;OC7D3          EQU     $08
;OC7D2          EQU     $04
;OC7D1          EQU     $02
;OC7D0          EQU     $01

TIM_TCNT        EQU     $03D4

TIM_TSCR1       EQU     $03D6
;TEN            EQU     $80
;TSWAI          EQU     $40
;TSFRZ          EQU     $20
;TFFCA          EQU     $10

TIM_TTOV        EQU     $03D7
;TOV7           EQU     $80
;TOV6           EQU     $40
;TOV5           EQU     $20
;TOV4           EQU     $10
;TOV3           EQU     $08
;TOV2           EQU     $04
;TOV1           EQU     $02
;TOV0           EQU     $01

TIM_TCTL1       EQU     $03D8
;OM7            EQU     $80
;OL7            EQU     $40
;OM6            EQU     $20
;OL6            EQU     $10
;OM5            EQU     $08
;OL5            EQU     $04
;OM4            EQU     $02
;OL4            EQU     $01

TIM_TCTL2       EQU     $03D9
;OM3            EQU     $80
;OL3            EQU     $40
;OM2            EQU     $20
;OL2            EQU     $10
;OM1            EQU     $08
;OL1            EQU     $04
;OM0            EQU     $02
;OL0            EQU     $01

TIM_TCTL3       EQU     $03DA
;EDG7B          EQU     $80
;EDG7A          EQU     $40
;EDG6B          EQU     $20
;EDG6A          EQU     $10
;EDG5B          EQU     $08
;EDG5A          EQU     $04
;EDG4B          EQU     $02
;EDG4A          EQU     $01

TIM_TCTL4       EQU     $03DB
;EDG3B          EQU     $80
;EDG3A          EQU     $40
;EDG2B          EQU     $20
;EDG2A          EQU     $10
;EDG1B          EQU     $08
;EDG1A          EQU     $04
;EDG0B          EQU     $02
;EDG0A          EQU     $01

TIM_TIE         EQU     $03DC
;C7I            EQU     $80
;C6I            EQU     $40
;C5I            EQU     $20
;C4I            EQU     $10
;C3I            EQU     $08
;C2I            EQU     $04
;C1I            EQU     $02
;C0I            EQU     $01

TIM_TSCR2       EQU     $03DD
;TOI            EQU     $80
;TCRE           EQU     $08
;PR2            EQU     $04
;PR1            EQU     $02
;PR0            EQU     $01

TIM_TFLG1       EQU     $03DE
;C7F            EQU     $80
;C6F            EQU     $40
;C5F            EQU     $20
;C4F            EQU     $10
;C3F            EQU     $08
;C2F            EQU     $04
;C1F            EQU     $02
;C0F            EQU     $01

TIM_TFLG2       EQU     $03DF
;TOF            EQU     $80

TIM_TC0         EQU     $03E0
TIM_TC1         EQU     $0052
TIM_TC2         EQU     $0054
TIM_TC3         EQU     $0056
TIM_TC4         EQU     $0058
TIM_TC5         EQU     $005A
TIM_TC6         EQU     $005C
TIM_TC7         EQU     $005E

TIM_PACTL       EQU     $03F0
;PAEN           EQU     $40
;PAMOD          EQU     $20
;PEDGE          EQU     $10
;CLK1           EQU     $08
;CLK0           EQU     $04
;PAOVI          EQU     $02
;PAI            EQU     $01

TIM_PAFLG       EQU     $03F1
;PAOVF          EQU     $02
;PAIF           EQU     $01

TIM_PACNT       EQU     $03F2
TIM_PACN1       EQU     $03F2
TIM_PACNH       EQU     $03F2
TIM_PACN0       EQU     $03F3
TIM_PACNL       EQU     $03F3

;$03F4 to $03FB reserved

TIM_OCPD	EQU	$03FC
;OCPD0     	EQU    	$01
;OCPD1     	EQU    	$02
;OCPD2     	EQU    	$04
;OCPD3     	EQU    	$08
;OCPD4     	EQU    	$10
;OCPD5     	EQU    	$20
;OCPD6     	EQU    	$40
;OCPD7     	EQU    	$80

;$03FD reserved

TIM_PTPSR	EQU	$03FE
;PTPS0    	EQU    	$01
;PTPS1    	EQU    	$02
;PTPS2    	EQU    	$04
;PTPS3    	EQU    	$08
;PTPS4    	EQU    	$10
;PTPS5    	EQU    	$20
;PTPS6    	EQU    	$40
;PTPS7    	EQU    	$80

;$03FF to $07FF reserved

;NVM locations 
BAKEY0          EQU    	$FF00
BAKEY1          EQU    	$FF02
BAKEY2          EQU    	$FF04
BAKEY3          EQU    	$FF06
		       	
NVFPROT         EQU    	$FF0C
FPOPEN     	EQU    	$80
RNV6       	EQU    	$40
FPHDIS     	EQU    	$20
FPHS1      	EQU    	$10
FPHS0      	EQU    	$08
FPLDIS     	EQU    	$04
FPLS1      	EQU    	$02
FPLS0       	EQU    	$01

NVEPROT         EQU    	$FF0D
EPOPEN     	EQU    	$80
RNV6       	EQU    	$40
RNV5       	EQU    	$20
RNV4       	EQU    	$10
EPDIS      	EQU    	$08
EPS2       	EQU    	$04
EPS1       	EQU    	$02
EPS0       	EQU    	$01

NVFOPT          EQU    	$FF0E
NV7         	EQU    	$80
NV6         	EQU    	$40
NV5         	EQU    	$20
NV4         	EQU    	$10
NV3         	EQU    	$08
NV2         	EQU    	$04
NV1         	EQU    	$02
NV0         	EQU    	$01

NVFSEC          EQU    	$FF0F
KEYEN1      	EQU    	$80
KEYEN0      	EQU    	$40
RNV5        	EQU    	$20
RNV4        	EQU    	$10
RNV3        	EQU    	$08
RNV2        	EQU    	$04
SEC1        	EQU    	$02
SEC0        	EQU    	$01
#endif
