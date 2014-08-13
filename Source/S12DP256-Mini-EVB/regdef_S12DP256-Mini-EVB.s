#ifndef	REGDEF
#define	REGDEF
;###############################################################################
;# S12CBase - REGDEF - Register Definitions (S12DP256-Mini-EVB)                #
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
;#    This module defines the register map of the S12C128.                     #
;###############################################################################
;# Required Modules:                                                           #
;#    - none                                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    November 15, 2011                                                        #
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

;$0004 to $0007 reserved


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

PEAR		EQU	$000A
NOACCE		EQU	$80
PIPOE		EQU	$20
NECLK		EQU	$10
LSTRE		EQU	$08
RDWE		EQU	$04

MODE		EQU	$000B
MODC		EQU	$80
MODB		EQU	$40
MODA		EQU	$20
IVIS		EQU	$08
EMK		EQU	$02
EME		EQU	$01

PUCR		EQU	$000C
PUPKE		EQU	$80
PUPEE		EQU	$10
PUPBE		EQU	$02
PUPAE		EQU	$01

RDRIV		EQU	$000D
RDPK		EQU	$80
RDPE		EQU	$10
RDPB		EQU	$02
RDPA		EQU	$01

EBICTL		EQU	$000E
ESTR		EQU	$01

;$000F reserved

INITRM		EQU	$0010
RAM15		EQU	$80
RAM14		EQU	$40
RAM13		EQU	$20
RAM12		EQU	$10
RAM11		EQU	$08
RAMHAL		EQU	$01

INITRG		EQU	$0011
REG14		EQU	$40
REG13		EQU	$20
REG12		EQU	$10
REG11		EQU	$08

INITEE		EQU	$0012
EE15		EQU	$80
EE14		EQU	$40
EE13		EQU	$20
EE12		EQU	$10
EEON		EQU	$01

MISC		EQU	$0013
EXSTR1		EQU	$08
EXSTR0		EQU	$04
ROMHM		EQU	$02
ROMON		EQU	$01

MTST0		EQU	$0014

ITCR		EQU	$0015
WRINT		EQU	$10
ADR3		EQU	$08
ADR2		EQU	$04
ADR1		EQU	$02
ADR0		EQU	$01

ITEST		EQU	$0016
INTE		EQU	$80
INTC		EQU	$40
INTA		EQU	$20
INT8		EQU	$10
INT6		EQU	$08
INT4		EQU	$04
INT2		EQU	$02
INT0		EQU	$01

MTST1		EQU	$0017

;$0018 to $0019 reserved

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

MEMSIZ0		EQU	$001C
REG_SW0		EQU	$80
EEP_SW1		EQU	$20
EEP_SW0		EQU	$10
RAM_SW2		EQU	$04
RAM_SW1		EQU	$02
RAM_SW0		EQU	$01

MEMSIZ1		EQU	$001D
ROM_SW1		EQU	$80
ROM_SW0		EQU	$40
PAG_SW1		EQU	$02
PAG_SW0		EQU	$01

INTCR		EQU	$001E
IRQE		EQU	$80
IRQEN		EQU	$40

HPRIO		EQU	$001F
PSEL7		EQU	$80
PSEL6		EQU	$40
PSEL5		EQU	$20
PSEL4		EQU	$10
PSEL3		EQU	$08
PSEL2		EQU	$04
PSEL1		EQU	$02
	
;$0020 to 0027 reserved

DBGC2		EQU	$0028
BKPCT0		EQU	$0028
BKABEN		EQU	$80
FULL		EQU	$40
BDM		EQU	$20
TAGAB		EQU	$10
BKCEN		EQU	$08
TAGC		EQU	$04
RWCEN		EQU	$02
RWC		EQU	$01

DBGC3		EQU	$0029
BKPCT1		EQU	$0029
BKAMBH		EQU	$80
BKAMBL		EQU	$40
BKBMBH		EQU	$20
BKBMBL		EQU	$10
RWAEN		EQU	$08
RWA		EQU	$04
RWBEN		EQU	$02
RWB		EQU	$01

DBGCAX		EQU	$002A
BKP0X		EQU	$002A

DBGCAH		EQU	$002B
DBGCAL		EQU	$002C
BKP0H		EQU	$002B
BKP0L		EQU	$002C

DBGCBX		EQU	$002D

DBGCBH		EQU	$002E
DBGCBL		EQU	$002F
BKP1H		EQU	$002E
BKP1L		EQU	$002F

PPAGE		EQU	$0030
PIX5		EQU	$20
PIX4		EQU	$10
PIX3		EQU	$08
PIX2		EQU	$04
PIX1		EQU	$02
PIX0		EQU	$01

;$0031 reserved

