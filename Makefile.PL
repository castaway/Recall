#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Recall';
all_from 'lib/Recall.pm';

requires 'Moose';
requires 'Catalyst::Runtime' => '5.90016';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Markdown';
requires 'Catalyst::Plugin::StackTrace';
requires 'DateTime';
requires 'DateTime::Format::MySQL';
requires 'Text::Markdown';
requires 'HTML::TagCloud';
requires 'Catalyst::Action::RenderView';
requires 'namespace::autoclean';
requires 'Catalyst::View::XML::Feed';
requires 'Catalyst::View::TT';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Restarter';
requires 'MooseX::NonMoose';
requires 'DBIx::Class::Helper::ResultSet::CorrelateRelationship';
requires 'DBIx::Class::Schema::Loader';
requires 'MooseX::MarkAsMethods';
requires 'DBD::mysql';
requires 'File::Slurp';
requires 'Class::Trigger';
requires 'DBIx::ContextualFetch';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
