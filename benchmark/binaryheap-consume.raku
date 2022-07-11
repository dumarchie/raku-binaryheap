use lib 'lib';
use BinaryHeap;

my \n    = 2**16;
my $heap = BinaryHeap.new: (^n).roll(n);
my $time = now;
$heap.consume;
$time = now - $time;

printf "Consume all values from a heap (n = %d): %0.2fms\n", n, $time * 1000;
