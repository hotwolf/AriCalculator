#ifndef	REGDEF_COMPILED
#define REGDEF_COMPILED
;###############################################################################
;# S12CBase - REGDEF - Register Definitions (S12G-Micro-EVB)                   #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;#    This module defines the register map of the S12G-family.                 #
;###############################################################################
;# Required Modules:                                                           #
;#    - none                                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    Apr 1, 2010                                                              #
;#      - Initial release                                                      #
;###############################################################################
;#############################
;# S12G Register Definitions #
;#############################
PORTA		EQU	$0000
PTA7		EQU	$80
PTA6		EQU	$40
PTA5		EQU	$20
PTA4		EQU	$10
PTA3		EQU	$08
PTA2		EQU	$04
PTA1		EQU	$02
PTA0		EQU	$01
PA7		EQU	$80
PA6		EQU	$40
PA5		EQU	$20
PA4		EQU	$10
PA3		EQU	$08
PA2		EQU	$04
PA1		EQU	$02
PA0		EQU	$01

PORTB		EQU	$0001
PTB7		EQU	$80
PTB6		EQU	$40
PTB5		EQU	$20
PTB4		EQU	$10
PTB3		EQU	$08
PTB2		EQU	$04
PTB1		EQU	$02
PTB0		EQU	$01
PB7		EQU	$80
PB6		EQU	$40
PB5		EQU	$20
PB4		EQU	$10
PB3		EQU	$08
PB2		EQU	$04
PB1		EQU	$02
PB0		EQU	$01

DDRA		EQU	$0002
DDRA7		EQU	$80
DDRA6		EQU	$40
DDRA5		EQU	$20
DDRA4		EQU	$10
DDRA3		EQU	$08
DDRA2		EQU	$04
DDRA1		EQU	$02
DDRA0		EQU	$01

DDRB		EQU	$0003
DDRB7		EQU	$80
DDRB6		EQU	$40
DDRB5		EQU	$20
DDRB4		EQU	$10
DDRB3		EQU	$08
DDRB2		EQU	$04
DDRB1		EQU	$02
DDRB0		EQU	$01

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

PORTE		EQU	$0008
PTE1		EQU	$02
PTE0		EQU	$01
PE1		EQU	$02
PE0		EQU	$01

DDRE		EQU	$0009
DDRE1		EQU	$02
DDRE0		EQU	$01

;$000A reserved

MODE            EQU     $000B
MODC            EQU     $80

PUCR            EQU     $000C
BKPUE           EQU     $40
PUPEE           EQU     $10
PUPDE           EQU     $08
PUPCE           EQU     $04
PUPBE           EQU     $02
PUPAE           EQU     $01

;$000D to $0010 reserved

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
	
MMCCTL          EQU     $0013
NVMRES           EQU     $01

;$0014 reserved

PPAGE           EQU     $0015
PIX3            EQU     $08
PIX2            EQU     $04
PIX1            EQU     $02
PIX0            EQU     $01

;$0006 to $0019 reserved

PARTIDH		EQU	$001A
ID15		EQU	$80
ID14		EQU	$40
ID13		EQU	$20
ID12		EQU	$10
ID11		EQU	$08
ID10		EQU	$04
ID9		EQU	$02
ID8		EQU	$01

PARTIDL		EQU	$001B
ID7		EQU	$80
ID6		EQU	$40
ID5		EQU	$20
ID4		EQU	$10
ID3		EQU	$08
ID2		EQU	$04
ID1		EQU	$02
ID0		EQU	$01

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
BDM             EQU     $10
DBGBRK          EQU     $04
COMRV           EQU     $03

DBGSR           EQU    	$0021
TBF          	EQU    	$80
SSF2         	EQU    	$04
SSF1         	EQU    	$02
SSF0         	EQU    	$01

DBGTCR          EQU    	$0022
TSOURCE     	EQU    	$40
TRCMOD      	EQU    	$0C
TALIGN      	EQU    	$01

DBGC2           EQU    	$0023
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
TBF		EQU    	$80
CNT		EQU    	$7F

DBGSCRX         EQU    	$0027
SC3        	EQU    	$08
SC2        	EQU    	$04
SC1        	EQU    	$02
SC0        	EQU    	$01

DBGMFR          EQU     $0027
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
NDB       	EQU    	$02
COMPE      	EQU    	$01

DBGXAH          EQU    $0029
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

DBGADH          EQU    	$002C
DBGAD15       	EQU    	$80
DBGAD14       	EQU    	$40
DBGAD13       	EQU    	$20
DBGAD12       	EQU    	$10
DBGAD11       	EQU    	$08
DBGAD10       	EQU    	$04
DBGAD9        	EQU    	$02
DBGAD8        	EQU    	$01

DBGADL          EQU    	$002D
DBGAD7        	EQU    	$80
DBGAD6        	EQU    	$40
DBGAD5        	EQU    	$20
DBGAD4        	EQU    	$10
DBGAD3        	EQU    	$08
DBGAD2        	EQU    	$04
DBGAD1        	EQU    	$02
DBGAD0        	EQU    	$01

DBGADHM         EQU    	$002E
DBGADM15       	EQU    	$80
DBGADM14       	EQU    	$40
DBGADM13       	EQU    	$20
DBGADM12       	EQU    	$10
DBGADM11       	EQU    	$08
DBGADM10       	EQU    	$04
DBGADM9        	EQU    	$02
DBGADM8        	EQU    	$01
		       	
DBGADLM         EQU    	$002F
DBGADM7        	EQU    	$80
DBGADM6        	EQU    	$40
DBGADM5        	EQU    	$20
DBGADM4        	EQU    	$10
DBGADM3        	EQU    	$08
DBGADM2        	EQU    	$04
DBGADM1        	EQU    	$02
DBGADM0        	EQU    	$01

;$0030 to $0033 reserved

CPMUSYNR        EQU     $0034
SYNR            EQU     $0034
VCOFRQ1        	EQU     $80
VCOFRQ0        	EQU     $40
SYNDIV5         EQU     $20
SYNDIV4         EQU     $10
SYNDIV3         EQU     $08
SYNDIV2         EQU     $04
SYNDIV1         EQU     $02
SYNDIV0         EQU     $01

