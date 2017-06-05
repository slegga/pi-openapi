#! /usr/bin/env perl

use warnings;
use strict;
use autodie;
use feature 'say';
use IO::Socket;
Use Mojo::UserAgent;
$| = 1;

my $socket = IO::Socket::INET->new(PeerAddr => '64.137.192.243' , PeerPort => 22 , Proto => 'tcp' , Timeout => 10);
my $cfg = eval ...;
#Check connection
if( $socket )    {
    say time . ' ok';
} else {
    say time . ' unreachable';
   # https://github.com/cloudatcost/api
   my $ua  = Mojo::UserAgent->new;
  my $tx = $ua->post('https://panel.cloudatcost.com/api/v1/powerop.php' => form
 => {key=>$cfg->key, login=>$cfg->username, sid=>$cfg->sid, action=>'reset'});
  if (my $res = $tx->success) { say $res->body }
  else {
    my $err = $tx->error;
    die "$err->{code} response: $err->{message}" if $err->{code};
    die "Connection error: $err->{message}";
  }
}
