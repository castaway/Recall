package Recall::Schema::DB::ResultSet::DocumentsToTag;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

__PACKAGE__->load_components(qw(Helper::ResultSet::CorrelateRelationship));

__PACKAGE__->meta->make_immutable;

1;
 