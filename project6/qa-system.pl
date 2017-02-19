#Jordan Tang
#CS416
#May 2, 2016
#VERSION 2.1 (now with date of birth and more!!!) Start reading here for updates (ALSO NOTE THAT NEW PROGRAM IS SIGNIFICANTLY SHORTER THAN VERSION 1.0)
#Enhancement 1 to Query Reformulation: Program will look for less and less keywords within the question, using a back off strategy. A lower confidence score will be assigned as less words are searched for. 
#Enhancement 2 to Query Reformulation: Query expansion application, with words not originally found in the originally query are searched for within the document. 
#Enhancement 1 to Answer Composition: For questions involving a major league US sports player team history, program will look for team names within the document, pick them out, and then combine them into a complete answer for a player's team history or current team played on.
#Enhancement 2 to Answer Composition: For questions involving a film's cast, program will look for the cast of a film and will recombine and structure them into a complete answer giving the stars of a film. 
#Confidence Scoring of Answers: Anytime a keyword is found or a certain pattern matches, some arbitrary number is added to the initial score of 0. Can reach up to 0.99, will never hit 1 as there is no complete guarentee the final answer is 100 percent correct. 
#Summary: This program will answer Who, What, When, and Where questions from the user, providing answers in complete sentences that are specific to the questions asked through the use of Wikipedia. The program will recognize if no answers are found and respond appropriately. 
#Instructions: To use the following program, simply input into the commandline: /perl qa-system.pl mylogfile.txt
#Example of output and input:
#Input: perl qa-system.pl mylogfile.txt
#Output: This is a QA system by Jordan Tang. It will try to answer questions that start with Who, What, When, or Where (Please use proper grammar). Enter "exit" to leave the program.
#Input: What is Perl?
#Output: 'Perl' is a family of high-level, general-purpose, interpreted, dynamic programming languages.
#Input: exit 
#Output: Thank you, Goodbye!
#Output: (in mylogfile.txt)
#Output: Question: What is Perl?
#Output: Search term: Perl
#Output: Raw wiki data: ........
#Output: Confidence score: 0.9
#Output: ........
#Algorithm: I began by setting up the Wikipedia module, and taking user input. Whatever the user input was, I'd dissect it to find the subject matter. I then had several different regex options for questions of the Who, What, When, Where variety. If a user query matched one of the options, I then checked the found Wikipedia article for a certain pattern/keyword after query expansion and a backoff strategy was applied, and set up my potential answers appropriately if the pattern/keyword was matched. I had a confidence score associated with each potential match and whichever had the highest score was the answer ultimately used. If no pattern was found, then no answer is given. 
    
use 5.010;
use strict;
use warnings;
use WWW::Wikipedia;


#The wiki module
my $wiki = WWW::Wikipedia->new();
my $doc = "";
my $i = 0;
 
#This is for my log file
unless(open OUTPUT, '>'.$ARGV[$i]) {
    die "HELP ME\n";
}

say "This is a QA system by Jordan Tang. It will try to answer questions that start with Who, What, When, or Where (Please use proper grammar). Enter \"exit\" to leave the program.";

print OUTPUT "The following contains the questions asked by the user, searches I execute, and raw wiki data.\n";
print OUTPUT "-----------------------------------------------------------------------------------\n\n";

#Initiating values here
my $question = "";
my $answer = "";
my $add = "";
my $flag = "exit";

