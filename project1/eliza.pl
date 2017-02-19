#Jordan Tang
#CS416
#February 8th, 2016
#Summary: the following program is designed to simulate a psychotherapist and will engage in simple dialogue with the user. The program takes keywords from the user's input and picks out default responses. 
#Instructions: to use the following program, simply respond to the program in the terminal with clear input and complete sentences. To exit the program, simply type "quit".  
#Example of output and input(output = A, input = B):
#A: Hi, I'm a psychotherapist. To begin, please enter your first name.
#B: Jordan.
#A: Hello Jordan, what would you like to talk about today?
#B: I want to rule the nation.
#A: Why do you want to rule the nation?
#B: I don't know, I think I crave power.
#A: Ah yes, tell me more about your cravings
#B: I am always hungry.
#A: Why are you always hungry?
#B: I have too many problems.
#A: Why do you have too many problems?
#B: quit
#A: Thank you for talking with me. I hope to see you again soon! 
#Algorithm: Before I even began, I went and tried some Eliza samples on the web to guage their responses and what they generally picked up on. After familiarizing myself with syntax, most of the work was just organization as well as a lot of testing to find new words/faults in the program. I began compiling a list of popular key words that I would include. I then set up the opening question and figured how to take, alter, and store input. I came up with a quit key to exit the program when the user finishes and also made a statement to check if the user's input was empty. I decided to go with a while loop as it was up to the user to end the program when they choose to. I came up with some default statements to handle any gibberish or anything the program didn't have in its bank of keywords. I then began some simple word swapping, then moved on to general keywords and then more specific keywords. The program essentially takes user input and goes through several banks of keywords set to a certain priority level. Once it finds one it executes the statement. If nothing is found the program generates a random default statement. This continutes with the user giving more input until the user inputs 'quit'. 
 
use 5.010;
use strict;
use warnings;

#INTRODUCTION:  
say "Hi, I'm a psychotherapist. To begin, please enter your first name.";

#Input is taken and stored in variable name, where it is then stripped of punctuation and lowercased for future use. 
my $name = <STDIN>;
chomp $name;
my $lcname = lc($name);
$lcname =~ s/[[:punct:]]//g;
#The propername variable will be what is used throughout the program later to reference the user.
my $propername = ucfirst($lcname);

#This will serve to exit the program if the user inputs quit, or any variation of quit(such as QUIT, QuIt, Q.u.i.t, quit!!!)
if($lcname eq "quit") { 
	say "Thank you for talking with me. I hope to see you again soon!";
	exit;
}

#This while loop ensures the user hasn't just pressed enter or filled the input with just whitespace. It will continue to prompt the user until legitimate input is given.
while($name =~ /^\s*$/)  { 
	say "I'm sorry, you need to respond for me to understand you. Let's try again.";
	$name = <STDIN>;
	chomp $name;
	$lcname = lc($name);
	$lcname =~ s/[[:punct:]]//g;
	$propername = ucfirst($lcname);
}

#Addressing the user 
say "Hello $propername, what would you like to talk about today?";

#This is just here for the while loop. The value serves no purpose as it will never change, the user chooses when to exit the program. 
my $counter = 10;


