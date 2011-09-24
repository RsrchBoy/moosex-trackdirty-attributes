package MooseX::TrackDirty::Attributes;

# ABSTRACT: Track dirtied attributes

use warnings;
use strict;

use Moose 2.0 ();
use namespace::autoclean;
use Moose::Exporter;

# debugging
#use Smart::Comments '###', '####';

{
    package MooseX::TrackDirty::Attributes::Trait::Attribute::WithNativeTraits;
    use Moose::Role;
    use namespace::autoclean;

    with 'MooseX::TrackDirty::Attributes::Trait::Attribute';

    # TODO...
}
{
    package MooseX::TrackDirty::Attributes::Trait::Class;
    use namespace::autoclean;
    use Moose::Role;

    # TODO implement!
    sub get_all_dirtiable_attributes { warn }

}

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ 'MooseX::TrackDirty::Attributes::Trait::Attribute' => 'TrackDirty' ],
    ],
    class_metaroles => {
        class => [ 'MooseX::TrackDirty::Attributes::Trait::Class' ],
    },
    role_metaroles => {
        #applied_attribute => [ 'MooseX::TrackDirty::Attributes::Trait::Attribute' ],
    },
);

!!42;

__END__

=head1 SYNOPSIS

    use Moose;
    use MooseX::TrackDirty::Attributes;

    # one_is_dirty() is generated w/lazy_build
    has one => (is => 'rw', lazy_build => 1);

    # dirtyness "accessor" is generated as two_isnt_clean()
    has two => (is => 'rw', default => 'foo', dirty => 'two_isnt_clean');

    # we do not track three's cleanliness
    has three => (is => 'rw', default => 'foo', track_dirty => 0);

    # ...etc

=head1 WARNING!

This module should be considered alpha at the moment.  I'm still trying to
figure out the best way to do this -- in particular, tracking attribute status
with a hardcoded base class role feels, well, dirty...  It seems like I should
be able to use L<MooseX::Role::Parameterized> to make this a touch more
flexible.

I'll try to preserve this modules behaviour, but no promises at the moment.

=head1 DESCRIPTION

MooseX::TrackDirty::Attributes does the necessary metaclass fiddling to track
if attributes are dirty; that is, if they're set to some value not from a
builder, default, or construction.  An attribute can be returned to a clean
state by invoking its clearer.

=head1 CAVEAT

Note that this is fairly crude; with few exceptions we can only track
dirtiness at the very first level.  That is, if you have an attribute that is
a HashRef, we can tell that the _attribute_ is dirty iff the actual HashRef
ref changes, but not if the HashRef's keys/values change. e.g.
$self->hashref({ new => 'hash' }) would render the 'hashref' attribute dirty,
but $self->hashref->{foo} = 'bar' would not.

=head2 CAVEAT TO THE CAVEAT

Some attributes are designed to be used at this level; namely those that
employ an attribute helper trait to interface with the lower-level bits
directly.  Support for tracking dirtiness at that level is in the works;
right now Array and Hash trait helpers are tracked.

=head1 ATTRIBUTE OPTIONS

We install an attribute metaclass trait that provides three additional
atttribute options, as well as wraps the generated clearer and writer/accessor
methods of the attribute.  By default, use'ing this module causes this
trait to be installed for all attributes defined in the package.

=over 4

=item track_dirty => (0|1)

If true (the default), we track this attrbutes dirtiness and wrap any
generated clearer, setter or accessor methods.

=item dirty => Str

If set, create a "dirtiness accessor".  Default is to not create one.  If
lazy_build is specified, a method is generated with "foo_is_dirty", where foo
is the attribute name.

=item track_attribute_helpers_dirty => (0|1)

If true (the default), we also track any "writing" attribute helper methods
installed by the native attribute traits.  (e.g. Hash, Array, etc.)

Note that this goes deeper than general "dirtiness" tracking.  w/o tracking
attribute helpers, we only mark an attribute as dirty when a setter or
accessor (used as a setter) is invoked.

=back

=cut
