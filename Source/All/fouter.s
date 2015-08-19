#ifndef FOUTER_COMPILED
#define FOUTER_COMPILED
;###############################################################################
;# S12CForth - FOUTER - Forth outer interpreter                                #
;###############################################################################
;#    Copyright 2011-2015 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
;#    family.                                                                  #
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
;#    This module implements the outer interpreter of the S12CForth            #
;#    environment.                                                             #
;#                                                                             #
;#    The outer interpreter implements these registers:                        #
;#          STATE = Compilation (>0) or interpretation (=0) state              #
;#     NUMBER_TIB = Number of chars in the TIB                                 #
;#          TO_IN = In-pointer of the TIB (>IN)	       			       #
;#       	    (TIB_START+TO_IN) points to the next character	       #
;#  									       #
;#    Program termination options:                                             #
;#        ABORT:   Restart outer interpreter                                   #
;#        QUIT:    Restart outer interpreter                                   #
;#        SUSPEND: Restart outer interpreter                                   #
;#                                                                             #
;#        Compile mode if STATE != 0                                           #
;#        SUSPEND mode if    IP != 0                                           #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 5, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FINNER - Forth inner interpreter                                         #
;#    FIO    - Forth communication interface                                   #
;#    FRS    - Forth return stack                                              #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
;#    FINNER - Forth inner interpreter                                         #
;#    FIO    - Forth communication interface                                   #
;#    FEXCPT - Forth Exception Handler                                         #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;        
;                         +--------------+--------------+        
;        RS_TIB_START, -> |              |              |
;           TIB_START     |              |              | <- [TIB_OFFSET]          
;                         |              |              | |          
;                         |       Text Input Buffer     | | [NUMBER_TIB]
;                         |              |              | |	       
;                         |              v              | |	       
;                     -+- | --- --- --- --- --- --- --- | v	       
;          TIB_PADDING |  .                             . <- [TIB_OFFSET+NUMBER_TIB] 
;                     -+- .                             .            
;                         | --- --- --- --- --- --- --- |            
;                         |              ^              | <- [RSP]
;                         |              |              |
;                         |        Return Stack         |
;                         |              |              |
;                         +--------------+--------------+
;             RS_EMPTY, ->                                 
;           RS_TIB_END
;
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Safety distance to return stack
;------------------------------- 
#ifndef TIB_PADDING
TIB_PADDING		EQU	4 		;default is 4 bytes
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;STATE variable 
STATE_INTERPRET		EQU	FALSE
STATE_COMPILE		EQU	TRUE

;Text input buffer 
TIB_START		EQU	RS_TIB_START

;Default line width 
DEFAULT_LINE_WIDTH	EQU	80

;ASCII C0 codes 
FOUTER_SYM_LF  		EQU	STRING_SYM_LF
FOUTER_SYM_CR  		EQU	STRING_SYM_CR
FOUTER_SYM_BACKSPACE  	EQU	STRING_SYM_BACKSPACE
FOUTER_SYM_DEL  	EQU	STRING_SYM_DEL
FOUTER_SYM_TAB  	EQU	STRING_SYM_TAB
FOUTER_SYM_BELL  	EQU	STRING_SYM_BELL
FOUTER_SYM_SPACE  	EQU	STRING_SYM_SPACE
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FOUTER_VARS_START_LIN
			ORG 	FOUTER_VARS_START, FOUTER_VARS_START_LIN
#else
			ORG 	FOUTER_VARS_START
FOUTER_VARS_START_LIN	EQU	@
#endif	
			ALIGN	1	
STATE			DS	2 		;interpreter state (0:iterpreter, -1:compile)
NUMBER_TIB  		DS	2		;number of chars in the TIB
TO_IN  			DS	2		;parse index (TIB_START+TO_IN -> start of parse area)
	
FOUTER_VARS_END		EQU	*
FOUTER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;===============
#macro	FOUTER_INIT, 0
			MOVW	#$0000, NUMBER_TIB	;empty TIB
			MOVW	#$0000, TO_IN		;reset parser
#emac

;#Abort action (to be executed in addition of QUIT action)
#macro	FOUTER_ABORT, 0
			MOVW	#$0000, NUMBER_TIB	;empty TIB
			MOVW	#$0000, TO_IN		;reset parser
#emac
	
;#Quit action (to be executed in addition of SUSPEND action)
#macro	FOUTER_QUIT, 0
#emac
	
;#Suspend action
#macro	FOUTER_SUSPEND, 0
#emac

;Functions:
;==========
;#Assemble prompt in TIB
; args:   none
; result: none
; SSTACK: none
;         X is  preserved
#macro FOUTER_PROMPT, 0
			;Initialize TIB pointer
			LDY	TIB_START
			;Add line break (string pointer in Y)
			STRING_MOVE_NL_NONTERM STRING_NL_BYTE_COUNT,Y+
			;Check for unparsed command line (string pointer in Y)
			CLRA				;ignore whitespace in TIB
			FOUTER_SKIP_DELIMITER		;
			BCC	FOUTER_PROMPT_1		;TIB was empty
			MOVB	#"!", 1,Y+		;add warn prompt
