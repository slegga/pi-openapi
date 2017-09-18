#! /usr/bin/env perl

use warnings;
use strict;
use autodie;
use feature 'say';
use IO::Socket;
use Mojo::UserAgent;
use YAML::Tiny;
use Data::Dumper;

# http://www.perlmonks.org/?node_id=645259


$| = 1;

my $cfg = YAML::Tiny->read("$ENV{HOME}/etc/poll-cloud-server.yml")->[0]; #first element

# say Dumper $cfg;
my $socket = IO::Socket::INET->new(PeerAddr => $cfg->{PeerAddr} , PeerPort => $cfg->{PeerPort} , Proto => $cfg->{Proto} , Timeout => $cfg->{Timeout});
#Check connection
my $ok=0;
if( $socket )    {
	if( my $line = <$socket> ) {
		if($line =~ /SSH/) {
	    say time . ' ok';
			$ok=1;
		} else {
			say time . ' ERROR: Connected but expect SSH got:'.$line;
		}
	} else {
		say time . ' ERROR: Connected but no answear';
	}
} 

else {
    printf "%s ERROR: unreachable '%s' %s:%s\n", time,$@,$cfg->{PeerAddr},$cfg->{PeerPort};
   # https://github.com/cloudatcost/api
}
if(! $ok ) {
   my $ua  = Mojo::UserAgent->new;
  my $tx = $ua->post('https://panel.cloudatcost.com/api/v1/powerop.php' => form
 => {key=>$cfg->{key}, login=>$cfg->{username}, sid=>$cfg->{sid}, action=>'reset'});
  if (my $res = $tx->success) { 
		printf "SUCCESS REBOOT: %s\n",$res->body; 
	}
  else {
    my $err = $tx->error;
		if ($err->{code}) {
	    printf "ERROR REBOOT: %s response: %s\n",$err->{code}, $err->{message};
		} else {
			printf "Connection error: %s\n",($err->{message}//'NO ERROR MESSAGE OR ANY THING.');
		}
  }
}
