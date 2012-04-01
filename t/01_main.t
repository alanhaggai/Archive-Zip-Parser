#!/usr/bin/perl

use strict;
BEGIN { $^W = 1 }

use Test::More 'tests' => 31;
use Archive::Zip::Parser;

my $parser;

# new method requires a mandatory parametre
eval { $parser = Archive::Zip::Parser->new; };
like $@, qr/requires a file name/, 'new: requires a file name';

# new method requires valid file name
eval { $parser = Archive::Zip::Parser->new('test_files/foobar.zip'); };
like $@, qr/Error opening file/, 'new: error opening file';

eval { $parser = Archive::Zip::Parser->new('test_files/not_a_zip'); };
like $@, qr/not a zip file/, 'new: not a zip file';

$parser = Archive::Zip::Parser->new('test_files/foo.zip');

my $end_of_central_directory_record = $parser->end_of_central_directory_record;
is $end_of_central_directory_record->number_of_this_disk, 0,
  'size of this disk';
is $end_of_central_directory_record
  ->number_of_the_disk_with_the_start_of_the_central_directory, 0,
  'number_of_the_disk_with_the_start_of_the_central_directory';
is $end_of_central_directory_record
  ->total_number_of_entries_in_the_central_directory_on_this_disk, 1,
  'total number of entries in the central directory on this disk';
is $end_of_central_directory_record
  ->total_number_of_entries_in_the_central_directory, 1,
  'total number of entries in the central directory';
is $end_of_central_directory_record->size_of_the_central_directory, 93,
  'size of the central directory';
is $end_of_central_directory_record
  ->offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number,
  79,
'offset of start of central directory with respect to the starting disk number';
is $end_of_central_directory_record->zip_file_comment_length, 14,
  'zip file comment length';
is $end_of_central_directory_record->zip_file_comment, 'Just a comment',
  'zip file comment';

my @central_directory_records = $parser->central_directory_records;
is $central_directory_records[0]->signature, CENTRAL_DIRECTORY_RECORD_SIGNATURE,
  'signature';

my $version_made_by = $central_directory_records[0]->version_made_by;
is $version_made_by->{'specification_version'}, '3.0', 'specification version';
is $version_made_by->{'attribute_information'}, CENTRAL_DIRECTORY_RECORD_UNIX,
  'attribute information';

my $version_needed_to_extract =
  $central_directory_records[0]->version_needed_to_extract;
is $version_needed_to_extract->{'minimum_feature_version'}, '1.0',
  'minimum feature version value';
is $version_needed_to_extract->{'attribute_information'},
  CENTRAL_DIRECTORY_RECORD_MS_DOS_OS2,
  'attribute information description';

my $general_purpose_bit_flag =
  $central_directory_records[0]->general_purpose_bit_flag;
is $central_directory_records[0]->compression_method,
  CENTRAL_DIRECTORY_RECORD_FILE_IS_STORED, 'compression method';
my $last_mod_file_date = $central_directory_records[0]->last_mod_file_date;
is $last_mod_file_date->{'year'},  2012, 'year';
is $last_mod_file_date->{'month'}, 3,    'month';
is $last_mod_file_date->{'day'},   31,   'day';

my $last_mod_file_time = $central_directory_records[0]->last_mod_file_time;
is $last_mod_file_time->{'hour'},   16, 'hour';
is $last_mod_file_time->{'minute'}, 27, 'minute';
is $last_mod_file_time->{'second'}, 5,  'second';

is $central_directory_records[0]->crc_32, '4DF208A7', 'CRC-32';
is $central_directory_records[0]->compressed_size,    18, 'uncompressed size';
is $central_directory_records[0]->uncompressed_size,  18, 'uncompressed size';
is $central_directory_records[0]->file_name_length,   3,  'file name length';
is $central_directory_records[0]->extra_field_length, 24, 'extra field length';
is $central_directory_records[0]->file_comment_length, 20,
  'file comment length';

is $central_directory_records[0]->file_name, 'foo', 'file name';
is $central_directory_records[0]->file_comment, 'Comment for file foo',
  'file comment';
