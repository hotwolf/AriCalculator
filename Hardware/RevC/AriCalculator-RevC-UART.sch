EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:w_microcontrollers
LIBS:AriCalculator
LIBS:w_analog
LIBS:w_connectors
LIBS:w_device
LIBS:AriCalculator-RevC-Main-cache
EELAYER 27 0
EELAYER END
$Descr User 8268 5827
encoding utf-8
Sheet 5 6
Title "UART"
Date "29 oct 2014"
Rev "RevC"
Comp "Dirk Heisswolf"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L FT232RL IC4
U 1 1 544AC281
P 4950 2600
F 0 "IC4" H 4950 3500 60  0000 C CNN
F 1 "FT232RL" H 5350 1600 60  0000 L CNN
F 2 "" H 4950 2600 60  0000 C CNN
F 3 "" H 4950 2600 60  0000 C CNN
	1    4950 2600
	1    0    0    -1  
$EndComp
$Comp
L USB-MINI-B CON3
U 1 1 544AC290
P 2050 2300
F 0 "CON3" H 2050 2750 60  0000 C CNN
F 1 "USB-MINI-B" H 2000 1800 60  0000 C CNN
F 2 "" H 2050 2300 60  0000 C CNN
F 3 "" H 2050 2300 60  0000 C CNN
	1    2050 2300
	-1   0    0    -1  
$EndComp
$Comp
L R R12
U 1 1 544AC3BF
P 6150 2450
F 0 "R12" V 6230 2450 40  0000 C CNN
F 1 "100" V 6157 2451 40  0000 C CNN
F 2 "~" V 6080 2450 30  0000 C CNN
F 3 "~" H 6150 2450 30  0000 C CNN
	1    6150 2450
	-1   0    0    1   
$EndComp
$Comp
L R R13
U 1 1 544AC3CE
P 6300 2450
F 0 "R13" V 6380 2450 40  0000 C CNN
F 1 "100" V 6307 2451 40  0000 C CNN
F 2 "~" V 6230 2450 30  0000 C CNN
F 3 "~" H 6300 2450 30  0000 C CNN
	1    6300 2450
	-1   0    0    1   
$EndComp
$Comp
L R R14
U 1 1 544AC3DD
P 6450 2450
F 0 "R14" V 6530 2450 40  0000 C CNN
F 1 "100" V 6457 2451 40  0000 C CNN
F 2 "~" V 6380 2450 30  0000 C CNN
F 3 "~" H 6450 2450 30  0000 C CNN
	1    6450 2450
	-1   0    0    1   
$EndComp
$Comp
L R R15
U 1 1 544AC3EC
P 6600 2450
F 0 "R15" V 6680 2450 40  0000 C CNN
F 1 "100" V 6607 2451 40  0000 C CNN
F 2 "~" V 6530 2450 30  0000 C CNN
F 3 "~" H 6600 2450 30  0000 C CNN
	1    6600 2450
	-1   0    0    1   
$EndComp
NoConn ~ 1500 2600
NoConn ~ 1500 2450
NoConn ~ 1500 2150
NoConn ~ 1500 2000
NoConn ~ 4000 2900
NoConn ~ 4000 2800
$Comp
L GND #PWR017
U 1 1 54502C29
P 4650 3900
F 0 "#PWR017" H 4650 3900 30  0001 C CNN
F 1 "GND" H 4650 3830 30  0001 C CNN
F 2 "" H 4650 3900 60  0000 C CNN
F 3 "" H 4650 3900 60  0000 C CNN
	1    4650 3900
	1    0    0    -1  
$EndComp
NoConn ~ 2600 2450
$Comp
L GND #PWR018
U 1 1 54502C47
P 2600 2700
F 0 "#PWR018" H 2600 2700 30  0001 C CNN
F 1 "GND" H 2600 2630 30  0001 C CNN
F 2 "" H 2600 2700 60  0000 C CNN
F 3 "" H 2600 2700 60  0000 C CNN
	1    2600 2700
	1    0    0    -1  
