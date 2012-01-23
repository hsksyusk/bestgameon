package Bestgame::Schema::Result::Ranking;

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

Bestgame::Schema::Result::Ranking

=cut

__PACKAGE__->table("RANKING");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 userid

  data_type: 'integer'
  is_nullable: 0

=head2 rank

  data_type: 'integer'
  is_nullable: 0

=head2 asin

  data_type: 'char'
  is_nullable: 0
  size: 10

=head2 comment

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "userid",
  { data_type => "integer", is_nullable => 0 },
  "rank",
  { data_type => "integer", is_nullable => 0 },
  "asin",
  { data_type => "char", is_nullable => 0, size => 10 },
  "comment",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("USERID", ["userid", "rank"]);
__PACKAGE__->add_unique_constraint("USERID_ASIN", ["userid", "asin"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-17 18:20:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+FeFWJJX7jxBIaKQ+bnB4g
__PACKAGE__->belongs_to(weight => 'Bestgame::Schema::Result::Weight', 'rank');
__PACKAGE__->belongs_to(twitter_user => 'Bestgame::Schema::Result::User', 'userid');
__PACKAGE__->has_many(to_userid_asin_good=> 'Bestgame::Schema::Result::Good', 
	{	'foreign.to_userid'=>'self.userid',
		'foreign.asin'=>'self.asin',},
	{	 order_by => { -asc => 'timestamp' } },
);
__PACKAGE__->has_many(to_userid_asin_comment=> 'Bestgame::Schema::Result::Comment',
	{	'foreign.to_userid'=>'self.userid',
		'foreign.asin'=>'self.asin', },
	{	 order_by => { -asc => 'timestamp' } },

);
__PACKAGE__->belongs_to(draft_flag_userid => 'Bestgame::Schema::Result::History', 'userid');


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
