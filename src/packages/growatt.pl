#! perl

use warnings;
use strict;
use utf8;
use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for Growatt7k.

my $d = HA::MQTT::Device->new
  ( name	      => "Growatt7k",
    prefix	      => "Growatt",
    root	      => "growatt7k",
    model	      => "Growatt 7000 TL3",
    manufacturer      => "Growatt",
    identifiers       => [ "AH44460477" ],
    sw_version        => "3.1",
  );

my @sensors =
  ( "Serial number",
    { name => "Logtime",
      state_topic => "timestamp",
      device_class => "timestamp",
    },
    "Status",
    { name => "Temperature(°C)", topic => "Temperature", value => "float" },
    { name => "IPM Temperature(°C)", topic => "IPM Temperature", value => "float" },
    { name => "Vpv1(V)", topic => "Vpv1", value => "float" },
    { name => "Vpv2(V)", topic => "Vpv2", value => "float" },
    { name => "Ipv1(A)", topic => "Ipv1", value => "float" },
    { name => "Ipv2(A)", topic => "Ipv2", value => "float" },
    { name => "Ppv(W)",  topic => "Ppv" , value => "float" },
    { name => "Ppv1(W)", topic => "Ppv1", value => "float" },
    { name => "Ppv2(W)", topic => "Ppv2", value => "float" },
    { name => "VacR(V)", topic => "VacR", value => "float" },
    { name => "VacS(V)", topic => "VacS", value => "float" },
    { name => "VacT(V)", topic => "VacT", value => "float" },
    { name => "IacR(A)", topic => "IacR", value => "float" },
    { name => "IacS(A)", topic => "IacS", value => "float" },
    { name => "IacT(A)", topic => "IacT", value => "float" },
    { name => "Fac(Hz)", topic => "Fac" , value => "float" },
    { name => "Pac(W)",  topic => "Pac" , value => "float" },
    { name => "PacR(W)", topic => "PacR", value => "float" },
    { name => "PacS(W)", topic => "PacS", value => "float" },
    { name => "PacT(W)", topic => "PacT", value => "float" },
    { name => "Eac today(kWh)",  topic => "Eac_today" , value => "float" },
    { name => "Eac total(kWh)",  topic => "Eac_total" , value => "float" },
    { name => "Epv1 today(kWh)", topic => "Epv1_today", value => "float" },
    { name => "Epv2 today(kWh)", topic => "Epv2_today", value => "float" },
    { name => "Epv total(kWh)",  topic => "Epv_total" , value => "float" },
    { name => "Epv1 total(kWh)", topic => "Epv1_total", value => "float" },
    { name => "Epv2 total(kWh)", topic => "Epv2_total", value => "float" },
    { name => "T total(h)", topic => "T_total", value => "float" },
    { name => "P BUS Voltage(V)", topic => "P_BUS_Voltage", value => "float" },
    { name => "N BUS Voltage(V)", topic => "N_BUS_Voltage", value => "float" },
    { name => "Power Factor", topic => "Power_Factor",
      device_class => "power_factor", value => "float" },
    { name => "Rac(Var)", topic => "Rac",
      icon => "mdi:lightning-bolt-outline", value => "float" },
    { name => "E Rac total(kVarh)", topic => "E_Rac_total",
      icon => "mdi:lightning-bolt-outline", value => "float" },
    { name => "E Rac today(kVarh)", topic => "E_Rac_today",
      icon => "mdi:lightning-bolt-outline", value => "float" },
    { name => "WarnCode", topic => "WarnCode",
      icon => "mdi:comment-alert-outline", value => "int" },
  );

$d->add_sensor($_) for @sensors;

binmode STDOUT => ':utf8';

my $res = $d->generate;

my $xp = Text::Template::Tiny->new( %$res );

print $xp->expand($_) while <DATA>;

__DATA__
# Growatt 7000 TL3                          -*-hass-*-
#
# WARNING: THIS IS A GENERATED FILE. CHANGES WILL BE LOST!

script:
[% script %]

automation:

[% automation %]

  - id: Automation__Growatt_Temperature_Alarm
    alias: Growatt Temperature Alarm
    description: "Alarm when Groatt temperature gets too high."
    mode: single
    trigger:
      - platform: numeric_state
        entity_id: sensor.growatt_temperature
        above: 60
    action:
      - service: telegram_bot.send_message
        data:
          message: "Growatt Omvormer → {{ states('sensor.growatt_temperature') }} °C"

# Exclude some fast changing (and less relevant) sensors from the
# LogBook.

logbook:
  exclude:
    entities:
      - sensor.growatt_logtime
