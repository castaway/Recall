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

# Great password, eh? Good luck connecting to the server running this and not containing any data I care about...
my $recall = Recall::Schema::DB->connect('dbi:mysql:recall', 'recall', 'recall'); 
my $documents = $recall->resultset('Document');

my @blog_entries  = SBuilder::DataSource::Resources->search({ action => 'Blog' });

foreach my $entry (@blog_entries) {
	
	my $id = $entry->id;
    my $path = $entry->path;

    my $date_slug;

    # Special cases for broken data. TODO: Make sure the redirects are implemented to support this!
    if ($path eq '/2006/12/xml-rai.html') {
    	$date_slug = "/2006/12/18/xml-rai.html";
    } elsif ($path eq '/2006/12/css-validator.html') {
    	$date_slug = "/2006/12/18/css-validator.html";
    } else {
    	$date_slug = $path;
    }

    my ($year, $month, $day, $slug) = ($date_slug =~ m!/(\d+)/(\d+)/(\d+)/(.+)!);
    
    # No constraints on what a slug can be for legacy content
    # $slug = Recall::Slug->new( name => $slug )->slug;

	my $datetime = DateTime->new(year => $year, month => $month, day => $day);    


	my $meta = SBuilder::DataSource::MetaData->find($id);;
	my $title = $meta->title;
	my $summary = $meta->description; # TODO add support for summaries to Recall. Ditto keywords / tags.


    my $file = "/home/david/sBuilder/source/blog.dorward.me.uk" . $path;
    my $content = read_file($file);

    # TODO : Parse out the image URIs, fetch the images, upload them a service, then update the content

    say "$id - $slug - $path - $datetime";

    my $doc = $documents->create({ slug => $slug});
    my $ver = $doc->create_related('versions', { 
			edited => $datetime, 
			title => $title, 
			source => $content 
		});
    $doc->first_published($ver);
    $doc->live($ver);
    $doc->update;

}
