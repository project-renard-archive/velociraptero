use Test::More;

BEGIN { use_ok("Velociraptero::Util::PDFImage"); }
use FindBin;
use Path::Class;
use File::Temp;

my $test_pdf_file = dir( $FindBin::Bin )->subdir('data')->file('10.1.1.5.pdf');

my $png = Velociraptero::Util::PDFImage->pdf_to_png( "$test_pdf_file", density => 300 );

$fh0 = File::Temp->new();
file( $fh0->filename )->spew( iomode => '>:raw', $png);

ok( -s $fh0->filename, 'file contains data' );

system( 'xzgv', $fh0->filename );

$fh1 = File::Temp->new();
file( $fh1->filename )->spew( iomode => '>:raw',
  Velociraptero::Util::PDFImage->png_thumbnail( $png ) );

ok( -s $fh1->filename, 'thumbnail file contains data' );

system( 'xzgv', $fh1->filename );

done_testing;
