#!/usr/bin/env perl

use strict;
use warnings;

use Festival::Client::Async qw(parse_lisp);

my $fest = Festival::Client::Async->new;
my $lisp = '(SayText "this is a test")';
my $actions = { LP => sub {}, WV => sub {} };
$fest->server_eval_sync($lisp, $actions); # blocking
$lisp = qq{
(set! utt1 (Utterance Text "Hello world"))
(utt.synth utt1)
};

__END__

$fest->server_eval($lisp); # just queues $lisp for writing
if ($fest->write_pending) {
    while (defined(my $b = $fest->write_more)) {
        last if $b == 0;
    }
}
while (defined(my $b = $fest->read_more)) {
    last if $b == 0;
}
if ($fest->error_pending) {
    # Oops
}
while ($fest->wave_pending) {
    my $waveform_data = $fest->dequeue_wave;

    # Do something with it
}
while ($fest->lisp_pending) {
    my $lisp = $fest->dequeue_lisp;
    my $arr = parse_lisp($lisp);

    # Do something with it
}
