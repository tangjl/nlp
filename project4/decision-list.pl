#Jordan Tang
#CS416
#April 6, 2016
#Summary: This program will read in a training file and from it create a decision list sorted by log-likelihood score, where it will then apply the decision list to a test file using word sense disambiguation and output an answer file with word senses assigned to the test file.  
#Instructions: To use the following program, simply input into the commandline: /decision-list.pl line-train.txt(training file) line-test.txt (file to be tested on) my-decision-list.txt(output file with features) my-line-answers.txt(output file with answers)
#Example of output and input:
#Input: perl decision-list.pl line-train.txt line-test.txt my-decision-list.txt my-line-answers.txt
#Output: (In separate file)
#(For the my-decision-list.txt file):
#These are the decision lists features
#-------------------------------------------------------
#Feature: information <head>line</head> 
#Log-likelihood score: 2.00432137378264
#Word sense: phone
#...
#(For the my-line-answers.txt file):
#<answer instance="line-n.w8_059:8174:" senseid="phone"/>
#<answer instance="line-n.w7_098:12684:" senseid="phone"/>
#...
#Algorithm: I began by reading through the training document and finding each instance of the target word. Then I created instances based off 5 different collocation features. I checked the word immediately to the left of the target word, the word immediately to the right, the two immediate words to the left of the target word, the two words immediately to the right, and finally the words immediately to the left and the right of the target word. I found the frequency of each feature and calculated the log-likelihood of each feature and compiled it into a decision list. I then read through the test file and found each instance of the target word there. I would create 5 instances again based off the different collocation features, and check to see if they existed in my decision list. If they did, then I would pick the one with the highest log-likelihood, and if not then I would settle with a default value calculated earlier based on which sense occurred most often in the training file. Finally, I would output everything to their respective files.   
#Accuracy: Overall accuracy was around 73 percent
#Accuracy: Number of times my answer was supposed to be phone but was not: 34 (This is primarily because my default sense ended up being "product" based off the test data.
#The most frequent sense baseline was phone, at 57 percent

    
use 5.010;
use strict;
use warnings;
use List::MoreUtils qw(firstidx);

#initializing variables here    
my $row = "";
my %hash = ();
my $i = 0;   
my $counter = 0;
 
#creating the decision list file
unless(open OUTPUT, '>'.$ARGV[$i+2]) {
    die "INPUT INVALID\n";
}

#creating the edited text file
unless(open OUTPUT2, '>'.$ARGV[$i+3]) {
    die "INPUT INVALID\n";
}

#more initialization
my $index;
my $collo;
my %hash2 = ();
my %hash3 = ();
my %hash4 = ();
my %hash5 = ();
my %hash6 = ();
my %hash22 = ();
my %hash33 = ();
my %hash44 = ();
my %hash55 = ();
my %hash66 = ();
my $sense = "";
my $sense2 = "";
my $check = "";
my $check2 = "";
 
