#!/usr/bin/env perl

use lib qw[../lib/ /home/david/perl5/lib/perl5/S];
use v5.10;
use Recall::Schema::DB;
use SQL::Translator;

my $recall = Recall::Schema::DB->connect('dbi:mysql:recall', 'recall', 'recall'); 
$recall->create_ddl_dir(['SQL::Translator::Producer::GraphViz'],
                       '0.1',
                       '/tmp/graph'
                       );