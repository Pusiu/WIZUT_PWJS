#!/usr/bin/perl

$usersFile = '';
if ($ARGV[0] ne '')
{
    print STDERR "Określono plik z użytkownikami:  $ARGV[0]\n";
    $usersFile = $ARGV[0];
}

if (-t STDIN and -t STDOUT and scalar(@ARGV) eq 0 )
{
    print "Użycie: ./parser.pl [opcjonalna nazwa pliku z użytkownikami] < [plik wejściowy] > [plik wyjściowy]\n";
    exit;
}

if (-t STDIN)
{
    start:
    print STDERR "Podaj nazwę pliku źródłowego: ";
    $filename = <STDIN>;
    #$filename = "WIPING5.html";
    chop $filename;

    if ($filename eq '' )
    {
        print STDERR "Należy podać odpowiedni plik na stdin\n";
        goto start;
    }

    if (not -e $filename)
    {
        print STDERR "Podany plik $filename nie istnieje\n";
        goto start;
    }
    open $file, "<", $filename;
}
else
{
    $file=STDIN;
}


@matches;
%foundUsers;
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
    $foundUsers{$matches[$i]}="\"$matches[$i+1]\",\"$matches[$i]\"," . join("",@submatches) . "\n";
}


$output = *STDOUT;
print {$output} '"Nazwa zawodnika","Nazwa konta",';
foreach $t(@titles)
{
    print {$output} "$t,"; 
}
print {$output} '"SOL","SCORE"' . "\n";

if ($usersFile ne "")
{
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
            print STDERR "Nie znaleziono $l\n";
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
if (-t STDOUT)
{
    print STDERR "\nZawartość została wypisana na ekran, ponieważ nie przekierowano wyjścia do pliku\n";
}
else
{
    print STDERR "Zawartość została wypisana do pliku\n";
}
close $output;
close $file;