FOUTER_PROMPT_1		MOVW	#$0000, NUMBER_TIB	;empty TIB
			MOVW	#$0000, TO_IN		;reset parser
			;Check for SUSPEND mode(string pointer in Y)
			LDD	IP			;check IP
			BEQ	FOUTER_PROMPT_2
			MOVB	#"S", 1,Y+		;add SUSPEND prompt
			;Check for interactive prompt(string pointer in Y)
FOUTER_PROMPT_2		LDD	STATE 			;check STATE
			BNE	FOUTER_PROMPT_3		;compile state
			MOVB	#">", 1,Y+		;add interactive prompt
			JOB	FOUTER_PROMPT_5		;print whitespace
			;Determine compile prompt (string pointer in Y)
FOUTER_PROMPT_3		EQU	*			
#ifdef	NVC
			LDD	NVC 			;check check for NV compile
			BEQ	FOUTER_PROMPT_4		;RAM compile
			MOVB	#"@", 1,Y+		;add NV compile prompt
			JOB	FOUTER_PROMPT_5		;print whitespace
#endif
FOUTER_PROMPT_4		MOVB	#"+", 1,Y+		;add NV compile prompt			
			;Print whitespace (string pointer in Y)
FOUTER_PROMPT_5		MOVB	#(STRING_SYM_SPACE|STRING_TERM), 1,Y+;add NV compile prompt
#emac

;#Check if a char is a delimiter 
; args:   A:      delimiter (0=any whitespace)
;         B:      char
; result: Z-flag: set if char is a delimiter
; SSTACK: 0 bytes
;         All registers preserved
#macro	FOUTER_CHECK_DELIMITER, 0
			TBNE	A, CUSTOM_DELIMITER  	;custom delimiter
			CMPB	FOUTER_SYM_SPACE	;" "
			BEQ	DONE
			CMPB	FOUTER_SYM_TAB		;tab
			JOB	DONE
CUSTOM_DELIMITER	CBA				;custom
DONE			EQU	*
#emac

;#Check if parse area is exceeded
; args:   Y:      >IN	
;         #TIB:   char count in TIB
; result: C-flag: !=no overrun, 0=overrun
;	  Y:      cleared on overrun, otherwise unchanged
;         #TIB:   cleared on overrun, otherwise unchanged
; SSTACK: 0 bytes
;         D and X are preserved
#macro	FOUTER_CHECK_OVERRUN, 0
			CPY	NUMBER_TIB		;check for parse overrun
			BLO	DONE			;parse overrun
			LDY	#$0000
			STY	NUMBER_TIB
DONE			EQU	*
#emac
	
;#Skip delimiter in TIB 
; args:   A:      delimiter (0=any whitespace)
;         #TIB:   char count in TIB
;         >IN:    TIB parse index
; result: Y:      new >IN
;	  B:      next char in TIB
;         C-flag: set if TIB contains parsable content 
;         #TIB:   new char count in TIB
;         >IN:    new TIB parse index
; SSTACK: 2 bytes
;         A and X are preserved
#macro	FOUTER_SKIP_DELIMITER, 0
			SSTACK_JOBSR	FOUTER_SKIP_DELIMITER, 2
#emac

;#Count and Terminate string at >IN
; args:   A:      delimiter (0=any whitespace)
;         Y:      >IN	
;         #TIB:   char count in TIB
;         >IN:    parse index (points to a non-delimiter within the parse area)
; result: D:      char count
;	  X:      string pointer
;	  Y:      new >IN 
;         #TIB:   cleared on overrun, otherwise unchanged
;         >IN:    cleared on overrun, otherwise new >IN
; SSTACK: 0 bytes
;         A and X are preserved
#macro	FOUTER_COUNT_AND_TERMINATE, 0
			;Find end of word (delimiter in A, parse index in Y)
LOOP			TFR	Y, X 			;save parse index
			LEAX	1,X			;advance parse index
			FOUTER_CHECK_OVERRUN 		;check for parse overrun
			BCC	END_OF_WORD		;parse overrun
			LDAB	TIB_START,Y		;get next char
			ANDB	#~STRING_TERM		;remove termination
			STAB	TIB_START,Y		;update char	
			FOUTER_CHECK_DELIMITER		;check for whitespace
			BNE	LOOP			;non-delimiter
			;End of word found (index of last char in X, new parse index in Y) 
