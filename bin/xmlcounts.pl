#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Data::Dumper;
use feature 'say';

use XML::Counts;

my $file_name = shift @ARGV or die "Want filename arg";

my $c = counts_from_file($file_name);
die "Error: $c->{Error}" if $c->{Error};

say sprintf("Letters: %d; Normalized text length: %d; Links: %d; Broken links: %d;",
	@{$c}{qw(Letters NormalizedLetters Links BrokenLinks)},
);

