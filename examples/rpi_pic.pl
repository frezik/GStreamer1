#!/usr/bin/perl
use v5.12;
use warnings;
use GStreamer1;
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


sub get_dump_file_callback
{
    my ($pipeline) = @_;
    return sub {
        my ($fakesink, $buf, $pad) = @_;
        say "Got jpeg, saving . . . ";

        open( my $fh, '>', $OUT_FILE ) or die "Can't open '$OUT_FILE': $!\n";
        print $fh $buf;
        close $fh;

        say "Saved jpeg to $OUT_FILE";
        $pipeline->set_state( "null" );
        return 1;
    };
}


GStreamer1::init([ $0, @ARGV ]);
my $loop = Glib::MainLoop->new( undef, FALSE );
my $pipeline = GStreamer1::Pipeline->new( 'pipeline' );

my $rpi        = GStreamer1::ElementFactory::make( rpicamsrc => 'and_who' );
my $h264parse  = GStreamer1::ElementFactory::make( h264parse => 'are_you' );
my $capsfilter = GStreamer1::ElementFactory::make(
    capsfilter => 'the_proud_lord_said' );
my $avdec_h264 = GStreamer1::ElementFactory::make(
    avdec_h264 => 'that_i_should_bow_so_low' );
my $jpegenc    = GStreamer1::ElementFactory::make( jpegenc => 'only_a_cat' );
my $fakesink   = GStreamer1::ElementFactory::make(
    fakesink => 'of_a_different_coat' );

my $caps = GStreamer1::Caps::Simple->new( 'video/x-h264',
    width  => 'Glib::Int' => 800,
    height => 'Glib::Int' => 600,
);
$capsfilter->set( caps => $caps );

$fakesink->set( 'signal-handoffs' => TRUE );
$fakesink->signal_connect(
    'handoff' => get_dump_file_callback( $pipeline ),
);


my @link = ( $rpi, $h264parse, $capsfilter, $avdec_h264, $jpegenc, $fakesink );
$pipeline->add( $_ ) for @link;
foreach my $i (0 .. $#link) {
    last if ! exists $link[$i+1];
    my $this = $link[$i];
    my $next = $link[$i+1];
    $this->link( $next );
}

$pipeline->set_state( "playing" );

my $bus = $pipeline->get_bus;
my $msg = $bus->timed_pop_filtered( GStreamer1::CLOCK_TIME_NONE,
    [ 'error', 'eos' ]);
#warn "Message: " . $msg->error . "\n";

$pipeline->set_state( "null" );