END_OF_WORD		BSET	TIB_START,X,#STRING_TERM;terminate string
			TFR	X, D			;calculate char count
			SUBD	TO_IN			;char count -> D
			LDX	TO_IN			;determine string pointer
			LEAX	TIB_START,X		;string pointer -> X
			STY	TO_IN			;update >IN
#emac
	
;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
; args:   A:   delimiter
;         #TIB: char count in TIB
;         >IN:  TIB parse index
; result: X:    string pointer
;	  D:    character count
;         >IN:  new TIB parse index
; SSTACK: 6 bytes
;         Y is preserved
#macro	FOUTER_PARSE, 0
			SSTACK_JOBSR	FOUTER_PARSE, 6
#emac

;#Find the next string (delimited by whitespace) on the TIB and terminate it. 
; args:   #TIB: char count in TIB
;         >IN:  TIB parse index
; result: X:    string pointer
;	  D:    character count
;         >IN:  new TIB parse index
; SSTACK: 6 bytes
;         Y is preserved
#macro	FOUTER_PARSE_WS, 0
			CLRA
			FOUTER_PARSE
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FOUTER_CODE_START_LIN
			ORG 	FOUTER_CODE_START, FOUTER_CODE_START_LIN
#else
			ORG 	FOUTER_CODE_START
FOUTER_CODE_START_LIN	EQU	@
#endif

;#Skip delimiter in TIB 
; args:   A:      delimiter (0=any whitespace)
;         #TIB:   char count in TIB
;         >IN:    TIB parse index
; result: Y:      new >IN
;	  B:      next char in TIB
;         C-flag: set if TIB contains parsable content 
;         #TIB:   new char count in TIB
;         >IN:    new TIB parse index
; SSTACK: 2 bytes
;         A and X are preserved
FOUTER_SKIP_DELIMITER	EQU	*
			;Skip delimiter chars 
			LDY	TO_IN 			;read parse pointer
			SSTACK_PREPULL	2		;check SSTACK
FOUTER_SKIP_DELIMITER_1	FOUTER_CHECK_OVERRUN		;check for parse overrun
			STY	TO_IN			;update >IN
			BCC	FOUTER_SKIP_DELIMITER_2	;parse overrun
			LDAB	TIB_START,Y		;check next char
			ANDB	#~STRING_TERM		;remove termination
			LEAY	1,Y			;advance parse pointer
			FOUTER_CHECK_DELIMITER		;check for delimiter
			BEQ	FOUTER_SKIP_DELIMITER_1	;delimiter found
			;Flag parsable content and done 
			SEC
FOUTER_SKIP_DELIMITER_2	RTS
		
;#Find the next string (delimited by a selectable character) on the TIB and terminate it. 
; args:   A:    delimiter (0=any whitespace)
;         #TIB: char count in TIB
;         >IN:  TIB parse index
; result: X:    string pointer
;	  D:    character count	
;         #TIB:   new char count in TIB
;         >IN:  new TIB parseindex
; SSTACK: 6 bytes
;         Y is preserved
FOUTER_PARSE		EQU	*	
			;Save registers
			PSHY				;save Y
			;Skip over delimiters (delimiter in A)
			FOUTER_SKIP_DELIMITER  		;skip over delimiters
			BCC	FOUTER_PARSE_2		;TIB is empty
			;Count chars and terminate word (delimiter in A, >IN in Y)
			FOUTER_COUNT_AND_TERMINATE
			;Retore registers 
			SSTACK_PREPULL	4		;check SSTACK
			PULY				;restore Y
			;Done
			RTS

;#Look-up word in dictionaries 
; args:   X:      string pointer (terminated string)
; result: Y:      new >IN
;	  B:      next char in TIB
;         C-flag: set if TIB contains parsable content 
;         #TIB:   new char count in TIB
;         >IN:    new TIB parse index
; SSTACK: 2 bytes
;         A and X are preserved








	
	
;Code fields:
;============

;QUERY ( -- ) Query command line input
;Make the user input device the input source. Receive input into the terminal
;input buffer,mreplacing any previous contents. Make the result, whose address is
;returned by TIB, the input buffer.  Set >IN to zero.
; args:   none
; result: #TIB: char count in TIB
;         >IN:  index pointing to the start of the TIB => 0x0000
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_QUERY		EQU	*
			;Reset input buffer
			MOVW	#0000, NUMBER_TIB 	;zero chars in TIB
			MOVW	#0000, TO_IN		;parse area to start of TIB
			;Receive input
