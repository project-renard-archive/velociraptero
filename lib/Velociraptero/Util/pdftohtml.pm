package Velociraptero::Util::pdftohtml;

use strict;
use warnings;

use File::chdir;
use File::Which;
use Path::Class;
use Method::Signatures;

my $pdftohtml_bin = 'pdftohtml';

method pdftohtml_render( Str $pdf_file ) {
	my $temp = File::Temp->new( SUFFIX => '.html' );
	my $ret = system(  $pdftohtml_bin,
		qw(-s -i -noframes),
		$pdf_file, $temp->filename );
	die "pdftohtml did not run" if $ret;
	my $html = file($temp->filename)->slurp( iomode => '<:encoding(UTF-8)');

	# FIX: for bug
	# <https://bugs.freedesktop.org/show_bug.cgi?id=20379>
	# <http://sourceforge.net/p/pdftohtml/discussion/150221/thread/76fa7d5b/>
	$html =~ s{bgcolor="#A0A0A0"}{}; # remove grey background colour

	$html;
}

sub can_pdftohtml {
	!!which($pdftohtml_bin);
}

1;
