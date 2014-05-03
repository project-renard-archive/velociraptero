package Velociraptero::Util::TTS;

use strict;
use warnings;

use Text::Unidecode;

sub preprocess_for_tts {
	my ($self, $text) = @_;
	$_ = $text;
	$_ = unidecode($_); # FIXME this is a sledgehammer approach

	s/\[(\d+(,\s*\d+)*)\]/citation \1/gi; # [12,28] -> citations 12, 28
	s/Fig[. ]*(\d+)/Figure \1/gi; # Fig. 4 -> Figure 4
	s/Sec[. ]*(\d+)/Section \1/gi; # Sec. 2 -> Section 2
	s/e\.g\.,/for example,/gi; # (e.g., text) -> (for example, text)
	s/i\.e\.,/that is,/gi; # (i.e., text) -> (that is, text)
	$_;
}

1;