CF_QUERY_1		EXEC_CF	CF_EKEY			;input char -> [PS+0]
			;Get input (input char in [PS+0])
			LDD	[PSP] 			;input char -> B
			;Ignore LF (input char in B)
			CMPB	#FOUTER_SYM_LF
			BEQ	CF_QUERY_4		;ignore
			;Check for ENTER (CR) (input char in B and in [PS+0])
			CMPB	#FOUTER_SYM_CR	
			BEQ	CF_QUERY_8		;command line complete		
			;Check for BACKSPACE (input char in B and in [PS+0])
			CMPB	#FOUTER_SYM_BACKSPACE	
			BEQ	CF_QUERY_7	 	;backspace
			CMPB	#FOUTER_SYM_DEL	
			BEQ	CF_QUERY_7	 	;backspace
			;Check for valid special characters (input char in B and in [PS+0])
			CMPB	#FOUTER_SYM_TAB	
			BEQ	CF_QUERY_2	 	;echo and append to buffer
			;Check for invalid characters (input char in B and in [PS+0])
			CMPB	#" " 			;first legal character in ASCII table
			BLO	CF_QUERY_5		;beep
			CMPB	#"~"			;last legal character in ASCII table
			BHI	CF_QUERY_5 		;beep			
			;Check for buffer overflow (input char in B and in [PS+0])
CF_QUERY_2		LDX	NUMBER_TIB 		;determine TIB size
			LEAX	(TIB_START+TIB_PADDING),X
			CPX	RSP
			BHS	CF_QUERY_5 		;beep
			;Append char to input line (input char in B and in [PS+0], TIB pointer+padding in X)
			STAB	-TIB_PADDING,X 		;append char
			LDX	NUMBER_TIB		;increment NUMBER_TIB
			LEAX	1,X
			STX	NUMBER_TIB			
			;Echo input char (input char in [PS+0])
CF_QUERY_3		EXEC_CF	CF_EMIT			;print character
			JOB	CF_QUERY_1
			;Ignore input char
CF_QUERY_4		LDY	PSP 			;drop char from PS
			LEAY	2,Y
			STY	PSP
			JOB	CF_QUERY_1
			;BEEP			
CF_QUERY_5		LDD	#FOUTER_SYM_BEEP	;replace received char by a beep
CF_QUERY_6		STD	[PSP]
			JOB	CF_QUERY_3 		;transmit beep
			;Check for buffer underflow (input char in [PS+0])
CF_QUERY_7		LDY	NUMBER_TIB 		;compare char count
			BEQ	CF_QUERY_5		;beep
			LDD	#STRING_SYM_BACKSPACE	;replace received char by a backspace
			JOB	CF_QUERY_6
			;Command line complete
CF_QUERY_8		LDY	PSP 			;drop char from PS
			LEAY	2,Y
			STY	PSP
			LDY	NUMBER_TIB 		;check char count
			BEQ	CF_QUERY_9 		;command line is empty
			LEAY	-1,Y			;terminate last character
			BSET	TIB_START,Y, #STRING_TERM
CF_QUERY_9		NEXT

;PARSE ( char "ccc<char>" -- c-addr u ) Parse the TIB
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
; args:   PSP+0: delimiter char (0=any whitespace)
; result: PSP+0: character count
;         PSP+2: string pointer
; SSTACK: 0 bytes
; PS:     2 cells
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_PARSE		EQU	*
			;Check PS
			PS_CHECK_UFOF	1, 1 		;check PSP
			STY	PSP			;new PSP -> Y
			;Parse next word (new PSP in Y) 
			LDAA	3,Y 			;delimiter -> A
			FOUTER_PARSE			;parse
			STX	2,Y			;return string pointer
			STD	0,Y			;return char count
			;Done
			NEXT

;FIND ( c-addr -- c-addr 0 |  xt 1 | xt -1 )  
;Find the definition named in the terminated string at c-addr. If the definition is
;not found, return c-addr and zero.  If the definition is found, return its
;execution token xt.  If the definition is immediate, also return one (1),
;otherwise also return minus-one (-1).  For a given string, the values returned
;by FIND while compiling may differ from those returned while not compiling. 
; args:   PSP+0: terminated string to match dictionary entry
; result: PSP+0: 1 if match is immediate, -1 if match is not immediate, 0 in
;         	 case of a mismatch
;  	  PSP+2: execution token on match, input string on mismatch
; SSTACK: 0 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_FIND			EQU	*
			;Check UDICT
			EXEC_CF	CF_UDICT_FIND 			;search UDICT
			;PS_CHECK_UF 2				;PSP -> Y
			LDY	PSP
			LDD	0,Y				;check result
			BNE	CF_FIND_1			;done
			LEAY	2,Y				;drop result flag
			STY	PSP
#ifdef NVC	
			;Check NVDICT
			EXEC_CF	CF_NVDICT_FIND 			;search NVDICT
			;PS_CHECK_UF 2				;PSP -> Y
			LDY	PSP
			LDD	0,Y				;check result
			BNE	CF_FIND_1			;done
			LEAY	2,Y				;drop result flag
			STY	PSP
#endif
			;Check CDICT
			EXEC_CF	CF_CDICT_FIND 			;search CDICT
			;Done
CF_FIND_1		NEXT