CPMUREFDV       EQU     $0035
REFDV           EQU     $0035
REFFRQ1      	EQU    	$80
REFFRQ0      	EQU    	$40
REFDIV3         EQU     $08
REFDIV2         EQU     $04
REFDIV1         EQU     $02
REFDIV0         EQU     $01

CPMUPOSTDIV     EQU    	$0036
POSTDIV         EQU    	$0036
POSTDIV4   	EQU    	$10
POSTDIV3   	EQU     $08
POSTDIV2   	EQU    	$04
POSTDIV1   	EQU    	$02
POSTDIV0   	EQU    	$01

CPMUFLG         EQU     $0037
RTIF            EQU     $80
PORF            EQU     $40
LVRF            EQU     $20
LOCKIF          EQU     $10
LOCK            EQU     $08
ILAF	        EQU     $04
OSCIF           EQU     $02
UPOSC           EQU     $01

CPMUINT         EQU     $0038
RTIE            EQU     $80
LOCKIE          EQU     $10
OSCIE           EQU     $02

CPMUCLKS        EQU     $0039
PLLSEL          EQU     $80
PSTP            EQU     $40
PRE             EQU     $08
PCE             EQU     $04
RTIOSCSEL       EQU     $02
COPOSCSEL       EQU     $01

CPMUPLL         EQU     $003A
FM1            	EQU     $20
FM0             EQU     $10

CPMURTI         EQU     $003B
RTDEC      	EQU     $80
RTR6            EQU     $40
RTR5            EQU     $20
RTR4            EQU     $10
RTR3            EQU     $08
RTR2            EQU     $04
RTR1            EQU     $02
RTR0            EQU     $01

CPMUCOP         EQU     $003C
WCOP            EQU     $80
RSBCK           EQU     $40
WRTMASK     	EQU    	$20
CR2             EQU     $04
CR1             EQU     $02
CR0             EQU     $01

;$003D to $003E reserved

CPMUARMCOP      EQU     $003F
ARMCOP          EQU     $003F

TIOS		EQU	$0040
IOS7		EQU	$80
IOS6		EQU	$40
IOS5		EQU	$20
IOS4		EQU	$10
IOS3		EQU	$08
IOS2		EQU	$04
IOS1		EQU	$02
IOS0		EQU	$01

TCFORC		EQU	$0041
FOC7		EQU	$80
FOC6		EQU	$40
FOC5		EQU	$20
FOC4		EQU	$10
FOC3		EQU	$08
FOC2		EQU	$04
FOC1		EQU	$02
FOC0		EQU	$01

TOC7M		EQU	$0042
OC7M7		EQU	$80
OC7M6		EQU	$40
OC7M5		EQU	$20
OC7M4		EQU	$10
OC7M3		EQU	$08
OC7M2		EQU	$04
OC7M1		EQU	$02
OC7M0		EQU	$01

TOC7D		EQU	$0043
OC7D7		EQU	$80
OC7D6		EQU	$40
OC7D5		EQU	$20
OC7D4		EQU	$10
OC7D3		EQU	$08
OC7D2		EQU	$04
OC7D1		EQU	$02
OC7D0		EQU	$01

TCNT		EQU	$0044

TSCR1		EQU	$0046
TEN		EQU	$80
TSWAI		EQU	$40
TSFRZ		EQU	$20
TFFCA		EQU	$10
PRNT		EQU	$08

TTOV		EQU	$0047
TOV7		EQU	$80
TOV6		EQU	$40
TOV5		EQU	$20
TOV4		EQU	$10
TOV3		EQU	$08
TOV2		EQU	$04
TOV1		EQU	$02
TOV0		EQU	$01

TCTL1		EQU	$0048
OM7		EQU	$80
OL7		EQU	$40
OM6		EQU	$20
OL6		EQU	$10
OM5		EQU	$08
OL5		EQU	$04
OM4		EQU	$02
OL4		EQU	$01

TCTL2		EQU	$0049
OM3		EQU	$80
OL3		EQU	$40
OM2		EQU	$20
OL2		EQU	$10
OM1		EQU	$08
OL1		EQU	$04
OM0		EQU	$02
OL0		EQU	$01

TCTL3		EQU	$004A
EDG7B		EQU	$80
EDG7A		EQU	$40
EDG6B		EQU	$20
EDG6A		EQU	$10
EDG5B		EQU	$08
EDG5A		EQU	$04
EDG4B		EQU	$02
EDG4A		EQU	$01

TCTL4		EQU	$004B
EDG3B		EQU	$80
EDG3A		EQU	$40
EDG2B		EQU	$20
EDG2A		EQU	$10
EDG1B		EQU	$08
EDG1A		EQU	$04
EDG0B		EQU	$02
EDG0A		EQU	$01

TIE		EQU	$004C
C7I		EQU	$80
C6I		EQU	$40
C5I		EQU	$20
C4I		EQU	$10
C3I		EQU	$08
C2I		EQU	$04
C1I		EQU	$02
C0I		EQU	$01

TSCR2		EQU	$004D
TOI		EQU	$80
TCRE		EQU	$08
PR2		EQU	$04
PR1		EQU	$02
PR0		EQU	$01

TFLG1		EQU	$004E
C7F		EQU	$80
C6F		EQU	$40
C5F		EQU	$20
C4F		EQU	$10
C3F		EQU	$08
C2F		EQU	$04
C1F		EQU	$02
C0F		EQU	$01

TFLG2		EQU	$004F
TOF		EQU	$80

TC0		EQU	$0050
TC1		EQU	$0052
TC2		EQU	$0054
TC3		EQU	$0056
TC4		EQU	$0058
TC5		EQU	$005A
TC6		EQU	$005C
TC7		EQU	$005E

PACTL		EQU	$0060
PAEN		EQU	$40
PAMOD		EQU	$20
PEDGE		EQU	$10
CLK1		EQU	$08
CLK0		EQU	$04
PAOVI		EQU	$02
PAI		EQU	$01

PAFLG		EQU	$0061
PAOVF		EQU	$02
PAIF		EQU	$01

PACNT		EQU	$0062

;$0064 to $006B reserved

