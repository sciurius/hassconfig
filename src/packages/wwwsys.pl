#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
# Generate HA YAML for WWW system monitoring

my $d = HA::MQTT::Device->new
  ( name	      => "WWW",
    root	      => "www",
    model	      => "Server",
    manufacturer      => "PvdV",
    identifiers       => [ "wwwsys" ],
    sw_version        => "0",
  );

my @sensors =
  (
   { name	     => "Disk Used (kB)",
     value_template  => "{{ value_json.used | int }}",
     state_topic     => "~/disk/status",
   },
   { name	     => "Disk Size (kB)",
     value_template  => "{{ value_json.size | int }}",
     state_topic     => "~/disk/status",
   },
   { name	     => "Disk Available (kB)",
     value_template  => "{{ value_json.available | int }}",
     state_topic     => "~/disk/status",
   },
   { name	     => "Disk Inuse (%)",
     value_template  => "{{ value_json.inuse | int }}",
     state_topic     => "~/disk/status",
   },
   { name	     => "Time",
     value_template  => "{{ value_json.time }}",
     device_class    => "timestamp",
     state_topic     => "~/disk/status",
   },
  );

$d->add_sensor($_) for @sensors;

binmode STDOUT => ':utf8';

my $res = $d->generate;

use Text::Template::Tiny;
my $xp = Text::Template::Tiny->new( %$res );

print $d->detab( $xp->expand($_) ) while <DATA>;

__DATA__
# Monitoring WWW system disk.
#
# WARNING: THIS IS A GENERATED FILE. CHANGES WILL BE LOST!

script:

[% script %]

homeassistant:
  customize:
[% customize %]

automation:

[% automation %]

  - id: Automation__wwwsys_disk_usage
    alias: wwwsys disk usage
    description: 'Monitor disk usage of www system.'
    trigger:
      - platform: numeric_state
        entity_id: sensor.www_disk_inuse
        above: 98
    action:
      - action: notify.default
        data:
          message: "WWW system vol: {{ trigger.to_state.state }} %"
    mode: single

recorder:
  exclude:
    entities:
      - sensor.www_time
