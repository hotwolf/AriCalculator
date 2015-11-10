#!/usr/bin/env perl
###############################################################################
# S12CForth - Dictionary Tree Generator                                       #
###############################################################################
#    Copyright 2013 Dirk Heisswolf                                            #
#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
#    family.                                                                  #
#                                                                             #
#    S12CForth is free software: you can redistribute it and/or modify        #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    S12CForth is distributed in the hope that it will be useful,             #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
###############################################################################
# Description:                                                                #
#    This perl script generates the assembler source of a search tree (incl.  #
#    parser) for the S12CForth CORE NFAs.                                     #
###############################################################################
# Version History:                                                            #
#    8 January, 2013                                                          #
#      - Initial release                                                      #
#    8 October, 2013                                                          #
#      - Fixed output format                                                  #
###############################################################################

#################
# Perl settings #
#################
use 5.005;
#use warnings;
use File::Basename;
use FindBin qw($RealBin);
use lib $RealBin;
use Data::Dumper;
use lib "$RealBin/../HSW12/Perl";
require hsw12_asm;

###############
# global vars #
###############
@src_files         = ();
@lib_files         = ();
%defines           = ();
$output_path       = ();
$prog_name         = "";
$arg_type          = "src";
$srec_format       = $hsw12_asm::srec_def_format;
$srec_data_length  = $hsw12_asm::srec_def_data_length;
$srec_add_s5       = $hsw12_asm::srec_def_add_s5;
$srec_word_entries = 1;
$command_file_name = "";
$symbols           = {};
$code              = {};
$comp_symbols      = {};
$pag_addrspace     = {};

%dict_tree         = ();
$max_name_length   = 0;
$tree_layout_width = 0;
@zero_terms        = ();
@first_entry       = ();
$first_cfa         = undef;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
@months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
@days   = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");

##########################
# read command line args #
##########################
#printf "parsing args: count: %s\r\n", $#ARGV + 1;
foreach $arg (@ARGV) {
    #printf "  arg: %s\r\n", $arg;
    if ($arg =~ /^\s*\-L\s*$/i) {
	$arg_type = "lib";
    } elsif ($arg =~ /^\s*\-D\s*$/i) {
	$arg_type = "def";
    } elsif ($arg =~ /^\s*\-/) {
	#ignore
    } elsif ($arg_type eq "src") {
	#sourcs file
	push @src_files, $arg;
    } elsif ($arg_type eq "lib") {
	#library path
	if ($arg !~ /\/$/) {$arg = sprintf("%s/", $arg);}
	unshift @lib_files, $arg;
        $arg_type          = "src";
    } elsif ($arg_type eq "def") {
	#precompiler define
	if ($arg =~ /^\s*(\w+)=(\w+)\s*$/) {
	    $defines{uc($1)} = $2;
	} elsif ($arg =~ /^\s*(\w+)\s*$/) {
	    $defines{uc($1)} = "";
	}
        $arg_type          = "src";
    }
}

###################
# print help text #
###################
if ($#src_files < 0) {
    printf "usage: %s [-L <library path>] [-D <define: name=value or name>] <src files> \r\n", $0;
    print  "\r\n";
    exit;
}

###################
# add default lib #
###################
#printf "libraries:    %s (%s)\r\n",join("\", \"", @lib_files), $#lib_files;
#printf "source files: %s (%s)\r\n",join("\", \"", @src_files), $#src_files;
if ($#lib_files < 0) {
  foreach $src_file (@src_files) {
    #printf "add library:%s/\r\n", dirname($src_file);
    push @lib_files, sprintf("%s/", dirname($src_file));
  }
}

#######################################
# determine program name and location #
#######################################
$prog_name   = basename($src_files[0], ".s");
$output_path = dirname($src_files[0], ".s");

####################
## add default lib #
####################
##printf "libraries:    %s (%s)\n",join("\", \"", @lib_files), $#lib_files;
##printf "source files: %s (%s)\n",join("\", \"", @src_files), $#src_files;
#if ($#lib_files < 0) {
#  foreach $src_file (@src_files) {
#    #printf "add library:%s/\n", dirname($src_file);
#    push @lib_files, sprintf("%s/", dirname($src_file));
#  }
#}

