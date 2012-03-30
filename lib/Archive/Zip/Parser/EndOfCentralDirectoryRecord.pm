package Archive::Zip::Parser::EndOfCentralDirectoryRecord;

use strict;
BEGIN { $^W = 1 }

sub new {
    my ( $self, @structs ) = @_;
    return bless {
        'number_of_this_disk' => $structs[0],
        'number_of_the_disk_with_the_start_of_the_central_directory' =>
          $structs[1],
        'total_number_of_entries_in_the_central_directory_on_this_disk' =>
          $structs[2],
        'total_number_of_entries_in_the_central_directory' => $structs[3],
        'size_of_the_central_directory'                    => $structs[4],
        'offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number'
          => $structs[5],
        'zip_file_comment_length' => $structs[6],
        'zip_file_comment'        => $structs[7],
    }, $self;
}

sub number_of_this_disk {
    my $self = shift;
    return $self->{'number_of_this_disk'};
}

sub number_of_the_disk_with_the_start_of_the_central_directory {
    my $self = shift;
    return
    $self->{'number_of_the_disk_with_the_start_of_the_central_directory'};
}

sub total_number_of_entries_in_the_central_directory_on_this_disk {
    my $self = shift;
    return
    $self->{'total_number_of_entries_in_the_central_directory_on_this_disk'};
}

sub total_number_of_entries_in_the_central_directory {
    my $self = shift;
    return $self->{'total_number_of_entries_in_the_central_directory'};
}

sub size_of_the_central_directory {
    my $self = shift;
    return $self->{'size_of_the_central_directory'};
}

sub
offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number {
    my $self = shift;
    return
    $self->{'offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number'};
}

sub zip_file_comment_length {
    my $self = shift;
    return $self->{'zip_file_comment_length'};
}

sub zip_file_comment {
    my $self = shift;
    return $self->{'zip_file_comment'};
}

1;
