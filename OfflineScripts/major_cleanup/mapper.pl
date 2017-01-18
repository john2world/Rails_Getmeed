#!/usr/bin/env perl

use strict;
use warnings;
use Modern::Perl;
use Text::CSV;
use Text::Trim;
use String::Similarity;
use Getopt::Long::Descriptive;
use Data::Dumper;

my ($fdata, $fmap, $data_colname, $type_colname, $fout, $fout_disc, $fout_majors);
my $csv = Text::CSV->new({ binary => 1 })  # should set binary attribute.
		or die "Cannot use CSV: " . Text::CSV->error_diag();

#=================#
# Parsing options #
#=================#

# Sample command
#perl mapper.pl --am huge.amap -d final_unc.csv --tc affiliation --tm Student --dc major
# prints program usage
sub usage {
		say "Usage: $0 <CSV-file-with-data> <file-with-mappings> " .
				"[column-with-data(default: Department)] " .
				"[column-with-student-type(default: Type)] " .
				"[output-filename(default: <fname>_out.csv)]";
}

my ($opt, $usage) = describe_options(
		"$0 %o <some-arg>",
		[ 'data|d=s', "file with data", { required => 1  } ],
		[ 'map|m=s',   "mapping for majors", { default  => 'majors.txt' } ],
		[
		 'data_colname|dc=s', "data column header(Default: Department)",
		 { default  => 'Department' }
		],
		
		[
		 'type_colname|tc=s', "student/staff type column header(Default: Type)",
		 { default  => 'Type' }
		],

		[
		 'type_match|tm=s', "string that should be in type col(Default: student)",
		 { default  => 'student' }
		],
		
		[
		 'output|o=s', "output filename(Default: '<file-with-data>_out.csv')",
		 # { default  => $opt->data . '_out.csv' }
		],
		
		[
		 'discarded|od=s', "output filename with discarded entries(Default: '<file-with-data>_discarded.csv')",
		 # { default  => $opt->data . '_discarded.csv' }
		],

		[
		 'unmapped|u=s', "output filename with entries without good mapping(Default: '<file-with-data>_new_mappings.csv')",
		 # { default  => $opt->data . '_new_mappings.csv' }
		],

		[
		 'threshold|t=f', "quality threshold",
		 { default  => 0.8 }
		],

		[
		 'add_map|am=s', "additional mapping file",
		 { default  => undef }
		],

		[
		 'null_str|ns=s', "string that used as pacifier for non-matched entries",
		 { default  => 'null' }
		],
		
		[],
		[ 'verbose|v', "print extra stuff(Default: 1)", { default => 1 } ],
		[ 'help|h', "print usage message and exit" ],
		);

usage, exit 0 if $opt->help;

# file with data
$fdata = $opt->data;
# file with mappings
$fmap = $opt->map;
# column with data to process
$data_colname = $opt->data_colname;
# column with type of taken up post
$type_colname = $opt->type_colname;
# output of processing
$fout = $opt->output // $fdata . '_out.csv';
# output file with discarded entries
$fout_disc = $opt->discarded // $fdata . '_discarded.csv';
# output file with discarded entries
$fout_majors = $opt->unmapped // $fdata . '_unknown_majors.csv';

# file names must not be empty and files with such names must exist in FS
usage, die "File '${fdata}' not found" unless $fdata and -r $fdata;
usage, die "File '${fmap}' not found" unless $fmap and -r $fmap;

warn "Seems file '${fdata}' is not a CSV file" unless $fdata =~ /.*\.csv/i;

#===========#
# Functions #
#===========#

# fixes &amp; mgt and so on
sub fix_abbrevs {
		my ($str) = @_;
		$str =~ s/&(amp;)?/And/;
		$str =~ s/\bMgt\b/Management/;
		$str =~ s/\bSch\b/School/;
		$str =~ s/\bPol\b/Polic/;
		$str =~ s/\bPub\b/Public/;

		return $str;
}

sub rm_unneeded_words {
		my ($words) = @_;
		my @words = grep {
				$_ ne '' and
				$_ !~ /^(and|the|,|&amp;)$/i and
				length($_) > 2
		} @$words;
		
		return \@words;
}

