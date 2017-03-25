;page numbers are from the MC9S12G Family Reference Manual and Datasheet

;include definitions 
              INCLUDE 'derivative.inc'
            
BIT0          EQU %00000001
BIT1          EQU %00000010
BIT2          EQU %00000100
BIT3          EQU %00001000
BIT4          EQU %00010000
BIT5          EQU %00100000
BIT6          EQU %01000000
BIT7          EQU %10000000

ROMStart      EQU $4000                  ;absolute address to place code data
RAM2Start     EQU $2100                  ;absolute address to place variable data
CONSTANTStart EQU $5000                  ;absolute address to place constant data

m             EQU $2000

r4            EQU $2001
r3            EQU $2002
r2            EQU $2003
r1            EQU $2004
r0            EQU $2005

n             EQU $2006

k4            EQU $2007
k3            EQU $2008
k2            EQU $2009
k1            EQU $200A
k0            EQU $200B

e             EQU $200C

border        EQU $200D

s4            EQU $2010
s3            EQU $2011
s2            EQU $2012
s1            EQU $2013
s0            EQU $2014

l4            EQU $2015
l3            EQU $2016
l2            EQU $2017
l1            EQU $2018
l0            EQU $2019

m_1           EQU $201A

r4_1          EQU $201B
r3_1          EQU $201C
r2_1          EQU $201D
r1_1          EQU $201E
r0_1          EQU $201F

n_1           EQU $2020

k4_1          EQU $2021
k3_1          EQU $2022
k2_1          EQU $2023
k1_1          EQU $2024
k0_1          EQU $2025

e_1           EQU $2026

m_2           EQU $2027

r4_2          EQU $2028
r3_2          EQU $2029
r2_2          EQU $202A
r1_2          EQU $202B
r0_2          EQU $202C

n_2           EQU $202D

k4_2          EQU $202E
k3_2          EQU $202F
k2_2          EQU $2030
k1_2          EQU $2031
k0_2          EQU $2032

e_2           EQU $2033

m_3           EQU $2034

r4_3          EQU $2035
r3_3          EQU $2036
r2_3          EQU $2037
r1_3          EQU $2038
r0_3          EQU $2039

n_3           EQU $203A

k4_3          EQU $203B
k3_3          EQU $203C
k2_3          EQU $203D
k1_3          EQU $203E
k0_3          EQU $203F

e_3           EQU $2040

m_4           EQU $2041

r4_4          EQU $2042
r3_4          EQU $2043
r2_4          EQU $2044
r1_4          EQU $2045
r0_4          EQU $2046

n_4           EQU $2047

k4_4          EQU $2048
k3_4          EQU $2049
k2_4          EQU $204A
k1_4          EQU $204B
k0_4          EQU $204C

e_4           EQU $204D

;variable data section
              ORG RAM2Start                
                          
page_Counter  DS.B 1
col_Counter   DS.B 1
col_Value     DS.B 1
savedY        DS.B 1
Ycoord        DS.B 1
keyNumber     DS.B 1
counter       DS.B 1
flag1         DS.B 1
flag2         DS.B 1
shifttest     DS.B 1 

;code section
              ORG   ROMStart
            
entry:        LDS   #RAMEnd+1            ;initialise stack pointer, RAMEnd = #0x3FFF (see mc9s12g128.inc)

              LDAA  #$FF                 ;accumulator A = #0xFF
            
              STAA  DDR0AD               ;DDR0AD = A = #0xFF,set to output (DDR0AD@0x0274,p1246 & p42) 
              STAA  DDR1AD               ;DDR1AD = A = #0xFF (DDR0AD@0x0275,p1246)
              STAA  DDRA                 ;DDRA = A = #0xFF (DDRA@0x0002,p1230)
              STAA  DDRB                 ;DDRB = A = #0xFF (DDRB@0x0003,p1230)
              STAA  DDRC                 ;DDRC = A = #0xFF (DDRC@0x0006,p1230)
              STAA  DDRD                 ;DDRD = A = #0xFF (DDRD@0x0007,p1230)
              STAA  DDRE                 ;DDRE = A = #0xFF (DDRE@0x0009,p1230)
              STAA  DDRJ                 ;DDRJ = A = #0xFF (DDRJ@0x026A,p1246)
              STAA  DDRM                 ;DDRM = A = #0xFF (DDRM@0x0252,p1244)                                       
              STAA  DDRT                 ;DDRT = A = #0xFF (DDRT@0x0242,p1244)
              
              MOVB #$FF,PERP             ;PERP = #0xFF,pull-up resistors enabled on Port P (PERP@0x025C & PPSP@0x025D,p1245)                     
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;timer initialisation 1            
            
              MOVB  #$05,TSCR2           ;TSCR2 = A = 0000 0101,no interrupt,prescale factor = 32 (TSCR2@0x004D,p1234)
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of timer initialisation 1 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SPI initialisation (PTS.4 = MISO0,PTS.5 = MOSI0,PTS.6 = SCK0,PTS.7 = SS0)      
            
              LDAA  #$02
              STAA  SPI0BR               ;SPI0BR = 0000 0010,divide by 8 (SPI0BR@0x00DA,p1239,baud rate set,p696)
            
              LDAA  #$50
              STAA  SPI0CR1              ;SPI0CR1 = 0101 0000 (SPI0CR1@0x00D8,p1239)
                                         ;SPI enabled, master mode, CPOL = 0, CPHA = 0                                   
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of SPI initialisation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;variable initialisation

              CLRA
              
              STAA col_Value             
              
              STAA flag1
              
              STAA flag2
              
              STAA m
              STAA n
              
              STAA r0
              STAA r1
              STAA r2
              STAA r3
              STAA r4
              
              STAA k0
              STAA k1
              STAA k2
              STAA k3
              STAA k4
              
              STAA m_1
              STAA n_1
              
              STAA r0_1
              STAA r1_1
              STAA r2_1
              STAA r3_1
              STAA r4_1
              
              STAA k0_1
              STAA k1_1
              STAA k2_1
              STAA k3_1
              STAA k4_1
              
              STAA m_2
              STAA n_2
              
              STAA r0_2
              STAA r1_2
              STAA r2_2
              STAA r3_2
              STAA r4_2
              
              STAA k0_2
              STAA k1_2
              STAA k2_2
              STAA k3_2
              STAA k4_2
              
              STAA m_3
              STAA n_3
              
              STAA r0_3
              STAA r1_3
              STAA r2_3
              STAA r3_3
              STAA r4_3
              
              STAA k0_3
              STAA k1_3
              STAA k2_3
              STAA k3_3
              STAA k4_3
              
              STAA m_4
              STAA n_4
              
              STAA r0_4
              STAA r1_4
              STAA r2_4
              STAA r3_4
              STAA r4_4
              
              STAA k0_4
              STAA k1_4
              STAA k2_4
              STAA k3_4
              STAA k4_4
              
              STAA shifttest                           
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of variable initialisation              

              BCLR PORTD,#BIT6           ;PORTD = x0xx xxxx,PD6 = RST = 0 (PORTD@0x0005,p1230)
            
              JSR timer                  ;delay 
            
              BSET PORTD,#BIT6           ;PORTD = x1xx xxxx,PD6 = RST = 1
            
              BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command
            
              LDAA #$A3
            
              JSR sendByte               ;set bias to 1/7                 
            
              LDAA #$A0                   
            
              JSR sendByte               ;set display to normal
            
              LDAA #$C8                   
            
              JSR sendByte               ;set COM output scan direction to reverse
            
              LDAA #$A6                   
            
              JSR sendByte               ;set display to normal (i.e. not inverted)
            
              LDAA #$40                   
            
              JSR sendByte               ;set RAM display start line to 0
            
              LDAA #$2C                   
            
              JSR sendByte               
            
              JSR timer                  ;delay
            
              LDAA #$2F                   
            
              JSR sendByte               
            
              JSR timer                  ;delay
            
              LDAA #$AF                   
            
              JSR sendByte               ;display on
            
              LDAA #$A4                   
            
              JSR sendByte               ;all points normal
            
              JSR clearScreen            ;clear the screen
              
              JSR dispStack              ;display the stack
              
              JSR dispMode               ;display the mode
              
              BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

							LDAA #$B1

							JSR sendByte               ;set to page 5
   
							LDAA #$10
					    JSR sendByte               ;set MSN of column address to 0 
					 
					    LDAA #$01
					    JSR sendByte               ;set LSN of column address to 1
					 
					    BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data	

              MOVB #$01,Ycoord           ;Ycoord reset to 1                            
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;timer initialisation 2            
            
              MOVB  #$87,TSCR2           ;TSCR2 = A = 1000 0111,interrupt,prescale factor = 128 (TSCR2@0x004D,p1234)
              
              LDAA  #$80                 ;accumulator A = #0x80
              STAA  TSCR1                ;TSCR1 = A = 1000 0000,timer enabled (TSCR1@0x0046,p1234)
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of timer initialisation 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;RTI initialisation            
            
              BSET CPMUINT,#BIT7         ;enable RTI
              
              LDAA #$77                   
              STAA CPMURTI               ;set the time-out period (p372)
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of RTI initialisation           
              
              CLI                        ;unmask interrupts
              
              BRA $                      ;wait for interrupt
              
