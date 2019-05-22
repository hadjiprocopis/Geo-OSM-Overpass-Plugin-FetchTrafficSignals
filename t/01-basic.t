#!/usr/bin/env perl

use strict;
use warnings;

use lib 'blib/lib';

use Test::More;

use Geo::OSM::Overpass;
use Geo::OSM::Overpass::Plugin::FetchTrafficSignals;
use Geo::BoundingBox;

my $num_tests = 0;

my $bbox = Geo::BoundingBox->new();
ok(defined $bbox && 'Geo::BoundingBox' eq ref $bbox, 'Geo::BoundingBox->new()'.": called") or BAIL_OUT('Geo::BoundingBox->new()'.": failed, can not continue."); $num_tests++;
# this is LAT,LON convention
ok(1 == $bbox->bounded_by(
	[35.175699, 33.374037, 35.176120, 33.374745]
), 'bbox->bounded_by()'." : called"); $num_tests++;

my $eng = Geo::OSM::Overpass->new();
ok(defined $eng && 'Geo::OSM::Overpass' eq ref $eng, 'Geo::OSM::Overpass->new()'.": called") or BAIL_OUT('Geo::OSM::Overpass->new()'.": failed, can not continue."); $num_tests++;
$eng->verbosity(2);
ok(defined $eng->bbox($bbox), "bbox() called"); $num_tests++;

my $plug = Geo::OSM::Overpass::Plugin::FetchTrafficSignals->new({
	'engine' => $eng
});
ok(defined($plug) && 'Geo::OSM::Overpass::Plugin::FetchTrafficSignals' eq ref $plug, 'Geo::OSM::Overpass::Plugin::FetchTrafficSignals->new()'." : called"); $num_tests++;

ok(defined $plug->gorun(), "checking gorun()"); $num_tests++;

my $result = $eng->last_query_result();
ok(defined $result, "checking last_query_result()."); $num_tests++;
# saturn operator, see https://perlmonks.org/?node_id=11100099
ok(defined($result) && $$result =~ m|<node.+?id="37559112".+?>.*?<tag.+?v="traffic_signals".+?>|s, "checking result contains specific node."); $num_tests++;
ok(defined($result) && 1 == ( ()= $$result =~ m|<node.+?id=".+?".+?>|gs), "checking result contains exactly one node."); $num_tests++;

# END
done_testing($num_tests);
