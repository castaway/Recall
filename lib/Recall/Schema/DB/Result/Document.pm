package Recall::Schema::DB::Result::Document;

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

Recall::Schema::DB::Result::Document

=cut

__PACKAGE__->table("Documents");

=head1 ACCESSORS

=head2 document_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 first_published_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 live_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 slug

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "document_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "first_published_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "live_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("document_id");

=head1 RELATIONS

=head2 live

Type: belongs_to

Related object: L<Recall::Schema::DB::Result::Version>

=cut

__PACKAGE__->belongs_to(
  "live",
  "Recall::Schema::DB::Result::Version",
  { version_id => "live_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 first_published

Type: belongs_to

Related object: L<Recall::Schema::DB::Result::Version>

=cut

__PACKAGE__->belongs_to(
  "first_published",
  "Recall::Schema::DB::Result::Version",
  { version_id => "first_published_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 permanent

Type: might_have

Related object: L<Recall::Schema::DB::Result::Permanent>

=cut

__PACKAGE__->might_have(
  "permanent",
  "Recall::Schema::DB::Result::Permanent",
  { "foreign.document_id" => "self.document_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 versions

Type: has_many

Related object: L<Recall::Schema::DB::Result::Version>

=cut

__PACKAGE__->has_many(
  "versions",
  "Recall::Schema::DB::Result::Version",
  { "foreign.document_id" => "self.document_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-25 09:22:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HUMrjJEWFvW3xa0CqJ7E4A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