keyHandlerSub DC.W key0
              DC.W key1 
              DC.W key2
              DC.W key3 
              DC.W key4
              DC.W key5 
              DC.W key6
              DC.W key7 
              DC.W key8
              DC.W key9 
              DC.W key10
              DC.W key11
              DC.W key12
              DC.W key13
              DC.W key14
              DC.W key15
              
              DC.W key0S
              DC.W key1S 
              DC.W key2S
              DC.W key3S 
              DC.W key4S
              DC.W key5S 
              DC.W key6S
              DC.W key7S 
              DC.W key8S
              DC.W key9S 
              DC.W key10S
              DC.W key11S
              DC.W key12S
              DC.W key13S
              DC.W key14S
              DC.W key15S 
              
              DC.W key0S2
              DC.W key1S2 
              DC.W key2S2
              DC.W key3S2 
              DC.W key4S2
              DC.W key5S2 
              DC.W key6S2
              DC.W key7S2 
              DC.W key8S2
              DC.W key9S2 
              DC.W key10S2
              DC.W key11S2
              DC.W key12S2
              DC.W key13S2
              DC.W key14S2
              DC.W key15S2
                            
;**************************************************************
;*                        Subroutines                         *
;**************************************************************  
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;sendByte subroutine     
            
sendByte:    BRCLR SPI0SR,#BIT5,sendByte ;if SPI0SR.5 (SPTEF) = 0 then branch to sendByte,i.e. loop until SPTEF = 1
                                         ;SPTEF = 1 -> SPIDR empty                                      
            
             STAA SPI0DRL                ;initiate data transfer and clear SPTEF
            
sendByte_2:  BRCLR SPI0SR,#BIT7,sendByte_2 ;if SPI0SR.7 (SPIF) = 0 then branch to sendByte_2, i.e. loop until SPIF = 1
                                         ;SPIF = 1 -> new data copied to SPIDR
                                         
             LDAB SPI0DRL                ;read SPI0DRL to B to clear SPIF
                                       
             RTS
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of sendByte subroutine
                                       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;timer subroutine          
            
timer:        LDAA  #$80                 ;accumulator A = #0x80
              STAA  TSCR1                ;TSCR1 = A = 1000 0000,timer enabled (TSCR1@0x0046,p1234)
            
timer_2:      BRCLR TFLG2,#BIT7,timer_2  ;if TFLG2 anl #0x80 = 0 then branch to timer_2,i.e loop until TOF = 1 (timer overflows)
              BSET  TFLG2,#BIT7          ;TFLG2 orl #0x80 to set TFLG2.7 = TOF to clear the timer overflow flag (TOF) (TFLG2@0x004F,p1234)
            
              CLRA                       ;accumulator A = #0x00
              STAA  TSCR1                ;TSCR1 = A = 0000 0000,timer disabled (TSCR1@0x0046,p1234)
            
              RTS
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end timer subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;clearScreen subroutine

clearScreen:  LDX #$08
              MOVB #$B0,page_Counter     ;page_Counter = 1011 0000 -> page 4 (due to bug on GLCD?)
           
clearScreen_1:
              BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command
           
              LDAA page_Counter          ;A = page_Counter 
              JSR sendByte               ;set the page
           
              LDAA #$10
					    JSR sendByte               ;set MSN of column address to 0 
					 
					    LDAA #$01
					    JSR sendByte               ;set LSN of column address to 1
					 
					    BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data
					    
					    CLRA
					    
					    JSR clearPage          
              
              INC page_Counter           ;increment the page number
              
              DEX                        ;decrement register X
              BNE clearScreen_1
              
              RTS
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end clearScreen subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;clearPage subroutine

clearPage:    MOVB #$80,col_Counter      ;col_Counter = 128,index for number of columns cleared 
					    
clearPage_1:  JSR sendByte               ;blank the column

              DEC col_Counter            ;decrement col_Counter
              BNE clearPage_1            ;jump to clearPage_1 if col_Counter is not zero (i.e. if Z = 0)
              
              RTS
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end clearPage subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dispStack subroutine

