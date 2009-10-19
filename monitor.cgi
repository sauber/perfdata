#!/usr/bin/perl

use warnings;
use strict;
use RRDs;
use CGI qw/:standard *table/;

our $path = '/data/projects/perfdata';

sub rrdfilelist {
  our @files;
  unless ( @files ) {
    opendir DH, $path;
      @files = grep s/.rrd$//, readdir DH;
    closedir DH;
  }
  return @files;
}

sub rrdimg {
  my($file,$period) = @_;
  my %span = (
    1 => int(-24*60*60*1.15),
    2 => int(-7*24*60*60*1.15),
    3 => int(-31*24*60*60*1.15),
    4 => int(-365*24*60*60*1.15),
  );
  $| = 1; # Send header before data
  my($caption,$color,@options);
  if ( $file =~ /load/ ) {
    $caption = 'System Load';
    $color = '#cf0000';
    @options = ();
  } else {
    $caption = 'Temperature (C)';
    $color = '#0000cf';
    @options = ( '-u', 80, '-l', 40,, '-r' );
  }
  print header(-type => "image/png");
  #  '-u', 100, '-l', 0,, '-r',
  my @ds = (
    '-', '-a', 'PNG', '--start', $span{$period},
    '-w', 200, '-h', 100,
    @options,
    "DEF:a=$path/$file.rrd:$file:AVERAGE", 
    "LINE2:a$color:$caption",
  );
  #warn "rrdgraph @ds\n";
  RRDs::graph(@ds);
  warn RRDs::error if RRDs::error;
}

sub rrdlink {
  my($file,$period) = @_;

  "<img src='?file=$file&period=$period' alt='file=$file period=$period'>"
}

sub mainpage {
  header,
  start_html(
     -title => "saubermon",
     -head => meta({ -http_equiv => "Refresh", -content => "300" }),
  ),
  h2('Temperature graphs'),
  table(
    Tr(
      map th($_), qw(Disk Daily Weekly Monthly Yearly)
    ),
    map {
      my $g = $_;
      Tr(
        th($g),
        map td(rrdlink($g, $_)), qw(1 2 3 4)
      )
    } sort(rrdfilelist())
  ),
  end_html,
  "\n";
}

if (param()) {
  rrdimg(param('file'),param('period'));
} else {
  print mainpage;
}
