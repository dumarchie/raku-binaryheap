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

Module `BinaryHeap` implements a heap data structure and an (in-place) `heapsort` routine. The heap data structure is implemented by role `GenHeap`, which stores values in an implicit binary tree that satisfies the **heap property**: the priority of a node never *tops* the priority of its parent. The priority of the element at the top of a heap is greater than or equal to the priority of all other elements in a *max-heap*, and less than or equal to the priority of all other elements in a *min-heap*.

Module `BinaryHeap` provides two classes that do the `GenHeap` role using Raku's built-in three-way comparison operator: `MaxHeap` and `MinHeap`. These heaps do not distinguish between a heap element and its priority. The dynamic `max-heap` and `min-heap` factories accept a custom comparator that may define an element's priority differently.

An uninitialized heap can be manipulated as if it were an empty heap instance. Methods that add values autovivify an uninitialized heap. For example:

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

    role GenHeap[&infix:<tops>] does Iterable { }

Implements the heap data structure. Infix `tops` defines the heap invariant: no child node has a priority that tops the priority of its parent. See the implementations of `MaxHeap` and `MinHeap` for examples.

class MaxHeap
-------------

    class MaxHeap does GenHeap[* cmp * == More] { }

A *max-heap* that uses Raku's built-in `infix:<cmp>` to compare the priority of elements.

class MinHeap
-------------

    class MinHeap does GenHeap[* cmp * == Less] { }

A *min-heap* that uses Raku's built-in `infix:<cmp>` to compare the priority of elements.

infix eqv
---------

Defined as:

    multi sub infix:<eqv>(GenHeap \a, GenHeap \b --> Bool:D)

Returns `True` if and only if the two heaps are of the same type and contain equivalent elements at each position.

sub heapsort
------------

Defined as:

    proto sub heapsort(|)
    multi sub heapsort(@values, Bool() :$reverse)
    multi sub heapsort(&comparator, @values, Bool() :$reverse)

Sorts the elements in-place and returns the array if `@values` is an array; otherwise sorts and returns the elements of a new `Array`. Values are sorted using the provided three-way `&comparator` or Raku's built-in `&infix:<cmp>`.

To sort in descending order, use the `:reverse` adverb or negate the result of `&comparator`. For example, the following statements both return values in descending order:

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

Returns `True` if the heap contains at least one element, and `False` if the heap is empty.

method clone
------------

Returns a clone of the heap.

method elems
------------

Returns the number of elements in the heap.

method extract
--------------

Defined as:

    method extract($n? --> Seq:D)

Returns a `Seq` that generates values by popping elements from the heap until `$n` elements were extracted or the heap is empty. If no values are pushed onto the heap before the `Seq` is exhausted, the sequence will be in non-decreasing order if called on a *min-heap*, and in non-increasing order if called on a *max-heap*.

method gist
-----------

Returns the gist of the heap.

method iterator
---------------

Returns an iterator that produces the elements encountered in a breadth-first traversal of the heap.

method list
-----------

Returns the elements encountered during a breadth-first traversal of the heap.

method merge
------------

Defined as:

    method merge(+values --> ::?CLASS:D)

Merges the provided values into the heap and returns the modified heap. Autovivifies an uninitialized heap.

method new
----------

Defined as:

    method new(+values, Bool() :$in-place --> ::?CLASS:D)

Constructs a new heap containing the provided values. If `values` is a single, non-itemized array, the `:in-place` adverb causes the array to be heapified in place. By default, an array is cloned before heapification. In either case, the array's type constraint applies to all elements in the heap.

method of
---------

Returns the type constraint for the elements in the heap. Returns `Mu` by default, but a heap can be constrained to a specific element type by calling `.new` with a type-constrained array.

method pop
----------

Removes the element at the top of the heap and returns it, or returns a `Failure` if the heap is empty.

method push
-----------

Defined as:

    method push(**@values --> ::?CLASS:D)

Inserts the provided values into the heap and returns the modified heap. Autovivifies an uninitialized heap.

method push-pop
---------------

Defined as:

    method push-pop(Mu \value)

Functionally equivalent to, but more efficient than `.push(value)` followed by `.pop`. Replaces the top of the heap if its priority tops that of the provided `value`; otherwise just returns the provided `value`.

method raku
-----------

Returns a string representation of the heap that can be `EVAL`ed to reconstruct the heap, provided it belongs to a named class. Used to compare the structural equivalence of heaps when the exported `&infix:eqv` candidate is not in scope.

method replace
--------------

Defined as:

    method replace(Mu \new)

Functionally equivalent to, but more efficient than `.pop` followed by `.push(new)`. Replaces the element at the top of the heap with the `new` value and returns the old value. Returns `Nil` if called on an empty heap.

method top
----------

Returns the element stored at the top of the heap, or `Nil` if the heap is empty.

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