OCPD		EQU	$006C
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
PTPS7    	EQU    	$80
PTPS6    	EQU    	$40
PTPS5    	EQU    	$20
PTPS4    	EQU    	$10
PTPS3    	EQU    	$08
PTPS2    	EQU    	$04
PTPS1    	EQU    	$02
PTPS0    	EQU    	$01

;$006F reserved

ATDCTL0         EQU     $0070
WRAP3    	EQU    	$08
WRAP2    	EQU    	$04
WRAP1    	EQU    	$02
WRAP0    	EQU    	$01

ATDCTL1         EQU     $0071
ETRIGSEL  	EQU    	$80
SRES1     	EQU    	$40
SRES0     	EQU    	$20
DIS     	EQU  	$10
ETRIGCH3  	EQU    	$08
ETRIGCH2  	EQU    	$04
ETRIGCH1  	EQU    	$02
ETRIGCH0  	EQU    	$01

ATDCTL2         EQU     $0072
AFFC            EQU     $40
ETRIGLE         EQU     $10
ETRIGP          EQU     $08
ETRIGE          EQU     $04
ASCIE           EQU     $02
ASCIF           EQU     $01

ATDCTL3         EQU     $0073
DJM             EQU     $80
S8C             EQU     $40
S4C             EQU     $20
S2C             EQU     $10
S1C             EQU     $08
FIFO            EQU     $04
FRZ1            EQU     $02
FRZ0            EQU     $01

ATDCTL4         EQU     $0074
SMP2	        EQU     $80
SMP1            EQU     $40
SMP0            EQU     $20
PRS4            EQU     $10
PRS3            EQU     $08
PRS2            EQU     $04
PRS1            EQU     $02
PRS0            EQU     $01

ATDCTL5         EQU     $0075
SC              EQU     $40
SCAN            EQU     $20
MULT            EQU     $10
CD              EQU     $08
CC              EQU     $04
CB              EQU     $02
CA              EQU     $01

ATDSTAT0        EQU     $0076
SCF             EQU     $80
ETORF           EQU     $20
FIFOR           EQU     $10
CC3             EQU     $04
CC2             EQU     $04
CC1             EQU     $02
CC0             EQU     $01

;$0077 reserved

ATDCMPEH        EQU    	$0078
CMPE15   	EQU    	$80
CMPE14   	EQU    	$40
CMPE13   	EQU    	$20
CMPE12   	EQU    	$10
CMPE11   	EQU    	$08
CMPE10   	EQU    	$04
CMPE9    	EQU    	$02
CMPE8    	EQU    	$01

ATDCMPEL        EQU     $0079
CMPE7    	EQU     $80
CMPE6    	EQU     $40
CMPE5    	EQU     $20
CMPE4    	EQU     $10
CMPE3    	EQU     $08
CMPE2    	EQU     $04
CMPE1    	EQU     $02
CMPE0    	EQU     $01

ATDSTAT2H       EQU    	$007A
CCF15   	EQU    	$80
CCF14   	EQU    	$40
CCF13   	EQU    	$20
CCF12   	EQU    	$10
CCF11   	EQU    	$08
CCF10   	EQU    	$04
CCF9    	EQU    	$02
CCF8    	EQU    	$01

ATDSTAT2L       EQU    	$007B
CCF7    	EQU    	$80
CCF6    	EQU    	$40
CCF5    	EQU    	$20
CCF4    	EQU    	$10
CCF3    	EQU    	$08
CCF2    	EQU    	$04
CCF1    	EQU    	$02
CCF0    	EQU    	$01

ATDDIENH        EQU    	$007C
ATDDIEN	        EQU    	$007C
IEN15    	EQU    	$80
IEN14    	EQU    	$40
IEN13    	EQU    	$20
IEN12    	EQU    	$10
IEN11    	EQU    	$08
IEN10    	EQU    	$04
IEN9     	EQU    	$02
IEN8     	EQU    	$01

ATDDIENL        EQU    	$007D
IEN7     	EQU    	$80
IEN6     	EQU    	$40
IEN5     	EQU    	$20
IEN4     	EQU    	$10
IEN3     	EQU    	$08
IEN2     	EQU    	$04
IEN1     	EQU    	$02
IEN0     	EQU    	$01

ATDCMPHTH       EQU    	$007E
CMPHT15  	EQU    	$80
CMPHT14  	EQU    	$40
CMPHT13  	EQU    	$20
CMPHT12  	EQU    	$10
CMPHT11  	EQU    	$08
CMPHT10  	EQU    	$04
CMPHT9   	EQU    	$02
CMPHT8   	EQU    	$01
		       	
ATDCMPHTL       EQU    	$007F
CMPHT0  	EQU    	$01
CMPHT1  	EQU    	$02
CMPHT2  	EQU    	$04
CMPHT3  	EQU    	$08
CMPHT4  	EQU    	$10
CMPHT5  	EQU    	$20
CMPHT6  	EQU    	$40
CMPHT7  	EQU    	$80

ATDDR0          EQU    	$0080
ATDDR0H         EQU    	$0080
ATDDR0L         EQU    	$0081
	        
ATDDR1          EQU    	$0082
ATDDR1H         EQU    	$0082
ATDDR1L         EQU    	$0083
   	        	       	
ATDDR2          EQU    	$0084
ATDDR2H         EQU    	$0084
ATDDR2L         EQU    	$0085
   	        	       	
ATDDR3          EQU    	$0086
ATDDR3H         EQU    	$0086
ATDDR3L         EQU    	$0087
   	        	       	
ATDDR4          EQU    	$0088
ATDDR4H         EQU    	$0088
ATDDR4L         EQU    	$0089
   	        	       	
ATDDR5          EQU    	$008A
ATDDR5H         EQU    	$008A
ATDDR5L         EQU    	$008B
   	        	       	
ATDDR6          EQU    	$008C
ATDDR6H         EQU    	$008C
ATDDR6L         EQU    	$008D
   	        	       	
ATDDR7          EQU    	$008E
ATDDR7H         EQU    	$008E
ATDDR7L         EQU    	$008F
   	        	       	