####################
# load symbol file #
####################
$symbol_file_name = sprintf("%s/%s.sym", $output_path, $prog_name);
printf STDERR "Loading: %s\n",  $symbol_file_name;
if (open (FILEHANDLE, sprintf("<%s", $symbol_file_name))) {
    $data = join "", <FILEHANDLE>;
    eval $data;
    close FILEHANDLE;
}
#printf STDERR $data;
#printf STDERR "Importing %s\n",  join(",\n", keys %{$symbols});
#exit;

#######################
# compile source code #
#######################
#printf STDERR "src files: \"%s\"\r\n", join("\", \"", @src_files);  
#printf STDERR "lib files: \"%s\"\r\n", join("\", \"", @lib_files);  
#printf STDERR "defines:   \"%s\"\r\n", join("\", \"", @defines);  
$code = hsw12_asm->new(\@src_files, \@lib_files, \%defines, "S12", 1, $symbols);

###################
# write list file #
###################
$list_file_name = sprintf("%s/%s.lst", $output_path, $prog_name);
if (open (FILEHANDLE, sprintf("+>%s", $list_file_name))) {
    $out_string = $code->print_listing();
    print FILEHANDLE $out_string;
    #print STDOUT     $out_string;
    #printf "output: %s\n", $list_file_name;
    close FILEHANDLE;
} else {
    printf STDERR "Can't open list file \"%s\"\n", $list_file_name;
    exit;
}

