package Archive::Zip::Parser;

use strict;
BEGIN { $^W = 1 }

use constant CHUNK_SIZE => 10_240;

sub new {
    my ( $self, $file ) = @_;

    if ( !defined $file ) {
        die "`new` requires a file name as its argument";
    }

    open my $fh, "<$file" or die "Error opening file[$file]: $!";

    # Check if the file is a zip file or not. All zip files begin with the
    # 0x504B0304 signature. However, the signature can be anywhere in the file.
    # Skip until it is found.

    my $chunk;
    read $fh, $chunk, CHUNK_SIZE;

    my $signature = q{\x50\x4B\x03\x04};
    while ( defined $fh && $chunk !~ /$signature/ ) {
        die "$file is not a zip file";
    }

    # now the file handle points just after the signature

    return bless { 'fh' => $fh }, shift;
}

1;
