#!/usr/bin/perl

start:
print "Podaj nazwę pliku źródłowego: ";
$filename = <STDIN>;
#$filename = "WIPING5.html";
chop $filename;
unless (-e $filename)
{
    print "Podany plik nie istnieje\n";
    goto start;
}

@matches;
%foundUsers;
open $file, $filename;

@titles;

while(defined($line=<$file>))
{
    if (@tm = $line =~ />(WIPING.+?)<\/a>/gm)
    {
        @titles = @tm;
        foreach $t(@titles)
        {
            $t =~ s/(\w+)/"$1"/;
        }
    }
    
    if (@m = $line =~ /<tr class="problemrow">.*?<a href=".+?users\/(.+?)">(.*?)<\/a>(.+?<\/td><\/tr>)/gm)
    {
     @matches = @m;
    }
}
for ($i=0; $i < scalar(@matches);$i+=3)
{
    my @submatches = $matches[$i+2] =~ /(?:.+?>(?=[^ ])(.{1,5})<)/gm;
    foreach $sm(@submatches)
    {
        $sm =~ s/\./,/;
        $sm =~ s/-/0,0/;
        $sm = "\"$sm\",";
    }
    #print "$matches[$i+1] ($matches[$i]): @submatches\n";

    $foundUsers{$matches[$i]}="\"$matches[$i+1]\",\"$matches[$i]\"," . join("",@submatches) . "\n";
    #print $foundUsers{$matches[$i]};
}

open $output, '>', "output.csv";
print {$output} '"Nazwa zawodnika","Nazwa konta",';
foreach $t(@titles)
{
    print {$output} "$t,"; 
}
print {$output} '"SOL","SCORE"' . "\n";


userFileLabel:
print "Podaj nazwę pliku z listą użytkowników, lub wciśnij enter jeśli takiej nie ma: ";
$usersFile = <STDIN>;
chop $usersFile;
if ($usersFile ne "")
{
    unless (-e $usersFile)
    {
        print "Podany plik nie istnieje\n";
        goto userFileLabel;
    }
    open $uf, $usersFile;
    while(defined($l=<$uf>))
    {
        $l =~ s/\n//;
        if (exists($foundUsers{$l}))
        {
            print {$output} $foundUsers{$l};
        }
        else
        {
            print "Nie znaleziono $l\n";
        }
    }
    close ($uf);
}
else
{
    foreach $u(keys %foundUsers)
    {
        print {$output} $foundUsers{$u};
    }
}

close $output;
close $file;