#####################
# check code status #
#####################
if ($code->{problems}) {
    printf STDERR "Problem summary: %s\r\n", $code->{problems};
} else {
    #####################################
    # read symbol table and address map #
    #####################################
    $comp_symbols  = $code->{comp_symbols};
    $pag_addrspace = $code->{pag_addrspace};
    
    #####################
    # write symbol file #
    #####################
    #$symbol_file_name = sprintf("%s/%s.sym", $output_path, $prog_name);
    if (open (FILEHANDLE, sprintf("+>%s", $symbol_file_name))) {
	$dump = Data::Dumper->new([$code->{comp_symbols}], ['symbols']);
	$dump->Indent(2);
	print FILEHANDLE $dump->Dump;
 	close FILEHANDLE;
    } else {
	printf STDERR "Can't open symbol file \"%s\"\n", $symbol_file_name;
	exit;
    }

    #printf STDERR "Loaded...(%s)\n", $#{$code->{code}};
    #######################
    # parse code for CFAs #
    #######################
    foreach $code_entry (@{$code->{code}}) {	
	$code_comments = $code_entry->[2];
	$code_label    = $code_entry->[3];
	$code_opcode   = $code_entry->[4];
	$code_args     = $code_entry->[5];
	$code_pc_lin   = $code_entry->[6];
	$code_pc_pag   = $code_entry->[7];
	$code_hex      = $code_entry->[8];
	$code_byte_cnt = $code_entry->[9];
	$code_macros   = $code_entry->[11];
	$code_sym_tabs = $code_entry->[12];
	
	#printf STDERR "Label: \"%s\"\n", $code_label;
	#Word must begin with "CFA_" label
	if ($code_label =~ /^CFA_/) {		
	    #printf STDERR "CFA found: \"%s\"\n", $code_label;
	    
	    #Word must contain the comment line: ;Word: <name> ... HIDDEN ... IMMEDIATE"
	    my $name_string  = "";
	    my $name_found   = 0;
	    my $is_immediate = 0;
	    my $is_hidden    = 0;
	    foreach my $code_comment (@{$code_comments}) {
		#printf STDERR "Comment: \"%s\"\n", $code_comment;
		if ($code_comment =~ /^;Word:\s+(\S+)/) {
		    $name_found   = 1;
		    $name_string  =  uc($1);
		    #$name_string =  $1;     //case sensitive naming
		    if ($code_comment =~ /^;Word:\s+\S+\s+.*IMMEDIATE\s*$/) {
			$is_immediate = 1;
		    } else {
			$is_immediate = 0;
		    }
		    if ($code_comment =~ /^;Word:\s+\S+\s+.*HIDDEN\s*$/) {
			$is_hidden = 1;
		    } else {
			$is_hidden = 0;
		    }
		    last;
		}
	    }	    
	    if ($name_found) {
		#printf STDERR "      \"%s\"%s%s\n", $name_string,
		#                                    $is_hidden    ? " HIDDEN" : "",
		#                                    $is_immediate ? " IMMEDIATE" : "";
		 if (! $is_hidden) {
		     #Find longest name
		     if (length($name_string) > $max_name_length) {
			 $max_name_length = length($name_string);
		     }
		     
		     #Split name into letters
		     @name_array = split("", $name_string);
		     
		     #Add word to dictionary tree
		     add_to_tree(\%dict_tree, \@name_array, $code_label, $is_immediate);
		 }
	    }
	}
    }

    ###################################
    # condense tree (find substrings) #
    ###################################
    condense_tree(\%dict_tree);

    ##########################################
    # find zero-length terminated substrings #
    ##########################################
    #find_zero_term(\%dict_tree);

    #########################
    # write NFA search tree #
    #########################
    $dict_tree_file_name = sprintf("%s/fcdict_tree.s", $output_path);

    if (open (FILEHANDLE, sprintf(">%s", $dict_tree_file_name))) {

	#Print header
	#------------ 
        printf FILEHANDLE "#ifndef FCDICT_TREE_COMPILED\n"; 
        printf FILEHANDLE "#define FCDICT_TREE_COMPILED\n"; 
        printf FILEHANDLE ";###############################################################################\n"; 
        printf FILEHANDLE ";# S12CForth - Search Tree for the Core Dictionary                             #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";#    Copyright 2009-2015 Dirk Heisswolf                                       #\n";
        printf FILEHANDLE ";#    This file is part of the S12CForth framework for Freescale's S12(X) MCU  #\n";
        printf FILEHANDLE ";#    families.                                                                #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CForth is free software: you can redistribute it and/or modify        #\n";
        printf FILEHANDLE ";#    it under the terms of the GNU General Public License as published by     #\n";
        printf FILEHANDLE ";#    the Free Software Foundation, either version 3 of the License, or        #\n";
        printf FILEHANDLE ";#    (at your option) any later version.                                      #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CForth is distributed in the hope that it will be useful,             #\n";
        printf FILEHANDLE ";#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #\n";
        printf FILEHANDLE ";#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #\n";
        printf FILEHANDLE ";#    GNU General Public License for more details.                             #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    You should have received a copy of the GNU General Public License        #\n";
        printf FILEHANDLE ";#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Description:                                                                #\n";
        printf FILEHANDLE ";#    This file contains a search tree for the NFAs of the S12CForth CORE      #\n";
        printf FILEHANDLE ";#    words.                                                                   #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Generated on %3s, %3s %.2d %4d                                               #\n", $days[$wday], $months[$mon], $mday, $year;
        printf FILEHANDLE ";###############################################################################\n";

	#Print tree layout
	$tree_layout_width = get_tree_layout_width(\%dict_tree);
        printf FILEHANDLE "\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Dictionary Tree Structure                                                   #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";\n";
        printf FILEHANDLE "; -> ";
	print_tree_layout(\%dict_tree, ";    ");

	#Constants label
        printf FILEHANDLE "\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Constants                                                                   #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE "\n";

	#Constants
        printf FILEHANDLE ";Global constants\n";
        printf FILEHANDLE "#ifndef      NULL\n";
        printf FILEHANDLE "NULL                    EQU     $0000\n";
        printf FILEHANDLE "#endif\n";
 	printf FILEHANDLE "\n";
        printf FILEHANDLE ";Tree depth\n";
        printf FILEHANDLE "FCDICT_TREE_DEPTH       EQU     %d\n", get_tree_depth(\%dict_tree);
 	printf FILEHANDLE "\n";
        printf FILEHANDLE ";First CFA\n";
        printf FILEHANDLE "FCDICT_FIRST_CFA        EQU     %s\n", $first_cfa;
 
	#Macro label
        printf FILEHANDLE "\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Macros                                                                      #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE "\n";

	#Print tree
        printf FILEHANDLE ";Dictionary tree\n";
        printf FILEHANDLE "#macro       FCDICT_TREE, 0\n";
        printf FILEHANDLE ";Local constants\n";
        #printf FILEHANDLE "STRING_TERMINATION      EQU     \$00\n";
        printf FILEHANDLE "EMPTY_STRING            EQU     \$00\n";
        printf FILEHANDLE "BRANCH                  EQU     \$00\n";
        printf FILEHANDLE "END_OF_BRANCH           EQU     \$00\n";
        printf FILEHANDLE "IMMEDIATE               EQU     \$8000\n";
        #printf FILEHANDLE "\n";
	my $mem_offset = 0;
	print_tree(\%dict_tree, "", [], \$mem_offset);
        printf FILEHANDLE "#emac\n";

	#Initialize tree pointer structure
        printf FILEHANDLE ";#Set pointer structure to first CDICT entry\n";
        printf FILEHANDLE "; args:   1: address of CDICT root\n";
        printf FILEHANDLE ";         2: index register to address tree entry structure\n";
        printf FILEHANDLE ";         3: offset of tree entry structure\n";
        printf FILEHANDLE "; result: none\n";
        printf FILEHANDLE "; SSTACK: none\n";
        printf FILEHANDLE ";         All registers are preserved\n";
        printf FILEHANDLE "#macro FCDICT_ITERATOR_INIT, 3\n";
 	print_init_macro();
        printf FILEHANDLE "#emac\n";

        printf FILEHANDLE "#endif\n";
 
	close FILEHANDLE;
    } else {
	printf STDERR "Can't open output file \"%s\"\r\n", $nfa_tree_file_name;
	exit;
    }
}