#This is what loops until the user decides to exit
while($question ne $flag) {
$question = "";
$answer = "";
$add = "";
$doc = "";
my @pg = ();
my @searchterms = ();
$question = <STDIN>;
chomp $question;
$question =~ s/\?//;
$answer = $question;

print OUTPUT "Question: $question\n";

#Quit if the user types exit
if($question eq "exit") {
	say "Thank you! Goodbye.";
	exit;
}

#One of the new question types, for players of major league US sports teams
elsif($question =~ /^Who has / || $question =~ /^What teams has /) {
	my $score = 0;
	my $answer = '';
	#stripping the question to find the search terms
	$question =~ s/^Who has //;
	$question =~ s/^What teams has //;
	$question =~ s/ played for//;
	$question =~ s/ played on//;
	@searchterms = ();
	#these are additional keywords to be look for that I came up with from observing common terms in documents
	push @searchterms, 'player';
	push @searchterms, 'played';
	push @searchterms, 'for';
	push @searchterms, 'college';
	push @searchterms, 'professional';
	push @searchterms, 'seasons';
	push @searchterms, 'attended';
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		#Removing all the junk and other useless characters in the document
		my $score2 = 0;
        	$_ =~ s/\{[\s|\S]*\}//g;
		$_ =~ s/\}//g;
		$_ =~ s/\Q<!--\E [\s|\S]+ \Q-->\E//g;
		$_ =~ s/\Q<!--\E[\s|\S]+\Q-->\E//g;
		$_ =~ s/<ref\s.*>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\([\s|\S]+\)//g;
		$_ =~ s/\Q<ref>\E.*\Q<\/ref>\E//g;
		$_ =~ s/<ref>[\s|\S]+<\/ref>//g;
		$_ =~ s/\,[a-z][\s|\S]+\,//g;
		$_ =~ s/\[[\s|\S]+\]//g;
		$_ =~ s/\<\/ref\>//g;
		
		#If certain keywords are found, add to the score
		if($_ =~ /\'.+\'/) {
			$score2 += 0.1
		}
		if($_ =~ /\s$searchterms[0]\s/) {
			$score2 += 0.1
		}
		if($_ =~ /\s$searchterms[1]\s/) {
			$score2 += 0.1
		}
		if($_ =~ /\s$searchterms[2]\s/) {
			$score2 += 0.1
		}
		if($_ =~ /\s$searchterms[3]\s/) {
			$score2 += 0.1
		}
		if($_ =~ /\s$searchterms[4]\s/) {
			$score2 += 0.1
		}
		if($_ =~ /\s$searchterms[5]\s/) {
			$score2 += 0.1
		}
		if($_ =~ /\s$searchterms[6]\s/) {
			$score2 += 0.1
		}
		
		print OUTPUT "Potential answer: $_\n\n";

		if($_ =~ /\'.+\'/) {				
		$_ =~ s/\n/ /g; 
		my @cut = split('\. ', $_);
		my $counter = 0;		
			#goes through each sentence and finds the teams through certain patterns. If they are found, then add them to the final answer
			foreach my $looper (@cut) {
				if($looper =~ /for the/) {
				$looper =~ s/[\s|\S]+for //;
				$score2 += 0.1;
					if($counter == 0) {
					$answer = $answer . $looper;					
					$counter++;					
					}
					elsif($looper =~ /^the [A-Z]/ || $looper =~ /^[A-Z]/)  {
					$answer = $answer . " and " . $looper;  
					}				
				}
				elsif($looper =~ /played college/) {
				$looper =~ s/[\s|\S]+\sat\s//;
				$looper =~ s/[\s|\S]+\sfor\s//;
				$score2 += 0.1;
					if($counter == 0) {
					$answer = $answer . $looper;					
					$counter++;					
					}
					elsif($looper =~ /^the [A-Z]/ || $looper =~ /^[A-Z]/) {
					$answer = $answer . " and " . $looper;  
					}				
				}
				elsif($looper =~ /plays for/) {
				$looper =~ s/[\s|\S]+\splays for\s//;
				$score2 += 0.1;
					if($counter == 0) {
					$answer = $answer . $looper;					
					$counter++;					
					}
					elsif($looper =~ /^the [A-Z]/ || $looper =~ /^[A-Z]/) {
					$answer = $answer . " and " . $looper;  
					}				
				}	
				elsif($looper =~ /playing for/) {
				$looper =~ s/[\s|\S]+\splaying for\s//;
				$score2 += 0.1;
					if($counter == 0) {
					$answer = $answer . $looper;					
					$counter++;					
					}
					elsif($looper =~ /^the [A-Z]/ || $looper =~ /^[A-Z]/) {
					$answer = $answer . " and " . $looper;  
					}				
				}			
				
			}
	
			#whatever potential answer scores highest is returned
			if($score2 > $score) {
				$answer =~ s/\,[\s|\S]*/\./g;
				$answer =~ s/ as a .*//g;
				$answer =~ s/ before [\s|\S]+/\./g;
				$add = $answer;
				if($add eq '') {
				goto START;
				}
				$score = $score2;
				print OUTPUT "This is the answer I'm going with: $add\n\n";
			} 

		}
		print OUTPUT "Confidence score: $score2\n\n";
	}
	if($score == 0) {
		goto START;
	}
	if($score >= 1) {
		$score = 0.99;
	}
	$answer = "$question has played for $add";
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	print OUTPUT "This is my confidence score: $score\n\n";
	say ucfirst("$answer");
}
#And so on and so forth. This case is with the movie stars
elsif($question =~ /^Who was in / || $question =~ /^Who is in /) {
	my $score = 0;
	my $answer = '';
	$question =~ s/^Who was in //;
	$question =~ s/^Who is in //;
	@searchterms = ();
	push @searchterms, 'starring';
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);
	
	foreach (@pg) {
		if($_ =~ /$searchterms[0]/) {
			$score += 0.99;
		}
		$_ =~ s/music[\s|\S]*//g;
		$_ =~ s/\Q<!--\E [\s|\S]+ \Q-->\E//g;
		$_ =~ s/\Q<!--\E[\s|\S]+\Q-->\E//g;
		$_ =~ s/<ref\s.*>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\([\s|\S]+\)//g;
		$_ =~ s/\Q<ref>\E.*\Q<\/ref>\E//g;
		$_ =~ s/<ref>[\s|\S]+<\/ref>//g;
		$_ =~ s/\,[a-z][\s|\S]+\,//g;
		$_ =~ s/\[[\s|\S]+\]//g;
		$_ =~ s/\<\/ref\>//g;
		$_ =~ s/[\s|\S]+\sstarring//g;
		$_ =~ s/\}\}[\s|\S]+//g;
		$_ =~ s/[\s|\S]+\|//g;

		print OUTPUT "Potential answer: $_\n\n";
		print OUTPUT "Confidence score: $score\n\n";

		if($_ =~ /\*/) {
			$_ =~ s/\* //g;	
			my @arr = split(/\n/,$_);
			my $size = @arr;
			my $counter = 0;
			foreach my $loop (@arr) {
				if($counter == 0) {
					$counter++;
				}
				elsif($counter == 1) {
					$add = $add . " " . $loop;
					$counter++;
				}
				elsif($counter == $size - 1) {
					$add = $add . ", and " . $loop;
				}
				elsif($counter < $size) {
					$add = $add . ", " . $loop;
					$counter++;
				}
			}
		}
		
	}
	if($score == 0) {
		goto START;
	}
	print OUTPUT "This is the answer I'm going with: $add\n\n";
	$answer = "$question features$add";
	$answer =~ s/\s+$/\./;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	print OUTPUT "This is my confidence score: $score\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^What /) {
	my $score = 0;
	$question =~ s/^What is a //;
	$question =~ s/^What is an //;
	$question =~ s/^What is //;
	$question =~ s/^What are //;
	$question =~ s/^What was the //;
	@searchterms = ();
	push @searchterms, 'is';
	push @searchterms, 'was';
	push @searchterms, 'a';
	push @searchterms, 'an';
	push @searchterms, 'are';
	push @searchterms, 'the';
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		my $score2 = 0;
        	$_ =~ s/\{[\s|\S]*\}//g;
		$_ =~ s/\}//g;
		$_ =~ s/\Q<!--\E [\s|\S]+ \Q-->\E//g;
		$_ =~ s/\Q<!--\E[\s|\S]+\Q-->\E//g;
		$_ =~ s/<ref\s.*>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\([\s|\S]+\)//g;
		$_ =~ s/\Q<ref>\E.*\Q<\/ref>\E//g;
		$_ =~ s/<ref>[\s|\S]+<\/ref>//g;
		$_ =~ s/\,[a-z][\s|\S]+\,//g;

		
		if($_ =~ /\'.+\'/) {
			$score2 += 0.13
		}
		if($_ =~ /\s$searchterms[0]\s/) {
			$score2 += 0.13
		}
		if($_ =~ /\s$searchterms[1]\s/) {
			$score2 += 0.13
		}
		if($_ =~ /\s$searchterms[2]\s/) {
			$score2 += 0.13
		}
		if($_ =~ /\s$searchterms[3]\s/) {
			$score2 += 0.13
		}
		if($_ =~ /\s$searchterms[4]\s/) {
			$score2 += 0.13
		}
		if($_ =~ /\s$searchterms[5]\s/) {
			$score2 += 0.13
		}

		print OUTPUT "Potential answer: $_\n\n";
		print OUTPUT "Confidence score: $score2\n\n";

		if($_ =~ /\'.+\'/) {		
		$_ =~ s/\'.+\' \([\s|\S]+\) is a/$question is a/;
      	 	$_ =~ s/\'.+\' \([\s|\S]+\) was a/$question was a/;
		$_ =~ s/\'.+\' \([\s|\S]+\) is /$question is /;
      	 	$_ =~ s/\'.+\' \([\s|\S]+\) was /$question was /;
		$_ =~ s/\'.+\' \([\s|\S]+\) are /$question are /;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
	
			if($score2 > $score) {
				$add = $_;
				$score = $score2;
				print OUTPUT "This is the answer I'm going with: $add\n\n";
			} 

		}
	}
	if($score == 0) {
		goto START;
	}
	if($score >= 1) {
		$score = 0.99;
	}		
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my final answer: $answer\n\n";
	print OUTPUT "This is my confidence score: $score\n\n";
	say ucfirst("$answer");
}

