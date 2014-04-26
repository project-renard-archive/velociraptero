use Test::More;

BEGIN { use_ok("Velociraptero::Util::FestivalTTS"); }
use FindBin;
use Path::Class;
use File::Temp;

my $test_phrase = q{In practical terms, computation of the determinant is
computationally inefficient, and there are faster ways to calculate the
inverse, such as via Gaussian Elimination.};

my $mp3 = Velociraptero::Util::FestivalTTS->text_to_mp3( $test_phrase );

$fh0 = File::Temp->new();
file( $fh0->filename )->spew( iomode => '>:raw', $mp3);

ok( -s $fh0->filename, 'file contains data' );

#system( 'mplayer', $fh0->filename );

done_testing;
