#Jordan Tang
#CS416
#March 23, 2016
#Summary: This program will take as input a training file containing part of speech tagged text, and a file containing text to be part of speech tagged.
#Instructions: To use the following program, simply input into the commandline: /tagger.pl pos-train.txt (training data) pos-test.txt (data to be tested on) 
#Example of output and input: 
#Input: perl tagger.pl pos-train.txt pos-test.txt pos-test-with-tags.txt
#Output: (In separate file)
#Output: No/DT ,/, 
#Output: [ it/PRP ] 
#Output: [ was/VBD n't/RB Black/NNP Monday/NNP ] 
#Output: ./. 
#Algorithm: I began by reading through the training file and collecting the frequencies of each word and then the frequency of each word plus a tag, which I would then use to find the max probability in a new hashtable. I then read through the file to be tagged, and depending on the word assigned the appropriate max tag and copied everything into a new output file.  
   
use 5.010;
use strict;
use warnings;
  
say "Give it some time...";
  
my %hash = (); 
my %hash2 = ();
my %hash4 = ();
my $row = "";
my $i = 0;   

#creating the new output file
unless(open OUTPUT, '>'.$ARGV[$i+2]) {
	die "HELP ME\n";
}


#reading input through the command line
open(SRC, $ARGV[$i]) || die "DIE\n"; 
while($row = <SRC>) {
  chomp $row; 
  #stuff that is unnecessary for training is removed and then tokens are stored in a hashtable
  $row =~ s/\\\//AAA/g;
  $row =~ s/\/\(//g;
  $row =~ s/\/\)//g;
  $row =~ s/\{//g;
  $row =~ s/\}//g;
  $row =~ s/\(//g;
  $row =~ s/\)//g;
  $row =~ s/\-\-/AAAAAA/g; #A lot of special cases...
  $row =~ s/\-/AAAA/g;
  $row =~ s/\B\%\B//g;
  $row =~ s/^\./AAAAAAAA/g;
  $row =~ s/\[ //g;
  $row =~ s/\|[A-Z]+//g;
  $row =~ s/\]//g; 
  #gives the frequency of each word plus a certain tag
  my @words = split(/\s+/, $row);
  foreach my $value(@words) {
    $hash{$value}++;
  }
  $row =~ s/\/[A-Z]+$//g;
  $row =~ s/\/[A-Z]+\$//g;
  $row =~ s/\/[[:punct:]]+//g;
  $row =~ s/\/[A-Z][A-Z]+//g;	
  #second hashtable gives the raw frequency of each word
  @words = split(/\s+/, $row);
  foreach my $value(@words) {
    $hash2{$value}++;
  }
  $row = "";
}

#getting the probability of each word with its POS tag
while ((my $key,my $value) = each %hash) {
    my $newkey = $key;
    $newkey =~ s/(\/[A-Z]*[[:punct:]]*)$//g; 
    $hash{$key} = $value/$hash2{$newkey};  
}

close SRC;
   
my %hash3 = (); 

#reading in the file to be tested on
open(SRC, $ARGV[$i+1]) || die "DIE\n";
while($row = <SRC>) {
  chomp $row;
  $row =~ s/\\\//AAA/g;
  $row =~ s/\{//g;
  $row =~ s/\}//g;
  $row =~ s/\(//g;
  $row =~ s/\)//g;
  $row =~ s/\-\-/AAAAAA/g; #more special cases
  $row =~ s/\-/AAAA/g;  
  $row =~ s/\B\.\B/AAAAAAAA/g;
  $row =~ s/\B\%\B//g;  
  $row =~ s/\[ //g;
  $row =~ s/\]//g;
  #storing words into a hashtable
  my @words = split(/\s+/, $row);
  foreach my $value(@words) {
    $hash3{$value} = $value;
  } 
  $row = "";
}

#My approach here was to go through each word in the test file, and given a word, match it to the other hastable given the word followed directly by '/' and any character after. After collecting the set of words with POS tag for a single word, I would then pick the one with the highest probability and tag the value of the word key in the hashtable.
my $number = 0;
my $addon = "";
while(my($key, $value) = each %hash3){
    while(my($key2, $value2) = each %hash) {
	if($key2 =~ /\b$value\/.+\b/) {
		$hash4{$key2} = $value2;
	}
    }

#This picks my base probability to compare to.
foreach my $key3 (keys %hash4) {
	$number = $hash4{$key3};
	last;
	} 

#If only one POS tag exists for a word, just use that
    if(1 == keys %hash4) {
	while(my($key3, $value3) = each %hash4) {
	$hash3{$key} = $key3;
	}	
	}
#If none exists in the training data, use /NN
#Other special cases are covered here as well
    elsif(!%hash4) {
	if($value =~ /AAAAAAAA/) {
	$hash3{$key} = $value . "/.";
	}
	elsif($value =~ /.+\-.+/) {
	$hash3{$key} = $value . "/NN";	
	}
	elsif($value =~ /.+\..+/) {
	$hash3{$key} = $value . "/NN";	
	}
	elsif($value =~ /[[:punct:]]+/) {
	$hash3{$key} = $value . "/" . $value;
	}
	else {
	$hash3{$key} = $value . "/NN";	
	}
	}
#Else go through the hashtable until you find a larger probability
    else {
	while(my($key3, $value3) = each %hash4) {
		if($hash4{$key3} >= $number) {
		$addon = $key3;
		$number = $hash4{$key3};
		}
	}
	$hash3{$key} = $addon;
	}
    	%hash4 = ();
}

close SRC;

my $newrow = "";

#This begins to store data in the new output text file
#Recreated the test file but added tags
open(SRC, $ARGV[$i+1]) || die "DIE\n";
while($row = <SRC>) {
  chomp $row;
  $row =~ s/\\\//AAA/g;
  $row =~ s/\B\.\B/AAAAAAAA/g;
  $row =~ s/\-\-/AAAAAA/g;
  $row =~ s/\-/AAAA/g;
  my @words = split(/\s+/, $row);
  foreach my $value(@words) {
  while(my($key2, $value2) = each %hash3){
  if ($key2 eq $value) {
	$newrow = $newrow . "$hash3{$key2}" . " ";
  }
  }
  #special cases
  if ($value eq "(" || $value eq "{") {
	$newrow = $newrow . $value . "/( ";
  } 
  if ($value eq ")" || $value eq "}") {
	$newrow = $newrow . $value . "/) ";
  }
  if ($value eq "[" || $value eq "]") {
	$newrow = $newrow . $value . " ";
  }
  if ($value eq "%") {
	$newrow = $newrow . "%/NN ";
  }
  }
  #patching up special cases
  $newrow =~ s/AAAAAAAA/\./g;
  $newrow =~ s/AAAAAA/\-\-\/\:/g;
  $newrow =~ s/AAAA/\-/g;
  $newrow =~ s/AAA/\\\//g;
  print OUTPUT "$newrow\n";  
  $row = "";
  $newrow = "";
}

close SRC;

close OUTPUT;

