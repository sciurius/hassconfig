#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for Growatt7k.

my $d = HA::MQTT::Device->new
  ( name	      => "Bresser51",
    prefix	      => "Bresser51",
    root	      => "rtl_433/bresser51",
    topic_root	      => "bresser51",
    model	      => "Bresser 5 in 1",
    manufacturer      => "Bresser",
    identifiers       => [ "bresser51" ],
    sw_version        => "1.0",
  );

my @sensors =
  (
   { name => "Serial number",
     topic => "id" },
   { name => "Temperature (⁰C)",
     topic => "temperature_C",
     value => "float" },
   { name => "Humidity (%)",
     device_class => "humidity",
     value => "int" },
   { name => "Wind Gust (m/s)",
     topic => "wind_max_m_s",
     value => "float" },
   { name => "Wind Speed (m/s)",
     topic => "wind_avg_m_s",
     value => "float" },
   { name => "Wind Direction Unadjusted(⁰)",
     icon => "mdi:compass-rose",
     topic => "wind_dir_deg",
     value => "int" },
   { name => "Rain Unadjusted (mm)",
     icon => "mdi:weather-rainy",
     topic => "rain_mm",
     value => "float1" },
   { name => "Time",
     device_class => "timestamp",
     icon => "mdi:clock-outline" },
   { name => "Battery",
     type => "binary",
     device_class => "battery",
     topic => "battery_ok",
     payload_on => 0,
     payload_off => 1 },
  );

$d->add_sensor($_) for @sensors;

binmode STDOUT => ':utf8';

my $res = $d->generate;

my $xp = Text::Template::Tiny->new( %$res );

print $xp->expand($_) while <DATA>;

__DATA__
# Bresser 5-in-1 / Bresser 6-in-1 / Bresser 7-in-1      -*-hass-*-
#
# WARNING: THIS IS A GENERATED FILE. CHANGES WILL BE LOST!

script:

[% script %]

homeassistant:
  customize:
[% customize %]

# Helpers.

input_number:

  # Just in case the weather station is not precisely aimed at the
  # north, enter the difference here. So if the station is e.g. aimed
  # east you would put 90 here.

  bresser51_dir_corr:
    name: Direction Correction
    min: -359
    max: 359
    step: 1
    mode: slider
    unit_of_measurement: "⁰"
    icon: mdi:axis-z-rotate-clockwise

  # The weather station resets its values when the batteries are
  # changed. To cope with that, we maintain a helper with an
  # offset value.
  # Sensor bresser51_rain_offset gives the value of the
  # corresponding input_number sensor.

  bresser51_rain_offset:
    name: Rain Correction
    min: 0.0
    max: 9999999.9
    step: 0.1
    mode: box
    unit_of_measurement: "mm"

  # This is to remember the earliest value (max 168h).
  bresser51_rain_earliest:
    name: Earliest Rain Value
    min: 0.0
    max: 9999999.9
    step: 0.1
    mode: box
    unit_of_measurement: "mm"

template:

- sensor:

    # Adjust for not being north-oriented.
    - name: Bresser51 Wind Direction
      state: >-
        {{ (
             (states('sensor.bresser51_wind_direction_unadjusted')|int)
           - (states('sensor.bresser51_dir_corr')|int)
           ) % 360 }}
      unit_of_measurement: "⁰"
      icon: mdi:compass-rose

    - name: Bresser51 Dir Corr
      state: "{{ states('input_number.bresser51_dir_corr') }}"
      unit_of_measurement: "⁰"
      icon: mdi:axis-z-rotate-clockwise

    # Map heading in degrees to discrete values 0..16
    # Note that the bresser sensor returns values:
    #  0 22 45 68 90 112 135 158 180 202 225 248 270 292 315 338 360?
    - name: Bresser51 Wind Direction Sector
      icon: mdi:compass-rose
      state: >-
        {{ (
        (states('sensor.bresser51_wind_direction')|int) /
        22 ) | int % 16 }}

    # The adjusted direction, in degrees. 0 22.5 45 67.5 ...
    - name: Bresser51 Wind Direction Sector Adjusted
      unit_of_measurement: "⁰"
      icon: mdi:compass-rose
      state: >-
        {{ (states('sensor.bresser51_wind_direction_sector')|int) * 22.5 }}

# {% set names = "N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW N".split() %}

    # Map sector to symbolic name.
    - name: Bresser51 Wind Direction Name
      icon: mdi:compass-rose
      state: |
        {% set names = "N NNO NO ONO O OZO ZO ZZO Z ZZW ZW WZW W WNW NW NNW N".split() %}
        {{ names[states('sensor.bresser51_wind_direction_sector')|int] }}

# {% set names = "N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW N".split() %}

    # Wind force.
    - name: Bresser51 Wind Beaufort
      unit_of_measurement: "Bft"
      icon: mdi:windsock
      state: |
        {{(((states('sensor.bresser51_wind_speed') | float) / 0.836) ** (2/3)) | round(0, 'ceil')}}

    # Wind speed in Km/h, for convenience
    - name: Bresser51 Wind Speed Kmh
      state: |
        {{ ( 3.6 * (states('sensor.bresser51_wind_speed') | float) ) | round(1) }}
      unit_of_measurement: "km/h"
      icon: mdi:weather-windy

    # Wind Chill (Feels like) temperature.
    # JAG/TI formula.
    # Correction in line 3 is for 1.5m level measurement of the wind
    # speed instead of the required 10m.
    - name: Bresser51 Wind Chill
      state: |
        {% set t = states('sensor.bresser51_temperature')|float %}
        {% set s = states('sensor.bresser51_wind_speed')|float %}
        {% set s = s * 1.5 %}
        {% set chill = (13.12 + 0.6215 * t + ( 0.4867 * t - 13.96 ) * s ** 0.16) %}
        {% if ( chill > t ) %}{% set chill = t %}{% endif %}
        {{ chill|round(1) }}
      unit_of_measurement: "⁰C"
      icon: mdi:thermometer

