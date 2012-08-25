package Recall::Schema::DB::ResultSet::Document;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

=head2 get_first_published_between( $dt_start, $dt_end, %additional )

Given a start and end DateTime object and (optionally)
any additional key/value pairs of search parameters, 
gets documents that were first published between two given dates.

=cut

sub get_first_published_between {
	my ($self, $dt_start, $dt_end, %additional) = @_;
	my $dtf = $self->result_source->schema->storage->datetime_parser;
	return $self->search({
      %additional,
      'first_published.edited' => {
        -between => [
          $dtf->format_datetime($dt_start),
          $dtf->format_datetime($dt_end),
        ],
      }
    },
    {
      join => 'first_published',
    });
}

__PACKAGE__->meta->make_immutable;

1;
 