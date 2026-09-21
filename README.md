NAME
====

BinaryHeap - Array-based binary heap supporting heapsort

SYNOPSIS
========

```raku
use BinaryHeap;

my BinaryHeap::MinHeap $heap;
$heap.push(42, 11);
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

*Deprecated:* these classes are parameterizable with a custom three-way comparison operator. For example, the following code constrains lexical variable `$heap` to a *max-heap* that compares objects by their `.key`:

    my BinaryHeap::MaxHeap[*.key cmp *.key] $heap;

This parameterization is deprecated because it relies on Rakudo-specific internals. There are two alternatives for defining a `BinaryHeap` with a custom comparator. The first is to define a custom class, for example:

    my class MaxHeap does BinaryHeap[*.key cmp *.key == More] {}

A concise alternative is to use a dynamic object factory:

    my $max-heap = max-heap(*.key cmp *.key);

An uninitialized `BinaryHeap` is a valid representation of an empty heap. This means that all public methods can be called on a type object. Methods that may add values to the heap autovivify an uninitialized invocant, which means they can only be called on a *container* that stores or defaults to a *class* type. For example:

    my MaxHeap $heap;
    say $heap.values;      # OUTPUT: «()␤»
    say $heap.replace(42); # OUTPUT: «Nil␤»
    say $heap.top;         # OUTPUT: «42␤»

EXPORTS
=======

    use BinaryHeap :heapsort, :max-heap, :min-heap

Module `BinaryHeap` exports useful subroutines from the `BinaryHeap::Utils` package. Apart from the mandatory `infix:<eqv>` export, they can be accessed by fully qualified name when importing the short name is inconvenient.

infix eqv
---------

Defined as:

    multi sub infix:<eqv>(BinaryHeap \a, BinaryHeap \b --> Bool:D)

Returns `True` if and only if the two heaps are of the same type and contain equivalent [values](#method_values). Note that a class is a different type than a role, so `BinaryHeap.new eqv BinaryHeap` returns `False`, not because role `BinaryHeap` is undefined, but because `BinaryHeap.new` returns an instance of a *class* with the same name as the role.

sub heapsort
------------

Defined as:

    proto sub heapsort(|) is export(:DEFAULT, :heapsort)
    multi sub heapsort(@array, :$reverse)
    multi sub heapsort(&comparator, @array, :$reverse)

Sorts and returns the `@array`, using a custom three-way `&comparator` if provided. By default the array is sorted in ascending order, but it is sorted in descending order if `:$reverse` is true. Hence, the following statements both put the elements of the array in descending order:

    heapsort @array, :reverse;
    heapsort -(* cmp *), @array;

Note that `heapsort` is not a [stable sort](https://en.wikipedia.org/wiki/Sorting_algorithm#Stability).

sub max-heap
------------

Defined as:

    proto sub max-heap(| --> BinaryHeap:D) is export(:max-heap)
    multi sub max-heap(@values?)
    multi sub max-heap(&infix:<cmp>, @values?)

Returns a standard `BinaryHeap::MaxHeap` instance if called without a comparator. Otherwise returns a custom `BinaryHeap[* cmp * == More]` instance. The provided values are stored on the heap.

sub min-heap
------------

Defined as:

    proto sub min-heap(| --> BinaryHeap:D) is export(:min-heap)
    multi sub min-heap(@values?)
    multi sub min-heap(&infix:<cmp>, @values?)

Returns a standard `BinaryHeap::MinHeap` instance if called without a comparator. Otherwise returns a custom `BinaryHeap[* cmp * == Less]` instance. The provided values are stored on the heap.

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

method consume
--------------

Defined as:

    method consume( --> Seq:D)

Returns a `Seq` that generates values by removing them from the top of the heap. If no values are inserted into the heap before the `Seq` is exhausted, the values will be in ascending order if called on a *min-heap*, in descending order if called on a *max-heap*.

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

method sort
-----------

Defined as:

    method sort()

Returns an empty `Array` if called on an uninitialized heap. Otherwise sorts the underlying array in descending order if called on a *min-heap*, in ascending order if called on a *max-heap*. Replaces the underlying array with an empty copy and returns the sorted array.

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

  * [Heapsort - Wikipedia](https://en.wikipedia.org/wiki/Heapsort)

  * [Raku's built-in `sort` routine](https://docs.raku.org/routine/sort), which is faster than a [`heapsort`](#sub_heapsort) on Rakudo.

AUTHOR
======

Peter du Marchie van Voorthuysen

Source can be located at: https://github.com/dumarchie/raku-binaryheap

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Peter du Marchie van Voorthuysen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

