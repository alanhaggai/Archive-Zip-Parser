#!/usr/bin/perl

use strict;
BEGIN { $^W = 1 }

use Test::More 'tests' => 1;
use_ok 'Archive::Zip::Parser';

my $parser = Archive::Zip::Parser->new;
