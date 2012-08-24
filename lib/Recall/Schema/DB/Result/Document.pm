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

=head2 slug

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 published

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "slug",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "published",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("slug");

=head1 RELATIONS

=head2 versions

Type: has_many

Related object: L<Recall::Schema::DB::Result::Version>

=cut

__PACKAGE__->has_many(
  "versions",
  "Recall::Schema::DB::Result::Version",
  { "foreign.slug" => "self.slug" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-24 10:57:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1LiI1+1JE0ux9Ya7DQpaXQ

__PACKAGE__->belongs_to(
  "published_version",
  "Recall::Schema::DB::Result::Version",
  { 
      "foreign.slug" => "self.slug",
      "foreign.edited" => "self.published",
   },
  { cascade_copy => 0, cascade_delete => 0 }
  );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
