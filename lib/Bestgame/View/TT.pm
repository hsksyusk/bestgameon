package Bestgame::View::TT;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    ENCODING => 'utf-8',
    render_die => 1,
);

=head1 NAME

Bestgame::View::TT - TT View for Bestgame

=head1 DESCRIPTION

TT View for Bestgame.

=head1 SEE ALSO

L<Bestgame>

=head1 AUTHOR

User &

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
