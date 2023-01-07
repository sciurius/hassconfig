#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for Growatt7k.

my $d = HA::MQTT::Device->new
  ( name	      => "Systems",
    root	      => "tele",
    topic_root	      => "",
    model	      => "Systems",
    manufacturer      => "Misc",
    identifiers       => [ "systems" ],
    sw_version        => "0",
  );


for ( qw( Phoenix NAS1 Srv1 Srv4 ) ) {
    $d->add_sensor( { name => "$_ Temperature (°C)",
		      value => "float",
		      state_topic => "~/".lc($_)."/temperature" } );
}

binmode STDOUT => ':utf8';

print <<EOD;
# MQTT sensors for systems              -*- hass -*-

EOD

print $d->as_string;
