package Velociraptero;
use Mojo::Base 'Mojolicious';

use strict;

# This method will run once at server start
sub startup {
	my $self = shift;

	my $config = $self->plugin('Config');

	$self->helper(zotero => sub {
		$self->config->{zotero_db};
	});

  # Router
	my $r = $self->routes;
	$r->namespaces(['Velociraptero::Controller']);

	$r->get('/')->to('root#index');
	$r->get('/items')->to('root#items');
	$r->get('/item/:itemid/attachments')->to('root#item_attachments');
}

1;
