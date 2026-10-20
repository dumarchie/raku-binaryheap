use BinaryHeap <MinHeap>;

constant n = 2**19;

sub input(\n, \of) {
    srand(42); # make roll reproducible
    my \seq = (^n).roll(n);
    given of {
        when 'Int' { my Int @ = seq } 
        when 'int' { my int @ = seq }
        default { seq.list }
    }
}

sub MAIN(Int $n = n, Str :$type, Bool :$in-place) {
    my \values = input($n, $type);
    print "Heapify {values.^name} with {values.elems} elems: ";

    my $time = now;
    my $heap = MinHeap.new(values, :$in-place);
    $time = now - $time;
    printf "%0.2fms\n", $time * 1000;
}
