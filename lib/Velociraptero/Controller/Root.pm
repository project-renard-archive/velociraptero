package Velociraptero::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';

use Biblio::Zotero::DB;
use strict;
use utf8::all;
use Mojo::JSON 'j';
use Try::Tiny;
use Path::Class;
use Path::Class::URI;
use URI::Escape;

use constant MIMETYPE_PDF => 'application/pdf';

# GET /
sub index {
	my $self = shift;

	$self->param( app_config => j({
		url => $self->url_for( '/api/item' ),
		push_state => $self->flash('push_state')
	}) ); # JSON
	my $pdfjs_url = $self->url_for('/vendor/zmughal-build-pdf.js/web/viewer.html');
	$self->param( pdfjs_viewer_url => $pdfjs_url );
	$self->param( attachmentview_config => j({
		pdfjs_viewer_url => $pdfjs_url
	}));
	$self->render();
}

# GET /*wildcard
sub wildcard {
	my $self = shift;
	$self->flash( push_state => $self->param('wildcard') );
	$self->redirect_to( '/' );
}


# GET /api/item
sub items {
	my ($self) = @_;
	return $self->documents();
}

# GET /api/item/:itemid/attachment
# return JSON of attachments
# only gets the ones that are application/pdf
sub item_attachments {
	my ($self) = @_;

	my @attachment_info = map {
		$self->item_attachment_info($_)
	} @{ $self->get_pdf_attachments( $self->param('itemid') ) };

	$self->render( json => [
		map {
			{
				id => $_->{attachment_itemid},
				itemid => $_->{itemid},
				mimetype => $_->{mimetype},
				item_attachment_file_url => $self->url_for(
					'/api/item/'. $_->{itemid} .
					'/attachment/' . $_->{attachment_itemid} .
					'/' . $_->{name} )
			}
		} @attachment_info ] );
}

sub item_attachment_info {
	my ($self, $item_attachment) = @_;
	{
		itemid => ( defined $item_attachment->sourceitemid
			? $item_attachment->get_column('sourceitemid')
			: $item_attachment->get_column('itemid') ),
		attachment_itemid => $item_attachment->get_column('itemid'),
		mimetype => $item_attachment->get_column('mimetype'),
		name => ($item_attachment->uri->path_segments)[-1],
	};
}

sub get_pdf_attachments {
	my ($self, $itemid) = @_;
	my $item = $self->zotero->schema->resultset('StoredItem')->find( $itemid  );

	my @attachments;

	return [] unless $item;

	if( $item->is_attachment ) {
		my $item_attachment = $item->item_attachments_itemid;
		@attachments = ( $item_attachment ) if $item_attachment->mimetype eq MIMETYPE_PDF;
	} else {
		@attachments = $item->stored_item_attachments_sourceitemids
			->search( { mimetype => MIMETYPE_PDF } )->all ;
	}
	\@attachments;
}

# GET /api/item/:itemid/attachment/:itemattachmentid/#name
sub item_attachment_file {
	my $self = shift;

	my $attachment_id = $self->param('itemattachmentid');
	my $item_attachment = $self->zotero->schema->resultset('ItemAttachment')->find( $attachment_id  );

	# TODO only if the scheme is file:
	my $filepath = file_from_uri($item_attachment->uri);
	$self->render_file( filepath => $filepath,
		format => $self->app->types->detect( $item_attachment->mimetype ) );
}

sub zotero_documents {
	my ($self) = @_;
	[map { $self->zotero_item_TO_JSON($_) } $self->zotero->library
		->items
		->with_item_attachment_resultset('StoredItemAttachment')
		->items_with_pdf_attachments
		#->page(1)
		->all ];
}

sub zotero_item_TO_JSON {
	my ($self, $zotero_item) = @_;
	my $fields = $zotero_item->fields;

	my $authors = $self->zotero_item_get_authors($zotero_item);

	my $data = {};

	$data->{id} = $zotero_item->itemid;
	$data->{title} = $fields->{title} if exists $fields->{title};
	$data->{date} = ( $fields->{date} =~ /^(\d+)/ )[0] if exists $fields->{date};
	$data->{author} = $authors;

	$data->{attachments_url} = $self->url_for( '/api/item/' . $zotero_item->itemid . '/attachment' );

	$data;
}

sub zotero_item_get_authors {
	my ($self, $zotero_item) = @_;
	[ map {
			if ( $_->lastname and $_->firstname ) { # TODO, perhaps do this client-side?
				"@{[$_->lastname]}, @{[$_->firstname]}"
			} elsif( $_->lastname ) {
			"@{[$_->lastname]}"
			} else {
			"@{[$_->firstname]}"
			}
		}
		map { $_->creatorid->creatordataid } # TODO separate by creatortypeid and put as a convenience method in
		$zotero_item->item_creators->search({}, { order_by => 'orderindex' } )->all ];
}

sub documents {
	my ($self) = @_;
	$self->render( json => $self->zotero_documents );
}

sub collection {
	my ($self) = @_;
	my $data = {};
	$data = {
		label => 'My Library',
		id => 0, # id 0 is not from the DB, but I'll use it here
		children => [ map { $self->_get_collection($_) }
			$self->_get_toplevel_collections->all ],
	};
	$self->render( json => $data );
}

sub _get_toplevel_collections {
	my ($self) = @_;
	# TODO: maybe this can be cleaned up in Biblio::Zotero::DB itself
	my $get_top_level_collections = $self->zotero
		->library
		->collections
		->search( {
			libraryid => undef,
			parentcollectionid => undef });
}

sub _get_collection {
	my ($self, $collection) = @_;
	return {
		name => $collection->collectionname,
		id => $collection->collectionid,
		children => [ map { $self->_get_collection($_) }
			$collection->children->all ],
	};
}

1;
