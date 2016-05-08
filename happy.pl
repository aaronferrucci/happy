#perl -w
use strict;
use warnings;

my $seen = {};

sub step($)
{
  my ($n) = @_;
  my @digits = split(//, $n);
  my $sum = 0;
  for my $digit (@digits) {
    $sum += $digit ** 2;
  }
  return $sum;
}

sub _transform($$$);
sub _transform($$$)
{
  my ($n, $iters, $nums) = @_;
  push @$nums, $n;
  
  if ($iters > 20) {
    return $nums;
  }

#  if (defined $seen->{$n}) {
#    # We've seen it before. Nothing to do further.
#    return $nums;
#  }

  # First time we've seen this number? Remember and continue.
  $seen->{$n} = 1;
  my $next = step($n);
  return _transform($next, $iters + 1, $nums);
}

sub transform($)
{
  my ($n) = @_;
  return _transform($n, 0, [])
}

my $results = [];
for my $i (1 .. 1000) {
  $results->[$i] = transform($i);
}

print << 'EOT';
digraph G {
  graph [maxdist="18.000" bgcolor=black];
  node [fixedsize=true shape=circle];
EOT

my $edges = {};
my $happy = {};
for my $i (1 .. @$results - 1) {
  my @path = @{$results->[$i]};
  my $is_happy = grep {$_ == 1} @path;
  my $color = $is_happy ? "green" : "red";
  map {$happy->{$_} = $is_happy} @path;

  if (@path > 1) {
    for my $j (1 .. $#path) {
      $edges->{"  $path[$j - 1] -> $path[$j] [color=$color];\n"} = 1;
    }
  }
}

for my $node (sort {$a <=> $b} keys %$seen) {
  my $color = $happy->{$node} ? "green" : "red";
  print "  $node [color=$color, dist=\"10.000\", fontcolor=$color, fontname=\"Times-Bold\", shape=circle, style=bold];\n";
}

for my $edge (keys %$edges) {
  print $edge;
}
  
print "}\n";