ATDDR8          EQU    	$0090
ATDDR8H         EQU    	$0090
ATDDR8L         EQU    	$0091
   	        	       	
ATDDR9          EQU    	$0092
ATDDR9H         EQU    	$0092
ATDDR9L         EQU    	$0093
   	        	       	
ATDDR10         EQU    	$0093
ATDDR10H        EQU    	$0093
ATDDR10L        EQU    	$0095
   	        	       	
ATDDR11         EQU    	$0096
ATDDR11H        EQU    	$0096
ATDDR11L        EQU    	$0097
   	        	       	
ATDDR12         EQU    	$0098
ATDDR12H        EQU    	$0098
ATDDR12L        EQU    	$0099
   	        	       	
ATDDR13         EQU    	$009A
ATDDR13H        EQU    	$009A
ATDDR13L        EQU    	$009B
   	        	       	
ATDDR14         EQU    	$009C
ATDDR14H        EQU    	$009C
ATDDR14L        EQU    	$009D
   	        	       	
ATDDR15         EQU    	$009E
ATDDR15H        EQU    	$009E
ATDDR15L        EQU    	$009F

PWME            EQU     $00A0
PWME7           EQU     $80
PWME6           EQU     $40
PWME5           EQU     $20
PWME4           EQU     $10
PWME3           EQU     $08
PWME2           EQU     $04
PWME1           EQU     $02
PWME0           EQU     $01

PWMPOL          EQU     $00A1
PPOL7           EQU     $80
PPOL6           EQU     $40
PPOL5           EQU     $20
PPOL4           EQU     $10
PPOL3           EQU     $08
PPOL2           EQU     $04
PPOL1           EQU     $02
PPOL0           EQU     $01

PWMCLK          EQU     $00A2
PCLK7           EQU     $80
PCLK6           EQU     $40
PCLK5           EQU     $20
PCLK4           EQU     $10
PCLK3           EQU     $08
PCLK2           EQU     $04
PCLK1           EQU     $02
PCLK0           EQU     $01

PWMPRCLK        EQU     $00A3
PCKB2           EQU     $40
PCKB1           EQU     $20
PCKB0           EQU     $10
PCKA2           EQU     $04
PCKA1           EQU     $02
PCKA0           EQU     $01

PWMCAE          EQU     $00A4
CAE7            EQU     $80
CAE6            EQU     $40
CAE5            EQU     $20
CAE4            EQU     $10
CAE3            EQU     $08
CAE2            EQU     $04
CAE1            EQU     $02
CAE0            EQU     $01

PWMCTL          EQU     $00A5
CON67           EQU     $80
CON45           EQU     $40
CON23           EQU     $20
CON01           EQU     $10
PSWAI           EQU     $08
PFRZ            EQU     $04

PWMCLKAB        EQU     $00A6
PCLKAB7         EQU     $80
PCLKAB6         EQU     $40
PCLKAB5         EQU     $20
PCLKAB4         EQU     $10
PCLKAB3         EQU     $08
PCLKAB2         EQU     $04
PCLKAB1         EQU     $02
PCLKAB0         EQU     $01

;$00A7 reserved

PWMSCNTA        EQU     $00A8
PWMSCNTB        EQU     $00A9
	
;$00AA to $00AB reserved

PWMCNT0         EQU     $00AC
PWMCNT1         EQU     $00AD
PWMCNT2         EQU     $00AE
PWMCNT3         EQU     $00AF
PWMCNT4         EQU     $00B0
PWMCNT5         EQU     $00B1
PWMCNT6         EQU     $00B2
PWMCNT7         EQU     $00B3
	
PWMPER0         EQU     $00B4
PWMPER1         EQU     $00B5
PWMPER2         EQU     $00B6
PWMPER3         EQU     $00B7
PWMPER4         EQU     $00B8
PWMPER5         EQU     $00B9
PWMPER6         EQU     $00BA
PWMPER7         EQU     $00BB

PWMDTY0         EQU     $00BC
PWMDTY1         EQU     $00BD
PWMDTY2         EQU     $00BE
PWMDTY3         EQU     $00BF
PWMDTY4         EQU     $00C0
PWMDTY5         EQU     $00C1
PWMDTY6         EQU     $00C2
PWMDTY7         EQU     $00C3

;$00C4 to $00C7 reserved

SCIBDH          EQU     $00C8
SCI0BDH         EQU     $00C8
IREN    	EQU     $80
TNP1            EQU     $40
TNP0            EQU     $20
SBR12           EQU     $10
SBR11           EQU     $08
SBR10           EQU     $04
SBR9            EQU     $02
SBR8            EQU     $01

SCI0ASR1        EQU     $00C9
RXEDGIF   	EQU    	$80
BERRV     	EQU    	$04
BERRIF    	EQU    	$02
BKDIF     	EQU    	$01
	
SCIBDL          EQU     $00C9
SCI0BDL         EQU     $00C9
SBR7           	EQU     $80
SBR6           	EQU     $40
SBR5           	EQU     $20
SBR4           	EQU     $10
SBR3           	EQU     $08
SBR2           	EQU     $04
SBR1           	EQU     $02
SBR0           	EQU     $01

SCI0ACR1        EQU     $00C9
RXEDGIE   	EQU    	$80
BERRIE    	EQU    	$02
BKDIE     	EQU    	$01

SCICR1          EQU     $00CA
SCI0CR1         EQU     $00CA
LOOPS          	EQU     $80
SCISWAI        	EQU     $40
RSRC           	EQU     $20
M              	EQU     $10
WAKE           	EQU     $08
ILT            	EQU     $04
PE             	EQU     $02
PT             	EQU     $01

SCI0ACR2        EQU     $00CA
BERRM1    	EQU     $04
BERRM0    	EQU     $02
BKDFE     	EQU     $01

SCICR2          EQU     $00CB
SCI0CR2         EQU     $00CB
TXIE           	EQU     $80
TCIE           	EQU     $40
RIE            	EQU     $20
ILIE           	EQU     $10
TE             	EQU     $08
RE             	EQU     $04
RWU            	EQU     $02
SBK            	EQU     $01

