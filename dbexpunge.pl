#!/usr/bin/perl -w

# Deleting records from HomeAssistant database backwards.

# Author          : Johan Vromans
# Created On      : Fri Jun 17 08:32:04 2022
# Last Modified By: Johan Vromans
# Last Modified On: Wed Jun 22 15:49:06 2022
# Update Count    : 35
# Status          : Unknown, Use with caution!

################ Common stuff ################

use strict;

# Package or program libraries, if appropriate.
# $LIBDIR = $ENV{'LIBDIR'} || '/usr/local/lib/sample';
# use lib qw($LIBDIR);
# require 'common.pl';

# Package name.
my $my_package = 'Sciurix';
# Program name and version.
my ($my_name, $my_version) = qw( dbexpunge 0.01 );

################ Command line parameters ################

use Getopt::Long 2.13;

# Command line options.
my $dbname = "hass";		# or hass_test
my $verbose = 1;		# verbose processing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test mode.

# Process command line options.
app_options();

# Post-processing.
$trace |= ($debug || $test);

################ Presets ################

my $TMPDIR = $ENV{TMPDIR} || $ENV{TEMP} || '/usr/tmp';

my $cutoff = `date '--date=14 days ago' +"%Y-%m-%dT00:00:00"`;
chomp($cutoff);
warn("Cutoff: $cutoff\n") if $verbose;

################ The Process ################

use ResInfo;
my $db = resinfo("db.$dbname.dbi");
die("No database found for \"$dbname\"\n") if $db =~ /ERROR/;

use DBI;
my $dbh = DBI::->connect( $db, "jv", undef );

my @ids =
  qw( binary_sensor.boiler_heating_active
      binary_sensor.boiler_heating_pump
      number.boiler_heating_temperature
      sensor.boiler_current_flow_temperature
      sensor.bresser51_humidity
      sensor.bresser51_rain
      sensor.bresser51_temperature
      sensor.energy_consumed
      sensor.energy_generated
      sensor.fritz_box_phone_state
      sensor.dsmr_consumption_gas_delivered
      sensor.dsmr_reading_electricity_delivered_1
      sensor.dsmr_reading_electricity_delivered_2
      sensor.dsmr_reading_electricity_returned_1
      sensor.dsmr_reading_electricity_returned_2
      sensor.openweathermap_humidity
      sensor.openweathermap_temperature
      sensor.shelly1l_1_tasmota_analog_temperature
      sensor.thermostat_hc1_current_room_temperature
      switch.doorbell
      switch.kelder_ventilator
);

for my $area ( qw( achterkamer badkamer bijkeuken buiten hal kantoor kelder
		   kruipruimte slaapkamer vliering woonkamer zolder ) ) {
    for ( qw( temperature humidity ) ) {
	push( @ids, "sensor.${area}_$_" );
    }
    push( @ids, "sensor.${area}_illuminace" ) if $area eq "achterkamer";
}

my $select = <<EOD;
SELECT state_id FROM states
WHERE
NOT (  false
 @{[ map { "   OR entity_id = '$_'\n" } sort @ids ]})
AND last_updated < '$cutoff'
ORDER BY state_id ASC;
EOD

my $delete = <<EOD;
DELETE FROM states WHERE state_id = ?;
EOD

my $fknull = <<EOD;
UPDATE states SET old_state_id = NULL WHERE old_state_id = ?;
EOD

my $st1 = $dbh->prepare($select);
my $st2 = $dbh->prepare($delete);
my $st3 = $dbh->prepare($fknull);

$dbh->{AutoCommit} = 0 if $test;

$st1->execute;

my $tally = 0;
while ( my $res = $st1->fetch ) {
    print("$res->[0]\n") if $verbose > 1;
    $st3->execute($res->[0]) or die("$st3->errstr\n");
    $st2->execute($res->[0]) or die("$st2->errstr\n");
    $tally++;
}

$dbh->rollback if $test;

warn( "Number of records removed: $tally",
      $test ? " (just testing)" : "",
      "\n" );

$dbh->disconnect;

exit 0;

################ Subroutines ################

sub app_options {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally

    # Process options, if any.
    # Make sure defaults are set before returning!
    return unless @ARGV > 0;

    if ( !GetOptions(
		      'dbname=s'=> \$dbname,
		     'ident'	=> \$ident,
		     'verbose+'	=> \$verbose,
		     'quiet'	=> sub { $verbose = 0 },
		     'trace'	=> \$trace,
		     'help|?'	=> \$help,
		     'test|dry-run|n' => \$test,
		     'debug'	=> \$debug,
		    ) or $help )
    {
	app_usage(2);
    }
    app_ident() if $ident;
}

sub app_ident {
    print STDERR ("This is $my_package [$my_name $my_version]\n");
}

sub app_usage {
    my ($exit) = @_;
    app_ident();
    print STDERR <<EndOfUsage;
Usage: $0 [options] [file ...]
   --dbname		database name, if not 'hass'
   --dry-run|n|test	just testing
   --ident		shows identification
   --help		shows a brief help message and exits
   --verbose		provides more verbose information
   --quiet		runs as silently as possible
EndOfUsage
    exit $exit if defined $exit && $exit != 0;
}
