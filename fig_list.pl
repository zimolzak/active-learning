#!/usr/bin/perl -w
use strict;
while(<>){
    print if s/.*(~~[a-zA-Z]+).*/$1/;
}