SCISR1          EQU     $00CC
SCI0SR1         EQU     $00CC
TDRE           	EQU     $80
TC             	EQU     $40
RDRFF          	EQU     $20
IDLE           	EQU     $10
OR             	EQU     $08
NF             	EQU     $04
FE             	EQU     $02
PF             	EQU     $01

SCISR2          EQU     $00CD
SCI0SR2         EQU     $00CD
AMAP		EQU	$08
TXPOL		EQU	$10
RXPOL		EQU	$08	
BRK13          	EQU     $04
TXDIR          	EQU     $02
RAF            	EQU     $01

SCIDRH          EQU     $00CE
SCI0DRH         EQU     $00CE
R8             	EQU     $80
T8             	EQU     $40

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
	
;$00DE to $00E7 reserved

SCI2BDH         EQU     $00E8
;IREN    	EQU     $80
;TNP1           EQU     $40
;TNP0           EQU     $20
;SBR12          EQU     $10
;SBR11          EQU     $08
;SBR10          EQU     $04
;SBR9           EQU     $02
;SBR8           EQU     $01

SCI2ASR1        EQU     $00E8
;RXEDGIF   	EQU    	$80
;BERRV     	EQU    	$04
;BERRIF    	EQU    	$02
;BKDIF     	EQU    	$01
	
SCI2BDL         EQU     $00E9
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI2ACR1        EQU     $00E9
;RXEDGIE   	EQU    	$80
;BERRIE    	EQU    	$02
;BKDIE     	EQU    	$01

SCI2CR1         EQU     $00EA
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

SCI2ACR2        EQU     $00EA
;BERRM1    	EQU     $04
;BERRM0    	EQU     $02
;BKDFE     	EQU     $01

SCI2CR2         EQU     $00EB
;TXIE           EQU     $80
;TCIE           EQU     $40
;RIE            EQU     $20
;ILIE           EQU     $10
;TE             EQU     $08
;RE             EQU     $04
;RWU            EQU     $02
;SBK            EQU     $01

SCI2SR1         EQU     $00EC
;TDRE           EQU     $80
;TC             EQU     $40
;RDRFF          EQU     $20
;IDLE           EQU     $10
;OR             EQU     $08
;NF             EQU     $04
;FE             EQU     $02
;PF             EQU     $01

SCI2SR2         EQU     $00ED
;BRK13          EQU     $04
;TXDIR          EQU     $02
;RAF            EQU     $01

SCI2DRH         EQU     $00EE
;R8             EQU     $80
;T8             EQU     $40

SCI2DRL         EQU     $00EF

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
FDIVLCK         EQU     $40
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

;$0103 reserved

FCNFG           EQU    	$0104
CCIE         	EQU    	$80
IGNSF        	EQU    	$10
FDFD         	EQU    	$02
FSFD         	EQU    	$01

FERCNFG         EQU    	$0105
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

DPROT           EQU     $0109
EPROT           EQU     $0109
DPOPEN       	EQU    	$80
EPOPEN       	EQU    	$80
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

;$010C to $010F reserved

FOPT            EQU    	$0110
NV7           	EQU    	$80
NV6           	EQU    	$40
NV5           	EQU    	$20
NV4           	EQU    	$10
NV3           	EQU    	$08
NV2           	EQU    	$04
NV1           	EQU    	$02
NV0           	EQU    	$01

;$0111 to $011F reserved
	
IVBR            EQU    	$0120

;$0121 to $013F reserved
	
CANCTL0		EQU	$0140
RXFRM		EQU	$80
RXACT		EQU	$40
CSWAI		EQU	$20
SYNCH		EQU	$10
TIMEN		EQU	$08 ;RENAMED 
WUPE		EQU	$04
SLPRQ		EQU	$02
INITRQ		EQU	$01

CANCTL1		EQU	$0141
CANE		EQU	$80
CLKSRC		EQU	$40
LOOPB		EQU	$20
LISTEN		EQU	$10
WUPM		EQU	$04
SLPAK		EQU	$02
INITAK		EQU	$01

CANBTR0		EQU	$0142
SJW1		EQU	$80
SJW0		EQU	$40
BRP5		EQU	$20
BRP4		EQU	$10
BRP3		EQU	$08
BRP2		EQU	$04
BRP1		EQU	$02
BRP0		EQU	$01

CANBTR1		EQU	$0143
SAMP		EQU	$80
TSEG22		EQU	$40
TSEG21		EQU	$20
TSEG20		EQU	$10
TSEG13		EQU	$08
TSEG12		EQU	$04
TSEG11		EQU	$02
TESG10		EQU	$01

CANRFLG		EQU	$0144
WUPIF		EQU	$80
CSCIF		EQU	$40
RSTAT1		EQU	$20
RSTAT0		EQU	$10
TSTAT1		EQU	$08
TSTAT0		EQU	$04
OVRIF		EQU	$02
RXF		EQU	$01

CANRIER		EQU	$0145
WUPIE		EQU	$80
CSCIE		EQU	$40
RSTATE1		EQU	$20
RSTATE0		EQU	$10
TSTATE1		EQU	$08
TSTATE0		EQU	$04
OVRIE		EQU	$02
RXFIE		EQU	$01

CANTFLG		EQU	$0146
TXE2		EQU	$04
TXE1		EQU	$02
TXE0		EQU	$01

CANTIER		EQU	$0147
TXEIE2		EQU	$04
TXEIE1		EQU	$02
TXEIE0		EQU	$01

CANTARQ		EQU	$0148
ABTRQ2		EQU	$04
ABTRQ1		EQU	$02
ABTRQ0		EQU	$01

CANTAAK		EQU	$0149
ABTAK2		EQU	$04
ABTAK1		EQU	$02
ABTAK0		EQU	$01

CANTBSEL	EQU	$014A
TX2		EQU	$04
TX1		EQU	$02
TX0		EQU	$01

CANIDAC		EQU	$014B
IDAM1		EQU	$20
IDAM0		EQU	$10
IDHIT2		EQU	$04
IDHIT1		EQU	$02
IDHIT0		EQU	$01

; $14c and $14d reserved

CANRXERR	EQU	$014E
CANTXERR	EQU	$014F

