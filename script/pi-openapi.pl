#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use Mojolicious::Commands;


=head1 NAME

pi-openapi.pl - For talking with cloudatcost server.

=cut

# Start command line interface for application
Mojolicious::Commands->start_app('SH::PiOpenAPI');

