#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for OtoLift stairlift.

my $tas = "tasm02";

my $d = HA::MQTT::Device->new
  ( name	      => "OtoLift",
    root	      => "tele/$tas",
    topic_root	      => "$tas",
    model	      => "Modul Air One",
    manufacturer      => "OtoLift",
    identifiers       => [ "otolift" ],
    sw_version        => "1.00",
    # Common to all sensors.
    state_topic           => "~/STATE",
    availability_topic    => "~/LWT",
    payload_available     => "Online",
    payload_not_available => "Offline",
  );

my @sensors =
  (
   { name	     => "Going Up",
     type	     => "binary",
     state_topic     => "stat/$tas/POWER1",
     payload_on	     => "ON",
     payload_off     => "OFF",
   },
   { name	     => "Going Down",
     type	     => "binary",
     state_topic     => "stat/$tas/POWER2",
     payload_on	     => "ON",
     payload_off     => "OFF",
   },
  );

$d->add_sensor($_) for @sensors;

binmode STDOUT => ':utf8';

my $res = $d->generate;

my $xp = Text::Template::Tiny->new( %$res );

print $d->detab($xp->expand($_)) while <DATA>;

__DATA__
# OtoLift Stairlift with Tasmota controls       -*- hess -*-

#### WARNING: This is a generated file. Changes will get lost!

script:

[% script %]

  otolift_stop:
    mode: restart
    sequence:
      - service: mqtt.publish
        data:
          topic: cmnd/tasm02/power1
          payload: 0
      - service: mqtt.publish
        data:
          topic: cmnd/tasm02/power2
          payload: 0

  otolift_up:
    mode: restart
    sequence:
      - service: script.otolift_stop
      - service: mqtt.publish
        data:
          topic: cmnd/tasm02/power1
          payload: 1

  otolift_down:
    mode: restart
    sequence:
      - service: script.otolift_stop
      - service: mqtt.publish
        data:
          topic: cmnd/tasm02/power2
          payload: 1

template:

  - sensor:
      - name: Otolift On
        unique_id: otolift_on
        state: >-
          {% if is_state('binary_sensor.otolift_going_up','on') %}
          Up
          {% elif is_state('binary_sensor.otolift_going_down','on') %}
          Down
          {% else %}
          Stopped
          {% endif %}
        icon: mdi:elevator-passenger-outline

  - cover:
      - name: Otolift
        device_class: garage
        open_cover:
          action: script.otolift_up
        close_cover:
          action: script.otolift_down
        stop_cover:
          action: script.otolift_stop

automation:

[% automation %]
