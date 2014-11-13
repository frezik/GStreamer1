package Gst;

use v5.12;
use warnings;
use Glib::Object::Introspection;

# ABSTRACT: Bindings for GStreamer 1.0, the open source multimedia framework

BEGIN {
    foreach my $name ('', (
        'Allocators',
        'App',
        'Audio',
        'Base',
        'Check',
        'Controller',
        'Fft',
        'InsertBin',
        'Mpegts',
        'Net',
        'Pbutils',
        'Riff',
        'Rtp',
        'Rtsp',
        'Sdp',
        'Tag',
        'Video',
    )) {
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


1;
__END__

