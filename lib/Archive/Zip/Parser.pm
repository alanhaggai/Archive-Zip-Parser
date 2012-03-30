package Archive::Zip::Parser;

use strict;
BEGIN { $^W = 1 }

sub new {
    my ( $self, $file ) = @_;

    if ( !defined $file ) {
        die "`new` requires a file name as its argument";
    }

    open my $fh, "<$file" or die "Error opening file[$file]: $!";

    return bless { 'fh' => $fh }, shift;
}

1;
