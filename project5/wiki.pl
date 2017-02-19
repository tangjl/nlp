      use WWW::Wikipedia;
      my $wiki = WWW::Wikipedia->new();

      ## search for 'perl' 
      my $result = $wiki->search( 'manhattan project' );

	print "ITS WORKING";
      ## if the entry has some text print it out
      if ( $result->text() ) { 
          print $result->text();
      }

