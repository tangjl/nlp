#Jordan Tang
#CS416
#February 26th, 2016
#Summary: The following program will create an n-gram model based off a corpus selected by the user, and will generate sentences based off the ngram model. 
#Instructions: To use the following program, simply input into the commandline: ./ngram.pl <n-gram> <number of sentences> <corpus>
#Example of output and input:
#Input: perl ngram.pl 3 5 turtlemiracles.txt
#Output: This program generates random sentences based on an Ngram model.
#Output: Command line settings: ngram.pl 3 5 
#Output: Sentence 1: i really do like turtles .
#Output: Sentence 2: i can't believe this is a miracle !
#Output: Sentence 3: this is a miracle !
#Output: Sentence 4: it's working !
#Output: Sentence 5: my turtle farm is looking nice .
#Algorithm:
  
use 5.010;
use strict;
use warnings;
 
#Taking in the ngram and the number of sentences 
my $n = shift @ARGV;
my $m = shift @ARGV;
 
#This is here to make sure user input is valid 
while(!defined $n||!defined $m) {
    say "Input invalid. Please try again.";
    exit;
}
 
#Output that tells the user what they inputted 
say "This program generates random sentences based on an Ngram model.";
say "Command line settings: $0 $n $m";
 
#my hash table and $row basically copies the txt files  
my %hash = (); 
my %hash2 = ();
my $row = "";
 
#SO THIS RIGHT HERE IS SOLELY FOR UNIGRAMS. BIGRAMS AND MORE ARE COMING
if($n == 1) { 
 
#Reading the textfile
while (<>) {
  chomp;
  $row .= $_;
 
  my $lcrow = lc($row);
  $lcrow =~ s/[.]/ . /g; 
  $lcrow =~ s/[,]/ , /g;
  $lcrow =~ s/[!]/ ! /g;
  $lcrow =~ s/[?]/ ? /g;
  $lcrow =~ s/[;]/ ; /g;
  $lcrow =~ s/[:]/ : /g;
  $lcrow =~ s/[-]/ - /g;
  $lcrow =~ s/["]/ " /g;
  #Putting all the tokens into a hashtable with the amount of times they appear in the corpus
  my @words = split(/\s+/, $lcrow);
  foreach my $value(@words) {
    $hash{$value}++;
  } 
  $row = "";
}
  
#checking keys and values in my hash
my @keys = keys %hash;
my @values = values %hash;
my $total = 0;
  
#This measures the total amount of tokens
foreach (@values) {
  $total = $total + $_;
}
 
#This measures frequency and stores the frequency of each token into the original hash
while ((my $key,my $value) = each %hash) {
    $hash{$key} = $value/$total;  
}

 
#This loops generates my random sentences
my $mm = 1;
while($m > 0) {
 
    my $sentence = "";
    my $chosen = "";
 
    do { 
    my $sum = 0;
    $chosen = "";
     foreach my $item(keys %hash) {
     $sum += $hash{$item};
     $chosen = $item if rand($sum) < $hash{$item};
     }
    $sentence .= $chosen . " ";
    } until ($chosen =~ /[.!?]/);
    print "Sentence $mm: $sentence\n";
    $m--;
    $mm++;
}
 
} 
 
#For multiple ngrams
else {
 
my $nn = $n - 2;
$n = $n - 1;
my $flag = 0;
my @array2 = ();
my $rand = 0;
my $arraysize2 = 0;
 
#Reading the textfile
while (<>) {
  $row .= "<start> "; #start tag will signal the beginning of sentences
  chomp;
  $row .= $_;
 
  #This is all for lowercasing and separating tokens namely punctuation marks
  my $lcrow = lc($row);
  $lcrow =~ s/[.]/ . /g; 
  $lcrow =~ s/[,]/ , /g;
  $lcrow =~ s/[!]/ ! /g;
  $lcrow =~ s/[?]/ ? /g;
  $lcrow =~ s/[;]/ ; /g;
  $lcrow =~ s/[:]/ : /g;
  $lcrow =~ s/[-]/ - /g;
  $lcrow =~ s/["]/ " /g;

  #Putting all the tokens into two hashtables with the amount of times they appear in the corpus, one for n and one for n-1
  push (@array2, $lcrow);
  my @words = split(/\s+/, $lcrow);
  $arraysize2 = @array2;
  $arraysize2 = $arraysize2 - 1;
  my $arraysize = @words;
  if($arraysize >= $n) {
    $flag = 1;
  } 
  $hash{$_}++ for $lcrow =~ m/(?=(\S+(?: \S+){$n}))\S+/g; 
  $hash2{$_}++ for $lcrow =~ m/(?=(\S+(?: \S+){$nn}))\S+/g; 
  $row = "";
}
  my $mm = 1;
  if($flag == 0) {
    while($m > 0) {
    $rand = int(rand($arraysize2)); 
    my $sentence = $array2[$rand];
    $sentence =~ s/^(<start> )//g;
    print "Sentence $mm: $sentence\n";
    $m--;
    $mm++;
        }
    exit;
  }
 
#checking keys and values in my hash
my @keys = keys %hash;
my @values = values %hash;
my $total = 0;
  
#This measures the total amount of tokens
foreach (@values) {
  $total = $total + $_;
}
 
#checking keys and values in my hash
my @keys2 = keys %hash2;
my @values2 = values %hash2;
my $total2 = 0;
  
#This measures the total amount of tokens
foreach (@values2) {
  $total2 = $total2 + $_;
}
 
#This measures frequency and stores the frequency of each token into the original hash
while ((my $key,my $value) = each %hash) {
    my $newkey = $key;
    $newkey =~ s/\s+\S+$//;
    $hash{$key} = $value/$hash2{$newkey};  
     
}
 
#This loops generates my random sentences
$mm = 1;
while($m > 0) {
 
    my %hash3 = ();
    my %hash4 = ();
    my $sentence = "";
    my $chosen = "";
    my $chosen2 = "";
    my $total = 0;
 
    while ((my $key,my $value) = each %hash) {
    if($key =~ m/^(<start>)/) { 
        $hash3{$key} = $value;
        $total++; 
    }
    }
    while ((my $key,my $value) = each %hash3) {
    $hash3{$key} = $value/$total;  
    }
     
    my $sum = 0;
    $chosen = "";
     
     foreach my $item(keys %hash3) {
     $sum += $hash3{$item};
     $chosen = $item if rand($sum) < $hash3{$item};
     }
     
    $chosen =~ s/^(<start> )//;
    $sentence .= $chosen . " ";
    $total = 0;     
     
    my @splitter = split " ", $sentence;
    push @splitter, my $helper = pop @splitter;
    if($helper =~ /[.?!]/) {
    goto START;
    }
     
    #BACKTOTHIS
    do {
     
    while ((my $key,my $value) = each %hash) {
    if($key =~ m/^($chosen )/) { 
        $hash4{$key} = $value;
        $total++;
    }
    }
     
    my $sum = 0;
    $chosen = "";
    $chosen2 = "";
     foreach my $item(keys %hash4) {
     $sum += $hash4{$item};
     $chosen = $item if rand($sum) < $hash4{$item};
     }
     
    my @splitter = split " ", $chosen;
    push @splitter, $chosen2 = pop @splitter;
     
    $sentence .= $chosen2 . " ";
    $chosen =~ s/^\S+\s*//;
    %hash4 = ();
     
    } until ($chosen2 =~ /[.!?]/);
    START:
    print "Sentence $mm: $sentence\n";
    $m--;
    $mm++;
}
 
}
