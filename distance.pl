#!/usr/bin/perl

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::                                                                         :::
#:::  This routine calculates the distance between two points (given the     :::
#:::  latitude/longitude of those points). It is being used to calculate     :::
#:::  the distance between two locations using GeoDataSource(TM) products    :::
#:::                                                                         :::
#:::  Definitions:                                                           :::
#:::    South latitudes are negative, east longitudes are positive           :::
#:::                                                                         :::
#:::  Passed to function:                                                    :::
#:::    lat1, lon1 = Latitude and Longitude of point 1 (in decimal degrees)  :::
#:::    lat2, lon2 = Latitude and Longitude of point 2 (in decimal degrees)  :::
#:::    unit = the unit you desire for results                               :::
#:::           where: 'M' is statute miles (default)                         :::
#:::                  'K' is kilometers                                      :::
#:::                  'N' is nautical miles                                  :::
#:::                                                                         :::
#:::  Worldwide cities and other features databases with latitude longitude  :::
#:::  are available at https://www.geodatasource.com	                     :::
#:::                                                                         :::
#:::  For enquiries, please contact sales@geodatasource.com                  :::
#:::                                                                         :::
#:::  Official Web site: https://www.geodatasource.com                       :::
#:::                                                                         :::
#:::            GeoDataSource.com (C) All Rights Reserved 2018               :::
#:::                                                                         :::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

my $pi = atan2(1,1) * 4;

sub distance {
  my ($lat1, $lon1, $lat2, $lon2, $unit) = @_;
  if (($lat1 == $lat2) && ($lon1 == $lon2)) {
    return 0;
  }
  else {
    my $theta = $lon1 - $lon2;
    my $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
    $dist  = acos($dist);
    $dist = rad2deg($dist);
    $dist = $dist * 60 * 1.1515;
    if ($unit eq "K") {
      $dist = $dist * 1.609344;
    } elsif ($unit eq "N") {
      $dist = $dist * 0.8684;
    }
    return ($dist);
  }
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function get the arccos function using arctan function   :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub acos {
  my ($rad) = @_;
  my $ret = atan2(sqrt(1 - $rad**2), $rad);
  return $ret;
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts decimal degrees to radians             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub deg2rad {
  my ($deg) = @_;
  return ($deg * $pi / 180);
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts radians to decimal degrees             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub rad2deg {
  my ($rad) = @_;
  return ($rad * 180 / $pi);
}

#print distance(32.9697, -96.80322, 29.46786, -98.53506, "M") . " Miles\n";
#print distance(32.9697, -96.80322, 29.46786, -98.53506, "K") . " Kilometers\n";
#print distance(32.9697, -96.80322, 29.46786, -98.53506, "N") . " Nautical Miles\n";

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::                                                                         :::
#:::            Copyrights Francesco Ansanelli 2020                          :::
#:::                                                                         :::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

my @impianti;
my @keys;
my $n_impianti = 0;

open(f1, "<$ARGV[0]");
while (my $line1 = <f1>) {
  chomp($line1);
  #         0       1        2             3            4          5      6         7          8           9
  #idImpianto;Gestore;Bandiera;Tipo Impianto;Nome Impianto;Indirizzo;Comune;Provincia;Latitudine;Longitudine
  my @values1 = split(";", $line1, -1);
  if (scalar(@values1)>9) {
    if ($values1[0] ne 'idImpianto' && $values1[8] ne 'NULL' && $values1[9] ne 'NULL') {
      push @keys, $values1[0];
      push @impianti, [$values1[8], $values1[9]];
      $n_impianti = $n_impianti + 1;
    }
  }
}
close(f1);

for (my $i = 0; $i < $n_impianti - 1; $i++) {
  for (my $j = $i + 1; $j < $n_impianti; $j++) {
    my $id_1 = $keys[$i];
    my $id_2 = $keys[$j];
    my @impianto_1 = $impianti[$i];
    my @impianto_2 = $impianti[$j];
    my $m = distance($impianto_1[0][0], $impianto_1[0][1], $impianto_2[0][0], $impianto_2[0][1], "K") * 1000;
    if ($m < 50) {
      print "$id_1 - $id_2 distano $m mt\n";
    }
  }
}

print "done"
