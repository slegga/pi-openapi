#!/usr/bin/env perl

use Mojo::File 'path';

my $lib;
BEGIN {
    my $gitdir = Mojo::File->curfile;
    my @cats = @$gitdir;
    while (my $cd = pop @cats) {
        if ($cd eq 'git') {
            $gitdir = path(@cats,'git');
            last;
        }
    }
    $lib =  $gitdir->child('utilities-perl','lib')->to_string;
};
use lib $lib;
use SH::UseLib;
use SH::ScriptX;
use Mojo::Base 'SH::ScriptX';
use open qw(:std :utf8);
use Regexp::Common;

#use Carp::Always;

=encoding utf8

=head1 NAME

python2perl.pl - Convert python code to perl code. Not accurate makes the job easier.

=head1 DESCRIPTION

<DESCRIPTION>

=head1 ATTRIBUTES

=head2 configfile - default to $CONFIG_DIR then $HOME/etc/<scriptname>.yml

=cut

has lineno =>0;

has ph => sub{  my $self = shift;path($self->extra_options->[0])->open('<') };

has keyword_change =>sub{{}};
option 'dryrun!', 'Print to screen instead of doing changes';

sub main {
    my $self = shift;
    #my $python_code = path($e[0])->slurp;
    my $i=0;
    my %varable_seen;
    my %multilines;
    my ($in_sub);
    my %keyword_change;
    say "use Mojo::Base -base, -signatures;";
    say "use Mojo::JSON 'encode_json';";

    my $old_indent='';
    while (my $l = $self->nextline ) { # <$ph>
        chomp $l;
        if ($multilines{'"""'}) {
            if ($l =~ /\s*"""/) {
                say "=cut";
                $multilines{'"""'}=0;
            }
            else {
                say $l;
            }
        }
        else {
            if ($l =~/^\s*\#/) {
                say $l;
                next;
            }
            elsif($l=~/^$/) {
                say $l;
                next;
            }
            elsif($l=~/^import requests/) {
                say 'use Mojo::UserAgent;';
                say 'has ua => sub {Mojo::UserAgent->new};';
                my $t = $self->keyword_change;
                $t->{requests} = {to=>'$self->{ua}',methods=>{
                    get=>{to=>'get',pos=>{0=>'Mojo::URL->new($)'},keywords=>{'params'=>'->query($)'}},
                    post=>{to=>'post',pos=>{0=>'Mojo::URL->new($)=>{Accept => \'*/*\'}'},keywords=>{'data'=>'=>form =>$'}}
                }};
                $self->keyword_change($t);
                next;
            }
            elsif(my @keywords = grep {$l=~/\b$_\b/} keys %{ $self->keyword_change}) {
                for my $keyword(@keywords) {
                    my $v =$self->keyword_change->{$keyword}->{to};
                    $l=~ s/\b$keyword\b/$v/g;
                }
            }

            #TODO: indent
            $l=~/(\s*)(\S.*)/;
            $l= $2;
            my $indent=$1;
            if (length($indent) <length($old_indent)) {
                say $indent.'}';
            }
            if ($l =~/^\s*([a-zA-Z][\w]*)\s*=\s*None$/) {
                my $key = $1;
                say $indent.($varable_seen{$key}?'':'my ')."\$$key = undef;";
                $varable_seen{$key}++;
            }
            elsif ($l =~/^\s*([a-zA-Z][\w]*)\s*=\s*(.+)$/) {
                my ($key,$value) = ($1,$2);
                $value = ($self->expression_get($value))[0];
                say $indent.($varable_seen{$key}?'':'my ')."\$$key = $value".($value eq '{'?'':';');
                $varable_seen{$key}++;
                if ($value eq '{') {
                    say $self->hash_get_rest;
                }
            }
            elsif ($l =~ /^class\s+(\w+):/) {
                say "package $1;";
            }
            elsif ($l =~ /\s*"""(.*)/) {
                $multilines{'"""'}=1;
                say "=head2 $1";
            }
            elsif ($l =~ /^\s*def\s+([\w_]+)(.*):/) {
                my ($proc,$input) = ($1,$2);
#                say "}" if $in_sub;
                $proc='new' if $proc eq '__init__';
                say "sub $proc ".$self->inputs_get($input)."{";
                ;
                $in_sub=1;
            }
            elsif ($l =~ /^\s*(\w+)\.(\w+)\s*=\s*(\w+)$/) {
                print "\t" if $in_sub;
                say $indent."\$$1\->$2(\$$3);";
            }
            elsif ($l =~ /for (\w+) in (\w+)\s*:/ ){
                say $indent."for my \$$1(\@\$$2) {";
            }
            elsif ($l =~/(\w+)\[(\w+)\]\s*=\s*(\w+)\[(\w+)\]/ ) { # data[key] = options[key]
                say $indent."\$$1\->{\$$2} = \$$3\->{\$$4};";
            }
            elsif ( $l =~ /^\s*(if|elif)\s*(\w+)\s*==\s*(.+)\s*:/ ) { #if type == "GET":
                say $indent.($1 eq 'elif'?'elsif':$1)." (\$$2 eq $3) {";
            }
            elsif ($l =~ /^\s*else:/)  {
                say $indent. 'else {';
            }
            # raise Exception("InvalidRequestType: " + str(type))
            elsif ($l =~ /raise Exception\((.*)\)$/) {
                say $indent. "die ".($self->expression_get($1))[0].';';
            }
            elsif ($l =~ /return (.*)$/) {
                say $indent. "return ".($self->expression_get($1))[0];
            }
            else {
                die $self->lineno. ":  $l";
            }
            $old_indent=$indent;
        }
    }
}

