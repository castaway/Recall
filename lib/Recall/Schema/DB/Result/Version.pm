package Recall::Schema::DB::Result::Version;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Recall::Schema::DB::Result::Version

=cut

__PACKAGE__->table("Versions");

=head1 ACCESSORS

=head2 version_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 document_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 edited

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 source

  data_type: 'text'
  is_nullable: 1

=head2 html

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "version_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "document_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "edited",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "source",
  { data_type => "text", is_nullable => 1 },
  "html",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("version_id");

=head1 RELATIONS

=head2 documents_live

Type: has_many

Related object: L<Recall::Schema::DB::Result::Document>

=cut

__PACKAGE__->has_many(
  "documents_live",
  "Recall::Schema::DB::Result::Document",
  { "foreign.live_id" => "self.version_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 documents_first_publisheds

Type: has_many

Related object: L<Recall::Schema::DB::Result::Document>

=cut

__PACKAGE__->has_many(
  "documents_first_publisheds",
  "Recall::Schema::DB::Result::Document",
  { "foreign.first_published_id" => "self.version_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 document

Type: belongs_to

Related object: L<Recall::Schema::DB::Result::Document>

=cut

__PACKAGE__->belongs_to(
  "document",
  "Recall::Schema::DB::Result::Document",
  { document_id => "document_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2013-01-06 18:30:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9K8Pj9Tl8Z01JkukOPl89A

use Text::Markdown 'markdown';

=head2 HTML caching

Update the HTML column when the source column is updated

=cut

# Update the cache of HTML if the source on the version changes
# (This won't usually happen as the source is usually only set
#  at creation time).
around source => sub {
    my ($orig, $self) = (shift, shift);

    if (@_) {
      my $markdown = $_[0];
      $self->html(markdown($markdown));
    }
    $self->$orig(@_);
};

# Cache the HTML if we haven't generated any before
around html => sub {
    my ($orig, $self) = (shift, shift);
    if (@_) {
        return $self->$orig(@_);
    } else {
        my $html = $self->$orig(@_);
        unless ($html) {
            $html = markdown($self->source);
            $self->$orig($html);
            $self->update;
        }
        return $html;
    }
    
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
