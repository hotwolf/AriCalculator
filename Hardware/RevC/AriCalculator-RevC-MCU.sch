EESchema Schematic File Version 2
LIBS:AriCalculator
LIBS:AriCalculator-RevC-cache
EELAYER 27 0
EELAYER END
$Descr User 8268 5827
encoding utf-8
Sheet 6 6
Title "MCU"
Date "11 nov 2014"
Rev "RevC"
Comp "Dirk Heisswolf"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MC9S12G IC1
U 1 1 544AC272
P 3900 2450
F 0 "IC1" H 3900 2550 60  0000 C CNN
F 1 "MC9S12G" H 3900 2350 60  0000 C CNN
F 2 "~" H 4450 2350 60  0000 C CNN
F 3 "~" H 4450 2350 60  0000 C CNN
	1    3900 2450
	1    0    0    -1  
$EndComp
$Comp
L BDM CON1
U 1 1 544FF341
P 1900 3950
F 0 "CON1" H 1900 3600 60  0000 C CNN
F 1 "BDM" H 1900 4350 60  0000 C CNN
F 2 "~" H 2450 3250 60  0000 C CNN
F 3 "~" H 2450 3250 60  0000 C CNN
	1    1900 3950
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR025
U 1 1 544FF350
P 4900 1400
F 0 "#PWR025" H 4900 1400 30  0001 C CNN
F 1 "GND" H 4900 1330 30  0001 C CNN
F 2 "" H 4900 1400 60  0000 C CNN
F 3 "" H 4900 1400 60  0000 C CNN
	1    4900 1400
	1    0    0    -1  
$EndComp
$Comp
L 3V3 #PWR33
U 1 1 544FF35F
P 4450 1300
F 0 "#PWR33" H 4450 1400 40  0001 C CNN
F 1 "3V3" H 4450 1449 40  0000 C CNN
F 2 "" H 4450 1300 60  0000 C CNN
F 3 "" H 4450 1300 60  0000 C CNN
	1    4450 1300
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 544FF36E
P 4700 1350
F 0 "C1" H 4700 1450 40  0000 L CNN
F 1 "100nf" H 4706 1265 40  0000 L CNN
F 2 "~" H 4738 1200 30  0000 C CNN
F 3 "~" H 4700 1350 60  0000 C CNN
	1    4700 1350
	0    -1   -1   0   
$EndComp
$Comp
L C C2
U 1 1 544FF3C3
P 2500 2000
F 0 "C2" H 2500 2100 40  0000 L CNN
F 1 "100nF" H 2506 1915 40  0000 L CNN
F 2 "~" H 2538 1850 30  0000 C CNN
F 3 "~" H 2500 2000 60  0000 C CNN
	1    2500 2000
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR026
U 1 1 544FF410
P 2300 2600
F 0 "#PWR026" H 2300 2600 30  0001 C CNN
F 1 "GND" H 2300 2530 30  0001 C CNN
F 2 "" H 2300 2600 60  0000 C CNN
F 3 "" H 2300 2600 60  0000 C CNN
	1    2300 2600
	1    0    0    -1  
$EndComp
$Comp
L 3V3 #PWR29
U 1 1 544FF596
P 1300 3700
F 0 "#PWR29" H 1300 3800 40  0001 C CNN
F 1 "3V3" H 1300 3849 40  0000 C CNN
F 2 "" H 1300 3700 60  0000 C CNN
F 3 "" H 1300 3700 60  0000 C CNN
	1    1300 3700
	1    0    0    -1  
$EndComp
$Comp
L SPI CON2
U 1 1 544FF664
P 1900 2950
F 0 "CON2" H 1900 3300 60  0000 C CNN
F 1 "SPI" H 1900 2550 60  0000 C CNN
F 2 "~" H 2450 2250 60  0000 C CNN
F 3 "~" H 2450 2250 60  0000 C CNN
	1    1900 2950
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR027
U 1 1 544FF75E
P 1300 3200
F 0 "#PWR027" H 1300 3200 30  0001 C CNN
F 1 "GND" H 1300 3130 30  0001 C CNN
F 2 "" H 1300 3200 60  0000 C CNN
F 3 "" H 1300 3200 60  0000 C CNN
	1    1300 3200
	1    0    0    -1  
