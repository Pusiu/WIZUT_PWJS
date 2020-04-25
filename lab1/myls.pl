#!/usr/bin/perl

use Cwd;

$rootDir=cwd();
$printLong=0;
$printOwner=0;

for ($i=0; $i < scalar(@ARGV); $i++)
{
    if ($ARGV[$i] eq '-l')
    {
        $printLong=1;
    }
    elsif ($ARGV[$i] eq '-L')
    {
        $printOwner=1;
    }
    elsif (-d $ARGV[$i]) #check if it's a directory
    {
        $rootDir=$ARGV[$i];
    }
    else
    {
        print "Błąd, nieznany argument: $ARGV[$i] \nDozwolone argumenty to:\n-l\n-L\noraz nazwa lub ścieżka do istniejacego katalogu\n";
        exit;
    }
}

#print "Directory: $rootDir\nPrint long: $printLong\nPrint owner: $printOwner\n";

opendir $dir, $rootDir;

@entries = grep {$_ ne '.' and $_ ne '..'} readdir $dir;


foreach $entry(@entries)
{
    if ($printLong)
    {
        @s = stat($rootDir . "/" . $entry);
        print sprintf("%-30s\t", substr($entry,0,30));
        print sprintf("%10d\t", $s[7]);
        @time = localtime($s[10]);
        print sprintf("%04d-%02d-%02d %02d:%02d:%02d", $time[5]+1900, $time[4], $time[3], $time[2], $time[1], $time[0]) . "\t";
        $mode = @s[2] & 0777;

        (-d $rootDir . "/" . $entry) ? print "d" : print "-";
        for ($i=0; $i < 3; $i++)
        {
            (($mode) & (256 >> $i*3)) ? print "r" : print "-";
            (($mode) & (128 >> $i*3)) ? print "w" : print "-";
            (($mode) & (64 >> $i*3)) ? print "x" : print "-";
        }
    }
    else
    {
        print $entry;
    }

    if ($printOwner)
    {
        @s = stat($rootDir . "/" . $entry);
        $uid = $s[4];
        print " " . getpwuid($uid);
    }
    
    print "\n";
}

closedir $dir;