;PREFIX ( c-addr1 -- flag u c-addr2 )  
;Remove any number prefix from terminated string c-addr1. Return sign information
;flag (true if negative), base u and the remaining terminated string c-addr2. 
;PREFIX recognizes C and ASM prefix notations:
; args:   PSP+0: terminated string
; result: PSP+0: new terminated string
;         PSP+2: base
;         PSP+4: sign (true if negative)
; SSTACK: 0 bytes
; PS:     2 cells
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
;
CF_PREFIX		EQU	*
			;Check PS
			PS_CHECK_UFOF	1, 2 		;new PSP -> Y
			STY	PSP
			;Set default values (PSP in Y)
			LDX	4,Y 			;move string pointer
			STX	0,Y
			MOVW	BASE, 2,Y 		;set default base
			MOVW	#$0000, 4,Y		;positive by default
			;Check for sign (PSP in Y, string pointer in X)
			LDAB	0,X	  		;read forst char
			BMI	CF_PREFIX_ 		;string too short
			CMPA	"+"                     
			BEQ	CF_PREFIX_
	


;Empty the data stack and perform the function of QUIT, which includes emptying
;the return stack, without displaying a message. 
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_ABORT_RT		EQU	*
			;Execute ABORT actions
			FORTH_ABORT
			;Execute QUIT actions
			;JOB	CF_QUIT_RT

;QUIT run-time ( -- ) ( R: j*x -- )
;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;input device the input source, and enter interpretation state. Do not display a
;message. Repeat the following: 
; -Accept a line from the input source into the input buffer, set >IN to zero,
;  and interpret. 
; -Display the system prompt if in interpretation state,
;  all processing has been completed, and no ambiguous condition exists.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_QUIT_RT		EQU	*
			;Execute QUIT actions
			FORTH_QUIT
			;Execute SUSPEND actions
			;JOB	CF_SUSPEND_RT

;SUSPEND ( -- )
;Execute a temporary debug shell.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     0 cells
; RS:     5 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_SUSPEND_RT		EQU	*
			;Execute SUSPEND actions
			FORTH_SUSPEND
			;Start shell
			;JOB	CF_SHELL
	
;SHELL ( -- ) Generic interactive shell
;Common S12CForth shell. 
; args:   none
; result: none
; SSTACK: 22 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_SHELL		EQU	*
			;Print shell prompt
CF_SHELL_1		FOUTER_PROMPT 				;assemble prompt in TIB
			PS_PUSH	TIB_START			;print TIB
			EXEC_CF	CF_DOT_STRING
			;Query command line
			EXEC_CF	CF_QUERY 			;query command line
			;Parse command line
CF_SHELL_2		CLRA					;delimiter is any whitespace
			FOUTER_PARSE				;parse next word
			TBEQ	D, CF_SHELL_1			;no word found
			;Check parsed word (string pointer in X, char count in D) 

	

			PS_PUSH	#0 				;0=all whitespace
			EXEC_CF	CF_PARSE	
			;Check PARSE results
			PS_PULL_D 				;check char count
			TBEQ	D, CF_SHELL_2			;process input
			PS_DROP	1				;clean up PS
			JOB	CF_SHELL_1			;prompt for new input
			;Look-up string in dictionaries
CF_SHELL_2		EXEC_CF	CF_FIND
			PS_CHECK_UF 2				;PSP -> Y
			LDD	0,Y				;check result
			




	

			;Parse command line
CF_SHELL_5        	FOUTER_PARSE_WS
			TBEQ	D, CF_SHELL_1      	;parse next line



;			TBNE	D, CF_SHELL_7      	;parse next line
;			JOB	CF_SHELL_1
			;Search UDICT (string pointer in X, char count in D)
CF_SHELL_7		EQU	*	
#ifdef	NVC
			LDY	NVC	  		;ignore UDICT in NVCOMPILE mode
			BNE	CF_SHELL_8 		;skip UDICT search
#endif
;TBD			FUDICT_SEARCH	   		;search UDICT
;TBD			BCS	CF_SHELL_9		;process word	
CF_SHELL_8		EQU	*
#ifdef	NVC
			;Search NVDICT (string pointer in X, char count in D)
			FNVDICT_SEARCH
			BCS	CF_SHELL_9		;process word	
#endif
			;Search CDICT (string pointer in X, char count in D)
			FCDICT_SEARCH
			BCC	CF_SHELL_12		;evaluate string as integer	
			;Process word ({IMMEDIATE, CFA>>1} in D)
CF_SHELL_9		LSLD				;extract CFA
			BCS	CF_SHELL_10		;execute immediate word
			LDY	STATE			;check STATE
			BNE	CF_SHELL_11		;compile word	
			;Execute word (CFA in D)
