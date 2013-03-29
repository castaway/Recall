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
      prefetch => ['first_published', 'live', 'permanent', 'tag'] 
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
      order_by => { -asc => 'first_published.edited' },
      prefetch => ['first_published', 'live']
    })->next;

    my $previous = $self->search({
      %additional,
      'first_published.edited' => { "<" => $dtf->format_datetime($dt_start) }
    },
    {
      join => 'first_published',
      order_by => { -desc => 'first_published.edited' },
      prefetch => ['first_published', 'live']
    })->next;

    my %result;
    $result{previous} = $previous if $previous;
    $result{next} = $next if $next;

    return %result;
}

=head2 is_published

Filters out results that are not yet published

=cut

sub published {
  my $self = shift;
  return $self->search({ "document.first_published_id" => { '!=' => undef } });
}

=head2 newest_first

Orders by publication date. Newest first

=cut
 
sub newest_first {
  my $self = shift;
  return $self->search({},{
      join => 'first_published',
      order_by => {
        -desc => 'first_published.edited'
      }
    });
}


=head2 get_most_recent_articles( $limit )

Gets the most recent $limit articles that have been published

=cut

sub get_most_recent_articles {
    my ($self, $limit ) = @_;
    return $self->search(
        {},
        {
            join => 'first_published',
            order_by => {
                -desc => 'first_published.edited'
            },
            rows => $limit
        }
    );
}




__PACKAGE__->meta->make_immutable;

1;
 