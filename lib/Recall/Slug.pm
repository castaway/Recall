package Recall::Slug;

use strict;
use warnings;
use v5.10;
use Moose;

has 'name' => ( isa => 'Str', is => 'rw' );

sub slug {
	my $self = shift;
	my $slug = lc $self->name;
	$slug =~ s/[^a-z0-9]+/-/g;
	$slug =~ s/^-//;
	$slug =~ s/-$//;
	return $slug;
}

1;