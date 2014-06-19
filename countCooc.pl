#!/usr/bin/perl
use strict;
use warnings"all";

my @classes = ("Eac","Eme","Eub","Rac","Rme","Rph","Wac","Wme","Wph","Wub");
my %rawco;
my %rawoc;
foreach my $cl1 (@classes){
    $rawoc{$cl1} = 0;
    foreach my $cl2 (@classes){
	$rawco{$cl1}->{$cl2} = 0
    }
}

my $file = $ARGV[0];
my %prots;
open(CLASS,"<",$file);
while(<CLASS>){
    chomp;
    my ($gene,@classes) = split;
    $prots{$gene} = 1;
    @classes = sort@classes;
    my %doms;
    foreach my $class (@classes){
	my ($clstr,$freq) = split(/:/,$class);
	my @cls = split(/,/,$clstr);
	foreach my $cl (@cls){
	    $doms{$cl} += $freq;
	}
    }
    my @keys = keys %doms;
    for(my $i = 0; $i < scalar@keys; $i++){
	$rawoc{$keys[$i]} += $doms{$keys[$i]};
	$rawco{$keys[$i]}->{$keys[$i]} += $doms{$keys[$i]}*($doms{$keys[$i]}-1);
    }
    for(my $i = 0; $i < scalar@keys; $i++){
	for(my $j = $i+1; $j < scalar@keys; $j++){
	    $rawco{$keys[$i]}->{$keys[$j]} +=  $doms{$keys[$i]}*$doms{$keys[$j]};
	}
    }
}
close(CLASS);
my $total = scalar(keys %prots);

for (my $i = 0; $i < scalar@classes; $i++){
    for(my $j = $i; $j < scalar@classes; $j++){
	print $classes[$i],"_",$classes[$j],"\t",$rawco{$classes[$i]}->{$classes[$j]},"\n";
	if($rawoc{$classes[$i]}*$rawoc{$classes[$j]} != 0){
	    print STDERR $classes[$i],"_",$classes[$j],"\t",$total * $rawco{$classes[$i]}->{$classes[$j]} / ($rawoc{$classes[$i]}*$rawoc{$classes[$j]}),"\n";
	}else{
	    print STDERR $classes[$i],"_",$classes[$j],"\tNA\n";
	}
	
    }
}
