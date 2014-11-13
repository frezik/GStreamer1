#!perl
use v5.12;
use warnings;
use Gst;
use Devel::Symdump;

# Dump out everything under the Gst:: namespace recursively

my $dump = Devel::Symdump->rnew( 'Gst' );
say $_ for sort $dump->functions;
