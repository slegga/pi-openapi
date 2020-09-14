#!/usr/bin/env perl

use Mojo::Base -strict, -signatures;
use lib 'output/';
use CACPy;
use YAML::Syck qw 'Dump';
use Data::Dumper;
my  $configfile = ($ENV{CONFIG_DIR}||$ENV{HOME}.'/etc').'/'.'cac.yml';
my  $config = YAML::Syck::LoadFile("$configfile");
say Dump $config;
my $cac = CACPy->new($config->{email},$config->{key});
my $li = $cac->get_server_info();
say Dumper $li;