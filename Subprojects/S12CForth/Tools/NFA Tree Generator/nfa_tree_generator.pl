#!/usr/bin/env perl
###############################################################################
# S12CForth - NFA Tree Generator                                              #
###############################################################################
#    Copyright 2012 Dirk Heisswolf                                            #
#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
#    family.                                                                  #
#                                                                             #
#    S12CBase is free software: you can redistribute it and/or modify         #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    S12CBase is distributed in the hope that it will be useful,              #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #
###############################################################################
# Description:                                                                #
#    This perl script generates the assembler source of a search tree (incl.  #
#    parser) for the S12CForth CORE NFAs.                                     #
###############################################################################
# Version History:                                                            #
#    8 January, 2013                                                          #
#      - Initial release                                                      #
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
$initial_pc;

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

###################
# add default lib #
###################
#printf "libraries:    %s (%s)\n",join("\", \"", @lib_files), $#lib_files;
#printf "source files: %s (%s)\n",join("\", \"", @src_files), $#src_files;
if ($#lib_files < 0) {
  foreach $src_file (@src_files) {
    #printf "add library:%s/\n", dirname($src_file);
    push @lib_files, sprintf("%s/", dirname($src_file));
  }
}

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

    #########################
    # write NFA search tree #
    #########################
    $nfa_tree_file_name = sprintf("%s/fcore_nfa_tree.s", $output_path);

    if (open (FILEHANDLE, sprintf(">%s", $nfa_tree_file_name))) {

	#Print header
	#------------ 
        printf FILEHANDLE ";###############################################################################\n"; 
        printf FILEHANDLE ";# S12CForth - NFA Search Tree for CORE Words                                  #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";#    Copyright 2009-2012 Dirk Heisswolf                                       #\n";
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
        printf FILEHANDLE ";# Generated on %3s, %3s %.2d %4d                                              #\n", $days[$wday], $months[$mon], $mday, $year;
        printf FILEHANDLE ";###############################################################################\n";

	#Parse code for CFAs
	#------------------- 
        foreach $code_entry (@{$self->{code}}) {

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

	    #CFA label must begin with "CFA_"
	    if ($code_label =~ /^CFA_/) {
		
		printf STDERR, "Found %s\n", $code_label;

		#Parse comment for name string
		foreach $code_comment (@{$code_comments}) {
		    if ($code_comment =~ /Word:\ (\S+)/) {
			$word_string  =  uc($1);

			printf STDERR, "      \"%s\" %s\n", $word_string, $is_immediate ? "-> IMMEDIATE" : "";;

			#Check if word is immediate
			if ($code_comment =~ /Word:\ \S+\s.*immediate/i) {
			    $is_immediate = 1;
			} else {
			    $is_immediate = 0;
			}

			#Split Word
			@word_array = split("", $word_string);

			#Consider termination
			$word_char = pop @word_array;
			push @word_array, sprintf("%S_t", $word_last);
			
			#Build tree
			add_to_tree(\%NFA_tree, \@word_array, \$code_label, $is_immediate);
		    }
		}

	    }
	}
	
	close FILEHANDLE;
    } else {
	printf STDERR "Can't open output file \"%s\"\r\n", $nfa_tree_file_name;
	exit;
    }
}

1;

####################
# Add_word to tree #
####################
sub add_to_tree {
    my $tree           = shift @_;
    my $word_array     = shift @_;
    my $cfa_name       = shift @_;
    my $is_immediate   = shift @_;

    my @tmp_array      = @$word_array;
    my $tmp_char       = shift @tmp_array;

    #Consider termination
    if ($#tmp_array >= 0) {
	$tree->{sprintf("%s_t", $tmp_char)}->{cfa_name}     = $cfa_name;
	$tree->{sprintf("%s_t", $tmp_char)}->{is_immediate} = $is_immediate;
    } else {
	if (! exists $tree->{$tmp_char}) {
	    $tree->{$tmp_char} = {};
	}
	add_to_tree($tree->{$tmp_char}, \@tmp_array, $cfa_name, $is_immediate);
    }
    1;
}





