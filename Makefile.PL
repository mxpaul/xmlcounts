use ExtUtils::MakeMaker;

WriteMakefile(
	NAME              => "XML::Counts",
	VERSION_FROM      => "lib/XML/Counts.pm",
	EXE_FILES         => ["bin/xmlcounts.pl"],
);
