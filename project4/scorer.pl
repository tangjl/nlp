#Jordan Tang
#CS416
#April 6, 2016
#Summary: This program will compare two files, one with answers and another with a key, and compute the accuracy.
#Instructions: To use the following program, simply input into the commandline: /perl scorer.pl my-line-answers.txt(file with answers) line-key.txt(file being compared to)
#Example of output and input:
#Input: /perl scorer.pl my-line-answers.txt line-key.txt
#Output: Overall accuracy: 81.8009412095245
#Output: Number of times my answer was supposed to be product but was not: 9
#Output: Number of times my answer was supposed to be phone but was not: 14
#Algorithm: I started by opening up both text files and going through each, separating out each word sense I was looking for and inputting them into two arrays. I would then iterate through an array and compare its value at a location to the value of the other array at the same respective location. If it matched, I would increment the accuracy. I also had a hashtable which collected which instances were incorrect. 
   
use 5.010;
use strict;
use warnings;
  
my %hash = (); 
my $total = 0;
my $count = 0;
my $arrSize = 0;
my $row = "";
my $i = 0;
my @words1 = ();
my @words2 = ();
my @array = ();
my @array2 = ();
my $word = "";

#Opening up my answers
open(SRC, $ARGV[$i]) || die "DIE\n"; 
while($row = <SRC>) {
  chomp $row; 
  my @words1 = split(/\"/, $row);
  $word = $words1[3];
  push (@array, $word);
  $row = "";
}
close SRC;

$arrSize = @array;

#Opening up the key to be compared to
open(SRC, $ARGV[$i+1]) || die "DIE\n";
while($row = <SRC>) {
  chomp $row; 
  my @words2 = split(/\"/, $row);
  $word = $words2[3];
  push (@array2, $word);
  $row = "";
}
close SRC;

#If the answer matches the key at the same position, then accuracy increases
my $j = 0;
foreach(@array) {
	if($array[$j] eq $array2[$j]) {
	$count++;
	}
	else {
		$hash{$array2[$j]}++;
	}
	$j++;
}
my $accuracy = ($count/$arrSize)*100;


print "Overall accuracy: $accuracy%\n";
while(my($key, $value) = each %hash) {
	print "Number of times my answer was supposed to be $key but was not: $value\n"; #This explains which cases I was wrong
}
 