sub init_add_mappings {
		my ($fname, $mapping) = @_;
		my ($line, %mp, @mj, @dc, %rm);

		say $fname;
		
		if (open(my $fhamap, "<", $fname)) {
				while ($line = <$fhamap>) {
						next if (trim $line) eq '';

						# break by separator
						my @res = split('->', $line, 2);
						my $add = trim $res[0];

						# entries starting with '#' must be discarded
						if (substr($res[0], 0, 1) eq '#') {
								push @dc, ($res[0] =~ /#\s*(.*)/);
								next;
						} elsif (substr($res[0], 0, 1) eq '/') {
								$res[0] = substr($res[0], 1);
								trim $res[0];
								trim $res[1];
								$rm{$res[0]} = $res[1];
								next;
						}

						my $orig = trim $res[1];

						$mp{$add} = $mapping->{$orig};
						$mp{$add}{'additional'} = 1;
						push @mj, $add;
				}
				close($fhamap);
		}

		return {
				map => \%mp,
				majors => \@mj,
				discard => \@dc,
				rx_map => \%rm,
		}; 
}

# read mappings file
sub init_mappings {
		my ($fmap) = @_;

		my ($line, %mapping, %rx_map, @majors, @discard);
		open(my $fhmap, "<", $fmap) or die "${fmap}: $!";
		while ($line = <$fhmap>) {
				chomp $line;

				# mappings separated with tabulation so we can use it to split string on 2 parts
				my @res = split(/\t/, $line, 2);
				trim $res[0];
				trim $res[1];

				my $orig = fix_abbrevs $res[0];
				$mapping{$orig}{'code'} = $res[1];
				$mapping{$orig}{'major'} = $orig;
				push @majors, $orig;

				# each major name consist of words, but such words as [ and in of the ... ]
				# should be removed
				$mapping{$orig}{'words'} = rm_unneeded_words([ split(/\W/, $orig) ]);
		}
		close($fhmap);

		my $add;
		# local mappings
		$add = init_add_mappings("${fdata}.amap", \%mapping);
		%mapping = (%mapping, %{ $add->{'map'} });
		@majors = (@majors, @{ $add->{'majors'} });
		@discard = (@discard, @{ $add->{'discard'} });
		%rx_map = (%rx_map, %{ $add->{'rx_map'} });

		# global mapping
		if ($opt->add_map) {
				$add = init_add_mappings($opt->add_map, \%mapping);
				%mapping = (%mapping, %{ $add->{'map'} });
				@majors = (@majors, @{ $add->{'majors'} });
				@discard = (@discard, @{ $add->{'discard'} });
				%rx_map = (%rx_map, %{ $add->{'rx_map'} });
		}

		return {
				mapping => \%mapping,
				majors => \@majors,
				discard => \@discard,
				rx_map => \%rx_map,
		};
}

# finds best match for $chunk in @$data
sub find_best_match {
		my ($chunk, $data, $rx_map) = @_;
		my ($bestpat, $maxsim, $index) = ('', -1, -1);
		my $done = 0;

		# REGEXP matching
		if ($rx_map) {
				foreach my $rx (keys %$rx_map) {
						if ($chunk =~ /$rx/) {
								# say "here '$chunk' -> '$rx' -> " . $rx_map->{$rx};
								$done = 1;
								$bestpat = $rx_map->{$rx};
								$maxsim = 1;
								last;
						}
				}
		}

		unless ($done) {
				# simple matching
				foreach my $idx (keys @$data) {
						my $pat = $data->[$idx];
						my $sim = similarity($chunk, $pat);

						if ($sim > $maxsim) {
								$bestpat = $pat;
								$maxsim = $sim;
								$index = $idx;
						}
				}
		}

		return {
				bestpattern => $bestpat,
				index => $index,
				similarity => $maxsim
		};
}

# reads all data from CSV file
sub read_data {
		my ($fdata, $discard) = @_;

		my (@rows, $row, @entries);
		open(my $fhdata, "<", $fdata) or die "${fdata}: $!";;

		# first line is headers
		my $headers = $csv->getline($fhdata);
		
		# type column index

		my $tcidx = indexof($type_colname, $headers);
		my $type_cidx = $tcidx->{'index'};

		my $dcidx = indexof($data_colname, $headers);
		my $data_cidx = $dcidx->{'index'};

		if ($opt->verbose and $tcidx->{'similarity'} < 0.9) {
				say "WARN: type column not properly matches. Asked -> '" .
						$opt->type_colname . "', got -> '" . $headers->[$type_cidx] . "'";
		}

		open(my $fh_disc, ">", $fout_disc) or die "${fout_disc}: $!";;
		$csv->print($fh_disc, $headers);
		say $fh_disc '';

		say $opt->type_match;

		# reading CSV data
		while ($row = $csv->getline($fhdata)) {
				s/\h+/ /m foreach @$row;
				trim foreach @$row;

				#say "data: " . $row->[2] . "-" . $row->[3];

				# we need only students
				# if (similarity($row->[$type_cidx], 'Student') < 0.9) {
				my $tval = $opt->type_match;
				unless ($row->[$type_cidx] =~ /$tval/i) {
						#say "type mismatch";
						# generating file with discarded entries
						$csv->print($fh_disc, $row);
						say $fh_disc "";
						next;
				}
				# skipping entry if no data for it
				unless ($row->[$data_cidx]) {
						# generating file with discarded entries
						$csv->print($fh_disc, $row);
						say $fh_disc "";
						next;
				}

				# using provided discard list
				if ($row->[$data_cidx] ~~ @$discard) {
						#say "discarding";
						$csv->print($fh_disc, $row);
						say $fh_disc "";
						next;
				}

				# selecting only first major of student as it's a most important
				$row->[$data_cidx] = (split(',', $row->[$data_cidx]))[0];
				trim $row->[$data_cidx];

				# fixing &amp; to 'And' and etc
				$row->[$data_cidx] = fix_abbrevs($row->[$data_cidx]);
				
				push @rows, $row;
		}
		close($fout_disc);
		close($fhdata);

		# say Dumper(\@rows);
		
		return {
				headers => $headers,
				rows => \@rows,
				entries => \@entries
		};
}

# finds empty columns in CSV file or creates new ones
sub find_empty {
		my ($how_many, $headers) = @_;
		my (@empty_idx, $i, $got);

		# how many free spaces already gotten
		$got = 0;

		for ($i = 0; $i <= $#{$headers}; $i++) {
				return @empty_idx if $got >= $how_many;
				
				if ($headers->[$i] eq '') {
						push @empty_idx, $i;
						$got++;
				}
		}

		# adding new columns in no other empty ones
		my $from = scalar @$headers;
		my $to = $from + ($how_many - $got) - 1;
		my @range = $from .. $to;
		@empty_idx = (@empty_idx, @range);

		return @empty_idx;
}

# returns ID of column which most approximate to colname
sub indexof {
		my ($colname, $headers) = @_;
		
		# searching best match
		my ($idx, $maxsim) = (-1, -1);
		foreach my $num (keys @$headers) {
				my $sim = similarity($colname, $headers->[$num]);
				
				if ($sim > $maxsim) {
						$maxsim = $sim;
						$idx = $num;
				}
		}

		# say Dumper([$headers, \%idx, $idx]);
		
		return {
				index => $idx,
				similarity => $maxsim
		};
}

sub print_output {
		my ($headers, $rows, $filename) = @_;

		open my $fhout, ">", $filename or die "$filename: $!";
		$csv->print($fhout, $headers);
		say $fhout "";
		$csv->print($fhout, $_), say $fhout "" for @$rows;
		close $fhout;
}

#===================#
# Preparing to work #
#===================#

# initializing mappings from file
my $init = init_mappings($fmap);
my %mapping = %{ $init->{'mapping'} };
my @majors = @{ $init->{'majors'} };
my @for_discard = @{ $init->{'discard'} };
# REGEXP mappings
my %rx_map = %{ $init->{'rx_map'} };
# say Dumper($init);

my $data = read_data($fdata, \@for_discard);
my @headers = @{ $data->{'headers'} };
my @rows = @{ $data->{'rows'} };
my @entries = @{ $data->{'entries'} };
# say Dumper($data);

my ($mm, $mmid, $sim_factor_col, $mmx, $mmidx, $csim, $wsim) = find_empty(7, \@headers);

# data column index
my $dcidx = indexof($data_colname, \@headers);
my $data_cidx = $dcidx->{'index'};
if ($opt->verbose and $dcidx->{'similarity'} < 0.9) {
		say "WARN: data column not properly matches. Asked -> '" .
				$opt->data_colname . "', got -> '" . $headers[$data_cidx] . "'";
}	

#=====================#
# Let's get work done #
#=====================#

$headers[$mm] = "Meed Major";
$headers[$mmid] = "Meed Major Id";

my %unk_map;

# foreach my $row_num (keys @rows) {
foreach my $row (@rows) {
		my $data = $row->[$data_cidx];
		my $bm = find_best_match($data, \@majors, \%rx_map);

		if ($bm->{'similarity'} < $opt->threshold) {
				$unk_map{$data}{'count'}++;
				$unk_map{$data}{'best_match'} = $bm->{'bestpattern'};
				$unk_map{$data}{'similarity'} = $bm->{'similarity'};
				
				$row->[$mm] = $opt->null_str;
				$row->[$mmid] = $opt->null_str;
				
				next;
		}

		$row->[$mm] = $mapping{$bm->{'bestpattern'}}{'major'};
		$row->[$mmid] = $mapping{$bm->{'bestpattern'}}{'code'};
}

if (keys %unk_map) {
		open my $fh_unmap, ">", $fout_majors;
		
		# writing header
		$csv->print($fh_unmap, [ 'Unknown major', 'Sim %',
														 'Best match', 'Number of times seen', ]);
		say $fh_unmap '';

		# writing data
		for (sort keys %unk_map) {
				my $bm = $unk_map{$_}{'best_match'};
				$csv->print($fh_unmap, [ $_, sprintf("%.2f", $unk_map{$_}{'similarity'} * 100),
																 $mapping{$bm}{'major'}, $unk_map{$_}{'count'}, ], );
				say $fh_unmap '';
		}
		
		close $fh_unmap;
}

print_output(\@headers, \@rows, $fout);
