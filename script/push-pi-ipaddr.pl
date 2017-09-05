#!/usr/bin/env perl

#use Modern::Perl;
use strict;
use warnings;
use autodie;
use feature 'say';
use Data::Dumper;
use POSIX qw (strftime);
use Mojo::JSON qw(j);
use Mojo::UserAgent;

###
my $ua = Mojo::UserAgent->new;
$ua->max_redirects(5);
my $value_hr = $ua->get('http://ip-api.com/json/')->res->json;

my $uname = `uname -a`;
my $cels;
if ($uname=~/raspb/i) {
     $cels=`/opt/vc/bin/vcgencmd measure_temp`;
  ($value_hr->{temp}) = ($cels=~/temp\=([\d\.\,\w\-\+]+.\w)/);
} elsif ($uname=~/msys/i) {
    $cels='';
} else {
    $cels =`sensors`;
  ($value_hr->{temp}) = ($cels=~/temp1\:\s+([\d\.\,\w\-\+]+)/);
}
$value_hr->{time} = strftime("%Y-%m-%d %H:%M:%S", localtime);
printf j( $value_hr);
###
#my $base_dir = '/path/to/certs/';
#$ua->ca($base_dir . 'ca-cert.crt');
#$ua->cert($base_dir . 'clientcert.crt');

#my $bio = Net::SSLeay::BIO_new_file($base_dir . 'clientcert.crt', 'r');
#my $privkey = Net::SSLeay::PEM_read_bio_PrivateKey($bio, undef, 'password');
#$ua->key($privkey);

my $tx = $ua->post('https://hjernen.glemte.no/api/pi'=> json =>  $value_hr);

if(my $res = $tx->success) {
  say $res->body;
#  print Dumper($tx);
} else {
  my ($err, $code) = $tx->error;
  say $code ? "$code response: $err" : "Connection error:". Dumper $err;
}

