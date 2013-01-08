#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

# All pages are going to get new URLs
# Everything is going to move off blog.foo and onto foo/blog
# Somethings are going to get the dates in their URIs fixed up (e.g. some are missing days)
# This works out the difference between the old and the new


# Pondering: Have the two import scripts write to a database and then use that to generate Apache redirect directives?
