package Archive::Zip::Parser::CentralDirectoryRecord;

use strict;
BEGIN { $^W = 1 }

sub new {
    my ( $self, @structs ) = @_;
    return bless {
        'signature'                       => $structs[0],
        'version_made_by'                 => [ $structs[1], $structs[2] ],
        'version_needed_to_extract'       => [ $structs[3], $structs[4] ],
        'general_purpose_bit_flag'        => $structs[5],
        'compression_method'              => $structs[6],
        'last_mod_file_time'              => $structs[7],
        'last_mod_file_date'              => $structs[8],
        'crc_32'                          => $structs[9],
        'compressed_size'                 => $structs[10],
        'uncompressed_size'               => $structs[11],
        'file_name_length'                => $structs[12],
        'extra_field_length'              => $structs[13],
        'file_comment_length'             => $structs[14],
        'disk_number_start'               => $structs[15],
        'internal_file_attributes'        => $structs[16],
        'external_file_attributes'        => $structs[17],
        'relative_offset_of_local_header' => $structs[18],
    }, $self;
}

sub signature {
    my $self = shift;
    return uc $self->{'signature'};
}

sub version_made_by {
    my $self = shift;
    my ( $specification_version, $attribute_information ) =
      @{ $self->{'version_made_by'} };

    $specification_version = join '.', $specification_version / 10,
      $specification_version % 10;
    return {
        'specification_version' => $specification_version,
        'attribute_information' => $attribute_information,
    };
}

sub version_needed_to_extract {
    my $self = shift;
    my ( $minimum_feature_version, $attribute_information ) =
      @{ $self->{'version_needed_to_extract'} };

    $minimum_feature_version = join '.', $minimum_feature_version / 10, $minimum_feature_version % 10;
    return {
        'minimum_feature_version' => $minimum_feature_version,
        'attribute_information' => $attribute_information
    };
}

sub general_purpose_bit_flag {
    my $self = shift;
    my @bits = split //, $self->{'general_purpose_bit_flag'};
    return bless { 'bits' => \@bits },
      'Archive::Zip::Parser::CentralDirectoryRecord::GeneralPurposeBitFlag';
}

sub compression_method {
    my $self = shift;
    return $self->{'compression_method'};
}

sub last_mod_file_time {
    my $self               = shift;
    my $last_mod_file_time = $self->{'last_mod_file_time'};

    my $last_mod_file_time_bits = sprintf '%b', $last_mod_file_time;
    $last_mod_file_time_bits = substr '0' x 16 . $last_mod_file_time_bits, -16;

    my $hour   = substr $last_mod_file_time_bits, 0,  5;
    my $minute = substr $last_mod_file_time_bits, 5,  6;
    my $second = substr $last_mod_file_time_bits, 11, 5;

    $hour   = unpack 'N', pack 'B32', substr '0' x 32 . $hour,   -32;
    $minute = unpack 'N', pack 'B32', substr '0' x 32 . $minute, -32;
    $second = unpack 'N', pack 'B32', substr '0' x 32 . $second, -32;

    return {
        'hour'   => $hour,
        'minute' => $minute,
        'second' => $second,
    };
}

sub last_mod_file_date {
    my $self               = shift;
    my $last_mod_file_date = $self->{'last_mod_file_date'};

    my $last_mod_file_date_bits = sprintf '%b', $last_mod_file_date;
    $last_mod_file_date_bits = substr '0' x 16 . $last_mod_file_date_bits, -16;

    my $year  = substr $last_mod_file_date_bits, 0,  7;
    my $month = substr $last_mod_file_date_bits, 7,  4;
    my $day   = substr $last_mod_file_date_bits, 11, 5;

    $year  = unpack 'N', pack 'B32', substr '0' x 32 . $year,  -32;
    $month = unpack 'N', pack 'B32', substr '0' x 32 . $month, -32;
    $day   = unpack 'N', pack 'B32', substr '0' x 32 . $day,   -32;

    return {
        'year'  => $year + 1980,
        'month' => $month,
        'day'   => $day,
    };
}

sub crc_32 {
    my $self = shift;
    return uc $self->{'crc_32'};
}

sub compressed_size {
    my $self = shift;
    return $self->{'compressed_size'};
}

sub uncompressed_size {
    my $self = shift;
    return $self->{'uncompressed_size'};
}

sub file_name_length {
    my $self = shift;
    return $self->{'file_name_length'};
}

sub extra_field_length {
    my $self = shift;
    return $self->{'extra_field_length'};
}

sub file_comment_length {
    my $self = shift;
    return $self->{'file_comment_length'};
}

sub disk_number_start {
    my $self = shift;
    return $self->{'disk_number_start'};
}

sub internal_file_attributes {
    my $self = shift;
    return $self->{'internal_file_attributes'};
}

sub external_file_attributes {
    my $self = shift;
    return $self->{'external_file_attributes'};
}

sub relative_offset_of_local_header {
    my $self = shift;
    return $self->{'relative_offset_of_local_header'};
}

sub attribute_information {
    my $self = shift;
    return $self->{'attribute_information'};
}

sub _length {
    my $self = shift;
    return $self->file_name_length + $self->extra_field_length +
      $self->file_comment_length;
}

package Archive::Zip::Parser::CentralDirectoryRecord::GeneralPurposeBitFlag;

use strict;
use warnings;

sub encrypted {
    my $self = shift;
    if ( $self->{'bits'}->[0] ) {
        return 1;
    }
    return;
}

sub dictionary {
    my $self = shift;
    if ( $self->{'bits'}->[1] ) {
        return '8k sliding dictionary';
    }
    else {
        return '4k sliding dictionary';
    }
}

sub method_to_encode_sliding_dictionary_output {
    my $self = shift;
    if ( $self->{'bits'}->[2] ) {
        return '3 Shannon-Fano trees';
    }
    else {
        return '2 Shannon-Fano trees';
    }
}

sub compression {
    my $self = shift;
    my @bits = @{ $self->{'bits'} };

    if ( $bits[2] == 0 ) {
        if ( $bits[1] == 0 ) {
            return 'Normal (-en) compression option was used';
        }
        return 'Maximum (-exx/-ex) compression option was used';
    }
    else {
        if ( $bits[1] == 0 ) {
            return 'Fast (-ef) compression option was used';
        }
        return 'Super fast (-es) compression option was used';
    }
}

sub eos_marker {
    my $self = shift;
    if ( $self->{'bits'}->[1] ) {
        return 1;
    }
    return;
}

sub crc32_compressed_size_uncompressed_size_set_to_zero {
    my $self = shift;
    if ( $self->{'bits'}->[3] ) {
        return 1;
    }
    return;
}

sub enhanced_deflating {
    my $self = shift;
    if ( $self->{'bits'}->[4] ) {
        return 1;
    }
    return;
}

sub compressed_patched_data {
    my $self = shift;
    if ( $self->{'bits'}->[5] ) {
        return 1;
    }
    return;
}

sub strong_encryption {
    my $self = shift;
    if ( $self->{'bits'}->[6] ) {
        return 1;
    }
    return;
}

sub language_encoding_flag {
    my $self = shift;
    if ( $self->{'bits'}->[11] ) {
        return 1;
    }
    return;
}

sub enhanced_compression {
    my $self = shift;
    if ( $self->{'bits'}->[12] ) {
        return 1;
    }
    return;
}

# TODO: Bit 13

1;
