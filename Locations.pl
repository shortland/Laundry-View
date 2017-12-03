#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;
use Path::Tiny;
use JSON;

sub renewLocationData {
	my @quads = quadNames();
	my $jsonObj = {quads => []};
	for (my $i = 0; $i < scalar(@quads); $i++) {
		$jsonObj = quadBuildings($quads[$i], $jsonObj);
	}
	path("location_data.json")->spew(encode_json($jsonObj));
	return "location_data.json has been refreshed with new data\n";
}

sub quadBuildings {
	my ($quadName, $jsonObj) = @_;
	my $baseURL = "http://classic.laundryview.com/lvs.php";
	my $raw = getData($baseURL);
	my @splitChunks = split(/<div class="h4" style="cursor:hand;cursor:pointer;" onclick="/m, $raw);

	my $i = 0;
	for my $chunk (@splitChunks) {
		$chunk =~ m/uptween\(['a-z0-9,]+\);">\s*(\w+-*\s*\w+)/g;
		if (defined $1) {
			my $found = $1;
			if ($found =~ /^$quadName$/) {
				my @buildingNames = ($splitChunks[$i] =~ m/<a href="laundry_room.php\?lr=[\d]+" class="\w-\w+">\s*(\w+\s*\w*\s*-*\s*\w*\s*\d*)/g);
				for my $buildingName (@buildingNames) {
					$buildingName =~ s/\s+$//;
				}
				my @buildingCodes = ($splitChunks[$i] =~ m/<a href="laundry_room.php\?lr=(\d+)/g);
				my $obj = {name => $found, buildings => [@buildingNames], ids => [@buildingCodes]};
				push(@{$jsonObj->{quads}}, $obj); 
				last;
			}
		}
		$i++;
	}
	return $jsonObj;
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
	print renewLocationData();
}