package Bestgame::Schema::ResultSet::User;
use strict;
use warnings;
use base qw/DBIx::Class::ResultSet/;
 
sub auto_create {
    my ( $class, $hashref, $c ) = @_;
    my $member = $class->create({
        twitter_user_id    => $hashref->{twitter_user_id},
    });
    return $member;
}

1;