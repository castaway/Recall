package Recall::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Recall::URI;

=head1 NAME

Recall::Controller::Tag - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

Shows a list of tags with at least 2 documents associated with them

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @tags = $c->model("DB::Tag")->with_document_count->all();


    my @all_tags = grep 
    	{ 
    		$_->{document_count} > 1
    	} map {
    		{
    			name => $_->name,
    			document_count => $_->get_column('document_count'),
    			url => $c->uri_for($self->action_for('specific_tag'), [ $_->name ])
    		}
    	} @tags;

    $c->stash->{all_tags} = \@all_tags;
    
}


=head2 specific_tag

Shows a list of documents for a given tag

=cut

sub specific_tag :Path :Args(1) {
    my ( $self, $c, $tag ) = @_;

    my ($tag_result) = $c->model("DB::Tag")->search(
    	{ 'name' => $tag },
    	{ 
    		prefetch => { documents_to_tags => 'document' } 
    	}
    );
    
    my @documents = map { 
    		{ 
    			title => $_->title,
    			url => Recall::URI->new( catalyst => $c, document => $_ )->uri
    		}
    	} $tag_result->documents->newest_first;



	$c->stash->{title} = $tag;
    $c->stash->{documents} = \@documents;

}




=head1 AUTHOR

David Dorward,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
