package My::Schema::Result::Teachers;

use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('+DBICx::SharedPK', 'Core');
__PACKAGE__->table('my_teachers');

__PACKAGE__->add_columns(
  teacher_id => {
    data_type => 'integer',
    is_nullable => 0,
  },
);

__PACKAGE__->set_shared_primary_key('My::Schema::Result::IDs' => 'teacher_id');

1;
