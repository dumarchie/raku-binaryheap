use BinaryHeap <MinHeap>;

constant elems = 2**16;

sub heap($size, $type) {
    my \values = (^elems).roll($size);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $size = elems, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible

    my $heap = heap($size, $array-of);
    print "Pop all values from a heap with $size elems: ";

    my $start = now;
    $heap.pop for ^$size;
    printf "%0.2fms\n", (now - $start) * 1000;
}