PORTK		EQU	$0032
PTK7		EQU	$80
PTK6		EQU	$40
PTK5		EQU	$20
PTK4		EQU	$10
PTK3		EQU	$08
PTK2		EQU	$04
PTK1		EQU	$02
PTK0		EQU	$01
PK7		EQU	$80
PK6		EQU	$40
PK5		EQU	$20
PK4		EQU	$10
PK3		EQU	$08
PK2		EQU	$04
PK1		EQU	$02
PK0		EQU	$01

DDRK		EQU	$0033
DDRK7		EQU	$80
DDRK6		EQU	$40
DDRK5		EQU	$20
DDRK4		EQU	$10
DDRK3		EQU	$08
DDRK2		EQU	$04
DDRK1		EQU	$02
DDRK0		EQU	$01

SYNR		EQU	$0034
SYN5		EQU	$20
SYN4		EQU	$10
SYN3		EQU	$08
SYN2		EQU	$04
SYN1		EQU	$02
SYN0		EQU	$01

REFDV		EQU	$0035
REFDV3		EQU	$08
REFDV2		EQU	$04
REFDV1		EQU	$02
REFDV0		EQU	$01

CTFLG		EQU	$0036
TOUT7		EQU	$80
TOUT6		EQU	$40
TOUT5		EQU	$20
TOUT4		EQU	$10
TOUT3		EQU	$08
TOUT2		EQU	$04
TOUT1		EQU	$02
TOUT0		EQU	$01

CRGFLG		EQU	$0037
RTIF		EQU	$80
PORF		EQU	$40
LVRF		EQU	$20
LOCKIF		EQU	$10
LOCK		EQU	$08
TRACK		EQU	$04
SCMIF		EQU	$02
SCM		EQU	$01

CRGINT		EQU	$0038
RTIE		EQU	$80
LOCKIE		EQU	$10
SCMIE		EQU	$02

CLKSEL		EQU	$0039
PLLSEL		EQU	$80
PSTP		EQU	$40
SYSWAI		EQU	$20
ROAWAI		EQU	$10
PLLWAI		EQU	$08
CWAI		EQU	$04
RTIWAI		EQU	$02
COPWAI		EQU	$01

PLLCTL		EQU	$003A
CME		EQU	$80
PLLON		EQU	$40
AUTO		EQU	$20
ACQ		EQU	$10
PRE		EQU	$04
PCE		EQU	$02
SCME		EQU	$01

RTICTL		EQU	$003B
RTR6		EQU	$40
RTR5		EQU	$20
RTR4		EQU	$10
RTR3		EQU	$08
RTR2		EQU	$04
RTR1		EQU	$02
RTR0		EQU	$01

COPCTL		EQU	$003C
WCOP		EQU	$80
RSBCK		EQU	$40
CR2		EQU	$04
CR1		EQU	$02
CR0		EQU	$01

FORBYP		EQU	$003D
RTIBYP		EQU	$80
COPBYP		EQU	$40
PLLBYP		EQU	$10
FCM		EQU	$02

CTCTL		EQU	$003E

ARMCOP		EQU	$003F

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

;$006C to $006F reserved

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

ATDCTL0		EQU	$0080
ATD0CTL0	EQU	$0080
ATDCTL1		EQU	$0081
ATD0CTL1	EQU	$0081

ATDCTL2		EQU	$0082
ATD0CTL2	EQU	$0082
ADPU		EQU	$80
AFFC		EQU	$40
AWAI		EQU	$20
ETRIGLE		EQU	$10
ETRIGP		EQU	$08
ETRIG		EQU	$04
ASCIE		EQU	$02
ASCIF		EQU	$01


ATDCTL3		EQU	$0083
ATD0CTL3	EQU	$0083
S8C		EQU	$40
S4C		EQU	$20
S2C		EQU	$10
S1C		EQU	$08
FIFO		EQU	$04
FRZ1		EQU	$02
FRZ0		EQU	$01

ATDCTL4		EQU	$0084
ATD0CTL4	EQU	$0084
SRES8		EQU	$80
SMP1		EQU	$40
SMP0		EQU	$20
PRS4		EQU	$10
PRS3		EQU	$08
PRS2		EQU	$04
PRS1		EQU	$02
PRS0		EQU	$01

ATDCTL5		EQU	$0085
ATD0CTL5	EQU	$0085
DJM		EQU	$80
DSGN		EQU	$40
SCAN		EQU	$20
MULT		EQU	$10
CC		EQU	$04
CB		EQU	$02
CA		EQU	$01

ATDSTAT0	EQU	$0086
ATD0STAT0	EQU	$0086
SCF		EQU	$80
ETORF		EQU	$20
FIFOR		EQU	$10
CC2		EQU	$04
CC1		EQU	$02
CC0		EQU	$01

;$0087 reserved

ATDTEST0	EQU	$0088
ATD0TEST0	EQU	$0088
SAR9		EQU	$80
SAR8		EQU	$40
SAR7		EQU	$20
SAR6		EQU	$10
SAR5		EQU	$08
SAR4		EQU	$04
SAR3		EQU	$02
SAR2		EQU	$01

