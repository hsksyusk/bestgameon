package Bestgame::Schema::Result::User;

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

Bestgame::Schema::Result::User

=cut

__PACKAGE__->table("USER");

=head1 ACCESSORS

=head2 id_field

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 twitter_user_id

  data_type: 'integer'
  is_nullable: 0

=head2 twitter_user

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 twitter_access_token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 twitter_access_token_secret

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id_field",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "twitter_user_id",
  { data_type => "integer", is_nullable => 0 },
  "twitter_user",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "twitter_access_token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "twitter_access_token_secret",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id_field");
__PACKAGE__->add_unique_constraint("TWITTER_USER_ID", ["twitter_user_id"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-17 18:20:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DWOstLMNue8Dq7ZUJPV0Dg
__PACKAGE__->might_have(userid_ranking => 'Bestgame::Schema::Result::History', 'userid');
__PACKAGE__->might_have(userid_account=> 'Bestgame::Schema::Result::Account', 'userid');
__PACKAGE__->might_have(userid_profile=> 'Bestgame::Schema::Result::Profile', 'userid');
__PACKAGE__->has_many(from_userid_favorite=> 'Bestgame::Schema::Result::Favorite', 'from_userid');
__PACKAGE__->has_many(to_userid_favorite=> 'Bestgame::Schema::Result::Favorite', 'to_userid');
__PACKAGE__->has_many(from_userid_good=> 'Bestgame::Schema::Result::Good', 'from_userid');
__PACKAGE__->has_many(to_userid_good=> 'Bestgame::Schema::Result::Good', 'to_userid');
__PACKAGE__->has_many(from_userid_comment=> 'Bestgame::Schema::Result::Comment', 'from_userid');
__PACKAGE__->has_many(to_userid_comment=> 'Bestgame::Schema::Result::Comment', 'to_userid');
__PACKAGE__->resultset_class('Bestgame::Schema::ResultSet::User');



# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
