package XML::Counts;

our $VERSION = v0.01;

use parent qw(Exporter);
our @EXPORT = our @EXPORT_OK = qw(counts_from_file counts_from_fd);

use XML::Parser;

sub counts_from_fd {
	my $fd = shift;

	my (@links, %ids);
	my $res = {Letters => 0, NormalizedLetters => 0, Links => 0, BrokenLinks => 0, Error => 0};

	#my @names = qw(Element Proc Comment CdataStart CdataEnd Notation Default);
	my %handlers ;#= map { my $n = $_; $n => sub { my $e = shift; warn "$n: " . Dumper \@_; }} @names;
	$handlers{Char} = sub {
		my ($d, $content) = (shift, shift);
		my $len_decoded = length($content);
		$res->{Letters}++ while $content =~ /\S/g;
		$res->{NormalizedLetters} += $len_decoded;
	};

	$handlers{Start} = sub {
		my ($d, $tag, %attr) = (shift, @_);
		if ($attr{qq{l:href}}) { push @links, $attr{qq{l:href}} }
		if ($attr{id}) { $ids{$attr{id}} = $tag }
	};

	my $decoder = XML::Parser->new(Handlers=> \%handlers);
	$decoder->parse($fd);

	$res->{BrokenLinks} = grep { s/^#// && !exists $ids{$_} } @links;
	$res->{Links} = 0+ @links;
	return $res;
}

sub counts_from_file {
	my $fname = shift;
	stat $fname;
	return {Error => "File not found: $fname" } unless -e _;
	return {Error => "File is not readable: $fname" } unless -r _;
	return {Error => "File is not a regular file: $fname" } unless -f _;
	open my $f, '<', $fname or return { Error => "open $fname error: $!"};
	my $res = counts_from_fd($f);
	close $f;
	return $res;
}

1;
