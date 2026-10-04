use BinaryHeap;

my \n       = 2**19;
my @values  = (^n).roll(n);
my \reified = @values.elems;

my $time = now;
my $heap = BinaryHeap.new(@values);
$time = now - $time;

printf "Create heap from array with {reified} elems: %0.2fms\n", $time * 1000;
