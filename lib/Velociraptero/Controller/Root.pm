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
use List::UtilsBy qw(sort_by);
use PDF::pdf2json;
use Class::Unload;

use Velociraptero::Util::PDFImage;
use Velociraptero::Util::pdf2htmlEX;
use Velociraptero::Util::pdftohtml;
use Velociraptero::Util::FestivalTTS;
use Velociraptero::Util::PDFSentence;

use constant MIMETYPE_PDF => 'application/pdf';

# GET /
sub index {
	my $self = shift;

	$self->param( app_config => j({
		url => $self->url_for( '/api/item' ),
		category_url => $self->url_for( '/api/library' ),
		push_state => $self->flash('push_state')
	}) ); # JSON
	my $pdfjs_url = $self->url_for('/vendor/zmughal-build-pdf.js/web/viewer.html');
	my $pdf2htmlEX_url = $self->url_for('/api/pdf2htmlEX_render');
	if( Velociraptero::Util::pdf2htmlEX->can_pdf2htmlEX ) {
		$self->param( viewer_url => $pdf2htmlEX_url );
	} else {
		$self->param( viewer_url => $pdfjs_url );
	}
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
	$self->render( json => $self->item_attachments_TO_JSON($self->param('itemid')) );
}

sub item_attachments_TO_JSON {
	my ($self, $itemid) = @_;
	my @attachment_info = map {
		$self->item_attachment_info($_)
	} @{ $self->get_pdf_attachments( $itemid ) };
	[ map {
		{
			id => $_->{attachment_itemid},
			itemid => $_->{itemid},
			title => $_->{title},
			mimetype => $_->{mimetype},
			item_attachment_file_url => $self->url_for(
				'/api/item/'. $_->{itemid} .
				'/attachment/' . $_->{attachment_itemid} .
				'/' . $_->{name} ),
			item_attachment_cover_url => $self->url_for(
				'/api/item/'. $_->{itemid} .
				'/attachment-cover/' . $_->{attachment_itemid} ),
			tts_model_url => $self->url_for(
				'/api/item/'. $_->{itemid} .
				'/attachment-sentence/' . $_->{attachment_itemid} ),
		} } @attachment_info ];
}

sub item_attachment_info {
	my ($self, $item_attachment) = @_;
	my $data = {
		itemid => ( defined $item_attachment->sourceitemid
			? $item_attachment->get_column('sourceitemid')
			: $item_attachment->get_column('itemid') ),
		attachment_itemid => $item_attachment->get_column('itemid'),
		mimetype => $item_attachment->get_column('mimetype'),
		name => ($item_attachment->uri->path_segments)[-1],
	};
	if( $data->{itemid} == $data->{attachment_itemid} ) {
		# just a file with no sourceitem
		$data->{title} = $data->{name};
	} else {
		# get title from title of sourceitem
		my $item_info = $self->zotero_item_TO_JSON($item_attachment->sourceitemid);
		$data->{title} = defined $item_info->{title}
			?  $item_info->{title}
			: '-';
	}
	$data;
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

	my $item_attachment = $self->_get_itemattachmentid( $self->param('itemattachmentid') );
	$self->render_file( filepath => $self->_get_filepath_from_itemattachmentid( $self->param('itemattachmentid') ),
		format => $self->app->types->detect( $item_attachment->mimetype ) );
}

sub _get_itemattachmentid {
	my ($self, $attachment_id) = @_;
	my $item_attachment = $self->zotero->schema->resultset('ItemAttachment')->find( $attachment_id  );
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

	$data->{item_attachment_cover_url} = $self->url_for(
				'/api/item/'. $zotero_item->itemid . '/attachment-cover' );

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
		$zotero_item->item_creators->search(
			{ creatortypeid => $self->zotero_creatortypeid_author },
			{ order_by => 'orderindex' } )->all ];

}

sub documents {
	my ($self) = @_;
	$self->render( json => $self->zotero_documents );
}

sub collection {
	my ($self) = @_;
	my $data = {};
	$data = [ {
		label => 'My Library',
		id => 0, # id 0 is not from the DB, but I'll use it here
		children => $self->_get_collection_recurse(
			scalar($self->_get_toplevel_collections)),
	} ];
	$self->render( json => [$data] );
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
	my $id = $collection->collectionid;
	return {
		label => $collection->collectionname,
		id => $collection->collectionid,
		url => $self->url_for("/api/library/$id"),
		datatable_url => $self->url_for("/api/library/$id/datatable"),
		children => $self->_get_collection_recurse( 
			scalar($collection->children)),
	};
}

sub _get_collection_recurse {
	my ($self, $collection_rs) = @_;
	[ map { $self->_get_collection($_) }
		sort_by { fc $_->collectionname  }
		$collection_rs->all ];
}

# GET /api/library/:collectionid
sub collection_items {
	my ($self) = @_;
	$self->render( json =>
		$self->collection_items_TO_JSON(
			$self->param('collectionid') ) );
}

sub collection_items_TO_JSON {
	my ($self, $collectionid) = @_;
	[ map { $self->zotero_item_TO_JSON($_) }
		$self->zotero->schema
			->resultset('Collection')
			->find($collectionid)
			->collection_items_rs
			->search_related_rs('itemid')
			->all ];
}

