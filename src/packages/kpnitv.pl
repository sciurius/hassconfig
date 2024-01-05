#! perl

use warnings;
use strict;
use utf8;

use HA::MQTT::Device;
use Text::Template::Tiny;

# Generate HA YAML for KPN iTV.

my $d = HA::MQTT::Device->new
  ( name	      => "KPN-iTV",
    root	      => "kpnitv",
    model	      => "Webbie",
    manufacturer      => "Johan",
    identifiers       => [ "KPN-iTV" ],
    sw_version        => "1",
  );

my @sensors =
  (
   { name	     => "Recordings used (min)",
     state_topic     => "~/recordingstatus",
     value_template  => "{{value_json.usedMinutes}}",
   },
   { name	     => "Recordings total (min)",
     state_topic     => "~/recordingstatus",
     value_template  => "{{value_json.totalMinutes}}",
   },
   { name	     => "Timestamp",
     state_topic     => "~/recordingstatus",
     value_template  => "{{value_json.systemTime}}",
   },
  );

$d->add_sensor($_) for @sensors;

binmode STDOUT => ':utf8';

my $res = $d->generate;

my $xp = Text::Template::Tiny->new( %$res );

print $d->detab($xp->expand($_)) while <DATA>;

__DATA__
# KPN iTV using Webbie		     -*- hess -*-

#### WARNING: This is a generated file. Changes will get lost!

script:

[% script %]

automation:
 
[% automation %]
