use Test::More;

BEGIN { use_ok("Velociraptero::Util::pdf2htmlEX"); }
use FindBin;
use Path::Class;
use File::Temp;

my $test_pdf_file = dir( $FindBin::Bin )->subdir('data')->file('10.1.1.5.pdf');

SKIP: {
  skip 'pdf2htmlEX not available'
    unless Velociraptero::Util::pdf2htmlEX->can_pdf2htmlEX;

    my $html = Velociraptero::Util::pdf2htmlEX->pdf2htmlEX_render( "$test_pdf_file" );

    ok( length $html, 'html generated');
}

done_testing;
