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
    has @!path; # reusable path for sift-down
    method !SET-SELF(@array) {
        @!array := @array;
        $!elems = @!array.elems;
        self;
    }

    # Clone a concrete heap
    multi method clone(BinaryHeap:D: --> BinaryHeap:D) {
        my @copy = @!array.head($!elems);
        self.CREATE!SET-SELF(@copy);
    }

    # Construct a heap with zero or more values
    proto method new(|) {*}
    multi method new(        --> BinaryHeap:D) { self.CREATE }
    multi method new(+values --> BinaryHeap:D) { self.heapify(values.Array) }

    # Heapify an array
    method heapify(@array --> BinaryHeap:D) {
        self.CREATE!SET-SELF(@array)!HEAPIFY;
    }
    method !HEAPIFY() {
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
        my $node := @!array[$pos];
        @!path.BIND-POS(my int $path-end, $node);

        my int $heap-end = $!elems - 1;
        while ($pos = ($pos * 2) + 1) < $heap-end {
            my \left  = @!array[$pos];
            my \right = @!array[$pos + 1];
            if left precedes right {
                @!path.BIND-POS(++$path-end, left);
            }
            else {
                $pos += 1;
                @!path.BIND-POS(++$path-end, right);
            }
        }

        # at the deepest level there may be only one child
        if $pos == $heap-end {
            @!path.BIND-POS(++$path-end, @!array[$pos]);
        }

        # shorten the path until the final node can hold the value of the first
        my $value = $node;
        while $path-end > 0 && $value precedes @!path[$path-end] {
            $path-end--;
        }

        # shift values until we reach the final node of the path
        $pos = 0;
        while $pos < $path-end {
            my \child = @!path[++$pos];
            $node  = child;
            $node := child;
        }

        # assign the original value of the first node to the final node
        $node = $value;
    }

    # Extract a single value from a heap
    method pop() {
        self ?? self!extract !! Failure.new:
          X::Cannot::Empty.new(:action<pop>, :what(self.^name));
    }
    method !extract() {
        my $value = @!array[$!elems - 1]:delete;
        --$!elems > 0 ?? self.replace($value) !! $value;
    }

    # Extract a Seq of values from a heap
    method consume( --> Seq:D) {
        gather take self!extract while self;
    }

    # Insert values into a heap
    proto method push(|) {*}
    multi method push(::?CLASS:U $_ is rw: **@values is raw --> BinaryHeap:D) {
        $_ = self.CREATE.push(|@values);
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
        # increment $!elems only if the value can be assigned to a new node
        my $node := @!array[$!elems];
        $node = value;
        my int $pos = $!elems++;

        # sift the provided value up from the new node
        while $pos > 0
          && value precedes my \parent = @!array[$pos = ($pos - 1) div 2]
        {
            $node  = parent;
            $node := parent;
        }
        $node = value;
    }

    # Insert, then extract
    method push-pop(Mu \value) {
        self && @!array[0] precedes value ?? self.replace(value) !! value;
    }

    # Replace the top of a heap (extract, then insert)
    method replace(\SELF: Mu \new) {
        if self {
            my $node := @!array[0];
            my $old = $node;
            $node = new;
            self!sift-down(0);
            $old;
        }
        else {
            SELF.push(new);
            Nil;
        }
    }

    proto method sort(|) {*}
    multi method sort(BinaryHeap:U:) { Array.new }
    multi method sort(BinaryHeap:D:) {
        my @array := @!array;
        while $!elems > 1 {
            my $node := @array[--$!elems];
            $node = self.replace($node);
        }
        self!SET-SELF(@array.new);
        @array;
    }

    method Bool( --> Bool:D) { self.defined && $!elems > 0 }
    method top() { self ?? @!array[0] !! Nil }

    # Allow introspection, but do not return containers:
    method values( --> Seq:D) {
        if self {
            my int $i;
            gather take @!array[$i++] while $i < $!elems;
        }
        else {
            Empty.Seq;
        }
    }

    multi sub infix:<eqv>(BinaryHeap \a, BinaryHeap \b --> Bool:D) is export {
        a.WHAT === b.WHAT && a.values eqv b.values;
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

proto sub heapsort(|) is export {*}
multi sub heapsort(@array, :$reverse) {
    my \heap = $reverse ?? BinaryHeap::MinHeap !! BinaryHeap::MaxHeap;
    heap.heapify(@array).sort;
}
multi sub heapsort(&cmp, @array, :$reverse) {
    my \heap = $reverse ?? BinaryHeap::MinHeap !! BinaryHeap::MaxHeap;
    heap.^parameterize(&cmp).heapify(@array).sort;
}

=begin pod

=head1 NAME

BinaryHeap - Array-based binary heap supporting heapsort

=head1 SYNOPSIS

=begin code :lang<raku>
use BinaryHeap;

my BinaryHeap::MinHeap $heap;
$heap.push(42, 11);
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
to all other nodes of the tree. The default relation defines a I<min-heap>, i.e.
the top value compares C<Less> than or C<Same> as every other value on the heap.

Module C<BinaryHeap> provides two classes that mix in the role:

=begin item
C<class BinaryHeap::MaxHeap does BinaryHeap[* cmp * == More]>

In a I<max-heap>, a child node never compares C<More> than its parent node.
=end item

=begin item
C<class BinaryHeap::MinHeap does BinaryHeap[* cmp * == Less]>

In a I<min-heap>, a child node never compares C<Less> than its parent node.
=end item

These classes are parameterizable with a custom three-way comparison operator.
For example, this I<max-heap> compares objects by their C<.key>:

    my BinaryHeap::MaxHeap[*.key cmp *.key] $heap;

An uninitialized C<BinaryHeap> is a valid representation of an empty heap. This
means that all documented methods can be called on a type object. Methods that
may add values to the heap try to autovivify an uninitialized invocant, which
means they can only be called on a I<container> that stores or defaults to a
I<class> type. For example, given the uninitialized C<$heap> declared above:

    say $heap.values;      # OUTPUT: «()␤»
    say $heap.replace(42); # OUTPUT: «Nil␤»
    say $heap.top;         # OUTPUT: «42␤»

=head1 EXPORTS

=head2 infix eqv

Defined as:

    multi sub infix:<eqv>(BinaryHeap \a, BinaryHeap \b --> Bool:D)

Returns C<True> if and only if the two heaps are of the same type and contain
equivalent L<values|#method_values>. Note that a concrete heap is of a different
type than a role, so:

    say BinaryHeap.new eqv BinaryHeap;                   # OUTPUT: «False␤»
    say BinaryHeap::MaxHeap.new eqv BinaryHeap::MaxHeap; # OUTPUT: «True␤»

=head2 sub heapsort

Defined as:

    multi sub heapsort(@array, :$reverse)
    multi sub heapsort(&comparator, @array, :$reverse)

Sorts and returns the C<@array>, using a custom three-way C<&comparator> if
provided. By default the array is sorted in ascending order, but it is sorted in
descending order if C<:$reverse> is true. Hence, the following statements both
put the elements of the array in descending order:

    heapsort @array, :reverse;
    heapsort -(* cmp *), @array;

Note that C<heapsort> is not a L<stable
sort|https://en.wikipedia.org/wiki/Sorting_algorithm#Stability>.

=head1 METHODS

=head2 method Bool

Defined as:

    method Bool( --> Bool:D)

Returns C<True> if the heap contains at least one node, and C<False> if the
heap is empty.

=head2 method clone

Defined as:

    multi method clone(BinaryHeap:D: --> BinaryHeap:D)

Returns a clone of the invocant. The clone is based on a distinct array, so
modifications to one heap will not affect the other heap.

=head2 method consume

Defined as:

    method consume( --> Seq:D)

Returns a C<Seq> that generates values by removing them from the top of the
heap. If no values are inserted into the heap before the C<Seq> is exhausted,
the values will be in ascending order if called on a I<min-heap>, in descending
order if called on a I<max-heap>.

=head2 method heapify

Defined as:

    method heapify(@array --> BinaryHeap:D)

Constructs a new heap based on the provided array, whose elements are put in
heap order. The C<@array> should not be modified directly while the heap is in
use.

=head2 method new

Defined as:

    method new(+values --> BinaryHeap:D)

Constructs a new heap storing the provided values.

=head2 method pop

Defined as:

    method pop()

Removes the value stored at the L<top|#method_top> of the heap and returns it,
or returns a C<Failure> if the heap is empty.

=head2 method push

Defined as:

    method push(**@values --> BinaryHeap:D)

Inserts the provided values into the heap and returns the modified heap.
Autovivifies the invocant if called on a container storing or defaulting to a
class type object. For example:

    my BinaryHeap::MaxHeap $heap;
    $heap.push(42, 11);
    say $heap.pop; # OUTPUT: «42␤»
    say $heap.top; # OUTPUT: «11␤»

=head2 method push-pop

Defined as:

    method push-pop(Mu \value)

Functionally equivalent, but more efficient than a L<push|#method_push>
followed by a L<pop|#method_pop>. L<Replaces the top|#method_replace> of the
heap if it C<precedes> the provided value; otherwise just returns the provided
value.

=head2 method replace

Defined as:

    method replace(Mu \new)

Functionally equivalent, but more efficient than a L<pop|#method_pop> followed
by a L<push|#method_push>. Removes the L<top|#method_top> of the heap and
returns it after inserting the new value.

=head2 method sort

Defined as:

    method sort()

Returns an empty C<Array> if called on an uninitialized heap. Otherwise sorts
the underlying array in descending order if called on a I<min-heap>, in
ascending order if called on a I<max-heap>. Replaces the underlying array with
an empty copy and returns the sorted array.

=head2 method top

Defined as:

    method top()

Returns the value stored at the top of the heap, or C<Nil> if the heap is empty.

=head2 method values

Defined as:

    method values( --> Seq:D)

Returns a C<Seq> of the values encountered during a breadth-first traversal of
the heap.

=head1 SEE ALSO

=item L<Binary heap - Wikipedia|https://en.wikipedia.org/wiki/Binary_heap>

=item L<Heapsort - Wikipedia|https://en.wikipedia.org/wiki/Heapsort>

=item L<Raku's built-in C<sort> routine|https://docs.raku.org/routine/sort>,
which is faster than a L<C<heapsort>|#sub_heapsort> on Rakudo.

=head1 AUTHOR

Peter du Marchie van Voorthuysen

Source can be located at: https://github.com/dumarchie/raku-binaryheap

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Peter du Marchie van Voorthuysen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
