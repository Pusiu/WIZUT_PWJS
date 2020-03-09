#!/usr/bin/perl

use Cwd;

$rootDir=cwd();
$printLong=false;
$printOwner=false;

for ($i=0; $i < scalar(@ARGV); $i++)
{
    if ($ARGV[$i] eq '-l')
    {
        $printLong=true;
    }
    elsif ($ARGV[$i] eq '-L')
    {
        $printOwner=true;
    }
    elsif (-d $ARGV[$i]) #check if it's a directory
    {
        $rootDir=$ARGV[$i];
    }
    else
    {
        print "Nieznany argument: $ARGV[$i] \n";
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
        print sprintf("%-30s\t", $entry);
        print $s[7] . "\t";
        @time = localtime($s[10]);
        print sprintf("%d-%02d-%02d %02d:%02d:%02d", $time[5]+1900, $time[4], $time[3], $time[2], $time[1], $time[0]) . "\t";
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