dispStack:    LDY #$03                   ;stack 4,3,2    

              LDX #stackLevels
              
              MOVB #$B5,page_Counter     ;start at level 4 (page 1)

dispStack_1:  BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

              LDAA page_Counter
              JSR sendByte
              
              LDAA #$10
					    JSR sendByte               ;set MSN of column address to 0 
					 
					    LDAA #$01
					    JSR sendByte               ;set LSN of column address to 1
					    
					    BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data
					    
					    MOVB #$06,col_Counter      ;six columns
					    
					    JSR sendData          
                            
              INC page_Counter
              
              DEY              
              BNE dispStack_1
              
              BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command
              
              LDAA #$B0                  ;page 4
              JSR sendByte
              
              LDAA #$10
					    JSR sendByte               ;set MSN of column address to 0 
					 
					    LDAA #$01
					    JSR sendByte               ;set LSN of column address to 1
					    
					    BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data
					    
					    MOVB #$06,col_Counter      ;six columns
					    					    
              JSR sendData
              
              RTS 
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end dispStack subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dispMode subroutine

dispMode:     BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

							LDAA #$B4                  ;A = 1011 0100 -> page 0 (due to bug on GLCD?) 
              JSR sendByte               ;set the page
                
              LDAA #$10
					    JSR sendByte               ;set MSN of column address to 0 
					 
					    LDAA #$01
					    JSR sendByte               ;set LSN of column address to 1
					      
					    LDX #Tadic
					    MOVB #$24,col_Counter
                
              BRCLR flag2,#BIT6,updateDisp_2
                
              LDX #Deci
              MOVB #$12,col_Counter
                
updateDisp_2: BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data

              JSR sendData               ;display mode annunciator
              
              RTS
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end dispMode subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;sendData subroutine

sendData:     LDAA 1,X+                  ;load into A the byte at the location pointed to by X, then increment X by 1 
              JSR sendByte

              INC Ycoord                           
                
              DEC col_Counter
              BNE sendData 
								
              RTS
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end sendData subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;key subroutine

key:          BSET flag1,#BIT4           ;set keyPressed?          

              CLR keyNumber
              
              BSET PT1AD,#BIT1           ;PT1AD.0 = 0 -> row 0 scanned
              BSET PT1AD,#BIT2
              BSET PT1AD,#BIT3  
                           
              JSR colScan                ;scan all four columns of row 0
              
              BRSET flag1,#BIT5,keyHandler ;(flag1.5 = keyFound?)

              BSET PT1AD,#BIT0           ;PT1AD.1 = 0 -> row 1 scanned
              BCLR PT1AD,#BIT1  

              JSR colScan                ;scan all four columns of row 1

              BRSET flag1,#BIT5,keyHandler ;(flag1.5 = keyFound?) 

              BSET PT1AD,#BIT1           ;PT1AD.2 = 0 -> row 2 scanned
              BCLR PT1AD,#BIT2

              JSR colScan                ;scan all four columns of row 2

              BRSET flag1,#BIT5,keyHandler ;(flag1.5 = keyFound?)
              
              BSET PT1AD,#BIT2           ;PT1AD.3 = 0 -> row 3 scanned
              BCLR PT1AD,#BIT3               

              JSR colScan                ;scan all four columns of row 3

              BRA keyHandler

tofISR_4:     BRA exit

;clear error message on page 6/7 once a key has been pressed if the errorFlag is set

keyHandler:   BRCLR flag1,#BIT6,tofISR_5 ;no error message displayed (flag1.6 = errorFlag?)   

              JSR updateDisp                                     
								
              BCLR flag1,#BIT6               ;clear errorFlag									
								
tofISR_5:     LDX #keyHandlerSub

              CLRA                           ;clear A              

              LDAB keyNumber

              ADDB keyNumber
              
              BRCLR flag1,#BIT1,tofISR_6 ;if Shift1 function selected add 32 to X (flag1.1 = shift1KeyFlag)
              
              ADDB #$20                            							 
								
tofISR_6:     BRCLR flag1,#BIT3,tofISR_8 ;if Shift2 function selected add 64 to X (flag1.3 = shift2KeyFlag)  

              ADDB #$40

tofISR_8:     JMP [D,X]

tofISR_7:     BCLR flag1,#BIT5           ;(flag1.5 = keyFound?)  

exit:         RTS 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key0:         NOP                                      ;/

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key1:         BRSET flag2,#BIT5,key1_1         

              JSR dispApos                             ;apostrophe

              BSET flag2,#BIT5

key1_1:       JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key2:         JSR dispZero                             ;0 
              
              CLC                                      ;clear carry
              
              BRSET flag2,#BIT5,key2_2
              
              JSR rSet
              
              BRA key2_1
              
key2_2:       JSR kSet                                       			

key2_1:       JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key3:         BRSET flag2,#BIT1,lift3                  ;ENTER
              BRSET flag2,#BIT2,lift2
              BRSET flag2,#BIT3,lift1_1
              JMP key3_2
              
lift1_1:      JMP lift1                       

lift3:        MOVB m_3,m_4                             ;level 3 value copied to level 4
                                                   
              MOVB r0_3,r0_4
              MOVB r1_3,r1_4
              MOVB r2_3,r2_4
              MOVB r3_3,r3_4
              MOVB r4_3,r4_4
              
              MOVB n_3,n_4
              
              MOVB k0_3,k0_4
              MOVB k1_3,k1_4
              MOVB k2_3,k2_4
              MOVB k3_3,k3_4
              MOVB k4_3,k4_4
              
              MOVB e_3,e_4
              
              BSET flag2,#BIT0                   

lift2:        MOVB m_2,m_3                             ;level 2 value copied to level 3
                                                   
              MOVB r0_2,r0_3
              MOVB r1_2,r1_3
              MOVB r2_2,r2_3
              MOVB r3_2,r3_3
              MOVB r4_2,r4_3
              
              MOVB n_2,n_3
              
              MOVB k0_2,k0_3
              MOVB k1_2,k1_3
              MOVB k2_2,k2_3
              MOVB k3_2,k3_3
              MOVB k4_2,k4_3
              
              MOVB e_2,e_3
              
              BSET flag2,#BIT1  
								
lift1:        MOVB m_1,m_2                             ;level 1 value copied to level 2
                                                   
              MOVB r0_1,r0_2
              MOVB r1_1,r1_2
              MOVB r2_1,r2_2
              MOVB r3_1,r3_2
              MOVB r4_1,r4_2
              
              MOVB n_1,n_2
              
              MOVB k0_1,k0_2
              MOVB k1_1,k1_2
              MOVB k2_1,k2_2
              MOVB k3_1,k3_2
              MOVB k4_1,k4_2
              
              MOVB e_1,e_2
              
              BSET flag2,#BIT2
								
