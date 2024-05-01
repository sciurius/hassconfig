#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for Tasmota RF Bridge Sensors.

my $toi = "tasm01";		# device

my $d = HA::MQTT::Device->new
  ( name                  => "RfBridge",
    root                  => "tele/$toi",
    topic_root            => "rfbridge",
    model                 => "NodeMCU",
    manufacturer          => "Tasmota",
    identifiers           => [ ucfirst($toi) ],
    sw_version            => "12.2.0",
    # Common to all sensors.
    state_topic           => "~/RESULT",
    availability_topic    => "~/LWT",
    payload_available     => "Online",
    payload_not_available => "Offline",
  );

my @sensors =
  (
   { name                  => "Signal",
     value_template        => "{{ value_json.RfReceived.Data }}",
     json_attributes_topic => "~/RESULT",
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

my $xp = Text::Template::Tiny->new( %$res );

print $d->detab($xp->expand($_)) while <DATA>;

__DATA__
# Tasmota RF Bridge	               -*-hass-*-

#### WARNING: This is a generated file. Changes will get lost!

script:

[% script %]

  rfbridge_button_0_pressed:

    mode: queued
    sequence:
      - service: notify.mobile_app_sm_a320fl
        data:
          message: TTS
          data:
            tts_text: Damsel in distress
            priority: high
            ttl: 0
            media_stream: "alarm_stream_max"
            importance: high
      - service: script.smotty_notify
        data:
          message: Button 0 pressed
      - service: telegram_bot.send_message
        data:
          message: Button 0 pressed

  rfbridge_button_a_pressed:

    mode: queued
    sequence:
      - service: light.toggle
        target:
          entity_id: light.woonkamer_totem
      - service: telegram_bot.send_message
        data:
          message: Button A pressed

  rfbridge_button_b_pressed:

    mode: queued
    sequence:
      - service: light.toggle
        target:
          entity_id: light.woonkamer_heks
        data:
          brightness_pct: 100
          rgb_color: [191,0,255]
      - service: telegram_bot.send_message
        data:
          message: Button B pressed

  rfbridge_button_c_pressed:

    mode: queued
    sequence:
      - service: light.toggle
        target:
          entity_id:
            - light.woonkamer_wand_l
            - light.woonkamer_wand_r
      - service: telegram_bot.send_message
        data:
          message: Button C pressed

  rfbridge_button_d_pressed:

    mode: queued
    sequence:
      - service: telegram_bot.send_message
        data:
          message: Button D pressed

  rfbridge_button_2_pressed:

    mode: queued
    sequence:
      - service: telegram_bot.send_message
        data:
          message: Button 2 pressed

  rfbridge_doorbell_pressed:

    mode: queued
    sequence:
      - service: notify.mobile_app_sm_a320fl
        data:
          message: TTS
          data:
            tts_text: Someone at the door
            priority: high
            ttl: 0
            media_stream: "alarm_stream_max"
            importance: high
      - service: telegram_bot.send_message
        data:
          message: Doorbell pressed

  rfbridge_chime:
    mode: single
    variables:
      chime: 0
      map:
        - "0x5555C0"            # Default (Ding Dong 2)
        - "0x555503"            # Für Elise
        - "0x55550C"            # Westminster Bell
        - "0x555530"            # Ding Dong 1
        - "0x5555C0"            # Ding Dong 2
        
    sequence:
      - service: mqtt.publish
        data:
          topic: cmnd/tasm01/rfsend
          payload: "{{ map[chime] }}"

input_select:
  rfbridge_chime_mode:
    name: Chime
    options:
      - Für Elise
      - Westminster Bell
      - Ding Dong 1
      - Ding Dong 2
    initial: Ding Dong 2
    icon: mdi:bell-ring-outline

homeassistant:
  customize:
[% customize %]

automation:

[% automation %]

  - id: Automation__RfBridge_Button_Pressed
    alias: RfBridge Button Pressed
    description: ''
    mode: queued

    trigger:
      - platform: state
        entity_id:
        - sensor.rfbridge_signal
        attribute: Time

    variables:
      button_mapper:
        # Proto: 1, Bits: 24
        "0x177B68": Button_0
        "0x9CDB61": Button_A
        "0x9CDB62": Button_B
        "0x9CDB64": Button_C
        "0x9CDB68": Button_D
        "0x460421": Button_2
        "0x5555C0": Doorbell

    condition: |-
      {{ trigger.to_state.state not in ( "unavailable", "unknown" )
	 and
	 trigger.from_state.state != "unavailable"
	 and
	 trigger.to_state.state in button_mapper
      }}

    action:
      - service: >
          {% if button_mapper[trigger.to_state.state] %}
          script.rfbridge_{{ button_mapper[trigger.to_state.state]|lower }}_pressed
          {% else %}
          telegram_bot.send_message
          {% endif %}
        data:
          message: >
            Button {{ trigger.to_state.state }}
            (atts  {{ state_attr('sensor.rfbridge_signal','RfReceived') }})
            pressed
