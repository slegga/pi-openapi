#!/usr/bin/env perl
use Toadfarm -init;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

=head1 NAME

toadfarm.pl - master of mojolicious script on pi

=cut

my $datestring = localtime();
print "------------------------------\n";
print "Started: $datestring\n";

logging {
        combined => 1,
        file     => "/var/log/toadfarm/pi-openapi.log",
        level    => "info",
};
mount "SH::PiOpenAPI";

plugin "Toadfarm::Plugin::AccessLog";
start ['http://*:8888'], workers => 1;
