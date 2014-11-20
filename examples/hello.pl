#!perl
use v5.12;
use warnings;
use GStreamer1;

# This is based on the GStreamer Hello, World! tutorial at:
#
# http://docs.gstreamer.com/pages/viewpage.action?pageId=327735
# 
# You can download 'sintel_trailer-480p.webm' from there
#

my $URI = shift || die "Need URI to play\n";

GStreamer1::init([ $0, @ARGV ]);
my $pipeline = GStreamer1::parse_launch( "playbin uri=$URI" );

GStreamer1::Element::set_state( $pipeline, "playing" );

my $bus = GStreamer1::Element::get_bus( $pipeline );
my $msg = $bus->timed_pop_filtered( GStreamer1::CLOCK_TIME_NONE,
    [ 'error', 'eos' ]);

GStreamer1::Element::set_state( $pipeline, "null" );