# GET /api/library/:collectionid/datatable
sub collection_items_datatable {
	my ($self) = @_;
	my $item_list = $self->collection_items_TO_JSON(
				$self->param('collectionid') );
	for my $item (@$item_list) {
		$item->{authors} = join "; ", @{$item->{author}};
		delete $item->{author};

		# patch up missing fields
		for my $field (qw/title date/) {
			$item->{$field} = '-' unless exists $item->{$field};
		}
	}
	my $data = {
		sEcho => 1,
		iTotalRecords => scalar @$item_list,
		iTotalDisplayRecords => scalar @$item_list,
		aaData => $item_list
	};
	$self->render( json => $data );
}

# GET /api/item/:itemid/attachment-cover
sub item_attachment_cover_all {
	my ($self) = @_;
	# TODO: what if there are no attachments?
	my $itemattachmentid = $self->get_pdf_attachments(
		$self->param('itemid') )->[0]->get_column('itemid');
	$self->redirect_to($self->url_for() . '/' . $itemattachmentid );
}

# GET /api/item/:itemid/attachment-cover/:itemattachmentid
sub item_attachment_cover {
	my ($self) = @_;
	# TODO: what if this fails
	my $png_thumb =
		$self->_get_thumbnail_for_itemattachmentid(
			$self->param('itemattachmentid') );
	$self->render( data => $png_thumb, format => 'png' )
}

sub _get_thumbnail_for_itemattachmentid {
	my ($self, $itemattachmentid) = @_;
	$self->cache->compute("thumb-$itemattachmentid", '1 year', sub {
		my $filepath = $self->_get_filepath_from_itemattachmentid($itemattachmentid);

		my $png_data = Velociraptero::Util::PDFImage->pdf_to_png( "$filepath"  );
		my $png_thumb_data = Velociraptero::Util::PDFImage->png_thumbnail( $png_data );
	});
}

# /api/pdf2htmlEX_render
sub pdf2htmlEX_render {
	my ($self) = @_;
	my $file_url = Mojo::URL->new( $self->param('file') );
	my $file_parts = $file_url->path;
	shift @$file_parts while $file_parts->[0] ne 'attachment';
	my $itemattachmentid = $file_parts->[1];
	$self->render( text =>
		$self->_get_pdfhtml_for_itemattachmentid($itemattachmentid)
		);
}

sub _get_pdfhtml_for_itemattachmentid {
	my ($self, $itemattachmentid) = @_;
	$self->cache->compute("pdf2htmlEX-$itemattachmentid", '1 year', sub {
		my $filepath = $self->_get_filepath_from_itemattachmentid($itemattachmentid);

		my $html;
		try {
			$html = Velociraptero::Util::pdf2htmlEX->pdf2htmlEX_render( "$filepath"  );
		} catch {
			$html = Velociraptero::Util::pdftohtml->pdftohtml_render( "$filepath"  );
		};
		$html;
	});
}

sub _get_sentence_data {
	my ($self, $itemattachmentid) = @_;;
	$self->cache->compute("sentence-$itemattachmentid", '1 year', sub {
		my $filepath = $self->_get_filepath_from_itemattachmentid(  $itemattachmentid );
		Velociraptero::Util::PDFSentence->sentence_data("$filepath");
	});
}

# GET /api/item/:itemid/attachment-sentence/:itemattachmentid
sub get_sentences {
	my ($self) = @_;
	my $sentences = $self->_get_sentence_data( $self->param('itemattachmentid') );

	my $playlist = [];
	for my $sentence_id (0..@$sentences-1) {
		my $sentence = $sentences->[$sentence_id];
		my $url = $self->url_for(
			$self->url_for()
			. '/tts/'
			. $sentence_id );
		$sentence->{tts_url} =  $url;
		push @$playlist, {
			title => "$sentence_id: @{[$sentence->{text}]}",
			mp3 => $url,
		};
	}

	$self->render( json => { sentences => $sentences,
		playlist => $playlist } );

	# algorithm
	# for every page
	#   for every element on page
	#      concatentate string
	#      #add tag saying which element it came from (this might be useful another time)
	# Run sentence splitter
	#    get offsets
	#    record sentence ordinal value => [beginning, end]
	#    #tag offsets as belong to a given sentence's ordinal value
}

sub _get_filepath_from_itemattachmentid {
	my ($self, $itemattachmentid) = @_;
	my $filepath = file_from_uri(
			$self->_get_itemattachmentid( $itemattachmentid )->uri
		);
	$filepath;
}

# GET /api/item/:itemid/attachment-sentence/:itemattachmentid/tts/:phraseid
sub get_phrase_tts {
	my ($self) = @_;
	my $sentences = $self->_get_sentence_data( $self->param('itemattachmentid') );
	my $sentence = $sentences->[ $self->param('phraseid') ];
	my $text = $sentence->{text};

        # for reload
	Class::Unload->unload('Velociraptero::Util::TTS');
	require Velociraptero::Util::TTS;
	my $preproc = Velociraptero::Util::TTS->preprocess_for_tts( $text );

	# TODO : this is blocking FIXME
	my $mp3 = Velociraptero::Util::FestivalTTS->text_to_mp3($preproc);
	$self->render( data => $mp3, format => 'mp3' );
}

1;
