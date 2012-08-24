package Recall::Controller::Root;
use Moose;
use namespace::autoclean;
use Recall::Slug;
use Data::Dump qw/dump/;
BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Recall::Controller::Root - Root Controller for Recall

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

=head2 default

Figure out if a page is being requested and dispatch

=cut

sub default :Path {
    my ( $self, $c, @args ) = @_;

    # The last argument must be the slug
    my $slug = pop @args;
    $slug = Recall::Slug->new( name => $slug )->slug;

    # Find an associated document
    my $doc_table = $c->model("DB::Document");
    my $document = $doc_table->find($slug);

    # 404 if there is no associated document
    unless ($document) {
		$c->detach('not_found');
    }

    # Get the latest published version of the document
    my $published = $document->published_version;

    # 404 if the document exists only in draft form
    unless ($published) {
    	$c->detach('not_found');
    }

    # TODO - figure out cannonical URI for page and redirect to it if we aren't on it already

    # Populate the template
    $c->stash->{title} = $published->title;
	$c->stash->{body} = $c->markdown->markdown($published->source);
	$c->stash->{template} = 'page.tt';
}

=head2 not_found

A 404 error document

=cut

sub not_found :Private {
	my ( $self, $c, @args ) = @_;

    # The last argument must be the slug

    $c->response->body( 'Page not found' );
    $c->response->status(404);	
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

David Dorward,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
