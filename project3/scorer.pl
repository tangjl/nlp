#Jordan Tang
#CS416
#March 23, 2016
#Summary: This program will compare two tagged files, one a key, and give the overall accuracy of the tags
#Instructions: To use the following program, simply input into the commandline: /scorer.pl pos-test-with-tags.txt (tagged file) pos-test-key.txt (key to be tested against) pos-tagging-report.txt (file with output data) 
#Example of output and input:
#Input: /scorer.pl pos-test-with-tags.txt pos-test-key.txt pos-tagging-report.txt  
#Output: Overall accuracy: 81.8009412095245
#Algorithm: I started by opening up both text files and going through each, separating out each word with its POS tag and inputting them into two arrays. I would then iterate through an array and compare its value at a location to the value of the other array at the same respective location. If it matched, I would increment the accuracy. 
   
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

#Creating the output file
unless(open OUTPUT, '>'.$ARGV[$i+2]) {
	die "HELP ME\n";
}

#Opening up the file that was tagged to be compared
open(SRC, $ARGV[$i]) || die "DIE\n"; 
while($row = <SRC>) {
  chomp $row; 
  #Got rid of annoying brackets
  $row =~ s/\[ //g;
  $row =~ s/\]//g; 
  my @words1 = split(/\s+/, $row);
  #Created an array filled with each word plus its tag
  foreach my $value(@words1) {
    push (@array, $value);
  }   
  $total = @words1; 
  $arrSize = $arrSize + $total;
}
close SRC;

#Opening up the key to be compared to
open(SRC, $ARGV[$i+1]) || die "DIE\n";
while($row = <SRC>) {
  chomp $row; 
  $row =~ s/\[ //g;
  $row =~ s/\]//g; 
  my @words2 = split(/\s+/, $row);
  #Doing the same thing as above
  foreach my $value(@words2) {
    push (@array2, $value);
  }  
}
close SRC;

#If keys matched at the same location of each file, then accuracy increases
my $j = 0;
foreach(@array) {
	if($array[$j] eq $array2[$j]) {
	$count++;
	}
	$j++;
}

my $accuracy = ($count/$arrSize)*100;

print OUTPUT "Overall accuracy: $accuracy\n";

close OUTPUT;
