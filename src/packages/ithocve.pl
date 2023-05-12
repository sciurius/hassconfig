#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for Itho CVE-S with NRG Itho WiFi Addon.

my $d = HA::MQTT::Device->new
  ( name                  => "NRGItho",
    root                  => "itho",
    model                 => "NRG Itho WiFi Addon",
    manufacturer          => "NRG.Watch",
    identifiers           => [ "NRGItho" ],
    sw_version            => "2.4.0a8",
    # Common to all sensors.
    state_topic           => "~/ithostatus",
    availability_topic    => "~/lwt",
    payload_available     => "online",
    payload_not_available => "offline",
  );

my @sensors =
  (
   { name            => "Error",
     value_template  => "{{ value_json.Error | int }}" },
   { name            => "Startup Counter",
     value_template  => "{{ value_json['Startup counter'] | int }}" },
   { name            => "Total Operation (hours)",
     value_template  => "{{ value_json['Total operation (hours)'] | int}}" },
  );

$d->add_sensor($_) for @sensors;

my $dev = $d->generate;

$d = HA::MQTT::Device->new
  ( name                  => "IthoCVE",
    root                  => "itho",
    model                 => "CVE-Silent",
    manufacturer          => "Itho Daalderop",
    via_device            => "NRGItho",
    identifiers           => [ "IthoCVE" ],
    sw_version            => "27(fw)",
    # Common to all sensors.
    state_topic           => "~/ithostatus",
    availability_topic    => "~/lwt",
    payload_available     => "online",
    payload_not_available => "offline",
  );

@sensors =
  (
   { name            => "Temperature (°C)",
     value_template  => "{{ value_json.temp | float }}" },
   { name            => "Humidity (%)",
     device_class    => "humidity",
     value_template  => "{{ value_json.hum | float }}" },
   { name            => "Humidity ppmw",
     unit_of_measurement => "ppmw",
     value_template  => "{{ value_json.ppmw | int }}" },
   { name            => "Fan Speed (rpm)",
     value_template  => "{{ value_json['Fan speed (rpm)'] }}",
     icon            => "mdi:fan" },
   { name            => "Fan Speed Status (%)",
     value_template  => "{{ value_json['Speed status'] }}",
     icon            => "mdi:fan" },
   { name            => "Fan Setpoint (rpm)",
     value_template  => "{{ value_json['Fan setpoint (rpm)'] }}",
     icon            => "mdi:fan" },
   { name            => "Ventilation Setpoint (%)",
     value_template  => "{{ value_json['Ventilation setpoint (%)'] }}",
     icon            => "mdi:fan" },
   { name            => "Fan Remaining Time (min)",
     value_template  => "{{ value_json['RemainingTime (min)'] }}",
     icon            => "mdi:fan-clock" },
   { name            => "Fan Remaining Time (min)",
     value_template  => "{{ value_json['RemainingTime (min)'] }}",
     icon            => "mdi:fan-clock" },
  );

$d->add_sensor($_) for @sensors;

$d->add_select( name              => "Fan Info",
                options           => [ qw(low high auto),
				       "timer 1", "timer 2", "timer 3" ],
                value_template    => "{{ value_json.FanInfo }}",
                command_topic     => "~/cmd",
                command_template  => q[{ "vremote": "{{ value }}" }],
                icon              => "mdi:fan" );

$d->add_sensor( name => "state",
                value_template => "{{ value }}",
                state_topic => "itho/state",
                icon => "mdi:fan" );

binmode STDOUT => ':utf8';

my $res = $d->generate;

# Mix in the controller device.
$res->{"d_$_"} = $dev->{$_} for keys %$dev;

my $xp = Text::Template::Tiny->new( %$res );

print $d->detab($xp->expand($_)) while <DATA>;

__DATA__
# Itho Daalderop CVE-S w/ NRG gateway                -*-hass-*-

#### WARNING: This is a generated file. Changes will get lost!

################ Sensors ################

# The easy ones, temperature and humidity, For some reason the Itho
# CVE-S reports both under a short and a longer name.
# The short names have one decimal, the long names have two decimal places.
#
# For the fan, there are a number of sometimes confusing sensors.
#
# Fan Speed (rpm) -- the actual speed (in RPM) of the fan.
# Speed status -- the actual speed (in % of full) of the fan.
# Fan setpoint (rpm) -- the desired (minimal?) speed of the fan.
# Ventilation setpoint (%) -- the desired (minimal?) speed of the fan.
#
# Here confusion starts, since in "low" mode the ventilation setpoint
# drops to 0%, but the fan setpoint drops to only 450 RPM.
#
# Fan Info -- the mode the unit is operating in.
# This can be low (±450 rpm), auto (±905 rpm) or high (±1969 rpm).
# There are also timers for full speed: timer1 (10 min.), timer2 (20
# min.) and timer3 (30 min.).
# RemainingTime (min) -- The remaining time if a timer is active.
#
# Currently unused:
#
# Selection -- 2 = low, 3 = medium?, 4 = high, 5 = timer, 7 = auto

script:
[% d_script %]
[% script %]

################ Helpers ################

input_select:

# Input helper for operation mode (Fan Info).

  ithocve_fan_mode:
    name: IthoCVE Fan Mode
    options:
      - auto
      - low
      - high
      - timer 1
      - timer 2
      - timer 3
    icon: mdf:fan

input_number:

