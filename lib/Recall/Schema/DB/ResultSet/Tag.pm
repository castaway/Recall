package Recall::Schema::DB::ResultSet::Tag;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

__PACKAGE__->load_components(qw(Helper::ResultSet::CorrelateRelationship));

sub with_document_count {
  my $self = shift;
 
  $self->search({},
    {
      '+columns' => 
        { document_count => $self->correlate('documents_to_tags')->related_resultset('document')->search({ "document.first_published_id" => { '!=' => undef } })->count_rs->as_query }
    }
  );
}

__PACKAGE__->meta->make_immutable;

1;
 