#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Exception;

use My::Schema;

for my $package ('DBD::SQLite', 'SQL::Translator') {
  eval "require $package";
  plan skip_all => "Tests require $package, " if $@;
}

my $schema;
lives_ok sub { $schema = My::Schema->test_schema },
  'Schema deployed sucessfuly';

my $user1 = $schema->resultset('Users')->create({});
ok($user1, 'Got a Users object');
is($user1->user_id, 1, '... expected user_id');

my $sk = $user1->_shared_pk_rel;
is($sk->shared_id, 1,       '... the same as the related shared key');
is($sk->source,    'Users', '... and the expected source, Users');

my $teacher1 = $schema->resultset('Teachers')->create({});
ok($teacher1, 'Got a Teachers object');
is($teacher1->teacher_id, 2, '... expected teacher_id');

$sk = $teacher1->_shared_pk_rel;
is($sk->shared_id, 2,          '... the same as the related shared key');
is($sk->source,    'Teachers', '... and the expected source, Teachers');

done_testing();
