\ ###############################################################################
\ # Tic Tac Toe for S12CForth                                                   #
\ ###############################################################################
\ #    Copyright 2011 Dirk Heisswolf                                            #
\ #    This file is part of the S12CForth framework for Freescale's S12C MCU    #
\ #    family.                                                                  #
\ #                                                                             #
\ #    S12CForth is free software: you can redistribute it and/or modify        #
\ #    it under the terms of the GNU General Public License as published by     #
\ #    the Free Software Foundation, either version 3 of the License, or        #
\ #    (at your option) any later version.                                      #
\ #                                                                             #
\ #    S12CForth is distributed in the hope that it will be useful,             #
\ #    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
\ #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
\ #    GNU General Public License for more details.                             #
\ #                                                                             #
\ #    You should have received a copy of the GNU General Public License        #
\ #    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
\ ###############################################################################
\ # Description:                                                                #
\ #    This is a classic Tic Tac Toe game (intended as demonstrator for the     #
\ #    S12CForth framework).                                                    #
\ #                                                                             #
\ #    Rules:                                                                   #
\ #      One player plays against the computer. The human player always begins  #
\ #      the game. The player puts "O"s onto the board, the computer sets "X"s. #
\ #                                                                             #
\ #    Screenshot:                                                              #
\ #                                                                             #
\ #    Board:   Options:                                                        #
\ #     O| |      |b|c                                                          #
\ #    --+-+--  --+-+--                                                         #
\ #      |O|X    d| |                                                           #
\ #    --+-+--  --+-+--                                                         #
\ #      | |     g|h|i                                                          #
\ #                                                                             #
\ #    Your turn (q for quit):                                                  #
\ #                                                                             #
\ ###############################################################################

\ #########
\ # Setup #
\ #########
hex                                             \ all literals are in hexadecimal format

: d2/ ( xd -- xd )                              \ fix Swift Forth's implementation of "D2/"
  2/ swap 2/ swap ;

\ ###################
\ # Output routines #
\ ###################
\ Print the header of the board
: .header ( -- ) 
  cr cr
  ." Board:   Options:" ;

\ Print the prompt
: .prompt ( -- ) 
  cr cr
  ." Your turn (q for quit): ";

\ Print a column separator onto the board
: .colsep ( -- ) 
  [char] | emit ;

\ Print a row separator onto the board
: .finalrowsep (  -- ) 
  cr
  ." --+-+--" ;

\ Print a row separator onto the board
: .rowsep (  -- ) 
  .finalrowsep
  ."   --+-+--" ;

\ Print a piece onto the board
: .piece ( Xs Os -- ) 
  1 and 
  if 
    [char] O emit
    drop
  else 
    1 and
    if
      [char] X emit
    else
      space
    then
  then ;

\ Print a choice for a move onto the board
: .choice ( char pieces -- ) 
  1 and 
  if 
    drop
    space
  else
    emit
  then ;

\ Print a row onto the board
: .row ( char Xs Os -- )
  2dup
  cr space   
  2dup .piece .colsep d2/ 2dup .piece .colsep d2/ .piece
  4 spaces
  or
  2dup .choice .colsep 2/ swap 1+ swap 2dup .choice .colsep 2/ swap 1+ swap .choice ;
  
\ Print a row onto the board
: .finalrow ( char Xs Os -- )
  cr space   
  2dup .piece .colsep d2/ 2dup .piece .colsep d2/ .piece ;
   
\ Print print the board
: .board ( Xs Os -- )
  .header
  [char] a dup 2over .row
  .rowsep
  3 + rot rot d2/ d2/ d2/ rot dup 2over .row
  .rowsep  
  3 + rot rot d2/ d2/ d2/ .row
  .prompt ;

\ Print print the final board
: .finalboard ( Xs Os -- )
  cr
  2dup .finalrow
  .finalrowsep
  d2/ d2/ d2/ 2dup .finalrow
  .finalrowsep
  d2/ d2/ d2/ .finalrow ;