while($counter == 10) {

#Same code here as before
my $input = <STDIN>; 
chomp $input;
my $newinput = lc($input);
$newinput =~ s/[[:punct:]]//g;

if($newinput eq "quit") { 
	say "Thank you for talking with me. I hope to see you again soon!";
	exit;
}

if($newinput =~ /^\s*$/)  { 
	say "I'm sorry, you need to respond for me to understand you. Let's try again.";
}

#Each if/elsif statement is ordered by importance, and checks the input to see if a certain keyword is found before executing.

#If the user addresses the eliza program, the program will divert the attention.
if($newinput =~ /\byou\b/)
	{
		say "Let's talk about you $propername, not me. Now go on."; 
	}
#This will handle some pesky words.
elsif($newinput =~ /\b(because|yes|ok|no|maybe)\b/) 
{
		say "Hmmm that's very interesting $propername. I want to hear more.";
}
#This is meant to cover for any questions the user asks. 
elsif($newinput =~ /\b(how|why|what|when|who)\b/)
{
		say "I'm not sure. Sorry I'm not much help, perhaps you could find out yourself?";
}
#Covering some generic and specific emotions. First more negative emotions than more positive ones.
elsif($newinput =~ /\b(sad|mad|tired|depressed|emotional|angry|scared|exhausted|afraid|aggravated|annoyed|bored|confused|displeased|distressed|guilty|jealous|overwhelmed|regretful|resentful|anxious|shameful|troubled|upset|concerned|victimized|unhappy|exposed)\b/) {
	say "That's unfortunate. Let's talk about it $propername.";
}
elsif($newinput =~ /\b(glad|awesome|fantastic|happy|determined|hopeful|optimistic|patient|prideful|relaxed|great|amazing|energetic)\b/) {
	say "That's great! Let's talk about it $propername.";
}
#This elsif statement addresses a lot of popular nouns and gets the user to talk more about them.
elsif($newinput =~ /\b(year|people|thing|life|school|world|family|problem|week|day|company|work|home|money|job|health|death|love|sports|games)\b/) {
		if($newinput =~ /\byear\b/) {
		$newinput = "your year";		
		}
		elsif($newinput =~ /\bpeople\b/) {
		$newinput = "people";
		}
		elsif($newinput =~ /\bthing\b/) {
		$newinput = "the thing";
		}
		elsif($newinput =~ /\blife\b/) {
		$newinput = "life";
		}
		elsif($newinput =~ /\bschool\b/) {
		$newinput = "school";
		}
		elsif($newinput =~ /\bworld\b/) {
		$newinput = "the world";
		}
		elsif($newinput =~ /\bfamily\b/) {
		$newinput = "your family";
		}
		elsif($newinput =~ /\bproblem\b/) {
		$newinput = "this problem";
		}
		elsif($newinput =~ /\bweek\b/) {
		$newinput = "your week";
		}
		elsif($newinput =~ /\bday\b/) {
		$newinput = "your day";
		}
		elsif($newinput =~ /\bcompany\b/) {
		$newinput = "this company";
		}
		elsif($newinput =~ /\bwork\b/) {
		$newinput = "work";
		}
		elsif($newinput =~ /\bhome\b/) {
		$newinput = "home";
		}
		elsif($newinput =~ /\bmoney\b/) {
		$newinput = "money";
		}
		elsif($newinput =~ /\bjob\b/) {
		$newinput = "your job";
		}
		elsif($newinput =~ /\bhealth\b/) {
		$newinput = "your health";
		}
		elsif($newinput =~ /\bdeath\b/) {
		$newinput = "death";
		}
		elsif($newinput =~ /\blove\b/) {
		$newinput = "love";
		}
		elsif($newinput =~ /\bsports\b/) {
		$newinput = "sports";
		}
		elsif($newinput =~ /\bgames\b/) {
		$newinput = "games";
		}
		print "OK can you tell me more about $newinput.\n";
}
#This elsif touches on certain verbs and responds using the verb in its noun counterpart
elsif($newinput =~ /\b(feel|crave|need|know|think|hate)\b/) 
{
		if($newinput =~ /\bfeel\b/) {
		$newinput = "feelings";
		}
		elsif($newinput =~ /\bcrave\b/) {
		$newinput = "cravings";
		}
		elsif($newinput =~ /\bneed\b/) {
		$newinput = "needs";
		}
		elsif($newinput =~ /\bknow\b/) {
		$newinput = "knowledge";
		}
		elsif($newinput =~ /\bthink\b/) {
		$newinput = "thoughts";
		}
		elsif($newinput =~ /\bhate\b/) {
		$newinput = "hatred";
		}
		print "Ah yes, tell me more about your $newinput.\n";		
}
#Verbs, that unlike the ones near the beginning, do not have common noun counterparts.
elsif($newinput =~ /\b(get|make|go|take|see|give|find|like|look|worry)\b/) 
{
		say "Why do you?";
}
#These elsif statements cover a majority of the responses, and transform input from the user. 
elsif($newinput =~ /\b(am|are|is|im|were|its|was|theyre)\b/)
{ 
		$newinput =~ s/i am/Why are you/;
		$newinput =~ s/im/Why are you/;
		$newinput =~ s/we are/Why are you all/;
		$newinput =~ s/were/Why are you all/;
		$newinput =~ s/its/Why is it/;
		$newinput =~ s/i was/Why were you/;
		$newinput =~ s/they are/Why are they/;
		$newinput =~ s/theyre/Why are they/;
		print ucfirst($newinput) . "?\n"; 
}
elsif($newinput =~ /\b(want|have|cant|dont|wont|can not|will not|do not)\b/) 
{ 
		$newinput =~ s/i want/Why do you want/;
		$newinput =~ s/i cant/Why can't you/;
		$newinput =~ s/i dont/Why don't you/;
		$newinput =~ s/i wont/Why won't you/;
		$newinput =~ s/i cannot/Why can't you/;
		$newinput =~ s/i will not/Why won't you/;
		$newinput =~ s/i do not/Why don't you/;
		$newinput =~ s/i have/Why do you have/;
		print "$newinput?\n";
}
elsif($newinput =~ /\b(can|do|will)\b/) 
{
		$newinput =~ s/i can/Why can you/;
		$newinput =~ s/i do/Why do you/;
		$newinput =~ s/i will/Why will you/;
		print "$newinput?\n";
}
#This else statement basically randomizes a bunch of default responses if the program doesn't pick up on any key words. 
else {
		my $randomnumber = int(rand(4));
		if($randomnumber == 0) {
		say "Interesting...tell me more $propername.";
		}	
		elsif($randomnumber == 1) {
		say "$propername, can you elaborate on that please?";
		}
		elsif($randomnumber == 2) {
		say "I'm not quite sure I understand.";
		}
		elsif($randomnumber == 3) {		
		say "Come again?";
		}
		else {
		say "Hmmm can you rephrase that for me $propername?";
		}
	}
}


