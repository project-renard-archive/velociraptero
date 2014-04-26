package Velociraptero::Util::FestivalTTS;

use strict;
use warnings;

use IPC::Run3;

sub text_to_mp3 {
	my ($self, $text, $mp3data) = @_;
	# TTS after setting voice
	my $tts = q{text2wave -eval "(voice_cmu_us_bdl_arctic_clunits)"};
	# encode stdin to stdout
	my $mp3_encode = q{ lame - -};
	my $cmd = qq{ $tts | $mp3_encode };
	my ($in, $out, $err);
	$in = $text; # send text to festival
	# NOTE: this uses the shell
        run3 $cmd, \$in, \$out, \$err;
	die "text to speech was not successful" if $?;
	return $out; # contains encoded MP3
}


1;
