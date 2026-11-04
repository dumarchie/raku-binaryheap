use BinaryHeap <MinHeap>;

constant n = 2**16;

sub heap(\values, $type) {
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $n = n, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible

    my $m = ($n div 2) * 3;
    my $heap = heap((^$n).roll($m), $array-of);
    print "Pop $n values from a heap with $m elems: ";

    my $time = now;
    $heap.pop for ^$n;
    $time = now - $time;

    printf "%0.2fms\n", $time * 1000;
}
