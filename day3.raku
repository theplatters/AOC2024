my $contents = "input3.txt".IO.slurp;
my regex mul {'mul('\d+','\d+')'}
my @matches = $contents.comb(&mul);

grammar Calculator {
    token TOP { <calc-op> }

    proto rule calc-op          {*}
          rule calc-op:sym<mul> { 'mul('<num>','<num>')'}

    token num { \d+ }
}

class Calculations {
    method TOP              ($/) { make $<calc-op>.made; }
    method calc-op:sym<mul> ($/) { make [*] $<num>; }
}

my $sum = 0;
for @matches {
  $sum += Calculator.parse($_, actions => Calculations).made;
}

put $sum;

# =============================
#          Part 2
# =============================
my $active = True;

grammar BetterCalculator{
    token TOP { <command> }
    proto token command {*}  # Dispatch for commands
    token command:sym<activate> { 'do()' }
    token command:sym<deactivate> { 'don\'t()' }
    token command:sym<mul> { 'mul('<num>','<num>')' }
    token num { \d+ }
}

class BetterCalculations {
    method TOP              ($/) { make $<command>.made; }
    method command:sym<mul> ($/) {if $active {make [*] $<num>;} else {make 0;} }
    method command:sym<activate> ($/) {$active = True; make 0;}
    method command:sym<deactivate> ($/) {$active = False; make 0;}
}

my token do {'do'
['n\'t']?
'()'
}
my regex fil {<mul> | <do>} 

my @matches2 = $contents.comb(&fil);
put @matches2;
my $part2 = 0;

my $calc = BetterCalculations.new();
for @matches2 {
  my $result = BetterCalculator.parse($_, actions => $calc).made;
  if $result.defined {
    $part2 +=  $result;
  }
}

put $part2;
