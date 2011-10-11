#!/usr/bin/perl
#######################################
#Dieses Programm berechnet die Autokorrelation einer Geschwindigkeit 
#
######################################
open (IN, "$ARGV[0]");
@in = <IN>;
close (IN);

open (OUT, ">msd_$ARGV[0]");

$lines = $#in;
print "lines: $lines\n";
$min_intervalls = 2;
print "min_intervalls: $min_intervalls\n";
$max_size = int(($lines+1)/$min_intervalls);
print "max_size: $max_size\n";
$t_max = $lines - $max_size;
print "t_max: $t_max\n";

@temp1=split (/\s+/, $in[0]);
@temp2=split (/\s+/, $in[1]);
$delta_t=$temp2[0]-$temp1[0];

for($tau=0;$tau<=$max_size;$tau++){
	$sum=0;
	$counter=0;
	for($t=0;$t<=$t_max;$t+=($tau>0?$tau:1)){
		($teil, $x1, $y1, $z1) = split (/\s+/, $in[$t]);
		($teil, $x2, $y2, $z2) = split (/\s+/, $in[$t+$tau]);
		$sum+=($x2-$x1)**2+($y2-$y1)**2+($z2-$z1)**2;
    $counter++;
	}
  $av=$sum/$counter;
  $tau2=$tau*$delta_t;
	print OUT "$tau2\t$av\n";

}




