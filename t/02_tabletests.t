#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin); use lib ("$Bin/../lib");

use Test::More;
use Test::Deep;
use Carp qw(croak);
use Data::Dumper;

use XML::Counts;

#my $valid_xml = q{<html xmlns="https://www.w3.org/1999/xhtml"/>};
my $valid_xml = q{<?xml version="1.1"?><_/>};

sub table_tests_run {
	my $funcname = shift or croak 'need function name';
	my $cases = shift; croak "need cases array" unless ref $cases eq 'ARRAY';
	for my $case (@$cases) {
		croak "need cases to be a HASH" unless ref $case eq 'HASH';
		croak 'need desc key for case' unless exists $case->{desc};
		croak 'need input array for case '. $case->{desc} unless ref $case->{input} eq 'ARRAY';
		croak 'need want hash' unless ref $case->{want} eq 'HASH';
		my $desc = sprintf('%s when %s', $funcname, $case->{desc});
		open my $f, '<', \$case->{input}[0] or croak "open input fd: $!";
		#my $old = $Word::Count::MAXREAD;
		#$Word::Count::MAXREAD = $case->{maxread} if $case->{maxread};
		my $got = do {no strict 'refs'; &$funcname($f)};
		#$Word::Count::MAXREAD = $old;
		close($f);
		cmp_deeply($got, $case->{want}, $desc) or diag Dumper $got;
	}
}


my @cases = (
	{ desc => 'smallest xml',
		input => [$valid_xml],
		want => {Letters => 0, NormalizedLetters => 0, Links => 0, BrokenLinks => 0, Error => 0},
	},
	{ desc => 'one of each',
		input => [q{<?xml version="1.1"?><a l:href="#broken">1</a>}],
		want => {Letters => 1, NormalizedLetters => 1, Links => 1, BrokenLinks => 1, Error => 0},
	},
);

table_tests_run('counts_from_fd', \@cases);
done_testing;
