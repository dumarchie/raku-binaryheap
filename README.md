NAME
====

BinaryHeap - Array-based binary heap

SYNOPSIS
========

```raku
use BinaryHeap;

my $heap = BinaryHeap.new(42, 11);
say $heap.pop; # OUTPUT: «11␤»
say $heap.top; # OUTPUT: «42␤»
```

DESCRIPTION
===========

    role BinaryHeap[&infix:<precedes> = * cmp * == Less] {}

Role `BinaryHeap` stores values in an implicit binary tree that satisfies the **heap property**: the value of a node never `precedes` the value of its parent node.

Infix `precedes` defines a priority relation, such that the root of the tree, known as the [top](#method_top) of the heap, has a priority higher than or equal to all other nodes of the tree. The default relation defines a *min-heap*, i.e. the top value compares `Less` than or `Same` as every other value on the heap.

Module `BinaryHeap` provides two classes that mix in the role:

  * `class BinaryHeap::MaxHeap does BinaryHeap[* cmp * == More]`

    In a *max-heap*, a child node never compares `More` than its parent node.

  * `class BinaryHeap::MinHeap does BinaryHeap[* cmp * == Less]`

    In a *min-heap*, a child node never compares `Less` than its parent node.

These classes are parameterizable with a custom three-way comparison operation. For example, this *max-heap* compares objects by their `.key`:

    my BinaryHeap::MaxHeap[*.key cmp *.key] $heap;

An uninitialized `BinaryHeap` is a valid representation of an empty heap. This means that all documented methods can be called on a type object. Methods that may add values to the heap try to autovivify an uninitialized invocant, which means they can only be called on a *container* that stores or defaults to a *class* type. For example, given the uninitialized `$heap` declared above:

    say $heap.values;      # OUTPUT: «()␤»
    say $heap.replace(42); # OUTPUT: «Nil␤»
    say $heap.top;         # OUTPUT: «42␤»

EXPORTS
=======

infix eqv
---------

Defined as:

    multi sub infix:<eqv>(BinaryHeap \a, BinaryHeap \b --> Bool:D)

Returns `True` if and only if the two heaps are of the same type and contain equivalent [values](#method_values). Note that a concrete heap is of a different type than a role, so:

    say BinaryHeap.new eqv BinaryHeap;                   # OUTPUT: «False␤»
    say BinaryHeap::MaxHeap.new eqv BinaryHeap::MaxHeap; # OUTPUT: «True␤»

METHODS
=======

method Bool
-----------

Defined as:

    method Bool( --> Bool:D)

Returns `True` if the heap contains at least one node, and `False` if the heap is empty.

method clone
------------

Defined as:

    multi method clone(BinaryHeap:D: --> BinaryHeap:D)

Returns a clone of the invocant. The clone is based on a distinct array, so modifications to one heap will not affect the other heap.

method heapify
--------------

Defined as:

    method heapify(@array --> BinaryHeap:D)

Constructs a new heap based on the provided array, whose elements are put in heap order. The `@array` should not be modified directly while the heap is in use.

method new
----------

Defined as:

    method new(+values --> BinaryHeap:D)

Constructs a new heap storing the provided values.

method pop
----------

Defined as:

    method pop()

Removes the value stored at the [top](#method_top) of the heap and returns it, or returns a `Failure` if the heap is empty.

method push
-----------

Defined as:

    method push(**@values --> BinaryHeap:D)

Inserts the provided values into the heap and returns the modified heap. Autovivifies the invocant if called on a container storing or defaulting to a class type object. For example:

    my BinaryHeap::MaxHeap $heap;
    $heap.push(42, 11);
    say $heap.pop; # OUTPUT: «42␤»
    say $heap.top; # OUTPUT: «11␤»

method push-pop
---------------

Defined as:

    method push-pop(Mu \value)

Functionally equivalent, but more efficient than a [push](#method_push) followed by a [pop](#method_pop). [Replaces the top](#method_replace) of the heap if it `precedes` the provided value; otherwise just returns the provided value.

method replace
--------------

Defined as:

    method replace(Mu \new)

Functionally equivalent, but more efficient than a [pop](#method_pop) followed by a [push](#method_push). Removes the [top](#method_top) of the heap and returns it after inserting the new value.

method top
----------

Defined as:

    method top()

Returns the value stored at the top of the heap, or `Nil` if the heap is empty.

method values
-------------

Defined as:

    method values( --> Seq:D)

Returns a `Seq` of the values encountered during a breadth-first traversal of the heap.

SEE ALSO
========

  * [Binary heap - Wikipedia](https://en.wikipedia.org/wiki/Binary_heap)

AUTHOR
======

Peter du Marchie van Voorthuysen

Source can be located at: https://github.com/dumarchie/raku-binaryheap

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Peter du Marchie van Voorthuysen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

