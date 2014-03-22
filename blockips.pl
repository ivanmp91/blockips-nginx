#!/usr/bin/env perl
use strict;
use warnings;

use LWP::Simple;
use Digest::MD5;

my $url="http://www.badips.com/get/list/wordpress/";
my $tmp_file="/tmp/blockips.conf";
my $nginx_conffile="/etc/nginx/conf.d/blockips.conf";
my $script_name=$0;

my $response= get($url) or die "Cannot get bad ip list";
my @ip_list=split('\n',$response);

if(scalar(@ip_list) > 0){
	my $tmp_fh;
	open($tmp_fh,">",$tmp_file) or die "Cannot open temporary file";
	foreach(@ip_list){
		print $tmp_fh "deny ".$_.";\n";
	}
	close $tmp_fh;
	my $nginx_md5=md5sum($nginx_conffile);
	my $tmp_md5=md5sum($tmp_file);
	if($nginx_md5 ne $tmp_md5){
		system("/bin/cp $tmp_file $nginx_conffile");
		my $reload_exit=&nginx_reload;
		if($reload_exit){
			&git_commit;
		}
		else{
			&git_revert($nginx_conffile);
			&nginx_reload;
		}
	}
}

sub md5sum{
	my $file=shift;
	my $digest="";
	open(FH,$file) or die "Can't open file for md5sum\n";
	my $md5=Digest::MD5->new;
	$md5->addfile(*FH);
	$digest=$md5->hexdigest;
	close(FH);

	return $digest;
}

sub nginx_reload{
	my $check_conf=system("/usr/sbin/nginx -t");
	if($check_conf==0){
		system("/usr/sbin/nginx -s reload");
		return 1;
	}
	else{
		return 0;
	}
}

sub git_commit{
	system("/usr/bin/etckeeper commit \"nginx blocked ip list updated by $script_name\"");
}

sub git_revert{
	my $file=shift;
	system("/usr/bin/etckeeper vcs checkout $file");
}

