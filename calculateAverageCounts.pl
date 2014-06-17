#!/usr/bin/perl
use warnings"all";
use strict;

sub calcAverages{
    my $dir = shift;
    print STDERR $dir,"\n";
    opendir(DIR,$dir);
    my @files = readdir(DIR);
    closedir(DIR);
    my %sums;
    $sums{"Eac"} = 0;
    $sums{"Eme"} = 0;
    $sums{"Eub"} = 0;
    $sums{"Rac"} = 0;
    $sums{"Rme"} = 0;
    $sums{"Rph"} = 0;
    $sums{"Wac"} = 0;
    $sums{"Wme"} = 0;
    $sums{"Wph"} = 0;
    $sums{"Wub"} = 0; 
    my $counter = 0;
    foreach my $file (@files){
	if($file =~ /^\./){next}
	unless(-d $dir."/".$file){next}
	
	#unless(-e $dir."/".$file."/avcounts"){
	calcAverages($dir."/".$file);
	#}
	$counter++;
	open(IN,"<",$dir."/".$file."/avcounts");
	<IN>;
	while(my $line = <IN>){
	    chomp($line);
	    my ($class,$count) = split(/\s+/,$line);
	    if(exists $sums{$class}){$sums{$class} += $count;}
	}
	close(IN);
    }
    if($counter > 0){
	open(OUT,">",$dir."/avcounts");
	print OUT "class\t$dir\n";
	foreach my $class (sort keys %sums){
	    print OUT $class,"\t",($sums{$class}/$counter),"\n";
	}
	close(OUT);
	
    }
}


my $base = $ARGV[0];

calcAverages($base);
