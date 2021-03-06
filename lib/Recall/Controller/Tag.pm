package Recall::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Recall::URI;
use HTML::TagCloud;

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

    my $cloud = HTML::TagCloud->new;
    for my $tag (@tags) {
        my $count = $tag->get_column('document_count');
        my $name = $tag->name;
        if ($count > 1) {
            $cloud->add(
                $name, 
                $c->uri_for($self->action_for('specific_tag'), [ $name ]),
                $count
            );
        }
    }

    $c->stash->{cloud} = $cloud->html;
    $c->stash->{cloud_css} = $cloud->css;

    # my @all_tags = grep 
    # 	{ 
    # 		$_->{document_count} > 1
    # 	} map {
    # 		{
    # 			name => $_->name,
    # 			document_count => $_->get_column('document_count'),
    # 			url => $c->uri_for($self->action_for('specific_tag'), [ $_->name ])
    # 		}
    # 	} @tags;

    # $c->stash->{all_tags} = \@all_tags;
    
}


=head2 specific_tag

Shows a list of documents for a given tag

=cut

sub specific_tag :Path :Args(1) {
    my ( $self, $c, $tag ) = @_;

    my ($tag_result) = $c->model("DB::Tag")->search(
    	{ 'name' => $tag },
    	{ 
    		prefetch => [
                {
                    'about_document' => 'live'
                },
                { 
                    documents_to_tags => [
                        { 'document' => 'live' },
                        { 'document' => 'first_published' },
                        { 'document' => 'permanent' },
                    ]
                }
            ],
            order_by => {
                -desc => 'first_published.edited'
            }
    	}
    );

    unless ($tag_result) {
        $c->detach(qw[Root not_found]);
    }

    my @documents = map { 
    		{ 
    			title => $_->title,
    			url => Recall::URI->new( catalyst => $c, document => $_ )->uri
    		}
    	} $tag_result->documents;

    $c->stash->{title} = $tag;
    $c->stash->{documents} = \@documents;

    my $tag_index = $tag_result->about_document;

    if ($tag_index) {
        $c->stash->{title} = $tag_index->title;
        $c->stash->{html} = $tag_index->html;
    }

	

}




=head1 AUTHOR

David Dorward,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
