use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Recall';
use Recall::Controller::Blog;

ok( request('/blog')->is_success, 'Request should succeed' );
done_testing();