sub nextline {
    my $self = shift;
    my $i = $self->lineno;
    my $fh =$self->ph;
    my $return = <$fh>;
    $i++;
    $self->lineno($i);

    return $return;
}

sub inputs_get {
    my ($self, $input) = @_;
    $input =~ s/([\(,]\s*)([\w])/$1\$$2/g;
    return $input;
}

sub args_list_get {
    my ($self, $list) = @_;
    my $return = '';
    my $i=0;
    for my $x(split(/\,/,$list)) {

        $x =~ s/^\s*//;
        $x =~ s/^\w+\=//;
        $return = ($i?', ':''). ($self->expression_get($x))[0];
        $i++;
    }
    ...;
}

sub list_get {
...;
}

sub expression_get {

    my ($self, $expression) = @_;
    my $extra={};
    return $expression if ! $expression;
    my $sep_reg = qr{[\+\*\/\-]};
    if ($expression !~ /$sep_reg/) {
        return $self->part_get($expression);
    } else {
        my @parts;
        my @seps;
        my $return='';
        while ($expression =~ /^\s*([\w]\S+|\"$RE{quoted}\")\s*($sep_reg)/p) {
            $expression = ${^POSTMATCH};
            push @parts,[ $self->part_get($1),$2 ];
            push @seps,$2;
            my $type;
            for my $part (@parts) {
                $type ||= $part->[1]->{type}//undef;
                $return .= $part->[0];
                if ($part->[2] eq '+' && (!$type || $type eq 'string')) {
                    $return .= ' . ';
                } else {
                    $return .= " $part->[2] ";
                }
            }
            $extra->{type}=$type;
        }
        $expression =~/(.*)/p;
        die"$expression: Missing part: ${^POSTMATCH}" if ${^POSTMATCH};
        $return .= ($self->part_get($1))[0];
        return ($return,$extra); # must return like this because may be used as part_get
    }
 #   else {
#        warn $expression;
#        ...;
#    }
    # part expression in parts and signs

}

sub part_get {
    my ($self, $part) = @_;
    my $extra={};
    $part=~s/\s+//;
    if ($part =~/^".*"$/) {
        return ($part,$extra);
    }


    if ($part =~/^'.*'$/) {
        $extra->{type} = 'string';
       return ($part,$extra);
    }
    while ($part =~/,$/) {
        my $x = $self->nextline;
        chomp($x);
        $x =~ s/^\s*//;
        $part .= ' '.$x;
    }
    if ($part =~ (/^\w/)) {
        my $return = '$'.$part;
        $return =~ s/\./->/;
        if ($part !~/\(/) {
            return ($return,$extra);
        }
        if ($part =~/\(\)\s*$/) {
            if ($part=~/(\w+)\.json\(\)\s*/) {
                return 'encode_json('.($self->expression_get($1))[0].')';
            }
            return ($return,$extra);
        }

        if ($part =~/(.*)(\((.+)\))/) {
            my $first = $1;
            my $param_list = $3;
            $return = $first .'(' .$self->args_list_get($param_list).')';
            return ($return, $extra);
        }
        warn $return;
        ...;
    }
    if ($part =~ /(^"[^"]"$)/) {
        $extra->{type} = 'string';
        return ($part,$extra);
    }
    if (  $part =~ /\s*str\((\w+)\)/  ) {  # str(type)
        $extra->{type} = 'string';
            return ("\$$1",$extra);
        }

    if ($part eq '{') {
        return ($self->hash_get_rest,$extra);
    }
    if ($part =~ /^(\$.*)\.(.+)\((.+)\)$/) {
        my $return='';
        my ($object,$method,$input) = ($1,$2,$3);
        if (my ($key) = grep {$object eq $self->keyword_change->{$_}->{to}} keys %{$self->keyword_change}) {
            $return .= $object;
            if (my ($mkey) = grep {$method eq $_} keys %{$self->keyword_change->{$key}->{methods}}) {
                $return .= '->' . $mkey . '(';
                my $method_data = $self->keyword_change->{$key}->{methods}->{$mkey};
                die "Unkwnown method $key.$mkey" if ! $method_data;
                my $i=0;
                for my $kk(split /\,/,$input) {
                    if (my $r = $method_data->{pos}->{$i}) {
                        my $v = ($self->expression_get($kk))[0];
                        $r =~ s/\$/$v/;
                        $return .=$r;
                    } elsif ($kk =~/\=/) {
                        my ($ke,$va)=split(/=/, $kk,2);
                        if (my ($keyword) = grep {$ke eq $_}  keys %{$method_data->{keywords}}) {
                            my $r = $method_data->{keywords}->{$keyword};
                            my $v = ($self->expression_get($va))[0];
                            $r =~ s/\$/$v/;
                            $return .=$r;
                        } else {
                            warn Dumper $method_data;
                            die "No support for keyword $ke, valid keywords are " .join(', ', keys %{$method_data->{keywords}});
                        }
                    } else {
                        die $part;
                        $return .= ($i==0?'':', ').($self->expression_get($kk))[0];
                    }
                    $i++;
                }
                $return .= ')';
            } else {
                die "Unknown method $key.$method valid is " . join(',', keys %{$self->keyword_change->{$key}->{methods} });
            }
        } else {
            die "Unknown object $object";
        }
        return $return;
    }
    warn $part;
    ...;
 }


# get {a=>'b',e=>'f'};
sub hash_get_rest {
    my $self = shift;
    my $return = "{\n";
    while( my $l = $self->nextline ) {
        chomp($l);
        if($l=~/'(\w+)'\s*:\s*(.+)/) {
            my ($key,$value) = ($1,$2);
            if ($value=~/^\w/) {
                $value= '$'.$value;
                $value=~ s/\./->/g;
            }

            $return .= "$key => $value";
        }
        elsif ($l =~/^\s*}$/) {
            $return .= "};";
            last;
        }
    }
    return $return;
}
__PACKAGE__->new(options_cfg=>{extra=>1})->main();