CF_SHELL_10 		TFR	D, X
			EXEC_CFA_X
			JOB	CF_SHELL_6		;parse next word
			;Compile word (CFA in D)
CF_SHELL_11	;TBD	UDICT_COMPILE_WORD	 	;compile to UDICT or NVDICT buffer
			JOB	CF_SHELL_6		;parse next word
			;Evaluate string as integer (string pointer in X, char count in D) 
CF_SHELL_12		FOUTER_INTEGER	     		;(SSTACK: 22 bytes)
			DBNE	D, CF_SHELL_14 		;double cell integer
			;Process single cell integer (number in X)
			LDD	STATE			;check STATE
			BNE	CF_SHELL_13		;compile number as literal
			;Push single cell integer onto PS (number in X)
			PS_CHECK_OF	1 		;new PSP -> Y
			STY	PSP			;update PSP
			STX	0,Y	   		;push number onto PS
			JOB	CF_SHELL_6		;parse next word
			;Compile single cell integern integer as literal (number in X)
CF_SHELL_13	;TBD	UDICT_COMPILE_LIT	 	;compile to UDICT or NVDICT buffer
			JOB	CF_SHELL_6		;parse next word
			;Check for valid double cell integer (cell count-1 in D,  number in Y:X)
CF_SHELL_14		DBNE	D, CF_SHELL_16 		;invalid number
			;Process double number (number in Y:X)
			LDD	STATE			;check STATE
			BNE	CF_SHELL_15		;compile number as literal
			;Push double number onto PS (number in Y:X)
			TFR	Y, D
			PS_CHECK_OF	2 		;new PSP -> Y
			STY	PSP			;update PSP
			STD	0,Y			;push double number onto PS
			STX	2,Y
			JOB	CF_SHELL_4		;parse next word
			;Compile double number as literal (number in Y:X)
CF_SHELL_15	;TBD	UDICT_COMPILE_DLIT	 	;compile to UDICT or NVDICT buffer
			JOB	CF_SHELL_6		;parse next word
			;Unknown word (or number out of range)
CF_SHELL_16		THROW	 FEXCPT_EC_UDEFWORD
	




;RESUME ( -- )
;Resume from a temporary debug shell.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     2 cells
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_RSOF
;         FEXCPT_EC_COMERR
CF_RESUME		EQU	*
			;Check if SUSPEND_MARKER is already set
			LDX	SUSPEND_MARKER	
			TBNE	X, CF_RESUME_ 			;SUSPEND_MARKER is already set
			;Resore SUSPEND context	(SUSPEND_MARKER in X)
			RS_CHECK_UF 5				;check for underflow
			MOVW	2,X+, BASE			;restore conversion radix
			MOVW	2,X+, STATE			;restore compile state
			MOVW	2,X+, TO_IN			;restore parse index
			MOVW	2,X+, IP			;restore instruction pointer
			MOVW	2,X+, HANDLER			;restore exception handler
			MOVW	#$0000, SUSPEND_MARKER		;clear SUSPEND_MARKER	
			STX	RSP				;X -> RSP	
			;Restore TIB
			LDD	TIB_OFFSET			;restore char count
			SUBD	#TIB_START
			STD	NUMBER_TIB
			MOVW	#TIB_START,TIB_OFFSET		;reset TIB
			;Done
			NEXT


	

;>NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) 
;ud2 is the unsigned result of converting the characters within the string
;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;left-to-right until a character that is not convertible, including any "+" or
;"-", is encountered or the string is entirely converted. c-addr2 is the
;location of the first unconverted character or the first character past the end
;of the string if the string was entirely converted. u2 is the number of
;unconverted characters in the string. If ud2 overflows during the conversion,
;both result and conversion string are left untouched.	
; args:   PSP+0: character count
;         PSP+1: string pointer
;         PSP+2: initial number
; result: PSP+0: remaining character count
;         PSP+1: pointer to unconverted substring
;         PSP+2: resulting number
; SSTACK: 18 bytes
; PS:     none
; RS:     none
; throws: FEXCPT_EC_PSUF
CF_TO_NUMBER		EQU	*
			;Check PS
			PS_CHECK_UF	4 		;PSP -> Y			
			;Check SSTACK (PSP in Y)
			SSTACK_PREPUSH	18
			;Copy parameters from PS to SSTACK (PSP in Y)
			MOVW	6,Y, 2,SP- 		;number LSW
			MOVW	4,Y, 2,SP-		;number MSW
			MOVW	2,Y, 2,SP-		;string pointer
			MOVW	0,Y, 2,SP-		;char count
			;copy BASE to SSTACK (PSP in Y)
			FOUTER_FIX_BASE
			PSHD
			;Try to convert string to number  (PSP in Y)
			FOUTER_TO_NUMBER		;(SSTACK: 8 bytes)
			BCC	CF_TO_NUMBER_1		;numeric overflow
			;Copy parameters from SSTACK to PS (PSP in Y)
			SSTACK_PREPULL	10
			MOVW	2,SP, 0,Y 		;char count
			MOVW	4,SP, 2,Y 		;string pointer
			MOVW	6,SP, 4,Y 		;number MSW
			MOVW	8,SP, 6,Y 		;number LSW
			;Clean up SSTACK
