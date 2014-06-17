#!/usr/bin/perl
use strict;
use warnings"all";
use Data::Dumper;


our $box = 10;
our $hline = 10;
our $text = 20;
our $fontsize = int($text*3/2)-2;
our $interspace = 10;
our %max;
our $maxlevel = -1;
our $minkidsdepth = 0;
our $localmax = 0;
our $aslog = 0;
our $filename = "avcounts";

sub numberofkids{
    my $tree = shift;
    my $level = shift;
    if($maxlevel >= 0&& $level == $maxlevel){return 1;}
    if($minkidsdepth > 0 && kidsDepth($tree) < $minkidsdepth){return 1;}
    #print STDERR $dir,"\n";
    
    my $kids = 0;
    for(my $i = 1; $i < scalar@{$tree}; $i+=2){
	$kids += numberofkids($tree->[$i],$level+1);
    }
    if($kids == 0){$kids = 1;}
    return $kids;
}

sub kidsDepth{
    my $tree = shift;
    #print STDERR $dir,"\n";
    my $depth = 0;
    for(my $i = 1; $i < scalar@{$tree}; $i+=2){
	my $curdepth = kidsDepth($tree->[$i]);
	if($curdepth > $depth){$depth = $curdepth;} 
    }
    $depth++;
    return $depth;
}

sub loadData{
    my $file = shift;
    my $in;
    #print STDERR $file,"\n";
    open($in,"<",$file);
    <$in>;
    my %data;
    while(<$in>){
	chomp;
	my ($class,$count) = split;
	if($aslog == 1){$count = log($count);}
	$data{$class} = $count;
    }
    close($in);
    return %data;
}

sub extractName{
    my $string  = shift;
    $string =~ s/^.*\///;
    $string =~ s/_/ /g;
    return $string;
}

sub draw{
    my $dir = shift;
    #print STDERR "DRAW $dir\n";
    my $level = shift;
    my $tree = shift;
    my $x = shift;
    my $y = shift;
    my %data = loadData($dir."/$filename");
    if($localmax == 1){
	my @v = sort{$b <=> $a} values %data;
	foreach  my $class (keys %max){
	    $max{$class} = $v[0];
	}
    }
    my $name  = extractName($dir);
    #calculate total height used by the subtree based on kids to draw
    my $kids = numberofkids($tree,$level);
    my $height = $kids * (3*$box + $text) + ($kids-1) * $interspace;
    # calculate vertical starting point
    my $ystart = $y+int($height/2);
    #print horizontal line for subtree root
    print "<line x1=\"$x\" y1=\"$ystart\" x2=\"".($x+$hline)."\" y2=\"$ystart\" style=\"stroke:black;stroke-width:2\" />\n";
    #calculate start of boxes
    $ystart -= int((3*$box + $text)/2);
    my $xstart = $x+$hline;
    #draw boxes
    #writer
    my $light = 1 - $data{"Wac"}/$max{"Wac"};
    $light = int($light*255 +0.5);
    print "<rect x=\"$xstart\" y=\"$ystart\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />";
    $light = 1 - $data{"Wme"}/$max{"Wme"};
    $light = int($light*255 +0.5);
    print "<rect x=\"".($xstart+$box)."\" y=\"$ystart\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />";
    $light = 1 - $data{"Wub"}/$max{"Wub"};
    $light = int($light*255 +0.5);
    print "<rect x=\"".($xstart+2*$box)."\" y=\"$ystart\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />";
    $light = 1 - $data{"Wph"}/$max{"Wph"};
    $light = int($light*255 +0.5);
    print "<rect x=\"".($xstart+3*$box)."\" y=\"$ystart\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />\n";
    #eraser
    $light = 1 - $data{"Eac"}/$max{"Eac"};
    $light = int($light*255 +0.5);
    print "<rect x=\"$xstart\" y=\"".($ystart+$box)."\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />";
    $light = 1 - $data{"Eme"}/$max{"Eme"};
    $light = int($light*255 +0.5);
    print "<rect x=\"".($xstart+$box)."\" y=\"".($ystart+$box)."\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />";
    $light = 1 - $data{"Eub"}/$max{"Eub"};
    $light = int($light*255 +0.5);
    print "<rect x=\"".($xstart+2*$box)."\" y=\"".($ystart+$box)."\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />\n";
    #reader
    $light = 1 - $data{"Rac"}/$max{"Rac"};
    $light = int($light*255 +0.5);
    print "<rect x=\"$xstart\" y=\"".($ystart+2*$box)."\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />";
    $light = 1 - $data{"Rme"}/$max{"Rme"};
    $light = int($light*255 +0.5);
    print "<rect x=\"".($xstart+$box)."\" y=\"".($ystart+2*$box)."\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />";
    $light = 1 - $data{"Rph"}/$max{"Rph"};
    $light = int($light*255 +0.5);
    print "<rect x=\"".($xstart+3*$box)."\" y=\"".($ystart+2*$box)."\" width=\"$box\" height=\"$box\" style=\"fill:rgb($light,$light,$light);stroke:black;stroke-width:1\" />\n";
    ##draw text
    $ystart += 3*$box+$text;
    print "<text x=\"$xstart\" y=\"$ystart\" style=\"font-size:$fontsize;font-family=Monospace\">$name</text>\n";
    
    #draw a horizontal and vertical line for tree structure if there are kids
    print STDERR "$dir ",scalar@{$tree},">0 && ($maxlevel < 0 ||  $level < $maxlevel) && ( $minkidsdepth==0 || ",kidsDepth($tree)," > $minkidsdepth)\n";
    if(scalar@{$tree} >0 && ($maxlevel < 0 ||  $level < $maxlevel) && ($minkidsdepth == 0  || kidsDepth($tree) > $minkidsdepth)){
	#short horizontal line for connection of node info to next root
	my $oldxstart = $xstart+4*$box;
	$xstart += int(length($name) * 2/3 * $fontsize) + 1;
	$ystart = $y+int($height/2);
	print "<line x1=\"$oldxstart\" y1=\"$ystart\" x2=\"".($xstart+$hline)."\" y2=\"$ystart\" style=\"stroke:black;stroke-width:2\" />\n";
	$xstart += $hline;
	# vertical line to indicate the kids range
	my $topkids = numberofkids($tree->[1],$level+1); #number of kids of top kid
	my $bottomkids = numberofkids($tree->[-1], $level+1); #number of kids of bottom kid
	$ystart = $y + int(($topkids*3*$box + $topkids*$text + ($topkids-1)*$interspace)/2);
	my $yend = $y + $height - int(($bottomkids*3*$box + $bottomkids*$text + ($bottomkids-1)*$interspace)/2);
	print "<line x1=\"$xstart\" y1=\"$ystart\" x2=\"$xstart\" y2=\"$yend\" style=\"stroke:black;stroke-width:2\"/>\n";
	$x = $xstart;
	
	for(my $i = 0; $i < scalar@{$tree}; $i += 2){
	    my $dirname = $tree->[$i];
	    my $subtree = $tree->[$i+1];
	    draw($dir."/".$dirname, $level+1, $subtree, $x,$y);
	    my $drawnkids = numberofkids($subtree,$level+1);
	    $y += $drawnkids*(3*$box+$text+$interspace);
	}
    }
}

