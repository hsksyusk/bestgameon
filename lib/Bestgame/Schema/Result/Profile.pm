package Bestgame::Schema::Result::Profile;

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

Bestgame::Schema::Result::Profile

=cut

__PACKAGE__->table("PROFILE");

=head1 ACCESSORS

=head2 userid

  data_type: 'integer'
  is_nullable: 0

=head2 address

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 address_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 sex

  data_type: 'integer'
  is_nullable: 1

=head2 sex_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 bloodtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 bloodtype_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 birthyear

  data_type: 'integer'
  is_nullable: 1

=head2 birthyear_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 birthday_month

  data_type: 'integer'
  is_nullable: 1

=head2 birthday_day

  data_type: 'integer'
  is_nullable: 1

=head2 birthday_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 url_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 favorite_genre

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 favorite_genre_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 favorite_hard

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 favorite_hard_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 favorite_maker

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 favorite_maker_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 introduction

  data_type: 'text'
  is_nullable: 1

=head2 introduction_flag

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "userid",
  { data_type => "integer", is_nullable => 0 },
  "address",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "address_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "sex",
  { data_type => "integer", is_nullable => 1 },
  "sex_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "bloodtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "bloodtype_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "birthyear",
  { data_type => "integer", is_nullable => 1 },
  "birthyear_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "birthday_month",
  { data_type => "integer", is_nullable => 1 },
  "birthday_day",
  { data_type => "integer", is_nullable => 1 },
  "birthday_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "url_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "favorite_genre",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "favorite_genre_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "favorite_hard",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "favorite_hard_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "favorite_maker",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "favorite_maker_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "introduction",
  { data_type => "text", is_nullable => 1 },
  "introduction_flag",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("userid");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-21 17:07:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PCi+lL+M8phheVP9Ia4goA
__PACKAGE__->belongs_to(twitter_user => 'Bestgame::Schema::Result::User', 'userid');


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