####################
# Add_word to tree #
####################
sub add_to_tree {
    my $tree           = shift @_;
    my $name_array     = shift @_;
    my $cfa_name       = shift @_;
    my $is_immediate   = shift @_;

    my @tmp_array      = (@$name_array);
    my $tmp_char       = shift @tmp_array;
    #printf STDERR "Add to tree: \"%s\"->\"%s\" \"%s\" %d\n", $tmp_char, join("", @tmp_array), $cfa_name, $#tmp_array;

    #Consider termination
    if ($#tmp_array >= 0) {
	if (! exists $tree->{$tmp_char}) {
	    $tree->{$tmp_char} = {};
	}
	add_to_tree($tree->{$tmp_char}, \@tmp_array, $cfa_name, $is_immediate);
    } else {
	$tree->{$tmp_char}->{"\n"}->{cfa_name}     = $cfa_name;
	$tree->{$tmp_char}->{"\n"}->{is_immediate} = $is_immediate;
    }
    1;
}

#################
# Condense tree #
#################
sub condense_tree {
    my $tree           = shift @_;    
    my @strings = sort keys %$tree;

    while (my $string = shift @strings) {
	if ($string ne "\n") {
	    #No end of string
	    my $child_tree    = $tree->{$string};
	    my @child_strings = sort keys %$child_tree;
	    #Check if child and grandchild can be combined 
	    if ($#child_strings  == 0) {
		my $child_string    = $child_strings[0];
		my $combined_string = $string . $child_string;
		$tree->{$combined_string} = $child_tree->{$child_string};
		delete $tree->{$string};
		unshift @strings, $combined_string;
	    } else {
		condense_tree($child_tree);
	    }
	}
    }
    1;
}		    
       
##########################################
# Find zero-length terminated substrings #
##########################################
sub find_zero_term {
    my $tree           = shift @_;    
    my @strings = sort keys %$tree;

    while (my $string = shift @strings) {
	if ($string eq "\n") {
	    push @zero_terms, $tree->{$string};
	} else {
	    find_zero_term($tree->{$string});
	}
    }
    1;
}

