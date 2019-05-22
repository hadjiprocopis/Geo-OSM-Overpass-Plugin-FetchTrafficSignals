package Geo::OSM::Overpass::Plugin::FetchTrafficSignals;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use parent 'Geo::OSM::Overpass::Plugin';

# returns undef on failure
sub gorun {
	my $self = $_[0];

	my $parent = ( caller(1) )[3] || "N/A";
	my $whoami = ( caller(0) )[3];

	my $eng = $self->engine();
	my $bbox = $eng->bbox();
	if( ! defined $bbox ){ print STDERR "$whoami (via $parent) : a bounding box was not specified via the engine.\n"; return undef }
	my $bbox_query = $bbox->stringify_as_OSM_bbox_query_xml();
	my $qu = $eng->_overpass_XML_preamble();
	$qu .= <<EOQ;
 <union>
  <query type='node'>
   <has-kv k='highway' v='traffic_signals'/>
   ${bbox_query}
  </query>
 </union>
EOQ
	$qu .= $eng->_overpass_XML_postamble();

	if( ! $eng->query($qu) ){ print STDERR "$whoami (via $parent) : call to query() has failed.\n"; return undef }
	return 1 # success
}

# end of program, pod starts here
=head1 NAME

Geo::OSM::Overpass::Plugin::FetchTrafficSignals - Plugin for L<Geo::OSM::Overpass> to fetch bus stop data in given area

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

This is a plugin for L<Geo::OSM::Overpass>, which is a module to fetch
data from the OpenStreetMap Project using Overpass API. It fetches
data about bus stops within a geographical area defined by a bounding
box. In order to use this plugin, first create a L<Geo::BoundingBox>
object for the bounding box enclosing the area. Secondly, create
a L<Geo::OSM::Overpass> object to do the communication with the
Overpass API server. Thirdly, create the plugin object and run
its C<gorun()> method.

    use Geo::BoundingBox;
    use Geo::OSM::Overpass;
    use Geo::OSM::Overpass::Plugin::FetchTrafficSignals;

    my $bbox = Geo::BoundingBox->new();
    # a bounding box bounded by (bottom-left-corner, top-right-corner) as LAT,LON
    $bbox->bounded_by(35.175699, 33.374037, 35.176120, 33.374745);
    my $eng = Geo::OSM::Overpass->new();
    die unless defined $eng;
    $eng->bbox($bbox) or die;
    my $plug = Geo::OSM::Overpass::Plugin::FetchTrafficSignals->new({
        'engine' => $eng
    });
    die unless defined $plug;
    $plug->gorun() or die;
    # print results, but it's a reference!
    print "Results: ".${$eng->last_query_result()}."\n";
    # prints:
    # <?xml version="1.0"?>
    # <osm version="0.6" generator="Overpass API 0.7.55.7 8b86ff77">
    # <note>The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.</note>
    # <meta osm_base="2019-05-15T22:24:03Z"/>
    # 
    #   <node id="37559112" lat="35.1759320" lon="33.3745372">
    #     <tag k="highway" v="traffic_signals"/>
    #   </node>
    # 
    # </osm>


=head1 SUBROUTINES/METHODS

=head2 C<< new({'engine' => $eng}) >>

Constructor. A hashref of parameters contains the
only required parameter which is an already created
L<Geo::OSM::Overpass> object. If in your plugin have
no use for this, then call it like C<new({'engine'=>undef})>


=head2 C<< gorun() >>

It will execute the query using the specified L<Geo::OSM::Overpass>
object (aka the engine) specified in the constructor.

It will return 1 on success or C<undef> on failure.

The result of the query can be accessed using ```print "Results: ".${eng->last_query_result()}."\n";```


=head1 AUTHOR

Andreas Hadjiprocopis, C<< <bliako at cpan.org> >>

=head1 CAVEATS

This is alpha release, the API is not yet settled and may change.

=head1 BUGS

Please report any bugs or feature requests to C<bug-geo-osm-overpass-plugin-FetchTrafficSignals at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Geo-OSM-Overpass-Plugin-FetchTrafficSignals>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Geo::OSM::Overpass::Plugin::FetchTrafficSignals


You can also look for information at:

=over 4

=item * L<Geo::BoundingBox> a geographical bounding box class.

=item * L<Geo::OSM::Overpass> aka the engine.

=item * L<Geo::OSM::Plugin> the parent class of all the plugins for
L<Geo::OSM::Overpass>

=item * L<https://www.openstreetmap.org> main entry point for the OpenStreetMap Project.

=item * L<https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide> Overpass API
query language guide.

=item * L<https://overpass-turbo.eu> Overpass Turbo query language online
sandbox. It can also convert to XML query language.

=item * L<http://overpass-api.de/query_form.html> yet another online sandbox and
converter.

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Geo-OSM-Overpass-Plugin-FetchTrafficSignals>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Geo-OSM-Overpass-Plugin-FetchTrafficSignals>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Geo-OSM-Overpass-Plugin-FetchTrafficSignals>

=item * Search CPAN

L<https://metacpan.org/release/Geo-OSM-Overpass-Plugin-FetchTrafficSignals>

=back


=head1 DEDICATIONS

Almaz

=head1 ACKNOWLEDGEMENTS

The OpenStreetMap project and all the good people who
thought it, implemented it, collected the data and
publicly host it.

```
 @misc{OpenStreetMap,
   author = {{OpenStreetMap contributors}},
   title = {{Planet dump retrieved from https://planet.osm.org }},
   howpublished = "\url{ https://www.openstreetmap.org }",
   year = {2017},
 }
```

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Andreas Hadjiprocopis.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=cut

1; # End of Geo::OSM::Overpass::Plugin::FetchTrafficSignals
