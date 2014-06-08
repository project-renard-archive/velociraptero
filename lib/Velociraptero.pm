package Velociraptero;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::RenderFile;

use strict;

# This method will run once at server start
sub startup {
	my $self = shift;

	my $config = $self->plugin('Config');
	$self->plugin('RenderFile');

	$self->helper(zotero => sub {
		$self->config->{zotero_db};
	});

	$self->helper(cache => sub {
		$self->config->{chi};
	});

	$self->helper(preferred_renderer => sub {
		$self->config->{renderer} // undef;
	});


	my $creatortypeid_author = $self->zotero->schema
		->resultset('CreatorType')
		->search( { creatortype => 'author' } )
		->first->creatortypeid;
	$self->helper(zotero_creatortypeid_author => sub {
		$creatortypeid_author;
	});


	# Router
	my $r = $self->routes;
	$r->namespaces(['Velociraptero::Controller']);

	$r->get('/api/library')->to('root#collection');
	$r->get('/api/library/:collectionid')->to('root#collection_items');
	$r->get('/api/library/:collectionid/datatable')->to('root#collection_items_datatable');

	$r->get('/api/item')->to('root#items');
	$r->get('/api/item/:itemid/attachment')->to('root#item_attachments');
	$r->get('/api/item/:itemid/attachment/:itemattachmentid')->to('root#item_attachment_file');
	$r->get('/api/item/:itemid/attachment/:itemattachmentid/#name')->to('root#item_attachment_file');

	$r->get('/api/item/:itemid/attachment-cover')->to('root#item_attachment_cover_all');
	$r->get('/api/item/:itemid/attachment-cover/:itemattachmentid')->to('root#item_attachment_cover');

	$r->get('/api/pdf2htmlEX_render')->to('root#pdf2htmlEX_render');

	$r->get('/api/phrase')->to('root#phrase_mp3');
	$r->get('/api/item/:itemid/attachment-sentence/:itemattachmentid')->to('root#get_sentences');
	$r->get('/api/item/:itemid/attachment-sentence/:itemattachmentid/tts/:phraseid')->to('root#get_phrase_tts');

	# anything else
	$r->get('/')->to('root#index');
	$r->get('/*wildcard')->to('root#wildcard');
}

1;
