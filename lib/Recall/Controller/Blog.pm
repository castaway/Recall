package Recall::Controller::Blog;
use Moose;
use namespace::autoclean;

use DateTime;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Recall::Controller::Blog - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 Blog homepage

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Recall::Controller::Blog in Blog.');

    # TODO: Render most recent blog entries

}

=head2 year

Show blog entries for year

=cut

sub year :Path :Args(1) {
  my ( $self, $c, $year ) = @_;

  my $dt_start = DateTime->new(year => $year);
  my $dt_end = $dt_start->clone->add( years => 1, seconds => -1 );

  my @documents = $c->model("DB::Document")->get_first_published_between($dt_start, $dt_end);

  $c->response->body( (scalar @documents) . " documents published in $year");
}

=head2 month

Show blog entries for month

=cut

sub month :Path :Args(2) {
  my ( $self, $c, $year, $month ) = @_;

  my $dt_start = DateTime->new(year => $year, month => $month );
  my $dt_end = $dt_start->clone->add( months => 1, seconds => -1 );

  my @documents = $c->model("DB::Document")->get_first_published_between($dt_start, $dt_end);

  $c->response->body( (scalar @documents) . " documents published in $month / $year");
}

=head2 day

Show blog entries for day

=cut

sub day :Path :Args(3) {
  my ( $self, $c, $year, $month, $day ) = @_;

  my $dt_start = DateTime->new(year => $year, month => $month, day => $day );
  my $dt_end = $dt_start->clone->add( days => 1, seconds => -1 );

  my @documents = $c->model("DB::Document")->get_first_published_between($dt_start, $dt_end);

  $c->response->body( (scalar @documents) . " documents published on $day / $month / $year");
}



=head2 entry

Render a specific blog entry

=cut

sub entry :Path :Args(4) {
  my ( $self, $c, $year, $month, $day, $slug ) = @_;

  my $dt_start = DateTime->new(year => $year, month => $month, day => $day);
  my $dt_end = $dt_start->clone->add( days => 1, seconds => -1 );

  my ($document) = $c->model("DB::Document")->get_first_published_between($dt_start, $dt_end, slug => $slug);

  # 404 if there is no associated document
  $c->detach(qw/Root not_found/) unless ($document);

  # Get the latest published version of the document
  my $live = $document->live;

  # TODO - figure out cannonical URI for page and redirect to it if we aren't on it already

  # Populate the template
  $c->stash->{title} = $live->title;
  $c->stash->{body} = $c->markdown->markdown($live->source);
  $c->stash->{template} = 'page.tt';
}

=head1 AUTHOR

David Dorward,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
