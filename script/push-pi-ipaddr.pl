#!/usr/bin/env perl

#use Modern::Perl;
use strict;
use warnings;
use autodie;
use feature 'say';
use Data::Dumper;

use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new;
#my $base_dir = '/path/to/certs/';
#$ua->ca($base_dir . 'ca-cert.crt');
#$ua->cert($base_dir . 'clientcert.crt');

#my $bio = Net::SSLeay::BIO_new_file($base_dir . 'clientcert.crt', 'r');
#my $privkey = Net::SSLeay::PEM_read_bio_PrivateKey($bio, undef, 'password');
#$ua->key($privkey);

my $tx = $ua->post('https://hjernen.glemte.no/api/pi'=> json => {ip=>'1.2.3.4'});

if(my $res = $tx->success) {
  say $res->body;
  print Dumper($tx);
} else {
  my ($err, $code) = $tx->error;
  say $code ? "$code response: $err" : "Connection error:". Dumper $err;
}

