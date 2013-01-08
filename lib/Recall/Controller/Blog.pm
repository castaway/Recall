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

    # Redirect to canonical URI
    my $canonical = $c->uri_for(
            $self->action_for('index')
        );
    if ($c->request->uri ne $canonical) {
    $c->response->redirect($canonical, 301);
    return;
    }
    $c->stash->{canonical} = $canonical;

    $c->forward('recent');
}

=head2 Blog homepage

=cut

sub feed :Path('feed') :Args(0) {
    my ( $self, $c ) = @_;

    # Redirect to canonical URI
    my $canonical = $c->uri_for(
            $self->action_for('feed')
        );
    if ($c->request->uri ne $canonical) {
    $c->response->redirect($canonical, 301);
    return;
    }
    $c->stash->{canonical} = $canonical;

    $c->forward('recent');

    # TODO: Use "Most recently edited time of most recently edited document" where apropriate

    $c->stash->{feed} = {
      format      => 'Atom',
      id          => $c->req->base,
      title       => "Dorward's Ramblings",
      description => "David Dorward's Blog",
      link        => $c->req->base,
      modified    => $c->stash->{documents}[0]{raw}->first_published->edited,
      entries => [
        map {
            {
                id       => $_->{uri},
                link     => $_->{uri},
                title    => $_->{title},
                modified => $_->{raw}->first_published->edited,
                content  => $_->{content}
            };
        } @{$c->stash->{documents}}
      ],
    };
  $c->forward('Recall::View::Feed');



}

=head2 recent

Get most recent blog entries

=cut

sub recent :Private {
  my ( $self, $c) = @_;
  
  my @documents = $c->model("DB::Document")->get_most_recent_articles(10);
    my @documents_data = map {
        {
            title => $_->title,
            uri => $self->get_url_for_document($c, $_),
            content => $_->html,
            published => $self->template_ready_date($c, $_->first_published->edited),
            raw => $_
        };
    } @documents;
    $c->stash->{documents} = \@documents_data;
}

=head2 period

Get blog enteries for a given period

=cut

sub period :Private {
  my ( $self, $c) = @_;
  my $dt_start = $c->stash->{range}{start};
  my $dt_end = $c->stash->{range}{end};
  my @documents = $c->model("DB::Document")->get_first_published_between($dt_start, $dt_end);
  my %nearby = $c->model("DB::Document")->get_next_and_previous($dt_start, $dt_end);
  my @documents_data = map {
        {
            title => $_->title,
            uri => $self->get_url_for_document($c, $_)
        };
    } @documents;
  $c->stash->{documents} = \@documents_data;
  $c->stash->{nearby} = \%nearby;
}

=head2 year

Show blog entries for year

=cut

sub year :Path :Args(1) {
  my ( $self, $c, $year ) = @_;
  my $dt_start = DateTime->new(year => $year);

  # Redirect to canonical URI
  my $canonical = $c->uri_for(
            $self->action_for('year'),
            [ split '-', $dt_start->strftime("%Y") ]
        );
  if ($c->request->uri ne $canonical) {
    $c->response->redirect($canonical, 301);
    return;
  }
  $c->stash->{canonical} = $canonical;

  # Get data
  my $dt_end = $dt_start->clone->add( years => 1, seconds => -1 );
  $c->stash->{range} = { start => $dt_start, end => $dt_end };
  $c->forward('period');

  # Get metadata about nearby data
  foreach my $key (keys %{$c->stash->{nearby}}) {
    my $date = $c->stash->{nearby}{$key}->first_published->edited;
    my $value = {
        text => $date->strftime("%Y"),
        uri => $c->uri_for(
            $self->action_for('year'),
            [ split '-', $date->strftime("%Y") ]
        )
    };
    $c->stash->{nearby}{$key} = $value;
  }

  # Add a title
  $c->stash->{title} = $dt_start->strftime("Entries for %Y");
  $c->stash->{period_length} = "year";
}

=head2 month

Show blog entries for month

=cut

