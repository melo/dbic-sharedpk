package DBICx::SharedPK;

use strict;
use warnings;
use Carp qw( croak );
use constant SHAREDPK_REL_NAME => '_shared_pk_rel';

sub set_shared_primary_key {
  my ($class, $foreign_class, $field) = @_;

  $class->set_primary_key($field);
  $class->ensure_class_loaded($foreign_class);
  my ($foreign_key, $too_many) = eval { $foreign_class->primary_columns };

  croak(
    'FATAL: set_shared_primary_key() requires a foreign class with a primary key'
  ) unless $foreign_key;
  croak(
    'FATAL: set_shared_primary_key() requires a foreign class with a singular primary key'
  ) if $too_many;

  $class->belongs_to(SHAREDPK_REL_NAME, $foreign_class,
    {"foreign.$foreign_key" => "self.$field"},
  );
}

sub insert {
  my ($self, @rest) = @_;
  my $source = $self->result_source;

  my $meth = $self->next::can;

  return $source->schema->txn_do(
    sub {
      if ($source->has_relationship(SHAREDPK_REL_NAME)) {
        my ($key) = $self->primary_columns;
        if (!defined($self->get_column($key))) {
          my $frg_obj =
            $self->create_related(SHAREDPK_REL_NAME,
            {source => $source->source_name});
          $self->set_column($key => ($frg_obj->id)[0]);
        }
      }

      return $meth->($self, @rest);
    }
  );
}

1;
