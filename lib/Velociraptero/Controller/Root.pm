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
		url => $self->url_for( '/items' ),
	}) ); # JSON

	$self->render();
}

# GET /items
sub items {
	my ($self) = @_;
	return $self->documents();
}

# GET /item/:itemid/attachments
# only gets the ones that are application/pdf
sub item_attachments {
	my ($self) = @_;

	my @attachment_info = map {
		$self->item_attachment_info($_)
	} @{ $self->get_pdf_attachments( $self->param('itemid') ) };

	$self->render( json => [
		map { $self->url_for(
			'/item/'. $_->{itemid} .
			'/attachment/' . $_->{attachment_itemid} .
			'/' . uri_escape($_->{name}) )
		} @attachment_info ] );
}

sub item_attachment_info {
	my ($self, $item_attachment) = @_;
	{
		itemid => ( defined $item_attachment->sourceitemid
			? $item_attachment->get_column('sourceitemid')
			: $item_attachment->get_column('itemid') ),
		attachment_itemid => $item_attachment->get_column('itemid'),
		name => file( $item_attachment->get_column('path') =~ s/^storage://r )->basename, # path column may be in the form "storage:filename"
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

# GET /item/:itemid/attachment/:itemattachmentid/#name
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
	[map { $self->zotero_item_toJSON($_) } $self->zotero->library
		->items
		->with_item_attachment_resultset('StoredItemAttachment')
		->items_with_pdf_attachments->page(1)->all];
}

sub zotero_item_toJSON {
	my ($self, $zotero_item) = @_;
	my $fields = $zotero_item->fields;

	my $authors = $self->zotero_item_get_authors($zotero_item);

	my $data = {};

	$data->{id} = $zotero_item->itemid;
	$data->{title} = $fields->{title} if exists $fields->{title};
	$data->{date} = ( $fields->{date} =~ /^(\d+)/ )[0] if exists $fields->{date};
	$data->{author} = $authors;

	$data->{attachments_url} = $self->url_for( '/item/' . $zotero_item->itemid . '/attachments' );

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

sub test_documents {
	[
		{
			title => 'Learning From Data',
			author => 'Yaser S. Abu-Mostafa, Malik Magdon-Ismail and Hsuan-Tien Lin',
			#cover => 'http://ecx.images-amazon.com/images/I/41%2B9AHJZt2L._AA160_.jpg',
			date => 'Mar 27, 2012',
		},
		{
			title => 'Design Patterns: Elements of Reusable Object-Oriented Software',
			author => 'Erich Gamma, Richard Helm, Ralph Johnson and John Vlissides',
			cover => 'http://ecx.images-amazon.com/images/I/51Q-RLSadrL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
			date => 'Nov 10, 1994',
		},
		{
			title => 'Pattern Recognition and Machine Learning (Information Science and Statistics)',
			author => 'Christopher M. Bishop',
			date => 'Oct 1, 2007',
			#cover => 'http://ecx.images-amazon.com/images/I/612j5Uo43eL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
		{
			title => 'Bayesian Reasoning and Machine Learning',
			author => 'David Barber',
			date => 'Mar 12, 2012',
			cover => 'http://ecx.images-amazon.com/images/I/31Kr313aTJL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
		{
			title => 'Probabilistic Graphical Models: Principles and Techniques (Adaptive Computation and Machine Learning series)',
			author => 'Daphne Koller and Nir Friedman',
			date => 'Jul 31, 2009',
			cover => 'http://ecx.images-amazon.com/images/I/412Q24g5bGL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
		{
			title => 'Machine Learning: The Art and Science of Algorithms that Make Sense of Data',
			author => 'Peter Flach',
			date => 'Nov 12, 2012',
			cover => 'http://ecx.images-amazon.com/images/I/51Kw40Ov4kL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
		{
			title => 'Speech and Language Processing (2nd Edition)',
			author => 'Daniel Jurafsky and James H. Martin',
			date => 'May 26, 2008',
			cover => 'http://ecx.images-amazon.com/images/I/41M9fU8XtVL._AA160_.jpg',
		},
		{
			title => 'Information Theory, Inference and Learning Algorithms',
			author => 'David J. C. MacKay',
			date => 'Oct 6, 2003',
			cover => 'http://ecx.images-amazon.com/images/I/31NgZc70mQL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
		{
			title => 'Multiple View Geometry in Computer Vision',
			author => 'Richard Hartley and Andrew Zisserman',
			date => 'Apr 19, 2004',
			cover => 'http://ecx.images-amazon.com/images/I/519AnjySQuL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
		{
			title => 'Mastering OpenCV with Practical Computer Vision Projects',
			author => 'Daniel Lélis Baggio, Shervin Emami, David Millán Escrivá and Khvedchenia Ievgen',
			date => 'Dec 3, 2012',
			cover => 'http://ecx.images-amazon.com/images/I/5175kdB4o8L._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
		{
			title => 'Making Things See: 3D vision with Kinect, Processing, Arduino, and MakerBot (Make: Books)',
			author => 'Greg Borenstein',
			date => 'Feb 3, 2012',
			cover => 'http://ecx.images-amazon.com/images/I/51Q-qX4yGEL._SL160_PIsitb-sticker-arrow-dp,TopRight,12,-18_SH30_OU01_AA160_.jpg',
		},
	];
}

1;
