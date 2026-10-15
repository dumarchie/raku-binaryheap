use BinaryHeap <MinHeap>;

my \n    = 2**16;
my $heap = MinHeap.new: (^n).roll(n);
my $time = now;
$heap.extract;
$time = now - $time;

printf "Consume all values from a heap (n = %d): %0.2fms\n", n, $time * 1000;
