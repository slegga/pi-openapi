package SH::PiOpenAPI::Controller::Status;
use Mojo::Base "Mojolicious::Controller";

sub list {

  # Do not continue on invalid input and render a default 400
  # error document.
  my $c = shift->openapi->valid_input or return;

  # You might want to introspect the specification for the current route
  my $spec = $c->openapi->spec;
  # unless ($spec->{'x-opening-hour'} == (localtime)[2]) {
#    return $c->render(openapi => [], status => 498);
#  }

  # $c->openapi->valid_input copies valid data to validation object,
  # and the normal Mojolicious api works as well.
  my $input = $c->validation->output;
  my $age   = $c->param("age"); # same as $input->{age}
  my $body  = $c->req->json;    # same as $input->{body}

  # $output will be validated by the OpenAPI spec before rendered
  my $output = {pets => [{name => "kit-e-cat"}]};
  $c->render(openapi => $output);
}

1;