ATDTEST1	EQU	$0089
ATD0TEST1	EQU	$0089
SAR1		EQU	$80
SAR0		EQU	$40
RST		EQU	$04
SC		EQU	$01

;$008a reserved

ATDSTAT1	EQU	$008B
ATD0STAT1	EQU	$008B
CCF7		EQU	$80
CCF6		EQU	$40
CCF5		EQU	$20
CCF4		EQU	$10
CCF3		EQU	$08
CCF2		EQU	$04
CCF1		EQU	$02
CCF0		EQU	$01

;$008c reserved

ATDDIEN		EQU	$008D
ATD0DIEN	EQU	$008D

;$008E reserved

PORTAD0		EQU	$008F
PTAD07		EQU	$80
PTAD06		EQU	$40
PTAD05		EQU	$20
PTAD04		EQU	$10
PTAD03		EQU	$08
PTAD02		EQU	$04
PTAD01		EQU	$02
PTAD00		EQU	$01

ATDDR0H		EQU	$0090
ATD0DR0H	EQU	$0090
ATDDR0L		EQU	$0091
ATD0DR0L	EQU	$0091
ATDDR1H		EQU	$0092
ATD0DR1H	EQU	$0092
ATDDR1L		EQU	$0093
ATD0DR1L	EQU	$0093
ATDDR2H		EQU	$0094
ATD0DR2H	EQU	$0094
ATDDR2L		EQU	$0095
ATD0DR2L	EQU	$0095
ATDDR3H		EQU	$0096
ATD0DR3H	EQU	$0096
ATDDR3L		EQU	$0097
ATD0DR3L	EQU	$0097
ATDDR4H		EQU	$0098
ATD0DR4H	EQU	$0098
ATDDR4L		EQU	$0099
ATD0DR4L	EQU	$0099
ATDDR5H		EQU	$009A
ATD0DR5H	EQU	$009A
ATDDR5L		EQU	$009B
ATD0DR5L	EQU	$009B
ATDDR6H		EQU	$009C
ATD0DR6H	EQU	$009C
ATDDR6L		EQU	$009D
ATD0DR6L	EQU	$009D
ATDDR7H		EQU	$009E
ATD0DR7H	EQU	$009E
ATDDR7L		EQU	$009F
ATD0DR7L	EQU	$009F

PWME		EQU	$00A0
PWME7		EQU	$80
PWME6		EQU	$40
PWME5		EQU	$20
PWME4		EQU	$10
PWME3		EQU	$08
PWME2		EQU	$04
PWME1		EQU	$02
PWME0		EQU	$01

PWMPOL		EQU	$00A1
PPOL7		EQU	$80
PPOL6		EQU	$40
PPOL5		EQU	$20
PPOL4		EQU	$10
PPOL3		EQU	$08
PPOL2		EQU	$04
PPOL1		EQU	$02
PPOL0		EQU	$01

PWMCLK		EQU	$00A2
PCLK7		EQU	$80
PCLK6		EQU	$40
PCLK5		EQU	$20
PCLK4		EQU	$10
PCLK3		EQU	$08
PCLK2		EQU	$04
PCLK1		EQU	$02
PCLK0		EQU	$01

PWMPRCLK	EQU	$00A3
PCKB2		EQU	$40
PCKB1		EQU	$20
PCKB0		EQU	$10
PCKA2		EQU	$04
PCKA1		EQU	$02
PCKA0		EQU	$01

PWMCAE		EQU	$00A4
CAE7		EQU	$80
CAE6		EQU	$40
CAE5		EQU	$20
CAE4		EQU	$10
CAE3		EQU	$08
CAE2		EQU	$04
CAE1		EQU	$02
CAE0		EQU	$01
  
PWMCTL		EQU	$00A5
CON67		EQU	$80
CON45		EQU	$40
CON23		EQU	$20
CON01		EQU	$10
PSWAI		EQU	$08
PFRZ		EQU	$04

PWMTST		EQU	$00A6
PWMPRSC		EQU	$00A7

PWMSCLA		EQU	$00A8
PWMSCLB		EQU	$00A9

PWMSCNTA	EQU	$00AA
PWMSCNTB	EQU	$00AB

PWMCNT0		EQU	$00AC
PWMCNT1		EQU	$00AD
PWMCNT2		EQU	$00AE
PWMCNT3		EQU	$00AF
PWMCNT4		EQU	$00B0
PWMCNT5		EQU	$00B1
PWMCNT6		EQU	$00B2
PWMCNT7		EQU	$00B3

PWMPER0		EQU	$00B4
PWMPER1		EQU	$00B5
PWMPER2		EQU	$00B6
PWMPER3		EQU	$00B7
PWMPER4		EQU	$00B8
PWMPER5		EQU	$00B9
PWMPER6		EQU	$00BA
PWMPER7		EQU	$00BB

