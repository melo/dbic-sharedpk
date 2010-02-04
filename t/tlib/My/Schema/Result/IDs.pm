package My::Schema::Result::IDs;

use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('my_ids');

__PACKAGE__->add_columns(
  shared_id => {
    data_type         => 'integer',
    is_nullable       => 0,
    is_auto_increment => 1,
  },

  source => {
    data_type   => 'varchar',
    size        => 100,
    is_nullable => 0,
  },
);

__PACKAGE__->set_primary_key('shared_id');

1;
