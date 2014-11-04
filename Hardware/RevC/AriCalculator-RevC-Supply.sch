EESchema Schematic File Version 2
LIBS:AriCalculator
LIBS:AriCalculator-RevC-cache
EELAYER 27 0
EELAYER END
$Descr User 8268 5827
encoding utf-8
Sheet 2 6
Title "Supply"
Date "4 nov 2014"
Rev "RevC"
Comp "Dirk Heisswolf"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L AAA-BATTERY BAT1
U 1 1 544A80D6
P 2550 3150
F 0 "BAT1" H 2650 3300 60  0000 L CNN
F 1 "AAA-BATTERY" V 2300 3150 60  0000 C CNN
F 2 "" H 2900 3250 60  0000 C CNN
F 3 "" H 2900 3250 60  0000 C CNN
	1    2550 3150
	1    0    0    -1  
$EndComp
$Comp
L AAA-BATTERY BAT2
U 1 1 544A80E5
P 2550 3950
F 0 "BAT2" H 2650 4100 60  0000 L CNN
F 1 "AAA-BATTERY" V 2300 3950 60  0000 C CNN
F 2 "" H 2900 4050 60  0000 C CNN
F 3 "" H 2900 4050 60  0000 C CNN
	1    2550 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	2550 3500 2550 3600
$Comp
L +BATT #PWR01
U 1 1 544A8180
P 2650 1600
F 0 "#PWR01" H 2650 1550 20  0001 C CNN
F 1 "+BATT" H 2650 1700 30  0000 C CNN
F 2 "" H 2650 1600 60  0000 C CNN
F 3 "" H 2650 1600 60  0000 C CNN
	1    2650 1600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 544A8190
P 2550 4400
F 0 "#PWR02" H 2550 4400 30  0001 C CNN
F 1 "GND" H 2550 4330 30  0001 C CNN
F 2 "" H 2550 4400 60  0000 C CNN
F 3 "" H 2550 4400 60  0000 C CNN
	1    2550 4400
	1    0    0    -1  
$EndComp
$Comp
L SWITCH_INV SW1
U 1 1 544A865B
P 2650 2200
F 0 "SW1" H 2450 2350 50  0000 C CNN
F 1 "POWER SWITCH" H 2450 2050 50  0000 C CNN
F 2 "~" H 2650 2200 60  0000 C CNN
F 3 "~" H 2650 2200 60  0000 C CNN
	1    2650 2200
	0    1    1    0   
$EndComp
$Comp
L GND #PWR03
U 1 1 544A8720
P 2750 2800
F 0 "#PWR03" H 2750 2800 30  0001 C CNN
F 1 "GND" H 2750 2730 30  0001 C CNN
F 2 "" H 2750 2800 60  0000 C CNN
F 3 "" H 2750 2800 60  0000 C CNN
	1    2750 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	2550 4300 2550 4400
$Comp
L MCP1640 IC2
U 1 1 544A87F2
P 4500 2950
F 0 "IC2" H 4500 3200 60  0000 C CNN
F 1 "MCP1640" H 4500 2700 60  0000 C CNN
F 2 "" H 4450 2700 60  0000 C CNN
F 3 "" H 4450 2700 60  0000 C CNN
	1    4500 2950
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 544A8878
P 3600 2500
F 0 "C3" H 3600 2600 40  0000 L CNN
F 1 "4.7uF" H 3606 2415 40  0000 L CNN
F 2 "~" H 3638 2350 30  0000 C CNN
F 3 "~" H 3600 2500 60  0000 C CNN
	1    3600 2500
	-1   0    0    -1  
$EndComp
$Comp
L C C4
U 1 1 544A8887
P 5700 2800
F 0 "C4" H 5700 2900 40  0000 L CNN
F 1 "10uF" H 5706 2715 40  0000 L CNN
F 2 "~" H 5738 2650 30  0000 C CNN
F 3 "~" H 5700 2800 60  0000 C CNN
	1    5700 2800
	1    0    0    -1  
$EndComp
$Comp
L R R8
U 1 1 544A8896
P 5450 3350
F 0 "R8" H 5530 3350 40  0000 C CNN
F 1 "470K" V 5457 3351 40  0000 C CNN
F 2 "~" V 5380 3350 30  0000 C CNN
F 3 "~" H 5450 3350 30  0000 C CNN
	1    5450 3350
	-1   0    0    1   
