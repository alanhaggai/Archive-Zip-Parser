package Archive::Zip::Parser;

use strict;
BEGIN { $^W = 1 }

use constant CHUNK_SIZE => 10_240;
use Fcntl qw( SEEK_SET SEEK_END SEEK_CUR );

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
    my $signature = q{\x50\x4B\x03\x04};
    while (defined $fh
        && sysread( $fh, $chunk, CHUNK_SIZE )
        && $chunk !~ /$signature/g )
    {
        die "$file is not a zip file";
    }

    # now the file handle points just after the signature
    sysseek $fh, pos $chunk, SEEK_SET;

    $self = bless {
        'fh'   => $fh,
        'size' => -s $fh,
    }, $self;

    $self->_parse_end_of_central_directory_record;

    return $self;
}

sub _fh {
    my $self = shift;
    return $self->{'fh'};
}

sub _size {
    my $self = shift;
    return $self->{'size'};
}

sub _parse_end_of_central_directory_record {
    my $self             = shift;
    my $fh               = $self->_fh;
    my $size             = $self->_size;
    my $chunk_size       = CHUNK_SIZE;
    my $orig_fh_position = sysseek $fh, 0, SEEK_CUR;

    # search from the end of the file handle to check for the 0x504B0506
    # signature
    if ( $size < CHUNK_SIZE ) {

        # if the file size is lesser than the chunk size, set the chunk size to
        # the file size
        $chunk_size = $size;
    }

    sysseek $fh, -$chunk_size, SEEK_END;
    sysread $fh, my ($chunk), $chunk_size;

    my $signature = q{\x50\x4B\x05\x06};
    if ( $chunk !~ /$signature/g ) {
        die "End of central directory record is not found!\n";
    }

    my $position = $chunk_size - pos $chunk;
    sysseek $fh, -$position, SEEK_END;
    sysread $fh, $chunk, $position;

    my (
        $number_of_this_disk,
        $number_of_the_disk_with_the_start_of_the_central_directory,
        $total_number_of_entries_in_the_central_directory_on_this_disk,
        $total_number_of_entries_in_the_central_directory,
        $size_of_the_central_directory,
        $offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number,
        $zip_file_comment_length,
        $zip_file_comment,
    ) = unpack 'ssssllsa*', $chunk;

    # reset to original filehandle position
    sysseek $fh, $orig_fh_position, SEEK_SET;

    $self->{'end_of_central_directory_record'} = {
        'number_of_this_disk' => $number_of_this_disk,
        'number_of_the_disk_with_the_start_of_the_central_directory' =>
          $number_of_the_disk_with_the_start_of_the_central_directory,
        'total_number_of_entries_in_the_central_directory_on_this_disk' =>
          $total_number_of_entries_in_the_central_directory_on_this_disk,
        'total_number_of_entries_in_the_central_directory' =>
          $total_number_of_entries_in_the_central_directory,
        'size_of_the_central_directory' => $size_of_the_central_directory,
        'offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number'
          => $offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number,
        'zip_file_comment_length' => $zip_file_comment_length,
        'zip_file_comment'        => $zip_file_comment,
    };
}

1;
