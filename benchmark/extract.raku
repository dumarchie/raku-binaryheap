use BinaryHeap <MinHeap>;

constant size = 2**16;

sub heap($size, $type) {
    my \values = (^$size).roll($size);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $size = size, Int $n?, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible

    my &run;
    my $heap = heap($size, $array-of);
    if $n.defined {
        print "Extract up to $n values from a heap with $size elems: ";
        &run = { $heap.extract($n) };
    }
    else {
        print "Extract all values from a heap with $size elems: ";
        &run = { $heap.extract };
    }

    my $start = now;
    run();
    printf "%0.2fms\n", (now - $start) * 1000;
}
