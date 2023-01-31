package HA::MQTT::Device;

use warnings;
use strict;
use JSON::PP();
use YAML();
use Carp;
use utf8;

=head1 NAME

HA::MQTT::Device - The great new HA::MQTT::Device!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use HA::MQTT::Device;

    my $foo = HA::MQTT::Device->new();
    ...

=head1 METHODS

=head2 new

=cut

sub new {
    my ( $pkg, %init ) = @_;

    my $self = bless { device => {},
		       sensors => [],
		       binary_sensors => [],
		     } => $pkg;

    for my $t ( qw( name model manufacturer identifiers
		    sw_version ) ) {
	$self->{device}->{$t} = delete($init{$t}) // croak("Missing \"$t\"");
    }
    for my $t ( qw( via_device ) ) {
	next unless defined $init{$t};
	$self->{device}->{$t} = delete($init{$t});
    }
    $self->{_pfx} = delete($init{prefix}) || $self->{device}->{name};

    $self->{_tag} = lc $self->_mkid( delete($init{tag}) || $self->{device}->{name} );

    $self->{root} = delete($init{root}) || $self->{_tag};
    $self->{topic_root} = delete($init{topic_root}) || $self->{root};

    # Note that via_device should be one of the identifiers of another device.
    for ( qw( state_topic availability_topic
	      payload_available payload_not_available
	   ) ) {
	$self->{$_} = delete($init{$_});
    }
    croak("Unprocessed arguments: " . join(" ", keys(%init)))
      if %init;

    return $self;
}

=head2 add_sensor

=cut

# Map unit of measure to device class.
my %dcmap; INIT {
    %dcmap = (
            A	  => "current",
	    C     => "temperature",
	    H	  => "duration",
	    kWh	  => "energy",
	    V	  => "voltage",
	    W	  => "power",
	    Wh	  => "energy",
	    "⁰C"  => "temperature",
    );
}

sub add_sensor {
    my $self = shift;

    my %init;
    if ( @_ == 1 ) {
	%init = ref($_[0]) ? %{$_[0]} : ( name => $_[0] );
    }
    else {
	%init = @_;
    }

    my $type = delete $init{type} // "sensor";

    my @req = qw( name );
    my @opt = qw( friendly_name unique_id
		  unit_of_measurement device_class
		  topic value value_template
		  state_topic json_attributes_topic
		  availability_topic payload_available payload_not_available
		  icon
	       );

    # Check sensor type and ajust req/opt.

    ### Read-only
    if ( $type eq "sensor" ) {
    }
    elsif ( $type eq "binary" ) {
	push( @req, qw( payload_on payload_off ) );
    }

    ### Read-Write
    elsif ( $type eq "number" ) {
	push( @req, qw( command_topic ) );
	push( @opt, qw( min max ) );
    }
    elsif ( $type eq "switch" ) {
	push( @req, qw( command_topic payload_on payload_off ) );
    }
    elsif ( $type eq "select" ) {
	push( @req, qw( command_topic options ) );
	push( @opt, qw( command_template ) );
    }
    else {
	croak("Unhandled sensor type: \"$type\"");
    }

    # Check required arguments.
    for ( @req ) {
	croak("Missing \"$_\" for $type") unless defined $init{$_};
    }

    # Check arguments.
    my %args;
    for ( @req, @opt ) {
	$args{$_} = delete $init{$_};
    }
    croak("Unprocessed arguments: " . join(" ", keys(%init)))
      if %init;

    my $name = $args{name} || croak("Missing name for sensor");

    # Split off unit of measurement from name, if any.
    if ( $name =~ /^(.+)\(([^)]+)\)$/) {
	$name = $1;
	my $uom = $2;
	$name =~ s/\s+$//;
	$args{name} = $name;
	$args{unit_of_measurement} //= $uom;
	$args{device_class} //= $dcmap{$uom} if defined $dcmap{$uom};;
	$args{friendly_name} //= "$name ($uom)";
    }

    # Set up the sensor structure.
    my $s = { device => $self->{device},
	      "~"    => $self->{root},
	      type   => $type,
	    };

    # These may be defaulted from the device.
    for ( qw( state_topic availability_topic
	      payload_available payload_not_available ) ) {
	next if defined( $s->{$_} ) || !defined( $self->{$_} );
	$s->{$_} = $self->{$_};
    }

    my $t = $args{name};
    $s->{name} = join( " ", $self->{_pfx}, $t );

    $s->{unique_id} = lc $self->_mkid( $s->{name} );
    if ( $args{topic} && $args{topic} =~ m;[~/]; ) {
	$s->{topic} = $args{topic};
    }
    else {
	$s->{topic} = $self->_mkid( $args{topic} || lc $t );
    }

    if ( $args{state_topic} && $args{state_topic} =~ m;[~/]; ) {
	$s->{state_topic} = $args{state_topic};
    }
    elsif ( !defined $s->{state_topic} ) {
	$s->{state_topic} = "~/" . $self->_mkid( $args{state_topic} || $s->{topic} );
    }

    if ( $args{value} ) {
	if ( $args{value} =~ /^float(\d)?$/ ) {
	    my $r = $1 ? "|round($1)" : "";
	    $s->{value_template} = '{{ value|float'.$r.' }}';
	}
	elsif ( "int" eq ( $args{value} )) {
	    $s->{value_template} = '{{ value|int }}';
	}
	else {
	    $s->{value_template} = $args{value};
	}
	delete $args{value};
    }

    for ( @req, @opt ) {
	next unless defined $args{$_};
	next if defined $s->{$_};
	$s->{$_} = delete $args{$_};
    }

    push( @{ $self->{sensors} }, $s );
    return $self;
}

