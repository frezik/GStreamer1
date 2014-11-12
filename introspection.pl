#!perl
use v5.14;
use warnings;
use Glib::Object::Introspection;

# Uses the Introspection-based bindings to load the GStreamer library into the 
# Gst:: namespace.  This is based on the GStreamer Hello, World! tutorial at:
#
# http://docs.gstreamer.com/pages/viewpage.action?pageId=327735
# 
# You can download 'sintel_trailer-480p.webm' from there
#

BEGIN {
    Glib::Object::Introspection->setup(
        basename => 'Gst',
        version  => '1.0',
        package  => 'GStreamer',
    );
    GStreamer::init([ $0, @ARGV ]);
}


my $pipeline = GStreamer::parse_launch( "playbin uri=file://sintel_trailer-480p.webm" );

GStreamer::Element::set_state( $pipeline, "playing" );

my $bus = GStreamer::Element::get_bus( $pipeline );
while( my $msg = $bus->timed_pop( GStreamer::CLOCK_TIME_NONE ) ) {
    my $type = $msg->type;
    warn "Got message type: '$type'\n";
    if( $type eq 'eos' ) {
        last;
    }
    elsif( $type eq 'error' ) {
        last;
    }
}

GStreamer::Element::set_state( $pipeline, "null" );
