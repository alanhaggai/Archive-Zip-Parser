package Archive::Zip::Parser;

use strict;
BEGIN { $^W = 1 }

use base 'Exporter';

use constant {
    CHUNK_SIZE                    => 10_240,
    CENTRAL_DIRECTORY_RECORD_SIZE => 46,
};

use constant {
    CENTRAL_DIRECTORY_RECORD_SIGNATURE => '504B0102',

    CENTRAL_DIRECTORY_RECORD_MS_DOS_OS2    => 0,
    CENTRAL_DIRECTORY_RECORD_AMIGA         => 1,
    CENTRAL_DIRECTORY_RECORD_OPENVMS       => 2,
    CENTRAL_DIRECTORY_RECORD_UNIX          => 3,
    CENTRAL_DIRECTORY_RECORD_VM_CMS        => 4,
    CENTRAL_DIRECTORY_RECORD_ATARI_ST      => 5,
    CENTRAL_DIRECTORY_RECORD_OS2_HPFS      => 6,
    CENTRAL_DIRECTORY_RECORD_MACINTOSH     => 7,
    CENTRAL_DIRECTORY_RECORD_Z_SYSTEM      => 8,
    CENTRAL_DIRECTORY_RECORD_CPM           => 9,
    CENTRAL_DIRECTORY_RECORD_WINDOWS_NTFS  => 10,
    CENTRAL_DIRECTORY_RECORD_MVS           => 11,
    CENTRAL_DIRECTORY_RECORD_VSE           => 12,
    CENTRAL_DIRECTORY_RECORD_ACORN_RISC    => 13,
    CENTRAL_DIRECTORY_RECORD_VFAT          => 14,
    CENTRAL_DIRECTORY_RECORD_ALTERNATE_MVS => 15,
    CENTRAL_DIRECTORY_RECORD_BEOS          => 16,
    CENTRAL_DIRECTORY_RECORD_TANDEM        => 17,
    CENTRAL_DIRECTORY_RECORD_OS400         => 18,
    CENTRAL_DIRECTORY_RECORD_OSX           => 19,

    CENTRAL_DIRECTORY_RECORD_DEFAULT_VALUE          => '1.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_A_VOLUME_LABEL => '1.1',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_A_DIRECTORY    => '2.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_DEFLATE_COMPRESSION =>
      '2.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_TRADITIONAL_PKWARE_ENCRYPTION =>
      '2.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_DEFLATE64 => '2.1',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_PKWARE_DCL_IMPLODE =>
      '2.5',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_A_PATCH_DATA_SET          => '2.7',
    CENTRAL_DIRECTORY_RECORD_FILE_USES_ZIP64_FORMAT_EXTENSIONS => '4.5',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_BZIP2_COMPRESSION =>
      '4.6',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_DES  => '5.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_3DES => '5.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_ORIGINAL_RC2_ENCRYPTION =>
      '5.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_RC4_ENCRYPTION => '5.0',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_AES_ENCRYPTION => '5.1',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_CORRECTED_RC2_ENCRYPTION =>
      '5.1',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_CORRECTED_RC2_64_ENCRYPTION =>
      '5.2',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_NON_OAEP_KEY_WRAPPING =>
      '6.1',
    CENTRAL_DIRECTORY_RECORD_CENTRAL_DIRECTORY_ENCRYPTION     => '6.2',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_LZMA    => '6.3',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_PPMD    => '6.3',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_BLOWFISH => '6.3',
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_TWOFISH  => '6.3',

    CENTRAL_DIRECTORY_RECORD_FILE_IS_STORED                                => 0,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_SHRUNK                                => 1,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_1     => 2,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_2     => 3,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_3     => 4,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_4     => 5,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_IMPLODED                              => 6,
    CENTRAL_DIRECTORY_RECORD_RESERVED_FOR_TOKENISING_COMPRESSION_ALGORITHM => 7,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_DEFLATED                              => 8,
    CENTRAL_DIRECTORY_RECORD_ENHANCED_DEFLATING_USING_DEFLATE64            => 9,
    CENTRAL_DIRECTORY_RECORD_PKWARE_DATA_COMPRESSION_LIBRARY_IMPLODING     => 10,
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE                            => 11,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_BZIP2_ALGORITHM      => 12,
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE                            => 13,
    CENTRAL_DIRECTORY_RECORD_LZMA                                          => 14,
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE                            => 15,
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE                            => 16,
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE                            => 17,
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_IBM_TERSE            => 18,
    CENTRAL_DIRECTORY_RECORD_IBM_LZ77_Z_ARCHITECTURE                       => 19,
    CENTRAL_DIRECTORY_RECORD_WAVPACK_COMPRESSED_DATA                       => 97,
    CENTRAL_DIRECTORY_RECORD_PPMD_VERSION_I_REV_1                          => 98,
};

