use BinaryHeap <MinHeap>;

constant n = 2**19;

sub heap($type) {
    do given $type {
        when Str:U { MinHeap               }
        when 'Mu'  { MinHeap.new           }
        when 'Int' { MinHeap.new(my Int @) } 
        when 'int' { MinHeap.new(my int @) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub input(\n) {
    srand(42); # make roll reproducible
    my \values = (^n).roll(n);
    values.elems; # reifies
    return values;
}

sub MAIN(Int $n = n, Str :$array-of) {
    my $heap = heap($array-of);
    my \values = input($n);
    print "Push $n values: onto a heap: ";

    my $time = now;
    $heap.push($_) for values;
    $time = now - $time;

    printf "%0.2fms\n", $time * 1000;
}
