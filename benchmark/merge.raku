use BinaryHeap <MinHeap>;

# For stable performance:
# set MVM_SPESH_BLOCKING=1

constant m = 2**19;
constant n = 2**18;

sub roll(\n) {
    eager (^n).roll(n);
}

sub heap(\n, $type = 'Mu') {
    my \values = (^n).roll(n);
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
    my \values = $with-heap ?? heap($m) !! roll($m);
    print "Merge {values.^name} with $m elems into a heap with $n elems: ";

    my $time = now;
    $heap.merge(values);
    $time = now - $time;

    printf "%0.2fms\n", $time * 1000;
}
