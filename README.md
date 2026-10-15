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

Module `BinaryHeap` implements a heap data structure and an (in-place) `heapsort` routine. The heap data structure is implemented by role `GenHeap`, which stores values in an implicit binary tree that satisfies the **heap property**: the value of a node never *precedes* the value of its parent node.

Module `BinaryHeap` provides two classes that do the `GenHeap` role using Raku's built-in three-way comparison operator: `MaxHeap` and `MinHeap`. It also provides `max-heap` and `min-heap` factory routines that accept a custom comparator, compose a class and return an instance of that class.

In many cases, an uninitialized heap can be manipulated as if it were an empty object instance. Methods that add values autovivify the heap, which means they can only be called on a *container*. For example:

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

Implements the heap data structure. Infix `precedes` defines the heap invariant: no child node has a value that precedes the value of its parent. See below implementations of `MaxHeap` and `MinHeap` for examples.

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

Returns `True` if and only if the two heaps are of the same type and contain equivalent [values](#method_values).

sub heapsort
------------

Defined as:

    proto sub heapsort(|)
    multi sub heapsort(@values, Bool() :$reverse)
    multi sub heapsort(&comparator, @values, Bool() :$reverse)

Sorts the values in-place and returns the array if `@values` is an array; otherwise sorts and returns a new `Array`. Values are sorted using the provided three-way `&comparator` or Raku's built-in `&infix:<cmp>`. 

To sort in descending order, use the `:reverse` adverb or negate the result of `&comparator`. For example, the following statements both put the values in descending order:

    heapsort @values, :reverse;
    heapsort -(* cmp *), @values;

Note that `heapsort` is not a [stable sort](https://en.wikipedia.org/wiki/Sorting_algorithm#Stability).

sub max-heap
------------

Defined as:

    sub max-heap(&infix:<cmp>, +values, Bool() :$in-place)

Returns a custom `GenHeap[* cmp * == More]` instance storing the provided values. If `values` is a single, non-itemized array, the `:in-place` adverb causes the array to be heapified in place. By default, an array is cloned before heapification.

sub min-heap
------------

Defined as:

    sub min-heap(&infix:<cmp>, +values, Bool() :$in-place)

Returns a custom `GenHeap[* cmp * == Less]` instance storing the provided values. If `values` is a single, non-itemized array, the `:in-place` adverb causes the array to be heapified in place. By default, an array is cloned before heapification.

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

method new
----------

Defined as:

    method new(+values, Bool() :$in-place --> ::?CLASS:D)

Constructs a new heap containing the provided values. If `values` is a single, non-itemized array, the `:in-place` adverb causes the array to be heapified in place. By default, an array is cloned before heapification. In either case, the array's type constraint applies to all values in the heap.

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

Defined as:

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

  * [Raku's built-in `sort` routine](https://docs.raku.org/routine/sort)

AUTHOR
======

Peter du Marchie van Voorthuysen

Source can be located at: https://github.com/dumarchie/raku-binaryheap

COPYRIGHT AND LICENSE
=====================

Copyright 2022-2026 Peter du Marchie van Voorthuysen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

