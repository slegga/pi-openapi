package SH::PiOpenAPI;
use Mojo::Base "Mojolicious";

=head1 NAME SH::PiOpenAPI

Main module for export pi data module

=head1 SYNOPSIS

    use Mojolicious::Commands;
    Mojolicious::Commands->start_app('SH::PIOpenAPI');

=head1 DESCRIPTION

Application class.

=head1 METHODS

=head2 startup

Setup method.

=cut

sub startup {
my $app = shift;
  $app->plugin("OpenAPI" => {url => $app->home->rel_file("openapi-def.json")});
}

1;
