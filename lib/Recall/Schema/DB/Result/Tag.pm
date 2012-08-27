package Recall::Schema::DB::Result::Tag;

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

Recall::Schema::DB::Result::Tag

=cut

__PACKAGE__->table("Tags");

=head1 ACCESSORS

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 about_document_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "about_document_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("name");
__PACKAGE__->add_unique_constraint("about_document_id", ["about_document_id"]);

=head1 RELATIONS

=head2 documents_to_tags

Type: has_many

Related object: L<Recall::Schema::DB::Result::DocumentsToTag>

=cut

__PACKAGE__->has_many(
  "documents_to_tags",
  "Recall::Schema::DB::Result::DocumentsToTag",
  { "foreign.tag_id" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 about_document

Type: belongs_to

Related object: L<Recall::Schema::DB::Result::Document>

=cut

__PACKAGE__->belongs_to(
  "about_document",
  "Recall::Schema::DB::Result::Document",
  { document_id => "about_document_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-27 12:44:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lSB0Kpy3OKjrHWXYzexLNg

__PACKAGE__->many_to_many( documents => 'documents_to_tags', 'document' );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