CANIDAR0	EQU	$0150
CANIDAR1	EQU	$0151
CANIDAR2	EQU	$0152
CANIDAR3	EQU	$0153
CANIDMR0	EQU	$0154
CANIDMR1	EQU	$0155
CANIDMR2	EQU	$0156
CANIDMR3	EQU	$0157

CANIDAR4	EQU	$0158
CANIDAR5	EQU	$0159
CANIDAR6	EQU	$015A
CANIDAR7	EQU	$015B
CANIDMR4	EQU	$015C
CANIDMR5	EQU	$015D
CANIDMR6	EQU	$015E
CANIDMR7	EQU	$015F

CANRXIDR0	EQU	$0160
CANRXIDR1	EQU	$0161
CANRXIDR2	EQU	$0162
CANRXIDR3	EQU	$0163
CANRXDSR0	EQU	$0164
CANRXDSR1	EQU	$0165
CANRXDSR2	EQU	$0166
CANRXDSR3	EQU	$0167
CANRXDSR4	EQU	$0168
CANRXDSR5	EQU	$0169
CANRXDSR6	EQU	$016A
CANRXDSR7	EQU	$016B
CANRXDLR	EQU	$016C

;$016D reserved

CANRTSRH	EQU	$016E
CANRTSRL	EQU	$016F
CANTXIDR0	EQU	$0170
CANTXIDR1	EQU	$0171
CANTXIDR2	EQU	$0172
CANTXIDR3	EQU	$0173
CANTXDSR0	EQU	$0174
CANTXDSR1	EQU	$0175
CANTXDSR2	EQU	$0176
CANTXDSR3	EQU	$0177
CANTXDSR4	EQU	$0178
CANTXDSR5	EQU	$0179
CANTXDSR6	EQU	$017A
CANTXDSR7	EQU	$017B
CANTXDLR	EQU	$017C
CANTXTBPR	EQU	$017D
CANTXTSRH	EQU	$017E
CANTXTSRL	EQU	$017F

;$0180 to $023F reserved

PTT		EQU	$0240
PTT7		EQU	$80
PTT6		EQU	$40
PTT5		EQU	$20
PTT4		EQU	$10
PTT3		EQU	$08
PTT2		EQU	$04
PTT1		EQU	$02
PTT0		EQU	$01
PT7		EQU	$80
PT6		EQU	$40
PT5		EQU	$20
PT4		EQU	$10
PT3		EQU	$08
PT2		EQU	$04
PT1		EQU	$02
PT0		EQU	$01

PTIT		EQU	$0241
PTIT7		EQU	$80
PTIT6		EQU	$40
PTIT5		EQU	$20
PTIT4		EQU	$10
PTIT3		EQU	$08
PTIT2		EQU	$04
PTIT1		EQU	$02
PTIT0		EQU	$01

DDRT		EQU	$0242
DDRT7		EQU	$80
DDRT6		EQU	$40
DDRT5		EQU	$20
DDRT4		EQU	$10
DDRT3		EQU	$08
DDRT2		EQU	$04
DDRT1		EQU	$02
DDRT0		EQU	$01

;$0243 reserved

PERT		EQU	$0244
PERT7		EQU	$80
PERT6		EQU	$40
PERT5		EQU	$20
PERT4		EQU	$10
PERT3		EQU	$08
PERT2		EQU	$04
PERT1		EQU	$02
PERT0		EQU	$01

PPST		EQU	$0245
PPST7		EQU	$80
PPST6		EQU	$40
PPST5		EQU	$20
PPST4		EQU	$10
PPST3		EQU	$08
PPST2		EQU	$04
PPST1		EQU	$02
PPST0		EQU	$01

;$0246 to 247 reserved

PTS		EQU	$0248
PTS7		EQU	$80
PTS6		EQU	$40
PTS5		EQU	$20
PTS4		EQU	$10
PTS3		EQU	$08
PTS2		EQU	$04
PTS1		EQU	$02
PTS0		EQU	$01
PS7		EQU	$80
PS6		EQU	$40
PS5		EQU	$20
PS4		EQU	$10
PS3		EQU	$08
PS2		EQU	$04
PS1		EQU	$02
PS0		EQU	$01

PTIS		EQU	$0249
PTIS7		EQU	$80
PTIS6		EQU	$40
PTIS5		EQU	$20
PTIS4		EQU	$10
PTIS3		EQU	$08
PTIS2		EQU	$04
PTIS1		EQU	$02
PTIS0		EQU	$01

DDRS		EQU	$024A
DDRS7		EQU	$80
DDRS6		EQU	$40
DDRS5		EQU	$20
DDRS4		EQU	$10
DDRS3		EQU	$08
DDRS2		EQU	$04
DDRS1		EQU	$02
DDRS0		EQU	$01

;$024B reserved

PERS		EQU	$024C
PERS7		EQU	$80
PERS6		EQU	$40
PERS5		EQU	$20
PERS4		EQU	$10
PERS3		EQU	$08
PERS2		EQU	$04
PERS1		EQU	$02
PERS0		EQU	$01

PPSS		EQU	$024D
PPSS7		EQU	$80
PPSS6		EQU	$40
PPSS5		EQU	$20
PPSS4		EQU	$10
PPSS3		EQU	$08
PPSS2		EQU	$04
PPSS1		EQU	$02
PPSS0		EQU	$01

WOMS		EQU	$024E
WOMS7		EQU	$80
WOMS6		EQU	$40
WOMS5		EQU	$20
WOMS4		EQU	$10
WOMS3		EQU	$08
WOMS2		EQU	$04
WOMS1		EQU	$02
WOMS0		EQU	$01

PRR0		EQU	$024F
PRR0P3		EQU	$80
PRR0P2		EQU	$40
PRR0T31		EQU	$20
PRR0T30		EQU	$10
PRR0T21		EQU	$08
PRR0T20		EQU	$04
PRR0S1		EQU	$02
PRR0S0		EQU	$01

PTM		EQU	$0250
PTM3		EQU	$08
PTM2		EQU	$04
PTM1		EQU	$02
PTM0		EQU	$01
PM3		EQU	$08
PM2		EQU	$04
PM1		EQU	$02
PM0		EQU	$01