###############################
# Determine depth of the tree #
###############################
sub get_tree_depth{
    my $tree       = shift @_; 
    my $depth      = 0;

    foreach my $string (keys %$tree) {
	if (($string ne "is_immediate") &&
	    ($string ne "cfa_name")) {
	    my $subtree_depth = get_tree_depth($tree->{$string});
	    #printf STDERR "string: \"%s\" %d %d\n", $string, $subtree_depth, $depth;
	    if ($depth < ($subtree_depth+1)) {
		$depth = ($subtree_depth+1);
	    }
	}	
    }
    return $depth;
}

##################################
# Determine witdh of tree layout #
##################################
sub get_tree_layout_width {
    my $tree       = shift @_;    

    my @strings = sort keys %$tree;
    my $max_string_width = 4;
    my $max_child_width  = 0;
    while (my $string = shift @strings) {
	chomp($string);
	if ((length($string)+4) > $max_string_width) {
	    $max_string_width = (length($string)+4);
	}
	my $child_tree  = $tree->{$string};
	my $child_width = get_tree_layout_width($tree->{$string});
	if ($child_width > $max_child_width) {
	    $max_child_width = $child_width;
	}
    }
    return ($max_string_width + $max_child_width);
}

#####################
# Print tree layout #
#####################
sub print_tree_layout {
    my $tree           = shift @_;
    my $pre_string     = shift @_;
    
    #Extract strings
    my @strings = sort(keys %$tree);
 
    #Find longest string
    my $max_string_length = 4;
    foreach my $string (@strings) {
	my $nt_string = $string;
	chomp($nt_string);
	if ((length($nt_string)+4) > $max_string_length) {
	    $max_string_length = (length($nt_string)+4);
	}
    }
  
    #Print strings
    my $new_pre_string;
    my $is_first_line = 1;
    while (my $string = shift @strings) {
	#Update pre-string
	if ($#strings >= 0) {
	    $new_pre_string  = $pre_string . sprintf(sprintf("%%-%ds", $max_string_length), "|");
	} else {
	    $new_pre_string  = $pre_string . sprintf(sprintf("%%-%ds", $max_string_length), " ");
	}

	#Print pre-string
	if ($is_first_line) {
	    $is_first_line = 0;
	    #printf FILEHANDLE "@";
	} else {
	    printf FILEHANDLE $pre_string;
	}
	
	#Print string
	if ($string eq "\n") {
	    #End of string
	    #printf FILEHANDLE "+";
	    my $arrow_length = $tree_layout_width+1;
	    $arrow_length -= length($pre_string);
	    foreach my $i (0..$arrow_length) {
		printf FILEHANDLE "-";
	    }
	    printf FILEHANDLE "> %s %s\n", $tree->{$string}->{cfa_name}, $tree->{$string}->{is_immediate} ? "(immediate)" : "" ;
	    if (! defined $first_cfa) {
		$first_cfa = $tree->{$string}->{cfa_name};
	    }
	} else {
	    #check if string is terminated
	    my $nt_string = $string;
	    chomp($nt_string);
	    if ($nt_string ne $string) {
		#$tring is terminated
		printf FILEHANDLE "%s ", $nt_string;
		my $arrow_length = $tree_layout_width;
		$arrow_length -= length($pre_string);
		$arrow_length -= length($nt_string);
		foreach my $i (0..$arrow_length) {
		    printf FILEHANDLE "-";
		}
		printf FILEHANDLE "> %s %s\n", $tree->{$string}->{cfa_name}, $tree->{$string}->{is_immediate} ? "(immediate)" : "" ;
		if (! defined $first_cfa) {
		    $first_cfa = $tree->{$string}->{cfa_name};
		}
	    } else {
		#string is not terminated
		#printf FILEHANDLE sprintf("%%-%ds", ($max_string_length+1)), $nt_string;
		printf FILEHANDLE $nt_string;
		my $arrow_length = $max_string_length-length($nt_string);
		if ($arrow_length < 3) {
		    printf FILEHANDLE sprintf("%%-%ds",  $arrow_length), " ";
		} elsif ($arrow_length == 3) {
		    printf FILEHANDLE " > ";
		} else {
		    printf FILEHANDLE " ";
		    foreach my $i (0..($arrow_length-4)) {
			printf FILEHANDLE "-";
		    }
		    printf FILEHANDLE "> ";
		}

		#printf FILEHANDLE sprintf(" >%d<", $max_string_length);

		print_tree_layout($tree->{$string}, $new_pre_string);
		if ($#strings >= 0) {
		    printf FILEHANDLE "%s\n", $new_pre_string;
		}
	    }
	}
    }
    1;
}