\ Game over message
: gameover
  cr ." Game over!" cr
  quit ;

\ ##################
\ # Input routines #
\ ##################
\ Make character uppercase
: uppercase ( char -- char )
  dup [char] a [ char z 1+ ] literal within
  if 
    [ char a char A - ] literal -
  then ;

\ Query input
: choose ( pieces -- choice )
  0 0                              \ stack: pieces char choice
  begin
    2drop
    key uppercase                  \ stack: pieces char
    dup [char] Q  =                \ stack: pieces char flag
    if
      2drop
      gameover
    then
    dup [char] A - dup 0 9 within  \ stack: pieces char index flag
    if 
      1 swap lshift                \ stack: pieces char choice
    else
      drop 0                       \ stack: pieces char choice
    then
    2 pick invert and dup 0<>      \ stack: pieces char choice flag
  until
  swap [ char a char A - ] literal + 
  emit                             
  nip ;

\ ###############
\ # AI routines #
\ ###############
\ Check if for a tie
: tie? ( pieces -- flag)
  1FF = ;

\ Check for subset
: subset? ( pieces subset -- flag )
  tuck and = ;

\ Check if somebody has won
: won? ( pieces -- flag )
    dup    7 subset?       \ stack: pieces flag 
    over  38 subset? or    \ stack: pieces flag
    over 1c0 subset? or    \ stack: pieces flag
    over  49 subset? or    \ stack: pieces flag
    over  92 subset? or    \ stack: pieces flag
    over 124 subset? or    \ stack: pieces flag
    over 111 subset? or    \ stack: pieces flag
    swap  54 subset? or ;  \ stack: flag

\ Make a random move for the player
: random ( pieces -- choice )
  dup 1ff =
  if
    drop 0
  else
    100                   \ stack: occupied choice 
    begin
      2dup subset?
    while
      2/
    repeat
    nip
  then ;

\ Check if center is free
: center ( pieces -- choice )
  invert 10 and ;

\ Check if the player has the opportunity to win
: opportunity? ( Xs Os -- choice )
  tuck or      \ stack: Os occupied
  begin
    dup random dup          \ stack: Os occupied choice flag
    if			    
      dup 3 pick or         \ stack: Os occupied choice nextOs
      won?                  \ stack: Os occupied choice flag
      if 		    
        rot rot 2drop true  \ stack choice true
      else
        or false            \ stack: Os occupied false
      then
    else
      nip nip true          \ stack: false true
    then
  until ;

\ Computer offense
: offense ( Xs Os -- choice )
  swap opportunity? ;

\ Computer defense
: defense ( Xs Os -- choice )
  opportunity? ;

\ #############
\ # Game play #
\ #############
\ One user turn
: userturn ( Xs Os -- Xs Os )
  2dup .board                      \ draw board
  2dup or choose                   \ get input
  or                               \ adjust board
  dup won?
  if
    cr .finalboard
    cr ." Congratulations!" gameover
  then
  2dup or tie?
  if
    cr .finalboard
    cr ." Tie!" gameover
  then ;

\ One computer turn
: computerturn ( Xs Os -- Xs Os )
  2dup offense dup 0=                \ try offense
  if
    drop 2dup defense dup 0=         \ try defense
    if
      drop 2dup or center dup 0=     \ try center
      if
        \ drop 2dup or random dup 0= \ try any move    
        \ if                         \ tie not possible if user starts
        \   2drop
        \   cr .finalboard
        \   cr ." Tie!" gameover
        \ then
        drop 2dup or random          \ try any move    
      then
    then
  then
  rot or swap
  over won?
  if
    cr .finalboard
    cr ." I win!" gameover
  then ;

\ Start game
: ttt
  0 0                              \ start with empty board
  begin
    userturn                       \ user turn
    computerturn                   \ computer turn
    0
  until ;
