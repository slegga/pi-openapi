#! /usr/bin/env perl

use warnings;
use strict;
use autodie;
use feature 'say';
use IO::Socket;
$| = 1;

my $socket = IO::Socket::INET->new(PeerAddr => '64.137.192.243' , PeerPort => 22 , Proto => 'tcp' , Timeout => 10);

#Check connection
if( $socket )    {
    say time . ' ok';
} else {
    say time . ' unreachable';
   # https://github.com/cloudatcost/api
}