=head2 add_binary_sensor

=cut

sub add_binary_sensor {
    my $self = shift;

    my %init;
    if ( @_ == 1 ) {
	%init = ref($_[0]) ? %{$_[0]} : ( name => $_[0] );
    }
    else {
	%init = @_;
    }

    shift->add_sensor( type => "binary_sensor", %init );
}

=head2 add_select

=cut

sub add_select {
    my $self = shift;

    my %init;
    if ( @_ == 1 ) {
	%init = ref($_[0]) ? %{$_[0]} : ( name => $_[0] );
    }
    else {
	%init = @_;
    }

    $self->add_sensor( type => "select", %init );
}

=head2 add_number

=cut

sub add_number {
    my $self = shift;

    my %init;
    if ( @_ == 1 ) {
	%init = ref($_[0]) ? %{$_[0]} : ( name => $_[0] );
    }
    else {
	%init = @_;
    }

    $self->add_sensor( type => "number", %init );
}

=head2 add_switch

=cut

sub add_switch {
    my $self = shift;

    my %init;
    if ( @_ == 1 ) {
	%init = ref($_[0]) ? %{$_[0]} : ( name => $_[0] );
    }
    else {
	%init = @_;
    }

    $self->add_sensor( type => "switch", %init );
}

=head2 generate

=cut

