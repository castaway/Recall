#!/usr/bin/env perl

use strict;
use warnings;
use v5.18;
use WWW::Mechanize::TreeBuilder;
use WWW::Mechanize;
use URI::URL;
use LWP::UserAgent;

my %results;

my $mech = WWW::Mechanize->new();

WWW::Mechanize::TreeBuilder->meta->apply($mech);

$mech->get( "http://drax:3000/sitemap" );
my @links = grep {  $_->url =~ m!http://drax:3000/! } $mech->links();
for (@links) {
    my $url = $_->url;
    $mech->get($url);

    my @page_links = $mech->links;
    my @page_images = $mech->images;

    my @urls = map { $_->url_abs } (@page_images, @page_links);
    my @scripts = map { URI::URL->new( $_->attr('src'), $url )->abs } $mech->look_down( _tag => "script");
    my @forms = map { URI::URL->new( $_->attr('action'), $url )->abs } $mech->look_down( _tag => "form");

    for my $href (@urls, @scripts, @forms) {
        unless ($results{$href}) {
            $results{$href} = [];
        }
        push @{$results{$href}}, $url;
    }
}

my $ua = LWP::UserAgent->new;
$ua->timeout(10);

for my $url (keys %results) {
    # Filter out relative URIs that still work
    if ($url =~ m!http://drax:3000/!) {
        my $response = $ua->get($url);
        if ($response->is_success) {
            next;
        }
    } elsif ($url !~ m!dorward.me.uk!) {
    # Filter out URIs to non-Dorward domains
        next;
    }

    say $url;
    say "\t$_" for @{$results{$url}};
}