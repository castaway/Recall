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

=head2 get_next_and_previous( $dt_start, $dt_end, %additional )

Given a start and end DateTime object and (optionally)
any additional key/value pairs of search parameters, 
gets the first documents that meet the additional 
criteria that are outside the region.

=cut

sub get_next_and_previous {
	my ($self, $dt_start, $dt_end, %additional) = @_;
	my $dtf = $self->result_source->schema->storage->datetime_parser;

	my $next = $self->search({
      %additional,
      'first_published.edited' => { ">" => $dtf->format_datetime($dt_end) }
    },
    {
      join => 'first_published',
      order_by => { -asc => 'first_published.edited' }
    })->next;

    my $previous = $self->search({
      %additional,
      'first_published.edited' => { "<" => $dtf->format_datetime($dt_start) }
    },
    {
      join => 'first_published',
      order_by => { -desc => 'first_published.edited' }
    })->next;

    my %result;
    $result{previous} = $previous if $previous;
    $result{next} = $next if $next;

    return %result;
}

=head2 is_published

Filters out results that are not yet published

=cut

sub is_published {
  my $self = shift;
  return $self->search({ "document.first_published_id" => { '!=' => undef } });
}
 


__PACKAGE__->meta->make_immutable;

1;
 