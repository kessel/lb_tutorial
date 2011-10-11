#!/usr/bin/perl
#######################################
# This program calculates the autocorrelation function
# for each column of the input file. The first
# column is taken as time coordinate
#
######################################
open (IN, "$ARGV[0]");
@in = <IN>;
close (IN);

open (OUT, ">", "acf_$ARGV[0]");

$lines = $#in;
print "lines: $lines\n";
@temp1 = split (/\s+/, $in[0]);
@temp2 = split (/\s+/, $in[1]);
$columns=$#temp1+1;
print "$columns\n";
$min_samples = 10;
print "min_intervalls: $min_intervalls\n";
$max_size = int(($lines)/$min_samples);
print "max_size: $max_size\n";
$t_max = $lines - $max_size;
print "t_max: $t_max\n";
$delta_t= $temp2[0] - $temp1[0];

for($tau=0;$tau<=$max_size;$tau++){
  print "$tau\n";
	@sum=((0.) x ($columns-1));
	@av=((0.) x ($columns-1));
  print "@sum";
	$counter=0;
	for($t=0;$t<=$t_max;$t+=($tau>0?$tau:1)){
		@former = split (/\s+/, $in[$t]);
		@later = split (/\s+/, $in[$t+$tau]);
    for ($i=1; $i < $columns; $i++) { 
   		$sum[$i-1]+=$former[$i]*$later[$i];
    }
    $counter++;
	}
  for ($i=1; $i < $columns; $i++) { 
  	$av[$i-1]+=$sum[$i-1]/$counter;
  }
  $tau2=$tau*$delta_t;
	print "$tau2 @av\n";
	print OUT "$tau2 @av\n";
}




