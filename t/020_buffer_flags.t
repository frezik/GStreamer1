# Copyright (c) 2014  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
use Test::More tests => 2;
use v5.14;
use GStreamer1;
use Glib qw( TRUE FALSE );

use constant TEST_FILE               => 't_data/test.h264';
use constant EXPECTED_KEYFRAME_COUNT => 2;
use constant EXPECTED_FRAME_COUNT    => 24;


my $KEYFRAME_COUNT = 0;
my $FRAME_COUNT    = 0;
sub get_catch_handoff_callback
{
    my ($pipeline, $loop) = @_;

    my $return = sub {
        my ($sink, $data_buf, $pad) = @_;
        $FRAME_COUNT++;
        eval {
            #if( $data_buf->flag_is_set( 'flag-delta-unit' ) ) {
            if( $data_buf->flags & 'flag-delta-unit' ) {
                $KEYFRAME_COUNT++;
            }
        };
        warn $@ if $@;

        if( $FRAME_COUNT >= EXPECTED_FRAME_COUNT ) {
            # End it here, since $bus->add_watch has issues
            $loop->quit;
        }
        return 1;
    };

    return $return;
}

sub get_bus_callback
{
    my ($loop) = @_;
    my $return = sub {
        my ($bus, $message) = @_;
        if( $message->type & "error" ) {
            warn $message->error;
            $loop->quit;
        }
        elsif( $message->type & "eos" ) {
            $loop->quit;
        }

        return TRUE;
    };

    return $return;
}


GStreamer1::init([ $0, @ARGV ]);
my $loop = Glib::MainLoop->new( undef, FALSE );
my $pipeline = GStreamer1::Pipeline->new( 'pipeline' );

my $src  = GStreamer1::ElementFactory::make( filesrc  => 'src' );
my $sink = GStreamer1::ElementFactory::make( fakesink => 'sink' );

$src->set( 'location' => TEST_FILE );

$sink->set( 'signal-handoffs' => TRUE );
$sink->signal_connect(
    'handoff' => get_catch_handoff_callback( $pipeline, $loop ),
);

$pipeline->add( $_ ) for $src, $sink;
$src->link( $sink );

my $bus = $pipeline->get_bus;
# TODO Using $bus->add_watch() causes an error:
#
# (020_buffer_flags.t:19606): GStreamer-WARNING **: GstBus watch dispatched without callback
# You must call g_source_set_callback().
#
# Will need to look into Later(tm).
#
#$bus->add_watch( get_bus_callback( $loop ), undef );

$pipeline->set_state( "playing" );
$loop->run;

local $TODO = "Fix Buffer->flag_is_set";
cmp_ok( $FRAME_COUNT,    '==', EXPECTED_FRAME_COUNT,
    "Expected frame count" );
cmp_ok( $KEYFRAME_COUNT, '==', EXPECTED_KEYFRAME_COUNT,
    "Expected keyframe count" );
