package Bestgame::Controller::Root;
use Moose;
use namespace::autoclean;
use utf8;
use Data::Dumper;
use Data::Page::Navigation;
use DateTime;
use DateTime::Format::MySQL;
use DateTime::Format::W3CDTF;
use String::Random;
use Switch;
use LWP::Simple;
use XML::RSS;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Bestgame::Controller::Root - Root Controller for Bestgame

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
	my ( $self, $c ) = @_;
	$c->stash->{pagetitle} = 'BESTGAMEON みんなのゲームランキング';

	$c->stash->{history} = [$c->model('hsksyusk::HISTORY')->search(
		{ draft_flag => 0 },
		{
			order_by => { -desc => 'ranking_create' },
			rows => 5, 
		}
	)];
	
	$c->stash->{famous} = [$c->model('hsksyusk::GOOD')->search(
		{ 'draft_flag_to_userid.draft_flag' => 0 },
		{
			join => 'draft_flag_to_userid',
			select => ['to_userid',{ count => 'to_userid' },'draft_flag_to_userid.draft_flag'],
			as => ['to_userid','count_good','draft_flag_to_userid.draft_flag'],
			group_by => ['to_userid'],
			order_by => 'count(to_userid) DESC',
			rows => 5, 
		}
	)];

	my $goodgame = $c->model('hsksyusk::GOOD')->search(
		undef, {
			group_by => ['asin'],
			select => ['asin',{ count => 'id' }],
			as => ['asin','count_good'],
			order_by => 'count(id) DESC',
			rows => 5, 
		}
	);

	my $ua = $c->model('Net::Amazon');
	my @goodgame_items=();
	
	while (my $item = $goodgame->next) {
		my $response = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		);
		if ( !$response->is_success ) {
			$c->response->body( $response->message );
		}
		push (@goodgame_items, {
			asin => $item->asin,
			title => $response->properties->title(),
			count_good => $item->get_column('count_good')
		});
	}
	$c->stash->{goodgame} = \@goodgame_items;


	my $allranking = $c->model('hsksyusk::RANKING')->search(
		{ 'draft_flag_userid.draft_flag' => 0 },
		{
			join => ['weight','draft_flag_userid'],
			select => ['asin',{ sum => 'weight.weight' },'draft_flag_userid.draft_flag'],
			as => ['asin','sum_weight','draft_flag_userid.draft_flag'],
			group_by => ['asin'],
			order_by => 'sum(weight.weight) DESC',
			rows => 5, 
		}
	);

	my @allranking_items=();

	while (my $item = $allranking->next) {
		my $response = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		);
		if ( !$response->is_success ) {
			$c->response->body( $response->message );
		}

		push (@allranking_items, {
			asin => $item->asin,
			point => $item->get_column('sum_weight'),
			title => $response->properties->title(),
		});
	}
	$c->stash->{allranking} = \@allranking_items;

}

sub hello :Local {
  my ( $self, $c ) = @_;
  $c->stash->{pagetitle} = 'Hello world';
  $c->stash->{message} = 'ようこそ地球へ';
}
sub newranking : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = '新着ゲームランキング - BESTGAMEON';

	my $page = (defined $c->req->param( 'page' ) )
		? $c->req->param( 'page' ) : 1;

	my $item_count = $c->model('hsksyusk::HISTORY')->search(
		{ draft_flag => 0 }, 
	)->count();

	$c->stash->{history} = [$c->model('hsksyusk::HISTORY')->search(
		{ draft_flag => 0 }, 
		{
			order_by => { -desc => 'ranking_create' },
			rows => 20, 
			page => $page,
		}
	)];
	$c->stash->{pager} = Data::Page->new($item_count, 20, $page);

}

sub famousranking : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = '人気のゲームランキング - BESTGAMEON';

	my $page = (defined $c->req->param( 'page' ) )
		? $c->req->param( 'page' ) : 1;

	my $item_count = $c->model('hsksyusk::GOOD')->search(
		{ 'draft_flag_to_userid.draft_flag' => 0 },
		{
			join => 'draft_flag_to_userid',
			select => ['to_userid','draft_flag_to_userid.draft_flag'],
			group_by => ['to_userid'],
		}
	)->count();

	$c->stash->{famous} = [$c->model('hsksyusk::GOOD')->search(
		{ 'draft_flag_to_userid.draft_flag' => 0 },
		{
			join => 'draft_flag_to_userid',
			select => ['to_userid',{ count => 'to_userid' },'draft_flag_to_userid.draft_flag'],
			as => ['to_userid','count_good','draft_flag_to_userid.draft_flag'],
			group_by => ['to_userid'],
			order_by => 'count(to_userid) DESC',
			rows => 20, 
			page => $page,
		}
	)];
	
	$c->stash->{pager} = Data::Page->new($item_count, 20, $page);

}

sub goodgame : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = 'GOOD!の多いゲーム - BESTGAMEON';

	my $page = (defined $c->req->param( 'page' ) )
		? $c->req->param( 'page' ) : 1;

	my $item_count = $c->model('hsksyusk::GOOD')->search(
		undef, { group_by => ['asin'], }
	)->count();

	my $goodgame = $c->model('hsksyusk::GOOD')->search(
		undef, {
			group_by => ['asin'],
			select => ['asin',{ count => 'id' }],
			as => ['asin','count_good'],
			order_by => 'count(id) DESC',
			rows => 20, 
			page => $page,
		}
	);

	my $ua = $c->model('Net::Amazon');
	my @items=();
	
	while (my $item = $goodgame->next) {
		my $response = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		);
		if ( !$response->is_success ) {
			$c->response->body( $response->message );
		}
		push (@items, {
			asin => $item->asin,
			title => $response->properties->title(),
			ImageUrlSmall => $response->properties->ImageUrlSmall(),
			count_good => $item->get_column('count_good')
		});
	}
	$c->stash->{goodgame} = \@items;
	$c->stash->{pager} = Data::Page->new($item_count, 20, $page);

}

sub allranking : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = '総合ゲームランキング - BESTGAMEON';

	my $page = (defined $c->req->param( 'page' ) )
		? $c->req->param( 'page' ) : 1;

	my $item_count = $c->model('hsksyusk::RANKING')->search(
		{ 'draft_flag_userid.draft_flag' => 0 },
		{
			join => 'draft_flag_userid',
			select => ['asin','draft_flag_userid.draft_flag'],
			group_by => ['asin'],
		}
	)->count();

	my $allranking = $c->model('hsksyusk::RANKING')->search(
		{ 'draft_flag_userid.draft_flag' => 0 },
		{
			join => ['weight','draft_flag_userid'],
			select => ['asin',{ sum => 'weight.weight' },'draft_flag_userid.draft_flag'],
			as => ['asin','sum_weight','draft_flag_userid.draft_flag'],
			group_by => ['asin'],
			order_by => 'sum(weight.weight) DESC',
			rows => 10, 
			page => $page,
		}
	);

	my $ua = $c->model('Net::Amazon');

	my @items=();

	while (my $item = $allranking->next) {
		my $response = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		);
		if ( !$response->is_success ) {
			$c->response->body( $response->message );
		}
		my $imageurl = $response->properties->ImageUrlLarge();
		$imageurl =~ s/.jpg/._SX230_.jpg/;

		my $comment = [$c->model('hsksyusk::RANKING')->search(
			{
				'me.asin' => $item->asin,
				'draft_flag_userid.draft_flag' => 0,
			}, {
				join => ['to_userid_asin_good','draft_flag_userid'],
				select => ['userid','me.asin','rank','comment','draft_flag_userid.draft_flag'],
				group_by => ['me.userid'],
				order_by => { -asc => 'rank' },
			}
		)];
		push (@items, {
			asin => $item->asin,
			point => $item->get_column('sum_weight'),
			title => $response->properties->title(),
			imageurl => $imageurl,
			game => [$response->properties],
			comment => $comment,
		});
	}

	$c->stash->{pager} = Data::Page->new($item_count, 10, $page);
	$c->stash->{allranking} = \@items;
}