PWMDTY0		EQU	$00BC
PWMDTY1		EQU	$00BD
PWMDTY2		EQU	$00BE
PWMDTY3		EQU	$00CF
PWMDTY4		EQU	$00C0
PWMDTY5		EQU	$00C1
PWMDTY6		EQU	$00C2
PWMDTY7		EQU	$00C3

;$00C3 to $00C7 reserved

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

SCI1BDL         EQU     $00D1
;SBR7           EQU     $80
;SBR6           EQU     $40
;SBR5           EQU     $20
;SBR4           EQU     $10
;SBR3           EQU     $08
;SBR2           EQU     $04
;SBR1           EQU     $02
;SBR0           EQU     $01

SCI1CR1         EQU     $00D2
;LOOPS          EQU     $80
;SCISWAI        EQU     $40
;RSRC           EQU     $20
;M              EQU     $10
;WAKE           EQU     $08
;ILT            EQU     $04
;PE             EQU     $02
;PT             EQU     $01

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
ADR7     	EQU    	$80
ADR6     	EQU    	$40
ADR5     	EQU    	$20
ADR4     	EQU    	$10
ADR3     	EQU    	$08
ADR2     	EQU    	$04
ADR1     	EQU    	$02

IBFD 		EQU	$00E1
I0BFD 		EQU	$00E1
IBC7     	EQU    	$80
IBC6     	EQU    	$40
IBC5     	EQU    	$20
IBC4     	EQU    	$10
IBC3     	EQU    	$08
IBC2     	EQU    	$04
IBC1     	EQU    	$02
IBC0     	EQU    	$01

IBCR            EQU	$00E2
I0BCR           EQU	$00E2
IBEN     	EQU    	$80
IBIE     	EQU    	$40
SL    		EQU    	$20
RX    		EQU    	$10
TXAK     	EQU    	$08
RSTA     	EQU    	$04
IBSWAI   	EQU    	$01

IBSR 		EQU	$00E3
I0BSR 		EQU	$00E3
TCF      	EQU    	$80
IAAS     	EQU    	$40
IBB      	EQU    	$20
RXAK     	EQU    	$01
SRW      	EQU    	$04
IBIF     	EQU    	$02

IBDR    	EQU	$00E4
I0BDR    	EQU	$00E4

IBCR2		EQU	$00E5
I0BCR2		EQU	$00E5
GCEN    	EQU    	$80
ADTYPE  	EQU    	$40
ADR2    	EQU    	$04
ADR1    	EQU    	$02
ADR0    	EQU    	$01

;$00E6 to $00E7 reserved

DLCBCR1    	EQU	$00E8
IMSG    	EQU    	$80
CLKS	  	EQU    	$40
IE	    	EQU    	$02
WCM	    	EQU    	$01

DLCBSVR    	EQU	$00E9
I3    		EQU    	$20
I2    		EQU    	$10
I1     		EQU    	$08
I0     		EQU    	$04

DLCBCR2    	EQU	$00EA
SMRST    	EQU    	$80
DLOOP	  	EQU    	$40
RX4XE	        EQU     $20
NBFS	        EQU     $10
TEOD            EQU     $08
TSIFR           EQU     $04
TMIFR1          EQU     $02
TMIFR0          EQU     $01

DLCBDR    	EQU	$00EB

DLCBARD    	EQU	$00EC
RXPOL	  	EQU    	$40
BO3             EQU     $08
BO2             EQU     $04
BO1             EQU     $02
BO0             EQU     $01

DLCBRSR    	EQU	$00ED
R5	  	EQU    	$20
R4	  	EQU    	$10
R3              EQU     $08
R2              EQU     $04
R1              EQU     $02
R0              EQU     $01

DLCSCR    	EQU	$00EE
BDLCE	  	EQU    	$10

DLCSTAT    	EQU	$00EF
BDLCIDLE	EQU    	$01

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
 
FCLKDIV		EQU	$0100
FDIVLD		EQU	$80
FDIV8		EQU	$40
FDIV5		EQU	$20
FDIV4		EQU	$10
FDIV3		EQU	$08
FDIV2		EQU	$04
FDIV1		EQU	$02
FDIV0		EQU	$01

FSEC		EQU	$0101
KEYEN		EQU	$80
NV6		EQU	$40
NV5		EQU	$20
NV4		EQU	$10
NV3		EQU	$08
NV2		EQU	$04
SEC01		EQU	$02
SEC00		EQU	$01
	
FTSTMOD		EQU	$0102
BIST		EQU	$80
HOLD		EQU	$40
INVOKE		EQU	$20
WRALL		EQU	$10
DIRECT		EQU	$01

FCNFG		EQU	$0103
CBEIE		EQU	$80
CCIE		EQU	$40
KEYACC		EQU	$20
BKSEL1		EQU	$02
BKSEL0		EQU	$01

FPROT		EQU	$0104
FPOPEN		EQU	$80
FPHDIS		EQU	$20
FPHS1		EQU	$10
FPHS0		EQU	$08
FPLDIS		EQU	$04
FPLS1		EQU	$02
FPLS0		EQU	$01