key3_2:       MOVB m,m_1                             ;edit line value copied to level 1
                                                   
              MOVB r0,r0_1
              MOVB r1,r1_1
              MOVB r2,r2_1
              MOVB r3,r3_1
              MOVB r4,r4_1
              
              MOVB n,n_1
              
              MOVB k0,k0_1
              MOVB k1,k1_1
              MOVB k2,k2_1
              MOVB k3,k3_1
              MOVB k4,k4_1
              
              MOVB e,e_1

              BSET flag2,#BIT3 

              JSR updateDisp																	

              JMP tofISR_7

;updateDisp subroutine - clears the screen and updates the stack

updateDisp:   JSR clearScreen                
              JSR dispStack
              
              BRSET flag2,#BIT0,level4
              BRSET flag2,#BIT1,level3
              BRSET flag2,#BIT2,level2_1
              BRSET flag2,#BIT3,level1_1
              JMP updateDisp_1
              
level2_1:     JMP level2

level1_1:     JMP level1          

level4:       MOVB m_4,m                              ;level 4 value copied to buffer
                                                   
              MOVB r0_4,r0
              MOVB r1_4,r1
              MOVB r2_4,r2
              MOVB r3_4,r3
              MOVB r4_4,r4
              
              MOVB n_4,n
              
              MOVB k0_4,k0
              MOVB k1_4,k1
              MOVB k2_4,k2
              MOVB k3_4,k3
              MOVB k4_4,k4
              
              MOVB e_4,e

					  	BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

						  LDAA #$B5

						  JSR sendByte                          ;set to page 1

              BRSET flag2,#BIT6,write_Rat_3   ;if ratDisp flag set,display numbers in rational form 

              JSR write
              
              BRA jmp_3
              
write_Rat_3:  JSR writeRat

jmp_3:															
 
level3:       MOVB m_3,m                              ;level 3 value copied to buffer
                                                   
              MOVB r0_3,r0
              MOVB r1_3,r1
              MOVB r2_3,r2
              MOVB r3_3,r3
              MOVB r4_3,r4
              
              MOVB n_3,n
              
              MOVB k0_3,k0
              MOVB k1_3,k1
              MOVB k2_3,k2
              MOVB k3_3,k3
              MOVB k4_3,k4
              
              MOVB e_3,e

					  	BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

						  LDAA #$B6

						  JSR sendByte                          ;set to page 2

              BRSET flag2,#BIT6,write_Rat_2   ;if ratDisp flag set,display numbers in rational form 

              JSR write
              
              BRA jmp_2
              
write_Rat_2:  JSR writeRat

jmp_2:													

level2:       MOVB m_2,m                              ;level 2 value copied to buffer
                                                   
              MOVB r0_2,r0
              MOVB r1_2,r1
              MOVB r2_2,r2
              MOVB r3_2,r3
              MOVB r4_2,r4
              
              MOVB n_2,n
              
              MOVB k0_2,k0
              MOVB k1_2,k1
              MOVB k2_2,k2
              MOVB k3_2,k3
              MOVB k4_2,k4
              
              MOVB e_2,e

					  	BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

						  LDAA #$B7

						  JSR sendByte                          ;set to page 3

              BRSET flag2,#BIT6,write_Rat_1   ;if ratDisp flag set,display numbers in rational form 

              JSR write
              
              BRA jmp_1
              
write_Rat_1:  JSR writeRat

jmp_1:							
                
level1:       MOVB m_1,m                              ;level 1 value copied to buffer
                                                   
              MOVB r0_1,r0
              MOVB r1_1,r1
              MOVB r2_1,r2
              MOVB r3_1,r3
              MOVB r4_1,r4
              
              MOVB n_1,n
              
              MOVB k0_1,k0
              MOVB k1_1,k1
              MOVB k2_1,k2
              MOVB k3_1,k3
              MOVB k4_1,k4
              
              MOVB e_1,e

					  	BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

						  LDAA #$B0

						  JSR sendByte                          ;set to page 4
						  
						  BRSET flag2,#BIT6,write_Rat_0   ;if ratDisp flag set, display numbers in rational form 

              JSR write
              
              BRA updateDisp_1
              
write_Rat_0:  JSR writeRat

updateDisp_1: JSR dispMode   
                
                BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command								
								
								LDAA #$B1
								JSR sendByte               ;set to page 5
   
							  LDAA #$10
					      JSR sendByte               ;set MSN of column address to 0 
					 
					      LDAA #$01
					      JSR sendByte               ;set LSN of column address to 1
					 
					      BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data	

                MOVB #$01,Ycoord           ;Ycoord reset to 1
                
                BCLR flag2,#BIT5           ;clear apostropheFlag
                
                CLRA
                
                STAA m                     ;reset m,n,r,k to 0
                STAA n
              
                STAA r0
                STAA r1
                STAA r2
                STAA r3
                STAA r4
              
                STAA k0
                STAA k1
                STAA k2
                STAA k3
                STAA k4

                RTS                                           

;end of updateDisp subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;

;write subroutine - writes the 2-adic number on the screen

write:          MOVB #$7B,savedY           ;savedY = 123

                JSR dispPart               ;display constant part (k)
                
                JSR setY
                
                LDAA savedY                ;update savedY
					      SUBA #$06                 
					      STAA savedY  
																
								LDX #Apos                  ;display apostrophe
								
								MOVB #$06,col_Counter      ;six columns
								
								JSR sendData
								
								MOVB m,n
								
								MOVB r4,k4 
								MOVB r3,k3
								MOVB r2,k2
								MOVB r1,k1
								MOVB r0,k0
								
								JSR dispPart               ;display repetitive part (r)								                    
                
                RTS								

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end of write subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;writeRat subroutine - converts the 2-adic number to rational form and displays it

writeRat:   JSR convert              ;determine numerator (l) and denominator (s)

            ;JSR gcd                  ;determine gcd(l,s)
            
            ;JSR reduced              ;determine l/gcd(l,s),s/gcd(l,s)
            
            MOVB #$4B,savedY          ;denominator starts at y=75
            
            JSR setY           
            
            MOVB s4,r4
            MOVB s3,r3
            MOVB s2,r2
            MOVB s1,r1
            MOVB s0,r0            

            JSR dispInt               ;display the denominator
            
            LDAA savedY               ;update savedY
					  SUBA #$06                 
					  STAA savedY
					  
					  JSR setY
            
            LDX #Soli
            
            MOVB #$06,col_Counter      ;six columns
            
            JSR sendData
            
            LDAA savedY               ;update savedY
					  SUBA #$36                 
					  STAA savedY
					  
					  JSR setY
            
            MOVB l4,r4
            MOVB l3,r3
            MOVB l2,r2
            MOVB l1,r1
            MOVB l0,r0
            
            JSR dispInt              ;display the numerator
            
            RTS
                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of writeRat subroutine 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key4:         NOP                                      ;*

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key5:         NOP                                      ;9

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key6:         NOP                                      ;8

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key7:         NOP                                      ;7

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key8:         NOP                                      ;-

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key9:         NOP                                      ;6

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key10:        NOP                                      ;5

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key11:        NOP                                      ;4

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key12:        NOP                                      ;+

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key13:        NOP                                      ;3

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key14:        NOP                                      ;2

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key15:        JSR dispOne                              ;1 
              
              SEC                                      ;set carry
              
              BRSET flag2,#BIT5,key15_2
              
              JSR rSet
              
              BRA key15_1
              
