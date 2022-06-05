# Roles cannot autovivify, so we need parameterizable classes
use Parameterizable;

# A BinaryHeap is an implicit binary tree that satisfies the heap property:
# the value of a node never precedes the value of its parent node
proto sub infix:<precedes>($, $) {*}

role BinaryHeap[&infix:<precedes> = * cmp * == Less] {
    # The heap is represented by @!array[^$!elems];
    # the array may contain additional elements to accommodate a heapsort.
    has @!array;
    has int $!elems;

    # Construct a heap with zero or more values
    proto method new(|) {*}
    multi method new( --> BinaryHeap:D) { self.CREATE }
    multi method new(Mu \arg --> BinaryHeap:D) {
        self.CREATE.STORE(arg);
    }
    multi method new(Slip:D \values --> BinaryHeap:D) {
        self.CREATE.STORE(values<>);
    }
    multi method new(**@values is raw --> BinaryHeap:D) {
        self.CREATE.STORE(@values);
    }

    proto method STORE(BinaryHeap:D: |) {*}
    multi method STORE(BinaryHeap:D: Mu \value --> BinaryHeap:D) {
        @!array = value;
        $!elems = 1;
        self;
    }
    multi method STORE(BinaryHeap:D: Iterable:D \values --> BinaryHeap:D) {
        @!array = values;
        $!elems = @!array.elems;

        # heapify
        my int $pos = ($!elems - 2) div 2; # last internal node
        self!sift-down($pos--) while $pos >= 0;
        self;
    }

    # Sift down with bounce to reduce the number of comparisons
    # Define a path down from a node at a given position, by selecting the
    # highest priority (or right) child at each level. Then shorten the path
    # until the final node can contain the value of the first node without
    # violating the heap condition. Then assign each node in the path the value
    # of its successor, and assign the final node the value of the first node.
    method !sift-down(int $pos is copy --> Nil) {
        my @path;
        my $node := @!array[$pos];
        @path[my int $path-end] := $node;

        my int $heap-end = $!elems - 1;
        while ($pos = ($pos * 2) + 1) < $heap-end {
            my \left  = @!array[$pos];
            my \right = @!array[$pos + 1];
            if left precedes right {
                @path[++$path-end] := left;
            }
            else {
                $pos += 1;
                @path[++$path-end] := right;
            }
        }

        # at the deepest level there may be only one child
        if $pos == $heap-end {
            @path[++$path-end] := @!array[$pos];
        }

        # shorten the path until the final node can hold the value of the first
        my $value = $node;
        while $path-end > 0 && $value precedes @path[$path-end] {
            $path-end--;
        }

        # shift values until we reach the final node of the path
        $pos = 0;
        while $pos < $path-end {
            my \child = @path[++$pos];
            $node  = child;
            $node := child;
        }

        # assign the original value of the first node to the final node
        $node = $value;
    }

    # Extract a value from a heap
    method pop(BinaryHeap:D:) is nodal {
        if $!elems > 0 {
            my $value = @!array[--$!elems]:delete;
            $!elems > 0 ?? self.replace($value) !! $value;
        }
        else {
            Failure.new:
              X::Cannot::Empty.new(:action<pop>, :what(self.^name));
        }
    }

    # Insert values into a heap
    proto method push(BinaryHeap: |) {*}
    multi method push(BinaryHeap:U \SELF: **@values is raw --> BinaryHeap:D) {
        SELF = SELF.CREATE.push(|@values);
    }
    multi method push(BinaryHeap:D: **@values is raw --> BinaryHeap:D) {
        self!insert($_) for @values;
        self;
    }
    multi method push(BinaryHeap:D: Slip \values --> BinaryHeap:D) {
        self!insert($_) for values;
        self;
    }
    multi method push(BinaryHeap:D: Mu \value --> BinaryHeap:D) {
        self!insert(value);
        self;
    }
    method !insert(Mu \value --> Nil) {
        # sift the provided value up from a new node
        my $node := @!array[my int $pos = $!elems++];
        while $pos > 0
          && value precedes my \parent = @!array[$pos = ($pos - 1) div 2]
        {
            $node  = parent;
            $node := parent;
        }
        $node = value;
    }

    # Insert, then extract
    method push-pop(BinaryHeap:D: Mu \value) {
        $!elems > 0 && @!array[0] precedes value
          ?? self.replace(value)
          !! value;
    }

    # Replace the top of a heap (extract, then insert)
    method replace(BinaryHeap:D: Mu \new) {
        if $!elems > 0 {
            my $node := @!array[0];
            my $old = $node;
            $node = new;
            self!sift-down(0);
            $old;
        }
        else {
            @!array[$!elems++] = new;
            Nil;
        }
    }

    multi method Bool(::?CLASS::D: --> Bool:D) { $!elems > 0 }
    method top(BinaryHeap:D:) { $!elems > 0 ?? @!array[0] !! Nil }

    # Allow introspection, but do not return containers:
    multi method values(::?CLASS:D: --> Seq:D) {
        my int $i;
        gather while $i < $!elems { take @!array[$i++] }
    }
}