FSTAT		EQU	$0105
CBEIF		EQU	$80
CCIF		EQU	$40
PVIOL		EQU	$20
ACCERR		EQU	$10
BLANK		EQU	$04

FCMD		EQU	$0106
ERASE		EQU	$40
PROG		EQU	$20
ERVR		EQU	$04
MASS		EQU	$01

FCTL		EQU	$0107
TTMR		EQU	$80
IFREN		EQU	$20
NVSTR		EQU	$10
XE		EQU	$08
YE		EQU	$04
SE		EQU	$02
OE		EQU	$01

FADDRHI		EQU	$0108
FADDRLO		EQU	$0109
FDATAHI		EQU	$010A
FDATALO		EQU	$010B

;$010C to $010F reserved

ECLKDIV		EQU	$0110
EDIVLD		EQU	$80
EDIV8		EQU	$40
EDIV5		EQU	$20
EDIV4		EQU	$10
EDIV3		EQU	$08
EDIV2		EQU	$04
EDIV1		EQU	$02
EDIV0		EQU	$01

;$0111 to $0112 reserved

ECNFG		EQU	$0113
;CBEIE		EQU	$80
;CCIE		EQU	$40

EPROT		EQU	$0114
EPOPEN		EQU	$80
NV6		EQU	$40
NV5		EQU	$20
NV4		EQU	$10
EPLDIS		EQU	$08
EP2		EQU	$04
EP1		EQU	$02
EP0		EQU	$01

ESTAT		EQU	$0115
;CBEIF		EQU	$80
;CCIF		EQU	$40
;PVIOL		EQU	$20
;ACCERR		EQU	$10
;BLANK		EQU	$04

ECMD		EQU	$0116
;ERASE		EQU	$40
;PROG		EQU	$20
;ERVR		EQU	$04
;MASS		EQU	$01

EADDRHI		EQU	$0118
EADDRLO		EQU	$0119
EDATAHI		EQU	$011A
EDATALO		EQU	$011B

;$011C to $011F reserved

ATD1CTL0	EQU	$0120
ATD1CTL1	EQU	$0121

ATD1CTL2	EQU	$0122
;ADPU		EQU	$80
;AFFC		EQU	$40
;AWAI		EQU	$20
;ETRIGLE	EQU	$10
;ETRIGP		EQU	$08
;ETRIG		EQU	$04
;ASCIE		EQU	$02
;ASCIF		EQU	$01

ATD1CTL3	EQU	$0123
;S8C		EQU	$40
;S4C		EQU	$20
;S2C		EQU	$10
;S1C		EQU	$08
;FIFO		EQU	$04
;FRZ1		EQU	$02
;FRZ0		EQU	$01

ATD1CTL4	EQU	$0124
;SRES8		EQU	$80
;SMP1		EQU	$40
;SMP0		EQU	$20
;PRS4		EQU	$10
;PRS3		EQU	$08
;PRS2		EQU	$04
;PRS1		EQU	$02
;PRS0		EQU	$01

ATD1CTL5	EQU	$0125
;DJM		EQU	$80
;DSGN		EQU	$40
;SCAN		EQU	$20
;MULT		EQU	$10
;CC		EQU	$04
;CB		EQU	$02
;CA		EQU	$01

ATD1STAT0	EQU	$0126
;SCF		EQU	$80
;ETORF		EQU	$20
;FIFOR		EQU	$10
;CC2		EQU	$04
;CC1		EQU	$02
;CC0		EQU	$01

;$0126 reserved

ATD1TEST0	EQU	$0128
;SAR9		EQU	$80
;SAR8		EQU	$40
;SAR7		EQU	$20
;SAR6		EQU	$10
;SAR5		EQU	$08
;SAR4		EQU	$04
;SAR3		EQU	$02
;SAR2		EQU	$01

ATD1TEST1	EQU	$0129
;SAR1		EQU	$80
;SAR0		EQU	$40
;RST		EQU	$04
;SC		EQU	$01

;$012a reserved

ATD1STAT1	EQU	$012B
;CCF7		EQU	$80
;CCF6		EQU	$40
;CCF5		EQU	$20
;CCF4		EQU	$10
;CCF3		EQU	$08
;CCF2		EQU	$04
;CCF1		EQU	$02
;CCF0		EQU	$01

;$012C reserved

ATD1DIEN	EQU	$012D

;$012E reserved

PORTAD1		EQU	$012F
PTAD17		EQU	$80
PTAD16		EQU	$40
PTAD15		EQU	$20
PTAD14		EQU	$10
PTAD13		EQU	$08
PTAD12		EQU	$04
PTAD11		EQU	$02
PTAD10		EQU	$01

