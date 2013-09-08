#!/usr/bin/env perl

use strict;
use warnings;
use v5.18;
use lib "../lib";
use Recall::Schema::DB;


my $recall = Recall::Schema::DB->connect('dbi:mysql:recall', 'recall', 'recall'); 
my @versions = $recall->resultset("Version")->all();
for my $version (@versions) {
    my $source = $version->source;
    $source =~ s!http://blog.dorward.me.uk/!/blog/!g;
    $version->source($source);
    $version->update;
}
