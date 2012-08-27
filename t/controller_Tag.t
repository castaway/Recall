use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Recall';
use Recall::Controller::Tag;

ok( request('/tag')->is_success, 'Request should succeed' );
done_testing();
