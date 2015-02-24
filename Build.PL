use Module::Build;
use strict;
use warnings;
use ExtUtils::Depends;


my $glib_dep  = ExtUtils::Depends::load( 'Glib' );
my $gtk_dep   = ExtUtils::Depends::load( 'Gtk2' );
my $gst_flags = `pkg-config --cflags gstreamer-1.0`;
my $gst_libs  = `pkg-config --libs gstreamer-1.0`;

 
my %module_build_args = (
    module_name => '##{ $dist ##}',
    ##{ $plugin->get_prereqs(1) ##}
    needs_compiler       => 1,
    dynamic_config       => 1,
    allow_pureperl       => 0,
    extra_compiler_flags => join( ' ', $glib_dep->{inc},  $gtk_dep->{inc},
        $gst_flags ),
    extra_linker_flags   => join( ' ', $glib_dep->{libs}, $gtk_dep->{libs},
        $gst_libs ),
);

my $builder = Module::Build->new(%module_build_args);
$builder->create_build_script;
