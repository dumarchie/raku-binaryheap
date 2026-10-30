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

sub MAIN(Int $n = n, Int $m = m, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible
    
    my $heap = heap($n, $array-of);
    my \values = roll($m);
    print "Merge $m values into a heap with $n elems: ";

    my $time = now;
    $heap.merge(values);
    $time = now - $time;

    printf "%0.2fms\n", $time * 1000;
}