PTIM		EQU	$0251
PTIM3		EQU	$08
PTIM2		EQU	$04
PTIM1		EQU	$02
PTIM0		EQU	$01

DDRM		EQU	$0252
DDRM3		EQU	$08
DDRM2		EQU	$04
DDRM1		EQU	$02
DDRM0		EQU	$01

;$0253 reserved

PERM		EQU	$0254
PERM3		EQU	$08
PERM2		EQU	$04
PERM1		EQU	$02
PERM0		EQU	$01

PPSM		EQU	$0255
PPSM3		EQU	$08
PPSM2		EQU	$04
PPSM1		EQU	$02
PPSM0		EQU	$01

WOMM		EQU	$0256
WOMM3		EQU	$08
WOMM2		EQU	$04
WOMM1		EQU	$02
WOMM0		EQU	$01

PKGCR		EQU	$0257
APICLKS7	EQU	$80
PKGCR2		EQU	$04
PKGCR1		EQU	$02
PKGCR0		EQU	$01
	
PTP		EQU	$0258
PTP7		EQU	$80
PTP6		EQU	$40
PTP5		EQU	$20
PTP4		EQU	$10
PTP3		EQU	$08
PTP2		EQU	$04
PTP1		EQU	$02
PTP0		EQU	$01
PP7		EQU	$80
PP6		EQU	$40
PP5		EQU	$20
PP4		EQU	$10
PP3		EQU	$08
PP2		EQU	$04
PP1		EQU	$02
PP0		EQU	$01

PTIP		EQU	$0259
PTIP7		EQU	$80
PTIP6		EQU	$40
PTIP5		EQU	$20
PTIP4		EQU	$10
PTIP3		EQU	$08
PTIP2		EQU	$04
PTIP1		EQU	$02
PTIP0		EQU	$01

DDRP		EQU	$025A
DDRP7		EQU	$80
DDRP6		EQU	$40
DDRP5		EQU	$20
DDRP4		EQU	$10
DDRP3		EQU	$08
DDRP2		EQU	$04
DDRP1		EQU	$02
DDRP0		EQU	$01

;$025B reserved

PERP		EQU	$025C
PERP7		EQU	$80
PERP6		EQU	$40
PERP5		EQU	$20
PERP4		EQU	$10
PERP3		EQU	$08
PERP2		EQU	$04
PERP1		EQU	$02
PERP0		EQU	$01

PPSP		EQU	$025D
PPSP7		EQU	$80
PPSP6		EQU	$40
PPSP5		EQU	$20
PPSP4		EQU	$10
PPSP3		EQU	$08
PPSP2		EQU	$04
PPSP1		EQU	$02
PPSP0		EQU	$01

PIEP		EQU	$025E
PIEP7		EQU	$80
PIEP6		EQU	$40
PIEP5		EQU	$20
PIEP4		EQU	$10
PIEP3		EQU	$08
PIEP2		EQU	$04
PIEP1		EQU	$02
PIEP0		EQU	$01

PIFP		EQU	$025F
PIFP7		EQU	$80
PIFP6		EQU	$40
PIFP5		EQU	$20
PIFP4		EQU	$10
PIFP3		EQU	$08
PIFP2		EQU	$04
PIFP1		EQU	$02
PIFP0		EQU	$01

ACMPC		EQU	$260
ACIE		EQU	$80
ACOPE		EQU	$40
ACICE		EQU	$20
ACMOD1		EQU	$08
ACMOD0		EQU	$04
ACE		EQU	$01

ACMPS		EQU	$261
ACIF		EQU	$80
ACO		EQU	$40
	
;$0262 to $0267 reserved

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

;$026B reserved

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

PT0AD          	EQU     $0270
PT0AD7         	EQU     $80
PT0AD6         	EQU     $40
PT0AD5         	EQU     $20
PT0AD4         	EQU     $10
PT0AD3         	EQU     $08
PT0AD2         	EQU     $04
PT0AD1         	EQU     $02
PT0AD0         	EQU     $01
	       	
PT1AD          	EQU     $0271
PT1AD7         	EQU     $80
PT1AD6         	EQU     $40
PT1AD5         	EQU     $20
PT1AD4         	EQU     $10
PT1AD3         	EQU     $08
PT1AD2         	EQU     $04
PT1AD1         	EQU     $02
PT1AD0         	EQU     $01
	       	
PTI0AD         	EQU     $0272
PTI0AD7        	EQU     $80
PTI0AD6        	EQU     $40
PTI0AD5        	EQU     $20
PTI0AD4        	EQU     $10
PTI0AD3        	EQU     $08
PTI0AD2        	EQU     $04
PTI0AD1        	EQU     $02
PTI0AD0        	EQU     $01
	       	
PTI1AD         	EQU     $0273
PTI1AD7        	EQU     $80
PTI1AD6        	EQU     $40
PTI1AD5        	EQU     $20
PTI1AD4        	EQU     $10
PTI1AD3        	EQU     $08
PTI1AD2        	EQU     $04
PTI1AD1        	EQU     $02
PTI1AD0        	EQU     $01

DDR0AD         	EQU     $0274
DDR0AD7        	EQU     $80
DDR0AD6        	EQU     $40
DDR0AD5        	EQU     $20
DDR0AD4        	EQU     $10
DDR0AD3        	EQU     $08
DDR0AD2        	EQU     $04
DDR0AD1        	EQU     $02
DDR0AD0        	EQU     $01
	       	
DDR1AD         	EQU     $0275
DDR1AD7        	EQU     $80
DDR1AD6        	EQU     $40
DDR1AD5        	EQU     $20
DDR1AD4        	EQU     $10
DDR1AD3        	EQU     $08
DDR1AD2        	EQU     $04
DDR1AD1        	EQU     $02
DDR1AD0        	EQU     $01

RVACTL		EQU	$0276
RVAON		EQU	$01

PRR1		EQU	$0277
PRR1AN		EQU	$01

PER0AD         	EQU     $0278
PER0AD7        	EQU     $80
PER0AD6        	EQU     $40
PER0AD5        	EQU     $20
PER0AD4        	EQU     $10
PER0AD3        	EQU     $08
PER0AD2        	EQU     $04
PER0AD1        	EQU     $02
PER0AD0        	EQU     $01
	       	