key15_2:      JSR kSet                                       			

key15_1:      JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key0S:        NOP                                      ;

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;invert stack level 1 value         

key1S:        MOVB m_1,m                               ;level 1 value copied to buffer
                                                   
              MOVB r0_1,r0
              MOVB r1_1,r1
              MOVB r2_1,r2
              MOVB r3_1,r3
              MOVB r4_1,r4
              
              MOVB n_1,n
              
              MOVB k0_1,k0
              MOVB k1_1,k1
              MOVB k2_1,k2
              MOVB k3_1,k3
              MOVB k4_1,k4
              
              MOVB e_1,e            

              MOVB r0, s0                                ;copy r to s
              MOVB r1, s1
              MOVB r2, s2
              MOVB r3, s3
              MOVB r4, s4
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;if k<>0 jump to pneg_7
            LDX #$2007
            MOVB #$05,counter

pneg_8:     LDAA 1,X+                                  ;load into A the byte at the location pointed to by X, then increment X by 1
            LBNE pneg_7                                ;long branch to pneg_7 if <> 0
            DEC counter
            BNE pneg_8
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;if r<>0 jump to pneg_9
            LDX #$2001
            MOVB  #$05,counter

pneg_10:    LDAA 1,X+                                  ;load into A the byte at the location pointed to by X, then increment X by 1
            BNE pneg_9                                 ;branch to pneg_9 if <> 0
            DEC counter
            BNE pneg_10
            
            JMP pneg_end                               ;exit if k=0 and r=0
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;determine position of first "1" in r
pneg_9:     CLR counter
            
pneg_1:     INC counter

            ROR r4
            ROR r3
            ROR r2
            ROR r1
            ROR r0
            
            BCC pneg_1
            
            MOVB counter,border
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;update k
            LDAA counter
            ADDA n
            DECA
            STAA counter
            
            MOVB #$01,k0

pneg_2:     ASL k0
            ROL k1
            ROL k2
            ROL k3
            ROL k4
            DEC counter
            BNE pneg_2
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;update n
            LDAA border
            ADDA n
            STAA n
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            JSR comr
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;set mth bit,all other bits 0 and store in r
            MOVB m,counter
            DEC counter
            MOVB #$01,r0
            
            CLR r4
            CLR r3
            CLR r2
            CLR r1
            
            CLC
            
pneg_4:     ASL r0
            ROL r1
            ROL r2
            ROL r3
            ROL r4
            
            DEC counter
            BNE pneg_4
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;determine new value of r, store in s
            MOVB border,counter
            
pneg_6:     ASR s4
            ROR s3
            ROR s2
            ROR s1
            ROR s0
            
            BCC pneg_5
            
            LDAA s0
            ORAA r0
            STAA s0
            LDAA s1
            ORAA r1
            STAA s1
            LDAA s2
            ORAA r2
            STAA s2
            LDAA s3
            ORAA r3
            STAA s3
            LDAA s4
            ORAA r4
            STAA s4
            
pneg_5:     DEC counter
            BNE pneg_6
            
            JSR updater
            
            JMP pneg_end
            
pneg_7:     JSR comr
            
            JSR updatek
            
            JSR updater
            
pneg_end:   MOVB m,m_1                             ;buffer copied to level 1
                                                   
            MOVB r0,r0_1
            MOVB r1,r1_1
            MOVB r2,r2_1
            MOVB r3,r3_1
            MOVB r4,r4_1
              
            MOVB n,n_1
              
            MOVB k0,k0_1
            MOVB k1,k1_1
            MOVB k2,k2_1
            MOVB k3,k3_1
            MOVB k4,k4_1
              
            MOVB e,e_1
            
            JSR updateDisp

            BCLR flag1,#BIT0                        ;updateDisp clears the Shift annunciator, so clear 
            BCLR flag1,#BIT1                        ;corresponding shift flags	   

            JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;comr subroutine
comr:       CLR r4                           ;determine mask
            CLR r3
            CLR r2
            CLR r1
            CLR r0

            MOVB m,counter

pneg_3:     SEC

            ROL r0
	          ROL r1
            ROL r2
            ROL r3
            ROL r4

            DEC counter
            BNE pneg_3

            COM s0                            ;determine COM r, set all other values to 0 using mask
	          COM s1
            COM s2
            COM s3
            COM s4

            LDAA s0
            ANDA r0
            STAA s0
            LDAA s1
            ANDA r1
            STAA s1
            LDAA s2
            ANDA r2
            STAA s2
            LDAA s3
            ANDA r3
            STAA s3
            LDAA s4
            ANDA r4
            STAA s4

            RTS
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end comr subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;update r subroutine
updater:    MOVB s0, r0
            MOVB s1, r1
            MOVB s2, r2
            MOVB s3, r3
            MOVB s4, r4
            
            RTS
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end update r subroutine
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;update k subroutine
updatek:    CLR r4                              ;determine mask
            CLR r3
            CLR r2
            CLR r1
            CLR r0

            MOVB n,counter

updatek_1:  SEC                                  ;set carry

            ROL r0
	          ROL r1
            ROL r2
            ROL r3
            ROL r4

            DEC counter
            BNE updatek_1
            
            CLRA                                 ;negate k
            SUBA k0
            STAA k0
            
            LDAA #$00
            SBCA k1
            STAA k1
            
            LDAA #$00
            SBCA k2
            STAA k2
            
            LDAA #$00
            SBCA k3
            STAA k3
            
            LDAA #$00
            SBCA k4
            STAA k4
            
            LDAA k0                               ;set appropriate bits to 0 using mask
            ANDA r0
            STAA k0
            LDAA k1
            ANDA r1
            STAA k1
            LDAA k2
            ANDA r2
            STAA k2
            LDAA k3
            ANDA r3
            STAA k3
            LDAA k4
            ANDA r4
            STAA k4
            
            RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end update k subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key2S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key3S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key4S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key5S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key6S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key7S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key8S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key9S:        NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key10S:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key11S:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key12S:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key13S:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key14S:       BSET flag2,#BIT6                         ;set DEC mode flag

              JSR updateDisp
            
              BCLR flag1,#BIT0                         ;updateDisp clears the Shift 1 annunciator,so clear
              BCLR flag1,#BIT1                         ;corresponding shift flags

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key15S:       BCLR flag2,#BIT6                         ;set 2-adic mode flag

              JSR updateDisp
            
              BCLR flag1,#BIT0                         ;updateDisp clears the Shift 1 annunciator,so clear
              BCLR flag1,#BIT1                         ;corresponding shift flags

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key0S2:       NOP                                      ;

              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