$EndComp
$Comp
L 3V3 #PWR27
U 1 1 544FF76D
P 1300 2700
F 0 "#PWR27" H 1300 2800 40  0001 C CNN
F 1 "3V3" H 1300 2849 40  0000 C CNN
F 2 "" H 1300 2700 60  0000 C CNN
F 3 "" H 1300 2700 60  0000 C CNN
	1    1300 2700
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 544FF846
P 2000 2200
F 0 "R1" V 2080 2200 40  0000 C CNN
F 1 "120" V 2007 2201 40  0000 C CNN
F 2 "~" V 1930 2200 30  0000 C CNN
F 3 "~" H 2000 2200 30  0000 C CNN
	1    2000 2200
	0    -1   -1   0   
$EndComp
$Comp
L R R2
U 1 1 544FF855
P 2000 2400
F 0 "R2" V 2080 2400 40  0000 C CNN
F 1 "120" V 2007 2401 40  0000 C CNN
F 2 "~" V 1930 2400 30  0000 C CNN
F 3 "~" H 2000 2400 30  0000 C CNN
	1    2000 2400
	0    -1   -1   0   
$EndComp
$Comp
L LED LED1
U 1 1 544FF88C
P 1500 2200
F 0 "LED1" H 1500 2300 50  0000 C CNN
F 1 "GREEN" H 1300 2150 50  0000 C CNN
F 2 "~" H 1500 2200 60  0000 C CNN
F 3 "~" H 1500 2200 60  0000 C CNN
	1    1500 2200
	-1   0    0    -1  
$EndComp
$Comp
L LED LED2
U 1 1 544FF89B
P 1500 2400
F 0 "LED2" H 1500 2500 50  0000 C CNN
F 1 "RED" H 1350 2350 50  0000 C CNN
F 2 "~" H 1500 2400 60  0000 C CNN
F 3 "~" H 1500 2400 60  0000 C CNN
	1    1500 2400
	-1   0    0    -1  
$EndComp
$Comp
L 3V3 #PWR26
U 1 1 544FF8D2
P 1250 2100
F 0 "#PWR26" H 1250 2200 40  0001 C CNN
F 1 "3V3" H 1250 2249 40  0000 C CNN
F 2 "" H 1250 2100 60  0000 C CNN
F 3 "" H 1250 2100 60  0000 C CNN
	1    1250 2100
	1    0    0    -1  
$EndComp
Text HLabel 3950 3600 3    60   Output ~ 0
DISPLAY_BACKLIGHT
Wire Wire Line
	2800 2000 2700 2000
Wire Wire Line
	2800 2100 2300 2100
Wire Wire Line
	2300 2000 2300 2600
Wire Wire Line
	2300 2300 2800 2300
Connection ~ 2300 2100
Wire Wire Line
	2300 2500 2800 2500
Connection ~ 2300 2300
Connection ~ 2300 2500
Wire Wire Line
	1300 3700 1300 3800
Wire Wire Line
	2800 3000 2800 4100
Wire Wire Line
	2800 4100 2500 4100
Wire Wire Line
	2800 2600 2500 2600
Wire Wire Line
	2500 2600 2500 2800
Wire Wire Line
	2800 2700 2550 2700
Wire Wire Line
	2550 2700 2550 3450
Wire Wire Line
	2550 3450 1200 3450
Wire Wire Line
	1200 3450 1200 2950
Wire Wire Line
	1200 2950 1300 2950
Wire Wire Line
	2800 2800 2600 2800
Wire Wire Line
	2600 2800 2600 2950
Wire Wire Line
	2600 2950 2500 2950
Wire Wire Line
	2800 2900 2650 2900
Wire Wire Line
	2650 2900 2650 3100
Wire Wire Line
	2650 3100 2500 3100
Wire Wire Line
	1300 3200 1300 3100
Wire Wire Line
	1300 2800 1300 2700
Wire Wire Line
	1300 3950 1150 3950
Wire Wire Line
	1150 3950 1150 1650
Wire Wire Line
	1150 1650 2800 1650
Wire Wire Line
	2800 1650 2800 1900
Wire Wire Line
	2800 2200 2250 2200
Wire Wire Line
	2800 2400 2250 2400
Wire Wire Line
	1750 2200 1700 2200
Wire Wire Line
	1750 2400 1700 2400
