package Velociraptero::Util::PDFImage;

use strict;
use warnings;

use Path::Class;
use Method::Signatures;
use IPC::Run3;
use Try::Tiny;
use autodie qw(:all);

my $threads;
try {
	require Sys::Info;
	my $info = Sys::Info->new;
	my $cpu  = $info->device( CPU => () );
	$threads = $cpu->count;
} catch {
	$threads = 1;
};

method png_thumbnail( Str $png, Int $height = 600 ) {
	my $stdin = $png;
	my $stdout;
	my $cmd = [ "convert",
		"-thumbnail", "x$height",
		"png:-", "png:-" ];
	run3( $cmd, \$stdin, \$stdout, undef );
	$stdout;
}

=method

=over 2

=item page_number : 0-based (default 0)

=item density: (default 300)

=back

=cut
# best to worst:
# $self->_pdf_to_png_mudraw( @_ );
# $self->_pdf_to_png_gs_imagemagick( @_ );
# $self->_pdf_to_png_imagemagick( @_ );
method pdf_to_png (
	Str $pdf_file,
	Int :$page_number = 0,
	Int :$density = 300
	) {
	#$self->_pdf_to_png_imagemagick( @_ );
	#$self->_pdf_to_png_gs_imagemagick( @_ );
	$self->_pdf_to_png_mudraw( @_ );
}

method _pdf_to_png_imagemagick (
	Str $pdf_file,
	Int :$page_number = 0,
	Int :$density = 300,
	) {

	my $stdout;
	my $cmd = [ "convert",
		#"-verbose",
		"-density", $density,
		"-quality", 90,
		"pdf:$pdf_file\[$page_number\]",
		"-flatten", # improves quality of text (no jagged edges)
		"png:-" ];
	# returns STDOUT
	run3( $cmd, undef, \$stdout, undef );
	$stdout;
}

method _pdf_to_png_gs_imagemagick (
	Str $pdf_file,
	Int :$page_number = 0,
	Int :$density = 300
	) {
	$page_number += 1; # gs is 1-based
	my $fh = File::Temp->new();
	my $cmd = [
		"gs",
		"-dNumRenderingThreads=$threads",
		qw(-q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT
		-dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2
		-sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 ),
		"-r${density}x${density}",
		"-dFirstPage=$page_number", "-dLastPage=$page_number",
	   	"-sOutputFile=@{[$fh->filename]}",
		"-f", $pdf_file ];
	my $ret = system( @$cmd );
	system('mogrify', '-flatten', $fh->filename);
	die "ghostscript conversion failed" if $ret;
	file($fh->filename)->slurp( iomode => '<:raw' );
}

method _pdf_to_png_mudraw (
	Str $pdf_file,
	Int :$page_number = 0,
	Int :$density = 300,
	) {

	my $fh = File::Temp->new( SUFFIX => '.png' );
	my $cmd = [ "mudraw",
		"-r", $density,
		"-o", $fh->filename,
		"$pdf_file", "$page_number" ];
	my $ret = system( @$cmd );
	die "mupdf conversion failed" if $ret;
	file($fh->filename)->slurp( iomode => '<:raw' );
}

1;