#reading input through the command line
open(SRC, $ARGV[$i]) || die "DIE\n";
while($row = <SRC>) {
  chomp $row;
  if($row =~ /^<answer/) { #This contains the different word senses and how often they appear
  	my @words = split(/\"/, $row);
  	my $senseid = $words[-2];
	$sense = $senseid;
  	$hash{$senseid}++;
  }
  my @words2 = split(/\s+/, $row);
  foreach my $value(@words2) { #This was just to check how many overall occurances of the target word there were
    if($value =~ /<head>.+<\/head>/) {
    $counter++;
  	}
  }

  #The way I did this was a bit unorthodox. I attached the word sense at the end of the feature I looked at as one string overall and assigned that as the key and the frequency of the feature as the value of the hash. I did this subsequently for the rest of my hashtables below.
  if($row =~ /<head>.+<\/head>/) { #This gives the word and one word before it
	my @words3 = split(/ /, $row);
	my $arrsize = @words3;
	$index = firstidx {$_ =~ /<head>.+<\/head>/} @words3; 
	$collo = $words3[$index];
	if($index > 1) {
	$collo = $words3[$index-1] . " " . $collo; 
	}
	$sense2 = $collo . " " . $sense;
	$hash2{$collo}++;
	$hash22{$sense2}++;
  }
  if($row =~ /<head>.+<\/head>/) { #This gives the word and one word after it
	my @words3 = split(/ /, $row);
	my $arrsize = @words3;
	$index = firstidx {$_ =~ /<head>.+<\/head>/} @words3; 
	$collo = $words3[$index];
	if($index < $arrsize - 1) {
	$collo = $collo . " " . $words3[$index+1];
	}
	$sense2 = $collo . " " . $sense;
	$hash3{$collo}++;
	$hash33{$sense2}++;
  }
  if($row =~ /<head>.+<\/head>/) { #This gives the word, and one element behind and one element in front
	my @words3 = split(/ /, $row);
	my $arrsize = @words3;
	$index = firstidx {$_ =~ /<head>.+<\/head>/} @words3; 
	$collo = $words3[$index];
	if($index > 1) {
	$collo = $words3[$index-1] . " " . $collo; 
	}
	if($index < $arrsize - 1) {
	$collo = $collo . " " . $words3[$index+1];
	}
	$sense2 = $collo . " " . $sense;
	$hash4{$collo}++;
	$hash44{$sense2}++;
  }
  if($row =~ /<head>.+<\/head>/) { #This gives the word and two words before it
	my @words3 = split(/ /, $row);
	my $arrsize = @words3;
	$index = firstidx {$_ =~ /<head>.+<\/head>/} @words3; 
	$collo = $words3[$index];
	if($index > 2) {
	$collo = $words3[$index-2] . " " . $words3[$index-1] . " " . $collo; 
	}
	$sense2 = $collo . " " . $sense;
	$hash5{$collo}++;
	$hash55{$sense2}++;
  }
  if($row =~ /<head>.+<\/head>/) { #This gives the word and two words after it
	my @words3 = split(/ /, $row);
	my $arrsize = @words3;
	$index = firstidx {$_ =~ /<head>.+<\/head>/} @words3; 
	$collo = $words3[$index];
	if($index < $arrsize - 2) {
	$collo = $collo . " " . $words3[$index+1] . " " . $words3[$index+2];
	}
	$sense2 = $collo . " " . $sense;
	$hash6{$collo}++;
	$hash66{$sense2}++;
  }
  $row = "";
}

#I use this later on
my @mysenses = keys %hash;
$check = $mysenses[0];
$check2 = $mysenses[1];

#More initialization...you can tell I was starting to run out of ideas for variable names here
my $sensex = "";
my $count1 = 0;
my $sensey = "";
my $count2 = 0;
my %hashdog = ();
my %hashcat = ();
my %hashdog2 = ();
my %hashcat2 = ();
my %hashdog3 = ();
my %hashcat3 = ();
my %hashdog4 = ();
my %hashcat4 = ();
my %hashdog5 = ();
my %hashcat5 = ();
my $log = 0;

#This makes sure everything is in log base 10
sub log10 {
    my $n = shift;
    return log($n)/log(10);
}

#This is for the calculations for hash2, where I get the overall word sense and log likelihood of the features
while(my($key, $value) = each %hash2) {
	my $it = 0;
	$count1 = 0;
	$count2 = 0;
	while(my($key2, $value2) = each %hash22) {
		if($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 0) {
			my @words = split(/ /, $key2);
			$sensex = $words[2];
			$count1 = $hash22{$key2}; 
			$it = 1;	
		}
		elsif($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 1) {
			my @words = split(/ /, $key2);
			$sensey = $words[2];
			$count2 = $hash22{$key2};
		} 
	}
	if($count1 >= $count2) {
		$hashdog{$key} = $sensex;
	}
	else {
		$hashdog{$key} = $sensey;
	}
	$log = abs(log10((($count1/$hash2{$key})+0.01)/(($count2/$hash2{$key})+0.01)));
	$hashcat{$key} = $log;
}


#This is for the calculations for hash3, where I get the overall word sense and log likelihood of the features
while(my($key, $value) = each %hash3) {
	my $it = 0;
	$count1 = 0;
	$count2 = 0;
	while(my($key2, $value2) = each %hash33) {
		if($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 0) {
			my @words = split(/ /, $key2);
			$sensex = $words[2];
			$count1 = $hash33{$key2};
			$it = 1;	
		}
		elsif($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 1) {
			my @words = split(/ /, $key2);
			$sensey = $words[2];
			$count2 = $hash33{$key2};
		} 
	}
	if($count1 >= $count2) {
		$hashdog2{$key} = $sensex;
	}
	else {
		$hashdog2{$key} = $sensey;
	}
	$log = abs(log10((($count1/$hash3{$key})+0.01)/(($count2/$hash3{$key})+0.01)));
	$hashcat2{$key} = $log;
}

#This is for the calculations for hash4, where I get the overall word sense and log likelihood of the features
while(my($key, $value) = each %hash4) {
	my $it = 0;
	$count1 = 0;
	$count2 = 0;

	while(my($key2, $value2) = each %hash44) {
		if($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 0) {
			my @words = split(/ /, $key2);
			$sensex = $words[3];
			$count1 = $hash44{$key2};
			$it = 1;	
		}
		elsif($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 1) {
			my @words = split(/ /, $key2);
			$sensey = $words[3];
			$count2 = $hash44{$key2};
		} 
	}
	if($count1 >= $count2) {
		$hashdog3{$key} = $sensex;
	}
	else {
		$hashdog3{$key} = $sensey;
	}
	$log = abs(log10((($count1/$hash4{$key})+0.01)/(($count2/$hash4{$key})+0.01)));
	$hashcat3{$key} = $log;
}

#This is for the calculations for hash5, where I get the overall word sense and log likelihood of the features
while(my($key, $value) = each %hash5) {
	my $it = 0;
	$count1 = 0;
	$count2 = 0;
	while(my($key2, $value2) = each %hash55) {
		if($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 0) {
			my @words = split(/ /, $key2);
			$sensex = $words[3];
			$count1 = $hash55{$key2};
			$it = 1;	
		}
		elsif($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 1) {
			my @words = split(/ /, $key2);
			$sensey = $words[3];
			$count2 = $hash55{$key2};
		} 
	}
	if($count1 >= $count2) {
		$hashdog4{$key} = $sensex;
	}
	else {
		$hashdog4{$key} = $sensey;
	}
	$log = abs(log10((($count1/$hash5{$key})+0.01)/(($count2/$hash5{$key})+0.01)));
	$hashcat4{$key} = $log;
}

#This is for the calculations for hash6, where I get the overall word sense and log likelihood of the features
while(my($key, $value) = each %hash6) {
	my $it = 0;
	$count1 = 0;
	$count2 = 0;
	while(my($key2, $value2) = each %hash66) {
		if($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 0) {
			my @words = split(/ /, $key2);
			$sensex = $words[3];
			$count1 = $hash66{$key2};
			$it = 1;	
		}
		elsif($key2 =~ /(^\Q$key\E [$check|$check2])/ && $it == 1) {
			my @words = split(/ /, $key2);
			$sensey = $words[3];
			$count2 = $hash66{$key2};
		} 
	}
	if($count1 >= $count2) {
		$hashdog5{$key} = $sensex;
	}
	else {
		$hashdog5{$key} = $sensey;
	}
	$log = abs(log10((($count1/$hash6{$key})+0.01)/(($count2/$hash6{$key})+0.01)));
	$hashcat5{$key} = $log;
}

close SRC;
 

#even more initialization. I thought chosense was a pretty clever name (chosen - sense --> chosense)
my $chosense = "";
my $sensecheck = "";
my $logcheck = 0;
my $currentlog1 = 0;
my $currentlog2 = 0;
my $currentlog3 = 0;
my $currentlog4 = 0;
my $currentlog5 = 0;
my $collo1 = "";
my $collo2 = "";
my $collo3 = "";
my $collo4 = "";
my $collo5 = "";
my $sense1 = "";
$sense2 = "";
my $sense3 = "";
my $sense4 = "";
my $sense5 = "";
my $a = "";
my $b = 0;
my $c = "";
my $d = 0;
my $default = "";

#This is where I pick out the default value to set for certain lines that don't match any of the features
my $int = 0;
while(my($key, $value) = each %hash) {
	if($int == 0){
	$a = $key;
	$b = $value;
	}
	else {
	$c = $key;
	$d = $value;
	}
	$int++;
}

if($b > $d) {
	$default = $a;
}
else {
	$default = $c;
}

#Formatting for the line answers
open(SRC, $ARGV[$i+1]) || die "DIE\n";
while($row = <SRC>) {
  chomp $row;
  if($row =~ /^<instance/) {
	$row =~ s/<instance id/<answer instance/g;	
	$row =~ s/>/ senseid=\"/g; 
	print OUTPUT2 "$row";  	
  }
  #When I detect the target word, I start to run all this
  if($row =~ /<head>.+<\/head>/) { 
	my @words3 = split(/ /, $row);
	my $arrsize = @words3;
	$index = firstidx {$_ =~ /<head>.+<\/head>/} @words3; 
	$collo1 = $words3[$index];
   	$collo2 = $words3[$index];
   	$collo3 = $words3[$index];
    	$collo4 = $words3[$index];
    	$collo5 = $words3[$index];
	#I create 5 instances for each time the target word is found based on my features
	if($index > 1) {
    		$collo1 = $words3[$index-1] . " " . $collo1; 
    	}
	if($index < $arrsize - 1) {
		$collo2 = $collo2 . " " . $words3[$index+1];
	}
	if($index > 2) {
		$collo3 = $words3[$index-2] . " " . $words3[$index-1] . " " . $collo3; 
	}
    	if($index < $arrsize - 2) {
       		$collo4 = $collo4 . " " . $words3[$index+1] . " " . $words3[$index+2];
    	}
	if($index > 1 && $index < $arrsize - 1) {
		$collo5 = $words3[$index-1] . " " . $collo5 . " " . $words3[$index+1]; 	
	}

	#This is so if nothing matches later on, at least there will be a default sense assigned
	$sense1 = $default;
	$sense2 = $default;
	$sense3 = $default;
	$sense4 = $default;
	$sense5 = $default;


	#Then I go through the hash tables with the features with the instances and see if there is a match
	while(my($key, $value) = each %hash2) {
        if($collo1 =~ /(^\Q$key\E)/) {
            $currentlog1 = $hashcat{$key};   
            $sense1 = $hashdog{$key};
        }
	}
	
	while(my($key, $value) = each %hash3) {
        if($collo2 =~ /(^\Q$key\E)/) {
            $currentlog2 = $hashcat2{$key};   
            $sense2 = $hashdog2{$key};
        }
	}

	while(my($key, $value) = each %hash4) {
        if($collo5 =~ /(^\Q$key\E)/) {
            $currentlog5 = $hashcat3{$key};   
            $sense5 = $hashdog3{$key};
        }
	}

	while(my($key, $value) = each %hash5) {
        if($collo3 =~ /(^\Q$key\E)/) {
            $currentlog3 = $hashcat4{$key};   
            $sense3 = $hashdog4{$key};	
        }
	}

	while(my($key, $value) = each %hash6) {
        if($collo4 =~ /(^\Q$key\E)/) {
            $currentlog4 = $hashcat5{$key};   
            $sense4 = $hashdog5{$key};
        }
	}

	#This is my ranking system for which feature has the higher score
	if($currentlog5 >= $currentlog1 && $currentlog5 >= $currentlog2 && $currentlog5 >= $currentlog3 && $currentlog5 >= $currentlog4) {
		$chosense = $sense5;
	}
	elsif($currentlog3 > $currentlog5 && $currentlog3 >= $currentlog4 && $currentlog3 >= $currentlog2 && $currentlog3 >= $currentlog1) {
		$chosense = $sense3;
	}
	elsif($currentlog4 > $currentlog5 && $currentlog4 > $currentlog3 && $currentlog4 >= $currentlog2 && $currentlog4 >= $currentlog1) {
		$chosense = $sense4;
	}
	elsif($currentlog1 > $currentlog5 && $currentlog1 > $currentlog4 && $currentlog1 > $currentlog3 && $currentlog1 >= $currentlog2) {
		$chosense = $sense1;
	}
	elsif($currentlog2 > $currentlog1 && $currentlog2 > $currentlog3 && $currentlog2 > $currentlog4 && $currentlog2 > $currentlog5) {
		$chosense = $sense2;
	}

  print OUTPUT2 "$chosense\"\/>\n";

  $row = "";
  }

}

print OUTPUT "These are the decision lists features\n";
print OUTPUT "-------------------------------------------------------\n";

#Formatting for my decision list. I just had the feature, the log-likelihood score attached to it, and the word sense.
while(my($key, $value) = each %hash2) {
	print OUTPUT "Feature: $key \n";
	print OUTPUT "Log-likelihood score: $hashcat{$key}\n";
	print OUTPUT "Word sense: $hashdog{$key}\n";
	print OUTPUT "\n";
}

while(my($key, $value) = each %hash3) {
	print OUTPUT "Feature: $key \n";
	print OUTPUT "Log-likelihood score: $hashcat2{$key}\n";
	print OUTPUT "Word sense: $hashdog2{$key}\n";
	print OUTPUT "\n";
}

while(my($key, $value) = each %hash4) {
	print OUTPUT "Feature: $key \n";
	print OUTPUT "Log-likelihood score: $hashcat3{$key}\n";
	print OUTPUT "Word sense: $hashdog3{$key}\n";
	print OUTPUT "\n";
}

while(my($key, $value) = each %hash5) {
	print OUTPUT "Feature: $key \n";
	print OUTPUT "Log-likelihood score: $hashcat4{$key}\n";
	print OUTPUT "Word sense: $hashdog4{$key}\n";
	print OUTPUT "\n";
}

while(my($key, $value) = each %hash6) {
	print OUTPUT "Feature: $key \n";
	print OUTPUT "Log-likelihood score: $hashcat5{$key}\n";
	print OUTPUT "Word sense: $hashdog5{$key}\n";
	print OUTPUT "\n";
}

close SRC;
 
close OUTPUT;

close OUTPUT2;
