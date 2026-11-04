use BinaryHeap <MinHeap>;

constant n = 2**19;

sub heap(\n, $type) {
    my \values = (^n).roll(n);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $n = n, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible

    my $heap = heap($n, $array-of);
    print "Traverse heap with $n elems: ";

    my $time = now;
    $heap.values;
    $time = now - $time;

    printf "%0.2fms\n", $time * 1000;
}