key1S2:       NOP
                                                       
              JMP tofISR_7
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key2S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key3S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key4S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key5S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key6S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key7S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key8S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key9S2:       NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key10S2:      NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key11S2:      NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key12S2:      NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key13S2:      NOP

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key14S2:      NOP                        

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

key15S2:      NOP                         

              JMP tofISR_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of key subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;colScan subroutine                                                            

colScan:        BRCLR PTP,#BIT4,gotKey        

                INC keyNumber
                BRCLR PTP,#BIT5,gotKey
                
                INC keyNumber
                BRCLR PTP,#BIT6,gotKey
                
                INC keyNumber
                BRCLR PTP,#BIT7,gotKey

                INC keyNumber

                BRA colScan_1               

gotKey:         BSET flag1,#BIT5

colScan_1:      RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of colScan subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dispZero subroutine

dispZero:       LDX #Digit      

                MOVB #$06,col_Counter      ;six columns
					    
					      JSR sendData   

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of dispZero subroutine 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dispOne subroutine

dispOne:        LDX #Digit
                LDAB #$06
                ABX     

                MOVB #$06,col_Counter      ;six columns
					    
					      JSR sendData

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of dispOne subroutine 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dispApos subroutine

dispApos:       LDX #Apos      

                MOVB #$06,col_Counter      ;six columns
					    
					      JSR sendData

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of dispApos subroutine 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;rSet subroutine

rSet:           ROL r0
                ROL r1
                ROL r2
                ROL r3
                ROL r4
                
                INC m                          

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of rSet subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;kSet subroutine

kSet:           ROL k0
                ROL k1
                ROL k2
                ROL k3
                ROL k4
                
                INC n 

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of kSet subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;gcd subroutine

gcd:            NOP

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of gcd subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;reduced subroutine

reduced:        NOP

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of reduced subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dispReduced subroutine

dispReduced:    NOP

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of dispReduced subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;start of setY subroutine

setY:           BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

                LDAA savedY
                ASRA
                ASRA
                ASRA
                ASRA
                ANDA #$0F
                ADDA #$10   
              
					      JSR sendByte               ;set MSN of column address
					      
					      LDAA savedY
                ANDA #$0F
                
                JSR sendByte               ;set LSN of column address					      
					      
					      BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data
					      
					      RTS
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of setY subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;start of dispPart subroutine

dispPart:      MOVB n,counter

dispPart_1:    JSR setY

               LDAA savedY                ;update savedY
					     SUBA #$06
					     STAA savedY
					      
               LDX #Digit                 ;zero
               ROR k4
               ROR k3
               ROR k2
               ROR k1
               ROR k0
               
               BCC dispPart_2
               
               LDAB #$06
               ABX                        ;add 6 to #Digit (one) 
               
dispPart_2:    MOVB #$06,col_Counter      ;six columns    
               JSR sendData
               DEC counter
               BNE dispPart_1
               
               RTS
               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of dispPart subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;convert subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;copy r to s
convert:    MOVB r0, s0
            MOVB r1, s1
            MOVB r2, s2
            MOVB r3, s3
            MOVB r4, s4
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;copy k to l
            MOVB k0, l0
            MOVB k1, l1
            MOVB k2, l2
            MOVB k3, l3
            MOVB k4, l4
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;shift k m bits to the left,result in l

            MOVB m,counter
            
convert_1:  ASL l0
            ROL l1
            ROL l2
            ROL l3
            ROL l4
            
            DEC counter
            BNE convert_1
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;subtract k from l,result in l
            LDAA l0
            SUBA k0
            STAA l0

            LDAA l1
            SBCA k1
            STAA l1

            LDAA l2
            SBCA k2
            STAA l2

            LDAA l3
            SBCA k3
            STAA l3

            LDAA l4
            SBCA k4
            STAA l4
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;shift r n bits to the left,result in s

            MOVB n,counter

convert_2:  ASL s0
            ROL s1
            ROL s2
            ROL s3
            ROL s4

            DEC counter
            BNE convert_2
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;subtract s from l,result in l (numerator)
            LDAA l0
            SUBA s0
            STAA l0

            LDAA l1
            SBCA s1
            STAA l1

            LDAA l2
            SBCA s2
            STAA l2

            LDAA l3
            SBCA s3
            STAA l3

            LDAA l4
            SBCA s4
            STAA l4
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;determine denominator and store in s

            MOVB #$01,s0
            CLR s1
            CLR s2
            CLR s3
            CLR s4
            
            MOVB m,counter
            
convert_3:  ASL s0
            ROL s1
            ROL s2
            ROL s3
            ROL s4
            
            DEC counter
            BNE convert_3
            
            LDAA s0
            SUBA #$01
            STAA s0
            
            LDAA s1
            SBCA #$00
            STAA s1
            
            LDAA s2
            SBCA #$00
            STAA s2
            
            LDAA s3
            SBCA #$00
            STAA s3
            
            LDAA s4
            SBCA #$00
            STAA s4
            
            RTS
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of convert subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dispInt subroutine

dispInt:        BCLR flag2,#BIT4                              ;clear signFlag 
                	
                BSET flag1,#BIT7                              ;set firstFlag 

                LDAA r4
                BPL dispInt_1                                 ;if A (r4) is positive (MSB = 0) branch to dispInt_1
                
                CLRA                                          ;otherwise negate r
                SUBA r0
                STAA r0
                
                LDAA #$00
                SBCA r1
                STAA r1
                
                LDAA #$00
                SBCA r2
                STAA r2
                
                LDAA #$00
                SBCA r3
                STAA r3
                
                LDAA #$00
                SBCA r4
                STAA r4
                 
							  BSET flag2,#BIT4                       ;set signFlag							

