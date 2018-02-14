#!/usr/bin/env perl
###############################################################################
# S12CForth - Forth to ASM Compiler                                           #
###############################################################################
#    Copyright 2015 Dirk Heisswolf                                            #
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
#   19 Februuary, 2015                                                        #
#      - Initial release                                                      #
###############################################################################

#################
# Perl settings #
#################
#use warnings;
#use strict;
use 5.005;
use FindBin qw($RealBin);
use lib $RealBin;
use lib "$RealBin/../HSW12/Perl";

####################
# create namespace #
####################
package forth2asm_comp;

###########
# modules #
###########
#use IO::File;
#use Fcntl;
#use Text::Tabs;
#use File::Basename;

#############
# constants #
#############
###################
# word properties #
###################
*word_prop_none      = \0;
*word_prop_immediate = \1;
*word_prop_hidden    = \2;
*word_prop_redefined = \4;

#################
# input formats #
#################
*forth_header_line          = \qr/^\\\s(.*)\s*$/;                          #$1:comment
*forth_comment_line         = \qr/^\s*\\\s(.*)\s*$/;                       #$1:comment
*forth_commented_code       = \qr/^\s*([^\\]*)\s+\\\s(.*)\s*$/;            #$1:code $2:comment
*forth_io_spec              = \qr/^\s*(.*)\s+(\(.*--.*\))\s+(.*)$/;        #$1:code $2:io spec $3:code




*forth_inline_comment_start = \qr/^\s*\(\s*$/;
*forth_inline_comment_end   = \qr/^\s*\)\s*$/;
*forth_dict_attr_first      = \qr/ASM:\s+(.+)/i;
*forth_dict_attr_all        = \qr/ASM:.*\s+HIDDEN/i;
*forth_dict_attr_immediate  = \qr/ASM:.*\s+IMMEDIATE/i;
*forth_dict_attr_hidden     = \qr/ASM:.*\s+HIDDEN/i;

*forth_io_spec              = \qr/\s+(\(\s[^\(\)\\]*--[^\(\)\\]*\s\))\s/;  #$1:i/o spec   

##################
# output formats #
##################
*asm_major_comment = \";%s\n";#"                                     #1:comment
*asm_word_header   = \";WORD: %-20s %s\n";#"                         #1:name 2:attributes 
*asm_line          = \"%-20s DW %-20s;%-20s %s\n";#"                 #1:label 2:code 3:word 4:comment

#################
# compile states #
#################
*state_interpret    = \0;
*state_compile      = \1;

###############
# forth words #
###############



*word_decimal      = \qr/^\s*decimal\s*$/i;
*word_hex          = \qr/^\s*hex\s*$/i;
*word_constant     = \qr/^\s*constant\s*$/i;



*word_allot        = \qr/^\s*allot\s*$/i;
*word_variable     = \qr/^\s*variable\s*$/i;
*word_create       = \qr/^\s*create\s*$/i;
*word_colon        = \qr/^\s*:\s*$/i;
*word_comma        = \qr/^\s*:\s*$/i;

#compilation
*word_if           = \qr/^\s*if\s*$/i;
*word_else         = \qr/^\s*else\s*$/i;
*word_then         = \qr/^\s*then\s*$/i;
*word_do           = \qr/^\s*do\s*$/i;
*word_loop         = \qr/^\s*loop\s*$/i;
*word_plus_loop    = \qr/^\s*+loop\s*$/i;
*word_begin        = \qr/^\s*begin\s*$/i;
*word_until        = \qr/^\s*until\s*$/i;
*word_while        = \qr/^\s*while\s*$/i;
*word_repeat       = \qr/^\s*repeat\s*$/i;
*word_case         = \qr/^\s*case\s*$/i;
*word_endcase      = \qr/^\s*endcase\s*$/i;
*word_of           = \qr/^\s*of\s*$/i;
*word_endof        = \qr/^\s*endof\s*$/i;

###############
# code fields #
###############
*cf_constant       = \"CF_CONSTANT_RT";#"

    
###############
# constructor #
###############
sub new {
    my $proto            = shift @_;
    my $class            = ref($proto) || $proto;   
    my $dict             = shift @_;
    my $forth_file       = shift @_;
    my $self             = {};

    #initalize global variables
    $self->{dict}        = $dict;
    $self->{forth_file)  = $forth_file
    
    #reset remaining global variables
    $self->{error}       = "";
    $self->{compilation} = [];
    
    #instantiate object
    bless $self, $class;
      
    #parse Forth code
    $self->parse_forth()
    
    return $self;
}

