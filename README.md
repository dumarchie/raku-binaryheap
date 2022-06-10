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

Infix `precedes` defines a priority relation, such that the root of the tree, known as the [top](#method_top) of the heap, has a priority higher than or equal to all other nodes of the tree. The default relation defines a *min heap*, i.e. the top value compares `Less` than or `Same` as every other value on the heap.

Module `BinaryHeap` provides two classes that mix in the role:

  * `class BinaryHeap::MaxHeap does BinaryHeap[* cmp * == More]`

    In a *max-heap*, a child node never compares [More](More) than its parent node.

  * `class BinaryHeap::MinHeap does BinaryHeap[* cmp * == Less]`

    In a *min-heap*, a child node never compares [Less](Less) than its parent node.

These classes are parameterizable with a custom comparison routine. For example, this max-heap compares objects by their `.key`:

    my BinaryHeap::MaxHeap[*.key cmp *.key] $heap;

METHODS
=======

method Bool
-----------

Defined as:

    multi method Bool(BinaryHeap:D: --> Bool:D)

Returns `True` if the heap contains at least one node, and `False` if the heap is empty.

method new
----------

Defined as:

    method new(+values --> BinaryHeap:D)

Creates a new heap instance. The provided values are stored in heap order.

method pop
----------

Defined as:

    method pop(BinaryHeap:D:) is nodal

Removes the value stored at the [top](#method_top) of the heap and returns it, or returns a `Failure` if the heap is empty.

method push
-----------

Defined as:

    method push(**@values is raw --> BinaryHeap:D)

Inserts the provided values into the heap and returns the modified heap. Autovivifies the invocant if called on a container storing or defaulting to a class type object. For example:

    my BinaryHeap::MaxHeap $heap;
    $heap.push(42, 11);
    say $heap.pop; # OUTPUT: «42␤»
    say $heap.top; # OUTPUT: «11␤»

method push-pop
---------------

Defined as:

    method push-pop(BinaryHeap:D: Mu \value)

Functionally equivalent, but more efficient than a [push](#method_push) followed by a [pop](#method_pop). [Replaces the top](#method_replace) of the heap if it precedes the provided value; otherwise returns the provided value.

method replace
--------------

Defined as:

    method replace(BinaryHeap:D: Mu \new)

Functionally equivalent, but more efficient than a [pop](#method_pop) followed by a [push](#method_push). Replaces the [top](#method_top) of the heap with the new value and returns the old value, or `Nil` if the heap was empty.

method top
----------

Defined as:

    method top(BinaryHeap:D:)

Returns the value stored at the top of the heap, or `Nil` if the heap is empty.

method values
-------------

    multi method values(BinaryHeap:D: --> Seq:D)

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

