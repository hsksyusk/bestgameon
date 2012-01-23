package Bestgame::Schema::Result::Weight;

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

Bestgame::Schema::Result::Weight

=cut

__PACKAGE__->table("WEIGHT");

=head1 ACCESSORS

=head2 rank

  data_type: 'integer'
  is_nullable: 0

=head2 weight

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rank",
  { data_type => "integer", is_nullable => 0 },
  "weight",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("rank");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-17 18:20:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SAhzMrBa9SdY3eECK6pisg
__PACKAGE__->has_many(weight_ranking => 'Bestgame::Schema::Result::Ranking', 'rank');


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
