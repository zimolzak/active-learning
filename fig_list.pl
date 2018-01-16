#!/usr/bin/perl -w
use strict;
while(<>){
    print if s/.*(fig[A-Z][A-Za-z]+).*/$1/;
    print if s/.*(table[A-Z][A-Za-z]+).*/$1/;
}
