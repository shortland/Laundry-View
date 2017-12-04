#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;
use Path::Tiny;
use JSON qw(encode_json);
use CGI::Carp qw(fatalsToBrowser);
use CGI;

sub renewLocationData {
	my ($school, $ua) = @_;
	my @quads = quadNames($ua);
	if ($quads[0] =~ /^DEMO LOCATION$/) {
		return "Host not using campus WIFI. Please define a campus.</br>\n";
	}
	elsif ($quads[0] =~ /^$/) {
		return "Error fetching data</br>\n";
	}
	my $jsonObj = {quads => []};
	for (my $i = 0; $i < scalar(@quads); $i++) {
		$jsonObj = quadBuildings($quads[$i], $jsonObj, $ua);
	}
	path("js/location_data.json")->spew(encode_json($jsonObj));
	chmod 0777, "js/location_data.json" or die "Couldn't chmod js/location_data.json: $!";
	return "location_data.json has been refreshed with new data</br>\n";
}

sub quadBuildings {
	my ($quadName, $jsonObj, $ua) = @_;
	my $baseURL = "http://laundryview.com/lvs.php?s=2376";
	my $raw = getData($baseURL, $ua);
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
	my ($ua) = @_;
	my $baseURL = "http://laundryview.com/lvs.php?s=2376";
	my $raw = getData($baseURL, $ua);
	my @names = ($raw =~ m/<div class=\"h4\" style=\"cursor:hand;cursor:pointer;\" onclick="[\S]+">[\s]+([\S]+\s?[\S]+)/g);
	return @names;
}

sub setSession {
	my ($school) = @_;
	my $request = HTTP::Request->new(GET => "http://laundryview.com/" . $school);
	my $ua = LWP::UserAgent->new;
	$ua->cookie_jar({});
	$ua->request($request);
	return $ua;
}

sub getData {
	my ($url, $ua) = @_;
	my $request = HTTP::Request->new(GET => $url);
	my $response = $ua->request($request)->content;
	return $response;
}

BEGIN {
	my $cgi = new CGI;
	print $cgi->header(-type => "text/html");

	my $defaultSchool = "stonybrook";

	if (defined $cgi->param("s")) {
		$defaultSchool = $cgi->param("s");
	}

	my $capitalizeSchool = uc(substr($defaultSchool, 0, 1)) . substr($defaultSchool, 1);
	print my $html = 
qq{<!DOCTYPE html>
<html lang="en">
<head>
	<title>$capitalizeSchool Alerts</title>
	<link rel="manifest" href="js/manifest.json">
	<meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />
	<script type="text/javascript" src='js/jquery.js'></script>
	<script type="text/javascript" src='js/jquery_colors.js'></script>
	<script type="text/javascript" src='js/script.js'></script>
	<link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
	<center>
		<h3>School: <i>$capitalizeSchool</i></h3>
	</center>
</body>
</html>};
	print renewLocationData($defaultSchool, setSession($defaultSchool));
}