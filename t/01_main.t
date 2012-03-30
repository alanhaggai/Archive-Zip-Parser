#!/usr/bin/perl

use strict;
BEGIN { $^W = 1 }

use Test::More 'tests' => 5;
use_ok 'Archive::Zip::Parser';

my $parser;

# new method requires a mandatory parametre
eval {
    $parser = Archive::Zip::Parser->new;
};
like $@, qr/requires a file name/, 'new: requires a file name';

# new method requires valid file name
eval {
    $parser = Archive::Zip::Parser->new('test_files/foobar.zip');
};
like $@, qr/Error opening file/, 'new: error opening file';

eval {
    $parser = Archive::Zip::Parser->new('test_files/not_a_zip');
};
like $@, qr/not a zip file/, 'new: not a zip file';

# open existing file
eval {
    $parser = Archive::Zip::Parser->new('test_files/foo.zip');
};
is !$@, 1, 'new: opens existing file';

