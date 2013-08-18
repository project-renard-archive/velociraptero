package Velociraptero::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';

use Biblio::Zotero::DB;
use strict;
use utf8::all;
use Mojo::JSON 'j';
use Try::Tiny;

# This action will render a template
sub index {
	my $self = shift;

	$self->param( app_config => j({
		url => $self->url_for( '/items' ),
	}) ); # JSON

	$self->render();
}

sub items {
	my ($self) = @_;
	return $self->documents();
}

sub zotero_documents {
	my ($self) = @_;
	[map { $self->zotero_item_toJSON($_) } $self->zotero->library->items->page(0)->all];
}

sub zotero_item_toJSON {
	my ($self, $zotero_item) = @_;
	my $fields = $zotero_item->fields;

	my $authors = [
		map {
			if ( $_->lastname and $_->firstname ) { # TODO, perhaps do this client-side?
				"@{[$_->lastname]}, @{[$_->firstname]}"
			} elsif( $_->lastname ) {
			"@{[$_->lastname]}"
			} else {
			"@{[$_->firstname]}"
			}
		}
		map { $_->creatorid->creatordataid }
		$zotero_item->item_creators->all ];

	my $data = {};

	$data->{title} = $fields->{title} if exists $fields->{title};
	$data->{date} = ( $fields->{date} =~ /^(\d+)/ )[0] if exists $fields->{date};
	$data->{author} = $authors;

	$data;
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