CF_TO_NUMBER_1		LEAS	10,SP
			;Done
			NEXT
	
;INTEGER ( c-addr u -- d s | n 1 | 0) Interpret string as integer
;Interpret string as integer value and return a single or double cell number
;along with the cell count. If the interpretation was unsuccessful, return a
;FALSE flag
; args:   PSP+0: char count
;         PSP+1: string pointer
; result: PSP+0: cell count
;         PSP+1: double value
; or
;         PSP+0: cell count
;         PSP+1: single value
; or
;         PSP+0: false flag
; SSTACK: 22 bytes
; PS:     1 cell
; RS:     none
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_INTEGER		EQU	*
			;Check PS
			PS_CHECK_UFOF	2, 1 		;new PSP -> Y
			STY	PSP
			;Interpret string (PSP in Y)
			LDD	2,Y
			LDX	4,Y
			FOUTER_INTEGER			;(SSTACK: 22 bytes)
			STD	0,Y			;store cell count
			DBEQ	D, CF_INTEGER_4		;single cell
			DBNE	D, CF_INTEGER_2		;not an integer (done)
			;Double cell value (integer in Y:X) 
			TFR	Y, D
			LDY	PSP
			STD	2,Y
			STX	4,Y
			;Done
CF_INTEGER_1		NEXT
			;Not an integer 
CF_INTEGER_2		LDY	PSP
			MOVW	#$0000, 4,+Y
CF_INTEGER_3		STY	PSP
			JOB	CF_INTEGER_1 		;done
			;Single cell value (integer in X) 
CF_INTEGER_4		LDY	PSP
			MOVW	#$0001, 2,+Y
			JOB	CF_INTEGER_3

;RESUME ( -- ) IMMEDIATE
;Exit suspend mode 
;
;Throws:
;"Return stack underflow"
CF_RESUME		EQU	*
#ifdef HANDLER
			RS_PULL5	HANDLER, TO_IN, NUMBER_TIB, TIB_OFFSET, IP
#else
			RS_PULL4	TO_IN, NUMBER_TIB, TIB_OFFSET, IP
#endif

			LDX	NEXT_WATCH 
			STX	NEXT_PTR
			JMP	0,X 			;jump to next watch
	
;LITERAL run-time semantics
;Run-time: ( -- x )
;Place x on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CF_LITERAL_RT		EQU	*
			PS_CHECK_OF	1		;check for PS overflow (PSP-new cells -> Y)
			LDX	IP			;push the value at IP onto the PS
			MOVW	2,X+ 0,Y		; and increment the IP
			STX	IP
			STY	PSP
			NEXT

;2LITERAL run-time semantics
;Run-time: ( -- d )
;Place d on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CF_TWO_LITERAL_RT	EQU	*
			PS_CHECK_OF	2		 ;check for PS overflow (PSP-new cells -> Y)
			LDX	IP			 ;push the value at IP onto the PS
			MOVW	2,X+, 0,Y		 ; and increment the IP
			MOVW	2,X+, 2,Y		 ; and increment the IP
			STX	IP
			STY	PSP
			NEXT
	
FOUTER_CODE_END		EQU	*
FOUTER_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FOUTER_TABS_START_LIN
			ORG 	FOUTER_TABS_START, FOUTER_TABS_START_LIN
#else
			ORG 	FOUTER_TABS_START
FOUTER_TABS_START_LIN	EQU	@
#endif	

;Symbol tables
FOUTER_SYMTAB		EQU	NUM_SYMTAB
	
;System prompts
FOUTER_NL_SUSPEND	STRING_NL_NONTERM
			FCS	"!"
FOUTER_NL_PLAIN   	EQU	STRING_STR_NL
FOUTER_INTERACT_PROMPT	FCS	"> "
FOUTER_COMPILE_PROMPT	FCS	"+ "
#ifdef NVC
FOUTER_NVCOMPILE_PROMPT	FCS	"@ "
#endif
FOUTER_SYSTEM_ACK	FCS	" ok"

FOUTER_TREE_EOB		EQU	$00 	;end of branch
FOUTER_TREE_BI		EQU	$00 	;branch indicator
FOUTER_TREE_ES		EQU	$00 	;empty string
	
FOUTER_TABS_END		EQU	*
FOUTER_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FOUTER_WORDS_START_LIN
			ORG 	FOUTER_WORDS_START, FOUTER_WORDS_START_LIN
#else
			ORG 	FOUTER_WORDS_START
