use BinaryHeap <GenHeap>;

my \n    = 2**16;
my $heap = GenHeap.new: (^n).roll(n);
my $time = now;
for ^n {
    $heap.pop;
}
$time = now - $time;

printf "Pop value from heap (n = %d): %0.2fms\n", n, $time * 1000;