use Fcntl qw( SEEK_SET SEEK_END SEEK_CUR );

use Archive::Zip::Parser::EndOfCentralDirectoryRecord;
use Archive::Zip::Parser::CentralDirectoryRecord;

our @EXPORT = qw(
    CENTRAL_DIRECTORY_RECORD_SIGNATURE

    CENTRAL_DIRECTORY_RECORD_MS_DOS_OS2
    CENTRAL_DIRECTORY_RECORD_AMIGA
    CENTRAL_DIRECTORY_RECORD_OPENVMS
    CENTRAL_DIRECTORY_RECORD_UNIX
    CENTRAL_DIRECTORY_RECORD_VM_CMS
    CENTRAL_DIRECTORY_RECORD_ATARI_ST
    CENTRAL_DIRECTORY_RECORD_OS2_HPFS
    CENTRAL_DIRECTORY_RECORD_MACINTOSH
    CENTRAL_DIRECTORY_RECORD_Z_SYSTEM
    CENTRAL_DIRECTORY_RECORD_CPM
    CENTRAL_DIRECTORY_RECORD_WINDOWS_NTFS
    CENTRAL_DIRECTORY_RECORD_MVS
    CENTRAL_DIRECTORY_RECORD_VSE
    CENTRAL_DIRECTORY_RECORD_ACORN_RISC
    CENTRAL_DIRECTORY_RECORD_VFAT
    CENTRAL_DIRECTORY_RECORD_ALTERNATE_MVS
    CENTRAL_DIRECTORY_RECORD_BEOS
    CENTRAL_DIRECTORY_RECORD_TANDEM
    CENTRAL_DIRECTORY_RECORD_OS400
    CENTRAL_DIRECTORY_RECORD_OSX

    CENTRAL_DIRECTORY_RECORD_DEFAULT_VALUE
    CENTRAL_DIRECTORY_RECORD_FILE_IS_A_VOLUME_LABEL
    CENTRAL_DIRECTORY_RECORD_FILE_IS_A_DIRECTORY
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_DEFLATE_COMPRESSION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_TRADITIONAL_PKWARE_ENCRYPTION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_DEFLATE64
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_PKWARE_DCL_IMPLODE
    CENTRAL_DIRECTORY_RECORD_FILE_IS_A_PATCH_DATA_SET
    CENTRAL_DIRECTORY_RECORD_FILE_USES_ZIP64_FORMAT_EXTENSIONS
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_BZIP2_COMPRESSION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_DES
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_3DES
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_ORIGINAL_RC2_ENCRYPTION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_RC4_ENCRYPTION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_AES_ENCRYPTION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_CORRECTED_RC2_ENCRYPTION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_CORRECTED_RC2_64_ENCRYPTION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_NON_OAEP_KEY_WRAPPING
    CENTRAL_DIRECTORY_RECORD_CENTRAL_DIRECTORY_ENCRYPTION
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_LZMA
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_PPMD
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_BLOWFISH
    CENTRAL_DIRECTORY_RECORD_FILE_IS_ENCRYPTED_USING_TWOFISH

    CENTRAL_DIRECTORY_RECORD_FILE_IS_STORED
    CENTRAL_DIRECTORY_RECORD_FILE_IS_SHRUNK
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_1
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_2
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_3
    CENTRAL_DIRECTORY_RECORD_FILE_IS_REDUCED_WITH_COMPRESSION_FACTOR_4
    CENTRAL_DIRECTORY_RECORD_FILE_IS_IMPLODED
    CENTRAL_DIRECTORY_RECORD_RESERVED_FOR_TOKENISING_COMPRESSION_ALGORITHM
    CENTRAL_DIRECTORY_RECORD_FILE_IS_DEFLATED
    CENTRAL_DIRECTORY_RECORD_ENHANCED_DEFLATING_USING_DEFLATE64
    CENTRAL_DIRECTORY_RECORD_PKWARE_DATA_COMPRESSION_LIBRARY_IMPLODING
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_BZIP2_ALGORITHM
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE
    CENTRAL_DIRECTORY_RECORD_LZMA
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE
    CENTRAL_DIRECTORY_RECORD_RESERVED_BY_PKWARE
    CENTRAL_DIRECTORY_RECORD_FILE_IS_COMPRESSED_USING_IBM_TERSE
    CENTRAL_DIRECTORY_RECORD_IBM_LZ77_Z_ARCHITECTURE
    CENTRAL_DIRECTORY_RECORD_WAVPACK_COMPRESSED_DATA
    CENTRAL_DIRECTORY_RECORD_PPMD_VERSION_I_REV_1
);

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
    $self->_parse_central_directory_records;

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