Wire Wire Line
	1300 2200 1250 2200
Wire Wire Line
	1250 2100 1250 2400
Wire Wire Line
	1250 2400 1300 2400
Connection ~ 1250 2200
Wire Wire Line
	3950 3550 3950 3600
NoConn ~ 4250 3550
NoConn ~ 4150 3550
NoConn ~ 4050 3550
NoConn ~ 5000 2500
NoConn ~ 5000 2300
NoConn ~ 4050 1350
Text HLabel 3850 3600 3    60   3State ~ 0
KEYPAD_COL_0
Text HLabel 3750 3600 3    60   3State ~ 0
KEYPAD_COL_1
Text HLabel 3650 3600 3    60   3State ~ 0
KEYPAD_COL_2
Text HLabel 3550 3600 3    60   3State ~ 0
KEYPAD_COL_3
Text HLabel 3450 3600 3    60   3State ~ 0
KEYPAD_COL_4
Text HLabel 5050 3000 2    60   Input ~ 0
KEYPAD_ROW_A
Text HLabel 5050 2800 2    60   Input ~ 0
KEYPAD_ROW_B
Text HLabel 5050 2600 2    60   Input ~ 0
KEYPAD_ROW_C
Text HLabel 5050 2400 2    60   Input ~ 0
KEYPAD_ROW_D
Text HLabel 5050 2200 2    60   Input ~ 0
KEYPAD_ROW_E
Text HLabel 5050 2100 2    60   Input ~ 0
KEYPAD_ROW_F
$Comp
L +BATT #PWR028
U 1 1 544FFB66
P 5050 2900
F 0 "#PWR028" H 5050 2850 20  0001 C CNN
F 1 "+BATT" V 5050 3050 30  0000 C CNN
F 2 "" H 5050 2900 60  0000 C CNN
F 3 "" H 5050 2900 60  0000 C CNN
	1    5050 2900
	0    1    1    0   
$EndComp
Wire Wire Line
	3450 3550 3450 3600
Wire Wire Line
	3550 3550 3550 3600
Wire Wire Line
	3650 3550 3650 3600
Wire Wire Line
	3750 3550 3750 3600
Wire Wire Line
	3850 3550 3850 3600
Wire Wire Line
	5000 2800 5050 2800
Wire Wire Line
	5000 2600 5050 2600
Wire Wire Line
	5000 2400 5050 2400
Wire Wire Line
	5000 2200 5050 2200
Wire Wire Line
	5000 2100 5050 2100
Wire Wire Line
	5000 2000 5050 2000
Text HLabel 2800 1250 0    60   Output ~ 0
UART_CTS
Text HLabel 2800 1050 0    60   Input ~ 0
UART_RTS
Text HLabel 6600 750  2    60   Output ~ 0
UART_TXD
Text HLabel 6600 950  2    60   Input ~ 0
UART_RXD
Text HLabel 3550 1300 1    60   Output ~ 0
DISPLAY_SS
Text HLabel 3650 1300 1    60   Output ~ 0
DISPLAY_SCK
Text HLabel 3750 1300 1    60   Output ~ 0
DISPLAY_MOSI
Text HLabel 3850 1300 1    60   Output ~ 0
DISPLAY_A0
Text HLabel 3950 1300 1    60   Output ~ 0
DISPLAY_RESET
Wire Wire Line
	4900 1050 4900 1400
Wire Wire Line
	4500 1350 4450 1350
Wire Wire Line
	4450 1350 4450 1300
Wire Wire Line
	4350 1350 4350 1050
Wire Wire Line
	4350 1050 4900 1050
Connection ~ 4900 1350
Wire Wire Line
	3950 1300 3950 1350
Wire Wire Line
	3850 1300 3850 1350
Wire Wire Line
	3750 1300 3750 1350
Wire Wire Line
	3650 1300 3650 1350
Wire Wire Line
	3550 1300 3550 1350
$Comp
L 3V3 #PWR32
U 1 1 5450CFC7
P 2700 1900
F 0 "#PWR32" H 2700 2000 40  0001 C CNN
F 1 "3V3" H 2700 2049 40  0000 C CNN
F 2 "" H 2700 1900 60  0000 C CNN
F 3 "" H 2700 1900 60  0000 C CNN
	1    2700 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	2700 2000 2700 1900
