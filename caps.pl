#!/usr/bin/perl -w
use strict;
while(<>){
    print if s/.*?([A-Z]{2,}).*/$1/;
}
