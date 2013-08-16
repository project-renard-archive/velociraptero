package Velociraptero;
use Mojo::Base 'Mojolicious';

use strict;

# This method will run once at server start
sub startup {
  my $self = shift;

  my $config = $self->plugin('Config');
  use DDP; p $config;

  # Router
  my $r = $self->routes;
  $r->namespaces(['Velociraptero::Controller']);

  # Normal route to controller
  $r->get('/items')->to('root#items');
}

1;
