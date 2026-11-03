use BinaryHeap <MinHeap>;

constant n = 2**16;

sub input(\n) {
    eager (^n).roll(n)
}

sub heap(\n, $type) {
    my \values = input(n);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $n = n, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible

    my \values = input($n);
    my $heap = heap($n, $array-of);
    print "Replace $n times the top of a heap with $n elems: ";

    my $time = now;
    $heap.replace($_) for values;
    $time = now - $time;

    printf "%0.2fms\n", $time * 1000;
}
