#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Template;

my $d = HA::MQTT::Device->new
  ( name	      => "Systems",
    root	      => "tele",
    topic_root	      => "",
    model	      => "Systems",
    manufacturer      => "Misc",
    identifiers       => [ "systems" ],
    sw_version        => "0",
  );


for ( qw( Phoenix NAS1 Srv1 Srv4 Srv5 ) ) {
    $d->add_sensor( { name => "$_ Temperature (°C)",
		      value => "float",
		      state_topic => "~/".lc($_)."/temperature" } );
}

$d->add_sensor( { name => "WAN Uptime(s)",
		  value => "int",
		  device_class => "duration",
		  state_topic => "tele/fritz/uptime" } );

binmode STDOUT => ':utf8';

my $res = $d->generate;

my $xp = Template->new;

my $tmp = join( "", map { $d->detab($_) } <DATA> );
$xp->process( \$tmp, $res );

__DATA__
# MQTT sensors for systems              -*- hass -*-

script:

[% script %]

automation:

[% automation %]

homeassistant:

  customize:

[% customize %]