ATD1DR0H	EQU	$0130
ATD1DR0L	EQU	$0131
ATD1DR1H	EQU	$0132
ATD1DR1L	EQU	$0133
ATD1DR2H	EQU	$0134
ATD1DR2L	EQU	$0135
ATD1DR3H	EQU	$0136
ATD1DR3L	EQU	$0137
ATD1DR4H	EQU	$0138
ATD1DR4L	EQU	$0139
ATD1DR5H	EQU	$013A
ATD1DR5L	EQU	$013B
ATD1DR6H	EQU	$013C
ATD1DR6L	EQU	$013D
ATD1DR7H	EQU	$013E
ATD1DR7L	EQU	$013F

CANCTL0		EQU	$0140
CAN0CTL0		EQU	$0140
RXFRM		EQU	$80
RXACT		EQU	$40
CSWAI		EQU	$20
SYNCH		EQU	$10
TIMEN		EQU	$08 ;RENAMED 
WUPE		EQU	$04
SLPRQ		EQU	$02
INITRQ		EQU	$01

CANCTL1		EQU	$0141
CAN0CTL1	EQU	$0141
CANE		EQU	$80
CLKSRC		EQU	$40
LOOPB		EQU	$20
LISTEN		EQU	$10
WUPM		EQU	$04
SLPAK		EQU	$02
INITAK		EQU	$01

CANBTR0		EQU	$0142
CAN0BTR0	EQU	$0142
SJW1		EQU	$80
SJW0		EQU	$40
BRP5		EQU	$20
BRP4		EQU	$10
BRP3		EQU	$08
BRP2		EQU	$04
BRP1		EQU	$02
BRP0		EQU	$01

CANBTR1		EQU	$0143
CAN0BTR1	EQU	$0143
SAMP		EQU	$80
TSEG22		EQU	$40
TSEG21		EQU	$20
TSEG20		EQU	$10
TSEG13		EQU	$08
TSEG12		EQU	$04
TSEG11		EQU	$02
TESG10		EQU	$01

CANRFLG		EQU	$0144
CAN0RFLG	EQU	$0144
WUPIF		EQU	$80
CSCIF		EQU	$40
RSTAT1		EQU	$20
RSTAT0		EQU	$10
TSTAT1		EQU	$08
TSTAT0		EQU	$04
OVRIF		EQU	$02
RXF		EQU	$01

CANRIER		EQU	$0145
CAN0RIER	EQU	$0145
WUPIE		EQU	$80
CSCIE		EQU	$40
RSTATE1		EQU	$20
RSTATE0		EQU	$10
TSTATE1		EQU	$08
TSTATE0		EQU	$04
OVRIE		EQU	$02
RXFIE		EQU	$01

CANTFLG		EQU	$0146
CAN0TFLG	EQU	$0146
TXE2		EQU	$04
TXE1		EQU	$02
TXE0		EQU	$01

CANTIER		EQU	$0147
CAN0TIER	EQU	$0147
TXEIE2		EQU	$04
TXEIE1		EQU	$02
TXEIE0		EQU	$01

CANTARQ		EQU	$0148
CAN0TARQ	EQU	$0148
ABTRQ2		EQU	$04
ABTRQ1		EQU	$02
ABTRQ0		EQU	$01

CANTAAK		EQU	$0149
CAN0TAAK	EQU	$0149
ABTAK2		EQU	$04
ABTAK1		EQU	$02
ABTAK0		EQU	$01

CANTBSEL	EQU	$014A
CAN0TBSEL	EQU	$014A
TX2		EQU	$04
TX1		EQU	$02
TX0		EQU	$01

CANIDAC		EQU	$014B
CAN0IDAC	EQU	$014B
IDAM1		EQU	$20
IDAM0		EQU	$10
IDHIT2		EQU	$04
IDHIT1		EQU	$02
IDHIT0		EQU	$01

; $14c and $14d reserved

CANRXERR	EQU	$014E
CAN0RXERR	EQU	$014E
CANTXERR	EQU	$014F
CAN0TXERR	EQU	$014F

CANIDAR0	EQU	$0150
CAN0IDAR0	EQU	$0150
CANIDAR1	EQU	$0151
CAN0IDAR1	EQU	$0151
CANIDAR2	EQU	$0152
CAN0IDAR2	EQU	$0152
CANIDAR3	EQU	$0153
CAN0IDAR3	EQU	$0153
CANIDMR0	EQU	$0154
CAN0IDMR0	EQU	$0154
CANIDMR1	EQU	$0155
CAN0IDMR1	EQU	$0155
CANIDMR2	EQU	$0156
CAN0IDMR2	EQU	$0156
CANIDMR3	EQU	$0157
CAN0IDMR3	EQU	$0157

CANIDAR4	EQU	$0158
CAN0IDAR4	EQU	$0158
CANIDAR5	EQU	$0159
CAN0IDAR5	EQU	$0159
CANIDAR6	EQU	$015A
CAN0IDAR6	EQU	$015A
CANIDAR7	EQU	$015B
CAN0IDAR7	EQU	$015B
CANIDMR4	EQU	$015C
CAN0IDMR4	EQU	$015C
CANIDMR5	EQU	$015D
CAN0IDMR5	EQU	$015D
CANIDMR6	EQU	$015E
CAN0IDMR6	EQU	$015E
CANIDMR7	EQU	$015F
CAN0IDMR7	EQU	$015F