dispInt_1:      MOVB #$00,s4
                MOVB #$05,s3                           ;#0x0005F5E100 = 100,000,000 
                MOVB #$F5,s2
                MOVB #$E1,s1
                MOVB #$00,s0
								
                JSR nest
                
                MOVB #$00,s4
                MOVB #$00,s3                           ;#0x0000989680 = 10,000,000
                MOVB #$98,s2
                MOVB #$96,s1
                MOVB #$80,s0

                JSR nest
                
                MOVB #$00,s4
                MOVB #$00,s3                           ;#0x00000F4240 = 1,000,000
                MOVB #$0F,s2
                MOVB #$42,s1
                MOVB #$40,s0

                JSR nest
                
                MOVB #$00,s4
                MOVB #$00,s3                           ;#0x00000186A0 = 100,000
                MOVB #$01,s2
                MOVB #$86,s1
                MOVB #$A0,s0

                JSR nest 
                
                MOVB #$00,s4
                MOVB #$00,s3                           ;#0x0000002710 = 10,000
                MOVB #$00,s2
                MOVB #$27,s1
                MOVB #$10,s0

                JSR nest
                
                MOVB #$00,s4
                MOVB #$00,s3                           ;#0x00000003E8 = 1,000
                MOVB #$00,s2
                MOVB #$03,s1
                MOVB #$E8,s0

                JSR nest 
                
                MOVB #$00,s4
                MOVB #$00,s3                           ;#0x0000000064 = 100
                MOVB #$00,s2
                MOVB #$00,s1
                MOVB #$64,s0

                JSR nest
                
                MOVB #$00,s4
                MOVB #$00,s3                           ;#0x0000000A = 10
                MOVB #$00,s2
                MOVB #$00,s1
                MOVB #$0A,s0

                JSR nest          

							  LDAA r0                                ;display the value of r0
                
                LDAB #$06
                MUL
                
                LDX #Digit
                ABX 
                
                MOVB #$06,col_Counter                  ;six columns
                JSR sendData
                
							  BRCLR flag2,#BIT4,dispInt_2            ;if value is positive exit,otherwise...
								
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                BCLR PORTD,#BIT7                       ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command

							  LDAA savedY                            ;savedY = savedY - 6
							  SUBA #$06
							  STAA savedY
							
								JSR setY               

                BSET PORTD,#BIT7                       ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data

                LDX #Minus
                
                MOVB #$06,col_Counter                  ;six columns
                
                JSR sendData                           ;display "-"                																							

dispInt_2:      RTS                                   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of dispInt subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nest subroutine 

nest:           CLR counter                            ;counter = index for the number of times value is subtracted            
            
nest_1:         LDAA r0                                ;subtract power of ten
                SUBA s0
                STAA r0
                
                LDAA r1
                SBCA s1
                STAA r1
                
                LDAA r2
                SBCA s2
                STAA r2
                
                LDAA r3
                SBCA s3
                STAA r3
                
                LDAA r4
                SBCA s4
                STAA r4               

                BCS recover                             ;if too much subtracted add it back

                INC counter
                jmp nest_1
								
recover:        LDAA r0
                ADDA s0
                STAA r0
                
                LDAA r1
                ADCA s1
                STAA r1
                
                LDAA r2
                ADCA s2
                STAA r2
                
                LDAA r3
                ADCA s3
                STAA r3
                
                LDAA r4
                ADCA s4
                STAA r4

                LDAA counter                           ;load the value of the digit into A

                BRCLR flag1,#BIT7,nest_2               ;display the value if this is not the first digit
								
                BEQ nest_3                             ;if the first digit is zero (A=0 -> Z=1) add 6 to savedY,set Y and exit,
								                                       ;otherwise display the digit						

nest_2:         LDAB #$06
                MUL                                    ;D = A x B to determine offset
                
                LDX #Digit
                ABX                                    ;X = #Digit + B
                
                MOVB #$06,col_Counter                  ;six columns 
                                
                JSR sendData
								
                BCLR flag1,#BIT7                       ;clear firstFlag
								
                BRA nest_4 
								               
nest_3:         LDAA savedY                            ;add 6 to savedY
                ADDA #$06
                STAA savedY
                
                JSR setY								             

nest_4:         RTS

;end of nest subroutine;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;shiftKey subroutine

shiftKey:       INC shifttest

                LDD #$FFFF

shiftDelay1:    SUBD #$0001                                  ;debounce

                BNE shiftDelay1      

                LDX #clrShiftDisp       

                BRSET flag1,#BIT2,shift2Key                  ;shift2 key was pressed

                BCLR flag1,#BIT0                             ;otherwise clear shift1KeyPressed?      

                BRSET flag1,#BIT1,shift1KeyC                 ;clear shift1KeyFlag if it is set 
                
                BSET flag1,#BIT1                             ;otherwise set shift1KeyFlag
                
                LDX #setShift1Disp                           ;display "Shift 1"
                
                BRA dispShift                
                
shift1KeyC:     BCLR flag1,#BIT1                             ;clear shift1KeyFlag 
                
                BRA dispShift

shift2Key:      BCLR flag1,#BIT2                             ;clear shift2KeyPressed?      

                BRSET flag1,#BIT3,shift2KeyC                 ;clear shift2KeyFlag if it is set 
                
                BSET flag1,#BIT3                             ;otherwise set shift2KeyFlag
                
                LDX #setShift2Disp                           ;display "Shift 2"
                
                BRA dispShift

shift2KeyC:     BCLR flag1,#BIT3                              ;clear shift2KeyFlag
                
dispShift:      MOVB Ycoord,savedY 

                BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command
              
                LDAA #$B4                  ;A = 1011 0100 -> page 0 (due to bug on GLCD?) 
                JSR sendByte               ;set the page
              
                LDAA #$07                   
                JSR sendByte               ;set LSN of column address to 7
              
                LDAA #$15                   
                JSR sendByte               ;set MSN of column address to 5 (57H = 87)
							
					  	  BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data
					  	
					  	  MOVB #$2A,col_Counter      ;col_Counter = 42,index for number of columns set

                JSR sendData               ;display/clear "Shift 1/2"
                
                MOVB savedY,Ycoord         ;return cursor to previous position

						    BCLR PORTD,#BIT7           ;PORTD = 0xxx xxxx,PD7 = A0 = 0,send command
						  
						    LDAA #$B1                  ;A = 1011 0001 -> page 5 (due to bug on GLCD?) 
                JSR sendByte               ;set the page
								
                JSR setY
								
							  BSET PORTD,#BIT7           ;PORTD = 1xxx xxxx,PD7 = A0 = 1,send data 							           

 shiftKeyExit:  BSET flag1,#BIT4           ;set keyPressed?  
 
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of shiftKey subroutine   

;**************************************************************
;*                       Interrupts                           *
;**************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TIMER ISR to scan keypad

