#!/usr/bin/env perl
###############################################################################
#             Search Tree Generator for the OpenBDM SCI Driver                #
###############################################################################
#    Copyright 2009 Dirk Heisswolf                                            #
###############################################################################
# Description:                                                                #
#    This perl script generates the assembler source for two search trees,    #
#    which are used by the S12CBase baud rate detection.                      #
#    One is used to determine the set of baud rates that are valid for a      #
#    certain high pulse.                                                      #
#    The other one is used to determine the set of baud rates that are valid  #
#    for a certain low pulse.                                                 #
#                                                                             #
#    Each table assigs a set of valid baud rates to a range of pulse lengths. #
#    lower boundary <= pulse length < upper boundary -> set of baud rates     #
#                                                                             #
#    The format of a node entry is the following:                             #
#                                                                             #
#                      +--------+--------+                                    #
#    start of entry -> | lower boundary  | value of lower boundary            #
#                      +--------+--------+                                    #
#                      |  BRs   |  BRs   | set of boud rates - twice          #
#                      +--------+--------+                                    #
#                      |  node pointer   | pointer to node with longer        #
#                      +--------+--------+ boundary value                     #
#    node node with -> | lower boundary  |                                    #
#    even lower        +--------+--------+                                    #
#    boundary value    |  BRs   |  BRs   |                                    #
#                      +--------+--------+                                    #
#                      |  node pointer   |                                    #
#                      +--------+--------+                                    #
#                                                                             #
###############################################################################
# Version History:                                                            #
#    14 May, 2009                                                             #
#      - Initial release                                                      #
###############################################################################

@tables = ({'file'       => "sci_bdtab.s",
	   #'baud_masks' => {  '4800' => 0x01,
	   #		       '9600' => 0x02,
	   #		      '19200' => 0x04,
	   #		      '38400' => 0x08,
	   #		      '57600' => 0x10,
	   #		      '76800' => 0x20,
	   #		     '115200' => 0x40,
	   #		     '153600' => 0x80},
	   #'baud_divs'  => {  '4800' =>  320,
	   #		       '9600' =>  160,
	   #		      '19200' =>   80,
	   #		      '38400' =>   40,
	   #		      '57600' =>   27,
	   #		      '76800' =>   20,
	   #		     '115200' =>   13,
	   #		     '153600' =>   10}
	    'baud_masks' => {  '4800' => 0x01,
			       '7200' => 0x02,
			       '9600' => 0x04,
			      '14400' => 0x08,
			      '19200' => 0x10,
			      '28800' => 0x20,
			      '38400' => 0x40,
			      '57600' => 0x80},
	    'baud_divs'  => {  '4800' =>  320,
			       '7200' =>  213,
			       '9600' =>  160,
			      '14400' =>  107,
			      '19200' =>   80,
			      '28800' =>   53,
			      '38400' =>   40,
			      '57600' =>   27}
	   });

