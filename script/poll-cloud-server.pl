#! /usr/bin/env perl

use warnings;
use strict;
use autodie;
use feature 'say';
use IO::Socket;
use Mojo::UserAgent;
use YAML::Tiny;

$| = 1;

my $cfg = eval YAML::Tiny->read("$ENV{HOME}/etc/poll-cloud-server.yml");
my $socket = IO::Socket::INET->new(PeerAddr => $cfg->PeerAddr , PeerPort => $cfg->PeerPort , Proto => $cfg->Proto , Timeout => $cfg->Timeout);
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
