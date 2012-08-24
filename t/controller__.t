use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Recall';
use Recall::Controller::_;

ok( request('/_')->is_success, 'Request should succeed' );
done_testing();
