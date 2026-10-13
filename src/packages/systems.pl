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


for ( qw( Phoenix NAS1 Srv5 Maccho ) ) {
    $d->add_sensor( { name => "$_ Temperature (°C)",
		      value => "float",
		      state_topic => "~/".lc($_)."/temperature" } );
}
for ( qw( srv1 srv4 mc621 osmc ) ) {
    $d->add_sensor( { name => uc($_)." Temperature (°C)",
		      value_template => "{{ value_json.cputemperature|float }}",
		      state_topic => "~/$_/state" } );
    $d->add_sensor( { name => uc($_)." GPU Temperature (°C)",
		      value_template => "{{ value_json.gputemperature|float }}",
		      state_topic => "~/$_/state" } );
    $d->add_sensor( { name => uc($_)." Timestamp",
		      value_template => "{{ value_json.timestamp }}",
		      state_topic => "~/$_/state" } );
    $d->add_sensor( { name => uc($_)." State",
		      state_topic => "~/$_/state" } );
}

$d->add_sensor( { name => "WAN Uptime(s)",
		  value => "int",
		  device_class => "duration",
		  state_topic => "~/fritz/uptime" } );


for ( qw( smotty ) ) {
    $d->add_sensor( { name => uc($_)." Battery (%)",
		      device_class => "battery",
		      value_template => "{{ value_json.batteryLevel|int }}",
		      state_topic => "~/$_/status" } );
    $d->add_sensor( { name => uc($_)." Plugged",
		      type => "binary",
		      value_template => "{{ 'ON' if value_json.isPlugged else 'OFF' }}",
		      payload_on => "ON",
		      payload_off => "OFF",
		      state_topic => "~/$_/status" } );
    $d->add_sensor( { name => uc($_)." Temperature (°C)",
		      value_template => "{{ value_json.batteryTemperature|float }}",
		      state_topic => "~/$_/status" } );
    $d->add_sensor( { name => uc($_)." Timestamp",
		      device_class => "timestamp",
		      value_template => "{{ (value_json.timestamp|int/1000)|timestamp_local }}",
		      state_topic => "~/$_/status" } );
}

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