sub _tell {
    my $self = shift;
    return sysseek $self->_fh, 0, SEEK_CUR;
}

sub _parse_end_of_central_directory_record {
    my $self             = shift;
    my $fh               = $self->_fh;
    my $size             = $self->_size;
    my $chunk_size       = CHUNK_SIZE;
    my $orig_fh_position = $self->_tell;

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

    # reset to original filehandle position
    sysseek $fh, $orig_fh_position, SEEK_SET;

    my $end_of_central_directory_record =
      Archive::Zip::Parser::EndOfCentralDirectoryRecord->new(
        unpack 'SSSSLLSa*', $chunk );

    $self->{'end_of_central_directory_record'} = $end_of_central_directory_record;

    return;
}

sub end_of_central_directory_record {
    my $self = shift;
    return $self->{'end_of_central_directory_record'};
}

sub _parse_central_directory_records {
    my $self = shift;
    my $fh   = $self->_fh;
    my $end_of_central_directory_record =
      $self->end_of_central_directory_record;
    my $size = $end_of_central_directory_record->size_of_the_central_directory;

    for ( 1 .. $end_of_central_directory_record
        ->total_number_of_entries_in_the_central_directory_on_this_disk )
    {
        my $central_directory_record = $self->_next_central_directory_record;
        push @{ $self->{'central_directory_records'} },
          $central_directory_record;
    }

    return;
}

sub _next_central_directory_record {
    my $self = shift;
    my $fh = $self->_fh;

    my $offset;
    if ( !$self->{'central_directory_records'} ) {
        $offset =
          $self->end_of_central_directory_record
          ->offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number;
    }
    else {
        $offset = $self->_tell;
    }

    sysseek $fh, $offset, SEEK_SET;
    sysread $fh, my ($chunk), CENTRAL_DIRECTORY_RECORD_SIZE;

    my $central_directory_record =
      Archive::Zip::Parser::CentralDirectoryRecord->new(
        unpack 'H8C2C2B16SSSH8LLSSSSSLL', $chunk );

    # Place the filehandle pointer at first of the next Central Directory Record
    sysseek $fh,
      $central_directory_record->file_name_length +
      $central_directory_record->extra_field_length +
      $central_directory_record->file_comment_length, SEEK_CUR;

    return $central_directory_record;
}

sub central_directory_records {
    my $self = shift;
    return @{ $self->{'central_directory_records'} };
}

1;
