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


for ( qw( Phoenix NAS1 Srv5 ) ) {
    $d->add_sensor( { name => "$_ Temperature (°C)",
		      value => "float",
		      state_topic => "~/".lc($_)."/temperature" } );
}
for ( "mc/mc_01" ) {
    $d->add_sensor( { name => "MC Temperature (°C)",
		      value => "float",
		      state_topic => "$_/temperature" } );
    $d->add_sensor( { name => "MC GPU Temperature (°C)",
		      value => "float",
		      state_topic => "$_/gputemperature" } );
}
for ( qw( srv1 srv4 mc621 ) ) {
    $d->add_sensor( { name => uc($_)." Temperature (°C)",
		      value => "float",
		      state_topic => "~/$_/temperature" } );
    $d->add_sensor( { name => uc($_)." GPU Temperature (°C)",
		      value => "float",
		      state_topic => "~/$_/gputemperature" } );
}

$d->add_sensor( { name => "WAN Uptime(s)",
		  value => "int",
		  device_class => "duration",
		  state_topic => "~/fritz/uptime" } );

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
