# == WHAT
# Show the title of linked YouTube movies.
#
# == WHO
# Jan Moesen, 2012
#
# == INSTALL
# Save it in ~/.irssi/scripts/ and do /script load tubespam.pl
# OR
# Save it in ~/.irssi/scripts/autorun and (re)start Irssi

use strict;
use Irssi;
use LWP::Simple;
use HTML::TokeParser;
use vars qw($VERSION %IRSSI);

$VERSION = '0.1';
%IRSSI = (
	authors     => 'Jan Moesen',
	name        => 'TubeSpam',
	description => 'Show the title of linked YouTube movies.',
	license     => 'GPL',
	url         => 'http://jan.moesen.nu/',
);

sub tubespam_process_message {
	my ($server, $msg, $target, $nick) = @_;

	return unless $target =~ /^#(wijs|catena|lolwut)/;

	my $video_id = 0;
	if ($msg =~ m/https?:\/\/youtu\.be\/([-\w]+)/) {
		$video_id = $1;
	} elsif ($msg =~ m/https?:\/\/(?:www\.)youtube\.com\/.*\bv=([-\w]+)/) {
		$video_id = $1;
	}
	return unless $video_id;

	if ($msg =~ /!spoiler/) {
		if ($video_id eq 'b2duli2jvGw') {
			$server->command("kick $target $nick /sink $nick");
		} else {
			return;
		}
	}

	my $video_url = "http://gdata.youtube.com/feeds/api/videos/$video_id?v=2&fields=title";
	my $html = get($video_url); # Actually, this is XML, but it Should Work.
	return unless $html;
	my $parser = HTML::TokeParser->new(\$html);
	$parser->get_tag('title');
	my $title = $parser->get_token;
	return unless $title;

	$title = "$title->[1]";
	my $message = "YouTube video: \"$title\"";
	$server->command("msg $target $message");
}

Irssi::signal_add_last('message public', sub {
	my ($server, $msg, $nick, $mask, $target) = @_;
	Irssi::signal_continue($server, $msg, $nick, $mask, $target);
	tubespam_process_message($server, $msg, $target, $nick);
});
Irssi::signal_add_last('message own_public', sub {
	my ($server, $msg, $target) = @_;
	Irssi::signal_continue($server, $msg, $target);
	tubespam_process_message($server, $msg, $target, 'janmoesen');
});
