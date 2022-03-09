use Mojolicious::Lite;

get '/' => sub{
	my $self = shift;
	$self->render(text => 'My App');
};

get '/ping' => sub{
	my $self = shift;

	if (system qq((ping http://127.0.0.1/")) == 0){
		$self->render(text => '200 OK');
	}
	else {
		$self->render(text => 'Error!! Ping cmd failed.');
	}
};

get '/wordfinder/' => sub{
	my $self = shift;
	$self->render(text => 'Search word required!');
};


get '/wordfinder/:search_word' => sub{
	my $self = shift;
	my $search_word = $self->param('search_word');

	if (not defined $search_word) {
		$self->render(text => 'Search word required!');
	}
	else {
		my @search_word = split //, $search_word;
		my %word_hash;
		my %dict;

		my @list = (0..$#search_word);
		my $list = join ("," , @list);
		my %count;

		my @valid_final_words;

		open WORDS, "/usr/share/dict/words" or die "can't open words file\n";
		while (<WORDS>) {
		    chomp;
		    $dict{$_} = 1;
		}

		my %pertmutations_hash;

		for (my $i=scalar(@search_word); $i>0; $i--){

		    %pertmutations_hash = map { $_ => 1 } glob "{$list}" x $i;
		    foreach my $key ( keys %pertmutations_hash ) {
		        #print "$key\n";
		        my @index = split //, $key;
		        for(my $i=0; $i<scalar(@index);$i++){
		           my $value = $index[$i];
		           if (defined $search_word[$value]) {
		             $word_hash{$key} .= $search_word[$value];
		           }
		        }

		        if (exists($dict{$word_hash{$key}})) {
		            my $word = $word_hash{$key};
		            my @dict_word = split //, $word_hash{$key};
		            my $dict_word = join ("," , @dict_word);

		            foreach my $str (split /,/, $dict_word) {
		                $count{$word}{$str}++;
		                if ($count{$word}{$str} > 1){
		                  delete $word_hash{$key};
		                }
		            }

		            if (defined $word_hash{$key}) {
		                push (@valid_final_words, $word_hash{$key});
		            }
		        }
		    }
		}

		$self->render( json => {
        "word_list" => \@valid_final_words,
    });
	}
};

app->start;
