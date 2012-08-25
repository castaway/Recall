#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use DateTime;

use lib qw[ 
	../../lib/ 
	/home/david/prog/sBuilder/prog/perl/
	];
use Recall::Schema::DB;
use Recall::Slug;
use SBuilder::DataSource::Resources;

my @blog_entries  = SBuilder::DataSource::Resources->search({ action => 'Blog' });

my @uniqueness;

foreach my $entry (@blog_entries) {
	
	my $id = $entry->id;
    my $path = $entry->path;

    # Special cases for broken data. TODO: Make sure the redirects are implemented to support this!
    if ($path eq '/2006/12/xml-rai.html') {
    	$path = "/2006/12/18/xml-rai.html";
    }
	if ($path eq '/2006/12/css-validator.html') {
    	$path = "/2006/12/18/css-validator.html";
    }    

    my ($year, $month, $day, $slug) = ($path =~ m!/(\d+)/(\d+)/(\d+)/(.+)!);
    
    # No constraints on what a slug can be for legacy content
    # $slug = Recall::Slug->new( name => $slug )->slug;

	my $datetime = DateTime->new(year => $year, month => $month, day => $day);    

    say "$id - $slug - $path - $datetime";

}
