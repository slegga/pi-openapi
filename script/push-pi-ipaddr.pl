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
use Clone 'clone';
use Socket;
=head1 NAME

push-ip-addr - Tell cloud server where which ip address the private pi server has.

=head1 DESCRIPTION

Script for telling which ip address my home router has, and the temperature of the pi server.

=cut


my $ua = Mojo::UserAgent->new;
$ua->max_redirects(5);
# http://ip-api.com/json/ only show ipv4 path
# http://v4v6.ipv6-test.com/api/myip.php?json show default address
my $value_d_hr = $ua->get('http://v4v6.ipv6-test.com/api/myip.php?json')->res->json;
my $value_4_hr = $ua->get('http://v4.ipv6-test.com/api/myip.php?json')->res->json;
my $value_6_hr =  $ua->get('http://v6.ipv6-test.com/api/myip.php?json')->res->json;

my $value_hr;
for my $key(keys %$value_4_hr) {
	$value_hr->{"ipv4_$key"} = $value_4_hr->{$key};
}
for my $key(keys %$value_6_hr) {
	$value_hr->{"ipv6_$key"} = $value_6_hr->{$key};
}
$value_hr->{address} = $value_d_hr->{address};
$value_hr->{a_proto} = $value_d_hr->{proto};
# $value_hr->{a_dns} = scalar gethostbyaddr(inet_pton(AF_INET,$value_hr->{ipv4_address})//inpet_pton(AF_INET6,$value_hr->{ipv6_address}), AF_INET);

my $uname = `uname -a`;
my $cels;
if ($uname=~/raspb/i) {
     $cels=`/opt/vc/bin/vcgencmd measure_temp`;
  ($value_hr->{temp}) = ($cels=~/temp\=([\d\.\,\w\-\+]+.\w)/);
} elsif ($uname=~/msys/i) {
    $cels='';
} else {
    $cels =`sensors`;
  ($value_hr->{a_temp}) = ($cels=~/temp1\:\s+([\d\.\,\w\-\+]+)/);
}
$value_hr->{a_time} = strftime("%Y-%m-%d %H:%M:%S", localtime);


printf j( $value_hr);
###
#my $base_dir = '/path/to/certs/';
#$ua->ca($base_dir . 'ca-cert.crt');
#$ua->cert($base_dir . 'clientcert.crt');

#my $bio = Net::SSLeay::BIO_new_file($base_dir . 'clientcert.crt', 'r');
#my $privkey = Net::SSLeay::PEM_read_bio_PrivateKey($bio, undef, 'password');
#$ua->key($privkey);

my $tx = $ua->post('https://piano.0x.no/api/home/pi'=> json =>  $value_hr);

if(my $res = $tx->result->is_success) {
  say $res->body;
#  print Dumper($tx);
} else {
  my ($err, $code) = $tx->error;
  say $code ? "$code response: $err" : "Connection error:". Dumper $err;
}

