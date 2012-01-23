package Bestgame::Model::Net::Amazon;

use strict;
use warnings;

use Cache::File;
use base qw/ Catalyst::Model::Net::Amazon /;

my $cache = Cache::File->new( 
	cache_root        => '/home/hsksyusk/tmp/amazon_cache',
	default_expires   => '1 weeks',
);

__PACKAGE__->config(
    token => 'AKIAIAEUY32DWAJC3MPA',
    secret_key   => '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',
    locale       => 'jp',
    affiliate_id => 'bsrnvebm-22',
    max_pages       => 2,
    cache => $cache,
);

=head1 NAME

Bestgame::Model::Net::Amazon - S3 Model Class


=head1 SYNOPSIS

See L<Bestgame>.

=head1 DESCRIPTION

Net::Amazon Model Class.

=head1 AUTHOR

User &

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.

=cut

1;
