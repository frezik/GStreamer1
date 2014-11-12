#!perl
use v5.14;
use warnings;
use Glib::Object::Introspection;
use Devel::Symdump;

# Load up every Gst* library on the system using the Introspection-based
# bindings.  Dump them all into the Gst:: namespace, and then dump them all.

BEGIN {
    foreach my $name ('', qw{
        Allocators
        App
        Audio
        Base
        Check
        Controller
        Fft
        InsertBin
        Mpegts
        Net
        Pbutils
        Riff
        Rtp
        Rtsp
        Sdp
        Tag
        Video
    }) {
        my $basename = 'Gst' . $name;
        my $pkg      = $name
            ? 'Gst::' . $name
            : 'Gst';
        Glib::Object::Introspection->setup(
            basename => $basename,
            version  => '1.0',
            package  => $pkg,
        );
    }

    Gst::init([ $0, @ARGV ]);
}


my $dump = Devel::Symdump->rnew( 'Gst' );
say $_ for sort $dump->functions;