CANRXIDR0	EQU	$0160
CAN0RXIDR0	EQU	$0160
CANRXIDR1	EQU	$0161
CAN0RXIDR1	EQU	$0161
CANRXIDR2	EQU	$0162
CAN0RXIDR2	EQU	$0162
CANRXIDR3	EQU	$0163
CAN0RXIDR3	EQU	$0163
CANRXDSR0	EQU	$0164
CAN0RXDSR0	EQU	$0164
CANRXDSR1	EQU	$0165
CAN0RXDSR1	EQU	$0165
CANRXDSR2	EQU	$0166
CAN0RXDSR2	EQU	$0166
CANRXDSR3	EQU	$0167
CAN0RXDSR3	EQU	$0167
CANRXDSR4	EQU	$0168
CAN0RXDSR4	EQU	$0168
CANRXDSR5	EQU	$0169
CAN0RXDSR5	EQU	$0169
CANRXDSR6	EQU	$016A
CAN0RXDSR6	EQU	$016A
CANRXDSR7	EQU	$016B
CAN0RXDSR7	EQU	$016B
CANRXDLR	EQU	$016C
CAN0RXDLR	EQU	$016C

;$016D reserved

CANRTSRH	EQU	$016E
CAN0RTSRH	EQU	$016E
CANRTSRL	EQU	$016F
CAN0RTSRL	EQU	$016F
CANTXIDR0	EQU	$0170
CAN0TXIDR0	EQU	$0170
CANTXIDR1	EQU	$0171
CAN0TXIDR1	EQU	$0171
CANTXIDR2	EQU	$0172
CAN0TXIDR2	EQU	$0172
CANTXIDR3	EQU	$0173
CAN0TXIDR3	EQU	$0173
CANTXDSR0	EQU	$0174
CAN0TXDSR0	EQU	$0174
CANTXDSR1	EQU	$0175
CAN0TXDSR1	EQU	$0175
CANTXDSR2	EQU	$0176
CAN0TXDSR2	EQU	$0176
CANTXDSR3	EQU	$0177
CAN0TXDSR3	EQU	$0177
CANTXDSR4	EQU	$0178
CAN0TXDSR4	EQU	$0178
CANTXDSR5	EQU	$0179
CAN0TXDSR5	EQU	$0179
CANTXDSR6	EQU	$017A
CAN0TXDSR6	EQU	$017A
CANTXDSR7	EQU	$017B
CAN0TXDSR7	EQU	$017B
CANTXDLR	EQU	$017C
CAN0TXDLR	EQU	$017C
CANTXTBPR	EQU	$017D
CAN0TXTBPR	EQU	$017D
CANTXTSRH	EQU	$017E
CAN0TXTSRH	EQU	$017E
CANTXTSRL	EQU	$017F
CAN0TXTSRL	EQU	$017F

CAN1CTL0	EQU	$0180
;RXFRM		EQU	$80
;RXACT		EQU	$40
;CSWAI		EQU	$20
;SYNCH		EQU	$10
;TIMEN		EQU	$08 ;RENAMED 
;WUPE		EQU	$04
;SLPRQ		EQU	$02
;INITRQ		EQU	$01

CAN1CTL1	EQU	$0181
;CANE		EQU	$80
;CLKSRC		EQU	$40
;LOOPB		EQU	$20
;LISTEN		EQU	$10
;WUPM		EQU	$04
;SLPAK		EQU	$02
;INITAK		EQU	$01

CAN1BTR0	EQU	$0182
;SJW1		EQU	$80
;SJW0		EQU	$40
;BRP5		EQU	$20
;BRP4		EQU	$10
;BRP3		EQU	$08
;BRP2		EQU	$04
;BRP1		EQU	$02
;BRP0		EQU	$01

CAN1BTR1	EQU	$0183
;SAMP		EQU	$80
;TSEG22		EQU	$40
;TSEG21		EQU	$20
;TSEG20		EQU	$10
;TSEG13		EQU	$08
;TSEG12		EQU	$04
;TSEG11		EQU	$02
;TESG10		EQU	$01

CAN1RFLG	EQU	$0184
;WUPIF		EQU	$80
;CSCIF		EQU	$40
;RSTAT1		EQU	$20
;RSTAT0		EQU	$10
;TSTAT1		EQU	$08
;TSTAT0		EQU	$04
;OVRIF		EQU	$02
;RXF		EQU	$01

CAN1RIER	EQU	$0185
;WUPIE		EQU	$80
;CSCIE		EQU	$40
;RSTATE1	EQU	$20
;RSTATE0	EQU	$10
;TSTATE1	EQU	$08
;TSTATE0	EQU	$04
;OVRIE		EQU	$02
;RXFIE		EQU	$01

