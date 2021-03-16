#! /usr/bin/perl

use warnings;
use strict;

# Autor: Basil Marti (basil.marti@unbas.ch)
# Script zur Korrektur von falschen Unterfeldern $$6 in Feld 880
# Argument 1: Alma Sequential Datei mit 880-Feldern, die zu korrigieren sind
# Argument 2: Alma Sequential Datei mit 8xx-Feldern, die mit den falschen 880 Feldern verknüpft sind
# Argument 3: MARCXML-Datei mit allen 880-Feldern mit korrigiertem Unterfeld $$6

die "Argumente: $0 Input (880), Input (8xx), Output\n" unless @ARGV == 3;

my($input1file,$input2file,$outputfile) = @ARGV;

open my $handle1, '<:utf8', $input1file or die "$0: open $input1file: $!";
chomp(my @lines1 = <$handle1>);
close $handle1;

open my $handle2, '<:utf8', $input2file or die "$0: open $input2file: $!";
chomp(my @lines2 = <$handle2>);
close $handle2;

open my $out, ">:utf8", $outputfile or die "$0: open $outputfile: $!";

my $sys_prev;

for (@lines1) {

    my $line = $_;

    my $sys = substr($_,0,18);  
    #print $sys . "\n";
    my $sf6 = substr($_,30,6);
    #print $sf6 . "\n";

    my $ind_1 = substr($_,22,1);
    my $ind_2 = substr($_,23,1);
    
    my $sf6_tag = substr($sf6,0,3);
    my $sf6_seq = substr($sf6,4,2);

    #print $sf6_tag . "\n";
    #print $sf6_seq . "\n";
    
    for (@lines2) {

        my $sys_2 = substr($_,0,18);
        my $tag_2 = substr($_,19,3);
        my $sf6_2 = substr($_,30,6);
    
        my $sf6_tag_2 = substr($sf6_2,0,3);
        my $sf6_seq_2 = substr($sf6_2,4,2);

        if ($sys eq $sys_2 && $sf6_tag eq $tag_2 && $_ =~ /\$\$6/  ) {
            unless ( $sf6_seq eq $sf6_seq_2 ) {
                #print $sf6_seq . "-";
                # Korrektur von Sequenz in Unterfeld $6 falls Systemnummer und Feldnummer in $6 übereinstimmen
                substr($line,34,2) = $sf6_seq_2; 
                #print $sf6_seq_2 . "\n";
            }
        }
    }
   
    #Ausgabe der korrigierten Aufnahme als minimale MARCXML Aufnahme (nur mit Leader, 001 und korrigiertem 880)
    my $subfields = substr($line,27);
    
    $subfields =~ s/&/&amp;/sg;
    $subfields =~ s/</&lt;/sg;
    $subfields =~ s/>/&gt;/sg;
    $subfields =~ s/"/&quot;/sg;

    $subfields =~ s/\$\$(.)/<\/subfield><subfield code="\1">/g;
    $subfields =~ s/$/<\/subfield>/g;
    $subfields =~ s/^<\/subfield>//g;


    if ( $sys eq $sys_prev ) {
    
        print $out '<datafield tag="880" ind1="' . $ind_1 . '" ind2="' . $ind_2 . '">' . $subfields . '</datafield>' . "\n";
    
    } else {

        print $out '</marc:record>' . "\n";
        print $out '<marc:record xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"><leader>01094nam a2200361 a 4500</leader>' . "\n";
        print $out '<controlfield tag="001">' . $sys . '</controlfield>' .  "\n";
        print $out '<datafield tag="880" ind1="' . $ind_1 . '" ind2="' . $ind_2 . '">' . $subfields . '</datafield>' . "\n";

    }
   
    $sys_prev = $sys;

}

close $out or warn "$0: close $outputfile:: $!";

