#!/usr/bin/env perl

=head1 NAME

tell-dropbox-my-ip.pl

=head1 DESCRIPTION

This is going to be a personal server. So only I need to know the IP.

The plan:
Look up ip
http://ip-api.com/json/
Lookup pi temparure: /opt/vc/bin/vcgencmd measure_temp
Store date.
Store in given catalog. Check dropbox status, dropbox start dropbox stop.


=cut
use Mojo::Base -strict;
use Mojo::UserAgent;
use Mojo::JSON qw( j decode_json encode_json from_json );
use Mojo::Util 'dumper';
use POSIX qw( strftime );
# http://mojolicious.org/perldoc/Mojolicious/Guides/Growing
#
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