FOUTER_WORDS_START_LIN	EQU	@
#endif	
			ALIGN	1
;#ANSForth Words:
;================
;Word: QUERY ( -- )
;Make the user input device the input source. Receive input into the terminal
;input buffer,mreplacing any previous contents. Make the result, whose address is
;returned by TIB, the input buffer.  Set >IN to zero.
;
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
;"Invalid RX data"
CFA_QUERY		DW	CF_QUERY

;Word: PARSE ( char "ccc<char>" -- c-addr u )
;Parse ccc delimited by the delimiter char. c-addr is the address (within the
;input buffer) and u is the length of the parsed string.  If the parse area was
;empty, the resulting string has a zero length.
;
;Throws:
;"Parameter stack overflow"
;"Parameter stack underflow"
CFA_PARSE		DW	CF_PARSE

;Word: >NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) 
;ud2 is the unsigned result of converting the characters within the string
;specified by c-addr1 u1 into digits, using the number in BASE, and adding each
;into ud1 after multiplying ud1 by the number in BASE. Conversion continues
;left-to-right until a character that is not convertible, including any "+" or
;"-", is encountered or the string is entirely converted. c-addr2 is the
;location of the first unconverted character or the first character past the end
;of the string if the string was entirely converted. u2 is the number of
;unconverted characters in the string. If ud2 overflows during the conversion,
;both result and conversion string are left untouched.
;
;Throws:
;"Parameter stack underflow"
CFA_TO_NUMBER		DW	CF_TO_NUMBER
	
;Word: BASE ( -- a-addr ) 
;a-addr is the address of a cell containing the current number-conversion radix
;{{2...36}}. 
;
;Throws:
;"Parameter stack overflow"
CFA_BASE		DW	CF_CONSTANT_RT
			DW	BASE

;Word: STATE ( -- a-addr ) 
;a-addr is the address of a cell containing the compilation-state flag. STATE is
;true when in compilation state, false otherwise. The true value in STATE is
;non-zero. Only the following standard words alter the value in STATE:
; : (colon), ; (semicolon), ABORT, QUIT, :NONAME, [ (left-bracket), and
; ] (right-bracket). 
;  Note:  A program shall not directly alter the contents of STATE. 
;
;Throws:
;"Parameter stack overflow"
CFA_STATE		DW	CF_CONSTANT_RT
			DW	STATE
	
;Word: >IN ( -- a-addr )
;a-addr is the address of a cell containing the offset in characters from the
;start of the input buffer to the start of the parse area.  
;
;Throws:
;"Parameter stack overflow"
CFA_TO_IN		DW	CF_CONSTANT_RT
			DW	TO_IN

;Word: #TIB ( -- a-addr )
;a-addr is the address of a cell containing the number of characters in the
;terminal input buffer.
;
;Throws:
;"Parameter stack overflow"
CFA_NUMBER_TIB		DW	CF_CONSTANT_RT
			DW	NUMBER_TIB

;Word: WORDS ( -- )
;List the definition names in the first word list of the search order. The
;format of the display is implementation-dependent.
;WORDS may be implemented using pictured numeric output words. Consequently, its
;use may corrupt the transient region identified by #>.
CFA_WORDS		DW	CF_INNER
			DW	CFA_WORDS_CDICT
			DW	CFA_EOW

;#S12CForth Words:
;=================
;Word: INTEGER ( c-addr u -- d s | n 1 | 0)
;Interpret string as integer value and return a single or double cell number
;along with the cell count. If the interpretation was unsuccessful, return a
;FALSE flag
;
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
CFA_INTEGER		DW	CF_INTEGER

;Word: SUSPEND ( -- )
;Execute a temporary debug shell.
;
;Throws:
;"Parameter stack overflow"
;"Return stack overflow"
;"Communication error"
CFA_SUSPEND		DW	CF_SUSPEND

;Word: RESUME ( -- ) IMMEDIATE
;Exit suspend mode 
;
;Throws:
;"Return stack underflow"
CFA_RESUME		DW	CF_RESUME

;Word: TIB-OFFSET ( -- a-addr )
;a-addr is the address of a cell containing the number of characters in the
;terminal input buffer.
;
;Throws:
;"Parameter stack overflow"
CFA_TIB_OFFSET		DW	CF_CONSTANT_RT
			DW	TIB_OFFSET

;LITERAL run-time semantics
;Run-time: ( -- x )
;Place x on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CFA_LITERAL_RT		DW	CF_LITERAL_RT

;2LITERAL run-time semantics
;Run-time: ( -- x1 x2 )
;Place cell pair x1 x2 on the stack.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CFA_TWO_LITERAL_RT	DW	CF_TWO_LITERAL_RT

FOUTER_WORDS_END	EQU	*
FOUTER_WORDS_END_LIN	EQU	@
#endif