$EndComp
$Comp
L R R7
U 1 1 544A88A5
P 5450 2750
F 0 "R7" V 5530 2750 40  0000 C CNN
F 1 "820K" V 5457 2751 40  0000 C CNN
F 2 "~" V 5380 2750 30  0000 C CNN
F 3 "~" H 5450 2750 30  0000 C CNN
	1    5450 2750
	-1   0    0    -1  
$EndComp
$Comp
L INDUCTOR L1
U 1 1 544A88DE
P 3900 2500
F 0 "L1" V 3850 2500 40  0000 C CNN
F 1 "4.7uH" V 4000 2500 40  0000 C CNN
F 2 "~" H 3900 2500 60  0000 C CNN
F 3 "~" H 3900 2500 60  0000 C CNN
	1    3900 2500
	1    0    0    1   
$EndComp
Wire Wire Line
	2650 1700 2650 1600
Wire Wire Line
	2550 2800 2550 2700
Wire Wire Line
	2750 2700 2750 2800
$Comp
L +BATT #PWR04
U 1 1 544A8A64
P 5100 2850
F 0 "#PWR04" H 5100 2800 20  0001 C CNN
F 1 "+BATT" H 5100 2950 30  0000 C CNN
F 2 "" H 5100 2850 60  0000 C CNN
F 3 "" H 5100 2850 60  0000 C CNN
	1    5100 2850
	0    1    1    0   
$EndComp
$Comp
L +BATT #PWR05
U 1 1 544A8A85
P 3900 2150
F 0 "#PWR05" H 3900 2100 20  0001 C CNN
F 1 "+BATT" H 3900 2250 30  0000 C CNN
F 2 "" H 3900 2150 60  0000 C CNN
F 3 "" H 3900 2150 60  0000 C CNN
	1    3900 2150
	1    0    0    -1  
$EndComp
$Comp
L 3V3 #PWR8
U 1 1 544A8B01
P 5300 2450
F 0 "#PWR8" H 5300 2550 40  0001 C CNN
F 1 "3V3" H 5300 2575 40  0000 C CNN
F 2 "" H 5300 2450 60  0000 C CNN
F 3 "" H 5300 2450 60  0000 C CNN
	1    5300 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5300 2950 5050 2950
Wire Wire Line
	5300 2450 5300 2950
Wire Wire Line
	5300 2500 5700 2500
Connection ~ 5300 2500
Wire Wire Line
	5700 2500 5700 2600
Connection ~ 5450 2500
Wire Wire Line
	5450 3000 5450 3100
Wire Wire Line
	5050 3050 5450 3050
Connection ~ 5450 3050
$Comp
L GND #PWR06
U 1 1 544A8C6A
P 5450 3700
F 0 "#PWR06" H 5450 3700 30  0001 C CNN
F 1 "GND" H 5450 3630 30  0001 C CNN
F 2 "" H 5450 3700 60  0000 C CNN
F 3 "" H 5450 3700 60  0000 C CNN
	1    5450 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 3600 5450 3700
Wire Wire Line
	5700 3000 5700 3600
Wire Wire Line
	5700 3600 5450 3600
Wire Wire Line
	3900 2150 3900 2200
Wire Wire Line
	3600 2300 3600 2200
Wire Wire Line
	3600 2200 3900 2200
Wire Wire Line
	3900 2800 3900 2850
Wire Wire Line
	3900 2850 3950 2850
Wire Wire Line
	3600 2700 3600 3050
Wire Wire Line
	3600 2950 3950 2950
$Comp
L GND #PWR07
U 1 1 544A8D25
P 3600 3050
F 0 "#PWR07" H 3600 3050 30  0001 C CNN
F 1 "GND" H 3600 2980 30  0001 C CNN
F 2 "" H 3600 3050 60  0000 C CNN
F 3 "" H 3600 3050 60  0000 C CNN
	1    3600 3050
	1    0    0    -1  
$EndComp
Connection ~ 3600 2950
$Comp
L +BATT #PWR08
U 1 1 544A8DF4
P 3900 3050
F 0 "#PWR08" H 3900 3000 20  0001 C CNN
F 1 "+BATT" H 3900 3150 30  0000 C CNN
F 2 "" H 3900 3050 60  0000 C CNN
F 3 "" H 3900 3050 60  0000 C CNN
	1    3900 3050
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3900 3050 3950 3050
Wire Wire Line
	5100 2850 5050 2850
$EndSCHEMATC
