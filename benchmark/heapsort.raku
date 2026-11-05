use BinaryHeap <&heapsort>;

constant n-unique = 2**16;

sub values($size, $type) {
    my \values = (^n-unique).roll($size);
    eager given $type {
        when Str:U { values            }
        when 'Mu'  { my @ = values     }
        when 'Int' { my Int @ = values } 
        when 'int' { my int @ = values }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }
}

sub MAIN(Int $n = n-unique, Str :$array-of) {
    srand(42); # make roll reproducible

    my \values = values($n, $array-of);
    print "Heapsort {values.^name} with $n elems: ";

    my $start = now;
    heapsort values;
    printf "%0.2fms\n", (now - $start) * 1000;
}
