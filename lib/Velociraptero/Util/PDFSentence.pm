package Velociraptero::Util::PDFSentence;

use strict;
use warnings;

use PDF::pdf2json;
use Lingua::EN::Sentence::Offsets qw/get_offsets add_acronyms/;

# get abbreviations from the __DATA__ section
my $abbrev = join "", <DATA>;
$abbrev =~ s,\s*#.*$,,mg;
my @abbrev = split ' ', $abbrev;
add_acronyms(@abbrev);

sub sentence_data {
	my ($self, $filepath) = @_;

	my $pdf_json = PDF::pdf2json->pdf2json($filepath);

	my $string;

	my $prev_text = '';
	for my $page (@$pdf_json) {
		my $page_text = $page->{text};
		my $prev_y = $page->{text}[0]{top};
		for my $text_el (@$page_text) {

			# if we are on a new line and the previous line did not end in a hyphen
			# add a space
			$string .= ' ' if( $text_el->{top} != $prev_y and $prev_text !~ /-$/ );

			# remove link text
			# (NOTE this can be anywhere in the data value, not
			# just at the beginning --- which is bad. Enough to
			# make me rethink using pdf2json.)
			$text_el->{data} =~ s/actionGoTo:\d+,//g;

			$string .= $text_el->{data};
			
			$prev_text = $text_el->{data};
			$prev_y = $text_el->{top};
		}
	}

	my $offsets = get_offsets( $string );
	# NOTE Offsets need to be sorted because it appears that they might not
	# be in order.  Not sure what that means or if that is a bug.
	$offsets = [ sort { $a->[0] <=> $b->[0] } @$offsets ];
	my $sentences = [];
	for my $o (@$offsets) {
		my $data = {
			text => substr($string, $o->[0], $o->[1]-$o->[0]),
			offsets => $o,
		};
		push @$sentences, $data;
	}
	$sentences;
}


1;
# NOTE the following abbreviations are part of citations. It would make better
# sense to use a separate set of abbreviations in the reference section than in
# the rest of the text.
#
# This may require modifying Lingua::EN::Sentence::Offsets to use objects
# instead of package variables to store abbreviations.
__DATA__
trans   # transactions
proc    # proceedings / processing
vol     # volume
inform  # information
pp      # pages
comput  # computing
conf    # conference
soc     # society
anal    # analysis

sec     # section
fig     # figure
