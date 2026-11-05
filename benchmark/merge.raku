use BinaryHeap <MinHeap>;

constant n-unique = 2**16;
constant n = 2**19;

sub values($n) {
    (^n-unique).roll($n);
}

sub heap($size, $type) {
    my \values = values($size);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $n = n, Int $m = n, Str :$array-of = 'Mu', Bool() :$with-heap) {
    srand(42); # make roll reproducible
    
    my $heap = heap($n, $array-of);
    my \values = $with-heap ?? heap($m, $array-of) !! values($m);
    print "Merge {values.^name} with $m elems into a heap with $n elems: ";

    my $start = now;
    $heap.merge(values);
    printf "%0.2fms\n", (now - $start) * 1000;
}
