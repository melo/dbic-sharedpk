package My::Schema;

use strict;
use warnings;
use base 'DBIx::Class::Schema';
use constant MY_DB_FILENAME => 'test.db';

__PACKAGE__->load_namespaces;

sub test_schema {
  my ($class) = @_;

  unlink(MY_DB_FILENAME);
  my $schema = $class->connect('dbi:SQLite:' . MY_DB_FILENAME);
  $schema->deploy;

  return $schema;
}

END { unlink(MY_DB_FILENAME) }

1;
