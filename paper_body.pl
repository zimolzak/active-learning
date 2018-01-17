#!/usr/bin/perl -w
use strict;
my $printme = 0;
while(<>){
    $printme = 1 if /^Background/;
    $printme = 0 if /^References/;
    print if $printme;
}
