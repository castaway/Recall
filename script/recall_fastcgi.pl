#!/usr/bin/env perl

# # # Working dev Apache configuration
# Via http://wiki.catalystframework.org/wiki/gettingstarted/tutorialsandhowtos/layering_static_content_over_your_catalyst_applcation_with_apache_and_fastcgi
# <VirtualHost *:80>
#         DocumentRoot  /home/david/prog/recall/http_root
#         ServerName recall.local
#         ErrorLog /home/david/prog/recall/logs/error.log
#         CustomLog /home/david/prog/recall/logs/access.log combined

#         <Location /static/>
#                 SetHandler default-handler
#         </Location>

#         Alias /static/ /home/david/prog/recall/Recall/root/static/
#         Alias / /home/david/prog/recall/Recall/script/recall_fastcgi.pl/

#         SetHandler fcgid-script
#         Options +ExecCGI
#         SetEnv PERL5LIB /home/david/perl5/lib/perl5/i486-linux-gnu-thread-multi:/home/david/perl5/lib/perl5:/home/david/prog/recall/Recall/lib 

#         # Make sure the rewriting phase skips http://example.net/static
#         # and http://example.net/.fcgi
#         RewriteCond $1 !^(static|.fcgi)/?$

#         # If a file OR directory matching the request exists...
#         RewriteCond "/var/www/static/$1" -f [OR]
#         RewriteCond "/var/www/static/$1/index.html" -f

#         # ...then rewrite the request to use our fake static
#         # content alias (which is actually the DocumentRoot)
#         RewriteRule ^/(.*)$ /static/$1

#         # If the request is for a directory, then make sure to serve up index.html
#         RewriteCond "/var/www/static/$1" -d
#         RewriteRule ^/static/(.*)/?$ /static/$1/index.html

#         # Finally, signal that rewriting is done and pass-through
#         # the request to the alias handler
#         RewriteRule ^/static/ - [L,PT]

# </VirtualHost>


use lib qw[
    /home/david/perl5/lib/perl5/i486-linux-gnu-thread-multi
    /home/david/perl5/lib/perl5
    /home/david/prog/recall/Recall/lib
];

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('Recall', 'FastCGI');

1;

=head1 NAME

recall_fastcgi.pl - Catalyst FastCGI

=head1 SYNOPSIS

recall_fastcgi.pl [options]

 Options:
   -? -help      display this help and exits
   -l --listen   Socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -n --nproc    specify number of processes to keep
                 to serve requests (defaults to 1,
                 requires -listen)
   -p --pidfile  specify filename for pid file
                 (requires -listen)
   -d --daemon   daemonize (requires -listen)
   -M --manager  specify alternate process manager
                 (FCGI::ProcManager sub-class)
                 or empty string to disable
   -e --keeperr  send error messages to STDOUT, not
                 to the webserver
   --proc_title  Set the process title (is possible)

=head1 DESCRIPTION

Run a Catalyst application as fastcgi.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