$EndComp
NoConn ~ 5850 2300
NoConn ~ 5850 2400
NoConn ~ 5850 2500
NoConn ~ 5850 2600
NoConn ~ 5850 2700
NoConn ~ 5850 2800
NoConn ~ 5850 3000
NoConn ~ 5850 3100
$Comp
L C C18
U 1 1 54502C6B
P 3850 3300
F 0 "C18" H 3850 3400 40  0000 L CNN
F 1 "100nF" H 3856 3215 40  0000 L CNN
F 2 "~" H 3888 3150 30  0000 C CNN
F 3 "~" H 3850 3300 60  0000 C CNN
	1    3850 3300
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR019
U 1 1 54502C84
P 3850 3550
F 0 "#PWR019" H 3850 3550 30  0001 C CNN
F 1 "GND" H 3850 3480 30  0001 C CNN
F 2 "" H 3850 3550 60  0000 C CNN
F 3 "" H 3850 3550 60  0000 C CNN
	1    3850 3550
	1    0    0    -1  
$EndComp
$Comp
L FILTER FB1
U 1 1 54503F06
P 3050 1950
F 0 "FB1" H 3050 2100 60  0000 C CNN
F 1 "MI0805K400R-10" H 3050 1850 60  0000 C CNN
F 2 "~" H 3050 1950 60  0000 C CNN
F 3 "~" H 3050 1950 60  0000 C CNN
	1    3050 1950
	1    0    0    -1  
$EndComp
$Comp
L R R10
U 1 1 54503F24
P 3650 2650
F 0 "R10" V 3730 2650 40  0000 C CNN
F 1 "4K7" V 3657 2651 40  0000 C CNN
F 2 "~" V 3580 2650 30  0000 C CNN
F 3 "~" H 3650 2650 30  0000 C CNN
	1    3650 2650
	-1   0    0    -1  
$EndComp
$Comp
L R R11
U 1 1 54503F33
P 3650 3250
F 0 "R11" V 3730 3250 40  0000 C CNN
F 1 "10K" V 3657 3251 40  0000 C CNN
F 2 "~" V 3580 3250 30  0000 C CNN
F 3 "~" H 3650 3250 30  0000 C CNN
	1    3650 3250
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR020
U 1 1 54503FB1
P 3650 3550
F 0 "#PWR020" H 3650 3550 30  0001 C CNN
F 1 "GND" H 3650 3480 30  0001 C CNN
F 2 "" H 3650 3550 60  0000 C CNN
F 3 "" H 3650 3550 60  0000 C CNN
	1    3650 3550
	1    0    0    -1  
$EndComp
$Comp
L R R16
U 1 1 54504202
P 4650 1500
F 0 "R16" V 4730 1500 40  0000 C CNN
F 1 "R" V 4657 1501 40  0000 C CNN
F 2 "~" V 4580 1500 30  0000 C CNN
F 3 "~" H 4650 1500 30  0000 C CNN
	1    4650 1500
	0    1    -1   0   
$EndComp
$Comp
L LED D1
U 1 1 54504211
P 5200 1500
F 0 "D1" H 5200 1600 50  0000 C CNN
F 1 "YELLOW" H 5150 1400 50  0000 C CNN
F 2 "~" H 5200 1500 60  0000 C CNN
F 3 "~" H 5200 1500 60  0000 C CNN
	1    5200 1500
	1    0    0    -1  
$EndComp
$Comp
L C C19
U 1 1 545042A7
P 2400 1350
F 0 "C19" H 2400 1450 40  0000 L CNN
F 1 "10nF" H 2350 1250 40  0000 R CNN
F 2 "~" H 2438 1200 30  0000 C CNN
F 3 "~" H 2400 1350 60  0000 C CNN
	1    2400 1350
	1    0    0    -1  
$EndComp
$Comp
L C C16
U 1 1 545042B6
P 3500 1350
F 0 "C16" H 3500 1450 40  0000 L CNN
F 1 "4.7uF" H 3506 1265 40  0000 L CNN
F 2 "~" H 3538 1200 30  0000 C CNN
F 3 "~" H 3500 1350 60  0000 C CNN
	1    3500 1350
	1    0    0    -1  
