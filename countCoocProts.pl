#!/usr/bin/perl
use strict;
use warnings"all";

my @classes = sort("Eac","Eme","Eub","Rac","Rme","Rph","Wac","Wme","Wph","Wub");

my %occu;
my %cooc;

for(my $i = 0; $i < scalar@classes; $i++){
    my $cl1 = $classes[$i];
    $occu{$cl1} = 0;
    for(my $j = $i+1; $j < scalar@classes; $j++){
	my $cl2 = $classes[$j];
	$cooc{$cl1."_".$cl2} = 0;
    }
}

my $file = $ARGV[0];
my $out = $ARGV[1];

open(IN,"<",$file);
while(<IN>){
    chomp;
    my @f = split(/\t/);
    my $pcls = $f[1];
    $pcls =~ s/:[0-9]+//g;
    my @pclasses = sort(split(/,/,$pcls));
    for(my $i = 0; $i < scalar@pclasses; $i++){
	$occu{$pclasses[$i]}++;
	for(my $j = $i+1; $j < scalar@pclasses; $j++){
	    $cooc{$pclasses[$i]."_".$pclasses[$j]}++;
	    
	}
    }
}
close(IN);


open(OUT,">",$out);
print OUT "class/class_combi\tcounts\n";
foreach my $coocc (keys %cooc){
    print OUT $coocc,"\t",$cooc{$coocc},"\n";
}

foreach my $occuc (keys %occu){
    print OUT $occuc,"\t",$occu{$occuc},"\n";
}
close(OUT);