sub generate {
    my ( $self, $filename ) = @_;

    my $s = [];
    my $pp = JSON::PP->new->canonical->pretty;
    my %res;

    for my $d ( @{ $self->{sensors} } ) {
	$d->{type} = "binary_sensor" if $d->{type} eq "binary";
	my $seq =
	  { service => "mqtt.publish",
	    data =>
	    { topic => join( "/", "homeassistant", $d->{type},
			     $self->{topic_root}, $d->{topic} . "/config" ),
	      retain => 0,
	    }
	  };
	my $pl =
	  { name => $d->{name},
	    "~" => $self->{root},
	    unique_id => $d->{unique_id},
	    state_topic => $d->{state_topic},
	    device => $self->{device},
	  };

	for ( qw( device_class unit_of_measurement icon min max
		  command_topic options payload_on payload_off
		  json_attributes_topic
	       ) ) {
	    next unless defined $d->{$_};
	    $pl->{$_} = $d->{$_};
	}
	for ( qw( command_template value_template ) ) {
	    next unless defined $d->{$_};
	    $pl->{$_} = '{% raw %}"' . $d->{$_} . '"{% endraw %}';
	}
	if ( $d->{availability_topic} ) {
	    $pl->{availability} =
	      [ { topic => $d->{availability_topic},
		  payload_available => $d->{payload_available},
		  payload_not_available => $d->{payload_not_available},
		} ];
	}
	$seq->{data}->{payload} = $pp->encode($pl);
	push( @$s, $seq );
    }

    my $y = { script =>
	      { "@{[$self->{_tag}]}_define_sensors" =>
		{ mode => "single",
		  sequence => $s } } };
    my $t = YAML::Dump($y);
    $t =~ s/" \{\% \s+ raw \s+ \%\}
	    \\" (.*?) \\"
	    \{\% \s+ endraw \s+ \%\} "
	   /{\% raw \%}"$1"{\% endraw \%}/gx;

    $t =~ s/\A.*script:\n+//s;
    $res{script} = $t;

    $t = join( "",
	   "  # Setup autodiscovery for the sensors.\n",
	   "  - alias: Trigger @{[$self->{device}->{name}]} device sensors definitions\n",
	   "    id: Automation__Trigger_@{[$self->_mkid($self->{device}->{name})]}_device_sensors_definitions\n",
	   "    trigger:\n",
	   "      - platform: homeassistant\n",
	   "        event: start\n",
	   "    action:\n",
	   "      - service: script.@{[$self->{_tag}]}_define_sensors\n",
	   "        data: {}\n\n" );

    $res{automation} = $t;

    $t = "";
    for my $d ( @{ $self->{sensors} } ) {
	next unless $d->{friendly_name};
	next if $d->{name} eq $d->{friendly_name};
	$t .= join( "",
		    "    ",
		    $d->{type} . "." . lc( $self->_mkid($d->{name}) ), ":\n",
		    "      friendly_name: ", $d->{friendly_name}, "\n",
		    "\n" );
    }

    $res{customize} = $t if $t;

    return \%res;
}

sub as_string {
    my ( $self ) = @_;
    my $res = $self->generate;

    my $ret = join( "\n",
		    "script:\n", $res->{script},
		    "automation:\n", $res->{automation} );

    $ret .= join( "\n",
		  "homeassistant:\n",
		  "  customize:\n", $res->{customize} ) if $res->{customize};


    return $ret;
}

sub _mkid {
    my $t = $_[1];
    $t =~ s/[^a-z0-9]+/_/gi;
    $t =~ s/_$//;
    return $t;
}

=head1 AUTHOR

Johan Vromans, C<< <JV at cpan.org> >>

=head1 SUPPORT AND DOCUMENTATION

Development of this module takes place on GitHub:
https://github.com/sciurius/perl-HA-MQTT-Device.

You can find documentation for this module with the perldoc command.

    perldoc HA::MQTT::Device

Please report any bugs or feature requests using the issue tracker on
GitHub.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2022 Johan Vromans, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

unless ( caller ) {
    package main;
    my $d = HA::MQTT::Device->new
      ( name	      => "Growatt7k",
	prefix	      => "Growatt",
	root	      => "growatt7k",
	model	      => "Growatt 7000 TL3",
	manufacturer  => "Growatt",
	identifiers   => [ "AH44460477" ],
	sw_version    => "3.1",
      );

    my @sensors =
      ( "Serial number",
	{ name => "Logtime",
	  state_topic => "timestamp",
	  device_class => "timestamp",
	},
	"Status",
	{ name => "Temperature(⁰C)", topic => "Temperature", value => "float" },
	{ name => "IPM Temperature(⁰C)", topic => "IPM Temperature", value => "float" },
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
	{ name => "T total(H)", topic => "T_total", value => "float" },
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
    $d->generate;
}

# Since we will generate YAML, we may want to use this.

sub detab {
    my ( $self, $line ) = @_;
    my @l = split( /\t/, $line );

    # Replace tabs with blanks, retaining layout

    $line = shift(@l);
    $line .= " " x (8-length($line)%8) . shift(@l) while $#l >= 0;

    return $line;
}

1; # End of HA::MQTT::Device