elsif($question =~ /^Who /) {
	my $score = 0;
	$question =~ s/^Who is //;
	$question =~ s/^Who was //;
	@searchterms = ();
	push @searchterms, 'is';
	push @searchterms, 'was';
	push @searchterms, 'the';
	push @searchterms, 'an';
	push @searchterms, 'a';
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		my $score2 = 0;
        	$_ =~ s/\{[\s|\S]*\}//g;
		$_ =~ s/\}//g;
		$_ =~ s/\Q<!--\E [\s|\S]+ \Q-->\E//g;
		$_ =~ s/\Q<!--\E[\s|\S]+\Q-->\E//g;
		$_ =~ s/<ref\s.*>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\([\s|\S]+\)//g;
		$_ =~ s/\Q<ref>\E.*\Q<\/ref>\E//g;
		$_ =~ s/<ref>[\s|\S]+<\/ref>//g;
		$_ =~ s/\,[a-z][\s|\S]+\,//g;

		if($_ =~ /\'.+\'/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[0]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[1]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[2]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[3]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[4]\s/) {
			$score2 += 0.15
		}

		print OUTPUT "Potential answer: $_\n\n";
		print OUTPUT "Confidence score: $score2\n\n";
				
		if($_ =~ /\'.+\'/) {		
		$_ =~ s/\'.+\' \([\s|\S]+\) is a/$question is a/;
      	 	$_ =~ s/\'.+\' \([\s|\S]+\) was a/$question was a/;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
	
	
			if($score2 > $score) {
				$add = $_;
				$score = $score2;
				print OUTPUT "This is the answer I'm going with: $add\n\n";
			} 

		}
	}
	if($score == 0) {
		goto START;
	}
	if($score >= 1) {
		$score = 0.99;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	print OUTPUT "This is my confidence score: $score\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^Where /) {
	my $score = 0;
	$question =~ s/^Where did the //;
	$question =~ s/^Where did //;
	$question =~ s/^Where is the //;
	$question =~ s/^Where was the //;
	$question =~ s/^Where are the //;
	$question =~ s/^Where is //;
	$question =~ s/^Where was //;
	$question =~ s/^Where are //;
	$question =~ s/ the //;
	$question =~ s/ located//;
	$question =~ s/ at//;
	$question =~ s/ occur//;
	$question =~ s/ happen//;
	$question =~ s/ take place//;
	$question =~ s/ transpire//;
	@searchterms = ();
	push @searchterms, 'is';
	push @searchterms, 'was';
	push @searchterms, 'located';
	push @searchterms, 'are';
	push @searchterms, 'in';
	push @searchterms, 'at';
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		$_ =~ s/\{[\s|\S]*\}//g;
		$_ =~ s/\}//g;
		$_ =~ s/\Q<!--\E [\s|\S]+ \Q-->\E//g;
		$_ =~ s/\Q<!--\E[\s|\S]+\Q-->\E//g;
		$_ =~ s/<ref\s.*>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\([\s|\S]+\)//g;
		$_ =~ s/\Q<ref>\E.*\Q<\/ref>\E//g;
		$_ =~ s/<ref>[\s|\S]+<\/ref>//g;
		$_ =~ s/\,[a-z][\s|\S]+\,//g;
		my $score2 = 0;
		
		if($_ =~ /\'.+\'/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[0]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[1]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[2]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[3]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[4]\s/) {
			$score2 += 0.15
		}
		if($_ =~ /\s$searchterms[5]\s/) {
			$score2 += 0.15
		}	

		print OUTPUT "Potential answer: $_\n\n";
		print OUTPUT "Confidence score: $score2\n\n";	
		if($_ =~ /\'.+\'/) {
		$_ =~ s/\.\s[\s|\S]*/\./; 		
		$_ =~ s/occurred\s[\s|\S]+\sin/occurred in/g;
		$_ =~ s/took place\s[\s|\S]+\sin/took place in/g;
		$_ =~ s/transpired\s[\s|\S]+\sin/transpired in/g;
		$_ =~ s/happened\s[\s|\S]+\sin/happened in/g;		
		$_ =~ s/is\s[\s|\S]+\sin/is in/g;
		$_ =~ s/was\s[\s|\S]+\sin/was in/g;
		$_ =~ s/was\s[\s|\S]+\sat/was at/g;
		$_ =~ s/\, [a-z][\s|\S]*//;		
		$_ =~ s/\n/ /g;
	
	
			if($score2 > $score) {
				$add = $_;
				$score = $score2;
				print OUTPUT "This is the answer I'm going with: $add\n\n";
			} 

		}
	}
	if($score == 0) {
		goto START;
	}
	if($score >= 1) {
		$score = 0.99;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	print OUTPUT "This is my confidence score: $score\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When was / && $question =~ /born/) {
	my $score = 0;
	$question =~ s/^When was //;
	$question =~ s/ born//;
	@searchterms = ();
	push @searchterms, 'born';
	push @searchterms, 'date of birth';
	push @searchterms, 'birthday';
	push @searchterms, 'birth';	

	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		my $score2 = 0;
        	$_ =~ s/\{[\s|\S]*\}//g;
		$_ =~ s/\}//g;
		$_ =~ s/\Q<!--\E [\s|\S]+ \Q-->\E//g;
		$_ =~ s/\Q<!--\E[\s|\S]+\Q-->\E//g;
		$_ =~ s/<ref\s.*>//g;
		$_ =~ s/\Q<ref>\E.*\Q<\/ref>\E//g;
		$_ =~ s/<ref>[\s|\S]+<\/ref>//g;
		$_ =~ s/\,[a-z][\s|\S]+\,//g;

		if($_ =~ /\'.+\'/) {
			$score2 += 0.2
		}
		if($_ =~ /\s$searchterms[0]\s/) {
			$score2 += 0.2
		}
		if($_ =~ /\s$searchterms[1]\s/) {
			$score2 += 0.2
		}
		if($_ =~ /\s$searchterms[2]\s/) {
			$score2 += 0.2
		}
		if($_ =~ /\s$searchterms[3]\s/) {
			$score2 += 0.2
		}

		print OUTPUT "Potential answer: $_\n\n";
		print OUTPUT "Confidence score: $score2\n\n";

		if($_ =~ /\'.+\'/) {
		$_ =~ s/[\s|\S]*\([\s|\S]*born/$question was born on/;
		$_ =~ s/\)[\s|\S]*/\./;
		$_ =~ s/[\s|\S]*\(/$question was born on/;
		$_ =~ s/\n/ /g; 
	
			if($score2 > $score) {
				$add = $_;
				$score = $score2;
				print OUTPUT "This is the answer I'm going with: $add\n\n";
			} 

		}
	}
	if($score == 0) {
		goto START;
	}
	if($score >= 1) {
		$score = 0.99;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	print OUTPUT "This is my confidence score: $score\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When /) {
	my $score = 0;
	$question =~ s/^When is //;
	$question =~ s/^When was the //;
	$question =~ s/^When was //;
	$question =~ s/^When did the //;
	$question =~ s/^When did //;
	$question =~ s/ take place//;
	$question =~ s/ occur//;
	$question =~ s/ transpire//;
	$question =~ s/ happen//;
	@searchterms = ();
	push @searchterms, 'is';
	push @searchterms, 'was';
	push @searchterms, 'in';
	push @searchterms, 'occurred';
	push @searchterms, 'took place';
	push @searchterms, 'transpired';
	push @searchterms, 'began';
	push @searchterms, 'started';
	push @searchterms, 'finished';
	push @searchterms, 'ended';
	push @searchterms, 'over';
	push @searchterms, 'between';
	push @searchterms, 'held on';
	push @searchterms, 'observed';
	push @searchterms, 'happened';
	push @searchterms, 'celebrated';
	push @searchterms, 'lasted';
	push @searchterms, 'from';
	push @searchterms, 'until';
	push @searchterms, 'played on';
	push @searchterms, 'during';

	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		my $score2 = 0;
        	$_ =~ s/\{[\s|\S]*\}//g;
		$_ =~ s/\}//g;
		$_ =~ s/\Q<!--\E [\s|\S]+ \Q-->\E//g;
		$_ =~ s/\Q<!--\E[\s|\S]+\Q-->\E//g;
		$_ =~ s/<ref\s.*>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\([\s|\S]+\)//g;
		$_ =~ s/\Q<ref>\E.*\Q<\/ref>\E//g;
		$_ =~ s/<ref>[\s|\S]+<\/ref>//g;
		$_ =~ s/\,[a-z][\s|\S]+\,//g;

		if($_ =~ /\'.+\'/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[0]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[1]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[2]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[3]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[4]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[5]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[6]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[7]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[8]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[9]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[10]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[11]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[12]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[13]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[14]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[15]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[16]\s/) {
			$score2 += 0.05
		}		
		if($_ =~ /\s$searchterms[17]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[18]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[19]\s/) {
			$score2 += 0.05
		}
		if($_ =~ /\s$searchterms[20]\s/) {
			$score2 += 0.05
		}

		print OUTPUT "Potential answer: $_\n\n";
		print OUTPUT "Confidence score: $score2\n\n";

		if($_ =~ /\'.+\'/) {

		$_ =~ s/\s[\s|\S]+\sbegan on/$question began on/g;
		$_ =~ s/is\s[\s|\S]+\scelebrated on/is celebrated on/g; 		
		$_ =~ s/\s[\s|\S]+\sstarted/$question started/g;		
		$_ =~ s/\s[\s|\S]+\splayed on/$question was played on/g;
		$_ =~ s/\s[\s|\S]+\slasted from/$question took place from/g;
		$_ =~ s/[\s|\S]*held on/$question is held on/;
		$_ =~ s/[\s|\S]*observed annually /$question is held /;
		$_ =~ s/[\s|\S]*is on/$question is held on/;
		$_ =~ s/[\s|\S]*happened on/$question is held on/;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\, [a-z][\s|\S]*\,//;
		$_ =~ s/\n/ /g; 
	
			if($score2 > $score) {
				$add = $_;
				$score = $score2;
				print OUTPUT "This is the answer I'm going with: $add\n\n";
			} 

		}
	}
	if($score == 0) {
		goto START;
	}
	if($score >= 1) {
		$score = 0.99;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	print OUTPUT "This is my confidence score: $score\n\n";
	say ucfirst("$answer");
}

#This is where my flag jumps to. Restarts the asking process. 
else {
	START:
	say "I am sorry, I'm afraid I do not know the answer to that.";
}
}

close OUTPUT;
