use lib 'lib';
use BinaryHeap;

my \n      = 2**19;
my \values = (^n).roll(n);

my $time = now;
my $heap = BinaryHeap.new(values);
$time = now - $time;

printf "Create heap with multiple values (n = %d): %0.2fms\n", n, $time * 1000;
