use BinaryHeap <MinHeap>;

constant m = 2**19;
constant n = 2**18;

sub roll(\n) {
    my \values = (^n).roll(n);
    values.elems; # reifies
    return values;
}

sub heap(\n, $type) {
    my \values = roll(n);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $n = n, Int $m = m, Str :$array-of = 'Mu', Bool() :$with-heap) {
    srand(42); # make roll reproducible
    
    my $heap = heap($n, $array-of);
    my &merge;
    if $with-heap {
        my \heap2 = heap($m, 'Mu'); # not itemized!
        &merge = { $heap.merge(heap2) };
        print "Merge heap with $m elems into a heap with $n elems: ";
    }
    else {
        my \values = roll($m);
        &merge = { $heap.merge(values) };
        print "Merge $m values into a heap with $n elems: ";
    }

    my $time = now;
    merge;
    $time = now - $time;

    printf "%0.2fms\n", $time * 1000;
}
