#!perl
use v5.14;
use warnings;
use Gst;

# This is based on the GStreamer Hello, World! tutorial at:
#
# http://docs.gstreamer.com/pages/viewpage.action?pageId=327735
# 
# You can download 'sintel_trailer-480p.webm' from there
#

my $URI = shift || die "Need URI to play\n";

my $pipeline = Gst::parse_launch( "playbin uri=$URI" );

Gst::Element::set_state( $pipeline, "playing" );

my $bus = Gst::Element::get_bus( $pipeline );
my $msg = $bus->timed_pop_filtered( Gst::CLOCK_TIME_NONE,
    [ 'error', 'eos' ]);

Gst::Element::set_state( $pipeline, "null" );
