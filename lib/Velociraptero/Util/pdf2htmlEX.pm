package Velociraptero::Util::pdf2htmlEX;

use strict;
use warnings;

use File::chdir;
use File::Which;
use Path::Class;
use Method::Signatures;

my $pdf2htmlEX_bin = 'pdf2htmlEX';

method pdf2htmlEX_render( Str $pdf_file ) {
	my $fh = File::Temp->new(UNLINK => 0);

	my $pdf_file_name = file( $pdf_file )->absolute;
	my $temp_file = file($fh->filename);
	my $ret;
	{
		local $CWD = $temp_file->dir;
		# TODO: close STDERR
		$ret = system( $pdf2htmlEX_bin, $pdf_file_name,	$temp_file->basename );
	}
	die "pdf2htmlEX did not run" if $ret;
	$temp_file->slurp;
}

sub can_pdf2htmlEX {
	!!which('pdf2htmlEX');
}

1;
