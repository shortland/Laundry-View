#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;

sub quadBuildings {
	my ($quadName, $quadNameNext) = @_;
	my $baseURL = "http://classic.laundryview.com/lvs.php";
	my $raw = getData($baseURL);
	my @splitLine = split(/<div class="h4" style="cursor:hand;cursor:pointer;" onclick="/m, $raw);
	use Data::Dumper;
	print Dumper @splitLine;
	
	return ("apple", "orange", "potato");
}

sub quadNames {
	my $baseURL = "http://classic.laundryview.com/lvs.php";
	my $raw = getData($baseURL);
	my @names = ($raw =~ m/<div class=\"h4\" style=\"cursor:hand;cursor:pointer;\" onclick="[\S]+">[\s]+([\S]+\s?[\S]+)/g);
	return @names;
}

sub getData {
	my ($url) = @_;
	my $request = HTTP::Request->new(GET => $url);
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request($request)->content();
	return $response;
}

BEGIN {
	my %buildingQuads;
	my @quads = quadNames();

	for (my $i = 0; $i < scalar(@quads); $i++) {
		$buildingQuads{$quads[$i]} = [quadBuildings($quads[$i], $quads[$i+1])];
		last;
	}

	print $buildingQuads{"MENDELSOHN QUAD"}[1];

	#use Data::Dumper;
	#print Dumper %buildingQuads;
	#print scalar @{$buildingQuads{"ROTH QUAD"}};
}