use BinaryHeap <MinHeap>;

constant n = 2**19;

sub heap(\n, $type) {
    srand(42); # make roll reproducible
    my \seq = (^n).roll(n);
    my \values = do given $type {
        when Str:U { seq.list       }
        when 'Mu'  { seq.Array      }
        when 'Int' { my Int @ = seq } 
        when 'int' { my int @ = seq }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
    return MinHeap.new(values, :in-place);
}

sub MAIN(Int $n = n, Str :$array-of) {
    my $heap = heap($n, $array-of);
    print "Traverse heap with $n elems: ";

    my $time = now;
    $heap.Seq;
    $time = now - $time;
    printf "%0.2fms\n", $time * 1000;
}
