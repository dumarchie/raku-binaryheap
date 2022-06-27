use lib 'lib';
use BinaryHeap;

my \n     = 2**16;
my @array = (^n).roll(n);
@array.elems; # reifies

my $time = now;
heapsort @array;
$time = now - $time;

printf "Heapsort array (n = %d): %0.2fms\n", n, $time * 1000;
