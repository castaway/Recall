package Recall::Controller::Admin;
use Moose;
use namespace::autoclean;
use Recall::Slug;

BEGIN {extends 'Catalyst::Controller'; }

use DateTime;

=head1 NAME

Recall::Controller::Admin - Administration pages

=head1 DESCRIPTION

Catalyst Controller that provides administration pages for Recall.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Recall::Controller::Admin in Admin.');
}

=head2 documents

Lists the available documents in the system and prompts to add new ones

=cut

sub documents :Path('document') :Args(0) {
	my ( $self, $c ) = @_;

	$c->stash->{uri_create} = $c->uri_for($self->action_for('create'));

	# Get list of available documents
	my $doc_table = $c->model("DB::Document");
	my @documents = map {
			{ 
				slug => $_->slug,
				edit_uri => $c->uri_for($self->action_for('edit'), [ $_->id ]),
				published => !!$_->live
			}
		} $doc_table->newest_first->all();

	$c->stash->{documents} = [ @documents ];
}

=head2 documents/create

Creates a document, the redirects to edit it

=cut

sub create :Path('document/create') :Args(0) {
	my ( $self, $c ) = @_;
	my $slug = Recall::Slug->new( name => $c->request->body_parameters->{slug} )->slug;

	# TODO - Make slug fit the pattern

	if (defined $slug) {
		my $doc_table = $c->model("DB::Document");
		my $d = $doc_table->find($slug);
		unless ($d) {
			my $result = $doc_table->create({slug => $slug});
			# Redirect to the edit page
			return $c->response->redirect($c->uri_for($self->action_for('edit'), [$result->id]));
		}
		# Else:
			# Render form and offer to edit
	}

	# Else render form

	$c->response->body('Creating');
}

=head2 documents/edit

Presents an editing form for a document and allows it to be saved

=cut

sub edit :Path('document/edit') :Args(1) {
	my ( $self, $c, $document_id ) = @_;

	my $doc_table = $c->model("DB::Document");
	my $document = $doc_table->find($document_id);

	unless ($document) {
		# TODO make sure this comparison works
		# TODO show an error for trying to edit a non-existent slug
	}

	# If post data and not previewing. Save it.
	my %post = %{$c->request->body_parameters};

	if (%post) {
		# TODO: CSRF protection	
		$c->detach('preview') if ($post{preview});
		my $version = $document->create_related('versions', { 
			edited => DateTime->now, 
			title => $post{title}, 
			source => $post{source} 
		});
		if ($post{publish}) {
			$document->first_published($version) unless ($document->first_published);
			$document->live($version);
			$document->update;
		}
        if ($post{index_tag}) {
            my ($tag) = $c->model("DB::Tag")->find($post{index_tag});
            $tag->about_document($document);
            $tag->update;
        }

        my @updated_tags = map { s/^\s*//; s/\s*$//; $_ } split(',', $post{tags} || "");
        my $tag_rs = $c->model("DB::Tag");
        $document->set_tags([map {
            $tag_rs->find_or_create({name => $_});
        } @updated_tags]);

        my ($tag) = $c->model("DB::Tag")->find($post{index_tag});
        if ($tag) {
            $tag->about_document($document);
            $tag->update;
        }
	}

	$c->stash->{id} = $document_id;
	$c->stash->{slug} = $document->slug;

	if ($post{preview}) {
		$c->stash->{title} = $post{title};
		$c->stash->{source} = $post{source};
	} else {
		my $latest = $document->versions->search(undef, {order_by => {-desc => 'edited' }, rows => 1 })->next;
		if ($latest) {
			$c->stash->{title} = $latest->title;
			$c->stash->{source} = $latest->source;
		}

        $c->stash->{my_tags} = join(", ", (map { $_->name } $document->tags));

        my @tags = $c->model("DB::Tag")->search(undef, { order_by => { -asc => 'name' }});
        my ($about_document_for) = $document->tag->name if ($document->tag);
        $c->stash->{all_tags} = [map { 
                { 
                    name => $_->name,
                    selected => ($about_document_for && $_->name eq $about_document_for)
                } 
            } @tags];
	}
	# Things to add later
		# revert to old versions
}

sub edit_nothing :Path('document/edit') :Args(0) {
	my ( $self, $c ) = @_;
	return $c->response->redirect($c->uri_for(
					$c->controller('Admin')->action_for('documents')
				), 301);
}

=head2 preview

=cut

sub preview :Private {
	my ( $self, $c ) = @_;
	my %post = %{$c->request->body_parameters};
	$c->stash->{title} = $post{title};
	$c->stash->{body} = $c->markdown->markdown($post{source});
	$c->stash->{template} = 'admin/preview.tt';
}

=head2 tag

Select tags for editing

=cut

sub tag :Path('tag') :Args(0) {
    my ( $self, $c ) = @_;
    my @tags = map {
            my $tag = $_;
            my $name = $tag->name;
            {
                count => $tag->get_column('document_count'),
                name => $name,
                documents_link => $c->uri_for($c->controller("Tag")->action_for('specific_tag'), [ $name ]),
                edit_link => $c->uri_for($self->action_for('specific_tag'), [ $name ])
            }

        } $c->model("DB::Tag")->with_document_count->all();
    $c->stash->{tags} = \@tags;
}

=head2 specific_tag

Edit a tag

=cut

sub specific_tag :Path('tag') :Args(1) {
    my ( $self, $c, $name ) = @_;
    $c->stash->{tag} = $name;

    my %post = %{$c->request->body_parameters};
    my $action = $post{submit};

    unless ($action) {
        return; # Just render the form
    }

    if ($action eq "Delete") {
        $c->model("DB::Tag")->find($name)->delete;
        $c->response->redirect(
            $c->uri_for($self->action_for('tag'))
        );
    }

    if ($action eq "Rename") {
        my $new_name = $post{new_name};
        my $orm = $c->model("DB::Tag")->find($name);
        $orm->name($new_name);
        $orm->update;
        $c->response->redirect(
            $c->uri_for($self->action_for('specific_tag'), [ $new_name ])
        );
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
