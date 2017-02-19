#Jordan Tang
#CS416
#April 18, 2016
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
#Output: Question: What is Perl
#Output: Search term: Perl
#Output: Raw wiki data: ........
#Algorithm: I began by setting up the Wikipedia module, and taking user input. Whatever the user input was, I'd dissect it to find the subject matter. I then had several different regex options for questions of the Who, What, When, Where variety. If a user query matched one of the options, I then checked the found Wikipedia article for a certain pattern and set the output appropriately if the pattern was matched. If not, then no answer is given. Note: code is fairly repetitive, so most comments will be at the beginning.  
    
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
my $babyflag = 0;

#This is what loops until the user decides to exit
while($question ne $flag) {
$question = "";
$answer = "";
$add = "";
$doc = "";
my @pg = ();
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
#First kind of question: who was
elsif($question =~ /^Who was/) {
	#The general breakdown, dissect the question for the subject matter
	$question =~ s/Who was //;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	#If the result is found in Wikipedia, return the article	
	if ( $result->text() ) { 
		$doc = $result->text();                  
	}
	print OUTPUT "Raw wiki data: $doc\n";
	#I chose to divide the article from where newline breaks were found. So I had a couple chunks for each article essentially and would look through the ones that matched the data I was looking for. 
	@pg = split(/\n\n/, $doc);
	
	#Going through each piece
	foreach (@pg) {
		#This gets rid of the garbage formatting at the beginning of each article
        	$_ =~ s/\{[\s|\S]*\}//g;
		
		#If a pattern is matched, then I remove from the piece the stuff I don't need and keep what I do need		
		if($_ =~ /\'.+\' [\s|\S]* was/) {
		$_ =~ s/\'.+\' \([\s|\S]+\) was/$question was/;
		$_ =~ s/<ref[\s|\S]*\/ref>//g; #These ref tags gave me a lot of problems
		$_ =~ s/\([\s|\S]*\)//g; #Same with stuff in parenthesis
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'.*/) {
		$_ =~ s/\'.+\'[\s|\S]* was/$question was/;
		$_ =~ s/<ref[\s|\S]*\/ref>//g;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		#If no pattern is matched, then I have a flag so that I can jump to my default "no answer is found" answer
		else {
		$babyflag = 1;
		}
	}
	#Here is where the jump occurs. See the end of the code for that part. 
	if($babyflag == 1) {
		goto START;
	}
	#If an answer is found than I output it and correct spacing below. 
	$answer = $add;
	$answer =~ s/^ //;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
#And the above is repeated for the rest of my cases with slight variations
elsif($question =~ /^Who is/) {
	$question =~ s/Who is //;
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
		$_ =~ s/\<ref name\=\"[\s|\S]*\"\>//g;
		
		if($_ =~ /\'.+\'\([\s|\S]* (is|was)/) {
		$_ =~ s/<ref[\s|\S]*\/ref>//g;
		$_ =~ s/\'.+\' \([\s|\S]+\) is a/$question is a/;
		$_ =~ s/\'.+\' \([\s|\S]+\) was a/$question was a/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\n/ /g;
		$add = $_;
		$babyflag = 0;
		last;
		}	
		elsif($_ =~ /\'.+\' \([\s|\S]* (is|was)/) {
		$_ =~ s/\'.+\' \([\s|\S]+\) is a/$question is a/;
		$_ =~ s/\'.+\' \([\s|\S]+\) was a/$question was a/;
		$_ =~ s/<ref>//g;
		$_ =~ s/<\/ref>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\([\s|\S]+\)//g;
		$_ =~ s/\<ref\s.*\>//g; 
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}	
		elsif($_ =~ /\'.+\' [\s|\S]* is/) {
		$_ =~ s/\'.+\' \([\s|\S]+\) is a/$question is a/;
		$_ =~ s/\'.+\' \([\s|\S]+\) was a/$question was a/;
		$_ =~ s/<ref[\s|\S]*\/ref>//g;
		$_ =~ s/\([\s|\S]*\)//g; 
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'.*/) {
		$_ =~ s/\'.+\'[\s|\S]* is a/$question is a/;
		$_ =~ s/\'.+\'[\s|\S]* was a/$question was a/;
		$_ =~ s/<ref[\s|\S]*\/ref>//g;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^What is a /) { 
	$question =~ s/What is a //;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}
	print OUTPUT "Raw wiki data: $doc\n";	
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		if($_ =~ /[\s|\S]+ \'.+\' is /) {
		$_ =~ s/\{[\s|\S]+\}//;
		$_ =~ s/[\s|\S]+ \'$question\' is /A $question is /; 
		$_ =~ s/\(.*\) //;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /A \'.+\' (\(.*\))? is /) {
		$_ =~ s/[\s|\S]* \'.+\' is /A $question is /; 
		$_ =~ s/\(.*\) //;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /A \'.+\'\,[\s|\S]*\, is /) {
		$_ =~ s/\,(.*)\, is/ is/;
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /A \'.+\' is /) {
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\(.*\) //;
		$_ =~ s/\n/ /g; 
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^What is an /) { 
	$question =~ s/What is an //;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}	
	print OUTPUT "Raw wiki data: $doc\n";
	@pg = split(/\n\n/, $doc);

	
	foreach (@pg) {
		$_ =~ s/\{[\s|\S]*\}//g;
		$_ =~ s/[\s|\S]+An \'.+\'/An $question/;
		
		if($_ =~ /[\s|\S]+ \'.+\' is /) {
		$_ =~ s/\{[\s|\S]+\}//;
		$_ =~ s/[\s|\S]+ \'$question\' is /An $question is /; 
		$_ =~ s/\(.*\) //;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /An \'.+\' (\(.*\))? is /) {
		$_ =~ s/[\s|\S]* \'.+\' is /An $question is /; 
		$_ =~ s/\(.*\) //;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /An \'$question\'\, /) {
		$_ =~ s/[\s|\S]* \'.+\' is /An $question is /; 
		$_ =~ s/\(.*\) //;
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\, \([\s|\S]*\)//;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /An \'.+\'\,[\s|\S]*\, is /) {
		$_ =~ s/\,(.*)\, is/ is/;
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /An \'.+\' is /) {		
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\(.*\) //;
		$_ =~ s/\n/ /g; 
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\' [\s|\S]* is /) {	
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\(.*\) //;
		$_ =~ s/\n/ /g; 
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /An \'.+\' [\s|\S]* is /) {		
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\(.*\) //;
		$_ =~ s/\n/ /g; 
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /[an|An] $question /) {
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\(.*\) //;
		$_ =~ s/\n/ /g; 
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^What is/) { 
	$question =~ s/What is //;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}	
	print OUTPUT "Raw wiki data: $doc\n";
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
		if($_ =~ /\'.+\' is /) {
		$_ =~ s/[\s|\S]* \'.+\' is /$question is /; 
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\' \([\s|\S]*\) is /) {
		$_ =~ s/\'.+\' \([\s|\S]*\) is /$question is /;
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'\,[\s|\S]* is /) {
		$_ =~ s/\<\!\-\-[\s|\S]*\-\-\>//g;
		$_ =~ s/\(.*\)//g; 
		$_ =~ s/[\s|\S]* \'.+\'\,[\s|\S]* is /$question is /;
		$_ =~ s/\.[\s|\S]*/\./; 
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When is /) {
	$question =~ s/When is //;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}	
	print OUTPUT "Raw wiki data: $doc\n";
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
        	$_ =~ s/\{[\s|\S]*\}//g;
				
		if($_ =~ /\'.+\'/ && $_ =~ / held on /) {
		$_ =~ s/[\s|\S]*held on/is held on/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]+/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ /observed/) {
		say "cases";
		$_ =~ s/[\s|\S]*observed annually /is held /;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]+/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / is on /) {
		$_ =~ s/[\s|\S]*is on/is held on/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]+/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / happened /) {
		$_ =~ s/[\s|\S]*happened on/is held on/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]+/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ /celebrated/) {
		$_ =~ s/[\s|\S]*celebrated on/is celebrated on/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]+/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $question . " " . $add;
	$answer =~ s/^ //;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When was /) {
	$question =~ s/When was //;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}	
	print OUTPUT "Raw wiki data: $doc\n";
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
        	$_ =~ s/\{[\s|\S]*\}//g;
				
		if($_ =~ /\'.+\'/ && $_ =~ / began on /) {
		$_ =~ s/[\s|\S]* began on/began on/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / started /) {
		$_ =~ s/[\s|\S]* started/started/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / lasted from /) {
		$_ =~ s/[\s|\S]* lasted from/lasted from/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / played on /) {
		$_ =~ s/[\s|\S]* was played on/was played on/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / in the [0-9]+[s]?/) {
		$_ =~ s/[\s|\S]* in the/in the/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = " occurred" . $_;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $question . " " . $add;
	$answer =~ s/^ //;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When did the .* (begin|start|occur)/) {
	$question =~ s/When did the //;
	$question =~ s/(begin|start|occur)//;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}	
	print OUTPUT "Raw wiki data: $doc\n";
	@pg = split(/\n\n/, $doc);

	foreach (@pg) {
        	$_ =~ s/\{[\s|\S]*\}//g;
				
		if($_ =~ /\'.+\'/ && ($_ =~ /(began|started) (on|in)/) || ($_ =~ /lasted from/) || ($_ =~ /(place|occurred) between/) || ($_ =~ / [F|f]rom /) || ($_ =~ /beginning (on|in)/)) {
		$_ =~ s/[\s|\S]* began on/began on/;
		$_ =~ s/[\s|\S]* began in/began in/;
		$_ =~ s/[\s|\S]* beginning on/began on/;
		$_ =~ s/[\s|\S]* beginning in/began in/;
		$_ =~ s/[\s|\S]* started on/started on/;
		$_ =~ s/[\s|\S]* started in/started in/;
		$_ =~ s/[\s|\S]* lasted from/began on/;
		$_ =~ s/[\s|\S]* place between/began on/;
		$_ =~ s/[\s|\S]* occurred between/began on/;
		$_ =~ s/[\s|\S]* [F|f]rom/began on/;
		$_ =~ s/\sand\s/\./g;
		$_ =~ s/\sto\s/\./g;
		$_ =~ s/\s\-\s/\./g;
		$_ =~ s/\.[\s|\S]*/\./; 
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = "The " . $question . $add;
	$answer =~ s/^ //;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When did .* (begin|start)/) {
$question =~ s/When did //;
$question =~ s/(begin|start)//;
	print OUTPUT "Search term: $question\n";
	my $result = $wiki->search($question);
	if ( $result->text() ) { 
         $doc = $result->text();        
	}	
	print OUTPUT "Raw wiki data: $doc\n";
	@pg = split(/\n\n/, $doc);
	
	foreach (@pg) {
        	$_ =~ s/\{[\s|\S]*\}//g;
				
		if($_ =~ /\'.+\'/ && ($_ =~ /(began|started) (on|in)/) || ($_ =~ /lasted from/) || ($_ =~ /(place|occurred) between/) || ($_ =~ / [F|f]rom /)) {
		$_ =~ s/[\s|\S]* lasted from/began on/;c		
		$_ =~ s/[\s|\S]* began on/began on/;
		$_ =~ s/[\s|\S]* began in/began in/;
		$_ =~ s/[\s|\S]* started on/started on/;
		$_ =~ s/[\s|\S]* started in/started in/;
		$_ =~ s/[\s|\S]* place between/began on/;
		$_ =~ s/[\s|\S]* occurred between/began on/;
		$_ =~ s/[\s|\S]* [F|f]rom/began on/;
		$_ =~ s/\sand\s/\./g;
		$_ =~ s/\sto\s/\./g;
		$_ =~ s/\.[\s|\S]*/\./; 
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $question . $add;
	$answer =~ s/^ //;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When did the .* (end|finish|conclude)/) {
$question =~ s/When did the //;
$question =~ s/(end|finish|conclude)//;
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
				
		if($_ =~ /\'.+\'/ && ($_ =~ /(ended|finished|concluded) (on|in)/ || $_ =~ /lasted until/ || $_ =~ /(lasted|lasting) from/ || $_ =~ / between [0-9]+/)) {
		$_ =~ s/[\s|\S]*\slasted until/ended in/;
		$_ =~ s/[\s|\S]*\slasted from/ended on/;
		$_ =~ s/[\s|\S]* ended on/ended on/;
		$_ =~ s/[\s|\S]* ended in/ended in/;
		$_ =~ s/[\s|\S]* finished on/finished on/;
		$_ =~ s/[\s|\S]* finished in/finished in/;
		$_ =~ s/[\s|\S]* concluded on/concluded on/;
		$_ =~ s/[\s|\S]* concluded in/concluded in/;
		$_ =~ s/[\s|\S]* between [0-9]+ and/concluded in/;
		$_ =~ s/[\s|\S]*[0-9]+\sto/ended in/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]*/\./; 
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = "The " . $question . $add;
	$answer =~ s/^ //;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^When did .* (end|finish|conclude)/) {
$question =~ s/When did //;
$question =~ s/(end|finish|conclude)//;
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
				
		if($_ =~ /\'.+\'/ && ($_ =~ /(ended|finished|concluded) (on|in)/ || $_ =~ /lasted until/ || $_ =~ /(lasted|lasting) from/ || $_ =~ / between [0-9]+/)) {
		$_ =~ s/[\s|\S]*\slasted until/ended in/;
		$_ =~ s/[\s|\S]*\slasted from/ended on/;
		$_ =~ s/[\s|\S]* ended on/ended on/;
		$_ =~ s/[\s|\S]* ended in/ended in/;
		$_ =~ s/[\s|\S]* finished on/finished on/;
		$_ =~ s/[\s|\S]* finished in/finished in/;
		$_ =~ s/[\s|\S]* concluded on/concluded on/;
		$_ =~ s/[\s|\S]* concluded in/concluded in/;
		$_ =~ s/[\s|\S]* between [0-9]+ and/concluded in/;
		$_ =~ s/[\s|\S]*[0-9]+\sto/ended in/;
		$_ =~ s/\.[\s|\S]*/\./;
		$_ =~ s/\,[\s|\S]*/\./; 
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $question . $add;
	$answer =~ s/^ //;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^Where did the/) {
	$question =~ s/Where did the //;
	$question =~ s/ (occur|happen|take place|transpire)//;
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
		
		if($_ =~ /\'.+\'/ && $_ =~ / held /) {
		$_ =~ s/[\s|\S]* held in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / began / && $_ =~ / in /) {
		$_ =~ s/[\s|\S]* in /located in /;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / was / && ($_ =~ / at / || $_ =~ / in /)) {
		$_ =~ s/[\s|\S]* at/located in/;
		$_ =~ s/[\s|\S]* in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = "The " . $question . " was " . $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^Where did/) {
	$question =~ s/Where did //;
	$question =~ s/ (occur|happen|take place|transpire)//;
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
		
		if($_ =~ /\'.+\'/ && $_ =~ / held /) {
		$_ =~ s/[\s|\S]* held in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / began / && $_ =~ / in /) {
		$_ =~ s/[\s|\S]* in /located in /;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / was / && ($_ =~ / at / || $_ =~ / in /)) {
		$_ =~ s/[\s|\S]* at/located in/;
		$_ =~ s/[\s|\S]* in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}	
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $question . " was " . $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^Where is the/) {
	$question =~ s/Where is the//;
	$question =~ s/ (located|at)//;
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
		
		if($_ =~ /\'.+\'/ && $_ =~ /located in/) {
		$_ =~ s/[\s|\S]*located in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}	
		elsif($_ =~ /\'.+\'/ && ($_ =~ /(city|country|[S|s]ituated) in/)) {
		$_ =~ s/[\s|\S]* city in/located in/;
		$_ =~ s/[\s|\S]* country in/located in/;
		$_ =~ s/[\s|\S]* [S|s]ituated in/located in/;
		$_ =~ s/<ref[\s|\S]*\/ref>//g;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / in / && $_ =~ / is /) {
		$_ =~ s/[\s|\S]* in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = "The" . $question . " is " . $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^Where is /) {
	$question =~ s/Where is //;
	$question =~ s/ (located|at)//;
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
		
		if($_ =~ /\'.+\'/ && $_ =~ /located in/) {
		$_ =~ s/[\s|\S]*located in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 	
		$add = $_;
		$babyflag = 0;
		last;
		}	
		elsif($_ =~ /\'.+\'/ && ($_ =~ /(city|country|[S|s]ituated) in/)) {
		$_ =~ s/[\s|\S]* city in/located in/;
		$_ =~ s/[\s|\S]* country in/located in/;
		$_ =~ s/[\s|\S]* [S|s]ituated in/located in/;
		$_ =~ s/<ref[\s|\S]*\/ref>//g;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\. [\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ /within/) {
		$_ =~ s/[\s|\S]*within/located in/;
		$_ =~ s/<ref[\s|\S]*\/ref>//g;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / in / && $_ =~ / is /) {
		$_ =~ s/\.\s[\s|\S]*/\./;		
		$_ =~ s/[\s|\S]*\sin/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}	
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $question . " is " . $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^Where was the/) {
	$question =~ s/Where was the //;
	$question =~ s/ (located|at)//;
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
		
		if($_ =~ /\'.+\'/ && $_ =~ / held /) {
		$_ =~ s/[\s|\S]* held in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / began / && $_ =~ / in /) {
		$_ =~ s/[\s|\S]* in /located in /;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / was / && ($_ =~ / at / || $_ =~ / in /)) {
		$_ =~ s/[\s|\S]* at/located in/;
		$_ =~ s/[\s|\S]* in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = "The " . $question . " was " . $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
elsif($question =~ /^Where was/) {
	$question =~ s/Where was //;
	$question =~ s/ (located|at)//;
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
		
		if($_ =~ /\'.+\'/ && $_ =~ / held /) {
		$_ =~ s/[\s|\S]* held in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g;
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / began / && $_ =~ / in /) {
		$_ =~ s/[\s|\S]* in /located in /;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g;	
		$add = $_;
		$babyflag = 0;
		last;
		}
		elsif($_ =~ /\'.+\'/ && $_ =~ / was / && ($_ =~ / at / || $_ =~ / in /)) {
		$_ =~ s/[\s|\S]* at/located in/;
		$_ =~ s/[\s|\S]* in/located in/;
		$_ =~ s/\<ref\s.*\>//g;
		$_ =~ s/\(.*\)//g;
		$_ =~ s/\Q<ref>\E//g;
		$_ =~ s/\Q<\/ref>\E//g;
		$_ =~ s/\.\s[\s|\S]*/\./;
		$_ =~ s/\,\s[\s|\S]*/\./;
		$_ =~ s/\n/ /g; 
		$add = $_;
		$babyflag = 0;
		last;
		}	
		else {
		$babyflag = 1;
		}
	}
	if($babyflag == 1) {
		goto START;
	}
	$answer = $question . " was " . $add;
	$answer =~ s/^\s*//;
	print OUTPUT "This is my answer: $answer\n\n";
	say ucfirst("$answer");
}
#This is where my flag jumps to. Restarts the asking process. 
else {
	START:
	$babyflag = 0;
	say "I am sorry, I'm afraid I do not know the answer to that.";
}
}

close OUTPUT;