#Table loop
#---------- 
foreach $table (@tables) {
    $file       = $table->{'file'};
    $baud_masks = $table->{'baud_masks'};
    $baud_divs  = $table->{'baud_divs'};
    
    %boundaries  = ();
    $boundary;
    
    %high_tab    = ();
    %low_tab     = ();


    #Open file
    #--------- 
    if (open (FILEHANDLE, sprintf(">%s", $file))) {

	#Print header
	#------------ 
        printf FILEHANDLE ";###############################################################################\n"; 
        printf FILEHANDLE ";# S12CBase - SCI Baud Detection Search Trees                                  #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";#    Copyright 2010 Dirk Heisswolf                                            #\n";
        printf FILEHANDLE ";#    This file is part of the OpenBDM BDM pod firmware.                       #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CBase is free software: you can redistribute it and/or modify         #\n";
        printf FILEHANDLE ";#    it under the terms of the GNU General Public License as published by     #\n";
        printf FILEHANDLE ";#    the Free Software Foundation, either version 3 of the License, or        #\n";
        printf FILEHANDLE ";#    (at your option) any later version.                                      #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CBase is distributed in the hope that it will be useful,              #\n";
        printf FILEHANDLE ";#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #\n";
        printf FILEHANDLE ";#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #\n";
        printf FILEHANDLE ";#    GNU General Public License for more details.                             #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    You should have received a copy of the GNU General Public License        #\n";
        printf FILEHANDLE ";#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Description:                                                                #\n";
        printf FILEHANDLE ";#    This file contains the two search trees which are required for the SCI   #\n";
        printf FILEHANDLE ";#    modules baud rate detection.                                             #\n";
        printf FILEHANDLE ";#    One is used to determine the set of baud rates that are valid for a      #\n";
        printf FILEHANDLE ";#    certain high pulse.                                                      #\n";
        printf FILEHANDLE ";#    The other one is used to determine the set of baud rates that are valid  #\n";
        printf FILEHANDLE ";#    for a certain low pulse.                                                 #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    Each table assigs a set of valid baud rates to a range of pulse lengths. #\n";
        printf FILEHANDLE ";#    lower boundary <= pulse length < upper boundary -> set of baud rates     #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    The format of a node entry is the following:                             #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#    start of entry -> | lower boundary  | value of lower boundary            #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                      |  BRs   |  BRs   | set of boud rates - twice          #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                      |  node pointer   | pointer to node with longer        #\n";
        printf FILEHANDLE ";#                      +--------+--------+ boundary value                     #\n";
        printf FILEHANDLE ";#    node node with -> | lower boundary  |                                    #\n";
        printf FILEHANDLE ";#    even lower        +--------+--------+                                    #\n";
        printf FILEHANDLE ";#    boundary value    |  BRs   |  BRs   |                                    #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                      |  node pointer   |                                    #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Version History:                                                            #\n";
        printf FILEHANDLE ";#    14 May, 2009                                                             #\n";
        printf FILEHANDLE ";#      - Initial release                                                      #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE "\n";

	#Calculate boundaries
	#-------------------- 
	
	foreach my $baud (keys %$baud_divs) {
	    $baud_div  = $baud_divs->{$baud};
	    $baud_mask = $baud_masks->{$baud};

	    #print "baud      = $baud\n";
	    #print "baud_div  = $baud_div\n";
	    #print "baud_mask = $baud_mask\n";

	    
	    #Check minimum high pulse ranges
	    #-------------------------------
	    #A baud rate is valid if: pulse_length >= 16 * divider * (77/80)
	    
	    $boundary = ($baud_div *77)/5;
	    $boundary = int($boundary);
	    
	    if (exists $boundaries{$boundary}->{high_min}) {
		$boundaries{$boundary}->{high_min} = $boundaries{$boundary}->{high_min} | $baud_mask;
	    } else {
		$boundaries{$boundary}->{high_min} = $baud_mask;
	    }
	
	    #printf "boundary: %s %s\n", $boundary, $boundaries{$boundary}->{high_min};
	    
	    #Check minimum idle pulse ranges
	    #-------------------------------
	    #A idle pulse is detected if: pulse_length >= 8*16 * divider * (151/144)
	    # --> Too much overhead  
	    
	    #Check low pulse ranges
	    #----------------------
	    #A baud rate is valid if: pulse_length >= n*16 * divider * (77/80)   for n=[1..9]
	    #                         pulse_length <= n*16 * divider * (151/144)
	    
	    foreach $n (1..9) {
		$boundary = ($n* $baud_div * 77)/5;
		$boundary = int($boundary);
		
		if (exists $boundaries{$boundary}->{low_min}) {
		    $boundaries{$boundary}->{low_min} = $boundaries{$boundary}->{low_min} | $baud_mask;
		} else {
		    $boundaries{$boundary}->{low_min} = $baud_mask;
		}
		
		$boundary = ($n* $baud_div *151)/9;  
		#$boundary = (int($boundary) < $boundary) ? int($boundary)+1 : int($boundary);
		$boundary = int($boundary)+1;
			     
		if (exists $boundaries{$boundary}->{low_max}) {
		    $boundaries{$boundary}->{low_max} = $boundaries{$boundary}->{low_max} | $baud_mask;
		} else {
		    $boundaries{$boundary}->{low_max} = $baud_mask;
		}
	    }
	}
	          
	#Calculate tables
	#---------------- 
	$hi_valids      = 0;
	$lo_valids      = 0;
	$prev_hi_valids = 0;
	$prev_lo_valids = 0;
	$prev_boundary  = 0;
	
	foreach $boundary (sort {$a <=> $b} keys %boundaries) {
	    $boundary_hw = ($boundary >>16) & 0xffff;
	    $boundary_lw =  $boundary       & 0xffff;
	    	    
	    if (exists $boundaries{$boundary}->{high_min}) {
		$hi_valids |= $boundaries{$boundary}->{high_min};
	    }
	    if (exists $boundaries{$boundary}->{low_min}) {
		$lo_valids |= $boundaries{$boundary}->{low_min};
	    }
	    if (exists $boundaries{$boundary}->{low_max}) {
		$lo_valids &= ~$boundaries{$boundary}->{low_max};
	    }
	    
	    #High pulse table
	    if (exists $boundaries{$boundary}->{high_min}) {
		if (!exists $high_tab{$boundary_hw}) {
		    $high_tab{$boundary_hw} = [];
		    if ($prev_hi_valids != 0) {
		    	 push @{$high_tab{$boundary_hw}}, [($#{$high_tab{$boundary_hw}}+1),
		    					   0,
		    					   $hi_valids];
		    }
		}
		push @{$high_tab{$boundary_hw}}, [($#{$high_tab{$boundary_hw}}+1),
						  $boundary,
						  #sprintf("%%%s_%s", bin2str($hi_valids, 8), bin2str($hi_valids, 8))];
						 $hi_valids];
		
	    }
		
	    #Low pulse table
	    if ((exists $boundaries{$boundary}->{low_min}) ||
		(exists $boundaries{$boundary}->{low_max})) {
		if (!exists $low_tab{$boundary_hw}) {
		    $low_tab{$boundary_hw} = [];
		    if ($prev_lo_valids != 0) {
			push @{$low_tab{$boundary_hw}}, [($#{$low_tab{$boundary_hw}}+1),
							  0,
							  $lo_valids];
		    }
		}
		push @{$low_tab{$boundary_hw}}, [($#{$low_tab{$boundary_hw}}+1),
						 $boundary,
						 $lo_valids];	   
	    }
	    $prev_boundary  = $boundary;
	    $prev_hi_valids = $hi_valids;
	    $prev_lo_valids = $lo_valids;
	}

	#Print comment for high pulse table
	#----------------------------------
        printf FILEHANDLE ";###############################################################################\n";
	print  FILEHANDLE ";# High pulses                                                                 #\n";
        printf FILEHANDLE ";###############################################################################\n";

	print_ctabs(\%high_tab);

	#Print high pulse table
	#----------------------
	print  FILEHANDLE "\n";
	$count = 0;
	foreach $boundary_hw (sort keys %high_tab) {
	    $count++;
	}
	printf FILEHANDLE "%s\tEQU\t\$%.2X\n", "SCI_HT_CNT", $count;

	if ($count > 1) {
	    printf FILEHANDLE "%s\t\tEQU\t*\n", "SCI_HT_LIST";
	    foreach $boundary_hw (sort keys %high_tab) {
		my $tree_name = sprintf "SCI_HT%1X", $boundary_hw;  
		printf FILEHANDLE "\t\tDW\t%s\n", $tree_name;
	    }
	}

	print  FILEHANDLE "\n";
	foreach $boundary_hw (sort keys %high_tab) {
	    my $tree_name = sprintf "SCI_HT%1X", $boundary_hw;  
   	
	    print  FILEHANDLE "\n";
	    printf FILEHANDLE "%s\t\tEQU\t*\n", $tree_name;
   	
	    printf FILEHANDLE "%s", print_st_rec($high_tab{$boundary_hw}, $tree_name, "");
	    print  FILEHANDLE "\n";
	    #exit;
	}

	#Print comment for low pulse table
	#--------------------------------- 	
        printf FILEHANDLE ";###############################################################################\n";
	print  FILEHANDLE ";# Low pulses                                                                  #\n";
        printf FILEHANDLE ";###############################################################################\n";

	print_ctabs(\%low_tab);

	#Print low pulse table
	#---------------------
	print  FILEHANDLE "\n";
	$count = 0;
	foreach $boundary_hw (sort keys %low_tab) {
	    $count++;
	}
	printf FILEHANDLE "%s\tEQU\t\$%.2X\n", "SCI_LT_CNT",  $count;

	if ($count > 1) {
	    printf FILEHANDLE "%s\t\tEQU\t*\n", "SCI_LT_LIST";
	    foreach $boundary_hw (sort keys %low_tab) {
		my $tree_name = sprintf "SCI_LT%1X", $boundary_hw;  
		printf FILEHANDLE "\t\tDW\t%s\n", $tree_name;
	    }
	}

	print  FILEHANDLE "\n";
	foreach $boundary_hw (sort keys %low_tab) {
	    my $tree_name = sprintf "SCI_LT%1X", $boundary_hw;  
     	
	    print  FILEHANDLE "\n";
	    printf FILEHANDLE "%s\t\tEQU\t*\n", $tree_name;
   	
	    printf FILEHANDLE "%s", print_st_rec($low_tab{$boundary_hw}, $tree_name, "");
 	    print  FILEHANDLE "\n";
	    #exit;
	}

    } else {
	printf STDERR "Cannot open list file \"%s\"\n", $file;
	exit;
    }
}

 sub print_st_rec {
    my $table = shift @_;
    my $label = shift @_;
    my $str   = shift @_;
    
    my $count;
    my $boundary;
    my $valids;

    my $pos    = ($#$table&1)+($#$table>>1);
    #my @ltab   = @$table;
    #my @rtab   = splice @ltab, $pos;
    #shift @rtab;
    my @rtab   = @$table;
    my @ltab   = splice @rtab, $pos;
    shift @ltab;
    my $llab;
    
    #print "table = $#$table ($table->[0]->[0] - $table->[$#$table]->[0])\n";
    #print "pos   = $pos ($table->[$pos]->[0], $table->[$pos]->[1], $table->[$pos]->[2])\n";
    #print "rtab  = $#rtab\n";
    #print "ltab  = $#ltab\n";
    #exit;
    
    if ($#ltab >= 0) {
	my $lpos = ($#ltab&1)+($#ltab>>1);
	$llab = sprintf("%s_%.2X", $label, $ltab[$lpos]->[0]);
    } else {
	$llab = "\$0000\t";
    }
    
    #print "llab  = $llab\n";
    #exit;

    $count    = $table->[$pos]->[0];
    $boundary = $table->[$pos]->[1] & 0xffff;
    $valids   = sprintf("%%%s_%s", bin2str($table->[$pos]->[2], 8), bin2str($table->[$pos]->[2], 8));

    $str .= sprintf("%s_%.2X\tDW\t\$%.4X %s %s\t;pulse >=%6d cycs\n",
		    $label,
		    $count,
		    $boundary,
		    $valids,
		    $llab,
		    $boundary);
    #exit;  
    
    #print "rtab  = $#rtab\n";
    if ($#rtab >= 0) {
	$str .= print_st_rec(\@rtab, $label);
    } else {
	$str .= "\t\tDW\t\$0000\n"
	} 
    #exit;
    
    #print "ltab  = $#ltab\n";
    if ($#ltab >= 0) {
	$str .= print_st_rec(\@ltab, $label);
    }
    return $str;
}

sub print_ctab_header {
    my $bauds          = shift @_;
    my @baud_chars;
    my $baud_chars_max = 0;
    my $baud_matrix    = {};
    my $i;
    my $j;
    my $str            = "";

    for ($i=0; $i<=$#$bauds; $i++) {
	@baud_chars = split(//, sprintf("%s", $bauds->[$i]));
	if ($baud_chars_max < $#baud_chars) {$baud_chars_max = $#baud_chars;}
    }

    for ($i=0; $i<=$#$bauds; $i++) {
	@baud_chars = split(//, sprintf("%s", $bauds->[$i]));
	for ($j=0; $j<=$#baud_chars; $j++) {
	    $baud_matrix->{$i}->{$j+($baud_chars_max-$#baud_chars)} = $baud_chars[$j];
	}
    }
    
    foreach $j (0..($baud_chars_max-1)) {
	$str .= sprintf ";# %-50s ", "";
	foreach $i (0..$#$bauds) {
	    if (exists $baud_matrix->{$i}->{$j}) {
		$str .= $baud_matrix->{$i}->{$j};
	    } else {
		$str .= " ";
	    }
	}
	$str .= "\n";
    }
    $str .= sprintf ";# %-50s ", "Range";
    foreach $i (0..$#$bauds) {
	if (exists $baud_matrix->{$i}->{$baud_chars_max}) {
	    $str .= $baud_matrix->{$i}->{$baud_chars_max};
	} else {
	    $str .= " ";
	}
    }
    $str .= "\n";
    
    $str .= ";# ---------------------------------------------------";
    foreach $i (0..$#$bauds) {
	$str .= "-";
    }
    $str .= "\n";

    return $str;
}

sub print_ctabs {
    my $tab            = shift @_;
    my $str            = "";

    my $boundary_hw;   
    my $tab_entry;
    my $count;
    my $boundary;
    my $valids;
    my $prev_boundary;
    my $prev_valids;


    foreach $boundary_hw (sort keys %$tab) {
	#printf FILEHANDLE ";# Table %d:\n", $boundary_hw;
	print  FILEHANDLE ";#\n";
	print  FILEHANDLE print_ctab_header([sort {$baud_masks->{$b} <=> $baud_masks->{$a}} keys %$baud_masks]);

	$prev_boundary = undef;
	$prev_valids   = undef;	
	foreach $entry (@{$tab->{$boundary_hw}}) {
	    $count    = $entry->[0];
	    $boundary = $entry->[1];
	    $valids   = $entry->[2];

	    if (defined $prev_boundary) {
		printf FILEHANDLE ";# %-50s %s\n", sprintf("%6d <= pulse < %6d [%6X,%6X]", $prev_boundary, 
							                                   $boundary, 
							                                   $prev_boundary, 
							                                   $boundary), 
		                                   bin2str_x($prev_valids, 8);
	    }
	    $prev_boundary = $boundary;
	    $prev_valids   = $valids;
	}
	printf FILEHANDLE ";# %-50s %s\n", sprintf("%6d <= pulse   %6s [%6X,%6s] ", $prev_boundary, 
						   "", 
						   $prev_boundary,
						   "..."), 
	                                           bin2str_x($prev_valids, 8);
	print  FILEHANDLE "\n";
    }
}


sub bin2str {
   my $bin   = shift @_;
   my $width = shift @_;
   my $str   = "";

   foreach my $i (1..$width) {
      if ($bin & 1) {
         $str = "1" . $str;
      } else {
         $str = "0" . $str;
      }
      $bin = $bin >> 1;
   }
   return $str;
}

sub bin2str_x {
   my $bin   = shift @_;
   my $width = shift @_;
   my $str   = "";

   foreach my $i (1..$width) {
      if ($bin & 1) {
         $str = "X" . $str;
      } else {
         $str = "." . $str;
      }
      $bin = $bin >> 1;
   }
   return $str;
}
