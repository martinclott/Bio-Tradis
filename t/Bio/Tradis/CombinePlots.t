#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp;
use File::Slurp;

BEGIN { unshift( @INC, '../lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Tradis::CombinePlots');
}

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ( $plotfile, $obj );

$plotfile = "t/data/CombinePlots/comb_sample.txt";

ok( $obj = Bio::Tradis::CombinePlots->new( plotfile => $plotfile, _destination  => $destination_directory ),
    'creating object' );

ok( $obj->combine, 'combining plots' );
ok(
    -e 'combined/first.insert_site_plot.gz',
    'checking first combined plot file exists'
);
ok(
    -e 'combined/second.insert_site_plot.gz',
    'checking second combined plot file exists'
);
ok(
	-e 'comb_sample.stats',
	'checking stats file exists'
);

system("gunzip -c combined/first.insert_site_plot.gz > first.test.plot");
is(
    read_file('first.test.plot'),
    read_file('t/data/CombinePlots/first.expected.plot'),
    'checking first file contents'
);
system("gunzip -c combined/second.insert_site_plot.gz > second.test.plot");
is(
    read_file('second.test.plot'),
    read_file('t/data/CombinePlots/second.expected.plot'),
    'checking second file contents'
);
is(
	read_file('comb_sample.stats'),
	read_file('t/data/CombinePlots/comb_expected.stats'),
	'checking stats file contents'
);

#check with gzipped plots
$plotfile = "t/data/CombinePlots/zip_comb_list.txt";

ok( $obj = Bio::Tradis::CombinePlots->new( plotfile => $plotfile, _destination  => $destination_directory ),
    'creating object' );

ok( $obj->combine, 'combining plots' );
ok(
    -e 'combined/zip_combined.insert_site_plot.gz',
    'checking first combined plot file exists'
);
system("gunzip -c combined/zip_combined.insert_site_plot.gz > zip_combined.test.plot");
is(
    read_file('zip_combined.test.plot'),
    read_file('t/data/CombinePlots/zip_comb_exp.plot'),
    'checking zipped file contents'
);
is(
	read_file('zip_comb_list.stats'),
	read_file('t/data/CombinePlots/zip_comb_exp.stats'),
	'checking stats file contents'
);

unlink('first.test.plot');
unlink('second.test.plot');
unlink('zip_combined.test.plot');
done_testing();
