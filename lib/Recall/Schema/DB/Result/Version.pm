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

=head2 slug

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

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
  "slug",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
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
__PACKAGE__->set_primary_key("slug", "edited");

=head1 RELATIONS

=head2 slug

Type: belongs_to

Related object: L<Recall::Schema::DB::Result::Document>

=cut

__PACKAGE__->belongs_to(
  "slug",
  "Recall::Schema::DB::Result::Document",
  { slug => "slug" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-24 10:55:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:knoY17YGWHDKzE41pEfTqw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
