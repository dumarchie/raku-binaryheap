use BinaryHeap <&heapsort>;

constant n = 2**16;

sub input(\n, $type) {
    srand(42); # make roll reproducible
    my \seq = (^n).roll(n);
    my \values = do given $type {
        when Str:U { seq.list       }
        when 'Mu'  { seq.Array      }
        when 'Int' { my Int @ = seq } 
        when 'int' { my int @ = seq }
        die "Array must be of type Mu|Int|int; array of $type is not supported";
    }

    values.elems; # reifies
    return values;
}


sub MAIN(Int $n = n, Str :$array-of) {
    my \values = input($n, $array-of);
    print "Heapsort {values.^name} with $n elems: ";

    my $time = now;
    heapsort values;
    $time = now - $time;
    printf "%0.2fms\n", $time * 1000;
}
