#! /usr/bin/perl

use warnings;
use strict;

# Autor: Basil Marti (basil.marti@unbas.ch)
# Script zur Analyse von falschen Unterfeldern $$6 in Feld 880
# Argument 1: Alma Sequential Datei mit 880-Feldern, die zu korrigieren sind
# Argument 2: Alma Sequential Datei mit 8xx-Feldern, die mit den falschen 880 Feldern verknüpft sind
# Argument 3: Alma Sequential Datei mit allen falsch verknüpften 880-Feldern

die "Argumente: $0 Input (880), Input (8xx), Output\n" unless @ARGV == 3;


my($input1file,$input2file,$outputfile) = @ARGV;

open my $handle1, '<', $input1file or die "$0: open $input1file: $!";
chomp(my @lines1 = <$handle1>);
close $handle1;

open my $handle2, '<', $input2file or die "$0: open $input2file: $!";
chomp(my @lines2 = <$handle2>);
close $handle2;

open my $out, ">", $outputfile or die "$0: open $outputfile: $!";

for (@lines1) {

    my $found;

    my $sys = substr($_,0,9);
    my $sf6 = substr($_,21,6);

    my $sf6_tag = substr($sf6,0,3);
    my $sf6_seq = substr($sf6,4,2);

    #print $sf6_tag . "\n";
    #print $sf6_seq . "\n";
    
    for (@lines2) {

        my $sys_2 = substr($_,0,9);
        my $tag_2 = substr($_,10,3);
        my $sf6_2 = substr($_,21,6);
    
        my $sf6_tag_2 = substr($sf6_2,0,3);
        my $sf6_seq_2 = substr($sf6_2,4,2);

        if ($sys eq $sys_2 && $sf6_tag eq $tag_2 && $sf6_seq eq $sf6_seq_2  ) {
             $found = 1;
        }
    }

    # Ausgabe des 880-Feldes in Inputdatei 1, falls kein dazugehöriges 8xx-Feld existiert (basierend auf Abgleich mit $$6)
    print $out  $_ . "\n" unless $found;
}

close $out or warn "$0: close $outputfile:: $!";