PER1AD         	EQU     $0279
PER1AD7        	EQU     $80
PER1AD6        	EQU     $40
PER1AD5        	EQU     $20
PER1AD4        	EQU     $10
PER1AD3        	EQU     $08
PER1AD2        	EQU     $04
PER1AD1        	EQU     $02
PER1AD0        	EQU     $01

PPS0AD         	EQU     $027A
PPS0AD7        	EQU     $80
PPS0AD6        	EQU     $40
PPS0AD5        	EQU     $20
PPS0AD4        	EQU     $10
PPS0AD3        	EQU     $08
PPS0AD2        	EQU     $04
PPS0AD1        	EQU     $02
PPS0AD0        	EQU     $01
	       	
PPS1AD         	EQU     $027B
PPS1AD7        	EQU     $80
PPS1AD6        	EQU     $40
PPS1AD5        	EQU     $20
PPS1AD4        	EQU     $10
PPS1AD3        	EQU     $08
PPS1AD2        	EQU     $04
PPS1AD1        	EQU     $02
PPS1AD0        	EQU     $01

PIE0AD         	EQU     $027C
PIE0AD7        	EQU     $80
PIE0AD6        	EQU     $40
PIE0AD5        	EQU     $20
PIE0AD4        	EQU     $10
PIE0AD3        	EQU     $08
PIE0AD2        	EQU     $04
PIE0AD1        	EQU     $02
PIE0AD0        	EQU     $01
	       	
PIE1AD         	EQU     $027D
PIE1AD7        	EQU     $80
PIE1AD6        	EQU     $40
PIE1AD5        	EQU     $20
PIE1AD4        	EQU     $10
PIE1AD3        	EQU     $08
PIE1AD2        	EQU     $04
PIE1AD1        	EQU     $02
PIE1AD0        	EQU     $01

PIF0AD         	EQU     $027E
PIF0AD7        	EQU     $80
PIF0AD6        	EQU     $40
PIF0AD5        	EQU     $20
PIF0AD4        	EQU     $10
PIF0AD3        	EQU     $08
PIF0AD2        	EQU     $04
PIF0AD1        	EQU     $02
PIF0AD0        	EQU     $01
	       	
PIF1AD         	EQU     $027F
PIF1AD7        	EQU     $80
PIF1AD6        	EQU     $40
PIF1AD5        	EQU     $20
PIF1AD4        	EQU     $10
PIF1AD3        	EQU     $08
PIF1AD2        	EQU     $04
PIF1AD1        	EQU     $02
PIF1AD0        	EQU     $01

;$0280 to $02F0 reserved

CPMULVCTL  	EQU    	$02F1
LVDS      	EQU    	$04
LVIE      	EQU    	$02
LVIF      	EQU    	$01

CPMUAPICTL      EQU    	$02F2
APICLK   	EQU    	$80
APIES    	EQU    	$10
APIEA    	EQU    	$08
APIFE    	EQU    	$04
APIE     	EQU    	$02
APIF     	EQU    	$01

CPMUAPITR       EQU    	$02F3
APITR5   	EQU    	$80
APITR4   	EQU    	$40
APITR3   	EQU    	$20
APITR2   	EQU    	$10
APITR1   	EQU    	$08
APITR0   	EQU    	$04

CPMUAPIRH       EQU    	$02F4
APIR15   	EQU    	$80
APIR14   	EQU    	$40
APIR13   	EQU    	$20
APIR12   	EQU    	$10
APIR11   	EQU    	$08
APIR10   	EQU    	$04
APIR9    	EQU    	$02
APIR8    	EQU    	$01

CPMUAPIRL       EQU    	$02F5
APIR7         	EQU     $80
APIR6         	EQU     $40
APIR5         	EQU     $20
APIR4         	EQU     $10
APIR3         	EQU     $08
APIR2         	EQU     $04
APIR1         	EQU     $02
APIR0         	EQU     $01

;$02F6 to $02F7 reserved

CPMUIRCTRIMH    EQU    	$02F8
TCTRIM3        	EQU     $80
TCTRIM2        	EQU     $40
TCTRIM1        	EQU     $20
TCTRIM0        	EQU     $10
IRCTRIM9        EQU     $02
IRCTRIM8        EQU     $01

CPMUIRCTRIML    EQU    	$02F9
IRCTRIM7        EQU     $80
IRCTRIM6        EQU     $40
IRCTRIM5        EQU     $20
IRCTRIM4        EQU     $10
IRCTRIM3        EQU     $08
IRCTRIM2        EQU     $04
IRCTRIM1        EQU     $02
IRCTRIM0        EQU     $01

CPMUOSC		EQU    	$02FA
OSCE            EQU     $80
OSCPINS_EN      EQU     $20

CPMUPROT	EQU    	$02FB
PROT            EQU     $01

;$02FC to $03BF reserved

DAC0CTL		EQU    	$03C0
FVR		EQU	$80
DRIVE		EQU	$40
MODE2		EQU	$04
MODE1		EQU	$02
MODE0		EQU	$01
	
;$03C1 reserved

DAC0VOLTAGE    	EQU    	$03C2
VOLTAGE7        EQU     $80
VOLTAGE6        EQU     $40
VOLTAGE5        EQU     $20
VOLTAGE4        EQU     $10
VOLTAGE3        EQU     $08
VOLTAGE2        EQU     $04
VOLTAGE1        EQU     $02
VOLTAGE0        EQU     $01

;$03C3 to $03C7 reserved

DAC1CTL		EQU    	$03C8
;FVR		EQU	$80
;DRIVE		EQU	$40
;MODE2		EQU	$04
;MODE1		EQU	$02
;MODE0		EQU	$01
	
;$03C9 reserved

DAC1VOLTAGE    	EQU    	$03CA
;VOLTAGE7       EQU     $80
;VOLTAGE6       EQU     $40
;VOLTAGE5       EQU     $20
;VOLTAGE4       EQU     $10
;VOLTAGE3       EQU     $08
;VOLTAGE2       EQU     $04
;VOLTAGE1       EQU     $02
;VOLTAGE0       EQU     $01

; $03CBto $03FF reserved
#endif

