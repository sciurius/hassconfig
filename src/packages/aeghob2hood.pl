#! perl					-*- hass -*-

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for AEG Hob2Hood.

my $tas = "psw05";

my $d = HA::MQTT::Device->new
  ( name	      => "hob2hood",
    root	      => "tele/$tas",
    topic_root	      => "$tas",
    model	      => "IKE74440CB",
    manufacturer      => "AEG",
    identifiers       => [ "aegh2h" ],
    sw_version        => "1.00",
    # Common to all sensors.
    state_topic           => "~/STATE",
    availability_topic    => "~/LWT",
    payload_available     => "Online",
    payload_not_available => "Offline",
  );

my @sensors =
  (
   { name             => "Signal",
     state_topic      => "~/h2h",
   },
   { name             => "Uptime (s)",
     state_topic      => "~/STATE",
     value_template   => "{{ value_json.UptimeSec }}",
     device_class     => "duration",
     icon	      => "mdi:clock-outline",
   },
   { name             => "MqttCount",
     state_topic      => "~/STATE",
     value_template   => "{{ value_json.MqttCount }}",
   },
   { name             => "WifiCount",
     state_topic      => "~/STATE",
     value_template   => "{{ value_json.Wifi.LinkCount }}",
   },
  );

$d->add_sensor($_) for @sensors;

binmode STDOUT => ':utf8';

my $res = $d->generate;

my %xxctl =
  ( SPEED_1   => "0xE3C01BE2",
    SPEED_2   => "0xD051C301",
    SPEED_3   => "0xC22FFFD7",
    SPEED_4   => "0xB9121B29",
    SPEED_OFF => "0x055303A3",
    LIGHT_ON  => "0xE208293C",
    LIGHT_OFF => "0x24ACF947",
  );
my %ctl =
  ( SPEED_1   => "F1",
    SPEED_2   => "F2",
    SPEED_3   => "F3",
    SPEED_4   => "F4",
    SPEED_OFF => "F0",
    LIGHT_ON  => "L1",
    LIGHT_OFF => "L0",
  );
$res->{"ir_$_"} = $ctl{$_} for keys(%ctl);

my $xp = Text::Template::Tiny->new( %$res );

print $d->detab($xp->expand($_)) while <DATA>;

__DATA__
# AEG Hob2Hood       -*- hass -*-

#### WARNING: This is a generated file. Changes will get lost!

script:

[% script %]

input_boolean:
  hob2hood_light:
    name: Hob2Hood Light
    icon: mdi:wall-sconce-flat

input_number:
  hob2hood_fan:
    name: Hob2Hood Fan Speed
    min: 0
    max: 4
    icon: mdi:fan

template:

  - sensor:
      - name: Hob2Hood Fan
        unique_id: hob2hood_fan
        state: >-
          {{ states('input_number.hob2hood_fan') }}
        icon: mdi:fan

  - binary_sensor:
      - name: Hob2Hood Light
        unique_id: hob2hood_light
        state: >-
          {{ states('input_boolean.hob2hood_light') }}
        icon: mdi:wall-sconce-flat

automation:

[% automation %]

  - id: Automation__H2H_Tracker
    alias: H2H Tracker
    description: Track H2H changes.
    trigger:
      - platform: state
        entity_id: sensor.hob2hood_signal
    condition:
      not:
        or:
          - condition: state
            entity_id: sensor.hob2hood_signal
            state: unknown
          - condition: state
            entity_id: sensor.hob2hood_signal
            state: unavailable
    action:
      - choose:
          - conditions: '{{ trigger.to_state.state == "[% ir_LIGHT_ON %]" }}'
            sequence:
              - service: input_boolean.turn_on
                target:
                  entity_id: input_boolean.hob2hood_light
              - service: switch.turn_on
                target:
                  entity_id: switch.keuken_afzuigkap
              - service: input_number.set_value
                target:
                  entity_id: input_number.hob2hood_fan
                data:
                  value: 0
              - service: script.stop_keuken_afzuigkap_timer
          - conditions: '{{ trigger.to_state.state == "[% ir_LIGHT_OFF %]" }}'
            sequence:
              - service: input_boolean.turn_off
                target:
                  entity_id: input_boolean.hob2hood_light
              - service: script.start_keuken_afzuigkap_timer
          - conditions: '{{ trigger.to_state.state == "[% ir_SPEED_OFF %]" }}'
            sequence:
              - service: input_number.set_value
                target:
                  entity_id: input_number.hob2hood_fan
                data:
                  value: 0
          - conditions: '{{ trigger.to_state.state == "[% ir_SPEED_1 %]" }}'
            sequence:
              - service: input_number.set_value
                target:
                  entity_id: input_number.hob2hood_fan
                data:
                  value: 1
          - conditions: '{{ trigger.to_state.state == "[% ir_SPEED_2 %]" }}'
            sequence:
              - service: input_number.set_value
                target:
                  entity_id: input_number.hob2hood_fan
                data:
                  value: 2
          - conditions: '{{ trigger.to_state.state == "[% ir_SPEED_3 %]" }}'
            sequence:
              - service: input_number.set_value
                target:
                  entity_id: input_number.hob2hood_fan
                data:
                  value: 3
          - conditions: '{{ trigger.to_state.state == "[% ir_SPEED_4 %]" }}'
            sequence:
              - service: input_number.set_value
                target:
                  entity_id: input_number.hob2hood_fan
                data:
                  value: 4

