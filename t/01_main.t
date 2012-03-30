#!/usr/bin/perl

use strict;
BEGIN { $^W = 1 }

use Test::More 'tests' => 13;
use_ok 'Archive::Zip::Parser';

my $parser;

# new method requires a mandatory parametre
eval { $parser = Archive::Zip::Parser->new; };
like $@, qr/requires a file name/, 'new: requires a file name';

# new method requires valid file name
eval { $parser = Archive::Zip::Parser->new('test_files/foobar.zip'); };
like $@, qr/Error opening file/, 'new: error opening file';

eval { $parser = Archive::Zip::Parser->new('test_files/not_a_zip'); };
like $@, qr/not a zip file/, 'new: not a zip file';

# open existing file
eval { $parser = Archive::Zip::Parser->new('test_files/foo.zip'); };
is !$@, 1, 'new: opens existing file';

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
is $end_of_central_directory_record->size_of_the_central_directory, 73,
  'size of the central directory';
is $end_of_central_directory_record
  ->offset_of_start_of_central_directory_with_respect_to_the_starting_disk_number,
  79,
'offset of start of central directory with respect to the starting disk number';
is $end_of_central_directory_record->zip_file_comment_length, 14,
  'zip file comment length';
is $end_of_central_directory_record->zip_file_comment, 'Just a comment',
  'zip file comment';
