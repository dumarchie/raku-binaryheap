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

sub MAIN(Int $size = size, Int $n = size, Str :$array-of = 'Mu') {
    srand(42); # make roll reproducible

    my $heap = heap($size, $array-of);
    my \new = eager (^$size).roll($n);
    print "Replace $n times the top of a heap with $size elems: ";

    my $start = now;
    $heap.replace($_) for new;
    printf "%0.2fms\n", (now - $start) * 1000;
}
