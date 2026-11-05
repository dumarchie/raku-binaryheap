use BinaryHeap <MinHeap>;

constant n-unique = 2**16;
constant n = 2**19;

sub heap($size, $type) {
    my \values = (^n-unique).roll($size);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $size = n, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible
    
    my $heap = heap($size, $array-of);
    print "Traverse heap with $size elems: ";

    my $start = now;
    $heap.values;
    printf "%0.2fms\n", (now - $start) * 1000;
}
