#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper;
use XML::Parser;
use feature 'say';

die "Want filename arg" unless @ARGV > 0;
my $file_name = shift @ARGV;
stat $file_name;
die "File not found: $file_name" unless -e _;
die "File is not readable: $file_name" unless -r _;
die "File is not a regular file: $file_name" unless -f _;

my (@links, %ids);
my ($cnt_letters, $cnt_normalized) = (0, 0);

my $decoder = XML::Parser->new();

#my @names = qw(Element Proc Comment CdataStart CdataEnd Notation Default);
my %handlers ;#= map { my $n = $_; $n => sub { my $e = shift; warn "$n: " . Dumper \@_; }} @names;
$handlers{Char} = sub {
	my ($d, $content) = (shift, shift);
	my $len_decoded = length($content);
	$cnt_letters ++ while $content =~ /\S/g;
	$cnt_normalized += $len_decoded;
	#utf8::encode($content);
	#my $len_encoded = length($content);
	#warn sprintf("CHAR: [%d:%d] %s", $len_decoded, $len_encoded, $content) if $content =~ /gt;/;
};

$handlers{Start} = sub {
	my ($d, $tag, %attr) = (shift, @_);
	if ($attr{qq{l:href}}) { push @links, $attr{qq{l:href}} }
	if ($attr{id}) { $ids{$attr{id}} = $tag }
};

$decoder->setHandlers(%handlers);
$decoder->parsefile($file_name);

my $broken_links_cnt = grep { s/^#// && !exists $ids{$_} } @links;

say sprintf("Letters: %d; Normalized text length: %d; Links: %d; broken links: %d;",
	$cnt_letters, $cnt_normalized, 0+@links, $broken_links_cnt,
);

