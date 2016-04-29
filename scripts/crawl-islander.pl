#! /usr/bin/env perl

use strict;
use Carp;
use URI::Escape;

my $usage = "Usage: $0 > org_acc_beg_end_len_island_url.txt\n\n";

get_main_list();

sub get_main_list {
    my $url = 'http://bioinformatics.sandia.gov/islander/genomes.html';
    # my $htm = `curl -s $url |tee genomes.html`;
    my $htm = `cat genomes.html`;
    my @lines = split(/\n/, $htm);
    my $found = 0;
    my $raw_dir = 'data/islander/raw';
    for (@lines) {
        next unless $found || /Island Count/;
        last if $found && /table>/;
        $found = 1;
        my ($term) = /term=(\d+)/;
        my ($link) = m|href="(http://bioinformatics.sandia.gov/islander/cgi-bin/.*?)">|;
        next unless $link;
        # print join("\t", $term, $link) . "\n";
        # my ($org) = $link =~ /lineage=(\S+)/;
        # run("curl \"$link\" > $raw_dir/$term.htm") unless -s "$raw_dir/$term.htm";
    }
    my @raw = `ls $raw_dir`;
    for my $htm (@raw) {
        for (`grep island.cgi $raw_dir/$htm`) {
            my ($url) = m|href="(http.*?)">|;
            my ($id) = $url =~ /island=(\S+)/;
            my $htm = `curl -s '$url' |tee temp.html`;
            my ($org) = $htm =~ /Host.*"taxa">(.*?)</;
            my ($acc) = $htm =~ /accession:.*nc=(.*?)">/;
            my ($len) = $htm =~ /Length:.*?(\d+) bp</;
            my ($beg, $end) = $htm =~ /coordinates.*?(\d+)\.\.(\d+)</;
            print join("\t", $org, $acc, $beg, $end, $len, $id, $url) . "\n";
        }
    }
}

sub run { system(@_) == 0 or confess("FAILED: ". join(" ", @_)); }