tofISR:       CLRA                       ;accumulator A = #0x00
              STAA  TSCR1                ;TSCR1 = A = 0000 0000,timer disabled (TSCR1@0x0046,p1234)
              
              BSET  TFLG2,#BIT7          ;TFLG2 orl #0x80 to set TFLG2.7 = TOF to clear the timer overflow flag (TOF) (TFLG2@0x004F,p1234)

;check if the shift keys are being processed and update variables and the display accordingly

              BRSET PTP,#BIT3,shift1NP   ;shift1 key not pressed -> check shift2 key
              
              BSET flag1,#BIT0           ;otherwise set flag1.0 (shift1KeyPressed?) and JSR shiftKey								                         
								                         
							JSR shiftKey               
							
shift1NP:     BRSET PTP,#BIT2,tofISR_2   ;shift2 key not pressed -> scan keypad

              BSET flag1,#BIT2           ;otherwise set flag1.2 (shift2KeyPressed?) and JSR shiftKey 								                         
								                         
						  JSR shiftKey
						  
;scan the keypad

tofISR_2:     BCLR PT1AD,#BIT0           ;clear all four keypad rows
              BCLR PT1AD,#BIT1
              BCLR PT1AD,#BIT2
              BCLR PT1AD,#BIT3
              
              LDAA PTP
              COMA
              ANDA #$F0
              BEQ releaseKey             ;if keypad not pressed (A=0) check that shift keys have been released
                                         ;and exit interrupt  
              
              JSR key                    ;otherwise scan keypad           
              
;wait for key to be released                           
              
releaseKey:   BCLR PT1AD,#BIT0           ;clear all four keypad rows
              BCLR PT1AD,#BIT1
              BCLR PT1AD,#BIT2
              BCLR PT1AD,#BIT3
              
releaseKey_1: BRCLR flag1,#BIT4,exitInt  ;if no key was pressed,exit interrupt
              LDAA PTP
              COMA
              BNE releaseKey_1           ;if any key is pressed (A<>0) branch to releaseKey_1               
              
exitInt:      LDD #$FFFF           

shiftDelay2:  SUBD #$0001                ;debounce

              BNE shiftDelay2       

              MOVB #$80,TSCR1            ;TSCR1 = A = 1000 0000,timer enabled (TSCR1@0x0046,p1234)

              BCLR flag1,#BIT4           ;clear keyPressed?

              RTI
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end TIMER ISR


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;RTI ISR to blink cursor

rtiISR:       COM col_Value              ;invert col_Value
					    LDAA col_Value
					    
					    MOVB #$06,col_Counter      ;col_Counter = 6,index for number of columns set		    
					     
rtiISR_1:     JSR sendByte               ;set/clear the column (does not affect Ycoord)

              DEC col_Counter            ;decrement col_Counter
              BNE rtiISR_1               ;jump to rtiISR_1 if col_Counter is not zero (i.e. if Z = 0)
              
              MOVB Ycoord,savedY
					    
					    JSR setY                   ;reset Y to Ycoord		            
              
              BSET CPMUFLG,#BIT7         ;clear RTIF
              
              RTI
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end RTI ISR

;constant data section
              ORG CONSTANTStart
              
stackLevels   DC.B $FF, $E7, $EB, $ED, $80, $EF               ;4 inverted 
              DC.B $FF, $DE, $BE, $BA, $B4, $CE               ;3 inverted
              DC.B $FF, $BD, $9E, $AE, $B6, $B9               ;2 inverted
              DC.B $FF, $FF, $BD, $80, $BF, $FF               ;1 inverted 
              
setShift1Disp DC.B $00, $46, $49, $49, $49, $31               ;S
              DC.B $00, $7F, $08, $04, $04, $78               ;h
              DC.B $00, $00, $44, $7D, $40, $00               ;i
              DC.B $00, $08, $7E, $09, $01, $02               ;f
              DC.B $00, $04, $3F, $44, $40, $20               ;t
					  	DC.B $00, $00, $00, $00, $00, $00 
              DC.B $00, $00, $42, $7F, $40, $00               ;1 
              
setShift2Disp DC.B $00, $46, $49, $49, $49, $31               ;S
              DC.B $00, $7F, $08, $04, $04, $78               ;h
              DC.B $00, $00, $44, $7D, $40, $00               ;i
              DC.B $00, $08, $7E, $09, $01, $02               ;f
              DC.B $00, $04, $3F, $44, $40, $20               ;t
					  	DC.B $00, $00, $00, $00, $00, $00 
              DC.B $00, $42, $61, $51, $49, $46               ;2
              
clrShiftDisp  DC.B $00, $00, $00, $00, $00, $00 
              DC.B $00, $00, $00, $00, $00, $00 
              DC.B $00, $00, $00, $00, $00, $00 
              DC.B $00, $00, $00, $00, $00, $00  
              DC.B $00, $00, $00, $00, $00, $00 
              DC.B $00, $00, $00, $00, $00, $00
							DC.B $00, $00, $00, $00, $00, $00
							
Digit         DC.B $00, $3E, $51, $49, $45, $3E               ;0
              DC.B $00, $00, $42, $7F, $40, $00               ;1
              DC.B $00, $42, $61, $51, $49, $46               ;2
              DC.B $00, $21, $41, $45, $4B, $31               ;3
              DC.B $00, $18, $14, $12, $7F, $10               ;4
              DC.B $00, $27, $45, $45, $45, $39               ;5
              DC.B $00, $3C, $4A, $49, $49, $30               ;6
              DC.B $00, $01, $71, $09, $05, $03               ;7
              DC.B $00, $36, $49, $49, $49, $36               ;8
              DC.B $00, $06, $49, $49, $29, $1E               ;9 

Apos          DC.B $00, $00, $05, $03, $00, $00               ;apostrophe
Soli          DC.B $00, $20, $10, $08, $04, $02               ;/
Minus         DC.B $00, $08, $08, $08, $08, $08               ;-

Tadic         DC.B $00, $42, $61, $51, $49, $46               ;2
              DC.B $00, $08, $08, $08, $08, $08               ;-
              DC.B $00, $20, $54, $54, $54, $78               ;a
              DC.B $00, $38, $44, $44, $48, $7F               ;d
              DC.B $00, $00, $44, $7D, $40, $00               ;i
              DC.B $00, $38, $44, $44, $44, $20               ;c
              
Deci          DC.B $00, $7F, $41, $41, $22, $1C               ;D
              DC.B $00, $38, $54, $54, $54, $18               ;e
              DC.B $00, $38, $44, $44, $44, $20               ;c

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************

             ORG $FFDE
             DC.W tofISR                 ;TIMER Vector
             
             ORG $FFF0
             DC.W rtiISR                 ;RTI Vector
             
             ORG $FFFE
             DC.W  entry                 ;Reset Vector
