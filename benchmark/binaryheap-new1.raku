use lib 'lib';
use BinaryHeap;

my \n    = 2**22;
my $time = now;
for ^n {
    BinaryHeap.new($_);
}
$time = now - $time;

printf "Create single-element heap (n = %d): %0.2fms\n", n, $time * 1000;
