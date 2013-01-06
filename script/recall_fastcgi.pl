#!/usr/bin/env perl

# # # Working dev Apache configuration
# DocumentRoot  /home/david/prog/recall/http_root
# ServerName recall.local
# ErrorLog /home/david/prog/recall/logs/error.log
# CustomLog /home/david/prog/recall/logs/access.log combined
# SetHandler fcgid-script
# Options +ExecCGI
# Alias / /home/david/prog/recall/Recall/script/recall_fastcgi.pl/

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
