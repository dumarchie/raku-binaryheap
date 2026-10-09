use BinaryHeap <GenHeap>;

my \n = 2**19;
srand(42); # make roll reproducible

my @values = (^n).roll(n);
say "Last value: {@values.tail}"; # reifies

# Base the heap on a native array for speedup
my $heap = GenHeap.new(my int @);

my $time = now;
$heap.push($_) for @values;
$time = now - $time;

printf "Push value onto heap (n = %d): %0.2fms\n", n, $time * 1000;
