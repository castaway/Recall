package Recall::URI;

use strict;
use warnings;
use v5.10;
use Moose;

has 'document' => ( isa => 'Recall::Schema::DB::Result::Document', is => 'ro' );
has 'catalyst' => ( isa => 'Catalyst', is => 'ro' );

sub uri {
	my $self = shift;
	my $d = $self->document;
	my $c = $self->catalyst;

	# Figure out what kind of document we are. Current options are:
	# * Page
    # * Tag
	# * Blog (default)

	if ($d->permanent) {
		my $local = $d->permanent->url;
		$local =~ s!^/!!;
		return $c->uri_for(
			$c->controller("Root")->action_for('default')
		) . $local;
	} elsif ($d->tag) {
        return $c->uri_for(
            $c->controller("Tag")->action_for('specific_tag'),
            $d->tag->name
        );
    } else {
		return $c->uri_for(
			$c->controller("Blog")->action_for('entry'), 
			[ 
				$d->first_published->edited->year,
				$d->first_published->edited->month,
				$d->first_published->edited->day,
				$d->slug
			]
		);
	}
}

1;