package URIHistory;

use strict;
use warnings;
use v5.10;
use Moose;
use WWW::Mechanize;
use HTML::TreeBuilder::XPath;
use DateTime;
use DateTime::Format::DateParse;
use File::Slurp;
use JSON;

my $mech = WWW::Mechanize->new();

my $cache;
my $cache_file = read_file('cache.json', err_mode => 'quiet');
if ($cache_file) {
	$cache = decode_json($cache_file);
} else {
	$cache = {};
}

=head2 get_creation_date

Uses the Internet Archive's Way Back Machine to get the date that it first 
archived a given URI. From this we can get a rough first publication time.

=cut

sub get_creation_date {
	my ($self, $uri) = @_;
	my $html;
	if ($cache->{$uri}) {
		$html = $cache->{$uri};
	} else {
		$mech->get( q[http://wayback.archive.org/web/*/] . $uri );
		$html = $mech->content();
		$cache->{$uri} = $html;
	}
	my $tree = HTML::TreeBuilder::XPath->new;
	$tree->parse($html);
	my $xpath = q[//*[@id="wbMeta"]/p[1]/a[2]];
	my $date_link_content = $tree->findvalue($xpath);
	my $dt = DateTime::Format::DateParse->parse_datetime($date_link_content);
	$cache_file = encode_json($cache);
	write_file('cache.json', $cache_file);
	return $dt;
}

1;