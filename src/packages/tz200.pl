#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;

# Generate HA YAML for Panasonic Lumix TZ200.

my $d = HA::MQTT::Device->new
  ( name	      => "TZ200",
    root	      => "tele/tz200",
    topic_root	      => "tz200",
    model	      => "TZ200",
    manufacturer      => "Panasonic",
    identifiers       => [ "tz200" ],
    sw_version        => "0",
  );

my @sensors =
  (
   { name	     => "Battery (%)",
     value_template  => "{{ value_json.battery | int }}",
     device_class    => "battery",
     state_topic     => "state",
   },
  );

$d->add_sensor($_) for @sensors;

binmode STDOUT => ':utf8';

print <<EOD;
# Panasonic Lumix TZ200 camera.

# The sync tool publishes the battery state via MQTT.

EOD

print $d->as_string;
