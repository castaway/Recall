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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-25 09:17:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:faudqZy9Yl0kc0xr6re+Ag

use Text::Markdown 'markdown';

=head2 html

Gets an HTML version of the source of the version

=cut

sub html {
  my $self = shift;
  return markdown($self->source);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
