#!/usr/bin/perl
use v5.12;
use warnings;
use Gst;
use Glib qw( TRUE FALSE );

# Get a jpeg image from the Raspberry Pi camera.  This requires the rpicamsrc 
# gst plugin, which you can download and compile from:
#
# https://github.com/thaytan/gst-rpicamsrc
#
# Duplicates this command line:
#
# gst-launch-1.0 rpicamsrc ! h264parse ! 'video/x-h264,width=800,height=600' \
#    ! avdec_h264 ! jpegenc quality=50 ! filesink location=output.jpg
#

my $OUT_FILE = shift || die "Need file to save to\n";


#Gst::init( $0, @ARGV );
my $loop = Glib::MainLoop->new( undef, FALSE );
my $pipeline = Gst::Pipeline->new( 'pipeline' );

my ($rpi, $h264parse, $capsfilter, $avdec_h264, $jpegenc, $fakesink)
    = Gst::ElementFactory->make(
        rpi        => 'and_who',
        h264parse  => 'are_you',
        capsfilter => 'the_proud_lord_said',
        avedc_h264 => 'that_i_should_bow_so_low',
        jpegenc    => 'only_a_cat',
        fakesink   => 'of_a_different_coat',
    );

my $caps = Gst::Caps->new_empty_simple( 'video/x-h264' );
$caps->set_value( width  => 800 );
$caps->set_value( height => 600 );
$capsfilter->set( caps => $caps );


$pipeline->add( $rpi, $h264parse, $capsfilter, $avdec_h264, $jpegenc,
    $fakesink );
$rpi->link( $h264parse, $capsfilter, $avdec_h264, $jpegenc, $fakesink );
my $bus = Gst::Element::get_bus( $pipeline );
my $msg = $bus->timed_pop_filtered( Gst::CLOCK_TIME_NONE,
    [ 'error', 'eos' ]);

Gst::Element::set_state( $pipeline, "null" );