$EndComp
$Comp
L C C17
U 1 1 545042C5
P 3700 1350
F 0 "C17" H 3700 1450 40  0000 L CNN
F 1 "100nF" H 3706 1265 40  0000 L CNN
F 2 "~" H 3738 1200 30  0000 C CNN
F 3 "~" H 3700 1350 60  0000 C CNN
	1    3700 1350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR021
U 1 1 545043BA
P 2400 1600
F 0 "#PWR021" H 2400 1600 30  0001 C CNN
F 1 "GND" H 2400 1530 30  0001 C CNN
F 2 "" H 2400 1600 60  0000 C CNN
F 3 "" H 2400 1600 60  0000 C CNN
	1    2400 1600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR022
U 1 1 545043C9
P 3600 1600
F 0 "#PWR022" H 3600 1600 30  0001 C CNN
F 1 "GND" H 3600 1530 30  0001 C CNN
F 2 "" H 3600 1600 60  0000 C CNN
F 3 "" H 3600 1600 60  0000 C CNN
	1    3600 1600
	1    0    0    -1  
$EndComp
$Comp
L VUSB #PWR023
U 1 1 54504942
P 3400 1150
F 0 "#PWR023" H 3400 1100 20  0001 C CNN
F 1 "VUSB" H 3400 1250 30  0000 C CNN
F 2 "" H 3400 1150 60  0000 C CNN
F 3 "" H 3400 1150 60  0000 C CNN
	1    3400 1150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4650 3800 5250 3800
Connection ~ 4800 3800
Connection ~ 5100 3800
Connection ~ 4950 3800
Wire Wire Line
	4650 3800 4650 3900
Wire Wire Line
	2600 2600 2600 2700
Wire Wire Line
	3850 3100 4000 3100
Wire Wire Line
	3850 3500 3850 3550
Wire Wire Line
	4000 1850 3850 1850
Wire Wire Line
	3650 3500 3650 3550
Wire Wire Line
	3650 2900 3650 3000
Wire Wire Line
	3400 1950 4000 1950
Wire Wire Line
	3650 1950 3650 2400
Connection ~ 3650 2950
Wire Wire Line
	4000 2300 2600 2300
Wire Wire Line
	4000 2200 2600 2200
Wire Wire Line
	3850 1500 3850 3100
Wire Wire Line
	4000 2600 3900 2600
Wire Wire Line
	3900 2600 3900 2950
Wire Wire Line
	3900 2950 3650 2950
Wire Wire Line
	2600 2200 2600 2150
Wire Wire Line
	2700 1950 2600 1950
Wire Wire Line
	2600 1150 2600 2000
Connection ~ 3650 1950
Wire Wire Line
	5850 2200 6150 2200
Wire Wire Line
	5850 2100 6300 2100
Wire Wire Line
	6300 2100 6300 2200
Wire Wire Line
	5850 2000 6450 2000
Wire Wire Line
	6450 2000 6450 2200
Wire Wire Line
	5850 1900 6600 1900
Wire Wire Line
	6600 1900 6600 2200
Wire Wire Line
	5850 2900 6000 2900
Connection ~ 3850 1850
Wire Wire Line
	2600 1150 2400 1150
Connection ~ 2600 1950
Wire Wire Line
	3400 1950 3400 1150
Wire Wire Line
	3400 1150 3700 1150
Connection ~ 3500 1150
Wire Wire Line
	3500 1550 3700 1550
Wire Wire Line
	2400 1550 2400 1600
Wire Wire Line
	3600 1550 3600 1600
Connection ~ 3600 1550
Wire Wire Line
	6000 2900 6000 1500
Wire Wire Line
	6000 1500 5400 1500
Wire Wire Line
	5000 1500 4900 1500
Wire Wire Line
	4400 1500 3850 1500
Text HLabel 6150 2750 3    60   Input ~ 0
UART_CTS
Text HLabel 6300 2750 3    60   Output ~ 0
UART_RTS
Text HLabel 6600 2750 3    60   Output ~ 0
UART_RXD
Text HLabel 6450 2750 3    60   Input ~ 0
UART_TXD
Wire Wire Line
	6150 2700 6150 2750
Wire Wire Line
	6300 2700 6300 2750
Wire Wire Line
	6450 2700 6450 2750
Wire Wire Line
	6600 2700 6600 2750
$EndSCHEMATC