sub search : Local {
	my ( $self, $c, $template ) = @_;
	$c->stash->{pagetitle} = 'ゲーム検索 - BESTGAMEON';
	$c->stash->{template} = $template . '.tt' if (defined $template);
	if ($c->req->method eq 'POST') {
		if ( $c->form->has_error ) {
			$c->stash->{error} = $c->form;
		} else {
			my $ua = $c->model('Net::Amazon');
			my $page = (defined $c->req->param( 'page' ) )
				? $c->req->param( 'page' ) : 1;
		
			my $response = $ua->search( 
				keyword => $c->req->param( 'keyword' ),
				mode => 'VideoGames',
				page => $page,
				AssociateTag => 'bsrnvebm-22',
			);
			if ( !$response->is_success ) {
				$c->response->body( $response->message );
			}
			$c->stash->{pager} = Data::Page->new($response->total_results(), 10 * $ua->{max_pages}, $page);
			$c->stash->{keyword} = $c->req->param( 'keyword' );
			$c->stash->{entries} = [$response->properties];
		}
	}
}

sub edit : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = 'ランキングを作る - BESTGAMEON';
	if ( $c->user_exists) {
		my $userid =  $c->user->get('id_field');
		my $ranking = $c->model('hsksyusk::RANKING')->search(
			{ userid => $userid, },
			{ order_by => { -asc => 'rank' },}
		);
		if ( $ranking->count ) {
			$c->stash->{dataload_flag} = 1;
			my @items=();
			my $ua = $c->model('Net::Amazon');
			
			while (my $item = $ranking->next) {
				my $response = $ua->search( 
					asin => $item->asin, 
				);
				if ( !$response->is_success ) {
					$c->response->body( $response->message );
				}
				push (@items, {
					asin => $item->asin,
					title => $response->properties->title(),
					imageurl => $response->properties->ImageUrlSmall() ,
					comment => $item->comment,
				});
			}
			$c->stash->{items} = \@items;
		} else {
			$c->stash->{dataload_flag} = 0;
		}
	} else {
		$c->go("login"); 
	}
}


=head2 default

Standard 404 error page

=cut