# Fetching history data from PostgreSQL recorder db.
# Must now be done via UI now. Such a shame!
#
# sensor:
#
#   - platform: sql
#     db_url: !secret recorder_db
#     queries:
#       - name: Bresser51 DB Rain 1H
#         query: >-
#           SELECT * FROM states
#           WHERE entity_id = 'sensor.bresser51_rain'
#                 AND last_updated < CURRENT_TIMESTAMP - INTERVAL '1 hour'
#           ORDER BY last_updated DESC
#           LIMIT 1;
#         column: state
#         unit_of_measurement: mm
#       - name: Bresser51 DB Rain 24H
#         query: >-
#           SELECT * FROM states
#           WHERE entity_id = 'sensor.bresser51_rain'
#                 AND last_updated < CURRENT_TIMESTAMP - INTERVAL '24 hour'
#           ORDER BY last_updated DESC
#           LIMIT 1;
#         column: state
#         unit_of_measurement: mm
#       - name: Bresser51 DB Rain 168H
#         query: >-
#           SELECT * FROM states
#           WHERE entity_id = 'sensor.bresser51_rain'
#                 AND last_updated < CURRENT_TIMESTAMP - INTERVAL '168 hour'
#           ORDER BY last_updated DESC
#           LIMIT 1;
#         column: state
#         unit_of_measurement: mm

    - name: Bresser51 Rain
      state: |
        {{ ( states('sensor.bresser51_rain_unadjusted') | float )
           +
           ( states('sensor.bresser51_rain_offset') | float ) }}
      unit_of_measurement: "mm"
      icon: mdi:weather-rainy

    - name: Bresser51 Rain Earliest
      unit_of_measurement: mm
      icon: mdi:weather-rainy
      state: "{{ states('input_number.bresser51_rain_earliest') | float }}"

    # Sensor corresponding to the input_number for rain offset.
    - name: Bresser51 Rain Offset
      unit_of_measurement: mm
      icon: mdi:weather-rainy
      state: "{{ states('input_number.bresser51_rain_offset') | float }}"
      
    # Rain (last hour);
    - name: Bresser51 Rain 1H
      unit_of_measurement: "mm"
      icon: mdi:weather-rainy
      state: |
        {% set x = states('sensor.bresser51_db_rain_1h') %}
        {% if x == "unknown" %}
        {% set x = states('sensor.bresser51_rain_earliest') %}
        {% endif %} 
        {{ ((states('sensor.bresser51_rain') | float) - ( x | float) ) | round(1) }} 

    # Rain (last 24 hours);
    - name: Bresser51 Rain 24H
      unit_of_measurement: "mm"
      icon: mdi:weather-rainy
      state: |
        {% set x = states('sensor.bresser51_db_rain_24h') %}
        {% if x == "unknown" %}
        {% set x = states('sensor.bresser51_rain_earliest') %}
        {% endif %} 
        {{ ((states('sensor.bresser51_rain') | float) - ( x | float) ) | round(1) }} 

    # Rain (last 168 hours (week));
    - name: Bresser51 Rain 168H
      unit_of_measurement: "mm"
      icon: mdi:weather-rainy
      state: |
        {% set x = states('sensor.bresser51_db_rain_168h') %}
        {% if x == "unknown" %}
        {% set x = states('sensor.bresser51_rain_earliest') %}
        {% endif %} 
        {{ ((states('sensor.bresser51_rain') | float) - ( x | float) ) | round(1) }} 

    # Use the temperature/humidity as a replacement for the old outside
    # meters.

    - name: Buiten Temperature
      state: "{{ states('sensor.bresser51_temperature') }}"
      unit_of_measurement: ⁰C
      device_class: temperature

    - name: Buiten Humidity
      unit_of_measurement: "%"
      device_class: humidity
      state: "{{ states('sensor.bresser51_humidity') }}"

automation:

[% automation %]

  # When the rain 168H value changes, remember it.
  - id: Automation__bresser51_save_earliest_rain_value
    alias: Save Bresser51 Earliest Rain Value
    description: ''
    trigger:
      - platform: state
        entity_id:
          - sensor.bresser51_db_rain_168h
    condition:
      not:
        or:
          - condition: state
            entity_id: sensor.bresser51_db_rain_168h
            state: unknown
          - condition: state
            entity_id: sensor.bresser51_db_rain_168h
            state: unavailable
          - condition: state
            entity_id: sensor.bresser51_db_rain_168h
            state: ''
    action:
      - service: input_number.set_value
        data:
          value: "{{ states('sensor.bresser51_db_rain_168h') }}"
        target:
          entity_id: input_number.bresser51_rain_earliest
    mode: single

# Exclude some fast changing (and less relevant) sensors from the
# LogBook.

logbook:
  exclude:
    entities:
      - sensor.bresser51_time
    entity_globs:
      - sensor.bresser51_wind*