##############
# Print tree #
##############
sub print_tree {
    my $tree              = shift @_;    
    my $substring         = shift @_;    
    my $position          = shift @_;
    my $mem_offset_ref    = shift @_;
    my @strings           = sort keys %$tree;
    my @subtree_order     = ();
    my $subtree_reordered = 0;
    my $root_label        = "FCDICT_TREE";
    my $label_format      = "FCDICT_TREE_%s";
    my $instr_form_nc     = "%-23s %-7s %s\n";
    my $instr_form        = "%-23s %-7s %-31s ;%s\n";

    #Print subtree comment
    my $comment_line   = "";
    if ($#{$position} >= 0) {
	$comment_line .= sprintf("Subtree %-15s%-10s-> %s+%2X", join("->", @$position) . " =>", 
                                                                sprintf("\"%s\"", $substring), 
				                                $root_label, $$mem_offset_ref);
    } else  {
	$comment_line .= "Root";
    }
    printf FILEHANDLE ";%s\n", $comment_line;
    #printf FILEHANDLE ";";
    #foreach my $i (1..length($comment_line)) {
    #	printf FILEHANDLE "-";
    #}
    #printf FILEHANDLE "\n";

    #Update first entry
    my $is_fitst_entry = 1; 
    foreach my $pos(@$position) {
	if ($pos != 0) {
	    $is_fitst_entry = 0;
	    last;
	}
    }
    if ($is_fitst_entry) {
	my $substring =  $strings[0];
	chomp($substring);
	if ($#first_entry < 0) {
	    #printf STDERR "first entry1: %d %d %s %s\n", $#first_entry,
	    #                                             $$mem_offset_ref,
	    #                                             $root_label,
	    #                                             $substring;
	    push @first_entry, {offset    => $$mem_offset_ref,
				label     => $root_label,
				substring => $substring};
	} else {
	    #printf STDERR "first entry2: %d %d %s %s\n", $#first_entry,
	    #                                             $$mem_offset_ref,
	    #                                             sprintf($label_format, join("_", @$position)),
	    #                                             $substring;
	    push @first_entry, {offset    => $$mem_offset_ref,
				label     => sprintf($label_format, join("_", @$position)),
				substring => $substring};
	}
    }

    my $is_first_line = 1;
    foreach my $string_index (0..($#strings)) {
	my $string    = $strings[$string_index];
	my $nt_string = $string;
	chomp($nt_string);
	my $combo_string = $substring . $nt_string;

	#Determine left column
	my $left_col = "";
	if ($is_first_line) {
	    if ($#{$position} < 0) {
		#$left_col = sprintf($label_format, "TOP");
		$left_col = $root_label;
	    } else {
		$left_col = sprintf($label_format, join("_", @$position));
	    }
	    $is_first_line = 0;
	}

	#Print substring entry
	if ($nt_string eq $string) {
	    #String is not terminated
	    if ($nt_string !~ /\"/) {
		printf FILEHANDLE $instr_form_nc, $left_col, "FCS", sprintf("\"%s\"", $nt_string);
		$$mem_offset_ref += scalar(split("", $string));
	    } else {
		printf FILEHANDLE $instr_form_nc, $left_col, "FCS", sprintf("\'%s\'", $nt_string);
		$$mem_offset_ref += scalar(split("", $string));
	    }
	    printf FILEHANDLE $instr_form_nc, "", "DB", "BRANCH";
	    $$mem_offset_ref += 1;
	    printf FILEHANDLE $instr_form, "", "DW", sprintf($label_format, join("_", @$position, $string_index)), sprintf("%s...", $combo_string);
	    $$mem_offset_ref += 2;
	    
	    #Optimize subtree order
	    if ($subtree_reordered) {
		#Already reordered
		push @subtree_order, $string_index;
	    } else {
		#Check if reordering is possible
		if (exists $tree->{$string}->{"\n"}) {
		    unshift @subtree_order, $string_index;
		    $subtree_reordered = 1;
		} else {
		    push @subtree_order, $string_index;
		}
	    }

	} else {
	    #String is not terminated
	    my $cfa_entry;
	    my $cfa_entry = sprintf("%s>>1", );
	    my $cfa_entry = sprintf("%s>>1", );
	    if ($tree->{$string}->{is_immediate}) {
		#Immediate
		$cfa_entry = sprintf("(%s>>1)|IMMEDIATE", $tree->{$string}->{cfa_name});
	    } else {	
		#Not immediate
		$cfa_entry = sprintf("(%s>>1)", $tree->{$string}->{cfa_name});
	    }       	    
	    if (length($nt_string) > 0) {
		#Non-zero length
		if ($nt_string !~ /\"/) {
		    printf FILEHANDLE $instr_form_nc, $left_col, "FCS", sprintf("\"%s\"", $nt_string);
		    $$mem_offset_ref += scalar(split("", $string));
		} else {
		    printf FILEHANDLE $instr_form_nc, $left_col, "FCS", sprintf("\'%s\'", $nt_string);
		    $$mem_offset_ref += scalar(split("", $string));
		}
		#printf FILEHANDLE $instr_form_nc, "", "DB", "STRING_TERMINATION";
	    } else {
		printf FILEHANDLE $instr_form_nc, $left_col, "DB", "EMPTY_STRING";
		$$mem_offset_ref += 1;
	    }
	    printf FILEHANDLE $instr_form, "", "DW", $cfa_entry, sprintf("-> %s", $combo_string); 
	    $$mem_offset_ref += 2;
	}
	$left_col = "";
    }

    #Print substree termination
    if ($subtree_reordered) {
  	#printf FILEHANDLE $instr_form, "", ";DB", "END_OF_BRANCH", "merged";
	#$$mem_offset_ref += 1;
 	printf FILEHANDLE $instr_form_nc, "", ";DB", "END_OF_BRANCH";
	$$mem_offset_ref += 1;
    } else {
	printf FILEHANDLE $instr_form_nc, "", "DB", "END_OF_BRANCH";
        $$mem_offset_ref += 1;
    }
  	
    #Print next level of subtrees
    foreach my $string_index (@subtree_order) {
	my $string       = $strings[$string_index];
	my $combo_string = $substring . $string;
	chomp($combo_string);
	#printf FILEHANDLE "String:   %s\n", "$string";
	#printf FILEHANDLE "Position: %s\n", join(",", @{$position}, $string_index);

	#Print subtree
	print_tree($tree->{$string}, $combo_string, [@{$position}, $string_index], $mem_offset_ref);
    }
    1;
}

####################
# Print init macro #
####################
sub print_init_macro {
    my $tree_depth   = get_tree_depth(\%dict_tree);
    my @init_offsets = @first_entry;
    
    foreach my $level (0...$tree_depth) {
	if ($#init_offsets >= 0) {
	    my $entry = shift @init_offsets;
	    printf FILEHANDLE "                        %-30s;%s\n", sprintf("MOVW #(\\1+\$%.2X), \(\\3+\$%.2X),\\2", $entry->{offset}, (2*$level)),
    	                                                            sprintf("%-20s(\"%s\")", $entry->{label}, $entry->{substring});
	} else {
	    printf FILEHANDLE "                        %-30s;\n",   sprintf("MOVW #NULL,     \(\\3+\$%.2X),\\2", (2*$level)),
	}
    }
}

1;
