#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;

sub quadBuildings {
	my ($quadName, $quadNameNext) = @_;
	my $baseURL = "http://classic.laundryview.com/lvs.php";
	my $raw = getData($baseURL);
	my @splitChunks = split(/<div class="h4" style="cursor:hand;cursor:pointer;" onclick="/m, $raw);

	my $i = 0;
	for my $chunk (@splitChunks) {
		$chunk =~ m/uptween\(['a-z0-9,]+\);">\s*(\w+-*\s*\w+)/g;
		if (defined $1) {
			my $found = $1;
			if ($found =~ /^$quadName$/) {
				print $found . "\n";
				my @buildingNames = ($splitChunks[$i] =~ m/<a href="laundry_room.php\?lr=[\d]+" class="\w-\w+">\s*(\w+\s*\w*\s*-*\s*\w*\s*\d*)/g);
				my @buildingCodes = ($splitChunks[$i] =~ m/<a href="laundry_room.php\?lr=(\d+)/g);
				my $c = 0;
				for my $n (@buildingNames) {
					print "\t" . $n . " (". $buildingCodes[$c++]. ")\n";
				}
				last;
			}
		}
		$i++;
	}
	#my %namesAndCodes;
	#$namesAndCodes{'names'} = [$];

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
	}

	#print $buildingQuads{"MENDELSOHN QUAD"}[1];

	#use Data::Dumper;
	#print Dumper %buildingQuads;
	#print scalar @{$buildingQuads{"ROTH QUAD"}};
}