# Input helper for fan speed.

  ithocve_fan_speed:
    name: IthoCVE Fan Speed
    min: 0
    max: 100
    step: 5
    unit_of_measurement: "%"
    icon: mdi:target

# Input helper for auto fan speed.

  ithocve_humidity_threshold:
    name: IthoCVE Humidity Threshold
    min: 0
    max: 100
    step: 5
    unit_of_measurement: "%"
    icon: mdi:target

input_boolean:
  ithocve_humidity_sensor:
    name: IthoCVE Humidity Sensor

################ Templates ################

template:

  - sensor:

      - name: IthoCVE State Percent
        unique_id: ithocve_state_percent
        state: "{{ (states('sensor.ithocve_state')|int / 2.55) |round }}"
        unit_of_measurement: "%"

      - name: IthoCVE Fan Info
        unique_id: ithocve_fan_info
        state: "{{ states('select.ithocve_fan_info') }}"

################ Automations ################

automation:

[% d_automation %]
[% automation %]

  - id: Automation__IthoCVE_Set_Fan_Mode
    alias: IthoCVE Set Fan Mode
    description: >-
      Change the state. This will publish an MQTT message that will
      change the fan mode. This change will then trigger the 'IthoCVE Set
      Fan Mode' trigger that updates the UI.
    trigger:
      - platform: state
        entity_id: input_select.ithocve_fan_mode
    condition:
      not:
        or:
          - condition: state
            entity_id: input_select.ithocve_fan_mode
            state: unknown
          - condition: state
            entity_id: input_select.ithocve_fan_mode
            state: unavailable
    action:
      - service: mqtt.publish
        data:
          topic: itho/cmd
          payload_template: >-
            { "vremote": "{{ trigger.to_state.state }}" }
    mode: single

  - id: Automation__IthoCVE_Sync_Fan_Mode
    alias: IthoCVE Sync Fan Mode
    description: >-
      Set the UI selection to the actual state.
    trigger:
      - platform: state
        entity_id: sensor.ithocve_fan_info
    condition: []
    action:
    - service: automation.turn_off
      target:
        entity_id: automation.ithocve_set_fan_mode
    - service: input_select.select_option
      target:
        entity_id: input_select.ithocve_fan_mode
      data:
        option: "{{ states('sensor.ithocve_fan_info') }}"
    - service: telegram_bot.send_message
      data:
        message: "Badkamerafzuiging → {{ states('sensor.ithocve_fan_info').upper() }}"
    - service: automation.turn_on
      target:
        entity_id: automation.ithocve_set_fan_mode
    mode: queued

  - id: Automation__IthoCVE_Update_Fan_Slider
    alias: IthoCVE Update Fan Slider
    trigger:
      platform: state
      entity_id: sensor.ithocve_state_percent
    condition:
      condition: template
      value_template: >-
        {{ ( states('sensor.ithocve_state_percent')|int
             -
             states('input_number.ithocve_fan_speed')|int )|abs > 1 }}
    action:
      service: input_number.set_value
      target:
        entity_id: input_number.ithocve_fan_speed
      data:
        value: "{{ trigger.to_state.state }}"

  - id: Automation__IthoCVE_Update_Fan_Speed
    alias: IthoCVE Update Fan Speed
    trigger:
      platform: state
      entity_id: input_number.ithocve_fan_speed
    condition:
      condition: template
      value_template: >-
        {{ ( states('sensor.ithocve_state_percent')|int
             -
             states('input_number.ithocve_fan_speed')|int )|abs > 1 }}
    action:
      - service: mqtt.publish
        data:
          topic: itho/cmd
          payload_template: >-
            { "speed":{{ (trigger.to_state.state|float * 2.55)|round }} }

  - id: Automation__IthoCVE_Afzuiging
    alias: IthoCVE Afzuiging
    description: Schakel de afzuiging in wanneer de badkamer vochtig is.

    trigger:
      - platform: state
        entity_id:
          - sensor.badkamer_humidity
        for: "00:02:00"

    condition:
      - condition: numeric_state
        entity_id: sensor.badkamer_humidity
        above: input_number.ithocve_humidity_threshold
      - condition: state
        entity_id: input_boolean.ithocve_humidity_sensor
        state: "on"

    action:

      - service: input_number.set_value
        data:
          value: |
            {% set tv = states('sensor.badkamer_humidity')|int %}
            {% set th = states('input_number.ithocve_humidity_threshold')|int %}
            {% if tv > th %}
            {% set x = (tv - th) / (1 - th/100) %}
            {% else %}
            {% set x = 0 %}
            {% endif %}
            {{ x|float|round }}
        target:
          entity_id: input_number.ithocve_fan_speed

  - id: Automation__IthoCVE_Afzuiging_Off
    alias: IthoCVE Afzuiging Off
    description: Schakel de afzuiging uit wanneer de badkamer niet vochtig.

    trigger:
      - platform: numeric_state
        entity_id:
          - sensor.badkamer_humidity
        below: input_number.ithocve_humidity_threshold
        for: "00:02:00"
      - platform: state
        entity_id:
          - input_boolean.ithocve_humidity_sensor
        to: "off"

    condition:
      - condition: numeric_state
        entity_id: input_number.ithocve_fan_speed
        above: -1

    action:

      - service: input_number.set_value
        data:
          value: "0"
        target:
          entity_id: input_number.ithocve_fan_speed