CAN1TFLG	EQU	$0186
;TXE2		EQU	$04
;TXE1		EQU	$02
;TXE0		EQU	$01

CAN1TIER	EQU	$0187
;TXEIE2		EQU	$04
;TXEIE1		EQU	$02
;TXEIE0		EQU	$01

CAN1TARQ	EQU	$0188
;ABTRQ2		EQU	$04
;ABTRQ1		EQU	$02
;ABTRQ0		EQU	$01

CAN1TAAK	EQU	$0189
;ABTAK2		EQU	$04
;ABTAK1		EQU	$02
;ABTAK0		EQU	$01

CAN1TBSEL	EQU	$018A
;TX2		EQU	$04
;TX1		EQU	$02
;TX0		EQU	$01

CAN1IDAC	EQU	$018B
;IDAM1		EQU	$20
;IDAM0		EQU	$10
;IDHIT2		EQU	$04
;IDHIT1		EQU	$02
;IDHIT0		EQU	$01

; $18c and $18d reserved

CAN1RXERR	EQU	$018E
CAN1TXERR	EQU	$018F

CAN1IDAR0	EQU	$0190
CAN1IDAR1	EQU	$0191
CAN1IDAR2	EQU	$0192
CAN1IDAR3	EQU	$0193
CAN1IDMR0	EQU	$0194
CAN1IDMR1	EQU	$0195
CAN1IDMR2	EQU	$0196
CAN1IDMR3	EQU	$0197

CAN1IDAR4	EQU	$0198
CAN1IDAR5	EQU	$0199
CAN1IDAR6	EQU	$019A
CAN1IDAR7	EQU	$019B
CAN1IDMR4	EQU	$019C
CAN1IDMR5	EQU	$019D
CAN1IDMR6	EQU	$019E
CAN1IDMR7	EQU	$019F

CAN1RXIDR0	EQU	$01A0
CAN1RXIDR1	EQU	$01A1
CAN1RXIDR2	EQU	$01A2
CAN1RXIDR3	EQU	$01A3
CAN1RXDSR0	EQU	$01A4
CAN1RXDSR1	EQU	$01A5
CAN1RXDSR2	EQU	$01A6
CAN1RXDSR3	EQU	$01A7
CAN1RXDSR4	EQU	$01A8
CAN1RXDSR5	EQU	$01A9
CAN1RXDSR6	EQU	$01AA
CAN1RXDSR7	EQU	$01AB
CAN1RXDLR	EQU	$01AC

;$01AD reserved

CAN1RTSRH	EQU	$01AE
CAN1RTSRL	EQU	$01AF
CAN1TXIDR0	EQU	$01B0
CAN1TXIDR1	EQU	$01B1
CAN1TXIDR2	EQU	$01B2
CAN1TXIDR3	EQU	$01B3
CAN1TXDSR0	EQU	$01B4
CAN1TXDSR1	EQU	$01B5
CAN1TXDSR2	EQU	$01B6
CAN1TXDSR3	EQU	$01B7
CAN1TXDSR4	EQU	$01B8
CAN1TXDSR5	EQU	$01B9
CAN1TXDSR6	EQU	$01BA
CAN1TXDSR7	EQU	$01BB
CAN1TXDLR	EQU	$01BC
CAN1TXTBPR	EQU	$01BD
CAN1TXTSRH	EQU	$01BE
CAN1TXTSRL	EQU	$01BF
	
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
PTJ1            EQU     $02
PTJ0            EQU     $01
PJ7             EQU     $80
PJ6             EQU     $40
PJ1             EQU     $02
PJ0             EQU     $01

PTIJ            EQU     $0269
PTIJ7           EQU     $80
PTIJ6           EQU     $40
PTIJ1           EQU     $02
PTIJ0           EQU     $01

DDRJ            EQU     $026A
DDRJ7           EQU     $80
DDRJ6           EQU     $40
DDRJ1           EQU     $02
DDRJ0           EQU     $01

RDRJ            EQU     $026B
RDRJ7           EQU     $80
RDRJ6           EQU     $40
RDRJ1           EQU     $02
RDRJ0           EQU     $01

PERJ            EQU     $026C
PERJ7           EQU     $80
PERJ6           EQU     $40
PERJ1           EQU     $02
PERJ0           EQU     $01

PPSJ            EQU     $026D
PPSJ7           EQU     $80
PPSJ6           EQU     $40
PPSJ1           EQU     $02
PPSJ0           EQU     $01

PIEJ            EQU     $026E
PIEJ7           EQU     $80
PIEJ6           EQU     $40
PIEJ1           EQU     $02
PIEJ0           EQU     $01

PIFJ            EQU     $026F
PIFJ7           EQU     $80
PIFJ6           EQU     $40
PIFJ1           EQU     $02
PIFJ0           EQU     $01

;$0270 to $027F reserved

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

;$02C0 to $03FF reserved

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