Text HLabel 3350 3600 3    60   BiDi ~ 0
KEYPAD_COL_5
Wire Wire Line
	3350 3600 3350 3550
Wire Wire Line
	5050 3000 5000 3000
Text HLabel 5050 2000 2    60   Input ~ 0
KEYPAD_ROW_G
NoConn ~ 5000 1900
Wire Wire Line
	5050 2900 5000 2900
Text HLabel 5050 2700 2    60   UnSpc ~ 0
VUSB_SENSE
Wire Wire Line
	5050 2700 5000 2700
$Comp
L R R7
U 1 1 545B39EE
P 3100 1050
F 0 "R7" V 3180 1050 40  0000 C CNN
F 1 "100" V 3107 1051 40  0000 C CNN
F 2 "~" V 3030 1050 30  0000 C CNN
F 3 "~" H 3100 1050 30  0000 C CNN
	1    3100 1050
	0    -1   -1   0   
$EndComp
$Comp
L R R8
U 1 1 545B39FD
P 3100 1250
F 0 "R8" V 3180 1250 40  0000 C CNN
F 1 "100" V 3107 1251 40  0000 C CNN
F 2 "~" V 3030 1250 30  0000 C CNN
F 3 "~" H 3100 1250 30  0000 C CNN
	1    3100 1250
	0    -1   -1   0   
$EndComp
$Comp
L R R3
U 1 1 545B3A0C
P 6300 750
F 0 "R3" V 6380 750 40  0000 C CNN
F 1 "100" V 6307 751 40  0000 C CNN
F 2 "~" V 6230 750 30  0000 C CNN
F 3 "~" H 6300 750 30  0000 C CNN
	1    6300 750 
	0    -1   -1   0   
$EndComp
$Comp
L R R5
U 1 1 545B3A1B
P 6300 1150
F 0 "R5" V 6380 1150 40  0000 C CNN
F 1 "100" V 6307 1151 40  0000 C CNN
F 2 "~" V 6230 1150 30  0000 C CNN
F 3 "~" H 6300 1150 30  0000 C CNN
	1    6300 1150
	0    -1   -1   0   
$EndComp
$Comp
L R R4
U 1 1 545B3A2A
P 6300 950
F 0 "R4" V 6380 950 40  0000 C CNN
F 1 "100" V 6307 951 40  0000 C CNN
F 2 "~" V 6230 950 30  0000 C CNN
F 3 "~" H 6300 950 30  0000 C CNN
	1    6300 950 
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3350 1350 3350 1250
Wire Wire Line
	3450 1350 3450 1050
Wire Wire Line
	3450 1050 3350 1050
Wire Wire Line
	2850 1050 2800 1050
Wire Wire Line
	2850 1250 2800 1250
$Comp
L R R6
U 1 1 545B3C06
P 6300 1350
F 0 "R6" V 6380 1350 40  0000 C CNN
F 1 "100" V 6307 1351 40  0000 C CNN
F 2 "~" V 6230 1350 30  0000 C CNN
F 3 "~" H 6300 1350 30  0000 C CNN
	1    6300 1350
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4250 950  4250 1350
Wire Wire Line
	4250 950  6050 950 
Wire Wire Line
	4150 1350 4150 750 
Wire Wire Line
	4150 750  6050 750 
Wire Wire Line
	6550 750  6600 750 
Wire Wire Line
	6550 950  6600 950 
Wire Wire Line
	6550 950  6550 1350
Connection ~ 6550 1150
Wire Wire Line
	4450 3550 5950 3550
Wire Wire Line
	5950 3550 5950 1150
Wire Wire Line
	5950 1150 6050 1150
Wire Wire Line
	6050 1350 6050 3650
Wire Wire Line
	6050 3650 4350 3650
Wire Wire Line
	4350 3650 4350 3550
$Comp
L GND #PWR029
U 1 1 545A5D88
P 1300 4200
F 0 "#PWR029" H 1300 4200 30  0001 C CNN
F 1 "GND" H 1300 4130 30  0001 C CNN
F 2 "~" H 1300 4200 60  0000 C CNN
F 3 "~" H 1300 4200 60  0000 C CNN
	1    1300 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	1300 4100 1300 4200
$EndSCHEMATC
