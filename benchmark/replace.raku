use BinaryHeap <MinHeap>;

constant n-unique = 2**16;

sub heap($size, $type) {
    my \values = (^n-unique).roll($size);
    do given $type {
        when 'Mu'  { MinHeap.new(values)            }
        when 'Int' { MinHeap.new(my Int @ = values) } 
        when 'int' { MinHeap.new(my int @ = values) }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $size = n-unique, Int $n = n-unique, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible

    my $heap = heap($size, $array-of);
    my \new = eager (^n-unique).roll($n);
    print "Replace $n times the top of a heap with $size elems: ";

    my $start = now;
    $heap.replace($_) for new;
    printf "%0.2fms\n", (now - $start) * 1000;
}
