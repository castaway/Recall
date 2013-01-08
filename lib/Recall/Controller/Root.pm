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

    # Find an associated document
    my $per_table = $c->model("DB::Permanent");
    my ($version) = $per_table->find({ url => '/' . $c->request->path });
    
    # 404 if there is no associated document
    unless ($version) {
        $c->detach('not_found');
    }

    my $document = $version->document;
    
    # Get the latest published version of the document
    my $live = $document->live;

    # 404 if the document exists only in draft form
    unless ($live) {
    	$c->detach('not_found');
    }
    $c->stash->{document} = $document;
    $c->forward('Blog', 'render_entry');
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
