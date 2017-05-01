package SH::PiOpenAPI;
use Mojo::Base "Mojolicious";

sub startup {
my $app = shift;
  $app->plugin("OpenAPI" => {url => $app->home->rel_file("openapi-def.json")});
}

1;
