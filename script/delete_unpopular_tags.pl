#!/usr/bin/env perl

use strict;
use warnings;
use v5.18;
use lib "../lib";
use Recall::Schema::DB;
use Text::SimpleTable::AutoWidth;

my $recall = Recall::Schema::DB->connect('dbi:mysql:recall', 'recall', 'recall'); 
my @tags = grep {
        $_->{count} <= 1
    } map {
        my $tag = $_;
        my $name = $tag->name;
        {
            count => $tag->get_column('document_count'),
            name => $name,
        }

    } $recall->resultset("Tag")->with_document_count->all();

my $tl = Text::SimpleTable::AutoWidth->new(
        captions => ["Tag", "Count"]
    );

$tl->row($_->{name}, $_->{count}) foreach @tags;
print $tl->draw;


for my $tag_name (@tags) {
    $tag_name = $tag_name->{name};
    my $tag = $recall->resultset("Tag")->find({ name => $tag_name });
    $tag->delete;
}