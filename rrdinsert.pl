#!/usr/bin/perl

# Generic tool to insert data into a RRD data base
# Creates first rrd file if it does not exist
# ./rrdinsert.pl path key value

use warnings;
use strict;
use RRDs;

sub rrdfile {
  my($dir,$label) = @_;

  return "$dir/$label.rrd";
}

sub rrdcreate {
  my($dir,$label) = @_;

  my $file = rrdfile $dir, $label;
  return if -w $file;
  my $start = time - 1;
  my $timeout = 1800;
  my $step = 300;
  my @ds = ( '--start', $start, '--step', $step );
  push @ds, "DS:$label:GAUGE:$timeout:U:U";
  # Interval - Duration  : interval=sec    -    duration=sec
  #   5 mins - 2 days    :      5*6=300    -     2*86400=172800
  #  30 mins - 2 weeks   :     30*60=1800  -    14*86400=1209600
  #  2 hours - 3 months  :   2*60*60=7200  -    92*86400=7948800
  #  6 hours - 1 year    :   6*60*60=21600 -   365*86400=31536000
  # 24 hours - 5 years   :  24*60*60=86400 - 5*365*86400=157680000
  my @intervals = (
    [ 300 => 172800 ],
    [ 1800 => 172800 ],
    [ 7200 => 7948800 ],
    [ 21600 => 31536000 ],
    [ 86400 => 157680000 ],
  );
  for my $i ( @intervals ) {
    my $interval = int $i->[0] / $step;
    my $duration = int 1.04 * $i->[1] / $step / $interval; # 4% bonus
    push @ds, "RRA:AVERAGE:0.5:$interval:$duration";
  }
  #warn "rrdtool create $file @ds\n";
  RRDs::create($file, @ds);
  warn RRDs::error if RRDs::error;
}

# Insert data into file
sub rrdupdate {
  my($dir,$label,$value) = @_;

  my $file = rrdfile $dir, $label;
  my @ds = "N:$value";
  #warn "rrdtool update $file @ds\n";
  RRDs::update($file, @ds);
  warn RRDs::error if RRDs::error;
}


my($dir,$label,$value) = @ARGV;
die "Usage: $0 dir key value\n" unless $dir and $label and $value;
die "Usage: $0 dir key value\n" unless $label =~ s/\D+/;
rrdcreate $dir, $label, $value;
rrdupdate $dir, $label, $value;
