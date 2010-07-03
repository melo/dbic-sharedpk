package DBICx::SharedPK;

use strict;
use warnings;
use Carp qw( croak );
use constant SHAREDPK_REL_NAME => '_shared_pk_rel';

sub set_shared_primary_key {
  my ($class, $foreign_class, $field, $rel_name) = @_;
  $rel_name ||= SHAREDPK_REL_NAME;

  $class->set_primary_key($field);
  $class->ensure_class_loaded($foreign_class);
  my ($foreign_key, $too_many) = eval { $foreign_class->primary_columns };

  croak(
    'FATAL: set_shared_primary_key() requires a foreign class with a primary key'
  ) unless $foreign_key;
  croak(
    'FATAL: set_shared_primary_key() requires a foreign class with a singular primary key'
  ) if $too_many;

  $class->belongs_to($rel_name, $foreign_class,
    {"foreign.$foreign_key" => "self.$field"},
  );

  my $si = $class->source_info || {};
  $si->{SHAREDPK_REL_NAME} = $rel_name;
  $class->source_info($si);
}

sub insert {
  my ($self, @rest) = @_;
  my $source   = $self->result_source;
  my $rel_name = $source->source_info->{SHAREDPK_REL_NAME};

  my $meth = $self->next::can;

  return $source->schema->txn_do(
    sub {
      if ($source->has_relationship($rel_name)) {
        my ($key) = $self->primary_columns;
        if (!defined($self->get_column($key))) {
          my $frg_obj =
            $self->create_related($rel_name,
            {source => $source->source_name});
          $self->set_column($key => ($frg_obj->id)[0]);
        }
      }

      return $meth->($self, @rest);
    }
  );
}

1;

=encoding utf8


=head1 NAME

DBICx::SharedPK - Use the primary key of a shared source on other sources


=head1 SYNOPSIS

    ### Create your PK source
    package My::Schema::Result::IDs;
    
    use base 'DBIx::Class';
    
    __PACKAGE__->load_namespaces('Core');
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
    
    
    ### Use on your sources
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
    
    __PACKAGE__->set_shared_primary_key('My::Schema::Result::IDs' => 'user_id');
    
    1;


=head1 DESCRIPTION

Source C<My::Schema::Result::IDs> is used to generate IDs. Then you can
use them on other sources automagically.


=head1 METHODS

=head2 set_shared_primary_key()

Defines our primary key, get them from source.


=head1 DIAGNOSTICS

The following exceptions might be thrown:


=over 4


=item FATAL: set_shared_primary_key() requires a foreign class with a primary key

The shared PK class lacks a primary key.


=item FATAL: set_shared_primary_key() requires a foreign class with a singular primary key

The shared PK class has a multiple column primary key. This module only
supports single column primary keys.


=back


=head1 SEE ALSO

L<DBIx::Class>


=head1 AUTHOR

Pedro Melo, C<< <melo@simplicidade.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2010 Pedro Melo

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=for coverage

=head2 insert

=cut
