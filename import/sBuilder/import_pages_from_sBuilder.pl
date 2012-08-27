#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use DateTime;
use File::Slurp;

use lib qw[ 
	../../lib/ 
	/home/david/prog/sBuilder/prog/perl/
	];
use Recall::Schema::DB;
use Recall::Slug;
use SBuilder::DataSource::Resources;
use SBuilder::DataSource::MetaData;
use URIHistory;
use Try::Tiny;
  use List::Uniq ':all';


# Before trying to this the database. Test to see if we can import a history

my $h = URIHistory->new();

# Great password, eh? Good luck connecting to the server running this and not containing any data I care about...
my $recall = Recall::Schema::DB->connect('dbi:mysql:recall', 'recall', 'recall'); 
my $documents = $recall->resultset('Document');
my $tag_tab = $recall->resultset('Tag');

my @article_entries  = SBuilder::DataSource::Resources->search({ action => 'Template' });

foreach my $entry (@article_entries) {
    my $id = $entry->id;
    my $path = $entry->path;
	my $domain = $entry->domain;

	say $path;

	my $meta = SBuilder::DataSource::MetaData->find($id);;
	my $title = $meta->title;
	my $summary = $meta->description; # TODO add support for summaries to Recall. Ditto keywords / tags.

    my $file = "/home/david/sBuilder/source/dorward.me.uk" . $path;
    my $content = read_file($file);

	my $uri = "http://$domain$path";
	$uri =~ s!index.html$!!;

	my $perm = $path;
	$perm =~ s!index.html$!!;
    
	my $published;
    try {
		$published = $h->get_creation_date($uri);
	};
	$published = DateTime->new(year => 1970) unless $published;

    my @tags = uniq( map { $_ = lc $_; s/\s*$//g; s/^\s*//g; $_ } split ',', $meta->keywords );

    my $doc = $documents->create({ slug => $perm });
    my $ver = $doc->create_related('versions', { 
			edited => $published, 
			title => $title, 
			source => $content 
		});
    my $per = $doc->create_related('permanent', { 
			url => $perm, 
		});
    $doc->first_published($ver);
    $doc->live($ver);

    foreach my $tag_name (@tags) {
        next unless $tag_name;
        say ' * ' . $tag_name;
        my $tag = $tag_tab->find_or_create({name => $tag_name});
        $doc->add_to_tags($tag);
    }
    $doc->update;
    
}