sub month :Path :Args(2) {
  my ( $self, $c, $year, $month ) = @_;
  my $dt_start = DateTime->new(year => $year, month => $month );

  # Redirect to canonical URI
  my $canonical = $c->uri_for(
            $self->action_for('month'),
            [ split '-', $dt_start->strftime("%Y-%m") ]
        );
  if ($c->request->uri ne $canonical) {
    $c->response->redirect($canonical, 301);
    return;
  }
  $c->stash->{canonical} = $canonical;

  # Get data
  my $dt_end = $dt_start->clone->add( months => 1, seconds => -1 );
  $c->stash->{range} = { start => $dt_start, end => $dt_end };
  $c->forward('period');

  # Get metadata about nearby data
  foreach my $key (keys %{$c->stash->{nearby}}) {
    my $date = $c->stash->{nearby}{$key}->first_published->edited;
    my $value = {
        text => $date->strftime("%B %Y"),
        uri => $c->uri_for(
            $self->action_for('month'),
            [ split '-', $date->strftime("%Y-%m") ]
        )
    };
    $c->stash->{nearby}{$key} = $value;
  }

  # Add a title
  $c->stash->{title} = $dt_start->strftime("Entries for %B %Y");
  $c->stash->{period_length} = "month";
}

=head2 day

Show blog entries for day

=cut

sub day :Path :Args(3) {
  my ( $self, $c, $year, $month, $day ) = @_;
  my $dt_start = DateTime->new(year => $year, month => $month, day => $day );
  
  # Redirect to canonical URI
  my $canonical = $c->uri_for(
            $self->action_for('day'),
            [ split '-', $dt_start->strftime("%Y-%m-%d") ]
        );
  if ($c->request->uri ne $canonical) {
    $c->response->redirect($canonical, 301);
    return;
  }
  $c->stash->{canonical} = $canonical;
  
  # Get data
  my $dt_end = $dt_start->clone->add( days => 1, seconds => -1 );
  $c->stash->{range} = { start => $dt_start, end => $dt_end };
  $c->forward('period');

  # Get metadata about nearby data
  foreach my $key (keys %{$c->stash->{nearby}}) {
    my $date = $c->stash->{nearby}{$key}->first_published->edited;
    my $value = { 
        text => $date->strftime("%a. %d %B %Y"), 
        uri => $c->uri_for(
            $self->action_for('day'),
            [ split '-', $date->strftime("%Y-%m-%d") ]
        )
    };
    $c->stash->{nearby}{$key} = $value;
  }

  # Add a title
  $c->stash->{title} = $dt_start->strftime("Entries for %a. %d %B %Y");
  $c->stash->{period_length} = "day";
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

  # Redirect to canonical URI
  my $canonical = $self->get_url_for_document($c, $document);
  if ($c->request->uri ne $canonical) {
    $c->response->redirect($canonical, 301);
    return;
  }
  $c->stash->{canonical} = $canonical;
  $c->stash->{document} = $document;
  $c->forward('render_entry');
}

sub render_entry :Private {
    my ($self, $c) = @_;
    my $document = $c->stash->{document};
    my $published = $document->first_published;
    # my $edited = $document->last_edited;

    # Populate the template
    $c->stash->{title} = $document->title;
    $c->stash->{date} = {
    published => $self->template_ready_date($c, $published->edited)
    };
    # my $edited_time = $edited->edited->strftime("%a. %d %B %Y");
    # if ($edited_time ne $c->stash->{date}{published}{human}) {
    #   $c->stash->{date}{edited} = {
    #       human => $edited_time,
    #       iso => $edited->edited->strftime("%Y-%m-%d"),
    #   };
    # }
    $c->stash->{body} = $document->html;
    $c->stash->{template} = 'blog/entry.tt';
}

=head2 get_url_for_document

Given a document, generates a URL for it

=cut

sub get_url_for_document :Private {
    # TODO: Get this to format the numbers correctly. 
    # TODO: Get entry() to run content through this to check if the URI is canonical or not
    my ($self, $c, $document) = @_;

    my $static = $document->permanent;
    if ($static) {
        $static = $static->url;
        $static =~ s!^/!!;
        return $c->uri_for(
                    $c->controller('Root')->action_for('default')
                ) . $static;
    }

    my $date = $document->first_published->edited;
    return $c->uri_for(
        $self->action_for('entry'), 
        [ (split '-', $date->strftime("%Y-%m-%d")), $document->slug ]
    );
}

=head2 template_ready_date

Given a datetime object, returns a hash containing a human readable date, and
iso date (for HTML 5's datetime attribute) and a URI to link to the page for
entries written on that date.

=cut

sub template_ready_date :Private {
    my ($self, $c, $datetime) = @_;    
    return {
        human => $datetime->strftime("%a. %d %B %Y"),
        iso => $datetime->strftime("%Y-%m-%d"),
        uri => $c->uri_for(
            $self->action_for('day'),
            [ (split '-', $datetime->strftime("%Y-%m-%d")) ]
        )
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
