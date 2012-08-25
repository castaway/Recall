package Recall::Schema::DB::Result::Permanent;

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

Recall::Schema::DB::Result::Permanent

=cut

__PACKAGE__->table("Permanent");

=head1 ACCESSORS

=head2 document_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "document_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("document_id");

=head1 RELATIONS

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i12D8bwGOKwXgjAFLhFJCQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
