package Recall::Controller::Admin;
use Moose;
use namespace::autoclean;
use Recall::Slug;

BEGIN {extends 'Catalyst::Controller'; }

use DateTime;

=head1 NAME

Recall::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


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
	my @documents = sort { 
			$a->{slug} cmp $b->{slug};
		} map {
			{ 
				slug => $_->slug,
				edit_uri => $c->uri_for($self->action_for('edit'), [ $_->slug ]),
				published => !!$_->published
			}
		} $doc_table->all();

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
	}

	# Things to add later
		# tags
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

=head1 AUTHOR

David Dorward,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