##############
# destructor #
##############
sub DESTROY {
    my $self = shift @_;

}

##################
# parse ASM code #
##################
sub compile_forth {
    my $self = shift @_;
    #file I/O
    my $file_handle;

    ####################
    # check forth file #
    ####################
    if (-e $self->{forth_file}) {
	if (-r $self->{forth_file}) {
	    if ($file_handle = IO::File->new($file, O_RDONLY)) {
		####################
		# parse forth file #
		####################
		$self->{file_header) = [];
		my $parsed_code      = ();
		my $is_header        = 1;
		my $line_count       = 0;
		my @comment_lines    = ();
			
		$Text::Tabs::tabstop = 8;              #tab length
		while (my $line = <$file_handle>) {
		    #condition line
		    chomp $line;                       #trim line
		    $line =~ s/\s*$//;                 #remove white space
		    $line = Text::Tabs::expand($line); #replace tabs
		    #print STDERR "Line: $line\n";

		    #increment line count
		    $line_count++;

		    ##################
		    # capture header #
		    ##################
		    if ($is_header) {
			if ($line =~ $forth_header) {
			    push @{$self->{file_header)}, $line;
			    next;
			} else {
			    $is_header = 0;
			}
		    } else {
			#########################
			# capture comment lines #
			#########################
			if ($line =~ $forth_comment_line) {
			    push @comment_lines, $line;
			} else {			
			    ########################
			    # extract code comment #
			    ########################
			    my $code_comment = "";
			    if ($line =~ $forth_commented_code) {
				$line = $1;
				$code_comment
			    }
		    
			    ###################
			    # extract IO spec #
			    ###################
			    my $io_spec = "";
			    if ($line =~ $forth_io_spec) {
				$line    = sprintf("%s %s", $1, $3);
				$io_spec = $2;
			    }
			    
			    #################
			    # extract words #
			    #################			    
			    foreach my $word split(/\s+/, $line) {
				my $code_entry = {word       => $word,
						  line_count => $line_count}; 
				if ($#comment_lines >= 0) {
				    $code_entry->{comment_lines} = [@comment_lines];
				    @comment_lines               = ();
				}
				if ($code_comment !~ /\s*/) {
				    $code_entry->{code_comment} = $code_comment;
				    $code_comment               = "";
				}
				if ($io_spec !~ /\s*/) {
				    $code_entry->{io_spec} = $io_spec;
				    $io_spec               = "";
				}
				push @parsed_code, $code_entry;
			    }
			}
		    }
		}
		$file_handle->close();

		#######################
		# compile parsed code #
		#######################
		my $base          = 10;
		my $state         = $state_interpret
		my @stack         = ();
		my $current_word  = "";
		my $current_label = "";
	
		my $i  = 0;
		while ($i <= $#parsed_code) {
		    $word = $parsed_code[$i]->{word};
		    #####################
		    # interpreted words #
		    #####################
		    if ($state == $state interpret) {
			for ($word) {
			    /$word_decimal/ && do {
				#DECIMAL
				$base = 10;
				last;};
			    /$word_hex/ && do {
				#HEX
				$base = 16;
				last;};
			    /$word_constant/ && do {
				#CONSTANT
				if ($#stack >= 0) {
				    


		    

		};

    #compiler variables
    my $current_word  = "";
    my $current_label = "";











	    my $code_string    = "";
		    my $comment_string = "";
		    if ($line =~ $forth_commented_code) {
			$code_string    = $1;
			$comment_string = $2;
			#push @comments, $comment_string;
		    } else {
			$code_string    = $line;
		    }
		    
		    ###############
		    # parse words #
		    ###############
		    foreach my $word (split(/\s+/, $code_string)) {
			##########################
			# handle inline comments #
			##########################
			if ($word =~ $forth_inline_comment_start) {
			    $inline_comment = 1;
			    next;
			}
			if ($word =~ $forth_inline_comment_end) {
			    $inline_comment = 0;
			    next;
			}
			
			#############
			# interpret #
			#############
			if ($parse_state == $parse_interpret) {
			    for ($word) {
				/$word_decimal/ && do {
				    #DECIMAL
				    $base = 10;
				    last;};
				/$word_hex/ && do {
				    #HEX
				    $base = 16;
				    last;};
				/$word_constant/ && do {
				    #CONSTANT
				    $parse_state == $parse_get_constant_name;
				    if ($comment_string !~ /^\s*/$/) {
					push @comments, $comment_string;
				    }   
				    push @compilations {code_field => $cf_constant,
							comments   => [@comments],
							hidden     => ($comment_string =~ 


				    
                                last;};










###############################
# parse dictionary attributes #
###############################
sub get_dict_attr_label {
    my $self           = shift @_;
    my $comment_string = shift @_;
    #parse attribures
    $comment_string =~ ;





							














			
 elsif ($word =~ $forth_inline_comment_end) {






			if ($word =~ $forth_inline_comment_start) {
			    $inline_comment = 1;
			} elsif ($word =~ $forth_inline_comment_end) {
			    $inline_comment = 0;
			} elsif (! $inline_comment) {			    
			    my $word_entry = {word       => $word,
					      line       => $line,
					      line_count => $line_count,
					      comments   => [@comment_buffer]};
			    if ($io_spec !~ /^\s*$/) {
				$word_entry->{io_spec} = $io_spec;
			    }  
			    push @parsed_code $word_entry;
			    @comment_buffer = ();
			}
		    }
		    $io_spec = "";
		}
		close $file_handle;
		
		#############
		# interpret #
		#############
		my $parse_state     = $parse_state_interpret;
		my $base            = 10;
		my $parameter_stack = ();
		my @variables       = ();
		my @words           = ();
				
		for (my $i==0;
		        $i <= parsed_code;
		        $i++) {
		    $word_entry = @parsed_code[$i];
		    if ($parse_state == $parse_state_interpret} {
			#Interpretation
			for ($word_entry->{word}) {
			    /$word_decimal/ && do {
				#DECIMAL
				$base = 10;
                                last;};
			    /$word_hex/ && do {
				#HEX
				$base = 16;
                                last;};
			    /$word_variable/ && do {
				#VARIABLE
				#get next word
				my $next_entry = @parsed_code[++$i];
				

				
                               last;};

			    /$word_constant/ && do {
				#CONSTANT


                               last;};





			


		    } else {
			#Compilation






			
			
		    }
		}

		
			
						

		


	    } else {
		$self->{error} = sprintf("unable to open \"%s\" (%s)", $self->{forth_file}, $!);
 	    }
	} else {
	    $self->{error} = sprintf("file \"%s\" is not readable", $self->{forth_file});
	}
    } else {
	$self->{error} = sprintf("file \"%s\" does not exist", $self->{forth_file});
    }
}

    
    ###########################
    # parse ASM code for CFAs #
    ###########################
    foreach my $code_entry (@{$self->{asm_code}->{code}}) {	
	#my $code_line     = $code_entry->[0];
	#my $code_file     = $code_entry->[1];
	my $code_comments = $code_entry->[2];
	my $code_label    = $code_entry->[3];
	#my $code_opcode   = $code_entry->[4];
	#my $code_args     = $code_entry->[5];
	#my $code_pc_lin   = $code_entry->[6];
	#my $code_pc_pag   = $code_entry->[7];
	#my $code_hex      = $code_entry->[8];
	#my $code_byte_cnt = $code_entry->[9];
	#my $code_macros   = $code_entry->[11];
	#my $code_sym_tabs = $code_entry->[12];

	#printf STDERR "Label: \"%s\"\n", $code_label;
	#Word must begin with "CFA_" label
	if ($code_label =~ /^CFA_/) {		
	    #printf STDERR "CFA found: \"%s\"\n", $code_label;

	    #Word must contain the comment line: ;Word: <name> ... HIDDEN ... IMMEDIATE"
	    my $name_string  = "";
	    my $properties   = 0;
	    foreach my $code_comment (@{$code_comments}) {
		#printf STDERR "Comment: \"%s\"\n", $code_comment;
		if ($code_comment =~ /^;Word:\s+(\S+)/) {
		    $name_found   = 1;
		    $name_string  =  uc($1);
		    #$name_string =  $1;     //case sensitive naming
		    if ($code_comment =~ /^;Word:\s+\S+\s+.*IMMEDIATE\s*$/) {
			$properties |= $word_prop_immediate;
		    }
		    if ($code_comment =~ /^;Word:\s+\S+\s+.*HIDDEN\s*$/) {
			$properties |= $word_prop_hidden;
		    }
		    #save word
		    $self->{asm_words}->{$name_string) = [$code_label, $properties];
		    last;
		}
	    }	    
	}
    }
}

###############################
# turn name into an ASM label #
###############################
sub name_to_label {
    my $self = shift @_;
    my $name = shift @_;

    ################
    # convert name #
    ################
    my $label = uc($name);       #make uppercase
    $label =~ /^\./DOT_/;        #leading dot
    $label =~ /\.$/_DOT/;        #trailing dot
    $label =~ /^\?/QUESTION_/;   #leading question mark
    $label =~ /\?$/_QUESTION/;   #trailing question mark
    $label =~ /\?$/_QUESTION/;   #trailing question mark

    return $label;
}

##########################
# add word to dictionary #
##########################
sub add_word {
    my $self       = shift @_;
    my $name       = shift @_;
    my $properties = shift @_;
    my $label      = shift @_;
    my $ok         = 1;
    
    #make case insensitive
    $name  = uc($name);
    $label = uc($label);

    #set last word
    $self->{last_word} = $name;
    
    #check if word already exists
    if ((exists $self->{asm_words}->{$name}) ||
	(exists $self->{forth_words}->{$name})) {
	$properties |= $word_prop_redefined;
	$ok          = 0;
    }

    #add word
    $self->{forth_words}->{$name) = [$label, $properties];
        
    return $ok;
}

############################
# make last word immediate #
############################
sub last_word_Immediate {
    my $self       = shift @_;

    if (exists $self->{forth_words}->{$self->{last_word}}) {
	$self->{forth_words}->{$self->{last_word}}->[1] |= $word_prop_redefined;
    }
}






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
@asm_files         = ();
@lib_files         = ();
%defines           = ();
@forth_files       = ();
$asm_output_path   = ();
$asm_prog_name     = "";
$forth_output_path = ();
$forth_prog_name   = "";
$arg_type          = "none;
$srec_format       = $hsw12_asm::srec_def_format;
$srec_data_length  = $hsw12_asm::srec_def_data_length;
$srec_add_s5       = $hsw12_asm::srec_def_add_s5;
$srec_word_entries = 1;
$command_file_name = "";
$symbols           = {};
$code              = {};
$comp_symbols      = {};
$pag_addrspace     = {};

%compile_words     = ();
%immediate_words   = ();

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
    } elsif ($arg =~ /^\s*\-A\s*$/i) {
	$arg_type = "asm";
    } elsif ($arg =~ /^\s*\-F\s*$/i) {
	$arg_type = "forth";
    } elsif ($arg =~ /^\s*\-/) {
	#ignore
    } elsif ($arg_type eq "asm") {
	#ASM file
	push @asm_files, $arg;
    } elsif ($arg_type eq "forth") {
	#Forth file
	push @forth_files, $arg;
    } elsif ($arg_type eq "lib") {
	#library path
	if ($arg !~ /\/$/) {$arg = sprintf("%s/", $arg);}
	unshift @lib_files, $arg;
    } elsif ($arg_type eq "def") {
	#precompiler define
	if ($arg =~ /^\s*(\w+)=(\w+)\s*$/) {
	    $defines{uc($1)} = $2;
	} elsif ($arg =~ /^\s*(\w+)\s*$/) {
	    $defines{uc($1)} = "";
	}
    }
}

###################
# print help text #
###################
if ($#asm_files < 0) {
    printf "usage: %s [-L <library path>] [-D <define: name=value or name>] -A <ASM files> -F <Forth files> \r\n", $0;
    print  "\r\n";
    exit;
}

###################
# add default lib #
###################
#printf "libraries:   %s (%s)\r\n",join("\", \"", @lib_files), $#lib_files;
#printf "asm files:   %s (%s)\r\n",join("\", \"", @asm_files), $#asm_files;
#printf "forth files: %s (%s)\r\n",join("\", \"", @forth_files), $#forth_files;
if ($#lib_files < 0) {
  foreach my $asm_file (@asm_files) {
    #printf "add library:%s/\r\n", dirname($asm_file);
    push @lib_files, sprintf("%s/", dirname($asm_file));
  }
  foreach my $forth_file (@forth_files) {
    #printf "add library:%s/\r\n", dirname($forth_file);
    push @lib_files, sprintf("%s/", dirname($forth_file));
  }
}

#######################################
# determine program name and location #
#######################################
$asm_prog_name     = basename($asm_files[0], ".s");
$asm_output_path   = dirname($asm_files[0],  ".s");
$forth_prog_name   = basename($asm_files[0], ".4th");
$forth_output_path = dirname($asm_files[0],  ".4th");

####################
# load symbol file #
####################
$symbol_file_name = sprintf("%s/%s.sym", $asm_output_path, $asm_prog_name);
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
#printf STDERR "asm files: \"%s\"\r\n", join("\", \"", @asm_files);  
#printf STDERR "lib files: \"%s\"\r\n", join("\", \"", @lib_files);  
#printf STDERR "defines:   \"%s\"\r\n", join("\", \"", @defines);  
$code = hsw12_asm->new(\@asm_files, \@lib_files, \%defines, "S12", 1, $symbols);

###################
# write list file #
###################
$list_file_name = sprintf("%s/%s.lst", $asm_output_path, $asm_prog_name);
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
    #$symbol_file_name = sprintf("%s/%s.sym", $asm_output_path, $asm_prog_name);
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
	    
	    #Word must contain the comment line: ;Word: <name> ... IMMEDIATE"
	    my $name_string  = "";
	    my $name_found   = 0;
	    my $is_immediate = 0;
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
		    last;
		}
	    }	    
	    if ($name_found) {
		#printf STDERR "      \"%s\" %s\n", $name_string, $is_immediate ? "-> IMMEDIATE" : "";;
		
		if ($is_immediate) {
		    $immediate_words{$name_string} = $code_label;
		} else {
		    $compile_words{$name_string) = $code_label;
		}
	    }
	}
    }

    #####################
    # parse forth files #
    #####################
    foreach my $forth_file (@forth_files) {
	my $file_name;
        ############################
        # determine full file name #
        ############################
        #printf "forth_file: %s\n", $forth_file;
        if ($forth_file =~ /$path_absolute/) {
           #asolute path
	   #printf STDERR "absolute path: %s\n", $file_name;
            $file_name = $forth_file;
	} else {
	    #relative path
	    foreach my $library_path (@$library_list) {
		$file_name = sprintf("%s%s", $library_path, $forth_file);
		#printf STDERR "relative path: %s\n", $file_name;
		if (-e $file_name) {
		    last;
		} else {
		    $file_name = $forth_file;
		}
	    }	    
	    #printf STDERR "relative path: %s\n", $file_name;
	}

        ###################
        # open forth file #
        ###################
	if (-e $file_name) {
	    if (-r $file_name) {
		if (open (FILEHANDLE, sprintf("<%s", $file_name))) {




























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
        printf FILEHANDLE ";###############################################################################\n"; 
        printf FILEHANDLE ";# S12CForth - Search Tree for the Core Dictionary                             #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";#    Copyright 2009-2013 Dirk Heisswolf                                       #\n";
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

	#Macro label
        printf FILEHANDLE "\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Macros                                                                      #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE "\n";

	#Print tree
        printf FILEHANDLE "#ifndef FCDICT_TREE_EXTSTS\n";
        printf FILEHANDLE "FCDICT_TREE_EXISTS      EQU     1\n";
	printf FILEHANDLE "\n";
        printf FILEHANDLE ";Global constants\n";
        printf FILEHANDLE "FCDICT_TREE_DEPTH       EQU     %d\n", get_tree_depth(\%dict_tree);
 	printf FILEHANDLE "\n";
        printf FILEHANDLE ";Dictionary tree\n";
        printf FILEHANDLE "#macro       FCDICT_TREE, 0\n";
        printf FILEHANDLE ";Local constants\n";
        #printf FILEHANDLE "STRING_TERMINATION      EQU     \$00\n";
        printf FILEHANDLE "EMPTY_STRING            EQU     \$00\n";
        printf FILEHANDLE "BRANCH                  EQU     \$00\n";
        printf FILEHANDLE "END_OF_BRANCH           EQU     \$00\n";
        printf FILEHANDLE "IMMEDIATE               EQU     \$8000\n";
        #printf FILEHANDLE "\n";
	print_tree(\%dict_tree, "", []);
        printf FILEHANDLE "#emac\n";
        printf FILEHANDLE "#endif\n";
 
	close FILEHANDLE;
    } else {
	printf STDERR "Can't open output file \"%s\"\r\n", $nfa_tree_file_name;
	exit;
    }
}
















		

1;
