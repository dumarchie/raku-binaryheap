# The EXPORT sub must be defined outside the module scope
sub EXPORT(**@keys) {
    my %EXPORT = ::<BinaryHeap>.WHO;
    if my @missing = @keys.grep({ %EXPORT{$_}:!exists }) {
        die "Trying to import from 'BinaryHeap', "
          ~ "but the following symbols are not exported: "
          ~ @missing.join(", ");
    }
    Map.new(@keys.map({ $_ => %EXPORT{$_} }))
}

unit module BinaryHeap;

# A heap is a binary tree that satisfies the heap invariant:
# the priority of a node never tops the priority of its parent node
proto sub infix:<tops>($, $) {*}

role GenHeap[&infix:<tops>] is export {
    # The heap is represented by @!array[^$!elems];
    # the array may contain additional elements to accommodate a heapsort.
    has @!array;
    has int $!elems;
    has @!path; # reusable path for sift-down
    method !SET-SELF(@array, $elems = @array.elems) {
        @!array := @array;
        $!elems = $elems;
        if $!elems > 1 { # heapify array
            my int $pos = ($!elems - 2) div 2; # last internal node
            self!sift-down($pos--) while $pos >= 0;
        }
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
            if left tops right {
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
        while $path-end > 0 && $value tops @!path[$path-end] {
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

    # Construct a heap with zero or more values
    proto method new(| --> ::?CLASS:D) {*}
    multi method new(::?CLASS:) { ::?CLASS.CREATE }
    multi method new(::?CLASS: **@values) {
        ::?CLASS.CREATE!SET-SELF(@values);
    }
    # Flatten an itemized Slip
    multi method new(::?CLASS: Slip \values) {
        self.new(values.Array, :in-place);
    }
    multi method new(::?CLASS: Iterable \value, Bool() :$in-place) {
        my @values;
        if value.VAR !=== value {
            @values = value;
        }
        elsif value ~~ Array|array {
            @values := $in-place ?? value !! value.clone;
        }
        else {
            @values := value.Array;
        }
        ::?CLASS.CREATE!SET-SELF(@values);
    }

    # A heap has the type constraint of the underlying array
    proto method of() {*}
    multi method of(::?CLASS:U:) { Mu }
    multi method of(::?CLASS:D:) { @!array.of }

    # A clone should retain a constraint on element type
    multi method clone(::?CLASS:D:) {
        ::?CLASS.CREATE!SET-SELF(@!array.clone, $!elems);
    }

    # Extract a single value from a heap
    method pop() {
        self ?? self!extract-one !! Failure.new:
          X::Cannot::Empty.new(:action<pop>, :what(self.^name));
    }
    method !extract-one() {
        my $value = @!array[--$!elems];
        $!elems ?? self!replace-top($value) !! $value;
    }

    # Extract a Seq of values from a heap
    proto method extract(| --> Seq:D) {*} 
    multi method extract() {
        gather take self!extract-one while self;
    }
    multi method extract(\n) {
        my int $n = n;
        gather take self!extract-one while self && $n-- > 0;
    }

    # Insert values into a heap
    proto method push(| --> ::?CLASS:D) {*}
    multi method push(::?ROLE:U $self is rw: **@values is raw) {
        # Note: this may yield a different heap structure than .new
        $self = self.CREATE.push(|@values);
    }
    multi method push(::?ROLE:D: **@values is raw) {
        self!insert($_) for @values;
        self;
    }
    multi method push(::?ROLE:D: Slip \values) {
        self!insert($_) for values;
        self;
    }
    multi method push(::?ROLE:D: Mu \value) {
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
          && value tops my \parent = @!array[$pos = ($pos - 1) div 2]
        {
            $node  = parent;
            $node := parent;
        }
        $node = value;
    }

    # Insert, then extract
    method push-pop(Mu \value) {
        self && @!array[0] tops value ?? self.replace(value) !! value;
    }

    # Replace the top of a heap (extract, then insert)
    method replace(\SELF: Mu \new) {
        if self {
            self!replace-top(new);
        }
        else {
            SELF.push(new);
            Nil;
        }
    }
    method !replace-top(Mu \new) {
        my $value = @!array[0];
        @!array[0] = new;
        self!sift-down(0);
        $value;
    }

    # The actual heapsort implementation
    method extract-reverse is implementation-detail {
        while $!elems > 1 {
            my $node := @!array[--$!elems];
            $node = self.replace($node);
        }
        @!array;
    }

    multi method Bool(::?CLASS:D: --> Bool:D) { $!elems > 0 }
    method top() { self ?? @!array[0] !! Nil }

    # Expose (number of) values on the heap
    multi method elems(::?CLASS:U $self is rw: --> 0) { $self = self.new }
    multi method elems(::?CLASS:D:) { $!elems }

    multi method values(::?CLASS:D: --> Seq:D) {
        my int $pos;
        gather take @!array[$pos++] while $pos < $!elems;
    }

    multi method gist(::?CLASS:D:) {
        self.values.gist;
    }

    # Representation for core infix eqv
    multi method raku(::?CLASS:D:) {
        my $cons = "{self.^name}.new";
        $!elems ?? $cons ~ @!array[^$!elems].raku !! $cons;
    }
}

class MaxHeap does GenHeap[* cmp * == More] is export {}

class MinHeap does GenHeap[* cmp * == Less] is export {}

multi sub infix:<eqv>(GenHeap:D \a, GenHeap:D \b --> Bool:D)
                                            is export(:MANDATORY) {
    a.WHAT === b.WHAT && a.values eqv b.values;
}

# Heapsort
our proto heapsort(|) is export {*}
multi sub heapsort(@array, Bool() :$reverse) {
    my \Heap = $reverse ?? MinHeap !! MaxHeap;
    Heap.new(@array, :in-place).extract-reverse;
}
multi sub heapsort(&cmp, @array, Bool() :$reverse) {
    my &make-heap := $reverse ?? &min-heap !! &max-heap;
    make-heap(&cmp, @array, :in-place).extract-reverse;
}

# Dynamic heap factories
our proto max-heap(|) is export {*}
multi sub max-heap(&cmp, **@values) {
    max-heap(&cmp, @values, :in-place);
}
multi sub max-heap(&infix:<cmp>, Iterable \values, Bool() :$in-place) {
    GenHeap[* cmp * == More].new(values, :$in-place);
}

our proto min-heap(|) is export {*}
multi sub min-heap(&cmp, **@values) {
    min-heap(&cmp, @values, :in-place);
}
multi sub min-heap(&infix:<cmp>, Iterable \values, Bool() :$in-place) {
    GenHeap[* cmp * == Less].new(values, :$in-place);
}

=begin pod

=head1 NAME

BinaryHeap - Array-based binary heap supporting heapsort

=head1 SYNOPSIS

    use BinaryHeap <MinHeap>;

    my MinHeap $heap;
    $heap.push(11, 42);
    say $heap.pop; # OUTPUT: «11␤»
    say $heap.top; # OUTPUT: «42␤»

=head1 DESCRIPTION

Module C<BinaryHeap> implements a heap data structure and an (in-place)
C<heapsort> routine. The heap data structure is implemented by role C<GenHeap>,
which stores values in an implicit binary tree that satisfies the B<heap
property>: the priority of a node never I<tops> the priority of its parent. The
priority of the element at the top of a heap is greater than or equal to the
priority of all other elements in a I<max-heap>, and less than or equal to the
priority of all other elements in a I<min-heap>.

Module C<BinaryHeap> provides two classes that do the C<GenHeap> role using
Raku's built-in three-way comparison operator: C<MaxHeap> and C<MinHeap>. These
heaps do not distinguish between a heap element and its priority. The dynamic
C<max-heap> and C<min-heap> factories accept a custom comparator that may
define an element's priority differently.

In many cases, an uninitialized heap can be manipulated as if it were an empty
object instance. Methods that add values autovivify the heap, which means they
can only be called on a I<container>. For example:

    my MinHeap $heap;
    say $heap.values;      # OUTPUT: «()␤»
    say $heap.replace(42); # OUTPUT: «Nil␤»
    say $heap.top;         # OUTPUT: «42␤»

=head1 EXPORTS

    use BinaryHeap <GenHeap &heapsort>;

Apart from the mandatory C<&infix:<eqv>> candidate, the following symbols in the
C<BinaryHeap> namespace are all exported by default. To import specific symbols
only, provide a list of symbol names to `use`.

=head2 role GenHeap

    role GenHeap[&infix:<tops>] {

Implements the heap data structure. Infix C<tops> defines the heap invariant:
no child node has a priority that tops the priority of its parent. See the
implementations of C<MaxHeap> and C<MinHeap> for examples.

=head2 class MaxHeap

    class MaxHeap does GenHeap[* cmp * == More] {}

A I<max-heap> that uses Raku's built-in C<infix:<cmp>> to compare the priority
of elements.

=head2 class MinHeap

    class MinHeap does GenHeap[* cmp * == Less] {}

A I<min-heap> that uses Raku's built-in C<infix:<cmp>> to compare the priority
of elements.

=head2 infix eqv

Defined as:

    multi sub infix:<eqv>(GenHeap:D \a, GenHeap:D \b --> Bool:D)

Returns C<True> if and only if the two heaps are of the same type and contain
equivalent elements at each position.

=head2 sub heapsort

Defined as:

    proto sub heapsort(|)
    multi sub heapsort(@values, Bool() :$reverse)
    multi sub heapsort(&comparator, @values, Bool() :$reverse)

Sorts the elements in-place and returns the array if C<@values> is an array;
otherwise sorts and returns the elements of a new C<Array>. Values are sorted
using the provided three-way C<&comparator> or Raku's built-in C<&infix:<cmp>>.

To sort in descending order, use the C<:reverse> adverb or negate the result of
C<&comparator>. For example, the following statements both return values in
descending order:

    heapsort @values, :reverse;
    heapsort -(* cmp *), @values;

Note that C<heapsort> is not a L<stable
sort|https://en.wikipedia.org/wiki/Sorting_algorithm#Stability>.

=head2 sub max-heap

Defined as:

    sub max-heap(&infix:<cmp>, +values, Bool() :$in-place)

Returns a custom C<GenHeap[* cmp * == More]> instance storing the provided
values. If C<values> is a single, non-itemized array, the C<:in-place> adverb
causes the array to be heapified in place. By default, an array is cloned before
heapification.

=head2 sub min-heap

Defined as:

    sub min-heap(&infix:<cmp>, +values, Bool() :$in-place)

Returns a custom C<GenHeap[* cmp * == Less]> instance storing the provided
values. If C<values> is a single, non-itemized array, the C<:in-place> adverb
causes the array to be heapified in place. By default, an array is cloned before
heapification.

=head1 METHODS

This section documents the methods provided by role C<GenHeap>.

=head2 method Bool

Defined as:

    multi method Bool(::?CLASS:D: --> Bool:D)

Returns C<True> if the heap contains at least one element, and C<False> if the
heap is empty.

=head2 method clone

Defined as:

    multi method clone(::?CLASS:D:)

Returns a clone of the heap.

=head2 method elems

Defined as:

    multi method elems(::?CLASS:U $self is rw: --> 0)
    multi method elems(::?CLASS:D:)

Returns the number of elements in the heap. Autovivifies because Rakudo defines
the number of elements in a type object as 1.

=head2 method extract

Defined as:

    method extract(\n? --> Seq:D)

Returns a C<Seq> that generates values by popping elements from the heap until
C<n> elements were extracted or the heap is empty. If no values are pushed onto
the heap before the C<Seq> is exhausted, the sequence will be in non-decreasing
order if called on a I<min-heap>, and in non-increasing order if called on a
I<max-heap>.

=head2 method gist

Defined as:

    multi method gist(::?CLASS:D:)

Returns the gist of the array underlying the heap.

=head2 method new

Defined as:

    method new(+values, Bool() :$in-place --> ::?CLASS:D)

Constructs a new heap containing the provided values. If C<values> is a single,
non-itemized array, the C<:in-place> adverb causes the array to be heapified in
place. By default, an array is cloned before heapification. In either case, the
array's type constraint applies to all elements in the heap.

=head2 method of

Defined as:

    method of()

Returns the type constraint for the elements in the heap. Returns C<Mu> by
default, but a heap can be constrained to a specific element type by calling
C<.new> with a type-constrained array.

=head2 method pop

Defined as:

    method pop()

Removes the element at the top of the heap and returns it, or returns a
C<Failure> if the heap is empty.

=head2 method push

Defined as:

    method push(**@values --> ::?CLASS:D)

Inserts the provided values into the heap and returns the modified heap.
Autovivifies an uninitialized invocant.

=head2 method push-pop

Defined as:

    method push-pop(Mu \value)

Functionally equivalent to, but more efficient than C<.push(value)> followed by
C<.pop>. Replaces the top of the heap if its priority tops that of the provided
value; otherwise returns the C<value> self.

=head2 method raku

Defined as:

    multi method raku(::?CLASS:D:)

Returns a string representation of the heap that can be C<EVAL>ed to reconstruct
the heap, provided it belongs to a named class. Used to compare the structural
equivalence of heaps when the exported C<&infix:eqv> candidate is not in scope.

=head2 method replace

Defined as:

    method replace(Mu \new)

Functionally equivalent to, but more efficient than C<.pop> followed by
C<.push(new)>. Replaces the element at the top of the heap with the C<new> value
and returns the old value.

=head2 method top

Defined as:

    method top()

Returns the element stored at the top of the heap, or C<Nil> if the heap is
empty.

=head2 method values

Defined as:

    multi method values(::?CLASS:D: --> Seq:D)

Returns a C<Seq> of the elements encountered during a breadth-first traversal of
the heap.

=head1 SEE ALSO

=item L<Binary heap - Wikipedia|https://en.wikipedia.org/wiki/Binary_heap>

=item L<Heapsort - Wikipedia|https://en.wikipedia.org/wiki/Heapsort>

=item L<Raku's built-in C<sort> routine|https://docs.raku.org/routine/sort>

=head1 AUTHOR

Peter du Marchie van Voorthuysen

Source can be located at: https://github.com/dumarchie/raku-binaryheap

=head1 COPYRIGHT AND LICENSE

Copyright 2022-2026 Peter du Marchie van Voorthuysen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