sub regist : Local {
	my ($self, $c) = @_;

	my @messages=();

	if ($c->req->method eq 'POST') {

		my $draft_flag = 0;
		if ( $c->req->param( 'draft' ) eq 'true' ) {
			$draft_flag = 1;
		}
		
		if ( !$c->user_exists ) {
			push (@messages, "ログインセッションが切れました。恐れ入りますが再度ログインしてください。別ウィンドウでBESTGAMEONを開いてログインすれば、これまでの入力内容は保持されます。");
		} else {
			if ( $c->form->has_error ) {
				@messages = sort { $a <=> $b } @{$c->form->messages('regist')};
			}
			if ( $c->req->param( 'rank1' ) ne "" ) {
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank2'  ) ) { push (@messages, "1位と2位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank3'  ) ) { push (@messages, "1位と3位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank4'  ) ) { push (@messages, "1位と4位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank5'  ) ) { push (@messages, "1位と5位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank6'  ) ) { push (@messages, "1位と6位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank7'  ) ) { push (@messages, "1位と7位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank8'  ) ) { push (@messages, "1位と8位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "1位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank1' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "1位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank2' ) ne "" ) {
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank3'  ) ) { push (@messages, "2位と3位のゲームが重複しています"); }
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank4'  ) ) { push (@messages, "2位と4位のゲームが重複しています"); }
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank5'  ) ) { push (@messages, "2位と5位のゲームが重複しています"); }
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank6'  ) ) { push (@messages, "2位と6位のゲームが重複しています"); }
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank7'  ) ) { push (@messages, "2位と7位のゲームが重複しています"); }
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank8'  ) ) { push (@messages, "2位と8位のゲームが重複しています"); }
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "2位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank2' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "2位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank3' ) ne "" ) {
				if ( $c->req->param( 'rank3' ) eq $c->req->param( 'rank4'  ) ) { push (@messages, "3位と4位のゲームが重複しています"); }
				if ( $c->req->param( 'rank3' ) eq $c->req->param( 'rank5'  ) ) { push (@messages, "3位と5位のゲームが重複しています"); }
				if ( $c->req->param( 'rank3' ) eq $c->req->param( 'rank6'  ) ) { push (@messages, "3位と6位のゲームが重複しています"); }
				if ( $c->req->param( 'rank3' ) eq $c->req->param( 'rank7'  ) ) { push (@messages, "3位と7位のゲームが重複しています"); }
				if ( $c->req->param( 'rank3' ) eq $c->req->param( 'rank8'  ) ) { push (@messages, "3位と8位のゲームが重複しています"); }
				if ( $c->req->param( 'rank3' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "3位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank3' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "3位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank4' ) ne "" ) {
				if ( $c->req->param( 'rank4' ) eq $c->req->param( 'rank5'  ) ) { push (@messages, "4位と5位のゲームが重複しています"); }
				if ( $c->req->param( 'rank4' ) eq $c->req->param( 'rank6'  ) ) { push (@messages, "4位と6位のゲームが重複しています"); }
				if ( $c->req->param( 'rank4' ) eq $c->req->param( 'rank7'  ) ) { push (@messages, "4位と7位のゲームが重複しています"); }
				if ( $c->req->param( 'rank4' ) eq $c->req->param( 'rank8'  ) ) { push (@messages, "4位と8位のゲームが重複しています"); }
				if ( $c->req->param( 'rank4' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "4位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank4' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "4位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank5' ) ne "" ) {
				if ( $c->req->param( 'rank5' ) eq $c->req->param( 'rank6'  ) ) { push (@messages, "5位と6位のゲームが重複しています"); }
				if ( $c->req->param( 'rank5' ) eq $c->req->param( 'rank7'  ) ) { push (@messages, "5位と7位のゲームが重複しています"); }
				if ( $c->req->param( 'rank5' ) eq $c->req->param( 'rank8'  ) ) { push (@messages, "5位と8位のゲームが重複しています"); }
				if ( $c->req->param( 'rank5' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "5位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank5' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "5位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank6' ) ne "" ) {
				if ( $c->req->param( 'rank6' ) eq $c->req->param( 'rank7'  ) ) { push (@messages, "6位と7位のゲームが重複しています"); }
				if ( $c->req->param( 'rank6' ) eq $c->req->param( 'rank8'  ) ) { push (@messages, "6位と8位のゲームが重複しています"); }
				if ( $c->req->param( 'rank6' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "6位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank6' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "6位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank7' ) ne "" ) {
				if ( $c->req->param( 'rank7' ) eq $c->req->param( 'rank8'  ) ) { push (@messages, "7位と8位のゲームが重複しています"); }
				if ( $c->req->param( 'rank7' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "7位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank7' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "7位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank8' ) ne "" ) {
				if ( $c->req->param( 'rank8' ) eq $c->req->param( 'rank9'  ) ) { push (@messages, "8位と9位のゲームが重複しています"); }
				if ( $c->req->param( 'rank8' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "8位と10位のゲームが重複しています"); }
			}
			if ( $c->req->param( 'rank9' ) ne "" ) {
				if ( $c->req->param( 'rank9' ) eq $c->req->param( 'rank10' ) ) { push (@messages, "9位と10位のゲームが重複しています"); }
			}
		}

		if ( $#messages >= 0 ){
			$c->stash->{messages} = \@messages;
			$c->stash->{error_flag} = 1;
		} else {
			$c->stash->{error_flag} = 0;

			my $userid =  $c->user->get('id_field');

			my $txn = sub {
	
				my $ranking = $c->model('hsksyusk::RANKING')->search({
					userid => $userid,
				});

				if ( $ranking->count ) {
					$ranking->delete();
				}

				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '1',
					asin	=> $c->req->param( 'rank1' ),
					comment => $c->req->param( 'comment1' ),
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '2',
					asin	=> $c->req->param( 'rank2' ),
					comment => $c->req->param( 'comment2' ),
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '3',
					asin	=> $c->req->param( 'rank3' ),
					comment => $c->req->param( 'comment3' ),
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '4',
					asin	=> $c->req->param( 'rank4' ),
					comment => $c->req->param( 'comment4' )
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '5',
					asin	=> $c->req->param( 'rank5' ),
					comment => $c->req->param( 'comment5' )
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '6',
					asin	=> $c->req->param( 'rank6' ),
					comment => $c->req->param( 'comment6' )
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '7',
					asin	=> $c->req->param( 'rank7' ),
					comment => $c->req->param( 'comment7' )
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '8',
					asin	=> $c->req->param( 'rank8' ),
					comment => $c->req->param( 'comment8' )
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '9',
					asin	=> $c->req->param( 'rank9' ),
					comment => $c->req->param( 'comment9' )
				});
				$c->model('hsksyusk::RANKING')->create({
					userid  => $userid,
					rank	=> '10',
					asin	=> $c->req->param( 'rank10' ),
					comment => $c->req->param( 'comment10' )
				});

				my $history = $c->model('hsksyusk::HISTORY')->find_or_new({
					userid  => $userid,
					ranking_update	=> \'NOW()',
					draft_flag => $draft_flag,
				});
				if ( $history->in_storage ) {
					my $history_update = $c->model('hsksyusk::HISTORY')->search({
						userid  => $userid,
					});
					if ( !$draft_flag && $history_update->search({ranking_create => {is => undef}})->count  > 0) {
						$history_update->update({
							ranking_create	=> \'NOW()',
							ranking_update	=> \'NOW()',
							draft_flag => $draft_flag,
						});
					} else {
						$history_update->update({
							ranking_update	=> \'NOW()',
							draft_flag => $draft_flag,
						});
					}
				} else {
					if ( !$draft_flag ) {
						$history->ranking_create(\'NOW()');
					}
					$history->insert();
				}
			};
			
			eval { $c->model('hsksyusk')->schema->txn_do($txn); };
			$c->session->{ranking_create} = 1;
			 
			if ($@) {
				if ( $@ =~ /rollback failed/ ) {
					$c->error("rollback failed: $@");
				}
				else {
					$c->error("rollbacked: $@");
				}
			}
		}
		$c->forward('View::JSON');
	} 
}

sub rank : Local :Args(1) {
	my ($self, $c) = @_;

	my $username = $c->req->args->[0];
	$c->stash->{pagetitle} = $username . 'さんのゲームランキング - BESTGAMEON';

	$c->stash->{ranking_create} = 0;
	if ( $c->session->{ranking_create} == 1 ) {
		$c->stash->{ranking_create} = 1;
		$c->session->{ranking_create} = 0;
	}

	my $user = $c->model('hsksyusk::USER')
	  ->search({
		twitter_user => $username,
	});
	my $userid = $user->next->id_field;

	my $edit_flag = 0;
	if ( $c->user_exists && $c->user->get('twitter_user') eq $username) {
		$edit_flag = 1; 
	}

	my $faved_flag = 0;
	if ( $c->user_exists ) {
		my $fav_count = $c->model('hsksyusk::FAVORITE')->search({
			from_userid => $c->user->get('id_field'),
			to_userid => $userid,
		})->count;
		if ( $fav_count > 0 ) {
			$faved_flag = 1;
		}
	}
	
	my $ranking = $c->model('hsksyusk::RANKING')
	  ->search(
		{ userid => $userid, },
		{ order_by => { -asc => 'rank' },}
	);

	my $ranking_exists = 0;

	my $history = $c->model('hsksyusk::HISTORY')->find($userid);

	if( $ranking->count == 0 ) {
		$ranking_exists = 0;
	} elsif ( $history->draft_flag ){ 
		$ranking_exists = 0;
	} else {
		$ranking_exists = 1;
		my @items=();
		my $ua = $c->model('Net::Amazon');
		
		while (my $item = $ranking->next) {
			my $response = $ua->search(
				asin => $item->asin,
				AssociateTag => 'bsrnvebm-22',
			);
			if ( !$response->is_success ) {
				$c->response->body( $response->message );
			}
			my $imageurl = $response->properties->ImageUrlLarge();
			$imageurl =~ s/.jpg/._SX230_.jpg/;
			push (@items, {
				rank => $item->rank,
				asin => $item->asin,
				userid => $item->userid,
				title => $response->properties->title(),
				url => $response->properties->url(),
				imageurl => $imageurl,
				comment => $item->comment,
				to_userid_asin_good => [$item->to_userid_asin_good],
				to_userid_asin_comment => [$item->to_userid_asin_comment],
			});
		}
		
		$c->stash->{items} = \@items;
	}

	$c->stash->{template} = 'rank.tt';
	$c->stash->{username} = $username;
	$c->stash->{userid} = $userid;
	$c->stash->{edit_flag} = $edit_flag;
	$c->stash->{faved_flag} = $faved_flag;
	$c->stash->{ranking_exists} = $ranking_exists;
	$c->stash->{history} = $history;
}

sub game : Local :Args(1) {
	my ($self, $c) = @_;

	my $asin = $c->req->args->[0];

	my $ua = $c->model('Net::Amazon');
	
	my $response = $ua->search(
		asin => $asin,
		AssociateTag => 'bsrnvebm-22',
	);
	if ( !$response->is_success ) {
		$c->response->body( $response->message );
	}
	my $imageurl = $response->properties->ImageUrlLarge();
	$imageurl =~ s/.jpg/._SX230_.jpg/;
	$c->stash->{imageurl} = $imageurl;

	my $ranking = [$c->model('hsksyusk::RANKING')->search(
		{
			'me.asin' => $asin,
			'draft_flag_userid.draft_flag' => 0,
		}, {
			join => ['to_userid_asin_good','draft_flag_userid'],
			group_by => ['me.userid'],
			select => ['userid','me.asin','rank','comment','draft_flag_userid.draft_flag'],
			order_by => { -asc => 'rank' },
		}
	)];

	$c->stash->{game} = [$response->properties];
	$c->stash->{url} = $response->properties->url();
	$c->stash->{title} = $response->properties->title();
	$c->stash->{ranking} = $ranking;
	$c->stash->{template} = 'game.tt';
	$c->stash->{pagetitle} = $response->properties->title() . ' - BESTGAMEON';	

}

sub mypage : Local {
	my ($self, $c) = @_;

	if ( $c->user_exists) {
		my $user_mypage = "/rank/".$c->user->get('twitter_user');
		$c->res->redirect($user_mypage); 
	} else {
		$c->go("login"); 
	}

}


sub user : Local : Args(1) {
	my ($self, $c) = @_;

	my $username = $c->req->args->[0];
	$c->stash->{pagetitle} = $username . 'さんのホーム - BESTGAMEON';

	my $user = $c->model('hsksyusk::USER')
	  ->search({
		twitter_user => $username,
	});
	my $userid = $user->next->id_field;

	my $ua = $c->model('Net::Amazon');

	my $edit_flag = 0;
	if ( $c->user_exists && $c->user->get('twitter_user') eq $username) {
		$edit_flag = 1; 
	}

	$c->stash->{profile} = $c->model('hsksyusk::PROFILE')->find($userid);

	my $my_favorite = $c->model('hsksyusk::FAVORITE')->search({
		from_userid => $userid,
	});
	my $my_favorite_count = $my_favorite->count;
	$c->stash->{my_favorite_count} = $my_favorite_count;
	if ($my_favorite_count > 0) { $c->stash->{my_favorites} = [$my_favorite->search()]; }

	my $get_favorite = $c->model('hsksyusk::FAVORITE')->search({
		to_userid => $userid,
	});
	my $get_favorite_count = $get_favorite->count;
	$c->stash->{get_favorite_count} = $get_favorite_count;
	if ($get_favorite_count > 0) { $c->stash->{get_favorites} = [$get_favorite->search()]; }

	my $faved_flag = 0;
	if ( $c->user_exists ) {
		my $fav_count = $get_favorite->search({
			from_userid => $c->user->get('id_field'),
		})->count;
		if ( $fav_count > 0 ) {
			$faved_flag = 1;
		}
	}

	my $ranking = $c->model('hsksyusk::RANKING')
	  ->search({
		userid => $userid,
	});

	my $ranking_exists = 0;
	my $get_good_count = 0;
	my $get_comment_count = 0;
	if ( $ranking->count > 0 )	{
		$ranking_exists = 1;
		
		$c->stash->{history} = $c->model('hsksyusk::HISTORY')->find($userid);

		$get_comment_count = $c->model('hsksyusk::COMMENT')->search({
			to_userid => $userid,
			from_userid => { '!=' => $userid },
		})->count;

		if ( $get_comment_count > 0 ) {

			my $get_comment = $c->model('hsksyusk::COMMENT')->search(
				{
					to_userid => $userid, 
					from_userid => { '!=' => $userid },
				},
				{	
					order_by => { -desc => 'timestamp' },
					rows => 5, 
				},
			);

			my @get_comments=();

			while ( my $item = $get_comment->next ) {
				my $username = $c->model('hsksyusk::USER')->find($item->from_userid)->twitter_user;
				my $get_comment_ranking = $c->model('hsksyusk::RANKING')
				  ->search({
					userid => $item->to_userid,
					asin => $item->asin,
				});
				my $rank = ( $get_comment_ranking->count )
					? $get_comment_ranking->next->rank : '-';
				my $title = $ua->search(
					asin => $item->asin,
					AssociateTag => 'bsrnvebm-22',
				)->properties->title();
				push (@get_comments, {
					rank => $rank,
					title => $title,
					username => $username,
					comment => $item->comment,
					timestamp => $item->timestamp,
				});
			}
			$c->stash->{get_comments} = \@get_comments;
		}


		$get_good_count = $c->model('hsksyusk::GOOD')->search({ to_userid => $userid,})->count;

		if ( $get_good_count > 0 ) {

			my $get_good = $c->model('hsksyusk::GOOD')->search(
				{	to_userid => $userid, },
				{	
					order_by => { -desc => 'timestamp' },
					rows => 5, 
				},
			);

			my @get_goods=();

			while ( my $item = $get_good->next ) {
				my $username = $c->model('hsksyusk::USER')->find($item->from_userid)->twitter_user;
				my $get_good_ranking = $c->model('hsksyusk::RANKING')
				  ->search({
					userid => $item->to_userid,
					asin => $item->asin,
				});
				my $rank = ( $get_good_ranking->count )
					? $get_good_ranking->next->rank : '-';
				my $title = $ua->search(
					asin => $item->asin,
					AssociateTag => 'bsrnvebm-22',
				)->properties->title();
				push (@get_goods, {
					rank => $rank,
					title => $title,
					username => $username,
					timestamp => $item->timestamp,
				});
			}
			$c->stash->{get_goods} = \@get_goods;
		}
	}

	my $give_comment_count =$c->model('hsksyusk::COMMENT')->search({from_userid => $userid, })->count;

	if ( $give_comment_count > 0 ) {

		my $give_comment = $c->model('hsksyusk::COMMENT')->search(
			{	from_userid => $userid, },
			{	
				order_by => { -desc => 'timestamp' },
				rows => 5, 
			},
		);

		my @give_comments=();
		while ( my $item = $give_comment->next ) {
			my $username = $c->model('hsksyusk::USER')->find($item->to_userid)->twitter_user;
			my $give_comment_ranking = $c->model('hsksyusk::RANKING')
			  ->search({
				userid => $item->to_userid,
				asin => $item->asin,
			});
			my $rank = ( $give_comment_ranking->count )
				? $give_comment_ranking->next->rank : '-';
			my $title = $ua->search(
				asin => $item->asin,
				AssociateTag => 'bsrnvebm-22',
			)->properties->title();
			push (@give_comments, {
				rank => $rank,
				title => $title,
				username => $username,
				comment => $item->comment,
				timestamp => $item->timestamp,
			});
		}
		$c->stash->{give_comments} = \@give_comments;
	}

	my $give_good_count =$c->model('hsksyusk::GOOD')->search({from_userid => $userid, })->count;

	if ( $give_good_count > 0 ) {

		my $give_good = $c->model('hsksyusk::GOOD')->search(
			{	from_userid => $userid, },
			{	
				order_by => { -desc => 'timestamp' },
				rows => 5, 
			},
		);

		my @give_goods=();
		while ( my $item = $give_good->next ) {
			my $username = $c->model('hsksyusk::USER')->find($item->to_userid)->twitter_user;
			my $give_good_ranking = $c->model('hsksyusk::RANKING')
			  ->search({
				userid => $item->to_userid,
				asin => $item->asin,
			});
			my $rank = ( $give_good_ranking->count )
				? $give_good_ranking->next->rank : '-';
			my $title = $ua->search(
				asin => $item->asin,
				AssociateTag => 'bsrnvebm-22',
			)->properties->title();
			push (@give_goods, {
				rank => $rank,
				title => $title,
				username => $username,
				timestamp => $item->timestamp,
			});
		}
		$c->stash->{give_goods} = \@give_goods;
	}

	$c->stash->{template} = 'user.tt';
	$c->stash->{username} = $username;
	$c->stash->{userid} = $userid;
	$c->stash->{ranking_exists} = $ranking_exists;

	$c->stash->{get_good_count} = $get_good_count;
	$c->stash->{give_good_count} = $give_good_count;

	$c->stash->{get_comment_count} = $get_comment_count;
	$c->stash->{give_comment_count} = $give_comment_count;

	$c->stash->{edit_flag} = $edit_flag;
	$c->stash->{faved_flag} = $faved_flag;
}

sub goodget : Local : Args(3) {
	my ($self, $c) = @_;

	my $userid = $c->req->args->[0];
	my $page = $c->req->args->[1];
	my $volume = $c->req->args->[2];

	my $ua = $c->model('Net::Amazon');

	my @get_goods=();
	
	for (my $i = 0; $i < $volume ; $i++) {
		my $get_good = $c->model('hsksyusk::GOOD')->search(
			{	to_userid => $userid, },
			{	
				order_by => { -desc => 'timestamp' },
				page => $page,
				rows => 5, 
			},
		);
	
		while ( my $item = $get_good->next ) {
			my $username = $c->model('hsksyusk::USER')->find($item->from_userid)->twitter_user;
			my $goodget_ranking = $c->model('hsksyusk::RANKING')
			  ->search({
				userid => $item->to_userid,
				asin => $item->asin,
			});
			my $rank = ( $goodget_ranking->count )
				? $goodget_ranking->next->rank : '-';
			my $title = $ua->search(
				asin => $item->asin,
				AssociateTag => 'bsrnvebm-22',
			)->properties->title();
			push (@get_goods, {
				rank => $rank,
				title => $title,
				username => $username,
				timestamp => $item->timestamp,
			});
		}
		
		$page += 1;
	}
	$c->stash->{get_goods} = \@get_goods;
}

sub goodgive : Local : Args(3) {
	my ($self, $c) = @_;

	my $userid = $c->req->args->[0];
	my $page = $c->req->args->[1];
	my $volume = $c->req->args->[2];

	my $ua = $c->model('Net::Amazon');

	my @give_goods=();
	
	for (my $i = 0; $i < $volume ; $i++) {
	
		my $give_good = $c->model('hsksyusk::GOOD')->search(
			{	from_userid => $userid, },
			{	
				order_by => { -desc => 'timestamp' },
				page => $page,
				rows => 5, 
			},
		);

		while ( my $item = $give_good->next ) {
			my $username = $c->model('hsksyusk::USER')->find($item->to_userid)->twitter_user;
			my $goodgive_ranking = $c->model('hsksyusk::RANKING')
			  ->search({
				userid => $item->to_userid,
				asin => $item->asin,
			});
			my $rank = ( $goodgive_ranking->count )
				? $goodgive_ranking->next->rank : '-';
			my $title = $ua->search(
				asin => $item->asin,
				AssociateTag => 'bsrnvebm-22',
			)->properties->title();
			push (@give_goods, {
				rank => $rank,
				title => $title,
				username => $username,
				timestamp => $item->timestamp,
			});
		}
		
		$page += 1;
	}
	$c->stash->{give_goods} = \@give_goods;
}

sub resget : Local : Args(3) {
	my ($self, $c) = @_;

	my $userid = $c->req->args->[0];
	my $page = $c->req->args->[1];
	my $volume = $c->req->args->[2];

	my $ua = $c->model('Net::Amazon');

	my @get_comments=();
	
	for (my $i = 0; $i < $volume ; $i++) {

		my $get_comment = $c->model('hsksyusk::COMMENT')->search(
			{
				to_userid => $userid, 
				from_userid => { '!=' => $userid },
			},
			{	
				order_by => { -desc => 'timestamp' },
				page => $page,
				rows => 5, 
			},
		);

		while ( my $item = $get_comment->next ) {
			my $username = $c->model('hsksyusk::USER')->find($item->from_userid)->twitter_user;
			my $resget_ranking = $c->model('hsksyusk::RANKING')
			  ->search({
				userid => $item->to_userid,
				asin => $item->asin,
			});
			my $rank = ( $resget_ranking->count )
				? $resget_ranking->next->rank : '-';
			my $title = $ua->search(
				asin => $item->asin,
				AssociateTag => 'bsrnvebm-22',
			)->properties->title();
			push (@get_comments, {
				rank => $rank,
				title => $title,
				username => $username,
				comment => $item->comment,
				timestamp => $item->timestamp,
			});
		}
		$page += 1;
	}

	$c->stash->{get_comments} = \@get_comments;
}

sub resgive : Local : Args(3) {
	my ($self, $c) = @_;

	my $userid = $c->req->args->[0];
	my $page = $c->req->args->[1];
	my $volume = $c->req->args->[2];

	my $ua = $c->model('Net::Amazon');

	my @give_comments=();
	
	for (my $i = 0; $i < $volume ; $i++) {
		my $give_comment = $c->model('hsksyusk::COMMENT')->search(
			{	from_userid => $userid, },
			{	
				order_by => { -desc => 'timestamp' },
				page => $page,
				rows => 5, 
			},
		);

		while ( my $item = $give_comment->next ) {
			my $username = $c->model('hsksyusk::USER')->find($item->to_userid)->twitter_user;
			my $resgive_ranking = $c->model('hsksyusk::RANKING')
			  ->search({
				userid => $item->to_userid,
				asin => $item->asin,
			})->next->rank;
			my $title = $ua->search(
				asin => $item->asin,
				AssociateTag => 'bsrnvebm-22',
			)->properties->title();
			my $rank = ( $resgive_ranking->count )
				? $resgive_ranking->next->rank : '-';
			push (@give_comments, {
				rank => $rank,
				title => $title,
				username => $username,
				comment => $item->comment,
				timestamp => $item->timestamp,
			});
		}
		$page += 1;
	}
	$c->stash->{give_comments} = \@give_comments;
}

sub bp : Local :Args(2) {
	my ($self, $c) = @_;

	my $username = $c->req->args->[0];
	my $partstype = $c->req->args->[1];

	my $itemlimit = 1;
	switch ($partstype) {
		case 'm' {
			$itemlimit = 3;
			$c->stash->{img_flag} = 0;
			$c->stash->{readmore_flag} = 1;
		}
		case 'n' {
			$itemlimit = 10;
			$c->stash->{img_flag} = 0;
			$c->stash->{readmore_flag} = 0;
		}
		case 'i' {
			$itemlimit = 3;
			$c->stash->{img_flag} = 1;
			$c->stash->{readmore_flag} = 1;
		}
		case 'l' {
			$itemlimit = 10;
			$c->stash->{img_flag} = 1;
			$c->stash->{readmore_flag} = 0;
		}
	}

	my $user = $c->model('hsksyusk::USER')
	  ->search({
		twitter_user => $username,
	});
	my $userid = $user->next->id_field;


	my $ranking = $c->model('hsksyusk::RANKING')
	  ->search( { userid => $userid, }, {	
			order_by => { -asc =>'rank' },
			rows => $itemlimit, 
		}
	);

	my @items=();
	my $ua = $c->model('Net::Amazon');
	
	while (my $item = $ranking->next) {
		my $response = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		);
		if ( !$response->is_success ) {
			$c->response->body( $response->message );
		}
		push (@items, {
			rank => $item->rank,
			asin => $item->asin,
			title => $response->properties->title(),
			imageurl => $response->properties->ImageUrlSmall(),
		});
	}
	
	$c->stash->{username} = $username;
	$c->stash->{items} = \@items;

}

sub parts : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = 'ブログパーツ - BESTGAMEON';	

	if ($c->user_exists) {
		my $userid = $c->user->get('id_field');
		if ( $c->model('hsksyusk::RANKING')->search({ userid => $userid,})->count > 0 && $c->model('hsksyusk::HISTORY')->find($userid)->draft_flag == 0) {
			$c->stash->{username} = $c->user->get('twitter_user');
			$c->stash->{rank_exists} = 1;
		} else {
			$c->stash->{rank_exists} = 0;
			$c->stash->{username} = 'hsksyusk';
		}
	} else {
		$c->stash->{rank_exists} = 0;
		$c->stash->{username} = 'hsksyusk';
	}
	
}

sub comment : Local {
	my ($self, $c) = @_;

	if ($c->req->method eq 'POST' ) {
		if ( !$c->form->has_error && $c->user_exists ) {
			$c->model('hsksyusk::COMMENT')->create({
				from_userid  => $c->user->get('id_field'),
				to_userid => $c->req->param( 'to_userid' ),
				asin	=> $c->req->param( 'asin' ),
				comment	=> $c->req->param( 'comment' ),
			});
			$c->stash->{to_username} = $c->user->get('twitter_user');
			$c->stash->{error_flag} = 0;
		} else {
			$c->stash->{error_flag} = 1;
			$c->stash->{error_message} = $c->form->messages('contact')->[0];
		}
		$c->forward('View::JSON');
	}
}

sub good : Local {
	my ($self, $c) = @_;

	if ($c->req->method eq 'POST' ) {
		if ( !$c->form->has_error && $c->user_exists ) {
			$c->model('hsksyusk::GOOD')->create({
				from_userid  => $c->user->get('id_field'),
				to_userid => $c->req->param( 'to_userid' ),
				asin	=> $c->req->param( 'asin' ),
			});
			$c->stash->{to_username} = $c->user->get('twitter_user');
			$c->stash->{error_flag} = 0;
		} else {
			$c->stash->{error_flag} = 1;
		}
		$c->forward('View::JSON');
	}
}

sub favorite : Local {
	my ($self, $c) = @_;

	if ($c->req->method eq 'POST' ) {
		if ( !$c->form->has_error && $c->user_exists 
		&& $c->req->param( 'to_userid' )!=$c->user->get('id_field')) {
			$c->model('hsksyusk::FAVORITE')->create({
				from_userid  => $c->user->get('id_field'),
				to_userid => $c->req->param( 'to_userid' ),
			});
			$c->stash->{error_flag} = 0;
		} else {
			$c->stash->{error_flag} = 1;
		}
		$c->forward('View::JSON');
	}
}

sub unfavorite : Local {
	my ($self, $c) = @_;

	if ($c->req->method eq 'POST' ) {
		if ( !$c->form->has_error && $c->user_exists 
		&& $c->req->param( 'to_userid' )!=$c->user->get('id_field')) {
			$c->model('hsksyusk::FAVORITE')->search({
				from_userid  => $c->user->get('id_field'),
				to_userid => $c->req->param( 'to_userid' ),
			})->delete();
			$c->stash->{error_flag} = 0;
		} else {
			$c->stash->{error_flag} = 1;
		}
		$c->forward('View::JSON');
	}
}

sub login : Local {
	my ($self, $c) = @_;

}

sub logout : Local {
	my ($self, $c) = @_;

	$c->logout();
	$c->response->redirect("/");
}

sub twitter_login : Local {
   my ($self, $c) = @_;
   
   my $realm = $c->get_auth_realm('twitter');
   $c->res->redirect( $realm->credential->authenticate_twitter_url($c) );
}

sub callback : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = 'ログインしました - BESTGAMEON';	

	if ($c->authenticate(undef,'twitter')) {
		my $userid = $c->user->get('id_field');
		my $account = $c->model('hsksyusk::ACCOUNT')->find_or_new({
			userid => $userid,
		});
		if ( !$account->in_storage ) {
			$account->create_date(\'NOW()');
			$account->insert();
			$c->stash->{template} = 'callback_signup.tt';
		}
	} else {
		$c->stash->{pagetitle} = 'ログインエラー - BESTGAMEON';	
		$c->stash->{template} = 'login_error.tt';
	}
}

sub login_error : Local {
	my ($self, $c) = @_;

}

sub email_suggest : Local {
	my ($self, $c) = @_;

	$c->stash->{pagetitle} = 'メールアドレス登録 - BESTGAMEON';
	$c->stash->{template} = 'email_suggest.tt';

	$c->stash->{error_flag} = 0;

	if ($c->req->method eq 'POST' ) {
		my $mailaddress = $c->req->param( 'mailaddress' );
		if ( $c->form->has_error ) {
			$c->stash->{messages1} = $c->form->messages('email_suggest');
			$c->stash->{error_flag} = 1;
		} else {
			if ( $c->forward('email_regist',[$mailaddress]) ) {
				$c->stash->{pagetitle} = 'メールアドレス仮登録完了 - BESTGAMEON';	
				$c->stash->{template} = 'email_pre_regist.tt';
			} else {
				$c->stash->{error_flag} = 2;
			}

		}
	}
}

sub loginbox : Local {
	my ($self, $c) = @_;
	
}

sub email_regist : Private {
	my ($self, $c) = @_;
	my $mailaddress = $c->req->args->[0];

	if (!$c->user_exists) {
		$c->stash->{messages2} = 'ログインしていません。恐れ入りますが、再度ログインしてください';
		return 0;
	}
	my $userid = $c->user->get('id_field');

	my $account = $c->model('hsksyusk::ACCOUNT')->search({
		email => $mailaddress,
		email_auth => '1',
	});
	if ( $account->count ) {
		$c->stash->{messages2} = 'このメールアドレスは、すでに登録されています';
		return 0;
	}

	my $mailcheckkey = String::Random->new->randregex('[A-Za-z0-9]{32}');

	$c->model('hsksyusk::ACCOUNT')->search({
		userid  => $userid,
	})->update({
		email	=> $mailaddress,
		email_auth => '0',
		email_auth_key	=> $mailcheckkey,
	});

	$c->stash->{mailcheckkey} = $mailcheckkey;

	$c->email( 
		From => 'info@bestgameon.net',
		To => $mailaddress,
		Subject => 'メールアドレス仮登録のお知らせ',
		Template => 'mail_email_regist.tt',
	);

	$c->stash->{is_success} = 1;
	return 1;
}


sub mailcheck : Local :Args(1) {
	my ($self, $c) = @_;
	my $mailcheckkey = $c->req->args->[0];
	
	if (!$c->user_exists) {
		$c->go( 'login' );
	} else {
		my $userid = $c->user->get('id_field');

		my $account = $c->model('hsksyusk::ACCOUNT')->search({
			userid  => $userid,
			email_auth => 0,
			email_auth_key	=> $mailcheckkey,
		});

		if ( $account->count ) {
			$account->update({
				email_auth => '1',
				email_auth_key	=> \'NULL',
			});
			$c->stash->{pagetitle} = 'メールアドレス登録完了 - BESTGAMEON';	

		} else {
			$c->go( 'default' );
		}
	}
}

sub maintenance : Local {
	my ($self, $c) = @_;
	$c->stash->{pagetitle} = '設定 - BESTGAMEON';
	if ( $c->user_exists) {
		my $userid =  $c->user->get('id_field');

		my $email_delete = 0;
		my $edit_draft = 0;
		my $profile_update = 0;
		my $ranking_delete = 0;

		if ($c->req->method eq 'POST' ) {
			if ( $c->req->param('email_delete') ) {
				$email_delete = 1;
			} elsif ( $c->req->param('edit_draft') ) {
				$edit_draft = 1;
			} elsif ( $c->req->param('profile_update') ) {
				$profile_update = 1;
			} elsif ( $c->req->param('ranking_delete') ) {
				$ranking_delete = 1;
			}
		}

		$c->stash->{username} = $c->model('hsksyusk::USER')->find($userid)->twitter_user;
		my $ranking_count = $c->model('hsksyusk::RANKING')->search({
			userid => $userid,
		})->count;

		my $account = $c->model('hsksyusk::ACCOUNT')->find($userid);
		if ( $email_delete ) {
			$account->update({
					email => \'NULL',
					email_auth => 0,
			});
			$c->stash->{account} = $c->model('hsksyusk::ACCOUNT')->find($userid);
		} else {
			$c->stash->{account} = $account;
		}
		
		if ( $ranking_delete) {
			$c->model('hsksyusk::HISTORY')->search({
				userid  => $userid,
			})->delete();
			$c->model('hsksyusk::RANKING')->search({
				userid  => $userid,
			})->delete();
		}

		$c->stash->{ranking_exists} = 0;
		if ( $ranking_count > 0) {
			$c->stash->{ranking_exists} = 1;

			if ( $edit_draft ) {
				my $draft_flag = $c->req->param( 'draft' );
				my $history_update = $c->model('hsksyusk::HISTORY')->search({
					userid  => $userid,
				});
				if ( !$draft_flag && $history_update->search({ranking_create => {is => undef}})->count  > 0) {
					$history_update->update({
						ranking_create	=> \'NOW()',
						ranking_update	=> \'NOW()',
						draft_flag => $draft_flag,
					});
				} else {
					$history_update->update({
						ranking_update	=> \'NOW()',
						draft_flag => $draft_flag,
					});
				}
			}
			$c->stash->{history} = $c->model('hsksyusk::HISTORY')->find($userid);
		}
		
		if ( $profile_update ) {
			if ( $c->form->has_error ) {
				$c->stash->{messages} = $c->form->messages('maintenance');
				$c->stash->{error_flag} = 1;
			} else {
				my $profile = $c->model('hsksyusk::PROFILE')->update_or_new({
					userid               => $userid,
					address              => $c->req->param('address'),
					address_flag         => $c->req->param('address_flag'),
					sex                  => $c->req->param('sex'),
					sex_flag             => $c->req->param('sex_flag'),
					bloodtype            => $c->req->param('bloodtype'),
					bloodtype_flag       => $c->req->param('bloodtype_flag'),
					birthyear            => $c->req->param('birthyear'),
					birthyear_flag       => $c->req->param('birthyear_flag'),
					birthday_month       => $c->req->param('birthday_month'),
					birthday_day         => $c->req->param('birthday_day'),
					birthday_flag        => $c->req->param('birthday_flag'),
					url                  => $c->req->param('url'),
					url_flag             => $c->req->param('url_flag'),
					favorite_genre       => $c->req->param('favorite_genre'),
					favorite_genre_flag  => $c->req->param('favorite_genre_flag'),
					favorite_hard        => $c->req->param('favorite_hard'),
					favorite_hard_flag   => $c->req->param('favorite_hard_flag'),
					favorite_maker       => $c->req->param('favorite_maker'),
					favorite_maker_flag  => $c->req->param('favorite_maker_flag'),
					introduction         => $c->req->param('introduction'),
					introduction_flag    => $c->req->param('introduction_flag'),
				});
				if ( !$profile->in_storage) {
					$profile->insert();
				}
				$c->stash->{profile} = $c->model('hsksyusk::PROFILE')->find($userid);
			}
		} else {
			$c->stash->{profile} = $c->model('hsksyusk::PROFILE')->find($userid);
		}
	} else {
		$c->go("login"); 
	}
}

sub about :Local{
	my ( $self, $c ) = @_;
	$c->stash->{pagetitle} = 'このサイトについて - BESTGAMEON';

}
sub start :Local{
	my ( $self, $c ) = @_;
	$c->stash->{pagetitle} = 'はじめてのBESTGAMEON - BESTGAMEON';

}
sub advertise :Local{
	my ( $self, $c ) = @_;
	$c->stash->{pagetitle} = '広告掲載について - BESTGAMEON';

}

sub contact_send :Local{
	my ( $self, $c ) = @_;
}
sub contact :Local{
	my ( $self, $c ) = @_;
	$c->stash->{pagetitle} = 'ご質問・お問い合わせ - BESTGAMEON';

	$c->stash->{name} = '';
	$c->stash->{email} = '';
	$c->stash->{twitter_id} = '';
	$c->stash->{comment} = '';

	if ( $c->user_exists ) {
		$c->stash->{email} = $c->model('hsksyusk::ACCOUNT')->find($c->user->get('id_field'))->email;
		$c->stash->{twitter_id} = $c->user->get('twitter_user');
	}
	
	if ($c->req->method eq 'POST' ) {

		$c->stash->{username} = $c->req->param('name');
		$c->stash->{email} = $c->req->param('email');
		$c->stash->{twitter_id} = $c->req->param('twitter_id');
		$c->stash->{comment} = $c->req->param('comment');

		if ( $c->form->has_error ) {
			$c->stash->{messages} = $c->form->messages('contact');
			$c->stash->{error_flag} = 1;
		} else {
			$c->email( 
				From => 'contact@bestgameon.net',
				To => 'info@bestgameon.net',
				Subject => 'BESTGAMEONへの問い合わせ',
				Template => 'mail_contact.tt',
			);
			$c->stash->{pagetitle} = 'お問い合わせ完了 - BESTGAMEON';	
			$c->stash->{template} = 'contact_send.tt';
		}
	}

}

sub newranking_rss : Local {
	my ($self, $c) = @_;

	my $ua = $c->model('Net::Amazon');

	my $rss = new XML::RSS;

	$rss->channel(
		title => 'BESTGAMEON - 新着ランキング',
		link => 'http://bestgameon.net',
		language => 'ja',
		description => 'BESTGAMEON - 新着ランキング',
		dc => {
			date => DateTime::Format::W3CDTF->format_datetime( DateTime->now( time_zone => 'Asia/Tokyo' ) ),
		},
	);

	my $history = $c->model('hsksyusk::HISTORY')->search(
		{ 'draft_flag' => 0 },
		{
			order_by => { -desc => 'ranking_create' },
			rows => 100, 
		}
	);

	my $dt = new DateTime::Format::W3CDTF(time_zone => 'Asia/Tokyo');

	while ( my $item = $history->next ) {
		my $ranking = $c->model('hsksyusk::RANKING')->search(
			{ userid => $item->userid, },
			{ order_by => { -asc => 'rank' },} ,
		);
		my $description = "";
		while ( my $gameitem = $ranking->next ) {
			my $title = $ua->search(
				asin => $gameitem->asin,
				AssociateTag => 'bsrnvebm-22',
			)->properties->title();
			$description = $description . '<p>[' . $gameitem->rank . '位] <a href="http://bestgameon.net/game/' . $gameitem->asin . '" target="_blank" >' . $title . '</a></p>';
		}
		
		$rss->add_item(
			title       => $item->twitter_user->twitter_user . 'さんのランキング',
			link        => 'http://bestgameon.net/rank/' . $item->twitter_user->twitter_user,
			description => $description,
			dc => {
				date => $dt->format_datetime( $item->ranking_create ),
			},
		);
	}

	$c->stash->{rss} = $rss->as_string;
	$c->stash->{template} = 'rss.tt';
}

sub goodget_rss : Local : Args(1) {
	my ($self, $c) = @_;

	my $username = $c->req->args->[0];
	my $user = $c->model('hsksyusk::USER')
	  ->search({
		twitter_user => $username,
	});
	my $userid = $user->next->id_field;

	my $ua = $c->model('Net::Amazon');

	my $rss = new XML::RSS;
 
	$rss->channel(
		title => 'BESTGAMEON - ' . $username . 'さんの新着GOOD!',
		link => 'http://bestgameon.net/user/' . $username,
		language => 'ja',
		description => 'BESTGAMEON - ' . $username . 'さんの新着GOOD!',
		dc => {
			date => DateTime::Format::W3CDTF->format_datetime( DateTime->now( time_zone => 'Asia/Tokyo' ) ),
		},
	);

	my $get_good = $c->model('hsksyusk::GOOD')->search(
		{	to_userid => $userid, },
		{	
			order_by => { -desc => 'timestamp' },
			rows => 100, 
		},
	);
	
	my $dt = new DateTime::Format::W3CDTF(time_zone => 'Asia/Tokyo');

	while ( my $item = $get_good->next ) {
		
		my $from_username = $c->model('hsksyusk::USER')->find($item->from_userid)->twitter_user;
		my $rank = $c->model('hsksyusk::RANKING')
		  ->search({
			userid => $item->to_userid,
			asin => $item->asin,
		})->next->rank;
		my $title = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		)->properties->title();

		$rss->add_item(
			title       => $from_username . 'さんから [' . $rank . '位] ' . $title . 'にGOOD!をもらいました。',
			link        => 'http://bestgameon.net/rank/' . $username . '#rank' . $rank,
			description => $from_username . 'さんから [' . $rank . '位] ' . $title . 'にGOOD!をもらいました。',
			dc => {
				date => $dt->format_datetime( $item->timestamp ),
			},
		);
	}

	$c->stash->{rss} = $rss->as_string;
	$c->stash->{template} = 'rss.tt';
}

sub goodgive_rss : Local : Args(1) {
	my ($self, $c) = @_;

	my $username = $c->req->args->[0];
	my $user = $c->model('hsksyusk::USER')
	  ->search({
		twitter_user => $username,
	});
	my $userid = $user->next->id_field;

	my $ua = $c->model('Net::Amazon');

	my $rss = new XML::RSS;
 
	$rss->channel(
		title => 'BESTGAMEON - ' . $username . 'さんがつけた新着GOOD!',
		link => 'http://bestgameon.net/user/' . $username,
		language => 'ja',
		description => 'BESTGAMEON - ' . $username . 'さんがつけた新着GOOD!',
		dc => {
			date => DateTime::Format::W3CDTF->format_datetime( DateTime->now( time_zone => 'Asia/Tokyo' ) ),
		},
	);

	my $give_good = $c->model('hsksyusk::GOOD')->search(
		{	from_userid => $userid, },
		{	
			order_by => { -desc => 'timestamp' },
			rows => 100, 
		},
	);

	my $dt = new DateTime::Format::W3CDTF(time_zone => 'Asia/Tokyo');

	while ( my $item = $give_good->next ) {
		
		my $to_username = $c->model('hsksyusk::USER')->find($item->to_userid)->twitter_user;
		my $rank = $c->model('hsksyusk::RANKING')
		  ->search({
			userid => $item->to_userid,
			asin => $item->asin,
		})->next->rank;
		my $title = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		)->properties->title();

		$rss->add_item(
			title       => $to_username . 'さんの [' . $rank . '位] ' . $title . 'にGOOD!をつけました。',
			link        => 'http://bestgameon.net/rank/' . $to_username . '#rank' . $rank,
			description => $to_username . 'さんの [' . $rank . '位] ' . $title . 'にGOOD!をつけました。',
			dc => {
				date => $dt->format_datetime( $item->timestamp ),
			},
		);
	}

	$c->stash->{rss} = $rss->as_string;
	$c->stash->{template} = 'rss.tt';
}

sub resget_rss : Local : Args(1) {
	my ($self, $c) = @_;

	my $username = $c->req->args->[0];
	my $user = $c->model('hsksyusk::USER')
	  ->search({
		twitter_user => $username,
	});
	my $userid = $user->next->id_field;

	my $ua = $c->model('Net::Amazon');

	my $rss = new XML::RSS;
 
	$rss->channel(
		title => 'BESTGAMEON - ' . $username . 'さんの新着レス',
		link => 'http://bestgameon.net/user/' . $username,
		language => 'ja',
		description => 'BESTGAMEON - ' . $username . 'さんの新着レス',
		dc => {
			date => DateTime::Format::W3CDTF->format_datetime( DateTime->now( time_zone => 'Asia/Tokyo' ) ),
		},
	);

	my $get_comment = $c->model('hsksyusk::COMMENT')->search(
		{
			to_userid => $userid, 
			from_userid => { '!=' => $userid },
		},
		{	
			order_by => { -desc => 'timestamp' },
			rows => 100, 
		},
	);

	my $dt = new DateTime::Format::W3CDTF(time_zone => 'Asia/Tokyo');

	while ( my $item = $get_comment->next ) {
		
		my $from_username = $c->model('hsksyusk::USER')->find($item->from_userid)->twitter_user;
		my $rank = $c->model('hsksyusk::RANKING')
		  ->search({
			userid => $item->to_userid,
			asin => $item->asin,
		})->next->rank;
		my $title = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		)->properties->title();

		$rss->add_item(
			title       => $from_username . 'さんから [' . $rank . '位] ' . $title . 'にレスをもらいました。',
			link        => 'http://bestgameon.net/rank/' . $username . '#rank' . $rank,
			description => $item->comment,
			dc => {
				date => $dt->format_datetime( $item->timestamp ),
			},
		);
	}

	$c->stash->{rss} = $rss->as_string;
	$c->stash->{template} = 'rss.tt';
}

sub resgive_rss : Local : Args(1) {
	my ($self, $c) = @_;

	my $username = $c->req->args->[0];
	my $user = $c->model('hsksyusk::USER')
	  ->search({
		twitter_user => $username,
	});
	my $userid = $user->next->id_field;

	my $ua = $c->model('Net::Amazon');

	my $rss = new XML::RSS;
 
	$rss->channel(
		title => 'BESTGAMEON - ' . $username . 'さんがつけた新着レス',
		link => 'http://bestgameon.net/user/' . $username,
		language => 'ja',
		description => 'BESTGAMEON - ' . $username . 'さんがつけた新着レス',
		dc => {
			date => DateTime::Format::W3CDTF->format_datetime( DateTime->now( time_zone => 'Asia/Tokyo' ) ),
		},
	);

	my $give_comment = $c->model('hsksyusk::COMMENT')->search(
		{	from_userid => $userid, },
		{	
			order_by => { -desc => 'timestamp' },
			rows => 100, 
		},
	);

	my $dt = new DateTime::Format::W3CDTF(time_zone => 'Asia/Tokyo');

	while ( my $item = $give_comment->next ) {
		
		my $to_username = $c->model('hsksyusk::USER')->find($item->to_userid)->twitter_user;
		my $rank = $c->model('hsksyusk::RANKING')
		  ->search({
			userid => $item->to_userid,
			asin => $item->asin,
		})->next->rank;
		my $title = $ua->search(
			asin => $item->asin,
			AssociateTag => 'bsrnvebm-22',
		)->properties->title();

		$rss->add_item(
			title       => $to_username . 'さんの [' . $rank . '位] ' . $title . 'にレスをつけました。',
			link        => 'http://bestgameon.net/rank/' . $to_username . '#rank' . $rank,
			description => $item->comment,
			dc => {
				date => $dt->format_datetime( $item->timestamp ),
			},
		);
	}

	$c->stash->{rss} = $rss->as_string;
	$c->stash->{template} = 'rss.tt';
}


sub rules :Local {
	my ( $self, $c ) = @_;
}

sub privacypolicy :Local {
	my ( $self, $c ) = @_;
}

sub user_delete :Local {
	my ( $self, $c ) = @_;

	if ( $c->user_exists) {
		my $userid =  $c->user->get('id_field');
		
		$c->model('hsksyusk::ACCOUNT')->search({
			userid  => $userid,
		})->delete();
		$c->model('hsksyusk::HISTORY')->search({
			userid  => $userid,
		})->delete();
		$c->model('hsksyusk::PROFILE')->search({
			userid  => $userid,
		})->delete();
		$c->model('hsksyusk::RANKING')->search({
			userid  => $userid,
		})->delete();

		$c->model('hsksyusk::COMMENT')->search([
			{ from_userid  => $userid },
			{ to_userid => $userid },
		])->delete();
		$c->model('hsksyusk::FAVORITE')->search([
			{ from_userid  => $userid },
			{ to_userid => $userid },
		])->delete();
		$c->model('hsksyusk::GOOD')->search([
			{ from_userid  => $userid },
			{ to_userid => $userid },
		])->delete();
		
		$c->model('hsksyusk::USER')->search({
			id_field  => $userid,
		})->delete();

		$c->logout();
		$c->response->redirect("/");
	}

}


sub batch :Local {
	my ( $self, $c ) = @_;

	my $userid = 1;

	my $ranking = $c->model('hsksyusk::RANKING')
	  ->search({
		userid => $userid,
	});

	# テーブル結合してる。
	$c->response->body( $ranking->next->weight->weight );

}

sub default :Path {
	my ( $self, $c ) = @_;
	$c->response->body( 'Page not found' );
	$c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

User &

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