sub findMax{
    my $dir = shift;
    my $tree = shift;
    my $level = shift;
    if($maxlevel >= 0 && $level > $maxlevel){return;}
    #print STDERR "$dir treedepth ",kidsDepth($dir),"\n";
    if(kidsDepth($tree) < $minkidsdepth && $minkidsdepth > 0){return;}
    #print STDERR "MAX $dir\n";
    if(-e $dir."/$filename"){
	my %data = loadData($dir."/$filename");
	foreach my $class (keys %max){
	    if($max{$class} < $data{$class}){$max{$class} = $data{$class};}
	}
    }
    for(my $i = 0; $i < scalar@{$tree}; $i+=2){
	findMax($dir."/".$tree->[$i],$tree->[$i+1],$level+1);
    }
}


sub readtree{
    my $texttree = shift;
    my @tree = ();
    open(TREE,"<",$texttree);
    my @pos = ();
    my $lastdepth = 0;
   # my $counter = 0;
    while(<TREE>){
	#$counter++;
	chomp;
	my $index = length($_);
	$_ =~ s/(\+)*//;
	$index -= length($_);
	$index++;
	
        #new higher level
	if($index < $lastdepth){
	    while(scalar@pos > $index){pop@pos}
	}
	#print STDERR "$lastdepth $index\n";
	
	if($lastdepth < $index){
	    my $treeref;
	    if($index == 1){
		$treeref = \@tree
	    }else{
		$treeref = $tree[$pos[0]+1];
		for(my $i = 1; $i < scalar@pos; $i++){$treeref = $treeref->[$pos[$i]+1];}
	    }
	    push(@pos,0);
	    #print STDERR "$_ found\n";
	    push(@{$treeref},$_,[]);
	    #print STDERR Dumper(\@tree);
	    #print STDERR Dumper(\@pos);
	}else{
	    $pos[-1] += 2;
	    #print STDERR Dumper(\@pos);
	    my $treeref = $tree[$pos[0]+1];#print STDERR $pos[0]+1,"\n";
	    for(my $i = 1; $i < (scalar@pos-1); $i++){$treeref = $treeref->[$pos[$i]+1];}#print STDERR $pos[$i]+1,"\n";
	    #print STDERR "$_ found\n";
	    #print STDERR Dumper($treeref);
	    push(@{$treeref},$_,[]);
	    #print STDERR Dumper(\@tree);
	    #print STDERR Dumper(\@pos);
	}
	$lastdepth = $index;
    }
    close(TREE);
    return @tree;
}

#################################################MAIN STARTS HERE###########################################################
my $root = $ARGV[0];
my $treefile = $ARGV[1];
$filename = $ARGV[2];
$localmax = $ARGV[3];
$aslog = $ARGV[4];
if(defined $ARGV[5]){
    if($ARGV[5] >= 0){$maxlevel = $ARGV[5];}
    else{$minkidsdepth = -$ARGV[5];}
}
if(defined $ARGV[6]){
    if($ARGV[6] >= 0){$maxlevel = $ARGV[6];}
    else{$minkidsdepth = -$ARGV[6];}
}
# read tree
my @tree = readtree($treefile);
#print STDERR Dumper(\@tree);
# find maximal count
foreach my $class ("Wac", "Wme", "Wub", "Wph", "Eac", "Eme", "Eub", "Rac", "Rme", "Rph"){
    $max{$class} = 0;
}

#print STDERR "$root ",kidsDepth($root),"\n";exit;


findMax($root,\@tree,0);
print STDERR "MAX:\n", Dumper(\%max);
#print svg header
print "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" style=\"background:white\"> \n";
# draw tree
print STDERR "DRAW FROM HERE ",$tree[0],"\n";
draw($root."/".$tree[0],0,$tree[1],0,0);

#print svg footer
print "</svg>\n";

print STDERR numberofkids(\@tree,0);

__END__
<circle style="fill:hsl(0, 0%, 50%)"/>
print OUT "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n";
font-family="monospace", 2/3 *size*length

