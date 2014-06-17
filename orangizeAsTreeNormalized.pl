#!/usr/bin/perl
use strict;
use warnings"all";

sub subset{
    my $pattern = shift;
    my @list  = @_;
    my @result = ();
    $pattern .= "_";
    #print STDERR "$pattern\n";
    foreach my $el (@list){
	if($el =~ /$pattern[A-Za-z0-9]+$/){push(@result,$el);}
    }
    return @result;
}


sub countgenes{
    my $file = shift;
    my %hash;
    print STDERR "FILE ",$file,"\n";
    open(IN,"<",$file);
    while(<IN>){
	chomp;
	my @line = split(/\t/);
	$hash{$line[0]} = 1;
    }
    close(IN);
    my $num = scalar(keys %hash);
    return $num;
}
# tree data 
my $texttree = $ARGV[0];

# input file data
my $specieslist = $ARGV[1];
my $filedir = $ARGV[2];
my $filedirpred = $ARGV[3];
my $suffix = $ARGV[4];
my $suffixpred = $ARGV[5];
my $namemapping = $ARGV[6];

# output file data
my $base = $ARGV[7];

# create tree data 2 input file data mapping
#load species list
open(SL,"<",$specieslist);
my @list = <SL>;
chomp(@list);
close(SL);


#create mapping with tree
my %mapping;
open(TREE,"<",$texttree);
while(<TREE>){
    chomp;
    $_ =~ s/\+ //g;
    my $specie = $_;
    $_ =~ s/ /_/g;
    #print STDERR $_,"\n";
    my @candidates = subset $_,@list;
    #print STDERR "$_ ====>",join(",",@candidates),"\n";
    if(scalar@candidates > 0){
	my $match = $candidates[-1];
	$mapping{$specie} = $match; 
	#print STDERR "$specie $match\n";
    }else{
	print STDERR $specie,"\n";
    }
}
close(TREE);

# load mapping correction
open(MAP,"<",$namemapping);
while(<MAP>){
    chomp;
    my ($tree,$file) = split(/\t/);
    $mapping{$tree} = $file;
    print STDERR  "additional map from $tree -> $file\n";
}
close(MAP);

# create directory structure and copy file and symlin to avcounts and mpcounts
system("rm -r $base/*");
open(TREE,"<",$texttree);
my @dirstructure = ();
while(<TREE>){
    chomp;
    my $index = ($_ =~ tr/\+//);
    $_ =~ s/(\+ )*//;
    my $dir = $_;
    $dir =~ s/\s/_/g;
    $dir =~ s/[\(\)']//g;
    print STDERR $dir,"\n";
    
    print "+"x$index,"$dir\n";
    while(scalar@dirstructure > $index){pop(@dirstructure);}
    $dirstructure[$index] = $dir;
    
    print STDERR join("/",$base,@dirstructure),"\n";
    system("mkdir -p ".join("/",$base,@dirstructure));
    my $copyto = join("/",$base,@dirstructure);
    if(exists $mapping{$_}){
	my $inname = $filedir."/".$mapping{$_}.$suffix;
	my $outname = $copyto."/".$mapping{$_}.$suffix;
	my $predinname = $filedirpred."/".$mapping{$_}.$suffixpred;
	my $avname = $copyto."/avcounts";
	my $mpname = $copyto."/mpcounts";
       
	system("cp $inname $outname");
	system("ln -s $outname $avname");
	system("cp $inname $mpname");
	open(OUT,">>",$mpname);
	print OUT "total\t",countgenes($predinname),"\n";
	close(OUT);

#	print ("cp $inname $outname\n");
#	print ("ln -s $outname $avname\n");
#	print ("ln -s $outname $mpname\n");
    }
}
close(TREE);
