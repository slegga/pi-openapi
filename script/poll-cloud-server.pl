#!/usr/bin/env perl

use warnings;
use strict;
use autodie;
use feature 'say';
use IO::Socket;
use Mojo::UserAgent;
use YAML::Tiny;
use Data::Dumper;

# http://www.perlmonks.org/?node_id=645259


=head1 NAME

poll-cloud-server.pl - Test status of cloud server.

=head1 DESCRIPTION

Script for polling cloud server and for figure out if it is up or not.

=cut

$| = 1;

my $cfg = YAML::Tiny->read("$ENV{HOME}/etc/poll-cloud-server.yml")->[0];    #first element

# say Dumper $cfg;
my $socket = IO::Socket::INET->new(
    PeerAddr => $cfg->{PeerAddr},
    PeerPort => $cfg->{PeerPort},
    Proto    => $cfg->{Proto},
    Timeout  => $cfg->{Timeout}
);

#Check connection
my $ok = 0;
if ($socket) {
    if (my $line = <$socket>) {
        if ($line =~ /SSH/) {
            say time . ' ok';
            $ok = 1;
        }
        else {
            say STDERR time . ' ERROR: Connected but expect SSH got:' . $line;
        }
    }
    else {
        say STDERR time . ' ERROR: Connected but no answear';
    }
}

else {
    printf STDERR "%s ERROR: unreachable '%s' %s:%s\n", time, $@, $cfg->{PeerAddr}, $cfg->{PeerPort};

    # https://github.com/cloudatcost/api
}
if (!$ok) {
    my $ua = Mojo::UserAgent->new;
    my $tx = $ua->post('https://panel.cloudatcost.com/api/v1/powerop.php' => form =>
            {key => $cfg->{key}, login => $cfg->{username}, sid => $cfg->{sid}, action => 'reset'});
    my $res = $tx->result;
    if ($res->is_success) {
        printf "SUCCESS REBOOT: %s\n", $res->body;
    }
    else {
        my $err = $tx->error;
        if ($err->{code}) {
            my $msg = sprintf "ERROR REBOOT: %s response: %s\n", $err->{code}, $err->{message};
            say $msg;
            say $STDERR $msg;
        }
        else {
            my $msg = sprintf "Connection error: %s\n", ($err->{message} // 'NO ERROR MESSAGE OR ANY THING.');
            say $msg;
            say STDERR $msg;
        }
    }
}
