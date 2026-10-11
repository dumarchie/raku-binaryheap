NAME
====

BinaryHeap - Array-based binary heap supporting heapsort

SYNOPSIS
========

    use BinaryHeap <MinHeap>;

    my MinHeap $heap;
    $heap.push(11, 42);
    say $heap.pop; # OUTPUT: «11␤»
    say $heap.top; # OUTPUT: «42␤»

DESCRIPTION
===========

Module `BinaryHeap` implements a heap data structure and a (naïve) `heapsort` routine. The heap data structure is implemented by role `GenHeap`, which stores values in an implicit binary tree that satisfies the **heap property**: the value of a node never *precedes* the value of its parent node.

Module `BinaryHeap` provides two classes that do the `GenHeap` role using Raku's built-in three-way comparison operator: `MaxHeap` and `MinHeap`. It also provides `max-heap` and `min-heap` factory routines that accept a custom comparator, compose a class and return an instance of that class.

In many cases, an uninitialized `GenHeap` class can be manipulated as if it were an empty object instance. Methods that add values autovivify the heap, which means they can only be called on a *container*. For example:

    my MinHeap $heap;
    say $heap.values;      # OUTPUT: «()␤»
    say $heap.replace(42); # OUTPUT: «Nil␤»
    say $heap.top;         # OUTPUT: «42␤»

EXPORTS
=======

    use BinaryHeap <GenHeap &heapsort>;

Apart from the mandatory `&infix:<eqv>` candidate, the following symbols in the `BinaryHeap` namespace are all exported by default. To import specific symbols only, provide a list of symbol names to `use`.

role GenHeap
------------

    role GenHeap[&infix:<precedes>] {

Implements the heap data structure. Infix `precedes` defines the heap invariant: no child node has a value that precedes the value of its parent. See the implementations of `MaxHeap` and `MinHeap` for examples.

class MaxHeap
-------------

    class MaxHeap does GenHeap[* cmp * == More] {}

A *max-heap* that uses Raku's built-in `infix:<cmp>`.

class MinHeap
-------------

    class MinHeap does GenHeap[* cmp * == Less] {}

A *min-heap* that uses Raku's built-in `infix:<cmp>`.

infix eqv
---------

Defined as:

    multi sub infix:<eqv>(GenHeap \a, GenHeap \b --> Bool:D)

Returns `True` if and only if the two heaps are of the same type and contain equivalent [values](#method_values). Note that a class is a different type than a role, so `GenHeap.new eqv GenHeap` returns `False`, not because role `GenHeap` is undefined, but because `GenHeap.new` returns an instance of a *class* with the same name as the role.

sub heapsort
------------

Defined as:

    proto sub heapsort(|)
    multi sub heapsort(@array, :$reverse)
    multi sub heapsort(&comparator, @array, :$reverse)

Sorts and returns the `@array`, using a custom three-way `&comparator` if provided. By default the array is sorted in ascending order, but it is sorted in descending order if `:$reverse` is true. Hence, the following statements both put the elements of the array in descending order:

    heapsort @array, :reverse;
    heapsort -(* cmp *), @array;

Note that `heapsort` is not a [stable sort](https://en.wikipedia.org/wiki/Sorting_algorithm#Stability).

sub max-heap
------------

Defined as:

    proto sub max-heap(|)
    multi sub max-heap(@values?)
    multi sub max-heap(&infix:<cmp>, @values?)

Returns a custom `GenHeap[* cmp * == More]` instance if called with a comparator. The provided values are stored on the heap.

The candidate that uses the default `&infix:<cmp>` is *deprecated* as it is just syntactic sugar for `BinaryHeap::MaxHeap.new`.

sub min-heap
------------

Defined as:

    proto sub min-heap(|)
    multi sub min-heap(@values?)
    multi sub min-heap(&infix:<cmp>, @values?)

Returns a custom `GenHeap[* cmp * == Less]` instance if called with a comparator. The provided values are stored on the heap.

The candidate that uses the default `&infix:<cmp>` is *deprecated* as it is just syntactic sugar for `BinaryHeap::MinHeap.new`.

METHODS
=======

This section documents the methods provided by role `GenHeap`.

method Bool
-----------

Defined as:

    multi method Bool(::?CLASS:D: --> Bool:D)

Returns `True` if the heap contains at least one value, and `False` if the heap is empty.

method clone
------------

Defined as:

    multi method clone(::?CLASS:D:)

Returns a clone of the heap.

method consume
--------------

Defined as:

    method consume( --> Seq:D)

Returns a `Seq` that generates values by removing them from the top of the heap. If no values are inserted into the heap before the `Seq` is exhausted, the values will be in ascending order if called on a *min-heap*, in descending order if called on a *max-heap*.

method elems
------------

Defined as:

    multi method elems(::?CLASS:D:)

Returns the number of values on the heap. 

method gist
-----------

Defined as:

    multi method gist(::?CLASS:D:)

Returns the gist of the array underlying the heap.

method heapify
--------------

Defined as:

    method heapify(@array --> ::?CLASS:D)

Constructs a new heap based on the *provided* array, whose elements are put in heap order. This method is *deprecated* because it breaks encapsulation; use `.new(@array)` to create a heap with a type constraint on elements.

method new
----------

Conceptually defined as:

    method new(+values --> ::?CLASS:D)

Constructs a new heap storing the provided values. If values are provided as a single, non-itemized array, the type constraint of the array applies to all values on the heap.

method of
---------

Defined as:

    method of()

Returns the type constraint for the values on the heap. Returns `Mu` by default, but a heap can be constrained to a specific element type by calling `.new` with a type-constrained array.

method pop
----------

Defined as:

    method pop()

Removes the value stored at the [top](#method_top) of the heap and returns it, or returns a `Failure` if the heap is empty.

method push
-----------

Conceptually defined as:

    method push(**@values --> ::?CLASS:D)

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

method raku
-----------

Defined as:

    multi method raku(::?CLASS:D:)

Returns a string representation of the heap that can be `EVAL`ed to reconstruct the heap, provided it belongs to a named class. Used to compare the structural equivalence of heaps when the exported `&infix:eqv` candidate is not in scope.

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

Copyright 2022-2026 Peter du Marchie van Voorthuysen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

