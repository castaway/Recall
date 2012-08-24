#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use List::Uniq;

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
    my ($slug) = ($path =~ m!/([^/]*)\.html!);
    $slug = Recall::Slug->new( name => $slug )->slug;

    push @uniqueness, $slug;

}

my @really_unique = List::Uniq::uniq(@uniqueness);

say scalar @really_unique;
say scalar @uniqueness;