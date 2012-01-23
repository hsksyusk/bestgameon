package Bestgame::Schema::Result::WpCommentmeta;

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

Bestgame::Schema::Result::WpCommentmeta

=cut

__PACKAGE__->table("wp_commentmeta");

=head1 ACCESSORS

=head2 meta_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 comment_id

  data_type: 'bigint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meta_key

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 meta_value

  data_type: 'longtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "meta_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "comment_id",
  {
    data_type => "bigint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meta_key",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "meta_value",
  { data_type => "longtext", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("meta_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-20 20:14:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AqMG6c47jGsOBamuTAKmEg


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;