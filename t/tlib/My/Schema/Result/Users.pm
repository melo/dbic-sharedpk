package My::Schema::Result::Users;

use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('+DBICx::SharedPK', 'Core');
__PACKAGE__->table('my_users');

__PACKAGE__->add_columns(
  user_id => {
    data_type => 'integer',
    is_nullable => 0,
  },
);

__PACKAGE__->set_shared_primary_key('My::Schema::Result::IDs' => 'user_id', 'id_source');

1;