class BinaryHeap::MaxHeap does BinaryHeap[* cmp * == More] is Parameterizable {
    method MIXIN(&infix:<cmp>) {
        my &precedes = * cmp * == More;
        BinaryHeap[&precedes];
    }
}

class BinaryHeap::MinHeap does BinaryHeap[* cmp * == Less] is Parameterizable {
    method MIXIN(&infix:<cmp>) {
        my &precedes = * cmp * == Less;
        BinaryHeap[&precedes];
    }
}

=begin pod

=head1 NAME

BinaryHeap - Array-based binary heap

=head1 SYNOPSIS

=begin code :lang<raku>
use BinaryHeap;

my $heap = BinaryHeap.new(42, 11);
say $heap.pop; # OUTPUT: «11␤»
say $heap.top; # OUTPUT: «42␤»
=end code

=head1 DESCRIPTION

    role BinaryHeap[&infix:<precedes> = * cmp * == Less] {}

Role C<BinaryHeap> stores values in an implicit binary tree that satisfies the
B<heap property>: the value of a node never C<precedes> the value of its parent
node.

Infix C<precedes> defines a priority relation, such that the root of the tree,
known as the L<top|#method_top> of the heap, has a priority higher than or equal
to all other nodes of the tree. The default relation defines a I<min heap>, i.e.
the top value compares C<Less> than or C<Same> as every other value on the heap.

Module C<BinaryHeap> provides two classes that mix in the role:

=begin item
C<class BinaryHeap::MaxHeap does BinaryHeap[* cmp * == More]>

In a I<max-heap>, a child node never compares L<More> than its parent node.
=end item

=begin item
C<class BinaryHeap::MinHeap does BinaryHeap[* cmp * == Less]>

In a I<min-heap>, a child node never compares L<Less> than its parent node.
=end item

These classes are parameterizable with a custom comparison routine. For example,
this max-heap compares objects by their C<.key>:

    my BinaryHeap::MaxHeap[*.key cmp *.key] $heap;

=head1 METHODS

=head2 method Bool

Defined as:

    multi method Bool(BinaryHeap:D: --> Bool:D)

Returns C<True> if the heap contains at least one node, and C<False> if the
heap is empty.

=head2 method new

Defined as:

    method new(+values --> BinaryHeap:D)

Creates a new heap instance. The provided values are stored in heap order.

=head2 method pop

Defined as:

    method pop(BinaryHeap:D:) is nodal

Removes the value stored at the L<top|#method_top> of the heap and returns it,
or returns a C<Failure> if the heap is empty.

=head2 method push

Defined as:

    method push(BinaryHeap: **@values is raw --> BinaryHeap:D)

Inserts the provided values into the heap and returns the modified heap. Tries
to autovivify the invocant if called on an undefined invocant. For example:

    my BinaryHeap::MaxHeap $heap;
    $heap.push(42, 11);
    say $heap.pop; # OUTPUT: «42␤»
    say $heap.top; # OUTPUT: «11␤»

=head2 method push-pop

Defined as:

    method push-pop(BinaryHeap:D: Mu \value)

Functionally equivalent, but more efficient than a L<push|#method_push>
followed by a L<pop|#method_pop>. L<Replaces the top|#method_replace> of the
heap if it precedes the provided value; otherwise returns the provided value.

=head2 method replace

Defined as:

    method replace(BinaryHeap:D: Mu \new)

Functionally equivalent, but more efficient than a L<pop|#method_pop> followed
by a L<push|#method_push>. Replaces the L<top|#method_top> of the heap with the
new value and returns the old value, or C<Nil> if the heap was empty.

=head2 method top

Defined as:

    method top(BinaryHeap:D:)

Returns the value stored at the top of the heap, or C<Nil> if the heap is empty.

=head2 method values

    multi method values(BinaryHeap:D: --> Seq:D)

Returns a C<Seq> of the values encountered during a breadth-first traversal of
the heap.

=head1 SEE ALSO

=item L<Binary heap - Wikipedia|https://en.wikipedia.org/wiki/Binary_heap>

=head1 AUTHOR

Peter du Marchie van Voorthuysen

Source can be located at: https://github.com/dumarchie/raku-binaryheap

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Peter du Marchie van Voorthuysen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
