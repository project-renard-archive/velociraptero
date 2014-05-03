use Test::More;
use Test::Deep;

BEGIN { use_ok("Velociraptero::Util::PDFSentence"); }
use FindBin;
use Path::Class;

my $test_pdf_file = dir( $FindBin::Bin )->subdir('data')->file('10.1.1.5.pdf');

my $data = Velociraptero::Util::PDFSentence->sentence_data(  $test_pdf_file );
my $find_sentence = (grep { $_->{text} =~ /^TEST EXAMPLE/ } @$data)[0];
like( $find_sentence->{text}, qr/^TEST EXAMPLE\s+To demonstrate/ );

my $rot_sent_0 = "The choice of curvature as matching parameter for shape recognition provides invariance to rotation";
my $rot_sent_1 = "We have performed tests with one of the contours rotated more than 10 degrees";

my $rot_sent_idx_0 = (grep { $data->[$_]{text} =~ /$rot_sent_0/ } 0..@$data-1)[0];
my $rot_sent_idx_1 = (grep { $data->[$_]{text} =~ /$rot_sent_1/ } 0..@$data-1)[0];

ok( $rot_sent_idx_0 < $rot_sent_idx_1 );


done_testing;
