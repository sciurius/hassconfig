#! perl

use warnings;
use strict;
use utf8;
use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for PIco UPS

my $d = HA::MQTT::Device->new
  ( name	      => "UPS PIco",
    prefix	      => "UPS_PIco",
    root	      => "upspico",
    model	      => "UPS PIco",
    manufacturer      => "Pi Modules",
    identifiers       => [ "UPS_PIco" ],
    sw_version        => "1.0",
  );

my @sensors =
  ( { name => "Power Mode",
      value_template => "{{ value_json.power_mode }}" },
    { name => "Battery Level (V)",
      value_template => "{{ value_json.battery_level }}" },
    { name => "RPi Level (V)",
      value_template => "{{ value_json.rpi_level }}" },
    { name => "USB Level (V)",
      value_template => "{{ value_json.as1_level }}" },
    { name => "EPR Level (V)",
      value_template => "{{ value_json.as2_level }}" },
    { name => "Temperature (°C)",
      value_template => "{{ value_json.sot23_temperature }}" },
    { name => "PIco Run",
      icon => "mdi:counter",
      value_template => "{{ value_json.pico_run }}" },
    { name => "Charger",
      icon => "mdi:battery-charging-outline",
      value_template => "{{ value_json.charger }}" },
  );

$d->add_sensor( { state_topic => "~/status", %$_ } ) for @sensors;

@sensors = ();

for ( qw(year month day wday corr) ) {
    push( @sensors,
	  { name => "RTC " . ucfirst($_),
	    icon => "mdi:calendar-month",
	    value_template => "{{ value_json.$_ }}" } );
}
for ( qw(time hours minutes seconds) ) {
    push( @sensors,
	  { name => "RTC " . ucfirst($_),
	    icon => "mdi:calendar-clock",
	    value_template => "{{ value_json.$_ }}" } );
}

$d->add_sensor( { state_topic => "~/rtc", %$_ } ) for @sensors;

@sensors =
  ( { name => "Firmware Version",
      value_template => "{{ value_json.firmware_version }}" },
    { name => "Error Status",
      icon => "mdi:alert-circle-outline",
      value_template => "{{ value_json.error }}" },
    { name => "Error Status RPi J8 5V (V)",
      icon => "mdi:file-document-alert-outline",
      value_template => "{{ value_json.rpi_error }}" },
    { name => "Error Status Battery (V)",
      icon => "mdi:file-document-alert-outline",
      value_template => "{{ value_json.bat_error }}" },
    { name => "Error Status Battery Temperature (°C)",
      icon => "mdi:file-document-alert-outline",
      value_template => "{{ value_json.temp_error }}" },
    { name => "Still Alive Timeout Counter (s)",
      icon => "mdi:file-document-alert-outline",
      value_template => "{{ value_json.sta_counter }}" },
    { name => "Grace Time (s)",
      icon => "mdi:camera-timer",
      value_template => "{{ value_json.grace_time }}" },
    { name => "Low Power Restart Time (s)",
      icon => "mdi:camera-timer",
      value_template => "{{ value_json.lprsta }}" },
    { name => "Battery Powering Testing Timeout (s)",
      icon => "mdi:camera-timer",
      value_template => "{{ value_json.btto }}" },
    { name => "Filesystem Shutdown Timeout (s)",
      icon => "mdi:camera-timer",
      value_template => "{{ value_json.fssd_timeout }}" },
  );

$d->add_sensor( { state_topic => "~/control", %$_ } ) for @sensors;

binmode STDOUT => ':utf8';

my $res = $d->generate;

my $xp = Text::Template::Tiny->new( %$res );

print $xp->expand($_) while <DATA>;

__DATA__
# UPD PIco	                         -*-hass-*-
#
# WARNING: THIS IS A GENERATED FILE. CHANGES WILL BE LOST!

script:
[% script %]

automation:

[% automation %]

recorder:
  exclude:
    entity_globs:
      - sensor.ups_pico*
  include:
    entities:
      - sensor.ups_pico_battery_level
      - sensor.ups_pico_rpi_level
      - sensor.ups_pico_power_mode

logbook:
  exclude:
    entity_globs:
      - sensor.ups_pico*
  include:
    entities:
      - sensor.ups_pico_battery_level
      - sensor.ups_pico_rpi_level
      - sensor.ups_pico_power_mode
