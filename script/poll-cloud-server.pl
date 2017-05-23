#/usr/bin/env perl

use warnings;
use strict;
use autodie;

use IO::Socket;
$| = 1;

my $socket = IO::Socket::INET->new(PeerAddr => $target , PeerPort => $port , Proto => 'tcp' , Timeout => 10);
#Check connection
if( $socket )    {
# OK
} else {
   # https://github.com/cloudatcost/api
}
