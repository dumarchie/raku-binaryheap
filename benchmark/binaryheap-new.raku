use BinaryHeap <GenHeap>;

my \n = 2**19;
srand(42); # make roll reproducible

my @values = (^n).roll(n);
say "Last value: {@values.tail}"; # reifies

my $time = now;
my $heap = GenHeap.new(@values);
$time = now - $time;

printf "Create heap from array with %d values: %0.2fms\n", n, $time * 1000;
