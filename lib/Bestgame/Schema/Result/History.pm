package Bestgame::Schema::Result::History;

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

Bestgame::Schema::Result::History

=cut

__PACKAGE__->table("HISTORY");

=head1 ACCESSORS

=head2 userid

  data_type: 'integer'
  is_nullable: 0

=head2 ranking_update

  data_type: 'datetime'
  is_nullable: 0

=head2 ranking_create

  data_type: 'datetime'
  is_nullable: 1

=head2 draft_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "userid",
  { data_type => "integer", is_nullable => 0 },
  "ranking_update",
  { data_type => "datetime", is_nullable => 0 },
  "ranking_create",
  { data_type => "datetime", is_nullable => 1 },
  "draft_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("userid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-17 18:20:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+i6l2nv8R8Cwwq1i85Tqxg
__PACKAGE__->belongs_to(twitter_user => 'Bestgame::Schema::Result::User', 'userid');
__PACKAGE__->has_many(to_userid_good=> 'Bestgame::Schema::Result::Good', 'to_userid');
__PACKAGE__->has_many(to_userid_comment=> 'Bestgame::Schema::Result::Comment', 'to_userid');
__PACKAGE__->has_many(userid_ranking=> 'Bestgame::Schema::Result::Ranking', 'userid');


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
